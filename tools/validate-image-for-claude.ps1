#!/usr/bin/env pwsh
#Requires -Version 5.1

<#
.SYNOPSIS
Validate image before sending to Claude API

.DESCRIPTION
Checks image format, size, accessibility, and corruption before upload to prevent
"Could not process image" errors that break Claude Code CLI sessions.

.PARAMETER ImagePath
Path to image file to validate

.EXAMPLE
validate-image-for-claude.ps1 -ImagePath "screenshot.png"
#>

param(
    [Parameter(Mandatory)]
    [string]$ImagePath
)

# Supported formats by Claude API
$SupportedFormats = @('png', 'jpg', 'jpeg', 'gif', 'webp')
$MaxSizeBytes = 5 * 1024 * 1024  # 5 MB (Claude API limit)

Write-Host "Validating image: $ImagePath" -ForegroundColor Cyan

# Check 1: File exists and accessible
if (-not (Test-Path $ImagePath)) {
    Write-Host "FAIL: File not found or not accessible" -ForegroundColor Red
    Write-Host "   Path: $ImagePath" -ForegroundColor Gray
    exit 1
}

$file = Get-Item $ImagePath

# Check 2: File format
$extension = $file.Extension.TrimStart('.').ToLower()
if ($extension -notin $SupportedFormats) {
    Write-Host "FAIL: Unsupported format '$extension'" -ForegroundColor Red
    Write-Host "   Supported: $($SupportedFormats -join ', ')" -ForegroundColor Gray
    exit 1
}
Write-Host "PASS: Format $extension (supported)" -ForegroundColor Green

# Check 3: File size
$sizeMB = [math]::Round($file.Length / 1MB, 2)
if ($file.Length -gt $MaxSizeBytes) {
    Write-Host "FAIL: File too large ($sizeMB MB)" -ForegroundColor Red
    Write-Host "   Maximum: 5 MB" -ForegroundColor Gray
    Write-Host "   Tip: Use ImageMagick to resize:" -ForegroundColor Yellow
    Write-Host "   magick `"$ImagePath`" -resize 1920x1080> -quality 85 `"${ImagePath}.optimized.$extension`"" -ForegroundColor Gray
    exit 1
}
Write-Host "PASS: Size $sizeMB MB (within limit)" -ForegroundColor Green

# Check 4: File not empty
if ($file.Length -eq 0) {
    Write-Host "FAIL: File is empty (0 bytes)" -ForegroundColor Red
    exit 1
}

# Check 5: Basic image validation (try to read as image)
try {
    Add-Type -AssemblyName System.Drawing
    $img = [System.Drawing.Image]::FromFile($file.FullName)
    $width = $img.Width
    $height = $img.Height
    $img.Dispose()

    Write-Host "PASS: Dimensions ${width}x${height}" -ForegroundColor Green

    # Warn if very large dimensions
    if ($width -gt 4096 -or $height -gt 4096) {
        Write-Host "WARN: Very large dimensions may cause processing issues" -ForegroundColor Yellow
        Write-Host "   Consider resizing to max 1920x1080 for screenshots" -ForegroundColor Gray
    }
} catch {
    Write-Host "FAIL: File appears corrupted or not a valid image" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
    exit 1
}

# Check 6: Permissions (can we read the file?)
try {
    $stream = [System.IO.File]::OpenRead($file.FullName)
    $stream.Close()
    Write-Host "PASS: File permissions OK" -ForegroundColor Green
} catch {
    Write-Host "FAIL: Cannot read file (permission issue?)" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "SUCCESS: Image is valid for Claude API" -ForegroundColor Green
Write-Host "Safe to upload to Claude Code CLI" -ForegroundColor Gray
exit 0
