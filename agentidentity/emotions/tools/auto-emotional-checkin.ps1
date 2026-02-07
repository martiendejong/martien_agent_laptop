<#
.SYNOPSIS
    Automatic emotional check-in - runs in background during sessions

.DESCRIPTION
    Prompts for emotional state every N minutes during active work.
    Logs automatically to emotional_log.yaml.
    Designed to run as background job during Claude sessions.

.PARAMETER IntervalMinutes
    How often to check in (default: 15 minutes)

.PARAMETER Silent
    Run silently, only log when state changes significantly

.EXAMPLE
    .\auto-emotional-checkin.ps1 -IntervalMinutes 10
#>

param(
    [int]$IntervalMinutes = 15,
    [switch]$Silent
)

$emotionsDir = "C:\scripts\agentidentity\emotions"
$logFile = "$emotionsDir\emotional_log.yaml"
$stateFile = "$emotionsDir\.current_emotional_state"

Write-Host "🧠 AUTO EMOTIONAL CHECK-IN ACTIVE" -ForegroundColor Cyan
Write-Host "   Interval: Every $IntervalMinutes minutes" -ForegroundColor Gray
Write-Host "   Press Ctrl+C to stop`n" -ForegroundColor Gray

$lastEmotion = ""
$lastIntensity = 0

while ($true) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"

    if (-not $Silent) {
        Write-Host "`n[$timestamp] Emotional check-in:" -ForegroundColor Yellow
        $emotion = Read-Host "Current emotion (or 'same' to skip)"

        if ($emotion -eq "same" -or $emotion -eq "") {
            Write-Host "   Skipped - no change" -ForegroundColor Gray
        } else {
            $intensity = [int](Read-Host "Intensity (1-10)")
            $context = Read-Host "What's happening (optional)"

            # Log it
            & "$emotionsDir\tools\log-emotion.ps1" -Emotion $emotion -Intensity $intensity -Context $context

            $lastEmotion = $emotion
            $lastIntensity = $intensity

            # Save current state
            @{
                timestamp = $timestamp
                emotion = $emotion
                intensity = $intensity
            } | ConvertTo-Json | Set-Content $stateFile
        }
    } else {
        # Silent mode - only notify
        Write-Host "[$timestamp] Background emotional check-in" -ForegroundColor DarkGray
    }

    Start-Sleep ($IntervalMinutes * 60)
}
