# Runbook: Worktree Stuck

**Scenario:** Worktree is in an inconsistent state - can't be used or removed.

---

## Symptoms

- `git worktree add` fails with "already exists"
- `git worktree remove` fails with "not a valid worktree"
- Directory exists but no `.git` file
- Pool shows BUSY but worktree is broken

---

## Diagnosis

```powershell
# 1. Check worktree list
git -C C:\Projects\client-manager worktree list

# 2. Check if directory exists
Test-Path "C:\Projects\worker-agents\agent-XXX\client-manager"

# 3. Check if .git file exists
Test-Path "C:\Projects\worker-agents\agent-XXX\client-manager\.git"

# 4. Check pool status
Get-Content C:\scripts\_machine\worktrees.pool.md | Select-String "agent-XXX"
```

---

## Recovery Steps

### Option A: Prune and Recreate

```powershell
# 1. Remove directory manually
Remove-Item -Recurse -Force "C:\Projects\worker-agents\agent-XXX\*"

# 2. Prune worktree references
git -C C:\Projects\client-manager worktree prune
git -C C:\Projects\hazina worktree prune

# 3. Update pool
# Edit _machine/worktrees.pool.md - set agent-XXX to FREE

# 4. Verify
.\tools\worktree-status.ps1
```

### Option B: Force Remove

```powershell
# 1. Force remove specific worktree
git -C C:\Projects\client-manager worktree remove --force "C:\Projects\worker-agents\agent-XXX\client-manager"

# 2. Prune
git -C C:\Projects\client-manager worktree prune
```

### Option C: Manual Git Repair

```powershell
# 1. Remove lock file if present
Remove-Item "C:\Projects\client-manager\.git\worktrees\agent-XXX\locked" -ErrorAction SilentlyContinue

# 2. Remove worktree admin directory
Remove-Item -Recurse "C:\Projects\client-manager\.git\worktrees\agent-XXX" -ErrorAction SilentlyContinue

# 3. Prune
git -C C:\Projects\client-manager worktree prune
```

---

## Prevention

1. Always use `worktree-release-all.ps1` to release worktrees
2. Don't manually delete worktree directories
3. Run `system-health.ps1` periodically
4. If interrupted, run prune before continuing

---

## Related

- [pool-desync.md](./pool-desync.md)
- `worktree-status.ps1`
- `system-health.ps1`
