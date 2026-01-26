<#
.SYNOPSIS
    Agent coordination helper - messages, locks, conflicts

.DESCRIPTION
    Tools for multi-agent coordination:
    - Send messages to other agents
    - Check messages for current agent
    - Detect conflicts
    - View agent status
    - Emergency cleanup

.PARAMETER Action
    send_message, check_messages, detect_conflicts, view_agents, cleanup_locks

.PARAMETER ToAgent
    Target agent ID (or NULL for broadcast)

.PARAMETER Message
    Message text

.PARAMETER Priority
    Message priority (1-10, default 5)

.EXAMPLE
    .\agent-coordinate.ps1 -Action send_message -Message "Starting work on AuthService.ts" -Priority 7

.EXAMPLE
    .\agent-coordinate.ps1 -Action check_messages

.EXAMPLE
    .\agent-coordinate.ps1 -Action detect_conflicts

.EXAMPLE
    .\agent-coordinate.ps1 -Action cleanup_locks
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('send_message', 'check_messages', 'detect_conflicts', 'view_agents', 'cleanup_locks', 'broadcast')]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$ToAgent = '',

    [Parameter(Mandatory=$false)]
    [string]$Message = '',

    [Parameter(Mandatory=$false)]
    [int]$Priority = 5,

    [Parameter(Mandatory=$false)]
    [ValidateSet('info', 'warning', 'error', 'request')]
    [string]$MessageType = 'info'
)

$ErrorActionPreference = 'Stop'

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Get-AgentId {
    if (Test-Path "C:\scripts\_machine\.current_agent_id") {
        return (Get-Content "C:\scripts\_machine\.current_agent_id" -Raw).Trim()
    }
    return $null
}

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

function Send-AgentMessage {
    param(
        [string]$ToAgent,
        [string]$Message,
        [int]$Priority,
        [string]$MessageType
    )

    $fromAgent = Get-AgentId
    if (-not $fromAgent) {
        throw "Agent not registered. Run agent-session.ps1 -Action start first."
    }

    if (-not $Message) {
        throw "Message text required"
    }

    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    $Message = $Message -replace "'", "''"

    $toAgentSql = if ($ToAgent) { "'$ToAgent'" } else { "NULL" }

    $sql = @"
INSERT INTO agent_messages (from_agent_id, to_agent_id, message, timestamp, priority, message_type)
VALUES ('$fromAgent', $toAgentSql, '$Message', '$now', $Priority, '$MessageType');
"@

    Invoke-Sql -Sql $sql

    if ($ToAgent) {
        Write-Host "Message sent to $ToAgent (Priority: $Priority)" -ForegroundColor Green
    } else {
        Write-Host "Broadcast message sent to ALL agents (Priority: $Priority)" -ForegroundColor Green
    }
}

function Check-AgentMessages {
    $agentId = Get-AgentId
    if (-not $agentId) {
        throw "Agent not registered"
    }

    # Get unread messages for this agent (including broadcasts)
    $sql = @"
SELECT
    id,
    from_agent_id,
    message,
    datetime(timestamp) as time,
    priority,
    message_type
FROM agent_messages
WHERE (to_agent_id='$agentId' OR to_agent_id IS NULL)
AND read=0
ORDER BY priority DESC, timestamp DESC;
"@

    $messages = Invoke-Sql -Sql $sql

    if ($messages) {
        Write-Host "`nUnread Messages:" -ForegroundColor Cyan
        Write-Host "================`n" -ForegroundColor Cyan

        $messages -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $id = $parts[0]
                $from = $parts[1]
                $msg = $parts[2]
                $time = $parts[3]
                $priority = $parts[4]
                $type = $parts[5]

                $typeIcon = switch ($type) {
                    'info' { '' }
                    'warning' { '' }
                    'error' { '' }
                    'request' { '' }
                    default { '' }
                }

                $priorityColor = if ([int]$priority -ge 8) { 'Red' } elseif ([int]$priority -ge 6) { 'Yellow' } else { 'White' }

                Write-Host "  [$typeIcon P$priority] " -NoNewline -ForegroundColor $priorityColor
                Write-Host "From: $from" -ForegroundColor Gray
                Write-Host "    $msg" -ForegroundColor White
                Write-Host "    $time" -ForegroundColor DarkGray
                Write-Host ""

                # Mark as read
                Invoke-Sql "UPDATE agent_messages SET read=1 WHERE id=$id;" | Out-Null
            }
        }

        Write-Host "All messages marked as read.`n" -ForegroundColor Gray

    } else {
        Write-Host "`nNo unread messages.`n" -ForegroundColor Gray
    }
}

function Detect-Conflicts {
    Write-Host "`nConflict Detection Report" -ForegroundColor Cyan
    Write-Host "========================`n" -ForegroundColor Cyan

    $conflictsFound = $false

    # Check for worktree conflicts
    $sql = @"
SELECT seat, GROUP_CONCAT(agent_id, ', ') as agents
FROM worktree_allocations
WHERE status='active'
GROUP BY seat
HAVING COUNT(*) > 1;
"@

    $worktreeConflicts = Invoke-Sql -Sql $sql

    if ($worktreeConflicts) {
        $conflictsFound = $true
        Write-Host "WORKTREE CONFLICTS:" -ForegroundColor Red
        $worktreeConflicts -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                Write-Host "  Seat $($parts[0]): Multiple agents -> $($parts[1])" -ForegroundColor Red
            }
        }
        Write-Host ""
    }

    # Check for resource lock conflicts (same resource locked multiple times)
    $sql = @"
SELECT resource_path, GROUP_CONCAT(agent_id, ', ') as agents
FROM resource_locks
WHERE status='locked'
GROUP BY resource_type, resource_path
HAVING COUNT(*) > 1;
"@

    $lockConflicts = Invoke-Sql -Sql $sql

    if ($lockConflicts) {
        $conflictsFound = $true
        Write-Host "RESOURCE LOCK CONFLICTS:" -ForegroundColor Red
        $lockConflicts -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                Write-Host "  Resource $($parts[0]): Multiple locks -> $($parts[1])" -ForegroundColor Red
            }
        }
        Write-Host ""
    }

    # Check for file edit conflicts (multiple agents editing same file recently)
    $sql = @"
SELECT
    file_path,
    GROUP_CONCAT(agent_id, ', ') as agents,
    COUNT(DISTINCT agent_id) as agent_count
FROM file_modifications
WHERE datetime(timestamp) > datetime('now', '-1 hour')
AND operation IN ('write', 'edit')
GROUP BY file_path
HAVING COUNT(DISTINCT agent_id) > 1;
"@

    $fileConflicts = Invoke-Sql -Sql $sql

    if ($fileConflicts) {
        $conflictsFound = $true
        Write-Host "FILE EDIT CONFLICTS (last hour):" -ForegroundColor Yellow
        $fileConflicts -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                Write-Host "  File: $($parts[0])" -ForegroundColor Yellow
                Write-Host "    Agents: $($parts[1])" -ForegroundColor Yellow
            }
        }
        Write-Host ""
    }

    # Check for stale locks (locked >1 hour by terminated agent)
    $sql = @"
SELECT
    resource_type,
    resource_path,
    r.agent_id,
    datetime(locked_at) as locked,
    CAST((julianday('now') - julianday(locked_at)) * 24 * 60 AS INTEGER) as age_min
FROM resource_locks r
JOIN agents a ON a.agent_id = r.agent_id
WHERE r.status='locked'
AND a.status='terminated'
AND datetime(locked_at) < datetime('now', '-1 hour');
"@

    $staleLocks = Invoke-Sql -Sql $sql

    if ($staleLocks) {
        $conflictsFound = $true
        Write-Host "STALE LOCKS (terminated agents):" -ForegroundColor Yellow
        $staleLocks -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                Write-Host "  $($parts[0]): $($parts[1]) (Agent: $($parts[2]), Age: $($parts[4])min)" -ForegroundColor Yellow
            }
        }
        Write-Host ""
    }

    if (-not $conflictsFound) {
        Write-Host "No conflicts detected. All systems nominal!`n" -ForegroundColor Green
    }
}

function View-ActiveAgents {
    Write-Host "`nActive Agents" -ForegroundColor Cyan
    Write-Host "=============`n" -ForegroundColor Cyan

    $sql = @"
SELECT
    a.agent_id,
    a.status,
    COALESCE(a.current_task, '(idle)') as task,
    COALESCE(a.worktree_seat, '-') as seat,
    CAST((julianday('now') - julianday(a.last_heartbeat)) * 24 * 60 AS INTEGER) as idle_min,
    (SELECT COUNT(*) FROM tasks WHERE assigned_to=a.agent_id AND status='in_progress') as active_tasks
FROM agents a
WHERE a.status='active' AND datetime(a.last_heartbeat) > datetime('now', '-10 minutes')
ORDER BY a.last_heartbeat DESC;
"@

    $agents = Invoke-Sql -Sql $sql

    if ($agents) {
        $agents -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $agentId = $parts[0]
                $status = $parts[1]
                $task = $parts[2]
                $seat = $parts[3]
                $idleMin = $parts[4]
                $activeTasks = $parts[5]

                $statusIcon = if ($status -eq 'active') { '' } else { '' }
                $idleColor = if ([int]$idleMin -lt 2) { 'Green' } elseif ([int]$idleMin -lt 5) { 'Yellow' } else { 'Red' }

                Write-Host "  $statusIcon $agentId" -ForegroundColor Cyan
                Write-Host "    Seat: $seat | Task: $task | Active Tasks: $activeTasks" -ForegroundColor White
                Write-Host "    Last seen: ${idleMin}min ago" -ForegroundColor $idleColor
                Write-Host ""
            }
        }
    } else {
        Write-Host "  No active agents`n" -ForegroundColor Gray
    }
}

function Cleanup-StaleLocks {
    Write-Host "`nCleaning up stale locks..." -ForegroundColor Yellow

    # Release locks from terminated agents
    $sql = @"
UPDATE resource_locks
SET status='released', released_at=datetime('now')
WHERE status='locked'
AND agent_id IN (SELECT agent_id FROM agents WHERE status='terminated');
"@

    Invoke-Sql -Sql $sql

    # Release locks older than 2 hours
    $sql = @"
UPDATE resource_locks
SET status='released', released_at=datetime('now')
WHERE status='locked'
AND datetime(locked_at) < datetime('now', '-2 hours');
"@

    Invoke-Sql -Sql $sql

    Write-Host "Stale locks cleaned up successfully.`n" -ForegroundColor Green
}

# Main execution
try {
    switch ($Action) {
        'send_message' {
            Send-AgentMessage -ToAgent $ToAgent -Message $Message -Priority $Priority -MessageType $MessageType
        }

        'broadcast' {
            Send-AgentMessage -ToAgent '' -Message $Message -Priority $Priority -MessageType $MessageType
        }

        'check_messages' {
            Check-AgentMessages
        }

        'detect_conflicts' {
            Detect-Conflicts
        }

        'view_agents' {
            View-ActiveAgents
        }

        'cleanup_locks' {
            Cleanup-StaleLocks
        }
    }

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
