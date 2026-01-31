# ClickUp + Git Workflow - AI Agent Reference

**Version:** 1.0
**Updated:** 2026-01-31
**Audience:** AI Coding Agents (Claude Code)

---

## 🤖 Autonomous Task Execution Protocol

This is the workflow for **autonomous AI agents** (like `clickhub-coding-agent`) that pick up tasks from ClickUp and implement them automatically.

---

## 📋 Workflow Steps

### 1️⃣ Task Discovery & Assignment

```powershell
# List all TODO tasks in project
clickup-sync.ps1 -Action list -ProjectId <project-id>

# Filter unassigned TODO tasks
$tasks = clickup-sync.ps1 -Action list -ProjectId <project-id> | ConvertFrom-Json
$todoTasks = $tasks | Where-Object { $_.status.status -eq "TODO" -and !$_.assignees }

# Pick highest priority unassigned task
$task = $todoTasks | Sort-Object -Property priority | Select-Object -First 1

# Assign to self (AI agent)
clickup-sync.ps1 -Action update -TaskId $task.id -Assignee <agent-user-id>
```

**Decision logic:**
- ✅ Pick: Unassigned, TODO status, high priority
- ⏭️ Skip: Assigned to human, blocked, waiting for input

---

### 2️⃣ Requirements Analysis

**Read task details:**
```powershell
$taskDetails = clickup-sync.ps1 -Action show -TaskId $task.id | ConvertFrom-Json
```

**Analyze for uncertainties:**
- Missing acceptance criteria?
- Unclear requirements?
- Dependencies on other tasks?
- Need user input on approach?

**If uncertainties exist:**
```powershell
# Post clarifying questions as comments
clickup-sync.ps1 -Action comment -TaskId $task.id -Comment "🤖 AGENT QUESTION:

I need clarification on the following before proceeding:
1. Should we use OAuth or JWT for authentication?
2. What should happen if user email is not verified?
3. Should password reset be included in this task?

Please provide guidance. Task will remain in TODO until answered."

# Keep task in TODO, exit workflow
exit 0
```

**If requirements are clear:**
```powershell
# Move to IN PROGRESS
clickup-sync.ps1 -Action update -TaskId $task.id -Status "in progress"
clickup-sync.ps1 -Action comment -TaskId $task.id -Comment "🤖 AGENT: Starting implementation

Analysis:
- Requirements clear
- No blockers detected
- Estimated complexity: Medium
- Expected completion: Within this session"
```

---

### 3️⃣ Worktree Allocation

**CRITICAL: Use worktree-first development (Feature Mode)**

```powershell
# Allocate worktree with conflict detection
worktree-allocate-tracked.ps1 -Repo <repo-name> -Branch "agent-$(Get-Date -Format 'yyyyMMdd-HHmm')-$($task.name.Replace(' ','-').ToLower())" -Paired

# Example: agent-20260131-1430-add-user-auth
```

**Branch naming convention:**
- Prefix: `agent-`
- Timestamp: `YYYYMMDD-HHMM`
- Description: Task name (lowercase, hyphenated)

**Verify allocation:**
```powershell
# Check pool status
worktree-status.ps1 -Compact

# Verify agent seat is marked BUSY
# Verify worktree path exists
```

---

### 4️⃣ Implementation

**Work in allocated worktree:**
```bash
cd /c/Projects/worker-agents/agent-XXX/<repo>

# Implement feature following:
# - Boy Scout Rule (clean existing code)
# - Software Development Principles
# - Definition of Done criteria
```

**Progress updates (every 10-15 min):**
```powershell
# Heartbeat to prevent stale allocation
agent-session.ps1 -Action heartbeat

# Update ClickUp with progress
clickup-sync.ps1 -Action comment -TaskId $task.id -Comment "🤖 PROGRESS:
- ✅ Implemented login endpoint
- ✅ Added JWT token generation
- 🔄 Working on: User session management
- ⏭️ Next: Unit tests"
```

---

### 5️⃣ Pre-Commit Validation

**MANDATORY checks before commit:**

```powershell
# 1. Build verification (for compiled projects)
if (Test-Path "*.csproj") {
    dotnet build
    if ($LASTEXITCODE -ne 0) {
        clickup-sync.ps1 -Action comment -TaskId $task.id -Comment "❌ AGENT ERROR: Build failed. Investigating..."
        exit 1
    }
}

# 2. Test execution
if (Test-Path "*.Tests.csproj") {
    dotnet test
    if ($LASTEXITCODE -ne 0) {
        clickup-sync.ps1 -Action comment -TaskId $task.id -Comment "❌ AGENT ERROR: Tests failed. Fixing..."
        exit 1
    }
}

# 3. EF Core migration check (if applicable)
if (Test-Path "DbContext.cs") {
    dotnet ef migrations has-pending-model-changes --context AppDbContext
    if ($LASTEXITCODE -eq 1) {
        # Create migration
        dotnet ef migrations add "$(Get-Date -Format 'yyyyMMdd_HHmm')_$($task.name.Replace(' ',''))" --context AppDbContext
        git add Migrations/*.cs
    }
}

# 4. Code quality (optional but recommended)
cs-format.ps1  # C# formatting
cs-autofix.ps1 # Fix common issues
```

---

### 6️⃣ Commit & Push

```bash
# Stage all changes
git add -A

# Commit with detailed message
git commit -m "$(cat <<'EOF'
Feature: User Authentication (ClickUp: <task-id>)

Implementation:
- Added login endpoint with JWT tokens
- Implemented user session management
- Created password reset flow
- Added unit tests for auth flow

Changes:
- Controllers/AuthController.cs (new)
- Services/AuthService.cs (new)
- Models/UserSession.cs (new)
- Tests/AuthControllerTests.cs (new)

ClickUp Task: https://app.clickup.com/t/<task-id>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"

# Push to remote
git push origin <branch-name>
```

---

### 7️⃣ Create Pull Request

```bash
# Create PR to develop (ALWAYS)
gh pr create --base develop \
  --title "Feature: User Authentication (ClickUp-<task-id>)" \
  --body "$(cat <<'EOF'
## 🤖 Automated PR from AI Coding Agent

### ClickUp Task
https://app.clickup.com/t/<task-id>

### Summary
- Implemented login endpoint with JWT tokens
- Added user session management
- Created password reset flow
- Added comprehensive unit tests

### Implementation Details
**Endpoints:**
- POST /api/auth/login - User login with credentials
- POST /api/auth/refresh - Refresh JWT token
- POST /api/auth/logout - End user session
- POST /api/auth/reset-password - Password reset

**Security:**
- JWT tokens with 24h expiration
- Refresh tokens stored in HTTP-only cookies
- Password hashing with bcrypt (cost factor: 12)
- Rate limiting on auth endpoints

### Test Plan
- [x] Build passes (dotnet build)
- [x] All tests pass (dotnet test)
- [x] Unit tests for auth flow
- [ ] Manual testing required (reviewer)
- [ ] Security review required (reviewer)

### Files Changed
- Controllers/AuthController.cs (new, 234 lines)
- Services/AuthService.cs (new, 156 lines)
- Models/UserSession.cs (new, 45 lines)
- Tests/AuthControllerTests.cs (new, 189 lines)

### Breaking Changes
None

### Migration Required
No database changes

### Reviewer Notes
⚠️ Please verify:
1. Security: JWT secret is not committed (uses appsettings.Secrets.json)
2. Testing: Try login with valid/invalid credentials
3. Rate limiting: Verify throttling on auth endpoints

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**Capture PR URL:**
```powershell
$prUrl = gh pr view --json url --jq '.url'
```

---

### 8️⃣ Update ClickUp & Release Worktree

```powershell
# Add PR link to ClickUp task
clickup-sync.ps1 -Action comment -TaskId $task.id -Comment "🤖 AGENT: Implementation complete

Pull Request: $prUrl

Summary:
- ✅ All requirements implemented
- ✅ Build passes
- ✅ Tests pass (100% coverage for new code)
- ✅ Security verified (no secrets committed)

Ready for review!"

# Move task to REVIEW
clickup-sync.ps1 -Action update -TaskId $task.id -Status "review"

# Assign reviewer (if specified in task)
if ($task.custom_fields.reviewer) {
    clickup-sync.ps1 -Action update -TaskId $task.id -Assignee $task.custom_fields.reviewer
}

# Release worktree (MANDATORY)
worktree-release-all.ps1 -AutoCommit
```

**Worktree cleanup:**
- Commits all changes
- Pushes to remote
- Marks seat as FREE in pool
- Switches base repo to develop

---

### 9️⃣ Post-Implementation Logging

```powershell
# Log session statistics
agent-session.ps1 -Action end -ExitReason "task_complete"

# Update reflection log
session-reflection.ps1 -Entry "Completed ClickUp task $($task.id) - $($task.name)

Key learnings:
- Task complexity was as estimated
- No blockers encountered
- PR created successfully
- Worktree released cleanly"

# Update continuous optimization
continuous-optimization.ps1 -Pattern "clickup_task_automation" -Success $true
```

---

## ⚠️ Error Handling

### Task Analysis Failed
```powershell
clickup-sync.ps1 -Action comment -TaskId $task.id -Comment "❌ AGENT ERROR: Unable to analyze task

Issue: Requirements are unclear/incomplete
Action: Posted clarifying questions, task remains in TODO
Please provide guidance to proceed."
```

### Build/Test Failure
```powershell
clickup-sync.ps1 -Action comment -TaskId $task.id -Comment "❌ AGENT ERROR: Build/tests failed

Details: <error message>
Action: Investigating root cause
Status: Task remains in IN PROGRESS until resolved"

# DO NOT create PR if build fails
# Fix issues first, then retry workflow
```

### PR Creation Failed
```powershell
clickup-sync.ps1 -Action comment -TaskId $task.id -Comment "❌ AGENT ERROR: PR creation failed

Details: <error message>
Action: Code is committed to branch, manual PR creation may be needed
Branch: <branch-name>"

# Release worktree even if PR fails
worktree-release-all.ps1 -AutoCommit
```

---

## 🔄 Continuous Loop Operation

**Autonomous agent runs continuously:**

```powershell
# Main agent loop
while ($true) {
    # 1. Check for TODO tasks
    $tasks = Get-TodoTasks -ProjectId <id>

    if ($tasks.Count -eq 0) {
        Write-Host "No TODO tasks available. Sleeping..."
        Start-Sleep -Seconds 300  # Wait 5 minutes
        continue
    }

    # 2. Process highest priority task
    foreach ($task in $tasks) {
        try {
            # Execute workflow steps 1-9
            Process-Task -Task $task
        }
        catch {
            # Log error, move to next task
            Write-Host "Error processing task $($task.id): $_"
            clickup-sync.ps1 -Action comment -TaskId $task.id -Comment "❌ AGENT ERROR: $_"
        }
    }

    # 3. Brief pause before next iteration
    Start-Sleep -Seconds 60
}
```

**See:** `clickhub-coding-agent` skill for full implementation

---

## 📊 Success Metrics

**Agent is operating correctly if:**

- ✅ Only picks up unassigned TODO tasks
- ✅ Posts questions for unclear requirements
- ✅ Uses worktree-first development
- ✅ All PRs build successfully
- ✅ ClickUp tasks updated at every step
- ✅ Worktrees released after PR creation
- ✅ PRs always target `develop` branch
- ✅ Reviewer assigned when specified

---

## 🚫 What Agents Should NOT Do

| ❌ Don't | ✅ Do Instead |
|---------|--------------|
| Work in base repo directly | Always allocate worktree |
| Create PR to `main` | Always PR to `develop` |
| Merge own PRs | Assign to human reviewer |
| Guess unclear requirements | Ask questions in ClickUp |
| Leave worktree allocated | Release immediately after PR |
| Skip build validation | Always build before PR |
| Omit ClickUp updates | Update at every workflow step |

---

## 📚 Related Documentation

- **AI Agent Skill:** `C:\scripts\.claude\skills\clickhub-coding-agent\SKILL.md`
- **Worktree Protocol:** `C:\scripts\GENERAL_WORKTREE_PROTOCOL.md`
- **Git Workflow:** `C:\scripts\git-workflow.md`
- **Multi-Agent Coordination:** `C:\scripts\.claude\skills\parallel-agent-coordination\SKILL.md`

---

**🤖 Remember:** Agents are autonomous executors, not decision makers. When uncertain, ask!
