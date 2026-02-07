# Add Help Documentation - Bulk improvement
# Adds .SYNOPSIS and .DESCRIPTION to functions/scripts
# Created: 2026-02-07 (Continuing improvements)

param(
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [int]$Limit = 20
)

$ErrorActionPreference = "Stop"
$analysisFile = "C:\scripts\.machine\system-analysis.json"

if (-not (Test-Path $analysisFile)) {
    Write-Host "[ERROR] No analysis found. Run system-analyzer.ps1 first" -ForegroundColor Red
    exit 1
}

$analysis = Get-Content $analysisFile -Raw | ConvertFrom-Json

Write-Host ""
Write-Host "=== ADD HELP DOCUMENTATION ===" -ForegroundColor Cyan
Write-Host ""

# Get files missing help comments
$needsDocs = $analysis.metrics | Where-Object { -not $_.help_comments }

Write-Host "Found $($needsDocs.Count) files without help documentation" -ForegroundColor White
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN] Would add documentation to:" -ForegroundColor Yellow
} else {
    Write-Host "[PROCESSING] Adding docs to top $Limit files..." -ForegroundColor Yellow
}
Write-Host ""

$processed = 0
$skipped = 0

foreach ($file in $needsDocs | Select-Object -First $Limit) {
    $filePath = "C:\scripts\tools\$($file.file)"

    if (-not (Test-Path $filePath)) {
        Write-Host "[SKIP] $($file.file) - not found" -ForegroundColor Yellow
        $skipped++
        continue
    }

    $content = Get-Content $filePath -Raw

    # Check if already has help
    if ($content -match '\.SYNOPSIS|\.DESCRIPTION') {
        Write-Host "[SKIP] $($file.file) - already has documentation" -ForegroundColor Gray
        $skipped++
        continue
    }

    if (-not $DryRun) {
        $lines = Get-Content $filePath

        # Extract purpose from first comment line (usually line 1 or 2)
        $purpose = ""
        for ($i = 0; $i -lt [Math]::Min(5, $lines.Count); $i++) {
            if ($lines[$i] -match '^#\s*(.+)') {
                $purpose = $matches[1]
                if ($purpose -notmatch '^-+$' -and $purpose.Length -gt 10) {
                    break
                }
            }
        }

        if (-not $purpose) {
            $purpose = "PowerShell script: $($file.file)"
        }

        # Build help block
        $helpBlock = @"
<#
.SYNOPSIS
    $purpose

.DESCRIPTION
    $purpose

.NOTES
    File: $($file.file)
    Auto-generated help documentation
#>

"@

        # Find where to insert (after shebang, before param or first code)
        $insertIdx = 0

        # Skip shebang if present
        if ($lines[0] -match '^#!') {
            $insertIdx = 1
        }

        # Skip initial comment block
        while ($insertIdx -lt $lines.Count -and $lines[$insertIdx] -match '^\s*#') {
            $insertIdx++
        }

        # Skip blank lines
        while ($insertIdx -lt $lines.Count -and $lines[$insertIdx] -match '^\s*$') {
            $insertIdx++
        }

        # Insert help block
        $newLines = @()
        if ($insertIdx -gt 0) {
            $newLines += $lines[0..($insertIdx-1)]
        }
        $newLines += $helpBlock -split "`n"
        if ($insertIdx -lt $lines.Count) {
            $newLines += $lines[$insertIdx..($lines.Count-1)]
        }

        Set-Content $filePath -Value $newLines -Encoding UTF8
        Write-Host "[OK] $($file.file) - added help documentation" -ForegroundColor Green
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
    Write-Host "[SUCCESS] Help documentation added" -ForegroundColor Green
    Write-Host ""
    Write-Host "Benefits:" -ForegroundColor Cyan
    Write-Host "  - Better discoverability with Get-Help" -ForegroundColor White
    Write-Host "  - Clearer purpose for each script" -ForegroundColor White
    Write-Host "  - Professional appearance" -ForegroundColor White
}
Write-Host ""
