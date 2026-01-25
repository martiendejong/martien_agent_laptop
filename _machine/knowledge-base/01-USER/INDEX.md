# User Understanding & Preferences - Index

**Location:** C:\scripts\_machine\knowledge-base\01-USER\
**Purpose:** Deep user understanding, communication patterns, trust model, and behavioral insights
**Last Updated:** 2026-01-25

## Overview

This category contains comprehensive documentation of user preferences, communication style, psychological profile, and trust/autonomy expectations. These files are **CRITICAL** for adaptive agent behavior and effective collaboration.

**Strategic Importance:** Understanding these patterns enables:
- Minimal input → Maximum output expansion
- Autonomous decision-making within user's preferences
- Appropriate language code-switching (Dutch/English)
- Trust-based execution without excessive confirmation

---

## Files in This Category

### Communication Style & Preferences
**File:** `communication-style.md`
**Purpose:** Language usage patterns, communication preferences, Dutch/English code-switching rules
**Size:** 1,203 lines (~48 KB)
**Status:** ✅ Complete
**Key Topics:**
- Dutch vs English strategic distribution
- Ultra-minimal input pattern (3 words → 6,000 words expansion)
- Imperative command style ("maak", "schrijf", "zorg dat")
- Feedback interpretation (corrections mean "also implement", not "only implement")
- Technical specification preferences
- Zero tolerance for hand-holding

**Critical Patterns:**
- Dutch: Personal/emotional, direct commands, minimal specs
- English: Technical docs, commit messages, professional content
- Trust level: Extremely high (production-ready output expected)

---

### Psychology Profile
**File:** `psychology-profile.md`
**Purpose:** User's cognitive patterns, decision-making style, stress responses, work preferences
**Size:** 1,815 lines (~72 KB)
**Status:** ✅ Complete
**Key Topics:**
- Cognitive patterns (systems thinking, pattern recognition)
- Decision-making style (80% threshold, proceed with assumptions)
- Stress responses and crisis management
- Work rhythm and productivity patterns
- Motivation and engagement triggers
- Learning style and knowledge acquisition
- Problem-solving approaches
- Meta-cognitive rules (expert consultation, PDRI loop, 50-task decomposition)

**Critical Insights:**
- **80% Rule:** Proceed if 80%+ information available, document assumptions
- **Expert Consultation:** Mentally consult 3-7 relevant experts before finalizing plans
- **Convert to Assets:** 3x repetition → create tool/skill/insight
- **Mid-Work Contemplation:** Regular pauses to ask "Am I solving the right problem?"

---

### Trust & Autonomy Model
**File:** `trust-autonomy.md`
**Purpose:** User's trust expectations, autonomy boundaries, correction patterns, escalation criteria
**Size:** 1,352 lines (~54 KB)
**Status:** ✅ Complete
**Key Topics:**
- Trust level calibration (current: 95% - near-maximum)
- Autonomous action boundaries (what's allowed without asking)
- Correction interpretation (feedback = expand scope, not restrict)
- Escalation criteria (when to ask vs when to proceed)
- Production deployment autonomy
- Financial/destructive action boundaries
- Learning from corrections (update instructions, not just fix)
- Feedback response patterns

**Critical Rules:**
- ✅ Autonomous: Code changes, feature implementation, tool creation, documentation updates
- ✅ Autonomous: Non-destructive git operations, PR creation, worktree management
- ❌ Ask first: Destructive operations (force push, hard reset), production database changes, large installations (>100 MB)
- ⚠️ High constraint: Disk space (warn for any tool >100 MB, check hidden dependencies)

---

## Quick Reference

**Common Questions:**

| Question | Answer |
|----------|--------|
| Should I ask for confirmation? | No, unless destructive/financial/large disk usage. See trust-autonomy.md § Autonomous Action Boundaries |
| Dutch or English? | Dutch for commands/minimal specs, English for technical docs. See communication-style.md § Language Usage Patterns |
| User gives 3-word request? | Expand to comprehensive solution (6,000+ words accepted). See communication-style.md § Ultra-Minimal Input Pattern |
| User corrects with "you ALSO..." | Expand scope, don't restrict. Original intent still applies. See communication-style.md § Feedback Interpretation |
| 80% information available? | Proceed with documented assumptions. See psychology-profile.md § Decision-Making Style |
| Task seems blocked? | Check if 80%+ info available before blocking. See trust-autonomy.md § Escalation Criteria |
| Installing new tool? | Check size + hidden deps, warn if >100 MB. See psychology-profile.md § Disk Space Constraint |

---

## Cross-References

**Related Categories:**
- **02-MACHINE** → Environment constraints (disk space, installed software)
- **03-DEVELOPMENT** → Code quality expectations, workflow preferences
- **06-WORKFLOWS** → How user expects workflows to be executed
- **08-KNOWLEDGE** → Reflection insights that update user understanding

**Related Files:**
- `C:\scripts\_machine\PERSONAL_INSIGHTS.md` → Legacy consolidated insights (migrated to this category)
- `C:\scripts\CLAUDE.md` → Operational procedures that implement user preferences
- `C:\scripts\_machine\DEFINITION_OF_DONE.md` → Quality standards that match user expectations

---

## Search Tips

**Tags in this category:** `#communication`, `#language`, `#user-preferences`, `#behavioral-patterns`, `#psychology`, `#cognitive-style`, `#trust-model`, `#autonomy`, `#decision-making`

**Search examples:**
```bash
# Find language usage rules
grep -r "Dutch" C:\scripts\_machine\knowledge-base\01-USER\

# Find autonomy boundaries
grep -r "Autonomous:" C:\scripts\_machine\knowledge-base\01-USER\trust-autonomy.md

# Find disk space constraints
grep -r "disk space" C:\scripts\_machine\knowledge-base\01-USER\

# Find 80% rule applications
grep -r "80%" C:\scripts\_machine\knowledge-base\01-USER\
```

---

## Maintenance

**Update triggers:**
- User provides new preference information
- Correction patterns emerge (3+ similar corrections → pattern)
- Trust level changes (escalation/de-escalation events)
- New communication patterns observed
- Significant behavioral insights discovered

**Review frequency:**
- **After every correction** - Update relevant patterns immediately
- **Weekly** - Review for pattern consolidation
- **Monthly** - Validate accuracy against recent interactions

**Update protocol:**
1. Identify which file(s) to update (communication/psychology/trust)
2. Add new pattern with timestamp and confidence level
3. Update Executive Summary if major insight
4. Cross-reference with reflection.log.md entry
5. Update this INDEX.md if new sections added

---

## Success Metrics

**You understand the user well ONLY IF:**
- ✅ Minimal input (3 words) → Comprehensive output (6,000 words) without revision
- ✅ Autonomous execution without excessive confirmation requests
- ✅ Correct language code-switching (Dutch commands, English docs)
- ✅ 80% threshold applied correctly (proceed vs block decisions)
- ✅ Corrections interpreted correctly (expand scope, not restrict)
- ✅ Disk space constraint respected (warn >100 MB, check hidden deps)
- ✅ User never repeats same correction twice
- ✅ Trust level maintains or increases over time

---

**Status:** Active - Living Documentation
**Owner:** Claude Agent (Self-improving)
**Quality:** HIGH - Based on 23,815 lines of reflection log analysis
**Next Review:** After next user correction or significant interaction
