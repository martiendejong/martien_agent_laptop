#!/usr/bin/env pwsh
#Requires -Version 5.1

<#
.SYNOPSIS
Setup PowerShell profile aliases for Claude image validation

.DESCRIPTION
Adds convenient aliases to PowerShell profile for quick image validation/optimization
before uploading to Claude Code CLI.

.EXAMPLE
setup-image-validation-alias.ps1
#>

$profilePath = $PROFILE
$aliasCode = @'

# Claude Code CLI Image Safety Aliases (added 2026-02-21)
# Prevents "Could not process image" API errors that break sessions

function Test-ClaudeImage {
    <#
    .SYNOPSIS
    Validate image before sending to Claude Code CLI

    .EXAMPLE
    Test-ClaudeImage "screenshot.png"
    #>
    param([Parameter(Mandatory)][string]$ImagePath)

    & "C:\scripts\tools\validate-image-for-claude.ps1" -ImagePath $ImagePath

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "[PASS] Safe to upload to Claude CLI" -ForegroundColor Green
        return $true
    } else {
        Write-Host ""
        Write-Host "[WARN] Image validation failed - see errors above" -ForegroundColor Yellow
        Write-Host "Run: Optimize-ClaudeImage '$ImagePath' to auto-fix" -ForegroundColor Cyan
        return $false
    }
}

function Optimize-ClaudeImage {
    <#
    .SYNOPSIS
    Auto-fix oversized/problematic images for Claude API

    .EXAMPLE
    Optimize-ClaudeImage "screenshot.png"

    .EXAMPLE
    Optimize-ClaudeImage "4k-capture.png" -Quality 75 -MaxWidth 1280
    #>
    param(
        [Parameter(Mandatory)][string]$ImagePath,
        [int]$Quality = 85,
        [int]$MaxWidth = 1920,
        [int]$MaxHeight = 1080
    )

    & "C:\scripts\tools\optimize-image-for-claude.ps1" `
        -ImagePath $ImagePath `
        -Quality $Quality `
        -MaxWidth $MaxWidth `
        -MaxHeight $MaxHeight
}

function Send-ToClaudeImage {
    <#
    .SYNOPSIS
    Smart workflow: validate, optimize if needed, ready to upload

    .DESCRIPTION
    Validates image first. If fails, auto-optimizes and validates again.
    Use this before sending ANY image to Claude Code CLI.

    .EXAMPLE
    Send-ToClaudeImage "screenshot.png"

    .EXAMPLE
    dir E:\jengo\documents\screenshots\*.png | % { Send-ToClaudeImage $_.FullName }
    #>
    param([Parameter(Mandatory, ValueFromPipeline)][string]$ImagePath)

    process {
        Write-Host "[CHECK] Validating image: $ImagePath" -ForegroundColor Cyan
        Write-Host ""

        $valid = Test-ClaudeImage $ImagePath

        if (-not $valid) {
            Write-Host ""
            Write-Host "[FIX] Attempting auto-optimization..." -ForegroundColor Yellow
            Optimize-ClaudeImage $ImagePath

            $optimized = $ImagePath -replace '\.(png|jpg|jpeg|webp)$', '.optimized.$1'

            if (Test-Path $optimized) {
                Write-Host ""
                Write-Host "[SUCCESS] Optimized version created and validated" -ForegroundColor Green
                Write-Host "[OUTPUT] Use this file: $optimized" -ForegroundColor Cyan
                return $optimized
            } else {
                Write-Host ""
                Write-Host "[ERROR] Optimization failed - manual intervention required" -ForegroundColor Red
                return $null
            }
        } else {
            Write-Host "[PASS] Original image is safe to use" -ForegroundColor Green
            return $ImagePath
        }
    }
}

# Short aliases for convenience
Set-Alias -Name tci -Value Test-ClaudeImage
Set-Alias -Name oci -Value Optimize-ClaudeImage
Set-Alias -Name sci -Value Send-ToClaudeImage

'@

# Check if profile exists
if (-not (Test-Path $profilePath)) {
    Write-Host "Creating PowerShell profile at: $profilePath" -ForegroundColor Cyan
    $null = New-Item -Path $profilePath -ItemType File -Force
}

# Check if aliases already exist
$profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
if ($profileContent -match 'Claude Code CLI Image Safety Aliases') {
    Write-Host "[OK] Image validation aliases already in profile" -ForegroundColor Green
    Write-Host "  Profile: $profilePath" -ForegroundColor Gray
    exit 0
}

# Add aliases to profile
Add-Content -Path $profilePath -Value $aliasCode

Write-Host "[SUCCESS] PowerShell profile updated successfully" -ForegroundColor Green
Write-Host ""
Write-Host "Location: $profilePath" -ForegroundColor Gray
Write-Host ""
Write-Host "[RELOAD] Reload profile now (or restart terminal):" -ForegroundColor Cyan
Write-Host "   . `$PROFILE" -ForegroundColor Yellow
Write-Host ""
Write-Host "[ALIASES] Available aliases:" -ForegroundColor Cyan
Write-Host "   Test-ClaudeImage 'file.png'     (alias: tci)  - Validate image" -ForegroundColor Gray
Write-Host "   Optimize-ClaudeImage 'file.png' (alias: oci)  - Auto-fix image" -ForegroundColor Gray
Write-Host "   Send-ToClaudeImage 'file.png'   (alias: sci)  - Smart validate + optimize" -ForegroundColor Gray
Write-Host ""
Write-Host "[TIP] Recommended workflow:" -ForegroundColor Cyan
Write-Host "   sci screenshot.png  # Before uploading to Claude CLI" -ForegroundColor Yellow
