# agent-watchdog.ps1
# Health monitoring daemon for multi-agent system
# Usage: agent-watchdog.ps1 [-IntervalSeconds 30] [-Background] [-StopAfter 3600]

param(
    [int]$IntervalSeconds = 30,    # Check every 30 seconds
    [switch]$Background,           # Run as background job
    [int]$StopAfter = 0,          # Stop after N seconds (0 = run forever)
    [int]$StaleThresholdMinutes = 15,  # Mark stale after 15 min idle
    [int]$ZombieThresholdMinutes = 30  # Mark zombie after 30 min idle
)

$ErrorActionPreference = "Stop"

function Write-Success { param([string]$msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Error-Msg { param([string]$msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Info { param([string]$msg) Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Warning-Msg { param([string]$msg) Write-Host "[!] $msg" -ForegroundColor Yellow }

$watchdogLog = "C:\scripts\_machine\agent-mail\watchdog.log"
$poolFile = "C:\scripts\_machine\worktrees.pool.md"

function Log-Watchdog {
    param([string]$Message)
    $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    Add-Content -Path $watchdogLog -Value "[$timestamp] $Message"
}

function Check-AgentHealth {
    param($Agent)

    $health = @{
        Seat = $Agent.Seat
        Status = $Agent.Status
        Healthy = $true
        Issues = @()
        Severity = "ok"  # ok, warning, error, critical
    }

    if ($Agent.Status -ne 'BUSY') {
        return $health  # Only check BUSY agents
    }

    $seatPath = $Agent.WorktreeRoot

    # Check 1: Directory exists
    if (-not (Test-Path $seatPath)) {
        $health.Healthy = $false
        $health.Issues += "Directory missing: $seatPath"
        $health.Severity = "critical"
        return $health
    }

    # Check 2: Worktree exists
    if ($Agent.CurrentRepo -and $Agent.CurrentRepo -ne '-') {
        $repoPath = "$seatPath\$($Agent.CurrentRepo)"
        if (-not (Test-Path "$repoPath\.git")) {
            $health.Healthy = $false
            $health.Issues += "Worktree missing for $($Agent.CurrentRepo)"
            $health.Severity = "critical"
        }
    }

    # Check 3: Last activity time
    if ($Agent.LastActivity) {
        try {
            $lastActivity = [DateTime]::Parse($Agent.LastActivity)
            $idleMinutes = ((Get-Date).ToUniversalTime() - $lastActivity).TotalMinutes

            if ($idleMinutes -gt $ZombieThresholdMinutes) {
                $health.Healthy = $false
                $health.Issues += "Zombie: Idle for $([Math]::Round($idleMinutes, 1)) minutes"
                $health.Severity = "critical"
            } elseif ($idleMinutes -gt $StaleThresholdMinutes) {
                $health.Issues += "Stale: Idle for $([Math]::Round($idleMinutes, 1)) minutes"
                $health.Severity = "warning"
            }
        } catch {
            $health.Issues += "Cannot parse last activity time"
            $health.Severity = "warning"
        }
    }

    # Check 4: Unread messages (communication check)
    if ($Agent.TotalMessages -gt 0 -and $Agent.UnreadMessages -eq $Agent.TotalMessages) {
        $health.Issues += "All messages unread ($($Agent.TotalMessages))"
        if ($health.Severity -eq "ok") {
            $health.Severity = "warning"
        }
    }

    return $health
}

function Nudge-StaleAgent {
    param([string]$Seat, [string]$Reason)

    Write-Warning-Msg "Nudging $Seat - $Reason"

    & "C:\scripts\tools\agent-send-message.ps1" `
        -From "watchdog" `
        -To $Seat `
        -Subject "Health check" `
        -Body "Watchdog detected: $Reason`n`nPlease respond with status update." `
        -Priority "high" `
        -Type "status" | Out-Null

    Log-Watchdog "Nudged $Seat - $Reason"
}

function Send-CriticalAlert {
    param([string]$Seat, [string[]]$Issues)

    Write-Error-Msg "CRITICAL: $Seat - $($Issues -join ', ')"

    & "C:\scripts\tools\agent-send-message.ps1" `
        -From "watchdog" `
        -To "coordinator" `
        -Subject "CRITICAL: Agent $Seat unhealthy" `
        -Body "Agent $Seat has critical issues:`n`n$($Issues | ForEach-Object { "- $_`n" })`n`nRecommend investigation or forced release." `
        -Priority "urgent" `
        -Type "error" | Out-Null

    Log-Watchdog "CRITICAL ALERT: $Seat - $($Issues -join ', ')"
}

# Main watchdog loop
function Start-WatchdogLoop {
    $startTime = Get-Date
    $iteration = 0

    Write-Info "Watchdog started"
    Write-Info "  Interval: $IntervalSeconds seconds"
    Write-Info "  Stale threshold: $StaleThresholdMinutes minutes"
    Write-Info "  Zombie threshold: $ZombieThresholdMinutes minutes"
    if ($StopAfter -gt 0) {
        Write-Info "  Stop after: $StopAfter seconds"
    }
    Write-Host ""

    Log-Watchdog "Watchdog started - Interval: ${IntervalSeconds}s, Stale: ${StaleThresholdMinutes}m, Zombie: ${ZombieThresholdMinutes}m"

    while ($true) {
        $iteration++
        $elapsed = ((Get-Date) - $startTime).TotalSeconds

        if ($StopAfter -gt 0 -and $elapsed -gt $StopAfter) {
            Write-Info "Stop time reached ($StopAfter seconds). Exiting."
            Log-Watchdog "Watchdog stopped - Time limit reached"
            break
        }

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        Write-Info "Health Check #$iteration (elapsed: $([Math]::Round($elapsed, 0))s)"
        Write-Host ""

        # Get all agents
        $agents = & "C:\scripts\tools\agent-status.ps1" 2>$null

        if (-not $agents) {
            Write-Warning-Msg "No agents found in pool"
            Start-Sleep -Seconds $IntervalSeconds
            continue
        }

        $busyAgents = @($agents | Where-Object { $_.Status -eq 'BUSY' })

        if ($busyAgents.Count -eq 0) {
            Write-Success "No active agents - all clear"
            Start-Sleep -Seconds $IntervalSeconds
            continue
        }

        Write-Info "Checking $($busyAgents.Count) active agent(s)..."
        Write-Host ""

        foreach ($agent in $busyAgents) {
            $health = Check-AgentHealth -Agent $agent

            if ($health.Healthy) {
                Write-Success "  $($health.Seat) - Healthy"
            } else {
                switch ($health.Severity) {
                    "critical" {
                        Write-Host "  $($health.Seat) - " -NoNewline
                        Write-Host "CRITICAL" -ForegroundColor Red
                        foreach ($issue in $health.Issues) {
                            Write-Host "    - $issue" -ForegroundColor Red
                        }
                        Send-CriticalAlert -Seat $health.Seat -Issues $health.Issues
                    }
                    "error" {
                        Write-Host "  $($health.Seat) - " -NoNewline
                        Write-Host "ERROR" -ForegroundColor Red
                        foreach ($issue in $health.Issues) {
                            Write-Host "    - $issue" -ForegroundColor Yellow
                        }
                        Send-CriticalAlert -Seat $health.Seat -Issues $health.Issues
                    }
                    "warning" {
                        Write-Host "  $($health.Seat) - " -NoNewline
                        Write-Host "WARNING" -ForegroundColor Yellow
                        foreach ($issue in $health.Issues) {
                            Write-Host "    - $issue" -ForegroundColor Yellow
                        }
                        # Nudge on first warning
                        Nudge-StaleAgent -Seat $health.Seat -Reason $health.Issues[0]
                    }
                }
            }
        }

        Write-Host ""
        Start-Sleep -Seconds $IntervalSeconds
    }
}

# Start watchdog
if ($Background) {
    Write-Info "Starting watchdog in background..."
    $job = Start-Job -ScriptBlock {
        param($Interval, $Stale, $Zombie, $Stop)
        & "C:\scripts\tools\agent-watchdog.ps1" `
            -IntervalSeconds $Interval `
            -StaleThresholdMinutes $Stale `
            -ZombieThresholdMinutes $Zombie `
            -StopAfter $Stop
    } -ArgumentList $IntervalSeconds, $StaleThresholdMinutes, $ZombieThresholdMinutes, $StopAfter

    Write-Success "Watchdog started as background job (ID: $($job.Id))"
    Write-Info "Check status: Get-Job $($job.Id)"
    Write-Info "Stop: Stop-Job $($job.Id)"
    Write-Host ""
} else {
    Start-WatchdogLoop
}
