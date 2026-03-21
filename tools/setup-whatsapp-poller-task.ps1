# Setup WhatsApp EventBus Poller as Windows Scheduled Task
# Runs every 5 minutes to poll WhatsApp API and post events

param(
    [switch]$Remove  # Remove the task instead of creating it
)

$taskName = "WhatsAppEventBusPoller"
$scriptPath = "C:\scripts\tools\whatsapp-eventbus-poller.ps1"
$logPath = "E:\jengo\documents\temp\whatsapp-poller.log"

if ($Remove) {
    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "[REMOVED] Scheduled task '$taskName' has been removed"
    } else {
        Write-Host "[INFO] Task '$taskName' does not exist"
    }
    exit 0
}

# Check if task already exists
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "[INFO] Task '$taskName' already exists. Removing and recreating..."
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Create action - run PowerShell script with logging
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -Command `"& '$scriptPath' -Silent 2>&1 | Tee-Object -FilePath '$logPath' -Append`""

# Create trigger - every 5 minutes
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)

# Create settings
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 2) `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

# Create principal (run as current user)
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType S4U -RunLevel Limited

# Register the task
Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description "Polls WhatsApp API every 5 minutes and posts new messages to EventBus API" `
    | Out-Null

Write-Host "[SUCCESS] Scheduled task '$taskName' created successfully"
Write-Host ""
Write-Host "Task details:"
Write-Host "  Name:      $taskName"
Write-Host "  Interval:  Every 5 minutes"
Write-Host "  Script:    $scriptPath"
Write-Host "  Log file:  $logPath"
Write-Host ""
Write-Host "Management commands:"
Write-Host "  Start now:    Start-ScheduledTask -TaskName '$taskName'"
Write-Host "  Stop:         Stop-ScheduledTask -TaskName '$taskName'"
Write-Host "  View status:  Get-ScheduledTask -TaskName '$taskName' | Get-ScheduledTaskInfo"
Write-Host "  Remove:       .\setup-whatsapp-poller-task.ps1 -Remove"
Write-Host ""

# Ask if user wants to start the task now
$response = Read-Host "Start the task now? (y/n)"
if ($response -eq 'y') {
    Start-ScheduledTask -TaskName $taskName
    Start-Sleep -Seconds 2

    $info = Get-ScheduledTask -TaskName $taskName | Get-ScheduledTaskInfo
    Write-Host "[STARTED] Task is now running"
    Write-Host "  Last run:   $($info.LastRunTime)"
    Write-Host "  Next run:   $($info.NextRunTime)"
    Write-Host "  Last result: $($info.LastTaskResult)"
}
