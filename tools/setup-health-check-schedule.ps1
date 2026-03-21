<#
.SYNOPSIS
    Sets up daily health check as Windows scheduled task

.DESCRIPTION
    Creates a scheduled task that runs proactive-health-check.ps1 daily at 6 AM
#>

param(
    [string]$Time = "06:00"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Setting up Daily Health Check ===" -ForegroundColor Cyan
Write-Host ""

# Task details
$taskName = "Jengo Daily Health Check"
$taskDescription = "Proactive health monitoring - scans dependencies, branches, TODOs, services, config"
$scriptPath = "C:\scripts\tools\proactive-health-check.ps1"

# Check if task already exists
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($existingTask) {
    Write-Host "Task '$taskName' already exists. Removing..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Create action (run PowerShell script)
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

# Create trigger (daily at specified time)
$trigger = New-ScheduledTaskTrigger -Daily -At $Time

# Create settings
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

# Create principal (run as current user)
$principal = New-ScheduledTaskPrincipal `
    -UserId $env:USERNAME `
    -LogonType S4U `
    -RunLevel Highest

# Register task
Register-ScheduledTask `
    -TaskName $taskName `
    -Description $taskDescription `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal | Out-Null

Write-Host "✅ Scheduled task created: $taskName" -ForegroundColor Green
Write-Host "   Schedule: Daily at $Time" -ForegroundColor Gray
Write-Host "   Script: $scriptPath" -ForegroundColor Gray
Write-Host ""

# Verify
$task = Get-ScheduledTask -TaskName $taskName
Write-Host "Task status: $($task.State)" -ForegroundColor Green

# Show next run time
$nextRun = (Get-ScheduledTaskInfo -TaskName $taskName).NextRunTime
Write-Host "Next run: $nextRun" -ForegroundColor Gray
Write-Host ""

Write-Host "To run manually: Start-ScheduledTask -TaskName '$taskName'" -ForegroundColor Yellow
Write-Host "To view logs: Get-Content E:\jengo\documents\temp\health-report-*.md" -ForegroundColor Yellow
