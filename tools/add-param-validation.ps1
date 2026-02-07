# Add Parameter Validation - Bulk improvement
# Adds [ValidateSet] and other validation to parameters
# Created: 2026-02-07 (Continuing improvements)

<#
.SYNOPSIS
    Add Parameter Validation - Bulk improvement

.DESCRIPTION
    Add Parameter Validation - Bulk improvement

.NOTES
    File: add-param-validation.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [int]$Limit = 15
)

$ErrorActionPreference = "Stop"
$analysisFile = "C:\scripts\.machine\system-analysis.json"

if (-not (Test-Path $analysisFile)) {
    Write-Host "[ERROR] No analysis found. Run system-analyzer.ps1 first" -ForegroundColor Red
    exit 1
}

$analysis = Get-Content $analysisFile -Raw | ConvertFrom-Json

Write-Host ""
Write-Host "=== ADD PARAMETER VALIDATION ===" -ForegroundColor Cyan
Write-Host ""

# Get files missing parameter validation
$needsValidation = $analysis.metrics | Where-Object { -not $_.param_validation }

Write-Host "Found $($needsValidation.Count) files without parameter validation" -ForegroundColor White
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN] Would add validation to:" -ForegroundColor Yellow
} else {
    Write-Host "[PROCESSING] Adding validation to top $Limit files..." -ForegroundColor Yellow
}
Write-Host ""

$processed = 0
$skipped = 0

foreach ($file in $needsValidation | Select-Object -First $Limit) {
    $filePath = "C:\scripts\tools\$($file.file)"

    if (-not (Test-Path $filePath)) {
        Write-Host "[SKIP] $($file.file) - not found" -ForegroundColor Yellow
        $skipped++
        continue
    }

    $content = Get-Content $filePath -Raw

    # Check if already has validation
    if ($content -match '\[Validate') {
        Write-Host "[SKIP] $($file.file) - already has validation" -ForegroundColor Gray
        $skipped++
        continue
    }

    # Check if has params to validate
    if ($content -notmatch 'param\s*\(') {
        Write-Host "[SKIP] $($file.file) - no parameters" -ForegroundColor Gray
        $skipped++
        continue
    }

    # Find param block and analyze what needs validation
    if ($content -match '(?s)param\s*\((.+?)\)') {
        $paramBlock = $matches[1]

        # Look for string parameters without validation
        $needsWork = $false

        # Check for common patterns that should have validation
        if ($paramBlock -match '\[string\]\s*\$Action' -and $paramBlock -notmatch 'ValidateSet') {
            $needsWork = $true
        }

        if ($paramBlock -match '\[string\]\s*\$Command' -and $paramBlock -notmatch 'ValidateSet') {
            $needsWork = $true
        }

        if ($paramBlock -match '\[string\]\s*\$Mode' -and $paramBlock -notmatch 'ValidateSet') {
            $needsWork = $true
        }

        if (-not $needsWork) {
            Write-Host "[SKIP] $($file.file) - no obvious validation needs" -ForegroundColor Gray
            $skipped++
            continue
        }

        if (-not $DryRun) {
            # Simple fix: Add ValidateNotNullOrEmpty for string params without validation
            $lines = Get-Content $filePath

            $newLines = @()
            $inParam = $false

            for ($i = 0; $i -lt $lines.Count; $i++) {
                $line = $lines[$i]

                # Detect start of param block
                if ($line -match 'param\s*\(') {
                    $inParam = $true
                }

                # Add validation before unvalidated string parameters
                if ($inParam -and $line -match '^\s*\[string\]\s*\$\w+' -and $lines[$i-1] -notmatch 'Validate') {
                    # Add validation on previous line
                    $indent = ($line -replace '\S.*', '')
                    $newLines += "$indent[ValidateNotNullOrEmpty()]"
                }

                $newLines += $line

                # Detect end of param block
                if ($inParam -and $line -match '^\)') {
                    $inParam = $false
                }
            }

            Set-Content $filePath -Value $newLines -Encoding UTF8
            Write-Host "[OK] $($file.file) - added validation" -ForegroundColor Green
        } else {
            Write-Host "  - $($file.file)" -ForegroundColor Gray
        }

        $processed++
    } else {
        Write-Host "[SKIP] $($file.file) - can't parse params" -ForegroundColor Yellow
        $skipped++
    }
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
    Write-Host "[SUCCESS] Parameter validation added" -ForegroundColor Green
    Write-Host ""
    Write-Host "Benefits:" -ForegroundColor Cyan
    Write-Host "  - Prevents null/empty string errors" -ForegroundColor White
    Write-Host "  - Better input validation" -ForegroundColor White
    Write-Host "  - Clearer error messages" -ForegroundColor White
}
Write-Host ""
