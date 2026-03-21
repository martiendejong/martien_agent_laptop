#!/usr/bin/env pwsh
#Requires -Version 5.1

<#
.SYNOPSIS
Optimize image for Claude API upload

.DESCRIPTION
Resizes and compresses images to prevent "Could not process image" errors.
Uses ImageMagick if available, falls back to .NET System.Drawing.

.PARAMETER ImagePath
Path to image to optimize

.PARAMETER OutputPath
Output path (default: input with .optimized suffix)

.PARAMETER MaxWidth
Maximum width in pixels (default: 1920)

.PARAMETER MaxHeight
Maximum height in pixels (default: 1080)

.PARAMETER Quality
JPEG quality 1-100 (default: 85)

.EXAMPLE
optimize-image-for-claude.ps1 -ImagePath "large-screenshot.png"

.EXAMPLE
optimize-image-for-claude.ps1 -ImagePath "image.jpg" -Quality 75 -MaxWidth 1280
#>

param(
    [Parameter(Mandatory)]
    [string]$ImagePath,

    [string]$OutputPath,

    [int]$MaxWidth = 1920,

    [int]$MaxHeight = 1080,

    [int]$Quality = 85
)

if (-not (Test-Path $ImagePath)) {
    Write-Host "ERROR: File not found: $ImagePath" -ForegroundColor Red
    exit 1
}

$file = Get-Item $ImagePath
$extension = $file.Extension.TrimStart('.').ToLower()

# Default output path
if (-not $OutputPath) {
    $OutputPath = Join-Path $file.DirectoryName "$($file.BaseName).optimized.$extension"
}

Write-Host "Optimizing image for Claude API..." -ForegroundColor Cyan
Write-Host "   Input:  $ImagePath" -ForegroundColor Gray
Write-Host "   Output: $OutputPath" -ForegroundColor Gray

# Try ImageMagick first (better quality)
$magickPath = Get-Command magick -ErrorAction SilentlyContinue
if ($magickPath) {
    Write-Host "   Using ImageMagick..." -ForegroundColor Gray

    $args = @(
        "`"$($file.FullName)`""
        "-resize", "${MaxWidth}x${MaxHeight}>"  # Only shrink if larger
        "-quality", $Quality
        "-strip"  # Remove metadata
        "`"$OutputPath`""
    )

    $cmd = "magick $($args -join ' ')"
    Invoke-Expression $cmd

    if (Test-Path $OutputPath) {
        $originalSizeMB = [math]::Round($file.Length / 1MB, 2)
        $newFile = Get-Item $OutputPath
        $newSizeMB = [math]::Round($newFile.Length / 1MB, 2)
        $savings = [math]::Round((1 - ($newFile.Length / $file.Length)) * 100, 1)

        Write-Host "SUCCESS: Optimized successfully" -ForegroundColor Green
        Write-Host "   Original: $originalSizeMB MB" -ForegroundColor Gray
        Write-Host "   New:      $newSizeMB MB" -ForegroundColor Gray
        Write-Host "   Savings:  $savings%" -ForegroundColor Green
        Write-Host ""
        Write-Host "Use optimized image: $OutputPath" -ForegroundColor Cyan
        exit 0
    } else {
        Write-Host "WARN: ImageMagick failed, trying .NET fallback..." -ForegroundColor Yellow
    }
}

# Fallback: .NET System.Drawing
try {
    Add-Type -AssemblyName System.Drawing

    $img = [System.Drawing.Image]::FromFile($file.FullName)
    $width = $img.Width
    $height = $img.Height

    # Calculate new dimensions (maintain aspect ratio)
    $ratio = [Math]::Min($MaxWidth / $width, $MaxHeight / $height)
    if ($ratio -ge 1) {
        # Image already small enough, just copy
        Write-Host "   Image already within limits, copying..." -ForegroundColor Gray
        Copy-Item $ImagePath $OutputPath
    } else {
        $newWidth = [int]($width * $ratio)
        $newHeight = [int]($height * $ratio)

        Write-Host "   Resizing ${width}x${height} -> ${newWidth}x${newHeight}..." -ForegroundColor Gray

        $newImg = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        $graphics = [System.Drawing.Graphics]::FromImage($newImg)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($img, 0, 0, $newWidth, $newHeight)

        # Save with quality settings
        $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
            Where-Object { $_.MimeType -eq 'image/jpeg' }
        $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
            [System.Drawing.Imaging.Encoder]::Quality, $Quality)

        # Convert PNG to JPEG for better compression
        if ($extension -eq 'png') {
            $OutputPath = $OutputPath -replace '\.png$', '.jpg'
            Write-Host "   Converting PNG -> JPEG for better compression..." -ForegroundColor Gray
        }

        $newImg.Save($OutputPath, $encoder, $encoderParams)

        $graphics.Dispose()
        $newImg.Dispose()
    }

    $img.Dispose()

    $originalSizeMB = [math]::Round($file.Length / 1MB, 2)
    $newFile = Get-Item $OutputPath
    $newSizeMB = [math]::Round($newFile.Length / 1MB, 2)
    $savings = [math]::Round((1 - ($newFile.Length / $file.Length)) * 100, 1)

    Write-Host "SUCCESS: Optimized successfully (.NET fallback)" -ForegroundColor Green
    Write-Host "   Original: $originalSizeMB MB" -ForegroundColor Gray
    Write-Host "   New:      $newSizeMB MB" -ForegroundColor Gray
    Write-Host "   Savings:  $savings%" -ForegroundColor Green
    Write-Host ""
    Write-Host "Use optimized image: $OutputPath" -ForegroundColor Cyan

} catch {
    Write-Host "ERROR: Optimization failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
