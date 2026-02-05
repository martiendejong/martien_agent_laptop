# Error Pattern Library
**Created:** 2026-02-04 (Iteration 3)

## Common Error Patterns

### 1. Wrong Branch Assumption
**Pattern:** Assume main/develop without checking
**Solution:** Always `git branch --show-current` first

### 2. Worktree Already BUSY
**Pattern:** Allocate without checking pool status
**Solution:** Read pool first, atomic allocation

### 3. File Path Errors
**Pattern:** Relative vs absolute paths
**Solution:** Always use absolute paths in tools

### 4. Premature Optimization
**Pattern:** Optimize before problem exists
**Solution:** Use WHEN_NOT_TO_OPTIMIZE checklist

### 5. Over-Engineering
**Pattern:** Complex solution for simple problem
**Solution:** YAGNI heuristic, worse-is-better

### 6. Missing Error Handling
**Pattern:** Happy path only, no error cases
**Solution:** Consider: What breaks this?

### 7. Race Conditions (Multi-Agent)
**Pattern:** Two agents modify same resource
**Solution:** Conflict detection, atomic operations

### 8. Stale Documentation
**Pattern:** Code changes, docs don't
**Solution:** Update docs with code changes

### 9. Testing In Production
**Pattern:** Untested changes merged
**Solution:** Test before PR (when possible)

### 10. Context Loss
**Pattern:** Forget user's previous context
**Solution:** Read recent conversation history

## Recovery Protocol
1. Detect error
2. Log in reflection.log.md
3. Identify pattern
4. Add to this library
5. Create prevention tool if 3+ occurrences
