#Requires -Version 5.1

<#
.SYNOPSIS
    Start meeting recording

.DESCRIPTION
    Starts recording audio from your microphone using ffmpeg.
    Recording continues until you stop it manually.

.EXAMPLE
    .\start-recording.ps1

.EXAMPLE
    .\start-recording.ps1 -Microphone "Microphone Array"
    Specify microphone name

.EXAMPLE
    .\start-recording.ps1 -ListMicrophones
    List available microphones and exit
#>

[CmdletBinding()]
param(
    [string]$Microphone,
    [switch]$ListMicrophones
)

$ErrorActionPreference = 'Stop'

# Find ffmpeg
$ffmpegPath = $null

# Check common locations
$commonPaths = @(
    "C:\ffmpeg\bin\ffmpeg.exe",
    "C:\Program Files\ffmpeg\bin\ffmpeg.exe",
    "C:\tools\ffmpeg\bin\ffmpeg.exe"
)

# Check PATH first
$ffmpegCmd = Get-Command ffmpeg -ErrorAction SilentlyContinue
if ($ffmpegCmd) {
    $ffmpegPath = $ffmpegCmd.Source
} else {
    # Check common paths
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            $ffmpegPath = $path
            break
        }
    }

    # Check user's Downloads or extracted folders
    if (-not $ffmpegPath) {
        $userFfmpeg = Get-ChildItem "C:\Users\$env:USERNAME" -Recurse -Filter "ffmpeg.exe" -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -match "ffmpeg.*bin" } |
            Select-Object -First 1

        if ($userFfmpeg) {
            $ffmpegPath = $userFfmpeg.FullName
        }
    }
}

if (-not $ffmpegPath) {
    Write-Host "✗ ffmpeg not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install ffmpeg:" -ForegroundColor Yellow
    Write-Host "  1. Download from: https://www.gyan.dev/ffmpeg/builds/" -ForegroundColor White
    Write-Host "  2. Extract to C:\ffmpeg\" -ForegroundColor White
    Write-Host "  3. Add C:\ffmpeg\bin to your PATH" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "✓ Found ffmpeg: $ffmpegPath" -ForegroundColor Green
Write-Host ""

# List microphones
if ($ListMicrophones -or -not $Microphone) {
    Write-Host "=== Available Microphones ===" -ForegroundColor Cyan
    Write-Host ""

    $devices = & $ffmpegPath -list_devices true -f dshow -i dummy 2>&1 | Out-String

    # Extract audio devices
    $audioSection = $devices -split "`n" | Where-Object { $_ -match "DirectShow audio devices" }
    $inAudioSection = $false

    $microphones = @()

    foreach ($line in ($devices -split "`n")) {
        if ($line -match "DirectShow audio devices") {
            $inAudioSection = $true
            continue
        }

        if ($inAudioSection -and $line -match "DirectShow video devices") {
            break
        }

        if ($inAudioSection -and $line -match '\[dshow.*\]\s+"([^"]+)"') {
            $micName = $matches[1]
            $microphones += $micName
            Write-Host "  - $micName" -ForegroundColor White
        }
    }

    if ($microphones.Count -eq 0) {
        Write-Host "  No microphones found" -ForegroundColor Yellow
    }

    Write-Host ""

    if ($ListMicrophones) {
        Write-Host "Use one of the above names with: .\start-recording.ps1 -Microphone ""NAME""" -ForegroundColor Gray
        exit 0
    }

    if (-not $Microphone -and $microphones.Count -gt 0) {
        Write-Host "Select a microphone:" -ForegroundColor Yellow
        for ($i = 0; $i -lt $microphones.Count; $i++) {
            Write-Host "  [$($i+1)] $($microphones[$i])" -ForegroundColor White
        }
        Write-Host ""

        $selection = Read-Host "Enter number (1-$($microphones.Count))"
        $selectedIndex = [int]$selection - 1

        if ($selectedIndex -ge 0 -and $selectedIndex -lt $microphones.Count) {
            $Microphone = $microphones[$selectedIndex]
        } else {
            Write-Host "Invalid selection" -ForegroundColor Red
            exit 1
        }
    }
}

if (-not $Microphone) {
    Write-Host "✗ No microphone specified" -ForegroundColor Red
    Write-Host "Use: .\start-recording.ps1 -ListMicrophones" -ForegroundColor Yellow
    exit 1
}

# Prepare output
$recordingsDir = "C:\Users\$env:USERNAME\Recordings"
if (-not (Test-Path $recordingsDir)) {
    New-Item -ItemType Directory -Path $recordingsDir -Force | Out-Null
}

$outputFile = Join-Path $recordingsDir "meeting-$(Get-Date -Format 'yyyy-MM-dd-HHmm').mp3"

Write-Host "=== Starting Recording ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Microphone: $Microphone" -ForegroundColor Gray
Write-Host "  Output: $outputFile" -ForegroundColor Gray
Write-Host ""
Write-Host "Recording in progress..." -ForegroundColor Green
Write-Host ""
Write-Host "To stop recording and generate minutes:" -ForegroundColor Yellow
Write-Host "  .\stop-and-transcribe.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Or press 'q' in this window to stop recording" -ForegroundColor Gray
Write-Host ""

# Start recording
& $ffmpegPath -f dshow -i "audio=$Microphone" -ac 1 -ar 44100 -b:a 128k $outputFile -y

Write-Host ""
Write-Host "Recording stopped." -ForegroundColor Yellow
Write-Host ""
Write-Host "To transcribe this recording, run:" -ForegroundColor Cyan
Write-Host "  .\stop-and-transcribe.ps1" -ForegroundColor White
Write-Host ""
