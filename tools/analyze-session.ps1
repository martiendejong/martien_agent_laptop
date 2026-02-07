#!/usr/bin/env pwsh
# analyze-session.ps1 - Analyze session log for patterns
# Part of Embedded Learning Architecture

param(
    [Parameter(Mandatory=$false)]
    [string]$SessionLogPath = "C:\scripts\_machine\current-session-log.jsonl",

    [Parameter(Mandatory=$false)]
    [switch]$Detailed = $false,

    [Parameter(Mandatory=$false)]
    [int]$AutomationThreshold = 3
)

if (-not (Test-Path $SessionLogPath)) {
    Write-Host "❌ No session log found at: $SessionLogPath" -ForegroundColor Red
    Write-Host "   Session logging may not be active yet." -ForegroundColor Yellow
    exit 1
}

# Load session log
$logEntries = Get-Content $SessionLogPath | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
    $_ | ConvertFrom-Json
}

if ($logEntries.Count -eq 0) {
    Write-Host "❌ Session log is empty" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📊 SESSION ANALYSIS" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host ""

# Total actions
Write-Host "Total Actions Logged: $($logEntries.Count)" -ForegroundColor White
Write-Host ""

# Action frequency
Write-Host "📈 Action Frequency:" -ForegroundColor Yellow
$actionFreq = $logEntries | Group-Object -Property action | Sort-Object Count -Descending
$actionFreq | ForEach-Object {
    $color = "White"
    $marker = "  "
    if ($_.Count -ge $AutomationThreshold) {
        $color = "Yellow"
        $marker = "⚠️ "
    }
    Write-Host "$marker$($_.Count)x - $($_.Name)" -ForegroundColor $color
}
Write-Host ""

# Automation candidates
$automationCandidates = $actionFreq | Where-Object { $_.Count -ge $AutomationThreshold }
if ($automationCandidates) {
    Write-Host "🤖 Automation Candidates (≥${AutomationThreshold}x):" -ForegroundColor Green
    $automationCandidates | ForEach-Object {
        Write-Host "   • $($_.Name) - occurred $($_.Count) times" -ForegroundColor Green
    }
    Write-Host ""
}

# Error patterns
$errors = $logEntries | Where-Object { $_.outcome -like "*error*" -or $_.outcome -like "*fail*" }
if ($errors) {
    Write-Host "❌ Errors Detected:" -ForegroundColor Red
    $errorFreq = $errors | Group-Object -Property action | Sort-Object Count -Descending
    $errorFreq | ForEach-Object {
        $color = if ($_.Count -ge 2) { "Red" } else { "Yellow" }
        $urgency = if ($_.Count -ge 2) { "🚨 CRITICAL" } else { "⚠️ " }
        Write-Host "   $urgency $($_.Count)x - $($_.Name)" -ForegroundColor $color
    }
    Write-Host ""
}

# Automation triggers
$triggers = $logEntries | Where-Object { $_.automation_trigger -eq $true }
if ($triggers) {
    Write-Host "🔔 Automation Triggers Fired:" -ForegroundColor Magenta
    $triggers | ForEach-Object {
        Write-Host "   • $($_.timestamp) - $($_.suggestion)" -ForegroundColor Magenta
    }
    Write-Host ""
}

# Detailed mode - show timeline
if ($Detailed) {
    Write-Host "📋 Session Timeline:" -ForegroundColor Cyan
    $logEntries | ForEach-Object {
        $color = "Gray"
        $marker = "•"

        if ($_.automation_trigger) {
            $color = "Yellow"
            $marker = "⚠️"
        }

        if ($_.outcome -like "*error*") {
            $color = "Red"
            $marker = "❌"
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
Write-Host "💡 Recommendations:" -ForegroundColor Cyan
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
    Write-Host "   • $_" -ForegroundColor Cyan
}
Write-Host ""

# Return data for programmatic use
return @{
    TotalActions = $logEntries.Count
    AutomationCandidates = $automationCandidates.Count
    Errors = $errors.Count
    Triggers = $triggers.Count
}
