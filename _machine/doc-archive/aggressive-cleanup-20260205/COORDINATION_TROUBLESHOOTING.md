# Parallel Agent Coordination - Troubleshooting Quick Reference

**Purpose:** Fast resolution guide for common coordination issues
**Created:** 2026-01-20 03:00
**For:** Production use with multi-agent coordination

---

## 🚨 Issue Categories

1. **Allocation Conflicts** - Two agents trying to use same resource
2. **Stale State** - Orphaned allocations, crashed agents
3. **Performance Issues** - Slow allocation, high latency
4. **ManicTime Issues** - Activity monitoring not working
5. **State Inconsistency** - Pool vs. git reality mismatch

---

## 1️⃣ Allocation Conflicts

### Symptom: "Conflict Detected" Error

**What you see:**
```
🚨 CONFLICT DETECTED 🚨
There is already another agent working in this branch: agent-001-feature-x
```

**Quick Diagnosis:**
```bash
# Check who's using the branch
grep "agent-001-feature-x" C:/scripts/_machine/worktrees.pool.md
grep "agent-001-feature-x" C:/scripts/_machine/instances.map.md
git -C C:/Projects/client-manager worktree list | grep "agent-001-feature-x"
```

**Quick Fix:**
```bash
# Option 1: Use different branch name
# Append version: agent-001-feature-x-v2

# Option 2: If other agent is stale, reclaim
# (See "Stale State" section below)

# Option 3: Coordinate with other agent
# (If you can identify which session)
```

**Prevention:**
- Always run conflict detection before allocation
- Use unique branch names (include agent-XXX prefix)
- Check agent count before starting work

---

### Symptom: Duplicate Allocation (Same Worktree, Multiple Agents)

**What you see:**
- Git push conflicts
- Two agents editing same files
- Pool shows multiple BUSY for same seat

**Quick Diagnosis:**
```powershell
# Check for duplicates in pool
Get-Content C:/scripts/_machine/worktrees.pool.md | Select-String "BUSY"

# Check git worktrees
git -C C:/Projects/client-manager worktree list
git -C C:/Projects/hazina worktree list

# Cross-reference
```

**Quick Fix:**
```powershell
# 1. Determine winner (most recent activity)
$context = monitor-activity.ps1 -Mode context -OutputFormat object

# 2. Loser agent STOPS work immediately
# 3. Loser releases worktree
# 4. Winner continues

# 5. Manual cleanup if needed
# Edit pool.md: mark correct state
# Edit instances.map.md: remove duplicate entries
```

**Prevention:**
- Coordination strategy active (check agentCount)
- Jitter enabled for ≥3 agents
- Conflict detection before allocation
- Validation running (detects duplicates automatically)

---

## 2️⃣ Stale State

### Symptom: Orphaned Allocation (Agent Crashed)

**What you see:**
- Pool shows BUSY but no agent working
- Last activity > 5 minutes ago
- No heartbeat updates

**Quick Diagnosis:**
```powershell
# Check pool state
cat C:/scripts/_machine/worktrees.pool.md | grep "BUSY"

# Check running processes
$context = monitor-activity.ps1 -Mode context -OutputFormat object
$context.ClaudeInstances.Count

# Check heartbeats
Get-ChildItem C:/scripts/_machine/heartbeats/*.heartbeat |
  ForEach-Object {
    $hb = Get-Content $_ | ConvertFrom-Json
    $age = (Get-Date) - [DateTime]::Parse($hb.Timestamp)
    [PSCustomObject]@{
      Agent = $_.BaseName
      AgeMinutes = [math]::Round($age.TotalMinutes, 1)
      Stale = $age.TotalMinutes -gt 5
    }
  } | Where-Object { $_.Stale }
```

**Quick Fix:**
```powershell
# Automatic (wait for validation - runs every 5 min)
# Validation will auto-reclaim stale allocations

# Manual (immediate):
$staleSeat = "agent-003"  # Replace with actual stale seat

# 1. Edit pool.md: Change BUSY to FREE for $staleSeat
# 2. Remove from instances.map.md

# 3. Clean git worktrees
git -C C:/Projects/client-manager worktree remove "C:/Projects/worker-agents/$staleSeat/client-manager" --force
git -C C:/Projects/hazina worktree remove "C:/Projects/worker-agents/$staleSeat/hazina" --force
git -C C:/Projects/client-manager worktree prune
git -C C:/Projects/hazina worktree prune

# 4. Log recovery
echo "$(Get-Date -Format 'o') | $staleSeat | recovery | stale-cleanup | manual" >> C:/scripts/_machine/worktrees.activity.md
```

**Prevention:**
- Heartbeat active (background job)
- Periodic validation (every 5 min)
- Aggressive timeout (5 min → auto-reclaim)

---

### Symptom: Stale Heartbeat File

**What you see:**
- Heartbeat file exists but process terminated
- Timestamp not updating
- Validation warnings

**Quick Fix:**
```powershell
# Find stale heartbeats
Get-ChildItem C:/scripts/_machine/heartbeats/*.heartbeat |
  ForEach-Object {
    $hb = Get-Content $_ | ConvertFrom-Json
    $processExists = Get-Process -Id $hb.Pid -ErrorAction SilentlyContinue

    if (-not $processExists) {
      Write-Host "Stale heartbeat: $($_.Name) (PID $($hb.Pid) not running)"
      Remove-Item $_.FullName
    }
  }
```

**Prevention:**
- Process cleanup on exit
- Validation scans heartbeat directory
- Heartbeat files have process ID for verification

---

## 3️⃣ Performance Issues

### Symptom: Slow Allocation (>10 seconds)

**What you see:**
- Allocation takes >10 seconds
- User frustration
- Timeout warnings

**Quick Diagnosis:**
```powershell
# Check recent allocation times
Get-Content C:/scripts/_machine/worktrees.activity.md |
  Select-String "allocate" |
  Select-Object -Last 10 |
  ForEach-Object {
    # Parse log entry, extract duration
    # (Format: timestamp | agent | action | repo | branch | result | duration)
  }

# Check agent count (high contention?)
$context = monitor-activity.ps1 -Mode context -OutputFormat object
Write-Host "Active agents: $($context.ClaudeInstances.Count)"

# Check system load
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 ProcessName, CPU, WorkingSet
```

**Quick Fix:**
```powershell
# If high contention (≥3 agents):
# - Ensure pessimistic strategy active
# - Jitter should be enabled (random 0-500ms delay)
# - Check if other agents can defer work

# If system load high:
# - Close unnecessary applications
# - Check for background processes consuming resources

# If git operations slow:
# - Check disk I/O
# - Consider git gc (garbage collection)
# - Verify worktree paths accessible
```

**Prevention:**
- Monitor p99 latency (target: <10s)
- Adaptive strategy (optimistic for low contention)
- Alert if latency > 30s

---

### Symptom: High Conflict Rate (>5%)

**What you see:**
- Frequent "Conflict Detected" errors
- Retry storms
- Poor allocation success rate

**Quick Diagnosis:**
```powershell
# Calculate conflict rate (last hour)
$hourAgo = (Get-Date).AddHours(-1)
$log = Get-Content C:/scripts/_machine/worktrees.activity.md |
  Select-String "allocate" |
  Where-Object {
    $timestamp = ($_ -split '\|')[0].Trim()
    [DateTime]::Parse($timestamp) -gt $hourAgo
  }

$total = $log.Count
$conflicts = ($log | Select-String "conflict").Count
$conflictRate = if ($total -gt 0) { ($conflicts / $total) * 100 } else { 0 }

Write-Host "Conflict rate (last hour): $([math]::Round($conflictRate, 1))%"
Write-Host "Total allocations: $total"
Write-Host "Conflicts: $conflicts"
```

**Quick Fix:**
```powershell
# If conflict rate > 5%:

# 1. Verify conflict detection running
# (Should see in logs before every allocation)

# 2. Check branch naming (are agents using unique names?)
# Pattern should be: agent-XXX-<feature-name>

# 3. Increase jitter for high contention
# (Default: 0-500ms, consider 0-1000ms if ≥5 agents)

# 4. Check for race conditions
# (Two agents checking simultaneously)
# Solution: Stagger agent startup times
```

**Prevention:**
- Unique branch names (agent-XXX prefix)
- Proper jitter implementation
- Conflict detection mandatory
- Monitor conflict rate metric

---

## 4️⃣ ManicTime Issues

### Symptom: monitor-activity.ps1 Times Out

**What you see:**
```
Error: ManicTime database not responding
Timeout after 30 seconds
```

**Quick Diagnosis:**
```powershell
# Check ManicTime process
Get-Process -Name "*ManicTime*" -ErrorAction SilentlyContinue

# Check database file
Test-Path "$env:LOCALAPPDATA\Finkit\ManicTime\ManicTimeCore.db"

# Test query
try {
  $context = monitor-activity.ps1 -Mode current -OutputFormat object
  Write-Host "✓ ManicTime responding"
} catch {
  Write-Host "✗ ManicTime error: $_"
}
```

**Quick Fix:**
```powershell
# 1. Restart ManicTime
Stop-Process -Name "ManicTime" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process "C:\Program Files\ManicTime\ManicTime.exe"
Start-Sleep -Seconds 5

# 2. Verify database accessible
$dbPath = "$env:LOCALAPPDATA\Finkit\ManicTime\ManicTimeCore.db"
if (Test-Path $dbPath) {
  Write-Host "✓ Database found"
} else {
  Write-Host "✗ Database missing"
}

# 3. Fallback to degraded mode
# If ManicTime unavailable, assume single agent:
$agentCount = 1
$strategy = "optimistic"
$userFocused = $true  # Assume user is focused
```

**Prevention:**
- Monitor ManicTime process health
- Implement fallback/degraded mode
- Alert if ManicTime down >1 minute
- Consider ManicTime service auto-restart

---

### Symptom: Incorrect Agent Count

**What you see:**
- ManicTime reports 1 agent but you see 3 windows
- Agent count doesn't match reality

**Quick Diagnosis:**
```powershell
# Get ManicTime view
$context = monitor-activity.ps1 -Mode claude -OutputFormat object
Write-Host "ManicTime reports: $($context.Count) Claude instances"

# Get process list view
$processes = Get-Process |
  Where-Object {
    $_.ProcessName -match "claude|anthropic" -or
    $_.MainWindowTitle -match "Claude"
  }
Write-Host "Process list shows: $($processes.Count) processes"

# Compare
if ($context.Count -ne $processes.Count) {
  Write-Host "⚠️  Mismatch detected!"
  Write-Host "ManicTime may not be tracking all windows"
}
```

**Quick Fix:**
```powershell
# Use process list as ground truth
$agentCount = (Get-Process |
  Where-Object {
    $_.ProcessName -match "claude" -or
    $_.MainWindowTitle -match "Claude"
  }).Count

Write-Host "Using corrected agent count: $agentCount"
```

**Prevention:**
- Validate ManicTime data against process list
- Use both sources (ManicTime + process list)
- Alert on mismatches

---

## 5️⃣ State Inconsistency

### Symptom: Pool Shows BUSY but No Git Worktree

**What you see:**
- worktrees.pool.md says BUSY
- `git worktree list` shows no worktree
- Allocation records orphaned

**Quick Diagnosis:**
```bash
# Check pool
cat C:/scripts/_machine/worktrees.pool.md | grep "BUSY"

# Check git reality
git -C C:/Projects/client-manager worktree list
git -C C:/Projects/hazina worktree list

# Find mismatches
# (Pool BUSY but no corresponding git worktree)
```

**Quick Fix:**
```powershell
# Automatic: Wait for validation (runs every 5 min)

# Manual:
# 1. Identify orphaned entries in pool.md
# 2. Edit pool.md: Change BUSY to FREE
# 3. Remove from instances.map.md
# 4. Log repair:
echo "$(Get-Date -Format 'o') | validation | repair | orphaned-pool-entry" >> C:/scripts/_machine/worktrees.activity.md
```

**Prevention:**
- Periodic validation (every 5 min)
- Always release worktree after PR
- Never edit pool.md without updating git worktrees
- Atomic operations (pool + git together)

---

### Symptom: Git Worktree Exists but Pool Shows FREE

**What you see:**
- `git worktree list` shows active worktree
- Pool.md says FREE for that seat
- Untracked allocation

**Quick Fix:**
```powershell
# 1. Determine if worktree is truly in use
# Check for recent commits, file changes

# 2. If active:
# - Edit pool.md: Mark BUSY
# - Add to instances.map.md
# - Create heartbeat

# 3. If abandoned:
# - Remove git worktree
# - Keep pool.md as FREE
```

---

## 🔍 Diagnostic Commands Quick Reference

```powershell
# Agent count and activity
monitor-activity.ps1 -Mode context -OutputFormat object

# Pool status
cat C:/scripts/_machine/worktrees.pool.md

# Git worktrees
git -C C:/Projects/client-manager worktree list
git -C C:/Projects/hazina worktree list

# Running agents
Get-Process | Where-Object { $_.MainWindowTitle -match "Claude" }

# Heartbeats
Get-ChildItem C:/scripts/_machine/heartbeats/*.heartbeat

# Recent allocations
cat C:/scripts/_machine/worktrees.activity.md | tail -20

# Conflict detection (test)
bash C:/scripts/tools/check-branch-conflicts.sh client-manager test-branch

# Full health check
pwsh -Command "Test-SystemHealth"

# Validation (manual trigger)
pwsh -Command "Invoke-CoordinationValidation"

# Metrics dashboard
pwsh -Command "Get-AgentCoordinationMetrics -Live"
```

---

## 🎯 Escalation Path

**Level 1: Auto-Repair (Validation)**
- Runs every 5 minutes
- Auto-fixes orphaned allocations, stale heartbeats
- Logs all repairs

**Level 2: Manual Diagnosis**
- Use this troubleshooting guide
- Run diagnostic commands
- Apply quick fixes

**Level 3: System Reset**
```powershell
# If coordination completely broken:

# 1. Stop all agents
# 2. Release all worktrees
bash C:/scripts/tools/worktree-release-all.ps1 -Force

# 3. Reset pool to all FREE
# Edit pool.md manually

# 4. Clean up state files
Remove-Item C:/scripts/_machine/instances.map.md
# Recreate empty file

# 5. Prune all worktrees
git -C C:/Projects/client-manager worktree prune
git -C C:/Projects/hazina worktree prune

# 6. Verify base repos on develop
git -C C:/Projects/client-manager checkout develop
git -C C:/Projects/hazina checkout develop

# 7. Restart agents one by one
```

**Level 4: Log Investigation**
- Review reflection.log.md for patterns
- Check worktrees.activity.md for timeline
- Analyze metrics trends

---

## 📊 Health Check Commands

```powershell
# Quick health check (30 seconds)
Test-SystemHealth

# Full validation (2 minutes)
Invoke-CoordinationValidation

# Metrics dashboard (real-time)
Get-AgentCoordinationMetrics -Live -RefreshSeconds 5

# Check specific agent
Get-AgentStatus -AgentId "agent-003"

# Pool utilization
Get-PoolUtilization
```

---

**Last Updated:** 2026-01-20 03:00
**For:** Multi-agent coordination troubleshooting
**Reference:** See `SYSTEM_INTEGRATION.md` for complete protocol
**Support:** Check `reflection.log.md` for lessons learned from past issues
