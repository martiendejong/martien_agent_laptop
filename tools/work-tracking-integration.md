# Work Tracking Integration Guide

## Overview

This guide explains how to integrate the work tracking system into existing skills and workflows.

## Core Principle

**Every agent action should be automatically tracked without manual intervention.**

The work tracking module provides automatic detection and logging when properly integrated.

---

## Integration Methods

### Method 1: PowerShell Profile Auto-Load (RECOMMENDED)

Add to PowerShell profile so work-tracking is available in every session:

```powershell
# Location: $PROFILE (typically C:\Users\<user>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1)

# Import work tracking module
$workTrackingModule = "C:\scripts\tools\work-tracking.psm1"
if (Test-Path $workTrackingModule) {
    Import-Module $workTrackingModule -Force -ErrorAction SilentlyContinue

    # Auto-detect agent ID and set environment variable
    $agentId = Get-AgentId
    $env:AGENT_ID = $agentId

    Write-Host "Work tracking enabled (Agent: $agentId)" -ForegroundColor Green
}
```

**Benefits:**
- ✅ Works automatically in all sessions
- ✅ No code changes needed in skills
- ✅ Agents can manually call Start-Work, Update-Work, Complete-Work

**Drawbacks:**
- ❌ Requires manual function calls from agents
- ❌ Not fully automatic (agents must remember to track)

---

### Method 2: Skill-Level Integration (SEMI-AUTOMATIC)

Add work tracking calls to specific skills at key lifecycle points.

#### allocate-worktree Skill

**After successful worktree allocation:**

```powershell
# ... worktree allocation logic ...

# Track work start
Import-Module C:\scripts\tools\work-tracking.psm1 -Force -ErrorAction SilentlyContinue

Start-Work -ClickUpTask $TaskId -Branch $BranchName -Objective $Description -Repository $RepoName
```

#### release-worktree Skill

**After PR creation:**

```powershell
# ... PR creation logic ...

# Track work completion
Import-Module C:\scripts\tools\work-tracking.psm1 -Force -ErrorAction SilentlyContinue

Complete-Work -PR $PRNumber -Outcome "PR created, worktree released"
```

#### github-workflow Skill

**During PR merge:**

```powershell
# ... PR merge logic ...

# Track status updates
Import-Module C:\scripts\tools\work-tracking.psm1 -Force -ErrorAction SilentlyContinue

Update-Work -Status "MERGING" -Phase "PR Merge"

# ... after merge ...

Complete-Work -PR $PRNumber -Outcome "Merged to develop"
```

**Benefits:**
- ✅ Automatic tracking at key lifecycle points
- ✅ No manual calls needed from agents
- ✅ Consistent tracking across all operations

**Drawbacks:**
- ❌ Requires updating multiple skills
- ❌ Maintenance burden when skills change

---

### Method 3: Command Wrapper Functions (FULLY AUTOMATIC)

Wrap common commands (git, gh) with tracking logic.

Create `C:\scripts\tools\tracked-commands.psm1`:

```powershell
# Wrapper for git worktree add
function git {
    param([Parameter(ValueFromRemainingArguments)]$Args)

    # Call real git
    & git.exe $Args

    # Detect worktree add and track
    if ($Args[0] -eq 'worktree' -and $Args[1] -eq 'add') {
        Import-Module C:\scripts\tools\work-tracking.psm1 -ErrorAction SilentlyContinue
        # Extract branch name and start tracking
        $branchName = $Args[-1]
        Start-Work -Branch $branchName -Objective "Worktree allocated"
    }

    # Detect commits and update status
    if ($Args[0] -eq 'commit') {
        Import-Module C:\scripts\tools\work-tracking.psm1 -ErrorAction SilentlyContinue
        Update-Work -Status "CODING" -Phase "Development"
    }
}

# Wrapper for gh pr create
function gh {
    param([Parameter(ValueFromRemainingArguments)]$Args)

    # Call real gh
    $output = & gh.exe $Args

    # Detect PR creation and track
    if ($Args[0] -eq 'pr' -and $Args[1] -eq 'create') {
        Import-Module C:\scripts\tools\work-tracking.psm1 -ErrorAction SilentlyContinue

        # Extract PR number from output
        if ($output -match '#(\d+)') {
            $prNumber = "#$($Matches[1])"
            Complete-Work -PR $prNumber -Outcome "PR created"
        }
    }

    # Detect PR merge and track
    if ($Args[0] -eq 'pr' -and $Args[1] -eq 'merge') {
        Import-Module C:\scripts\tools\work-tracking.psm1 -ErrorAction SilentlyContinue
        Update-Work -Status "MERGING" -Phase "PR Merge"
    }

    return $output
}

Export-ModuleMember -Function git, gh
```

**Then add to profile:**

```powershell
Import-Module C:\scripts\tools\tracked-commands.psm1 -Force
```

**Benefits:**
- ✅ Fully automatic (no manual calls)
- ✅ Works with any git/gh usage
- ✅ Transparent to agents

**Drawbacks:**
- ❌ Overwrites built-in commands (can cause issues)
- ❌ Harder to debug (hidden tracking)

---

## Recommended Hybrid Approach

**Combine Method 1 (Profile Auto-Load) + Method 2 (Skill Integration)**

### Step 1: Auto-Load Module

Add to `$PROFILE`:

```powershell
# Work Tracking Auto-Load
$workTrackingModule = "C:\scripts\tools\work-tracking.psm1"
if (Test-Path $workTrackingModule) {
    Import-Module $workTrackingModule -Force -ErrorAction SilentlyContinue
    $env:AGENT_ID = Get-AgentId
}
```

### Step 2: Add Skill Integration Points

**Update key skills to call work tracking functions at lifecycle boundaries:**

| Skill | Integration Point | Function Call |
|-------|-------------------|---------------|
| `allocate-worktree` | After allocation | `Start-Work -ClickUpTask $Task -Branch $Branch -Objective $Desc` |
| `release-worktree` | After PR creation | `Complete-Work -PR $PRNum -Outcome "PR created"` |
| `github-workflow` (merge) | During merge | `Update-Work -Status "MERGING" -Phase "PR Merge"` |
| `github-workflow` (create) | After PR create | `Update-Work -Status "REVIEWING" -Phase "PR Created"` |
| `clickhub-coding-agent` | During coding | `Update-Work -Status "CODING" -Phase "Development"` |

### Step 3: Add Agent Instructions

Update `C:\scripts\CLAUDE.md` to instruct agents:

```markdown
## Work Tracking (Automatic)

The work tracking module is automatically loaded. During your session:

- **Starting work**: Call `Start-Work` when beginning a task
- **Updating status**: Call `Update-Work` when changing phases
- **Completing work**: Call `Complete-Work` when done

Example workflow:
```powershell
# Start new task
Start-Work -ClickUpTask "869c1xyz" -Objective "Add user auth"

# Update as you progress
Update-Work -Status "CODING" -Phase "Development"
Update-Work -Status "TESTING" -Phase "Build verification"

# Complete when done
Complete-Work -PR "#507" -Outcome "PR created, tests passing"
```

---

## Testing Integration

After integration, verify tracking works:

```powershell
# 1. Start a test work session
Start-Work -Objective "Test work tracking integration"

# 2. Check state was updated
Get-WorkState

# 3. Update status
Update-Work -Status "TESTING" -Phase "Integration test"

# 4. Check state again
Get-WorkState

# 5. Complete work
Complete-Work -Outcome "Integration test successful"

# 6. Verify completion in history
Get-WorkHistory -Last 1

# 7. Open dashboard to verify UI updates
start C:\scripts\_machine\work-dashboard.html
```

---

## Troubleshooting

### Module Not Loading

```powershell
# Check if module exists
Test-Path C:\scripts\tools\work-tracking.psm1

# Try importing manually
Import-Module C:\scripts\tools\work-tracking.psm1 -Force -Verbose

# Check for errors
$Error[0]
```

### Agent ID Not Detected

```powershell
# Manually set agent ID
$env:AGENT_ID = "agent-001"

# Verify
Get-AgentId
```

### State Not Updating

```powershell
# Check state file
Get-Content C:\scripts\_machine\work-state.json | ConvertFrom-Json

# Check events
Get-Content C:\scripts\_machine\events\$(Get-Date -Format 'yyyy-MM-dd').jsonl

# Enable debug logging
$env:WORK_TRACKING_DEBUG = '1'

# Try operation again
Start-Work -Objective "Debug test"
```

---

## Migration from Manual Tracking

If you have existing manual tracking (agent-coordination.md), migrate gradually:

1. ✅ Install work tracking system (this guide)
2. ✅ Run both systems in parallel for 1 week
3. ✅ Verify work-state.json captures all events
4. ✅ Migrate dashboard links to new HTML dashboard
5. ✅ Archive old coordination.md
6. ✅ Update skills to use new system exclusively

---

## Advanced: Custom Event Types

You can extend the tracking system with custom events:

```powershell
# Create custom event
$event = @{
    type = "custom.milestone_reached"
    agent = $env:AGENT_ID
    milestone = "10 PRs merged"
    timestamp = (Get-Date).ToUniversalTime().ToString("o")
}

# Write event
Write-Event -Event $event
```

---

## Integration Checklist

- [ ] Work tracking module installed (`work-tracking.psm1`)
- [ ] Database initialized (`work-tracking-init-db.ps1`)
- [ ] PowerShell profile updated (auto-load module)
- [ ] Key skills updated (allocate, release, github-workflow)
- [ ] Agent instructions updated (`CLAUDE.md`)
- [ ] System tray app installed and running
- [ ] HTML dashboard accessible
- [ ] Test workflow executed successfully
- [ ] Documentation updated

---

**Last Updated:** 2026-02-07
**Version:** 1.0.0
**Maintained By:** Work Tracking System
