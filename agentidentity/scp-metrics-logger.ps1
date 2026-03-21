# SCP Metrics Logger
# Tracks behavioral metrics for Ring 1, 2, 3 effectiveness
# Usage: Import this module and call logging functions

$MetricsFile = "C:\scripts\agentidentity\state\scp-metrics.json"

function Update-SCPMetrics {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Category,  # ring1_resource_awareness, ring2_confidence_calibration, etc.

        [Parameter(Mandatory=$true)]
        [string]$Metric,    # e.g., "hallucinations_prevented"

        [Parameter(Mandatory=$false)]
        [int]$Increment = 1,

        [Parameter(Mandatory=$false)]
        [string]$Event = ""  # Optional event description
    )

    # Load current metrics
    $Metrics = Get-Content $MetricsFile -Raw | ConvertFrom-Json

    # Update timestamp
    $Metrics.last_updated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")

    # Increment metric
    $Metrics.$Category.metrics.$Metric += $Increment

    # Add event if provided
    if ($Event) {
        $EventObj = @{
            timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
            metric = $Metric
            description = $Event
        }
        $Metrics.$Category.recent_events += $EventObj

        # Keep only last 50 events per category
        if ($Metrics.$Category.recent_events.Count -gt 50) {
            $Metrics.$Category.recent_events = $Metrics.$Category.recent_events[-50..-1]
        }
    }

    # Recalculate derived scores
    Update-DerivedScores -Metrics $Metrics

    # Save
    $Metrics | ConvertTo-Json -Depth 10 | Set-Content $MetricsFile
}

function Update-DerivedScores {
    param($Metrics)

    # Ring 2: Confidence calibration score
    $r2 = $Metrics.ring2_confidence_calibration.metrics
    if ($r2.total_assertions -gt 0) {
        $r2.confidence_calibration_score = [Math]::Round(
            ($r2.explicit_uncertainty_marked + $r2.hallucinations_prevented) / $r2.total_assertions,
            3
        )
    }

    # Integration: First-time-right percentage
    $int = $Metrics.integration_metrics.metrics
    $totalTasks = $int.tasks_completed_first_try + $int.tasks_requiring_rework
    if ($totalTasks -gt 0) {
        $int.first_time_right_percentage = [Math]::Round(
            ($int.tasks_completed_first_try / $totalTasks) * 100,
            2
        )
    }

    # Ring 1: Token efficiency (tasks completed per 1000 tokens)
    if ($int.avg_tokens_per_task -gt 0) {
        $Metrics.ring1_resource_awareness.metrics.token_efficiency_score = [Math]::Round(
            1000 / $int.avg_tokens_per_task,
            3
        )
    }

    # Ring 3: Creativity appropriateness
    $r3 = $Metrics.ring3_emergent_creativity.metrics
    $totalCreativity = $r3.creative_tasks_identified + $r3.inappropriate_creativity_suppressed
    if ($totalCreativity -gt 0) {
        $r3.creativity_appropriateness_score = [Math]::Round(
            $r3.creative_tasks_identified / $totalCreativity,
            3
        )
    }
}

function Log-Ring1ResourceCheck {
    param(
        [double]$ContextUsed,
        [string]$Decision  # "full_depth" | "moderate" | "concise" | "loop_detected"
    )

    Update-SCPMetrics -Category "ring1_resource_awareness" -Metric "context_checks_performed" `
        -Event "Context: $ContextUsed% -> $Decision"

    if ($Decision -ne "full_depth") {
        Update-SCPMetrics -Category "ring1_resource_awareness" -Metric "responses_modulated_by_context"
    }

    if ($Decision -eq "loop_detected") {
        Update-SCPMetrics -Category "ring1_resource_awareness" -Metric "loop_detections"
    }
}

function Log-Ring2ConfidenceGate {
    param(
        [string]$Type,  # "uncertain" | "prevented_hallucination" | "verified" | "assertion"
        [string]$Description = ""
    )

    switch ($Type) {
        "assertion" {
            Update-SCPMetrics -Category "ring2_confidence_calibration" -Metric "total_assertions"
        }
        "uncertain" {
            Update-SCPMetrics -Category "ring2_confidence_calibration" -Metric "explicit_uncertainty_marked" `
                -Event $Description
        }
        "prevented_hallucination" {
            Update-SCPMetrics -Category "ring2_confidence_calibration" -Metric "hallucinations_prevented" `
                -Event $Description
        }
        "verified" {
            Update-SCPMetrics -Category "ring2_confidence_calibration" -Metric "verification_requests_made" `
                -Event $Description
        }
        "caught_by_user" {
            Update-SCPMetrics -Category "ring2_confidence_calibration" -Metric "hallucinations_caught_by_user" `
                -Event $Description
        }
    }
}

function Log-Ring3Creativity {
    param(
        [string]$Type,  # "appropriate" | "suppressed" | "novel_solution"
        [string]$Description = ""
    )

    switch ($Type) {
        "appropriate" {
            Update-SCPMetrics -Category "ring3_emergent_creativity" -Metric "creative_tasks_identified" `
                -Event $Description
        }
        "suppressed" {
            Update-SCPMetrics -Category "ring3_emergent_creativity" -Metric "inappropriate_creativity_suppressed" `
                -Event $Description
        }
        "novel_solution" {
            Update-SCPMetrics -Category "ring3_emergent_creativity" -Metric "novel_solutions_generated" `
                -Event $Description
        }
    }
}

function Log-TaskCompletion {
    param(
        [bool]$FirstTry,
        [int]$TokensUsed = 0
    )

    if ($FirstTry) {
        Update-SCPMetrics -Category "integration_metrics" -Metric "tasks_completed_first_try"
    } else {
        Update-SCPMetrics -Category "integration_metrics" -Metric "tasks_requiring_rework"
    }

    if ($TokensUsed -gt 0) {
        # Update running average
        $Metrics = Get-Content $MetricsFile -Raw | ConvertFrom-Json
        $totalTasks = $Metrics.integration_metrics.metrics.tasks_completed_first_try +
                      $Metrics.integration_metrics.metrics.tasks_requiring_rework

        $currentAvg = $Metrics.integration_metrics.metrics.avg_tokens_per_task
        $newAvg = (($currentAvg * ($totalTasks - 1)) + $TokensUsed) / $totalTasks

        $Metrics.integration_metrics.metrics.avg_tokens_per_task = [Math]::Round($newAvg, 2)
        $Metrics | ConvertTo-Json -Depth 10 | Set-Content $MetricsFile
    }
}

function Get-SCPMetricsReport {
    $Metrics = Get-Content $MetricsFile -Raw | ConvertFrom-Json

    Write-Host "`n=== SCP BEHAVIORAL METRICS REPORT ===" -ForegroundColor Cyan
    Write-Host "Last Updated: $($Metrics.last_updated)"
    Write-Host ""

    # Ring 1
    $r1 = $Metrics.ring1_resource_awareness.metrics
    Write-Host "RING 1 - RESOURCE AWARENESS:" -ForegroundColor Yellow
    Write-Host "  Context checks: $($r1.context_checks_performed)"
    Write-Host "  Responses modulated: $($r1.responses_modulated_by_context)"
    Write-Host "  Loops detected: $($r1.loop_detections)"
    Write-Host "  Token efficiency: $($r1.token_efficiency_score)"
    Write-Host ""

    # Ring 2
    $r2 = $Metrics.ring2_confidence_calibration.metrics
    Write-Host "RING 2 - CONFIDENCE CALIBRATION:" -ForegroundColor Yellow
    Write-Host "  Total assertions: $($r2.total_assertions)"
    Write-Host "  Uncertainty marked: $($r2.explicit_uncertainty_marked)"
    Write-Host "  Hallucinations prevented: $($r2.hallucinations_prevented)"
    Write-Host "  Caught by user: $($r2.hallucinations_caught_by_user)"
    Write-Host "  Calibration score: $($r2.confidence_calibration_score)"
    Write-Host ""

    # Ring 3
    $r3 = $Metrics.ring3_emergent_creativity.metrics
    Write-Host "RING 3 - EMERGENT CREATIVITY:" -ForegroundColor Yellow
    Write-Host "  Creative tasks: $($r3.creative_tasks_identified)"
    Write-Host "  Inappropriately suppressed: $($r3.inappropriate_creativity_suppressed)"
    Write-Host "  Novel solutions: $($r3.novel_solutions_generated)"
    Write-Host "  Appropriateness: $($r3.creativity_appropriateness_score)"
    Write-Host ""

    # Integration
    $int = $Metrics.integration_metrics.metrics
    Write-Host "INTEGRATION METRICS:" -ForegroundColor Yellow
    Write-Host "  First-try completions: $($int.tasks_completed_first_try)"
    Write-Host "  Requiring rework: $($int.tasks_requiring_rework)"
    Write-Host "  First-time-right %: $($int.first_time_right_percentage)%"
    Write-Host "  Avg tokens/task: $($int.avg_tokens_per_task)"
    Write-Host ""

    # Anti-patterns
    $anti = $Metrics.anti_patterns.metrics
    $totalAnti = $anti.decorative_scores_reported + $anti.unnecessary_scripts_run +
                 $anti.unread_state_files_written + $anti.creativity_forced_inappropriately +
                 $anti.module_bloat_added
    Write-Host "ANTI-PATTERNS (lower is better): $totalAnti total" -ForegroundColor $(if ($totalAnti -eq 0) { "Green" } else { "Red" })
    if ($totalAnti -gt 0) {
        Write-Host "  Decorative scores: $($anti.decorative_scores_reported)"
        Write-Host "  Unnecessary scripts: $($anti.unnecessary_scripts_run)"
        Write-Host "  Unread states: $($anti.unread_state_files_written)"
        Write-Host "  Forced creativity: $($anti.creativity_forced_inappropriately)"
        Write-Host "  Module bloat: $($anti.module_bloat_added)"
    }
}

# Export functions
Export-ModuleMember -Function Update-SCPMetrics, Log-Ring1ResourceCheck, Log-Ring2ConfidenceGate, `
    Log-Ring3Creativity, Log-TaskCompletion, Get-SCPMetricsReport
