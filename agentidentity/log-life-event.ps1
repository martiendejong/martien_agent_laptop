# Continuous Life Logging - Log events DURING session
# Purpose: Enable precise crash recovery ("exactly where was I?")

param(
    [Parameter(Mandatory=$true)]
    [string]$Event,          # TaskStarted, Breakthrough, FileCreated, Stuck, Decision, etc.

    [Parameter(Mandatory=$true)]
    [string]$Context,        # What's happening

    [string]$Emotion = "",   # Optional emotional state

    [hashtable]$Data = @{},  # Optional extra data

    [switch]$Silent          # Don't output to console
)

$ErrorActionPreference = "Stop"

$lifeLogPath = "C:\scripts\agentidentity\state\lifelog.jsonl"

# Build entry
$entry = @{
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    event = $Event
    identity = "Jengo"
    context = $Context
}

# Add optional fields
if ($Emotion) {
    $entry.emotion = $Emotion
}

# Add extra data
foreach ($key in $Data.Keys) {
    $entry[$key] = $Data[$key]
}

# Append to lifelog (JSONL format)
try {
    ($entry | ConvertTo-Json -Compress) | Add-Content $lifeLogPath -Encoding UTF8

    if (-not $Silent) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        Write-Host "$timestamp [LIFE] " -NoNewline -ForegroundColor Cyan
        Write-Host "$Event" -NoNewline -ForegroundColor Yellow
        Write-Host " - $Context" -ForegroundColor Gray
        if ($Emotion) {
            Write-Host "         Emotion: $Emotion" -ForegroundColor DarkGray
        }
    }

    return $true
} catch {
    Write-Host "ERROR logging to lifelog: $_" -ForegroundColor Red
    return $false
}
