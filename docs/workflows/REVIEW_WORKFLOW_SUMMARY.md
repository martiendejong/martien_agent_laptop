# Review Workflow - Quick Reference

**Last Updated:** 2026-02-09
**User Mandate:** "ga reviewen" should trigger COMPLETE workflow

---

## One Command Does Everything

```
User: "ga reviewen"
```

**What happens automatically:**

### Phase 1: Discovery
1. ✅ Fetch all tasks in "review" status (hazina, client-manager, art-revisionist)
2. ✅ Find linked PRs for each task
3. ✅ Check PR state (OPEN, MERGED, or missing)

### Phase 2: Pre-Merge Verification (if PR is OPEN)
4. ✅ Merge develop into PR branch
5. ✅ Resolve conflicts (or report and stop)
6. ✅ Build locally (backend + frontend)
7. ✅ Test locally (NO GitHub CI - we skip deliberately)
8. ✅ Report failures (or continue)

### Phase 3: Merge to Develop
9. ✅ Merge PR into develop (if not already merged)
10. ✅ Delete PR branch automatically

### Phase 4: Integration Verification
11. ✅ Checkout develop branch
12. ✅ Pull latest changes
13. ✅ Build develop (backend + frontend)
14. ✅ Fix any integration issues immediately

### Phase 5: Documentation & Status Update
15. ✅ Analyze PR changes against task requirements
16. ✅ Post comprehensive review comment to ClickUp
17. ✅ Update task status:
    - client-manager: "review" → "testing"
    - art-revisionist: "review" → "done"
    - hazina: "review" → "complete"

---

## Status Mapping by Project

| Project | Review Status | Success Status | Failure Status |
|---------|---------------|----------------|----------------|
| client-manager | review | testing | to do |
| art-revisionist | review | done | to do |
| hazina | review | complete | to do |

**Available statuses:**
- **client-manager:** todo, busy, review, testing, needs input, needs refinement, next sprint, blocked, done, cancelled
- **art-revisionist:** backlog, refined, blocked, planned, to do, in progress, review, done
- **hazina:** to do, planning, in progress, at risk, update required, on hold, complete, cancelled, archive

---

## Failure Handling

**If merge conflicts:**
- Post comment: "Merge conflicts detected, needs manual resolution"
- Update status to "to do"
- STOP workflow for this task

**If build fails:**
- Post comment with build errors
- Update status to "to do"
- STOP workflow for this task

**If PR not found:**
- Post comment: "No PR found - create PR or clarify status"
- Update status to "to do"
- STOP workflow for this task

**If develop build fails after merge:**
- FIX IMMEDIATELY (critical path)
- Commit fixes directly to develop
- Re-verify build

---

## Key Principles

1. **GitHub CI is IGNORED** - We deliberately skip CI checks, only local builds matter
2. **Develop must always build** - If develop breaks, fix immediately
3. **Always merge develop INTO branch first** - Prevents merge conflicts
4. **Status names vary by project** - Check config for correct status
5. **Complete automation** - User shouldn't need to give detailed instructions

---

## Example Session (2026-02-09)

**User:** "ga reviewen"

**Result:**
- ✅ Found 4 tasks in review (art-revisionist)
- ✅ Located PRs #52, #53, #54 (all MERGED)
- ✅ Verified builds: Backend (0 errors), Frontend (success)
- ✅ Posted comprehensive review comments
- ✅ Updated all 4 tasks to "done"
- ⏱️ Total time: ~5 minutes for 4 tasks

**Tasks reviewed:**
- 869c29zua: TopicLearn Backend API
- 869c29zv6: TopicUsers Route Fix
- 869c1dppk: AI Art Style Classifier (ROI 4.38!)
- 869bz901c: Topic Featured Image

---

## Documentation

**Full workflow:** `C:\scripts\docs\workflows\CLICKUP_REVIEWER_WORKFLOW.md`
**Config:** `C:\scripts\_machine\clickup-config.json`
**Script:** `C:\scripts\tools\clickup-sync.ps1`

---

**Status:** ACTIVE - Standard workflow as of 2026-02-09
**User Feedback:** "eigenlijk nooit zo uitgebreid hoef te geven alleen 'ga reviewen' moet al genoeg zijn"
