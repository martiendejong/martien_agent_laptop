#!/usr/bin/env pwsh
# analyze-session.ps1 - Analyze session log for patterns
# Part of Embedded Learning Architecture

<#
.SYNOPSIS
    !/usr/bin/env pwsh

.DESCRIPTION
    !/usr/bin/env pwsh

.NOTES
    File: analyze-session.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Mandatory=$false)]

$ErrorActionPreference = "Stop"
    [string]$SessionLogPath = "C:\scripts\_machine\current-session-log.jsonl",

    [Parameter(Mandatory=$false)]
    [switch]$Detailed = $false,

    [Parameter(Mandatory=$false)]
    [int]$AutomationThreshold = 3
)

if (-not (Test-Path $SessionLogPath)) {
    Write-Host "âŒ No session log found at: $SessionLogPath" -ForegroundColor Red
    Write-Host "   Session logging may not be active yet." -ForegroundColor Yellow
    exit 1
}

# Load session log
$logEntries = Get-Content $SessionLogPath | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
    $_ | ConvertFrom-Json
}

if ($logEntries.Count -eq 0) {
    Write-Host "âŒ Session log is empty" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "ðŸ“Š SESSION ANALYSIS" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host ""

# Total actions
Write-Host "Total Actions Logged: $($logEntries.Count)" -ForegroundColor White
Write-Host ""

# Action frequency
Write-Host "ðŸ“ˆ Action Frequency:" -ForegroundColor Yellow
$actionFreq = $logEntries | Group-Object -Property action | Sort-Object Count -Descending
$actionFreq | ForEach-Object {
    $color = "White"
    $marker = "  "
    if ($_.Count -ge $AutomationThreshold) {
        $color = "Yellow"
        $marker = "âš ï¸ "
    }
    Write-Host "$marker$($_.Count)x - $($_.Name)" -ForegroundColor $color
}
Write-Host ""

# Automation candidates
$automationCandidates = $actionFreq | Where-Object { $_.Count -ge $AutomationThreshold }
if ($automationCandidates) {
    Write-Host "ðŸ¤– Automation Candidates (â‰¥${AutomationThreshold}x):" -ForegroundColor Green
    $automationCandidates | ForEach-Object {
        Write-Host "   â€¢ $($_.Name) - occurred $($_.Count) times" -ForegroundColor Green
    }
    Write-Host ""
}

# Error patterns
$errors = $logEntries | Where-Object { $_.outcome -like "*error*" -or $_.outcome -like "*fail*" }
if ($errors) {
    Write-Host "âŒ Errors Detected:" -ForegroundColor Red
    $errorFreq = $errors | Group-Object -Property action | Sort-Object Count -Descending
    $errorFreq | ForEach-Object {
        $color = if ($_.Count -ge 2) { "Red" } else { "Yellow" }
        $urgency = if ($_.Count -ge 2) { "ðŸš¨ CRITICAL" } else { "âš ï¸ " }
        Write-Host "   $urgency $($_.Count)x - $($_.Name)" -ForegroundColor $color
    }
    Write-Host ""
}

# Automation triggers
$triggers = $logEntries | Where-Object { $_.automation_trigger -eq $true }
if ($triggers) {
    Write-Host "ðŸ”” Automation Triggers Fired:" -ForegroundColor Magenta
    $triggers | ForEach-Object {
        Write-Host "   â€¢ $($_.timestamp) - $($_.suggestion)" -ForegroundColor Magenta
    }
    Write-Host ""
}

# Detailed mode - show timeline
if ($Detailed) {
    Write-Host "ðŸ“‹ Session Timeline:" -ForegroundColor Cyan
    $logEntries | ForEach-Object {
        $color = "Gray"
        $marker = "â€¢"

        if ($_.automation_trigger) {
            $color = "Yellow"
            $marker = "âš ï¸"
        }

        if ($_.outcome -like "*error*") {
            $color = "Red"
            $marker = "âŒ"
        }

        Write-Host "$marker $($_.timestamp) - $($_.action)" -ForegroundColor $color
        Write-Host "   Reasoning: $($_.reasoning)" -ForegroundColor DarkGray
        if ($_.outcome) {
            Write-Host "   Outcome: $($_.outcome)" -ForegroundColor DarkGray
        }
        Write-Host ""
    }
}

# Summary recommendations
Write-Host "ðŸ’¡ Recommendations:" -ForegroundColor Cyan
$recommendations = @()

if ($automationCandidates) {
    $recommendations += "Create automation for: $($automationCandidates.Name -join ', ')"
}

if ($errors.Count -ge 2) {
    $recommendations += "Update instructions to prevent repeated errors"
}

if ($logEntries.Count -lt 10) {
    $recommendations += "Consider logging more actions for better pattern detection"
}

if ($recommendations.Count -eq 0) {
    $recommendations += "No immediate actions required - session appears optimal"
}

$recommendations | ForEach-Object {
    Write-Host "   â€¢ $_" -ForegroundColor Cyan
}
Write-Host ""

# Return data for programmatic use
return @{
    TotalActions = $logEntries.Count
    AutomationCandidates = $automationCandidates.Count
    Errors = $errors.Count
    Triggers = $triggers.Count
}
