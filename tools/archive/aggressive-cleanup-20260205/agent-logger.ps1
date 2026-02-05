<#
.SYNOPSIS
    SQLite-based agent activity logger for multi-agent coordination

.DESCRIPTION
    Core logging system that tracks:
    - Active agents with heartbeat mechanism
    - All agent activities (task start/complete, worktree allocation, etc.)
    - Task tracking with status and assignments
    - Historical activity for analysis

.PARAMETER Action
    Action to perform: register, heartbeat, log, complete_task, start_task, query

.PARAMETER Message
    Log message or task description

.PARAMETER TaskId
    Optional task ID for task-related actions

.PARAMETER Metadata
    Optional JSON metadata

.EXAMPLE
    .\agent-logger.ps1 -Action register
    Register current agent and get agent ID

.EXAMPLE
    .\agent-logger.ps1 -Action log -Message "Allocating worktree for client-manager"

.EXAMPLE
    .\agent-logger.ps1 -Action start_task -Message "Implement OAuth integration" -TaskId "TASK-123"

.EXAMPLE
    .\agent-logger.ps1 -Action query -Query "active_agents"
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('register', 'heartbeat', 'log', 'start_task', 'complete_task', 'block_task', 'query', 'cleanup')]
    [string]$Action = 'log',

    [Parameter(Mandatory=$false)]
    [string]$Message = '',

    [Parameter(Mandatory=$false)]
    [string]$TaskId = '',

    [Parameter(Mandatory=$false)]
    [string]$Metadata = '{}',

    [Parameter(Mandatory=$false)]
    [ValidateSet('active_agents', 'all_agents', 'current_tasks', 'unfinished_tasks', 'agent_history', 'stale_agents')]
    [string]$Query = 'active_agents',

    [Parameter(Mandatory=$false)]
    [string]$AgentId = '',

    [Parameter(Mandatory=$false)]
    [int]$Limit = 50
)

$ErrorActionPreference = 'Stop'

# Paths
$DbPath = "C:\scripts\_machine\agent-activity.db"
$AgentIdFile = "C:\scripts\_machine\.current_agent_id"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"
$MachineId = $env:COMPUTERNAME

# Initialize database schema
function Initialize-Database {
    # Check if SQLite is available
    if (-not (Test-Path $SqlitePath)) {
        throw "SQLite not found at $SqlitePath. Please ensure it's installed."
    }

    # Create database if not exists
    if (-not (Test-Path $DbPath)) {
        Write-Host "Creating agent activity database..." -ForegroundColor Cyan

        # Create schema file
        $schemaFile = "$env:TEMP\agent-schema.sql"
        @'
CREATE TABLE IF NOT EXISTS agents (
    agent_id TEXT PRIMARY KEY,
    machine_id TEXT NOT NULL,
    session_id TEXT,
    started_at TEXT NOT NULL,
    last_heartbeat TEXT NOT NULL,
    status TEXT NOT NULL CHECK(status IN ('active', 'idle', 'terminated')),
    current_task TEXT,
    worktree_seat TEXT,
    metadata TEXT DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS activity_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_id TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    action_type TEXT NOT NULL,
    message TEXT,
    task_id TEXT,
    metadata TEXT DEFAULT '{}',
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

CREATE TABLE IF NOT EXISTS tasks (
    task_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL CHECK(status IN ('pending', 'in_progress', 'completed', 'blocked')),
    assigned_to TEXT,
    created_at TEXT NOT NULL,
    started_at TEXT,
    completed_at TEXT,
    priority INTEGER DEFAULT 5,
    metadata TEXT DEFAULT '{}',
    FOREIGN KEY (assigned_to) REFERENCES agents(agent_id)
);

CREATE INDEX IF NOT EXISTS idx_agents_status ON agents(status);
CREATE INDEX IF NOT EXISTS idx_agents_heartbeat ON agents(last_heartbeat);
CREATE INDEX IF NOT EXISTS idx_activity_agent ON activity_log(agent_id);
CREATE INDEX IF NOT EXISTS idx_activity_timestamp ON activity_log(timestamp);
CREATE INDEX IF NOT EXISTS idx_activity_action ON activity_log(action_type);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_assigned ON tasks(assigned_to);
'@ | Out-File -FilePath $schemaFile -Encoding UTF8

        # Execute schema
        & $SqlitePath $DbPath ".read $schemaFile"
        Remove-Item $schemaFile
        Write-Host "Database initialized" -ForegroundColor Green
    }
}

# Get or create agent ID
function Get-AgentId {
    if ($script:AgentId) {
        return $script:AgentId
    }

    # Try to load from file
    if (Test-Path $AgentIdFile) {
        $script:AgentId = Get-Content $AgentIdFile -Raw | Out-String | ForEach-Object { $_.Trim() }
        return $script:AgentId
    }

    # Generate new agent ID
    # Format: agent-<timestamp>-<random>
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $random = Get-Random -Minimum 1000 -Maximum 9999
    $script:AgentId = "agent-$timestamp-$random"

    # Save to file
    $script:AgentId | Out-File -FilePath $AgentIdFile -Encoding UTF8 -NoNewline

    return $script:AgentId
}

# Execute SQL query
function Invoke-Sql {
    param([string]$Sql, [switch]$Json)

    if ($Json) {
        $result = $Sql | & $SqlitePath $DbPath -json
    } else {
        $result = $Sql | & $SqlitePath $DbPath
    }

    return $result
}

# Register agent
function Register-Agent {
    $agentId = Get-AgentId
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    # Check if agent already registered
    $exists = Invoke-Sql "SELECT agent_id FROM agents WHERE agent_id='$agentId';"

    if ($exists) {
        # Update heartbeat
        Invoke-Sql @"
UPDATE agents
SET last_heartbeat='$now', status='active'
WHERE agent_id='$agentId';
"@
        Write-Host "Agent $agentId reconnected" -ForegroundColor Green
    } else {
        # Register new agent
        Invoke-Sql @"
INSERT INTO agents (agent_id, machine_id, started_at, last_heartbeat, status, metadata)
VALUES ('$agentId', '$MachineId', '$now', '$now', 'active', '{}');
"@
        Write-Host "Agent $agentId registered" -ForegroundColor Green

        # Log registration
        Invoke-Sql @"
INSERT INTO activity_log (agent_id, timestamp, action_type, message, metadata)
VALUES ('$agentId', '$now', 'register', 'Agent registered on $MachineId', '{}');
"@
    }

    return $agentId
}

# Update heartbeat
function Update-Heartbeat {
    $agentId = Get-AgentId
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    Invoke-Sql @"
UPDATE agents
SET last_heartbeat='$now', status='active'
WHERE agent_id='$agentId';
"@
}

# Log activity
function Write-ActivityLog {
    param(
        [string]$ActionType,
        [string]$Message,
        [string]$TaskId = '',
        [string]$Metadata = '{}'
    )

    $agentId = Get-AgentId
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    # Escape single quotes
    $Message = $Message -replace "'", "''"
    $Metadata = $Metadata -replace "'", "''"

    Invoke-Sql @"
INSERT INTO activity_log (agent_id, timestamp, action_type, message, task_id, metadata)
VALUES ('$agentId', '$now', '$ActionType', '$Message', '$TaskId', '$Metadata');
"@

    # Update heartbeat
    Update-Heartbeat
}

# Start task
function Start-Task {
    param(
        [string]$Title,
        [string]$TaskId = '',
        [string]$Description = '',
        [int]$Priority = 5
    )

    $agentId = Get-AgentId
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    # Generate task ID if not provided
    if (-not $TaskId) {
        $TaskId = "TASK-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    }

    # Escape quotes
    $Title = $Title -replace "'", "''"
    $Description = $Description -replace "'", "''"

    # Create or update task
    $exists = Invoke-Sql "SELECT task_id FROM tasks WHERE task_id='$TaskId';"

    if ($exists) {
        Invoke-Sql @"
UPDATE tasks
SET status='in_progress', assigned_to='$agentId', started_at='$now'
WHERE task_id='$TaskId';
"@
    } else {
        Invoke-Sql @"
INSERT INTO tasks (task_id, title, description, status, assigned_to, created_at, started_at, priority)
VALUES ('$TaskId', '$Title', '$Description', 'in_progress', '$agentId', '$now', '$now', $Priority);
"@
    }

    # Update agent current task
    Invoke-Sql @"
UPDATE agents
SET current_task='$TaskId'
WHERE agent_id='$agentId';
"@

    # Log activity
    Write-ActivityLog -ActionType "start_task" -Message "Started: $Title" -TaskId $TaskId

    Write-Host "Task $TaskId started" -ForegroundColor Green
    return $TaskId
}

# Complete task
function Complete-Task {
    param([string]$TaskId)

    $agentId = Get-AgentId
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    Invoke-Sql @"
UPDATE tasks
SET status='completed', completed_at='$now'
WHERE task_id='$TaskId';
"@

    # Clear agent current task
    Invoke-Sql @"
UPDATE agents
SET current_task=NULL
WHERE agent_id='$agentId' AND current_task='$TaskId';
"@

    # Log activity
    Write-ActivityLog -ActionType "complete_task" -Message "Completed task" -TaskId $TaskId

    Write-Host "Task $TaskId completed" -ForegroundColor Green
}

# Block task
function Block-Task {
    param(
        [string]$TaskId,
        [string]$Reason
    )

    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    $Reason = $Reason -replace "'", "''"

    Invoke-Sql @"
UPDATE tasks
SET status='blocked', metadata=json_set(metadata, '$.blocked_reason', '$Reason')
WHERE task_id='$TaskId';
"@

    # Log activity
    Write-ActivityLog -ActionType "block_task" -Message "Blocked: $Reason" -TaskId $TaskId

    Write-Host "Task $TaskId blocked: $Reason" -ForegroundColor Yellow
}

# Query data
function Invoke-Query {
    param([string]$QueryType, [string]$TargetAgentId = '', [int]$Limit = 50)

    switch ($QueryType) {
        'active_agents' {
            Write-Host "`nActive Agents:" -ForegroundColor Cyan
            $sql = @"
SELECT
    agent_id,
    machine_id,
    status,
    current_task,
    worktree_seat,
    datetime(last_heartbeat) as last_heartbeat,
    CAST((julianday('now') - julianday(last_heartbeat)) * 24 * 60 AS INTEGER) as idle_minutes
FROM agents
WHERE status='active' AND datetime(last_heartbeat) > datetime('now', '-10 minutes')
ORDER BY last_heartbeat DESC;
"@
            $result = Invoke-Sql -Sql $sql
            if ($result) {
                $result | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            } else {
                Write-Host "  No active agents" -ForegroundColor Gray
            }
        }

        'stale_agents' {
            Write-Host "`nStale Agents (>5 min no heartbeat):" -ForegroundColor Yellow
            $sql = @"
SELECT
    agent_id,
    status,
    current_task,
    datetime(last_heartbeat) as last_heartbeat,
    CAST((julianday('now') - julianday(last_heartbeat)) * 24 * 60 AS INTEGER) as idle_minutes
FROM agents
WHERE status='active' AND datetime(last_heartbeat) < datetime('now', '-5 minutes')
ORDER BY last_heartbeat ASC;
"@
            $result = Invoke-Sql -Sql $sql
            if ($result) {
                $result | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
            } else {
                Write-Host "  No stale agents" -ForegroundColor Green
            }
        }

        'current_tasks' {
            Write-Host "`n Current Tasks (in progress):" -ForegroundColor Cyan
            $sql = @"
SELECT
    t.task_id,
    t.title,
    t.assigned_to,
    t.priority,
    datetime(t.started_at) as started,
    CAST((julianday('now') - julianday(t.started_at)) * 24 * 60 AS INTEGER) as duration_minutes
FROM tasks t
WHERE t.status='in_progress'
ORDER BY t.priority DESC, t.started_at ASC
LIMIT $Limit;
"@
            $result = Invoke-Sql -Sql $sql
            if ($result) {
                $result | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            } else {
                Write-Host "  No tasks in progress" -ForegroundColor Gray
            }
        }

        'unfinished_tasks' {
            Write-Host "`n Unfinished Tasks:" -ForegroundColor Cyan
            $sql = @"
SELECT
    t.task_id,
    t.title,
    t.status,
    t.assigned_to,
    t.priority,
    datetime(t.created_at) as created
FROM tasks t
WHERE t.status IN ('pending', 'in_progress', 'blocked')
ORDER BY t.priority DESC, t.created_at ASC
LIMIT $Limit;
"@
            $result = Invoke-Sql -Sql $sql
            if ($result) {
                $result | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            } else {
                Write-Host "  No unfinished tasks" -ForegroundColor Green
            }
        }

        'agent_history' {
            if (-not $TargetAgentId) {
                $TargetAgentId = Get-AgentId
            }
            Write-Host "`n Activity History for $TargetAgentId (last $Limit):" -ForegroundColor Cyan
            $sql = @"
SELECT
    datetime(timestamp) as time,
    action_type,
    message,
    task_id
FROM activity_log
WHERE agent_id='$TargetAgentId'
ORDER BY timestamp DESC
LIMIT $Limit;
"@
            $result = Invoke-Sql -Sql $sql
            if ($result) {
                $result | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            } else {
                Write-Host "  No activity history" -ForegroundColor Gray
            }
        }

        'all_agents' {
            Write-Host "`n All Agents:" -ForegroundColor Cyan
            $sql = @"
SELECT
    agent_id,
    machine_id,
    status,
    current_task,
    datetime(started_at) as started,
    datetime(last_heartbeat) as last_heartbeat
FROM agents
ORDER BY started_at DESC
LIMIT $Limit;
"@
            $result = Invoke-Sql -Sql $sql
            if ($result) {
                $result | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            } else {
                Write-Host "  No agents found" -ForegroundColor Gray
            }
        }
    }
}

# Cleanup stale agents
function Invoke-Cleanup {
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    # Mark agents as terminated if no heartbeat for 10 minutes
    $sql = @"
UPDATE agents
SET status='terminated'
WHERE status='active' AND datetime(last_heartbeat) < datetime('now', '-10 minutes');
"@
    Invoke-Sql -Sql $sql

    # Log cleanup
    $agentId = Get-AgentId
    Invoke-Sql @"
INSERT INTO activity_log (agent_id, timestamp, action_type, message, metadata)
VALUES ('$agentId', '$now', 'cleanup', 'Terminated stale agents', '{}');
"@

    Write-Host " Cleanup completed" -ForegroundColor Green
}

# Main execution
try {
    Initialize-Database

    switch ($Action) {
        'register' {
            $id = Register-Agent
            Write-Host "`n Agent ID: $id" -ForegroundColor Cyan
            Write-Host "   Saved to: $AgentIdFile`n" -ForegroundColor Gray
        }

        'heartbeat' {
            Update-Heartbeat
            $id = Get-AgentId
            Write-Host " Heartbeat updated for $id" -ForegroundColor Green
        }

        'log' {
            if (-not $Message) {
                throw "Message required for log action"
            }
            Write-ActivityLog -ActionType "log" -Message $Message -TaskId $TaskId -Metadata $Metadata
            Write-Host " Activity logged" -ForegroundColor Green
        }

        'start_task' {
            if (-not $Message) {
                throw "Message (task title) required for start_task action"
            }
            $taskId = Start-Task -Title $Message -TaskId $TaskId -Description $Metadata
            Write-Host "`n Task ID: $taskId`n" -ForegroundColor Cyan
        }

        'complete_task' {
            if (-not $TaskId) {
                throw "TaskId required for complete_task action"
            }
            Complete-Task -TaskId $TaskId
        }

        'block_task' {
            if (-not $TaskId -or -not $Message) {
                throw "TaskId and Message (reason) required for block_task action"
            }
            Block-Task -TaskId $TaskId -Reason $Message
        }

        'query' {
            Invoke-Query -QueryType $Query -TargetAgentId $AgentId -Limit $Limit
        }

        'cleanup' {
            Invoke-Cleanup
        }
    }

} catch {
    Write-Host " Error: $_" -ForegroundColor Red
    exit 1
}
