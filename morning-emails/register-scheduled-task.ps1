#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Register Morning Email Briefing scheduled task

.DESCRIPTION
    Creates a Windows scheduled task that runs morning-briefing.ps1 on user login.
    Only runs once per day (first login).

.EXAMPLE
    .\register-scheduled-task.ps1

.EXAMPLE
    .\register-scheduled-task.ps1 -Unregister
    Remove the scheduled task
#>

[CmdletBinding()]
param(
    [switch]$Unregister
)

$ErrorActionPreference = 'Stop'
$TaskName = "MorningEmailBriefing"
$ScriptPath = Join-Path $PSScriptRoot "morning-briefing.ps1"

if ($Unregister) {
    Write-Host "Unregistering scheduled task: $TaskName" -ForegroundColor Yellow

    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "✓ Task unregistered successfully" -ForegroundColor Green
    } else {
        Write-Host "Task not found: $TaskName" -ForegroundColor Yellow
    }

    exit 0
}

# Check if script exists
if (-not (Test-Path $ScriptPath)) {
    Write-Error "Script not found: $ScriptPath"
    exit 1
}

Write-Host "Registering scheduled task: $TaskName" -ForegroundColor Cyan
Write-Host "Script: $ScriptPath" -ForegroundColor Gray

# Define the action
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""

# Define the trigger (at logon)
$trigger = New-ScheduledTaskTrigger -AtLogon

# Define settings
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 10)

# Define principal (current user)
$principal = New-ScheduledTaskPrincipal `
    -UserId $env:USERNAME `
    -LogonType Interactive `
    -RunLevel Limited

# Register the task
try {
    # Remove existing task if present
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Write-Host "Removing existing task..." -ForegroundColor Yellow
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    }

    # Register new task
    Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal `
        -Description "Automated morning email briefing with TTS. Runs once per day on first login." `
        | Out-Null

    Write-Host "✓ Scheduled task registered successfully" -ForegroundColor Green
    Write-Host ""
    Write-Host "Task Details:" -ForegroundColor Cyan
    Write-Host "  Name: $TaskName" -ForegroundColor Gray
    Write-Host "  Trigger: At logon" -ForegroundColor Gray
    Write-Host "  Frequency: Once per day (first login)" -ForegroundColor Gray
    Write-Host "  Script: $ScriptPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "To test manually, run:" -ForegroundColor Yellow
    Write-Host "  .\morning-briefing.ps1 -Test" -ForegroundColor White
    Write-Host ""
    Write-Host "To unregister, run:" -ForegroundColor Yellow
    Write-Host "  .\register-scheduled-task.ps1 -Unregister" -ForegroundColor White

} catch {
    Write-Error "Failed to register scheduled task: $_"
    exit 1
}
