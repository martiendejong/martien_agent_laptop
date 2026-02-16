# workflow-check.md - Mandatory Pre-Flight Checklist

## Purpose
This file enforces the worktree-first workflow. Every code edit must follow this checklist.

## Decision Tree: Can I edit this file?

```
User requests code changes
    │
    ├─ Is this READING files? ────────────────────────> ✅ YES: Use C:\Projects\<repo>
    │                                                         (Glob, Grep, Read tools OK)
    │
    └─ Is this EDITING/WRITING code?
           │
           └─ Where am I about to edit?
                │
                ├─ C:\Projects\<repo> ────────────────> ❌ STOP! WRONG LOCATION!
                │                                          Go to Step 1 below
                │
                └─ C:\Projects\worker-agents\agent-XXX\ ─> ✅ OK if worktree allocated
                                                             (check steps 1-5 completed)
```

## MANDATORY Steps Before ANY Code Edit

### Step 1: Read worktree pool
```bash
Read C:\scripts\_machine\worktrees.pool.md
```
Look for a FREE seat. If none exists, provision new seat (agent-002, agent-003, etc.)

### Step 2: Create git worktree
```bash
cd C:\Projects\<repo>
git worktree add C:\Projects\worker-agents\agent-XXX\<repo> -b agent-XXX-<feature-name>
```

### Step 3: Update worktree pool (mark BUSY)
```
Edit worktrees.pool.md:
- Change seat status from FREE to BUSY
- Set "Current repo" to <repo-name>
- Set "Branch" to agent-XXX-<feature-name>
- Set "Last activity" to current UTC timestamp
```

### Step 4: Log allocation
```
Append to worktrees.activity.md:
- Timestamp
- Seat allocated
- Repo name
- Branch name
- Task description
```

### Step 5: NOW you can edit
All Edit and Write operations must target:
```
C:\Projects\worker-agents\agent-XXX\<repo>\...
```

## After Completing Work

### Step 6: Commit and push
```bash
cd C:\Projects\worker-agents\agent-XXX\<repo>
git add .
git commit -m "..."
git push origin agent-XXX-<feature-name>
```

### Step 7: Create PR (if applicable)
```bash
gh pr create --base main --head agent-XXX-<feature-name>
```

### Step 8: Release worktree
```
Edit worktrees.pool.md:
- Change seat status from BUSY to FREE
- Clear "Current repo", "Branch"
- Update "Last activity"

Append to worktrees.activity.md:
- Completion timestamp
- Seat released
- Work summary
- PR link (if created)
```

## Common Mistakes to Avoid

1. ❌ Jumping straight to Edit tool without checking worktree pool
2. ❌ Editing files in C:\Projects\<repo> directly
3. ❌ Forgetting to update worktrees.pool.md
4. ❌ Not logging activity
5. ❌ Pattern-matching to "fix mode" without workflow check

## Recovery from Mistakes

If you accidentally edited in C:\Projects\<repo>:
1. User must approve keeping the changes
2. Commit changes to current branch
3. Log incident in reflection.log.md
4. Update this workflow to prevent recurrence
5. Continue with proper workflow for next task

## Enforcement

This checklist is MANDATORY. No exceptions unless explicitly authorized by user.
Reading claude_info.txt or claude.md at session start does not exempt you from this workflow.
You must actively check worktree allocation before every code edit session.
