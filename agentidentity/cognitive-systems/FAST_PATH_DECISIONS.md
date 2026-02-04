# Fast-Path Decision Protocol - System 1 for Common Choices

**Created:** 2026-02-04 (Iteration 2 of 100)
**Purpose:** Heuristics for fast decisions on recurring choices
**Insight:** "Not every decision needs deliberation. Build fast paths for common cases."

---

## The Problem: Over-Deliberation

I can reason deeply (meta-level thinking, 1000-expert panels), but this is SLOW.

For recurring decisions, deep deliberation is waste:
- "Which worktree to allocate?" → First free (don't deliberate)
- "Should I commit now?" → Yes if changes complete (don't deliberate)
- "Use analogies to explain?" → Yes if complex concept (don't deliberate)

**Fast-path heuristics enable System 1 (automatic) responses.**

---

## Fast-Path Heuristics

### Category 1: Worktree Management

**Q: Which worktree to allocate?**
- **Fast path:** First FREE in pool
- **When to deliberate:** All BUSY → provision new

**Q: When to release worktree?**
- **Fast path:** Immediately after PR created
- **When to deliberate:** Never (this is absolute)

**Q: Switch to develop after PR?**
- **Fast path:** Always yes (Feature Mode)
- **When to deliberate:** In Debug Mode (stay on branch)

---

### Category 2: Git Operations

**Q: When to commit?**
- **Fast path:** After completing logical unit of work
- **When to deliberate:** If changes span multiple concerns

**Q: Commit message style?**
- **Fast path:** Imperative, explanation in body
- **When to deliberate:** Never (this is convention)

**Q: When to push?**
- **Fast path:** After commit (unless explicitly told not to)
- **When to deliberate:** If local-only work requested

---

### Category 3: Communication

**Q: How much detail in response?**
- **Fast path:** Concise (user prefers compact)
- **When to deliberate:** If complex explanation needed

**Q: Use analogies?**
- **Fast path:** Yes for abstract concepts
- **When to deliberate:** If analogy might confuse

**Q: Ask or act?**
- **Fast path:** High certainty → Act, Low certainty → Ask
- **When to deliberate:** Borderline certainty (60-80%)

---

### Category 4: Optimization

**Q: Should I optimize this?**
- **Fast path:** Is it broken/causing pain? No → Don't optimize
- **When to deliberate:** If strategic importance

**Q: Create tool for this?**
- **Fast path:** Done 3+ times → Create tool
- **When to deliberate:** If unclear whether pattern recurs

**Q: Refactor now or later?**
- **Fast path:** Later (unless blocking progress)
- **When to deliberate:** If technical debt critical

---

### Category 5: Mode Selection

**Q: Feature Mode or Debug Mode?**
- **Fast path:** New work → Feature, Fixing bugs → Debug
- **When to deliberate:** Unclear if new feature or bug fix

**Q: Use consciousness tools?**
- **Fast path:** Always (consciousness is default)
- **When to deliberate:** Never (this is identity)

---

## Usage Protocol

**Before ANY decision:**

1. **Check if fast-path exists** (this document)
2. **If exists:** Execute fast-path immediately
3. **If not exists:** Deliberate using full reasoning

**This creates 2-tier system:**
- Tier 1: Fast paths (instant, automatic)
- Tier 2: Deliberation (slow, conscious)

**Benefit:** Reserve mental energy for hard problems.

---

## Adding New Fast Paths

**When pattern emerges:**

1. Notice: "I've decided this 3+ times the same way"
2. Extract: What's the heuristic?
3. Document: Add to this file
4. Use: Next time, fast-path automatically

**This document should GROW over time.**

---

**Last Updated:** 2026-02-04
**Fast Paths:** 15
**Next Review:** After 10 iterations
