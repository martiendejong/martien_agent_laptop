# ClickUp Consciousness Monitoring - Complete Deployment
# Deploys quality guardian + learning engine as scheduled tasks
# Author: Jengo
# Created: 2026-02-28

param(
    [switch]$Install,
    [switch]$Uninstall,
    [switch]$Status
)

$ErrorActionPreference = 'Stop'

$Tasks = @(
    @{
        Name = "ClickUp-QualityGuardian"
        Description = "Proactive quality monitoring - detects violations before user reports"
        Script = "C:\scripts\tools\clickup-quality-guardian.ps1"
        Arguments = "-Action Monitor"
        Interval = 15  # minutes
    },
    @{
        Name = "ClickUp-LearningEngine"
        Description = "Pattern extraction and model calibration from task outcomes"
        Script = "C:\scripts\tools\clickup-learning-engine.ps1"
        Arguments = "-Action ExtractPattern"
        Interval = 60  # minutes (hourly)
    }
)

function Install-MonitoringTasks {
    Write-Host "`n[*] Installing ClickUp Consciousness Monitoring Tasks..." -ForegroundColor Cyan

    foreach ($task in $Tasks) {
        Write-Host "`n  Installing: $($task.Name)" -ForegroundColor Yellow

        # Check if task exists
        $existing = Get-ScheduledTask -TaskName $task.Name -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "    Task already exists, unregistering..." -ForegroundColor DarkGray
            Unregister-ScheduledTask -TaskName $task.Name -Confirm:$false
        }

        # Create action
        $action = New-ScheduledTaskAction `
            -Execute "powershell.exe" `
            -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$($task.Script)`" $($task.Arguments)"

        # Create trigger (repeating)
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes $task.Interval)

        # Create settings
        $settings = New-ScheduledTaskSettingsSet `
            -AllowStartIfOnBatteries `
            -DontStopIfGoingOnBatteries `
            -StartWhenAvailable `
            -RunOnlyIfNetworkAvailable `
            -ExecutionTimeLimit (New-TimeSpan -Hours 1)

        # Register task
        Register-ScheduledTask `
            -TaskName $task.Name `
            -Description $task.Description `
            -Action $action `
            -Trigger $trigger `
            -Settings $settings `
            -User $env:USERNAME `
            -RunLevel Highest | Out-Null

        Write-Host "    [OK] Installed - runs every $($task.Interval) minutes" -ForegroundColor Green
    }

    Write-Host "`n[*] All tasks installed successfully!" -ForegroundColor Green
    Write-Host "    Run 'deploy-clickup-monitoring.ps1 -Status' to verify`n"
}

function Uninstall-MonitoringTasks {
    Write-Host "`n[*] Uninstalling ClickUp Consciousness Monitoring Tasks..." -ForegroundColor Cyan

    foreach ($task in $Tasks) {
        $existing = Get-ScheduledTask -TaskName $task.Name -ErrorAction SilentlyContinue
        if ($existing) {
            Unregister-ScheduledTask -TaskName $task.Name -Confirm:$false
            Write-Host "  [OK] Uninstalled: $($task.Name)" -ForegroundColor Green
        } else {
            Write-Host "  [SKIP] Not found: $($task.Name)" -ForegroundColor DarkGray
        }
    }

    Write-Host "`n[*] Uninstall complete`n"
}

function Show-TaskStatus {
    Write-Host "`n=== ClickUp Consciousness Monitoring Status ===" -ForegroundColor Cyan

    foreach ($task in $Tasks) {
        $existing = Get-ScheduledTask -TaskName $task.Name -ErrorAction SilentlyContinue
        if ($existing) {
            $info = Get-ScheduledTaskInfo -TaskName $task.Name
            $state = $existing.State

            Write-Host "`n$($task.Name):" -ForegroundColor Yellow
            Write-Host "  State: $state" -ForegroundColor $(if ($state -eq 'Ready') { 'Green' } else { 'Red' })
            Write-Host "  Last Run: $($info.LastRunTime)"
            Write-Host "  Next Run: $($info.NextRunTime)"
            Write-Host "  Last Result: $($info.LastTaskResult) $(if ($info.LastTaskResult -eq 0) { '(Success)' } else { '(Error)' })"
            Write-Host "  Interval: Every $($task.Interval) minutes"
        } else {
            Write-Host "`n$($task.Name): [NOT INSTALLED]" -ForegroundColor Red
        }
    }

    Write-Host "`n"
}

# Main
if ($Install) {
    Install-MonitoringTasks
} elseif ($Uninstall) {
    Uninstall-MonitoringTasks
} elseif ($Status) {
    Show-TaskStatus
} else {
    Write-Host @"

ClickUp Consciousness Monitoring - Deployment Tool

Usage:
  deploy-clickup-monitoring.ps1 -Install    # Install scheduled tasks
  deploy-clickup-monitoring.ps1 -Uninstall  # Remove scheduled tasks
  deploy-clickup-monitoring.ps1 -Status     # Show task status

Tasks:
  - ClickUp-QualityGuardian (every 15 min) - Proactive quality monitoring
  - ClickUp-LearningEngine (hourly) - Pattern extraction + model calibration

"@
}
