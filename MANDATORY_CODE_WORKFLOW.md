# MANDATORY Code Development Workflow

**Created:** 2026-02-04
**Status:** ACTIVE - NON-NEGOTIABLE RULES
**User Requirement:** "this process needs to be followed whenever any task is worked on through clickup or any other way that creates a branch in the repository"

---

## 🚨 THE RULE: 7-Step Mandatory Workflow

This workflow is **NON-NEGOTIABLE** and applies to **ALL code changes** that create a branch.

### Step 1: Create Branch

**Branch naming convention:**
```
<type>/<clickup-id>-<short-description>
```

**Examples:**
```bash
feature/869bhfw7r-restaurant-menu
fix/869bpz2c0-images-not-generating
refactor/869bmhjh9-product-catalog
```

**Types:**
- `feature/` - New functionality
- `fix/` - Bug fixes
- `refactor/` - Code improvements
- `docs/` - Documentation only
- `test/` - Test additions

**If ClickUp task exists:**
- Extract task ID (e.g., `869bhfw7r`)
- Include in branch name
- Update ClickUp status to "busy": `clickup-sync.ps1 -Action update -TaskId 869bhfw7r -Status busy`

---

### Step 2: Assign Worktree Agent to Branch

**CRITICAL: Feature Development Mode requires isolated worktrees**

```bash
# 1. Check for conflicts (MANDATORY)
bash C:/scripts/tools/check-branch-conflicts.sh <repo> <branch-name>

# 2. Allocate worktree
# Use allocate-worktree skill OR manual allocation:

cd C:/Projects/<repo>
git worktree add C:/Projects/worker-agents/agent-XXX/<repo> -b <branch-name>

# 3. For client-manager: ALSO allocate Hazina worktree (SAME branch name!)
cd C:/Projects/hazina
git worktree add C:/Projects/worker-agents/agent-XXX/hazina -b <branch-name>

# 4. Update tracking files
# - Mark seat BUSY in worktrees.pool.md
# - Log allocation in worktrees.activity.md
# - Add to instances.map.md
```

**See:** `worktree-workflow.md` for complete protocol

---

### Step 3: Make Changes

**Work in allocated worktree ONLY:**
```
✅ Edit: C:/Projects/worker-agents/agent-XXX/<repo>/**/*
❌ Edit: C:/Projects/<repo>/**/*  (FORBIDDEN in Feature Dev Mode!)
```

**Follow coding standards:**
- Read entire file before editing (Boy Scout Rule)
- Clean up unused imports, magic numbers, naming issues
- Add tests for new functionality
- Document complex logic

---

### Step 4: Merge Develop into Branch

**BEFORE creating PR, merge latest develop:**

```bash
cd C:/Projects/worker-agents/agent-XXX/<repo>

# 1. Fetch latest changes
git fetch origin

# 2. Merge develop into feature branch
git merge origin/develop

# 3. Resolve any conflicts
# - Fix merge conflicts in IDE
# - Test thoroughly
# - Commit merge if needed

# 4. Verify no conflicts remain
git status
```

**Why this matters:**
- Ensures code is up-to-date with latest changes
- Catches integration issues early
- Prevents conflicts in PR
- Tests run against current codebase

---

### Step 5: Resolve Issues - Ensure Build Passes and Tests Pass (DoD Verification)

**🎯 DEFINITION OF DONE CHECK POINT**

This step enforces the core quality criteria from Definition of Done (DoD).
**Reference:** `C:\scripts\_machine\DEFINITION_OF_DONE.md`

**MANDATORY verification before PR:**

```powershell
cd C:/Projects/worker-agents/agent-XXX/<repo>

# 1. Full clean build
dotnet clean
dotnet build --configuration Release

# 2. Verify build succeeded
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ BUILD FAILED - FIX BEFORE PR" -ForegroundColor Red
    # Go back to Step 3, fix issues
    exit 1
}

# 3. Run ALL tests
dotnet test --configuration Release

# 4. Verify tests passed
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ TESTS FAILED - FIX BEFORE PR" -ForegroundColor Red
    # Go back to Step 3, fix issues
    exit 1
}

# 5. Check for warnings (optional but recommended)
dotnet build --no-incremental | Select-String "warning"

# 6. For EF Core projects: Check pending migrations
dotnet ef migrations has-pending-model-changes --context IdentityDbContext
# If exit code 1 → Create migration FIRST!

# 7. Manual QA (if applicable)
# - Test UI changes in browser
# - Verify API endpoints work
# - Check edge cases
```

**Only proceed to Step 6 if ALL checks pass.**

**DoD Criteria Satisfied at This Step:**
- ✅ Development Complete (Step 3)
- ✅ Code Formatted and Linted
- ✅ Build Succeeds
- ✅ All Tests Passing
- ✅ Manual Testing Completed
- ✅ EF Migrations Created (if needed)

**Remaining DoD Criteria (completed in Steps 6-7):**
- ⏳ Version Control (Step 6)
- ⏳ ClickUp Task Updated (Step 7)

---

### Step 6: Create Pull Request (DoD: Version Control)

**PR creation protocol:**

```bash
cd C:/Projects/worker-agents/agent-XXX/<repo>

# 1. Commit all changes
git add -A
git commit -m "feat: <description>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# 2. Push to remote
git push -u origin <branch-name>

# 3. Create PR (ALWAYS specify --base develop!)
gh pr create --base develop \
  --title "<type>: <description> [<clickup-id>]" \
  --body "## ClickUp Task
https://app.clickup.com/t/<clickup-id>

## Summary
<description of changes>

## Test Plan
- [ ] Build passes
- [ ] All tests pass
- [ ] Manual QA completed

🤖 Generated with [Claude Code](https://claude.com/claude-code)"

# 4. Verify base branch (Pattern 56)
gh pr view --json baseRefName
# Must show: "baseRefName": "develop"
```

**PR title examples:**
```
feat: Restaurant menu catalog [869bhfw7r]
fix: Images not generating in chat [869bpz2c0]
refactor: Improve product catalog structure [869bmhjh9]
```

**DoD Criteria Satisfied at This Step:**
- ✅ Code Committed with Meaningful Message
- ✅ Branch Pushed to Remote
- ✅ Pull Request Created
- ✅ PR Base Branch Verified (develop)
- ✅ PR Description Complete (summary, test plan, screenshots)

**Remaining DoD Criteria (Step 7):**
- ⏳ ClickUp Task Updated with PR Link

---

### Step 7: 🚨 Add PR Link to ClickUp Task (NON-NEGOTIABLE!) (DoD: Stakeholder Communication)

**THIS IS THE MANDATORY STEP - NO EXCEPTIONS**

```bash
# Extract task ID from branch name
branch=$(git branch --show-current)
taskId=$(echo $branch | grep -oP '(\w{9})' | head -1)

# Get PR details
prNumber=$(gh pr view --json number --jq .number)
prUrl=$(gh pr view --json url --jq .url)

# Update ClickUp task with PR link
clickup-sync.ps1 -Action comment -TaskId $taskId -Comment "PR #${prNumber}: ${prUrl}"

# Verify update
echo "✅ ClickUp task $taskId updated with PR link"
```

**PowerShell version:**
```powershell
# Extract task ID from branch name
$branch = git branch --show-current
if ($branch -match '(\w{9})') {
    $taskId = $matches[1]
    $prNumber = (gh pr view --json number --jq .number)
    $prUrl = (gh pr view --json url --jq .url)

    clickup-sync.ps1 -Action comment -TaskId $taskId -Comment "PR #${prNumber}: ${prUrl}"
    Write-Host "✅ ClickUp task $taskId updated with PR link" -ForegroundColor Green
} else {
    Write-Host "⚠️  No ClickUp task ID found in branch name" -ForegroundColor Yellow
    Write-Host "MANUAL ACTION REQUIRED: Add PR link to ClickUp task" -ForegroundColor Red
}
```

**What this does:**
- Adds PR link as comment to ClickUp task
- Keeps ClickUp status at "busy" (PR still open, not merged)
- User can track PR progress from ClickUp
- Establishes traceability: Task → Branch → PR → Merge

**If no ClickUp task ID found:**
- ⚠️ MANUAL UPDATE REQUIRED
- Find the relevant ClickUp task
- Add PR link manually via ClickUp UI or API

**DoD Criteria Satisfied at This Step:**
- ✅ ClickUp Task Updated with PR Link
- ✅ Traceability Established (Task → Branch → PR)

**DoD Status:** ✅ **ALL Development Phase Criteria Met**

**Remaining DoD Criteria (Post-Merge):**
- ⏳ PR Approved and Merged (user/team responsibility)
- ⏳ CI/CD Pipeline Passed
- ⏳ Deployed to Production (deployment process)
- ⏳ Production Verification
- ⏳ Final Documentation Updates

**Full DoD Reference:** `C:\scripts\_machine\DEFINITION_OF_DONE.md`

---

## 📋 Complete Example Walkthrough

```bash
# User says: "Implement restaurant menu feature (ClickUp task 869bhfw7r)"

# STEP 1: Create branch name
branch_name="feature/869bhfw7r-restaurant-menu"

# Update ClickUp status
clickup-sync.ps1 -Action update -TaskId 869bhfw7r -Status busy

# STEP 2: Allocate worktree
bash C:/scripts/tools/check-branch-conflicts.sh client-manager $branch_name
cd C:/Projects/client-manager
git worktree add C:/Projects/worker-agents/agent-001/client-manager -b $branch_name
cd C:/Projects/hazina
git worktree add C:/Projects/worker-agents/agent-001/hazina -b $branch_name
# Update pool.md, activity.md, instances.map.md

# STEP 3: Make changes
cd C:/Projects/worker-agents/agent-001/client-manager
# ... implement feature ...
# ... write tests ...

# STEP 4: Merge develop
git fetch origin
git merge origin/develop
# Resolve conflicts if any

# STEP 5: Verify build and tests
dotnet clean
dotnet build --configuration Release
# ✅ Build succeeded

dotnet test --configuration Release
# ✅ All tests passed

# STEP 6: Create PR
git add -A
git commit -m "feat: Add restaurant menu catalog

Implements menu browsing, category filtering, and item details.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

git push -u origin feature/869bhfw7r-restaurant-menu

gh pr create --base develop \
  --title "feat: Restaurant menu catalog [869bhfw7r]" \
  --body "## ClickUp Task
https://app.clickup.com/t/869bhfw7r

## Summary
Implements restaurant menu catalog with category filtering and item details view.

## Changes
- New MenuCatalogController API endpoints
- Menu.cshtml Razor page with category tabs
- MenuService for menu data retrieval
- Unit tests for MenuController and MenuService

## Test Plan
- [x] Build passes (Release mode)
- [x] All tests pass
- [x] Manual QA: Menu displays correctly
- [x] Manual QA: Category filtering works
- [x] Manual QA: Item details open in modal

🤖 Generated with [Claude Code](https://claude.com/claude-code)"

# Verify base branch
gh pr view --json baseRefName
# ✅ Shows: "baseRefName": "develop"

# STEP 7: 🚨 Add PR link to ClickUp (MANDATORY!)
prNumber=$(gh pr view --json number --jq .number)
prUrl=$(gh pr view --json url --jq .url)
clickup-sync.ps1 -Action comment -TaskId 869bhfw7r -Comment "PR #${prNumber}: ${prUrl}"
# ✅ ClickUp task 869bhfw7r updated with PR link

# STEP 8: Release worktree (use release-worktree skill)
# - Clean worktree directory
# - Mark seat FREE in pool.md
# - Log release in activity.md
# - Switch base repos to develop
# - Commit tracking files
# - THEN present PR to user

echo "✅ PR #${prNumber} created and ClickUp updated: ${prUrl}"
```

---

## 🔍 Validation Checklist (Definition of Done Summary)

**Before presenting work as "done", verify ALL DoD criteria:**

### Workflow Steps (7-Step Mandatory Process)
- [ ] Branch created with proper naming convention
- [ ] Worktree allocated (if Feature Development Mode)
- [ ] Changes implemented and committed
- [ ] Develop merged into branch
- [ ] Build passes (dotnet build)
- [ ] All tests pass (dotnet test)
- [ ] PR created with `--base develop`
- [ ] PR base branch verified (must be develop)
- [ ] **🚨 PR link added to ClickUp task (MANDATORY)**
- [ ] Worktree released (if Feature Development Mode)
- [ ] Tracking files updated and committed

### Definition of Done Criteria
- [ ] ✅ **Development:** Code implemented per requirements
- [ ] ✅ **Quality:** Unit tests written, build passes, tests pass
- [ ] ✅ **Code Quality:** Formatted, linted, no warnings
- [ ] ✅ **Version Control:** Committed, pushed, PR created
- [ ] ✅ **PR Details:** Clear title/description, test plan included
- [ ] ✅ **ClickUp:** Task updated with PR link (traceability)
- [ ] ✅ **Documentation:** Technical docs updated (if applicable)
- [ ] ✅ **Security:** No hardcoded secrets, proper validation
- [ ] ⏳ **Integration:** PR approved and merged (team responsibility)
- [ ] ⏳ **Deployment:** Deployed to production (deployment process)
- [ ] ⏳ **Verification:** Production verification passed (post-deploy)

**Full DoD Reference:** `C:\scripts\_machine\DEFINITION_OF_DONE.md`

**If ANY step is incomplete, work is NOT done.**

---

## 🚫 Common Violations to Avoid

### ❌ VIOLATION: Creating PR without adding link to ClickUp
**Result:** User cannot track progress, breaks traceability
**Fix:** ALWAYS run Step 7, no exceptions

### ❌ VIOLATION: Skipping Step 4 (merge develop)
**Result:** PR has conflicts, fails CI, wastes time
**Fix:** ALWAYS merge develop before creating PR

### ❌ VIOLATION: Creating PR without running tests
**Result:** Broken code merged, user debugging preventable errors
**Fix:** ALWAYS run full build + test suite before PR

### ❌ VIOLATION: Using wrong PR base branch
**Result:** PR targets main instead of develop, wrong merge sequence
**Fix:** ALWAYS specify `--base develop`, verify immediately

### ❌ VIOLATION: Presenting PR before releasing worktree
**Result:** Seat locked, state messy, conflicts with next task
**Fix:** ALWAYS release worktree BEFORE presenting PR to user

---

## 📚 Related Documentation

- **Worktree Protocol:** `worktree-workflow.md`
- **Git Workflow:** `git-workflow.md`
- **ClickUp Integration:** `clickup-integration.md`
- **ClickUp GitHub Workflow:** `clickup-github-workflow.md`
- **Dual-Mode Workflow:** `GENERAL_DUAL_MODE_WORKFLOW.md`
- **Zero-Tolerance Rules:** `GENERAL_ZERO_TOLERANCE_RULES.md`
- **Definition of Done:** `_machine/DEFINITION_OF_DONE.md`

## 🛠️ Skills & Tools

- **allocate-worktree** - Skill for worktree allocation
- **release-worktree** - Skill for worktree cleanup
- **github-workflow** - Skill for PR management
- **clickup-sync.ps1** - Tool for ClickUp integration
- **detect-mode.ps1** - Tool for mode detection

---

**Last Updated:** 2026-02-04
**Maintained By:** Claude Agent
**User Mandate:** "this process needs to be followed whenever any task is worked on"
