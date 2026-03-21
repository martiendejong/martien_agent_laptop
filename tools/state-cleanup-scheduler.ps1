# State File Cleanup Scheduler
# Run weekly to prevent state file bloat

param([switch]$Install, [switch]$RunNow)

$stateDir = "C:\scripts\agentidentity\state"
$logFile = "C:\scripts\agentidentity\logs\state-cleanup.log"

function Write-CleanupLog {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "[$timestamp] $Message"
    Write-Host "[$timestamp] $Message"
}

function Cleanup-StateFiles {
    Write-CleanupLog "=== STATE CLEANUP STARTED ==="

    # 1. Trim bridge-activity.jsonl (keep last 1000 entries)
    $activityFile = "$stateDir\bridge-activity.jsonl"
    if (Test-Path $activityFile) {
        $lines = Get-Content $activityFile
        if ($lines.Count -gt 1000) {
            $keep = $lines | Select-Object -Last 1000
            $keep | Set-Content $activityFile
            Write-CleanupLog "Trimmed bridge-activity.jsonl: $($lines.Count) -> 1000 lines"
        }
    }

    # 2. Trim consciousness_state_v2.json EventBus (keep last 100 events)
    $stateFile = "$stateDir\consciousness_state_v2.json"
    if (Test-Path $stateFile) {
        try {
            $state = Get-Content $stateFile -Raw | ConvertFrom-Json
            if ($state.EventBus.Events -and $state.EventBus.Events.Count -gt 100) {
                $eventCount = $state.EventBus.Events.Count
                $state.EventBus.Events = $state.EventBus.Events | Select-Object -Last 100
                $state | ConvertTo-Json -Depth 100 | Set-Content $stateFile
                Write-CleanupLog "Trimmed EventBus: $eventCount -> 100 events"
            }
        }
        catch {
            Write-CleanupLog "ERROR trimming state file: $_"
        }
    }

    # 3. Delete old backups (keep last 5)
    $backups = Get-ChildItem "$stateDir\*.backup*" | Sort-Object LastWriteTime -Descending
    if ($backups.Count -gt 5) {
        $toDelete = $backups | Select-Object -Skip 5
        $toDelete | ForEach-Object {
            Remove-Item $_.FullName -Force
            Write-CleanupLog "Deleted old backup: $($_.Name)"
        }
    }

    # 4. Rotate logs (keep last 10MB)
    $logs = Get-ChildItem "C:\scripts\agentidentity\logs\*.log"
    foreach ($log in $logs) {
        if ($log.Length -gt 10MB) {
            $lines = Get-Content $log.FullName
            $keep = $lines | Select-Object -Last 10000
            $keep | Set-Content $log.FullName
            Write-CleanupLog "Rotated log: $($log.Name)"
        }
    }

    Write-CleanupLog "=== STATE CLEANUP COMPLETED ==="
}

if ($Install) {
    # Create scheduled task (weekly, Sunday 3AM)
    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-ExecutionPolicy Bypass -File `"$PSCommandPath`" -RunNow"

    $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 3am

    $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" `
        -LogonType Interactive -RunLevel Highest

    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries -StartWhenAvailable

    Register-ScheduledTask -TaskName "JengoStateCleanup" `
        -Action $action -Trigger $trigger -Principal $principal `
        -Settings $settings -Force

    Write-Host "Scheduled task 'JengoStateCleanup' installed (runs Sunday 3AM)" -ForegroundColor Green
}
elseif ($RunNow) {
    Cleanup-StateFiles
}
else {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  -Install    Install weekly scheduled task" -ForegroundColor White
    Write-Host "  -RunNow     Run cleanup now" -ForegroundColor White
}
