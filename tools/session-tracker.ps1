# Session Tracker - Real-time action logging + predictions
# Tracks what I'm doing, shows next-action predictions
# Created: 2026-02-07 (Real integration example)

<#
.SYNOPSIS
    Session Tracker - Real-time action logging + predictions

.DESCRIPTION
    Session Tracker - Real-time action logging + predictions

.NOTES
    File: session-tracker.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('log', 'status', 'predict', 'clear')]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$ToolName
)

$ErrorActionPreference = "Stop"
$sessionLog = "C:\scripts\.machine\current-session.log"

function Log-Action {
    param([string]$Tool)

    $timestamp = Get-Date -Format "HH:mm:ss"
    "$timestamp | $Tool" | Add-Content $sessionLog -Encoding UTF8

    # Show prediction
    Write-Host ""
    & "C:\scripts\tools\predict-next.ps1" -LastAction $Tool
}

function Show-Status {
    if (-not (Test-Path $sessionLog)) {
        Write-Host "No actions logged this session" -ForegroundColor Gray
        return
    }

    $lines = Get-Content $sessionLog
    Write-Host ""
    Write-Host "=== SESSION ACTIVITY ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Last 10 actions:" -ForegroundColor Yellow
    $lines | Select-Object -Last 10 | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Gray
    }
    Write-Host ""

    # Count tool usage
    $tools = @{}
    foreach ($line in $lines) {
        if ($line -match "\| (.+)$") {
            $tool = $matches[1]
            if (-not $tools.ContainsKey($tool)) {
                $tools[$tool] = 0
            }
            $tools[$tool]++
        }
    }

    Write-Host "Tool usage summary:" -ForegroundColor Yellow
    $tools.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value) times" -ForegroundColor White
    }
    Write-Host ""
}

function Clear-Session {
    if (Test-Path $sessionLog) {
        Remove-Item $sessionLog
    }
    Write-Host "[CLEARED] Session log reset" -ForegroundColor Green
}

# Main execution
switch ($Action) {
    'log' {
        if (-not $ToolName) {
            Write-Host "[ERROR] -ToolName required for log action" -ForegroundColor Red
            exit 1
        }
        Log-Action -Tool $ToolName
    }
    'status' {
        Show-Status
    }
    'predict' {
        if (-not $ToolName) {
            Write-Host "[ERROR] -ToolName required for predict action" -ForegroundColor Red
            exit 1
        }
        & "C:\scripts\tools\predict-next.ps1" -LastAction $ToolName
    }
    'clear' {
        Clear-Session
    }
}
