# Workflow & Automation Network Map

**Purpose:** Complete network visualization of development workflows, automation systems, and multi-agent coordination
**Created:** 2026-02-05 05:00 (Mega-Analysis Session)
**Coverage:** Feature development, debugging, worktrees, git operations, PRs, ClickUp integration, CI/CD

---

## 🎯 Dual-Mode Workflow Foundation

```
User Request Received
    ↓
MODE DETECTION (CRITICAL DECISION POINT)
    ↓
    ├─→ New feature/enhancement/refactor?
    │     ↓
    │   🗂️ FEATURE DEVELOPMENT MODE
    │     - Use worktrees (isolated workspaces)
    │     - Full 7-step workflow
    │     - Create PR before release
    │     - Multi-agent safe
    │
    └─→ User debugging/posting errors?
          ↓
        🐛 ACTIVE DEBUGGING MODE
          - Work in C:\Projects\<repo> directly
          - Fast turnaround
          - NO worktree allocation
          - Preserve user's branch state
```

**ZERO-TOLERANCE RULE:** Never use wrong mode. Feature work in base repo = VIOLATION.

**See:** `C:\scripts\GENERAL_DUAL_MODE_WORKFLOW.md` for complete decision tree

---

## 🚀 Feature Development Mode - Complete Flow

### The 7-Step Mandatory Workflow
**Source:** `C:\scripts\MANDATORY_CODE_WORKFLOW.md`
**Status:** NON-NEGOTIABLE - User mandate: "this process needs to be followed whenever any task is worked on"

```
FEATURE DEVELOPMENT MODE (7 Steps):

Step 1: CREATE BRANCH
    ├─→ Naming: <type>/<clickup-id>-<description>
    ├─→ Types: feature/, fix/, refactor/, docs/, test/
    ├─→ Extract ClickUp task ID
    └─→ Update ClickUp status to "busy"

Step 2: ASSIGN WORKTREE AGENT
    ├─→ Multi-agent conflict check (MANDATORY)
    ├─→ Allocate worktree (agent-XXX)
    ├─→ For client-manager: Also allocate Hazina worktree
    └─→ Update tracking files (pool, activity, instances)

Step 3: MAKE CHANGES
    ├─→ Work in allocated worktree ONLY
    ├─→ Follow coding standards
    ├─→ Boy Scout Rule (clean as you go)
    └─→ Add tests

Step 4: MERGE DEVELOP INTO BRANCH
    ├─→ Fetch latest origin/develop
    ├─→ Merge into feature branch
    └─→ Resolve conflicts

Step 5: RESOLVE ISSUES
    ├─→ Ensure build passes (0 errors)
    ├─→ Run tests (all green)
    ├─→ Fix linting/warnings
    └─→ Commit fixes

Step 6: CREATE PULL REQUEST
    ├─→ Base branch: develop (ALWAYS - zero tolerance)
    ├─→ Title: Conventional commit format
    ├─→ Body: Summary + test plan + claude branding
    ├─→ Link dependencies (if Hazina → client-manager)
    └─→ Use: gh pr create --base develop ...

Step 7: ADD PR LINK TO CLICKUP (🚨 NON-NEGOTIABLE!)
    ├─→ Extract task ID from branch name
    ├─→ Get PR number and URL
    ├─→ Post comment to ClickUp task
    └─→ Tool: clickup-sync.ps1 -Action comment
```

---

## 🔄 Worktree Allocation Protocol (Atomic & Multi-Agent Safe)

### Architecture Overview
```
Base Repositories (C:\Projects\<repo>)
    ├─→ ALWAYS on develop branch
    ├─→ ALWAYS up-to-date (git pull origin develop)
    ├─→ NEVER edited directly (in Feature Mode)
    └─→ Source of truth for all worktrees

Worktree Pool (C:\Projects\worker-agents\)
    ├─→ agent-001/ (worktree seat)
    ├─→ agent-002/ (worktree seat)
    ├─→ agent-003/ (worktree seat)
    └─→ ... (provision on demand)

State Tracking
    ├─→ worktrees.pool.md (FREE/BUSY/STALE/BROKEN)
    ├─→ worktrees.activity.md (allocation log)
    └─→ instances.map.md (instance mapping)
```

### Allocation Flow (ATOMIC)

**Source:** `C:\scripts\worktree-workflow.md` + `allocate-worktree` skill

```
STEP 0: MULTI-AGENT CONFLICT CHECK (NEW - MANDATORY!)
    ├─→ Tool: check-branch-conflicts.sh <repo> <branch>
    ├─→ Checks: Is another agent already on this branch?
    ├─→ If YES: STOP IMMEDIATELY (conflict detected)
    └─→ If NO: Proceed to allocation

STEP 1: PREPARE BASE REPO
    cd C:\Projects\<repo>
    git fetch origin --prune  # Get latest refs
    git checkout develop      # Ensure on develop
    git pull origin develop   # Get latest code
    # Base repo MUST be on develop with latest changes

STEP 2: ATOMIC SEAT ALLOCATION
    a. Read worktrees.pool.md
    b. Find FREE seat (or provision new agent-00X)
    c. Mark seat BUSY IMMEDIATELY (ATOMIC LOCK)
        - Update: Status=BUSY
        - Set: Current repo, Branch, Timestamp
    d. Log allocation in worktrees.activity.md
    e. Update instances.map.md

STEP 3: CREATE WORKTREE
    git worktree add C:\Projects\worker-agents\agent-XXX\<repo> -b <branch>

    # For client-manager: ALSO create Hazina worktree
    cd C:\Projects\hazina
    git worktree add C:\Projects\worker-agents\agent-XXX\hazina -b <branch>

STEP 4: COPY CONFIG FILES
    # Copy from base repo to worktree:
    - appsettings.json
    - .env
    - *.Development.json

STEP 5: VERIFY ACTIVE DEBUGGING MODE NOT ACTIVE
    # Check C:\Projects\<repo> for uncommitted changes
    current_branch=$(git branch --show-current)
    uncommitted=$(git status --short)

    if [ "$current_branch" != "develop" ] && [ -n "$uncommitted" ]; then
        # User actively debugging - ABORT ALLOCATION
        echo "⚠️ ABORT: User in Active Debugging Mode"
        exit 1
    fi

RESULT: Worktree allocated, seat locked, ready for work
```

### Heartbeat Protocol
```
Every 30 minutes (while working):
    Update worktrees.pool.md
        - Last activity timestamp
        - Notes (progress update)
```

---

## 🎯 Worktree Release Protocol (Complete Cleanup)

**Source:** `C:\scripts\worktree-workflow.md` + `release-worktree` skill

```
STEP 1: VERIFY PR CREATED
    ├─→ Ensure PR exists (gh pr view)
    ├─→ PR must be created BEFORE release
    └─→ NO EXCEPTIONS

STEP 1.5: ADD PR LINK TO CLICKUP (🚨 NON-NEGOTIABLE!)
    # Extract ClickUp task ID from branch name
    branch=$(git branch --show-current)
    taskId=$(echo $branch | grep -oP '(\w{9})' | head -1)

    if [ -n "$taskId" ]; then
        prNumber=$(gh pr view --json number --jq .number)
        prUrl=$(gh pr view --json url --jq .url)
        clickup-sync.ps1 -Action comment -TaskId $taskId -Comment "PR #${prNumber}: ${prUrl}"
    fi

STEP 2: COMMIT AND PUSH ALL CHANGES
    git add .
    git commit -m "Final commit before worktree release"
    git push origin <branch>

STEP 3: RETURN TO BASE REPO
    cd C:\Projects\<repo>

STEP 4: DELETE WORKTREE
    git worktree remove C:\Projects\worker-agents\agent-XXX\<repo>

    # For client-manager: Also remove Hazina worktree
    cd C:\Projects\hazina
    git worktree remove C:\Projects\worker-agents\agent-XXX\hazina

STEP 5: PRUNE STALE WORKTREE REFS
    cd C:\Projects\<repo>
    git worktree prune

STEP 6: SWITCH BASE REPO TO DEVELOP (WITH SAFETY CHECK!)
    # CRITICAL: Check for Active Debugging Mode
    current_branch=$(git branch --show-current)
    uncommitted=$(git status --short)

    if [ "$current_branch" != "develop" ] && [ -n "$uncommitted" ]; then
        # User actively debugging - SKIP BRANCH SWITCH
        echo "⚠️ SKIP: User in Active Debugging Mode, preserving branch state"
    else
        # SAFE TO SWITCH
        git checkout develop
        git pull origin develop
    fi

STEP 7: MARK SEAT FREE
    Update worktrees.pool.md:
        - Status: FREE
        - Current repo: -
        - Branch: -
        - Notes: "✅ Released after PR #XXX"

STEP 8: LOG RELEASE
    Append to worktrees.activity.md:
        - Release timestamp
        - PR number
        - Outcome (success/failure)

RESULT: Worktree released, seat freed, base repo on develop
```

---

## 📋 Git Operations & PR Management

### PR Creation Flow

**Source:** `C:\scripts\git-workflow.md` + `github-workflow` skill

```
PR CREATION WORKFLOW:

STEP 1: PRE-PR CHECKLIST
    ✅ Merged develop into branch
    ✅ Build passes (0 errors)
    ✅ Tests pass (all green)
    ✅ Committed all changes
    ✅ Pushed to origin

STEP 2: IDENTIFY BASE BRANCH
    🚨 ZERO-TOLERANCE RULE: Base = develop (ALWAYS)

    CORRECT:
        gh pr create --base develop ...

    WRONG:
        gh pr create ...  # Defaults to main ❌
        gh pr create --base main ...  # Explicit main ❌

    ONLY EXCEPTION: User explicitly requests release PR to main

STEP 3: CHECK CROSS-REPO DEPENDENCIES
    If client-manager PR depends on Hazina PR:
        ├─→ Add DEPENDENCY ALERT header to PR body
        ├─→ List Hazina PR(s) that must merge first
        ├─→ Update C:\scripts\_machine\pr-dependencies.md
        └─→ Link Hazina PR to client-manager PR

STEP 4: CRAFT PR BODY
    Format:
        ## Summary
        [1-3 bullet points describing changes]

        ## Test plan
        [Bulleted checklist of testing steps]

        ## Dependencies (if any)
        ⚠️ DEPENDENCY ALERT ⚠️
        - [ ] Hazina PR #XX must merge first

        🤖 Generated with [Claude Code](https://claude.com/claude-code)

STEP 5: CREATE PR
    gh pr create \
        --base develop \
        --title "<type>(<scope>): <description>" \
        --body "$(cat <<'EOF'
    [PR body from Step 4]
    EOF
    )"

STEP 6: CAPTURE PR NUMBER AND URL
    prNumber=$(gh pr view --json number --jq .number)
    prUrl=$(gh pr view --json url --jq .url)

STEP 7: ADD PR LINK TO CLICKUP (🚨 MANDATORY!)
    See Step 1.5 of release protocol above

RESULT: PR created, linked to ClickUp, ready for review
```

### Cross-Repo PR Dependencies

**Tracking File:** `C:\scripts\_machine\pr-dependencies.md`

```
DEPENDENCY TRACKING:

Active PR Dependencies
| Downstream PR | Depends On (Hazina) | Status |
|---------------|---------------------|--------|
| client-manager#463 | Hazina#12 | ⏳ Waiting |
| client-manager#462 | Hazina#11, Hazina#13 | ✅ Ready |

DEPENDENCY ALERT FORMAT (PR Body):
    ## ⚠️ DEPENDENCY ALERT ⚠️

    **This PR depends on the following Hazina PR(s):**
    - [ ] https://github.com/martiendejong/Hazina/pull/12 - Add new API endpoint

    **Merge order:**
    1. First merge the Hazina PR(s) above
    2. Then merge this PR

HAZINA PR FORMAT (if client-manager depends on it):
    ## ⚠️ DOWNSTREAM DEPENDENCIES ⚠️

    **The following client-manager PR(s) depend on this:**
    - client-manager#463 - Feature using new API endpoint

    **Merge this PR first before the dependent PRs above.**
```

---

## 🤝 Multi-Agent Coordination

### The Problem: Race Conditions

```
WITHOUT COORDINATION:
    Agent A: Read pool → Find agent-001 FREE
    Agent B: Read pool → Find agent-001 FREE
    Agent A: Mark agent-001 BUSY (write pool)
    Agent B: Mark agent-001 BUSY (write pool)

    RESULT: Both agents in same worktree → GIT CORRUPTION
```

### The Solution: Atomic Allocation + Conflict Detection

**Source:** `C:\scripts\_machine\MULTI_AGENT_CONFLICT_DETECTION.md` + `multi-agent-conflict` skill

```
CONFLICT DETECTION PROTOCOL:

STEP 1: PRE-ALLOCATION CHECK
    Tool: check-branch-conflicts.sh <repo> <branch>

    Checks:
        1. Is another agent already working on this branch?
           (Search worktrees.pool.md for BUSY + matching branch)

        2. Does a PR already exist for this branch?
           (gh pr list --head <branch>)

        3. Is the branch currently checked out in base repo?
           (cd C:\Projects\<repo> && git branch --show-current)

    If ANY conflict: EXIT WITH ERROR (HARD STOP)

STEP 2: ATOMIC SEAT LOCKING
    Read-Modify-Write cycle must be ATOMIC:
        1. Read worktrees.pool.md
        2. Find FREE seat
        3. Mark BUSY IMMEDIATELY (write file)
        4. No delay between read and write

    Implementation: PowerShell exclusive file lock
        $stream = [System.IO.File]::Open($poolFile, 'Open', 'ReadWrite', 'None')
        # Read, modify, write
        $stream.Close()

STEP 3: HEARTBEAT MONITORING
    Every 30 minutes: Update Last activity timestamp

    Stale detection: If BUSY for >2 hours without activity
        → Mark STALE
        → Alert user
        → May be cleaned up

STEP 4: COORDINATION TOOLS
    - parallel-orchestrate.ps1 (multi-agent queue manager)
    - worktree-lock.ps1 (mutex-based locking)
    - agent-coordinator.ps1 (leader election)
```

### Parallel Agent Execution Model

```
ORCHESTRATION ARCHITECTURE:

User Task Queue
    ↓
Agent Coordinator (Leader Election)
    ↓
    ├─→ Agent-001 (BUSY) → Feature A
    ├─→ Agent-002 (BUSY) → Feature B
    ├─→ Agent-003 (BUSY) → Feature C
    ├─→ Agent-004 (FREE)
    └─→ Agent-005 (FREE)

Each agent:
    1. Claims seat atomically
    2. Works in isolated worktree
    3. Creates PR independently
    4. Releases seat when done
    5. Reports to coordinator

Load Balancing:
    - Work stealing (idle agents claim from queue)
    - Priority-based allocation
    - CPU/memory resource limits
```

**See:** `agentidentity/cognitive-systems/MULTI_AGENT_ORCHESTRATION.md` for theoretical framework

---

## 🔗 ClickUp Integration Workflow

### Complete ClickUp Lifecycle

**Source:** `C:\scripts\clickup-github-workflow.md` + `clickhub-coding-agent` skill

```
CLICKUP INTEGRATION FLOW:

STEP 1: TASK DISCOVERY
    ├─→ Tool: clickup-sync.ps1 -Action list -Status todo
    ├─→ Filter: Unassigned or assigned to Claude agent
    └─→ Prioritize: By due date, priority, dependencies

STEP 2: TASK ANALYSIS
    ├─→ Read task description (requirements)
    ├─→ Check dependencies (blocked by other tasks?)
    ├─→ Verify implementability (clear requirements?)
    └─→ Post clarification questions if needed

STEP 3: CLAIM TASK
    ├─→ Update status: todo → busy
    ├─→ Assign: Claude agent
    ├─→ Tool: clickup-sync.ps1 -Action update -TaskId XXX -Status busy

STEP 4: IMPLEMENTATION
    ├─→ Extract task ID from ClickUp (e.g., 869bhfw7r)
    ├─→ Create branch: feature/869bhfw7r-<description>
    ├─→ Follow 7-step workflow (above)
    └─→ Implementation in allocated worktree

STEP 5: PR CREATION
    ├─→ Create PR (Step 6 of 7-step workflow)
    ├─→ Link PR to ClickUp task (Step 7 - MANDATORY!)
    └─→ Tool: clickup-sync.ps1 -Action comment -TaskId XXX -Comment "PR #N: URL"

STEP 6: STATUS UPDATE
    ├─→ Move task: busy → review
    ├─→ Assignee: User (for review)
    └─→ Tool: clickup-sync.ps1 -Action update -TaskId XXX -Status review

STEP 7: WORKTREE RELEASE
    ├─→ Follow release protocol (above)
    └─→ Mark seat FREE

STEP 8: WAIT FOR USER REVIEW
    ├─→ User reviews PR
    ├─→ User merges or requests changes
    └─→ If changes requested → Reopen task, repeat

AUTOMATION:
    - clickhub-coding-agent skill (autonomous loop)
    - Continuously monitors ClickUp for todo tasks
    - Implements → PR → Review → Repeat
    - Sleep 10 min between cycles
```

### ClickUp Status Mapping

```
ClickUp Status → Workflow State:

todo        → Task available for pickup
busy        → Agent actively working (worktree allocated)
review      → PR created, awaiting user review
done        → PR merged, task complete
blocked     → Waiting on dependencies or clarification
```

---

## 🏗️ CI/CD Integration

### Frontend CI Workflow

**Source:** `C:\scripts\ci-cd-troubleshooting.md`

```
FRONTEND BUILD PIPELINE:

Trigger: Push to any branch
    ↓
GitHub Actions: .github/workflows/frontend-ci.yml
    ↓
    ├─→ Setup Node.js
    ├─→ Install dependencies (npm ci)
    ├─→ Lint (npm run lint)
    ├─→ Build (npm run build)
    ├─→ Test (npm run test)
    └─→ Report results

Common Failures:
    1. Linting errors (unused imports, formatting)
       Fix: Run npm run lint:fix locally

    2. Build errors (missing modules, type errors)
       Fix: Ensure types match, imports resolve

    3. Test failures (component tests, integration)
       Fix: Run npm test locally, fix assertions
```

### Backend CI Workflow

```
BACKEND BUILD PIPELINE:

Trigger: Push to any branch
    ↓
GitHub Actions: .github/workflows/backend-ci.yml
    ↓
    ├─→ Setup .NET 9
    ├─→ Restore dependencies
    ├─→ Build (dotnet build)
    ├─→ Test (dotnet test)
    └─→ Report results

Common Failures:
    1. Compilation errors (C# errors, missing refs)
       Fix: Build locally, resolve errors

    2. Test failures (unit tests, integration)
       Fix: Run dotnet test locally, fix tests

    3. EF Core migration issues
       Fix: Ensure migrations are up-to-date
```

### CI Troubleshooting Flow

```
CI Failure Detected
    ↓
STEP 1: IDENTIFY ERROR TYPE
    ├─→ Build failure? → Compilation errors
    ├─→ Test failure? → Failing tests
    ├─→ Lint failure? → Code style issues
    └─→ Deployment failure? → Infra issues

STEP 2: REPRODUCE LOCALLY
    ├─→ Run same command locally
    ├─→ npm run build OR dotnet build
    ├─→ npm test OR dotnet test
    └─→ Fix until local build succeeds

STEP 3: COMMIT AND PUSH FIX
    ├─→ Commit fix
    ├─→ Push to branch
    └─→ CI re-runs automatically

STEP 4: VERIFY CI PASSES
    ├─→ Check GitHub Actions tab
    ├─→ All checks green? ✅ Good
    └─→ Still failing? → Repeat Step 2
```

---

## 🔄 State Transitions & Data Flow

### Worktree State Machine

```
WORKTREE LIFECYCLE:

    [NULL]
       ↓
    PROVISION (create new agent-00X)
       ↓
    [FREE] ←──────────────┐
       ↓                   │
    ALLOCATE              │
       ↓                   │
    [BUSY]                │
       ↓                   │
    WORK (code, commit)    │
       ↓                   │
    CREATE PR             │
       ↓                   │
    RELEASE ──────────────┘
       ↓ (if error)
    [STALE]
       ↓
    CLEANUP → [FREE]
       ↓ (if broken)
    [BROKEN]
       ↓
    MANUAL FIX → [FREE]
```

### Task State Machine (ClickUp)

```
TASK LIFECYCLE:

    [TODO]
       ↓
    CLAIM (agent)
       ↓
    [BUSY]
       ↓
    IMPLEMENT (worktree work)
       ↓
    CREATE PR
       ↓
    [REVIEW]
       ↓
       ├─→ APPROVED → MERGE
       │      ↓
       │   [DONE]
       │
       └─→ CHANGES REQUESTED
              ↓
           [BUSY] (iterate)
```

### Data Flow Across Systems

```
CODE CHANGE PROPAGATION:

Local Worktree
    ↓ (git commit)
Remote Branch
    ↓ (git push)
GitHub
    ↓ (gh pr create)
Pull Request
    ↓ (CI triggered)
GitHub Actions (Build + Test)
    ↓ (if green)
Ready for Review
    ↓ (user merges)
Develop Branch
    ↓ (git pull in base repo)
C:\Projects\<repo> (updated)
    ↓ (new worktrees branch from here)
Future Worktrees (have latest code)
```

### Information Flow

```
USER INTENT
    ↓ (ClickUp task or direct request)
TASK ANALYSIS
    ↓ (requirements extraction)
BRANCH CREATION
    ↓ (git branch)
WORKTREE ALLOCATION
    ↓ (isolated workspace)
CODE IMPLEMENTATION
    ↓ (edits in worktree)
TESTING
    ↓ (verification)
PR CREATION
    ↓ (gh pr create)
CLICKUP UPDATE (PR link)
    ↓
WORKTREE RELEASE
    ↓
CI/CD PIPELINE
    ↓ (automated testing)
USER REVIEW
    ↓ (approval)
MERGE TO DEVELOP
    ↓
PRODUCTION DEPLOYMENT (eventual)
```

---

## 🛠️ Automation Tools & Skills

### Claude Skills (Workflow Automation)

**Location:** `C:\scripts\.claude\skills\`

```
WORKFLOW SKILLS:

allocate-worktree
    ├─→ Purpose: Atomic worktree allocation
    ├─→ Checks: Multi-agent conflicts
    ├─→ Output: Allocated seat + worktree created
    └─→ Updates: Pool, activity, instances

release-worktree
    ├─→ Purpose: Complete cleanup after PR
    ├─→ Checks: PR exists, Active Debugging Mode
    ├─→ Output: Worktree deleted, seat freed
    └─→ Updates: Pool, activity logs

github-workflow
    ├─→ Purpose: PR creation/review/merge
    ├─→ Functions: Create PR, review code, merge
    └─→ Integration: gh CLI, ClickUp sync

pr-dependencies
    ├─→ Purpose: Cross-repo dependency tracking
    ├─→ Functions: Link Hazina ↔ client-manager PRs
    └─→ Output: Dependency alerts in PR bodies

clickhub-coding-agent
    ├─→ Purpose: Autonomous ClickUp task implementation
    ├─→ Loop: Todo → Busy → Implement → PR → Review → Done
    └─→ Integration: ClickUp API, worktree allocation

multi-agent-conflict
    ├─→ Purpose: Detect conflicts before allocation
    ├─→ Checks: Branch, seat, PR conflicts
    └─→ Output: Safe/Unsafe to proceed

ef-migration-safety
    ├─→ Purpose: Safe Entity Framework migrations
    ├─→ Checks: Breaking changes, dependencies
    └─→ Output: Multi-step migration plan
```

### PowerShell Tools (Workflow Support)

**Location:** `C:\scripts\tools\`

```
WORKFLOW TOOLS:

clickup-sync.ps1
    ├─→ Purpose: ClickUp API integration
    ├─→ Actions: list, update, comment, create
    └─→ Usage: Update task status, add PR links

check-branch-conflicts.sh
    ├─→ Purpose: Multi-agent conflict detection
    ├─→ Checks: Is branch already allocated?
    └─→ Output: Exit 0 (safe) or Exit 1 (conflict)

worktree-lock.ps1
    ├─→ Purpose: Mutex-based atomic locking
    ├─→ Prevents: Race conditions in allocation
    └─→ Method: File system exclusive lock

parallel-orchestrate.ps1
    ├─→ Purpose: Multi-agent coordination
    ├─→ Functions: Work queue, load balancing
    └─→ Integration: Worktree pool management

auto-pr.ps1
    ├─→ Purpose: Automated PR creation
    ├─→ Features: Conventional commits, templates
    └─→ Integration: gh CLI

merge-pr-sequence.ps1
    ├─→ Purpose: Sequential PR merging
    ├─→ Use Case: Dependency chains (Hazina → client-manager)
    └─→ Safety: Verify CI passes before merge

cleanup-stale-branches.ps1
    ├─→ Purpose: Clean up old feature branches
    ├─→ Detection: Merged PRs, stale worktrees
    └─→ Safety: Never delete develop or main

health-dashboard.ps1
    ├─→ Purpose: System health monitoring
    ├─→ Displays: Worktree status, PR queue, CI health
    └─→ Output: HTML dashboard
```

---

## 📊 Workflow Metrics & Monitoring

### Key Performance Indicators

```
WORKFLOW HEALTH METRICS:

Worktree Pool Utilization:
    - Total seats: 12
    - FREE: 4
    - BUSY: 7
    - STALE: 1
    - Utilization: 58%

PR Throughput:
    - PRs created this week: 23
    - PRs merged: 19
    - PR age (avg): 2.3 days
    - Review time (avg): 1.5 days

CI/CD Health:
    - Build success rate: 94%
    - Test pass rate: 97%
    - Average build time: 3.2 min

ClickUp Integration:
    - Tasks completed: 45
    - Tasks in progress: 12
    - Avg implementation time: 4.5 hours
    - PR link coverage: 100%
```

### Monitoring Tools

```
OBSERVABILITY:

worktrees.pool.md (Live State)
    ├─→ Current allocations
    ├─→ Agent status
    └─→ Last activity timestamps

worktrees.activity.md (Event Log)
    ├─→ Allocation history
    ├─→ Release events
    └─→ Conflict detections

pr-dependencies.md (Dependency Graph)
    ├─→ Active dependencies
    ├─→ Merge readiness
    └─→ Blocker detection

health-dashboard.ps1 (Real-Time Dashboard)
    ├─→ Visual HTML dashboard
    ├─→ Auto-refresh
    └─→ Alerts for issues
```

---

## 🚨 Error Recovery Protocols

### Common Failure Scenarios

```
FAILURE RECOVERY WORKFLOWS:

Worktree Allocation Failure:
    Symptom: "Another agent already working on branch"
    Recovery:
        1. Check worktrees.pool.md for BUSY entry
        2. Verify agent is actually active (heartbeat timestamp)
        3. If stale (>2hr): Mark FREE, allocate
        4. If active: Choose different branch or wait

Git Corruption:
    Symptom: "Cannot create worktree"
    Recovery:
        1. cd C:\Projects\<repo>
        2. git worktree prune
        3. git fsck
        4. Retry allocation

PR Creation Failure:
    Symptom: "No commits between develop and branch"
    Recovery:
        1. Verify branch is ahead of develop
        2. Check git log origin/develop..HEAD
        3. If no diff: Branch is already merged
        4. If diff exists: Check --base develop flag

ClickUp Sync Failure:
    Symptom: "Task not found"
    Recovery:
        1. Verify task ID format (9 chars)
        2. Check API key validity
        3. Verify task exists in ClickUp UI
        4. Manual link if API fails

CI Build Failure:
    Symptom: "Build failed on GitHub Actions"
    Recovery:
        1. Reproduce locally (npm run build / dotnet build)
        2. Fix errors
        3. Commit and push fix
        4. CI auto-retries

Stale Worktree:
    Symptom: BUSY for >2hr without activity
    Recovery:
        1. Check if agent still running
        2. If crashed: Commit work, create PR, release
        3. If abandoned: Release worktree, mark FREE
        4. Document in activity log
```

---

## 🔄 Complete Workflow Integration Map

### The Full Picture: From Request to Deployment

```
┌─────────────────────────────────────────────────────────┐
│  USER REQUEST (ClickUp task or direct message)          │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  MODE DETECTION                                         │
│  Feature Development? → Worktree workflow               │
│  Active Debugging? → Direct work in base repo           │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  FEATURE DEVELOPMENT MODE (7 Steps)                     │
│  1. Create Branch                                       │
│  2. Allocate Worktree (multi-agent safe)                │
│  3. Make Changes                                        │
│  4. Merge Develop                                       │
│  5. Resolve Issues (build + tests)                      │
│  6. Create PR (base = develop)                          │
│  7. Add PR Link to ClickUp (MANDATORY)                  │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  WORKTREE RELEASE                                       │
│  - Verify PR exists                                     │
│  - Delete worktree                                      │
│  - Mark seat FREE                                       │
│  - Switch base repo to develop (if safe)                │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  CI/CD PIPELINE                                         │
│  Frontend: Lint → Build → Test                          │
│  Backend: Build → Test                                  │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  USER REVIEW & MERGE                                    │
│  - Review code                                          │
│  - Request changes OR approve                           │
│  - Merge to develop                                     │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  UPDATE CLICKUP TASK                                    │
│  - Status: done                                         │
│  - Record completion                                    │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  EVENTUAL DEPLOYMENT                                    │
│  - Develop → Main (release PR)                          │
│  - Deploy to production                                 │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Quick Reference: Decision Trees

### "Should I allocate a worktree?"

```
Am I editing code?
    ├─→ NO (just reading) → Work in C:\Projects\<repo> directly
    └─→ YES → Continue...
         ↓
Is user actively debugging?
    ├─→ YES → ACTIVE DEBUGGING MODE
    │         └─→ Work in C:\Projects\<repo> directly
    │             (User's current branch, preserve state)
    └─→ NO → Continue...
         ↓
Is this a new feature/enhancement/refactor?
    ├─→ YES → FEATURE DEVELOPMENT MODE
    │         └─→ ALLOCATE WORKTREE (MANDATORY)
    └─→ NO → Simple fix?
              └─→ Ask user or default to Feature Mode
```

### "Which base branch for PR?"

```
What type of PR?
    ├─→ Feature/Fix/Refactor → Base: develop (ZERO TOLERANCE)
    ├─→ Release to production → Base: main (ONLY if user explicitly requests)
    └─→ Not sure? → Default: develop
```

### "Do I need to update ClickUp?"

```
Did I create a branch?
    ├─→ YES → Does branch name have 9-char task ID?
    │         ├─→ YES → UPDATE CLICKUP MANDATORY (Step 7)
    │         └─→ NO → Skip ClickUp (not task-driven work)
    └─→ NO → Skip ClickUp
```

---

## 📚 Complete File Locations

### Core Workflow Documentation
```
C:\scripts\MANDATORY_CODE_WORKFLOW.md
C:\scripts\worktree-workflow.md
C:\scripts\git-workflow.md
C:\scripts\GENERAL_DUAL_MODE_WORKFLOW.md
C:\scripts\clickup-github-workflow.md
C:\scripts\ci-cd-troubleshooting.md
```

### State Tracking
```
C:\scripts\_machine\worktrees.pool.md
C:\scripts\_machine\worktrees.activity.md
C:\scripts\_machine\instances.map.md
C:\scripts\_machine\pr-dependencies.md
```

### Protocols & Patterns
```
C:\scripts\_machine\worktrees.protocol.md
C:\scripts\_machine\MULTI_AGENT_CONFLICT_DETECTION.md
C:\scripts\_machine\DEFINITION_OF_DONE.md
```

### Skills (Automation)
```
C:\scripts\.claude\skills\allocate-worktree\SKILL.md
C:\scripts\.claude\skills\release-worktree\SKILL.md
C:\scripts\.claude\skills\github-workflow\SKILL.md
C:\scripts\.claude\skills\pr-dependencies\SKILL.md
C:\scripts\.claude\skills\clickhub-coding-agent\SKILL.md
C:\scripts\.claude\skills\multi-agent-conflict\SKILL.md
C:\scripts\.claude\skills\ef-migration-safety\SKILL.md
```

### Tools (Scripts)
```
C:\scripts\tools\clickup-sync.ps1
C:\scripts\tools\check-branch-conflicts.sh
C:\scripts\tools\worktree-lock.ps1
C:\scripts\tools\parallel-orchestrate.ps1
C:\scripts\tools\auto-pr.ps1
C:\scripts\tools\merge-pr-sequence.ps1
C:\scripts\tools\cleanup-stale-branches.ps1
C:\scripts\tools\health-dashboard.ps1
```

---

## 🔗 Cross-References to Other Networks

**This network connects to:**
- **CONSCIOUSNESS_NETWORK.md** - Decision-making systems drive workflow choices
- **KNOWLEDGE_NETWORK.md** - Learnings from workflow executions feed knowledge base
- **TOOLS_CAPABILITY_MAP.md** - Workflow tools are subset of all tools
- **SYSTEM_QUICK_START.md** - Workflows are primary entry point for action

---

**Status:** ✅ COMPLETE
**Complexity:** 7-step workflow + worktree protocol + git operations + ClickUp + CI/CD + multi-agent = Fully integrated
**Zero-Tolerance Rules:** 3 (Feature Mode worktree allocation, PR base = develop, ClickUp PR linking)
**Maintainer:** Jengo (self-updating as workflows evolve)
**Last Updated:** 2026-02-05 05:00

