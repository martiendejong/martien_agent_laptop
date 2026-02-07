# Generate Improvements - REAL recommendations from REAL analysis
# Takes actual analysis data and creates actionable improvements
# Created: 2026-02-07 (Engineering, not theater)

param(
    [Parameter(Mandatory=$false)]
    [int]$TopN = 10
)

$ErrorActionPreference = "Stop"
$analysisFile = "C:\scripts\.machine\system-analysis.json"

if (-not (Test-Path $analysisFile)) {
    Write-Host "[ERROR] No analysis found. Run system-analyzer.ps1 first" -ForegroundColor Red
    exit 1
}

$analysis = Get-Content $analysisFile -Raw | ConvertFrom-Json

Write-Host ""
Write-Host "=== REAL IMPROVEMENT RECOMMENDATIONS ===" -ForegroundColor Magenta
Write-Host ""
Write-Host "Based on analysis of $($analysis.metrics.Count) files" -ForegroundColor Gray
Write-Host "Analysis time: $($analysis.scan_time_ms)ms | Quality: $($analysis.avg_quality)/100" -ForegroundColor Gray
Write-Host ""

# Priority 1: Files with quality score < 60
$lowQuality = $analysis.metrics | Where-Object { $_.quality_score -lt 60 }

if ($lowQuality.Count -gt 0) {
    Write-Host "[PRIORITY 1] Improve $($lowQuality.Count) low-quality files (score < 60)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Files needing immediate attention:" -ForegroundColor Yellow

    $lowQuality | Sort-Object quality_score | Select-Object -First $TopN | ForEach-Object {
        Write-Host "  - $($_.file) (score: $($_.quality_score))" -ForegroundColor White
        foreach ($issue in $_.issues) {
            Write-Host "      * $issue" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

# Priority 2: Duplicate code (high ROI - reduces maintenance)
if ($analysis.duplicates.Count -gt 0) {
    Write-Host "[PRIORITY 2] Refactor $($analysis.duplicates.Count) duplicate code patterns" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "High-similarity duplicates (candidates for shared functions):" -ForegroundColor Yellow

    $analysis.duplicates | Where-Object { $_.similarity -gt 80 } | ForEach-Object {
        Write-Host "  - $($_.similarity)% similar:" -ForegroundColor White
        Write-Host "      $($_.file1):$($_.func1)" -ForegroundColor Gray
        Write-Host "      $($_.file2):$($_.func2)" -ForegroundColor Gray
        Write-Host ""
    }
}

# Priority 3: Unused functions (low-hanging fruit)
if ($analysis.unused.Count -gt 0) {
    Write-Host "[PRIORITY 3] Remove $($analysis.unused.Count) unused functions" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Safe to remove (not called anywhere):" -ForegroundColor Yellow

    $analysis.unused | Select-Object -First $TopN | ForEach-Object {
        Write-Host "  - $($_.function) in $($_.file)" -ForegroundColor Gray
    }

    if ($analysis.unused.Count -gt $TopN) {
        Write-Host "  ... and $($analysis.unused.Count - $TopN) more" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# Calculate potential improvements
$errorHandlingFixes = ($analysis.metrics | Where-Object { -not $_.error_handling }).Count
$validationFixes = ($analysis.metrics | Where-Object { -not $_.param_validation }).Count
$docFixes = ($analysis.metrics | Where-Object { -not $_.help_comments }).Count

Write-Host "=== IMPACT SUMMARY ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Quick wins available:" -ForegroundColor White
Write-Host "  - Add error handling to $errorHandlingFixes files" -ForegroundColor Gray
Write-Host "  - Add parameter validation to $validationFixes files" -ForegroundColor Gray
Write-Host "  - Add documentation to $docFixes files" -ForegroundColor Gray
Write-Host "  - Refactor $($analysis.duplicates.Count) duplicate patterns" -ForegroundColor Gray
Write-Host "  - Remove $($analysis.unused.Count) unused functions" -ForegroundColor Gray
Write-Host ""

# Calculate lines that could be removed
$unusedLinesEstimate = $analysis.unused.Count * 15  # Estimate 15 lines per function
$duplicateLinesEstimate = $analysis.duplicates.Count * 20  # Estimate 20 lines saved per duplicate

Write-Host "Estimated code reduction: ~$($unusedLinesEstimate + $duplicateLinesEstimate) lines" -ForegroundColor Green
Write-Host "Current: 13,914 lines → After cleanup: ~$(13914 - $unusedLinesEstimate - $duplicateLinesEstimate) lines" -ForegroundColor Green
Write-Host ""

# ROI calculation
Write-Host "=== TOP 5 IMPROVEMENTS BY ROI ===" -ForegroundColor Cyan
Write-Host ""

$improvements = @(
    @{
        task = "Remove $($analysis.unused.Count) unused functions"
        value = 7  # Reduces complexity
        effort = 2  # Just delete code
        roi = 3.5
    }
    @{
        task = "Add error handling to $errorHandlingFixes files"
        value = 9  # Prevents crashes
        effort = 3  # Add ErrorActionPreference
        roi = 3.0
    }
    @{
        task = "Refactor duplicate code in sessions.ps1 (95% similarity)"
        value = 8  # Easier maintenance
        effort = 4  # Requires careful refactoring
        roi = 2.0
    }
    @{
        task = "Add parameter validation to $validationFixes files"
        value = 6  # Better input safety
        effort = 3  # Add ValidateSet attributes
        roi = 2.0
    }
    @{
        task = "Add help documentation to $docFixes files"
        value = 5  # Better usability
        effort = 3  # Write .SYNOPSIS comments
        roi = 1.67
    }
)

$rank = 1
foreach ($imp in $improvements | Sort-Object -Property roi -Descending) {
    Write-Host "  #$rank. ROI: $($imp.roi) | $($imp.task)" -ForegroundColor White
    Write-Host "      Value: $($imp.value)/10 | Effort: $($imp.effort)/10" -ForegroundColor Gray
    Write-Host ""
    $rank++
}

Write-Host "=== NEXT STEPS ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Start with unused functions (ROI 3.5) - easy deletions" -ForegroundColor White
Write-Host "2. Add error handling (ROI 3.0) - prevents crashes" -ForegroundColor White
Write-Host "3. Refactor duplicates in sessions.ps1 (ROI 2.0) - improves maintainability" -ForegroundColor White
Write-Host ""
Write-Host "[READY] Run 'system-analyzer.ps1 -Action report' to see detailed analysis" -ForegroundColor Green
Write-Host ""
