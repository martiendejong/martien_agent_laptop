# 🚨 ZERO-TOLERANCE RULES - QUICK REFERENCE 🚨

**EFFECTIVE:** 2026-02-07 (Updated with STATUS requirement)
**USER MANDATE:** "zorg dat je dit echt nooit meer doet"
**VIOLATIONS:** CRITICAL FAILURE - NO EXCEPTIONS

---

## 📢 RULE 0: ALWAYS END WITH STATUS OVERVIEW (2026-02-07)

**MANDATORY FOR EVERY RESPONSE:**

```
STATUS: [Brief description]
========================
✅ What was done
✅ What's working
🔄 What's next
📁 Files modified/created
🚀 Commits pushed (if any)
```

**This is NON-NEGOTIABLE. User requires this format at end of EVERY response.**

Example:
```
STATUS: Phase 1 Complete - Semantic + Predictive Learning Active
==================================================================
✅ 4 tools created and tested
✅ Documentation complete (PHASE1_QUICKSTART.md)
✅ All changes committed and pushed to GitHub
🔄 Next: Implement Phase 2 or tune Phase 1 over 3 sessions?
```

❌ **VIOLATION = Ending response without STATUS overview**

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

### ✋ RULE 3B: PR MERGE PROTOCOL (NEW - 2026-02-08)
```
BEFORE merging ANY PR to develop:

MANDATORY SEQUENCE:
1. Code review completed (approval given)
2. Merge latest develop INTO feature branch
   git checkout <feature-branch>
   git pull origin develop
   # OR
   git merge origin/develop --no-edit
3. Resolve ALL merge conflicts (if any)
4. Build & test in feature branch (wait for CI checks)
5. Verify ALL critical checks pass (build, tests, security scans)
6. ONLY THEN merge PR to develop

DO NOT:
❌ Merge PR without merging develop first
❌ Merge PR with failing CI checks
❌ Merge PR without resolving conflicts
❌ Assume "it will work" without testing

VIOLATION EXAMPLE (2026-02-08):
- PR ready to merge but develop not merged in branch
- User: "develop die is in de branche gemerged dan mag je de PR mergen...
   anders niet, dan moet je eerst develop mergen"

CONSEQUENCE:
- Merge conflicts in develop
- Broken builds in develop
- Wasted time fixing post-merge
- User frustration

WHY THIS RULE EXISTS:
- Ensures feature branch is up-to-date with latest changes
- Catches integration issues BEFORE merging to develop
- Prevents breaking develop branch
- Maintains clean git history
```

### ✋ RULE 3C: DOCUMENTATION-FIRST DEPLOYMENT (NEW - 2026-02-08)
```
BEFORE deploying, starting, or configuring ANY service/application:

MANDATORY SEQUENCE:
1. Read C:\scripts\MACHINE_CONFIG.md (search for service name/port)
2. Read C:\scripts\installer\README.md (if applicable)
3. Read existing config files (appsettings.json, etc.)
4. VERIFY configuration matches documentation
5. THEN AND ONLY THEN execute deployment

DO NOT:
❌ Guess ports, protocols, or settings
❌ Use default/example configurations
❌ Deploy and fix errors afterward
❌ Trial-and-error approach

VIOLATION EXAMPLE (2026-02-08):
- Hazina Orchestration deployed 3x wrong
- HTTP/5000 → HTTP/5123 → HTTPS/5123 (correct)
- User: "where are your notes about this?"
- Documentation existed, was not checked

CONSEQUENCE:
- STOP immediately if you catch yourself guessing
- Read MACHINE_CONFIG.md
- Read installer docs
- Start over with correct config
```

### ✋ RULE 3D: C:\Projects\<repo> STAYS ON DEVELOP (Feature Development Mode)
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

### ✋ RULE 3E: NO PII IN PUBLIC CONTENT (NEW - 2026-02-13)
```
BEFORE publishing ANY content to a public website (FAQ, blog posts, page content, schema markup):

MANDATORY PII SECURITY SCAN:
□ No literal email addresses (info@domain.nl, etc.)
□ No phone numbers unless explicitly requested by user
□ No physical addresses unless explicitly requested
□ No internal URLs or admin paths
□ If page has a contact form → reference that instead

DO NOT:
❌ Include literal email addresses in generated web content
❌ Include mailto: links in FAQ answers or blog content
❌ Assume "it's just an email, it's fine"
❌ Skip this check because you're "in content mode"

VIOLATION EXAMPLE (2026-02-13):
- Generated FAQ for martiendejong.nl/impact
- Included "reach out directly at info@martiendejong.nl"
- Page ALREADY HAD a contact form
- Exposed user's email to spambot harvesting

ALWAYS USE INSTEAD:
✅ "Use the contact form on this page"
✅ "Get in touch via the contact section"
✅ JavaScript-rendered email (if email display truly needed)

WHY THIS RULE EXISTS:
- Email harvesting bots scan every public page continuously
- A single exposed email = permanent spam increase
- This is someone else's personal data, not yours to expose
- Contact forms exist specifically to prevent this
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
