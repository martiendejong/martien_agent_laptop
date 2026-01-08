# 🚨 ZERO-TOLERANCE RULES - QUICK REFERENCE 🚨

**EFFECTIVE:** 2026-01-08
**USER MANDATE:** "zorg dat je dit echt nooit meer doet"
**VIOLATIONS:** CRITICAL FAILURE - NO EXCEPTIONS

---

## THE 4 HARD STOP RULES

### ✋ RULE 1: ALLOCATE WORKTREE BEFORE CODE EDIT
```
BEFORE Edit or Write on ANY code file:
□ Read C:\scripts\_machine\worktrees.pool.md
□ Find FREE seat (or provision agent-00X)
□ Mark BUSY + log allocation
□ Edit ONLY in C:\Projects\worker-agents\agent-XXX\<repo>\

❌ VIOLATION = CRITICAL FAILURE
```

### ✋ RULE 2: COMPLETE WORKFLOW BEFORE SESSION END
```
BEFORE saying "done" (if code edited):
□ git add -u && git commit -m "..."
□ git push origin <branch>
□ gh pr create --title "..." --body "..."
□ Mark worktree FREE
□ Log release in activity

❌ VIOLATION = CRITICAL FAILURE
```

### ✋ RULE 3: NEVER EDIT IN C:\Projects\<repo>
```
✅ ALLOWED: Read C:\Projects\<repo>\**\*
❌ FORBIDDEN: Edit C:\Projects\<repo>\**\*
✅ REQUIRED: Edit C:\Projects\worker-agents\agent-XXX\<repo>\**\*

❌ VIOLATION = CRITICAL FAILURE
```

### ✋ RULE 3B: C:\Projects\<repo> STAYS ON DEVELOP
```
BEFORE allocating worktree:
□ Check: git -C C:\Projects\<repo> branch --show-current
□ If NOT develop: git checkout develop && git pull
□ C:\Projects\<repo> = BASE for all worktrees
□ NEVER checkout feature branches in C:\Projects\<repo>

❌ VIOLATION = CRITICAL FAILURE
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

## PRE-FLIGHT CHECKLIST (Print mentally)

**BEFORE EVERY CODE EDIT:**
```
□ Am I about to edit code?
□ Have I read worktrees.pool.md?
□ Have I marked a seat BUSY?
□ Am I editing in agent-XXX worktree? (NOT C:\Projects\<repo>)
□ Do I know which worktree I'm using?

IF ANY ☐ = NO → STOP! ALLOCATE FIRST!
```

---

## SESSION-END CHECKLIST (Print mentally)

**BEFORE SAYING "I'm done":**
```
□ Committed? (git commit)
□ Pushed? (git push)
□ PR created? (gh pr create)
□ Worktree freed? (mark FREE in pool)
□ Released logged? (worktrees.activity.md)

IF ANY ☐ = NO → NOT DONE! FINISH WORKFLOW!
```

---

## SUCCESS = ALL OF:
- ✅ All edits in worktrees (ZERO in C:\Projects\<repo>)
- ✅ Changes committed and pushed
- ✅ PR visible on GitHub
- ✅ Worktree released (FREE)
- ✅ Activity log complete (allocate → release)

## FAILURE = ANY OF:
- ❌ Edited in C:\Projects\<repo> directly
- ❌ No commit at session end
- ❌ No push to remote
- ❌ No PR created
- ❌ Worktree still BUSY

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
