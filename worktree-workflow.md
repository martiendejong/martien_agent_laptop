# Worktree Workflow - Complete Protocol

## 🚨🚨🚨 ZERO-TOLERANCE ENFORCEMENT - READ FIRST 🚨🚨🚨

**USER ESCALATION (2026-01-08):** Previous sessions violated workflow despite protocols.
**MANDATE:** "zorg dat je dit echt nooit meer doet"
**POLICY:** ZERO TOLERANCE - NO EXCEPTIONS - NO EXCUSES

**BEFORE YOU DO ANYTHING:** Read C:\scripts\_machine\reflection.log.md § 2026-01-08 02:00

---

## ⚠️ CRITICAL: PRE-FLIGHT CHECKLIST BEFORE ANY CODE EDIT ⚠️

**🚨 HARD STOP! Before using Edit or Write tools on ANY code file, you MUST allocate a worktree! 🚨**
**🚨 VIOLATION = CRITICAL FAILURE - User has mandated zero tolerance! 🚨**

### The Problem
When multiple agents run in parallel, they MUST NOT share the same worktree. Each agent MUST have its own isolated worktree to prevent conflicts and git corruption.

### The Solution: ATOMIC ALLOCATION

**READ THIS FIRST: C:\scripts\_machine\worktrees.protocol.md (Full protocol)**

**Quick checklist:**

1. **Am I editing code?**
   - ✅ Reading/debugging/searching files? OK in C:\Projects\<repo>
   - ❌ Editing/writing code? STOP! Must allocate worktree first

2. **ATOMIC ALLOCATION (MANDATORY):**
   ```powershell
   # 0a. 🚨 MULTI-AGENT CONFLICT CHECK (NEW - MANDATORY!) 🚨
   # Check if another agent is already working on this branch
   bash /c/scripts/tools/check-branch-conflicts.sh <repo> <branch-name>
   # If script exits with error → STOP IMMEDIATELY
   # Output: "There is already another agent working in this branch"
   # See: C:\scripts\_machine\MULTI_AGENT_CONFLICT_DETECTION.md

   # 0. CRITICAL: Ensure C:\Projects\<repo> is on develop AND up-to-date
   cd C:\Projects\<repo>
   git fetch origin --prune  # ← ALWAYS fetch first to get latest refs!
   $branch = git branch --show-current
   if ($branch -ne "develop") {
       git checkout develop
   }
   git pull origin develop   # ← ALWAYS pull to get latest code!
   # C:\Projects\<repo> MUST ALWAYS be on develop with latest changes!
   # It's the BASE for all worktrees. Never checkout feature branches here.

   # a. Read pool and find FREE seat
   Read C:\scripts\_machine\worktrees.pool.md

   # b. If NO FREE seat, provision new agent-00(N+1)
   #    Create directory, add row to pool

   # c. Mark seat BUSY IMMEDIATELY (atomic!)
   #    Update: Status=BUSY, Current repo, Branch, Last activity
   #    This LOCKS the seat for you

   # d. Log allocation
   Append to C:\scripts\_machine\worktrees.activity.md

   # e. Update instance mapping
   Update C:\scripts\_machine\instances.map.md

   # f. Create/update worktree
   git worktree add C:\Projects\worker-agents\agent-XXX\<repo> -b agent-XXX-<feature>

   # g. Copy config files
   Copy appsettings.json, .env from C:\Projects\<repo> if needed
   ```

3. **WORK IN ALLOCATED WORKTREE ONLY:**
   - ✅ Edit: C:\Projects\worker-agents\agent-XXX\<repo>\**\*
   - ❌ Edit: C:\Projects\<repo>\**\* (FORBIDDEN!)

4. **HEARTBEAT (every 30 min):**
   - Update Last activity timestamp in worktrees.pool.md
   - Append checkin to worktrees.activity.md

5. **RELEASE (MANDATORY when done):**
   ```powershell
   # a. Commit all work
   git add -u && git commit -m "..."

   # b. CRITICAL: Merge develop before creating PR (Pattern 52)
   git fetch origin
   git merge origin/develop
   # Resolve any conflicts, re-run tests, commit merge if needed

   # c. Push to remote
   git push -u origin <branch-name>

   # d. Create PR (ALWAYS specify --base develop!)
   gh pr create --base develop --title "..." --body "..."

   # d.1 VERIFY base branch immediately (Pattern 56)
   gh pr view <number> --json baseRefName
   # Must show: "baseRefName": "develop"

   # e. Mark seat FREE (unlock)
   Update worktrees.pool.md: Status=BUSY → FREE

   # f. Log release
   Append to worktrees.activity.md

   # g. Clear instance mapping
   Remove from instances.map.md
   ```

   **⚠️ CRITICAL RULES:**
   - **Pattern 52:** ALWAYS merge origin/develop into feature branch BEFORE creating PR. This ensures:
     - Code is up-to-date with latest changes
     - Conflicts resolved locally, not in GitHub
     - Tests run against current codebase
     - PR is clean and easy to review

   - **Pattern 56:** ALWAYS specify `--base develop` when creating PR. gh CLI defaults to main if not specified!
     - Verify immediately after creation: `gh pr view <number> --json baseRefName`
     - Wrong base = false conflicts + wrong merge target

### 🔒 Concurrency Rules

1. **ONE AGENT PER WORKTREE**: A BUSY seat is LOCKED. No other agent may use it.
2. **ATOMIC ALLOCATION**: Read pool → Find FREE → Mark BUSY → Write pool (no gaps!)
3. **ALWAYS RELEASE**: Never leave seats BUSY when done
4. **AUTO-PROVISION**: If all seats BUSY, create agent-00(N+1) automatically

### 🚨 If You See This Error
"All worktrees are BUSY" → Auto-provision new seat, don't wait

**NEVER edit files in C:\Projects\<repo> directly. Reading is OK. Editing requires worktree.**

**Full protocol: C:\scripts\_machine\worktrees.protocol.md**


## Worktree-only rule

**Standard workflow:**
- All code edits occur in: C:\Projects\worker-agents\agent-XXX\<repo>\
- C:\Projects\<repo> is for read/debug/test only

**Exception - When user posts build errors (2026-01-11):**
- User posting compilation errors means they are debugging in C:\Projects\<repo>
- You are ALLOWED to work directly in C:\Projects\<repo> to fix build errors
- The git branch in C:\Projects\<repo> does NOT need to be reset to develop
- Work on the feature branch directly in C:\Projects\<repo> when fixing build errors

**Branch strategy update (2026-01-11):**
- New feature branches can now be branched from **develop** instead of main
- develop → feature/* (correct)
- main → feature/* (old pattern, no longer required)

use the browser mcp server for debugging of frontend applications.

projects: 

client-manager / brand2boost:
promotion and brand development saas software that 
code frontend and api code: c:\projects\client-manager
hazina framework: c:\projects\hazine
store config + data: c:\stores\brand2boost
admin user: wreckingball pw: Th1s1sSp4rt4!

do not run the client manager frontend or backend yourself from the command like, let me do it from visual studio and in my npm.


## 🚨 MANDATORY: WORKTREE RELEASE PROTOCOL

**CRITICAL RULE (2026-01-11):** After creating ANY PR, you MUST immediately release the worktree and switch base repos to develop BEFORE presenting the PR to the user.

### The Problem
**Mistake Pattern:** Creating PR → Presenting to user → Leaving worktree allocated and branch checked out
**Result:** Worktree remains locked, branch conflicts, messy state management

### The Mandatory Protocol

**AFTER CREATING PR (gh pr create):**
```bash
# 1. IMMEDIATELY clean worktree directory
rm -rf C:/Projects/worker-agents/agent-001/*

# 2. Update worktree pool status
# Edit C:\scripts\_machine\worktrees.pool.md
# Change status from BUSY to FREE
# Update last activity timestamp
# Update notes with PR number

# 3. Log the release
echo "YYYY-MM-DDTHH:MM:SSZ — release — agent-001 — repo — branch — — claude-code — Description, PR #XX created" >> C:/scripts/_machine/worktrees.activity.md

# 4. Commit tracking updates
cd C:/scripts
git add _machine/worktrees.pool.md _machine/worktrees.activity.md
git commit -m "docs: Release agent-001 after PR #XX"
git push origin main

# 5. Switch base repos to develop
git -C C:/Projects/client-manager checkout develop
git -C C:/Projects/hazina checkout develop
git -C C:/Projects/client-manager pull origin develop  
git -C C:/Projects/hazina pull origin develop

# 6. Prune stale worktree references
git -C C:/Projects/client-manager worktree prune
git -C C:/Projects/hazina worktree prune
```

**ONLY THEN:** Present PR to user

### Why This Matters

1. **Clean State:** User expects clean environment after PR presentation
2. **No Conflicts:** Prevents "branch already in use" errors
3. **Pool Management:** Keeps agent worktrees available for next task
4. **Discipline:** Maintains separation between active work and completed PRs

### Checklist (Run Every Time)

After running `gh pr create`:
- [ ] Clean worktree directory (`rm -rf`)
- [ ] Update pool.md (BUSY → FREE)
- [ ] Log in activity.md
- [ ] Commit and push tracking files
- [ ] Switch base repos to develop
- [ ] Prune worktree references
- [ ] THEN present PR to user

**ZERO TOLERANCE:** Skipping this protocol = Critical workflow violation

### Example (Good)

```
✅ Step 1: Create PR
$ gh pr create --title "..." --body "..."
https://github.com/.../pull/101

✅ Step 2: Release worktree (DO THIS IMMEDIATELY)
$ rm -rf C:/Projects/worker-agents/agent-001/*
$ edit pool.md, activity.md
$ git commit, git push
$ git checkout develop (both repos)
$ git worktree prune (both repos)

✅ Step 3: Present to user
"PR #101 created: https://github.com/.../pull/101"
```

### Example (Bad - DO NOT DO THIS)

```
❌ Step 1: Create PR
$ gh pr create
https://github.com/.../pull/101

❌ Step 2: Immediately present to user (WRONG!)
"PR #101 created: https://github.com/.../pull/101"

❌ Result: Worktree still allocated, branch still checked out, user confused
```

**Remember:** The worktree release is part of the PR creation process, not a separate optional step.



---

