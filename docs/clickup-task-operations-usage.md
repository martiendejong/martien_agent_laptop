# ClickUp Task Operations - Usage Guide

**Script:** `C:\scripts\tools\clickup-task-operations.ps1`
**Purpose:** Atomic operations for common ClickUp workflows
**Created:** 2026-02-15

## Available Actions

### 1. GetUnassigned - Find unassigned tasks

Fetch all tasks in a specific status that have no assignee.

**Usage:**
```powershell
# Get all unassigned tasks in client-manager
powershell -File C:\scripts\tools\clickup-task-operations.ps1 -Action GetUnassigned -Project client-manager

# Get unassigned tasks in 'todo' status
powershell -File C:\scripts\tools\clickup-task-operations.ps1 -Action GetUnassigned -Project client-manager -Status todo

# Get unassigned tasks in hazina
powershell -File C:\scripts\tools\clickup-task-operations.ps1 -Action GetUnassigned -Project hazina
```

**Output:**
```
Found 3 unassigned tasks:
  [todo] Implement media library feature
    ID: 869abc123
    URL: https://app.clickup.com/t/869abc123
  [todo] Fix build warnings
    ID: 869def456
    URL: https://app.clickup.com/t/869def456
```

---

### 2. StartWork - Begin working on a task

**Atomic operation:**
1. Move task from current status → `busy`
2. Assign to default assignee (74525428 - Martien de Jong)
3. Post comment: "Jengo work started"

**Usage:**
```powershell
powershell -File C:\scripts\tools\clickup-task-operations.ps1 -Action StartWork -TaskId 869abc123
```

**Output:**
```
=== Starting work on task 869abc123 ===
Fetching task details...
Task: Implement media library feature
Current status: todo
Moving to 'busy' status...
Assigning to user 74525428...
Posting comment 'Jengo work started'...

✓ Task 869abc123 ready for work!
  Status: busy
  Assigned: 74525428
  Comment: Jengo work started
```

---

### 3. SubmitForReview - Submit task for review

**Atomic operation:**
1. Move task from current status → `review`
2. Remove ALL assignees
3. Post comment: "Taak ready voor review" (+ optional PR link)

**Usage:**
```powershell
# With PR link
powershell -File C:\scripts\tools\clickup-task-operations.ps1 `
    -Action SubmitForReview `
    -TaskId 869abc123 `
    -PrUrl "https://github.com/user/repo/pull/123"

# Without PR link
powershell -File C:\scripts\tools\clickup-task-operations.ps1 `
    -Action SubmitForReview `
    -TaskId 869abc123
```

**Output:**
```
=== Submitting task 869abc123 for review ===
Fetching task details...
Task: Implement media library feature
Current status: busy
Moving to 'review' status...
Removing assignees...
Posting review comment...

✓ Task 869abc123 submitted for review!
  Status: review
  Assigned: (none)
  Comment: Taak ready voor review
           PR: https://github.com/user/repo/pull/123
```

---

## Supported Projects

- `client-manager` (List ID: 901214097647)
- `hazina` (List ID: 901215559249)
- `art-revisionist` (List ID: 901211612245)

---

## Typical Workflow

```powershell
# Step 1: Find unassigned tasks
powershell -File C:\scripts\tools\clickup-task-operations.ps1 -Action GetUnassigned -Project client-manager -Status todo

# Step 2: Pick a task and start work
powershell -File C:\scripts\tools\clickup-task-operations.ps1 -Action StartWork -TaskId 869abc123

# Step 3: Do the work (allocate worktree, code, create PR)
# ... your work here ...

# Step 4: Submit for review
powershell -File C:\scripts\tools\clickup-task-operations.ps1 `
    -Action SubmitForReview `
    -TaskId 869abc123 `
    -PrUrl "https://github.com/user/repo/pull/123"
```

---

## Error Handling

All operations are atomic - if any step fails, the entire operation is rolled back (no partial updates).

**Common errors:**
- `ClickUp config not found` → Check `C:\scripts\_machine\clickup-config.json` exists
- `Unknown project` → Use: client-manager, hazina, or art-revisionist
- `API call failed` → Check API key is valid in clickup-config.json

---

## Configuration

**Config file:** `C:\scripts\_machine\clickup-config.json`

```json
{
  "api_key": "pk_74525428_...",
  "default_assignee": 74525428
}
```

**Notes:**
- API key must have read/write access to tasks
- Default assignee is Martien de Jong (74525428)
- All operations use this assignee when assigning tasks

---

## Integration with Consciousness Bridge

When using these operations during sessions, call consciousness bridge hooks:

```powershell
# Before starting work
powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action OnTaskStart -TaskDescription "Implement feature X" -Project "client-manager" -Silent

# After submitting for review
powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action OnTaskEnd -Outcome "success" -LessonsLearned "Feature implemented successfully" -Silent
```

---

**Last Updated:** 2026-02-15
