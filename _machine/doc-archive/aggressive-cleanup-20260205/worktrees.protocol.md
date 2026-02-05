# Worktree Allocation Protocol (ATOMIC)

## 🚨 CRITICAL: This protocol MUST be followed by ALL agents before ANY code edit

### Problem This Solves
When multiple agents run in parallel, they MUST NOT share the same worktree. Each agent MUST have its own isolated worktree to prevent conflicts, data races, and git corruption.

## Atomic Allocation Procedure

### Phase 1: PRE-EDIT CHECK (MANDATORY)

**Before using Edit or Write tools on ANY code file, you MUST:**

1. **Determine if code editing is required**
   - ✅ Reading files, searching, debugging: OK in C:\Projects\<repo>
   - ❌ Editing, writing code: STOP! Must allocate worktree first

2. **If editing is required, proceed to Phase 2**

### Phase 2: WORKTREE ALLOCATION (ATOMIC)

**CRITICAL PRE-CHECK: Ensure base repo is on develop**

```powershell
# Step 0: Verify C:\Projects\<repo> is on develop (REQUIRED)
cd "C:\Projects\<repo>"
$currentBranch = git branch --show-current
if ($currentBranch -ne "develop") {
    Write-Host "⚠️ WARNING: C:\Projects\<repo> is on branch '$currentBranch'"
    Write-Host "Switching to develop..."
    git checkout develop
    git pull origin develop
}

# Verify no uncommitted changes in base repo
$status = git status --porcelain
if ($status) {
    Write-Host "❌ ERROR: C:\Projects\<repo> has uncommitted changes!"
    Write-Host "Base repo must be clean before creating worktrees"
    exit 1
}
```

**This MUST be done atomically before any code edit:**

```powershell
# Step 1: Read the pool to find FREE seat
$pool = Get-Content "C:\scripts\_machine\worktrees.pool.md"

# Step 2: Find first FREE seat
# Parse table, find row with Status = FREE

# Step 3: If NO FREE seat exists, provision new one
# Find highest agent-XXX number, add 1
# Create: C:\Projects\worker-agents\agent-XXX\
# Add row to worktrees.pool.md with Status = FREE

# Step 4: Mark seat as BUSY IMMEDIATELY
# Update Status column from FREE → BUSY
# Update Current repo, Branch, Last activity columns
# Write back to worktrees.pool.md

# Step 5: Log allocation in activity log
# Append line to worktrees.activity.md:
# YYYY-MM-DDTHH:MM:SSZ — allocate — agent-XXX — <repo> — <branch> — <task-ids> — <instance> — <notes>

# Step 6: Update instance mapping
# Update instances.map.md with current session info

# Step 7: Create/update worktree if needed
git worktree add "C:\Projects\worker-agents\agent-XXX\<repo>" -b agent-XXX-<feature>
# OR if worktree exists and correct branch:
cd "C:\Projects\worker-agents\agent-XXX\<repo>" && git pull

# Step 8: Copy config files if needed
# Copy appsettings.json, .env, etc. from C:\Projects\<repo>
```

### Phase 3: WORK IN WORKTREE

**All code edits MUST occur in the allocated worktree:**

- ✅ Edit: C:\Projects\worker-agents\agent-XXX\<repo>\**\*.cs
- ❌ Edit: C:\Projects\<repo>\**\*.cs (FORBIDDEN)

**After each significant checkpoint:**
```powershell
# Update Last activity in worktrees.pool.md
# Append checkin to worktrees.activity.md
```

### Phase 4: RELEASE (MANDATORY)

**When work is complete OR you're switching tasks:**

```powershell
# Step 1: Commit and push changes
cd "C:\Projects\worker-agents\agent-XXX\<repo>"
git add -u
git commit -m "..."
git push origin agent-XXX-<feature>

# Step 2: Create PR if needed
gh pr create --title "..." --body "..."

# Step 3: Mark seat as FREE
# Update worktrees.pool.md: Status = BUSY → FREE

# Step 4: Log release
# Append to worktrees.activity.md:
# YYYY-MM-DDTHH:MM:SSZ — release — agent-XXX — <repo> — <branch> — <task-ids> — <instance> — <notes>

# Step 5: Clear instance mapping
# Remove entry from instances.map.md
```

## 🔒 Concurrency Rules

### Rule 1: ONE AGENT PER WORKTREE
- A worktree with Status = BUSY is LOCKED
- NO other agent may allocate it until Status = FREE
- If all seats are BUSY, provision a new seat (auto-increment)

### Rule 2: ATOMIC ALLOCATION
The allocation MUST be atomic:
```
READ pool → FIND free seat → MARK busy → WRITE pool
```
This prevents race conditions where 2 agents try to allocate the same seat.

### Rule 3: ALWAYS RELEASE
- Never leave a seat as BUSY after your work is done
- If you crash or are interrupted, the seat becomes STALE
- Stale detection: Last activity > 2 hours → mark STALE → FREE

### Rule 4: PROVISION ON DEMAND
- If no FREE seats exist, provision agent-00(N+1)
- Create directory: C:\Projects\worker-agents\agent-00X\
- Add row to worktrees.pool.md with Status = FREE
- Then allocate it immediately (mark BUSY)

## 🚨 Error Handling

### If worktree doesn't exist but pool says BUSY:
```powershell
# Check if git worktree actually exists
git worktree list

# If not: repair seat
# 1. Mark as BROKEN in pool
# 2. Create worktree from scratch
# 3. Mark as BUSY
# 4. Log repair-seat in activity log
```

### If pool file is corrupted:
```
STOP immediately. Ask user to check C:\scripts\_machine\worktrees.pool.md
Do NOT attempt to auto-repair without user approval.
```

### If 2 agents allocated same seat (race condition):
```
This should be IMPOSSIBLE if protocol is followed.
If detected: STOP, mark seat as BROKEN, ask user to investigate.
```

## 📊 Monitoring & Health

### Heartbeat System
- Every 30 minutes of active work: update Last activity timestamp
- Append checkin to worktrees.activity.md

### Stale Detection
- Seats with Last activity > 2 hours AND Status = BUSY → mark STALE
- STALE seats can be forcibly released by any agent:
  ```powershell
  # Mark STALE → FREE
  # Log: YYYY-MM-DDTHH:MM:SSZ — mark-stale — agent-XXX — ...
  ```

### Pool Health Check
Run periodically (daily):
```powershell
# For each seat:
# 1. Check if directory exists
# 2. Check if git worktree is valid
# 3. Check if Last activity is stale
# 4. Mark BROKEN/STALE/FREE as appropriate
```

## 📝 File Format Reference

### worktrees.pool.md
```markdown
| Seat | Agent start branch | Base repo path | Worktree root | Status | Current repo | Branch | Last activity (UTC) | Notes |
|---|---|---|---|---|---|---|---|---|
| agent-001 | agent001 | C:\Projects | C:\Projects\worker-agents\agent-001 | FREE | client-manager | agent001-feature | 2026-01-07T23:12:00Z | ... |
```

Status values: FREE | BUSY | STALE | BROKEN

### worktrees.activity.md
```
YYYY-MM-DDTHH:MM:SSZ — action — seat — repo — branch — task_ids — instance — notes
```

Actions: allocate | checkin | release | mark-stale | provision-seat | repair-seat

### instances.map.md
```markdown
| Instance | Seat | Repo | Branch | Task IDs | Started (UTC) | Last check-in (UTC) |
|---|---|---|---|---|---|---|
| claude-code-session-123 | agent-001 | client-manager | agent-001-feature | task-456 | ... | ... |
```

## 🎯 Quick Decision Tree

```
Do I need to edit code?
├─ NO → Use C:\Projects\<repo> (read-only OK)
└─ YES → STOP!
    └─ Is worktree allocated?
        ├─ NO → Go to Phase 2 (Allocate)
        └─ YES → Is it marked BUSY by ME?
            ├─ YES → Proceed with edit
            └─ NO → ERROR! Someone else using it
```

## 🔧 Implementation Checklist

Before EVERY code edit session:
- [ ] Read worktrees.pool.md
- [ ] Find FREE seat (or provision new)
- [ ] Mark seat BUSY atomically
- [ ] Log allocation in activity log
- [ ] Update instance mapping
- [ ] Verify worktree exists and is correct branch
- [ ] Copy config files if needed
- [ ] NOW you can edit code

After EVERY code edit session:
- [ ] Commit changes
- [ ] Push branch
- [ ] Create PR if applicable
- [ ] Mark seat FREE
- [ ] Log release in activity log
- [ ] Clear instance mapping

## 🚀 Auto-Provision Script (Future)

```powershell
# C:\scripts\tools\provision-worktree.ps1
param(
    [string]$repo,
    [string]$feature
)

# 1. Read pool, find FREE or provision new
# 2. Mark BUSY
# 3. Create worktree
# 4. Log allocation
# 5. Return: agent-XXX path
```

This makes allocation a single atomic operation.
