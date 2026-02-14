---
name: check-task-clarity
description: Check if a ClickUp task is clear enough to implement. Use BEFORE starting work on any ClickUp task. Auto-posts questions if unclear.
trigger_patterns:
  - "work on clickup task"
  - "implement task"
  - "start task"
  - "clickup task \w+"
auto_invoke: false
user_invocable: true
---

# Check Task Clarity

**Purpose:** Enforce "questions-first" workflow for ClickUp tasks. Before implementing ANY task, verify it's clear enough to proceed.

## When to Use

**MANDATORY before starting work on any ClickUp task:**
- User says "work on task X" or provides ClickUp URL
- You're about to implement a ClickUp task
- Feature Development Mode is triggered by a ClickUp task

## What It Does

1. Fetches task details from ClickUp API
2. Analyzes name + description for clarity
3. Checks for:
   - Sufficient detail (>200 chars)
   - Requirements and acceptance criteria
   - Technical specs for integrations/features
   - UI/UX details for frontend tasks
   - Error details for bug fixes
4. If CLEAR: Confirms and proceeds
5. If UNCLEAR: Posts questions as comments, moves to "needs input", STOPS work

## Clarity Patterns

**Tasks that are usually CLEAR:**
- FUTURE: tasks with "### Requirements" + "### Acceptance Criteria" + 500+ chars
- P1-P4 phase tasks with detailed specs
- Tasks with step-by-step implementation details
- Well-documented epics with sub-tasks

**Tasks that need INPUT:**
- Short descriptions (<100 chars)
- "Fix X" without error details
- "Integrate Y" without auth/API details
- "User should be able to..." without UI/UX specs
- "When user talks about..." without trigger detection logic

## Usage

```bash
# Check single task (manual)
powershell -File C:\scripts\tools\clickup-task-clarity-checker.ps1 -TaskId "869c4vycv"

# Check and auto-move if unclear (automated)
powershell -File C:\scripts\tools\clickup-task-clarity-checker.ps1 -TaskId "869c4vycv" -AutoMove

# Bulk review all 'todo' tasks (Python script)
python E:\jengo\documents\temp\clickup-task-clarity-review.py
```

## Integration with Feature Development Mode

**OLD workflow:**
1. User: "Work on ClickUp task 123"
2. Agent: Allocates worktree → starts coding
3. ❌ Realizes halfway: "Wait, what should the UI look like?"

**NEW workflow (enforced):**
1. User: "Work on ClickUp task 123"
2. Agent: Runs clarity check first
3. If unclear: Posts questions, moves to "needs input", asks user for clarification
4. If clear: Proceeds to worktree allocation → coding

## Questions Posted to ClickUp

The script automatically generates context-aware questions:

**Integration tasks:** "What auth method? Which API endpoints? Do we have credentials?"
**UI tasks:** "Where in the UI? What's the user flow? Any design mockups?"
**Bug fixes:** "What's the error? Steps to reproduce? Expected vs actual behavior?"
**AI features:** "How to detect user intent? Keywords or LLM function calling?"

## Workflow Update

**This is now STEP 0 of Feature Development Mode:**

```
STEP 0: Check task clarity (NEW)
  - Run clickup-task-clarity-checker.ps1
  - If unclear: STOP, post questions, wait for input
  - If clear: Proceed to step 1

STEP 1: Allocate worktree
STEP 2: Implement
STEP 3: PR + release
```

## Benefits

- **Prevents wasted work** on unclear requirements
- **Forces product owner to clarify** BEFORE implementation
- **Documents questions** in ClickUp for future reference
- **Standardizes** what "clear enough" means
- **Reduces back-and-forth** during implementation

## Files

- PowerShell tool: `C:\scripts\tools\clickup-task-clarity-checker.ps1`
- Python bulk script: `E:\jengo\documents\temp\clickup-task-clarity-review.py`
- This skill: `C:\scripts\skills\check-task-clarity.skill.md`

---

**Last Updated:** 2026-02-14
**Status:** ACTIVE - Use before starting ANY ClickUp task
