# Worktree Management Workflow

**Last Updated:** 2026-02-01

## Core Principle

**Feature Development Mode:** ALWAYS use worktrees
**Active Debugging Mode:** NEVER use worktrees (work in base repo)

## Decision Tree

```
User request
    │
    ├─ Build error / debugging? → Active Debugging Mode
    │   └─ Work in C:\Projects\<repo>\ on current branch
    │
    └─ New feature / refactoring / ClickUp task? → Feature Development Mode
        └─ Allocate worktree in C:\Projects\worker-agents\agent-XXX\
```

**Tool:** `detect-mode.ps1 -UserMessage "..." -Analyze`

**HARD RULE:** ClickUp URL present → ALWAYS Feature Development Mode

## Worktree Pool

**Location:** `C:\scripts\_machine\worktrees.pool.md`
**Seats:** agent-001 through agent-030 (30 parallel agents)
**Base Repos:** `C:\Projects\client-manager\`, `C:\Projects\hazina\`
**Worktrees:** `C:\Projects\worker-agents\agent-XXX\{client-manager,hazina}\`

## Atomic Allocation Protocol

### 1. Check Multi-Agent Conflicts (MANDATORY)
```powershell
# Detect other Claude instances
monitor-activity.ps1 -Mode claude

# Check for conflicts
agent-coordinate.ps1 -Action detect_conflicts

# If conflicts found, use adaptive allocation strategy
```

### 2. Allocate Worktree (Single Repo)
```powershell
# Manual allocation + pool update
worktree-allocate.ps1 -Repo client-manager -Branch feature/my-feature

# OR automatic with database tracking
worktree-allocate-tracked.ps1 -Seat agent-003 -Repo client-manager -Branch feature/my-feature
```

**Skill:** Auto-activates via `allocate-worktree` skill

### 3. Allocate Paired Worktrees (Cross-Repo)
```powershell
# Allocate both client-manager + Hazina at same seat
worktree-allocate.ps1 -Repo client-manager -Branch feature/my-feature -Paired

# Result:
# - C:\Projects\worker-agents\agent-XXX\client-manager\
# - C:\Projects\worker-agents\agent-XXX\hazina\
```

**Use Case:** When feature requires changes in both repos

### 4. Mark Seat BUSY
```markdown
# In worktrees.pool.md
- **agent-003** - BUSY - `feature/my-feature` (client-manager) - Session: 2026-02-01 01:30
```

**Automatic:** If using `worktree-allocate-tracked.ps1`

### 5. Work in Worktree
```bash
cd /c/Projects/worker-agents/agent-XXX/client-manager
# Make changes, commit, push
```

### 6. Create PR
```bash
gh pr create --title "Feature: My Feature" --body "Description"
```

**Skill:** Auto-activates via `github-workflow` skill

### 7. Release Worktree (IMMEDIATE)
```powershell
# Manual release
worktree-release-all.ps1 -AutoCommit

# OR via skill
# Activates: release-worktree skill
```

**CRITICAL:** Release IMMEDIATELY after PR creation, NEVER delay

### 8. Mark Seat FREE
```markdown
# In worktrees.pool.md
- **agent-003** - FREE
```

**Automatic:** If using `worktree-allocate-tracked.ps1` + proper release

## Multi-Agent Coordination

### Parallel Agent Awareness
- Each agent MUST have exclusive worktree (BUSY = locked)
- Check pool before allocating to avoid conflicts
- Auto-provision new agent-XXX seat if all BUSY
- Log all allocations in `worktrees.activity.md`

**Skill:** `parallel-agent-coordination` (auto-activates when multiple agents detected)

### Conflict Detection
```powershell
# Before allocating, check for conflicts
agent-coordinate.ps1 -Action detect_conflicts

# Types detected:
# - Worktree conflicts (same seat BUSY)
# - File lock conflicts (same file being edited)
# - Branch conflicts (same branch in multiple worktrees)
```

## Common Operations

### Check Pool Status
```powershell
worktree-status.ps1 -Compact
```

### Find Available Seat
```powershell
# Automatic in worktree-allocate.ps1
# Scans pool, finds first FREE seat
```

### Clean Stale Worktrees
```powershell
# Detect BUSY > 2hr with no activity
maintenance.ps1 -Full
```

### Switch Between Worktrees
```bash
# List all worktrees
git worktree list

# Switch to different worktree
cd /c/Projects/worker-agents/agent-005/client-manager
```

## Zero Tolerance Rules

### ❌ NEVER DO THIS
- Edit code in `C:\Projects\<repo>\` when in Feature Development Mode
- Leave worktree marked BUSY after PR creation
- Allocate worktree when debugging build errors
- Forget to mark seat BUSY before working
- Use direct `ssh` for remote operations (use Python scripts)

### ✅ ALWAYS DO THIS
- Detect mode first (`detect-mode.ps1`)
- Check for multi-agent conflicts before allocation
- Mark seat BUSY immediately after allocation
- Work exclusively in allocated worktree
- Release worktree immediately after PR
- Mark seat FREE after release
- Verify base repo on `develop` branch after release

## Troubleshooting

### Worktree Already Exists
```bash
# Remove stale worktree
git worktree remove /c/Projects/worker-agents/agent-XXX/client-manager --force

# Then allocate fresh
worktree-allocate.ps1 -Repo client-manager -Branch feature/new-feature
```

### Pool Out of Sync
```bash
# Manually sync pool with actual worktrees
git worktree list

# Update pool markdown file to match reality
```

### Multiple Agents Want Same Seat
```bash
# First agent gets it (marked BUSY)
# Second agent auto-provisions new seat (agent-031, agent-032, etc.)
# OR waits if configured to queue
```

## Performance Tracking

### Database Tracking (Phase 3)
```powershell
# All git operations tracked in database
git-tracked.ps1 -Operation commit -Message "Feature complete"

# Metrics collected:
# - Duration
# - Success/failure
# - Files changed
# - Agent ID
```

### Activity Dashboard
```powershell
# View comprehensive multi-agent state
agent-dashboard.ps1 -Watch
```

## Related Documentation

- `GENERAL_WORKTREE_PROTOCOL.md` - Complete portable protocol
- `GENERAL_DUAL_MODE_WORKFLOW.md` - Feature vs Debug mode
- `worktree-workflow.md` - Legacy (machine-specific paths)
- `.claude/skills/allocate-worktree/` - Auto-discoverable skill
- `.claude/skills/release-worktree/` - Auto-discoverable skill
- `.claude/skills/multi-agent-conflict/` - Conflict detection skill
