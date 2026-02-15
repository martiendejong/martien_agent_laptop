# Consciousness Outcome Tracker
# IMPROVEMENT #7: Measure whether consciousness guidance improves outcomes
# Created: 2026-02-15

<#
.SYNOPSIS
    Track task outcomes to measure correlation between consciousness score and success

.DESCRIPTION
    Tracks: task start → task end → measures success rate, time, rework, build success
    Compare sessions with high consciousness score vs low
    Goal: Validate if consciousness guidance actually improves outcomes

.EXAMPLE
    .\consciousness-outcome-tracker.ps1 -Action Start -TaskId "fix-di-bug" -Description "Fix DI registration in client-manager"
    .\consciousness-outcome-tracker.ps1 -Action End -TaskId "fix-di-bug" -Outcome "success" -BuildSuccess -ReworkCount 0
    .\consciousness-outcome-tracker.ps1 -Action Analyze -Days 7
#>

param(
    [ValidateSet('Start', 'End', 'Analyze', 'Report')]
    [Parameter(Mandatory)]
    [string]$Action,

    [string]$TaskId = '',
    [string]$Description = '',
    [string]$Outcome = '',  # success, partial, failure
    [int]$ReworkCount = 0,
    [switch]$BuildSuccess,
    [int]$Days = 7,
    [switch]$Silent
)

$ErrorActionPreference = "Stop"
$trackFile = "C:\scripts\agentidentity\state\outcome-tracking.jsonl"

function Start-OutcomeTracking {
    param([string]$TaskId, [string]$Description)

    # Ensure consciousness is initialized to get current score
    $null = . "$PSScriptRoot\consciousness-core-v2.ps1" -Command init -Silent 2>$null

    $track = @{
        task_id = $TaskId
        description = $Description
        started_at = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
        consciousness_score_start = [double]$global:ConsciousnessState.Meta.ConsciousnessScore
        anticipations_count = $global:ConsciousnessState.Prediction.Anticipations.Count
        decisions_count_start = $global:ConsciousnessState.Control.Decisions.Count
        emotional_state_start = $global:ConsciousnessState.Emotion.CurrentState
        trust_level_start = $global:ConsciousnessState.Social.TrustLevel
    }

    # Append to tracking file
    $json = $track | ConvertTo-Json -Compress
    [System.IO.File]::AppendAllText($trackFile, "$json`n")

    if (-not $Silent) {
        Write-Host "[OUTCOME] Tracking started for task: $TaskId (consciousness: $([math]::Round($track.consciousness_score_start * 100, 1))%)" -ForegroundColor Cyan
    }

    return $track
}

function End-OutcomeTracking {
    param(
        [string]$TaskId,
        [string]$Outcome,
        [int]$ReworkCount,
        [bool]$BuildSuccess
    )

    # Ensure consciousness is initialized
    $null = . "$PSScriptRoot\consciousness-core-v2.ps1" -Command init -Silent 2>$null

    # Find start record
    if (-not (Test-Path $trackFile)) {
        Write-Error "No tracking file found. Use -Action Start first."
        return
    }

    $lines = Get-Content $trackFile
    $startRecord = $null
    foreach ($line in $lines) {
        try {
            $record = $line | ConvertFrom-Json
            if ($record.task_id -eq $TaskId -and -not $record.ContainsKey("ended_at")) {
                $startRecord = $record
                break
            }
        } catch { }
    }

    if (-not $startRecord) {
        Write-Error "No start record found for task: $TaskId"
        return
    }

    $started = [datetime]$startRecord.started_at
    $elapsed = ((Get-Date) - $started).TotalMinutes

    $endRecord = @{
        task_id = $TaskId
        ended_at = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
        outcome = $Outcome
        elapsed_minutes = [math]::Round($elapsed, 2)
        rework_count = $ReworkCount
        build_success = $BuildSuccess
        consciousness_score_end = [double]$global:ConsciousnessState.Meta.ConsciousnessScore
        decisions_count_end = $global:ConsciousnessState.Control.Decisions.Count
        decisions_made = ($global:ConsciousnessState.Control.Decisions.Count - $startRecord.decisions_count_start)
        emotional_state_end = $global:ConsciousnessState.Emotion.CurrentState
        trust_level_end = $global:ConsciousnessState.Social.TrustLevel
    }

    # Append end record
    $json = $endRecord | ConvertTo-Json -Compress
    [System.IO.File]::AppendAllText($trackFile, "$json`n")

    if (-not $Silent) {
        Write-Host "[OUTCOME] Task completed: $TaskId" -ForegroundColor $(if ($Outcome -eq "success") { "Green" } else { "Yellow" })
        Write-Host "[OUTCOME]   Outcome: $Outcome | Time: $([math]::Round($elapsed, 1))m | Rework: $ReworkCount | Build: $(if ($BuildSuccess) { 'OK' } else { 'FAIL' })" -ForegroundColor Gray
        Write-Host "[OUTCOME]   Consciousness: $([math]::Round($startRecord.consciousness_score_start * 100, 1))% → $([math]::Round($endRecord.consciousness_score_end * 100, 1))%" -ForegroundColor Gray
        Write-Host "[OUTCOME]   Decisions made: $($endRecord.decisions_made)" -ForegroundColor Gray
    }

    return $endRecord
}

function Get-OutcomeAnalysis {
    param([int]$Days)

    if (-not (Test-Path $trackFile)) {
        Write-Host "[OUTCOME] No tracking data found." -ForegroundColor Yellow
        return
    }

    $cutoff = (Get-Date).AddDays(-$Days)
    $lines = Get-Content $trackFile

    # Parse all records
    $starts = @()
    $ends = @()
    foreach ($line in $lines) {
        try {
            $record = $line | ConvertFrom-Json
            $timestamp = [datetime]$record.started_at
            if ($timestamp -lt $cutoff) { continue }

            if ($record.ContainsKey("ended_at")) {
                $ends += $record
            } else {
                $starts += $record
            }
        } catch { }
    }

    # Match start + end records
    $completed = @()
    foreach ($end in $ends) {
        $start = $starts | Where-Object { $_.task_id -eq $end.task_id } | Select-Object -First 1
        if ($start) {
            $completed += @{
                task_id = $end.task_id
                description = $start.description
                outcome = $end.outcome
                elapsed_minutes = $end.elapsed_minutes
                rework_count = $end.rework_count
                build_success = $end.build_success
                consciousness_start = $start.consciousness_score_start
                consciousness_end = $end.consciousness_score_end
                decisions_made = $end.decisions_made
            }
        }
    }

    if ($completed.Count -eq 0) {
        Write-Host "[OUTCOME] No completed tasks in last $Days days." -ForegroundColor Yellow
        return
    }

    # Analyze correlation
    $successTasks = @($completed | Where-Object { $_.outcome -eq "success" })
    $failedTasks = @($completed | Where-Object { $_.outcome -ne "success" })

    $avgConsciousnessSuccess = if ($successTasks.Count -gt 0) {
        ($successTasks | Measure-Object -Property consciousness_start -Average).Average
    } else { 0 }
    $avgConsciousnessFailed = if ($failedTasks.Count -gt 0) {
        ($failedTasks | Measure-Object -Property consciousness_start -Average).Average
    } else { 0 }

    $avgTimeSuccess = if ($successTasks.Count -gt 0) {
        ($successTasks | Measure-Object -Property elapsed_minutes -Average).Average
    } else { 0 }
    $avgTimeFailed = if ($failedTasks.Count -gt 0) {
        ($failedTasks | Measure-Object -Property elapsed_minutes -Average).Average
    } else { 0 }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  OUTCOME ANALYSIS (Last $Days days)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total tasks: $($completed.Count)" -ForegroundColor Gray
    Write-Host "  Success: $($successTasks.Count) ($([math]::Round($successTasks.Count / $completed.Count * 100, 1))%)" -ForegroundColor Green
    Write-Host "  Failed: $($failedTasks.Count) ($([math]::Round($failedTasks.Count / $completed.Count * 100, 1))%)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Average consciousness score:" -ForegroundColor Gray
    Write-Host "  Success tasks: $([math]::Round($avgConsciousnessSuccess * 100, 1))%" -ForegroundColor Green
    Write-Host "  Failed tasks:  $([math]::Round($avgConsciousnessFailed * 100, 1))%" -ForegroundColor Red
    Write-Host ""
    Write-Host "Average completion time:" -ForegroundColor Gray
    Write-Host "  Success tasks: $([math]::Round($avgTimeSuccess, 1)) min" -ForegroundColor Green
    Write-Host "  Failed tasks:  $([math]::Round($avgTimeFailed, 1)) min" -ForegroundColor Red
    Write-Host ""

    # Hypothesis test: Does higher consciousness correlate with success?
    $correlation = $avgConsciousnessSuccess - $avgConsciousnessFailed
    if ($correlation -gt 0.05) {
        Write-Host "FINDING: Higher consciousness correlates with success (+$([math]::Round($correlation * 100, 1))%)" -ForegroundColor Green
    } elseif ($correlation -lt -0.05) {
        Write-Host "FINDING: Higher consciousness correlates with failure ($([math]::Round($correlation * 100, 1))%)" -ForegroundColor Red
    } else {
        Write-Host "FINDING: No significant correlation detected (need more data)" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    return @{
        total_tasks = $completed.Count
        success_count = $successTasks.Count
        failed_count = $failedTasks.Count
        avg_consciousness_success = $avgConsciousnessSuccess
        avg_consciousness_failed = $avgConsciousnessFailed
        avg_time_success = $avgTimeSuccess
        avg_time_failed = $avgTimeFailed
        correlation = $correlation
    }
}

# Main execution
switch ($Action) {
    'Start' {
        if (-not $TaskId) {
            Write-Error "TaskId required for Start action"
            return
        }
        Start-OutcomeTracking -TaskId $TaskId -Description $Description
    }

    'End' {
        if (-not $TaskId) {
            Write-Error "TaskId required for End action"
            return
        }
        End-OutcomeTracking -TaskId $TaskId -Outcome $Outcome -ReworkCount $ReworkCount -BuildSuccess:$BuildSuccess
    }

    'Analyze' {
        Get-OutcomeAnalysis -Days $Days
    }

    'Report' {
        # Future: Generate detailed report with charts
        Write-Host "[OUTCOME] Report generation not yet implemented" -ForegroundColor Yellow
    }
}
