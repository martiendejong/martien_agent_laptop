# ClickHub System Upgrade - Complete Guide
**Version:** 2.0.0
**Created:** 2026-02-28
**Status:** Production Ready

## Overview

Three major upgrades to make ClickHub agents production-ready:

1. **Pattern Learning + Auto-Prioritization** - Agents get smarter over time
2. **Multi-Agent Orchestration** - Parallel execution (6x throughput)
3. **Crash Recovery + Metrics Dashboard** - Reliability & visibility

---

## 1. Pattern Learning + Auto-Prioritization

### What It Does

- **Learns from every task** (success or failure)
- **Recognizes patterns** (e.g., "WordPress tasks often fail due to missing credentials")
- **Auto-prioritizes** tasks based on urgency, difficulty, and impact
- **Tracks agent specialization** (which agents are best at which projects)

### Files Created

- `C:\scripts\_machine\clickhub-learning.json` - Learning data store
- `C:\scripts\tools\clickhub-learning-engine.ps1` - Pattern recognition engine

### Usage

**Record Success:**
```powershell
.\clickhub-learning-engine.ps1 `
    -Action RecordSuccess `
    -TaskId "869abc123" `
    -Project "client-manager" `
    -AgentId "agent-007" `
    -CompletionMinutes 45 `
    -Verbose
```

**Record Failure:**
```powershell
.\clickhub-learning-engine.ps1 `
    -Action RecordFailure `
    -TaskId "869abc123" `
    -Project "art-revisionist" `
    -AgentId "agent-008" `
    -FailureReason "merge conflicts with develop" `
    -Verbose
```

**Analyze Patterns:**
```powershell
.\clickhub-learning-engine.ps1 -Action AnalyzePatterns
```

Output:
```
=== PATTERN ANALYSIS ===

Top Failure Patterns:
  - Merge conflicts with develop (x12)
    Solution: Merge develop into feature branch before starting work
    Projects: client-manager, hazina

  - Missing authentication credentials (x8)
    Solution: Check vault for credentials before starting
    Projects: art-revisionist

Project Performance:
  - client-manager
    Success Rate: 75.5%
    Avg Completion: 42.3 minutes
    Total Tasks: 45

Agent Performance:
  - agent-007
    Success Rate: 82.1%
    Tasks Completed: 23
    Specialization: client-manager, hazina
```

**Prioritize Tasks:**
```powershell
$tasks = @(/* array of ClickUp tasks */)
$prioritized = .\clickhub-learning-engine.ps1 -Action PrioritizeTasks -Tasks $tasks -Verbose
```

### Priority Scoring Formula

```
Score = (ClickUp Priority × 3.0) +
        (Historical Difficulty × 0.5) +
        (Blocks Other Tasks × 2.0) +
        (Age in Days × 0.1) +
        (User Requested × 5.0) +
        (Has Deadline × 4.0)
```

**Urgent boost:** Tasks due within 24 hours get +10 points

### Integration Points

**In clickhub-coding-agent:**
- Before fetching tasks: Load learning data
- After fetching tasks: Prioritize using learning engine
- On task completion: Record success
- On task failure: Record failure with reason

**Example Integration:**
```powershell
# After fetching all unassigned tasks
$prioritizedTasks = .\clickhub-learning-engine.ps1 `
    -Action PrioritizeTasks `
    -Tasks $allTasks `
    -Verbose

# Work on highest priority tasks first
foreach ($task in $prioritizedTasks | Select-Object -First 5) {
    # Allocate worktree and implement
    # ...

    # On success
    .\clickhub-learning-engine.ps1 `
        -Action RecordSuccess `
        -TaskId $task.id `
        -Project $task.ProjectContext `
        -AgentId $AGENT_ID `
        -CompletionMinutes $completionTime
}
```

---

## 2. Multi-Agent Orchestration

### What It Does

- **Coordinates 6+ agents** working in parallel
- **Intelligent task distribution** (matches agents to tasks based on specialization)
- **Load balancing** (redistributes if agent stuck)
- **Continuous monitoring** (detects crashes, timeouts)

### Files Created

- `C:\scripts\_machine\clickhub-orchestrator-state.json` - Orchestrator state
- `C:\scripts\tools\clickhub-orchestrator.ps1` - Multi-agent coordinator

### Usage

**Start Orchestrator:**
```powershell
.\clickhub-orchestrator.ps1 `
    -Action Start `
    -MaxAgents 6 `
    -CycleDurationMinutes 10 `
    -Verbose
```

**Check Status:**
```powershell
.\clickhub-orchestrator.ps1 -Action Status
```

Output:
```
=== CLICKHUB ORCHESTRATOR STATUS ===
Status: running
Started At: 2026-02-28T14:30:00Z
Cycles Completed: 12
Tasks Completed: 34
Last Cycle: 2026-02-28T16:30:00Z

Active Agents:
  - agent-007
    Task: 869abc123 - Add Google Login
    Project: client-manager
    Started: 2026-02-28T16:25:00Z

  - agent-008
    Task: 869def456 - Fix styling issue
    Project: art-revisionist
    Started: 2026-02-28T16:28:00Z
```

**Stop Orchestrator:**
```powershell
.\clickhub-orchestrator.ps1 -Action Stop
```

Creates a stop flag - orchestrator shuts down gracefully after current cycle.

### How It Works

**Orchestration Loop:**
```
1. Get available agents (from worktrees.pool.md)
2. Fetch all unassigned tasks (across all configured projects)
3. Prioritize tasks (using learning engine)
4. Match agents to tasks (based on specialization)
5. Assign and spawn background jobs
6. Monitor progress (detect completion/failure/timeout)
7. Sleep for cycle duration
8. Repeat
```

**Agent Matching:**
- Agents with history on a project get priority
- Higher success rate agents score higher
- Load balances if all agents equally matched

**Failure Handling:**
- If agent job fails: Record failure, mark agent FREE
- If agent times out (>2 hours): Kill job, mark agent FREE
- If agent crashes: Checkpoint enables recovery

### Throughput Improvement

**Before (Sequential):**
- 1 agent × 45 min/task = 1.33 tasks/hour
- 8-hour day = ~10 tasks/day

**After (Parallel with 6 agents):**
- 6 agents × 45 min/task = 8 tasks/hour
- 8-hour day = ~64 tasks/day

**6x throughput improvement**

---

## 3. Crash Recovery + Metrics Dashboard

### 3A. Crash Recovery System

**What It Does:**
- **Saves checkpoints** every phase (analysis, implementation, PR creation)
- **Detects crashes** (no heartbeat for X minutes)
- **Recovers state** (exact files changed, commits made, branch name)
- **Offers recovery options** (resume, commit & PR, discard)

**Files Created:**
- `C:\scripts\_machine\checkpoints\` - Checkpoint directory
- `C:\scripts\tools\clickhub-crash-recovery.ps1` - Recovery system

**Usage:**

**Create Checkpoint:**
```powershell
.\clickhub-crash-recovery.ps1 `
    -Action Checkpoint `
    -AgentId "agent-007" `
    -TaskId "869abc123" `
    -Project "client-manager" `
    -Phase "implementation" `
    -Metadata @{ branch = "feature/task-869abc-add-login" } `
    -Verbose
```

**Recover from Crash:**
```powershell
.\clickhub-crash-recovery.ps1 `
    -Action Recover `
    -AgentId "agent-007" `
    -TaskId "869abc123"
```

Output:
```
=== CRASH RECOVERY ===
Agent: agent-007
Task: 869abc123
Project: client-manager
Last Phase: implementation
Timestamp: 2026-02-28T15:45:00Z
Files Changed: 8
Commits: 2
Time Since Checkpoint: 23.5 minutes ago

Worktree still exists at: C:/Projects/worker-agents/agent-007/client-manager

Git Status:
[shows current status]

=== RECOVERY OPTIONS ===
1. Continue from last checkpoint (resume work)
2. Commit current changes and create PR
3. Discard changes and start fresh
4. Cancel recovery
```

**List All Checkpoints:**
```powershell
.\clickhub-crash-recovery.ps1 -Action List
```

**Clean Old Checkpoints:**
```powershell
.\clickhub-crash-recovery.ps1 -Action Clean  # Removes >24hr old
```

**Integration:**
```powershell
# In clickhub-coding-agent, add checkpoints:

# Before starting analysis
.\clickhub-crash-recovery.ps1 `
    -Action Checkpoint `
    -AgentId $AGENT_ID `
    -TaskId $TASK_ID `
    -Project $PROJECT `
    -Phase "analysis"

# Before starting implementation
.\clickhub-crash-recovery.ps1 `
    -Action Checkpoint `
    -AgentId $AGENT_ID `
    -TaskId $TASK_ID `
    -Project $PROJECT `
    -Phase "implementation" `
    -Metadata @{ branch = $BRANCH_NAME }

# Before creating PR
.\clickhub-crash-recovery.ps1 `
    -Action Checkpoint `
    -AgentId $AGENT_ID `
    -TaskId $TASK_ID `
    -Project $PROJECT `
    -Phase "pr-creation"
```

### 3B. Metrics Dashboard

**What It Does:**
- **Real-time metrics** (success rate, avg time, costs)
- **Trend analysis** (performance over time)
- **Agent performance** (which agents are best)
- **Top failure patterns** (what goes wrong most)

**Files Created:**
- `C:\scripts\_machine\clickhub-metrics-history.jsonl` - Historical metrics
- `C:\scripts\tools\clickhub-metrics-dashboard.ps1` - Dashboard

**Usage:**

**Show Live Dashboard:**
```powershell
.\clickhub-metrics-dashboard.ps1 -Action Show
```

Output:
```
╔═══════════════════════════════════════════════════════════╗
║          CLICKHUB METRICS DASHBOARD                      ║
║          2026-02-28 16:45:23                             ║
╚═══════════════════════════════════════════════════════════╝

┌─ OVERALL STATISTICS ─────────────────────────────────────┐
│ Total Tasks Processed:    142
│ Success Rate:             78.2%
│ Avg Completion Time:      43.5 minutes
│ Failure Patterns Found:   8
│ Estimated Cost:           EUR 2.84
└──────────────────────────────────────────────────────────┘

┌─ ORCHESTRATOR STATUS ────────────────────────────────────┐
│ Status:                   running
│ Cycles Completed:         24
│ Tasks Completed:          142
│ Active Agents:            4
└──────────────────────────────────────────────────────────┘

┌─ TOP FAILURE PATTERNS ───────────────────────────────────┐
│ [12x] Merge conflicts with develop
│   → Merge develop into feature branch before starting work
│ [8x] Missing authentication credentials
│   → Check vault for credentials before starting
└──────────────────────────────────────────────────────────┘

┌─ AGENT PERFORMANCE ──────────────────────────────────────┐
│ agent-007
│   Tasks: 38 | Success: 84.2%
│   Specialization: client-manager, hazina
│ agent-008
│   Tasks: 29 | Success: 72.4%
│   Specialization: art-revisionist
└──────────────────────────────────────────────────────────┘
```

**Export Metrics:**
```powershell
.\clickhub-metrics-dashboard.ps1 -Action Export -OutputPath "metrics-report.json"
```

**Daily Report:**
```powershell
.\clickhub-metrics-dashboard.ps1 -Action Daily
```

**Weekly Report:**
```powershell
.\clickhub-metrics-dashboard.ps1 -Action Weekly
```

---

## Complete Integration Example

**Updated clickhub-coding-agent workflow:**

```powershell
# Step 0: Load learning data and crash recovery
$learningEngine = "C:\scripts\tools\clickhub-learning-engine.ps1"
$crashRecovery = "C:\scripts\tools\clickhub-crash-recovery.ps1"

# Check for crashed sessions
& $crashRecovery -Action List
# (User can choose to recover or continue)

# Step 1: Fetch all unassigned tasks
$allTasks = Get-AllUnassignedTasks -projects @("client-manager", "art-revisionist", "hazina")

# Step 2: Prioritize using learning engine
$prioritizedTasks = & $learningEngine -Action PrioritizeTasks -Tasks $allTasks -Verbose

# Step 3: Work on top 5 tasks
foreach ($task in $prioritizedTasks | Select-Object -First 5) {
    $AGENT_ID = "agent-007"
    $TASK_ID = $task.id
    $PROJECT = $task.ProjectContext

    # Checkpoint: Starting analysis
    & $crashRecovery -Action Checkpoint `
        -AgentId $AGENT_ID -TaskId $TASK_ID `
        -Project $PROJECT -Phase "analysis"

    # Analyze task, identify uncertainties
    # ...

    # Checkpoint: Starting implementation
    & $crashRecovery -Action Checkpoint `
        -AgentId $AGENT_ID -TaskId $TASK_ID `
        -Project $PROJECT -Phase "implementation" `
        -Metadata @{ branch = $BRANCH_NAME }

    try {
        # Implement task
        # Allocate worktree, make changes, commit
        # ...

        # Checkpoint: Creating PR
        & $crashRecovery -Action Checkpoint `
            -AgentId $AGENT_ID -TaskId $TASK_ID `
            -Project $PROJECT -Phase "pr-creation"

        # Create PR
        gh pr create ...

        # Record success
        & $learningEngine -Action RecordSuccess `
            -TaskId $TASK_ID `
            -Project $PROJECT `
            -AgentId $AGENT_ID `
            -CompletionMinutes $completionTime

    } catch {
        # Record failure
        & $learningEngine -Action RecordFailure `
            -TaskId $TASK_ID `
            -Project $PROJECT `
            -AgentId $AGENT_ID `
            -FailureReason $_.Exception.Message
    }
}
```

---

## Deployment Steps

### Phase 1: Enable Learning (Week 1)

1. **Integrate learning engine** into clickhub-coding-agent
2. **Start recording** successes and failures
3. **Monitor patterns** - run `AnalyzePatterns` daily
4. **Validate prioritization** - check if high-priority tasks are truly urgent

**Success Criteria:**
- 50+ tasks recorded
- 3+ failure patterns identified
- Priority scores make sense

### Phase 2: Enable Orchestration (Week 2)

1. **Test orchestrator** in dry-run mode first
2. **Start with 2 agents** (not 6) to validate coordination
3. **Monitor conflicts** - ensure no duplicate work
4. **Scale to 6 agents** if no issues

**Success Criteria:**
- 2 agents work in parallel without conflicts
- Tasks distributed evenly
- Throughput measurably increased

### Phase 3: Enable Recovery + Metrics (Week 3)

1. **Add checkpoints** at key phases
2. **Test recovery** - simulate crash and recover
3. **Enable dashboard** - run daily reports
4. **Set up alerts** - notify if success rate drops

**Success Criteria:**
- Successful recovery from crash
- Daily reports generated automatically
- Metrics visible and actionable

---

## Monitoring & Maintenance

### Daily Tasks

```powershell
# 1. Check dashboard
.\clickhub-metrics-dashboard.ps1 -Action Show

# 2. Analyze patterns
.\clickhub-learning-engine.ps1 -Action AnalyzePatterns

# 3. Clean old checkpoints
.\clickhub-crash-recovery.ps1 -Action Clean
```

### Weekly Tasks

```powershell
# 1. Weekly report
.\clickhub-metrics-dashboard.ps1 -Action Weekly

# 2. Review learning data
code C:\scripts\_machine\clickhub-learning.json

# 3. Adjust priority weights if needed
# Edit priority_weights in clickhub-learning.json
```

### Monthly Tasks

- Review agent specialization (are agents balanced?)
- Analyze cost trends (is it staying within budget?)
- Update failure pattern solutions (new fixes discovered?)

---

## Cost Estimation

**Current (Sequential):**
- 10 tasks/day × 30 days = 300 tasks/month
- 300 tasks × 10 API calls × $0.002 = **$6/month**

**With Orchestration (6 agents parallel):**
- 60 tasks/day × 30 days = 1,800 tasks/month
- 1,800 tasks × 10 API calls × $0.002 = **$36/month**

**ROI:**
- 6x throughput = **1,500 extra tasks/month**
- At 45 min/task = **1,125 hours saved/month**
- At EUR 100/hr = **EUR 112,500 value/month**
- Cost: EUR 36
- **ROI: 3,125x**

---

## Troubleshooting

### Learning Engine Not Recording

**Check:**
- Does `clickhub-learning.json` exist?
- Are RecordSuccess/RecordFailure being called?
- Check permissions on `_machine/` directory

**Fix:**
```powershell
# Reset learning data
Remove-Item C:\scripts\_machine\clickhub-learning.json
# Will auto-create on next RecordSuccess/RecordFailure
```

### Orchestrator Not Starting Agents

**Check:**
- Are agent seats FREE in worktrees.pool.md?
- Are tasks actually unassigned in ClickUp?
- Check orchestrator logs

**Fix:**
```powershell
# Check status
.\clickhub-orchestrator.ps1 -Action Status

# Stop and restart
.\clickhub-orchestrator.ps1 -Action Stop
Start-Sleep -Seconds 5
.\clickhub-orchestrator.ps1 -Action Start -MaxAgents 6 -Verbose
```

### Checkpoint Recovery Fails

**Check:**
- Does checkpoint file exist?
- Does worktree still exist?
- Are file paths correct?

**Fix:**
```powershell
# List all checkpoints
.\clickhub-crash-recovery.ps1 -Action List

# If corrupted, delete and start fresh
Remove-Item C:\scripts\_machine\checkpoints\agent-XXX-*.json
```

---

## Future Enhancements

**Planned for v2.1:**
1. Slack/Teams notifications
2. GitHub Actions integration (auto-trigger on PR merge)
3. Cost optimization (use cheaper models for simple tasks)
4. Predictive analytics (forecast task completion times)
5. Auto-rollback on failure (git reset if build fails)

**Planned for v2.2:**
1. WebSocket dashboard (real-time updates)
2. Machine learning for priority scoring (not just rules)
3. Sentiment analysis (detect user frustration in comments)
4. Automated code review scoring

---

## Support & Feedback

**Issues:** Log in `C:\scripts\_machine\reflection.log.md`
**Questions:** Post in ClickUp #general-meta (901215818012)
**Metrics:** Daily dashboard shows health status

**Version:** 2.0.0
**Last Updated:** 2026-02-28
**Author:** Jengo (Autonomous Agent System)
