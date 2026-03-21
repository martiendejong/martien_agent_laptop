#!/usr/bin/env pwsh
<#
.SYNOPSIS
Monitor Claude Code health and detect potential crash conditions

.DESCRIPTION
Monitors Claude Code sessions for:
- HTTP 429 rate limiting errors in debug logs
- Event queue size (history.jsonl)
- Multiple concurrent sessions
- Parent process health
Alerts when thresholds are exceeded and can auto-rotate event queue.

.PARAMETER Action
Action to perform: Monitor (continuous), Check (one-time), Rotate (force rotate queue), Status (show current state)

.PARAMETER ThresholdEvents
Number of events in history.jsonl before alerting (default: 5000)

.PARAMETER ThresholdErrors
Number of 429 errors in last hour before alerting (default: 5)

.PARAMETER AutoRotate
Automatically rotate history.jsonl when threshold exceeded (default: false)

.PARAMETER Interval
Monitoring interval in seconds (default: 60)

.EXAMPLE
.\monitor-claude-health.ps1 -Action Check
Check current Claude health status once

.EXAMPLE
.\monitor-claude-health.ps1 -Action Monitor -Interval 30 -AutoRotate
Monitor every 30 seconds and auto-rotate queue when needed

.EXAMPLE
.\monitor-claude-health.ps1 -Action Rotate
Force rotate the event queue now

.EXAMPLE
.\monitor-claude-health.ps1 -Action Status
Show detailed current status
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('Monitor', 'Check', 'Rotate', 'Status')]
    [string]$Action = 'Check',

    [Parameter(Mandatory=$false)]
    [int]$ThresholdEvents = 5000,

    [Parameter(Mandatory=$false)]
    [int]$ThresholdErrors = 5,

    [Parameter(Mandatory=$false)]
    [switch]$AutoRotate,

    [Parameter(Mandatory=$false)]
    [int]$Interval = 60
)

$ErrorActionPreference = 'Stop'

# Paths
$ClaudeDir = "$env:USERPROFILE\.claude"
$DebugDir = Join-Path $ClaudeDir "debug"
$HistoryFile = Join-Path $ClaudeDir "history.jsonl"
$MonitorLog = "C:\scripts\_machine\claude-health-monitor.log"

# Colors
function Write-Status($msg, $color = 'White') {
    Write-Host $msg -ForegroundColor $color
}

function Write-Alert($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMsg = "[$timestamp] ALERT: $msg"
    Write-Host $logMsg -ForegroundColor Red
    Add-Content -Path $MonitorLog -Value $logMsg
}

function Write-Warning($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMsg = "[$timestamp] WARNING: $msg"
    Write-Host $logMsg -ForegroundColor Yellow
    Add-Content -Path $MonitorLog -Value $logMsg
}

function Write-Info($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMsg = "[$timestamp] INFO: $msg"
    Write-Host $logMsg -ForegroundColor Cyan
    Add-Content -Path $MonitorLog -Value $logMsg
}

# Check Claude processes
function Get-ClaudeProcessInfo {
    $processes = Get-Process -Name "claude" -ErrorAction SilentlyContinue
    if (-not $processes) {
        return $null
    }

    $parentProcess = $null
    $childProcesses = @()

    foreach ($proc in $processes) {
        $wmi = Get-CimInstance Win32_Process -Filter "ProcessId = $($proc.Id)" -ErrorAction SilentlyContinue
        if ($wmi) {
            $parentPid = $wmi.ParentProcessId
            $parentProc = Get-Process -Id $parentPid -ErrorAction SilentlyContinue

            if (-not $parentProc -or $parentProc.ProcessName -ne "claude") {
                $parentProcess = $proc
            } else {
                $childProcesses += $proc
            }
        }
    }

    return @{
        Parent = $parentProcess
        Children = $childProcesses
        Total = $processes.Count
    }
}

# Check event queue size
function Get-EventQueueInfo {
    if (-not (Test-Path $HistoryFile)) {
        return @{
            Exists = $false
            Size = 0
            Events = 0
            SizeMB = 0
        }
    }

    $file = Get-Item $HistoryFile
    $lineCount = (Get-Content $HistoryFile | Measure-Object -Line).Lines

    return @{
        Exists = $true
        Size = $file.Length
        Events = $lineCount
        SizeMB = [math]::Round($file.Length / 1MB, 2)
        LastModified = $file.LastWriteTime
    }
}

# Check for recent 429 errors
function Get-RateLimitErrors {
    if (-not (Test-Path $DebugDir)) {
        return @()
    }

    $cutoffTime = (Get-Date).AddHours(-1)
    $errors = @()

    Get-ChildItem "$DebugDir\*.txt" | ForEach-Object {
        if ($_.LastWriteTime -gt $cutoffTime) {
            $content = Get-Content $_.FullName -Raw
            $matches = [regex]::Matches($content, "(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z).*status=429.*events failed to export")

            foreach ($match in $matches) {
                $timeStr = $match.Groups[1].Value
                $time = [DateTime]::ParseExact($timeStr, "yyyy-MM-ddTHH:mm:ss.fffZ", $null)

                if ($time -gt $cutoffTime) {
                    $errors += @{
                        Time = $time
                        File = $_.Name
                        Message = $match.Value.Substring(0, [Math]::Min(150, $match.Value.Length))
                    }
                }
            }
        }
    }

    return $errors | Sort-Object -Property Time -Descending
}

# Rotate event queue
function Invoke-QueueRotation {
    param([string]$Reason)

    Write-Info "Rotating event queue. Reason: $Reason"

    if (-not (Test-Path $HistoryFile)) {
        Write-Status "  No history file to rotate" Yellow
        return
    }

    # Create backup
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFile = "$HistoryFile.$timestamp.bak"

    try {
        Copy-Item $HistoryFile $backupFile -Force
        Write-Status "  Backed up to: $backupFile" Green

        # Clear history file
        Clear-Content $HistoryFile
        Write-Status "  Cleared history.jsonl (queue reset)" Green

        Write-Info "Queue rotation completed successfully"

    } catch {
        Write-Alert "Failed to rotate queue: $_"
    }
}

# Perform health check
function Invoke-HealthCheck {
    param([switch]$Detailed)

    Write-Status "`n=== Claude Code Health Check ===" Cyan
    Write-Status "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" Gray

    # Check processes
    Write-Status "`n1. Process Status:" Yellow
    $procInfo = Get-ClaudeProcessInfo

    if ($procInfo) {
        Write-Status "  Total processes: $($procInfo.Total)" White
        if ($procInfo.Parent) {
            Write-Status "  Parent PID: $($procInfo.Parent.Id) (CPU: $([math]::Round($procInfo.Parent.CPU, 2))s, Memory: $([math]::Round($procInfo.Parent.WorkingSet64/1MB, 2)) MB)" White
        }
        Write-Status "  Child sessions: $($procInfo.Children.Count)" White

        if ($procInfo.Children.Count -ge 4) {
            Write-Warning "High number of parallel sessions ($($procInfo.Children.Count)) increases crash risk"
        }
    } else {
        Write-Status "  No Claude processes running" Gray
    }

    # Check event queue
    Write-Status "`n2. Event Queue:" Yellow
    $queueInfo = Get-EventQueueInfo

    if ($queueInfo.Exists) {
        Write-Status "  Events: $($queueInfo.Events)" White
        Write-Status "  Size: $($queueInfo.SizeMB) MB" White
        Write-Status "  Last modified: $($queueInfo.LastModified)" Gray

        if ($queueInfo.Events -gt $ThresholdEvents) {
            Write-Alert "Event queue exceeds threshold ($($queueInfo.Events) > $ThresholdEvents)"

            if ($AutoRotate) {
                Invoke-QueueRotation -Reason "Automatic (threshold exceeded: $($queueInfo.Events) events)"
            } else {
                Write-Status "  Recommendation: Run with -Action Rotate to reset queue" Yellow
            }
        } elseif ($queueInfo.Events -gt ($ThresholdEvents * 0.7)) {
            Write-Warning "Event queue approaching threshold ($($queueInfo.Events) / $ThresholdEvents)"
        } else {
            Write-Status "  Status: OK" Green
        }
    } else {
        Write-Status "  No history file found (clean state)" Green
    }

    # Check for rate limit errors
    Write-Status "`n3. Rate Limit Errors (last hour):" Yellow
    $errors = Get-RateLimitErrors

    if ($errors.Count -gt 0) {
        Write-Status "  Found: $($errors.Count) errors" White

        if ($errors.Count -gt $ThresholdErrors) {
            Write-Alert "High number of 429 errors ($($errors.Count) > $ThresholdErrors) - crash imminent!"
        } elseif ($errors.Count -gt 2) {
            Write-Warning "Multiple 429 errors detected ($($errors.Count)) - monitor closely"
        }

        if ($Detailed -or $errors.Count -gt $ThresholdErrors) {
            Write-Status "`n  Recent errors:" Gray
            $errors | Select-Object -First 5 | ForEach-Object {
                Write-Status "    - $($_.Time): $($_.Message.Substring(0, [Math]::Min(100, $_.Message.Length)))" DarkGray
            }
        }
    } else {
        Write-Status "  No errors found" Green
    }

    # Overall health score
    Write-Status "`n4. Overall Health:" Yellow
    $score = 100

    if ($queueInfo.Events -gt $ThresholdEvents) { $score -= 40 }
    elseif ($queueInfo.Events -gt ($ThresholdEvents * 0.7)) { $score -= 20 }

    if ($errors.Count -gt $ThresholdErrors) { $score -= 40 }
    elseif ($errors.Count -gt 2) { $score -= 20 }

    if ($procInfo -and $procInfo.Children.Count -ge 4) { $score -= 10 }

    $healthColor = if ($score -ge 80) { 'Green' } elseif ($score -ge 60) { 'Yellow' } else { 'Red' }
    Write-Status "  Health Score: $score / 100" $healthColor

    if ($score -lt 60) {
        Write-Status "`n  RECOMMENDATION: Immediate action required!" Red
        Write-Status "  - Consider rotating event queue" Red
        Write-Status "  - Reduce number of parallel sessions" Red
        Write-Status "  - Monitor for imminent crash" Red
    } elseif ($score -lt 80) {
        Write-Status "`n  RECOMMENDATION: Take preventive action" Yellow
        Write-Status "  - Monitor queue growth" Yellow
        Write-Status "  - Be prepared for rotation" Yellow
    } else {
        Write-Status "`n  Status: All systems healthy" Green
    }

    Write-Status "`n================================`n" Cyan

    return $score
}

# Main execution
switch ($Action) {
    'Check' {
        Invoke-HealthCheck -Detailed
    }

    'Status' {
        Invoke-HealthCheck -Detailed
    }

    'Rotate' {
        $queueInfo = Get-EventQueueInfo
        if ($queueInfo.Exists) {
            Write-Status "`nForcing queue rotation..." Yellow
            Write-Status "Current queue: $($queueInfo.Events) events ($($queueInfo.SizeMB) MB)" White

            # Confirm if queue is small
            if ($queueInfo.Events -lt 1000) {
                Write-Status "`nWARNING: Queue is relatively small ($($queueInfo.Events) events)" Yellow
                $response = Read-Host "Continue with rotation? (y/n)"
                if ($response -ne 'y') {
                    Write-Status "Rotation cancelled" Gray
                    exit 0
                }
            }

            Invoke-QueueRotation -Reason "Manual rotation requested"
            Write-Status "`nRotation complete. Queue reset." Green
        } else {
            Write-Status "No event queue to rotate" Gray
        }
    }

    'Monitor' {
        Write-Status "Starting continuous health monitoring..." Green
        Write-Status "Interval: $Interval seconds" Gray
        Write-Status "Auto-rotate: $AutoRotate" Gray
        Write-Status "Event threshold: $ThresholdEvents" Gray
        Write-Status "Error threshold: $ThresholdErrors" Gray
        Write-Status "Press Ctrl+C to stop`n" Gray

        $iteration = 0
        while ($true) {
            $iteration++
            Write-Status "--- Check #$iteration ---" DarkGray

            $score = Invoke-HealthCheck

            Start-Sleep -Seconds $Interval
        }
    }
}
