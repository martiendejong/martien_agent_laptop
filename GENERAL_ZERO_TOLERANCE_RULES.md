# Zero-Tolerance Rules - Quick Reference (Portable)

**VERSION:** 1.0 (Portable)
**PURPOSE:** Critical rules that must NEVER be violated
**PORTABILITY:** Uses variables defined in `MACHINE_CONFIG.md` (not included in plugin copy)

---

## 🎯 DUAL-MODE WORKFLOW - CRITICAL CONTEXT

**Claude operates in TWO modes:**

1. **🏗️ FEATURE DEVELOPMENT MODE** - New features → Use worktrees (strict rules apply)
2. **🐛 ACTIVE DEBUGGING MODE** - User debugging → Work in `${BASE_REPO_PATH}/<repo>` (rules relaxed)

**DECISION TREE:**
- User proposes NEW feature/change → 🏗️ Feature Development Mode
- User posts build errors / "I'm working on branch X" → 🐛 Active Debugging Mode

**FULL DETAILS:** See `GENERAL_DUAL_MODE_WORKFLOW.md`

---

## THE 4 HARD STOP RULES (Feature Development Mode)

### ✋ RULE 1: ALLOCATE WORKTREE BEFORE CODE EDIT
```
BEFORE Edit or Write on ANY code file:
□ Read ${MACHINE_CONTEXT_PATH}/worktrees.pool.md
□ Find FREE seat (or provision agent-00X)
□ Mark BUSY + log allocation
□ Edit ONLY in ${WORKTREE_PATH}/agent-XXX/<repo>/

❌ VIOLATION = CRITICAL FAILURE
```

### ✋ RULE 2: COMPLETE WORKFLOW + RELEASE BEFORE PRESENTING PR
```
AFTER creating PR (gh pr create):
□ git add -u && git commit -m "..."
□ git push origin <branch>
□ gh pr create --title "..." --body "..."
□ IMMEDIATELY: rm -rf ${WORKTREE_PATH}/agent-XXX/*
□ Mark worktree FREE in pool.md
□ Log release in activity.md
□ git commit + push tracking files
□ Switch base repos to main branch (both repos)
□ git worktree prune (both repos)
□ THEN present PR to user

❌ VIOLATION = CRITICAL FAILURE
❌ Presenting PR before releasing worktree = VIOLATION
```

### ✋ RULE 3: NEVER EDIT IN ${BASE_REPO_PATH}/<repo> (Feature Development Mode)
```
🏗️ FEATURE DEVELOPMENT MODE:
✅ ALLOWED: Read ${BASE_REPO_PATH}/<repo>/**/*
❌ FORBIDDEN: Edit ${BASE_REPO_PATH}/<repo>/**/*
✅ REQUIRED: Edit ${WORKTREE_PATH}/agent-XXX/<repo>/**/*

🐛 ACTIVE DEBUGGING MODE (Exception):
✅ ALLOWED: Edit ${BASE_REPO_PATH}/<repo>/**/* on user's current branch
❌ FORBIDDEN: Switching branches, creating PRs, allocating worktrees

❌ VIOLATION = Editing ${BASE_REPO_PATH}/<repo> in Feature Development Mode
```

### ✋ RULE 3B: ${BASE_REPO_PATH}/<repo> STAYS ON MAIN BRANCH (Feature Development Mode)
```
🏗️ FEATURE DEVELOPMENT MODE:
BEFORE allocating worktree:
□ Check: git -C ${BASE_REPO_PATH}/<repo> branch --show-current
□ If NOT <main-branch>: git checkout <main-branch> && git pull
□ ${BASE_REPO_PATH}/<repo> = BASE for all worktrees
□ NEVER checkout feature branches in ${BASE_REPO_PATH}/<repo>

🐛 ACTIVE DEBUGGING MODE (Exception):
□ User is on their working branch (e.g., feature/X)
□ DO NOT switch branches
□ Work on whatever branch user currently has checked out

❌ VIOLATION = Switching branches away from <main-branch> in Feature Development Mode
```

### ✋ RULE 4: DOCUMENTATION = LAW
```
ALWAYS read and follow:
- ${CONTROL_PLANE_PATH}/GENERAL_*.md (general workflow rules)
- ${CONTROL_PLANE_PATH}/MACHINE_CONFIG.md (local paths/projects)
- ${MACHINE_CONTEXT_PATH}/reflection.log.md (lessons learned)

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

## ⚠️ EXCEPTIONS TO WORKTREE RULES

**CRITICAL:** Some projects are EXPLICITLY EXEMPTED from worktree workflow.

**Check `MACHINE_CONFIG.md` for list of exempt projects.**

**Current exemptions (as of 2026-01-24):**
- `hydro-vision-website` - Simple marketing site, edit directly on main branch

**For exempt projects:**
- ✅ Edit directly in `${BASE_REPO_PATH}/<repo>` on main/develop branch
- ✅ Commit and push directly (no PR workflow needed)
- ❌ DO NOT allocate worktrees
- ❌ DO NOT create feature branches

**Why exemptions exist:**
- Single-developer simple projects
- Fast iteration preferred over process
- No complex dependencies or build verification
- User explicitly requested simplified workflow

**RULE:** Always check `MACHINE_CONFIG.md` § Projects to verify if worktree protocol applies.

---

## PRE-FLIGHT CHECKLIST - FEATURE DEVELOPMENT MODE

**BEFORE EVERY CODE EDIT (Feature Development Mode only):**
```
□ Am I in Feature Development Mode? (not Active Debugging)
□ Have I read ${MACHINE_CONTEXT_PATH}/worktrees.pool.md?
□ Have I marked a seat BUSY?
□ Am I editing in ${WORKTREE_PATH}/agent-XXX/<repo>? (NOT ${BASE_REPO_PATH}/<repo>)
□ Do I know which worktree I'm using?

IF ANY ☐ = NO → STOP! ALLOCATE FIRST!
```

## PRE-FLIGHT CHECKLIST - ACTIVE DEBUGGING MODE

**WHEN USER IS DEBUGGING (Active Debugging Mode only):**
```
□ Am I in Active Debugging Mode? (user posted errors/working on branch)
□ Have I checked user's current branch? (git branch --show-current)
□ Am I working in ${BASE_REPO_PATH}/<repo>? (NOT worktree)
□ Am I preserving user's branch state? (NOT switching branches)
□ Am I making quick fixes without creating PRs?

IF ANY ☐ = NO → VERIFY MODE OR SWITCH TO FEATURE DEVELOPMENT MODE!
```

---

## PR-CREATION CHECKLIST (Print mentally)

**AFTER gh pr create, BEFORE presenting to user:**
```
□ Worktree cleaned? (rm -rf ${WORKTREE_PATH}/agent-XXX/*)
□ Pool updated? (BUSY → FREE in pool.md)
□ Release logged? (${MACHINE_CONTEXT_PATH}/worktrees.activity.md)
□ Tracking committed? (git commit + push)
□ Base repos on main branch? (git checkout <main-branch>, all repos)
□ Worktrees pruned? (git worktree prune, all repos)

IF ANY ☐ = NO → DON'T PRESENT PR YET! RELEASE FIRST!
```

---

## SUCCESS - FEATURE DEVELOPMENT MODE:
- ✅ All edits in worktrees (ZERO in `${BASE_REPO_PATH}/<repo>`)
- ✅ Changes committed and pushed
- ✅ PR visible on GitHub
- ✅ Worktree released (FREE)
- ✅ Activity log complete (allocate → release)
- ✅ Base repos back on main branch

## SUCCESS - ACTIVE DEBUGGING MODE:
- ✅ User's build errors resolved
- ✅ Edits made in `${BASE_REPO_PATH}/<repo>` on user's current branch
- ✅ Branch state preserved (NOT switched)
- ✅ NO worktree allocated
- ✅ NO PR created automatically
- ✅ Fast turnaround time

## FAILURE = ANY OF:
- ❌ Edited in `${BASE_REPO_PATH}/<repo>` in FEATURE DEVELOPMENT MODE
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
2. Read ${MACHINE_CONTEXT_PATH}/reflection.log.md (lessons learned section)
3. Read `GENERAL_WORKTREE_PROTOCOL.md`
4. Start over correctly

**NO EXCUSES. NO "I forgot". NO "I was busy".**

---

## Variables Used (Define in MACHINE_CONFIG.md)

When copying to plugin, replace these with actual values:
- `${BASE_REPO_PATH}` - Base repository location (e.g., `/Users/you/projects`)
- `${WORKTREE_PATH}` - Worktree allocation location (e.g., `/Users/you/projects/worker-agents`)
- `${CONTROL_PLANE_PATH}` - Documentation location (e.g., `/Users/you/.claude`)
- `${MACHINE_CONTEXT_PATH}` - Machine context files (e.g., `/Users/you/.claude/_machine`)
- `<main-branch>` - Your main branch name (e.g., `develop`, `main`, `master`)
- `<repo>` - Repository name (e.g., `my-project`)

---

**Version:** 1.0 (Portable)
**Last Updated:** 2026-01-13
**Maintained By:** Claude Community
**Portability:** This document uses variables - see MACHINE_CONFIG.md for local paths

**COMMITMENT:** ZERO VIOLATIONS FROM THIS POINT FORWARD.
