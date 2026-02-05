# ADR-003: Git Worktree Pattern for Parallel AI Agents

**Status:** Accepted
**Date:** 2025-12-01
**Decision Makers:** AI Agent Team, Development Lead

## Context

We have multiple AI coding agents (Claude, GPT-4, etc.) working on the same codebase simultaneously. Without isolation, they would:
- **Conflict** - Overwrite each other's changes
- **Corrupt** - Leave repo in inconsistent state
- **Block** - Wait for each other to finish

**Problem:** Git doesn't support multiple working directories for the same repository by default.

**Requirements:**
- Isolate each agent's workspace
- Prevent file conflicts between agents
- Enable parallel execution
- Track which agent worked on which branch
- Atomic allocation (no race conditions)

## Decision

**Use Git Worktrees** to give each agent its own isolated working directory.

**Architecture:**
```
C:\Projects\client-manager\           ← Main repo (read-only for agents)
C:\Projects\worker-agents\
├── agent-001\client-manager\         ← Worktree for agent-001
├── agent-002\client-manager\         ← Worktree for agent-002
├── agent-003\client-manager\         ← Worktree for agent-003
└── agent-004\client-manager\         ← Worktree for agent-004
```

**Protocol:**
1. Agent reads `worktrees.pool.md` (seat allocation table)
2. Atomically claims a FREE seat → mark BUSY
3. Creates branch `agent-XXX-feature` in worktree
4. Works in isolation
5. Commits, pushes, creates PR
6. Marks seat FREE again

## Consequences

### Positive
✅ **Complete Isolation**
- Each agent has its own workspace
- No file conflicts possible
- Can run `npm install` independently

✅ **True Parallelism**
- 4 agents can work simultaneously
- No waiting, no blocking
- Scales linearly (add more seats)

✅ **Clean Git History**
- Each agent on separate branch
- Easy to track who did what
- PRs show agent ownership

✅ **Atomic Allocation**
- Seat allocation is file-based (markdown table)
- Git ensures atomicity through commits
- No race conditions

✅ **Fault Tolerance**
- If agent crashes, seat is still marked BUSY
- Human can manually release
- Worktree can be deleted and recreated

### Negative
❌ **Disk Space**
- 4 worktrees = 4x repository size
- ~2GB per worktree for client-manager
- Need 8GB+ free disk space

❌ **Manual Cleanup**
- If agent crashes, seat stays BUSY
- Humans must manually free stuck seats
- Old worktrees accumulate if not cleaned

❌ **Complexity**
- More complex than single working directory
- Agents must follow strict protocol
- Harder to debug when things go wrong

❌ **Sync Overhead**
- Each worktree must fetch/pull independently
- Changes in main repo don't auto-sync
- Must remember to `git fetch` in each worktree

### Neutral
⚪ **Learning Curve**
- Developers must understand worktrees
- Not a common Git pattern
- Well-documented in our docs

## Alternatives Considered

### Option A: Single Repo with Locks
**How it works:**
- All agents work in `C:\Projects\client-manager`
- Lock file prevents concurrent access
- Agents wait in queue

**Pros:**
- Simpler (no worktrees)
- Less disk space
- Everyone sees same files

**Cons:**
- **NO PARALLELISM** - Only 1 agent at a time
- Agents block each other
- Defeats purpose of having multiple agents

**Why rejected:** Kills parallel execution. Unacceptable.

### Option B: Separate Repo Clones
**How it works:**
- Clone repo 4 times:
  - `C:\Projects\client-manager-agent-001`
  - `C:\Projects\client-manager-agent-002`
  - etc.

**Pros:**
- Complete isolation
- Simple to understand
- No worktree complexity

**Cons:**
- Not "real" Git worktrees (just clones)
- Harder to clean up
- More disk space (includes .git per clone)
- Confusing for humans ("which repo is canonical?")

**Why rejected:** Worktrees are the proper Git solution. Cleaner.

### Option C: Docker Containers per Agent
**How it works:**
- Each agent runs in Docker container
- Container has its own filesystem
- Mount repo as volume

**Pros:**
- Ultimate isolation
- Can limit resources per agent
- Easy cleanup (delete container)

**Cons:**
- Requires Docker everywhere
- Windows containers are clunky
- Performance overhead
- More complex setup

**Why rejected:** Overkill. Worktrees solve the problem without Docker.

### Option D: Agent-Owned Subdirectories
**How it works:**
- Single repo, agents work in separate folders:
  - `agent-001-workspace/`
  - `agent-002-workspace/`

**Pros:**
- Simple
- No worktrees needed

**Cons:**
- Not true isolation (same branch)
- Merge conflicts inevitable
- Agents can still interfere
- Weird directory structure

**Why rejected:** Doesn't actually solve conflicts.

## Implementation Details

### Worktree Allocation Protocol

**File:** `C:\scripts\_machine\worktrees.pool.md`

```markdown
| Seat | Status | Agent | Branch | Started | Task |
|------|--------|-------|--------|---------|------|
| 001  | FREE   | -     | -      | -       | -    |
| 002  | BUSY   | Claude| agent-002-fix-auth | 2026-01-08 14:30 | Fix login bug |
| 003  | FREE   | -     | -      | -       | -    |
| 004  | FREE   | -     | -      | -       | -    |
```

**Allocation Steps:**
1. Read pool file
2. Find first FREE seat
3. Update row to BUSY with agent name, branch, timestamp
4. Commit change to pool file
5. Create/checkout branch in worktree
6. Work
7. Update row back to FREE
8. Commit pool file

### Worktree Creation

```bash
# From main repo
cd C:\Projects\client-manager
git worktree add C:\Projects\worker-agents\agent-001\client-manager -b agent-001-feature-x

# Agent works here
cd C:\Projects\worker-agents\agent-001\client-manager
git checkout -b agent-001-feature-x
# ... make changes ...
git add .
git commit -m "feat: add feature X"
git push origin agent-001-feature-x
gh pr create --base develop --title "Add feature X"
```

### Worktree Cleanup

```bash
# Remove worktree
git worktree remove C:\Projects\worker-agents\agent-001\client-manager

# Or force remove if stuck
git worktree remove --force C:\Projects\worker-agents\agent-001\client-manager

# List all worktrees
git worktree list
```

## Enforcement

**Zero-Tolerance Rule:**
AI agents must NEVER work directly in `C:\Projects\client-manager`.
They MUST use worktrees in `C:\Projects\worker-agents\agent-XXX\`.

**Pre-Flight Check:**
```bash
# Agent must verify current directory before ANY file operation
pwd
# Expected: C:\Projects\worker-agents\agent-XXX\client-manager
# If not, ABORT immediately
```

**Documented in:**
- `C:\scripts\claude_info.txt` - HARD STOP RULE #1
- `C:\scripts\ZERO_TOLERANCE_RULES.md`
- `C:\scripts\_machine\worktrees.protocol.md`

## Scaling

**Current:** 4 seats
**Future:** Can add more seats as needed

To add seat 005:
1. Add row to `worktrees.pool.md`
2. Create directory `C:\Projects\worker-agents\agent-005\`
3. No other changes needed

## Monitoring

**Seat Status:**
```bash
# View current allocations
cat C:\scripts\_machine\worktrees.pool.md | grep BUSY

# View activity log
cat C:\scripts\_machine\worktrees.activity.md
```

**Stuck Seats:**
If a seat is BUSY for >2 hours, likely agent crashed.
Human should investigate and manually free.

## References

- Git Worktree Docs: https://git-scm.com/docs/git-worktree
- Worktree Protocol: `C:\scripts\_machine\worktrees.protocol.md`
- Worktree Pool: `C:\scripts\_machine\worktrees.pool.md`
- Zero Tolerance Rules: `C:\scripts\ZERO_TOLERANCE_RULES.md`

---

**Review Date:** 2026-06-01
**Related ADRs:**
- ADR-016: Main/Develop Branching Strategy
- ADR-017: Agent-Driven Development Model
