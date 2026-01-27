<#
.SYNOPSIS
    Speech-to-text using OpenAI Whisper

.DESCRIPTION
    Converts audio to text using OpenAI Whisper API:
    - Supports multiple audio formats (mp3, mp4, wav, webm, m4a)
    - Multiple language support
    - Optional timestamps

.PARAMETER AudioPath
    Path to audio file

.PARAMETER Language
    Language code (optional - auto-detects if not specified)

.PARAMETER Timestamps
    Include word-level timestamps

.PARAMETER OutputPath
    Save transcription to file

.EXAMPLE
    .\voice-listen.ps1 -AudioPath "recording.mp3"

.EXAMPLE
    .\voice-listen.ps1 -AudioPath "meeting.wav" -Language "en" -OutputPath "transcript.txt"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$AudioPath,

    [Parameter(Mandatory=$false)]
    [string]$Language,

    [Parameter(Mandatory=$false)]
    [switch]$Timestamps,

    [Parameter(Mandatory=$false)]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Speech-to-Text (OpenAI Whisper)" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $AudioPath)) {
    Write-Host "❌ Audio file not found: $AudioPath" -ForegroundColor Red
    exit 1
}

# Load API key
$secretsPath = "C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json"
if (-not (Test-Path $secretsPath)) {
    Write-Host "❌ API key not found: $secretsPath" -ForegroundColor Red
    exit 1
}

$secrets = Get-Content $secretsPath | ConvertFrom-Json
$apiKey = $secrets.OpenAI.ApiKey

if (-not $apiKey) {
    Write-Host "❌ OpenAI.ApiKey not found in secrets" -ForegroundColor Red
    exit 1
}

$fileName = Split-Path $AudioPath -Leaf
$fileSize = (Get-Item $AudioPath).Length / 1MB

Write-Host "Audio: $fileName" -ForegroundColor White
Write-Host "Size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Gray
if ($Language) {
    Write-Host "Language: $Language" -ForegroundColor Cyan
}
Write-Host ""

# Check file size (max 25MB for Whisper)
if ($fileSize -gt 25) {
    Write-Host "❌ File too large (max 25MB)" -ForegroundColor Red
    exit 1
}

Write-Host "🎧 Transcribing audio..." -ForegroundColor Cyan

try {
    # Build form data
    $boundary = [System.Guid]::NewGuid().ToString()
    $audioBytes = [System.IO.File]::ReadAllBytes($AudioPath)
    $audioBase64 = [Convert]::ToBase64String($audioBytes)

    # Use curl for multipart form
    $responseFormat = if ($Timestamps) { "verbose_json" } else { "text" }

    $curlArgs = @(
        "-s",
        "-X", "POST",
        "https://api.openai.com/v1/audio/transcriptions",
        "-H", "Authorization: Bearer $apiKey",
        "-F", "file=@$AudioPath",
        "-F", "model=whisper-1",
        "-F", "response_format=$responseFormat"
    )

    if ($Language) {
        $curlArgs += @("-F", "language=$Language")
    }

    $result = & curl @curlArgs

    if ($Timestamps) {
        $json = $result | ConvertFrom-Json
        $text = $json.text
    } else {
        $text = $result
    }

    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan
    Write-Host "📝 Transcription:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host $text -ForegroundColor White
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan
    Write-Host ""

    if ($OutputPath) {
        $text | Set-Content $OutputPath -Encoding UTF8
        Write-Host "✅ Saved to: $OutputPath" -ForegroundColor Green
        Write-Host ""
    }

    # Return text for programmatic use
    return $text

} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}
