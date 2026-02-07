#!/usr/bin/env pwsh
# setup-daily-report-task.ps1
# Sets up Windows scheduled task to run daily work report at 6 PM

$ErrorActionPreference = "Stop"

$taskName = "WorkTrackingDailyReport"
$scriptPath = "C:\scripts\tools\daily-report.ps1"
$time = "18:00"  # 6 PM

Write-Host "📅 Setting up scheduled task: $taskName" -ForegroundColor Cyan
Write-Host "⏰ Schedule: Daily at $time" -ForegroundColor Gray
Write-Host "📜 Script: $scriptPath" -ForegroundColor Gray
Write-Host ""

# Check if task already exists
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($existingTask) {
    Write-Host "⚠️ Task '$taskName' already exists" -ForegroundColor Yellow
    $response = Read-Host "Do you want to replace it? (y/n)"

    if ($response -ne 'y') {
        Write-Host "❌ Cancelled" -ForegroundColor Red
        exit 0
    }

    Write-Host "🗑️ Removing existing task..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Create trigger (daily at 6 PM)
$trigger = New-ScheduledTaskTrigger -Daily -At $time

# Create action (run PowerShell script)
$action = New-ScheduledTaskAction `
    -Execute "pwsh.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

# Create task settings
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable:$false

# Register task
try {
    Register-ScheduledTask `
        -TaskName $taskName `
        -Trigger $trigger `
        -Action $action `
        -Settings $settings `
        -Description "Generates daily work tracking report at 6 PM" `
        -User $env:USERNAME `
        -RunLevel Limited

    Write-Host "✅ Scheduled task created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📌 Task Details:" -ForegroundColor Cyan
    Write-Host "   Name: $taskName" -ForegroundColor Gray
    Write-Host "   Schedule: Daily at $time" -ForegroundColor Gray
    Write-Host "   Script: $scriptPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 Useful commands:" -ForegroundColor Cyan
    Write-Host "   Get-ScheduledTask -TaskName '$taskName'  # View task" -ForegroundColor Gray
    Write-Host "   Start-ScheduledTask -TaskName '$taskName'  # Run now" -ForegroundColor Gray
    Write-Host "   Unregister-ScheduledTask -TaskName '$taskName'  # Remove task" -ForegroundColor Gray
    Write-Host ""

    # Test run
    $response = Read-Host "Do you want to run the task now to test? (y/n)"
    if ($response -eq 'y') {
        Write-Host "🚀 Running task..." -ForegroundColor Cyan
        Start-ScheduledTask -TaskName $taskName
        Start-Sleep -Seconds 2
        Write-Host "✅ Task executed" -ForegroundColor Green
    }
}
catch {
    Write-Host "❌ Failed to create scheduled task: $_" -ForegroundColor Red
    exit 1
}
