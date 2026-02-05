# Emergence Pattern Detector
# Detects unexpected patterns emerging from system interactions
# Part of Round 15: Meta-Level Systems Theory (#19)

param(
    [switch]$Analyze,
    [ValidateSet("Temporal", "Sequential", "Clustering", "All")]
    [string]$Pattern = "All",
    [int]$Days = 30,
    [switch]$Suggest
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$activityLog = "$rootDir\_machine\activity-log.json"

function Get-ActivityLog {
    if (Test-Path $activityLog) {
        return Get-Content $activityLog -Raw | ConvertFrom-Json
    }

    # Generate sample data if no log exists
    return @{
        activities = @()
    }
}

function Detect-TemporalClustering {
    param($Activities)

    Write-Host "`n=== TEMPORAL CLUSTERING DETECTION ===" -ForegroundColor Cyan

    $actionsByHour = @{}

    foreach ($activity in $Activities) {
        if ($activity.timestamp -match "(\d{2}):") {
            $hour = [int]$matches[1]
            if (-not $actionsByHour.ContainsKey($hour)) {
                $actionsByHour[$hour] = 0
            }
            $actionsByHour[$hour]++
        }
    }

    if ($actionsByHour.Count -gt 0) {
        Write-Host "`nActivity Distribution by Hour:" -ForegroundColor Yellow

        $total = ($actionsByHour.Values | Measure-Object -Sum).Sum
        $avg = $total / 24

        $actionsByHour.GetEnumerator() | Sort-Object Key | ForEach-Object {
            $bar = "█" * [Math]::Min(50, [Math]::Round($_.Value / $avg * 10))
            $percent = [Math]::Round(($_.Value / $total) * 100, 1)
            Write-Host ("  {0:D2}:00 | {1} ({2}%)" -f $_.Key, $bar, $percent) -ForegroundColor White
        }

        # Detect clusters (hours with activity > 2x average)
        $clusters = $actionsByHour.GetEnumerator() | Where-Object { $_.Value -gt ($avg * 2) } | Sort-Object Value -Descending

        if ($clusters.Count -gt 0) {
            Write-Host "`nClusters Detected (>2x average):" -ForegroundColor Green
            foreach ($cluster in $clusters) {
                Write-Host ("  {0:D2}:00 - {1} activities ({2:F1}x average)" -f $cluster.Key, $cluster.Value, ($cluster.Value / $avg)) -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "No temporal data available" -ForegroundColor Yellow
    }
}

function Detect-SequentialPatterns {
    param($Activities)

    Write-Host "`n=== SEQUENTIAL PATTERN DETECTION ===" -ForegroundColor Cyan

    $sequences = @{}

    for ($i = 0; $i -lt ($Activities.Count - 1); $i++) {
        $current = $Activities[$i].action
        $next = $Activities[$i + 1].action

        if ($current -and $next) {
            $pattern = "$current → $next"
            if (-not $sequences.ContainsKey($pattern)) {
                $sequences[$pattern] = 0
            }
            $sequences[$pattern]++
        }
    }

    if ($sequences.Count -gt 0) {
        Write-Host "`nTop 10 Sequential Patterns:" -ForegroundColor Yellow
        $sequences.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10 | ForEach-Object {
            Write-Host ("  {0} (occurs {1} times)" -f $_.Key, $_.Value) -ForegroundColor White
        }

        # Detect strong patterns (occur >10 times)
        $strongPatterns = $sequences.GetEnumerator() | Where-Object { $_.Value -gt 10 } | Sort-Object Value -Descending

        if ($strongPatterns.Count -gt 0) {
            Write-Host "`nStrong Patterns (>10 occurrences):" -ForegroundColor Green
            foreach ($pattern in $strongPatterns) {
                Write-Host ("  {0} ({1} times)" -f $pattern.Key, $pattern.Value) -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "No sequential pattern data available" -ForegroundColor Yellow
    }
}

function Detect-ActionClustering {
    param($Activities)

    Write-Host "`n=== ACTION CLUSTERING DETECTION ===" -ForegroundColor Cyan

    $actionCounts = @{}

    foreach ($activity in $Activities) {
        if ($activity.action) {
            if (-not $actionCounts.ContainsKey($activity.action)) {
                $actionCounts[$activity.action] = 0
            }
            $actionCounts[$activity.action]++
        }
    }

    if ($actionCounts.Count -gt 0) {
        $total = ($actionCounts.Values | Measure-Object -Sum).Sum

        Write-Host "`nTop 10 Actions:" -ForegroundColor Yellow
        $actionCounts.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10 | ForEach-Object {
            $percent = [Math]::Round(($_.Value / $total) * 100, 1)
            Write-Host ("  {0}: {1} ({2}%)" -f $_.Key, $_.Value, $percent) -ForegroundColor White
        }

        # 80/20 rule check
        $sortedActions = $actionCounts.GetEnumerator() | Sort-Object Value -Descending
        $cumulativePercent = 0
        $actionsFor80Percent = 0

        foreach ($action in $sortedActions) {
            $cumulativePercent += ($action.Value / $total) * 100
            $actionsFor80Percent++
            if ($cumulativePercent -ge 80) {
                break
            }
        }

        $percentOfActions = [Math]::Round(($actionsFor80Percent / $actionCounts.Count) * 100, 1)

        Write-Host "`n80/20 Rule Analysis:" -ForegroundColor Green
        Write-Host ("  Top {0} actions ({1}% of total) account for 80% of activity" -f $actionsFor80Percent, $percentOfActions) -ForegroundColor Yellow

        if ($percentOfActions -le 25) {
            Write-Host "  Strong 80/20 pattern detected - optimize these actions!" -ForegroundColor Green
        }
    }
    else {
        Write-Host "No action clustering data available" -ForegroundColor Yellow
    }
}

function Generate-Suggestions {
    param($Activities)

    Write-Host "`n=== IMPROVEMENT SUGGESTIONS FROM PATTERNS ===" -ForegroundColor Cyan

    if ($Activities.Count -eq 0) {
        Write-Host "No activity data to analyze" -ForegroundColor Yellow
        return
    }

    Write-Host "`nSuggestions based on emergent patterns:" -ForegroundColor Yellow

    # Generic suggestions
    Write-Host "`n1. Sequential Pattern Optimization:" -ForegroundColor Green
    Write-Host "   - If action X is always followed by Y, consider combining them" -ForegroundColor White
    Write-Host "   - Example: 'allocate-worktree → create-pr' could become single workflow" -ForegroundColor Gray

    Write-Host "`n2. Temporal Pattern Optimization:" -ForegroundColor Green
    Write-Host "   - Schedule resource-intensive tasks during low-activity hours" -ForegroundColor White
    Write-Host "   - Pre-load context before peak hours" -ForegroundColor Gray

    Write-Host "`n3. Action Clustering Optimization:" -ForegroundColor Green
    Write-Host "   - Focus optimization efforts on top 20% of actions (80/20 rule)" -ForegroundColor White
    Write-Host "   - Cache results for frequently repeated actions" -ForegroundColor Gray

    Write-Host "`n4. Emergence-Based Learning:" -ForegroundColor Green
    Write-Host "   - Document discovered patterns in best practices" -ForegroundColor White
    Write-Host "   - Update smart defaults based on actual usage patterns" -ForegroundColor Gray

    Write-Host "`n5. Automation Opportunities:" -ForegroundColor Green
    Write-Host "   - Strong sequential patterns suggest automation potential" -ForegroundColor White
    Write-Host "   - Temporal clusters suggest batch processing opportunities" -ForegroundColor Gray
}

# Main execution
$activities = Get-ActivityLog

if ($activities.activities.Count -eq 0) {
    Write-Host "No activity log data available" -ForegroundColor Yellow
    Write-Host "Activity logging will begin automatically as system is used" -ForegroundColor Gray
    exit
}

# Filter by date range
$cutoffDate = (Get-Date).AddDays(-$Days)
$recentActivities = $activities.activities | Where-Object {
    try {
        $activityDate = [DateTime]::Parse($_.timestamp)
        $activityDate -gt $cutoffDate
    }
    catch {
        $false
    }
}

Write-Host "Analyzing $($recentActivities.Count) activities from last $Days days..." -ForegroundColor Cyan

if ($Suggest) {
    Generate-Suggestions -Activities $recentActivities
}
elseif ($Analyze) {
    switch ($Pattern) {
        "Temporal" { Detect-TemporalClustering -Activities $recentActivities }
        "Sequential" { Detect-SequentialPatterns -Activities $recentActivities }
        "Clustering" { Detect-ActionClustering -Activities $recentActivities }
        "All" {
            Detect-TemporalClustering -Activities $recentActivities
            Detect-SequentialPatterns -Activities $recentActivities
            Detect-ActionClustering -Activities $recentActivities
        }
    }
}
else {
    Write-Host "Emergence Pattern Detector" -ForegroundColor Cyan
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  -Analyze -Pattern <type>  : Analyze patterns (Temporal, Sequential, Clustering, All)" -ForegroundColor White
    Write-Host "  -Suggest                  : Generate improvement suggestions from patterns" -ForegroundColor White
    Write-Host "  -Days <n>                 : Analyze last N days (default: 30)" -ForegroundColor White
}
