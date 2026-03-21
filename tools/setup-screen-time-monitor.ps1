<#
.SYNOPSIS
Setup screen time monitor to auto-start on login

.DESCRIPTION
Creates a Windows scheduled task that:
- Starts screen-time-monitor.ps1 automatically when you log in
- Runs hidden in background (no console window)
- Restarts if it crashes

.NOTES
Run this once to set up auto-start. Monitor will begin logging immediately.
#>

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " SCREEN TIME MONITOR SETUP" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Paths
$monitorScript = "C:\scripts\tools\screen-time-monitor.ps1"
$logPath = "E:\jengo\health\screen-time.jsonl"

# Verify monitor script exists
if (-not (Test-Path $monitorScript)) {
    Write-Host "ERROR: Monitor script niet gevonden: $monitorScript" -ForegroundColor Red
    Write-Host ""
    exit 1
}

Write-Host "[1/4] Scripts gecontroleerd... " -NoNewline -ForegroundColor Gray
Write-Host "OK" -ForegroundColor Green

# Ensure log directory exists
$logDir = Split-Path $logPath -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

Write-Host "[2/4] Log directory aangemaakt... " -NoNewline -ForegroundColor Gray
Write-Host "OK" -ForegroundColor Green

# Remove existing task if present
$taskName = "ScreenTimeMonitor"
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "[3/4] Oude scheduled task verwijderen... " -NoNewline -ForegroundColor Gray
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "[3/4] Geen oude scheduled task... " -NoNewline -ForegroundColor Gray
    Write-Host "OK" -ForegroundColor Green
}

# Create scheduled task
Write-Host "[4/4] Nieuwe scheduled task aanmaken... " -NoNewline -ForegroundColor Gray

# Action: run PowerShell hidden with monitor script
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$monitorScript`""

# Trigger: at logon
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME

# Settings: restart if fails, allow on battery, etc
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

# Principal: current user
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive

# Register task
Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description "Track screen time for health monitoring (Jengo)" `
    -Force | Out-Null

Write-Host "OK" -ForegroundColor Green

# Start task immediately
Write-Host ""
Write-Host "Monitor starten... " -NoNewline -ForegroundColor Gray
Start-ScheduledTask -TaskName $taskName
Start-Sleep -Seconds 2

# Verify it's running
$task = Get-ScheduledTask -TaskName $taskName
if ($task.State -eq "Running") {
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "WARNING: Task niet gestart" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " SETUP COMPLEET" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Monitor draait nu op achtergrond en start automatisch bij login." -ForegroundColor Gray
Write-Host ""
Write-Host "Log locatie:  $logPath" -ForegroundColor Gray
Write-Host "Dashboard:    .\screen-time-dashboard.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "Wacht 2-3 minuten, dan is er genoeg data voor eerste stats." -ForegroundColor Yellow
Write-Host ""
