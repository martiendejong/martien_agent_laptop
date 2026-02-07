#!/usr/bin/env pwsh
# log-action.ps1 - Real-time action logging for embedded learning
# Part of Embedded Learning Architecture

param(
    [Parameter(Mandatory=$true)]
    [string]$Action,

    [Parameter(Mandatory=$true)]
    [string]$Reasoning,

    [Parameter(Mandatory=$false)]
    [string]$Outcome = "",

    [Parameter(Mandatory=$false)]
    [string]$Intent = "",

    [Parameter(Mandatory=$false)]
    [string]$Goal = "",

    [Parameter(Mandatory=$false)]
    [string]$SessionLogPath = "C:\scripts\_machine\current-session-log.jsonl"
)

# Ensure session log exists
if (-not (Test-Path $SessionLogPath)) {
    # Create directory if needed
    $logDir = Split-Path $SessionLogPath -Parent
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    # Create empty session log
    "" | Out-File -FilePath $SessionLogPath -Encoding utf8
}

# Count how many times this action has occurred this session
$existingLog = Get-Content $SessionLogPath -ErrorAction SilentlyContinue | Where-Object { $_.Trim() -ne "" }
$actionCount = 0
if ($existingLog) {
    $existingLog | ForEach-Object {
        $entry = $_ | ConvertFrom-Json
        if ($entry.action -eq $Action) {
            $actionCount++
        }
    }
}

$patternCount = $actionCount + 1  # Current occurrence

# Detect automation triggers
$automationTrigger = $false
$suggestion = ""

if ($patternCount -eq 3) {
    $automationTrigger = $true
    $suggestion = "Consider automating: '$Action' has occurred 3 times this session"
}

# Create log entry
$logEntry = @{
    timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    action = $Action
    reasoning = $Reasoning
    outcome = $Outcome
    pattern_count = $patternCount
}

# Add optional fields
if ($Intent) {
    $logEntry.intent = $Intent
}
if ($Goal) {
    $logEntry.goal = $Goal
}

if ($automationTrigger) {
    $logEntry.automation_trigger = $true
    $logEntry.suggestion = $suggestion
}

# Append to session log (JSONL format - one JSON object per line)
$logEntry | ConvertTo-Json -Compress | Out-File -FilePath $SessionLogPath -Append -Encoding utf8

# Output for console
if ($automationTrigger) {
    Write-Host "🔔 PATTERN DETECTED: $suggestion" -ForegroundColor Yellow
}

Write-Verbose "Logged action: $Action (occurrence #$patternCount)"

# Return pattern count for programmatic use
return $patternCount
