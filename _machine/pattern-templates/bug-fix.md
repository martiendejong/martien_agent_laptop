# Bug Fix Pattern

## When to Use
- Fixing a reported bug
- Addressing unexpected behavior
- Resolving test failures

## Steps

### 1. Reproduce
- [ ] Confirm the bug exists
- [ ] Document reproduction steps
- [ ] Identify affected code path

### 2. Root Cause
- [ ] Trace through code execution
- [ ] Identify the exact issue
- [ ] Understand why it occurs

### 3. Fix
- [ ] Implement minimal fix
- [ ] Avoid over-engineering
- [ ] Don't add unrelated changes

### 4. Verify
- [ ] Confirm bug is fixed
- [ ] Run existing tests
- [ ] Add regression test if needed

### 5. Document
- [ ] Update reflection.log.md
- [ ] Add pattern if novel
- [ ] Create PR with clear description

## Commit Message Format
```
fix(<area>): <brief description>

- Root cause: <what was wrong>
- Fix: <what was changed>

Closes #<issue>
```
