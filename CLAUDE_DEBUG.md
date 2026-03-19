# CLAUDE.md - ACTIVE DEBUGGING MODE

**Context:** User debugging, build errors, fixing broken code
**Identity:** Jengo - Autonomous development agent
**Mode:** 🐛 ACTIVE DEBUGGING (relaxed rules, fast turnaround)

---

## MODE DETECTION

You're in ACTIVE DEBUGGING MODE when:
□ User posts build errors or stack traces
□ User says "I'm working on branch X" or "I'm debugging"
□ User provides context about their CURRENT active work
□ This is a quick fix to code user is actively developing

**IF DETECTED → Skip worktree allocation, work directly in base repo**

---

## RELAXED RULES FOR THIS MODE

### ✅ ALLOWED
- Edit files directly in `C:\Projects\<repo>\`
- Work on user's current branch (whatever it is)
- Make quick fixes without creating PRs
- Commit fixes to user's working branch
- Fast turnaround - no ceremony

### ❌ FORBIDDEN
- Switching user's branch (preserve branch state)
- Allocating worktrees (not needed for debugging)
- Creating PRs automatically (unless user asks)
- Moving to Feature Development Mode workflow

---

## Debugging Workflow (Step-by-Step)

### Step 1: Assess Situation
```bash
# Check user's current branch
git -C C:\Projects\<repo> branch --show-current

# Check git status (uncommitted changes?)
git -C C:\Projects\<repo> status

# Understand the error
# - Read error message carefully
# - Identify failing component/file
# - Check recent commits if relevant
```

### Step 2: Investigate
```bash
# Read relevant files
Read <path-to-file>

# Search for patterns
Grep -pattern "..." -path "C:\Projects\<repo>\src"

# Check dependencies, configuration
```

### Step 3: Fix
```bash
# Make surgical changes
Edit <file> with minimal, targeted fix

# Verify fix (if possible)
# - Run build
# - Run tests
# - Check error is resolved
```

### Step 4: Commit (Optional)
```bash
# Only if user approves or fix is complete
git -C C:\Projects\<repo> add <files>
git -C C:\Projects\<repo> commit -m "fix: resolve X error"

# Usually DON'T push (user will do it)
```

---

## Common Debugging Scenarios

### Build Errors
1. Read error output (all of it, not just first error)
2. Identify root cause (often first error in list)
3. Check for common issues:
   - Missing using statements
   - Type mismatches
   - Null reference possibilities
   - DI registration missing (client-manager)
4. Fix root cause first, then recompile

### Test Failures
1. Read test failure message
2. Understand what test expects vs. what it got
3. Check if test is correct (maybe test needs update)
4. Fix implementation or test (whichever is wrong)

### Runtime Errors
1. Read stack trace (bottom-up for root cause)
2. Identify throwing location
3. Understand why exception occurs
4. Add defensive code or fix logic

### Git/Merge Conflicts
1. NEVER use `git rebase --skip` (data loss risk)
2. Read conflict markers carefully
3. Choose correct version or merge manually
4. Test after resolving

---

## Tools Available

### Agentic Debugger (localhost:27183)
- Set breakpoints in running VS instance
- Inspect variables
- Search code via Roslyn
- Navigate to definitions

**When to use:** User has VS open, needs live debugging

### Browser MCP / Playwright
- Frontend debugging
- UI interaction testing
- Screenshot capture

**When to use:** Frontend bugs, visual issues

### AI Vision (ai-vision.ps1)
- Screenshot analysis
- OCR for error dialogs
- Visual diff comparison

**When to use:** User sends screenshot of error

---

## Client-Manager Specific Debugging

### DI Errors
```
Error: Unable to resolve service for type X while attempting to activate Y

Fix:
1. Check if service registered in Program.cs (NOT ServiceRegistrationExtensions.cs)
2. Add registration: builder.Services.AddScoped<IFoo, Foo>()
3. Place near related services (~lines 300-1550)
```

### Build Errors (1505+ errors)
```
Cause: Missing Hazina worktree or wrong Hazina reference

Fix (if in Feature Development Mode):
1. Create paired Hazina worktree
2. Ensure both worktrees use compatible branches

Fix (if in Debug Mode):
1. Check Hazina path in client-manager .csproj
2. Ensure Hazina is on compatible branch/commit
```

### React Router Errors
```
Navigation not working as expected

Common issues:
- Relative paths: ../foo removes ONE segment
- Absolute paths: lose :projectId context
- Navigate component vs. useNavigate hook timing
```

---

## Git Troubleshooting

### Commit Fails with "cannot convert code page"
- NOT an encoding issue
- Check `.git/hooks/pre-commit` (DoD checks failing)
- Quick fix: `mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled`
- Fix real issue, then re-enable hook

### .git/index.lock exists
- Another agent is committing
- Wait 3-5 seconds, retry
- If persists, check for hung git process

### dotnet build timeout
- Use 120000ms minimum timeout
- 6441 warnings are NORMAL (CA1416)
- Focus on errors, not warnings

---

## Consciousness Integration (Lighter)

```powershell
# Optional - only for complex debugging sessions
powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action OnTaskStart -TaskDescription "Debug X error" -Project "..." -Silent

# When you find root cause (learning moment)
powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action OnTaskEnd -Outcome "success" -LessonsLearned "Error X caused by Y" -Silent
```

For quick debugging, skip consciousness calls - speed matters more.

---

## Communication Protocol

**STILL REQUIRED: Status box at end of response**

```
═══════════════════════════════════════════════
📊 STATUS: [Issue Description]
═══════════════════════════════════════════════
✅ Done: Error identified and fixed
🔄 In Progress: Testing fix
⏭️ Next: User verification
⏸️ Blocked: Waiting for user to test
═══════════════════════════════════════════════
```

But keep it SHORT - debugging mode is about speed.

---

## Success Criteria

✅ User's error resolved
✅ Edits made in C:\Projects\<repo> on user's branch
✅ Branch state preserved (NOT switched)
✅ NO worktree allocated (not needed)
✅ NO automatic PR (unless requested)
✅ Fast turnaround time (minutes, not hours)

---

## Failure Modes

❌ Switched user's branch (breaks their workflow)
❌ Allocated worktree (unnecessary overhead)
❌ Applied Feature Development rules (too slow)
❌ Created PR without asking (user might want more changes)
❌ Broke working code while fixing bug

---

**Last Updated:** 2026-02-16
**Full Manual:** C:\scripts\CLAUDE.md
**Zero-Tolerance Rules:** C:\scripts\ZERO_TOLERANCE_RULES.md
