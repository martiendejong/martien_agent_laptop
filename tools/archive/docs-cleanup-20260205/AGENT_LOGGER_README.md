# Agent Activity Logger - SQLite-Based Multi-Agent Coordination

**Created:** 2026-01-26
**Purpose:** Structured activity logging and coordination for multiple Claude agents

## Overview

This system provides a SQLite database for tracking agent activities, tasks, and coordination across multiple concurrent Claude sessions. It replaces the limitation of markdown-based logs with queryable, structured data.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  Agent Activity Database                     │
│                 (agent-activity.db - SQLite)                 │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────┐  ┌──────────────────┐  ┌────────────────┐ │
│  │   agents    │  │  activity_log    │  │     tasks      │ │
│  │             │  │                  │  │                │ │
│  │ - agent_id  │  │ - id             │  │ - task_id      │ │
│  │ - status    │  │ - agent_id       │  │ - title        │ │
│  │ - task      │  │ - action_type    │  │ - status       │ │
│  │ - heartbeat │  │ - message        │  │ - assigned_to  │ │
│  │ - seat      │  │ - timestamp      │  │ - priority     │ │
│  └─────────────┘  └──────────────────┘  └────────────────┘ │
│                                                               │
└─────────────────────────────────────────────────────────────┘
        ▲                        ▲                      ▲
        │                        │                      │
        │                        │                      │
   ┌────┴─────┐            ┌─────┴──────┐        ┌─────┴──────┐
   │ Agent 1  │            │  Agent 2   │        │  Agent 3   │
   │ (Claude) │            │  (Claude)  │        │  (Claude)  │
   └──────────┘            └────────────┘        └────────────┘
```

## Database Schema

### Table: `agents`
Tracks all active and historical agents.

| Column | Type | Description |
|--------|------|-------------|
| agent_id | TEXT PRIMARY KEY | Unique agent identifier (auto-generated) |
| machine_id | TEXT | Computer name (supports multi-machine) |
| session_id | TEXT | Optional session identifier |
| started_at | TEXT | ISO timestamp when agent started |
| last_heartbeat | TEXT | ISO timestamp of last activity |
| status | TEXT | active, idle, terminated |
| current_task | TEXT | Task ID currently being worked on |
| worktree_seat | TEXT | Allocated worktree (agent-001, agent-002, etc) |
| metadata | TEXT | JSON metadata |

### Table: `activity_log`
Comprehensive log of all agent actions.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PRIMARY KEY | Auto-increment |
| agent_id | TEXT | Foreign key to agents |
| timestamp | TEXT | ISO timestamp of action |
| action_type | TEXT | register, log, start_task, complete_task, etc |
| message | TEXT | Human-readable message |
| task_id | TEXT | Optional task reference |
| metadata | TEXT | JSON metadata |

### Table: `tasks`
Task tracking and assignment.

| Column | Type | Description |
|--------|------|-------------|
| task_id | TEXT PRIMARY KEY | Unique task identifier |
| title | TEXT | Task title |
| description | TEXT | Detailed description |
| status | TEXT | pending, in_progress, completed, blocked |
| assigned_to | TEXT | Agent ID (FK to agents) |
| created_at | TEXT | ISO timestamp |
| started_at | TEXT | When work began |
| completed_at | TEXT | When completed |
| priority | INTEGER | 1-10 (higher = more urgent) |
| metadata | TEXT | JSON metadata |

## Core Tools

### 1. `agent-logger.ps1` - Core Logging Engine

**Purpose:** Register agents, log activities, manage tasks, query database

**Actions:**
- `register` - Register/reconnect agent, get unique ID
- `heartbeat` - Update agent heartbeat (keep alive)
- `log` - Log arbitrary activity
- `start_task` - Create and start a task
- `complete_task` - Mark task as completed
- `block_task` - Mark task as blocked
- `query` - Query database (active_agents, tasks, history, etc)
- `cleanup` - Terminate stale agents (>10min no heartbeat)

**Examples:**
```powershell
# Register agent and get ID
.\agent-logger.ps1 -Action register

# Log activity
.\agent-logger.ps1 -Action log -Message "Allocating worktree for client-manager"

# Start a task
.\agent-logger.ps1 -Action start_task -Message "Implement OAuth integration" -TaskId "TASK-001"

# Complete task
.\agent-logger.ps1 -Action complete_task -TaskId "TASK-001"

# Query active agents
.\agent-logger.ps1 -Action query -Query active_agents

# Find unfinished tasks
.\agent-logger.ps1 -Action query -Query unfinished_tasks
```

### 2. `query-agent-activity.ps1` - Dashboard & Reporting

**Purpose:** User-friendly queries with formatted output

**Actions:**
- `dashboard` - Comprehensive overview of all activity
- `agents` - List all agents
- `tasks` - List all tasks
- `history` - Show activity history for specific agent
- `unfinished` - Show unfinished tasks (available for pickup)
- `conflicts` - Detect worktree/task conflicts

**Examples:**
```powershell
# Show dashboard
.\query-agent-activity.ps1 -Action dashboard

# Watch dashboard (refresh every 5s)
.\query-agent-activity.ps1 -Action dashboard -Watch

# List all agents
.\query-agent-activity.ps1 -Action agents

# Show unfinished tasks
.\query-agent-activity.ps1 -Action unfinished

# View history for specific agent
.\query-agent-activity.ps1 -Action history -AgentId agent-20260126-1234

# Detect conflicts
.\query-agent-activity.ps1 -Action conflicts
```

## Integration with Existing Workflows

### Worktree Allocation
When allocating a worktree, log the activity:

```powershell
# In worktree-allocate.ps1
.\agent-logger.ps1 -Action log -Message "Allocated worktree: agent-003 for client-manager on branch feature/oauth"

# Update agent worktree seat
$agentId = Get-Content C:\scripts\_machine\.current_agent_id
sqlite3 C:\scripts\_machine\agent-activity.db "UPDATE agents SET worktree_seat='agent-003' WHERE agent_id='$agentId';"
```

### Task Management
When starting a ClickUp task or feature:

```powershell
.\agent-logger.ps1 -Action start_task -Message "ClickUp #869bwem7k: Add Facebook Page integration" -TaskId "869bwem7k" -Metadata "{\"source\":\"clickup\"}"
```

### Session Startup
At the start of every session:

```powershell
# 1. Register agent
.\agent-logger.ps1 -Action register

# 2. Check for unfinished tasks
.\query-agent-activity.ps1 -Action unfinished

# 3. Check for conflicts
.\query-agent-activity.ps1 -Action conflicts

# 4. Show dashboard
.\query-agent-activity.ps1 -Action dashboard
```

### Heartbeat (Periodic)
During long-running operations, update heartbeat every few minutes:

```powershell
.\agent-logger.ps1 -Action heartbeat
```

### Session Cleanup
At the end of session or periodically:

```powershell
.\agent-logger.ps1 -Action cleanup
```

## Agent ID Management

**Agent ID Format:** `agent-YYYYMMDDHHMMSS-NNNN`
- Example: `agent-20260126151530-4872`

**Persistence:** Stored in `C:\scripts\_machine\.current_agent_id`
- Each agent session has a unique ID
- ID persists across tool invocations within same session
- New ID generated if file missing

**Usage:**
```powershell
# Get current agent ID
$agentId = Get-Content C:\scripts\_machine\.current_agent_id

# Use in queries
.\query-agent-activity.ps1 -Action history -AgentId $agentId
```

## Coordination Protocols

### Claiming Unfinished Work
```powershell
# 1. Find available tasks
.\query-agent-activity.ps1 -Action unfinished

# 2. Claim a task
.\agent-logger.ps1 -Action start_task -TaskId "TASK-123" -Message "Resume work on OAuth integration"

# 3. Work on task...

# 4. Complete or block
.\agent-logger.ps1 -Action complete_task -TaskId "TASK-123"
# OR
.\agent-logger.ps1 -Action block_task -TaskId "TASK-123" -Message "Waiting for API keys"
```

### Detecting Other Agents
```powershell
# Check active agents before allocating worktree
.\agent-logger.ps1 -Action query -Query active_agents

# Detect conflicts
.\query-agent-activity.ps1 -Action conflicts
```

### Handoff Between Agents
```powershell
# Agent 1: Block task with handoff note
.\agent-logger.ps1 -Action block_task -TaskId "TASK-123" -Message "Blocked: Needs frontend expertise"

# Agent 2: Pick up blocked task
.\agent-logger.ps1 -Action start_task -TaskId "TASK-123" -Message "Frontend agent continuing work"
```

## Query Examples

### SQL Queries (Direct)
You can also query directly with `sqlite3`:

```bash
# All active agents
sqlite3 C:\scripts\_machine\agent-activity.db "SELECT * FROM agents WHERE status='active';"

# Recent activity
sqlite3 C:\scripts\_machine\agent-activity.db "SELECT * FROM activity_log ORDER BY timestamp DESC LIMIT 20;"

# Tasks by priority
sqlite3 C:\scripts\_machine\agent-activity.db "SELECT task_id, title, priority, status FROM tasks ORDER BY priority DESC, created_at ASC;"

# Agent workload
sqlite3 C:\scripts\_machine\agent-activity.db "SELECT assigned_to, COUNT(*) as task_count FROM tasks WHERE status='in_progress' GROUP BY assigned_to;"
```

### PowerShell Integration
```powershell
# Get all unfinished task IDs
$tasks = sqlite3 C:\scripts\_machine\agent-activity.db "SELECT task_id FROM tasks WHERE status IN ('pending', 'in_progress');"

# Process each task
$tasks -split "`n" | ForEach-Object {
    Write-Host "Task: $_"
}
```

## Maintenance

### Database Backup
```powershell
# Backup database
Copy-Item C:\scripts\_machine\agent-activity.db C:\scripts\_machine\agent-activity.backup.db
```

### Reset Database
```powershell
# Delete database (will be recreated on next run)
Remove-Item C:\scripts\_machine\agent-activity.db
```

### Cleanup Stale Data
```powershell
# Remove old completed tasks (older than 30 days)
sqlite3 C:\scripts\_machine\agent-activity.db "DELETE FROM tasks WHERE status='completed' AND datetime(completed_at) < datetime('now', '-30 days');"

# Remove old activity logs (older than 90 days)
sqlite3 C:\scripts\_machine\agent-activity.db "DELETE FROM activity_log WHERE datetime(timestamp) < datetime('now', '-90 days');"
```

## Performance

**Database Size:**
- ~1KB per agent
- ~0.5KB per task
- ~0.3KB per activity log entry

**Typical Session:**
- 1 agent = ~1KB
- 10 tasks = ~5KB
- 100 log entries = ~30KB
- **Total: ~36KB**

**Scalability:**
- SQLite handles millions of rows efficiently
- Indexes on key columns ensure fast queries
- Concurrent reads are lock-free
- Writes use brief locks (milliseconds)

## Troubleshooting

### SQLite Not Found
```powershell
# Install SQLite via winget
winget install --id SQLite.SQLite -e --accept-source-agreements --accept-package-agreements
```

### Database Locked
If you get "database is locked" errors:
- Another process has an active write
- Wait a moment and retry
- Check for zombie processes: `Get-Process sqlite3`

### Corrupt Database
```powershell
# Check integrity
sqlite3 C:\scripts\_machine\agent-activity.db "PRAGMA integrity_check;"

# If corrupt, restore from backup
Copy-Item C:\scripts\_machine\agent-activity.backup.db C:\scripts\_machine\agent-activity.db -Force
```

### Missing Agent ID
```powershell
# Regenerate agent ID
Remove-Item C:\scripts\_machine\.current_agent_id -ErrorAction SilentlyContinue
.\agent-logger.ps1 -Action register
```

## Future Enhancements

### Planned Features
- [ ] Web-based dashboard (HTML/JavaScript)
- [ ] Real-time notifications (webhooks)
- [ ] Agent-to-agent messaging
- [ ] Task dependencies (DAG)
- [ ] Performance metrics (task duration, bottlenecks)
- [ ] Export to JSON/CSV
- [ ] API server (REST/GraphQL)
- [ ] Multi-machine synchronization

### Integration Opportunities
- [ ] Auto-log from worktree-allocate.ps1
- [ ] Auto-log from clickup-sync.ps1
- [ ] Integration with parallel-agent-coordination skill
- [ ] Task creation from reflection.log.md learnings
- [ ] Automated conflict resolution

## References

- **Database:** `C:\scripts\_machine\agent-activity.db`
- **Agent ID:** `C:\scripts\_machine\.current_agent_id`
- **Tools:** `C:\scripts\tools\agent-logger.ps1`, `query-agent-activity.ps1`
- **SQLite Docs:** https://www.sqlite.org/docs.html

---

**Questions?** Check the dashboard: `.\query-agent-activity.ps1 -Action dashboard`
