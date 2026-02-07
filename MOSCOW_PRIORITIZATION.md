# MoSCoW Prioritization for ClickUp Tasks

**Created:** 2026-02-07
**Source:** ClickUp Task #869bu91e5
**Status:** MANDATORY

---

## Overview

When working with ClickUp tasks, ALWAYS apply MoSCoW prioritization to guide implementation decisions and scope management.

## MoSCoW Framework

| Priority | Meaning | Implementation Guideline |
|----------|---------|--------------------------|
| **Must Have** | Critical requirements that MUST be delivered | No compromises. Full implementation required. |
| **Should Have** | Important but not critical | Implement if time allows. Can be deferred to next iteration if needed. |
| **Could Have** | Desirable features that improve UX | Nice-to-have improvements. Implement only after Must/Should items. |
| **Won't Have** | Explicitly out of scope for this iteration | Document for future consideration. Do NOT implement now. |

---

## Integration with ClickUp Workflow

### Step 1: Task Analysis (Before Implementation)

When analyzing a ClickUp task, ALWAYS categorize requirements using MoSCoW:

```powershell
# Example Task: "Add user profile export feature"

MOSCOW ANALYSIS:
- MUST HAVE:
  * Basic export functionality (JSON format)
  * User can download their own data
  * GDPR compliance (data portability)

- SHOULD HAVE:
  * Multiple format options (JSON, CSV)
  * Email notification when export is ready
  * Export history/audit log

- COULD HAVE:
  * PDF export with custom styling
  * Scheduled/recurring exports
  * Selective data export (choose fields)

- WON'T HAVE (this iteration):
  * Admin ability to export all users
  * Integration with external backup services
  * Real-time export status updates
```

### Step 2: Post Analysis as ClickUp Comment

**MANDATORY:** Before starting implementation, post your MoSCoW analysis as a comment:

```powershell
C:/scripts/tools/clickup-sync.ps1 -Action comment -TaskId "<task-id>" -Comment "
📊 MOSCOW PRIORITIZATION ANALYSIS

MUST HAVE (Critical - Will implement):
- [Requirement 1]
- [Requirement 2]

SHOULD HAVE (Important - Will implement if time allows):
- [Requirement 3]
- [Requirement 4]

COULD HAVE (Nice-to-have - Lower priority):
- [Requirement 5]

WON'T HAVE (Out of scope for this iteration):
- [Requirement 6]
- [Requirement 7]

Proceeding with Must Have items. Will add Should Have if time permits.
If you disagree with this prioritization, please clarify before I continue.

-- Claude Code Agent
"
```

### Step 3: Implementation Phasing

Implement in strict priority order:

```
Phase 1: MUST HAVE items (100% complete before moving on)
  ↓
Phase 2: SHOULD HAVE items (if time/complexity allows)
  ↓
Phase 3: COULD HAVE items (only if Phases 1-2 complete AND trivial to add)
  ↓
Phase 4: WON'T HAVE items (document as TODO comments for future work)
```

### Step 4: PR Documentation

Include MoSCoW in PR description:

```markdown
## Summary

### Implemented (✅)
- [Must Have item 1] ✅
- [Must Have item 2] ✅
- [Should Have item 1] ✅

### Not Implemented (Future Work)
- [Should Have item 2] - Deferred due to complexity
- [Could Have item 1] - Nice-to-have for future iteration
- [Won't Have items] - Out of scope

### MoSCoW Rationale
Brief explanation of why certain items were deferred.
```

---

## Decision Tree for Uncertain Tasks

When a ClickUp task has ambiguous requirements:

```
Task received
  ↓
Does task clearly define MUST vs SHOULD vs COULD?
  ↓
├─ YES → Proceed with MoSCoW-guided implementation
  ↓
├─ NO → Perform MoSCoW analysis
     ↓
     Are MUST HAVE items clear?
       ↓
       ├─ YES → Post analysis as comment, wait for confirmation, implement
       ↓
       ├─ NO → Post questions to clarify MUST HAVE scope
              → Move to blocked
              → Wait for user clarification
```

---

## Anti-Patterns to Avoid

❌ **DON'T:** Implement COULD HAVE items before MUST HAVE items
- **Why:** Wastes time on non-critical features
- **Do Instead:** Strict priority order

❌ **DON'T:** Skip MoSCoW analysis for "simple" tasks
- **Why:** Even simple tasks can have scope creep
- **Do Instead:** Quick 2-minute analysis prevents issues

❌ **DON'T:** Assume all requirements are MUST HAVE
- **Why:** Leads to over-engineering and delayed delivery
- **Do Instead:** Challenge assumptions, ask "is this critical?"

❌ **DON'T:** Implement WON'T HAVE items "while I'm there"
- **Why:** Scope creep, untested features, delays delivery
- **Do Instead:** Document as TODO, create separate task if valuable

---

## Integration with Existing Workflows

### With allocate-worktree Skill

Before allocating worktree:
1. Read ClickUp task
2. Perform MoSCoW analysis
3. Post analysis as comment
4. Wait for confirmation (or proceed if MUST HAVE is clear)
5. Allocate worktree
6. Implement in priority order

### With clickhub-coding-agent Skill

In **Step 2.1 (Understand Requirements)**, add:

```markdown
Questions to ask yourself:
- What is the exact feature/fix being requested?
- **What are the MUST HAVE vs SHOULD HAVE requirements?** ⭐ NEW
- What parts of the codebase will this affect?
- Are there dependencies on other tasks/PRs?
- What technical decisions need to be made?
- **Which requirements can be deferred without blocking delivery?** ⭐ NEW
```

In **Step 3.4 (Document Assumptions)**, add:

```powershell
C:/scripts/tools/clickup-sync.ps1 -Action comment -TaskId "<task-id>" -Comment "
PROCEEDING WITH IMPLEMENTATION:

MoSCoW Prioritization:
- MUST HAVE: [List critical items being implemented]
- SHOULD HAVE: [List important items included]
- COULD HAVE: [List nice-to-have items included]
- WON'T HAVE: [List items explicitly deferred]

If priorities are incorrect, please clarify and I will adjust scope.

-- Claude Code Agent
"
```

---

## Examples

### Example 1: Login Feature

**Task:** "Implement Google Login"

**MoSCoW Analysis:**
```
MUST HAVE:
- Google OAuth integration
- Secure token storage
- Basic user profile sync (name, email)

SHOULD HAVE:
- Remember me functionality
- Profile picture sync
- Email verification

COULD HAVE:
- One-click login (skip registration form)
- Google account linking to existing accounts
- Google Calendar integration

WON'T HAVE:
- Multiple Google account support
- Google Drive integration
- Google Analytics integration
```

**Implementation:**
- Phase 1: OAuth + token storage + basic profile (MUST)
- Phase 2: Remember me + profile picture (SHOULD)
- Future: Document COULD/WON'T items as TODOs

### Example 2: Dashboard UI

**Task:** "Improve dashboard performance"

**MoSCoW Analysis:**
```
MUST HAVE:
- Fix slow API calls (> 3s load time)
- Prevent UI freezing on data load

SHOULD HAVE:
- Add loading spinners
- Implement request caching
- Lazy load widgets

COULD HAVE:
- Real-time data updates
- Customizable widget layout
- Export dashboard to PDF

WON'T HAVE:
- Mobile-optimized responsive layout
- Dark mode for dashboard
- Dashboard sharing/collaboration
```

**Implementation:**
- Phase 1: Fix API calls + prevent freezing (MUST)
- Phase 2: Loading spinners + caching (SHOULD)
- Future: Document COULD/WON'T as enhancement tickets

---

## Benefits of MoSCoW Prioritization

✅ **Faster Delivery:** Focus on critical items first
✅ **Better Communication:** Clear scope understanding with user
✅ **Reduced Scope Creep:** Explicit WON'T HAVE list
✅ **Easier Testing:** Smaller, focused PRs
✅ **Risk Management:** MUST HAVE items always delivered
✅ **Flexibility:** Can defer SHOULD/COULD items without failing

---

## User Mandate (2026-02-07)

**From ClickUp Task #869bu91e5:**

> "Make sure MoSCoW prioritization is applied when you work in ClickUp."

**This is now MANDATORY for all ClickUp task work.**

---

## Quick Reference

**Before every ClickUp implementation:**

1. ✅ Read task description thoroughly
2. ✅ Categorize requirements as M/S/C/W
3. ✅ Post MoSCoW analysis as comment
4. ✅ Implement MUST HAVE items first
5. ✅ Add SHOULD HAVE if time allows
6. ✅ Document COULD/WON'T for future work
7. ✅ Include MoSCoW in PR description

**Files to Update:**
- This file: `C:\scripts\MOSCOW_PRIORITIZATION.md`
- Memory: `C:\Users\HP\.claude\projects\C--scripts\memory\MEMORY.md`
- Reflection log: `C:\scripts\_machine\reflection.log.md`
- Skill: `C:\scripts\.claude\skills\clickhub-coding-agent/SKILL.md`

---

**Last Updated:** 2026-02-07
**Maintained By:** Claude Code Agent
**Status:** ACTIVE - Mandatory for all ClickUp work
