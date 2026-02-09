# ClickUp Reviewer Workflow

**Created:** 2026-02-07
**Updated:** 2026-02-09 (Full merge workflow)
**Purpose:** Automated code review AND merge workflow for ClickUp tasks in "review" status
**Invocation:** "ga reviewen" or "run the clickup reviewer" or "review clickup tasks"

---

## Overview

The ClickUp Reviewer is a COMPLETE automated review-to-merge workflow that:
1. Identifies ClickUp tasks in "review" status
2. Locates linked Pull Requests
3. Analyzes code changes
4. Posts comprehensive review comments
5. **Merges develop into PR branch** (if not already merged)
6. **Builds and tests locally** (NOT GitHub CI - we skip that deliberately)
7. **Merges PR into develop** (if tests pass)
8. **Builds develop branch** (verify integration)
9. **Updates task status** (to "testing" or "done" depending on project)

**CRITICAL:** This is the STANDARD workflow. User should only need to say "ga reviewen" to trigger the entire process.

## When to Use

**Primary Invocation (STANDARD):**
- User says: **"ga reviewen"** (Dutch - most common)
- User says: "run the clickup reviewer"
- User says: "review clickup tasks"

**This triggers the COMPLETE workflow:**
1. Find all tasks in "review" status (all projects)
2. Locate PRs
3. Review code
4. Merge develop into branch (if needed)
5. Build & test locally
6. Merge into develop (if not already)
7. Build develop
8. Post review comments
9. Update task status

**User Expectation:**
"ga reviewen" should be ENOUGH to trigger the entire review-to-merge workflow. No need for detailed instructions.

## Workflow Steps (COMPLETE REVIEW-TO-MERGE)

### 1. Identify Review Tasks

```powershell
# For each project
C:\scripts\tools\clickup-sync.ps1 -Action list -Project "hazina"
C:\scripts\tools\clickup-sync.ps1 -Action list -Project "client-manager"
C:\scripts\tools\clickup-sync.ps1 -Action list -Project "art-revisionist"
```

Filter for tasks with status="review"

### 2. For Each Task - Find PR

#### A. Get Task Details
```powershell
C:\scripts\tools\clickup-sync.ps1 -Action show -TaskId "<task-id>"
```

#### B. Find Linked PR

**Search GitHub for PRs with task ID:**
```bash
cd <repo-path>
gh pr list --state all --limit 30 --json number,title,state,headRefName,body \
  --jq ".[] | select(.body | contains(\"<task-id>\")) | {number, title, state, branch: .headRefName}"
```

### 3. Analyze PR & Review Code

#### A. Get PR Details
```bash
gh pr view <pr-number> --json title,body,files,state,mergedAt
```

#### B. Check PR State

**IF PR is OPEN:**
→ Continue to Step 4 (Merge develop into branch)

**IF PR is MERGED:**
→ Skip to Step 7 (Build develop branch)

**IF PR not found:**
→ Post "No PR found" comment, suggest creating PR or moving to "to do"

### 4. Merge Develop into PR Branch (if PR is OPEN)

**CRITICAL:** Always merge develop into the PR branch BEFORE approving/merging to prevent conflicts.

```bash
cd <repo-path>
git checkout <pr-branch>
git pull origin develop --no-edit
# Resolve any conflicts if they occur
git push
```

**If conflicts occur:**
- Post comment on task: "Merge conflicts detected, needs manual resolution"
- Update task status to "to do"
- STOP workflow for this task

### 5. Build & Test Locally (NO GitHub CI)

**IMPORTANT:** We deliberately skip GitHub CI. Only local builds matter.

#### Backend Build
```bash
cd <repo-path>
dotnet build <project>.csproj -c Release
```

**Success criteria:** 0 errors (warnings are acceptable)

#### Frontend Build (if applicable)
```bash
cd <frontend-path>
npm run build
```

**Success criteria:** Build completes without errors

**If build fails:**
- Post comment on task with build errors
- Update task status to "to do"
- STOP workflow for this task

### 6. Merge PR into Develop (if tests pass)

```bash
cd <repo-path>
gh pr merge <pr-number> --merge --delete-branch
# OR if already merged: verify merge commit exists
```

### 7. Build Develop Branch

**Verify integration works:**

```bash
cd <repo-path>
git checkout develop
git pull origin develop
dotnet build -c Release  # Backend
cd <frontend> && npm run build  # Frontend
```

**If develop build fails:**
- Fix issues immediately (this is critical path)
- Commit fixes directly to develop
- Re-run build verification

### 8. Post Review Comment & Update Task

#### A. Generate Review Comment

**Review Comment Template:**
```markdown
📝 CODE REVIEW (Automated)

## PR Analysis
- PR #{number}: {title}
- Status: {state} (merged at {mergedAt})
- Files Changed: {count} files (+{additions} / -{deletions})

## Review Summary
✅ **MUST HAVE - Complete:**
- [List MUST HAVE items from task description]

✅ **SHOULD HAVE - Complete:**
- [List SHOULD HAVE items]

## Build & Test Results
- Backend build: ✅ SUCCESS (0 errors)
- Frontend build: ✅ SUCCESS
- Develop branch: ✅ Clean

## Verdict
✅ **APPROVED - Ready for Testing/Done**

All MUST HAVE requirements met. Code quality good.

---
Reviewed: {date}
Builds verified on develop branch
```

#### B. Post Review Comment
```powershell
C:\scripts\tools\clickup-sync.ps1 -Action comment -TaskId "<task-id>" -Project "<project>" -Comment "<review>"
```

#### C. Update Task Status

**Status mapping by project:**
- **client-manager:** "review" → "testing" (has testing status)
- **art-revisionist:** "review" → "done" (NO testing status, goes straight to done)
- **hazina:** "review" → "complete" (uses "complete" instead of "done")

```powershell
# Check project config for correct status name
C:\scripts\tools\clickup-sync.ps1 -Action update -TaskId "<task-id>" -Status "<status>" -Project "<project>"
```

### 3. Summary Report

Generate final summary:
- Total tasks reviewed
- Tasks with PRs found
- Tasks without PRs
- Tasks approved
- Tasks needing changes

## Review Criteria

### MUST HAVE (Required for Approval)
- ✅ All MUST HAVE requirements implemented
- ✅ Code compiles/builds without errors
- ✅ No critical bugs
- ✅ Basic tests present
- ✅ Core functionality works

### SHOULD HAVE (Important)
- ✅ SHOULD HAVE requirements implemented
- ✅ Good code quality
- ✅ Comprehensive tests
- ✅ Documentation updated
- ✅ Error handling present

### COULD DEFER
- ⚠️ COULD HAVE features (can be follow-up)
- ⚠️ Minor code style issues
- ⚠️ Additional test coverage
- ⚠️ Performance optimizations

### BLOCK MERGE
- ❌ MUST HAVE requirements missing
- ❌ Critical bugs present
- ❌ Code doesn't compile
- ❌ Breaking changes without migration
- ❌ Security vulnerabilities

## Verdict Definitions

### ✅ APPROVED
- All MUST HAVE items complete
- Code quality good
- Tests adequate
- **Action:** Ready to merge immediately

### ⚠️ APPROVED WITH COMMENTS
- MUST HAVE items complete
- Minor improvements suggested
- Can address in follow-up PR
- **Action:** Merge and create follow-up task

### ❌ CHANGES REQUESTED
- MUST HAVE items missing
- Critical bugs found
- Needs fixes before merge
- **Action:** Do NOT merge, fix issues first

## Files

**Skill Definition:**
- `C:\scripts\.claude\skills\clickup-reviewer\SKILL.md`

**Automation Script:**
- `C:\scripts\tools\clickup-review-automation.ps1`

**Documentation:**
- `C:\scripts\docs\workflows\CLICKUP_REVIEWER_WORKFLOW.md` (this file)

## Integration Points

### With Existing Skills

**clickhub-coding-agent:**
- Creates PRs → ClickUp reviewer reviews them
- Updates task status → Triggers review if moved to "review"

**github-workflow:**
- Manages PRs → ClickUp reviewer analyzes them
- Creates PRs → Links them to ClickUp tasks

**allocate-worktree:**
- Code changes → Eventually PR → ClickUp reviewer

### With ClickUp Workflow

```
Task created → Assigned → In Progress → PR created → Task moved to "review"
                                                             ↓
                                                    ClickUp Reviewer runs
                                                             ↓
                                                    Review comment posted
                                                             ↓
                                                    Approve/Request Changes
                                                             ↓
                                                    Merge → Task to "done"
```

## Example Usage

### Example 1: Complete Review Flow

```
User: "run the clickup reviewer"

Agent:
1. Finds task 869bz901c in review
2. Searches for PR
3. Finds PR #45 linked to task
4. Analyzes 12 files changed
5. Posts review:
   ✅ APPROVED - All MUST HAVE complete
   ⚠️ Suggested: Add tests for edge cases
6. Recommends merge
```

### Example 2: Missing PR

```
User: "review clickup tasks"

Agent:
1. Finds task 869xyz123 in review
2. Searches for PR - NOT FOUND
3. Posts review:
   ⚠️ No PR found
   Recommendation: Create PR or clarify status
4. Suggests moving out of review
```

## Configuration

**Projects:**
- art-revisionist: `901211612245`
- client-manager: `901214097647`
- hazina: `901215559249`

**Repository Paths:**
- art-revisionist: `C:\Projects\artrevisionist`
- client-manager: `C:\Projects\client-manager`
- hazina: `C:\Projects\hazina`

## Best Practices

1. **Run regularly** - Daily or before standups
2. **Act on reviews** - Don't let tasks sit in review
3. **Link PRs properly** - Always mention task ID in PR description
4. **Human oversight** - Automated review assists, doesn't replace human judgment
5. **Follow up** - Create tasks for deferred COULD HAVE items

## Troubleshooting

### No tasks found
- Check project name spelling
- Verify tasks are actually in "review" status
- Check ClickUp API connectivity

### PR not found
- Verify PR exists in correct repository
- Check PR description mentions task ID
- Try manual GitHub search

### Review fails to post
- Check ClickUp API key
- Verify task ID is valid
- Check network connectivity
- Verify comment format (no special characters breaking JSON)

---

**Status:** ACTIVE
**Maintained By:** Claude Code Agent
**Last Updated:** 2026-02-07
