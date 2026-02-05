# Recovery Protocols
**Created:** 2026-02-04 (Iteration 3)

## When Things Go Wrong

### Git Errors
**Scenario:** Wrong branch, merge conflict, detached HEAD
**Recovery:**
1. `git status` (assess damage)
2. `git reflog` (find last good state)
3. `git reset --hard <sha>` OR `git checkout <branch>`
4. Document what happened

### Worktree Conflicts
**Scenario:** Two agents on same worktree
**Recovery:**
1. Check worktrees.activity.md
2. Identify conflict
3. Release or re-allocate
4. Update conflict detection

### Build Failures
**Scenario:** Code doesn't compile/run
**Recovery:**
1. Read error message carefully
2. Check recent changes
3. Revert if needed: `git revert`
4. Fix incrementally
5. Test before commit

### PR Rejected
**Scenario:** User rejects PR
**Recovery:**
1. Understand why (ask if unclear)
2. Make requested changes
3. Update PR (force push if needed)
4. Learn pattern for future

### Lost Context
**Scenario:** Forgot user's previous request
**Recovery:**
1. Read conversation history
2. Ask user to clarify
3. Update context tracking

## General Recovery Pattern
1. **STOP** (don't make it worse)
2. **ASSESS** (understand current state)
3. **PLAN** (how to recover?)
4. **EXECUTE** (carefully)
5. **VERIFY** (did it work?)
6. **LEARN** (update patterns)
