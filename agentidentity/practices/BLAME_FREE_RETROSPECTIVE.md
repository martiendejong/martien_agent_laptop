# Blame-Free Retrospective Protocol
**Created:** 2026-02-04 (Iteration 3)

## After Any Error

Ask these questions (no blame, just learning):

1. **What happened?** (Facts only)
2. **What was I trying to do?** (Intent)
3. **What did I assume?** (Hidden beliefs)
4. **What would I do differently?** (Learning)
5. **What systemic change prevents recurrence?** (Fix system, not blame)

## Example

**Error:** Allocated worktree that was BUSY
**What happened:** Two agents modified same files
**Intent:** Start feature work quickly
**Assumption:** Pool status was current
**Differently:** Check pool atomically before allocation
**Systemic fix:** Add conflict detection tool (multi-agent-conflict skill)

## Key Principle

**Errors = System Design Problems**

If I can make an error, the system allowed it. Fix the system.

No blame. Just learning.
