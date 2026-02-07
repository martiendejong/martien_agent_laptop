---
name: clickup-reviewer
description: Review ClickUp tasks in 'review' status by analyzing linked PRs and providing code review
tags: [clickup, code-review, pr-review, quality-assurance]
version: 1.0.0
created: 2026-02-07
---

# ClickUp Reviewer Skill

## Purpose

Automatically review ClickUp tasks in "review" status by:
1. Finding tasks in review status
2. Locating linked Pull Requests
3. Analyzing code changes
4. Providing comprehensive code review
5. Posting review as ClickUp comment

## Usage

```
User: "run the clickup reviewer"
User: "review clickup tasks"
User: "check tasks in review"
```

## Workflow

### Step 1: Find Tasks in Review

```powershell
C:\scripts\tools\clickup-sync.ps1 -Action list -Project "art-revisionist" |
  Where-Object { $_.Status -eq "review" }
```

### Step 2: For Each Task

1. **Get Task Details**
   ```powershell
   C:\scripts\tools\clickup-sync.ps1 -Action show -TaskId "<task-id>"
   ```

2. **Find Linked PR**
   - Check task description for PR links
   - Search GitHub for PRs mentioning task ID
   - Check PR body for ClickUp task references

3. **Fetch PR Details**
   ```bash
   gh pr view <pr-number> --json number,title,body,state,files,commits
   ```

4. **🚨 CRITICAL: Check Merge Status**
   ```bash
   gh pr view <pr-number> --json mergeable,mergeStateStatus
   ```

   **REQUIRED CHECK BEFORE APPROVAL:**
   - `mergeStateStatus` must be `"CLEAN"` (not `"DIRTY"`, `"BEHIND"`, or `"UNSTABLE"`)
   - `mergeable` must be `"MERGEABLE"` (not `"CONFLICTING"`)

   **If conflicts detected:**
   1. ❌ REJECT the PR (post comment explaining)
   2. ❌ Move ClickUp task back to "to do" status
   3. ❌ Comment on task: "PR rejected - merge conflicts with develop branch"
   4. ✅ Explain how to resolve: merge develop into feature branch, resolve conflicts, push
   5. ⏸️ STOP review process - do not proceed to code analysis

   **Example rejection comment:**
   ```markdown
   ## ⚠️ REVIEW FAILED - Merge Conflicts Detected

   **Merge Status:** CONFLICTING ❌
   **State:** DIRTY ❌

   This PR cannot be merged because it has conflicts with the `develop` branch.

   **Required Actions:**
   1. Merge latest `develop` into your feature branch
   2. Resolve all merge conflicts
   3. Test that application builds and runs
   4. Push resolved changes
   5. Request re-review

   **Resolution Commands:**
   ```bash
   git checkout <feature-branch>
   git pull origin develop
   # Resolve conflicts
   git add .
   git commit -m "chore: Merge develop and resolve conflicts"
   git push origin <feature-branch>
   ```

   Moving task back to 'to do' status.
   ```

5. **Analyze Changes**
   - Review file changes
   - Check for code quality issues
   - Verify MoSCoW requirements met
   - Ensure tests included
   - Check documentation updates

5. **Generate Review**
   Create comprehensive review covering:
   - **Functionality**: Does it meet requirements?
   - **Code Quality**: Clean, maintainable, follows patterns?
   - **Testing**: Are tests adequate?
   - **Documentation**: Is it documented?
   - **MoSCoW Compliance**: MUST/SHOULD items delivered?
   - **Issues Found**: Any bugs or concerns?
   - **Recommendations**: Suggestions for improvement

6. **Post Review Comment**
   ```powershell
   C:\scripts\tools\clickup-sync.ps1 -Action comment -TaskId "<task-id>" -Comment "<review>"
   ```

### Step 3: Summary Report

Generate summary of all reviewed tasks with recommendations.

## Review Template

```markdown
📝 CODE REVIEW (Automated by Claude Code Agent)

## PR Analysis
- **PR #**: {number}
- **Title**: {title}
- **Status**: {state}
- **Files Changed**: {count}
- **Commits**: {count}

## Functionality Review ✅/❌
{Analysis of whether PR meets task requirements}

## Code Quality Assessment ✅/⚠️/❌
{Analysis of code quality, patterns, maintainability}

## Testing Coverage ✅/⚠️/❌
{Analysis of test coverage and quality}

## Documentation ✅/⚠️/❌
{Analysis of code comments, README updates, etc.}

## MoSCoW Compliance ✅/⚠️
- MUST HAVE: {status}
- SHOULD HAVE: {status}
- COULD HAVE: {status}

## Issues Found
{List of concerns, bugs, or problems}

## Recommendations
1. {Recommendation 1}
2. {Recommendation 2}

## Verdict
✅ APPROVED - Ready to merge
⚠️ APPROVED WITH COMMENTS - Merge but address comments in follow-up
❌ CHANGES REQUESTED - Needs fixes before merge

---
Review conducted by Claude Code Agent
Date: {timestamp}
```

## No PR Found?

If task is in review but has no PR:

```markdown
📝 CODE REVIEW (Automated by Claude Code Agent)

## Status
⚠️ Task is in REVIEW status but no linked PR was found.

## Possible Reasons
1. PR not yet created
2. PR link not added to task description
3. Task waiting for requirements review (not code review)
4. PR in different repository

## Recommendations
- If code is complete: Create PR and link it to task
- If waiting for requirements: Move to "planned" or "blocked"
- If PR exists: Add link to task description

## Next Steps
Please clarify the review status:
- Is code ready for review? → Create PR
- Is this requirements review? → Update status
- Is PR elsewhere? → Link it

---
Review conducted by Claude Code Agent
Date: {timestamp}
```

## Integration with Existing Workflow

### Before Merging PR

1. ClickUp task MUST be in "review" status
2. Run `clickup-reviewer` skill
3. Address any concerns raised
4. Get approval from reviewer
5. Merge PR
6. Update task to "done"

### Quality Gates

**MUST HAVE for approval:**
- ✅ **PR merge status is CLEAN (no conflicts with develop)** ⚠️ CRITICAL
- ✅ All MUST HAVE requirements implemented
- ✅ No critical bugs found
- ✅ Basic tests present
- ✅ Code compiles/builds successfully

**SHOULD HAVE for approval:**
- ✅ SHOULD HAVE requirements mostly implemented
- ✅ Good code quality
- ✅ Comprehensive tests
- ✅ Documentation updated

**COULD DEFER:**
- ⚠️ COULD HAVE features (can be deferred)
- ⚠️ Minor code style issues
- ⚠️ Additional tests (if basic coverage exists)

## Examples

### Example 1: Full PR Review

```
Task: 869bz901c - Topics need featured image
PR: #XX - feat: Add featured image support for topics

Review:
✅ APPROVED - All MUST HAVE items complete
- Topics now display featured images ✅
- Fallback image handling ✅
- Upload UI functional ✅

⚠️ Minor improvements suggested:
- Add image optimization
- Add alt text field

Recommendation: MERGE and create follow-up task for improvements.
```

### Example 2: Missing PR

```
Task: 869bz901c - Topics need featured image
PR: NOT FOUND

⚠️ Task in review but no PR linked.
Recommendation: Create PR or clarify review status.
```

## Files

**Main Skill**: `C:\scripts\.claude\skills\clickup-reviewer\SKILL.md`
**Helper Script**: `C:\scripts\tools\clickup-review-automation.ps1` (to be created)

## Related Skills

- `clickhub-coding-agent` - For implementing ClickUp tasks
- `github-workflow` - For PR management
- `multi-agent-conflict` - For coordination

## Configuration

**Project Mapping** (from `clickup-config.json`):
- art-revisionist: List ID `901211612245`
- client-manager: List ID `901214097647`
- hazina: List ID `901215559249`

## Notes

- Review is automated but should be supplemented with human judgment
- Focus on objective criteria (functionality, tests, documentation)
- Be constructive in feedback
- Recommend specific improvements, not just criticism
- If uncertain, flag for human review

---

**Created**: 2026-02-07
**Author**: Claude Code Agent
**Status**: ACTIVE
**Invocation**: "run the clickup reviewer" or "review clickup tasks"
