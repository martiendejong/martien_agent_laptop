# Task Manager - Interrupt/Resume Protocol

**Purpose:** Formal mechanism to pause partially-completed tasks and resume them later with full context
**Created:** 2026-02-01
**Based on:** ACE Framework Layer 5 (Cognitive Control) requirements

---

## 🎯 Purpose

Enable graceful handling of interruptions:
- User requests higher-priority task
- System needs (maintenance, updates)
- Context switching between multiple projects
- Session crashes/interruptions
- Multi-day work on complex tasks

**Key Principle:** Any task in progress can be paused and later resumed exactly where it left off.

---

## 📊 Task Lifecycle States

```
┌──────────┐
│ PENDING  │ ← Task created, not started
└────┬─────┘
     │ start
     ▼
┌──────────┐
│ ACTIVE   │ ← Currently being worked on
└────┬─────┘
     │ pause / interrupt
     ▼
┌──────────┐
│ PAUSED   │ ← Interrupted, can resume
└────┬─────┘
     │ resume
     ▼
┌──────────┐
│ ACTIVE   │ (back to active)
└────┬─────┘
     │ complete / fail
     ▼
┌──────────┐
│COMPLETED │ or │ FAILED │
└──────────┘    └────────┘
```

### State Definitions

| State | Description | Allowed Transitions |
|-------|-------------|-------------------|
| **PENDING** | Task created, waiting to start | → ACTIVE, CANCELLED |
| **ACTIVE** | Currently being worked on | → PAUSED, COMPLETED, FAILED |
| **PAUSED** | Interrupted, context saved | → ACTIVE (resume), CANCELLED |
| **COMPLETED** | Successfully finished | (terminal state) |
| **FAILED** | Could not complete | (terminal state) |
| **CANCELLED** | Explicitly cancelled | (terminal state) |

---

## 🗂️ Task Context Schema

When a task is paused, we save complete context:

```yaml
task_id: "task-2026-02-01-001"
status: "PAUSED"
created_at: "2026-02-01 04:30:00"
started_at: "2026-02-01 04:31:15"
paused_at: "2026-02-01 05:45:22"

# What task
task:
  title: "Implement user authentication feature"
  description: "Add OAuth 2.0 authentication with Google and GitHub providers"
  category: "feature_development"
  priority: "HIGH"

# Where we were
progress:
  overall_percent: 60
  completed_steps:
    - "Created authentication controller"
    - "Implemented OAuth 2.0 flow for Google"
    - "Added user model with OAuth fields"
  current_step: "Implementing GitHub OAuth provider"
  next_steps:
    - "Complete GitHub OAuth implementation"
    - "Add unit tests for auth flows"
    - "Update frontend login component"

# Technical context
context:
  repository: "client-manager"
  branch: "feature/oauth-authentication"
  worktree: "agent-003"
  worktree_path: "C:/Projects/worker-agents/agent-003/client-manager"

  files_modified:
    - "Controllers/AuthenticationController.cs"
    - "Models/User.cs"
    - "Services/OAuthService.cs"

  files_open_in_editor:
    - path: "Services/OAuthService.cs"
      line: 142
      unsaved_changes: true

  uncommitted_changes: true
  stash_id: "stash@{0}"  # If changes were stashed

# Dependencies & blockers
dependencies:
  waiting_for: []
  blocked_by: []
  related_tasks: ["task-2026-01-28-005"]  # User model migration

# Cognitive state
mental_context:
  last_thought: "Need to handle GitHub token refresh - different from Google's implementation"
  open_questions:
    - "Should we support GitHub organization SSO?"
    - "Token storage strategy - database vs secure cookie?"
  decisions_made:
    - "Using OAuth 2.0 authorization code flow (not implicit)"
    - "Storing tokens encrypted in database"

# Session metadata
session:
  original_session_id: "session-2026-02-01-morning"
  pause_reason: "Higher priority bug fix requested"
  estimated_time_remaining: "2-3 hours"
```

---

## 🔧 Operations

### Save Task Context (Pause)

**Tool:** `save-task-context.ps1`

```powershell
# Minimal - auto-detects context
.\save-task-context.ps1 -Reason "User requested different task"

# Explicit - provide details
.\save-task-context.ps1 `
  -TaskTitle "Implement OAuth" `
  -Progress 60 `
  -Reason "Lunch break" `
  -EstimatedRemaining "2 hours"
```

**What it does:**
1. Detects current git context (branch, modified files, uncommitted changes)
2. Saves editor state (if accessible - VS Code, Visual Studio)
3. Creates task context file in `agentidentity/state/tasks/paused/`
4. Optionally stashes uncommitted changes
5. Returns task ID for later resume

### Resume Task

**Tool:** `resume-task.ps1`

```powershell
# List paused tasks
.\resume-task.ps1 -List

# Resume specific task
.\resume-task.ps1 -TaskId "task-2026-02-01-001"

# Resume most recent
.\resume-task.ps1 -Recent
```

**What it does:**
1. Loads task context from saved state
2. Checks out correct branch/worktree
3. Restores uncommitted changes (from stash if needed)
4. Displays context summary (what was being done, next steps)
5. Sets task status to ACTIVE
6. Updates current_session.yaml with resumed task

### Query Tasks

```powershell
# All paused tasks
.\query-tasks.ps1 -Status PAUSED

# Tasks older than 7 days
.\query-tasks.ps1 -Status PAUSED -OlderThan 7

# All active work
.\query-tasks.ps1 -Status ACTIVE
```

---

## 📁 Storage Structure

```
C:\scripts\agentidentity\state\tasks\
├── active\
│   └── current-task.yaml          # Currently active task (only one)
├── paused\
│   ├── task-2026-02-01-001.yaml   # Paused tasks (can resume)
│   ├── task-2026-01-30-003.yaml
│   └── task-2026-01-28-012.yaml
├── completed\
│   └── 2026-02\                   # Archived by month
│       ├── task-2026-02-01-001.yaml
│       └── task-2026-02-01-002.yaml
└── failed\
    └── 2026-02\
        └── task-2026-02-01-010.yaml
```

---

## 🔄 Integration with Existing Systems

### Executive Function
- Task Manager provides execution state tracking
- Executive Function provides planning and prioritization
- When Executive Function decides to switch tasks → Task Manager handles save/resume

### State Manager (current_session.yaml)
- State Manager tracks current session metadata
- Task Manager tracks task-specific execution state
- Current session references active task ID

### Worktree Management
- Task context includes worktree allocation
- Resuming task verifies worktree is still allocated (or reallocates)
- Completing task can auto-release worktree if desired

### Reflection Log
- Task completion writes to reflection.log.md
- Failed tasks document what went wrong and why
- Paused tasks (if old) flagged for review

---

## 🎯 Use Cases

### Use Case 1: User Interruption

```
1. I'm implementing OAuth (60% done)
2. User: "Fix this critical bug first"
3. save-task-context.ps1 -Reason "Critical bug fix"
   → Saves OAuth work (branch, files, context, next steps)
4. Fix bug, create PR
5. resume-task.ps1 -Recent
   → Restores OAuth context, shows where I left off
6. Continue OAuth work
```

### Use Case 2: Multi-Day Work

```
1. Start complex refactoring Monday morning
2. End of day: save-task-context.ps1 -Reason "End of session"
3. Tuesday morning: resume-task.ps1 -Recent
   → Exactly where I left off
4. Continue work
```

### Use Case 3: Session Crash

```
1. Working on feature implementation
2. Claude crashes unexpectedly
3. User restarts new session
4. resume-task.ps1 -List
   → Shows task that was active when crashed
5. resume-task.ps1 -TaskId "task-..."
   → Recovers work in progress
```

### Use Case 4: Parallel Task Streams

```
1. Working on Feature A (client-manager)
2. save-task-context.ps1 -Reason "Switching to Hazina work"
3. Work on Hazina feature B
4. save-task-context.ps1 -Reason "Back to client-manager"
5. resume-task.ps1 -TaskId "feature-A-task-id"
   → Seamless context switching
```

---

## ⚡ Performance Considerations

**Automatic Save Triggers:**
- Before allocating new worktree (if current task active)
- On explicit pause command
- End of session (graceful shutdown)
- (Future) Periodic auto-save every 30 minutes

**Cleanup:**
- Paused tasks > 30 days → Flagged for review
- Paused tasks > 90 days → Auto-archive to `tasks/archived/`
- Completed tasks → Archived by month

---

## 📊 Metrics & Monitoring

**Track:**
- Average task duration (start to complete)
- Pause/resume frequency
- Tasks abandoned (paused but never resumed)
- Context switch overhead (time to save/resume)

**Success Criteria:**
- ✅ Can resume task with <30 seconds of context recovery
- ✅ Zero information loss during pause/resume
- ✅ Clear mental model of what was being done
- ✅ No duplicate work due to lost context

---

## 🚀 Future Enhancements

1. **Editor Integration** - Direct VS Code/Visual Studio state save
2. **Automated Pause Detection** - Detect idle time → auto-pause
3. **Task Templates** - Common task types with preset context
4. **Dependency Graph** - Visual task dependencies
5. **Time Tracking** - Actual time spent per task
6. **Smart Resume Suggestions** - "You were working on X, but Y is now more urgent"

---

**Created:** 2026-02-01
**Status:** OPERATIONAL - Tools being implemented
**Next:** Build save-task-context.ps1 and resume-task.ps1 tools
