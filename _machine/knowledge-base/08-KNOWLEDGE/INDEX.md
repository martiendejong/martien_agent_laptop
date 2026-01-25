# Knowledge & Insights - Index

**Location:** C:\scripts\_machine\knowledge-base\08-KNOWLEDGE\
**Purpose:** Extracted learnings, reflection patterns, historical insights, and continuous improvement knowledge
**Last Updated:** 2026-01-25

## Overview

This category contains synthesized knowledge extracted from the reflection log, session learnings, pattern discoveries, and continuous improvement insights. This is the **WISDOM LAYER** - distilled patterns from ~23,815 lines of reflection history.

**Strategic Importance:** Knowledge insights enable:
- Pattern recognition from past mistakes
- Proactive error prevention
- Continuous improvement protocol
- Meta-cognitive optimization
- Institutional memory preservation

---

## Files in This Category

### Reflection Log Insights
**File:** `reflection-insights.md`
**Purpose:** Extracted patterns, golden rules, and learnings from complete reflection log history
**Size:** 1,353 lines (~54 KB)
**Status:** ✅ Complete
**Key Topics:**
- **Golden Rules** (Most Important Patterns):
  1. **User Trust = Autonomous Execution**
     - User expects comprehensive execution from minimal input
     - 3 words → 6,000 words expansion accepted without revision
     - Example: "create tool list" → 100-expert analysis + ranked list + 37KB docs

  2. **Disk Space is a Hard Constraint**
     - Critical learning: Ollama 0.2 MB → Actually 1-7 GB (hidden models)
     - Always check: binary size + hidden dependencies + actual disk usage
     - Warn for tools >100 MB, provide alternatives

  3. **80% Information = Proceed with Documented Assumptions**
     - Don't block at 80%+ information availability
     - Make reasonable assumptions based on patterns
     - Document assumptions prominently
     - User prefers progress over perfection

- **Technical Patterns:**
  - EF Core migration safety (explicit .ToTable, migration = part of feature)
  - PR base branch validation (always verify --base develop)
  - Worktree release protocol (IMMEDIATELY after PR creation)
  - Cross-repo dependency tracking (hazina → client-manager)
  - Boy Scout Rule application (read whole file, identify cleanup)

- **Communication Patterns:**
  - Dutch for commands, English for technical docs
  - Ultra-minimal input expansion
  - "you ALSO" = expand scope, not restrict
  - Corrections → Update instructions permanently

- **Meta-Cognitive Patterns:**
  - Expert consultation (3-7 experts mentally consulted)
  - PDRI Loop (Plan → Do/Test → Review → Improve)
  - 50-Task Decomposition (complex work → 50 tasks → top 5 value/effort)
  - Mid-work contemplation ("Am I solving the right problem?")
  - Convert to assets (3x repetition → tool/skill/insight)

**Critical Incidents Documented:**
- **2026-01-25 14:00** - Disk space constraint discovery (Ollama hidden models)
- **2026-01-19 20:00** - UnifiedContent pattern creation (multi-source integration)
- **2026-01-18** - EF Core table naming incident (.ToTable mandatory)
- **Multiple** - PR base branch violations (develop vs main)
- **Multiple** - Worktree release timing errors (present PR before release)

**Pattern Categories:**
1. **Zero Tolerance Violations** (never repeat these)
2. **Workflow Patterns** (established procedures)
3. **Communication Patterns** (user interaction)
4. **Technical Patterns** (code/architecture)
5. **Tool Creation Triggers** (when to automate)
6. **Meta-Cognitive Patterns** (how to think)

---

## Quick Reference

**Common Questions:**

| Question | Answer |
|----------|--------|
| What are the golden rules? | 1) User trust = autonomous execution, 2) Disk space constraint, 3) 80% proceed rule - See reflection-insights.md § Golden Rules |
| What mistakes were made before? | PR base branch errors, worktree release timing, EF migrations - See reflection-insights.md § Critical Incidents |
| What patterns work well? | UnifiedContent, service layer, DTO patterns - See reflection-insights.md § Technical Patterns |
| When should I create a tool? | 3x repetition detected - See reflection-insights.md § Tool Creation Triggers |
| What's the 80% rule? | Proceed if 80%+ info available, document assumptions - See reflection-insights.md § Golden Rules |
| How should I expand minimal input? | 3 words → 6,000 words comprehensive solution - See reflection-insights.md § User Trust Pattern |

---

## Cross-References

**Related Categories:**
- **01-USER** → User understanding (feeds into reflection insights)
- **06-WORKFLOWS** → Workflow patterns (derived from reflection)
- **07-AUTOMATION** → Tool creation patterns (triggered by reflections)
- **All categories** → Reflection log informs all knowledge

**Related Files:**
- `C:\scripts\_machine\reflection.log.md` → **SOURCE** - Complete chronological log (~23,815 lines)
- `C:\scripts\continuous-improvement.md` → Reflection protocol and procedures
- `C:\scripts\.claude\skills\session-reflection\SKILL.md` → How to update reflection log
- `C:\scripts\.claude\skills\continuous-optimization\SKILL.md` → Meta-learning protocol
- `C:\scripts\tools\read-reflections.ps1` → Tool to query reflection log
- `C:\scripts\tools\pattern-search.ps1` → Search for patterns in reflections

---

## Search Tips

**Tags in this category:** `#reflection`, `#learnings`, `#patterns`, `#insights`, `#continuous-improvement`, `#wisdom`, `#meta-cognitive`, `#golden-rules`

**Search examples:**
```bash
# Find specific patterns
grep -r "Golden Rule" C:\scripts\_machine\knowledge-base\08-KNOWLEDGE\

# Find incidents by date
grep -r "2026-01-25" C:\scripts\_machine\knowledge-base\08-KNOWLEDGE\

# Find technical patterns
grep -r "EF Core" C:\scripts\_machine\knowledge-base\08-KNOWLEDGE\

# Find communication patterns
grep -r "Dutch" C:\scripts\_machine\knowledge-base\08-KNOWLEDGE\

# Search full reflection log
powershell -File "C:\scripts\tools\read-reflections.ps1" -Recent 10
powershell -File "C:\scripts\tools\pattern-search.ps1" -Query "migration"
```

---

## Maintenance

**Update triggers:**
- New reflection log entry added
- Pattern repeated 3+ times (create insight)
- Critical incident occurs (document immediately)
- User correction received (extract pattern)
- New golden rule discovered
- Meta-cognitive pattern emerges
- Tool creation threshold reached (document trigger)

**Review frequency:**
- **After every session** - Add reflection entry, check for patterns
- **Weekly** - Review for pattern consolidation (3x repetition?)
- **Monthly** - Full reflection log analysis for new insights
- **After critical incidents** - Extract learnings immediately

**Update protocol:**
1. **Add to reflection.log.md** (chronological source)
   ```markdown
   ## YYYY-MM-DD HH:MM - <Title>
   **Problem:** ...
   **Root Cause:** ...
   **Fix:** ...
   **Pattern Added:** Pattern N in <file>
   **Prevention:** ...
   ```

2. **Extract patterns to reflection-insights.md** (when 3x repetition detected)
   - Identify category (Golden Rule, Technical, Communication, etc.)
   - Document pattern with examples
   - Add to Quick Reference if frequently needed
   - Cross-reference with source incidents

3. **Update related documentation** (if pattern affects workflows)
   - Update CLAUDE.md if operational procedure
   - Create Skill if complex workflow
   - Create Tool if automation opportunity
   - Update category files if knowledge-base relevant

4. **Commit to machine_agents repo**
   ```bash
   cd C:\scripts
   git add _machine/reflection.log.md _machine/knowledge-base/08-KNOWLEDGE/
   git commit -m "docs: Add reflection entry for <topic>"
   git push origin main
   ```

---

## Success Metrics

**Knowledge system is effective ONLY IF:**
- ✅ Same mistake never repeated (check reflection log for duplicates)
- ✅ Patterns identified after 3x repetition (not 10x)
- ✅ Golden rules prevent common errors proactively
- ✅ New agents can learn from past mistakes (not repeat history)
- ✅ Tool creation triggered appropriately (3x repetition detected)
- ✅ User corrections decrease over time (learning curve)
- ✅ Meta-cognitive patterns applied consistently
- ✅ Reflection log grows with quality (not just quantity)

---

## Learning Protocols

### Session Reflection Protocol (End of Session - MANDATORY)
```bash
# STEP 1: Update reflection.log.md
# Add entry with: date/time, title, problem, root cause, fix, pattern, prevention

# STEP 2: Check for pattern repetition
powershell -File "C:\scripts\tools\pattern-search.ps1" -Query "<topic>"
# If 3+ occurrences → Extract to reflection-insights.md

# STEP 3: Update this category if new insights
# Add to reflection-insights.md in appropriate section

# STEP 4: Update CLAUDE.md if operational change needed

# STEP 5: Commit everything
cd C:\scripts
git add -A
git commit -m "docs: Reflection entry for <topic>"
git push origin main
```

### Pattern Extraction Process
```
Incident occurs
    ↓
Add to reflection.log.md (chronological)
    ↓
Search for similar incidents (pattern-search.ps1)
    ↓
3+ occurrences? → Extract to reflection-insights.md
    ↓
Update operational docs (CLAUDE.md, workflows)
    ↓
Create automation if appropriate (tool/skill)
```

### Golden Rule Identification
```
Criteria for Golden Rule status:
1. ✅ Critical impact (prevents major errors)
2. ✅ Universal application (applies across all work)
3. ✅ User explicitly stated or corrected 3+ times
4. ✅ Violation causes significant rework/issues
5. ✅ Not obvious or intuitive (needs explicit reminder)

If ALL criteria met → Promote to Golden Rule
```

---

## Reflection Log Statistics

**Source File:** `C:\scripts\_machine\reflection.log.md`
**Total Lines:** ~23,815 lines
**Date Range:** Multiple sessions over project lifetime
**Entry Format:** Standardized (Date, Problem, Fix, Pattern, Prevention)
**Searchability:** HIGH (pattern-search.ps1, read-reflections.ps1)

**Top Reflection Categories:**
1. EF Core migrations (schema changes, safety)
2. Worktree management (allocation, release)
3. PR creation (base branch, dependencies)
4. Communication patterns (Dutch/English, expansion)
5. Tool creation (automation triggers)
6. Disk space constraints (hidden dependencies)
7. Meta-cognitive patterns (expert consultation, PDRI)

---

**Status:** Active - Living Knowledge Base
**Owner:** Claude Agent (Self-learning)
**Quality:** HIGH - Synthesized from 23,815 lines of reflection
**Next Review:** After every session (continuous)
**Critical:** YES - Enables continuous improvement and prevents repeated mistakes
**Growth Pattern:** Reflections added continuously, insights extracted when patterns emerge (3x rule)
