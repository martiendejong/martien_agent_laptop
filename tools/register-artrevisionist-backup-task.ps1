# Create scheduled task for artrevisionist nightly backup

$taskName = "Artrevisionist Nightly Backup"
$scriptPath = "C:\scripts\tools\backup-artrevisionist.ps1"

# Remove existing task if it exists
try {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
} catch {}

$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$scriptPath`""

# Run at 3:30 AM (30 minutes after brand2boost to stagger backups)
$trigger = New-ScheduledTaskTrigger -Daily -At "03:30"

$settings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Hours 1)

$principal = New-ScheduledTaskPrincipal `
    -UserId "SYSTEM" `
    -LogonType ServiceAccount `
    -RunLevel Highest

Register-ScheduledTask `
    -TaskName $taskName `
    -Description "Nightly backup of artrevisionist data folder with 5-day retention" `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Force

Write-Host "Task registered successfully!" -ForegroundColor Green
Get-ScheduledTask -TaskName $taskName | Format-List
