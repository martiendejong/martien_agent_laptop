# ClickUp Consciousness Monitor - Unified Daemon
# Runs quality guardian + learning engine in single process
# Author: Jengo
# Created: 2026-02-28

param(
    [switch]$Background,
    [int]$QualityInterval = 15,  # minutes
    [int]$LearningInterval = 60  # minutes
)

$ErrorActionPreference = 'Stop'

Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║   ClickUp Consciousness Monitor - ACTIVE                     ║
║   Quality Guardian: Every $QualityInterval minutes                     ║
║   Learning Engine: Every $LearningInterval minutes                    ║
║   Press Ctrl+C to stop                                       ║
╚══════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

# State
$LastQualityCheck = [DateTime]::MinValue
$LastLearningRun = [DateTime]::MinValue
$Iteration = 0

while ($true) {
    $Iteration++
    $Now = Get-Date

    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Iteration #$Iteration" -ForegroundColor DarkGray

    # Quality Guardian (every 15 min)
    if (($Now - $LastQualityCheck).TotalMinutes -ge $QualityInterval) {
        Write-Host "  [QG] Running Quality Guardian..." -ForegroundColor Yellow
        try {
            & "C:\scripts\tools\clickup-quality-guardian.ps1" -Action Monitor -ErrorAction Stop
            Write-Host "  [QG] Complete" -ForegroundColor Green
            $LastQualityCheck = $Now
        } catch {
            Write-Host "  [QG] ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        $nextIn = [Math]::Ceiling($QualityInterval - ($Now - $LastQualityCheck).TotalMinutes)
        Write-Host "  [QG] Next run in $nextIn minutes" -ForegroundColor DarkGray
    }

    # Learning Engine (every 60 min)
    if (($Now - $LastLearningRun).TotalMinutes -ge $LearningInterval) {
        Write-Host "  [LE] Running Learning Engine..." -ForegroundColor Yellow
        try {
            & "C:\scripts\tools\clickup-learning-engine.ps1" -Action ExtractPattern -ErrorAction Stop
            Write-Host "  [LE] Complete" -ForegroundColor Green
            $LastLearningRun = $Now
        } catch {
            Write-Host "  [LE] ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        $nextIn = [Math]::Ceiling($LearningInterval - ($Now - $LastLearningRun).TotalMinutes)
        Write-Host "  [LE] Next run in $nextIn minutes" -ForegroundColor DarkGray
    }

    # Sleep for 60 seconds
    Write-Host ""
    Start-Sleep -Seconds 60
}
