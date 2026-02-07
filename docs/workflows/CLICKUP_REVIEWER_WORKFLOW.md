# ClickUp Reviewer Workflow

**Created:** 2026-02-07
**Purpose:** Automated code review for ClickUp tasks in "review" status
**Invocation:** "run the clickup reviewer" or "review clickup tasks"

---

## Overview

The ClickUp Reviewer is an automated workflow that:
1. Identifies ClickUp tasks in "review" status
2. Locates linked Pull Requests
3. Analyzes code changes
4. Posts comprehensive review comments
5. Provides recommendations for approval/changes

## When to Use

**Automatic Triggers:**
- When user says "run the clickup reviewer"
- When user says "review clickup tasks"
- When user says "check tasks in review"

**Manual Triggers:**
- Before merging PRs
- During daily standup reviews
- When tasks have been in review >2 days

## Workflow Steps

### 1. Identify Review Tasks

```powershell
C:\scripts\tools\clickup-sync.ps1 -Action list -Project "art-revisionist"
```

Filter for tasks with status="review"

### 2. For Each Task

#### A. Get Task Details
```powershell
C:\scripts\tools\clickup-sync.ps1 -Action show -TaskId "<task-id>"
```

#### B. Find Linked PR

**Method 1: Check task description**
- Look for PR links (github.com/*/pull/*)
- Look for #PR-NUMBER references

**Method 2: Search GitHub**
```bash
cd <repo-path>
gh pr list --state all --search "<task-id>"
```

**Method 3: Scan PR bodies**
```bash
gh pr list --state all --limit 50 --json body,number |
  jq ".[] | select(.body | contains(\"<task-id>\"))"
```

#### C. Analyze PR (if found)

```bash
gh pr view <pr-number> --json number,title,state,files,commits,body,url
```

**Review Checklist:**
- ✅ All MUST HAVE requirements met?
- ✅ Code quality acceptable?
- ✅ Tests included?
- ✅ Documentation updated?
- ✅ No critical bugs?
- ⚠️ SHOULD HAVE requirements met?
- ⚠️ COULD HAVE features included?

#### D. Generate Review Comment

**If PR found:**
```markdown
📝 CODE REVIEW (Automated by Claude Code Agent)

## PR Analysis
- PR #: {number}
- Title: {title}
- Status: {state}
- Files Changed: {count}
- Commits: {count}

## Review Summary
[Analysis of changes]

## Verdict
✅ APPROVED / ⚠️ APPROVED WITH COMMENTS / ❌ CHANGES REQUESTED

---
Date: {timestamp}
Task: {taskId}
```

**If No PR found:**
```markdown
📝 CODE REVIEW (Automated by Claude Code Agent)

## Status
⚠️ Task in REVIEW but no linked PR found.

## Recommendations
- Create PR if code complete
- Move to 'to do' if not implemented
- Clarify review type (requirements vs code)

---
Date: {timestamp}
Task: {taskId}
```

#### E. Post Review
```powershell
C:\scripts\tools\clickup-sync.ps1 -Action comment -TaskId "<task-id>" -Comment "<review>"
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
