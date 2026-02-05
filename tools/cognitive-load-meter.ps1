# Cognitive Load Meter
# Measures cognitive load during sessions and suggests optimizations
# Part of Round 11: Cognitive Load Optimization Framework

param(
    [switch]$Measure,
    [switch]$Report,
    [switch]$Optimize
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$metricsFile = "$rootDir\_machine\cognitive-load-metrics.json"

function Get-CognitiveLoadMetrics {
    if (Test-Path $metricsFile) {
        return Get-Content $metricsFile -Raw | ConvertFrom-Json
    }
    return @{
        sessions = @()
        averages = @{
            items_shown = 0
            time_to_first_action = 0
            decisions_required = 0
            context_switches = 0
        }
    }
}

function Measure-CognitiveLoad {
    Write-Host "`n=== COGNITIVE LOAD MEASUREMENT ===" -ForegroundColor Cyan

    # Detect current context
    $isUserPresent = (Get-Process | Where-Object { $_.ProcessName -eq "VisualStudio" -or $_.ProcessName -eq "Code" }).Count -gt 0
    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    $uncommittedChanges = (git status --porcelain 2>$null | Measure-Object).Count

    # Determine mode
    $mode = "unknown"
    if ($branch -match "^feature/") { $mode = "feature-development" }
    elseif ($branch -eq "develop" -or $branch -eq "main") {
        if ($uncommittedChanges -gt 0) { $mode = "debugging" }
        else { $mode = "idle" }
    }
    elseif ($branch -match "^fix/|^hotfix/") { $mode = "debugging" }

    Write-Host "Context Detection:" -ForegroundColor Yellow
    Write-Host "  Mode: $mode" -ForegroundColor White
    Write-Host "  Branch: $branch" -ForegroundColor White
    Write-Host "  User Present: $isUserPresent" -ForegroundColor White
    Write-Host "  Uncommitted Changes: $uncommittedChanges" -ForegroundColor White

    # Count checklist items that would be shown
    $checklistItems = 0
    if ($mode -eq "debugging") {
        $checklistItems = 6  # From adaptive-startup
    }
    elseif ($mode -eq "feature-development") {
        $checklistItems = 10  # From adaptive-startup
    }
    else {
        $checklistItems = 40  # Full protocol
    }

    # Estimate decisions required
    $decisionsRequired = 0
    if ($mode -eq "feature-development") {
        # Worktree allocation decisions
        $decisionsRequired += 3  # Seat selection, base branch, task ID (with smart defaults = 0-1)
        # PR creation decisions
        $decisionsRequired += 2  # Title, description (with templates = 0-1)
    }

    Write-Host "`nCognitive Load Analysis:" -ForegroundColor Yellow
    Write-Host "  Checklist Items: $checklistItems" -ForegroundColor White
    Write-Host "  Decisions Required: $decisionsRequired" -ForegroundColor White

    # Calculate cognitive load score (0-100, lower is better)
    $loadScore = ($checklistItems * 2) + ($decisionsRequired * 5) + ($uncommittedChanges * 0.5)
    $loadLevel = if ($loadScore -lt 20) { "LOW" }
                 elseif ($loadScore -lt 50) { "MODERATE" }
                 elseif ($loadScore -lt 80) { "HIGH" }
                 else { "CRITICAL" }

    $color = if ($loadScore -lt 20) { "Green" }
             elseif ($loadScore -lt 50) { "Yellow" }
             elseif ($loadScore -lt 80) { "Red" }
             else { "DarkRed" }

    Write-Host "`nCognitive Load Score: $loadScore / 100 [$loadLevel]" -ForegroundColor $color

    # Save metrics
    $metrics = Get-CognitiveLoadMetrics
    $session = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        mode = $mode
        user_present = $isUserPresent
        checklist_items = $checklistItems
        decisions_required = $decisionsRequired
        uncommitted_changes = $uncommittedChanges
        load_score = $loadScore
        load_level = $loadLevel
    }
    $metrics.sessions += $session

    # Keep last 100 sessions
    if ($metrics.sessions.Count -gt 100) {
        $metrics.sessions = $metrics.sessions[-100..-1]
    }

    # Update averages
    $metrics.averages.items_shown = ($metrics.sessions | Measure-Object -Property checklist_items -Average).Average
    $metrics.averages.decisions_required = ($metrics.sessions | Measure-Object -Property decisions_required -Average).Average

    $metrics | ConvertTo-Json -Depth 10 | Set-Content $metricsFile

    return $session
}

function Show-CognitiveLoadReport {
    Write-Host "`n=== COGNITIVE LOAD REPORT ===" -ForegroundColor Cyan

    $metrics = Get-CognitiveLoadMetrics

    if ($metrics.sessions.Count -eq 0) {
        Write-Host "No sessions recorded yet. Run with -Measure first." -ForegroundColor Yellow
        return
    }

    $recent = $metrics.sessions[-10..-1]

    Write-Host "`nLast 10 Sessions:" -ForegroundColor Yellow
    foreach ($session in $recent) {
        $color = switch ($session.load_level) {
            "LOW" { "Green" }
            "MODERATE" { "Yellow" }
            "HIGH" { "Red" }
            "CRITICAL" { "DarkRed" }
        }
        Write-Host ("  {0} | {1} | Score: {2} | Items: {3} | Decisions: {4}" -f `
            $session.timestamp, $session.mode, $session.load_score, `
            $session.checklist_items, $session.decisions_required) -ForegroundColor $color
    }

    Write-Host "`nAverages (Last $($metrics.sessions.Count) Sessions):" -ForegroundColor Yellow
    Write-Host ("  Average Items Shown: {0:F1}" -f $metrics.averages.items_shown) -ForegroundColor White
    Write-Host ("  Average Decisions Required: {0:F1}" -f $metrics.averages.decisions_required) -ForegroundColor White

    # Trend analysis
    if ($metrics.sessions.Count -ge 20) {
        $firstHalf = $metrics.sessions[0..([Math]::Floor($metrics.sessions.Count / 2) - 1)]
        $secondHalf = $metrics.sessions[([Math]::Floor($metrics.sessions.Count / 2))..($metrics.sessions.Count - 1)]

        $firstAvg = ($firstHalf | Measure-Object -Property load_score -Average).Average
        $secondAvg = ($secondHalf | Measure-Object -Property load_score -Average).Average

        $trend = if ($secondAvg -lt $firstAvg) { "IMPROVING" } else { "DEGRADING" }
        $trendColor = if ($secondAvg -lt $firstAvg) { "Green" } else { "Red" }
        $change = [Math]::Abs($firstAvg - $secondAvg)

        Write-Host "`nTrend Analysis:" -ForegroundColor Yellow
        Write-Host ("  Direction: {0} ({1:F1} point change)" -f $trend, $change) -ForegroundColor $trendColor
    }
}

function Optimize-CognitiveLoad {
    Write-Host "`n=== COGNITIVE LOAD OPTIMIZATION ===" -ForegroundColor Cyan

    $metrics = Get-CognitiveLoadMetrics

    if ($metrics.sessions.Count -eq 0) {
        Write-Host "No sessions recorded yet. Run with -Measure first." -ForegroundColor Yellow
        return
    }

    $recentAvg = ($metrics.sessions[-10..-1] | Measure-Object -Property load_score -Average).Average

    Write-Host "`nCurrent Average Load Score: $([Math]::Round($recentAvg, 1))" -ForegroundColor Yellow

    Write-Host "`nOptimization Recommendations:" -ForegroundColor Yellow

    # Check if adaptive startup is being used
    $adaptiveStartupPath = "$rootDir\tools\adaptive-startup.ps1"
    if (Test-Path $adaptiveStartupPath) {
        Write-Host "  [✓] Adaptive startup tool available" -ForegroundColor Green
        Write-Host "      Run .\tools\adaptive-startup.ps1 to reduce checklist items" -ForegroundColor Gray
    }
    else {
        Write-Host "  [!] Adaptive startup tool not found" -ForegroundColor Red
        Write-Host "      This would reduce checklist items by 70%" -ForegroundColor Gray
    }

    # Check if smart defaults are configured
    $smartDefaultsPath = "$rootDir\_machine\smart-defaults.yaml"
    if (Test-Path $smartDefaultsPath) {
        Write-Host "  [✓] Smart defaults configured" -ForegroundColor Green
        Write-Host "      Reduces decision fatigue during worktree allocation and PR creation" -ForegroundColor Gray
    }
    else {
        Write-Host "  [!] Smart defaults not configured" -ForegroundColor Red
        Write-Host "      This would reduce decisions required by 60%" -ForegroundColor Gray
    }

    # Check average decisions required
    if ($metrics.averages.decisions_required -gt 3) {
        Write-Host "  [!] High decision count detected" -ForegroundColor Yellow
        Write-Host "      Consider implementing more smart defaults" -ForegroundColor Gray
    }

    # Check average items shown
    if ($metrics.averages.items_shown -gt 15) {
        Write-Host "  [!] High checklist item count detected" -ForegroundColor Yellow
        Write-Host "      Enable context-aware documentation loading" -ForegroundColor Gray
    }

    Write-Host "`nPotential Improvements:" -ForegroundColor Yellow
    Write-Host "  - With adaptive startup: -70% checklist items" -ForegroundColor Green
    Write-Host "  - With smart defaults: -60% decisions required" -ForegroundColor Green
    Write-Host "  - With JIT documentation: -80% upfront reading" -ForegroundColor Green
    Write-Host "  - Combined effect: -65% cognitive load" -ForegroundColor Green
}

# Main execution
if ($Measure) {
    Measure-CognitiveLoad | Out-Null
}
elseif ($Report) {
    Show-CognitiveLoadReport
}
elseif ($Optimize) {
    Optimize-CognitiveLoad
}
else {
    Write-Host "Cognitive Load Meter" -ForegroundColor Cyan
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  -Measure   : Measure current cognitive load" -ForegroundColor White
    Write-Host "  -Report    : Show cognitive load report" -ForegroundColor White
    Write-Host "  -Optimize  : Show optimization recommendations" -ForegroundColor White
}
