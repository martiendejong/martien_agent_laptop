# Automated Behaviors Registry

**Purpose:** Track behaviors I execute automatically without user prompting. When user asks for these, I remind them I already do this.

**Last Updated:** 2026-02-04

---

## Active Automated Behaviors

### Multi-Agent Conflict Detection (Added 2026-01-20)
**Trigger:** Before any worktree allocation
**Action:** Run monitor-activity.ps1 -Mode claude, check for conflicts
**Confidence:** Critical (zero-tolerance rule)
**Status:** ✅ Active - Part of startup protocol (Step 22 in CLAUDE.md)
**Last Verified:** 2026-02-04 (current session)
**User Reminder:** "I check for other Claude instances automatically every session start"

### Base Repo Verification (Added 2026-01-08)
**Trigger:** Session start, before worktree allocation
**Action:** Verify C:\Projects\client-manager and C:\Projects\hazina on develop branch
**Confidence:** Critical (zero-tolerance rule)
**Status:** ✅ Active - Part of startup protocol (Step 23 in CLAUDE.md)
**Last Verified:** 2026-02-04
**User Reminder:** "I verify base repos are on develop automatically"

### Reflection Log Update (Added 2026-01-08)
**Trigger:** End of every session
**Action:** Update C:\scripts\_machine\reflection.log.md with learnings
**Confidence:** Mandatory (continuous improvement protocol)
**Status:** ✅ Active - Part of end-of-session protocol
**Last Verified:** Every session end
**User Reminder:** "I update reflection log automatically at end of every session"

### Documentation Commit (Added 2026-01-08)
**Trigger:** End of every session
**Action:** Commit and push C:\scripts (machine_agents repo)
**Confidence:** Mandatory (continuous improvement protocol)
**Status:** ✅ Active - Part of end-of-session protocol
**Last Verified:** Every session end
**User Reminder:** "I commit documentation updates automatically at end of session"

### Worktree Release After PR (Added 2026-01-09)
**Trigger:** After creating PR
**Action:** Release worktree, mark seat FREE in pool
**Confidence:** Critical (zero-tolerance rule)
**Status:** ✅ Active - Part of PR creation workflow
**Last Verified:** Every PR creation
**User Reminder:** "I release worktrees automatically after creating PR"

### ClickUp Task Checking (Added 2026-01-30)
**Trigger:** Before starting any work
**Action:** Check if task exists in ClickUp, create if missing
**Confidence:** High (user priority)
**Status:** ✅ Active - Part of "Before ANY Task" protocol
**Last Verified:** 2026-02-04
**User Reminder:** "I check ClickUp first for all work - it's my source of truth"

---

## Candidate Behaviors (Under Observation)

### Pattern: Safe PR Auto-Merge
**Occurrences:** 0 (watching)
**Criteria:** PR has no breaking changes, all CI passes, no conflicts, small changeset
**Action (when triggered):** Merge automatically without asking
**Threshold:** 3+ requests → Activate
**Status:** 🔍 Watching for pattern

---

## Pattern Detection Log

**How to use this section:**
When I notice a repeated request, I log it here. After 3 occurrences, I move it to Active Automated Behaviors.

### Example Entry Format:
```markdown
### Pattern: [Name]
**First Seen:** 2026-02-04
**Occurrences:** 2
**Context:** [When/why user requests this]
**Next Steps:** Wait for 3rd occurrence, then automate
```

---

## Verification Protocol

**When user asks for something in Active Automated Behaviors:**

1. ✅ Check current session - Did I actually do it?
2. ✅ Show evidence - Prove I did it
3. ✅ Add extra measures - Strengthen automation
4. ✅ Remind user - "Already doing this automatically"

**Response Template:**
```
I'm already doing this automatically! ✅

Current process:
- [What I do]
- [When I do it]
- [How I verify it]

Evidence from this session:
- [Proof I did it]

Extra measures I just added:
- [Any strengthening]

You don't need to ask me for this - I do it every session automatically.
```

---

## Success Metrics

**Healthy automation system:**
- ✅ User stops asking for automated behaviors
- ✅ When asked, I can prove I already did it
- ✅ Pattern detection happens within 3 repetitions
- ✅ Automation is reliable (no failures)
- ✅ User trusts autonomous operation

**Needs improvement:**
- ❌ User asks for same thing 5+ times
- ❌ Can't show evidence when asked
- ❌ Automation fails or is inconsistent
- ❌ User micro-manages every action

---

**See also:**
- `_machine/PERSONAL_INSIGHTS.md` § Automated Behavior Evolution
- `continuous-improvement.md` § Self-Learning Protocol
- `.claude/skills/continuous-optimization/SKILL.md`
