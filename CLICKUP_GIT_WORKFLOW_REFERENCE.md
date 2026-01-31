# ClickUp + Git Workflow - Quick Reference Card

**Version:** 1.0
**Updated:** 2026-01-31
**Audience:** Human Developers

---

## 🎯 Overview

ClickUp is the **source of truth** for all work. Every code change has a corresponding ClickUp task.

---

## 📋 Workflow Steps

### 1️⃣ Pick Task from TODO

```powershell
# List available tasks
clickup-sync.ps1 -Action list -ProjectId <project-id>

# Filter TODO tasks
clickup-sync.ps1 -Action list -ProjectId <project-id> | grep "TODO"
```

**Action:** Assign task to yourself in ClickUp UI

---

### 2️⃣ Create Branch from develop/main

```bash
# Switch to base branch
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/<task-description>
# OR for bug fixes
git checkout -b fix/<bug-description>
```

**Branch naming:**
- `feature/*` - New features
- `fix/*` - Bug fixes
- `improvement/*` - Enhancements
- `agent-*-feature` - AI agent branches

---

### 3️⃣ Make Code Changes + Update ClickUp

**While working:**

```powershell
# Move task to IN PROGRESS
clickup-sync.ps1 -Action update -TaskId <id> -Status "in progress"

# Add progress comments
clickup-sync.ps1 -Action comment -TaskId <id> -Comment "Implemented X, working on Y"
```

**Update ClickUp:**
- Status: TODO → **IN PROGRESS**
- Add comments for:
  - Progress updates
  - Blockers/questions
  - Design decisions
  - Testing notes

---

### 4️⃣ Commit & Sync Changes

```bash
# Stage changes
git add <files>

# Commit with descriptive message
git commit -m "Feature: Add user authentication

- Implemented login endpoint
- Added JWT token generation
- Created user session management

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Push branch to remote
git push origin feature/<task-description>
```

---

### 5️⃣ Create Pull Request to develop

```bash
# Create PR (ALWAYS to develop, not main!)
gh pr create --base develop \
  --title "Feature: User Authentication" \
  --body "$(cat <<'EOF'
## Summary
- Implemented login endpoint with JWT tokens
- Added user session management
- Added unit tests for auth flow

## Test Plan
- [ ] Login with valid credentials succeeds
- [ ] Login with invalid credentials fails
- [ ] JWT token is generated correctly
- [ ] Session expires after timeout

## ClickUp Task
https://app.clickup.com/t/<task-id>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**PR must target `develop` branch (ZERO-TOLERANCE RULE)**

---

### 6️⃣ Link PR to ClickUp Task

```powershell
# Add PR link as comment
clickup-sync.ps1 -Action comment -TaskId <id> \
  -Comment "PR created: https://github.com/org/repo/pull/123"

# Move task to REVIEW
clickup-sync.ps1 -Action update -TaskId <id> -Status "review"
```

**Update ClickUp:**
- Add PR link in comments
- Status: IN PROGRESS → **REVIEW**
- **(Optional)** Assign reviewer in ClickUp

---

### 7️⃣ Code Review Process

#### If You're the **Reviewer:**

**Step 1: Checkout & Test**
```bash
# Fetch PR branch
gh pr checkout 123

# Run tests
npm test  # or dotnet test

# Test manually
npm start  # or dotnet run
```

**Step 2: Review Code**
- Check code quality
- Verify tests pass
- Test functionality
- Check for security issues

**Step 3A: Approve & Merge** ✅
```bash
# Merge PR (squash commits + delete branch)
gh pr merge 123 --squash --delete-branch
```
```powershell
# Update ClickUp to DONE
clickup-sync.ps1 -Action update -TaskId <id> -Status "complete"
clickup-sync.ps1 -Action comment -TaskId <id> -Comment "PR merged, deployed to develop"
```

**Step 3B: Request Changes** ⚠️
```bash
# Add review comments in GitHub
gh pr review 123 --comment --body "Please fix X, Y, Z"
```
```powershell
# Move task back to TODO
clickup-sync.ps1 -Action update -TaskId <id> -Status "todo"
clickup-sync.ps1 -Action comment -TaskId <id> -Comment "Review feedback: Fix X, Y, Z"
```

**Step 3C: Fix Issues Yourself** 🛠️
```bash
# Checkout PR branch
gh pr checkout 123

# Make fixes
git add <files>
git commit -m "Fix review comments"
git push

# Move to IN PROGRESS while fixing
```
```powershell
clickup-sync.ps1 -Action update -TaskId <id> -Status "in progress"
```

---

## 🤖 AI Agent Automation

The **AI Coding Agent** automates steps 1-6:

1. **Picks** TODO task from ClickUp
2. **Analyzes** requirements, identifies uncertainties
3. **Posts** questions as ClickUp comments if needed
4. **Allocates** worktree, creates branch
5. **Implements** code changes
6. **Commits**, pushes, creates PR
7. **Moves** task to REVIEW, assigns reviewer

**See:** `clickhub-coding-agent` skill for details

---

## 📊 Status Flow Diagram

```
┌─────────┐
│  TODO   │ ← Task created/returned after review
└────┬────┘
     │ (1) Assign to self
     ▼
┌─────────┐
│   IN    │ ← Working on implementation
│ PROGRESS│
└────┬────┘
     │ (2) Create PR
     ▼
┌─────────┐
│ REVIEW  │ ← Awaiting code review
└────┬────┘
     │
     ├─────► (Approve) ──────► COMPLETE ✅
     │
     ├─────► (Changes) ──────► TODO ⚠️
     │
     └─────► (Fix myself) ───► IN PROGRESS 🛠️
```

---

## ⚠️ Critical Rules

| Rule | Why |
|------|-----|
| ✅ **ALWAYS** create branch from `develop` | Keep work isolated |
| ✅ **ALWAYS** create PR to `develop` (not `main`) | Git-flow workflow |
| ✅ **ALWAYS** update ClickUp task | Team visibility |
| ✅ **ALWAYS** link PR in ClickUp | Traceability |
| ✅ **ALWAYS** delete branch after merge | Prevent clutter |
| ❌ **NEVER** merge your own PR | Peer review required |
| ❌ **NEVER** commit to `develop` directly | All changes via PR |
| ❌ **NEVER** create PR to `main` | Only `develop → main` |

---

## 🔧 Quick Commands Reference

```powershell
# ClickUp Commands
clickup-sync.ps1 -Action list -ProjectId <id>          # List tasks
clickup-sync.ps1 -Action show -TaskId <id>             # Get details
clickup-sync.ps1 -Action create                        # Create task
clickup-sync.ps1 -Action update -TaskId <id> -Status   # Change status
clickup-sync.ps1 -Action comment -TaskId <id> -Comment # Add comment

# Git Commands
git checkout develop && git pull origin develop        # Update develop
git checkout -b feature/x                              # Create branch
git add -A && git commit -m "message"                  # Commit changes
git push origin feature/x                              # Push branch
gh pr create --base develop --title "X" --body "Y"     # Create PR
gh pr merge <num> --squash --delete-branch             # Merge & cleanup

# Review Commands
gh pr checkout <num>                                   # Test PR locally
gh pr review <num> --approve                           # Approve
gh pr review <num> --comment --body "Fix X"            # Request changes
```

---

## 📚 Related Documentation

- **Git Workflow:** `C:\scripts\git-workflow.md`
- **Worktree Protocol:** `C:\scripts\GENERAL_WORKTREE_PROTOCOL.md`
- **ClickUp Integration:** `C:\scripts\_machine\knowledge-base\04-EXTERNAL-SYSTEMS\clickup-integration.md`
- **AI Agent Skill:** `C:\scripts\.claude\skills\clickhub-coding-agent\SKILL.md`

---

**🎯 Remember:** ClickUp is the source of truth. If it's not in ClickUp, it doesn't exist!
