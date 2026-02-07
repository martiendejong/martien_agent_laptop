#Requires -Version 5.1

<#
.SYNOPSIS
    Morning Email Briefing - Main Orchestrator

.DESCRIPTION
    Fetches unread Gmail emails, filters noise, generates summary, and speaks it aloud.
    Only runs once per day (first login of the day).

.EXAMPLE
    .\morning-briefing.ps1

.EXAMPLE
    .\morning-briefing.ps1 -Force
    Force run even if already ran today

.EXAMPLE
    .\morning-briefing.ps1 -Silent
    Don't speak, just fetch and display summary
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$Silent,
    [switch]$Test
)

$ErrorActionPreference = 'Stop'
$ScriptDir = $PSScriptRoot
$LogFile = Join-Path $ScriptDir "briefing.log"
$LastRunFile = Join-Path $ScriptDir "last-run.txt"

# Logging function
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $logMessage

    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN"  { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

# Check if already ran today
function Test-AlreadyRanToday {
    if (-not (Test-Path $LastRunFile)) {
        return $false
    }

    $lastRun = Get-Content $LastRunFile -Raw | ConvertFrom-Json
    $lastRunDate = [DateTime]::Parse($lastRun.date)
    $today = Get-Date -Format "yyyy-MM-dd"

    return $lastRunDate.ToString("yyyy-MM-dd") -eq $today
}

# Update last run timestamp
function Update-LastRun {
    $runInfo = @{
        date = (Get-Date).ToString("o")
        success = $true
    } | ConvertTo-Json

    Set-Content -Path $LastRunFile -Value $runInfo
}

# Main execution
try {
    Write-Log "=== Morning Email Briefing Started ===" -Level "INFO"

    # Check if should run
    if (-not $Force -and -not $Test) {
        if (Test-AlreadyRanToday) {
            Write-Log "Already ran today. Use -Force to run again." -Level "WARN"
            exit 0
        }
    }

    # Check Node.js
    $nodeVersion = & node --version 2>$null
    if (-not $nodeVersion) {
        Write-Log "Node.js not found. Please install Node.js." -Level "ERROR"
        exit 1
    }
    Write-Log "Node.js version: $nodeVersion"

    # Check if npm packages installed
    $packageJsonPath = Join-Path $ScriptDir "package.json"
    $nodeModulesPath = Join-Path $ScriptDir "node_modules"

    if (-not (Test-Path $nodeModulesPath)) {
        Write-Log "Installing npm dependencies..." -Level "INFO"
        Push-Location $ScriptDir
        try {
            & npm install 2>&1 | Out-String | Write-Log
        } finally {
            Pop-Location
        }
    }

    # Fetch emails
    Write-Log "Fetching emails..." -Level "INFO"
    Push-Location $ScriptDir
    try {
        if ($Test) {
            $output = & node fetch-emails.js --test 2>&1 | Out-String
        } else {
            $output = & node fetch-emails.js 2>&1 | Out-String
        }
        Write-Log $output

        if ($LASTEXITCODE -ne 0) {
            Write-Log "Email fetch failed with exit code $LASTEXITCODE" -Level "ERROR"
            exit 1
        }
    } finally {
        Pop-Location
    }

    # Check if summary exists
    $summaryPath = Join-Path $ScriptDir "summary.txt"
    if (-not (Test-Path $summaryPath)) {
        Write-Log "Summary file not found" -Level "ERROR"
        exit 1
    }

    $summary = Get-Content $summaryPath -Raw
    Write-Log "Summary generated ($($summary.Length) characters)"

    # Speak summary (unless Silent mode)
    if (-not $Silent) {
        Write-Log "Speaking summary..." -Level "INFO"

        # Check if Python available
        $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
        if (-not $pythonCmd) {
            $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
        }

        if ($pythonCmd) {
            # Try Python edge-tts
            Write-Log "Using Python edge-tts"
            $pythonScript = Join-Path $ScriptDir "speak-summary.py"
            & $pythonCmd.Source $pythonScript 2>&1 | Out-String | Write-Log
        } else {
            # Fallback to PowerShell System.Speech
            Write-Log "Python not found, using Windows System.Speech" -Level "WARN"

            Add-Type -AssemblyName System.Speech
            $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
            $speak.Rate = 0
            $speak.Volume = 100
            $speak.Speak($summary)
        }
    }

    # Update last run (only if not test mode)
    if (-not $Test) {
        Update-LastRun
    }

    Write-Log "=== Briefing Complete ===" -Level "SUCCESS"

} catch {
    Write-Log "Fatal error: $_" -Level "ERROR"
    Write-Log $_.ScriptStackTrace -Level "ERROR"
    exit 1
}
