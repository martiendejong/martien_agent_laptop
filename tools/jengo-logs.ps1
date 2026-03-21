#Requires -Version 5.1
<#
.SYNOPSIS
    Unified log query tool for Jengo - inspired by VibeTunnel's vtlog.sh

.DESCRIPTION
    Query logs from multiple sources:
    - Orchestration terminal sessions (E:\logs\*.txt)
    - Consciousness system logs (agentidentity/state/*.jsonl)
    - ClickUp operation logs
    - Git operation logs
    - PowerShell script logs

.PARAMETER Lines
    Number of recent lines to show (default: 100)

.PARAMETER ErrorsOnly
    Show only error/warning lines

.PARAMETER Component
    Filter by component (consciousness, orchestration, clickup, git, etc.)

.PARAMETER Since
    Show logs since time (e.g., "2 hours ago", "today", "2026-02-16")

.PARAMETER Pattern
    Search for specific text pattern (regex supported)

.PARAMETER Source
    Specific log source:
    - orchestration: Terminal session logs
    - consciousness: Consciousness system logs
    - bridge: Consciousness bridge activity
    - clickup: ClickUp operations
    - git: Git operations
    - all: All sources (default)

.PARAMETER Live
    NOT SUPPORTED in Claude Code (causes timeout)
    Use for manual terminal sessions only

.EXAMPLE
    jengo-logs.ps1 -Lines 50
    Show last 50 lines from all sources

.EXAMPLE
    jengo-logs.ps1 -ErrorsOnly
    Show only errors/warnings

.EXAMPLE
    jengo-logs.ps1 -Component consciousness
    Show consciousness system logs only

.EXAMPLE
    jengo-logs.ps1 -Since "2 hours ago"
    Show logs from last 2 hours

.EXAMPLE
    jengo-logs.ps1 -Pattern "PR #\d+"
    Search for PR references

.NOTES
    Created: 2026-02-16
    Inspired by: VibeTunnel's vtlog.sh
    Pattern: Unified logging with component filtering
#>

[CmdletBinding()]
param(
    [Alias("n")]
    [int]$Lines = 100,

    [Alias("e")]
    [switch]$ErrorsOnly,

    [Alias("c")]
    [string]$Component,

    [Alias("s")]
    [string]$Since,

    [Alias("p")]
    [string]$Pattern,

    [ValidateSet("orchestration", "consciousness", "bridge", "clickup", "git", "all")]
    [string]$Source = "all",

    [Alias("f")]
    [switch]$Live
)

# CRITICAL: Prevent -Live in Claude Code context
if ($Live -and $env:CLAUDE_CODE_SESSION) {
    Write-Error "NEVER use -Live (follow mode) in Claude Code - it will timeout!"
    Write-Host "Use without -Live flag for one-time query." -ForegroundColor Yellow
    exit 1
}

# Log source paths
$LogSources = @{
    Orchestration = "E:\logs\*.txt"
    Consciousness = "C:\scripts\agentidentity\state\*.jsonl"
    Bridge = "C:\scripts\agentidentity\state\bridge-activity.jsonl"
    ClickUp = "C:\scripts\_machine\clickup-operations.log"
    Git = "C:\scripts\_machine\git-operations.log"
}

# Parse -Since parameter
$SinceDate = $null
if ($Since) {
    try {
        if ($Since -match "^(\d+)\s+(hour|day|minute)s?\s+ago$") {
            $amount = [int]$matches[1]
            $unit = $matches[2]
            $SinceDate = switch ($unit) {
                "minute" { (Get-Date).AddMinutes(-$amount) }
                "hour" { (Get-Date).AddHours(-$amount) }
                "day" { (Get-Date).AddDays(-$amount) }
            }
        }
        elseif ($Since -eq "today") {
            $SinceDate = Get-Date -Hour 0 -Minute 0 -Second 0
        }
        else {
            $SinceDate = [datetime]::Parse($Since)
        }
        Write-Verbose "Filtering logs since: $SinceDate"
    }
    catch {
        Write-Warning "Could not parse -Since '$Since', showing all logs"
    }
}

# Function: Parse log entry timestamp
function Get-LogTimestamp {
    param([string]$Line)

    # Try common timestamp formats
    if ($Line -match '(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})') {
        try {
            return [datetime]::Parse($matches[1])
        }
        catch {
            return $null
        }
    }
    return $null
}

# Function: Check if line matches filters
function Test-LogLine {
    param(
        [string]$Line,
        [string]$CurrentSource
    )

    # Component filter
    if ($Component -and $Line -notmatch $Component) {
        return $false
    }

    # Pattern filter
    if ($Pattern -and $Line -notmatch $Pattern) {
        return $false
    }

    # Errors-only filter
    if ($ErrorsOnly) {
        if ($Line -notmatch '\b(error|warning|exception|fail|critical)\b') {
            return $false
        }
    }

    # Time filter
    if ($SinceDate) {
        $timestamp = Get-LogTimestamp $Line
        if ($timestamp -and $timestamp -lt $SinceDate) {
            return $false
        }
    }

    return $true
}

# Function: Read and process log file
function Read-LogFile {
    param(
        [string]$Path,
        [string]$SourceName
    )

    if (-not (Test-Path $Path)) {
        Write-Verbose "Log file not found: $Path"
        return @()
    }

    $lines = Get-Content $Path -Tail $Lines -ErrorAction SilentlyContinue
    $results = @()

    foreach ($line in $lines) {
        if (Test-LogLine -Line $line -CurrentSource $SourceName) {
            $results += [PSCustomObject]@{
                Timestamp = (Get-LogTimestamp $line)
                Source = $SourceName
                Line = $line
            }
        }
    }

    return $results
}

# Main execution
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📋 Jengo Unified Log Query" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$allLogs = @()

# Collect logs based on -Source parameter
if ($Source -eq "all" -or $Source -eq "orchestration") {
    Write-Verbose "Reading orchestration logs..."
    $orchestrationLogs = Get-ChildItem $LogSources.Orchestration -ErrorAction SilentlyContinue
    foreach ($logFile in $orchestrationLogs) {
        $allLogs += Read-LogFile -Path $logFile.FullName -SourceName "Orchestration"
    }
}

if ($Source -eq "all" -or $Source -eq "consciousness") {
    Write-Verbose "Reading consciousness logs..."
    $consciousnessLogs = Get-ChildItem $LogSources.Consciousness -ErrorAction SilentlyContinue
    foreach ($logFile in $consciousnessLogs) {
        $allLogs += Read-LogFile -Path $logFile.FullName -SourceName "Consciousness"
    }
}

if ($Source -eq "all" -or $Source -eq "bridge") {
    Write-Verbose "Reading consciousness bridge logs..."
    if (Test-Path $LogSources.Bridge) {
        $allLogs += Read-LogFile -Path $LogSources.Bridge -SourceName "Bridge"
    }
}

if ($Source -eq "all" -or $Source -eq "clickup") {
    Write-Verbose "Reading ClickUp logs..."
    if (Test-Path $LogSources.ClickUp) {
        $allLogs += Read-LogFile -Path $LogSources.ClickUp -SourceName "ClickUp"
    }
}

if ($Source -eq "all" -or $Source -eq "git") {
    Write-Verbose "Reading git logs..."
    if (Test-Path $LogSources.Git) {
        $allLogs += Read-LogFile -Path $LogSources.Git -SourceName "Git"
    }
}

# Sort by timestamp (recent last)
$allLogs = $allLogs | Sort-Object Timestamp

# Display results
if ($allLogs.Count -eq 0) {
    Write-Host "No log entries found matching filters." -ForegroundColor Yellow
}
else {
    Write-Host "Found $($allLogs.Count) matching log entries:" -ForegroundColor Green
    Write-Host ""

    foreach ($entry in $allLogs) {
        $sourceColor = switch ($entry.Source) {
            "Orchestration" { "Magenta" }
            "Consciousness" { "Cyan" }
            "Bridge" { "Blue" }
            "ClickUp" { "Yellow" }
            "Git" { "Green" }
            default { "White" }
        }

        # Highlight errors/warnings
        $lineColor = "White"
        if ($entry.Line -match '\berror\b') {
            $lineColor = "Red"
        }
        elseif ($entry.Line -match '\bwarning\b') {
            $lineColor = "Yellow"
        }

        Write-Host "[$($entry.Source)] " -NoNewline -ForegroundColor $sourceColor
        Write-Host $entry.Line -ForegroundColor $lineColor
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Query complete. Use -Verbose for more details." -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan

# Return structured data for programmatic use
return $allLogs
