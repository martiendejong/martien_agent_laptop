# Focus Recovery Protocol

**Purpose:** Auto-resume interrupted tasks with full context
**Created:** 2026-01-30
**Status:** OPERATIONAL
**Type:** Continuity intelligence layer
**Ratio:** 2.67 (Value: 8, Effort: 2, Risk: 1)

---

## Overview

When work gets interrupted, recover instantly with full context. No "where was I?" moments.

---

## Core Principles

### 1. Continuous Context Capture
Always know current state

### 2. Zero-Cost Interruption
Interruptions shouldn't destroy focus

### 3. Instant Resume
Jump back in without warm-up

### 4. State Preservation
Keep mental model intact

### 5. Automatic Recovery
No manual reconstruction

---

## Context Capture Protocol

### What to Capture

```yaml
focus_state_components:
  task_context:
    - "What I'm working on"
    - "Why I'm doing it"
    - "What I've tried so far"
    - "Current approach"

  work_artifacts:
    - "Files being edited"
    - "Terminal commands running"
    - "Browser tabs open"
    - "Worktree allocated"

  mental_state:
    - "Current hypothesis"
    - "Questions to investigate"
    - "Decisions pending"
    - "Blockers encountered"

  progress_tracking:
    - "Completed steps"
    - "Current step"
    - "Remaining steps"
    - "Time invested"

  environmental_state:
    - "Branch checked out"
    - "Services running"
    - "Database state"
    - "Build status"
```

---

## Automatic Capture Triggers

### When to Snapshot State

```yaml
capture_triggers:
  periodic:
    - "Every significant action completed"
    - "Every 10 minutes of active work"
    - "When switching between tasks"

  event_driven:
    - "User interrupts with new request"
    - "Error encountered (need to investigate)"
    - "Waiting for external input"
    - "Session about to end"

  manual:
    - "User says 'pause' or 'hold that thought'"
    - "User asks 'what are you working on?'"
    - "User says 'come back to this later'"
```

---

## State Preservation Format

### Focus State Snapshot

```yaml
snapshot_structure:
  timestamp: "2026-01-30T14:35:22Z"
  session_id: "agent-003-session-427"

  primary_task:
    description: "Implement user authentication with JWT"
    user_request: "Add login endpoint to API"
    started_at: "2026-01-30T14:00:00Z"

  current_status:
    step: "Creating UserController.Login() method"
    progress: "60% complete"
    what_works: "Token generation working"
    what_doesnt: "Refresh token logic incomplete"

  workspace_state:
    worktree: "C:/Projects/worker-agents/agent-003/client-manager"
    branch: "feature/jwt-auth"
    files_modified:
      - "Controllers/UserController.cs (editing line 47)"
      - "Services/AuthService.cs (completed)"
      - "Models/LoginRequest.cs (completed)"

  mental_model:
    hypothesis: "Need separate RefreshToken model for security"
    questions:
      - "Should refresh tokens be stored in DB or Redis?"
      - "What's the expiration policy?"
    decisions_pending:
      - "Token storage strategy"
      - "Refresh endpoint location"

  blockers:
    - "Need to decide on token storage (DB vs Redis)"
    - "Waiting for user input on expiration times"

  next_steps:
    - "Finish RefreshToken model"
    - "Implement token refresh endpoint"
    - "Add integration tests"
```

---

## Recovery Protocol

### Resuming Interrupted Work

```yaml
recovery_sequence:
  1_load_snapshot:
    action: "Retrieve latest focus state for interrupted task"

  2_reconstruct_mental_model:
    restore:
      - "What problem am I solving?"
      - "What approach was I taking?"
      - "What have I learned so far?"

  3_verify_environment:
    check:
      - "Is worktree still allocated?"
      - "Are files still in expected state?"
      - "Any external changes since snapshot?"

  4_resume_position:
    action:
      - "Open files at last edit position"
      - "Remind myself of next step"
      - "Check if blockers resolved"

  5_communicate_status:
    tell_user:
      - "Resuming [task]"
      - "Progress: [X% complete]"
      - "Next: [immediate action]"
```

---

## Interruption Handling

### Types of Interruptions

```yaml
interruption_types:
  user_initiated:
    scenario: "User asks new question mid-task"
    handling:
      - "Snapshot current state"
      - "Handle new request"
      - "Offer to resume previous task"

  error_triggered:
    scenario: "Build error while implementing"
    handling:
      - "Snapshot implementation state"
      - "Switch to debugging mode"
      - "Resume implementation after fix"

  waiting_for_input:
    scenario: "Blocked on user decision"
    handling:
      - "Snapshot with blocker noted"
      - "Work on other tasks"
      - "Auto-resume when user responds"

  session_end:
    scenario: "Session ending with incomplete work"
    handling:
      - "Comprehensive snapshot"
      - "Save to agentidentity/state/current_session.yaml"
      - "Auto-load in next session"
```

---

## Multi-Task Focus Management

### Task Stack

```yaml
task_stack_model:
  active_task:
    task: "Implement JWT auth"
    state: "IN_PROGRESS"
    snapshot: [current state]

  interrupted_tasks:
    - task: "Fix CSS layout bug"
      state: "INTERRUPTED"
      snapshot: [saved state]
      reason: "User asked for auth feature (higher priority)"

    - task: "Update dependencies"
      state: "PAUSED"
      snapshot: [saved state]
      reason: "Waiting for build to pass"

  operations:
    push: "Start new task (save current)"
    pop: "Resume previous task"
    peek: "Check what's on stack"
    clear_completed: "Remove finished tasks"
```

---

## Context Restoration Examples

### Example 1: User Interruption

```yaml
scenario:
  working_on: "Refactoring CustomerService.cs"
  interrupted_by: "User asks 'can you check the PR comments?'"

handling:
  1_snapshot:
    task: "CustomerService refactoring"
    current_line: "Line 147, extracting helper method"
    mental_state: "Need to rename variables after extraction"

  2_handle_interruption:
    - "Check PR comments"
    - "Address reviewer feedback"
    - "Update code"

  3_offer_resume:
    message: "PR comments addressed. Resume CustomerService refactoring?"

  4_restore_if_yes:
    - "Reopen CustomerService.cs at line 147"
    - "Remind: Extracting helper, then rename variables"
```

### Example 2: Session Boundary

```yaml
scenario:
  end_of_session: "Working on migration, session timeout"

snapshot:
  task: "Add User.EmailConfirmed column"
  progress:
    completed:
      - "Created migration file"
      - "Added Up() method"
    current: "Writing Down() rollback method"
    remaining:
      - "Test migration"
      - "Update UserService to check EmailConfirmed"

  saved_to: "agentidentity/state/current_session.yaml"

next_session_start:
  action: "Auto-load saved state"
  message: "Resuming: Email confirmation migration (60% complete). Next: finish Down() method."
```

### Example 3: Error Investigation

```yaml
scenario:
  working_on: "Implementing feature X"
  interrupted_by: "Build error in unrelated file"

handling:
  1_snapshot_implementation:
    feature: "X"
    state: "Half-written, not yet compilable"

  2_switch_to_debug:
    mode: "Active Debugging"
    focus: "Fix build error"

  3_fix_error:
    - "Identify issue"
    - "Apply fix"
    - "Verify build green"

  4_restore_implementation:
    mode: "Feature Development"
    resume: "Feature X implementation"
    mental_state: "Restore approach, continue coding"
```

---

## Integration with Other Layers

### With Strategic Planning
- **Strategic Planning** tracks long-term goals
- **Focus Recovery** handles short-term interruptions
- Together: maintain continuity across timescales

### With Working Memory Optimizer
- **Working Memory** manages active context
- **Focus Recovery** persists context across interruptions
- Working memory → snapshot → restore → working memory

### With Task Management
- **Task Management** lists what to do
- **Focus Recovery** remembers where we were in doing it
- Tasks = queue, Focus = execution state

---

## Automation

### Tools Integration

```yaml
automated_focus_management:
  context_snapshot_tool:
    script: "agentidentity/state/capture-focus-state.ps1"
    captures:
      - "Current worktree"
      - "Modified files"
      - "Git branch"
      - "Recent commands"

  session_state_tracker:
    file: "agentidentity/state/current_session.yaml"
    auto_save: "Every 10 minutes + on interruption"

  resume_helper:
    script: "agentidentity/state/resume-task.ps1"
    restores:
      - "Opens files at last position"
      - "Displays next steps"
      - "Checks environment state"
```

---

## Success Metrics

**This system works well when:**
- ✅ No "where was I?" confusion
- ✅ Instant resume after interruptions
- ✅ Mental model preserved across sessions
- ✅ Task context never lost
- ✅ Smooth task switching

**Warning signs:**
- ⚠️ Forgetting what I was doing
- ⚠️ Restarting work from scratch
- ⚠️ Asking user "what was I working on?"
- ⚠️ Lost context after interruption
- ⚠️ Slow warm-up when resuming

---

**Status:** ACTIVE - Zero-cost interruption handling
**Goal:** Never lose focus context
**Principle:** "Pause instantly, resume instantly"
