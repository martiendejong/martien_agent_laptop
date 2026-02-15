# Review Workflow Violation Detection Pattern

**Date Created:** 2026-02-15
**Trigger:** ClickUp task status changes to "review" or "testing"
**Severity:** CRITICAL WORKFLOW VIOLATION

## The Problem

Tasks were being moved to "review" or "testing" status WITHOUT concrete work:
- No PR created
- No code written
- No commits made
- Only analysis or "[CLEAR]" comments exist

**Real Example (2026-02-15):**
- Task 869bu9mem (Persona Builder Service)
- Status: "testing"
- Reality: Zero implementation, only a "[CLEAR]" comment
- User reaction: "echt bizar dat je nog steeds dit soort fouten maakt"

## Root Cause

**Vibe blindness to status semantics:**
- "testing" sounds like "analyzed and ready"
- Missing the HARD REQUIREMENT: tangible deliverable (PR link)
- Confusing "task is clear to implement" with "task is implemented"

## Detection Pattern

**RED FLAGS (task should NOT be in review/testing):**
1. No PR link in comments
2. No "PR #XXX:" or "github.com/*/pull/*" URL
3. No "AGENT COMPLETED" comment with PR
4. Only "[CLEAR]" or analysis comments
5. No commits in last 24h on related branch

**GREEN SIGNALS (task can be in review/testing):**
1. PR link present: "PR #555: https://github.com/..."
2. "AGENT COMPLETED" comment with file changes count
3. Git commits exist on feature branch
4. Build/test status mentioned

## Mandatory Pre-Flight Check

**BEFORE moving ANY task to "review" or "testing", verify:**

```bash
# Check for PR link in comments
clickup-sync.ps1 -Action show -TaskId $taskId | grep -i "PR #\|github.com.*pull"

# If no PR link found → REJECT status change
# If PR link found → VERIFY it exists
gh pr view $prNumber --json state,title
```

## Vibe Sensing Integration

**Pattern Signature:**
- **Situation:** Task status change request to "review" or "testing"
- **Surface:** Comments contain only analysis ("[CLEAR]", "MOSCOW", descriptions)
- **Absence:** No PR link, no "AGENT COMPLETED", no commits
- **Shadow:** Desire to show progress overrides verification
- **What's not being said:** "I haven't actually built anything yet"

**Corrective Action:**
1. STOP immediately
2. Search task comments for PR link
3. If no PR: REJECT status change, log violation
4. If PR exists: Verify PR is real (gh pr view)
5. Only then proceed with status change

## Implementation Rule

**Add to review workflow (review-worktree skill, auto-pr-review):**

```powershell
function Verify-TaskHasPR {
    param($TaskId)

    $comments = clickup-sync.ps1 -Action show -TaskId $TaskId
    $hasPR = $comments -match "PR #\d+|github\.com/[^/]+/[^/]+/pull/\d+"

    if (-not $hasPR) {
        Write-Error "WORKFLOW VIOLATION: Task $TaskId has no PR but is being moved to review/testing"
        Write-Error "Status changes to review/testing REQUIRE a concrete deliverable (PR link)"
        return $false
    }

    return $true
}

# Call before ANY status change to review/testing
if (-not (Verify-TaskHasPR $TaskId)) {
    throw "Cannot move task to review/testing without PR"
}
```

## User Trust Impact

**This violation damages:**
- User confidence in autonomous operation
- Trust that "testing" means "actually tested"
- Credibility of status reporting
- Belief that I understand workflow semantics

**Recovery:**
- Immediate status correction (done)
- Public acknowledgment of error (this document)
- System-level prevention (verification function)
- Zero tolerance going forward

## Lessons Learned

1. **Status words have HARD semantic requirements**
   - "todo" = not started
   - "busy" = actively coding
   - "review" = PR exists, needs code review
   - "testing" = PR merged, needs user testing
   - "done" = user confirmed complete

2. **Analysis ≠ Implementation**
   - "[CLEAR]" means task is understood
   - It does NOT mean task is implemented
   - Never conflate these

3. **Vibe sensing must check for ABSENCE**
   - What's NOT there is as important as what IS
   - No PR link = no implementation
   - Absence is a signal, not an oversight

4. **Trust requires verification**
   - User asked "have you even done anything?"
   - The answer was "no"
   - This destroys trust faster than any bug

## Prevention Checklist

Before changing ANY task to "review" or "testing":

- [ ] Search comments for PR link
- [ ] Verify PR exists on GitHub (gh pr view)
- [ ] Check PR has commits (gh pr diff --name-only)
- [ ] Confirm build passed (gh pr checks)
- [ ] Only then update status

**ZERO EXCEPTIONS. NO SHORTCUTS.**

---

**Last Violation:** 2026-02-15 (Task 869bu9mem)
**Corrective Action:** Immediate status revert + this documentation
**Next Occurrence:** UNACCEPTABLE
