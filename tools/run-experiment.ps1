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
    [switch]$Success,

    [Parameter(Mandatory=$false)]
    [int]$DurationMs,

    [Parameter(Mandatory=$false)]
    [string]$Conclusion
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Self-Optimization Experiments" -ForegroundColor White
Write-Host "=========================================" -ForegroundColor Cyan
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
            Write-Host "[ERROR] Required: -ExperimentName, -Hypothesis, -ApproachA, -ApproachB" -ForegroundColor Red
            exit 1
        }

        Write-Host "Creating experiment: $ExperimentName" -ForegroundColor Cyan
        Write-Host ""

        $existing = Invoke-Sql "SELECT experiment_name FROM experiments WHERE experiment_name = '$ExperimentName';"
        if ($existing) {
            Write-Host "[ERROR] Experiment already exists: $ExperimentName" -ForegroundColor Red
            exit 1
        }

        $hypothesisEscaped = $Hypothesis -replace "'", "''"
        $approachAEscaped = $ApproachA -replace "'", "''"
        $approachBEscaped = $ApproachB -replace "'", "''"
        $now = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")

        $sql = "INSERT INTO experiments (experiment_name, hypothesis, approach_a, approach_b, started_at, status) VALUES ('$ExperimentName', '$hypothesisEscaped', '$approachAEscaped', '$approachBEscaped', '$now', 'running');"

        Invoke-Sql -Sql $sql

        Write-Host "[OK] Experiment created!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Hypothesis: $Hypothesis" -ForegroundColor White
        Write-Host ""
        Write-Host "Approach A: $ApproachA" -ForegroundColor Cyan
        Write-Host "Approach B: $ApproachB" -ForegroundColor Magenta
        Write-Host ""
    }

    'record' {
        if (-not $ExperimentName -or -not $Approach) {
            Write-Host "[ERROR] Required: -ExperimentName, -Approach (A or B)" -ForegroundColor Red
            exit 1
        }

        $experiment = Invoke-Sql "SELECT status FROM experiments WHERE experiment_name = '$ExperimentName';"
        if (-not $experiment) {
            Write-Host "[ERROR] Experiment not found: $ExperimentName" -ForegroundColor Red
            exit 1
        }

        $successCol = if ($Approach -eq 'A') { 'a_success_count' } else { 'b_success_count' }
        $failCol = if ($Approach -eq 'A') { 'a_failure_count' } else { 'b_failure_count' }

        if ($Success) {
            $sql = "UPDATE experiments SET $successCol = $successCol + 1 WHERE experiment_name = '$ExperimentName';"
        } else {
            $sql = "UPDATE experiments SET $failCol = $failCol + 1 WHERE experiment_name = '$ExperimentName';"
        }
        Invoke-Sql -Sql $sql

        $result = if ($Success) { "SUCCESS" } else { "FAILURE" }
        $color = if ($Success) { "Green" } else { "Red" }
        Write-Host "[OK] Recorded: Approach $Approach = $result" -ForegroundColor $color
        if ($DurationMs) {
            Write-Host "   Duration: $DurationMs ms" -ForegroundColor Gray
        }
        Write-Host ""
    }

    'analyze' {
        if (-not $ExperimentName) {
            Write-Host "[ERROR] Required: -ExperimentName" -ForegroundColor Red
            exit 1
        }

        $sql = "SELECT experiment_name, hypothesis, approach_a, approach_b, a_success_count, a_failure_count, b_success_count, b_failure_count, status, winner FROM experiments WHERE experiment_name = '$ExperimentName';"
        $result = Invoke-Sql -Sql $sql

        if (-not $result) {
            Write-Host "[ERROR] Experiment not found: $ExperimentName" -ForegroundColor Red
            exit 1
        }

        $parts = $result -split '\|'
        $name = $parts[0]
        $hypothesis = $parts[1]
        $approachA = $parts[2]
        $approachB = $parts[3]
        $aSuccess = [int]$parts[4]
        $aFailure = [int]$parts[5]
        $bSuccess = [int]$parts[6]
        $bFailure = [int]$parts[7]
        $status = $parts[8]
        $winner = $parts[9]

        $aTotal = $aSuccess + $aFailure
        $bTotal = $bSuccess + $bFailure

        $aSuccessRate = if ($aTotal -gt 0) { [math]::Round(($aSuccess / $aTotal) * 100, 1) } else { 0 }
        $bSuccessRate = if ($bTotal -gt 0) { [math]::Round(($bSuccess / $bTotal) * 100, 1) } else { 0 }

        Write-Host "Experiment: $name" -ForegroundColor Cyan
        Write-Host "Status: $status" -ForegroundColor $(if ($status -eq 'running') { 'Yellow' } else { 'Green' })
        Write-Host ""
        Write-Host "Hypothesis: $hypothesis" -ForegroundColor White
        Write-Host ""
        Write-Host "-----------------------------------------" -ForegroundColor DarkCyan
        Write-Host "APPROACH A: $approachA" -ForegroundColor Cyan
        Write-Host "  Success Rate: $aSuccessRate% ($aSuccess/$aTotal trials)" -ForegroundColor $(if ($aSuccessRate -ge $bSuccessRate) { 'Green' } else { 'White' })
        Write-Host ""
        Write-Host "APPROACH B: $approachB" -ForegroundColor Magenta
        Write-Host "  Success Rate: $bSuccessRate% ($bSuccess/$bTotal trials)" -ForegroundColor $(if ($bSuccessRate -gt $aSuccessRate) { 'Green' } else { 'White' })
        Write-Host "-----------------------------------------" -ForegroundColor DarkCyan
        Write-Host ""

        if ($winner) {
            Write-Host "Winner: Approach $winner" -ForegroundColor Green
        } elseif ($aTotal -ge 5 -and $bTotal -ge 5) {
            if ($aSuccessRate -gt $bSuccessRate + 10) {
                Write-Host "[*] Recommendation: Approach A appears better" -ForegroundColor Cyan
            } elseif ($bSuccessRate -gt $aSuccessRate + 10) {
                Write-Host "[*] Recommendation: Approach B appears better" -ForegroundColor Cyan
            } else {
                Write-Host "[*] Recommendation: No clear winner yet" -ForegroundColor Yellow
            }
        } else {
            Write-Host "[*] Need more data: min 5 trials each" -ForegroundColor Yellow
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

                    $color = if ($status -eq 'completed') { 'Green' } else { 'Yellow' }
                    $icon = if ($status -eq 'completed') { '[DONE]' } else { '[RUNNING]' }

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
            Write-Host "[ERROR] Required: -ExperimentName, -Conclusion" -ForegroundColor Red
            exit 1
        }

        $sql = "SELECT a_success_count, a_failure_count, b_success_count, b_failure_count FROM experiments WHERE experiment_name = '$ExperimentName';"
        $result = Invoke-Sql -Sql $sql

        if (-not $result) {
            Write-Host "[ERROR] Experiment not found" -ForegroundColor Red
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

        Write-Host "[OK] Experiment concluded!" -ForegroundColor Green
        Write-Host "   Winner: Approach $winner" -ForegroundColor Cyan
        Write-Host "   Conclusion: $Conclusion" -ForegroundColor White
        Write-Host ""
    }
}
