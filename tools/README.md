# Agent Tools

## Overview

Productivity tools for Claude agents and developers working on multi-repo projects.

---

## Worktree Management Tools

### worktree-status.ps1 / worktree-status.sh

Shows active git worktrees across all worker agent seats and compares with pool status.

**Usage:**
```powershell
# Detailed view
.\worktree-status.ps1

# Compact table view
.\worktree-status.ps1 -Compact

# Or via bash
./worktree-status.sh
./worktree-status.sh -c
```

**Output includes:**
- Active worktrees per agent seat
- Branch names and commit hashes
- Pool status comparison (BUSY/FREE/STALE)
- Warnings for discrepancies (FREE but has worktrees)
- Orphaned worktrees not in agent folders
- Base repository status

**Example output:**
```
agent-001 [BUSY]
  - client-manager @ allitemslist (bbde2a5)
  - hazina @ allitemslist (390a63d)

agent-003 [FREE]
  - client-manager @ feature/restaurant-menu (a8cd673)

WARNING: 1 seats marked FREE but still have worktrees!
  - agent-003
```

**When to use:**
- Before allocating a worktree (check what's in use)
- After releasing a worktree (verify cleanup)
- When debugging worktree conflicts
- To find orphaned worktrees that need cleanup

### worktree-release-all.ps1 / worktree-release-all.sh

Commits all changes in worktrees and releases them to their resting branches.

**Usage:**
```powershell
# Dry-run (preview what would happen)
.\worktree-release-all.ps1 -DryRun

# Release all worktrees with auto-commit
.\worktree-release-all.ps1 -AutoCommit

# Release specific seat only
.\worktree-release-all.ps1 -Seats "agent-003"

# Skip push to remote
.\worktree-release-all.ps1 -AutoCommit -SkipPush

# Or via bash
./worktree-release-all.sh --dry-run
./worktree-release-all.sh --auto
./worktree-release-all.sh --seat agent-003
```

**What it does for each worktree:**
1. Checks for uncommitted changes
2. Commits with auto-generated message (or prompts for message)
3. Pushes to remote
4. Switches to resting branch (agent001, agent002, etc.)
5. Updates worktrees.pool.md to mark seat as FREE

**Example output:**
```
Processing agent-003
====================
  Repository: client-manager
  Current branch: feature/restaurant-menu
  Target branch: agent003
  [OK] No uncommitted changes
  -> Pushing to remote...
  [OK] Pushed to remote
  -> Switching to agent003...
  [OK] Switched to agent003
  -> Updating pool status...
  [OK] Pool status updated to FREE
```

**When to use:**
- End of work session (release all worktrees)
- Before starting fresh work (clean slate)
- After creating PRs (release back to resting state)

---

## Solution Integrity Tools

Tools for detecting and fixing .NET solution file integrity issues - specifically when .csproj files exist on disk but are not included in the solution file.

## Problem This Solves

**Symptom:** Hundreds of build errors like:
- `NU1105: Unable to find project information for '<project>.csproj'`
- `CS0006: Metadata file '<project>.dll' could not be found`

**Root Cause:** Projects exist on disk but weren't added to the solution file with `dotnet sln add`.

**Impact:** Cascading build failures across entire solution.

## Tools

### detect-missing-projects.ps1

Scans a single solution for projects missing from the solution file.

**Usage:**
```powershell
# Check a solution
.\detect-missing-projects.ps1 -SolutionPath "C:\Projects\hazina\Hazina.sln"

# Auto-fix missing projects
.\detect-missing-projects.ps1 -SolutionPath "C:\Projects\hazina\Hazina.sln" -AutoFix
```

**Exit codes:**
- `0`: All projects included in solution
- `1`: Missing projects detected

### check-all-solutions.ps1

Orchestrates checking multiple repositories.

**Usage:**
```powershell
# Check all configured repositories
.\check-all-solutions.ps1

# Auto-fix all issues
.\check-all-solutions.ps1 -AutoFix
```

## Quick Diagnostic

```bash
# Count projects on disk vs solution
find . -name "*.csproj" | grep -v "/bin/" | grep -v "/obj/" | wc -l
dotnet sln list | grep -v "^Project" | wc -l
```

## Related Documentation

- Reflection log: `C:\scripts\_machine\reflection.log.md` (2026-01-10 16:46)
- Pattern 70: Solution File Validation

---
*Created: 2026-01-10*
