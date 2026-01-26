<#
.SYNOPSIS
    Comprehensive multi-agent coordination dashboard

.DESCRIPTION
    Shows complete overview:
    - Active agents and sessions
    - Tasks in progress
    - Worktree allocations
    - Resource locks
    - Recent git operations
    - Recent PRs
    - Unread messages
    - Errors
    - Performance metrics

.PARAMETER Watch
    Refresh dashboard every 5 seconds

.PARAMETER Compact
    Show compact view

.EXAMPLE
    .\agent-dashboard.ps1

.EXAMPLE
    .\agent-dashboard.ps1 -Watch

.EXAMPLE
    .\agent-dashboard.ps1 -Compact
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$Watch,

    [Parameter(Mandatory=$false)]
    [switch]$Compact
)

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

function Show-Dashboard {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "           MULTI-AGENT COORDINATION DASHBOARD" -ForegroundColor Cyan
    Write-Host "                   $timestamp" -ForegroundColor DarkCyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""

    # SECTION 1: Active Agents & Sessions
    Write-Host "ACTIVE AGENTS & SESSIONS" -ForegroundColor Yellow
    Write-Host "------------------------" -ForegroundColor Yellow

    $sql = @"
SELECT
    a.agent_id,
    COALESCE(a.worktree_seat, '-') as seat,
    COALESCE(a.current_task, '(idle)') as task,
    CAST((julianday('now') - julianday(a.last_heartbeat)) * 24 * 60 AS INTEGER) as idle_min,
    COALESCE(s.session_id, '-') as session
FROM agents a
LEFT JOIN sessions s ON s.agent_id = a.agent_id AND s.ended_at IS NULL
WHERE a.status='active' AND datetime(a.last_heartbeat) > datetime('now', '-10 minutes')
ORDER BY a.last_heartbeat DESC;
"@

    $agents = Invoke-Sql -Sql $sql

    if ($agents) {
        $agents -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $color = if ([int]$parts[3] -lt 2) { 'Green' } elseif ([int]$parts[3] -lt 5) { 'Yellow' } else { 'Red' }
                Write-Host "  $($parts[0])" -ForegroundColor Cyan -NoNewline
                Write-Host " | Seat: $($parts[1]) | Task: $($parts[2]) | Idle: $($parts[3])m" -ForegroundColor $color
            }
        }
    } else {
        Write-Host "  No active agents" -ForegroundColor Gray
    }
    Write-Host ""

    # SECTION 2: Tasks
    Write-Host "TASKS IN PROGRESS" -ForegroundColor Yellow
    Write-Host "-----------------" -ForegroundColor Yellow

    $sql = @"
SELECT
    task_id,
    title,
    assigned_to,
    priority,
    CAST((julianday('now') - julianday(started_at)) * 24 * 60 AS INTEGER) as duration_min
FROM tasks
WHERE status='in_progress'
ORDER BY priority DESC, started_at ASC
LIMIT 10;
"@

    $tasks = Invoke-Sql -Sql $sql

    if ($tasks) {
        $tasks -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $priorityIcon = if ([int]$parts[3] -ge 8) { '' } elseif ([int]$parts[3] -ge 5) { '' } else { '' }
                Write-Host "  $priorityIcon $($parts[0]): $($parts[1])" -ForegroundColor White
                Write-Host "    Agent: $($parts[2]) | Duration: $($parts[4])m" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "  No tasks in progress" -ForegroundColor Gray
    }
    Write-Host ""

    # SECTION 3: Worktree Allocations
    Write-Host "WORKTREE ALLOCATIONS" -ForegroundColor Yellow
    Write-Host "--------------------" -ForegroundColor Yellow

    $sql = @"
SELECT
    seat,
    agent_id,
    repo,
    branch,
    CAST((julianday('now') - julianday(allocated_at)) * 24 * 60 AS INTEGER) as age_min
FROM worktree_allocations
WHERE status='active'
ORDER BY allocated_at DESC;
"@

    $worktrees = Invoke-Sql -Sql $sql

    if ($worktrees) {
        $worktrees -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                Write-Host "  $($parts[0]): $($parts[2])/$($parts[3])" -ForegroundColor Cyan
                Write-Host "    Agent: $($parts[1]) | Age: $($parts[4])m" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "  No active worktree allocations" -ForegroundColor Gray
    }
    Write-Host ""

    # SECTION 4: Resource Locks
    Write-Host "ACTIVE RESOURCE LOCKS" -ForegroundColor Yellow
    Write-Host "---------------------" -ForegroundColor Yellow

    $sql = @"
SELECT
    resource_type,
    resource_path,
    agent_id,
    CAST((julianday('now') - julianday(locked_at)) * 24 * 60 AS INTEGER) as age_min
FROM resource_locks
WHERE status='locked'
ORDER BY locked_at DESC
LIMIT 10;
"@

    $locks = Invoke-Sql -Sql $sql

    if ($locks) {
        $locks -split "`n" | ForEach-Object {
            if ($_ -match '\|') {
                $parts = $_ -split '\|'
                $ageColor = if ([int]$parts[3] -gt 60) { 'Red' } elseif ([int]$parts[3] -gt 30) { 'Yellow' } else { 'White' }
                Write-Host "  [$($parts[0])] $($parts[1])" -ForegroundColor White
                Write-Host "    Agent: $($parts[2]) | Age: $($parts[3])m" -ForegroundColor $ageColor
            }
        }
    } else {
        Write-Host "  No active locks" -ForegroundColor Gray
    }
    Write-Host ""

    if (-not $Compact) {
        # SECTION 5: Unread Messages
        $currentAgent = if (Test-Path "C:\scripts\_machine\.current_agent_id") {
            (Get-Content "C:\scripts\_machine\.current_agent_id" -Raw).Trim()
        } else { "" }

        if ($currentAgent) {
            $sql = @"
SELECT COUNT(*) FROM agent_messages
WHERE (to_agent_id='$currentAgent' OR to_agent_id IS NULL)
AND read=0;
"@

            $unreadCount = Invoke-Sql -Sql $sql

            Write-Host "MESSAGES" -ForegroundColor Yellow
            Write-Host "--------" -ForegroundColor Yellow

            if ([int]$unreadCount -gt 0) {
                Write-Host "  You have $unreadCount unread messages" -ForegroundColor Cyan
                Write-Host "  Run: agent-coordinate.ps1 -Action check_messages" -ForegroundColor Gray
            } else {
                Write-Host "  No unread messages" -ForegroundColor Gray
            }
            Write-Host ""
        }

        # SECTION 6: Recent Git Operations
        Write-Host "RECENT GIT OPERATIONS (last 10)" -ForegroundColor Yellow
        Write-Host "--------------------------------" -ForegroundColor Yellow

        $sql = @"
SELECT
    operation,
    repo,
    branch,
    agent_id,
    CASE success WHEN 1 THEN 'OK' ELSE 'FAIL' END as result,
    datetime(timestamp) as time
FROM git_operations
ORDER BY timestamp DESC
LIMIT 10;
"@

        $gitOps = Invoke-Sql -Sql $sql

        if ($gitOps) {
            $gitOps -split "`n" | ForEach-Object {
                if ($_ -match '\|') {
                    $parts = $_ -split '\|'
                    $resultColor = if ($parts[4] -eq 'OK') { 'Green' } else { 'Red' }
                    Write-Host "  [$($parts[4])] " -NoNewline -ForegroundColor $resultColor
                    Write-Host "$($parts[0]) on $($parts[1])/$($parts[2])" -ForegroundColor White
                }
            }
        } else {
            Write-Host "  No recent git operations" -ForegroundColor Gray
        }
        Write-Host ""

        # SECTION 7: Recent PRs
        Write-Host "RECENT PULL REQUESTS" -ForegroundColor Yellow
        Write-Host "--------------------" -ForegroundColor Yellow

        $sql = @"
SELECT
    repo,
    pr_number,
    title,
    status,
    agent_id
FROM pull_requests
ORDER BY created_at DESC
LIMIT 5;
"@

        $prs = Invoke-Sql -Sql $sql

        if ($prs) {
            $prs -split "`n" | ForEach-Object {
                if ($_ -match '\|') {
                    $parts = $_ -split '\|'
                    $statusIcon = switch ($parts[3]) {
                        'open' { '' }
                        'merged' { '' }
                        'closed' { '' }
                        default { '' }
                    }
                    Write-Host "  $statusIcon #$($parts[1]): $($parts[2])" -ForegroundColor White
                    Write-Host "    Repo: $($parts[0]) | Status: $($parts[3])" -ForegroundColor Gray
                }
            }
        } else {
            Write-Host "  No recent PRs" -ForegroundColor Gray
        }
        Write-Host ""

        # SECTION 8: Recent Errors
        Write-Host "RECENT ERRORS (last 24h)" -ForegroundColor Yellow
        Write-Host "------------------------" -ForegroundColor Yellow

        $sql = @"
SELECT
    severity,
    error_type,
    error_message,
    agent_id,
    datetime(timestamp) as time
FROM errors
WHERE datetime(timestamp) > datetime('now', '-1 day')
ORDER BY timestamp DESC
LIMIT 5;
"@

        $errors = Invoke-Sql -Sql $sql

        if ($errors) {
            $errors -split "`n" | ForEach-Object {
                if ($_ -match '\|') {
                    $parts = $_ -split '\|'
                    $severityColor = switch ($parts[0]) {
                        'critical' { 'Red' }
                        'error' { 'Red' }
                        'warning' { 'Yellow' }
                        default { 'Gray' }
                    }
                    Write-Host "  [$($parts[0].ToUpper())] $($parts[1])" -ForegroundColor $severityColor
                    Write-Host "    $($parts[2])" -ForegroundColor Gray
                }
            }
        } else {
            Write-Host "  No recent errors" -ForegroundColor Green
        }
        Write-Host ""

        # SECTION 9: Statistics
        Write-Host "STATISTICS" -ForegroundColor Yellow
        Write-Host "----------" -ForegroundColor Yellow

        $sql = @"
SELECT
    (SELECT COUNT(*) FROM agents WHERE status='active') as active_agents,
    (SELECT COUNT(*) FROM sessions WHERE ended_at IS NULL) as active_sessions,
    (SELECT COUNT(*) FROM tasks WHERE status='in_progress') as active_tasks,
    (SELECT COUNT(*) FROM worktree_allocations WHERE status='active') as active_worktrees,
    (SELECT COUNT(*) FROM resource_locks WHERE status='locked') as active_locks,
    (SELECT COUNT(*) FROM pull_requests WHERE status='open') as open_prs,
    (SELECT COUNT(*) FROM errors WHERE datetime(timestamp) > datetime('now', '-1 day')) as errors_24h;
"@

        $stats = Invoke-Sql -Sql $sql

        if ($stats) {
            $parts = $stats -split '\|'
            Write-Host "  Active Agents:     $($parts[0])" -ForegroundColor White
            Write-Host "  Active Sessions:   $($parts[1])" -ForegroundColor White
            Write-Host "  Active Tasks:      $($parts[2])" -ForegroundColor White
            Write-Host "  Active Worktrees:  $($parts[3])" -ForegroundColor White
            Write-Host "  Active Locks:      $($parts[4])" -ForegroundColor White
            Write-Host "  Open PRs:          $($parts[5])" -ForegroundColor White
            Write-Host "  Errors (24h):      " -NoNewline -ForegroundColor White
            $errorColor = if ([int]$parts[6] -gt 5) { 'Red' } elseif ([int]$parts[6] -gt 0) { 'Yellow' } else { 'Green' }
            Write-Host "$($parts[6])" -ForegroundColor $errorColor
        }
        Write-Host ""
    }

    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
}

# Main execution
try {
    if ($Watch) {
        while ($true) {
            Clear-Host
            Show-Dashboard
            Write-Host "Refreshing in 5 seconds... (Ctrl+C to stop)" -ForegroundColor Gray
            Start-Sleep -Seconds 5
        }
    } else {
        Show-Dashboard
    }

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
