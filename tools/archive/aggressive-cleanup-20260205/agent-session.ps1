<#
.SYNOPSIS
    Agent session manager with automatic tracking

.DESCRIPTION
    Manages agent sessions with automatic:
    - Session start/end tracking
    - Heartbeat monitoring
    - Resource cleanup on exit
    - Error tracking
    - Performance metrics

.PARAMETER Action
    start, heartbeat, end, status

.EXAMPLE
    .\agent-session.ps1 -Action start
    Start a new session

.EXAMPLE
    .\agent-session.ps1 -Action heartbeat
    Update session heartbeat

.EXAMPLE
    .\agent-session.ps1 -Action end -ExitReason "normal"
    End current session
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('start', 'heartbeat', 'end', 'status')]
    [string]$Action = 'start',

    [Parameter(Mandatory=$false)]
    [string]$ExitReason = 'normal',

    [Parameter(Mandatory=$false)]
    [string]$Metadata = '{}'
)

$ErrorActionPreference = 'Stop'

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"
$AgentIdFile = "C:\scripts\_machine\.current_agent_id"
$SessionIdFile = "C:\scripts\_machine\.current_session_id"

function Get-AgentId {
    if (Test-Path $AgentIdFile) {
        return (Get-Content $AgentIdFile -Raw).Trim()
    }
    return $null
}

function Get-SessionId {
    if (Test-Path $SessionIdFile) {
        return (Get-Content $SessionIdFile -Raw).Trim()
    }
    return $null
}

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

function Start-AgentSession {
    # Register agent first
    & "C:\scripts\tools\agent-logger.ps1" -Action register | Out-Null

    $agentId = Get-AgentId
    if (-not $agentId) {
        throw "Failed to register agent"
    }

    # Create session ID
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $random = Get-Random -Minimum 1000 -Maximum 9999
    $sessionId = "session-$timestamp-$random"

    # Save session ID
    $sessionId | Out-File -FilePath $SessionIdFile -Encoding UTF8 -NoNewline

    # Create session record
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    $Metadata = $Metadata -replace "'", "''"

    Invoke-Sql @"
INSERT INTO sessions (session_id, agent_id, started_at, metadata)
VALUES ('$sessionId', '$agentId', '$now', '$Metadata');
"@

    # Log session start
    & "C:\scripts\tools\agent-logger.ps1" -Action log -Message "Session started: $sessionId"

    Write-Host "`nSession started successfully!" -ForegroundColor Green
    Write-Host "  Agent ID:   $agentId" -ForegroundColor Cyan
    Write-Host "  Session ID: $sessionId" -ForegroundColor Cyan
    Write-Host ""

    return $sessionId
}

function Update-SessionHeartbeat {
    $sessionId = Get-SessionId
    if (-not $sessionId) {
        Write-Host "No active session. Run with -Action start first." -ForegroundColor Yellow
        return
    }

    # Update agent heartbeat
    & "C:\scripts\tools\agent-logger.ps1" -Action heartbeat | Out-Null

    Write-Host "Session heartbeat updated: $sessionId" -ForegroundColor Green
}

function Stop-AgentSession {
    param([string]$ExitReason)

    $sessionId = Get-SessionId
    $agentId = Get-AgentId

    if (-not $sessionId) {
        Write-Host "No active session to end." -ForegroundColor Yellow
        return
    }

    # Get session start time
    $startTime = Invoke-Sql "SELECT started_at FROM sessions WHERE session_id='$sessionId';"

    if ($startTime) {
        # Calculate duration
        $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        $duration = Invoke-Sql @"
SELECT CAST((julianday('$now') - julianday('$startTime')) * 24 * 60 * 60 AS INTEGER);
"@

        # Get task stats
        $tasksCompleted = Invoke-Sql @"
SELECT COUNT(*) FROM tasks
WHERE assigned_to='$agentId' AND status='completed'
AND datetime(completed_at) >= datetime('$startTime');
"@

        $tasksFailed = Invoke-Sql @"
SELECT COUNT(*) FROM tasks
WHERE assigned_to='$agentId' AND status='blocked'
AND datetime(created_at) >= datetime('$startTime');
"@

        # Update session
        Invoke-Sql @"
UPDATE sessions
SET ended_at='$now',
    duration_seconds=$duration,
    tasks_completed=$tasksCompleted,
    tasks_failed=$tasksFailed,
    exit_reason='$ExitReason'
WHERE session_id='$sessionId';
"@

        # Log session end
        & "C:\scripts\tools\agent-logger.ps1" -Action log -Message "Session ended: $sessionId ($ExitReason)"

        Write-Host "`nSession ended successfully!" -ForegroundColor Green
        Write-Host "  Session ID: $sessionId" -ForegroundColor Cyan
        Write-Host "  Duration: $duration seconds" -ForegroundColor Cyan
        Write-Host "  Tasks completed: $tasksCompleted" -ForegroundColor Green
        Write-Host "  Tasks failed: $tasksFailed" -ForegroundColor $(if ([int]$tasksFailed -gt 0) { 'Red' } else { 'Gray' })
        Write-Host ""

        # Clean up session ID file
        if (Test-Path $SessionIdFile) {
            Remove-Item $SessionIdFile
        }
    }
}

function Show-SessionStatus {
    $sessionId = Get-SessionId
    $agentId = Get-AgentId

    if (-not $sessionId) {
        Write-Host "No active session." -ForegroundColor Yellow
        return
    }

    $session = Invoke-Sql @"
SELECT
    session_id,
    agent_id,
    datetime(started_at) as started,
    CAST((julianday('now') - julianday(started_at)) * 24 * 60 * 60 AS INTEGER) as duration_sec
FROM sessions
WHERE session_id='$sessionId';
"@

    if ($session) {
        $parts = $session -split '\|'
        $durationMin = [math]::Round([int]$parts[3] / 60, 1)

        Write-Host "`nCurrent Session Status:" -ForegroundColor Cyan
        Write-Host "  Session ID: $($parts[0])" -ForegroundColor White
        Write-Host "  Agent ID:   $($parts[1])" -ForegroundColor White
        Write-Host "  Started:    $($parts[2])" -ForegroundColor White
        Write-Host "  Duration:   $durationMin minutes" -ForegroundColor White

        # Get current activity
        $currentTask = Invoke-Sql "SELECT current_task FROM agents WHERE agent_id='$agentId';"
        if ($currentTask) {
            Write-Host "  Current Task: $currentTask" -ForegroundColor Yellow
        }

        # Get worktree
        $worktreeSeat = Invoke-Sql "SELECT worktree_seat FROM agents WHERE agent_id='$agentId';"
        if ($worktreeSeat) {
            Write-Host "  Worktree: $worktreeSeat" -ForegroundColor Cyan
        }

        Write-Host ""
    }
}

# Main execution
try {
    switch ($Action) {
        'start' {
            Start-AgentSession
        }

        'heartbeat' {
            Update-SessionHeartbeat
        }

        'end' {
            Stop-AgentSession -ExitReason $ExitReason
        }

        'status' {
            Show-SessionStatus
        }
    }

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
