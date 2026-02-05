# Base Repository Has Uncommitted Changes

## Severity: Low

## Symptoms
- `git status` in C:\Projects\<repo> shows uncommitted changes
- Health check warns "base repo not clean"
- Cannot switch branches or allocate worktree

## Diagnosis

```bash
cd C:\Projects\client-manager  # or hazina
git status
```

Check:
1. Are these changes you made intentionally?
2. Are these debug changes that should be discarded?
3. Are these changes that should be committed?

## Recovery Steps

### Option A: Stash Changes
If you want to keep changes but restore clean state:
```bash
git stash
```
Later: `git stash pop` to restore

### Option B: Discard Changes
If changes are debug/temporary:
```bash
git checkout -- .
git clean -fd
```

### Option C: Commit Changes
If changes should be preserved:
```bash
git add -A
git commit -m "WIP: <description>"
git push origin develop
```

### Option D: Move to Worktree
If you're in Feature Development mode and should be in a worktree:
```bash
# Stash, switch to worktree, apply
git stash
# Allocate worktree via normal process
cd C:\Projects\worker-agents\agent-XXX\<repo>
git stash pop
```

## Prevention

1. **Check mode** before editing - Feature Development vs Active Debugging
2. **Allocate worktree** before making changes in Feature mode
3. **Commit frequently** to avoid large uncommitted states
4. **Run health check** at start of session

## Related
- [pool-desync.md](./pool-desync.md)
- [worktree-stuck.md](./worktree-stuck.md)
