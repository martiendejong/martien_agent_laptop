<#
.SYNOPSIS
    Enhanced SQLite-based agent activity logger with comprehensive tracking

.DESCRIPTION
    Extended logging system supporting:
    - Agents, tasks, and activity (original)
    - Worktree allocations
    - Resource locks
    - Git operations
    - PR tracking
    - File modifications
    - Tool usage

.PARAMETER Action
    Actions: register, heartbeat, log, start_task, complete_task, block_task,
             allocate_worktree, release_worktree,
             lock_resource, unlock_resource,
             log_git_op, log_pr, log_file_mod, log_tool_use,
             query, cleanup

.EXAMPLE
    .\agent-logger-enhanced.ps1 -Action allocate_worktree -Seat agent-003 -Repo client-manager -Branch feature/oauth

.EXAMPLE
    .\agent-logger-enhanced.ps1 -Action lock_resource -ResourceType file -ResourcePath "src/app.ts"

.EXAMPLE
    .\agent-logger-enhanced.ps1 -Action log_git_op -GitOp commit -Repo client-manager -Branch main -CommitSha abc123

.EXAMPLE
    .\agent-logger-enhanced.ps1 -Action log_pr -Repo client-manager -PRNumber 123 -Title "Add OAuth"
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('register', 'heartbeat', 'log', 'start_task', 'complete_task', 'block_task',
                 'allocate_worktree', 'release_worktree', 'query_worktrees',
                 'lock_resource', 'unlock_resource', 'check_lock',
                 'log_git_op', 'log_pr', 'log_file_mod', 'log_tool_use',
                 'query', 'cleanup')]
    [string]$Action = 'log',

    # General parameters
    [Parameter(Mandatory=$false)]
    [string]$Message = '',

    [Parameter(Mandatory=$false)]
    [string]$TaskId = '',

    # Worktree parameters
    [Parameter(Mandatory=$false)]
    [string]$Seat = '',

    [Parameter(Mandatory=$false)]
    [string]$Repo = '',

    [Parameter(Mandatory=$false)]
    [string]$Branch = '',

    # Resource lock parameters
    [Parameter(Mandatory=$false)]
    [string]$ResourceType = '',

    [Parameter(Mandatory=$false)]
    [string]$ResourcePath = '',

    # Git operation parameters
    [Parameter(Mandatory=$false)]
    [string]$GitOp = '',

    [Parameter(Mandatory=$false)]
    [string]$CommitSha = '',

    [Parameter(Mandatory=$false)]
    [int]$Success = 1,

    # PR parameters
    [Parameter(Mandatory=$false)]
    [int]$PRNumber = 0,

    [Parameter(Mandatory=$false)]
    [string]$Title = '',

    # File modification parameters
    [Parameter(Mandatory=$false)]
    [string]$FilePath = '',

    [Parameter(Mandatory=$false)]
    [ValidateSet('read', 'write', 'edit', 'delete', '')]
    [string]$FileOp = '',

    [Parameter(Mandatory=$false)]
    [int]$LinesChanged = 0,

    # Tool usage parameters
    [Parameter(Mandatory=$false)]
    [string]$ToolName = '',

    [Parameter(Mandatory=$false)]
    [int]$DurationMs = 0,

    # Query parameters
    [Parameter(Mandatory=$false)]
    [ValidateSet('active_agents', 'all_agents', 'current_tasks', 'unfinished_tasks', 'agent_history', 'stale_agents',
                 'active_worktrees', 'worktree_history', 'active_locks', 'recent_git_ops', 'recent_prs')]
    [string]$Query = 'active_agents',

    [Parameter(Mandatory=$false)]
    [string]$AgentId = '',

    [Parameter(Mandatory=$false)]
    [int]$Limit = 50,

    [Parameter(Mandatory=$false)]
    [string]$Metadata = '{}'
)

$ErrorActionPreference = 'Stop'

# Paths
$DbPath = "C:\scripts\_machine\agent-activity.db"
$AgentIdFile = "C:\scripts\_machine\.current_agent_id"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"
$MachineId = $env:COMPUTERNAME

# Get or create agent ID
function Get-AgentId {
    if ($script:AgentId) {
        return $script:AgentId
    }

    if (Test-Path $AgentIdFile) {
        $script:AgentId = Get-Content $AgentIdFile -Raw | Out-String | ForEach-Object { $_.Trim() }
        return $script:AgentId
    }

    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $random = Get-Random -Minimum 1000 -Maximum 9999
    $script:AgentId = "agent-$timestamp-$random"

    $script:AgentId | Out-File -FilePath $AgentIdFile -Encoding UTF8 -NoNewline

    return $script:AgentId
}

# Execute SQL query
function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

# Register agent
function Register-Agent {
    $agentId = Get-AgentId
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    $exists = Invoke-Sql "SELECT agent_id FROM agents WHERE agent_id='$agentId';"

    if ($exists) {
        Invoke-Sql @"
UPDATE agents
SET last_heartbeat='$now', status='active'
WHERE agent_id='$agentId';
"@
        Write-Host "Agent $agentId reconnected" -ForegroundColor Green
    } else {
        Invoke-Sql @"
INSERT INTO agents (agent_id, machine_id, started_at, last_heartbeat, status, metadata)
VALUES ('$agentId', '$MachineId', '$now', '$now', 'active', '{}');
"@
        Write-Host "Agent $agentId registered" -ForegroundColor Green
    }

    Write-Host "`n Agent ID: $agentId" -ForegroundColor Cyan
    Write-Host "   Saved to: $AgentIdFile`n" -ForegroundColor Gray

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

# Allocate worktree
function Allocate-Worktree {
    param(
        [string]$Seat,
        [string]$Repo,
        [string]$Branch
    )

    if (-not $Seat -or -not $Repo -or -not $Branch) {
        throw "Seat, Repo, and Branch required for allocate_worktree"
    }

    $agentId = Get-AgentId
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    # Check if seat already allocated
    $existing = Invoke-Sql @"
SELECT id FROM worktree_allocations
WHERE seat='$Seat' AND status='active';
"@

    if ($existing) {
        throw "Seat $Seat is already allocated (active allocation exists)"
    }

    # Create allocation
    Invoke-Sql @"
INSERT INTO worktree_allocations (agent_id, seat, repo, branch, allocated_at, status)
VALUES ('$agentId', '$Seat', '$Repo', '$Branch', '$now', 'active');
"@

    # Update agent current seat
    Invoke-Sql @"
UPDATE agents
SET worktree_seat='$Seat'
WHERE agent_id='$agentId';
"@

    # Update heartbeat
    Update-Heartbeat

    Write-Host "Worktree allocated: $Seat ($Repo/$Branch)" -ForegroundColor Green
}

# Release worktree
function Release-Worktree {
    param([string]$Seat)

    $agentId = Get-AgentId
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    if (-not $Seat) {
        # Release current agent's seat
        $Seat = Invoke-Sql "SELECT worktree_seat FROM agents WHERE agent_id='$agentId';"
        if (-not $Seat) {
            Write-Host "No worktree allocated to release" -ForegroundColor Yellow
            return
        }
    }

    # Release allocation
    Invoke-Sql @"
UPDATE worktree_allocations
SET released_at='$now', status='released'
WHERE seat='$Seat' AND agent_id='$agentId' AND status='active';
"@

    # Clear agent seat
    Invoke-Sql @"
UPDATE agents
SET worktree_seat=NULL
WHERE agent_id='$agentId';
"@

    Update-Heartbeat

    Write-Host "Worktree released: $Seat" -ForegroundColor Green
}

# Lock resource
function Lock-Resource {
    param(
        [string]$ResourceType,
        [string]$ResourcePath
    )

    if (-not $ResourceType -or -not $ResourcePath) {
        throw "ResourceType and ResourcePath required for lock_resource"
    }

    $agentId = Get-AgentId
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    # Check if already locked
    $existingLock = Invoke-Sql @"
SELECT agent_id FROM resource_locks
WHERE resource_type='$ResourceType' AND resource_path='$ResourcePath' AND status='locked';
"@

    if ($existingLock) {
        if ($existingLock -eq $agentId) {
            Write-Host "Resource already locked by this agent" -ForegroundColor Yellow
            return
        } else {
            throw "Resource locked by another agent: $existingLock"
        }
    }

    # Create lock
    Invoke-Sql @"
INSERT INTO resource_locks (resource_type, resource_path, agent_id, locked_at, status)
VALUES ('$ResourceType', '$ResourcePath', '$agentId', '$now', 'locked');
"@

    Update-Heartbeat

    Write-Host "Resource locked: $ResourceType $ResourcePath" -ForegroundColor Green
}

# Unlock resource
function Unlock-Resource {
    param(
        [string]$ResourceType,
        [string]$ResourcePath
    )

    if (-not $ResourceType -or -not $ResourcePath) {
        throw "ResourceType and ResourcePath required for unlock_resource"
    }

    $agentId = Get-AgentId
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    # Release lock
    Invoke-Sql @"
UPDATE resource_locks
SET released_at='$now', status='released'
WHERE resource_type='$ResourceType' AND resource_path='$ResourcePath' AND agent_id='$agentId' AND status='locked';
"@

    Update-Heartbeat

    Write-Host "Resource unlocked: $ResourceType $ResourcePath" -ForegroundColor Green
}

# Check if resource is locked
function Check-ResourceLock {
    param(
        [string]$ResourceType,
        [string]$ResourcePath
    )

    $lock = Invoke-Sql @"
SELECT agent_id, locked_at FROM resource_locks
WHERE resource_type='$ResourceType' AND resource_path='$ResourcePath' AND status='locked';
"@

    if ($lock) {
        $parts = $lock -split '\|'
        Write-Host "Resource IS locked by: $($parts[0]) at $($parts[1])" -ForegroundColor Red
        return $true
    } else {
        Write-Host "Resource is NOT locked" -ForegroundColor Green
        return $false
    }
}

# Log git operation
function Log-GitOperation {
    param(
        [string]$GitOp,
        [string]$Repo,
        [string]$Branch,
        [string]$CommitSha,
        [string]$Message,
        [int]$Success
    )

    if (-not $GitOp -or -not $Repo -or -not $Branch) {
        throw "GitOp, Repo, and Branch required for log_git_op"
    }

    $agentId = Get-AgentId
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    $Message = $Message -replace "'", "''"
    $errorMsg = if ($Success -eq 0) { $Message } else { '' }

    Invoke-Sql @"
INSERT INTO git_operations (agent_id, operation, repo, branch, commit_sha, message, timestamp, success, error_message)
VALUES ('$agentId', '$GitOp', '$Repo', '$Branch', '$CommitSha', '$Message', '$now', $Success, '$errorMsg');
"@

    Update-Heartbeat

    Write-Host "Git operation logged: $GitOp on $Repo/$Branch" -ForegroundColor Green
}

# Log PR
function Log-PullRequest {
    param(
        [string]$Repo,
        [int]$PRNumber,
        [string]$Title,
        [string]$Branch,
        [string]$TaskId
    )

    if (-not $Repo -or $PRNumber -eq 0 -or -not $Title -or -not $Branch) {
        throw "Repo, PRNumber, Title, and Branch required for log_pr"
    }

    $agentId = Get-AgentId
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    $Title = $Title -replace "'", "''"

    Invoke-Sql @"
INSERT INTO pull_requests (agent_id, repo, pr_number, title, branch, created_at, status, task_id)
VALUES ('$agentId', '$Repo', $PRNumber, '$Title', '$Branch', '$now', 'open', '$TaskId');
"@

    Update-Heartbeat

    Write-Host "PR logged: #$PRNumber - $Title" -ForegroundColor Green
}

# Log file modification
function Log-FileModification {
    param(
        [string]$FilePath,
        [string]$FileOp,
        [int]$LinesChanged,
        [string]$TaskId
    )

    if (-not $FilePath -or -not $FileOp) {
        throw "FilePath and FileOp required for log_file_mod"
    }

    $agentId = Get-AgentId
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    Invoke-Sql @"
INSERT INTO file_modifications (agent_id, file_path, operation, timestamp, lines_changed, task_id)
VALUES ('$agentId', '$FilePath', '$FileOp', '$now', $LinesChanged, '$TaskId');
"@

    Update-Heartbeat
}

# Log tool usage
function Log-ToolUsage {
    param(
        [string]$ToolName,
        [int]$DurationMs,
        [int]$Success,
        [string]$Message,
        [string]$Metadata
    )

    if (-not $ToolName) {
        throw "ToolName required for log_tool_use"
    }

    $agentId = Get-AgentId
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    $Message = $Message -replace "'", "''"
    $Metadata = $Metadata -replace "'", "''"

    Invoke-Sql @"
INSERT INTO tool_usage (agent_id, tool_name, timestamp, duration_ms, success, error_message, metadata)
VALUES ('$agentId', '$ToolName', '$now', $DurationMs, $Success, '$Message', '$Metadata');
"@

    Update-Heartbeat
}

# Enhanced queries
function Invoke-EnhancedQuery {
    param([string]$QueryType, [int]$Limit = 50)

    switch ($QueryType) {
        'active_worktrees' {
            Write-Host "`nActive Worktree Allocations:" -ForegroundColor Cyan
            $sql = @"
SELECT
    w.seat,
    w.agent_id,
    w.repo,
    w.branch,
    datetime(w.allocated_at) as allocated,
    CAST((julianday('now') - julianday(w.allocated_at)) * 24 * 60 AS INTEGER) as duration_min
FROM worktree_allocations w
WHERE w.status='active'
ORDER BY w.allocated_at DESC;
"@
            $result = Invoke-Sql -Sql $sql
            if ($result) {
                $result | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            } else {
                Write-Host "  No active worktree allocations" -ForegroundColor Gray
            }
        }

        'active_locks' {
            Write-Host "`nActive Resource Locks:" -ForegroundColor Cyan
            $sql = @"
SELECT
    resource_type,
    resource_path,
    agent_id,
    datetime(locked_at) as locked,
    CAST((julianday('now') - julianday(locked_at)) * 24 * 60 AS INTEGER) as duration_min
FROM resource_locks
WHERE status='locked'
ORDER BY locked_at DESC;
"@
            $result = Invoke-Sql -Sql $sql
            if ($result) {
                $result | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            } else {
                Write-Host "  No active resource locks" -ForegroundColor Gray
            }
        }

        'recent_git_ops' {
            Write-Host "`nRecent Git Operations (last $Limit):" -ForegroundColor Cyan
            $sql = @"
SELECT
    agent_id,
    operation,
    repo,
    branch,
    datetime(timestamp) as time,
    CASE success WHEN 1 THEN 'OK' ELSE 'FAIL' END as result
FROM git_operations
ORDER BY timestamp DESC
LIMIT $Limit;
"@
            $result = Invoke-Sql -Sql $sql
            if ($result) {
                $result | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            } else {
                Write-Host "  No git operations" -ForegroundColor Gray
            }
        }

        'recent_prs' {
            Write-Host "`nRecent Pull Requests:" -ForegroundColor Cyan
            $sql = @"
SELECT
    repo,
    pr_number,
    title,
    branch,
    status,
    agent_id,
    datetime(created_at) as created
FROM pull_requests
ORDER BY created_at DESC
LIMIT $Limit;
"@
            $result = Invoke-Sql -Sql $sql
            if ($result) {
                $result | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            } else {
                Write-Host "  No pull requests" -ForegroundColor Gray
            }
        }
    }
}

# Main execution
try {
    # Check if database exists
    if (-not (Test-Path $DbPath)) {
        throw "Database not found. Run agent-logger.ps1 -Action register first."
    }

    switch ($Action) {
        'register' {
            Register-Agent
        }

        'heartbeat' {
            Update-Heartbeat
            Write-Host "Heartbeat updated" -ForegroundColor Green
        }

        'allocate_worktree' {
            Allocate-Worktree -Seat $Seat -Repo $Repo -Branch $Branch
        }

        'release_worktree' {
            Release-Worktree -Seat $Seat
        }

        'lock_resource' {
            Lock-Resource -ResourceType $ResourceType -ResourcePath $ResourcePath
        }

        'unlock_resource' {
            Unlock-Resource -ResourceType $ResourceType -ResourcePath $ResourcePath
        }

        'check_lock' {
            Check-ResourceLock -ResourceType $ResourceType -ResourcePath $ResourcePath
        }

        'log_git_op' {
            Log-GitOperation -GitOp $GitOp -Repo $Repo -Branch $Branch -CommitSha $CommitSha -Message $Message -Success $Success
        }

        'log_pr' {
            Log-PullRequest -Repo $Repo -PRNumber $PRNumber -Title $Title -Branch $Branch -TaskId $TaskId
        }

        'log_file_mod' {
            Log-FileModification -FilePath $FilePath -FileOp $FileOp -LinesChanged $LinesChanged -TaskId $TaskId
        }

        'log_tool_use' {
            Log-ToolUsage -ToolName $ToolName -DurationMs $DurationMs -Success $Success -Message $Message -Metadata $Metadata
        }

        'query' {
            if ($Query -in @('active_worktrees', 'active_locks', 'recent_git_ops', 'recent_prs')) {
                Invoke-EnhancedQuery -QueryType $Query -Limit $Limit
            } else {
                Write-Host "Query type '$Query' not supported in enhanced version. Use agent-logger.ps1 for original queries." -ForegroundColor Yellow
            }
        }

        default {
            Write-Host "Action '$Action' not implemented in enhanced version. Use agent-logger.ps1 for original actions." -ForegroundColor Yellow
        }
    }

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
