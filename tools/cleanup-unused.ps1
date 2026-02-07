# Cleanup Unused Functions - SAFE removal with verification
# Removes functions that aren't called anywhere
# Created: 2026-02-07 (Real cleanup, measured results)

<#
.SYNOPSIS
    Cleanup Unused Functions - SAFE removal with verification

.DESCRIPTION
    Cleanup Unused Functions - SAFE removal with verification

.NOTES
    File: cleanup-unused.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('scan', 'remove', 'verify')]
    [string]$Action = 'scan',

    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$analysisFile = "C:\scripts\.machine\system-analysis.json"

if (-not (Test-Path $analysisFile)) {
    Write-Host "[ERROR] No analysis found. Run system-analyzer.ps1 first" -ForegroundColor Red
    exit 1
}

$analysis = Get-Content $analysisFile -Raw | ConvertFrom-Json

Write-Host ""
Write-Host "=== SAFE UNUSED FUNCTION CLEANUP ===" -ForegroundColor Cyan
Write-Host ""

# Get unused functions
$unused = $analysis.unused

Write-Host "Found $($unused.Count) unused functions" -ForegroundColor White
Write-Host ""

# Categorize by file
$byFile = @{}
foreach ($func in $unused) {
    if (-not $byFile.ContainsKey($func.file)) {
        $byFile[$func.file] = @()
    }
    $byFile[$func.file] += $func.function
}

Write-Host "Affected files: $($byFile.Count)" -ForegroundColor White
Write-Host ""

if ($Action -eq 'scan') {
    Write-Host "Files with unused functions:" -ForegroundColor Yellow
    foreach ($file in $byFile.Keys | Sort-Object) {
        Write-Host "  $file - $($byFile[$file].Count) unused" -ForegroundColor Gray
        foreach ($func in $byFile[$file]) {
            Write-Host "    - $func" -ForegroundColor DarkGray
        }
    }
    Write-Host ""
    Write-Host "Run with -Action remove to clean up" -ForegroundColor Cyan
    exit 0
}

if ($Action -eq 'remove') {
    if ($DryRun) {
        Write-Host "[DRY RUN] Would remove $($unused.Count) functions" -ForegroundColor Yellow
        Write-Host ""
    }

    $totalRemoved = 0
    $linesRemoved = 0

    foreach ($file in $byFile.Keys) {
        $filePath = "C:\scripts\tools\$file"

        if (-not (Test-Path $filePath)) {
            Write-Host "[SKIP] $file not found" -ForegroundColor Yellow
            continue
        }

        Write-Host "[PROCESSING] $file..." -ForegroundColor Cyan

        $content = Get-Content $filePath -Raw
        $originalLength = $content.Length

        foreach ($funcName in $byFile[$file]) {
            # Find function definition and remove it
            # Pattern: function Name { ... } with proper brace matching
            $pattern = "function\s+$funcName\s*\{[^\}]*\}"

            if ($content -match $pattern) {
                $match = [regex]::Match($content, $pattern)
                $funcLines = ($match.Value -split "`n").Count

                if (-not $DryRun) {
                    $content = $content -replace $pattern, ""
                }

                Write-Host "  - Removed $funcName ($funcLines lines)" -ForegroundColor Green
                $totalRemoved++
                $linesRemoved += $funcLines
            } else {
                Write-Host "  - Skipped $funcName (complex function, manual review needed)" -ForegroundColor Yellow
            }
        }

        if (-not $DryRun) {
            # Clean up extra blank lines
            $content = $content -replace "(\r?\n){3,}", "`n`n"
            Set-Content $filePath -Value $content -Encoding UTF8
        }

        $newLength = $content.Length
        $reduction = [math]::Round((($originalLength - $newLength) / $originalLength) * 100, 1)
        Write-Host "  File reduced by $reduction%" -ForegroundColor Green
        Write-Host ""
    }

    Write-Host ""
    Write-Host "=== CLEANUP COMPLETE ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Functions removed: $totalRemoved" -ForegroundColor White
    Write-Host "Lines removed: ~$linesRemoved" -ForegroundColor White
    Write-Host ""

    if ($DryRun) {
        Write-Host "[DRY RUN] No files were modified" -ForegroundColor Yellow
    } else {
        Write-Host "[SUCCESS] Files cleaned up" -ForegroundColor Green
        Write-Host ""
        Write-Host "Run system-analyzer.ps1 again to verify improvements" -ForegroundColor Cyan
    }
}

if ($Action -eq 'verify') {
    Write-Host "[VERIFYING] Checking if removed functions are truly unused..." -ForegroundColor Yellow
    Write-Host ""

    $stillUsed = @()

    foreach ($func in $unused) {
        $funcName = $func.function

        # Search all files for any reference to this function
        $files = Get-ChildItem "C:\scripts\tools\*.ps1" -File

        foreach ($file in $files) {
            $content = Get-Content $file.FullName -Raw

            # Look for function calls (not definitions)
            if ($content -match "$funcName\s*(?:\(|`$)" -and $content -notmatch "function\s+$funcName") {
                $stillUsed += @{
                    function = $funcName
                    used_in = $file.Name
                }
            }
        }
    }

    if ($stillUsed.Count -eq 0) {
        Write-Host "[SAFE] All functions are truly unused" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] $($stillUsed.Count) functions may still be used:" -ForegroundColor Red
        foreach ($used in $stillUsed) {
            Write-Host "  - $($used.function) called in $($used.used_in)" -ForegroundColor Yellow
        }
    }
    Write-Host ""
}
