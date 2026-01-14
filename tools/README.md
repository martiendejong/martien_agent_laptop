# Agent Tools

**Complete reference for Claude Agent productivity tools.**

---

## Quick Reference

| Tool | Purpose | Quick Usage |
|------|---------|-------------|
| `claude-ctl.ps1` | Unified CLI | `.\claude-ctl.ps1 status` |
| `bootstrap-snapshot.ps1` | Fast startup state | `.\bootstrap-snapshot.ps1 -Generate` |
| `system-health.ps1` | Health checks | `.\system-health.ps1 -Fix` |
| `worktree-allocate.ps1` | Allocate seat | `.\worktree-allocate.ps1 -Repo client-manager -Branch feature/x` |
| `worktree-status.ps1` | Check seats | `.\worktree-status.ps1 -Compact` |
| `worktree-release-all.ps1` | Release seats | `.\worktree-release-all.ps1 -AutoCommit` |
| `pattern-search.ps1` | Search past solutions | `.\pattern-search.ps1 -Query "error"` |
| `read-reflections.ps1` | Read reflection log | `.\read-reflections.ps1 -Recent 10` |
| `maintenance.ps1` | Run maintenance | `.\maintenance.ps1 -Full` |
| `archive-reflections.ps1` | Archive old entries | `.\archive-reflections.ps1 -DryRun` |
| `migrate-pool-to-json.ps1` | Convert pool to JSON | `.\migrate-pool-to-json.ps1` |
| `pre-commit-hook.ps1` | Enforcement hooks | `.\pre-commit-hook.ps1 -Check` |

---

## Unified CLI: claude-ctl.ps1

**Single entry point for all common operations.**

```powershell
# Show system status
.\claude-ctl.ps1 status

# Generate bootstrap snapshot
.\claude-ctl.ps1 snapshot

# Run health checks
.\claude-ctl.ps1 health

# Allocate worktree
.\claude-ctl.ps1 allocate -Seat agent-002 -Repo client-manager -Branch feature/x

# Release worktree
.\claude-ctl.ps1 release -Seat agent-002 -AutoCommit

# Add reflection entry
.\claude-ctl.ps1 reflect -Tag "BUG-FIX" -Message "Fixed null reference in..."

# Show mode help
.\claude-ctl.ps1 mode

# Show all commands
.\claude-ctl.ps1 help
```

---

## Bootstrap & Startup

### bootstrap-snapshot.ps1

Creates condensed startup state for faster agent initialization.

```powershell
# Generate fresh snapshot
.\bootstrap-snapshot.ps1 -Generate

# Read existing snapshot (default)
.\bootstrap-snapshot.ps1

# Compact one-liner output
.\bootstrap-snapshot.ps1 -Format oneliner

# JSON output for parsing
.\bootstrap-snapshot.ps1 -Format json
```

**Output includes:**
- Worktree pool status (FREE/BUSY counts)
- Base repository branches and cleanliness
- Active worktrees with branches
- Recent reflection entries
- Available tools and skills count

---

## Health & Diagnostics

### system-health.ps1

Comprehensive system health checker.

```powershell
# Run all checks
.\system-health.ps1

# Show detailed output
.\system-health.ps1 -Detailed

# Auto-fix discovered issues
.\system-health.ps1 -Fix
```

**Checks performed:**
- Required files exist
- Required tools present
- Base repos on develop branch
- Base repos clean (no uncommitted changes)
- Pool/worktree consistency
- External tool availability (git, gh, node)
- Documentation link validity

---

## Worktree Management

### worktree-allocate.ps1

Single-command worktree allocation with all safety checks.

```powershell
# Basic allocation
.\worktree-allocate.ps1 -Repo client-manager -Branch feature/new-thing

# Paired allocation (client-manager + hazina)
.\worktree-allocate.ps1 -Repo client-manager -Branch feature/x -Paired

# Specific seat
.\worktree-allocate.ps1 -Repo hazina -Branch fix/bug -Seat agent-003

# With description
.\worktree-allocate.ps1 -Repo client-manager -Branch feature/pdf -Description "PDF export feature"
```

**Automatically:**
- Finds free seat (or provisions new one)
- Verifies base repo on develop
- Creates worktree with proper branch
- Updates pool.md
- Logs activity

### worktree-status.ps1 / worktree-status.sh

Shows active git worktrees across all worker agent seats.

```powershell
# Detailed view
.\worktree-status.ps1

# Compact table view
.\worktree-status.ps1 -Compact

# Bash alternative
./worktree-status.sh
./worktree-status.sh -c
```

**Output includes:**
- Active worktrees per agent seat
- Branch names and commit hashes
- Pool status comparison (BUSY/FREE/STALE)
- Warnings for discrepancies
- Orphaned worktrees

### worktree-release-all.ps1 / worktree-release-all.sh

Commits and releases worktrees to resting branches.

```powershell
# Dry-run (preview)
.\worktree-release-all.ps1 -DryRun

# Release all with auto-commit
.\worktree-release-all.ps1 -AutoCommit

# Release specific seat
.\worktree-release-all.ps1 -Seats "agent-003"

# Skip push
.\worktree-release-all.ps1 -AutoCommit -SkipPush

# Bash alternative
./worktree-release-all.sh --auto
./worktree-release-all.sh --seat agent-003
```

---

## Solution Integrity

### detect-missing-projects.ps1

Finds .csproj files not included in solution.

```powershell
# Check a solution
.\detect-missing-projects.ps1 -SolutionPath "C:\Projects\hazina\Hazina.sln"

# Auto-fix
.\detect-missing-projects.ps1 -SolutionPath "path\to.sln" -AutoFix
```

### check-all-solutions.ps1

Orchestrates checking multiple repositories.

```powershell
# Check all configured repos
.\check-all-solutions.ps1

# Auto-fix all
.\check-all-solutions.ps1 -AutoFix
```

---

## Git & Repository Tools

### repo-dashboard.sh

Environment overview showing all repos and their states.

```bash
./repo-dashboard.sh
```

### check-base-repos.sh

Verifies base repos are on correct branches.

```bash
./check-base-repos.sh
```

### check-branch-conflicts.sh

Detects potential branch conflicts across repos.

```bash
./check-branch-conflicts.sh
```

### clean-stale-branches.sh

Removes old/merged branches.

```bash
./clean-stale-branches.sh
```

### pr-status.sh

Shows status of open PRs across repos.

```bash
./pr-status.sh
```

---

## External Integrations

### clickup-sync.ps1

ClickUp task management integration.

```powershell
# List tasks
.\clickup-sync.ps1 -Action list

# Create task
.\clickup-sync.ps1 -Action create -Name "Task name" -ListId <id>

# List available statuses
.\clickup-sync.ps1 -Action list-statuses -ListId <id>
```

### IMAP Email Tools

Email management for info@martiendejong.nl.

```bash
# Show recent messages
node imap-recent-messages.js

# Manage spam
node imap-spam-manager.js

# Batch actions
node imap-action.js --spam=1,2,3 --archive=4,5
```

See `EMAIL_MANAGEMENT.md` for full documentation.

---

## C# Development

### cs-format.ps1

Format C# code using dotnet format.

```powershell
.\cs-format.ps1 -Path "path\to\file.cs"
```

### cs-autofix/

Automated C# code fixes directory.

---

## Utility Scripts

### generate-feature-doc.ps1

Generates feature documentation templates.

### generate-changelog.sh

Creates changelog from git history.

### find-todos.sh

Finds TODO comments in codebase.

### coverage-report.sh

Generates test coverage report.

### sync-configs.sh

Synchronizes configuration files across repos.

---

## Tool Development Guidelines

When creating new tools:

1. **Use PowerShell for primary implementation** (cross-platform via pwsh)
2. **Add `-DryRun` parameter** for preview mode
3. **Add `-Verbose` or `-Detailed` parameter** for debugging
4. **Include help** via comment-based help
5. **Update this README** with usage examples
6. **Log significant actions** to appropriate activity files

---

## Related Documentation

- **Navigation:** `C:\scripts\NAVIGATION.md`
- **Problem solutions:** `C:\scripts\_machine\problem-solution-index.md`
- **Reflection log:** `C:\scripts\_machine\reflection.log.md`
- **Tool status:** `TOOLS_STATUS.md`
- **Tool index:** `TOOLS_INDEX.md`
- **Future ideas:** `FUTURE_TOOLS.md`

---

**Last Updated:** 2026-01-15
**Tool Count:** 25+ scripts
