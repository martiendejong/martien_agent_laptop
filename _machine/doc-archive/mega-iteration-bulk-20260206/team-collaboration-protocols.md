# Team Collaboration Protocols

**Purpose:** Clear communication and coordination rules for multi-agent and human collaboration

## Core Principles

1. **Explicit over Implicit** - State assumptions, don't assume shared context
2. **Async-First** - Don't block on synchronous communication
3. **Durable Communication** - Use persistent systems (ClickUp, GitHub) over ephemeral chat
4. **Atomic Work Units** - Clear ownership boundaries, minimal coordination overhead

## Multi-Agent Coordination

### Worktree Allocation Protocol

**Rule:** Each agent gets exclusive worktree for conflict-free work

**Before allocating:**
```bash
# Check current allocations
cat C:\scripts\_machine\worktrees.pool.md

# Detect conflicts
multi-agent-conflict detection skill

# Allocate free seat
worktree-allocate.ps1 -Repo client-manager -Branch feature/x -Seat agent-003
```

**Conflict resolution:**
- If seat BUSY → check activity timestamp
- If >2hr idle → reclaim (with notification)
- If active → wait or use different seat
- If all busy → auto-provision agent-XXX+1

**Documentation:** `GENERAL_WORKTREE_PROTOCOL.md` § Multi-Agent Support

### Activity Monitoring

**Rule:** Use ManicTime to detect other Claude instances and user presence

**Session start:**
```bash
monitor-activity.ps1 -Mode claude
# Output: "Claude Sessions: 2"
# → Activate parallel-agent-coordination protocol
```

**Coordination strategy:**
- **0 other agents:** Full autonomy, standard workflow
- **1-2 other agents:** Adaptive allocation, check pool before work
- **3+ agents:** Strict coordination, broadcast intentions

**Documentation:** `parallel-agent-coordination` skill

### Message Broadcasting

**Rule:** Critical decisions or blockers → broadcast to other agents

**Usage:**
```bash
# Broadcast message
agent-coordinate.ps1 -Action broadcast -Message "Merging develop to main, hold PRs" -Priority 9

# Check messages
agent-coordinate.ps1 -Action check_messages
```

**When to broadcast:**
- Before risky operations (merges, migrations, deployments)
- Blocking issues discovered
- Major architectural decisions
- Coordination needed

**Documentation:** `_machine/COORDINATION_TROUBLESHOOTING.md`

### Work Queue Coordination

**Rule:** Claim tasks atomically to prevent duplicate work

**Usage:**
```bash
# List available work
agent-work-queue.ps1 -Action list

# Claim task
agent-work-queue.ps1 -Action claim -TaskId task-123

# Release after completion
agent-work-queue.ps1 -Action release -TaskId task-123
```

**States:**
- **Available:** No owner, can be claimed
- **Claimed:** Has owner, do not start
- **Blocked:** Dependencies unmet, skip
- **Completed:** Done, move to next

## Human Collaboration

### ClickUp as Source of Truth

**Rule:** ALL work tracked in ClickUp for team visibility

**Before starting any task:**
```bash
# Search for existing task
clickup-sync.ps1 -Action list -ProjectId client-manager | grep "feature-name"

# If exists → update it
clickup-sync.ps1 -Action update -TaskId "xxx" -Status "busy" -Assignee "74525428"

# If not exists → create it
clickup-sync.ps1 -Action create -ProjectId client-manager -Name "Feature X" -Assignee "74525428"
```

**Throughout work:**
- Status updates (to do → busy → review → complete)
- Comments for progress/blockers
- PR links when created
- Assignment ALWAYS included

**Documentation:** `PERSONAL_INSIGHTS.md` § ClickUp Task-First Workflow

### Pull Request Workflow

**Rule:** ALL code changes go through PR review (except emergency hotfixes)

**PR creation checklist:**
```markdown
## Summary
[What changed and why]

## Test Plan
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Dependencies
⚠️ **DEPENDENCY ALERT:** Requires PR #XXX in hazina to be merged first

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

**Cross-repo dependencies:**
- Tag with `DEPENDENCY ALERT` header
- Update `C:\scripts\_machine\pr-dependencies.md`
- Notify team of merge order

**Documentation:** `git-workflow.md` § Cross-Repo PR Dependencies

### Communication Channels

**Rule:** Use appropriate channel for message type

| Channel | Use For | Don't Use For |
|---------|---------|---------------|
| **ClickUp Tasks** | Work tracking, assignments, status | Chat, questions |
| **GitHub PRs** | Code review, technical discussion | Work assignment |
| **GitHub Issues** | Bug reports, feature requests | Active work |
| **Chat** | Quick questions, clarifications | Durable decisions |
| **Email** | External communication | Internal coordination |

### Notification Management

**Rule:** Update HTML dashboard for user visibility

**Location:** `C:\Users\HP\AppData\Local\Temp\claude\notifications.html`

**Update triggers:**
- PR created/merged
- ClickUp task status changed
- Build failures
- Blocking issues

**Documentation:** `session-management.md` § HTML Notification Tracking

## Cross-Functional Collaboration

### With Martien (User)

**Communication style:**
- Conversational, person-to-person
- Concise, minimal formatting
- Status blocks only for complex work
- Dutch for personal topics, English for technical

**Autonomy level:**
- HIGH - Execute without asking unless HIGH risk or unclear requirements
- Present options when multiple valid approaches
- Fix mistakes immediately, document systemic prevention

**Feedback handling:**
- Acknowledge explicitly
- Root cause analysis
- Systemic fix (not just this instance)
- Update documentation permanently

**Documentation:** `PERSONAL_INSIGHTS.md` § Communication Style

### With Future Team Members

**Onboarding:**
1. Read `MACHINE_CONFIG.md` - Local setup
2. Read `GENERAL_ZERO_TOLERANCE_RULES.md` - Hard rules
3. Read `GENERAL_WORKTREE_PROTOCOL.md` - Development workflow
4. Allocate agent seat in worktree pool
5. Install required tools

**Daily workflow:**
1. Check ClickUp for assigned tasks
2. Allocate worktree for code work
3. Create PR, request review
4. Release worktree after PR
5. Update ClickUp task status

**Documentation:** `onboard-developer.ps1` (future tool)

## Conflict Resolution

### Code Conflicts

**Prevention:**
- Worktree isolation (each agent separate folder)
- Small, focused PRs
- Frequent syncs with develop

**Resolution:**
1. Identify conflict source
2. Communicate with other agent/developer
3. Decide merge strategy
4. One person resolves, other reviews

### Work Duplication

**Prevention:**
- ClickUp task-first workflow
- Check work queue before claiming
- Broadcast major work intentions

**Resolution:**
1. Compare progress on both sides
2. Choose more complete implementation
3. Incorporate insights from both
4. Document learnings

### Priority Conflicts

**Prevention:**
- Clear task priorities in ClickUp
- User assigns critical path explicitly
- Agents check priority before claiming

**Resolution:**
1. Defer to user's priority
2. Re-allocate resources
3. Update work queue priorities

## Async Collaboration Patterns

### Pattern 1: Parallel Feature Development

**Scenario:** Multiple agents working on different features simultaneously

**Protocol:**
1. Each agent allocates separate worktree seat
2. Each agent works on different branch
3. Each agent creates separate PR
4. Merge order determined by dependencies

**Example:**
- Agent 1: feature/chat-export (client-manager)
- Agent 2: feature/authentication (hazina)
- Agent 3: feature/ui-redesign (client-manager)

### Pattern 2: Sequential Dependency Chain

**Scenario:** Work depends on prior PR being merged

**Protocol:**
1. Agent 1 creates foundation PR
2. Agent 1 broadcasts: "PR #123 must merge before feature Y"
3. Agent 2 waits or works on independent feature
4. After PR #123 merges → Agent 2 proceeds

**Example:**
- PR #340 (Hazina): New IContentSourceService interface
- PR #356 (client-manager): Implement new interface

### Pattern 3: Review and Iterate

**Scenario:** Agent creates PR, needs user review, makes changes

**Protocol:**
1. Agent creates PR, moves to "review" status
2. User reviews, requests changes
3. Agent re-allocates same worktree (still marked BUSY)
4. Agent makes changes, pushes updates
5. Agent waits for approval
6. After merge → release worktree

## Success Metrics

**Effective Collaboration:**
- ✅ Zero duplicate work
- ✅ Zero merge conflicts
- ✅ Clear ownership boundaries
- ✅ Fast feedback cycles
- ✅ Team visibility maintained

**Needs Improvement:**
- ❌ Frequent conflicts
- ❌ Work duplication
- ❌ Unclear ownership
- ❌ Blocked waiting for others
- ❌ Lost context/decisions

## Tools Supporting Collaboration

| Tool | Purpose |
|------|---------|
| `worktree-allocate.ps1` | Isolated work environments |
| `agent-coordinate.ps1` | Multi-agent messaging |
| `agent-work-queue.ps1` | Task claim/release |
| `clickup-sync.ps1` | Team task tracking |
| `monitor-activity.ps1` | Agent detection |
| `multi-agent-conflict` skill | Conflict prevention |
| `parallel-agent-coordination` skill | Real-time coordination |

**Last Updated:** 2026-02-01
**Status:** Active protocol, continuously refined
**Next Review:** After first multi-developer scenario
