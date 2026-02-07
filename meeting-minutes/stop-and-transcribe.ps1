#Requires -Version 5.1

<#
.SYNOPSIS
    Stop meeting recording and generate transcribed minutes

.DESCRIPTION
    Stops any running ffmpeg recording process and automatically
    transcribes the latest recording using Whisper.

.EXAMPLE
    .\stop-and-transcribe.ps1

.EXAMPLE
    .\stop-and-transcribe.ps1 -Model small
    Use Whisper 'small' model for better accuracy

.EXAMPLE
    .\stop-and-transcribe.ps1 -NoTranscribe
    Just stop recording, don't transcribe
#>

[CmdletBinding()]
param(
    [ValidateSet("tiny", "base", "small", "medium", "large")]
    [string]$Model = "base",

    [switch]$NoTranscribe
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "=== Meeting Recorder - Stop & Transcribe ===" -ForegroundColor Cyan
Write-Host ""

# Stop ffmpeg
Write-Host "[1/2] Stopping ffmpeg recording..." -ForegroundColor Yellow

$ffmpegProcesses = Get-Process -Name ffmpeg -ErrorAction SilentlyContinue

if ($ffmpegProcesses) {
    Write-Host "  Found $($ffmpegProcesses.Count) ffmpeg process(es)" -ForegroundColor Gray

    foreach ($proc in $ffmpegProcesses) {
        # Send 'q' to gracefully stop ffmpeg
        try {
            # Try to send 'q' key (graceful stop)
            # Note: This is tricky in PowerShell, so we'll just stop the process
            $proc | Stop-Process -Force
            Write-Host "  ✓ Stopped ffmpeg process (PID: $($proc.Id))" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Failed to stop process: $_" -ForegroundColor Red
        }
    }

    # Wait a moment for file to finalize
    Start-Sleep -Seconds 2
} else {
    Write-Host "  ⚠ No ffmpeg recording processes found" -ForegroundColor Yellow
    Write-Host "  If you manually stopped the recording, that's fine." -ForegroundColor Gray
}

if ($NoTranscribe) {
    Write-Host ""
    Write-Host "Recording stopped (transcription skipped)" -ForegroundColor Green
    exit 0
}

# Find latest recording
Write-Host ""
Write-Host "[2/2] Transcribing latest recording..." -ForegroundColor Yellow

$recordingsDir = "C:\Users\$env:USERNAME\Recordings"

if (-not (Test-Path $recordingsDir)) {
    Write-Host "  ✗ Recordings directory not found: $recordingsDir" -ForegroundColor Red
    exit 1
}

$latestRecording = Get-ChildItem $recordingsDir -Filter "meeting-*.mp3" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $latestRecording) {
    Write-Host "  ✗ No recordings found in $recordingsDir" -ForegroundColor Red
    exit 1
}

Write-Host "  Latest recording: $($latestRecording.Name)" -ForegroundColor Gray
Write-Host "  Size: $([math]::Round($latestRecording.Length / 1MB, 2)) MB" -ForegroundColor Gray
Write-Host "  Model: $Model" -ForegroundColor Gray
Write-Host ""

# Check Python
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
}

if (-not $pythonCmd) {
    Write-Host "  ✗ Python not found. Please install Python 3.10+" -ForegroundColor Red
    exit 1
}

# Check if openai-whisper installed
$whisperCheck = & $pythonCmd.Source -c "import whisper" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ openai-whisper not installed" -ForegroundColor Red
    Write-Host "  Install with: pip install openai-whisper" -ForegroundColor Yellow
    exit 1
}

# Transcribe
$transcribeScript = Join-Path $PSScriptRoot "transcribe.py"

if (-not (Test-Path $transcribeScript)) {
    Write-Host "  ✗ Transcription script not found: $transcribeScript" -ForegroundColor Red
    exit 1
}

Write-Host "  Starting transcription (this will take a few minutes)..." -ForegroundColor Cyan
Write-Host ""

try {
    & $pythonCmd.Source $transcribeScript $latestRecording.FullName --model $Model

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ Complete! Check your Recordings folder for the minutes." -ForegroundColor Green

        # Open the minutes file
        $minutesFile = Join-Path $recordingsDir "$($latestRecording.BaseName)-minutes.md"
        if (Test-Path $minutesFile) {
            Write-Host ""
            Write-Host "Opening minutes file..." -ForegroundColor Cyan
            Start-Process $minutesFile
        }
    } else {
        Write-Host ""
        Write-Host "✗ Transcription failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "✗ Error during transcription: $_" -ForegroundColor Red
    exit 1
}
