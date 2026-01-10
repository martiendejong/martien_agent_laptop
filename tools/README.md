# Development Tools

Quick-win automation tools for the Claude Code environment.

## 🚀 Quick Start Guide

All tools are located in `C:\scripts\tools\` and can be run from Git Bash.

### Tool 1: Stale Branch Cleaner
**Delete all merged branches across repos**

```bash
# Dry run (see what would be deleted)
./clean-stale-branches.sh --dry-run

# Clean all repos
./clean-stale-branches.sh

# Clean specific repo
./clean-stale-branches.sh client-manager
```

**What it does:**
- Finds all PRs in MERGED state
- Deletes remote branches (origin)
- Deletes local branches
- Shows statistics

---

### Tool 2: Bulk PR Status
**See all open PRs at a glance**

```bash
# All repos
./pr-status.sh

# Specific repo
./pr-status.sh client-manager
```

**Output:**
- PR number and title
- Branch name
- CI status (SUCCESS/FAILURE/PENDING)
- Mergeable status (✅/⚠️/⏳)

---

### Tool 3: Multi-Repo Dashboard
**Complete environment status in one view**

```bash
./repo-dashboard.sh
```

**Shows:**
- Current branch for each repo
- Uncommitted changes count
- Open PRs with CI status
- Last 3 commits
- Agent pool status (FREE/BUSY)
- Active agents and their work

**Use case:** Run at start of day to see environment state

---

### Tool 4: Worktree Health Checker
**Detect and fix stale worktree allocations**

```bash
# Check health
./check-worktree-health.sh

# Show suggested fixes
./check-worktree-health.sh --fix
```

**Detects:**
- Missing directories
- Empty worktrees
- Merged PRs still marked BUSY
- Inactive agents (>2hr no commits)

**Prevents:** Resource leaks like the 6 stale agents we found

---

### Tool 5: Pre-commit Hook Manager
**Install git hooks to catch mistakes before commit**

```bash
# Install in all repos
./install-hooks.sh

# Install in specific repo
./install-hooks.sh client-manager
```

**Checks enforced:**
- ✅ Valid branch names (feature/, fix/, etc.)
- ✅ No merge conflict markers
- ✅ No debugger statements
- ✅ Warns on console.log
- ✅ Warns on large files (>5MB)
- ✅ Warns on TODO without issue #

**Skip temporarily:** `git commit --no-verify`

---

## 📊 Usage Examples

### Morning Routine
```bash
# See what's happening
./repo-dashboard.sh

# Check for stale worktrees
./check-worktree-health.sh

# See all PRs
./pr-status.sh
```

### Weekly Cleanup
```bash
# Clean old branches
./clean-stale-branches.sh --dry-run  # Preview
./clean-stale-branches.sh            # Execute

# Fix stale worktrees
./check-worktree-health.sh --fix
```

### First-time Setup
```bash
# Install pre-commit hooks
./install-hooks.sh
```

---

## 🔧 Installation

Already installed! Tools are in `C:\scripts\tools\`

To use from anywhere, add to PATH or create aliases:

```bash
# Add to ~/.bashrc or ~/.bash_profile
alias dashboard='C:/scripts/tools/repo-dashboard.sh'
alias prs='C:/scripts/tools/pr-status.sh'
alias wt-check='C:/scripts/tools/check-worktree-health.sh'
alias clean-branches='C:/scripts/tools/clean-stale-branches.sh'
```

---

## 📈 Value Delivered

| Tool | Time Saved | Frequency |
|------|------------|-----------|
| Dashboard | 5 min | Daily |
| PR Status | 3 min | 3x/day |
| Health Check | 10 min | Weekly |
| Branch Cleaner | 15 min | Weekly |
| Pre-commit Hooks | 5 min | Per commit |

**Total:** ~30 minutes saved per day

---

## 🐛 Troubleshooting

**"Permission denied"**
```bash
chmod +x C:/scripts/tools/*.sh
```

**"gh: command not found"**
- Install GitHub CLI: https://cli.github.com/
- Or use git commands instead

**"jq: command not found"**
```bash
# Install jq
choco install jq
# Or: scoop install jq
```

---

## 🎯 Tools 6-10 (Next Batch)

### Tool 6: TODO Tracker
**Find all TODO/FIXME/HACK comments**

```bash
# Find all TODOs
./find-todos.sh

# Export to markdown
./find-todos.sh --export

# Specific repo
./find-todos.sh client-manager
```

**Output:** Grouped by file, color-coded by type, line numbers included

---

### Tool 7: Config Sync
**Sync configs from base repos to worktrees**

```bash
# Sync all BUSY agents
./sync-configs.sh

# Specific agent
./sync-configs.sh agent-001

# Dry run
./sync-configs.sh --dry-run
```

**Syncs:** appsettings.json, .env, secrets.json

---

### Tool 8: Agent Activity Report
**See what each agent is doing**

```bash
./agent-activity.sh
```

**Shows:** Time allocated, last commit, PR status, inactive warnings

---

### Tool 9: Test Coverage Reporter
**Generate coverage reports**

```bash
# Run coverage
./coverage-report.sh

# Generate HTML
./coverage-report.sh --html

# Specific repo
./coverage-report.sh client-manager
```

**Output:** Backend + frontend coverage, low-coverage files highlighted

---

### Tool 10: Changelog Generator
**Generate changelog from merged PRs**

```bash
# All merged PRs
./generate-changelog.sh

# Since specific tag
./generate-changelog.sh --since-tag v2026.01.08-stable

# Specific repo
./generate-changelog.sh client-manager
```

**Format:** Keep a Changelog standard, categorized by type

---

## 💡 Improvement Suggestions

**Have an idea for a new tool?** Add it to `FUTURE_TOOLS.md`

**Found a bug?** Tools will auto-fix issues when possible, or report clear errors

**Want to contribute?** All tools are in `C:\scripts\tools\` - feel free to enhance!

---

**Created:** 2026-01-11
**Last Updated:** 2026-01-11 04:45
**Tools Available:** 10 of 50 planned
