#Requires -Version 5.1

<#
.SYNOPSIS
    Setup Meeting Recorder & Auto-Minutes Generator

.DESCRIPTION
    Installs Python dependencies and verifies system requirements

.EXAMPLE
    .\setup.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'

Write-Host ""
Write-Host "=== Meeting Recorder - Setup ===" -ForegroundColor Cyan
Write-Host ""

# Check Python
Write-Host "[1/3] Checking Python..." -ForegroundColor Yellow

$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
}

if ($pythonCmd) {
    $pythonVersion = & $pythonCmd.Source --version 2>&1
    Write-Host "  OK Python found: $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "  ERROR Python not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Python 3.10+ from: https://www.python.org/downloads/" -ForegroundColor Yellow
    exit 1
}

# Check ffmpeg
Write-Host ""
Write-Host "[2/3] Checking ffmpeg..." -ForegroundColor Yellow

$ffmpegCmd = Get-Command ffmpeg -ErrorAction SilentlyContinue
if ($ffmpegCmd) {
    Write-Host "  OK ffmpeg found: $($ffmpegCmd.Source)" -ForegroundColor Green
} else {
    Write-Host "  WARNING ffmpeg not found in PATH" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please install ffmpeg:" -ForegroundColor Cyan
    Write-Host "  1. Download from: https://www.gyan.dev/ffmpeg/builds/" -ForegroundColor White
    Write-Host "  2. Extract to C:\ffmpeg\" -ForegroundColor White
    Write-Host "  3. Add C:\ffmpeg\bin to your PATH" -ForegroundColor White
    Write-Host ""
    Write-Host "Or the start-recording.ps1 script will try to find it automatically." -ForegroundColor Gray
}

# Install Python dependencies
Write-Host ""
Write-Host "[3/3] Installing Python dependencies..." -ForegroundColor Yellow
Write-Host ""

Write-Host "  Installing openai-whisper (this may take a few minutes)..." -ForegroundColor Gray

& $pythonCmd.Source -m pip install openai-whisper --quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK openai-whisper installed" -ForegroundColor Green
} else {
    Write-Host "  ERROR Failed to install openai-whisper" -ForegroundColor Red
}

Write-Host ""
Write-Host "  Installing ffmpeg-python..." -ForegroundColor Gray

& $pythonCmd.Source -m pip install ffmpeg-python --quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK ffmpeg-python installed" -ForegroundColor Green
} else {
    Write-Host "  WARNING ffmpeg-python installation failed (optional)" -ForegroundColor Yellow
}

# Verify whisper installation
Write-Host ""
Write-Host "Verifying installation..." -ForegroundColor Yellow

$whisperTest = & $pythonCmd.Source -c "import whisper; print(whisper.__version__)" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK Whisper version: $whisperTest" -ForegroundColor Green
} else {
    Write-Host "  ERROR Whisper verification failed" -ForegroundColor Red
    Write-Host "  Try running: pip install openai-whisper --upgrade" -ForegroundColor Yellow
}

# Create Recordings directory
Write-Host ""
Write-Host "Creating Recordings directory..." -ForegroundColor Yellow

$recordingsDir = "C:\Users\$env:USERNAME\Recordings"
if (-not (Test-Path $recordingsDir)) {
    New-Item -ItemType Directory -Path $recordingsDir -Force | Out-Null
    Write-Host "  OK Created: $recordingsDir" -ForegroundColor Green
} else {
    Write-Host "  OK Already exists: $recordingsDir" -ForegroundColor Green
}

# Done
Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. List microphones: .\start-recording.ps1 -ListMicrophones" -ForegroundColor White
Write-Host "  2. Start recording: .\start-recording.ps1" -ForegroundColor White
Write-Host "  3. Stop & transcribe: .\stop-and-transcribe.ps1" -ForegroundColor White
Write-Host ""
Write-Host "See README.md for full documentation" -ForegroundColor Gray
Write-Host ""
