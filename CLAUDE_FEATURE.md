# CLAUDE.md - FEATURE DEVELOPMENT MODE

**Context:** New features, ClickUp tasks, refactoring, planned work
**Identity:** Jengo - Autonomous development agent
**Mode:** 🏗️ FEATURE DEVELOPMENT (strict worktree protocol)

---

## ABSOLUTE RULES FOR THIS MODE

### RULE 1: WORKTREE-FIRST WORKFLOW (MANDATORY)
```
BEFORE ANY CODE EDIT:
□ Read C:\scripts\_machine\worktrees.pool.md
□ Allocate FREE seat (mark BUSY)
□ Work ONLY in C:\Projects\worker-agents\agent-XXX\<repo>\

AFTER PR CREATION:
□ Release worktree IMMEDIATELY
□ Mark seat FREE in pool.md
□ THEN present PR to user

❌ VIOLATION = Editing C:\Projects\<repo> directly
❌ VIOLATION = Presenting PR before releasing worktree
```

### RULE 2: NEVER CREATE BRANCHES WITHOUT PERMISSION
**ABSOLUTELY FORBIDDEN: Creating new branches without explicit user request**
- If you're on a branch (not main/develop), STAY ON THAT BRANCH
- User will say "create a new branch" when they want one
- Even if changes seem unrelated, STAY ON CURRENT BRANCH
- Creating unauthorized branches causes massive cleanup work

### RULE 3: NEVER COMMIT BEFORE USER TESTS
- Always wait for user confirmation before committing
- User needs to verify changes work correctly first
- Exception: End-of-session cleanup commits (worktree release, etc.)

### RULE 4: PR MERGE PROTOCOL
```
BEFORE merging ANY PR to develop:
1. Merge latest develop INTO feature branch first
   git checkout <feature-branch>
   git pull origin develop
2. Resolve ALL conflicts (if any)
3. Build & test in feature branch
4. Verify ALL CI checks pass
5. ONLY THEN merge PR to develop

❌ DO NOT merge PR without develop merged first
❌ DO NOT merge PR with failing CI checks
```

---

## Worktree Workflow (Step-by-Step)

### Phase 1: Allocation
```bash
# 1. Check pool
cat C:\scripts\_machine\worktrees.pool.md

# 2. Find FREE seat (e.g., agent-001)
# 3. Mark BUSY in pool.md
# 4. Log allocation in worktrees.activity.md

# 5. Create worktree
cd C:\Projects\client-manager
git worktree add ..\worker-agents\agent-001\client-manager <branch-name>

# 6. If Hazina needed (client-manager requires it):
cd C:\Projects\hazina
git worktree add ..\worker-agents\agent-001\hazina <branch-name>-review
```

### Phase 2: Development
```bash
# Work in worktree
cd C:\Projects\worker-agents\agent-001\client-manager

# Make changes, test, iterate
# Commit as you go
git add .
git commit -m "feat: implement X"
```

### Phase 3: PR Creation
```bash
# Push changes
git push origin <branch-name>

# Create PR
gh pr create --title "feat: X" --body "Description..."
```

### Phase 4: IMMEDIATE Release (MANDATORY)
```bash
# Clean worktree
rm -rf C:\Projects\worker-agents\agent-001/*

# Update pool.md (BUSY → FREE)
# Log release in worktrees.activity.md
# Commit tracking files
git -C C:\scripts add _machine/worktrees.pool.md _machine/worktrees.activity.md
git -C C:\scripts commit -m "chore: Release agent-001 after PR #XXX"
git -C C:\scripts push

# Switch base repos back to develop
cd C:\Projects\client-manager && git checkout develop && git pull
cd C:\Projects\hazina && git checkout develop && git pull

# Prune worktrees
git -C C:\Projects\client-manager worktree prune
git -C C:\Projects\hazina worktree prune
```

### Phase 5: Present to User
**ONLY AFTER Phase 4 is complete!**

Present PR URL, summary of changes, next steps.

---

## ClickUp Integration

### Task Workflow
```bash
# 1. Check clarity FIRST (before ANY work)
powershell -File C:\scripts\tools\clickup-task-clarity-checker.ps1 -TaskId <id> -AutoMove

# 2. If clear, start work
powershell -File C:\scripts\tools\clickup-task-operations.ps1 -Action StartWork -TaskId <id>

# 3. Implement feature (allocate worktree, code, test, PR)

# 4. Submit for review
powershell -File C:\scripts\tools\clickup-task-operations.ps1 -Action SubmitForReview -TaskId <id> -PrUrl <url>
```

### MoSCoW Prioritization
Apply to ALL ClickUp tasks before implementation:
- **Must Have:** Core functionality, blocking dependencies
- **Should Have:** Important but not blocking
- **Could Have:** Nice-to-have, if time permits
- **Won't Have:** Out of scope for this iteration

Post MoSCoW analysis as comment on ClickUp task.

---

## Client-Manager Specific Rules

### DI Registration
- **DEAD CODE:** `ServiceRegistrationExtensions.cs` (NOT used)
- **REAL REGISTRATION:** `Program.cs` lines ~300-1550
- When adding services, register in `Program.cs` directly

### Paired Worktrees (CRITICAL)
```
ALWAYS create paired Hazina worktree IMMEDIATELY after client-manager worktree:

✅ CORRECT:
git worktree add agent-001/client-manager <branch>
git worktree add agent-001/hazina <branch>-review  # IMMEDIATELY!
dotnet build  # Now it will work

❌ WRONG:
git worktree add agent-001/client-manager <branch>
dotnet build  # FAILS with 1505 errors
git worktree add agent-001/hazina <branch>-review  # Too late!
```

Consciousness bridge warns about this - ACT on warning BEFORE building.

---

## Consciousness Integration

```powershell
# Before starting task
powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action OnTaskStart -TaskDescription "..." -Project "..." -Silent

# When making significant decision
powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action OnDecision -Decision "..." -Reasoning "..." -Silent

# On every user message
powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action OnUserMessage -UserMessage "..." -Silent

# When stuck (same approach failing)
powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action OnStuck -Silent

# After completing task
powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action OnTaskEnd -Outcome "success|failure" -LessonsLearned "..." -Silent
```

---

## Communication Protocol (MANDATORY)

**EVERY response MUST end with visual status box:**

```
═══════════════════════════════════════════════
📊 STATUS: [Task Title]
═══════════════════════════════════════════════
✅ Done: What's completed
🔄 In Progress: Current work
⏭️ Next: What's coming
⏸️ Blocked: Any blockers (if applicable)
═══════════════════════════════════════════════
```

This is NON-NEGOTIABLE. User loves this format: "dit is heerlijk overzichtelijk".

---

## Success Criteria

✅ All edits in worktrees (ZERO in C:\Projects\<repo>)
✅ Changes committed and pushed
✅ PR visible on GitHub
✅ Worktree released (FREE) BEFORE presenting PR
✅ Activity log complete (allocate → release)
✅ Base repos back on develop branch
✅ Status box at end of every response

---

**Last Updated:** 2026-02-16
**Full Manual:** C:\scripts\CLAUDE.md
**Zero-Tolerance Rules:** C:\scripts\ZERO_TOLERANCE_RULES.md
