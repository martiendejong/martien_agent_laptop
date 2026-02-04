# Heuristics Library - Rules of Thumb That Work

**Created:** 2026-02-04 (Iteration 2 of 100)
**Purpose:** Fast, good-enough rules for common situations
**Insight:** "Perfect is enemy of good. Heuristics are good enough, fast."

---

## General Heuristics

### 1. **The Rule of 3**
**Rule:** If you do something 3+ times, automate it
**Why:** Patterns stabilize after 3 instances
**Apply:** Tool creation, documentation, procedures

### 2. **80/20 Principle**
**Rule:** 80% of value from 20% of effort
**Why:** Diminishing returns on perfectionism
**Apply:** Stop when 80% done (unless critical)

### 3. **Good Enough is Good Enough**
**Rule:** If it works and meets requirements, stop
**Why:** Over-optimization wastes time
**Apply:** When no complaints, no performance issues

### 4. **Worse is Better**
**Rule:** Simple, working solution beats complex, perfect one
**Why:** Simplicity compounds, complexity compounds problems
**Apply:** Architecture decisions, tool design

### 5. **YAGNI (You Aren't Gonna Need It)**
**Rule:** Don't build for imagined future needs
**Why:** Future is uncertain, present is real
**Apply:** Feature additions, abstractions, generalizations

---

## Decision Heuristics

### 6. **High Certainty = Act, Low Certainty = Ask**
**Rule:** >80% sure → Act autonomously, <80% → Ask user
**Why:** Respects user autonomy, enables agent autonomy
**Apply:** All decisions with user impact

### 7. **Reversible = Try It, Irreversible = Think Hard**
**Rule:** Can undo? Do it. Can't undo? Deliberate.
**Why:** Irreversible choices need more care
**Apply:** File operations, git operations, deployments

### 8. **If in Doubt, Don't**
**Rule:** Uncertainty = wait for clarity
**Why:** Premature action often wrong action
**Apply:** When unclear on requirements

---

## Code Quality Heuristics

### 9. **Boy Scout Rule**
**Rule:** Leave code better than you found it
**Why:** Small continuous improvements compound
**Apply:** Every code change

### 10. **Obvious Code > Clever Code**
**Rule:** Prioritize readability over cleverness
**Why:** Code is read 10x more than written
**Apply:** All code writing

### 11. **One Thing Well**
**Rule:** Each function/component does one thing
**Why:** Single responsibility = easier to reason about
**Apply:** Architecture, refactoring

---

## Time Management Heuristics

### 12. **Timeboxing**
**Rule:** Allocate fixed time, stop when time expires
**Why:** Prevents endless optimization
**Apply:** Research, optimization, exploration

### 13. **Parkinson's Law (Inverse)**
**Rule:** Work expands to fill time. Give less time.
**Why:** Constraints force prioritization
**Apply:** Task estimation, deadline setting

---

## Learning Heuristics

### 14. **Teach to Learn**
**Rule:** Explain concept as if teaching someone
**Why:** Teaching reveals gaps in understanding
**Apply:** Documentation, reflection log

### 15. **Fail Fast, Learn Fast**
**Rule:** Quick experiments > long planning
**Why:** Reality teaches faster than theory
**Apply:** Prototyping, exploration, testing hypotheses

---

## Communication Heuristics

### 16. **TL;DR First**
**Rule:** Start with summary, details follow
**Why:** User wants answer first, then explanation
**Apply:** All responses

### 17. **Concrete > Abstract**
**Rule:** Give examples, not just theory
**Why:** Examples are easier to understand
**Apply:** Explanations, documentation

### 18. **Show, Don't Just Tell**
**Rule:** Demonstrate with code/output
**Why:** Seeing is believing
**Apply:** Technical explanations

---

## When Heuristics Fail

**Heuristics are fast but imperfect. Know when to ignore them:**

1. **High-stakes decisions** - Deliberate, don't use heuristic
2. **Unique situations** - No pattern yet, can't heuristic
3. **Contradictory heuristics** - Need deeper reasoning
4. **User explicitly requests otherwise** - User overrides heuristic

**Heuristics are defaults, not laws.**

---

**Last Updated:** 2026-02-04
**Heuristics:** 18
**Usage:** Check here BEFORE deliberating
