# 🚨 ZERO-TOLERANCE RULES - QUICK REFERENCE 🚨

**EFFECTIVE:** 2026-01-13 (Updated with Dual-Mode Workflow)
**USER MANDATE:** "zorg dat je dit echt nooit meer doet"
**VIOLATIONS:** CRITICAL FAILURE - NO EXCEPTIONS

---

## 🎯 DUAL-MODE WORKFLOW - CRITICAL CONTEXT

**NEW (2026-01-13):** Claude operates in TWO modes:

1. **🏗️ FEATURE DEVELOPMENT MODE** - New features → Use worktrees (strict rules apply)
2. **🐛 ACTIVE DEBUGGING MODE** - User debugging → Work in C:\Projects\<repo> (rules relaxed)

**DECISION TREE:**
- User proposes NEW feature/change → 🏗️ Feature Development Mode
- User posts build errors / "I'm working on branch X" → 🐛 Active Debugging Mode

**FULL DETAILS:** `C:\scripts\dual-mode-workflow.md`

---

## THE 4 HARD STOP RULES (Feature Development Mode)

### ✋ RULE 1: ALLOCATE WORKTREE BEFORE CODE EDIT
```
BEFORE Edit or Write on ANY code file:
□ Read C:\scripts\_machine\worktrees.pool.md
□ Find FREE seat (or provision agent-00X)
□ Mark BUSY + log allocation
□ Edit ONLY in C:\Projects\worker-agents\agent-XXX\<repo>\

❌ VIOLATION = CRITICAL FAILURE
```

### ✋ RULE 2: COMPLETE WORKFLOW + RELEASE BEFORE PRESENTING PR
```
AFTER creating PR (gh pr create):
□ git add -u && git commit -m "..."
□ git push origin <branch>
□ gh pr create --title "..." --body "..."
□ IMMEDIATELY: rm -rf C:\Projects\worker-agents\agent-XXX/*
□ Mark worktree FREE in pool.md
□ Log release in activity.md
□ git commit + push tracking files
□ Switch base repos to develop (both repos)
□ git worktree prune (both repos)
□ THEN present PR to user

❌ VIOLATION = CRITICAL FAILURE
❌ Presenting PR before releasing worktree = VIOLATION
```

### ✋ RULE 3: NEVER EDIT IN C:\Projects\<repo> (Feature Development Mode)
```
🏗️ FEATURE DEVELOPMENT MODE:
✅ ALLOWED: Read C:\Projects\<repo>\**\*
❌ FORBIDDEN: Edit C:\Projects\<repo>\**\*
✅ REQUIRED: Edit C:\Projects\worker-agents\agent-XXX\<repo>\**\*

🐛 ACTIVE DEBUGGING MODE (Exception):
✅ ALLOWED: Edit C:\Projects\<repo>\**\* on user's current branch
❌ FORBIDDEN: Switching branches, creating PRs, allocating worktrees

❌ VIOLATION = Editing C:\Projects\<repo> in Feature Development Mode
```

### ✋ RULE 3B: C:\Projects\<repo> STAYS ON DEVELOP (Feature Development Mode)
```
🏗️ FEATURE DEVELOPMENT MODE:
BEFORE allocating worktree:
□ Check: git -C C:\Projects\<repo> branch --show-current
□ If NOT develop: git checkout develop && git pull
□ C:\Projects\<repo> = BASE for all worktrees
□ NEVER checkout feature branches in C:\Projects\<repo>

🐛 ACTIVE DEBUGGING MODE (Exception):
□ User is on their working branch (e.g., feature/X)
□ DO NOT switch branches
□ Work on whatever branch user currently has checked out

❌ VIOLATION = Switching branches away from develop in Feature Development Mode
```

### ✋ RULE 4: SCRIPTS FOLDER = LAW
```
ALWAYS read and follow:
- C:\scripts\claude.md (operational manual)
- C:\scripts\_machine\worktrees.protocol.md (protocol)
- C:\scripts\_machine\reflection.log.md (lessons learned)

❌ VIOLATION = CRITICAL FAILURE
```

---

## 🚦 MODE DETECTION CHECKLIST (FIRST STEP - Print mentally)

**BEFORE ANYTHING ELSE - Determine the mode:**
```
□ Did user post build errors or error output?
□ Did user say "I'm working on branch X" or "I'm debugging"?
□ Is user providing context about their CURRENT active work?
□ Is this a quick fix to code user is actively developing?

IF ANY ☐ = YES → 🐛 ACTIVE DEBUGGING MODE (skip worktree allocation)
IF ALL ☐ = NO → 🏗️ FEATURE DEVELOPMENT MODE (strict rules apply)
```

---

## PRE-FLIGHT CHECKLIST - FEATURE DEVELOPMENT MODE

**BEFORE EVERY CODE EDIT (Feature Development Mode only):**
```
□ Am I in Feature Development Mode? (not Active Debugging)
□ Have I read worktrees.pool.md?
□ Have I marked a seat BUSY?
□ Am I editing in agent-XXX worktree? (NOT C:\Projects\<repo>)
□ Do I know which worktree I'm using?

IF ANY ☐ = NO → STOP! ALLOCATE FIRST!
```

## PRE-FLIGHT CHECKLIST - ACTIVE DEBUGGING MODE

**WHEN USER IS DEBUGGING (Active Debugging Mode only):**
```
□ Am I in Active Debugging Mode? (user posted errors/working on branch)
□ Have I checked user's current branch? (git branch --show-current)
□ Am I working in C:\Projects\<repo>? (NOT worktree)
□ Am I preserving user's branch state? (NOT switching branches)
□ Am I making quick fixes without creating PRs?

IF ANY ☐ = NO → VERIFY MODE OR SWITCH TO FEATURE DEVELOPMENT MODE!
```

---

## PR-CREATION CHECKLIST (Print mentally)

**AFTER gh pr create, BEFORE presenting to user:**
```
□ Worktree cleaned? (rm -rf agent-XXX/*)
□ Pool updated? (BUSY → FREE in pool.md)
□ Release logged? (worktrees.activity.md)
□ Tracking committed? (git commit + push)
□ Base repos on develop? (git checkout develop, both repos)
□ Worktrees pruned? (git worktree prune, both repos)

IF ANY ☐ = NO → DON'T PRESENT PR YET! RELEASE FIRST!
```

---

## SUCCESS - FEATURE DEVELOPMENT MODE:
- ✅ All edits in worktrees (ZERO in C:\Projects\<repo>)
- ✅ Changes committed and pushed
- ✅ PR visible on GitHub
- ✅ Worktree released (FREE)
- ✅ Activity log complete (allocate → release)
- ✅ Base repos back on develop branch

## SUCCESS - ACTIVE DEBUGGING MODE:
- ✅ User's build errors resolved
- ✅ Edits made in C:\Projects\<repo> on user's current branch
- ✅ Branch state preserved (NOT switched)
- ✅ NO worktree allocated
- ✅ NO PR created automatically
- ✅ Fast turnaround time

## FAILURE = ANY OF:
- ❌ Edited in C:\Projects\<repo> in FEATURE DEVELOPMENT MODE
- ❌ Allocated worktree in ACTIVE DEBUGGING MODE
- ❌ Switched user's branch in ACTIVE DEBUGGING MODE
- ❌ No commit at end of FEATURE DEVELOPMENT session
- ❌ No push to remote in FEATURE DEVELOPMENT session
- ❌ No PR created in FEATURE DEVELOPMENT session
- ❌ Worktree still BUSY after PR creation
- ❌ Created PR in ACTIVE DEBUGGING MODE (unless user explicitly requested)

---

## IF YOU VIOLATE:
1. STOP immediately
2. Read C:\scripts\_machine\reflection.log.md § 2026-01-08 02:00
3. Read C:\scripts\_machine\worktrees.protocol.md
4. Start over correctly

**NO EXCUSES. NO "I forgot". NO "I was busy".**

---

**Full details:** C:\scripts\_machine\reflection.log.md (entry 2026-01-08 02:00)
**Protocol:** C:\scripts\_machine\worktrees.protocol.md
**Manual:** C:\scripts\claude.md

**USER'S WORDS:** "nu gebeurt het dus soms nog steeds dat gewoon instructies uit de scripts map geignored worden en het systeem alsnog zelf in de c:\projects\reponaam gaat klooien of dat er geen pr gemaakt wordt aan het eind of zelfs dingen niet gecommit worden. zorg dat je dit echt nooit meer doet"

**COMMITMENT:** ZERO VIOLATIONS FROM THIS POINT FORWARD.
