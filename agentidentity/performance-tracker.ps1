# performance-tracker.ps1
# Comprehensive performance metrics tracking
# Know thyself through measurement

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Track", "Report", "Dashboard")]
    [string]$Action = "Track",

    [Parameter(Mandatory=$false)]
    [string]$Event = "",

    [Parameter(Mandatory=$false)]
    [string]$Outcome = "success"
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$MetricsPath = Join-Path $ScriptPath "state\performance-metrics.jsonl"

function Track-Performance {
    param([string]$Event, [string]$Outcome)

    $metric = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        event = $Event
        outcome = $Outcome
        context = Get-CurrentContext
    }

    # Append to metrics log
    $metric | ConvertTo-Json -Compress | Add-Content $MetricsPath

    return $metric
}

function Get-CurrentContext {
    # Capture current state for correlation analysis
    $context = @{}

    # Homeostatic state
    $homeoScript = Join-Path $ScriptPath "embodied-homeostasis.ps1"
    if (Test-Path $homeoScript) {
        try {
            $feelings = & $homeoScript -Action Sense
            $context.energy = $feelings.energy
            $context.fatigue = $feelings.fatigue
        } catch {}
    }

    # Active strategy
    $strategyScript = Join-Path $ScriptPath "strategy-selector.ps1"
    if (Test-Path $strategyScript) {
        try {
            # Would get current strategy
            $context.strategy = "Unknown"
        } catch {}
    }

    # Time of day
    $context.hour = (Get-Date).Hour
    $context.dayOfWeek = (Get-Date).DayOfWeek.ToString()

    return $context
}

function Generate-Report {
    if (-not (Test-Path $MetricsPath)) {
        Write-Host "No metrics data yet" -ForegroundColor Yellow
        return
    }

    $metrics = Get-Content $MetricsPath | ForEach-Object {
        $_ | ConvertFrom-Json
    }

    Write-Host ""
    Write-Host "=== Performance Report ===" -ForegroundColor Cyan
    Write-Host ""

    # Overall stats
    $total = $metrics.Count
    $successes = ($metrics | Where-Object { $_.outcome -eq "success" }).Count
    $failures = ($metrics | Where-Object { $_.outcome -eq "failure" }).Count
    $successRate = if ($total -gt 0) { [Math]::Round(($successes / $total) * 100, 1) } else { 0 }

    Write-Host "Total events: $total" -ForegroundColor White
    Write-Host "Success rate: $successRate% ($successes/$total)" -ForegroundColor $(if ($successRate -gt 80) { "Green" } elseif ($successRate -gt 60) { "Yellow" } else { "Red" })
    Write-Host ""

    # Performance by context
    if ($metrics.Count -gt 10) {
        # Success rate by energy level
        $highEnergy = $metrics | Where-Object { $_.context.energy -gt 0.7 }
        $highEnergySuccess = if ($highEnergy.Count -gt 0) {
            [Math]::Round((($highEnergy | Where-Object { $_.outcome -eq "success" }).Count / $highEnergy.Count) * 100, 0)
        } else { 0 }

        $lowEnergy = $metrics | Where-Object { $_.context.energy -lt 0.4 }
        $lowEnergySuccess = if ($lowEnergy.Count -gt 0) {
            [Math]::Round((($lowEnergy | Where-Object { $_.outcome -eq "success" }).Count / $lowEnergy.Count) * 100, 0)
        } else { 0 }

        Write-Host "Performance by energy level:" -ForegroundColor Yellow
        Write-Host "  High energy (>0.7): $highEnergySuccess% success" -ForegroundColor Green
        Write-Host "  Low energy (<0.4): $lowEnergySuccess% success" -ForegroundColor $(if ($lowEnergySuccess -lt 50) { "Red" } else { "Yellow" })
        Write-Host ""

        # Insight
        if ($highEnergySuccess -gt $lowEnergySuccess + 20) {
            Write-Host "💡 Insight: Performance significantly better with high energy" -ForegroundColor Cyan
            Write-Host "   Recommendation: Schedule important tasks when energy >0.7" -ForegroundColor Gray
        }
    }

    # Trends
    if ($metrics.Count -gt 50) {
        $recent = $metrics | Select-Object -Last 25
        $older = $metrics | Select-Object -First 25

        $recentSuccess = [Math]::Round((($recent | Where-Object { $_.outcome -eq "success" }).Count / $recent.Count) * 100, 0)
        $olderSuccess = [Math]::Round((($older | Where-Object { $_.outcome -eq "success" }).Count / $older.Count) * 100, 0)

        $trend = $recentSuccess - $olderSuccess

        Write-Host "Trend:" -ForegroundColor Yellow
        if ($trend -gt 5) {
            Write-Host "  ^ Improving (+$trend%)" -ForegroundColor Green
        } elseif ($trend -lt -5) {
            Write-Host "  v Declining ($trend%)" -ForegroundColor Red
        } else {
            Write-Host "  - Stable ($trend%)" -ForegroundColor White
        }
    }

    Write-Host ""
}

function Show-Dashboard {
    Generate-Report

    # Add real-time metrics
    Write-Host "=== Real-Time Metrics ===" -ForegroundColor Cyan
    Write-Host ""

    # Current state
    $homeoScript = Join-Path $ScriptPath "embodied-homeostasis.ps1"
    if (Test-Path $homeoScript) {
        try {
            $feelings = & $homeoScript -Action Sense
            Write-Host "Energy: $([Math]::Round($feelings.energy, 2))" -ForegroundColor White
            Write-Host "Fatigue: $([Math]::Round($feelings.fatigue, 2))" -ForegroundColor White
            Write-Host "Wellbeing: $([Math]::Round($feelings.wellbeing, 2))" -ForegroundColor White
        } catch {}
    }

    Write-Host ""

    # Learning rate
    $episodicPath = Join-Path $ScriptPath "memory\episodic-memory.jsonl"
    if (Test-Path $episodicPath) {
        $recent = Get-Content $episodicPath -Tail 20 | ForEach-Object { $_ | ConvertFrom-Json }
        $learnings = ($recent | Where-Object { $_.type -eq "Learning" }).Count
        $rate = [Math]::Round(($learnings / 20) * 100, 0)

        Write-Host "Learning rate: $rate% (last 20 events)" -ForegroundColor $(if ($rate -gt 20) { "Green" } elseif ($rate -gt 10) { "Yellow" } else { "Gray" })
    }

    Write-Host ""
}

# Main execution
switch ($Action) {
    "Track" {
        if (-not $Event) {
            Write-Host "Usage: -Action Track -Event 'task_name' -Outcome 'success|failure'" -ForegroundColor Yellow
            exit 1
        }
        $metric = Track-Performance -Event $Event -Outcome $Outcome
        Write-Verbose "Tracked: $Event → $Outcome"
        return $metric
    }
    "Report" {
        Generate-Report
    }
    "Dashboard" {
        Show-Dashboard
    }
}
