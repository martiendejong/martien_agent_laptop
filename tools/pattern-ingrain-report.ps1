# Pattern Ingrain Progress Report
# Analyzes pattern-applications.jsonl to track ingrain progress over time
# Usage: .\pattern-ingrain-report.ps1 [-Days 7] [-Pattern "Read before Edit"]

param(
    [int]$Days = 7,
    [string]$Pattern = $null,
    [switch]$Summary
)

$ErrorActionPreference = 'Stop'

# Paths
$applicationsLog = "$PSScriptRoot\..\agentidentity\state\pattern-applications.jsonl"
$protocolPath = "$PSScriptRoot\..\agentidentity\protocols\PATTERN_INGRAIN_PROTOCOL.md"

# Check if log exists
if (-not (Test-Path $applicationsLog)) {
    Write-Host "No pattern applications logged yet." -ForegroundColor Yellow
    Write-Host "Log will be created when pattern-guard is used." -ForegroundColor Gray
    exit 0
}

# Load applications
$applications = Get-Content $applicationsLog | ForEach-Object { $_ | ConvertFrom-Json }

# Filter by date range
$cutoffDate = (Get-Date).AddDays(-$Days)
$recentApps = $applications | Where-Object {
    try {
        $appDate = [DateTime]::Parse($_.ts)
        $appDate -gt $cutoffDate
    } catch {
        $false
    }
}

if ($recentApps.Count -eq 0) {
    Write-Host "No pattern applications in last $Days days." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "=== PATTERN INGRAIN REPORT ===" -ForegroundColor Cyan
Write-Host "Period: Last $Days days" -ForegroundColor Gray
Write-Host "Total applications: $($recentApps.Count)" -ForegroundColor Gray
Write-Host ""

# Group by checkpoint
$byCheckpoint = $recentApps | Group-Object checkpoint

Write-Host "--- By Checkpoint ---" -ForegroundColor Yellow
foreach ($group in $byCheckpoint) {
    $total = $group.Count
    $passed = ($group.Group | Where-Object { $_.result -eq 'passed' }).Count
    $warned = ($group.Group | Where-Object { $_.result -eq 'warned' }).Count
    $blocked = ($group.Group | Where-Object { $_.result -eq 'blocked' }).Count

    $passRate = if ($total -gt 0) { [math]::Round(($passed / $total) * 100, 1) } else { 0 }

    Write-Host "  $($group.Name): $total applications" -ForegroundColor Cyan
    Write-Host "    Passed: $passed ($passRate%)" -ForegroundColor Green
    Write-Host "    Warned: $warned" -ForegroundColor Yellow
    Write-Host "    Blocked: $blocked" -ForegroundColor Red
}

Write-Host ""
Write-Host "--- Trend Analysis ---" -ForegroundColor Yellow

# Calculate trend (first half vs second half of period)
$midpoint = $cutoffDate.AddDays($Days / 2)
$firstHalf = $recentApps | Where-Object {
    try {
        $appDate = [DateTime]::Parse($_.ts)
        $appDate -le $midpoint
    } catch {
        $false
    }
}
$secondHalf = $recentApps | Where-Object {
    try {
        $appDate = [DateTime]::Parse($_.ts)
        $appDate -gt $midpoint
    } catch {
        $false
    }
}

if ($firstHalf.Count -gt 0 -and $secondHalf.Count -gt 0) {
    $firstPassRate = if ($firstHalf.Count -gt 0) {
        [math]::Round((($firstHalf | Where-Object { $_.result -eq 'passed' }).Count / $firstHalf.Count) * 100, 1)
    } else { 0 }

    $secondPassRate = if ($secondHalf.Count -gt 0) {
        [math]::Round((($secondHalf | Where-Object { $_.result -eq 'passed' }).Count / $secondHalf.Count) * 100, 1)
    } else { 0 }

    $trend = $secondPassRate - $firstPassRate
    $trendSymbol = if ($trend -gt 5) { "[UP] IMPROVING" }
                   elseif ($trend -lt -5) { "[DOWN] DECLINING" }
                   else { "[STABLE]" }

    Write-Host "  First half: $firstPassRate% passed ($($firstHalf.Count) apps)" -ForegroundColor Gray
    Write-Host "  Second half: $secondPassRate% passed ($($secondHalf.Count) apps)" -ForegroundColor Gray
    Write-Host "  Trend: $trendSymbol ($([math]::Abs($trend))% change)" -ForegroundColor $(
        if ($trend -gt 5) { "Green" } elseif ($trend -lt -5) { "Red" } else { "Yellow" }
    )
} else {
    Write-Host "  Not enough data for trend analysis (need data across time period)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "--- Ingrain Status ---" -ForegroundColor Yellow

# Calculate ingrain rate (automatic application rate)
# For now, we consider "passed" = automatic (pattern satisfied without blocking)
# "warned" = partial (some manual reminder needed)
# "blocked" = external (violated pattern)

$totalApps = $recentApps.Count
$automaticApps = ($recentApps | Where-Object { $_.result -eq 'passed' }).Count
$partialApps = ($recentApps | Where-Object { $_.result -eq 'warned' }).Count
$violatedApps = ($recentApps | Where-Object { $_.result -eq 'blocked' }).Count

$automaticRate = if ($totalApps -gt 0) { [math]::Round(($automaticApps / $totalApps) * 100, 1) } else { 0 }
$partialRate = if ($totalApps -gt 0) { [math]::Round(($partialApps / $totalApps) * 100, 1) } else { 0 }
$violatedRate = if ($totalApps -gt 0) { [math]::Round(($violatedApps / $totalApps) * 100, 1) } else { 0 }

Write-Host "  Automatic (passed): $automaticRate% ($automaticApps/$totalApps)" -ForegroundColor Green
Write-Host "  Partial (warned): $partialRate% ($partialApps/$totalApps)" -ForegroundColor Yellow
Write-Host "  Violated (blocked): $violatedRate% ($violatedApps/$totalApps)" -ForegroundColor Red

Write-Host ""

# Success criteria check
$targetIngrainRate = 90
if ($automaticRate -ge $targetIngrainRate) {
    Write-Host "[PASS] TARGET ACHIEVED: $automaticRate% >= $targetIngrainRate% target" -ForegroundColor Green
} else {
    $gap = $targetIngrainRate - $automaticRate
    Write-Host "[WORK] IN PROGRESS: $gap% gap to $targetIngrainRate% target" -ForegroundColor Yellow
}

# Estimate time to target (based on trend)
if ($firstHalf.Count -gt 0 -and $secondHalf.Count -gt 0 -and $trend -gt 0) {
    $weeksToTarget = [math]::Ceiling($gap / ($trend * ($Days / 7)))
    if ($weeksToTarget -le 4) {
        Write-Host "[PROJ] Estimated: $weeksToTarget weeks to target (at current $trend% per week improvement)" -ForegroundColor Cyan
    }
}

Write-Host ""
