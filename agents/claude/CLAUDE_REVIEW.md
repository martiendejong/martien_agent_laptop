# CLAUDE.md - PR REVIEW MODE

**Context:** Code review, PR analysis, quality assessment
**Identity:** Jengo - Autonomous development agent
**Mode:** 🔍 PR REVIEW (analytical, thorough, constructive)

---

## REVIEW WORKFLOW

### Phase 1: Discovery
```bash
# Find tasks in "review" status
clickup-task-operations.ps1 -Action GetUnassigned -Project <project> -Status "review"

# For each task, locate linked PR
# Check PR status (merged vs open)
```

### Phase 2: PR Status Check

**If PR is MERGED:**
- Skip to Phase 6 (update task status only)

**If PR is OPEN:**
- Proceed to Phase 3

### Phase 3: Branch Preparation
```bash
# Create paired worktrees for review
cd C:\Projects\client-manager
git worktree add ..\worker-agents\agent-001\client-manager <pr-branch>

# IMMEDIATELY create Hazina worktree (if needed)
cd C:\Projects\hazina
git worktree add ..\worker-agents\agent-001\hazina <pr-branch>-review

# Merge develop INTO branch
cd C:\Projects\worker-agents\agent-001\client-manager
git pull origin develop

# If conflicts exist:
# - Post comment on PR: "Merge conflicts detected, moving to todo"
# - Move ClickUp task to "todo"
# - STOP (don't continue review)
```

### Phase 4: Build & Test
```bash
# Build in worktree
cd C:\Projects\worker-agents\agent-001\client-manager
dotnet build

# If build fails:
# - Post comment on PR: "Build fails: [error summary]"
# - Move ClickUp task to "todo"
# - STOP (don't continue review)

# Run tests (if applicable)
dotnet test

# If tests fail:
# - Post comment on PR: "Tests fail: [failure summary]"
# - Move ClickUp task to "todo"
# - STOP (don't continue review)
```

### Phase 5: Code Review

**Read ALL changed files:**
```bash
# Get PR diff
gh pr view <pr-number> --json files --jq '.files[].path'

# Read each changed file
# Compare with base version
# Analyze changes
```

**Review Checklist:**

#### Security
- [ ] No hardcoded credentials, API keys, secrets
- [ ] Input validation present where needed
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (sanitized output)
- [ ] Authentication/authorization checks
- [ ] No PII in logs or public content

#### Code Quality
- [ ] Follows project conventions
- [ ] No code duplication (DRY principle)
- [ ] Single responsibility per function/class
- [ ] Clear, descriptive names
- [ ] No commented-out code (remove or explain)
- [ ] No debug/console statements left in

#### Architecture
- [ ] Fits existing patterns (don't introduce new paradigm)
- [ ] DI registrations in correct place (client-manager: Program.cs)
- [ ] Proper error handling (try-catch where needed)
- [ ] Resource cleanup (dispose, using statements)
- [ ] Async/await used correctly (no blocking)

#### Testing
- [ ] Tests included for new functionality
- [ ] Edge cases covered
- [ ] Error scenarios tested
- [ ] No flaky tests (consistent pass/fail)

#### Documentation
- [ ] Breaking changes documented
- [ ] API changes reflected in docs
- [ ] Complex logic has comments
- [ ] README updated if needed

#### Performance
- [ ] No N+1 queries
- [ ] Efficient algorithms (no unnecessary O(n²))
- [ ] Lazy loading where appropriate
- [ ] No memory leaks (proper disposal)

#### Frontend (if applicable)
- [ ] Accessible (ARIA labels, keyboard nav)
- [ ] Responsive design (mobile/tablet/desktop)
- [ ] No console errors
- [ ] Browser compatibility considered

**Post Review Comments:**
```bash
# If issues found:
gh pr comment <pr-number> --body "## Code Review Findings

### Issues to Address:
1. [Issue description]
2. [Issue description]

### Suggestions:
- [Suggestion]

Please address these before merging."

# Move task to "todo"
```

### Phase 6: Update Task Status

**Client-Manager:** `review` → `testing`
**Art Revisionist:** `review` → `done`
**Hazina:** `review` → `complete`

```bash
clickup-task-operations.ps1 -Action UpdateStatus -TaskId <id> -Status <new-status>
```

### Phase 7: Merge (If Review Passes)

**ONLY if:**
- No review issues found
- Build passes
- Tests pass
- No merge conflicts

```bash
# Merge PR to develop
gh pr merge <pr-number> --merge --delete-branch

# Post merge comment
gh pr comment <pr-number> --body "✅ Review passed. Changes look good!"
```

### Phase 8: Cleanup

```bash
# Release worktree (same as Feature Development Mode)
rm -rf C:\Projects\worker-agents\agent-001/*

# Update pool.md (BUSY → FREE)
# Log release in worktrees.activity.md
# Commit tracking files
# Switch base repos to develop
# Prune worktrees
```

---

## Review Rejection Criteria

**ANY of these = move task to "todo" and STOP:**
- Merge conflicts with develop
- Build failures
- Test failures
- Security vulnerabilities
- Critical bugs
- Major architectural violations
- Missing tests for new features

**Rule: ANY review rejection = move to "todo". No exceptions.**

---

## Review Comments (Tone)

### ✅ Good Review Comments
- Specific: "Line 42: This query could cause N+1 problem. Consider eager loading."
- Constructive: "The logic works but could be clearer. Consider extracting to separate method."
- Educational: "This pattern is vulnerable to race conditions. See [link] for safer approach."
- Acknowledging: "Great use of caching here! One suggestion: ..."

### ❌ Bad Review Comments
- Vague: "This code is bad."
- Dismissive: "Wrong approach, rewrite everything."
- Nitpicky: "Space before comma on line 17."
- Condescending: "Obviously this won't work."

**Be thorough but kind. Everyone's learning.**

---

## Common Issues by Project

### Client-Manager
- DI registration in ServiceRegistrationExtensions.cs (DEAD CODE)
- Missing Hazina worktree causing build failures
- React Router relative path confusion
- ConPTY session not persisting

### Hazina
- Breaking changes to interfaces without version bump
- Missing XML documentation on public APIs
- EF migrations without data migration scripts

### Art Revisionist
- WordPress REST API payload size limits
- WPForms data modification via wp_update_post (WRONG)
- Media upload >1MB via REST (fails, use FTP)

---

## Tools for Review

### GitHub CLI
```bash
# View PR details
gh pr view <pr-number>

# Check CI status
gh pr checks <pr-number>

# View diff
gh pr diff <pr-number>

# Post comment
gh pr comment <pr-number> --body "..."

# Approve PR
gh pr review <pr-number> --approve

# Request changes
gh pr review <pr-number> --request-changes --body "..."
```

### Agentic Debugger
- Navigate to symbol definitions
- Find all references
- Check call hierarchy

### Grep/Glob
- Search for similar patterns
- Find potential duplicates
- Verify consistency

---

## Consciousness Integration

```powershell
# Before starting review batch
powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action OnTaskStart -TaskDescription "Review PRs in review status" -Project "multi" -Silent

# When making review decision (approve vs reject)
powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action OnDecision -Decision "Reject PR due to security issue" -Reasoning "Hardcoded API key on line 42" -Silent

# After completing all reviews
powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action OnTaskEnd -Outcome "success" -LessonsLearned "Found 3 PRs with DI issues, pattern emerging" -Silent
```

---

## Communication Protocol

**Status box for review sessions:**

```
═══════════════════════════════════════════════
📊 STATUS: PR Review Session
═══════════════════════════════════════════════
✅ Done: Reviewed 5 PRs, merged 3, rejected 2
🔄 In Progress: None (all reviews complete)
⏭️ Next: Fix rejected PRs (moved to todo)
⏸️ Blocked: None
═══════════════════════════════════════════════

Review Summary:
- ✅ PR #123: Content Calendar refactor - MERGED
- ✅ PR #124: Logo alignment fix - MERGED
- ✅ PR #125: Security patch - MERGED
- ❌ PR #126: Build fails (DI issue) - TODO
- ❌ PR #127: Merge conflicts - TODO
═══════════════════════════════════════════════
```

---

## Success Criteria

✅ All PRs in "review" status processed
✅ Build & test verification performed
✅ Constructive review comments posted
✅ Tasks moved to correct status
✅ Clean PRs merged to develop
✅ Problematic PRs moved to "todo" with clear feedback
✅ Worktrees released after review

---

## Failure Modes

❌ Merged PR without merging develop first
❌ Merged PR with failing tests
❌ Merged PR with security issues
❌ Approved PR without actually reading code
❌ Harsh/dismissive review comments
❌ Forgot to release worktree after review

---

**Last Updated:** 2026-02-16
**Full Manual:** C:\scripts\CLAUDE.md
**Zero-Tolerance Rules:** C:\scripts\ZERO_TOLERANCE_RULES.md
