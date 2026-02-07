#Requires -Version 5.1

<#
.SYNOPSIS
    Test TTS (Text-to-Speech) functionality

.DESCRIPTION
    Quick test of both edge-tts and Windows System.Speech TTS

.EXAMPLE
    .\test-tts.ps1

.EXAMPLE
    .\test-tts.ps1 -EdgeTTS
    Test only edge-tts

.EXAMPLE
    .\test-tts.ps1 -WindowsTTS
    Test only Windows System.Speech
#>

[CmdletBinding()]
param(
    [switch]$EdgeTTS,
    [switch]$WindowsTTS
)

$testText = "Good morning! This is a test of the text to speech system. If you can hear this, everything is working correctly."

Write-Host "=== TTS Test ===" -ForegroundColor Cyan
Write-Host ""

# Test edge-tts if requested or default
if ($EdgeTTS -or (-not $WindowsTTS)) {
    Write-Host "Testing edge-tts (Python)..." -ForegroundColor Yellow

    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonCmd) {
        $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
    }

    if ($pythonCmd) {
        # Create temp test script
        $tempPy = Join-Path $env:TEMP "test-tts.py"
        @"
import asyncio
try:
    import edge_tts
    async def speak():
        communicate = edge_tts.Communicate("$testText", "en-US-AriaNeural")
        await communicate.save("$env:TEMP\test-speech.mp3")
        print("✓ edge-tts audio generated")
    asyncio.run(speak())
except ImportError:
    print("✗ edge-tts not installed. Install with: pip install edge-tts")
except Exception as e:
    print(f"✗ Error: {e}")
"@ | Set-Content $tempPy -Encoding UTF8

        & $pythonCmd.Source $tempPy

        # Try to play the generated audio
        $testAudio = Join-Path $env:TEMP "test-speech.mp3"
        if (Test-Path $testAudio) {
            Write-Host "Playing audio..." -ForegroundColor Green
            # Use PowerShell to play MP3 via Windows Media Player
            Add-Type -AssemblyName PresentationCore
            $mediaPlayer = New-Object System.Windows.Media.MediaPlayer
            $mediaPlayer.Open([Uri]::new($testAudio))
            $mediaPlayer.Play()
            Start-Sleep -Seconds 5
            $mediaPlayer.Stop()
            $mediaPlayer.Close()

            Remove-Item $testAudio -Force
        }

        Remove-Item $tempPy -Force
    } else {
        Write-Host "✗ Python not found" -ForegroundColor Red
    }
}

Write-Host ""

# Test Windows TTS if requested or default
if ($WindowsTTS -or (-not $EdgeTTS)) {
    Write-Host "Testing Windows System.Speech..." -ForegroundColor Yellow

    try {
        Add-Type -AssemblyName System.Speech
        $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
        $speak.Rate = 0
        $speak.Volume = 100

        Write-Host "Speaking..." -ForegroundColor Green
        $speak.Speak($testText)
        $speak.Dispose()

        Write-Host "✓ Windows TTS works" -ForegroundColor Green
    } catch {
        Write-Host "✗ Windows TTS failed: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan
