# Enhanced SQLite Agent Tracking - Complete Guide

**Created:** 2026-01-26
**Schema Version:** 7
**Purpose:** Comprehensive multi-agent coordination with conflict prevention

## What's New

### Original Features (v1)
- ✅ **Agents** - Track active agents with heartbeat
- ✅ **Tasks** - Task management and assignment
- ✅ **Activity Log** - Complete audit trail

### Phase 1 Enhancements (v2-v4)
- ✅ **Worktree Allocations** (v2) - Track seat usage and history
- ✅ **Resource Locks** (v3) - Prevent file/resource conflicts
- ✅ **Git Operations** (v4) - Complete git audit trail

### Phase 2 Enhancements (v5-v7)
- ✅ **Pull Requests** (v5) - Link PRs to tasks and agents
- ✅ **File Modifications** (v6) - Track what files agents edit
- ✅ **Tool Usage** (v7) - Analytics on tool effectiveness

## Quick Start

### 1. Migrate Existing Database

```powershell
# Run migration (adds new tables)
.\agent-logger-migrate.ps1

# Check current schema version
.\agent-logger-migrate.ps1 -DryRun
```

### 2. Start Using Enhanced Features

```powershell
# Allocate a worktree
.\agent-logger-enhanced.ps1 -Action allocate_worktree `
    -Seat agent-003 `
    -Repo client-manager `
    -Branch feature/oauth

# Lock a file before editing
.\agent-logger-enhanced.ps1 -Action lock_resource `
    -ResourceType file `
    -ResourcePath "src/services/AuthService.ts"

# Edit the file...

# Unlock when done
.\agent-logger-enhanced.ps1 -Action unlock_resource `
    -ResourceType file `
    -ResourcePath "src/services/AuthService.ts"

# Log git operations
.\agent-logger-enhanced.ps1 -Action log_git_op `
    -GitOp commit `
    -Repo client-manager `
    -Branch feature/oauth `
    -CommitSha abc1234 `
    -Message "feat: Add OAuth authentication" `
    -Success 1

# Log PR creation
.\agent-logger-enhanced.ps1 -Action log_pr `
    -Repo client-manager `
    -PRNumber 123 `
    -Title "Add OAuth authentication" `
    -Branch feature/oauth `
    -TaskId "TASK-001"

# Log file modifications
.\agent-logger-enhanced.ps1 -Action log_file_mod `
    -FilePath "src/services/AuthService.ts" `
    -FileOp edit `
    -LinesChanged 45 `
    -TaskId "TASK-001"

# Log tool usage
.\agent-logger-enhanced.ps1 -Action log_tool_use `
    -ToolName "worktree-allocate.ps1" `
    -DurationMs 1500 `
    -Success 1

# Release worktree
.\agent-logger-enhanced.ps1 -Action release_worktree -Seat agent-003
```

### 3. Query Enhanced Data

```powershell
# View active worktree allocations
.\agent-logger-enhanced.ps1 -Action query -Query active_worktrees

# Check active resource locks
.\agent-logger-enhanced.ps1 -Action query -Query active_locks

# See recent git operations
.\agent-logger-enhanced.ps1 -Action query -Query recent_git_ops

# View recent PRs
.\agent-logger-enhanced.ps1 -Action query -Query recent_prs
```

## Integration Patterns

### Pattern 1: Worktree Workflow Integration

**Before (manual tracking):**
```powershell
# Allocate worktree manually
# Update worktrees.pool.md manually
# Hope no conflicts occur
```

**After (automatic tracking):**
```powershell
# In worktree-allocate.ps1, add:
.\agent-logger-enhanced.ps1 -Action allocate_worktree `
    -Seat $Seat `
    -Repo $Repo `
    -Branch $Branch

# Automatic conflict detection!
# If seat already allocated, script fails
```

### Pattern 2: File Edit Safety

**Prevent Multiple Agents Editing Same File:**

```powershell
# Agent 1: Lock file before editing
.\agent-logger-enhanced.ps1 -Action lock_resource `
    -ResourceType file `
    -ResourcePath "src/App.tsx"

# Edit file...

# Agent 2: Try to lock same file
.\agent-logger-enhanced.ps1 -Action lock_resource `
    -ResourceType file `
    -ResourcePath "src/App.tsx"
# ERROR: Resource locked by another agent!

# Agent 1: Unlock when done
.\agent-logger-enhanced.ps1 -Action unlock_resource `
    -ResourceType file `
    -ResourcePath "src/App.tsx"
```

### Pattern 3: Git Operation Tracking

**Wrap Git Commands:**

```powershell
# In your git commit wrapper
$commitSha = git rev-parse HEAD
$branch = git rev-parse --abbrev-ref HEAD

.\agent-logger-enhanced.ps1 -Action log_git_op `
    -GitOp commit `
    -Repo client-manager `
    -Branch $branch `
    -CommitSha $commitSha `
    -Message "feat: Add feature" `
    -Success 1
```

### Pattern 4: PR Lifecycle Tracking

**Auto-log PR creation:**

```powershell
# After gh pr create
$prNumber = 123  # extracted from gh output

.\agent-logger-enhanced.ps1 -Action log_pr `
    -Repo client-manager `
    -PRNumber $prNumber `
    -Title $title `
    -Branch $branch `
    -TaskId $currentTaskId
```

### Pattern 5: Tool Performance Analytics

**Measure tool effectiveness:**

```powershell
$start = Get-Date

# Run tool
.\some-tool.ps1

$duration = ((Get-Date) - $start).TotalMilliseconds

.\agent-logger-enhanced.ps1 -Action log_tool_use `
    -ToolName "some-tool.ps1" `
    -DurationMs $duration `
    -Success 1
```

## Database Schema Reference

### worktree_allocations
```sql
CREATE TABLE worktree_allocations (
    id INTEGER PRIMARY KEY,
    agent_id TEXT NOT NULL,
    seat TEXT NOT NULL,              -- agent-001, agent-002
    repo TEXT NOT NULL,               -- client-manager, hazina
    branch TEXT NOT NULL,             -- feature/x
    allocated_at TEXT NOT NULL,       -- ISO timestamp
    released_at TEXT,                 -- ISO timestamp or NULL
    status TEXT NOT NULL,             -- active, released, abandoned
    notes TEXT
);
```

**Usage:**
- Track which agent has which worktree
- Prevent double-allocation
- Detect abandoned worktrees (allocated but agent terminated)
- Worktree utilization analytics

### resource_locks
```sql
CREATE TABLE resource_locks (
    id INTEGER PRIMARY KEY,
    resource_type TEXT NOT NULL,      -- file, database, service
    resource_path TEXT NOT NULL,      -- src/app.ts
    agent_id TEXT NOT NULL,
    locked_at TEXT NOT NULL,
    released_at TEXT,
    status TEXT NOT NULL              -- locked, released
);
```

**Usage:**
- Prevent simultaneous file edits
- Lock shared resources (databases, APIs)
- Detect deadlocks (multiple locks by same agent)
- Automatic lock release on agent termination

### git_operations
```sql
CREATE TABLE git_operations (
    id INTEGER PRIMARY KEY,
    agent_id TEXT NOT NULL,
    operation TEXT NOT NULL,          -- commit, push, pull, merge
    repo TEXT NOT NULL,
    branch TEXT NOT NULL,
    commit_sha TEXT,
    message TEXT,
    timestamp TEXT NOT NULL,
    success INTEGER NOT NULL,         -- 0 or 1
    error_message TEXT
);
```

**Usage:**
- Complete git audit trail
- Debug "who committed what when"
- Track failed operations
- Repository activity analytics

### pull_requests
```sql
CREATE TABLE pull_requests (
    id INTEGER PRIMARY KEY,
    agent_id TEXT NOT NULL,
    repo TEXT NOT NULL,
    pr_number INTEGER NOT NULL,
    title TEXT NOT NULL,
    branch TEXT NOT NULL,
    created_at TEXT NOT NULL,
    merged_at TEXT,
    closed_at TEXT,
    status TEXT NOT NULL,             -- open, merged, closed
    task_id TEXT
);
```

**Usage:**
- Link PRs to tasks
- Track PR lifecycle
- Measure time-to-merge
- Agent productivity metrics

### file_modifications
```sql
CREATE TABLE file_modifications (
    id INTEGER PRIMARY KEY,
    agent_id TEXT NOT NULL,
    file_path TEXT NOT NULL,
    operation TEXT NOT NULL,          -- read, write, edit, delete
    timestamp TEXT NOT NULL,
    lines_changed INTEGER,
    task_id TEXT
);
```

**Usage:**
- Track what files agents touch
- Detect conflict-prone files
- Code ownership tracking
- Productivity analytics (lines changed per agent)

### tool_usage
```sql
CREATE TABLE tool_usage (
    id INTEGER PRIMARY KEY,
    agent_id TEXT NOT NULL,
    tool_name TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    duration_ms INTEGER,
    success INTEGER NOT NULL,
    error_message TEXT,
    metadata TEXT DEFAULT '{}'
);
```

**Usage:**
- Tool effectiveness measurement
- Identify slow/failing tools
- Usage frequency analytics
- Performance optimization targets

## Advanced Queries

### Find Conflict-Prone Files
```sql
SELECT
    file_path,
    COUNT(DISTINCT agent_id) as agent_count,
    COUNT(*) as modification_count
FROM file_modifications
WHERE datetime(timestamp) > datetime('now', '-7 days')
GROUP BY file_path
HAVING agent_count > 1
ORDER BY modification_count DESC;
```

### Agent Productivity Report
```sql
SELECT
    a.agent_id,
    COUNT(DISTINCT t.task_id) as tasks_completed,
    COUNT(DISTINCT pr.pr_number) as prs_created,
    SUM(fm.lines_changed) as total_lines_changed,
    COUNT(DISTINCT DATE(a.timestamp)) as active_days
FROM agents a
LEFT JOIN tasks t ON t.assigned_to = a.agent_id AND t.status = 'completed'
LEFT JOIN pull_requests pr ON pr.agent_id = a.agent_id
LEFT JOIN file_modifications fm ON fm.agent_id = a.agent_id
WHERE datetime(a.started_at) > datetime('now', '-30 days')
GROUP BY a.agent_id
ORDER BY tasks_completed DESC;
```

### Worktree Utilization
```sql
SELECT
    seat,
    COUNT(*) as total_allocations,
    SUM(CASE WHEN status='active' THEN 1 ELSE 0 END) as currently_active,
    AVG((julianday(COALESCE(released_at, datetime('now'))) - julianday(allocated_at)) * 24 * 60) as avg_duration_minutes
FROM worktree_allocations
GROUP BY seat
ORDER BY total_allocations DESC;
```

### Tool Performance Ranking
```sql
SELECT
    tool_name,
    COUNT(*) as usage_count,
    AVG(duration_ms) as avg_duration_ms,
    SUM(CASE WHEN success=1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as success_rate
FROM tool_usage
GROUP BY tool_name
ORDER BY usage_count DESC;
```

## Best Practices

### 1. Always Lock Before Edit
```powershell
# BAD: Edit without locking
Edit-File "src/app.ts"

# GOOD: Lock, edit, unlock
.\agent-logger-enhanced.ps1 -Action lock_resource -ResourceType file -ResourcePath "src/app.ts"
Edit-File "src/app.ts"
.\agent-logger-enhanced.ps1 -Action unlock_resource -ResourceType file -ResourcePath "src/app.ts"
```

### 2. Log All Git Operations
```powershell
# In your git wrapper scripts
function Git-Commit {
    param([string]$Message)

    $result = git commit -m $Message
    $success = if ($LASTEXITCODE -eq 0) { 1 } else { 0 }
    $sha = if ($success) { git rev-parse HEAD } else { "" }

    .\agent-logger-enhanced.ps1 -Action log_git_op `
        -GitOp commit `
        -Repo (Get-CurrentRepo) `
        -Branch (Get-CurrentBranch) `
        -CommitSha $sha `
        -Message $Message `
        -Success $success
}
```

### 3. Release Worktrees Immediately After PR
```powershell
# Create PR
gh pr create --title "..." --body "..."

# Log PR
.\agent-logger-enhanced.ps1 -Action log_pr -Repo ... -PRNumber ... -Title ... -Branch ...

# Release worktree IMMEDIATELY
.\agent-logger-enhanced.ps1 -Action release_worktree -Seat agent-003
```

### 4. Track Tool Usage for Analytics
```powershell
function Invoke-ToolWithTracking {
    param([string]$ToolPath, [array]$Arguments)

    $start = Get-Date
    $toolName = Split-Path $ToolPath -Leaf

    try {
        & $ToolPath @Arguments
        $success = if ($LASTEXITCODE -eq 0) { 1 } else { 0 }
    } catch {
        $success = 0
        $errorMsg = $_.Exception.Message
    } finally {
        $duration = ((Get-Date) - $start).TotalMilliseconds

        .\agent-logger-enhanced.ps1 -Action log_tool_use `
            -ToolName $toolName `
            -DurationMs $duration `
            -Success $success `
            -Message $errorMsg
    }
}
```

## Troubleshooting

### Stuck Locks

**Problem:** Resource locked by terminated agent

**Solution:**
```sql
-- Find stuck locks (>1 hour, agent terminated)
SELECT * FROM resource_locks
WHERE status='locked'
AND datetime(locked_at) < datetime('now', '-1 hour')
AND agent_id IN (SELECT agent_id FROM agents WHERE status='terminated');

-- Manually release
UPDATE resource_locks
SET status='released', released_at=datetime('now')
WHERE id = <lock_id>;
```

### Abandoned Worktrees

**Problem:** Worktree allocated but agent crashed

**Solution:**
```sql
-- Find abandoned worktrees
SELECT * FROM worktree_allocations w
WHERE w.status='active'
AND w.agent_id IN (SELECT agent_id FROM agents WHERE status='terminated');

-- Mark as abandoned
UPDATE worktree_allocations
SET status='abandoned'
WHERE id = <allocation_id>;
```

### Database Locked

**Problem:** "Database is locked" error

**Solution:**
- Another agent has an active write
- Wait a moment and retry
- Check for zombie processes: `Get-Process sqlite3`
- Kill if necessary: `Stop-Process -Name sqlite3`

## Migration from Markdown Logs

### Old System (worktrees.pool.md)
```markdown
| Seat | Status | Repo | Branch |
|------|--------|------|--------|
| agent-001 | BUSY | client-manager | feature/oauth |
```

### New System (SQLite)
```sql
SELECT seat, status, repo, branch FROM worktree_allocations WHERE status='active';
```

**Advantages:**
- ✅ Queryable with SQL
- ✅ Automatic conflict detection
- ✅ Historical data preserved
- ✅ Multi-agent safe (ACID transactions)
- ✅ Indexes for fast queries

## Future Enhancements (Phase 3)

Planned for future releases:

### Agent Messages (v8)
```sql
CREATE TABLE agent_messages (
    id INTEGER PRIMARY KEY,
    from_agent_id TEXT NOT NULL,
    to_agent_id TEXT,  -- NULL = broadcast
    message TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    read INTEGER DEFAULT 0,
    priority INTEGER DEFAULT 5
);
```

### Session Metadata (v9)
```sql
CREATE TABLE sessions (
    id INTEGER PRIMARY KEY,
    agent_id TEXT NOT NULL,
    started_at TEXT NOT NULL,
    ended_at TEXT,
    duration_seconds INTEGER,
    tasks_completed INTEGER DEFAULT 0,
    exit_reason TEXT
);
```

### Error Tracking (v10)
```sql
CREATE TABLE errors (
    id INTEGER PRIMARY KEY,
    agent_id TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    error_type TEXT NOT NULL,
    error_message TEXT NOT NULL,
    stack_trace TEXT,
    severity TEXT
);
```

## See Also

- **AGENT_LOGGER_README.md** - Original logging system documentation
- **PARALLEL_AGENT_COORDINATION_QUICKSTART.md** - Multi-agent coordination protocol
- **worktree-workflow.md** - Worktree management guide

---

**Questions?** Check the enhanced dashboard: `.\query-agent-activity.ps1 -Action dashboard`
