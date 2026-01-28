<#
.SYNOPSIS
    Tracks Claude Code session starts and clean exits.

.DESCRIPTION
    Maintains a registry of sessions that exited cleanly.
    Sessions not in this registry after the last clean exit are considered crashed.

.PARAMETER Action
    start - Record session start (call before starting Claude)
    end - Record clean exit (call after Claude exits normally)
    status - Show current tracking status
    baseline - Mark current time as baseline (all prior sessions ignored)

.EXAMPLE
    .\session-tracker.ps1 -Action start
    .\session-tracker.ps1 -Action end
    .\session-tracker.ps1 -Action status
    .\session-tracker.ps1 -Action baseline
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "end", "status", "baseline")]
    [string]$Action,

    [string]$Project = "C--scripts"
)

$ErrorActionPreference = "Stop"

# Configuration
$TrackerFile = "C:\scripts\_machine\session-tracker.json"
$ClaudeProjectsPath = "C:\Users\HP\.claude\projects"

function Initialize-Tracker {
    if (-not (Test-Path $TrackerFile)) {
        $tracker = @{
            clean_exits = @()
            last_start_time = $null
            last_clean_exit_time = $null
            last_clean_exit_session = $null
        }
        $tracker | ConvertTo-Json -Depth 10 | Out-File $TrackerFile -Encoding UTF8
    }
    return Get-Content $TrackerFile -Raw | ConvertFrom-Json
}

function Save-Tracker {
    param($Tracker)
    $Tracker | ConvertTo-Json -Depth 10 | Out-File $TrackerFile -Encoding UTF8
}

function Get-LatestSession {
    param([string]$AfterTime)

    $projectPath = Join-Path $ClaudeProjectsPath $Project
    if (-not (Test-Path $projectPath)) {
        return $null
    }

    $cutoff = if ($AfterTime) { [DateTime]::Parse($AfterTime) } else { (Get-Date).AddHours(-1) }

    $latestSession = Get-ChildItem -Path $projectPath -Filter "*.jsonl" -File |
        Where-Object { $_.LastWriteTime -gt $cutoff } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    return $latestSession
}

switch ($Action) {
    "start" {
        $tracker = Initialize-Tracker
        $tracker.last_start_time = (Get-Date).ToString("o")
        Save-Tracker $tracker

        Write-Host "[SESSION TRACKER] Session start recorded at $($tracker.last_start_time)" -ForegroundColor Cyan
    }

    "end" {
        $tracker = Initialize-Tracker

        if (-not $tracker.last_start_time) {
            Write-Host "[SESSION TRACKER] Warning: No start time recorded. Recording exit anyway." -ForegroundColor Yellow
            $tracker.last_start_time = (Get-Date).AddHours(-2).ToString("o")
        }

        # Find the session that was active since start
        $latestSession = Get-LatestSession -AfterTime $tracker.last_start_time

        if ($latestSession) {
            $sessionId = [System.IO.Path]::GetFileNameWithoutExtension($latestSession.Name)
            $exitTime = (Get-Date).ToString("o")

            # Add to clean exits list
            $exitRecord = @{
                session_id = $sessionId
                timestamp = $exitTime
                project = $Project
                file_path = $latestSession.FullName
                size_kb = [math]::Round($latestSession.Length / 1KB, 1)
            }

            # Convert to array if needed and add
            if ($tracker.clean_exits -is [System.Array]) {
                $tracker.clean_exits = @($tracker.clean_exits) + $exitRecord
            } else {
                $tracker.clean_exits = @($exitRecord)
            }

            # Keep only last 100 clean exits
            if ($tracker.clean_exits.Count -gt 100) {
                $tracker.clean_exits = $tracker.clean_exits | Select-Object -Last 100
            }

            $tracker.last_clean_exit_time = $exitTime
            $tracker.last_clean_exit_session = $sessionId

            Save-Tracker $tracker

            Write-Host "[SESSION TRACKER] Clean exit recorded!" -ForegroundColor Green
            Write-Host "  Session: $($sessionId.Substring(0,8))..."
            Write-Host "  Time: $exitTime"
            Write-Host "  Size: $($exitRecord.size_kb) KB"
        } else {
            Write-Host "[SESSION TRACKER] Warning: Could not find session file to mark as clean exit" -ForegroundColor Yellow
        }
    }

    "status" {
        $tracker = Initialize-Tracker

        Write-Host "`n=== Session Tracker Status ===" -ForegroundColor Cyan
        Write-Host "Tracker file: $TrackerFile"
        Write-Host "Last start: $($tracker.last_start_time)"
        Write-Host "Last clean exit: $($tracker.last_clean_exit_time)"
        Write-Host "Last clean session: $($tracker.last_clean_exit_session)"
        Write-Host "Total clean exits tracked: $($tracker.clean_exits.Count)"

        if ($tracker.clean_exits.Count -gt 0) {
            Write-Host "`nRecent clean exits:"
            $tracker.clean_exits | Select-Object -Last 5 | ForEach-Object {
                $shortId = if ($_.session_id.Length -gt 8) { $_.session_id.Substring(0,8) + "..." } else { $_.session_id }
                Write-Host "  $($_.timestamp) | $shortId | $($_.size_kb) KB"
            }
        }
    }

    "baseline" {
        $tracker = Initialize-Tracker
        $baselineTime = (Get-Date).ToString("o")

        # Mark current time as baseline - all sessions before this are considered "known"
        $tracker.last_clean_exit_time = $baselineTime
        $tracker.last_clean_exit_session = "BASELINE"

        # Add baseline_set property if it doesn't exist
        if (-not ($tracker | Get-Member -Name "baseline_set" -MemberType NoteProperty)) {
            $tracker | Add-Member -NotePropertyName "baseline_set" -NotePropertyValue $baselineTime
        } else {
            $tracker.baseline_set = $baselineTime
        }

        Save-Tracker $tracker

        Write-Host ""
        Write-Host "[SESSION TRACKER] Baseline established!" -ForegroundColor Green
        Write-Host ""
        Write-Host "  Time: $baselineTime" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  All sessions BEFORE this time are now ignored."
        Write-Host "  Only sessions AFTER this time without a clean exit marker"
        Write-Host "  will be considered 'crashed'."
        Write-Host ""
        Write-Host "  From now on, use claude_agent.bat to start Claude Code."
        Write-Host "  Sessions that exit normally will be marked as 'clean'."
        Write-Host "  Sessions that crash will be detectable."
        Write-Host ""
    }
}
