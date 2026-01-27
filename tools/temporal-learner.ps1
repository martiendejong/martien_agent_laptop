<#
.SYNOPSIS
    Learn time-based activity patterns

.DESCRIPTION
    Analyzes activity history to detect temporal patterns:
    - Monday 9am: User requests status updates (8/10 weeks)
    - Thursday 2pm: Production deployments (9/10 weeks)
    - Friday 5pm: Code freeze for weekend (10/10 weeks)

    Stores patterns in temporal_patterns table.

.PARAMETER Analyze
    Analyze activity and learn new patterns

.PARAMETER MinConfidence
    Minimum confidence threshold (0-1, default: 0.7)

.PARAMETER ShowPatterns
    Display learned patterns

.EXAMPLE
    .\temporal-learner.ps1 -Analyze

.EXAMPLE
    .\temporal-learner.ps1 -ShowPatterns -MinConfidence 0.8
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$Analyze,

    [Parameter(Mandatory=$false)]
    [decimal]$MinConfidence = 0.7,

    [Parameter(Mandatory=$false)]
    [switch]$ShowPatterns
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Temporal Pattern Learning" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

if ($ShowPatterns) {
    Write-Host "📊 Learned Patterns (confidence >= $MinConfidence):" -ForegroundColor Cyan
    Write-Host ""

    $sql = "SELECT day_of_week, hour_of_day, pattern, pattern_type, confidence, occurrences FROM temporal_patterns WHERE confidence >= $MinConfidence ORDER BY confidence DESC, occurrences DESC LIMIT 20;"

    $patterns = Invoke-Sql -Sql $sql

    if ($patterns) {
        $patterns -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $dow = $parts[0]
                $hour = $parts[1]
                $pattern = $parts[2]
                $type = $parts[3]
                $conf = [decimal]$parts[4]
                $occ = $parts[5]

                $dayName = @('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')[$dow]

                $confColor = if ($conf -ge 0.9) { 'Green' } elseif ($conf -ge 0.7) { 'Yellow' } else { 'Gray' }

                Write-Host "  [$dayName $($hour):00] " -ForegroundColor Cyan -NoNewline
                Write-Host "$pattern " -ForegroundColor White -NoNewline
                Write-Host "($([math]::Round($conf * 100))% confidence, $occ occurrences)" -ForegroundColor $confColor
            }
        }
        Write-Host ""
    } else {
        Write-Host "  No patterns found" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Run analysis to learn patterns:" -ForegroundColor Gray
        Write-Host "    .\temporal-learner.ps1 -Analyze" -ForegroundColor DarkGray
        Write-Host ""
    }

    exit 0
}

if ($Analyze) {
    Write-Host "🔍 Analyzing activity history..." -ForegroundColor Cyan
    Write-Host ""

    # Analyze tool_usage patterns by day/hour
    Write-Host "  Analyzing tool usage patterns..." -ForegroundColor Gray

    $toolPatternSql = @"
SELECT
    CAST(strftime('%w', timestamp) AS INTEGER) as day_of_week,
    CAST(strftime('%H', timestamp) AS INTEGER) as hour_of_day,
    tool_name,
    COUNT(*) as occurrences
FROM tool_usage
WHERE timestamp > datetime('now', '-90 days')
GROUP BY day_of_week, hour_of_day, tool_name
HAVING occurrences >= 3;
"@

    $toolPatterns = Invoke-Sql -Sql $toolPatternSql

    if ($toolPatterns) {
        $toolPatterns -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $dow = $parts[0]
                $hour = $parts[1]
                $tool = $parts[2]
                $occ = [int]$parts[3]

                # Calculate confidence (occurrences / weeks_of_data)
                $weeksOfData = 12  # 90 days
                $confidence = [math]::Min(1.0, $occ / $weeksOfData)

                if ($confidence -ge $MinConfidence) {
                    $pattern = "Tool used: $tool"
                    $patternEscaped = $pattern -replace "'", "''"

                    # Upsert pattern
                    $upsertSql = @"
INSERT INTO temporal_patterns (day_of_week, hour_of_day, pattern, pattern_type, confidence, occurrences, last_seen)
VALUES ($dow, $hour, '$patternEscaped', 'tool_usage', $confidence, $occ, datetime('now'))
ON CONFLICT(day_of_week, hour_of_day, pattern) DO UPDATE SET
    confidence = $confidence,
    occurrences = $occ,
    last_seen = datetime('now');
"@

                    Invoke-Sql -Sql $upsertSql
                }
            }
        }
    }

    # Analyze PR creation patterns
    Write-Host "  Analyzing PR creation patterns..." -ForegroundColor Gray

    $prPatternSql = @"
SELECT
    CAST(strftime('%w', created_at) AS INTEGER) as day_of_week,
    CAST(strftime('%H', created_at) AS INTEGER) as hour_of_day,
    COUNT(*) as occurrences
FROM pull_requests
WHERE created_at > datetime('now', '-90 days')
GROUP BY day_of_week, hour_of_day
HAVING occurrences >= 2;
"@

    $prPatterns = Invoke-Sql -Sql $prPatternSql

    if ($prPatterns) {
        $prPatterns -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $dow = $parts[0]
                $hour = $parts[1]
                $occ = [int]$parts[2]

                $weeksOfData = 12
                $confidence = [math]::Min(1.0, $occ / $weeksOfData)

                if ($confidence -ge $MinConfidence) {
                    $pattern = "PR creation"

                    $upsertSql = @"
INSERT INTO temporal_patterns (day_of_week, hour_of_day, pattern, pattern_type, confidence, occurrences, last_seen)
VALUES ($dow, $hour, '$pattern', 'pr_activity', $confidence, $occ, datetime('now'))
ON CONFLICT(day_of_week, hour_of_day, pattern) DO UPDATE SET
    confidence = $confidence,
    occurrences = $occ,
    last_seen = datetime('now');
"@

                    Invoke-Sql -Sql $upsertSql
                }
            }
        }
    }

    # Analyze error patterns
    Write-Host "  Analyzing error patterns..." -ForegroundColor Gray

    $errorPatternSql = @"
SELECT
    CAST(strftime('%w', timestamp) AS INTEGER) as day_of_week,
    CAST(strftime('%H', timestamp) AS INTEGER) as hour_of_day,
    COUNT(*) as occurrences
FROM errors
WHERE timestamp > datetime('now', '-90 days')
AND severity IN ('error', 'critical')
GROUP BY day_of_week, hour_of_day
HAVING occurrences >= 3;
"@

    $errorPatterns = Invoke-Sql -Sql $errorPatternSql

    if ($errorPatterns) {
        $errorPatterns -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $dow = $parts[0]
                $hour = $parts[1]
                $occ = [int]$parts[2]

                $weeksOfData = 12
                $confidence = [math]::Min(1.0, $occ / $weeksOfData)

                if ($confidence -ge $MinConfidence) {
                    $pattern = "High error frequency"

                    $upsertSql = @"
INSERT INTO temporal_patterns (day_of_week, hour_of_day, pattern, pattern_type, confidence, occurrences, last_seen)
VALUES ($dow, $hour, '$pattern', 'error_spike', $confidence, $occ, datetime('now'))
ON CONFLICT(day_of_week, hour_of_day, pattern) DO UPDATE SET
    confidence = $confidence,
    occurrences = $occ,
    last_seen = datetime('now');
"@

                    Invoke-Sql -Sql $upsertSql
                }
            }
        }
    }

    Write-Host ""
    Write-Host "✅ Pattern analysis complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "View patterns:" -ForegroundColor Cyan
    Write-Host "  .\temporal-learner.ps1 -ShowPatterns" -ForegroundColor Gray
    Write-Host ""

} else {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\temporal-learner.ps1 -Analyze" -ForegroundColor White
    Write-Host "  .\temporal-learner.ps1 -ShowPatterns" -ForegroundColor White
    Write-Host ""
}
