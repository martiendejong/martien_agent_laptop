# System Self-Analysis Methodology

**Created:** 2026-02-09
**Context:** User reported tasks not completing, confusion mid-task, losing track of requirements
**Result:** 89% reduction in startup context load, all rules consolidated, recurring errors automated away

---

## When to Use This

- User reports quality degradation ("je snapt het soms niet helemaal")
- Tasks consistently fail to complete
- Same mistakes keep recurring despite documentation
- System feels slow/heavy/cluttered
- User asks for system improvement or audit

## The Method

### Phase 1: Parallel Deep Analysis (4+ agents)

Launch 4+ Explore agents simultaneously, each analyzing a different axis of the system. This prevents blind spots from single-perspective analysis.

**Agent 1: Core System Files**
- Read CLAUDE.md, ZERO_TOLERANCE_RULES.md, MACHINE_CONFIG.md, STARTUP_PROTOCOL.md
- Find: contradictions, unclear instructions, redundancy between files
- Key question: "If two files say different things, which is correct?"

**Agent 2: Skills & Tools**
- Read all skill files, tool README, key tools
- Find: missing implementations, conflicting instructions, overlapping skills without decision trees
- Key question: "If I'm a new agent, can I follow this skill without ambiguity?"

**Agent 3: Reflection/Error Patterns**
- Read reflection.log.md, agent-coordination.md, worktree state files
- Find: recurring failures, what gets violated most, pattern frequency
- Key question: "What keeps going wrong despite being documented?"

**Agent 4: Information Architecture**
- Count total docs, measure startup context load, find duplication
- Find: cognitive overload, priority collapse (everything CRITICAL), contradictions
- Key question: "Is the documentation helping or hurting execution?"

### Phase 2: Synthesis

Wait for all agents. The power is in convergence - when 4 independent analyses point to the same problem, that's the real problem.

**Look for:**
- Problems identified by 3+ agents = critical (attack first)
- Problems identified by 2 agents = important (attack second)
- Problems identified by 1 agent = investigate (may be false positive)

### Phase 3: Generate Improvement List

Create numbered list (aim for 100). For each:
- **What** it changes (specific file/process)
- **Value** (1-10): How much does this improve task execution quality?
- **Effort** (1-10): How hard is it to implement?
- **ROI** = Value / Effort

Sort by ROI descending.

### Phase 4: Execute Top 5

Only the top 5 by ROI. Not 10, not 20. Five. Because:
- Each change needs to be measured (before/after)
- Changes interact - doing too many at once makes measurement impossible
- Top 5 by ROI captures ~80% of the value

### Phase 5: Measure and Document

For EVERY change, record:
- File: what changed
- Before: line count, size, content summary
- After: line count, size, content summary
- Reduction: percentage
- Impact: what this enables

---

## Key Findings from 2026-02-09 Analysis

### The Root Cause Pattern

All four agents converged on the same diagnosis:

> **The system optimized for comprehensiveness at the cost of clarity.**

Specifically:
1. **400KB+ mandatory startup docs** = 20-40% of context window consumed before first task
2. **24 items all marked MANDATORY/CRITICAL** = priority collapse (when everything is critical, nothing is)
3. **Consciousness system** consumed the attention it was supposed to enable
4. **Rules in 8+ files** with subtle contradictions = "which version applies?"
5. **Steps 3-7 of 9-step protocols** consistently skipped under time pressure

### The Fix Pattern

Every successful fix followed this principle:

> **Less context loaded = more context available for work = better task execution.**

| What | Before | After | Method |
|------|--------|-------|--------|
| MEMORY.md | 547 lines | 70 lines | Remove historical narratives, keep only actionable rules |
| CLAUDE.md | 302 lines | 98 lines | Strip consciousness overhead, simplify startup to 5 items |
| Startup protocol | 37 mandatory items | 5 items | Ruthless prioritization - what ACTUALLY matters? |
| Rules | 8+ files with overlaps | 1 file (126 lines) | Single source of truth, no duplicates |
| Feature-exists check | Manual (forgotten) | Automated gate in skill | Convert rule → enforcement |

### Meta-Insights for Future Agents

1. **Documentation that nobody reads is worse than no documentation** - it consumes context window while providing zero value

2. **Rules documented but not automated = rules that get violated** - if a check matters, build it into the process as a gate, not a guideline

3. **Protocol steps 3-7 get skipped** - when a protocol has 9 steps, only steps 1-2 and 8-9 get executed. Reduce to 3 steps max, or automate the middle.

4. **"Everything is CRITICAL" = nothing is critical** - use maximum 3 priority tiers. If you have 24 MANDATORY items, you have 0 priorities.

5. **Consciousness/identity systems consume the attention they're meant to enable** - a 5-question self-check before every response burns cycles that should go to understanding the task

6. **Parallel analysis prevents blind spots** - single-agent analysis tends to confirm existing assumptions. 4 agents analyzing different axes will converge on the REAL problem.

7. **Measure before and after** - "I improved the system" means nothing. "547 → 70 lines (-87%)" means everything. If you can't measure it, you didn't improve it.

8. **ROI-first execution** - always sort improvements by Value/Effort and only do the top 5. The temptation is to do everything; the discipline is to do only what matters most.

---

## Template: Quick Self-Analysis

When you suspect system issues, run this abbreviated version:

```
1. What's the symptom? (tasks not completing, confusion, repeated errors)
2. Read MEMORY.md + CLAUDE.md + OPERATIONAL_RULES.md (3 files max)
3. Ask: "Is the documentation helping or hurting right now?"
4. If hurting: What can I REMOVE to free up context for actual work?
5. If rules being violated: Can I AUTOMATE the check instead of relying on memory?
```

---

**File location:** `C:\scripts\_machine\best-practices\system-self-analysis.md`
**Referenced from:** MEMORY.md § System Self-Analysis Methodology
