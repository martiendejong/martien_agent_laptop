# Git Branching Strategy 🌿

**Purpose:** Consistent git workflow across all developers and AI agents

---

## Branch Structure

```
main (production)
  ↑
  └── develop (integration)
        ↑
        ├── agent-001-feature-a  (worktree: agent-001)
        ├── agent-002-feature-b  (worktree: agent-002)
        └── feature-feature-c    (manual developer)
```

---

## Branch Types

### 1. `main` - Production Branch

**Purpose:** Production-ready code only
**Protection:** Protected, requires PR approval
**Deploy:** Automatically deploys to production (future)

**Rules:**
- ❌ No direct commits
- ✅ Merge from `develop` only
- ✅ All tests must pass
- ✅ Code review required
- ✅ Tagged releases (v1.0.0, v1.1.0, etc.)

**Merge frequency:** Weekly or on-demand for hotfixes

---

### 2. `develop` - Integration Branch

**Purpose:** Integration branch for all feature work
**Protection:** Protected, requires PR approval
**Deploy:** Automatically deploys to staging (future)

**Rules:**
- ❌ No direct commits (except urgent fixes)
- ✅ Merge feature branches here first
- ✅ All tests must pass
- ✅ Keep up-to-date with main

**Merge frequency:** Multiple times per day

---

### 3. Feature Branches

**Naming Convention:**
```
agent-XXX-<feature-name>     # AI agent branches (in worktrees)
feature-<feature-name>       # Manual developer branches
bugfix-<bug-description>     # Bug fixes
hotfix-<critical-fix>        # Production hotfixes
```

**Examples:**
- `agent-001-chat-improvements`
- `agent-002-wordpress-integration`
- `feature-dark-mode`
- `bugfix-login-redirect`
- `hotfix-payment-webhook`

**Rules:**
- ✅ Branch from `develop` (NOT main)
- ✅ One feature per branch
- ✅ Short-lived (merge within 2-3 days)
- ✅ Delete after merge

---

## Worktree Workflow (AI Agents)

### ⚠️ CRITICAL: AI Agents MUST Use Worktrees

**Why?** Multiple AI agents running in parallel cannot share the same working directory.

**Worktree Location:**
```
C:\Projects\worker-agents\
├── agent-001\client-manager\  ← Git worktree for agent-001
├── agent-002\client-manager\  ← Git worktree for agent-002
├── agent-003\client-manager\  ← Git worktree for agent-003
└── agent-004\client-manager\  ← Git worktree for agent-004
```

### Worktree Allocation (BEFORE CODE EDIT)

**📋 See:** `C:\scripts\_machine\worktrees.protocol.md` for full protocol

**Quick version:**
1. Read `C:\scripts\_machine\worktrees.pool.md`
2. Find FREE seat
3. Mark seat BUSY
4. Create branch in worktree: `agent-XXX-<feature>`
5. Work in `C:\Projects\worker-agents\agent-XXX\client-manager\`
6. **NEVER work in** `C:\Projects\client-manager\` directly!

### Worktree Release (AFTER WORK DONE)

1. Commit: `git add -u && git commit -m "..."`
2. Push: `git push origin agent-XXX-<feature>`
3. PR: `gh pr create --base develop --title "..." --body "..."`
4. Mark seat FREE in worktrees.pool.md
5. Log release in worktrees.activity.md

---

## Regular Developer Workflow (Manual)

**For human developers** (no worktree needed):

### 1. Start New Feature

```bash
cd C:\Projects\client-manager
git checkout develop
git pull origin develop
git checkout -b feature-my-feature
```

### 2. Work on Feature

```bash
# Make changes
# Commit regularly
git add .
git commit -m "Add feature X"
git commit -m "Fix bug in feature X"
git commit -m "Add tests for feature X"
```

### 3. Keep Up-to-Date

```bash
# Rebase on develop regularly
git fetch origin
git rebase origin/develop
```

### 4. Push & Create PR

```bash
git push origin feature-my-feature
gh pr create --base develop --title "Add feature X" --body "Description..."
```

### 5. After PR Merged

```bash
git checkout develop
git pull origin develop
git branch -d feature-my-feature
git push origin --delete feature-my-feature
```

---

## Commit Message Convention

**Format:**
```
<type>(<scope>): <subject>

<body>

Co-Authored-By: <author>
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `style` - Formatting, whitespace
- `refactor` - Code restructuring
- `test` - Adding tests
- `chore` - Build, dependencies, tools

**Examples:**
```
feat(auth): add Google OAuth login

Implemented Google OAuth 2.0 authentication flow.
Users can now sign in with their Google accounts.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

```
fix(api): handle null reference in token balance

Fixed NullReferenceException when user has no token balance.
Added null check and default value of 0.

Fixes #123
```

```
docs: update GETTING_STARTED.md with troubleshooting

Added common errors and solutions for new developers.
```

---

## Pull Request Workflow

### Creating PR

**Title:** Clear, concise description
```
Add chat typing indicators
Fix memory leak in SignalR connection
Update dependencies to latest versions
```

**Body Template:**
```markdown
## Summary
Brief description of changes

## Changes
- Added X
- Modified Y
- Removed Z

## Test Plan
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manually tested feature X
- [ ] Checked browser console for errors

## Screenshots
(if UI changes)

## Related Issues
Closes #123
```

### Review Process

**Reviewers check:**
- ✅ Code quality
- ✅ Tests included
- ✅ Documentation updated
- ✅ No breaking changes
- ✅ Security concerns
- ✅ Performance impact

**PR must have:**
- ✅ All tests passing (CI)
- ✅ At least 1 approval
- ✅ No merge conflicts
- ✅ Up-to-date with base branch

### Merging

**Merge strategy:** Squash and merge (default)
- Keeps develop history clean
- Single commit per PR
- Easier to revert if needed

**Alternative:** Merge commit (for large features)
- Preserves feature branch history
- Use when feature has many meaningful commits

**Never:** Rebase and merge (avoid for develop)

---

## Hotfix Workflow (Production Emergency)

**When to use:** Critical bug in production that can't wait

### Process

```bash
# Branch from main (NOT develop)
git checkout main
git pull origin main
git checkout -b hotfix-critical-bug

# Fix the bug
git commit -m "hotfix: fix critical payment bug"

# Create PR to BOTH main and develop
gh pr create --base main --title "Hotfix: Critical payment bug"
gh pr create --base develop --title "Hotfix: Critical payment bug"

# After merge to main:
# 1. Tag release: git tag v1.0.1
# 2. Deploy to production immediately
# 3. Merge to develop to keep in sync
```

---

## Release Workflow

### Creating Release

```bash
# On main branch
git checkout main
git pull origin main

# Merge develop into main
git merge develop

# Tag release
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Push main
git push origin main

# Create GitHub release
gh release create v1.0.0 --notes "Release notes..."
```

### Version Numbering

**Semantic Versioning:** MAJOR.MINOR.PATCH

- **MAJOR** - Breaking changes (v2.0.0)
- **MINOR** - New features, backward compatible (v1.1.0)
- **PATCH** - Bug fixes, backward compatible (v1.0.1)

---

## Common Scenarios

### Scenario 1: Merge Conflict

```bash
# Pull latest develop
git fetch origin
git rebase origin/develop

# Resolve conflicts
# Edit files, resolve conflicts
git add <resolved-files>
git rebase --continue

# Force push (rebase rewrites history)
git push origin feature-my-feature --force-with-lease
```

### Scenario 2: Wrong Base Branch

```bash
# If you branched from main instead of develop
git rebase --onto develop main feature-my-feature
```

### Scenario 3: Undo Last Commit (Not Pushed)

```bash
# Undo commit, keep changes
git reset --soft HEAD~1

# Undo commit, discard changes
git reset --hard HEAD~1
```

### Scenario 4: Revert Merged PR

```bash
# On develop
git revert -m 1 <merge-commit-hash>
git push origin develop
```

---

## Branch Protection Rules (GitHub)

**`main` branch:**
- ✅ Require pull request reviews (1+ approvals)
- ✅ Require status checks to pass (CI/CD)
- ✅ Require branches to be up to date
- ✅ Require conversation resolution
- ❌ Allow force pushes
- ❌ Allow deletions

**`develop` branch:**
- ✅ Require pull request reviews (1+ approvals)
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ❌ Allow force pushes (except admins)
- ❌ Allow deletions

---

## Git Configuration

**Recommended settings:**

```bash
# User identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Default branch name
git config --global init.defaultBranch main

# Auto-setup remote tracking
git config --global push.autoSetupRemote true

# Rebase on pull (cleaner history)
git config --global pull.rebase true

# Better diff algorithm
git config --global diff.algorithm histogram

# Cache credentials (Windows)
git config --global credential.helper wincred
```

---

## Best Practices 📌

**DO:**
- ✅ Commit often (small, atomic commits)
- ✅ Write descriptive commit messages
- ✅ Pull/rebase frequently
- ✅ Keep branches short-lived
- ✅ Delete merged branches
- ✅ Run tests before pushing

**DON'T:**
- ❌ Commit directly to main or develop
- ❌ Force push to main or develop
- ❌ Commit secrets or credentials
- ❌ Commit large binary files
- ❌ Work in long-lived branches
- ❌ Merge without code review

---

## Tools

**Git GUI Clients:**
- [GitKraken](https://www.gitkraken.com/) - Visual git client
- [GitHub Desktop](https://desktop.github.com/) - Simple GitHub client
- [SourceTree](https://www.sourcetreeapp.com/) - Free git GUI

**VS Code Extensions:**
- GitLens - Git supercharged
- Git Graph - Visual git history
- GitHub Pull Requests - PR management in editor

**CLI Tools:**
- `gh` - GitHub CLI (create PRs, issues, etc.)
- `tig` - Text-mode interface for git
- `lazygit` - Terminal UI for git

---

## Related Documentation

- [worktrees.protocol.md](./worktrees.protocol.md) - Full worktree allocation protocol
- [DEVELOPER_ONBOARDING.md](./DEVELOPER_ONBOARDING.md) - Developer setup guide
- [GETTING_STARTED.md](./GETTING_STARTED.md) - Quick start guide

---

**Last Updated:** 2026-01-08
**Maintained by:** Claude Agent System & Development Team
**Questions?** Ask in team Slack #dev-git-questions
