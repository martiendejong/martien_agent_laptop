# ClickUp ↔ GitHub Workflow

**Created:** 2026-01-14
**Status:** Active

---

## Overview

This document defines how ClickUp tasks are linked to GitHub branches and PRs for the client-manager and hazina repositories.

---

## 1. Naming Convention

### Branch Names
```
<type>/<clickup-id>-<short-description>
```

**Examples:**
```
feature/869bhfw7r-restaurant-menu
fix/869bpz2c0-images-not-generating
refactor/869bmhjh9-product-catalog
```

**Types:**
- `feature/` - New functionality
- `fix/` - Bug fixes
- `refactor/` - Code improvements
- `docs/` - Documentation only
- `test/` - Test additions

### PR Titles
```
<type>: <description> [<clickup-id>]
```

**Examples:**
```
feat: Restaurant menu catalog [869bhfw7r]
fix: Images not generating in chat [869bpz2c0]
```

---

## 2. Linking Criteria

### When to Link ClickUp → GitHub

A ClickUp task gets linked to GitHub when:
- Task status changes to **"busy"** (in progress)
- Task requires code changes in client-manager or hazina

### When to Link GitHub → ClickUp

A GitHub branch/PR gets linked to ClickUp when:
- Branch name contains a ClickUp task ID
- PR is created for a task-related branch

---

## 3. Status Synchronization

| ClickUp Status | GitHub State | Trigger Event |
|----------------|--------------|---------------|
| todo | - | Task created in ClickUp |
| **busy** | Branch + PR open | Agent allocates worktree, starts work |
| **review** | PR merged | PR merged to develop/master → User does acceptance test |
| done | Acceptance passed | User confirms feature works correctly |

### Status Flow

```
todo → busy → review → done
              ↓
         (if test fails)
              ↓
           busy (new branch/PR)
```

### Automatic Updates

When agent creates a PR:
1. Add comment to ClickUp task with PR link
2. Keep ClickUp status at "busy" (PR still open)
3. PR description includes ClickUp task URL

When PR is merged:
1. Update ClickUp status to "review"
2. Add comment: "PR merged - ready for acceptance test"
3. **User performs acceptance test**

After acceptance test:
- **Pass:** User moves to "done"
- **Fail:** Agent creates new branch/PR, keeps status "busy"

---

## 4. Workflow Steps

### Starting Work on a Task

```
1. Check ClickUp for priority tasks
   > clickup-sync.ps1 -Action list

2. Pick a task, note the ID (e.g., 869bhfw7r)

3. ⚠️ CHECK TASK CLARITY (MANDATORY - 2026-02-14) ⭐ NEW STEP
   > powershell -File C:\scripts\tools\clickup-task-clarity-checker.ps1 -TaskId 869bhfw7r -AutoMove
   > If task is UNCLEAR:
     - Script posts questions as comments
     - Moves task to "needs input"
     - STOP and wait for product owner response
   > If task is CLEAR:
     - Continue to step 4
   > Reference: Skill /check-task-clarity
   > Purpose: Prevent wasted work on unclear requirements

4. 📊 PERFORM MOSCOW PRIORITIZATION (MANDATORY - 2026-02-07)
   > Analyze task requirements: Must/Should/Could/Won't Have
   > Post MoSCoW analysis as comment in ClickUp task
   > Reference: C:\scripts\MOSCOW_PRIORITIZATION.md
   > User mandate: Task #869bu91e5

5. Create branch with ClickUp task ID
   > Branch naming: feature/869bhfw7r-restaurant-menu

6. Allocate worktree for branch
   > Allocate agent seat and create worktree for this branch

7. Make changes to implement the feature (MoSCoW-guided)
   > Phase 1: MUST HAVE items (100% complete)
   > Phase 2: SHOULD HAVE items (if time allows)
   > Phase 3: COULD HAVE items (only if trivial)
   > Document WON'T HAVE as TODOs

8. Merge develop into branch before PR
   > git fetch origin && git merge origin/develop
   > Resolve conflicts, ensure build passes, tests pass

9. Create PR with task reference (include MoSCoW in description)
   > gh pr create --base develop --title "feat: Restaurant menu [869bhfw7r]"
   > Include implemented MUST/SHOULD/COULD and deferred items in PR body

10. 🚨 MANDATORY (NON-NEGOTIABLE): Add PR link to ClickUp task
    > clickup-sync.ps1 -Action comment -TaskId 869bhfw7r -Comment "PR #148: https://github.com/martiendejong/client-manager/pull/148"
    > THIS STEP IS REQUIRED - NO EXCEPTIONS

11. Release worktree per zero-tolerance rules
```

### When PR is Merged

```
1. Update ClickUp status to "review" (for acceptance testing)
   > clickup-sync.ps1 -Action update -TaskId 869bhfw7r -Status review

2. Add merge comment
   > clickup-sync.ps1 -Action comment -TaskId 869bhfw7r -Comment "✅ PR merged to develop - ready for acceptance test"
```

### After Acceptance Test

**If test passes (User action):**
- User moves task to "done" in ClickUp

**If test fails:**
```
1. Create new branch from develop
   > Branch: fix/869bhfw7r-restaurant-menu-v2

2. Status stays at "busy"

3. Create new PR, add comment to task
   > clickup-sync.ps1 -Action comment -TaskId 869bhfw7r -Comment "Fix PR #150: https://github.com/..."
```

---

## 5. Reference Format

### In ClickUp Task
```
## GitHub
- Branch: `feature/869bhfw7r-restaurant-menu`
- PR: #148 - https://github.com/martiendejong/client-manager/pull/148
- Status: Merged ✅
```

### In GitHub PR Description
```
## ClickUp Task
https://app.clickup.com/t/869bhfw7r

## Summary
[Description of changes]
```

---

## 6. ID Extraction

### From Branch Name
```powershell
# Extract ClickUp ID from branch
$branch = "feature/869bhfw7r-restaurant-menu"
$taskId = ($branch -split '/')[1] -split '-' | Select-Object -First 1
# Result: 869bhfw7r
```

### From PR Title
```powershell
# Extract ClickUp ID from PR title
$title = "feat: Restaurant menu [869bhfw7r]"
$taskId = [regex]::Match($title, '\[([a-z0-9]+)\]').Groups[1].Value
# Result: 869bhfw7r
```

---

## 7. Validation Rules

### Before Creating Branch
- [ ] Task ID exists in ClickUp
- [ ] Task is in Brand Designer list
- [ ] Task status is appropriate (todo, needs refinement, etc.)
- [ ] **Task clarity verified (not in 'needs input')** ⭐ MANDATORY (2026-02-14)
- [ ] **MoSCoW prioritization analysis performed** ⭐ MANDATORY (2026-02-07)

### Before Creating PR
- [ ] Branch name contains valid ClickUp ID
- [ ] ClickUp task updated to "busy"
- [ ] PR title includes task ID in brackets
- [ ] **MoSCoW analysis posted as ClickUp comment** ⭐ MANDATORY (2026-02-07)
- [ ] **PR description includes implemented MUST/SHOULD/COULD items** ⭐ MANDATORY (2026-02-07)

### Before Merging
- [ ] ClickUp status is "review"
- [ ] PR has ClickUp link in description
- [ ] **All MUST HAVE items implemented** ⭐ MANDATORY (2026-02-07)

---

## 8. Edge Cases

### Task Without Code Changes
- Status: Skip GitHub linking
- Example: "buy tokens" - business/payment task, not code

### Code Change Without Task
- Create ClickUp task first
- Or use branch without ID prefix for urgent fixes
- Document in PR: "No ClickUp task - urgent fix"

### Multiple PRs for One Task
- All PRs reference same task ID
- Add comments to task for each PR
- Only mark "done" when all PRs merged

### One PR for Multiple Tasks
- Use primary task ID in branch name
- Reference all task IDs in PR description
- Update all tasks when PR is merged

---

## 9. Tools

### clickup-sync.ps1 Commands

```powershell
# List tasks
clickup-sync.ps1 -Action list

# Start work on task
clickup-sync.ps1 -Action update -TaskId 869bhfw7r -Status busy

# Mark for review (after PR created)
clickup-sync.ps1 -Action update -TaskId 869bhfw7r -Status review

# Add PR link
clickup-sync.ps1 -Action comment -TaskId 869bhfw7r -Comment "PR #148 created"

# Mark done (after merge)
clickup-sync.ps1 -Action update -TaskId 869bhfw7r -Status done
```

---

## 10. MoSCoW Prioritization Integration (2026-02-07)

**User Mandate:** ClickUp Task #869bu91e5 requires MoSCoW prioritization for all ClickUp work.

### MoSCoW Framework
- **Must Have:** Critical requirements (cannot skip)
- **Should Have:** Important but can defer
- **Could Have:** Nice-to-have (lower priority)
- **Won't Have:** Explicitly out of scope

### Integration Points
1. **Task Analysis:** Categorize requirements before starting
2. **ClickUp Comments:** Post MoSCoW analysis for visibility
3. **Implementation:** Strict priority order (Must → Should → Could)
4. **PR Documentation:** Include MoSCoW breakdown in description

**See:** `C:\scripts\MOSCOW_PRIORITIZATION.md` for complete framework

---

## 11. Task Clarity Check (2026-02-14) ⭐ NEW

**User Mandate:** Before implementing ANY task, verify it's clear enough to proceed.

### Purpose
Prevent wasted work on unclear requirements by checking clarity BEFORE allocating worktrees and writing code.

### When Task is Unclear
Tasks moved to "needs input" status with questions posted automatically when they lack:
- Sufficient detail (<100 chars description)
- Requirements and acceptance criteria
- Technical specs (for integrations, auth details, API endpoints)
- UI/UX details (where in UI, user flow, design mockups)
- Error details (for bug fixes, reproduction steps)
- Trigger detection logic (for AI/LLM features)

### Automated Clarity Review
The system now automatically reviews ALL 'todo' tasks and:
1. Posts questions as comments if unclear
2. Moves unclear tasks to "needs input"
3. Posts confirmation if task is clear and ready

### Example: Unclear Task
**Before:**
- Name: "Fix Social Media Blog Import"
- Description: "Verify that all platforms work correctly"
- Status: todo

**After Clarity Check:**
- Comment posted: "What specific issue or error needs to be fixed? What are the steps to reproduce? Which platforms are affected?"
- Status: needs input
- Agent waits for product owner response

### Example: Clear Task
**Before:**
- Name: "FUTURE: Content Calendar Drag-and-Drop"
- Description: 500+ chars with Requirements, Acceptance Criteria, Technical Notes
- Status: todo

**After Clarity Check:**
- Comment posted: "This task is completely clear and can be implemented now"
- Status: stays todo (ready to implement)
- Agent can proceed to MoSCoW analysis

### Tools
- **Manual check:** `powershell -File C:\scripts\tools\clickup-task-clarity-checker.ps1 -TaskId <id>`
- **Automated check:** `powershell -File C:\scripts\tools\clickup-task-clarity-checker.ps1 -TaskId <id> -AutoMove`
- **Bulk review:** `python E:\jengo\documents\temp\clickup-task-clarity-review.py`
- **Skill:** `/check-task-clarity` in chat

**See:** `C:\scripts\skills\check-task-clarity.skill.md` for complete documentation

---

**Maintained by:** Claude Agent
**Last Updated:** 2026-02-14 (Task clarity check integration)
