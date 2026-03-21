<#
.SYNOPSIS
Setup ManicTime Worker - Install scheduled task to run every 5 minutes

.DESCRIPTION
Creates a Windows scheduled task that runs manictime-worker.ps1 every 5 minutes.
Monitors ManicTime activity and publishes events to message queue.

.NOTES
Worker: C:\scripts\tools\manictime-worker.ps1
Scheduled task: ManicTimeWorker (runs every 5 minutes)
#>

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " MANICTIME WORKER SETUP" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Paths
$workerScript = "C:\scripts\tools\manictime-worker-v2.ps1"
$dbPath = "$env:LOCALAPPDATA\Finkit\ManicTime\ManicTimeReports.db"
$statePath = "E:\jengo\health\manictime-state.json"
$eventsPath = "E:\jengo\health\manictime-events.jsonl"

# Verify worker script exists
if (-not (Test-Path $workerScript)) {
    Write-Host "ERROR: Worker script not found: $workerScript" -ForegroundColor Red
    Write-Host ""
    exit 1
}

Write-Host "[1/5] Worker script verified... " -NoNewline -ForegroundColor Gray
Write-Host "OK" -ForegroundColor Green

# Verify ManicTime database exists
if (-not (Test-Path $dbPath)) {
    Write-Host "[2/5] ManicTime database check... " -NoNewline -ForegroundColor Gray
    Write-Host "ERROR" -ForegroundColor Red
    Write-Host ""
    Write-Host "ManicTime database not found: $dbPath" -ForegroundColor Red
    Write-Host "Please start ManicTime and let it run for a few minutes first." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "[2/5] ManicTime database found... " -NoNewline -ForegroundColor Gray
Write-Host "OK" -ForegroundColor Green

# Ensure state directory exists
$stateDir = Split-Path $statePath -Parent
if (-not (Test-Path $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}

Write-Host "[3/5] State directory created... " -NoNewline -ForegroundColor Gray
Write-Host "OK" -ForegroundColor Green

# Remove existing task if present
$taskName = "ManicTimeWorker"
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "[4/5] Removing old scheduled task... " -NoNewline -ForegroundColor Gray
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "[4/5] No old scheduled task... " -NoNewline -ForegroundColor Gray
    Write-Host "OK" -ForegroundColor Green
}

# Create scheduled task
Write-Host "[5/5] Creating scheduled task... " -NoNewline -ForegroundColor Gray

# Action: run PowerShell hidden with worker script
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$workerScript`""

# Trigger: every 5 minutes
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)

# Settings: restart if fails, allow on battery, run as soon as possible if missed
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 4)

# Principal: current user
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive

# Register task
Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description "Monitor ManicTime activity and publish events every 5 minutes (Jengo)" `
    -Force | Out-Null

Write-Host "OK" -ForegroundColor Green

# Start task immediately for first run
Write-Host ""
Write-Host "Running first worker cycle... " -NoNewline -ForegroundColor Gray
Start-ScheduledTask -TaskName $taskName
Start-Sleep -Seconds 3

# Check if events were generated
if (Test-Path $eventsPath) {
    $eventCount = (Get-Content $eventsPath | Measure-Object -Line).Lines
    Write-Host "OK ($eventCount events)" -ForegroundColor Green
} else {
    Write-Host "WARNING (no events yet)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " SETUP COMPLETE" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Worker runs every 5 minutes automatically." -ForegroundColor Gray
Write-Host ""
Write-Host "State file:  $statePath" -ForegroundColor Gray
Write-Host "Events:      $eventsPath" -ForegroundColor Gray
Write-Host "Database:    $dbPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Events published:" -ForegroundColor Gray
Write-Host "  - WorkSessionStarted/Ended" -ForegroundColor Gray
Write-Host "  - ActivityChanged (app switches)" -ForegroundColor Gray
Write-Host "  - IdlePeriodDetected (>5 min idle)" -ForegroundColor Gray
Write-Host "  - DailySummary (end of day)" -ForegroundColor Gray
Write-Host ""
Write-Host "Any service can now subscribe to: $eventsPath" -ForegroundColor Yellow
Write-Host ""
