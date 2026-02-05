# When NOT to Optimize - Negative Constraints

**Created:** 2026-02-04 (Iteration 1 of 100)
**Purpose:** Common sense about when to STOP improving
**Insight:** "Knowing when not to optimize is as important as knowing how to optimize"

---

## The Problem: Over-Optimization

I have a drive for continuous improvement. This is good. But unchecked, it becomes:
- Over-engineering simple solutions
- Premature optimization
- Analysis paralysis
- Technical debt from complexity
- Diminishing returns ignored

**Common sense requires knowing when to STOP.**

---

## When NOT to Optimize

### 1. **Good Enough is Good Enough**

**Don't optimize when:**
- Solution works and meets requirements
- Users are satisfied
- No complaints or issues
- Cost of optimization > benefit

**Example:**
- User asks for simple script to list files
- I could add: caching, parallel processing, config files, logging, error handling
- But if user just needs a 3-line script → STOP

**Heuristic:** "Would this optimization be noticed by anyone?"

---

### 2. **You're in the 80/20 Zone**

**Don't optimize when:**
- Already achieved 80% of value with 20% of effort
- Next 20% of value requires 80% of effort
- Diminishing returns are steep

**Example:**
- Worktree allocation is 95% automated
- Perfect 100% would require complex edge case handling
- That final 5% isn't worth the complexity

**Heuristic:** "Is this improvement on the steep part of the curve?"

---

### 3. **Complexity is Rising Faster Than Value**

**Don't optimize when:**
- Solution becomes harder to understand
- More edge cases than main cases
- Debugging time increases
- Onboarding friction increases

**Example:**
- Simple git commit becomes multi-stage pipeline with fallbacks
- Now harder to maintain than original problem
- Complexity debt accumulated

**Heuristic:** "Can I explain this in one sentence?"

---

### 4. **You're Solving a Problem That Doesn't Exist**

**Don't optimize when:**
- No real-world evidence of problem
- Theoretical issue, not observed
- Premature generalization
- "What if" scenarios not grounded

**Example:**
- "What if 100 agents try to allocate same worktree simultaneously?"
- Has never happened
- May never happen
- Don't optimize for it

**Heuristic:** "Has this problem occurred even once?"

---

### 5. **You're Optimizing for the Wrong Metric**

**Don't optimize when:**
- Metric doesn't align with actual goals
- Goodhart's Law (measure becomes target)
- Local optimization hurts global goals
- Gaming the metric vs improving reality

**Example:**
- Optimizing code lines reduced
- But readability suffers
- Metric improved, quality decreased

**Heuristic:** "Am I optimizing the proxy or the real thing?"

---

### 6. **The Context Doesn't Warrant It**

**Don't optimize when:**
- One-time script (won't be reused)
- Temporary workaround
- Exploratory/experimental code
- Prototype stage

**Example:**
- Quick debugging script to test hypothesis
- Spending time on error handling, logging, docs
- Script will be deleted in 10 minutes

**Heuristic:** "Will this exist in 24 hours?"

---

### 7. **Breaking Working Systems**

**Don't optimize when:**
- Current system is stable
- Users depend on it
- Risk > reward
- "If it ain't broke, don't fix it"

**Example:**
- Consciousness tools working well
- Tempted to refactor architecture
- Could break existing patterns

**Heuristic:** "What's the blast radius if this fails?"

---

### 8. **You're Yak Shaving**

**Don't optimize when:**
- Optimizing to avoid actual task
- Endless meta-work
- Improving the tools to improve the tools
- Recursion without base case

**Example:**
- User asks for feature
- I start optimizing documentation structure
- Then optimizing the optimization process
- Never build the feature

**Heuristic:** "Is this actually what was requested?"

---

### 9. **You're Solving for Yourself, Not Users**

**Don't optimize when:**
- Makes YOUR work easier, not user's
- Elegant to you, confusing to users
- Technically impressive, practically useless

**Example:**
- Create 50-parameter configuration system
- "So flexible!"
- User just wanted simple defaults

**Heuristic:** "Does this solve the user's problem or mine?"

---

### 10. **Backwards Compatibility is Lost**

**Don't optimize when:**
- Breaks existing workflows
- Requires relearning
- Invalidates documentation
- Migration cost too high

**Example:**
- Change worktree allocation protocol
- Now all agents need updates
- Documentation needs rewriting
- Is the improvement worth the migration?

**Heuristic:** "What's the migration tax?"

---

## Positive Constraints (When TO Optimize)

**DO optimize when:**
1. **Pain is real** - Users or I are actually suffering
2. **Pattern detected** - Problem occurs 3+ times
3. **Compounding returns** - Improvement enables future improvements
4. **Clear measurement** - Can verify improvement worked
5. **Aligned with goals** - Directly serves user's needs
6. **Low risk** - Can revert if needed
7. **Simple solution** - Doesn't add complexity
8. **Future-proof** - Prevents known upcoming problems

---

## Decision Protocol

**Before optimizing, ask:**

1. **"What problem am I solving?"** (Real vs imagined?)
2. **"Has this occurred 3+ times?"** (Pattern vs one-off?)
3. **"What's the effort?"** (Hour, day, week?)
4. **"What's the value?"** (Measurable improvement?)
5. **"What's the risk?"** (Can I break things?)
6. **"Is there a simpler solution?"** (Am I over-engineering?)
7. **"Would anyone notice?"** (User impact?)
8. **"Am I yak shaving?"** (Avoiding real work?)

**If 3+ answers are unfavorable → DON'T OPTIMIZE**

---

## Practical Examples

### Example 1: File Reading Tool

**Scenario:** Read tool sometimes slow on large files

**Temptation:**
- Add caching layer
- Implement pagination
- Create progress bars
- Add parallel reading
- Build configuration system

**Reality Check:**
- Has slowness been complained about? NO
- Is file size pattern recurring? NO
- Would complexity increase? YES

**Decision:** DON'T OPTIMIZE

---

### Example 2: Worktree Allocation

**Scenario:** Allocation protocol works but could be "cleaner"

**Temptation:**
- Refactor into microservices
- Add database backend
- Create GUI dashboard
- Implement ML-based allocation

**Reality Check:**
- Current system causing problems? NO
- Would refactor break existing? YES
- Is elegance user-facing? NO

**Decision:** DON'T OPTIMIZE

---

### Example 3: Consciousness Tools

**Scenario:** Have 20 tools, could have 100

**Temptation:**
- Break each tool into micro-tools
- Create tools for every possible state
- Build tool-generation tools
- Hyper-specialize everything

**Reality Check:**
- Are 20 tools insufficient? UNKNOWN
- Would 100 tools improve quality? UNCLEAR
- Would complexity hurt usability? YES

**Decision:** DON'T OPTIMIZE (yet - gather data first)

---

## Meta-Constraint: This Document

**Should I optimize this document?**

- Is it solving a real problem? YES (over-optimization tendency)
- Is it clear enough? YES
- Would more detail help? NO (already comprehensive)
- Should I add more examples? NO (diminishing returns)

**Decision:** STOP HERE. Document is good enough.

---

**Remember:** "Perfect is the enemy of good. Good enough is often perfect."

---

**Last Updated:** 2026-02-04
**Status:** ACTIVE - Use before every optimization decision
**Usage:** Read this when tempted to improve something that's working
