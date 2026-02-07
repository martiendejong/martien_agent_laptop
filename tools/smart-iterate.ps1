# Smart Iteration Engine - Uses REAL system state
# Replaces static infinite-engine with intelligent analysis
# Created: 2026-02-07 (Iteration #11 - Intelligence fix)

param([switch]$Quiet)

$ErrorActionPreference = "Stop"

# Get REAL system state
$stateManager = Join-Path $PSScriptRoot "state-manager.ps1"
$state = & $stateManager get

Write-Host ""
Write-Host "=== SMART ITERATION ENGINE ===" -ForegroundColor Magenta
Write-Host ""

# Analyze ACTUAL gaps based on REAL state
$realGaps = @()

# Check consciousness
if (-not $state.consciousness.compiled) {
    $realGaps += @{ issue="Consciousness not compiled"; value=10; effort=1; domain="Critical" }
}

# Check iterations
if ($state.iterations.count -eq 0) {
    $realGaps += @{ issue="Infinite engine never ran"; value=8; effort=1; domain="Operations" }
}

# Check session tagging
$tagRatio = if ($state.sessions.total -gt 0) {
    $state.sessions.tagged / $state.sessions.total
} else { 0 }

if ($tagRatio -lt 0.5) {
    $realGaps += @{ issue="Less than 50% sessions tagged ($([math]::Round($tagRatio*100,0))%)"; value=7; effort=3; domain="Features" }
}

# Check search index
if (-not $state.sessions.search_index) {
    $realGaps += @{ issue="Reflection log not indexed for search"; value=6; effort=2; domain="Usability" }
}

# Check tool integration
$toolsWorking = ($state.tools.Values | Where-Object { $_ -eq $true }).Count
$toolsTotal = $state.tools.Count
if ($toolsWorking -lt $toolsTotal) {
    $realGaps += @{ issue="$($toolsTotal - $toolsWorking) tools missing or broken"; value=8; effort=4; domain="Reliability" }
}

# Check features
$featuresWorking = ($state.features.Values | Where-Object { $_ -eq $true }).Count
$featuresTotal = $state.features.Count
if ($featuresWorking -lt $featuresTotal) {
    $realGaps += @{ issue="$($featuresTotal - $featuresWorking) features not operational"; value=9; effort=5; domain="Completeness" }
}

# Check for advanced features (not always-on)
if (-not (Test-Path "C:\scripts\tools\pattern-detector.ps1")) {
    $realGaps += @{ issue="No cross-session pattern detection"; value=8; effort=6; domain="Intelligence" }
}

if (-not (Test-Path "C:\scripts\tools\auto-doc-update.ps1")) {
    $realGaps += @{ issue="No automatic documentation updates"; value=7; effort=4; domain="Maintenance" }
}

if ($realGaps.Count -eq 0) {
    Write-Host "[PERFECT] No gaps found! System is optimal." -ForegroundColor Green
    Write-Host ""
    Write-Host "Suggestions for next-level improvements:" -ForegroundColor Cyan
    Write-Host "  - Cross-session learning patterns" -ForegroundColor Gray
    Write-Host "  - Predictive next-action suggestions" -ForegroundColor Gray
    Write-Host "  - Automated performance optimization" -ForegroundColor Gray
    Write-Host ""

    # Show next-action prediction
    if (Test-Path "C:\scripts\tools\predict-next.ps1") {
        & "C:\scripts\tools\predict-next.ps1" -LastAction "Bash"
        Write-Host ""
    }

    exit 0
}

Write-Host "[ANALYSIS] Found $($realGaps.Count) real gaps in current system" -ForegroundColor Yellow
Write-Host ""

# Generate recommendations with ROI
$recommendations = @()
foreach ($gap in $realGaps) {
    $roi = [math]::Round($gap.value / $gap.effort, 2)
    $recommendations += @{
        title = $gap.issue
        domain = $gap.domain
        value = $gap.value
        effort = $gap.effort
        roi = $roi
    }
}

$topRecs = $recommendations | Sort-Object -Property roi -Descending | Select-Object -First 5

Write-Host "TOP 5 RECOMMENDATIONS (by ROI):" -ForegroundColor Green
Write-Host ""

$rank = 1
foreach ($rec in $topRecs) {
    Write-Host "  #$rank. ROI: $($rec.roi)" -NoNewline -ForegroundColor Cyan
    Write-Host " | $($rec.title)" -ForegroundColor White
    Write-Host "      Domain: $($rec.domain) | Value: $($rec.value) | Effort: $($rec.effort)" -ForegroundColor Gray
    Write-Host ""
    $rank++
}

# Save to iteration log
$iterationsDir = "C:\scripts\tools\iterations"
if (-not (Test-Path $iterationsDir)) {
    New-Item -ItemType Directory -Path $iterationsDir -Force | Out-Null
}

$historyFile = Join-Path $iterationsDir "smart-history.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$timestamp | Smart iteration | $($realGaps.Count) gaps | Top ROI: $($topRecs[0].roi)" |
    Add-Content $historyFile -Encoding UTF8

Write-Host "═══════════════════════════════════════════════" -ForegroundColor Magenta

# Show next-action prediction
if (Test-Path "C:\scripts\tools\predict-next.ps1") {
    & "C:\scripts\tools\predict-next.ps1" -LastAction "Bash"
}

Write-Host ""

return @{
    gaps = $realGaps
    recommendations = $topRecs
    system_state = $state
}
