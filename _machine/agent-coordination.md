# Agent Work Coordination Registry

**Purpose:** Prevent duplicate work and coordinate multi-agent activities across ClickUp tasks, GitHub PRs, and development work.

**CRITICAL:** All agents MUST check this file before starting ANY work.

---

## 🎯 Active Work (Check HERE First!)

| Agent | Status | ClickUp Task | GitHub PR | Branch | Objective | Phase | Updated (UTC) |
|-------|--------|--------------|-----------|--------|-----------|-------|---------------|
| current-session | DONE | 869c1w3d4 | - | - | Fix 404 error editing posts | ✅ Blocked - clarification requested | 2026-02-06T02:50:00Z |
| current-session | DONE | 869c1w210 | #507 | fix/post-edit-404-error | Pre-select categories/hooks | ✅ PR #507 created, worktree released | 2026-02-06T03:00:00Z |
| current-session | DONE | 869c1w38h | #508 | feature/wizard-success-page | Wizard success page | ✅ PR #508 created, worktree released | 2026-02-06T03:15:00Z |
| agent-001 | DONE | 869bz901c | #5 | feature/869bz901c-topic-page-image | Topic page image field | ✅ PR #5 created, ClickUp updated, worktree released | 2026-02-06T15:30:00Z |

**Legend:**
- **Agent**: agent-001, agent-002, etc.
- **Status**: PLANNING, CODING, TESTING, REVIEWING, MERGING, BLOCKED, DONE
- **ClickUp Task**: Task ID (e.g., 869c1xyz) or "-" if not applicable
- **GitHub PR**: PR number (e.g., #472) or "-" if creating new PR
- **Branch**: Git branch name or "-" if not started
- **Objective**: Brief description (max 50 chars)
- **Phase**: Current work phase
- **Updated**: Last update timestamp in UTC

---

## 📋 Coordination Protocol

### Before Starting ANY Work

```bash
# 1. Read coordination file
cat C:/scripts/_machine/agent-coordination.md

# 2. Check for conflicts:
#    - Is someone already working on the same PR?
#    - Is someone already working on the same ClickUp task?
#    - Is someone already merging what I want to merge?

# 3. If conflict detected → Coordinate or pick different work
# 4. If no conflict → Register your work immediately
```

### Registering New Work

Use the `register-work` skill or manually add entry:

```markdown
| agent-003 | PLANNING | 869c1abc | - | - | Implement feature X | Investigation | 2026-02-05T18:00:00Z |
```

### Updating Status

When changing phases (e.g., CODING → TESTING), update your entry:

```bash
# Find your line and update Status + Phase + Updated timestamp
```

### Completing Work

When done, move your entry to "Completed Today" section with outcome:

```markdown
| agent-003 | DONE | 869c1abc | #505 | feature/x | Implement feature X | ✅ PR #505 created | 2026-02-05T19:30:00Z |
```

---

## ✅ Completed Today

| Agent | ClickUp Task | GitHub PR | Objective | Outcome | Completed (UTC) |
|-------|--------------|-----------|-----------|---------|-----------------|
| agent-002 | - | #469 | Parent-child model | ✅ Merged to develop | 2026-02-05T15:52:25Z |
| agent-002 | - | #471 | Wizard backend logic | ✅ Merged to develop (fixed compilation errors) | 2026-02-05T17:51:30Z |
| agent-001 | - | #502 | Sub-posts WYSIWYG | ✅ Merged to develop | 2026-02-05T17:55:19Z |
| agent-004 | - | #493 | OAuth token refresh | ✅ Merged to develop | 2026-02-05T17:55:31Z |
| current-session | - | #472 | ParentPostManager UI (Phase 4) | ✅ Merged to develop (conflicts resolved) | 2026-02-05T22:51:47Z |
| current-session | - | #473 | Calendar Parent-Child Viz (Phase 5) | ✅ Merged to develop | 2026-02-05T23:19:27Z |
| current-session | - | #488 | AI Image Alt Text Generator | ✅ Merged to develop | 2026-02-05T23:21:00Z |
| current-session | - | #486 | Content Improvement Analyzer MVP | ✅ Merged to develop | 2026-02-05T23:23:00Z |
| current-session | - | #487 | Advanced Filtering (Sort & Quick Filters) | ✅ Merged to develop | 2026-02-05T23:23:00Z |
| current-session | - | develop | Frontend build broken (orphaned console.log) | ✅ Fixed 4 files, pushed to develop, updated PR #474 | 2026-02-06T00:45:00Z |
| current-session | - | #474, #505 | Fixed & merged PRs with passing builds | ✅ PR #474 & #505 merged to develop | 2026-02-06T01:45:00Z |
| current-session | - | #470, #475, #483 | Risk Level 1 PRs merge | ✅ All 3 Risk Level 1 PRs merged to develop | 2026-02-06T01:55:00Z |
| current-session | - | #495, #496 | Risk Level 2 PRs merge | ✅ Both Risk Level 2 PRs merged to develop | 2026-02-06T02:04:00Z |
| current-session | - | #490, #477, #497, #498, #499 | Risk Level 3 PRs merge | ✅ All 5 Risk Level 3 PRs merged to develop | 2026-02-06T02:16:00Z |
| current-session | - | #500, #501 | Risk Level 4 PRs merge | ✅ Both Risk Level 4 PRs merged to develop | 2026-02-06T02:18:00Z |
| current-session | - | #492 | Risk Level 5 PR merge | ✅ Infinite Improvement v2 (10K+ lines) merged to develop | 2026-02-06T02:20:00Z |

---

## 🚫 Common Conflicts to Prevent

### Duplicate PR Merges
**Problem:** Two agents try to merge the same PR simultaneously.

**Prevention:**
- Always check Active Work table before merging
- If someone is MERGING or REVIEWING a PR, do NOT touch it
- Register with REVIEWING status before starting PR review

### Duplicate ClickUp Task Work
**Problem:** Two agents implement the same ClickUp task.

**Prevention:**
- Check Active Work for ClickUp task ID before allocating worktree
- Register immediately after reading ClickUp task

### Branch Conflicts
**Problem:** Two agents work on the same branch.

**Prevention:**
- Worktrees.pool.md already prevents this
- Coordination file adds logical layer (intent to work)

---

## 🕐 Stale Work Detection

**Rule:** If `Updated` timestamp > 30 minutes ago and status unchanged → Work may be stale.

**Action for other agents:**
1. Check if agent's worktree still exists and has activity
2. Check ManicTime for agent activity
3. If truly stale: Mark as STALE in status column
4. After 1 hour stale: Another agent may take over

**Stale entry example:**
```markdown
| agent-005 | STALE (was CODING) | 869c1xyz | - | agent-005-feature | Feature Y | Last update 60min ago | 2026-02-05T16:00:00Z |
```

---

## 🔄 Status Definitions

| Status | Meaning | Typical Duration | Next Status |
|--------|---------|------------------|-------------|
| **PLANNING** | Reading code, researching, understanding requirements | 5-15 min | CODING |
| **CODING** | Writing code in worktree, making changes | 15-60 min | TESTING |
| **TESTING** | Building, running tests, verifying changes | 5-10 min | REVIEWING (own work) |
| **REVIEWING** | Reading PR code for merge decision | 5-15 min | MERGING |
| **MERGING** | Actively merging PR (develop merge, conflict resolution) | 5-10 min | DONE |
| **BLOCKED** | Waiting on dependency (another PR, user input, etc.) | Variable | (depends on blocker) |
| **DONE** | Work complete, move to "Completed Today" | - | - |

---

## 📝 Phase Definitions

Common phase values to use:
- **Investigation** - Understanding the problem
- **Design** - Planning implementation approach
- **Development** - Writing code
- **Build/Test** - Verifying compilation and tests
- **Code Review** - Reading PR changes
- **PR Merge** - Merging to develop
- **Cleanup** - Releasing worktree, updating tracking

---

## 🛠️ Integration with Existing Systems

### Worktree Pool (`worktrees.pool.md`)
- **Purpose:** Physical worktree allocation (which seat is BUSY/FREE)
- **Coordination file:** Logical work allocation (what work is being done)
- **Relationship:** Must allocate worktree (pool) AND register work (coordination)

### Instances Map (`instances.map.md`)
- **Purpose:** Track active agent instances
- **Coordination file:** More detailed - includes ClickUp tasks, PRs, phases
- **Future:** Consider merging instances.map into coordination file

### Activity Log (`worktrees.activity.md`)
- **Purpose:** Historical log of allocations and releases
- **Coordination file:** Current state snapshot
- **Relationship:** Activity log = historical, Coordination = real-time

---

## 🎯 Example Workflows

### Merging an Existing PR

```markdown
1. Check coordination file → No one working on PR #476 ✅
2. Register work:
   | agent-007 | REVIEWING | - | #476 | - | Review SVG fix PR | Code Review | 2026-02-05T18:10:00Z |
3. Allocate worktree (if needed for testing)
4. Review changes, merge develop, test
5. Update status:
   | agent-007 | MERGING | - | #476 | feature/svg-fix | Merge SVG fix PR | PR Merge | 2026-02-05T18:25:00Z |
6. Merge PR
7. Move to completed:
   | agent-007 | - | #476 | SVG fix PR | ✅ Merged to develop | 2026-02-05T18:30:00Z |
```

### Implementing ClickUp Task

```markdown
1. User requests: "Implement ClickUp task 869c1xyz"
2. Check coordination file → No one working on 869c1xyz ✅
3. Register work:
   | agent-003 | PLANNING | 869c1xyz | - | - | Implement auth feature | Investigation | 2026-02-05T18:00:00Z |
4. Allocate worktree
5. Update status:
   | agent-003 | CODING | 869c1xyz | - | agent-003-auth | Implement auth feature | Development | 2026-02-05T18:15:00Z |
6. Write code, test, commit
7. Create PR, update ClickUp with PR link
8. Update coordination:
   | agent-003 | DONE | 869c1xyz | #506 | agent-003-auth | Implement auth feature | ✅ PR #506 created | 2026-02-05T19:00:00Z |
```

---

## 🔧 Maintenance

### Daily Cleanup (End of Day)
- Move all DONE entries to archived log
- Clear "Completed Today" section
- Check for stale entries (>1 hour unchanged)

### Weekly Review
- Archive old completed entries to `agent-coordination-history.md`
- Review coordination patterns for improvements
- Update protocol based on lessons learned

---

**File Location:** `C:\scripts\_machine\agent-coordination.md`

**Last Updated:** 2026-02-05T18:00:00Z

**Maintained By:** All autonomous agents

**Critical Rule:** ALWAYS check this file before starting work. Failure to coordinate = wasted effort and merge conflicts.
