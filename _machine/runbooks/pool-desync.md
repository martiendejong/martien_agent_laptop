# Runbook: Pool Desync

**Scenario:** `worktrees.pool.md` doesn't match actual worktree state.

---

## Symptoms

- Seat shows FREE but has active worktrees
- Seat shows BUSY but directory is empty
- `worktree-status.ps1` shows warnings
- `system-health.ps1` reports inconsistencies

---

## Diagnosis

```powershell
# 1. Compare pool vs reality
.\tools\worktree-status.ps1 -Compact

# 2. Check specific seat
$seat = "agent-003"
Get-ChildItem "C:\Projects\worker-agents\$seat" -Directory

# 3. Check pool entry
Get-Content C:\scripts\_machine\worktrees.pool.md | Select-String $seat
```

---

## Recovery Steps

### Automated Fix

```powershell
# System health can auto-fix pool desync
.\tools\system-health.ps1 -Fix
```

### Manual Fix

```powershell
# 1. Get actual state
$seat = "agent-003"
$hasWorktrees = (Get-ChildItem "C:\Projects\worker-agents\$seat" -Directory -ErrorAction SilentlyContinue).Count -gt 0

# 2. Update pool.md
# If $hasWorktrees = $true → set to BUSY
# If $hasWorktrees = $false → set to FREE

# 3. Edit file directly
notepad C:\scripts\_machine\worktrees.pool.md

# 4. Verify
.\tools\worktree-status.ps1 -Compact
```

### Full Resync

If multiple seats are wrong:

```powershell
# 1. Get actual state for all seats
$workerPath = "C:\Projects\worker-agents"
Get-ChildItem $workerPath -Directory | ForEach-Object {
    $seat = $_.Name
    $count = (Get-ChildItem $_.FullName -Directory -ErrorAction SilentlyContinue).Count
    Write-Host "$seat : $count worktrees"
}

# 2. Update pool.md to match reality
# Edit _machine/worktrees.pool.md with correct statuses

# 3. Verify
.\tools\system-health.ps1
```

---

## Prevention

1. Always use tools to allocate/release (`claude-ctl.ps1`, `worktree-allocate.ps1`)
2. Don't manually edit worktree directories
3. Run `system-health.ps1` at start of session
4. Complete release workflow before presenting PR

---

## Related

- [worktree-stuck.md](./worktree-stuck.md)
- `system-health.ps1`
- `worktree-status.ps1`
