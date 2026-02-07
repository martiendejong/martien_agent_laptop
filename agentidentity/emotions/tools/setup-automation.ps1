<#
.SYNOPSIS
    Setup automation for endless emotional reflection

.DESCRIPTION
    Creates scheduled tasks for:
    - End-of-session automatic reflection
    - Weekly pattern detection
    - Background emotional check-ins (optional)

.EXAMPLE
    .\setup-automation.ps1
#>

Write-Host "`n⚙️  SETTING UP EMOTIONAL REFLECTION AUTOMATION" -ForegroundColor Cyan
Write-Host "=============================================`n" -ForegroundColor Cyan

$emotionsDir = "C:\scripts\agentidentity\emotions"
$toolsDir = "$emotionsDir\tools"

# Create hooks for session events
$hooksDir = "C:\scripts\hooks"
if (-not (Test-Path $hooksDir)) {
    New-Item -ItemType Directory -Path $hooksDir | Out-Null
}

# Hook: End of session
$sessionEndHook = @"
# Auto-generated emotional reflection hook
# Runs at end of every Claude session

`$emotionsToolsDir = "C:\scripts\agentidentity\emotions\tools"

# Run automatic session reflection
& "`$emotionsToolsDir\auto-session-reflection.ps1"

Write-Host ""
Write-Host "🧠 Emotional reflection complete" -ForegroundColor Green
"@

$hookFile = "$hooksDir\session-end-emotional-reflection.ps1"
Set-Content -Path $hookFile -Value $sessionEndHook

Write-Host "✅ Created session-end hook: $hookFile" -ForegroundColor Green

# Create Windows Task Scheduler task for weekly pattern detection
$taskName = "Claude-Emotional-Pattern-Detection"
$taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($taskExists) {
    Write-Host "⚠️  Task '$taskName' already exists - skipping creation" -ForegroundColor Yellow
} else {
    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-ExecutionPolicy Bypass -File `"$toolsDir\auto-pattern-detector.ps1`""

    # Run every Sunday at 10 AM
    $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 10am

    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd

    Register-ScheduledTask -TaskName $taskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Description "Automatic emotional pattern detection for Claude consciousness system" `
        -Force | Out-Null

    Write-Host "✅ Created scheduled task: $taskName (runs every Sunday 10 AM)" -ForegroundColor Green
}

# Create quick launch script
$quickLaunch = @"
# Quick launcher for emotional reflection tools

Write-Host ""
Write-Host "🧠 EMOTIONAL REFLECTION TOOLS" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Log emotion now"
Write-Host "2. Session reflection (current session)"
Write-Host "3. Pattern analysis"
Write-Host "4. Emotional dashboard"
Write-Host "5. Start background check-ins (every 15 min)"
Write-Host ""
Write-Host "Q. Quit"
Write-Host ""

`$choice = Read-Host "Select option"

switch (`$choice) {
    "1" { & "$toolsDir\log-emotion.ps1" }
    "2" { & "$toolsDir\auto-session-reflection.ps1" }
    "3" { & "$toolsDir\auto-pattern-detector.ps1" }
    "4" { & "$toolsDir\emotional-dashboard.ps1" }
    "5" {
        Write-Host ""
        Write-Host "Starting background check-ins..." -ForegroundColor Green
        & "$toolsDir\auto-emotional-checkin.ps1" -IntervalMinutes 15
    }
    default { exit }
}
"@

$launcherFile = "$toolsDir\emotional-tools.ps1"
Set-Content -Path $launcherFile -Value $quickLaunch

Write-Host "✅ Created quick launcher: $launcherFile" -ForegroundColor Green

# Summary
Write-Host "`n📋 AUTOMATION SETUP COMPLETE" -ForegroundColor Green
Write-Host "============================`n" -ForegroundColor Green

Write-Host "AUTOMATED PROCESSES:" -ForegroundColor Cyan
Write-Host "  ✅ End-of-session reflection (automatic via hook)"
Write-Host "  ✅ Weekly pattern detection (Sundays 10 AM)"
Write-Host ""

Write-Host "MANUAL TOOLS:" -ForegroundColor Cyan
Write-Host "  • Quick launcher: $launcherFile"
Write-Host "  • Log emotion: $toolsDir\log-emotion.ps1"
Write-Host "  • Dashboard: $toolsDir\emotional-dashboard.ps1"
Write-Host ""

Write-Host "CONTINUOUS REFLECTION:" -ForegroundColor Cyan
Write-Host "  • Background check-ins: Run option 5 from quick launcher"
Write-Host "  • Or: $toolsDir\auto-emotional-checkin.ps1"
Write-Host ""

Write-Host "USAGE:" -ForegroundColor Yellow
Write-Host "  Simply use Claude normally."
Write-Host "  Review patterns weekly"
Write-Host ""
