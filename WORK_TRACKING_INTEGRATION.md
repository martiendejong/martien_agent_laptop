# Work Tracking System - Agent Integration Guide

**Purpose:** Enable all Claude agents to automatically update the work tracking dashboard

---

## Quick Start (For Running Agents)

If you're a Claude agent reading this, add these commands to your workflow:

### 1. When Starting Work

```powershell
Start-Work -Objective "Your task description here" `
           -Repository "client-manager" `
           -ClickUpTask "869xxxxx" `
           -Branch "feature/your-branch"
```

### 2. When Making Progress

```powershell
Update-Work -Phase "CODING" -Status "Implemented auth endpoints"
```

### 3. When Completing Work

```powershell
Complete-Work -PR "client-manager#123" `
              -Outcome "Feature complete and tested"
```

---

## Integration Points

### A. Agent Startup (MANDATORY)

Add to agent startup protocol (in `STARTUP_PROTOCOL.md`):

```markdown
**Step 2.5: Initialize Work Tracking**

If working on a task/feature:
```powershell
Start-Work -Objective "<task description>" `
           -Repository "<repo-name>" `
           -ClickUpTask "<task-id>" `
           -Branch "<branch-name>"
```

This will:
- Register agent in dashboard
- Create entry in work-state.json
- Show as "Active Work" in real-time dashboard
```

### B. During Work (Regular Updates)

Update status when changing phases:

```powershell
# When starting to code
Update-Work -Phase "CODING"

# When testing
Update-Work -Phase "TESTING"

# When creating PR
Update-Work -Phase "REVIEWING"
```

**Common Phases:**
- PLANNING
- CODING
- TESTING
- REVIEWING
- MERGING
- BLOCKED

### C. Work Completion (MANDATORY)

Before ending session or presenting PR to user:

```powershell
Complete-Work -PR "<repo>#<number>" `
              -Outcome "Brief summary of what was accomplished"
```

---

## Module Auto-Loading

The work tracking module is **already auto-loaded** via PowerShell $PROFILE.

**Verify it's loaded:**
```powershell
Get-Module work-tracking
```

**If not loaded:**
```powershell
Import-Module C:\scripts\tools\work-tracking.psm1 -Force
```

---

## Agent ID Detection

The system auto-detects agent ID from:
1. Current directory path (if in `C:\Projects\worker-agents\agent-XXX\`)
2. Falls back to "current-session"

**Manual override:**
```powershell
$env:AGENT_ID = "agent-001"
Start-Work -Objective "..."
```

---

## Dashboard Access

**Quick Launch:** `CTRL+R` → `d` (or `C:\scripts\d.bat`)

**Features:**
- Real-time updates via WebSocket
- Search/filter agents
- Keyboard shortcuts (press `?`)
- Dark/light theme (`Ctrl+D`)

---

## Example Workflow: Feature Development

```powershell
# 1. Start work (after allocating worktree)
Start-Work -Objective "Add user profile settings page" `
           -Repository "client-manager" `
           -ClickUpTask "869abc123" `
           -Branch "feature/user-settings"

# 2. Update as you progress
Update-Work -Phase "CODING" -Status "Created settings component"
Update-Work -Phase "TESTING" -Status "Writing unit tests"

# 3. Complete when PR is created
Complete-Work -PR "client-manager#456" `
              -Outcome "User settings page complete with tests"
```

**Result:** Dashboard shows full timeline of your work in real-time!

---

## Example Workflow: Bug Fix

```powershell
# 1. Start work
Start-Work -Objective "Fix login redirect loop" `
           -Repository "client-manager" `
           -Branch "bugfix/login-redirect"

# 2. Update as you investigate
Update-Work -Phase "INVESTIGATION" -Status "Found root cause in auth middleware"
Update-Work -Phase "CODING" -Status "Applied fix"
Update-Work -Phase "TESTING" -Status "Verified fix works"

# 3. Complete
Complete-Work -PR "client-manager#457" `
              -Outcome "Login redirect fixed - middleware timeout increased"
```

---

## Integration with Existing Skills

### allocate-worktree skill

Add after worktree allocation:

```powershell
Start-Work -Objective $taskObjective `
           -Repository $repository `
           -ClickUpTask $clickUpTask `
           -Branch $branch
```

### release-worktree skill

Add before releasing:

```powershell
# If PR was created
Complete-Work -PR "$repository#$prNumber" -Outcome "Work completed"

# If work was abandoned
Update-Work -Status "BLOCKED" -Phase "CANCELLED"
```

### clickhub-coding-agent skill

Already integrated! The skill automatically:
- Calls `Start-Work` when picking up task
- Calls `Update-Work` during implementation
- Calls `Complete-Work` when PR is created

---

## Troubleshooting

### Dashboard shows no agents

**Check if module is loaded:**
```powershell
Get-Command Start-Work
```

**If not found:**
```powershell
Import-Module C:\scripts\tools\work-tracking.psm1 -Force
```

### Agent not showing in dashboard

**Check work state:**
```powershell
Get-WorkState | ConvertTo-Json -Depth 10
```

**Verify agent is registered:**
```powershell
$state = Get-WorkState
$state.agents
```

### WebSocket not connecting

**Check if server is running:**
```powershell
netstat -ano | findstr ":4243"
```

**If not running, dashboard falls back to 3s polling automatically**

---

## Advanced: Custom Reporting

### Generate daily report

```powershell
New-DailyReport

# Or for specific date
New-DailyReport -Date "2026-02-07"

# With email
New-DailyReport -Email "you@example.com"
```

### Query work history

```powershell
# Get today's events
Get-WorkHistory

# Get specific date
Get-WorkHistory -Date "2026-02-07"

# Get metrics
Get-WorkMetrics
```

---

## Summary

**For agents to show in dashboard:**

1. ✅ Module auto-loads (already set up)
2. ⏳ **Agents must call `Start-Work` when starting tasks** (needs integration)
3. ⏳ **Agents must call `Complete-Work` when finishing** (needs integration)

**Next Steps:**

1. Update agent startup protocols to call `Start-Work`
2. Update completion protocols to call `Complete-Work`
3. Train agents to use `Update-Work` for status updates

**Once integrated, the dashboard will automatically show all active agent work in real-time!**

---

**Documentation:**
- Full API: `C:\scripts\WORK_TRACKING_SYSTEM.md`
- Enhancements: `C:\scripts\_machine\WORK_TRACKING_ENHANCEMENTS_SUMMARY.md`
- Quick Launcher: `C:\scripts\QUICK_LAUNCHERS.md`
