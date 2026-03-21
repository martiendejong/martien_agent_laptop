<#
.SYNOPSIS
Meta-Control System - Layer 5 of World Model

.DESCRIPTION
Manages fast vs slow thinking, offline consolidation, and meta-level control.

Fast thinking: Automatic, quick, low-effort (System 1)
Slow thinking: Deliberate, effortful, logical (System 2)
Offline: Background consolidation while idle

.PARAMETER Action
Action to perform: DecideMode, Consolidate, Stats

.EXAMPLE
.\meta-control-system.ps1 -Action DecideMode -Context "routine-task"
.\meta-control-system.ps1 -Action Consolidate
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('DecideMode', 'Consolidate', 'Stats', 'TrackPerformance')]
    [string]$Action,

    [string]$Context = "",
    [string]$TaskType = "",
    [double]$UrgencyScore = 0.5,
    [double]$ComplexityScore = 0.5
)

$statePath = "C:\scripts\agentidentity\state\meta-control-state.json"

function Initialize-MetaControlState {
    $initial = @{
        current_mode = "slow"
        last_switch = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        fast_decisions = @()
        slow_decisions = @()
        consolidation_events = @()
        performance = @{
            fast_accuracy = 0.85
            slow_accuracy = 0.95
            fast_speed = 2.0
            slow_speed = 10.0
            error_rate_fast = 0.15
            error_rate_slow = 0.05
        }
        decision_history = @()
        meta_stats = @{
            total_fast = 0
            total_slow = 0
            total_consolidations = 0
            offline_learning_events = 0
        }
    }

    $initial | ConvertTo-Json -Depth 10 | Set-Content $statePath
    return $initial
}

function Get-MetaControlState {
    if (Test-Path $statePath) {
        return Get-Content $statePath -Raw | ConvertFrom-Json
    }
    return Initialize-MetaControlState
}

function Save-MetaControlState($state) {
    $state | ConvertTo-Json -Depth 10 | Set-Content $statePath
}

function Decide-ThinkingMode {
    param($context, $taskType, $urgency, $complexity)

    $state = Get-MetaControlState

    # Decision algorithm for fast vs slow
    $fastScore = 0.0
    $slowScore = 0.0

    # Urgency favors fast
    $fastScore += $urgency * 0.3
    $slowScore += (1 - $urgency) * 0.3

    # Complexity favors slow
    $slowScore += $complexity * 0.4
    $fastScore += (1 - $complexity) * 0.2

    # Task type patterns
    $fastTasks = @("routine", "simple", "familiar", "quick")
    $slowTasks = @("novel", "complex", "critical", "planning")

    foreach ($ft in $fastTasks) {
        if ($taskType -like "*$ft*" -or $context -like "*$ft*") {
            $fastScore += 0.15
        }
    }

    foreach ($st in $slowTasks) {
        if ($taskType -like "*$st*" -or $context -like "*$st*") {
            $slowScore += 0.15
        }
    }

    # Historical performance influences decision
    $fastAccuracy = $state.performance.fast_accuracy
    $slowAccuracy = $state.performance.slow_accuracy

    $fastScore += $fastAccuracy * 0.15
    $slowScore += $slowAccuracy * 0.15

    # Decide
    $chosenMode = if ($fastScore -gt $slowScore) { "fast" } else { "slow" }
    $confidence = [math]::Abs($fastScore - $slowScore)

    # Record decision
    $decision = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        context = $context
        task_type = $taskType
        urgency = $urgency
        complexity = $complexity
        fast_score = [math]::Round($fastScore, 3)
        slow_score = [math]::Round($slowScore, 3)
        chosen_mode = $chosenMode
        confidence = [math]::Round($confidence, 3)
    }

    if ($chosenMode -eq "fast") {
        $state.fast_decisions += $decision
        $state.meta_stats.total_fast++
    } else {
        $state.slow_decisions += $decision
        $state.meta_stats.total_slow++
    }

    $state.current_mode = $chosenMode
    $state.last_switch = $decision.timestamp
    $state.decision_history += $decision

    # Keep only last 50 decisions
    if ($state.decision_history.Count -gt 50) {
        $state.decision_history = $state.decision_history[-50..-1]
    }

    Save-MetaControlState $state

    Write-Host "[Meta-Control] Mode Decision:" -ForegroundColor Cyan
    Write-Host "  Context:     $context" -ForegroundColor White
    Write-Host "  Task Type:   $taskType" -ForegroundColor White
    Write-Host "  Urgency:     $urgency" -ForegroundColor White
    Write-Host "  Complexity:  $complexity" -ForegroundColor White
    Write-Host "  Fast Score:  $($decision.fast_score)" -ForegroundColor Yellow
    Write-Host "  Slow Score:  $($decision.slow_score)" -ForegroundColor Yellow
    Write-Host "  CHOSEN:      $($chosenMode.ToUpper())" -ForegroundColor $(if ($chosenMode -eq "fast") { "Green" } else { "Magenta" })
    Write-Host "  Confidence:  $($decision.confidence)" -ForegroundColor White

    return $decision
}

function Consolidate-OfflineLearning {
    Write-Host "`n[Meta-Control] Offline Consolidation Starting..." -ForegroundColor Cyan

    $state = Get-MetaControlState

    # Consolidation: Compress recent experiences into latent variables
    # This simulates what happens during "sleep" or idle time

    $consolidationStart = Get-Date

    # 1. Analyze recent decisions
    $recentDecisions = $state.decision_history | Select-Object -Last 10

    if ($recentDecisions.Count -eq 0) {
        Write-Host "[Meta-Control] No recent decisions to consolidate" -ForegroundColor Gray
        return
    }

    # 2. Find patterns
    $fastCount = ($recentDecisions | Where-Object { $_.chosen_mode -eq "fast" }).Count
    $slowCount = ($recentDecisions | Where-Object { $_.chosen_mode -eq "slow" }).Count

    $avgFastScore = if ($fastCount -gt 0) {
        ($recentDecisions | Where-Object { $_.chosen_mode -eq "fast" } | Measure-Object -Property fast_score -Average).Average
    } else { 0 }

    $avgSlowScore = if ($slowCount -gt 0) {
        ($recentDecisions | Where-Object { $_.chosen_mode -eq "slow" } | Measure-Object -Property slow_score -Average).Average
    } else { 0 }

    # 3. Update performance estimates based on patterns
    # (In real system, this would analyze actual outcomes)
    # For now, simulate slight improvement from consolidation

    $state.performance.fast_accuracy = [math]::Min($state.performance.fast_accuracy + 0.01, 0.98)
    $state.performance.slow_accuracy = [math]::Min($state.performance.slow_accuracy + 0.005, 0.99)

    # 4. Compress episodic memories into recipes
    $recipesPath = "C:\scripts\agentidentity\state\episodic-recipes.json"
    if (Test-Path $recipesPath) {
        $recipes = Get-Content $recipesPath -Raw | ConvertFrom-Json
        $recentRecipes = $recipes.recipes | Where-Object {
            $recipeDate = [datetime]::ParseExact($_.timestamp, "yyyy-MM-dd HH:mm:ss", $null)
            $recipeDate -gt (Get-Date).AddHours(-1)
        }

        Write-Host "  Consolidating $($recentRecipes.Count) recent recipes..." -ForegroundColor Gray
    }

    # 5. Record consolidation event
    $consolidationEvent = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        decisions_analyzed = $recentDecisions.Count
        fast_decisions = $fastCount
        slow_decisions = $slowCount
        avg_fast_score = [math]::Round($avgFastScore, 3)
        avg_slow_score = [math]::Round($avgSlowScore, 3)
        performance_update = @{
            fast_accuracy_delta = 0.01
            slow_accuracy_delta = 0.005
        }
        duration_ms = ((Get-Date) - $consolidationStart).TotalMilliseconds
    }

    $state.consolidation_events += $consolidationEvent
    $state.meta_stats.total_consolidations++
    $state.meta_stats.offline_learning_events++

    # Keep only last 20 consolidation events
    if ($state.consolidation_events.Count -gt 20) {
        $state.consolidation_events = $state.consolidation_events[-20..-1]
    }

    Save-MetaControlState $state

    Write-Host "`n[Consolidation Complete]" -ForegroundColor Green
    Write-Host "  Decisions analyzed: $($consolidationEvent.decisions_analyzed)" -ForegroundColor White
    Write-Host "  Fast decisions:     $fastCount" -ForegroundColor White
    Write-Host "  Slow decisions:     $slowCount" -ForegroundColor White
    Write-Host "  Performance gain:   +$($consolidationEvent.performance_update.fast_accuracy_delta) (fast), +$($consolidationEvent.performance_update.slow_accuracy_delta) (slow)" -ForegroundColor Yellow
    Write-Host "  Duration:           $([math]::Round($consolidationEvent.duration_ms, 1))ms" -ForegroundColor White

    return $consolidationEvent
}

function Track-Performance {
    param($mode, $wasCorrect)

    $state = Get-MetaControlState

    if ($mode -eq "fast") {
        $totalFast = $state.meta_stats.total_fast
        $currentAccuracy = $state.performance.fast_accuracy

        # Update with exponential moving average
        $alpha = 0.1
        $newAccuracy = if ($wasCorrect) {
            $currentAccuracy * (1 - $alpha) + 1.0 * $alpha
        } else {
            $currentAccuracy * (1 - $alpha) + 0.0 * $alpha
        }

        $state.performance.fast_accuracy = $newAccuracy
        $state.performance.error_rate_fast = 1 - $newAccuracy

    } else {
        $totalSlow = $state.meta_stats.total_slow
        $currentAccuracy = $state.performance.slow_accuracy

        $alpha = 0.1
        $newAccuracy = if ($wasCorrect) {
            $currentAccuracy * (1 - $alpha) + 1.0 * $alpha
        } else {
            $currentAccuracy * (1 - $alpha) + 0.0 * $alpha
        }

        $state.performance.slow_accuracy = $newAccuracy
        $state.performance.error_rate_slow = 1 - $newAccuracy
    }

    Save-MetaControlState $state

    Write-Host "[Meta-Control] Performance updated:" -ForegroundColor Cyan
    Write-Host "  Mode:         $mode" -ForegroundColor White
    Write-Host "  Was Correct:  $wasCorrect" -ForegroundColor $(if ($wasCorrect) { "Green" } else { "Red" })
    Write-Host "  New Accuracy: $([math]::Round($state.performance."$($mode)_accuracy", 3))" -ForegroundColor Yellow
}

function Show-MetaControlStats {
    $state = Get-MetaControlState

    Write-Host "`nMETA-CONTROL STATISTICS" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor Cyan

    Write-Host "`nCurrent State:" -ForegroundColor Yellow
    Write-Host "  Mode:             $($state.current_mode)" -ForegroundColor White
    Write-Host "  Last Switch:      $($state.last_switch)" -ForegroundColor White

    Write-Host "`nPerformance:" -ForegroundColor Yellow
    Write-Host "  Fast Accuracy:    $([math]::Round($state.performance.fast_accuracy, 3))" -ForegroundColor Green
    Write-Host "  Slow Accuracy:    $([math]::Round($state.performance.slow_accuracy, 3))" -ForegroundColor Green
    Write-Host "  Fast Speed:       $($state.performance.fast_speed)x" -ForegroundColor White
    Write-Host "  Slow Speed:       $($state.performance.slow_speed)x" -ForegroundColor White
    Write-Host "  Fast Error Rate:  $([math]::Round($state.performance.error_rate_fast, 3))" -ForegroundColor Red
    Write-Host "  Slow Error Rate:  $([math]::Round($state.performance.error_rate_slow, 3))" -ForegroundColor Red

    Write-Host "`nUsage Statistics:" -ForegroundColor Yellow
    Write-Host "  Total Fast:       $($state.meta_stats.total_fast)" -ForegroundColor White
    Write-Host "  Total Slow:       $($state.meta_stats.total_slow)" -ForegroundColor White
    Write-Host "  Consolidations:   $($state.meta_stats.total_consolidations)" -ForegroundColor White
    Write-Host "  Offline Learning: $($state.meta_stats.offline_learning_events)" -ForegroundColor White

    if ($state.decision_history.Count -gt 0) {
        $recent = $state.decision_history | Select-Object -Last 10
        Write-Host "`nRecent Decisions (last 10):" -ForegroundColor Yellow
        foreach ($dec in $recent) {
            $modeColor = if ($dec.chosen_mode -eq "fast") { "Green" } else { "Magenta" }
            Write-Host "  $($dec.timestamp) | $($dec.chosen_mode.PadRight(5)) | $($dec.context)" -ForegroundColor $modeColor
        }
    }

    Write-Host ""
}

# Main execution
switch ($Action) {
    'DecideMode' {
        Decide-ThinkingMode -context $Context -taskType $TaskType -urgency $UrgencyScore -complexity $ComplexityScore
    }
    'Consolidate' {
        Consolidate-OfflineLearning
    }
    'TrackPerformance' {
        # This would be called after a decision with outcome
        Track-Performance -mode "fast" -wasCorrect $true
    }
    'Stats' {
        Show-MetaControlStats
    }
}
