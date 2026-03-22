# ClickHub 2.0 Quick Start Guide

## Overview

ClickHub 2.0 is an autonomous ClickUp task management system with pattern learning, multi-agent orchestration, crash recovery, and real-time metrics.

## 5-Minute Setup

### Step 1: Verify Prerequisites

You need:
- ClickUp account with API access
- ClickUp config file at `C:\scripts\_machine\clickup-config.json`
- PowerShell 5.1 or higher
- Git worktree setup at `C:\Projects\worker-agents\`

### Step 2: Deploy System

```powershell
cd C:\scripts\tools
.\deploy-clickhub-system.ps1
```

This will:
- Verify all core scripts are present
- Initialize data files
- Run test suite
- Create quick reference card

**Deployment time: ~2 minutes**

### Step 3: Run Demo (Optional)

See the system in action:

```powershell
.\clickhub-demo.ps1
```

This demonstrates:
- Pattern learning (recording successes/failures)
- Crash recovery (checkpoint system)
- Metrics dashboard
- Notification system

**Demo time: ~3 minutes (interactive)**

### Step 4: Start Using

#### Manual Task Execution

Pick up a single task:

```powershell
# Work on internal/client projects (default)
/clickhub-coding-agent

# Work on specific project
/clickhub-coding-agent in hazina

# Work on specific list
/clickhub-coding-agent in list 901215559249
```

#### Automated Orchestration

Let the orchestrator manage multiple agents:

```powershell
# Start background orchestration (5 parallel agents, 5-minute cycles)
.\clickhub-orchestrator.ps1 -Action Start -MaxParallelAgents 5 -CycleIntervalSeconds 300

# Check status
.\clickhub-orchestrator.ps1 -Action Status

# Stop when done
.\clickhub-orchestrator.ps1 -Action Stop
```

## Core Workflows

### 1. Pattern Learning Workflow

The system learns from every task:

```
Task Execution
    ↓
SUCCESS → Record completion time, patterns, agent performance
    ↓
FAILURE → Record error pattern, suggest solution
    ↓
Pattern Analysis → Auto-prioritize similar tasks
```

**Example:**
```powershell
# After completing a task (automatic via skill integration)
# Learning engine records:
# - Completion time
# - Complexity estimate
# - Success patterns
# - Agent specialization

# View learned patterns
.\clickhub-learning-engine.ps1 -Action AnalyzePatterns
```

### 2. Crash Recovery Workflow

Automatic checkpoints at key phases:

```
Task Start
    ↓
Analysis Phase → Checkpoint created
    ↓
Implementation Phase → Checkpoint created
    ↓
PR Creation → Checkpoint created
    ↓
[CRASH OCCURS]
    ↓
Recovery → List checkpoints → Choose recovery option
```

**Example:**
```powershell
# If agent crashes, recover with:
.\clickhub-crash-recovery.ps1 -Action List
.\clickhub-crash-recovery.ps1 -Action Recover -CheckpointFile <path> -RecoveryOption Resume
```

Recovery options:
- **Resume**: Continue from checkpoint
- **CommitAndPR**: Create PR from current state
- **Discard**: Abandon changes
- **Cancel**: Keep checkpoint, decide later

### 3. Metrics Monitoring

Real-time visibility into system performance:

```powershell
# Current metrics
.\clickhub-metrics-dashboard.ps1 -Action Show

# Daily summary
.\clickhub-metrics-dashboard.ps1 -Action Daily

# Weekly summary
.\clickhub-metrics-dashboard.ps1 -Action Weekly

# Export to file
.\clickhub-metrics-dashboard.ps1 -Action Export -OutputPath "metrics.json"
```

Metrics tracked:
- Total tasks processed
- Success rate
- Average completion time
- Failure patterns
- Estimated cost
- Agent performance
- Trend analysis

### 4. Notification System

Get alerts for critical events:

**Configure**: Edit `C:\scripts\_machine\clickhub-notifications-config.json`

```json
{
  "enabled": true,
  "channels": {
    "slack": {
      "enabled": true,
      "webhook_url": "https://hooks.slack.com/...",
      "channels": {
        "urgent": "#dev-urgent",
        "daily": "#dev-updates"
      }
    }
  }
}
```

**Event types:**
- `TaskBlocked`: Task stuck for >4 hours
- `FailurePattern`: Same error occurs 5+ times
- `SuccessRateDrop`: Success rate drops >50%
- `DailyDigest`: End-of-day summary
- `AgentTimeout`: Agent running >2 hours

## ClickUp Swimlane Workflow

Tasks flow through statuses in strict order:

```
TODO
  ↓
IN PROGRESS/BUSY (agent working)
  ↓
REVIEW (PR created, awaiting review)
  ↓
TESTING (PR merged to develop)
  ↓
DONE
```

**Special statuses (use sparingly):**
- **BLOCKED**: External dependency, cannot proceed
- **NEEDS INFO**: Questions posted, awaiting user response

**Rules:**
- Only move to REVIEW after creating PR
- Only move to TESTING after merging PR
- Always post comments with URLs (PR links, commit links)
- Keep comments short and simple

## Invocation Modes

### Mode 1: Default (Internal + Client Projects)

```
/clickhub-coding-agent
```

Searches these projects:
- hazina
- client-manager
- art-revisionist
- brand2boost
- (all configured projects)

### Mode 2: Specific Project

```
/clickhub-coding-agent in hazina
```

Only searches "hazina" project tasks.

### Mode 3: Specific List ID

```
/clickhub-coding-agent in list 901215559249
```

Directly targets a ClickUp list by ID.

### Mode 4: Multiple Projects

```
/clickhub-coding-agent in hazina, client-manager
```

Searches only specified projects.

### Mode 5: Category

```
/clickhub-coding-agent in backend
```

Filters by category (backend, frontend, infrastructure).

## Common Tasks

### Check System Health

```powershell
# Run all tests
.\clickhub-tests.ps1 -Suite All

# Run specific suite
.\clickhub-tests.ps1 -Suite Learning
.\clickhub-tests.ps1 -Suite Orchestrator
.\clickhub-tests.ps1 -Suite CrashRecovery
```

### View Learning Data

```powershell
# Get statistics
.\clickhub-learning-engine.ps1 -Action GetStats

# Analyze patterns
.\clickhub-learning-engine.ps1 -Action AnalyzePatterns
```

### Clean Old Data

```powershell
# Clean checkpoints older than 48 hours
.\clickhub-crash-recovery.ps1 -Action Clean -OlderThanHours 48
```

### Monitor Orchestrator

```powershell
# Check active agents
.\clickhub-orchestrator.ps1 -Action Status

# Balance workload
.\clickhub-orchestrator.ps1 -Action Balance
```

## Troubleshooting

### Problem: Agent not picking up tasks

**Check:**
1. ClickUp config has correct list IDs
2. Tasks are in "todo" status
3. Tasks are unassigned
4. Worktree pool has FREE seats

```powershell
# Check worktree pool
Get-Content C:\scripts\_machine\worktrees.pool.md
```

### Problem: Tests failing

**Check:**
1. All core scripts present in `C:\scripts\tools\`
2. Data files initialized in `C:\scripts\_machine\`
3. ClickUp config valid JSON

```powershell
# Re-run deployment
.\deploy-clickhub-system.ps1 -SkipTests
```

### Problem: Orchestrator not starting

**Check:**
1. No other orchestrator running (only 1 allowed)
2. ClickUp API accessible
3. Worktree pool available

```powershell
# Stop existing orchestrator
.\clickhub-orchestrator.ps1 -Action Stop

# Start fresh
.\clickhub-orchestrator.ps1 -Action Start
```

### Problem: Notifications not sending

**Check:**
1. `clickhub-notifications-config.json` has `enabled: true`
2. Webhook URLs configured correctly
3. Channels enabled in config

```powershell
# Test notification
.\clickhub-notifications.ps1 -EventType "DailyDigest" -Data @{ tasks_processed = 1 } -Test
```

## Performance Tuning

### Orchestrator Settings

Edit `C:\scripts\_machine\clickhub-orchestrator-state.json`:

```json
{
  "config": {
    "max_parallel_agents": 5,         // More agents = faster, more resource usage
    "cycle_interval_seconds": 300,    // How often to check for new tasks
    "timeout_hours": 2                // Max time before agent timeout alert
  }
}
```

**Recommendations:**
- Development: 2-3 agents, 300s cycle
- Production: 5-8 agents, 180s cycle
- High load: 10+ agents, 120s cycle (requires more worktree seats)

### Priority Weights

Edit `C:\scripts\_machine\clickhub-learning.json`:

```json
{
  "priority_weights": {
    "clickup_priority": 3.0,          // Weight ClickUp's priority field
    "historical_difficulty": 0.5,     // Weight past completion time
    "blocks_other_tasks": 2.0,        // Weight dependency blocking
    "age_days": 0.1,                  // Weight task age
    "user_requested": 5.0,            // Weight explicit user requests
    "has_deadline": 4.0,              // Weight deadline presence
    "urgent_deadline_boost": 10.0     // Boost if deadline <24 hours
  }
}
```

**Tuning tips:**
- Increase `user_requested` if user assignments should take priority
- Increase `has_deadline` if deadlines are critical
- Decrease `age_days` if newer tasks are more important

## ROI Metrics

**Time savings:**
- Manual task selection: ~5 min → Auto-prioritization: ~10 sec
- Manual recovery from crash: ~30 min → Checkpoint recovery: ~2 min
- Manual pattern analysis: ~2 hrs → Automated learning: continuous

**Cost reduction:**
- Fewer failed tasks (pattern learning prevents repeated errors)
- Faster completion (learned difficulty estimates)
- Better agent matching (specialization tracking)

**Estimated ROI: 3,125x** (see CLICKHUB-SYSTEM-UPGRADE.md for full calculation)

## Next Steps

1. **Week 1**: Use manual invocation, observe learning
2. **Week 2**: Enable orchestrator for automated task pickup
3. **Week 3**: Configure notifications, monitor metrics weekly
4. **Week 4**: Tune priority weights based on actual patterns

## Support

**Documentation:**
- Full system docs: `C:\scripts\_machine\CLICKHUB-SYSTEM-UPGRADE.md`
- Quick reference: `C:\scripts\_machine\CLICKHUB-QUICK-REFERENCE.md`

**Configuration files:**
- ClickUp boards: `C:\scripts\_machine\clickup-config.json`
- Notifications: `C:\scripts\_machine\clickhub-notifications-config.json`
- Learning data: `C:\scripts\_machine\clickhub-learning.json`
- Orchestrator: `C:\scripts\_machine\clickhub-orchestrator-state.json`

**Testing:**
```powershell
.\clickhub-tests.ps1 -Suite All -Verbose
```

**Demo:**
```powershell
.\clickhub-demo.ps1
```
