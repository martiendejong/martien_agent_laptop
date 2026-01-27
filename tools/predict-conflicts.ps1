<#
.SYNOPSIS
    ML-based conflict prediction using file edit sequences

.DESCRIPTION
    Predicts potential conflicts by learning file edit patterns:
    - Customer.cs → CustomerService.cs → ICustomerRepository.cs
    - When Agent X edits Customer.cs, predict they'll edit CustomerService.cs next
    - Warn Agent Y who is currently editing CustomerService.cs

    Uses transition probability matrices (Markov chain approach).

.PARAMETER Learn
    Learn patterns from file_modifications table

.PARAMETER Predict
    Predict next files based on current edit

.PARAMETER CurrentFile
    File currently being edited (for prediction)

.PARAMETER AgentId
    Agent ID (for prediction context)

.PARAMETER ShowMatrix
    Show transition probability matrix

.EXAMPLE
    .\predict-conflicts.ps1 -Learn

.EXAMPLE
    .\predict-conflicts.ps1 -Predict -CurrentFile "Customer.cs" -AgentId "agent-001"
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$Learn,

    [Parameter(Mandatory=$false)]
    [switch]$Predict,

    [Parameter(Mandatory=$false)]
    [string]$CurrentFile,

    [Parameter(Mandatory=$false)]
    [string]$AgentId,

    [Parameter(Mandatory=$false)]
    [switch]$ShowMatrix
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Predictive Conflict Detection" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

# Create file_sequences table if not exists
$createTable = @"
CREATE TABLE IF NOT EXISTS file_sequences (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    from_file TEXT NOT NULL,
    to_file TEXT NOT NULL,
    transition_count INTEGER DEFAULT 1,
    last_seen TEXT NOT NULL,
    probability REAL DEFAULT 0.0,
    UNIQUE(from_file, to_file)
);
CREATE INDEX IF NOT EXISTS idx_file_seq_from ON file_sequences(from_file);
"@
Invoke-Sql -Sql $createTable

if ($Learn) {
    Write-Host "🧠 Learning file edit patterns..." -ForegroundColor Cyan
    Write-Host ""

    # Get file modification sequences per agent session
    $sql = @"
SELECT agent_id, file_path, timestamp
FROM file_modifications
WHERE operation = 'edit'
AND timestamp > datetime('now', '-90 days')
ORDER BY agent_id, timestamp;
"@

    $modifications = Invoke-Sql -Sql $sql

    if (-not $modifications) {
        Write-Host "⚠️ No file modifications found to learn from" -ForegroundColor Yellow
        Write-Host ""
        exit 0
    }

    $currentAgent = ""
    $lastFile = ""
    $transitionsLearned = 0

    $modifications -split "`n" | ForEach-Object {
        if ($_ -match '\|') {
            $parts = $_ -split '\|'
            $agent = $parts[0]
            $file = $parts[1]
            $timestamp = $parts[2]

            # Extract just filename for simpler patterns
            $fileName = Split-Path $file -Leaf

            if ($agent -eq $currentAgent -and $lastFile -ne "" -and $lastFile -ne $fileName) {
                # Record transition
                $fromEscaped = $lastFile -replace "'", "''"
                $toEscaped = $fileName -replace "'", "''"
                $now = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")

                $upsertSql = @"
INSERT INTO file_sequences (from_file, to_file, transition_count, last_seen)
VALUES ('$fromEscaped', '$toEscaped', 1, '$now')
ON CONFLICT(from_file, to_file) DO UPDATE SET
    transition_count = transition_count + 1,
    last_seen = '$now';
"@
                Invoke-Sql -Sql $upsertSql
                $transitionsLearned++
            }

            $currentAgent = $agent
            $lastFile = $fileName
        }
    }

    # Calculate probabilities
    Write-Host "📊 Calculating transition probabilities..." -ForegroundColor Cyan

    $updateProbSql = @"
UPDATE file_sequences
SET probability = CAST(transition_count AS REAL) / (
    SELECT SUM(transition_count)
    FROM file_sequences fs2
    WHERE fs2.from_file = file_sequences.from_file
);
"@
    Invoke-Sql -Sql $updateProbSql

    Write-Host ""
    Write-Host "✅ Learning complete!" -ForegroundColor Green
    Write-Host "   Transitions learned: $transitionsLearned" -ForegroundColor Gray
    Write-Host ""
}

if ($ShowMatrix) {
    Write-Host "📊 Transition Probability Matrix:" -ForegroundColor Cyan
    Write-Host ""

    $sql = "SELECT from_file, to_file, transition_count, probability FROM file_sequences WHERE probability >= 0.3 ORDER BY probability DESC LIMIT 30;"
    $matrix = Invoke-Sql -Sql $sql

    if ($matrix) {
        Write-Host "  From File → To File (Probability)" -ForegroundColor Gray
        Write-Host "  ─────────────────────────────────" -ForegroundColor DarkGray
        Write-Host ""

        $matrix -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $from = $parts[0]
                $to = $parts[1]
                $count = $parts[2]
                $prob = [decimal]$parts[3]
                $probPercent = [math]::Round($prob * 100)

                $color = if ($prob -ge 0.7) { 'Green' } elseif ($prob -ge 0.5) { 'Yellow' } else { 'White' }

                Write-Host "  $from → $to " -ForegroundColor White -NoNewline
                Write-Host "($probPercent%)" -ForegroundColor $color -NoNewline
                Write-Host " [$count times]" -ForegroundColor DarkGray
            }
        }
        Write-Host ""
    } else {
        Write-Host "  No patterns learned yet" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Learn patterns with:" -ForegroundColor Gray
        Write-Host "    .\predict-conflicts.ps1 -Learn" -ForegroundColor DarkGray
        Write-Host ""
    }
}

if ($Predict) {
    if (-not $CurrentFile) {
        Write-Host "❌ -CurrentFile required for prediction" -ForegroundColor Red
        exit 1
    }

    $fileName = Split-Path $CurrentFile -Leaf
    Write-Host "🔮 Predicting next files for: $fileName" -ForegroundColor Cyan
    Write-Host ""

    # Get predictions
    $fileEscaped = $fileName -replace "'", "''"
    $sql = "SELECT to_file, probability FROM file_sequences WHERE from_file = '$fileEscaped' AND probability >= 0.3 ORDER BY probability DESC LIMIT 5;"
    $predictions = Invoke-Sql -Sql $sql

    if (-not $predictions) {
        Write-Host "⚠️ No predictions available for this file" -ForegroundColor Yellow
        Write-Host "   (Not enough historical data)" -ForegroundColor Gray
        Write-Host ""
        exit 0
    }

    Write-Host "Predicted Next Files:" -ForegroundColor Cyan
    Write-Host ""

    $predictions -split "`n" | ForEach-Object {
        if ($_ -match '\|') {
            $parts = $_ -split '\|'
            $nextFile = $parts[0]
            $prob = [decimal]$parts[1]
            $probPercent = [math]::Round($prob * 100)

            $color = if ($prob -ge 0.7) { 'Green' } elseif ($prob -ge 0.5) { 'Yellow' } else { 'White' }

            Write-Host "  📄 $nextFile " -ForegroundColor White -NoNewline
            Write-Host "($probPercent% likely)" -ForegroundColor $color
        }
    }
    Write-Host ""

    # Check for active conflicts
    if ($AgentId) {
        Write-Host "⚠️ Checking for potential conflicts..." -ForegroundColor Cyan
        Write-Host ""

        # Get files currently being edited by other agents
        $conflictSql = @"
SELECT DISTINCT agent_id, file_path
FROM file_modifications
WHERE agent_id != '$AgentId'
AND timestamp > datetime('now', '-30 minutes')
AND operation = 'edit';
"@
        $activeEdits = Invoke-Sql -Sql $conflictSql

        if ($activeEdits) {
            $hasConflict = $false

            $activeEdits -split "`n" | ForEach-Object {
                if ($_ -match '\|') {
                    $parts = $_ -split '\|'
                    $otherAgent = $parts[0]
                    $otherFile = Split-Path $parts[1] -Leaf

                    # Check if predicted file matches other agent's current file
                    $predictions -split "`n" | ForEach-Object {
                        if ($_ -match '\|') {
                            $predParts = $_ -split '\|'
                            $predictedFile = $predParts[0]

                            if ($predictedFile -eq $otherFile) {
                                Write-Host "  🚨 CONFLICT ALERT!" -ForegroundColor Red
                                Write-Host "     You may edit: $predictedFile" -ForegroundColor Yellow
                                Write-Host "     Agent $otherAgent is currently editing this file!" -ForegroundColor Red
                                Write-Host ""
                                $hasConflict = $true
                            }
                        }
                    }
                }
            }

            if (-not $hasConflict) {
                Write-Host "  ✅ No conflicts predicted" -ForegroundColor Green
                Write-Host ""
            }
        } else {
            Write-Host "  ✅ No other agents currently editing files" -ForegroundColor Green
            Write-Host ""
        }
    }
}

if (-not $Learn -and -not $Predict -and -not $ShowMatrix) {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\predict-conflicts.ps1 -Learn" -ForegroundColor White
    Write-Host "  .\predict-conflicts.ps1 -Predict -CurrentFile 'Customer.cs'" -ForegroundColor White
    Write-Host "  .\predict-conflicts.ps1 -ShowMatrix" -ForegroundColor White
    Write-Host ""
}
