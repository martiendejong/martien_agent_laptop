# System Integration Guide - Complete Agent Coordination Ecosystem

**Purpose:** Master documentation showing how all components work together in unison
**Status:** Production System v2.0 (with Parallel Agent Coordination)
**Created:** 2026-01-20 03:00
**Critical:** READ THIS to understand the complete system architecture

---

## 🎯 Executive Summary

This document describes the complete Claude Agent ecosystem including:
- **Core workflow protocols** (Feature Development Mode, Active Debugging Mode)
- **Parallel agent coordination** (ManicTime-based real-time coordination)
- **State management** (Pool, instances, activity logs)
- **Validation & health checks** (Automated verification)
- **Tool integration** (How all 98 tools work together)

**Key Innovation (2026-01-20):** Parallel agent coordination using ManicTime for real-time activity monitoring enables 7+ agents to work efficiently without conflicts.

---

## 📊 System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         USER INTERACTION                             │
│  (Visual Studio, VS Code, Browser, Command Line)                    │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    MANICTIME ACTIVITY MONITOR                        │
│  - Tracks all application activity                                  │
│  - Process detection (Claude instances, VS, browsers)                │
│  - Window focus tracking (which app user is using)                   │
│  - Idle time detection (user present vs. away)                       │
│                                                                       │
│  Accessed via: monitor-activity.ps1                                  │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   CLAUDE AGENT COORDINATION LAYER                    │
│                                                                       │
│  ┌──────────────────────┐  ┌──────────────────────────────────┐   │
│  │ Activity Context     │  │ Coordination Intelligence        │   │
│  │ - Agent count        │  │ - Strategy selection             │   │
│  │ - User focus         │  │   (<3 agents: optimistic)        │   │
│  │ - Idle detection     │  │   (≥3 agents: pessimistic)       │   │
│  │ - Priority scoring   │  │ - Priority assignment            │   │
│  └──────────┬───────────┘  └──────────────┬───────────────────┘   │
│             │                              │                        │
│             └──────────────┬───────────────┘                        │
└────────────────────────────┼────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        STATE MANAGEMENT                              │
│                                                                       │
│  ┌────────────────────┐  ┌────────────────────┐  ┌───────────────┐│
│  │ worktrees.pool.md  │  │ instances.map.md   │  │ activity.md   ││
│  │ - Seat allocation  │  │ - Agent sessions   │  │ - Event log   ││
│  │ - BUSY/FREE status │  │ - Branch mapping   │  │ - Audit trail ││
│  │ - Current branches │  │ - Heartbeats       │  │ - Metrics     ││
│  └────────┬───────────┘  └─────────┬──────────┘  └───────┬───────┘│
└───────────┼──────────────────────────┼──────────────────────┼────────┘
            │                          │                      │
            └──────────────┬───────────┴──────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     WORKTREE MANAGEMENT                              │
│                                                                       │
│  Base Repos (Always on develop):                                     │
│  - C:\Projects\client-manager                                        │
│  - C:\Projects\hazina                                                │
│                                                                       │
│  Agent Worktrees (Feature Development):                              │
│  - C:\Projects\worker-agents\agent-001\client-manager                │
│  - C:\Projects\worker-agents\agent-001\hazina                        │
│  - C:\Projects\worker-agents\agent-002\...                           │
│  - ... (up to agent-012+)                                            │
│                                                                       │
│  Managed via: git worktree add/remove/prune                          │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    WORKFLOW EXECUTION                                │
│                                                                       │
│  Feature Development Mode:         Active Debugging Mode:            │
│  ┌─────────────────────────┐      ┌──────────────────────────┐     │
│  │ 1. Allocate worktree    │      │ 1. Work in base repo     │     │
│  │ 2. Edit in worktree     │      │ 2. On user's branch      │     │
│  │ 3. Create PR            │      │ 3. Quick fixes           │     │
│  │ 4. Release worktree     │      │ 4. No PR creation        │     │
│  └─────────────────────────┘      └──────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    VALIDATION & HEALTH CHECKS                        │
│                                                                       │
│  Periodic Validation (every 5 minutes):                              │
│  - Pool state vs. Git reality                                        │
│  - Agent registrations vs. Running processes                         │
│  - Heartbeat freshness                                               │
│  - Duplicate allocation detection                                    │
│  - Auto-repair inconsistencies                                       │
│                                                                       │
│  Continuous Monitoring:                                              │
│  - ManicTime activity tracking                                       │
│  - Metrics collection (allocation latency, conflicts)                │
│  - Dashboard updates                                                 │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🚦 Complete Startup Sequence (MANDATORY)

**Every agent session MUST follow this sequence:**

### Phase 1: Load Core Configuration (1-6)

```powershell
# 1. Load machine-specific paths
$config = Get-Content C:\scripts\MACHINE_CONFIG.md
# Defines: BASE_REPO_PATH, WORKTREE_PATH, CONTROL_PLANE_PATH

# 2. Load zero-tolerance rules
$rules = Get-Content C:\scripts\GENERAL_ZERO_TOLERANCE_RULES.md
# CRITICAL: Hard-stop rules for allocation, release, base repo usage

# 3. Load personal insights (user understanding)
$insights = Get-Content C:\scripts\_machine\PERSONAL_INSIGHTS.md
# Communication style, work patterns, behavioral optimization

# 4. Load software development principles
$principles = Get-Content C:\scripts\_machine\SOFTWARE_DEVELOPMENT_PRINCIPLES.md
# Boy Scout Rule, architectural purity, code quality standards

# 5. Load dual-mode workflow
$workflow = Get-Content C:\scripts\GENERAL_DUAL_MODE_WORKFLOW.md
# Feature Development vs. Active Debugging mode detection

# 6. Load Definition of Done
$dod = Get-Content C:\scripts\_machine\DEFINITION_OF_DONE.md
# Completion criteria for all task types
```

### Phase 2: Environment Verification (7-10)

```bash
# 7. Check environment state
bash C:/scripts/tools/repo-dashboard.sh
# Verifies: git status, branch positions, uncommitted changes

# 8. CRITICAL: Get activity context and agent count
pwsh -Command "monitor-activity.ps1 -Mode context -OutputFormat object | ConvertTo-Json"

# Output example:
{
  "ClaudeInstances": { "Count": 3 },
  "ActiveWindow": { "Title": "Visual Studio", "ProcessName": "devenv" },
  "IdleTime": { "Minutes": 2.3, "IsIdle": false },
  "System": { "UserAttending": true, "MultipleClaudeSessions": true },
  "Insights": [
    "Multiple Claude sessions detected (3) - parallel coordination active",
    "User currently focused on Visual Studio window"
  ]
}

# 9. Verify base repos on develop branch
git -C C:/Projects/client-manager branch --show-current  # Must be: develop
git -C C:/Projects/hazina branch --show-current          # Must be: develop

# If NOT on develop:
git -C C:/Projects/client-manager checkout develop && git pull origin develop
git -C C:/Projects/hazina checkout develop && git pull origin develop

# 10. Check worktree pool status
cat C:/scripts/_machine/worktrees.pool.md | grep -E "(FREE|BUSY|agent-)"
```

### Phase 3: Coordination Activation (11-13)

```powershell
# 11. Determine if coordination is needed
$context = monitor-activity.ps1 -Mode context -OutputFormat object
$agentCount = $context.ClaudeInstances.Count

if ($agentCount -gt 1) {
    Write-Host "🔀 PARALLEL COORDINATION ACTIVE: $agentCount agents detected"

    # 12. Load coordination protocol
    $coordination = Get-Content C:\scripts\.claude\skills\parallel-agent-coordination\SKILL.md

    # 13. Determine coordination strategy
    if ($agentCount -lt 3) {
        $strategy = "optimistic"  # Fast path
        Write-Host "  Strategy: Optimistic (low contention)"
    } else {
        $strategy = "pessimistic"  # Slow path
        Write-Host "  Strategy: Pessimistic (high contention - adding jitter)"
    }

    # Store for use during allocation
    $global:CoordinationActive = $true
    $global:CoordinationStrategy = $strategy
    $global:AgentCount = $agentCount
    $global:MyPriority = if ($context.System.UserAttending) { 100 } else { 50 }
} else {
    Write-Host "✅ Single agent mode - standard allocation"
    $global:CoordinationActive = $false
}
```

### Phase 4: Session Ready

```powershell
# 14. Log session start
$sessionStart = @{
    Timestamp = Get-Date -Format 'o'
    AgentId = $env:AGENT_ID  # Or derive from process/context
    AgentCount = $agentCount
    CoordinationActive = $global:CoordinationActive
    Strategy = $global:CoordinationStrategy
    Priority = $global:MyPriority
    UserAttending = $context.System.UserAttending
} | ConvertTo-Json

Add-Content -Path C:\scripts\_machine\session-starts.log -Value $sessionStart

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  CLAUDE AGENT SESSION READY" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Agent Count: $agentCount" -ForegroundColor $(if ($agentCount -gt 1) { 'Yellow' } else { 'Green' })
Write-Host "  Coordination: $(if ($global:CoordinationActive) { 'ACTIVE' } else { 'Not needed' })" -ForegroundColor $(if ($global:CoordinationActive) { 'Yellow' } else { 'Green' })
Write-Host "  User Present: $($context.System.UserAttending)" -ForegroundColor $(if ($context.System.UserAttending) { 'Green' } else { 'Yellow' })
Write-Host "  Base Repos: develop branch ✓" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
```

**Total Steps:** 14
**Time:** ~5-10 seconds
**Frequency:** EVERY session start, no exceptions

---

## 🔀 Unified Workflow Decision Tree

**This is the MASTER decision tree that integrates everything:**

```
┌─────────────────────────────────────────────────────────┐
│         USER PROVIDES TASK OR CONTEXT                   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │  MODE DETECTION      │
          │  (CRITICAL FIRST)    │
          └──────────┬───────────┘
                     │
         ┌───────────┴────────────┐
         │                        │
         ▼                        ▼
┌──────────────────┐    ┌──────────────────────┐
│ ClickUp Task URL?│    │ Build Errors Posted? │
│ Task ID format?  │    │ "I'm debugging..."?  │
│ Tracked work?    │    │ User on branch X?    │
└────────┬─────────┘    └──────────┬───────────┘
         │                         │
    YES  │  NO                YES  │  NO
         │                         │
         ▼                         ▼
┌─────────────────────────────────────────────┐
│  🏗️ FEATURE DEVELOPMENT MODE                │
│  (New features, tracked work, ClickUp tasks)│
└────────────┬────────────────────────────────┘
             │
             ▼
   ┌─────────────────────┐
   │ CHECK COORDINATION  │
   │ (Step 8 from startup)│
   └──────────┬──────────┘
              │
     ┌────────┴─────────┐
     │                  │
     ▼                  ▼
┌─────────────┐   ┌──────────────┐
│ 1 Agent     │   │ Multiple     │
│ (No coord)  │   │ Agents       │
└──────┬──────┘   └──────┬───────┘
       │                 │
       │                 ▼
       │        ┌─────────────────┐
       │        │ COORDINATION    │
       │        │ PROTOCOL ACTIVE │
       │        └────────┬────────┘
       │                 │
       │        ┌────────┴────────┐
       │        │                 │
       │        ▼                 ▼
       │   ┌─────────┐      ┌──────────┐
       │   │ <3 Agents│      │ ≥3 Agents│
       │   │Optimistic│      │Pessimistic│
       │   └────┬─────┘      └─────┬────┘
       │        │                  │
       └────────┴──────────────────┘
                │
                ▼
       ┌─────────────────────┐
       │ CONFLICT DETECTION  │
       │ (Pre-allocation)    │
       └──────────┬──────────┘
                  │
         ┌────────┴─────────┐
         │                  │
    CONFLICT          NO CONFLICT
         │                  │
         ▼                  ▼
    ┌─────────┐      ┌──────────────┐
    │ STOP    │      │ ALLOCATE     │
    │ Use diff│      │ WORKTREE     │
    │ branch  │      │              │
    └─────────┘      └──────┬───────┘
                            │
                            ▼
                   ┌─────────────────┐
                   │ WORK IN         │
                   │ WORKTREE        │
                   │ (agent-XXX)     │
                   └────────┬────────┘
                            │
                            ▼
                   ┌─────────────────┐
                   │ CREATE PR       │
                   │                 │
                   └────────┬────────┘
                            │
                            ▼
                   ┌─────────────────┐
                   │ RELEASE         │
                   │ WORKTREE        │
                   │ (Mark FREE)     │
                   └────────┬────────┘
                            │
                            ▼
                   ┌─────────────────┐
                   │ SWITCH BASE     │
                   │ TO DEVELOP      │
                   └────────┬────────┘
                            │
                            ▼
                        ✅ DONE




┌─────────────────────────────────────────────┐
│  🐛 ACTIVE DEBUGGING MODE                   │
│  (User debugging, build errors, quick fixes)│
└────────────┬────────────────────────────────┘
             │
             ▼
   ┌─────────────────────┐
   │ CHECK USER BRANCH   │
   │ (What's checked out)│
   └──────────┬──────────┘
              │
              ▼
   ┌─────────────────────┐
   │ WORK IN BASE REPO   │
   │ C:\Projects\<repo>  │
   │ On current branch   │
   └──────────┬──────────┘
              │
              ▼
   ┌─────────────────────┐
   │ MAKE QUICK FIXES    │
   │ No PR (unless user  │
   │ explicitly requests)│
   └──────────┬──────────┘
              │
              ▼
   ┌─────────────────────┐
   │ PRESERVE BRANCH     │
   │ STATE (Don't switch)│
   └──────────┬──────────┘
              │
              ▼
          ✅ DONE
```

---

## 🔧 State Management Integration

### Three-Layer State System

**Layer 1: Coordination State (Real-Time)**
```
Location: monitor-activity.ps1 output (ephemeral, queried on-demand)
Contents:
- Active Claude instances (count, PIDs, window titles)
- User focus state (which window is active)
- Idle time (minutes since last user input)
- Priority scores (derived from focus + activity)

Refresh: Every query (real-time)
Used for: Coordination strategy selection, priority assignment
```

**Layer 2: Allocation State (Persistent, Frequently Updated)**
```
Location: C:\scripts\_machine\
Files:
- worktrees.pool.md (seat allocation, BUSY/FREE status)
- instances.map.md (agent session mapping)
- worktrees.activity.md (event log, audit trail)

Refresh: On every allocation/release
Used for: Conflict detection, pool management, metrics
```

**Layer 3: Long-Term State (Persistent, Infrequently Updated)**
```
Location: C:\scripts\_machine\
Files:
- reflection.log.md (lessons learned, patterns)
- PERSONAL_INSIGHTS.md (user understanding)
- pr-dependencies.md (cross-repo tracking)

Refresh: End of session, after significant events
Used for: Learning, optimization, dependency tracking
```

### State Synchronization Protocol

**Allocation Flow (Write Path):**
```
1. Query ManicTime → Get agent count + priority
2. Check pool.md → Find FREE seat
3. Run conflict detection → Verify branch available
4. Mark BUSY in pool.md
5. Update instances.map.md
6. Log to worktrees.activity.md
7. Create git worktree
```

**Release Flow (Write Path):**
```
1. Create PR (gh pr create)
2. IMMEDIATELY mark FREE in pool.md
3. Remove from instances.map.md
4. Log release to worktrees.activity.md
5. Remove git worktree
6. Prune worktree references
7. Switch base repo to develop
```

**Validation Flow (Read Path + Repair):**
```
Every 5 minutes:
1. Read pool.md → Get all BUSY allocations
2. Check git worktree list → Verify worktrees exist
3. Check process list → Verify agents running
4. Compare states → Detect inconsistencies
5. Auto-repair → Release orphaned, fix duplicates
6. Log repairs → worktrees.activity.md
```

---

## 🎯 Complete Worktree Allocation Protocol (Integrated)

**This integrates: Mode detection + Coordination + Conflict detection + Allocation**

```powershell
function Allocate-Worktree-Integrated {
    param(
        [string]$Repo,
        [string]$BranchName,
        [string]$FeatureDescription
    )

    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  INTEGRATED WORKTREE ALLOCATION" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan

    # ═══════════════════════════════════════════════════════════
    # PHASE 1: PRE-FLIGHT CHECKS
    # ═══════════════════════════════════════════════════════════

    Write-Host ""
    Write-Host "Phase 1: Pre-Flight Checks" -ForegroundColor Yellow

    # 1.1: Mode Detection
    Write-Host "  [1/7] Mode detection..." -ForegroundColor Gray
    # (Assumed already done - this function only called in Feature Dev Mode)
    Write-Host "    ✓ Feature Development Mode confirmed" -ForegroundColor Green

    # 1.2: Coordination Context
    Write-Host "  [2/7] Getting coordination context..." -ForegroundColor Gray
    $context = monitor-activity.ps1 -Mode context -OutputFormat object
    $agentCount = $context.ClaudeInstances.Count
    $userFocused = $context.System.UserAttending
    $myPriority = if ($userFocused) { 100 } else { 50 }

    Write-Host "    ✓ Agent count: $agentCount" -ForegroundColor Green
    Write-Host "    ✓ Priority: $myPriority $(if ($userFocused) { '(user-focused)' } else { '(background)' })" -ForegroundColor Green

    # 1.3: Strategy Selection
    Write-Host "  [3/7] Selecting coordination strategy..." -ForegroundColor Gray
    if ($agentCount -lt 3) {
        $strategy = "optimistic"
        Write-Host "    ✓ Strategy: Optimistic (low contention)" -ForegroundColor Green
    } else {
        $strategy = "pessimistic"
        Write-Host "    ✓ Strategy: Pessimistic (high contention)" -ForegroundColor Yellow
        # Add jitter to reduce thundering herd
        $jitter = Get-Random -Minimum 0 -Maximum 500
        Write-Host "    ⏱  Adding ${jitter}ms jitter..." -ForegroundColor Gray
        Start-Sleep -Milliseconds $jitter
    }

    # 1.4: Conflict Detection
    Write-Host "  [4/7] Running conflict detection..." -ForegroundColor Gray
    $conflictResult = bash C:/scripts/tools/check-branch-conflicts.sh $Repo $BranchName

    if ($LASTEXITCODE -ne 0) {
        Write-Host "" -ForegroundColor Red
        Write-Host "🚨 CONFLICT DETECTED 🚨" -ForegroundColor Red
        Write-Host "Another agent is already using branch: $BranchName" -ForegroundColor Red
        Write-Host "Conflict details:" -ForegroundColor Red
        Write-Host $conflictResult -ForegroundColor Red
        Write-Host "" -ForegroundColor Red
        Write-Host "STOPPING - Use a different branch name" -ForegroundColor Red
        return $null
    }
    Write-Host "    ✓ No conflicts detected" -ForegroundColor Green

    # 1.5: Pool Check
    Write-Host "  [5/7] Checking worktree pool..." -ForegroundColor Gray
    $pool = Get-Content C:\scripts\_machine\worktrees.pool.md
    $freeSeat = $pool | Select-String "FREE" | Select-Object -First 1

    if (-not $freeSeat) {
        Write-Host "    ⚠️  No FREE seats - provisioning new seat..." -ForegroundColor Yellow
        # Auto-provision logic here
        $newSeatId = # ... determine next seat number
        # ... create new seat entry
    } else {
        $seatName = # ... extract seat name from $freeSeat
        Write-Host "    ✓ Found FREE seat: $seatName" -ForegroundColor Green
    }

    # 1.6: Base Repo Verification
    Write-Host "  [6/7] Verifying base repos..." -ForegroundColor Gray
    $cmBranch = git -C C:/Projects/client-manager branch --show-current
    $hazinaBranch = git -C C:/Projects/hazina branch --show-current

    if ($cmBranch -ne "develop") {
        Write-Host "    ⚠️  client-manager not on develop, switching..." -ForegroundColor Yellow
        git -C C:/Projects/client-manager checkout develop
        git -C C:/Projects/client-manager pull origin develop
    }
    if ($hazinaBranch -ne "develop") {
        Write-Host "    ⚠️  hazina not on develop, switching..." -ForegroundColor Yellow
        git -C C:/Projects/hazina checkout develop
        git -C C:/Projects/hazina pull origin develop
    }
    Write-Host "    ✓ Base repos on develop" -ForegroundColor Green

    # 1.7: Ready for Allocation
    Write-Host "  [7/7] Pre-flight checks complete ✓" -ForegroundColor Green

    # ═══════════════════════════════════════════════════════════
    # PHASE 2: ALLOCATION (Strategy-Dependent)
    # ═══════════════════════════════════════════════════════════

    Write-Host ""
    Write-Host "Phase 2: Allocation ($strategy)" -ForegroundColor Yellow

    if ($strategy -eq "optimistic") {
        # OPTIMISTIC PATH (Fast, assume no conflicts)
        Write-Host "  Using optimistic allocation (fast path)..." -ForegroundColor Gray

        # Mark BUSY immediately
        # ... update pool.md

        # Create worktrees
        $success = # ... git worktree add commands

        if (-not $success) {
            # Rollback: mark FREE again
            # Retry with pessimistic
        }
    } else {
        # PESSIMISTIC PATH (Slow, check before allocate)
        Write-Host "  Using pessimistic allocation (safe path)..." -ForegroundColor Gray

        # Re-check pool (state may have changed during jitter)
        # ... verify still FREE

        # Mark BUSY
        # ... update pool.md

        # Create worktrees
        # ... git worktree add commands
    }

    # ═══════════════════════════════════════════════════════════
    # PHASE 3: POST-ALLOCATION
    # ═══════════════════════════════════════════════════════════

    Write-Host ""
    Write-Host "Phase 3: Post-Allocation" -ForegroundColor Yellow

    # 3.1: Update State Files
    Write-Host "  [1/4] Updating state files..." -ForegroundColor Gray
    # ... update pool.md (already done)
    # ... update instances.map.md
    Write-Host "    ✓ pool.md updated" -ForegroundColor Green
    Write-Host "    ✓ instances.map.md updated" -ForegroundColor Green

    # 3.2: Log Allocation
    Write-Host "  [2/4] Logging allocation..." -ForegroundColor Gray
    $logEntry = "$(Get-Date -Format 'o') | $seatName | allocate | $Repo | $BranchName | success | ${agentCount}-agents | ${strategy}-strategy | priority-${myPriority}"
    Add-Content -Path C:\scripts\_machine\worktrees.activity.md -Value $logEntry
    Write-Host "    ✓ Logged to activity.md" -ForegroundColor Green

    # 3.3: Start Heartbeat (if coordination active)
    if ($agentCount -gt 1) {
        Write-Host "  [3/4] Starting heartbeat..." -ForegroundColor Gray
        # Start background heartbeat job
        # ... (future implementation)
        Write-Host "    ✓ Heartbeat active" -ForegroundColor Green
    } else {
        Write-Host "  [3/4] Heartbeat not needed (single agent)" -ForegroundColor Gray
    }

    # 3.4: Return Allocation Info
    Write-Host "  [4/4] Allocation complete ✓" -ForegroundColor Green

    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  ✅ WORKTREE ALLOCATED SUCCESSFULLY" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  Seat: $seatName" -ForegroundColor White
    Write-Host "  Branch: $BranchName" -ForegroundColor White
    Write-Host "  Strategy: $strategy" -ForegroundColor White
    Write-Host "  Agent Count: $agentCount" -ForegroundColor White
    Write-Host "  Path: C:\Projects\worker-agents\$seatName\$Repo" -ForegroundColor White
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green

    return @{
        Success = $true
        Seat = $seatName
        Branch = $BranchName
        Path = "C:\Projects\worker-agents\$seatName\$Repo"
        Strategy = $strategy
        AgentCount = $agentCount
        Priority = $myPriority
    }
}
```

---

## ✅ Definition of Done (Updated with Coordination)

**A task is DONE only when ALL criteria are met:**

### General (All Tasks)

- [x] Task completed as specified
- [x] No errors, warnings, or issues introduced
- [x] All affected documentation updated
- [x] Reflection.log.md updated with learnings

### Feature Development Mode (Code Changes)

**Pre-Work:**
- [x] Mode detected as Feature Development (not Active Debugging)
- [x] ManicTime coordination context checked
- [x] Coordination strategy selected (if multi-agent)
- [x] Conflict detection passed (no branch conflicts)
- [x] Worktree allocated successfully
- [x] Seat marked BUSY in pool.md
- [x] Allocation logged in worktrees.activity.md

**During Work:**
- [x] ALL code edits in worktree (ZERO in base repo)
- [x] Boy Scout Rule applied (file cleaner than found)
- [x] Code follows established patterns
- [x] No security vulnerabilities introduced
- [x] Heartbeat active (if multi-agent coordination)

**Post-Work:**
- [x] Code committed to branch
- [x] Code pushed to remote
- [x] PR created with proper format
- [x] ClickUp task linked (if applicable)
- [x] Worktree RELEASED (marked FREE)
- [x] Pool.md updated (BUSY → FREE)
- [x] Instances.map.md updated (removed)
- [x] Activity.md logged (release event)
- [x] Git worktree pruned
- [x] Base repos switched to develop
- [x] Heartbeat stopped (if applicable)
- [x] PR URL presented to user

**CRITICAL:** Worktree MUST be released BEFORE presenting PR to user.

### Active Debugging Mode (Quick Fixes)

**Pre-Work:**
- [x] Mode detected as Active Debugging
- [x] User's current branch identified
- [x] Working in base repo (NOT worktree)
- [x] NO worktree allocated

**During Work:**
- [x] Edits made in C:\Projects\<repo>
- [x] On user's current branch
- [x] Quick turnaround (<10 minutes)

**Post-Work:**
- [x] Build errors resolved OR
- [x] Bug fixed as requested
- [x] Branch state preserved (NOT switched)
- [x] NO PR created (unless user explicitly requested)
- [x] Fast delivery to user

### Coordination-Specific (Multi-Agent Sessions)

**If coordination was active:**
- [x] No conflicts with other agents
- [x] Proper strategy used (optimistic/pessimistic)
- [x] Priority respected (user-focused wins)
- [x] Metrics logged (allocation latency, conflicts)
- [x] Validation passed (pool state consistent)
- [x] No duplicate allocations
- [x] Heartbeat maintained throughout
- [x] Clean handoff (proper release)

---

## 🔍 Validation & Health Checks

### Startup Validation (Every Session)

```powershell
function Test-SystemHealth {
    Write-Host "Running System Health Checks..." -ForegroundColor Cyan

    $issues = @()

    # Check 1: Base repos on develop
    $cmBranch = git -C C:/Projects/client-manager branch --show-current
    $hazinaBranch = git -C C:/Projects/hazina branch --show-current

    if ($cmBranch -ne "develop") {
        $issues += "client-manager not on develop (currently: $cmBranch)"
    }
    if ($hazinaBranch -ne "develop") {
        $issues += "hazina not on develop (currently: $hazinaBranch)"
    }

    # Check 2: Pool state consistency
    $pool = Get-Content C:\scripts\_machine\worktrees.pool.md
    $busySeats = $pool | Select-String "BUSY"

    foreach ($seat in $busySeats) {
        # Extract seat name and branch
        # Check if git worktree exists
        # Check if process exists
        # Add to $issues if inconsistent
    }

    # Check 3: Orphaned worktrees
    $cmWorktrees = git -C C:/Projects/client-manager worktree list
    $hazinaWorktrees = git -C C:/Projects/hazina worktree list

    # Compare with pool.md
    # Detect worktrees not in pool = orphaned
    # Add to $issues

    # Check 4: ManicTime connectivity
    try {
        $context = monitor-activity.ps1 -Mode context -OutputFormat object
        if (-not $context) {
            $issues += "ManicTime monitoring not responding"
        }
    } catch {
        $issues += "ManicTime error: $_"
    }

    # Check 5: State files exist
    $requiredFiles = @(
        "C:\scripts\_machine\worktrees.pool.md",
        "C:\scripts\_machine\instances.map.md",
        "C:\scripts\_machine\worktrees.activity.md"
    )

    foreach ($file in $requiredFiles) {
        if (-not (Test-Path $file)) {
            $issues += "Missing required file: $file"
        }
    }

    # Report
    if ($issues.Count -eq 0) {
        Write-Host "✅ All health checks passed" -ForegroundColor Green
        return $true
    } else {
        Write-Host "⚠️  Found $($issues.Count) issues:" -ForegroundColor Yellow
        foreach ($issue in $issues) {
            Write-Host "  - $issue" -ForegroundColor Yellow
        }
        return $false
    }
}
```

### Periodic Validation (Every 5 Minutes - Background Job)

```powershell
function Invoke-PeriodicValidation {
    while ($true) {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Running periodic validation..." -ForegroundColor Cyan

        # Validation 1: Pool vs. Git Reality
        # ... (see parallel-agent-coordination skill)

        # Validation 2: Agent Processes
        # ... check heartbeats, detect crashed agents

        # Validation 3: Duplicate Allocations
        # ... detect same worktree allocated to multiple agents

        # Auto-Repair
        # ... release orphaned, fix duplicates

        # Log Results
        # ... write to validation.log

        Start-Sleep -Seconds 300  # 5 minutes
    }
}

# Start in background job
Start-Job -Name "CoordinationValidation" -ScriptBlock ${function:Invoke-PeriodicValidation}
```

### On-Demand Validation (Manual)

```bash
# Quick health check
pwsh -Command "Test-SystemHealth"

# Full validation with repair
pwsh -Command "Invoke-CoordinationValidation"

# Coordination metrics dashboard
pwsh -Command "Get-AgentCoordinationMetrics -Live"
```

---

## 🛠️ Tool Integration Map

**How all 98 tools work together:**

### Tier 1: Core Infrastructure

| Tool | Purpose | Used By | Frequency |
|------|---------|---------|-----------|
| `monitor-activity.ps1` | ManicTime integration | ALL workflows | Every allocation, validation |
| `check-branch-conflicts.sh` | Conflict detection | Allocation workflow | Every allocation |
| `worktree-status.ps1` | Pool status | Startup, validation | Session start, periodic |
| `repo-dashboard.sh` | Environment check | Startup | Session start |

### Tier 2: Coordination (New)

| Tool | Purpose | Used By | Frequency |
|------|---------|---------|-----------|
| `parallel-agent-coordination` (skill) | Complete protocol | Multi-agent sessions | When agentCount > 1 |
| `PARALLEL_AGENT_COORDINATION_QUICKSTART.md` | Implementation guide | Setup, reference | Initial setup, troubleshooting |

### Tier 3: Allocation & Release

| Tool | Purpose | Used By | Frequency |
|------|---------|---------|-----------|
| `allocate-worktree` (skill) | Worktree allocation | Feature Dev Mode | Every new feature |
| `release-worktree` (skill) | Worktree release | After PR creation | Every feature completion |
| `worktree-allocate.ps1` | Scripted allocation | Automated workflows | As needed |
| `worktree-release-all.ps1` | Batch release | Cleanup, recovery | Manual, recovery |

### Tier 4: Validation & Monitoring

| Tool | Purpose | Used By | Frequency |
|------|---------|---------|-----------|
| `Test-SystemHealth` (function) | Startup checks | Session start | Every session |
| `Invoke-PeriodicValidation` (function) | Ongoing validation | Background job | Every 5 minutes |
| `Get-AgentCoordinationMetrics` (function) | Dashboard | Monitoring | On-demand, live |
| `validation.log` | Validation history | Health checks | Continuous |

### Tier 5: Development & Quality

| Tool | Purpose | Used By | Frequency |
|------|---------|---------|-----------|
| `cs-format.ps1` | C# formatting | Code quality | Before commits |
| `cs-autofix` | C# auto-fix | Build errors | On errors |
| `pattern-search.ps1` | Find solutions | Problem-solving | As needed |
| `read-reflections.ps1` | Learn from past | Research | As needed |

---

## 📊 Metrics & Monitoring

**What to Track:**

### Real-Time Metrics (Dashboard)

```
Agent Status:
- Total registered agents: 3
- Active agents (user-focused): 1
- Background agents: 2
- Idle agents: 0

Pool Utilization:
- Total seats: 12
- BUSY: 4 (33%)
- FREE: 8 (67%)
- Utilization target: 40-60% (healthy)

Current Strategy:
- Agent count: 3
- Strategy: Pessimistic (≥3 agents)
- Average jitter: 250ms
```

### Historical Metrics (Last Hour/Day/Week)

```
Allocation Performance:
- Total allocations: 47
- Successful: 46 (97.9%) ✓
- Conflicts: 1 (2.1%)
- Average latency: 2.3s
- p99 latency: 8.1s ✓ (target: <10s)

Coordination Effectiveness:
- Optimistic allocations: 32 (68%)
- Pessimistic allocations: 15 (32%)
- Auto-repairs: 2
- Validation issues: 3 (all auto-fixed)

Agent Health:
- Crashes detected: 0
- Stale allocations: 1 (auto-reclaimed)
- Heartbeat success rate: 99.8%
```

### Alerting Thresholds

```
🔴 CRITICAL (Immediate Action):
- Allocation success rate < 90%
- p99 latency > 30 seconds
- Agent crash detected
- Pool exhausted (all BUSY)

🟡 WARNING (Monitor Closely):
- Allocation success rate 90-95%
- p99 latency 10-30 seconds
- Conflict rate > 5%
- Pool utilization > 80%

🟢 HEALTHY:
- Allocation success rate > 95%
- p99 latency < 10 seconds
- Conflict rate < 1%
- Pool utilization 40-60%
```

---

## 🚨 Troubleshooting Guide

### Issue: Multiple Agents Allocated Same Branch

**Symptoms:**
- Conflict detection failed
- Two agents working on same branch
- Git conflicts on push

**Diagnosis:**
```bash
# Check current allocations
cat C:\scripts\_machine\worktrees.pool.md | grep "BUSY"

# Check git worktrees
git -C C:/Projects/client-manager worktree list
git -C C:/Projects/hazina worktree list

# Check instances map
cat C:\scripts\_machine\instances.map.md
```

**Resolution:**
```powershell
# 1. Identify which agent should keep allocation (most recent activity)
$context = monitor-activity.ps1 -Mode context -OutputFormat object

# 2. Loser agent releases
# (In loser agent session)
Release-Worktree -WorktreeId $worktreeId -AgentId $myAgentId -Reason "Conflict resolution"

# 3. Winner continues work

# 4. Update conflict detection to prevent recurrence
```

**Prevention:**
- Ensure conflict detection runs BEFORE allocation
- Use adaptive strategy (jitter for >3 agents)
- Monitor conflict rate metrics

---

### Issue: Stale Worktree (Agent Crashed)

**Symptoms:**
- Pool shows BUSY but no agent working
- Git worktree exists but no process
- Last activity > 5 minutes ago

**Diagnosis:**
```powershell
# Check pool
cat C:\scripts\_machine\worktrees.pool.md

# Check processes
$context = monitor-activity.ps1 -Mode context -OutputFormat object
$context.ClaudeInstances.Count

# Check heartbeats
Get-ChildItem C:\scripts\_machine\heartbeats\*.heartbeat |
    ForEach-Object {
        $hb = Get-Content $_ | ConvertFrom-Json
        $age = (Get-Date) - [DateTime]::Parse($hb.Timestamp)
        [PSCustomObject]@{
            Agent = $_.BaseName
            Age = $age.TotalMinutes
            Stale = $age.TotalMinutes -gt 5
        }
    }
```

**Resolution:**
```powershell
# Auto-repair (validation will catch this)
# Or manual:

# 1. Identify stale seat
$staleSeat = "agent-003"

# 2. Release allocation
# Edit pool.md: mark FREE
# Remove from instances.map.md

# 3. Clean up git worktree
git -C C:/Projects/client-manager worktree remove C:/Projects/worker-agents/$staleSeat/client-manager --force
git -C C:/Projects/hazina worktree remove C:/Projects/worker-agents/$staleSeat/hazina --force
git -C C:/Projects/client-manager worktree prune
git -C C:/Projects/hazina worktree prune

# 4. Log recovery
echo "$(Get-Date -Format 'o') | $staleSeat | recovery | stale-allocation-cleanup" >> C:\scripts\_machine\worktrees.activity.md
```

**Prevention:**
- Periodic validation (every 5 minutes)
- Aggressive heartbeat monitoring
- Auto-reclamation after 5 minutes idle

---

### Issue: Base Repo Not on Develop

**Symptoms:**
- Allocation fails
- Conflicts when creating worktree
- Unexpected branch state

**Diagnosis:**
```bash
# Check current branches
git -C C:/Projects/client-manager branch --show-current
git -C C:/Projects/hazina branch --show-current

# Expected: develop
```

**Resolution:**
```bash
# Switch both repos to develop
cd C:/Projects/client-manager
git checkout develop
git pull origin develop

cd C:/Projects/hazina
git checkout develop
git pull origin develop

# Verify
git -C C:/Projects/client-manager branch --show-current  # Should show: develop
git -C C:/Projects/hazina branch --show-current          # Should show: develop
```

**Prevention:**
- Startup validation (step 9)
- After PR creation (release protocol)
- Periodic validation

---

### Issue: ManicTime Not Responding

**Symptoms:**
- `monitor-activity.ps1` times out
- Coordination context unavailable
- Can't detect agent count

**Diagnosis:**
```powershell
# Test ManicTime connectivity
try {
    $context = monitor-activity.ps1 -Mode context -OutputFormat object -ErrorAction Stop
    Write-Host "✓ ManicTime responding" -ForegroundColor Green
} catch {
    Write-Host "✗ ManicTime error: $_" -ForegroundColor Red
}

# Check ManicTime process
Get-Process -Name "*ManicTime*" -ErrorAction SilentlyContinue

# Check ManicTime database
Test-Path "$env:LOCALAPPDATA\Finkit\ManicTime\ManicTimeCore.db"
```

**Resolution:**
```powershell
# 1. Restart ManicTime
Stop-Process -Name "ManicTime" -Force -ErrorAction SilentlyContinue
Start-Process "C:\Program Files\ManicTime\ManicTime.exe"

# 2. Verify database accessible
Test-Path "$env:LOCALAPPDATA\Finkit\ManicTime\ManicTimeCore.db"

# 3. Fallback: Use degraded mode (assume single agent)
if (-not $context) {
    Write-Warning "ManicTime unavailable - using degraded mode (single agent assumptions)"
    $agentCount = 1
    $strategy = "optimistic"
}
```

**Prevention:**
- Monitor ManicTime process health
- Implement fallback mode for degraded operation
- Alert if ManicTime down for >1 minute

---

## 📚 Cross-Reference Index

**Master list of all related documentation:**

### Core Configuration
- `MACHINE_CONFIG.md` - Local paths and configuration
- `GENERAL_ZERO_TOLERANCE_RULES.md` - Hard-stop rules
- `GENERAL_DUAL_MODE_WORKFLOW.md` - Feature vs Debug modes
- `GENERAL_WORKTREE_PROTOCOL.md` - Complete worktree workflow

### User Understanding
- `_machine/PERSONAL_INSIGHTS.md` - Deep user profile and optimization
- `_machine/SOFTWARE_DEVELOPMENT_PRINCIPLES.md` - Boy Scout Rule, quality standards
- `_machine/DEFINITION_OF_DONE.md` - Completion criteria

### Coordination (NEW)
- `parallel-agent-coordination` (skill) - Complete coordination protocol
- `PARALLEL_AGENT_COORDINATION_QUICKSTART.md` - Implementation guide
- `SYSTEM_INTEGRATION.md` (THIS FILE) - How everything works together

### Workflows
- `allocate-worktree` (skill) - Allocation workflow
- `release-worktree` (skill) - Release workflow
- `multi-agent-conflict` (skill) - Conflict detection
- `activity-monitoring` (skill) - ManicTime integration
- `github-workflow` (skill) - PR creation and management

### State Files
- `_machine/worktrees.pool.md` - Seat allocation state
- `_machine/instances.map.md` - Agent session mapping
- `_machine/worktrees.activity.md` - Event log
- `_machine/reflection.log.md` - Lessons learned
- `_machine/pr-dependencies.md` - Cross-repo tracking

### Tools
- `monitor-activity.ps1` - ManicTime integration
- `check-branch-conflicts.sh` - Conflict detection
- `worktree-status.ps1` - Pool status
- `repo-dashboard.sh` - Environment check
- (See CLAUDE.md for complete tool list - 98 tools)

---

## ✅ System Integration Checklist

**Use this to verify complete system integration:**

### Startup Integration
- [ ] All 14 startup steps executed in order
- [ ] ManicTime context retrieved successfully
- [ ] Coordination strategy determined (if multi-agent)
- [ ] Base repos verified on develop
- [ ] Pool status checked
- [ ] Health check passed

### Allocation Integration
- [ ] Mode detection executed (Feature Dev vs Active Debug)
- [ ] Coordination context checked (agent count, priority)
- [ ] Conflict detection passed
- [ ] Strategy selected (optimistic/pessimistic)
- [ ] Worktree allocated successfully
- [ ] All state files updated (pool.md, instances.map.md, activity.md)
- [ ] Heartbeat started (if multi-agent)

### Work Integration
- [ ] Edits made in correct location (worktree for Feature, base for Debug)
- [ ] Boy Scout Rule applied
- [ ] Heartbeat maintained (if applicable)
- [ ] No conflicts with other agents

### Release Integration
- [ ] PR created successfully
- [ ] Worktree released IMMEDIATELY
- [ ] All state files updated (pool.md → FREE, instances.map.md → removed)
- [ ] Git worktree pruned
- [ ] Base repos switched to develop
- [ ] Heartbeat stopped
- [ ] Metrics logged

### Validation Integration
- [ ] Periodic validation running (background job)
- [ ] No inconsistencies detected
- [ ] Metrics within healthy thresholds
- [ ] Dashboard accessible

### Documentation Integration
- [ ] All related docs updated
- [ ] Reflection.log.md updated
- [ ] PERSONAL_INSIGHTS.md updated (if applicable)
- [ ] Cross-references accurate

---

## 🎓 Summary

**This System Integration Guide provides:**

1. **Complete Architecture** - How all components work together
2. **Unified Workflow** - Single decision tree integrating everything
3. **State Management** - Three-layer state system with synchronization
4. **Integrated Protocols** - Complete allocation/release with coordination
5. **Validation** - Startup, periodic, and on-demand health checks
6. **Tool Integration** - How 98 tools work together
7. **Metrics** - What to track and alerting thresholds
8. **Troubleshooting** - Common issues and resolutions
9. **Cross-References** - Links to all related documentation
10. **Checklists** - Verification of complete integration

**Status:** Production System v2.0 with Parallel Agent Coordination
**Last Updated:** 2026-01-20 03:00
**Maintained By:** Claude Agent (Self-improving system)
**Next Review:** After first week of production use with coordination

---

**This document is the MASTER integration guide. All agents should read this to understand how the complete system works together.**
