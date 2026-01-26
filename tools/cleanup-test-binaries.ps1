#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Clean test project build artifacts (bin/obj folders)

.DESCRIPTION
    Removes bin/obj folders from test projects to reclaim disk space.
    These folders are regenerated on next build.

.PARAMETER ProjectPath
    Path to the project root (default: C:\Projects\hazina)

.PARAMETER DryRun
    Show what would be deleted without actually deleting

.EXAMPLE
    cleanup-test-binaries.ps1 -DryRun
    cleanup-test-binaries.ps1 -ProjectPath C:\Projects\hazina
#>

param(
    [string]$ProjectPath = "C:\Projects\hazina",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Write-Host "Cleaning test project binaries in: $ProjectPath" -ForegroundColor Cyan
Write-Host ""

# Find all bin/obj folders in tests directory
$testsPath = Join-Path $ProjectPath "tests"
if (-not (Test-Path $testsPath)) {
    Write-Host "ERROR: Tests directory not found: $testsPath" -ForegroundColor Red
    exit 1
}

$foldersToDelete = @(
    Get-ChildItem -Path $testsPath -Recurse -Directory -Filter "bin" -ErrorAction SilentlyContinue
    Get-ChildItem -Path $testsPath -Recurse -Directory -Filter "obj" -ErrorAction SilentlyContinue
)

if ($foldersToDelete.Count -eq 0) {
    Write-Host "SUCCESS: No bin/obj folders found - already clean!" -ForegroundColor Green
    exit 0
}

# Calculate total size
$totalSize = 0
foreach ($folder in $foldersToDelete) {
    try {
        $size = (Get-ChildItem -Path $folder.FullName -Recurse -File -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum
        $totalSize += $size
    } catch {
        # Skip if can't calculate
    }
}

$totalSizeMB = [math]::Round($totalSize / 1MB, 2)

Write-Host "ANALYSIS: Found $($foldersToDelete.Count) folders to delete" -ForegroundColor Yellow
Write-Host "DISK SPACE: Total size: $totalSizeMB MB" -ForegroundColor Yellow
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN - Would delete:" -ForegroundColor Cyan
    foreach ($folder in $foldersToDelete) {
        $relativePath = $folder.FullName.Replace($ProjectPath, ".")
        Write-Host "  - $relativePath" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "TIP: Run without -DryRun to actually delete" -ForegroundColor Yellow
} else {
    Write-Host "DELETING: Removing folders..." -ForegroundColor Yellow

    $deleted = 0
    $failed = 0

    foreach ($folder in $foldersToDelete) {
        try {
            Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction Stop
            $deleted++
            Write-Host "  [OK] Deleted: $($folder.FullName.Replace($ProjectPath, '.'))" -ForegroundColor Green
        } catch {
            $failed++
            Write-Host "  [FAIL] Failed: $($folder.FullName.Replace($ProjectPath, '.'))" -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host "SUCCESS: Deleted $deleted folders" -ForegroundColor Green
    Write-Host "DISK SPACE: Reclaimed ~$totalSizeMB MB" -ForegroundColor Green

    if ($failed -gt 0) {
        Write-Host "WARNING: Failed to delete $failed folders (may be locked by VS/Rider)" -ForegroundColor Yellow
    }
}
