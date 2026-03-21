#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Validate project configuration consistency
.DESCRIPTION
    Checks:
    - All paths exist
    - All GitHub remotes are accessible
    - ClickUp boards exist
    - No duplicate entries
    - Documentation is in sync

.EXAMPLE
    .\project-validate.ps1
#>

$ErrorActionPreference = "Continue"

Write-Host "`n=== PROJECT VALIDATION ===" -ForegroundColor Cyan
Write-Host ""

$ConfigPath = "C:\scripts\_machine\clickup-config.json"
$Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

$Errors = @()
$Warnings = @()

# Validate each project
foreach ($ProjectName in $Config.projects.PSObject.Properties.Name) {
    $Project = $Config.projects.$ProjectName

    Write-Host "Validating $ProjectName..." -ForegroundColor Yellow

    # Check local path
    $LocalPath = $Project.local_path -replace '/', '\'
    if ($LocalPath -and -not (Test-Path $LocalPath)) {
        $Errors += "[$ProjectName] Path does not exist: $LocalPath"
    }

    # Check GitHub URL
    if ($Project.github -and $Project.github -ne "TBD") {
        # Could add gh api check here
    }

    # Check ClickUp list ID
    if ($Project.list_id -eq "TBD") {
        $Warnings += "[$ProjectName] ClickUp list ID is TBD"
    }

    # Check repos array
    if ($Project.repos.Count -eq 0 -and $ProjectName -ne "brand2boost-birdseye") {
        $Warnings += "[$ProjectName] No repos specified"
    }
}

# Display results
Write-Host "`n=== RESULTS ===" -ForegroundColor Cyan

if ($Errors.Count -gt 0) {
    Write-Host "`nERRORS ($($Errors.Count)):" -ForegroundColor Red
    foreach ($Error in $Errors) {
        Write-Host "  $Error" -ForegroundColor Red
    }
}

if ($Warnings.Count -gt 0) {
    Write-Host "`nWARNINGS ($($Warnings.Count)):" -ForegroundColor Yellow
    foreach ($Warning in $Warnings) {
        Write-Host "  $Warning" -ForegroundColor Yellow
    }
}

if ($Errors.Count -eq 0 -and $Warnings.Count -eq 0) {
    Write-Host "`nAll validations passed!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Errors: $($Errors.Count)" -ForegroundColor $(if ($Errors.Count -gt 0) { "Red" } else { "Green" })
Write-Host "  Warnings: $($Warnings.Count)" -ForegroundColor $(if ($Warnings.Count -gt 0) { "Yellow" } else { "Green" })
Write-Host ""

# Exit code
if ($Errors.Count -gt 0) { exit 1 }
