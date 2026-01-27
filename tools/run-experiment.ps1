<#
.SYNOPSIS
    A/B testing framework for self-optimization

.DESCRIPTION
    Run experiments to compare different approaches:
    - "git-tracked.ps1 vs raw git"
    - "Opus vs Sonnet for code review"
    - "Early error handling vs late"

    Tracks success rate, duration, error frequency.

.PARAMETER Action
    create: Create new experiment
    record: Record trial result
    analyze: Analyze experiment results
    list: List all experiments

.PARAMETER ExperimentName
    Name of the experiment

.PARAMETER Hypothesis
    What you expect to happen

.PARAMETER ApproachA
    Description of approach A

.PARAMETER ApproachB
    Description of approach B

.PARAMETER Approach
    Which approach this trial used (A or B)

.PARAMETER Success
    Whether this trial succeeded

.PARAMETER DurationMs
    Duration of this trial in milliseconds

.EXAMPLE
    .\run-experiment.ps1 -Action create -ExperimentName "git-tracked-vs-raw" -Hypothesis "git-tracked more reliable" -ApproachA "git-tracked.ps1" -ApproachB "raw git commands"

.EXAMPLE
    .\run-experiment.ps1 -Action record -ExperimentName "git-tracked-vs-raw" -Approach A -Success $true -DurationMs 1200

.EXAMPLE
    .\run-experiment.ps1 -Action analyze -ExperimentName "git-tracked-vs-raw"
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('create', 'record', 'analyze', 'list', 'conclude')]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$ExperimentName,

    [Parameter(Mandatory=$false)]
    [string]$Hypothesis,

    [Parameter(Mandatory=$false)]
    [string]$ApproachA,

    [Parameter(Mandatory=$false)]
    [string]$ApproachB,

    [Parameter(Mandatory=$false)]
    [ValidateSet('A', 'B')]
    [string]$Approach,

    [Parameter(Mandatory=$false)]
    [bool]$Success,

    [Parameter(Mandatory=$false)]
    [int]$DurationMs,

    [Parameter(Mandatory=$false)]
    [string]$Conclusion
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Self-Optimization Experiments" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

switch ($Action) {
    'create' {
        if (-not $ExperimentName -or -not $Hypothesis -or -not $ApproachA -or -not $ApproachB) {
            Write-Host "❌ Required: -ExperimentName, -Hypothesis, -ApproachA, -ApproachB" -ForegroundColor Red
            exit 1
        }

        Write-Host "Creating experiment: $ExperimentName" -ForegroundColor Cyan
        Write-Host ""

        # Check if exists
        $existing = Invoke-Sql "SELECT experiment_name FROM experiments WHERE experiment_name = '$ExperimentName';"
        if ($existing) {
            Write-Host "❌ Experiment already exists: $ExperimentName" -ForegroundColor Red
            exit 1
        }

        $hypothesisEscaped = $Hypothesis -replace "'", "''"
        $approachAEscaped = $ApproachA -replace "'", "''"
        $approachBEscaped = $ApproachB -replace "'", "''"
        $now = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")

        $sql = @"
INSERT INTO experiments (experiment_name, hypothesis, approach_a, approach_b, started_at, status)
VALUES ('$ExperimentName', '$hypothesisEscaped', '$approachAEscaped', '$approachBEscaped', '$now', 'running');
"@

        Invoke-Sql -Sql $sql

        Write-Host "✅ Experiment created!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Hypothesis: $Hypothesis" -ForegroundColor White
        Write-Host ""
        Write-Host "Approach A: $ApproachA" -ForegroundColor Cyan
        Write-Host "Approach B: $ApproachB" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "Record results with:" -ForegroundColor Yellow
        Write-Host "  .\run-experiment.ps1 -Action record -ExperimentName '$ExperimentName' -Approach A -Success `$true -DurationMs 1000" -ForegroundColor Gray
        Write-Host ""
    }

    'record' {
        if (-not $ExperimentName -or -not $Approach) {
            Write-Host "❌ Required: -ExperimentName, -Approach (A or B)" -ForegroundColor Red
            exit 1
        }

        # Check experiment exists and is running
        $experiment = Invoke-Sql "SELECT status FROM experiments WHERE experiment_name = '$ExperimentName';"
        if (-not $experiment) {
            Write-Host "❌ Experiment not found: $ExperimentName" -ForegroundColor Red
            exit 1
        }
        if ($experiment -eq "completed") {
            Write-Host "⚠️ Experiment already concluded" -ForegroundColor Yellow
            exit 0
        }

        $successCol = if ($Approach -eq 'A') { 'a_success_count' } else { 'b_success_count' }
        $failCol = if ($Approach -eq 'A') { 'a_failure_count' } else { 'b_failure_count' }
        $durationCol = if ($Approach -eq 'A') { 'a_avg_duration' } else { 'b_avg_duration' }

        if ($Success) {
            # Increment success count
            $sql = "UPDATE experiments SET $successCol = $successCol + 1 WHERE experiment_name = '$ExperimentName';"
        } else {
            # Increment failure count
            $sql = "UPDATE experiments SET $failCol = $failCol + 1 WHERE experiment_name = '$ExperimentName';"
        }
        Invoke-Sql -Sql $sql

        # Update average duration (rolling average)
        if ($DurationMs -gt 0) {
            $currentAvg = Invoke-Sql "SELECT $durationCol FROM experiments WHERE experiment_name = '$ExperimentName';"
            $totalCount = Invoke-Sql "SELECT $successCol + $failCol FROM experiments WHERE experiment_name = '$ExperimentName';"

            if ($currentAvg -and $totalCount) {
                $count = [int]$totalCount
                $avg = [decimal]$currentAvg
                $newAvg = (($avg * ($count - 1)) + $DurationMs) / $count
                Invoke-Sql "UPDATE experiments SET $durationCol = $newAvg WHERE experiment_name = '$ExperimentName';"
            }
        }

        $result = if ($Success) { "SUCCESS" } else { "FAILURE" }
        Write-Host "✅ Recorded: Approach $Approach = $result" -ForegroundColor $(if ($Success) { 'Green' } else { 'Red' })
        if ($DurationMs) {
            Write-Host "   Duration: $DurationMs ms" -ForegroundColor Gray
        }
        Write-Host ""
    }

    'analyze' {
        if (-not $ExperimentName) {
            Write-Host "❌ Required: -ExperimentName" -ForegroundColor Red
            exit 1
        }

        $sql = "SELECT experiment_name, hypothesis, approach_a, approach_b, a_success_count, a_failure_count, a_avg_duration, b_success_count, b_failure_count, b_avg_duration, status, winner, conclusion FROM experiments WHERE experiment_name = '$ExperimentName';"
        $result = Invoke-Sql -Sql $sql

        if (-not $result) {
            Write-Host "❌ Experiment not found: $ExperimentName" -ForegroundColor Red
            exit 1
        }

        $parts = $result -split '\|'
        $name = $parts[0]
        $hypothesis = $parts[1]
        $approachA = $parts[2]
        $approachB = $parts[3]
        $aSuccess = [int]$parts[4]
        $aFailure = [int]$parts[5]
        $aAvgDuration = [decimal]$parts[6]
        $bSuccess = [int]$parts[7]
        $bFailure = [int]$parts[8]
        $bAvgDuration = [decimal]$parts[9]
        $status = $parts[10]
        $winner = $parts[11]
        $conclusion = $parts[12]

        $aTotal = $aSuccess + $aFailure
        $bTotal = $bSuccess + $bFailure

        $aSuccessRate = if ($aTotal -gt 0) { [math]::Round(($aSuccess / $aTotal) * 100, 1) } else { 0 }
        $bSuccessRate = if ($bTotal -gt 0) { [math]::Round(($bSuccess / $bTotal) * 100, 1) } else { 0 }

        Write-Host "Experiment: $name" -ForegroundColor Cyan
        Write-Host "Status: $status" -ForegroundColor $(if ($status -eq 'running') { 'Yellow' } else { 'Green' })
        Write-Host ""
        Write-Host "Hypothesis: $hypothesis" -ForegroundColor White
        Write-Host ""

        Write-Host "┌─────────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
        Write-Host "│              APPROACH A vs APPROACH B               │" -ForegroundColor DarkCyan
        Write-Host "├─────────────────────────────────────────────────────┤" -ForegroundColor DarkCyan

        Write-Host "│ " -ForegroundColor DarkCyan -NoNewline
        Write-Host "A: $approachA" -ForegroundColor Cyan -NoNewline
        Write-Host "".PadRight(52 - $approachA.Length - 4) -NoNewline
        Write-Host "│" -ForegroundColor DarkCyan

        Write-Host "│   Success Rate: " -ForegroundColor DarkCyan -NoNewline
        Write-Host "$aSuccessRate%" -ForegroundColor $(if ($aSuccessRate -ge $bSuccessRate) { 'Green' } else { 'White' }) -NoNewline
        Write-Host " ($aSuccess/$aTotal trials)" -ForegroundColor Gray -NoNewline
        Write-Host "".PadRight(20 - $aSuccessRate.ToString().Length - $aSuccess.ToString().Length - $aTotal.ToString().Length) -NoNewline
        Write-Host "│" -ForegroundColor DarkCyan

        Write-Host "│   Avg Duration: " -ForegroundColor DarkCyan -NoNewline
        Write-Host "$([math]::Round($aAvgDuration, 0)) ms" -ForegroundColor $(if ($aAvgDuration -le $bAvgDuration) { 'Green' } else { 'White' }) -NoNewline
        Write-Host "".PadRight(30 - $aAvgDuration.ToString().Length) -NoNewline
        Write-Host "│" -ForegroundColor DarkCyan

        Write-Host "├─────────────────────────────────────────────────────┤" -ForegroundColor DarkCyan

        Write-Host "│ " -ForegroundColor DarkCyan -NoNewline
        Write-Host "B: $approachB" -ForegroundColor Magenta -NoNewline
        Write-Host "".PadRight(52 - $approachB.Length - 4) -NoNewline
        Write-Host "│" -ForegroundColor DarkCyan

        Write-Host "│   Success Rate: " -ForegroundColor DarkCyan -NoNewline
        Write-Host "$bSuccessRate%" -ForegroundColor $(if ($bSuccessRate -gt $aSuccessRate) { 'Green' } else { 'White' }) -NoNewline
        Write-Host " ($bSuccess/$bTotal trials)" -ForegroundColor Gray -NoNewline
        Write-Host "".PadRight(20 - $bSuccessRate.ToString().Length - $bSuccess.ToString().Length - $bTotal.ToString().Length) -NoNewline
        Write-Host "│" -ForegroundColor DarkCyan

        Write-Host "│   Avg Duration: " -ForegroundColor DarkCyan -NoNewline
        Write-Host "$([math]::Round($bAvgDuration, 0)) ms" -ForegroundColor $(if ($bAvgDuration -lt $aAvgDuration) { 'Green' } else { 'White' }) -NoNewline
        Write-Host "".PadRight(30 - $bAvgDuration.ToString().Length) -NoNewline
        Write-Host "│" -ForegroundColor DarkCyan

        Write-Host "└─────────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
        Write-Host ""

        if ($winner) {
            Write-Host "Winner: Approach $winner" -ForegroundColor Green
            Write-Host "Conclusion: $conclusion" -ForegroundColor White
        } else {
            # Suggest winner
            if ($aTotal -ge 10 -and $bTotal -ge 10) {
                if ($aSuccessRate -gt $bSuccessRate + 10) {
                    Write-Host "📊 Recommendation: Approach A appears better (higher success rate)" -ForegroundColor Cyan
                } elseif ($bSuccessRate -gt $aSuccessRate + 10) {
                    Write-Host "📊 Recommendation: Approach B appears better (higher success rate)" -ForegroundColor Cyan
                } elseif ($aAvgDuration -lt $bAvgDuration * 0.8) {
                    Write-Host "📊 Recommendation: Approach A appears better (faster)" -ForegroundColor Cyan
                } elseif ($bAvgDuration -lt $aAvgDuration * 0.8) {
                    Write-Host "📊 Recommendation: Approach B appears better (faster)" -ForegroundColor Cyan
                } else {
                    Write-Host "📊 Recommendation: No clear winner yet - continue testing" -ForegroundColor Yellow
                }
            } else {
                Write-Host "📊 Need more data: $([math]::Max(0, 10 - $aTotal)) more A trials, $([math]::Max(0, 10 - $bTotal)) more B trials" -ForegroundColor Yellow
            }
        }
        Write-Host ""
    }

    'list' {
        Write-Host "All Experiments:" -ForegroundColor Cyan
        Write-Host ""

        $sql = "SELECT experiment_name, status, started_at FROM experiments ORDER BY started_at DESC;"
        $experiments = Invoke-Sql -Sql $sql

        if ($experiments) {
            $experiments -split "`n" | ForEach-Object {
                if ($_ -match '\|') {
                    $parts = $_ -split '\|'
                    $name = $parts[0]
                    $status = $parts[1]
                    $started = $parts[2]

                    $icon = if ($status -eq 'completed') { '✅' } else { '🔬' }
                    $color = if ($status -eq 'completed') { 'Green' } else { 'Yellow' }

                    Write-Host "  $icon $name" -ForegroundColor $color
                    Write-Host "     Status: $status | Started: $started" -ForegroundColor Gray
                    Write-Host ""
                }
            }
        } else {
            Write-Host "  No experiments found" -ForegroundColor Yellow
            Write-Host ""
        }
    }

    'conclude' {
        if (-not $ExperimentName -or -not $Conclusion) {
            Write-Host "❌ Required: -ExperimentName, -Conclusion" -ForegroundColor Red
            exit 1
        }

        # Determine winner from data
        $sql = "SELECT a_success_count, a_failure_count, b_success_count, b_failure_count FROM experiments WHERE experiment_name = '$ExperimentName';"
        $result = Invoke-Sql -Sql $sql

        if (-not $result) {
            Write-Host "❌ Experiment not found" -ForegroundColor Red
            exit 1
        }

        $parts = $result -split '\|'
        $aSuccess = [int]$parts[0]
        $aFailure = [int]$parts[1]
        $bSuccess = [int]$parts[2]
        $bFailure = [int]$parts[3]

        $aRate = if (($aSuccess + $aFailure) -gt 0) { $aSuccess / ($aSuccess + $aFailure) } else { 0 }
        $bRate = if (($bSuccess + $bFailure) -gt 0) { $bSuccess / ($bSuccess + $bFailure) } else { 0 }

        $winner = if ($aRate -gt $bRate) { 'A' } elseif ($bRate -gt $aRate) { 'B' } else { 'TIE' }

        $conclusionEscaped = $Conclusion -replace "'", "''"
        $now = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")

        $sql = "UPDATE experiments SET status = 'completed', winner = '$winner', conclusion = '$conclusionEscaped', ended_at = '$now' WHERE experiment_name = '$ExperimentName';"
        Invoke-Sql -Sql $sql

        Write-Host "✅ Experiment concluded!" -ForegroundColor Green
        Write-Host "   Winner: Approach $winner" -ForegroundColor Cyan
        Write-Host "   Conclusion: $Conclusion" -ForegroundColor White
        Write-Host ""
    }
}
