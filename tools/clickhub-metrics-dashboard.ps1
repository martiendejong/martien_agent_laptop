# ClickHub Metrics Dashboard
# Version: 1.0.0
# Created: 2026-02-28
# Purpose: Real-time metrics and reporting

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Show", "Export", "Daily", "Weekly")]
    [string]$Action = "Show",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath,

    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

$learningFile = "C:\scripts\_machine\clickhub-learning.json"
$orchestratorStateFile = "C:\scripts\_machine\clickhub-orchestrator-state.json"
$metricsHistoryFile = "C:\scripts\_machine\clickhub-metrics-history.jsonl"

# Collect current metrics
function Collect-Metrics {
    $metrics = @{
        timestamp = Get-Date -Format "o"
        date = Get-Date -Format "yyyy-MM-dd"
    }

    # Load learning data
    if (Test-Path $learningFile) {
        $learning = Get-Content $learningFile | ConvertFrom-Json

        # Overall statistics
        $totalTasks = 0
        $totalSuccesses = 0
        $totalTime = 0

        foreach ($proj in $learning.project_stats.PSObject.Properties) {
            $stats = $proj.Value
            $totalTasks += $stats.total_tasks
            $totalSuccesses += [math]::Round($stats.total_tasks * $stats.success_rate)
            $totalTime += $stats.avg_completion_minutes * $stats.total_tasks
        }

        $metrics.total_tasks = $totalTasks
        $metrics.success_rate = if ($totalTasks -gt 0) {
            [math]::Round(($totalSuccesses / $totalTasks) * 100, 1)
        } else { 0 }
        $metrics.avg_completion_minutes = if ($totalTasks -gt 0) {
            [math]::Round($totalTime / $totalTasks, 1)
        } else { 0 }
        $metrics.failure_patterns = $learning.failure_patterns.Count

        # Top issues
        $metrics.top_failures = $learning.failure_patterns |
                                Sort-Object -Property occurrences -Descending |
                                Select-Object -First 5 |
                                ForEach-Object {
                                    @{
                                        pattern = $_.pattern
                                        count = $_.occurrences
                                        solution = $_.solution
                                    }
                                }

        # Agent performance
        $metrics.agents = @{}
        foreach ($agent in $learning.agent_performance.PSObject.Properties) {
            $perf = $agent.Value
            $metrics.agents[$agent.Name] = @{
                tasks_completed = $perf.tasks_completed
                success_rate = [math]::Round($perf.success_rate * 100, 1)
                specialization = $perf.specialization
            }
        }
    }

    # Load orchestrator state
    if (Test-Path $orchestratorStateFile) {
        $orch = Get-Content $orchestratorStateFile | ConvertFrom-Json
        $metrics.orchestrator = @{
            status = $orch.status
            cycles_completed = $orch.cycles_completed
            tasks_completed = $orch.tasks_completed
            active_agents = ($orch.agents.PSObject.Properties | Where-Object { $_.Value.status -eq "BUSY" }).Count
        }
    }

    # Calculate cost estimate (rough)
    # Assume: ~10 API calls per task at $0.002 each
    $estimatedCost = $totalTasks * 10 * 0.002
    $metrics.estimated_cost_eur = [math]::Round($estimatedCost, 2)

    return $metrics
}

# Save metrics to history
function Save-Metrics-History {
    param($metrics)

    # Append to JSONL file
    $metricsJson = $metrics | ConvertTo-Json -Compress
    Add-Content -Path $metricsHistoryFile -Value $metricsJson
}

# Display dashboard
function Show-Dashboard {
    $metrics = Collect-Metrics

    Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║          CLICKHUB METRICS DASHBOARD                      ║" -ForegroundColor Cyan
    Write-Host "║          $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')                          ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

    # Overall Statistics
    Write-Host "`n┌─ OVERALL STATISTICS ─────────────────────────────────────┐" -ForegroundColor Yellow
    Write-Host "│ Total Tasks Processed:    $($metrics.total_tasks)" -ForegroundColor White
    Write-Host "│ Success Rate:             $($metrics.success_rate)%" -ForegroundColor Green
    Write-Host "│ Avg Completion Time:      $($metrics.avg_completion_minutes) minutes" -ForegroundColor White
    Write-Host "│ Failure Patterns Found:   $($metrics.failure_patterns)" -ForegroundColor White
    Write-Host "│ Estimated Cost:           EUR $($metrics.estimated_cost_eur)" -ForegroundColor White
    Write-Host "└──────────────────────────────────────────────────────────┘" -ForegroundColor Yellow

    # Orchestrator Status (if running)
    if ($metrics.orchestrator) {
        $statusColor = if ($metrics.orchestrator.status -eq "running") { "Green" } else { "Red" }
        Write-Host "`n┌─ ORCHESTRATOR STATUS ────────────────────────────────────┐" -ForegroundColor Yellow
        Write-Host "│ Status:                   $($metrics.orchestrator.status)" -ForegroundColor $statusColor
        Write-Host "│ Cycles Completed:         $($metrics.orchestrator.cycles_completed)" -ForegroundColor White
        Write-Host "│ Tasks Completed:          $($metrics.orchestrator.tasks_completed)" -ForegroundColor White
        Write-Host "│ Active Agents:            $($metrics.orchestrator.active_agents)" -ForegroundColor White
        Write-Host "└──────────────────────────────────────────────────────────┘" -ForegroundColor Yellow
    }

    # Top Failures
    if ($metrics.top_failures -and $metrics.top_failures.Count -gt 0) {
        Write-Host "`n┌─ TOP FAILURE PATTERNS ───────────────────────────────────┐" -ForegroundColor Red
        foreach ($failure in $metrics.top_failures) {
            Write-Host "│ [$($failure.count)x] $($failure.pattern)" -ForegroundColor Red
            Write-Host "│   → $($failure.solution)" -ForegroundColor Gray
        }
        Write-Host "└──────────────────────────────────────────────────────────┘" -ForegroundColor Red
    }

    # Agent Performance
    if ($metrics.agents -and $metrics.agents.Count -gt 0) {
        Write-Host "`n┌─ AGENT PERFORMANCE ──────────────────────────────────────┐" -ForegroundColor Cyan
        foreach ($agentId in $metrics.agents.Keys | Sort-Object) {
            $agent = $metrics.agents[$agentId]
            Write-Host "│ $agentId" -ForegroundColor White
            Write-Host "│   Tasks: $($agent.tasks_completed) | Success: $($agent.success_rate)%" -ForegroundColor Gray
            if ($agent.specialization.Count -gt 0) {
                Write-Host "│   Specialization: $($agent.specialization -join ', ')" -ForegroundColor Gray
            }
        }
        Write-Host "└──────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    }

    Write-Host ""

    # Save to history
    Save-Metrics-History $metrics
}

# Export metrics to file
function Export-Metrics {
    param($outputPath)

    $metrics = Collect-Metrics

    if (-not $outputPath) {
        $outputPath = "clickhub-metrics-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    }

    $metrics | ConvertTo-Json -Depth 10 | Set-Content $outputPath

    Write-Host "Metrics exported to: $outputPath" -ForegroundColor Green
}

# Generate daily report
function Generate-Daily-Report {
    # Load metrics history
    if (-not (Test-Path $metricsHistoryFile)) {
        Write-Host "No metrics history available" -ForegroundColor Yellow
        return
    }

    $today = Get-Date -Format "yyyy-MM-dd"
    $allMetrics = Get-Content $metricsHistoryFile | ForEach-Object {
        $_ | ConvertFrom-Json
    }

    $todayMetrics = $allMetrics | Where-Object { $_.date -eq $today }

    if ($todayMetrics.Count -eq 0) {
        Write-Host "No metrics for today" -ForegroundColor Yellow
        return
    }

    # Get first and last metric of the day
    $firstMetric = $todayMetrics | Select-Object -First 1
    $lastMetric = $todayMetrics | Select-Object -Last 1

    $tasksToday = $lastMetric.total_tasks - $firstMetric.total_tasks

    Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║          CLICKHUB DAILY REPORT                           ║" -ForegroundColor Cyan
    Write-Host "║          " -NoNewline -ForegroundColor Cyan
    Write-Host $today -NoNewline -ForegroundColor Cyan
    Write-Host ("" + (" " * (44 - $today.Length)) + "║") -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

    Write-Host "`nTasks Processed Today: $tasksToday" -ForegroundColor White
    Write-Host "Success Rate: $($lastMetric.success_rate)%" -ForegroundColor Green
    Write-Host "Avg Completion Time: $($lastMetric.avg_completion_minutes) minutes" -ForegroundColor White

    if ($lastMetric.orchestrator) {
        Write-Host "`nOrchestrator Cycles: $($lastMetric.orchestrator.cycles_completed)" -ForegroundColor White
    }

    if ($lastMetric.top_failures -and $lastMetric.top_failures.Count -gt 0) {
        Write-Host "`nTop Issues Today:" -ForegroundColor Yellow
        foreach ($failure in $lastMetric.top_failures) {
            Write-Host "  - $($failure.pattern) (x$($failure.count))" -ForegroundColor Red
            Write-Host "    Solution: $($failure.solution)" -ForegroundColor Gray
        }
    }

    Write-Host "`nEstimated Cost Today: EUR $($lastMetric.estimated_cost_eur)" -ForegroundColor White
}

# Generate weekly report
function Generate-Weekly-Report {
    # Similar to daily but for past 7 days
    # TODO: Implement full weekly aggregation
    Write-Host "Weekly report not yet implemented" -ForegroundColor Yellow
}

# Main execution
switch ($Action) {
    "Show" {
        Show-Dashboard
    }
    "Export" {
        Export-Metrics -outputPath $OutputPath
    }
    "Daily" {
        Generate-Daily-Report
    }
    "Weekly" {
        Generate-Weekly-Report
    }
}
