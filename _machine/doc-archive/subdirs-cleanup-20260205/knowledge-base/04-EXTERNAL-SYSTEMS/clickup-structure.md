# ClickUp Workspace Structure & Integration Patterns

**Expert:** #32 - ClickUp API & Structure Specialist
**Created:** 2026-01-25
**Tags:** #clickup #project-management #integration #automation #api
**Related:** [[clickhub-coding-agent]], [[clickup-sync.ps1]], [[DEFINITION_OF_DONE_CLICKUP.md]]

---

## Overview

Complete documentation of ClickUp workspace structure, custom fields, task hierarchy, and integration patterns with Claude Agent development workflows.

**Primary Integration:** GigsHub Workspace → Brand Designer List → client-manager/hazina repositories

---

## 1. Workspace Structure

### 1.1 Workspace Hierarchy

```
ClickUp Workspaces (3 total)
│
├── Personal Workspace (9015747737)
│   ├── Managing our household (90152830188)
│   ├── Team Space (90152557872)
│   ├── Realtime Task Boards (90156079868)
│   └── Tax Administration (90156513478)
│
├── Furniture Website (9015748488)
│   ├── Martien de Jong (90152560438)
│   ├── Martien de Jong - Company (90153500783)
│   │   ├── Operations (90157505655)
│   │   ├── Sales (90157505633)
│   │   └── Projects (90157505784)
│   │       ├── Vera AI (Legacy) (901506248257) - 31 tasks
│   │       └── SocraNext (901511986511) - 3 tasks
│   └── the Nashipaes (90154132126)
│
└── **GigsHub Workspace (9012956001)** ⭐ PRIMARY
    ├── GigsHub (90123937819)
    └── **Team Tasks (90124247049)** ⭐ ACTIVE SPACE
        ├── **Internal (90126650982)** ⭐ DEVELOPMENT FOLDER
        │   └── **Brand Designer (901214097647)** ⭐ PRIMARY LIST
        │       └── ~100 tasks (client-manager + hazina)
        └── Clients (90126651004)
            ├── Vera AI (901211218614) - 104 tasks
            ├── wreckingball.ai (901211218756) - 19 tasks
            ├── CloudGrafo (901213168637) - 14 tasks
            └── Vloerenhuis (901213305955) - 33 tasks
```

### 1.2 Repository Mapping

**Configuration:** `C:\scripts\_machine\clickup-config.json`

| Repository | Workspace | List ID | List Name |
|------------|-----------|---------|-----------|
| **client-manager** | GigsHub | 901214097647 | Brand Designer |
| **hazina** | GigsHub | 901214097647 | Brand Designer |

**Branch Naming Convention:**
```bash
feature/<task-id>-<description>
# Example: feature/869bmj7gd-linkedin-import
```

---

## 2. Team Members & Assignment

### 2.1 Available Assignees

**Primary Team Members:**

| Name | User ID | Role | Email |
|------|---------|------|-------|
| **Martien de Jong** | `74525428` | Primary Developer/Reviewer | martien@wreckingball.ai |

**Assignment Rules:**

- **Default assignee:** `74525428` (Martien de Jong)
- **When to assign:**
  - ✅ **ALWAYS** when moving task to `busy` (implementation started)
  - ✅ **ALWAYS** when moving task to `review` (PR ready for acceptance test)
- **How to assign:**
  ```powershell
  C:/scripts/tools/clickup-sync.ps1 -Action update -TaskId "<task-id>" -Status "busy" -Assignee "74525428"
  ```

**To get team member IDs:**

```powershell
# List all workspace users
$headers = @{ Authorization = "pk_..." }
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/team" -Headers $headers

# Or check existing task assignees
C:/scripts/tools/clickup-sync.ps1 -Action show -TaskId "<task-id>"
```

---

## 3. Task Structure & Lifecycle

### 3.1 Task Status Workflow

**Available Statuses:**

| Status | Color | Purpose | Who Sets | Agent Action |
|--------|-------|---------|----------|--------------|
| **todo** | 🔵 Blue | Ready for implementation | User/Agent | Pick up for implementation |
| **busy** | 🟣 Purple | Agent working, branch/PR created | Agent | Set when starting work **+ ASSIGN** |
| **review** | 🟠 Orange | PR merged, ready for acceptance test | Agent (auto on PR merge) | Wait for user acceptance **+ ASSIGN** |
| **needs input** | 🟡 Yellow | Requires clarification from user | Agent | Post questions, block |
| **needs refinement** | 🟡 Yellow | Requires technical refinement | Agent/User | Analyze and refine |
| **next sprint** | ⚪ White | Backlog for future sprint | User | Skip (not current priority) |
| **blocked** | 🔴 Red | Cannot proceed (blocker exists) | Agent | Post blocker reason, skip |
| **done** | 🟢 Green | Acceptance test passed, complete | **USER ONLY** | Mark complete in ClickUp |
| **cancelled** | ⚫ Gray | No longer needed | User | Archive/ignore |

**Critical Rules:**
- ✅ Agent sets: `todo` → `busy` → `review`
- ❌ Agent **NEVER** sets: `done` (user acceptance required)
- ✅ Agent can set: `blocked`, `needs input` (with explanation)
- ✅ **NEW (2026-01-25):** Agent **ALWAYS** assigns task when moving to `busy` or `review`

### 3.2 Task Lifecycle Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    TASK LIFECYCLE                                │
└─────────────────────────────────────────────────────────────────┘

User Creates Task
      ↓
   [todo] ────────────────┐
      ↓                   │ (Agent posts questions)
Agent Picks Up            ↓
      ↓              [needs input] ──→ User answers
   [busy]                 ↓              ↓
      ↓              (Still unclear)  [todo]
Agent Creates PR          ↓
      ↓              [blocked] ──→ User resolves blocker
PR Merged                 ↓              ↓
      ↓                   └──────────→ [todo]
   [review] ──────────────┐
      ↓                   │ (Fails acceptance test)
User Tests                ↓
      ↓              [busy] ──→ Agent fixes
User Accepts              ↓
      ↓              [review] (retry)
   [done] ✅
```

### 3.3 Task Object Structure (API Response)

**Core Fields:**

```json
{
  "id": "869bmj7gd",                    // Unique task ID
  "custom_id": null,                     // Custom task number (if set)
  "custom_item_id": 0,
  "name": "configure linkedin for social media import",
  "text_content": "Full markdown description...",
  "description": "Full HTML description...",

  "status": {
    "id": "p901214097647_gQDCuVGi",
    "status": "todo",                    // Current status
    "color": "#d3d3d3",
    "orderindex": 0,
    "type": "open"
  },

  "orderindex": "3373.00000000000000000000",
  "date_created": "1737743471991",      // Unix timestamp (ms)
  "date_updated": "1737777956612",      // Unix timestamp (ms)
  "date_closed": null,
  "date_done": null,

  "archived": false,
  "creator": {
    "id": 74525428,
    "username": "Martien de Jong",
    "color": "#b5739d",
    "email": "martien@wreckingball.ai",
    "profilePicture": "https://..."
  },

  "assignees": [],                      // Array of user objects
  "watchers": [],                       // Array of user objects
  "checklists": [],                     // Subtask checklists
  "tags": [],                           // Labels/tags
  "parent": null,                       // Parent task ID (if subtask)
  "priority": null,                     // Priority object
  "due_date": null,                     // Unix timestamp (ms)
  "start_date": null,
  "points": null,                       // Story points
  "time_estimate": null,                // Estimated time (ms)
  "time_spent": 0,                      // Tracked time (ms)

  "custom_fields": [],                  // Array of custom field values

  "dependencies": [],                   // Blocking/blocked by tasks
  "linked_tasks": [],                   // Related tasks

  "team_id": "9012956001",
  "url": "https://app.clickup.com/t/869bmj7gd",
  "sharing": { "public": false },
  "permission_level": "create",

  "list": {
    "id": "901214097647",
    "name": "Brand Designer",
    "access": true
  },
  "project": {
    "id": "90126650982",
    "name": "Internal",
    "hidden": false,
    "access": true
  },
  "folder": {
    "id": "90126650982",
    "name": "Internal",
    "hidden": false,
    "access": true
  },
  "space": {
    "id": "90124247049"
  }
}
```

**Key Field Usage:**

| Field | Purpose | Agent Usage |
|-------|---------|-------------|
| `id` | Unique identifier | Task tracking, API calls |
| `name` | Task title | Branch naming, commit messages |
| `text_content` | Markdown description | Requirements analysis |
| `status.status` | Current state | Workflow decisions |
| `date_updated` | Last modified | Staleness detection |
| `assignees` | Who's working on it | Task picking (prefer unassigned) |
| `url` | ClickUp link | PR descriptions, comments |
| `custom_fields` | Extended metadata | Priority, labels, custom data |

---

## 4. Custom Fields

### 3.1 Standard Custom Fields (Brand Designer List)

**Note:** The Brand Designer list (901214097647) currently uses **status-based workflow** rather than custom fields for most metadata. Custom fields can be added via ClickUp UI.

**Common Custom Fields (Recommended):**

| Field Name | Field Type | Purpose | Values |
|------------|------------|---------|--------|
| **Priority** | Dropdown | Task urgency | P0 (Critical), P1 (High), P2 (Medium), P3 (Low) |
| **Epic** | Relationship | Feature grouping | Social Media Integrations, AI Prompting, Unified Content |
| **Story Points** | Number | Complexity estimate | 1, 2, 3, 5, 8, 13 (Fibonacci) |
| **Blocked Reason** | Text | Why task is blocked | Waiting for X, Need Y, Depends on Z |
| **PR Number** | Number | GitHub PR link | Auto-filled by agent |
| **Technical Debt** | Checkbox | Mark as tech debt | True/False |
| **Repository** | Dropdown | Target repo | client-manager, hazina, both |

**Adding Custom Fields:**

1. Go to ClickUp → Brand Designer list
2. Click "..." → "Customize" → "Custom Fields"
3. Add fields as needed
4. Update `clickup-sync.ps1` to read/write custom fields

### 3.2 Accessing Custom Fields via API

**Read Custom Fields:**

```powershell
# Get task with custom fields
$task = Invoke-RestMethod -Uri "$apiBase/task/$TaskId" -Headers $headers
$customFields = $task.custom_fields

# Example: Get Priority custom field
$priorityField = $customFields | Where-Object { $_.name -eq "Priority" }
$priorityValue = $priorityField.value  # "P1", "P2", etc.
```

**Update Custom Fields:**

```powershell
# Set custom field value
$url = "$apiBase/task/$TaskId/field/$FieldId"
$body = @{ value = "P1" } | ConvertTo-Json
Invoke-RestMethod -Method POST -Uri $url -Headers $headers -Body $body
```

---

## 5. Task Templates & Patterns

### 4.1 Common Task Patterns

**Pattern 1: Feature Implementation**

```markdown
# Task Template: Feature Implementation

## Requirements
- User story: As a [role], I want [feature] so that [benefit]
- Acceptance criteria:
  - [ ] Criterion 1
  - [ ] Criterion 2
  - [ ] Criterion 3

## Technical Approach
- Backend: [API endpoint, service, repository]
- Frontend: [Component, page, integration]
- Database: [Migration, new tables/fields]

## Test Plan
- [ ] Unit tests (backend)
- [ ] Integration tests
- [ ] E2E tests (frontend)
- [ ] Manual testing steps

## Dependencies
- Depends on: [Task ID or description]
- Blocks: [Task ID or description]

## Definition of Done
- [ ] Code implemented
- [ ] Tests passing
- [ ] PR merged
- [ ] Deployed to production
- [ ] Acceptance test passed
```

**Pattern 2: Bug Fix**

```markdown
# Task Template: Bug Fix

## Bug Description
- What's broken: [Describe the issue]
- Steps to reproduce:
  1. Step 1
  2. Step 2
  3. Expected vs Actual result

## Root Cause Analysis
- Cause: [What caused the bug]
- Affected code: [File/component]

## Fix Approach
- Solution: [How to fix it]
- Impact: [What else might be affected]

## Test Plan
- [ ] Bug no longer reproducible
- [ ] Regression tests pass
- [ ] Manual verification
```

**Pattern 3: Social Media Integration**

```markdown
# Task Template: Social Media Integration

## Platform
- Platform: [LinkedIn, Twitter, Instagram, etc.]
- API Version: [v2, v1.1, Graph API, etc.]

## OAuth Configuration
- Client ID: [From developer portal]
- Client Secret: [In appsettings.Secrets.json]
- Redirect URL: https://localhost:5173/social-callback
- Scopes Required: [read_profile, read_posts, etc.]

## Implementation Checklist
- [ ] Developer portal configured
- [ ] Backend OAuth service
- [ ] Frontend social button
- [ ] Import posts endpoint
- [ ] Error handling
- [ ] User mapping (social account → project)

## Test Plan
- [ ] OAuth flow works
- [ ] Posts imported successfully
- [ ] Error states handled
- [ ] User experience smooth
```

### 5.2 Required Task Fields

**Minimum Required for Agent Implementation:**

| Field | Requirement | Why |
|-------|-------------|-----|
| **Name** | Clear, concise title | Branch naming, PR title |
| **Description** | Detailed requirements | Agent understanding |
| **Acceptance Criteria** | ≥3 bullet points | Definition of done |
| **Status** | Set to `todo` | Agent task picking |

**Recommended Additional Fields:**

| Field | Benefit |
|-------|---------|
| Technical approach | Guides implementation |
| Dependencies | Prevents blocking issues |
| Test plan | Ensures quality |
| Screenshots/mockups | UI clarity |

---

## 5. Integration with Development Workflow

### 5.1 PR → ClickUp Task Linking

**Automatic Linking (via `clickup-sync.ps1`):**

```powershell
# When PR is created
clickup-sync.ps1 -Action link-pr -TaskId "869bmj7gd" -PrNumber 267

# What happens:
# 1. Post comment on ClickUp task: "GitHub PR #267: https://github.com/..."
# 2. Task remains in "busy" status (PR not yet merged)
```

**When PR is Merged:**

```powershell
# Agent calls after PR merge
clickup-sync.ps1 -Action pr-merged -TaskId "869bmj7gd" -PrNumber 267

# What happens:
# 1. Update task status to "review"
# 2. Post comment: "PR #267 merged - Ready for acceptance test"
# 3. User tests and sets status to "done"
```

### 6.2 Branch Naming → Task ID Convention

**Format:**
```bash
feature/<task-id>-<short-description>
# Example: feature/869bmj7gd-linkedin-import
```

**Parsing Task ID from Branch:**

```powershell
# Extract task ID from branch name
$branch = git branch --show-current
if ($branch -match '^feature/([0-9a-z]+)-') {
    $taskId = $matches[1]
    Write-Host "Task ID: $taskId"
}
```

### 5.3 Status Synchronization

**Agent → ClickUp:**

```powershell
# Update task status based on agent action
switch ($agentAction) {
    "start_work"   { clickup-sync.ps1 -Action update -TaskId $id -Status "busy" }
    "post_questions" { clickup-sync.ps1 -Action update -TaskId $id -Status "needs input" }
    "blocked"      { clickup-sync.ps1 -Action update -TaskId $id -Status "blocked" }
    "pr_created"   { # Status remains "busy" until merged }
    "pr_merged"    { clickup-sync.ps1 -Action pr-merged -TaskId $id -PrNumber $pr }
}
```

**ClickUp → Agent (via polling):**

```powershell
# Agent checks ClickUp for task updates every 10 minutes
clickup-sync.ps1 -Action list | Where-Object { $_.status -eq "todo" -and $_.assignees.Count -eq 0 }
```

### 6.4 Comment Automation

**Agent Posts Comments for:**

1. **Questions/Uncertainties:**
```powershell
$comment = @"
QUESTIONS BEFORE IMPLEMENTATION:

1. [Architecture] Should we use Repository pattern or direct DbContext access?
2. [UI/UX] Should the modal be full-screen or centered overlay?
3. [Business Logic] What happens if user has no active subscription?

Please clarify before I proceed with implementation.

-- ClickHub Coding Agent
"@

clickup-sync.ps1 -Action comment -TaskId $id -Comment $comment
```

2. **Implementation Progress:**
```powershell
$comment = @"
IMPLEMENTATION STARTED

Branch: feature/869bmj7gd-linkedin-import
Worktree: agent-002
Approach: OAuth2 flow with LinkedIn API v2

-- ClickHub Coding Agent
"@
```

3. **Duplicate Detection:**
```powershell
$comment = @"
DUPLICATE TASK DETECTED

This task appears to be a duplicate of:
- Task ID: 869abc123
- Task Name: "Google OAuth integration"
- Task URL: https://app.clickup.com/t/869abc123

Recommend closing this task and working on the master task instead.

-- ClickHub Coding Agent
"@
```

4. **PR Links:**
```powershell
# Automatically posted by link-pr action
"GitHub PR #267: https://github.com/martiendejong/client-manager/pull/267"
```

---

## 6. ClickHub Coding Agent Integration

### 6.1 Autonomous Agent Workflow

**Skill:** `.claude\skills\clickhub-coding-agent\SKILL.md`

**Agent Operating Loop:**

```
Loop Forever:
  1. Fetch unassigned tasks (status: todo, needs input, blocked)
  2. Analyze each task:
     a. Check for duplicates
     b. Identify uncertainties
     c. Search existing code/branches
  3. Handle duplicates:
     - Post comment identifying master task
     - Move to blocked
  4. Handle uncertainties:
     - Post questions as comment
     - Move to "needs input" or "blocked"
  5. Handle previously blocked tasks:
     - READ user replies carefully
     - If 80%+ info available → proceed with assumptions
     - Only re-block if truly impossible to proceed
  6. Implement TODO tasks:
     a. Allocate worktree
     b. Update status to "busy"
     c. Implement code
     d. Create PR
     e. Link PR to task
     f. Release worktree
  7. Sleep 10 minutes
  8. Repeat
End Loop
```

### 6.2 Task Picking Logic

**Priority Order:**

1. **High Priority TODOs** (P0, P1) - unassigned, status=todo
2. **Needs Input with Answers** - status=needs_input, has new comments
3. **Blocked with Resolutions** - status=blocked, blocker resolved
4. **Standard TODOs** (P2, P3) - unassigned, status=todo

**Exclusion Criteria:**

- ❌ Already assigned to someone
- ❌ Status = done, cancelled
- ❌ Missing description
- ❌ Blocked without resolution
- ❌ User explicitly marked "do not automate"

### 7.3 Question Posting Protocol

**When to Post Questions:**

✅ **DO post questions if:**
- Multiple implementation approaches exist (need user preference)
- UI/UX design decisions required (layout, colors, flow)
- Business logic unclear (edge cases, validation rules)
- Security/privacy implications (data access, permissions)
- Breaking changes possible (API changes, migrations)

❌ **DON'T post questions if:**
- Standard pattern exists in codebase
- Answer inferable from existing code
- Minor implementation detail (can be adjusted in PR review)
- Aesthetic preference (use existing theme)

**Anti-Loop Protocol (CRITICAL):**

When encountering a **blocked** task with previous agent questions:

1. **READ comment history carefully**
2. **Check if user replied with answers**
3. **If answered:**
   - ✅ Proceed with implementation (document assumptions)
   - ✅ Move to `busy` status
   - ❌ **NEVER** silently re-block
4. **If still unclear:**
   - ✅ Post **specific follow-up** questions
   - ✅ Explain **why** still blocked
   - ✅ Show you read previous replies

**User Directive (2026-01-20):**
> "When you see a task that you moved to blocked and someone replied with a comment to your questions, then don't move it back into blocked without at least saying why you absolutely cannot continue without having these questions answered."

**Philosophy:** Bias toward action, not paralysis. Users prefer iterations over perfection.

### 7.4 Assumption Documentation

**When Proceeding with Partial Information:**

```powershell
$comment = @"
PROCEEDING WITH IMPLEMENTATION:

Based on your answers, I'm implementing with these assumptions:
- [Assumption 1]: Using centered modal (standard pattern for this app)
- [Assumption 2]: Repository pattern (consistent with existing code)
- [Assumption 3]: User without subscription sees upgrade prompt

If any of these assumptions are incorrect, the implementation can be adjusted in PR review.

Moving to 'busy' status.

-- ClickHub Coding Agent
"@

clickup-sync.ps1 -Action comment -TaskId $id -Comment $comment
clickup-sync.ps1 -Action update -TaskId $id -Status "busy"
```

---

## 7. API Usage Patterns

### 7.1 API Configuration

**API Credentials:**

- **Location:** `C:\scripts\_machine\clickup-config.json`
- **API Key:** `pk_74525428_TXT8V1QUA13N7SCRM0UUM6WNQO2I2NML`
- **Base URL:** `https://api.clickup.com/api/v2`

**Headers:**

```powershell
$headers = @{
    Authorization = "pk_74525428_TXT8V1QUA13N7SCRM0UUM6WNQO2I2NML"
    "Content-Type" = "application/json"
}
```

### 7.2 Common API Calls

**List Tasks:**

```powershell
# Get all open tasks from Brand Designer list
$listId = "901214097647"
$url = "$apiBase/list/$listId/task?archived=false&include_closed=false"
$response = Invoke-RestMethod -Uri $url -Headers $headers
$tasks = $response.tasks
```

**Filter by Status:**

```powershell
# Get TODO tasks only
$url = "$apiBase/list/$listId/task?archived=false&statuses[]=todo"

# Get multiple statuses
$url = "$apiBase/list/$listId/task?archived=false&statuses[]=todo&statuses[]=busy"
```

**Get Single Task:**

```powershell
# Get full task details
$taskId = "869bmj7gd"
$url = "$apiBase/task/$taskId"
$task = Invoke-RestMethod -Uri $url -Headers $headers
```

**Update Task Status:**

```powershell
$url = "$apiBase/task/$taskId"
$body = @{ status = "busy" } | ConvertTo-Json
$task = Invoke-RestMethod -Method PUT -Uri $url -Headers $headers -Body $body
```

**Add Comment:**

```powershell
$url = "$apiBase/task/$taskId/comment"
$body = @{ comment_text = "PR #267 created" } | ConvertTo-Json
Invoke-RestMethod -Method POST -Uri $url -Headers $headers -Body $body
```

**Create Task:**

```powershell
$url = "$apiBase/list/$listId/task"
$body = @{
    name = "Task name"
    description = "Task description (markdown or HTML)"
    status = "todo"
} | ConvertTo-Json
$task = Invoke-RestMethod -Method POST -Uri $url -Headers $headers -Body $body
```

### 8.3 Rate Limits & Error Handling

**Rate Limits:**

- **Free Tier:** 100 requests/minute
- **Paid Tier:** 10,000 requests/hour
- **Current:** Unknown tier (assume 100/min)

**Best Practices:**

```powershell
# Add delay between API calls
Start-Sleep -Milliseconds 500

# Batch operations where possible
$tasks = Invoke-RestMethod -Uri "$apiBase/list/$listId/task" -Headers $headers
# Process all tasks in memory before making next API call

# Retry on 429 (rate limit)
$maxRetries = 3
$retryCount = 0
do {
    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers
        break
    } catch {
        if ($_.Exception.Response.StatusCode -eq 429) {
            $retryCount++
            Start-Sleep -Seconds (5 * $retryCount)  # Exponential backoff
        } else {
            throw
        }
    }
} while ($retryCount -lt $maxRetries)
```

**Error Handling:**

```powershell
try {
    $task = Invoke-RestMethod -Uri "$apiBase/task/$taskId" -Headers $headers
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorMessage = $_.Exception.Message

    switch ($statusCode) {
        401 { Write-Error "Unauthorized - check API key" }
        404 { Write-Error "Task not found: $taskId" }
        429 { Write-Error "Rate limit exceeded - retry later" }
        500 { Write-Error "ClickUp API error - try again" }
        default { Write-Error "API error: $errorMessage" }
    }
}
```

---

## 9. Automation Workflows

### 9.1 `clickup-sync.ps1` Tool

**Location:** `C:\scripts\tools\clickup-sync.ps1`

**Available Actions:**

| Action | Parameters | Purpose |
|--------|------------|---------|
| `list` | None | List all open tasks from Brand Designer |
| `show` | `-TaskId` | Show full task details |
| `update` | `-TaskId -Status [-Assignee]` | Update task status (and optionally assign) |
| `comment` | `-TaskId -Comment` | Add comment to task |
| `create` | `-Name -Description` | Create new task |
| `link-pr` | `-TaskId -PrNumber` | Link GitHub PR to task |
| `pr-merged` | `-TaskId -PrNumber` | Mark PR as merged, move to review |

**Usage Examples:**

```powershell
# List all tasks
C:/scripts/tools/clickup-sync.ps1 -Action list

# Show task details
C:/scripts/tools/clickup-sync.ps1 -Action show -TaskId "869bmj7gd"

# Update status
C:/scripts/tools/clickup-sync.ps1 -Action update -TaskId "869bmj7gd" -Status "busy"

# Update status AND assign (REQUIRED when moving to busy/review)
C:/scripts/tools/clickup-sync.ps1 -Action update -TaskId "869bmj7gd" -Status "busy" -Assignee "74525428"

# Add comment
C:/scripts/tools/clickup-sync.ps1 -Action comment -TaskId "869bmj7gd" -Comment "PR #267 created"

# Create task
C:/scripts/tools/clickup-sync.ps1 -Action create -Name "Fix login bug" -Description "Details here"

# Link PR
C:/scripts/tools/clickup-sync.ps1 -Action link-pr -TaskId "869bmj7gd" -PrNumber 267

# PR merged (auto-update to review)
C:/scripts/tools/clickup-sync.ps1 -Action pr-merged -TaskId "869bmj7gd" -PrNumber 267
```

### 8.2 ClickHub Autonomous Agent

**Continuous Operation:**

```powershell
# Start ClickHub agent (runs indefinitely)
# Agent will:
# - Fetch tasks every 10 minutes
# - Analyze and post questions
# - Implement TODO tasks
# - Create PRs
# - Sleep and repeat

# Safety: Create stop flag to terminate gracefully
New-Item -Path "C:/scripts/_machine/clickhub-stop.flag" -ItemType File
```

**Activity Log:**

- **Location:** `C:\scripts\_machine\clickhub-activity.log`
- **Format:**
```
2026-01-19T12:00:00Z | CYCLE_START | 12 unassigned tasks found
2026-01-19T12:01:30Z | ANALYZE | Task 869abc123 | Questions posted, moved to blocked
2026-01-19T12:03:00Z | IMPLEMENT | Task 869def456 | Worktree allocated: agent-002
2026-01-19T12:15:00Z | PR_CREATED | Task 869def456 | PR #157 | Worktree released
2026-01-19T12:16:00Z | CYCLE_END | 2 tasks processed, sleeping 600s
```

### 8.3 Webhooks (Future Enhancement)

**Potential Webhooks:**

- Task status changed → Trigger agent analysis
- Task assigned → Notify assignee
- Task commented → Check if agent question answered
- PR merged → Auto-update ClickUp task

**Configuration:**

```json
{
  "webhook_url": "https://your-server.com/clickup-webhook",
  "events": ["taskStatusUpdated", "taskCommentPosted"],
  "list_id": "901214097647"
}
```

---

## 10. Dashboard & Metrics

### 9.1 ClickUp Dashboard Setup

**Document:** `C:\scripts\_machine\clickup-dashboard-setup.md`

**Key Widgets:**

1. **🚨 Blocked Items** (Critical alert)
2. **👀 Review Queue** (SLA tracking)
3. **📊 Sprint Velocity** (Trend chart)
4. **👥 Team Workload** (WIP limits)
5. **🎯 Epic Progress** (Feature completion)
6. **📋 Sprint Kanban** (Task board)
7. **✅ Completed This Week** (Achievements)

**Dashboard URL:** https://app.clickup.com/9012956001/dashboards

### 9.2 Metrics Tracked

**Sprint Health:**
- Velocity: Tasks completed per week (Target: >40)
- Cycle Time: Days from busy → done (Target: ≤3 days)
- Lead Time: Days from todo → done (Target: ≤5 days)

**Flow Efficiency:**
- WIP per agent: Active tasks (Target: ≤3)
- Blocked items: Tasks stuck (Target: ≤2)
- Review queue: Tasks waiting acceptance (Target: ≤5)

**Quality:**
- Bug escape rate: Bugs found in production (Target: <10%)
- PR approval rate: PRs approved without changes (Target: >80%)
- Acceptance test pass rate: Tasks passing first test (Target: >90%)

---

## 10. Integration with Claude Agent

### 11.1 Mode Detection

**ClickUp URL = Feature Development Mode (HARD RULE)**

```powershell
# Use detect-mode.ps1 to prevent violations
detect-mode.ps1 -UserMessage $userRequest -Analyze

# If ClickUp URL detected → ALWAYS Feature Development Mode
# - Allocate worktree
# - Work in C:/Projects/worker-agents/agent-XXX/
# - Never edit C:/Projects/ directly
```

### 10.2 Definition of Done

**Document:** `C:\scripts\_machine\DEFINITION_OF_DONE_CLICKUP.md`

**Checklist:**

- [ ] Branch created from `develop`
- [ ] Code implemented
- [ ] Tests passing
- [ ] PR created with ClickUp task link
- [ ] PR merged to `develop`
- [ ] ClickUp task updated to `review`
- [ ] User acceptance test passed
- [ ] ClickUp task set to `done` (by user)
- [ ] Reflection log updated

### 11.3 Worktree Coordination

**When Implementing ClickUp Task:**

1. ✅ Check worktree pool availability
2. ✅ Allocate paired worktrees (client-manager + hazina if needed)
3. ✅ Mark seat BUSY in pool
4. ✅ Update ClickUp task to "busy"
5. ✅ Work in worktree
6. ✅ Create PR
7. ✅ Link PR to ClickUp task
8. ✅ Update ClickUp task to "review"
9. ✅ Release worktree
10. ✅ Mark seat FREE in pool

### 10.4 Cross-Repo Dependencies

**Pattern:** Feature requires changes in both client-manager and hazina

1. ✅ Create matching branches in both repos
2. ✅ Allocate paired worktrees
3. ✅ Implement changes in both repos
4. ✅ Create PRs for both (same PR number sequence)
5. ✅ Link **both** PRs to ClickUp task
6. ✅ Document dependency in PR descriptions
7. ✅ Merge hazina PR first, then client-manager
8. ✅ Update ClickUp task to "review" after both merged

---

## 12. Troubleshooting

### 12.1 Common Issues

**Issue: API Key Invalid**

```powershell
# Symptom: 401 Unauthorized
# Solution: Check C:\scripts\_machine\clickup-config.json
# Verify api_key is correct
```

**Issue: Task Not Found**

```powershell
# Symptom: 404 Not Found
# Cause: Task ID incorrect or task deleted
# Solution: List tasks to verify ID exists
clickup-sync.ps1 -Action list | Where-Object { $_.id -like "*869*" }
```

**Issue: Rate Limit Exceeded**

```powershell
# Symptom: 429 Too Many Requests
# Cause: Too many API calls in short time
# Solution: Add delays between calls
Start-Sleep -Milliseconds 500
```

**Issue: Agent Blocks Task Repeatedly**

```powershell
# Symptom: Task keeps getting blocked despite user answers
# Cause: Agent not reading previous comments
# Solution: Check comment history, apply anti-loop protocol
# Read: .claude\skills\clickhub-coding-agent\SKILL.md § Anti-Loop Protocol
```

**Issue: ClickUp Task Not Updating**

```powershell
# Symptom: Status change doesn't persist
# Cause: Invalid status name or API error
# Solution: Verify status names match ClickUp list configuration
# Valid statuses: todo, busy, review, needs input, blocked, done, cancelled
```

### 11.2 Debugging Tools

**List All Tasks with Status:**

```powershell
clickup-sync.ps1 -Action list | Select-Object ID, Name, Status, Updated | Format-Table -AutoSize
```

**Show Full Task JSON:**

```powershell
$taskId = "869bmj7gd"
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers @{Authorization="pk_..."} | ConvertTo-Json -Depth 10
```

**Check API Connectivity:**

```powershell
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/team" -Headers @{Authorization="pk_..."}
```

---

## 13. Best Practices

### 13.1 Task Creation

✅ **DO:**
- Write clear, concise task titles
- Include detailed requirements in description
- Add acceptance criteria (≥3 bullets)
- Set realistic due dates
- Tag with relevant labels
- Link to related tasks/PRs

❌ **DON'T:**
- Create vague tasks ("Fix stuff")
- Duplicate existing tasks
- Leave description empty
- Skip acceptance criteria
- Ignore dependencies

### 12.2 Agent Implementation

✅ **DO:**
- Post questions early if unclear
- Document assumptions when proceeding
- Link PRs to tasks immediately
- Update status accurately
- Release worktrees after PR creation
- Read user replies carefully

❌ **DON'T:**
- Implement without understanding
- Ignore user comments/answers
- Silently re-block tasks
- Skip testing
- Leave tasks in "busy" indefinitely
- Forget to update status

### 13.3 User Responsibilities

✅ **DO:**
- Answer agent questions promptly
- Review PRs within 48 hours (SLA)
- Perform acceptance tests
- Set tasks to "done" after acceptance
- Provide clear feedback on PRs

❌ **DON'T:**
- Ignore agent questions
- Delay PR reviews >2 days
- Skip acceptance testing
- Assume "merged = done"
- Change requirements mid-implementation

---

## 14. Future Enhancements

### 13.1 Planned Features

**Phase 1: Enhanced Automation**
- [ ] Webhook integration (real-time updates)
- [ ] Auto-assign tasks based on agent availability
- [ ] Custom field automation (auto-populate PR number)
- [ ] Time tracking integration

**Phase 2: Intelligence**
- [ ] Task priority prediction (ML model)
- [ ] Complexity estimation (story points auto-suggest)
- [ ] Duplicate detection (semantic similarity)
- [ ] Blocker prediction (dependency analysis)

**Phase 3: Reporting**
- [ ] Weekly sprint summary (auto-generated)
- [ ] Team velocity dashboard (real-time)
- [ ] Burndown chart automation
- [ ] Cycle time trends

### 13.2 Tool Wishlist

**From `daily-tool-review.ps1`:**

- `clickup-pr-sync.ps1` - Bi-directional sync (GitHub ↔ ClickUp)
- `clickup-sprint-planner.ps1` - AI-powered sprint planning
- `clickup-blocker-analyzer.ps1` - Analyze blocked tasks, suggest resolutions
- `clickup-task-duplicator.ps1` - Smart duplicate detection

---

## 14. Related Documentation

**Core Documents:**
- `C:\scripts\.claude\skills\clickhub-coding-agent\SKILL.md` - Autonomous agent workflow
- `C:\scripts\_machine\DEFINITION_OF_DONE_CLICKUP.md` - Task completion checklist
- `C:\scripts\_machine\clickup-dashboard-setup.md` - Dashboard configuration
- `C:\scripts\tools\clickup-sync.ps1` - API integration tool

**Workflows:**
- `C:\scripts\GENERAL_DUAL_MODE_WORKFLOW.md` - Mode detection (ClickUp → Feature Mode)
- `C:\scripts\GENERAL_WORKTREE_PROTOCOL.md` - Worktree allocation for ClickUp tasks
- `C:\scripts\_machine\DEFINITION_OF_DONE.md` - General DoD (all projects)

**Reflection Log Entries:**
- 2026-01-19 13:00 - ClickHub Coding Agent - First autonomous cycle
- 2026-01-19 14:30 - ClickHub Cycle #2 - Duplicate detection patterns
- 2026-01-20 01:35 - ClickHub Cycle #10 - Dashboard setup guide

---

## 15. Quick Reference

### 15.1 Key URLs

| Resource | URL |
|----------|-----|
| **ClickUp Workspace** | https://app.clickup.com/9012956001 |
| **Brand Designer List** | https://app.clickup.com/9012956001/v/li/901214097647 |
| **API Documentation** | https://clickup.com/api/clickupreference/operation/GetTasks/ |
| **Developer Portal** | https://app.clickup.com/settings/apps |

### 15.2 Key IDs

| Resource | ID |
|----------|-----|
| **GigsHub Workspace** | 9012956001 |
| **Team Tasks Space** | 90124247049 |
| **Internal Folder** | 90126650982 |
| **Brand Designer List** | 901214097647 |

### 15.3 Key Commands

```powershell
# List all tasks
clickup-sync.ps1 -Action list

# Show task details
clickup-sync.ps1 -Action show -TaskId "869bmj7gd"

# Update status
clickup-sync.ps1 -Action update -TaskId "869bmj7gd" -Status "busy"

# Add comment
clickup-sync.ps1 -Action comment -TaskId "869bmj7gd" -Comment "..."

# Link PR
clickup-sync.ps1 -Action link-pr -TaskId "869bmj7gd" -PrNumber 267

# PR merged
clickup-sync.ps1 -Action pr-merged -TaskId "869bmj7gd" -PrNumber 267
```

---

**Document Status:** ✅ COMPLETE
**Last Updated:** 2026-01-25
**Next Review:** 2026-02-01
**Maintainer:** Claude Agent (Expert #32)

