<#
.SYNOPSIS
    Text-to-speech output using OpenAI TTS

.DESCRIPTION
    Converts text to speech using OpenAI TTS API:
    - Multiple voice options
    - Adjustable speed
    - Save to file or play directly

.PARAMETER Text
    Text to convert to speech

.PARAMETER Voice
    Voice to use: alloy, echo, fable, onyx, nova, shimmer (default: nova)

.PARAMETER Speed
    Speech speed 0.25-4.0 (default: 1.0)

.PARAMETER OutputPath
    Save to file instead of playing

.PARAMETER Play
    Play audio after generation (default: true)

.EXAMPLE
    .\voice-speak.ps1 -Text "Hello, I am your AI assistant"

.EXAMPLE
    .\voice-speak.ps1 -Text "Build completed successfully" -Voice onyx -Speed 1.2

.EXAMPLE
    .\voice-speak.ps1 -Text "Error detected" -OutputPath "alert.mp3"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Text,

    [Parameter(Mandatory=$false)]
    [ValidateSet('alloy', 'echo', 'fable', 'onyx', 'nova', 'shimmer')]
    [string]$Voice = 'nova',

    [Parameter(Mandatory=$false)]
    [decimal]$Speed = 1.0,

    [Parameter(Mandatory=$false)]
    [string]$OutputPath,

    [Parameter(Mandatory=$false)]
    [switch]$Play = $true
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Text-to-Speech (OpenAI TTS)" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Load API key
$secretsPath = "C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json"
if (-not (Test-Path $secretsPath)) {
    Write-Host "❌ API key not found: $secretsPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Configure OpenAI API key in appsettings.Secrets.json" -ForegroundColor Yellow
    exit 1
}

$secrets = Get-Content $secretsPath | ConvertFrom-Json
$apiKey = $secrets.OpenAI.ApiKey

if (-not $apiKey) {
    Write-Host "❌ OpenAI.ApiKey not found in secrets" -ForegroundColor Red
    exit 1
}

Write-Host "Text: $Text" -ForegroundColor White
Write-Host "Voice: $Voice" -ForegroundColor Cyan
Write-Host "Speed: ${Speed}x" -ForegroundColor Gray
Write-Host ""

# Prepare output file
if (-not $OutputPath) {
    $OutputPath = "$env:TEMP\tts-$(Get-Date -Format 'yyyyMMdd-HHmmss').mp3"
}

Write-Host "🎤 Generating speech..." -ForegroundColor Cyan

try {
    $body = @{
        model = "tts-1"
        input = $Text
        voice = $Voice
        speed = $Speed
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "https://api.openai.com/v1/audio/speech" `
        -Method Post `
        -Headers @{
            "Authorization" = "Bearer $apiKey"
            "Content-Type" = "application/json"
        } `
        -Body $body `
        -OutFile $OutputPath

    Write-Host "✅ Audio generated: $OutputPath" -ForegroundColor Green
    Write-Host ""

    if ($Play) {
        Write-Host "🔊 Playing audio..." -ForegroundColor Cyan

        # Use Windows Media Player
        Add-Type -AssemblyName presentationCore
        $mediaPlayer = New-Object System.Windows.Media.MediaPlayer
        $mediaPlayer.Open([Uri]$OutputPath)
        $mediaPlayer.Play()

        # Wait for playback
        Start-Sleep -Seconds 1
        while ($mediaPlayer.Position -lt $mediaPlayer.NaturalDuration.TimeSpan) {
            Start-Sleep -Milliseconds 100
        }

        $mediaPlayer.Close()
        Write-Host "✅ Playback complete" -ForegroundColor Green
        Write-Host ""
    }

} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}
