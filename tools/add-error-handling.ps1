# Add Error Handling - Bulk improvement
# Adds $ErrorActionPreference to files missing it
# Created: 2026-02-07 (Safe, high-ROI improvement)

<#
.SYNOPSIS
    Add Error Handling - Bulk improvement

.DESCRIPTION
    Add Error Handling - Bulk improvement

.NOTES
    File: add-error-handling.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [int]$Limit = 10
)

$ErrorActionPreference = "Stop"
$analysisFile = "C:\scripts\.machine\system-analysis.json"

if (-not (Test-Path $analysisFile)) {
    Write-Host "[ERROR] No analysis found. Run system-analyzer.ps1 first" -ForegroundColor Red
    exit 1
}

$analysis = Get-Content $analysisFile -Raw | ConvertFrom-Json

Write-Host ""
Write-Host "=== ADD ERROR HANDLING ===" -ForegroundColor Cyan
Write-Host ""

# Get files missing error handling
$needsErrorHandling = $analysis.metrics | Where-Object { -not $_.error_handling }

Write-Host "Found $($needsErrorHandling.Count) files without error handling" -ForegroundColor White
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN] Would add error handling to:" -ForegroundColor Yellow
} else {
    Write-Host "[PROCESSING] Adding error handling to top $Limit files..." -ForegroundColor Yellow
}
Write-Host ""

$processed = 0
$skipped = 0

foreach ($file in $needsErrorHandling | Select-Object -First $Limit) {
    $filePath = "C:\scripts\tools\$($file.file)"

    if (-not (Test-Path $filePath)) {
        Write-Host "[SKIP] $($file.file) - not found" -ForegroundColor Yellow
        $skipped++
        continue
    }

    $content = Get-Content $filePath -Raw

    # Check if it already has error handling (sanity check)
    if ($content -match '\$ErrorActionPreference') {
        Write-Host "[SKIP] $($file.file) - already has error handling" -ForegroundColor Gray
        $skipped++
        continue
    }

    # Find where to insert (after param block or at start)
    $insertLine = 1

    if ($content -match '(?s)^(.*?param\s*\([^\)]+\))') {
        # Has param block - insert after it
        $paramBlock = $matches[1]
        $paramEnd = $content.IndexOf($paramBlock) + $paramBlock.Length

        # Find next newline after param block
        $nextNewline = $content.IndexOf("`n", $paramEnd)
        if ($nextNewline -gt 0) {
            $insertLine = ($content.Substring(0, $nextNewline) -split "`n").Count + 1
        }
    }

    if (-not $DryRun) {
        # Read as lines
        $lines = Get-Content $filePath

        # Insert error handling
        $errorLine = '$ErrorActionPreference = "Stop"'

        if ($insertLine -gt 1) {
            # After param block
            $newLines = @()
            $newLines += $lines[0..($insertLine-2)]
            $newLines += ""
            $newLines += $errorLine
            if ($insertLine -le $lines.Count) {
                $newLines += $lines[($insertLine-1)..($lines.Count-1)]
            }
        } else {
            # At start of file
            $newLines = @($errorLine, "") + $lines
        }

        Set-Content $filePath -Value $newLines -Encoding UTF8
        Write-Host "[OK] $($file.file) - added error handling at line $insertLine" -ForegroundColor Green
    } else {
        Write-Host "  - $($file.file)" -ForegroundColor Gray
    }

    $processed++
}

Write-Host ""
Write-Host "=== COMPLETE ===" -ForegroundColor Green
Write-Host ""
Write-Host "Files processed: $processed" -ForegroundColor White
Write-Host "Files skipped: $skipped" -ForegroundColor Gray
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN] Run without -DryRun to apply changes" -ForegroundColor Yellow
} else {
    Write-Host "[SUCCESS] Error handling added" -ForegroundColor Green
    Write-Host ""
    Write-Host "Benefits:" -ForegroundColor Cyan
    Write-Host "  - Scripts will stop on errors (prevents cascading failures)" -ForegroundColor White
    Write-Host "  - Easier debugging (clear failure points)" -ForegroundColor White
    Write-Host "  - More predictable behavior" -ForegroundColor White
}
Write-Host ""
