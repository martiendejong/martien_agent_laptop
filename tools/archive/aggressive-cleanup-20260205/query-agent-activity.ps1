<#
.SYNOPSIS
    Query agent activity database with formatted output

.DESCRIPTION
    User-friendly interface to query agent activity, tasks, and coordination status.
    Provides dashboard views and detailed reports.

.PARAMETER Action
    Query action: dashboard, agents, tasks, history, unfinished, conflicts

.PARAMETER AgentId
    Specific agent ID to query (optional)

.PARAMETER Format
    Output format: table, json, markdown

.EXAMPLE
    .\query-agent-activity.ps1 -Action dashboard
    Show comprehensive dashboard of all agent activity

.EXAMPLE
    .\query-agent-activity.ps1 -Action agents
    List all active agents

.EXAMPLE
    .\query-agent-activity.ps1 -Action unfinished
    Show all unfinished tasks

.EXAMPLE
    .\query-agent-activity.ps1 -Action history -AgentId agent-123
    Show activity history for specific agent
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('dashboard', 'agents', 'tasks', 'history', 'unfinished', 'conflicts', 'stats')]
    [string]$Action = 'dashboard',

    [Parameter(Mandatory=$false)]
    [string]$AgentId = '',

    [Parameter(Mandatory=$false)]
    [ValidateSet('table', 'json', 'markdown')]
    [string]$Format = 'table',

    [Parameter(Mandatory=$false)]
    [int]$Limit = 50,

    [Parameter(Mandatory=$false)]
    [switch]$Watch
)

$ErrorActionPreference = 'Stop'
$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

# Check if database exists
if (-not (Test-Path $DbPath)) {
    Write-Host " Database not found. Run agent-logger.ps1 -Action register first." -ForegroundColor Red
    exit 1
}

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

function Show-Dashboard {
    Write-Host "`n" -ForegroundColor Cyan
    Write-Host "             MULTI-AGENT COORDINATION DASHBOARD" -ForegroundColor Cyan
    Write-Host "`n" -ForegroundColor Cyan

    # Active agents
    Write-Host "" -ForegroundColor DarkCyan
    Write-Host "  ACTIVE AGENTS                                            " -ForegroundColor DarkCyan
    Write-Host "" -ForegroundColor DarkCyan

    $activeAgents = Invoke-Sql @"
SELECT
    agent_id,
    status,
    COALESCE(current_task, '(idle)') as current_task,
    COALESCE(worktree_seat, '-') as seat,
    CAST((julianday('now') - julianday(last_heartbeat)) * 24 * 60 AS INTEGER) as idle_min
FROM agents
WHERE status='active' AND datetime(last_heartbeat) > datetime('now', '-10 minutes')
ORDER BY last_heartbeat DESC;
"@

    if ($activeAgents) {
        Write-Host ""
        $activeAgents -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $agentId = $parts[0]
                $status = $parts[1]
                $task = $parts[2]
                $seat = $parts[3]
                $idleMin = $parts[4]

                $statusIcon = if ($status -eq 'active') { '' } else { '' }
                $idleColor = if ([int]$idleMin -lt 2) { 'Green' } elseif ([int]$idleMin -lt 5) { 'Yellow' } else { 'Red' }

                Write-Host "  $statusIcon " -NoNewline -ForegroundColor Green
                Write-Host "$agentId " -NoNewline -ForegroundColor Cyan
                Write-Host " " -NoNewline -ForegroundColor DarkGray
                Write-Host "Seat: $seat " -NoNewline -ForegroundColor Gray
                Write-Host " " -NoNewline -ForegroundColor DarkGray
                Write-Host "Task: $task " -NoNewline -ForegroundColor White
                Write-Host " " -NoNewline -ForegroundColor DarkGray
                Write-Host "${idleMin}m ago" -ForegroundColor $idleColor
            }
        }
        Write-Host ""
    } else {
        Write-Host "  No active agents" -ForegroundColor Gray
        Write-Host ""
    }

    # Stale agents
    $staleAgents = Invoke-Sql @"
SELECT COUNT(*) FROM agents
WHERE status='active' AND datetime(last_heartbeat) < datetime('now', '-5 minutes');
"@

    if ([int]$staleAgents -gt 0) {
        Write-Host "" -ForegroundColor Yellow
        Write-Host "   STALE AGENTS ($staleAgents agents, >5min no heartbeat)             " -ForegroundColor Yellow
        Write-Host "" -ForegroundColor Yellow

        $staleList = Invoke-Sql @"
SELECT
    agent_id,
    COALESCE(current_task, '(unknown)') as task,
    CAST((julianday('now') - julianday(last_heartbeat)) * 24 * 60 AS INTEGER) as idle_min
FROM agents
WHERE status='active' AND datetime(last_heartbeat) < datetime('now', '-5 minutes')
ORDER BY last_heartbeat ASC;
"@

        if ($staleList) {
            Write-Host ""
            $staleList -split "`n" | ForEach-Object {
                if ($_ -match '\|') {
                    $parts = $_ -split '\|'
                    Write-Host "   $($parts[0]) - Task: $($parts[1]) - ${parts[2]} min idle" -ForegroundColor Yellow
                }
            }
            Write-Host ""
            Write-Host "   Run: agent-logger.ps1 -Action cleanup" -ForegroundColor Gray
            Write-Host ""
        }
    }

    # Current tasks
    Write-Host "" -ForegroundColor DarkCyan
    Write-Host "  TASKS IN PROGRESS                                        " -ForegroundColor DarkCyan
    Write-Host "" -ForegroundColor DarkCyan

    $currentTasks = Invoke-Sql @"
SELECT
    t.task_id,
    t.title,
    COALESCE(t.assigned_to, '(unassigned)') as agent,
    t.priority,
    CAST((julianday('now') - julianday(t.started_at)) * 24 * 60 AS INTEGER) as duration_min
FROM tasks t
WHERE t.status='in_progress'
ORDER BY t.priority DESC, t.started_at ASC
LIMIT 10;
"@

    if ($currentTasks) {
        Write-Host ""
        $currentTasks -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $taskId = $parts[0]
                $title = $parts[1]
                $agent = $parts[2]
                $priority = $parts[3]
                $duration = $parts[4]

                $priorityIcon = switch ([int]$priority) {
                    { $_ -ge 8 } { '' }
                    { $_ -ge 5 } { '' }
                    default { '' }
                }

                Write-Host "  $priorityIcon " -NoNewline
                Write-Host "$taskId " -NoNewline -ForegroundColor Cyan
                Write-Host " " -NoNewline -ForegroundColor DarkGray
                Write-Host "$title " -NoNewline -ForegroundColor White
                Write-Host " " -NoNewline -ForegroundColor DarkGray
                Write-Host "$agent " -NoNewline -ForegroundColor Gray
                Write-Host " " -NoNewline -ForegroundColor DarkGray
                Write-Host "${duration}m" -ForegroundColor Gray
            }
        }
        Write-Host ""
    } else {
        Write-Host "  No tasks in progress" -ForegroundColor Gray
        Write-Host ""
    }

    # Blocked tasks
    $blockedTasks = Invoke-Sql @"
SELECT
    t.task_id,
    t.title,
    COALESCE(t.assigned_to, '(unassigned)') as agent
FROM tasks t
WHERE t.status='blocked'
ORDER BY t.created_at DESC
LIMIT 5;
"@

    if ($blockedTasks) {
        Write-Host "" -ForegroundColor Red
        Write-Host "  BLOCKED TASKS                                            " -ForegroundColor Red
        Write-Host "" -ForegroundColor Red
        Write-Host ""

        $blockedTasks -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                Write-Host "   $($parts[0]) - $($parts[1]) - Agent: $($parts[2])" -ForegroundColor Red
            }
        }
        Write-Host ""
    }

    # Unfinished tasks
    $unfinishedCount = Invoke-Sql @"
SELECT COUNT(*) FROM tasks
WHERE status IN ('pending', 'in_progress', 'blocked');
"@

    Write-Host "" -ForegroundColor DarkCyan
    Write-Host "  STATISTICS                                               " -ForegroundColor DarkCyan
    Write-Host "" -ForegroundColor DarkCyan
    Write-Host ""

    $stats = Invoke-Sql @"
SELECT
    (SELECT COUNT(*) FROM agents WHERE status='active') as active_agents,
    (SELECT COUNT(*) FROM tasks WHERE status='pending') as pending_tasks,
    (SELECT COUNT(*) FROM tasks WHERE status='in_progress') as in_progress_tasks,
    (SELECT COUNT(*) FROM tasks WHERE status='completed') as completed_tasks,
    (SELECT COUNT(*) FROM tasks WHERE status='blocked') as blocked_tasks,
    (SELECT COUNT(*) FROM activity_log WHERE datetime(timestamp) > datetime('now', '-1 hour')) as recent_activity;
"@

    if ($stats) {
        $parts = $stats -split '\|'
        Write-Host "   Active Agents:      " -NoNewline -ForegroundColor Gray
        Write-Host $parts[0] -ForegroundColor Green
        Write-Host "   Pending Tasks:      " -NoNewline -ForegroundColor Gray
        Write-Host $parts[1] -ForegroundColor Yellow
        Write-Host "   In Progress:        " -NoNewline -ForegroundColor Gray
        Write-Host $parts[2] -ForegroundColor Cyan
        Write-Host "   Completed:          " -NoNewline -ForegroundColor Gray
        Write-Host $parts[3] -ForegroundColor Green
        Write-Host "   Blocked:            " -NoNewline -ForegroundColor Gray
        Write-Host $parts[4] -ForegroundColor Red
        Write-Host "   Activity (1h):      " -NoNewline -ForegroundColor Gray
        Write-Host $parts[5] -ForegroundColor White
    }

    Write-Host ""
    Write-Host "" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Agents {
    Write-Host "`n All Agents:" -ForegroundColor Cyan
    Write-Host ""

    $agents = Invoke-Sql @"
SELECT
    agent_id,
    machine_id,
    status,
    COALESCE(current_task, '-') as task,
    COALESCE(worktree_seat, '-') as seat,
    datetime(started_at) as started,
    datetime(last_heartbeat) as last_seen
FROM agents
ORDER BY last_heartbeat DESC
LIMIT $Limit;
"@

    if ($agents) {
        Write-Host ("  {0,-25} {1,-15} {2,-10} {3,-30} {4,-10}" -f "Agent ID", "Machine", "Status", "Current Task", "Seat") -ForegroundColor DarkGray
        Write-Host ("  {0,-25} {1,-15} {2,-10} {3,-30} {4,-10}" -f ("-" * 25), ("-" * 15), ("-" * 10), ("-" * 30), ("-" * 10)) -ForegroundColor DarkGray

        $agents -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $color = switch ($parts[2]) {
                    'active' { 'Green' }
                    'idle' { 'Yellow' }
                    'terminated' { 'Red' }
                    default { 'Gray' }
                }
                Write-Host ("  {0,-25} {1,-15} {2,-10} {3,-30} {4,-10}" -f $parts[0], $parts[1], $parts[2], $parts[3], $parts[4]) -ForegroundColor $color
            }
        }
    } else {
        Write-Host "  No agents found" -ForegroundColor Gray
    }

    Write-Host ""
}

function Show-Tasks {
    Write-Host "`n All Tasks:" -ForegroundColor Cyan
    Write-Host ""

    $tasks = Invoke-Sql @"
SELECT
    t.task_id,
    t.title,
    t.status,
    COALESCE(t.assigned_to, '(unassigned)') as agent,
    t.priority,
    datetime(t.created_at) as created
FROM tasks t
ORDER BY t.created_at DESC
LIMIT $Limit;
"@

    if ($tasks) {
        Write-Host ("  {0,-20} {1,-40} {2,-12} {3,-20} {4}" -f "Task ID", "Title", "Status", "Agent", "Priority") -ForegroundColor DarkGray
        Write-Host ("  {0,-20} {1,-40} {2,-12} {3,-20} {4}" -f ("-" * 20), ("-" * 40), ("-" * 12), ("-" * 20), ("-" * 8)) -ForegroundColor DarkGray

        $tasks -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $color = switch ($parts[2]) {
                    'completed' { 'Green' }
                    'in_progress' { 'Cyan' }
                    'pending' { 'Yellow' }
                    'blocked' { 'Red' }
                    default { 'Gray' }
                }
                $title = if ($parts[1].Length -gt 40) { $parts[1].Substring(0, 37) + "..." } else { $parts[1] }
                Write-Host ("  {0,-20} {1,-40} {2,-12} {3,-20} {4}" -f $parts[0], $title, $parts[2], $parts[3], $parts[4]) -ForegroundColor $color
            }
        }
    } else {
        Write-Host "  No tasks found" -ForegroundColor Gray
    }

    Write-Host ""
}

function Show-History {
    param([string]$AgentId)

    if (-not $AgentId) {
        Write-Host " AgentId required for history view" -ForegroundColor Red
        return
    }

    Write-Host "`n Activity History - $AgentId (last $Limit):" -ForegroundColor Cyan
    Write-Host ""

    $history = Invoke-Sql @"
SELECT
    datetime(timestamp) as time,
    action_type,
    message,
    COALESCE(task_id, '-') as task
FROM activity_log
WHERE agent_id='$AgentId'
ORDER BY timestamp DESC
LIMIT $Limit;
"@

    if ($history) {
        $history -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $icon = switch ($parts[1]) {
                    'register' { '' }
                    'start_task' { '' }
                    'complete_task' { '' }
                    'block_task' { '' }
                    'log' { '' }
                    default { '' }
                }
                Write-Host "  $icon " -NoNewline
                Write-Host "$($parts[0]) " -NoNewline -ForegroundColor Gray
                Write-Host " " -NoNewline -ForegroundColor DarkGray
                Write-Host "$($parts[1].PadRight(15)) " -NoNewline -ForegroundColor Cyan
                Write-Host " " -NoNewline -ForegroundColor DarkGray
                Write-Host "$($parts[2]) " -NoNewline -ForegroundColor White
                if ($parts[3] -ne '-') {
                    Write-Host " " -NoNewline -ForegroundColor DarkGray
                    Write-Host "Task: $($parts[3])" -ForegroundColor Yellow
                } else {
                    Write-Host ""
                }
            }
        }
    } else {
        Write-Host "  No activity found" -ForegroundColor Gray
    }

    Write-Host ""
}

function Show-Unfinished {
    Write-Host "`n Unfinished Tasks:" -ForegroundColor Cyan
    Write-Host ""

    $unfinished = Invoke-Sql @"
SELECT
    t.task_id,
    t.title,
    t.status,
    COALESCE(t.assigned_to, '(available)') as agent,
    t.priority,
    datetime(t.created_at) as created
FROM tasks t
WHERE t.status IN ('pending', 'in_progress', 'blocked')
ORDER BY t.priority DESC, t.created_at ASC;
"@

    if ($unfinished) {
        $unfinished -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $icon = switch ($parts[2]) {
                    'pending' { '' }
                    'in_progress' { '' }
                    'blocked' { '' }
                    default { '' }
                }
                $priorityIcon = switch ([int]$parts[4]) {
                    { $_ -ge 8 } { '' }
                    { $_ -ge 5 } { '' }
                    default { '' }
                }

                Write-Host "  $icon $priorityIcon " -NoNewline
                Write-Host "$($parts[0]) " -NoNewline -ForegroundColor Cyan
                Write-Host " " -NoNewline -ForegroundColor DarkGray
                Write-Host "$($parts[1].PadRight(40)) " -NoNewline -ForegroundColor White
                Write-Host " " -NoNewline -ForegroundColor DarkGray
                Write-Host "$($parts[3].PadRight(20)) " -NoNewline -ForegroundColor Gray
                Write-Host " " -NoNewline -ForegroundColor DarkGray
                Write-Host "P$($parts[4])" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "  No unfinished tasks - all clear! " -ForegroundColor Green
    }

    Write-Host ""
}

function Show-Conflicts {
    Write-Host "`n Potential Conflicts:" -ForegroundColor Yellow
    Write-Host ""

    # Multiple agents with same worktree seat
    $seatConflicts = Invoke-Sql @"
SELECT
    worktree_seat,
    GROUP_CONCAT(agent_id, ', ') as agents
FROM agents
WHERE status='active' AND worktree_seat IS NOT NULL AND worktree_seat != ''
GROUP BY worktree_seat
HAVING COUNT(*) > 1;
"@

    if ($seatConflicts) {
        Write-Host "   WORKTREE SEAT CONFLICTS:" -ForegroundColor Red
        $seatConflicts -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                Write-Host "    Seat $($parts[0]): Multiple agents  $($parts[1])" -ForegroundColor Red
            }
        }
        Write-Host ""
    }

    # Multiple agents assigned to same task
    $taskConflicts = Invoke-Sql @"
SELECT
    t.task_id,
    t.title,
    COUNT(*) as agent_count
FROM tasks t
JOIN agents a ON a.current_task = t.task_id
WHERE a.status='active'
GROUP BY t.task_id, t.title
HAVING COUNT(*) > 1;
"@

    if ($taskConflicts) {
        Write-Host "   TASK CONFLICTS:" -ForegroundColor Red
        $taskConflicts -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                Write-Host "    Task $($parts[0]): $($parts[2]) agents working on same task" -ForegroundColor Red
            }
        }
        Write-Host ""
    }

    if (-not $seatConflicts -and -not $taskConflicts) {
        Write-Host "   No conflicts detected" -ForegroundColor Green
        Write-Host ""
    }
}

# Main execution
try {
    if ($Watch) {
        while ($true) {
            Clear-Host
            switch ($Action) {
                'dashboard' { Show-Dashboard }
                'agents' { Show-Agents }
                'tasks' { Show-Tasks }
                'history' { Show-History -AgentId $AgentId }
                'unfinished' { Show-Unfinished }
                'conflicts' { Show-Conflicts }
            }
            Write-Host "Refreshing in 5 seconds... (Ctrl+C to stop)" -ForegroundColor Gray
            Start-Sleep -Seconds 5
        }
    } else {
        switch ($Action) {
            'dashboard' { Show-Dashboard }
            'agents' { Show-Agents }
            'tasks' { Show-Tasks }
            'history' { Show-History -AgentId $AgentId }
            'unfinished' { Show-Unfinished }
            'conflicts' { Show-Conflicts }
        }
    }

} catch {
    Write-Host " Error: $_" -ForegroundColor Red
    exit 1
}
