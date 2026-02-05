# Phase 3 Integration Guide - Advanced Agent Coordination

## Overview

Phase 3 adds sophisticated coordination, session management, and observability features to the agent activity tracking system.

**New Capabilities:**
- **Agent-to-agent messaging** with broadcast support
- **Session lifecycle tracking** with automatic statistics
- **Structured error tracking** with severity levels
- **Performance metrics** collection and analysis
- **Knowledge capture** via learnings database
- **Comprehensive dashboard** with real-time monitoring
- **Integration wrappers** for existing tools

## New Database Tables (v8-v12)

### v8: agent_messages
Agent-to-agent communication system.

```sql
CREATE TABLE agent_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    from_agent_id TEXT NOT NULL,
    to_agent_id TEXT,              -- NULL = broadcast to all
    message TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    read INTEGER DEFAULT 0,        -- 0=unread, 1=read
    priority INTEGER DEFAULT 5,    -- 1-10 scale
    message_type TEXT DEFAULT 'info'  -- info, warning, error, request
);
```

**Use Cases:**
- Agent announces it's starting work on a feature
- Agent requests help from other agents
- System broadcasts important notifications
- Coordination to avoid conflicts

### v9: sessions
Complete session lifecycle tracking.

```sql
CREATE TABLE sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL UNIQUE,
    agent_id TEXT NOT NULL,
    started_at TEXT NOT NULL,
    ended_at TEXT,
    duration_seconds INTEGER,
    tasks_completed INTEGER DEFAULT 0,
    tasks_failed INTEGER DEFAULT 0,
    exit_reason TEXT,              -- normal, error, timeout, manual
    metadata TEXT DEFAULT '{}'
);
```

**Automatic Tracking:**
- Session start/end timestamps
- Duration calculation
- Task completion statistics
- Exit reason classification

### v10: errors
Structured error logging.

```sql
CREATE TABLE errors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_id TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    error_type TEXT NOT NULL,      -- build_error, runtime_error, timeout, etc.
    error_message TEXT NOT NULL,
    stack_trace TEXT,
    severity TEXT CHECK(severity IN ('warning', 'error', 'critical')),
    context TEXT DEFAULT '{}'      -- JSON with additional details
);
```

**Severity Levels:**
- **warning**: Non-blocking issues
- **error**: Failures that need attention
- **critical**: System-breaking issues

### v11: metrics
Performance metrics and measurements.

```sql
CREATE TABLE metrics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_id TEXT NOT NULL,
    metric_name TEXT NOT NULL,     -- build_time, test_duration, api_latency
    metric_value REAL NOT NULL,
    unit TEXT,                     -- seconds, milliseconds, count, bytes
    timestamp TEXT NOT NULL,
    context TEXT DEFAULT '{}'      -- JSON with measurement context
);
```

**Common Metrics:**
- Build/compile times
- Test execution duration
- Git operation latency
- Tool execution time
- Memory usage

### v12: learnings
Knowledge capture system.

```sql
CREATE TABLE learnings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    agent_id TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    category TEXT NOT NULL,        -- bug_fix, optimization, pattern, architecture
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    tags TEXT,                     -- comma-separated
    confidence INTEGER DEFAULT 5   -- 1-10 scale
);
```

**Learning Categories:**
- **bug_fix**: Solutions to bugs encountered
- **optimization**: Performance improvements discovered
- **pattern**: Reusable code patterns
- **architecture**: Design decisions and rationale

## New Integration Tools

### 1. agent-session.ps1 - Session Manager

**Purpose:** Manage agent sessions with automatic tracking and statistics.

**Actions:**
- `start` - Register agent and start new session
- `heartbeat` - Update session activity timestamp
- `end` - End session with statistics (duration, tasks completed/failed)
- `status` - View current session information

**Examples:**

```powershell
# Start a new session
.\agent-session.ps1 -Action start
# Output:
#   Session started successfully!
#   Agent ID:   agent-20260126235607-1234
#   Session ID: session-20260126235607-9697

# Update heartbeat during long-running work
.\agent-session.ps1 -Action heartbeat

# Check session status
.\agent-session.ps1 -Action status
# Output:
#   Current Session Status:
#   Session ID: session-20260126235607-9697
#   Agent ID:   agent-20260126235607-1234
#   Started:    2026-01-26 23:56:07
#   Duration:   5.2 minutes

# End session with reason
.\agent-session.ps1 -Action end -ExitReason "normal"
# Output:
#   Session ended successfully!
#   Session ID: session-20260126235607-9697
#   Duration: 312 seconds
#   Tasks completed: 5
#   Tasks failed: 0
```

**Integration:**
- Call `agent-session.ps1 -Action start` at beginning of agent script
- Call `agent-session.ps1 -Action heartbeat` periodically during work
- Call `agent-session.ps1 -Action end` when agent completes/exits

### 2. agent-coordinate.ps1 - Coordination Helper

**Purpose:** Multi-agent coordination via messaging and conflict detection.

**Actions:**
- `send_message` - Send message to specific agent
- `broadcast` - Send message to all agents
- `check_messages` - Read unread messages
- `detect_conflicts` - Find conflicts (worktrees, locks, files, stale locks)
- `view_agents` - List active agents with status
- `cleanup_locks` - Release stale resource locks

**Examples:**

```powershell
# Broadcast message to all agents
.\agent-coordinate.ps1 -Action broadcast `
    -Message "Starting work on AuthService.ts" `
    -Priority 7

# Send message to specific agent
.\agent-coordinate.ps1 -Action send_message `
    -ToAgent "agent-20260126235607-1234" `
    -Message "Can you review PR #123?" `
    -Priority 8 `
    -MessageType "request"

# Check for unread messages
.\agent-coordinate.ps1 -Action check_messages
# Output:
#   Unread Messages:
#   ================
#
#   [ P8] From: agent-20260126235607-5678
#     Can you review PR #123?
#     2026-01-26 23:45:12
#
#   All messages marked as read.

# Detect conflicts across system
.\agent-coordinate.ps1 -Action detect_conflicts
# Output:
#   Conflict Detection Report
#   ========================
#
#   WORKTREE CONFLICTS:
#     Seat agent-003: Multiple agents -> agent-001, agent-002
#
#   FILE EDIT CONFLICTS (last hour):
#     File: src/services/AuthService.ts
#       Agents: agent-001, agent-003

# View active agents
.\agent-coordinate.ps1 -Action view_agents
# Output:
#   Active Agents
#   =============
#
#    agent-20260126235607-1234
#     Seat: agent-003 | Task: Refactor AuthService | Active Tasks: 2
#     Last seen: 1min ago

# Clean up stale locks
.\agent-coordinate.ps1 -Action cleanup_locks
# Output:
#   Cleaning up stale locks...
#   Stale locks cleaned up successfully.
```

**Integration Patterns:**

```powershell
# Pattern 1: Announce start of work
.\agent-coordinate.ps1 -Action broadcast `
    -Message "Starting feature: OAuth implementation" `
    -Priority 6

# Pattern 2: Check for conflicts before starting
$conflicts = .\agent-coordinate.ps1 -Action detect_conflicts
if ($conflicts -match "CONFLICT") {
    Write-Host "Conflicts detected! Waiting for resolution..." -ForegroundColor Red
    exit 1
}

# Pattern 3: Request assistance
.\agent-coordinate.ps1 -Action broadcast `
    -Message "Need help: Build failing with EnableWindowsTargeting error" `
    -Priority 9 `
    -MessageType "request"

# Pattern 4: Periodic message check
while ($working) {
    .\agent-coordinate.ps1 -Action check_messages
    Start-Sleep -Seconds 300  # Check every 5 minutes
}
```

### 3. agent-dashboard.ps1 - Comprehensive Dashboard

**Purpose:** Real-time monitoring dashboard showing all agent activity.

**Parameters:**
- `-Watch` - Auto-refresh every 5 seconds
- `-Compact` - Show condensed view (stats only)

**Dashboard Sections:**
1. **Active Agents & Sessions** - Currently running agents with idle time
2. **Tasks In Progress** - Tasks being worked on with duration
3. **Worktree Allocations** - Active worktree assignments
4. **Resource Locks** - Currently locked resources with age
5. **Messages** - Unread message count
6. **Recent Git Operations** - Last 10 git operations with success/failure
7. **Recent Pull Requests** - Last 5 PRs with status
8. **Recent Errors** - Errors from last 24 hours
9. **Statistics** - System-wide counts and metrics

**Examples:**

```powershell
# View dashboard once
.\agent-dashboard.ps1

# Watch mode (auto-refresh every 5 seconds)
.\agent-dashboard.ps1 -Watch

# Compact view (minimal output)
.\agent-dashboard.ps1 -Compact
```

**Sample Output:**

```
================================================================
           MULTI-AGENT COORDINATION DASHBOARD
                   2026-01-26 23:56:13
================================================================

ACTIVE AGENTS & SESSIONS
------------------------
  agent-20260126235607-1234 | Seat: agent-003 | Task: OAuth implementation | Idle: 2m
  agent-20260126235607-5678 | Seat: agent-005 | Task: (idle) | Idle: 15m

TASKS IN PROGRESS
-----------------
  ↑ #123: Implement OAuth 2.0 flow
    Agent: agent-20260126235607-1234 | Duration: 45m

WORKTREE ALLOCATIONS
--------------------
  agent-003: client-manager/feature/oauth-implementation
    Agent: agent-20260126235607-1234 | Age: 47m

RESOURCE LOCKS
---------------------
  [file] src/services/AuthService.ts
    Agent: agent-20260126235607-1234 | Age: 20m

RECENT GIT OPERATIONS (last 10)
--------------------------------
  [OK] commit on client-manager/feature/oauth-implementation
  [OK] push on client-manager/feature/oauth-implementation
  [FAIL] merge on client-manager/develop

RECENT PULL REQUESTS
--------------------
  ↑ #405: Implement OAuth 2.0 authentication flow
    Repo: client-manager | Status: open

RECENT ERRORS (last 24h)
------------------------
  [ERROR] build_error
    MSBuild failed: Missing EnableWindowsTargeting import

STATISTICS
----------
  Active Agents:     2
  Active Sessions:   2
  Active Tasks:      1
  Active Worktrees:  1
  Active Locks:      1
  Open PRs:          3
  Errors (24h):      1
```

### 4. worktree-allocate-tracked.ps1 - Integrated Worktree Allocation

**Purpose:** Wrapper around `worktree-allocate.ps1` with automatic database tracking.

**5-Step Integration Process:**
1. **Check for conflicts** in database (prevent double-allocation)
2. **Allocate physical worktree** using existing tool
3. **Lock repository** to prevent conflicts
4. **Notify other agents** via broadcast message
5. **Log metrics** for performance tracking

**Examples:**

```powershell
# Allocate single repo worktree
.\worktree-allocate-tracked.ps1 `
    -Seat agent-003 `
    -Repo client-manager `
    -Branch feature/oauth

# Allocate paired worktrees (client-manager + hazina)
.\worktree-allocate-tracked.ps1 `
    -Seat agent-003 `
    -Repo client-manager `
    -Branch feature/oauth `
    -Paired
```

**Output:**

```
=== Tracked Worktree Allocation ===

[1/5] Checking for conflicts in database...
[2/5] Allocating physical worktree...
Worktree allocation complete!
  Seat: agent-003
  Repo: client-manager
  Branch: feature/oauth
  Path: C:\Projects\worker-agents\agent-003\client-manager

[3/5] Locking repository...
Resource locked: repository/client-manager/feature/oauth

[4/5] Notifying other agents...
Broadcast message sent to ALL agents (Priority: 5)

[5/5] Logging metrics...

Worktree allocation complete and tracked!
  Seat: agent-003
  Repo: client-manager
  Branch: feature/oauth
  Path: C:\Projects\worker-agents\agent-003\client-manager
```

**Error Handling:**

If seat is already allocated:
```
Error: Seat agent-003 is already allocated to agent-20260126235607-1234
Cannot allocate until released.
```

### 5. git-tracked.ps1 - Git Operations Wrapper

**Purpose:** Wrap git commands with automatic logging and performance tracking.

**Supported Operations:**
- `commit` - Stage all changes and commit
- `push` - Push to remote
- `pull` - Pull from remote
- `merge` - Merge branch
- `checkout` - Switch branch
- `rebase` - Rebase onto branch
- `add` - Stage files
- `status` - Show status

**Examples:**

```powershell
# Commit with message
.\git-tracked.ps1 -Operation commit -Message "feat: Add OAuth 2.0 support"

# Push to origin
.\git-tracked.ps1 -Operation push -Remote origin -Branch feature/oauth

# Pull latest changes
.\git-tracked.ps1 -Operation pull

# Merge develop into current branch
.\git-tracked.ps1 -Operation merge -Branch develop

# Checkout branch
.\git-tracked.ps1 -Operation checkout -Branch feature/oauth

# Git status
.\git-tracked.ps1 -Operation status
```

**Automatic Tracking:**
- **Git operation** logged to `git_operations` table with success/failure
- **Performance metric** logged to `metrics` table (duration in ms)
- **Commit SHA** captured (for commit, push, pull, merge, rebase)
- **Error messages** logged on failure

**Output:**

```powershell
# Successful commit
PS> .\git-tracked.ps1 -Operation commit -Message "feat: Add OAuth"
Git commit on client-manager/feature/oauth...
Committed: a1b2c3d4e5f6g7h8i9j0
Git operation logged: commit on client-manager/feature/oauth

# Failed operation
PS> .\git-tracked.ps1 -Operation push
Git push on client-manager/feature/oauth...
Git operation failed: Push rejected (non-fast-forward)
```

**Database Records Created:**

After each operation:
- `git_operations` table: operation type, repo, branch, commit SHA, success/failure, error message
- `metrics` table: `git_{operation}_duration` with milliseconds

**Query Examples:**

```powershell
# View all git operations today
echo "SELECT * FROM git_operations WHERE date(timestamp) = date('now');" | sqlite3 agent-activity.db

# Find failed operations
echo "SELECT * FROM git_operations WHERE success=0;" | sqlite3 agent-activity.db

# Average push time
echo "SELECT AVG(metric_value) FROM metrics WHERE metric_name='git_push_duration';" | sqlite3 agent-activity.db
```

## Integration with Existing Workflow

### Pattern 1: Full Agent Session

```powershell
# 1. Start session
.\agent-session.ps1 -Action start

# 2. Check for conflicts
.\agent-coordinate.ps1 -Action detect_conflicts

# 3. Allocate worktree with tracking
.\worktree-allocate-tracked.ps1 -Seat agent-003 -Repo client-manager -Branch feature/oauth

# 4. Do work...
cd C:\Projects\worker-agents\agent-003\client-manager
# ... edit files ...

# 5. Commit with tracking
.\git-tracked.ps1 -Operation commit -Message "feat: Implement OAuth"

# 6. Push with tracking
.\git-tracked.ps1 -Operation push

# 7. Release worktree
.\agent-logger-enhanced.ps1 -Action release_worktree -Seat agent-003

# 8. End session
.\agent-session.ps1 -Action end -ExitReason "normal"
```

### Pattern 2: Error Handling

```powershell
try {
    # Attempt git operation
    .\git-tracked.ps1 -Operation push

} catch {
    # Log error to database
    .\agent-logger-enhanced.ps1 -Action log_error `
        -ErrorType "git_push_failed" `
        -ErrorMessage $_.Exception.Message `
        -Severity "error"

    # Notify other agents
    .\agent-coordinate.ps1 -Action broadcast `
        -Message "Push failed: $($_.Exception.Message)" `
        -Priority 8 `
        -MessageType "error"

    exit 1
}
```

### Pattern 3: Performance Monitoring

```powershell
# Track tool execution time
$start = Get-Date

# Run tool
& some-expensive-tool.ps1

$duration = ((Get-Date) - $start).TotalMilliseconds

# Log metric
.\agent-logger-enhanced.ps1 -Action log_metric `
    -MetricName "tool_execution_time" `
    -MetricValue $duration `
    -Unit "milliseconds"
```

### Pattern 4: Knowledge Capture

```powershell
# After solving a bug
.\agent-logger-enhanced.ps1 -Action log_learning `
    -Category "bug_fix" `
    -Title "EnableWindowsTargeting import missing" `
    -Description "Add Microsoft.NET.Sdk.WindowsDesktop to Directory.Packages.props" `
    -Tags "build,msbuild,windows" `
    -Confidence 9
```

## Querying the Database

### Active Agents
```sql
SELECT a.agent_id, a.status, a.current_task,
       CAST((julianday('now') - julianday(a.last_heartbeat)) * 24 * 60 AS INTEGER) as idle_minutes
FROM agents a
WHERE a.status='active'
  AND datetime(a.last_heartbeat) > datetime('now', '-10 minutes')
ORDER BY a.last_heartbeat DESC;
```

### Session Statistics
```sql
SELECT
    COUNT(*) as total_sessions,
    AVG(duration_seconds) as avg_duration,
    SUM(tasks_completed) as total_tasks_completed,
    SUM(tasks_failed) as total_tasks_failed
FROM sessions
WHERE date(started_at) = date('now');
```

### Error Analysis
```sql
SELECT error_type, COUNT(*) as count, severity
FROM errors
WHERE datetime(timestamp) > datetime('now', '-1 day')
GROUP BY error_type, severity
ORDER BY count DESC;
```

### Performance Metrics
```sql
SELECT metric_name,
       AVG(metric_value) as avg_value,
       MIN(metric_value) as min_value,
       MAX(metric_value) as max_value,
       unit
FROM metrics
WHERE datetime(timestamp) > datetime('now', '-1 day')
GROUP BY metric_name
ORDER BY avg_value DESC;
```

### Conflict Detection
```sql
-- Worktree conflicts (multiple agents on same seat)
SELECT seat, GROUP_CONCAT(agent_id, ', ') as agents
FROM worktree_allocations
WHERE status='active'
GROUP BY seat
HAVING COUNT(*) > 1;

-- File edit conflicts (multiple agents editing same file recently)
SELECT file_path, GROUP_CONCAT(agent_id, ', ') as agents
FROM file_modifications
WHERE datetime(timestamp) > datetime('now', '-1 hour')
  AND operation IN ('write', 'edit')
GROUP BY file_path
HAVING COUNT(DISTINCT agent_id) > 1;

-- Stale locks (locked >1 hour by terminated agent)
SELECT resource_type, resource_path, agent_id,
       CAST((julianday('now') - julianday(locked_at)) * 24 * 60 AS INTEGER) as age_minutes
FROM resource_locks r
JOIN agents a ON a.agent_id = r.agent_id
WHERE r.status='locked'
  AND a.status='terminated'
  AND datetime(locked_at) < datetime('now', '-1 hour');
```

### Learnings Retrieval
```sql
-- Find learnings by category
SELECT title, description, tags, confidence
FROM learnings
WHERE category='bug_fix'
  AND confidence >= 7
ORDER BY timestamp DESC
LIMIT 10;

-- Find learnings by tag
SELECT title, description, category, confidence
FROM learnings
WHERE tags LIKE '%build%'
ORDER BY confidence DESC, timestamp DESC;
```

## Dashboard Usage Recommendations

### Development Session Monitoring

1. **Start session** with dashboard in watch mode:
   ```powershell
   # Terminal 1: Start dashboard
   .\agent-dashboard.ps1 -Watch

   # Terminal 2: Work normally
   .\agent-session.ps1 -Action start
   # ... do work ...
   ```

2. **Monitor for conflicts** when multiple agents running:
   ```powershell
   .\agent-coordinate.ps1 -Action detect_conflicts
   ```

3. **Check messages** periodically:
   ```powershell
   .\agent-coordinate.ps1 -Action check_messages
   ```

### Post-Session Analysis

After session ends, analyze:
- **Session duration**: How long did work take?
- **Task completion rate**: Tasks completed vs failed
- **Error frequency**: What errors occurred?
- **Performance bottlenecks**: Which operations were slow?
- **Learnings captured**: What was discovered?

Query examples:
```powershell
# Show session summary
echo "SELECT * FROM sessions ORDER BY started_at DESC LIMIT 1;" | sqlite3 agent-activity.db

# Show errors from session
echo "SELECT * FROM errors WHERE timestamp >= (SELECT started_at FROM sessions ORDER BY started_at DESC LIMIT 1);" | sqlite3 agent-activity.db

# Show metrics from session
echo "SELECT metric_name, AVG(metric_value) as avg FROM metrics WHERE timestamp >= (SELECT started_at FROM sessions ORDER BY started_at DESC LIMIT 1) GROUP BY metric_name;" | sqlite3 agent-activity.db
```

## Maintenance

### Database Cleanup

Over time, database can grow large. Periodically clean up old data:

```sql
-- Delete old sessions (>30 days)
DELETE FROM sessions WHERE datetime(started_at) < datetime('now', '-30 days');

-- Delete old activity logs (>30 days)
DELETE FROM activity_log WHERE datetime(timestamp) < datetime('now', '-30 days');

-- Delete old errors (>7 days)
DELETE FROM errors WHERE datetime(timestamp) < datetime('now', '-7 days') AND severity != 'critical';

-- Delete old metrics (>7 days)
DELETE FROM metrics WHERE datetime(timestamp) < datetime('now', '-7 days');

-- Vacuum database to reclaim space
VACUUM;
```

**Recommended Script:**

```powershell
# cleanup-database.ps1
$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

$cleanupSql = @"
DELETE FROM sessions WHERE datetime(started_at) < datetime('now', '-30 days');
DELETE FROM activity_log WHERE datetime(timestamp) < datetime('now', '-30 days');
DELETE FROM errors WHERE datetime(timestamp) < datetime('now', '-7 days') AND severity != 'critical';
DELETE FROM metrics WHERE datetime(timestamp) < datetime('now', '-7 days');
VACUUM;
"@

$cleanupSql | & $SqlitePath $DbPath

Write-Host "Database cleanup complete" -ForegroundColor Green
```

### Conflict Resolution

If conflicts are detected:

1. **Worktree conflicts**: Manually inspect which agent should keep allocation, release others
2. **Lock conflicts**: Use `cleanup_locks` to clear stale locks
3. **File conflicts**: Coordinate via messages to determine ownership

## Best Practices

### 1. Always Start and End Sessions

```powershell
# At beginning of agent script
.\agent-session.ps1 -Action start

# At end (use try/finally for reliability)
try {
    # ... agent work ...
} finally {
    .\agent-session.ps1 -Action end -ExitReason "normal"
}
```

### 2. Use Tracked Wrappers

Instead of:
```powershell
worktree-allocate.ps1 -Seat agent-003 -Repo client-manager -Branch feature/x
git commit -m "feat: Add feature"
```

Use:
```powershell
worktree-allocate-tracked.ps1 -Seat agent-003 -Repo client-manager -Branch feature/x
git-tracked.ps1 -Operation commit -Message "feat: Add feature"
```

### 3. Log Important Metrics

Track performance of critical operations:
```powershell
$start = Get-Date
# ... expensive operation ...
$duration = ((Get-Date) - $start).TotalMilliseconds

.\agent-logger-enhanced.ps1 -Action log_metric `
    -MetricName "critical_operation_duration" `
    -MetricValue $duration `
    -Unit "milliseconds"
```

### 4. Capture Learnings

When you discover a solution:
```powershell
.\agent-logger-enhanced.ps1 -Action log_learning `
    -Category "bug_fix" `
    -Title "Short description" `
    -Description "Detailed explanation with steps to reproduce and fix" `
    -Tags "relevant,tags,here" `
    -Confidence 8
```

### 5. Check Messages Regularly

In long-running agents:
```powershell
while ($working) {
    # Do work...

    # Check for messages every 5 minutes
    .\agent-coordinate.ps1 -Action check_messages
    Start-Sleep -Seconds 300
}
```

### 6. Announce Important Work

Before starting major work:
```powershell
.\agent-coordinate.ps1 -Action broadcast `
    -Message "Starting refactor of AuthService - will modify 15+ files" `
    -Priority 7
```

### 7. Use Dashboard for Monitoring

When multiple agents are running:
```powershell
# Keep dashboard open in watch mode
.\agent-dashboard.ps1 -Watch
```

## Troubleshooting

### Issue: Session not starting

**Symptom:** `agent-session.ps1 -Action start` fails

**Solution:**
1. Check if `agent-logger.ps1` is working: `.\agent-logger.ps1 -Action register`
2. Verify database exists: `Test-Path C:\scripts\_machine\agent-activity.db`
3. Check SQLite is accessible: `& "C:\scripts\_machine\sqlite3.exe" --version`

### Issue: Dashboard shows negative idle times

**Symptom:** Dashboard shows `-59m` for idle time

**Cause:** System clock differences or timezone issues

**Solution:** Ensure all timestamps use UTC. Update heartbeat:
```powershell
.\agent-session.ps1 -Action heartbeat
```

### Issue: Messages not appearing

**Symptom:** `check_messages` shows no messages after `send_message`

**Solution:**
1. Verify agent ID is correct: `cat C:\scripts\_machine\.current_agent_id`
2. Query database directly: `echo "SELECT * FROM agent_messages WHERE read=0;" | sqlite3 agent-activity.db`
3. Check message was sent: `echo "SELECT * FROM agent_messages ORDER BY timestamp DESC LIMIT 1;" | sqlite3 agent-activity.db`

### Issue: Worktree allocation conflicts

**Symptom:** `worktree-allocate-tracked.ps1` says seat is already allocated

**Solution:**
1. Check database: `echo "SELECT * FROM worktree_allocations WHERE status='active';" | sqlite3 agent-activity.db`
2. If stale, release manually: `.\agent-logger-enhanced.ps1 -Action release_worktree -Seat agent-XXX`
3. Verify worktrees.pool.md matches database state

### Issue: Dashboard not showing recent data

**Symptom:** Dashboard shows old or no data

**Solution:**
1. Verify heartbeat is updating: `.\agent-session.ps1 -Action heartbeat`
2. Check agent is registered as active: `echo "SELECT * FROM agents WHERE status='active';" | sqlite3 agent-activity.db`
3. Ensure timestamps are recent (within 10 minutes)

## Summary

Phase 3 provides:
- ✅ **Agent coordination** via messaging system
- ✅ **Session lifecycle** tracking with statistics
- ✅ **Error tracking** with severity classification
- ✅ **Performance monitoring** via metrics
- ✅ **Knowledge capture** through learnings database
- ✅ **Comprehensive dashboard** for real-time monitoring
- ✅ **Integration wrappers** for seamless workflow adoption

**Total Database Tables:** 16 (v1-v12)
**Total Scripts:** 10+ integration tools
**Schema Version:** 12

For complete details on Phase 1 & 2, see `ENHANCED_TRACKING_GUIDE.md`.
