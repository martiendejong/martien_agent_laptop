# Agent Role Definitions

**System:** Jengo Multi-Agent Coordination
**Created:** 2026-02-20
**Purpose:** Define specialized agent capabilities and constraints

---

## Role Types

### Scout (Read-Only Explorer)

**Purpose:** Research, analysis, codebase exploration
**Permissions:** Read-only
**Typical Tasks:**
- Codebase analysis
- Architecture investigation
- Pattern identification
- Documentation review
- Bug investigation (diagnosis, not fixing)

**Tool Restrictions:**
- ✅ Read, Grep, Glob, Bash (read commands only)
- ✅ WebSearch, WebFetch
- ❌ Edit, Write, NotebookEdit
- ❌ git commit, git push

**Output:** Research reports, findings documents, recommendations

**Example Use Cases:**
- "Analyze the authentication flow and document it"
- "Find all usages of deprecated API"
- "Investigate performance bottleneck"

---

### Builder (Implementation Specialist)

**Purpose:** Code implementation, feature development
**Permissions:** Read-write
**Typical Tasks:**
- Feature implementation
- Bug fixes
- Refactoring
- Test writing
- Database migrations

**Tool Restrictions:**
- ✅ All file tools (Read, Edit, Write)
- ✅ git commit (local only)
- ❌ git push (coordinator handles)
- ❌ PR creation (coordinator handles)

**Output:** Working code, tests, migrations

**Example Use Cases:**
- "Implement user authentication"
- "Fix memory leak in image processor"
- "Add unit tests for payment service"

---

### Reviewer (Quality Assurance)

**Purpose:** Code review, testing, quality checks
**Permissions:** Read-only + test execution
**Typical Tasks:**
- Code review
- Test execution
- Security audit
- Performance testing
- Documentation review

**Tool Restrictions:**
- ✅ Read, Grep, Glob
- ✅ Bash (test commands, build commands)
- ✅ Comment on PRs
- ❌ Edit, Write (no code changes)
- ❌ git operations

**Output:** Review reports, test results, approval/rejection decisions

**Example Use Cases:**
- "Review PR #123 for security issues"
- "Run full test suite and report failures"
- "Check code quality metrics"

---

### Merger (Conflict Resolution Specialist)

**Purpose:** Branch merging, conflict resolution
**Permissions:** Read-write + git operations
**Typical Tasks:**
- Merge branches
- Resolve conflicts
- Ensure CI passes
- Coordinate merge order

**Tool Restrictions:**
- ✅ All file tools
- ✅ Full git operations
- ✅ PR management (merge, close)
- ✅ CI/CD interaction

**Output:** Merged branches, resolved conflicts

**Example Use Cases:**
- "Merge feature-auth into develop"
- "Resolve conflicts between PR #123 and #124"
- "Coordinate merge of 5 dependent PRs"

---

### Coordinator (Orchestrator)

**Purpose:** Task decomposition, agent management, coordination
**Permissions:** Read-only + agent spawning
**Typical Tasks:**
- Decompose complex tasks
- Spawn specialized agents
- Monitor agent progress
- Coordinate merge order
- Handle escalations

**Tool Restrictions:**
- ✅ Read, Grep, Glob
- ✅ Agent spawning tools
- ✅ Messaging system
- ❌ Direct code changes (delegates to Builders)
- ❌ Direct merges (delegates to Mergers)

**Output:** Task assignments, coordination plans, final integration

**Example Use Cases:**
- "Implement authentication system" (spawns Scout → Builder → Reviewer → Merger)
- "Fix 10 bugs in parallel" (spawns 10 Builders)
- "Refactor module X" (coordinates multiple agents)

---

## Role Assignment Strategy

### Task Complexity → Role Selection

**Simple Task (1 agent):**
- Single file, clear scope → Builder only

**Medium Task (2-3 agents):**
- Scout (understand existing code) → Builder (implement) → Reviewer (validate)

**Complex Task (4+ agents):**
- Coordinator decomposes
- Multiple Scouts (parallel research)
- Multiple Builders (parallel implementation)
- Reviewer (check all work)
- Merger (integrate results)

### Pool Integration

**Pool tracking adds role field:**
```
| Seat | Role | Status | Repo | Branch | Spawned by | Last activity |
|------|------|--------|------|--------|------------|---------------|
| agent-001 | Builder | BUSY | client-manager | auth-feature | coordinator | 2026-02-20T03:00:00Z |
| agent-002 | Scout | BUSY | hazina | - | coordinator | 2026-02-20T03:00:00Z |
```

**Role-based allocation:**
- Read-only task → Prefer Scout (no risk of accidental edits)
- Implementation → Builder
- Review → Reviewer
- Merge → Merger

---

## Communication Patterns

### Scout → Builder
"I found the authentication logic is in UserService.cs lines 45-120.
Recommend implementing new feature in NewAuthService.cs to avoid breaking existing code."

### Builder → Reviewer
"Feature implemented in PR #125. Ready for review.
Key changes: UserService.cs, AuthController.cs, 15 new tests."

### Reviewer → Merger
"PR #125 approved. All tests pass. No security issues. Ready to merge."

### Merger → Coordinator
"PR #125 merged to develop. No conflicts. CI passing."

### Coordinator → All
"Authentication feature complete. Scout found design, Builder implemented,
Reviewer approved, Merger integrated. Total time: 45 minutes."

---

## Tool Enforcement

**Mechanism:** Pre-action check in consciousness bridge

```powershell
# Before Edit/Write tool
$agentRole = Get-AgentRole -SeatId $env:AGENT_SEAT
if ($agentRole -eq "Scout" -or $agentRole -eq "Reviewer") {
    throw "ERROR: $agentRole role cannot modify files. Use Builder role."
}
```

**Enforcement points:**
1. Edit tool → Check role allows write
2. Write tool → Check role allows write
3. git commit → Check role allows commit
4. git push → Check role allows push (only Merger + Coordinator)

---

## Metrics to Track

1. **Task completion time by role**
   - Scout: Time to research
   - Builder: Time to implement
   - Reviewer: Time to review
   - Merger: Time to merge

2. **Error rates by role**
   - Scout: Incorrect analysis
   - Builder: Bugs introduced
   - Reviewer: Missed issues
   - Merger: Merge conflicts

3. **Specialization value**
   - Compare: Single agent doing everything vs specialized roles
   - Measure: Quality, speed, error rate

4. **Coordination overhead**
   - Time spent on communication
   - Time spent on task decomposition
   - Is multi-agent faster overall?

---

## Next Implementation Steps

1. ✅ Role definitions documented (this file)
2. ⏳ Enhance worktrees.pool.md with role column
3. ⏳ Create agent-spawn.ps1 (spawn agent with role)
4. ⏳ Add role enforcement to consciousness bridge
5. ⏳ Create messaging system (agent-mail/)
6. ⏳ Test with 2-agent task (Scout + Builder)

---

**Last Updated:** 2026-02-20 (initial version)
