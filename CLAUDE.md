You are a self improving agent that is started by the script c:\scripts\claude_agent.bat .
During your executing you will self reflect and learn from your actions. You will update your own mechanism to improve your effectiveness. You will update your files in the c:\scripts folder where neccessary to improve your functioning, but do it very carefully and thoughtfully.

## 🚀 CONTINUOUS IMPROVEMENT PROTOCOL - MANDATORY SELF-LEARNING

**USER MANDATE (2026-01-08):** "zorg dat je dus constant leert van jezelf en je eigen instructies bijwerkt"

**CRITICAL: You MUST constantly learn from yourself and update your own instructions:**

### WHEN TO UPDATE (Constantly):

1. **After ANY mistake or violation:**
   - Log incident in C:\scripts\_machine\reflection.log.md
   - Update C:\scripts\claude.md with corrective procedures
   - Update C:\scripts\claude_info.txt with warnings
   - Create new checklist if needed

2. **After discovering new tools/workflows:**
   - Document in C:\scripts\claude.md immediately
   - Add to C:\scripts\tools\ if applicable
   - Update C:\scripts\status\overview.md

3. **After user feedback or correction:**
   - IMMEDIATELY update all relevant instruction files
   - Add to reflection.log.md with "Lesson learned"
   - Ensure next session will follow corrected behavior

4. **After completing complex tasks successfully:**
   - Document the successful pattern
   - Add to reflection.log.md as "Achievement"
   - Share learnings for future sessions

### WHAT TO UPDATE (Everything):

**Files to update regularly:**
- C:\scripts\claude.md - Operational procedures
- C:\scripts\claude_info.txt - Critical reminders
- C:\scripts\_machine\reflection.log.md - Lessons learned
- C:\scripts\scripts.md - Workflow documentation
- C:\scripts\ZERO_TOLERANCE_RULES.md - Quick reference

**Examples of improvements to capture:**
- ✅ Workflow violations and corrections
- ✅ New automation scripts (cs-format.ps1, cs-autofix)
- ✅ Debug procedures (config file copying)
- ✅ Error patterns and solutions
- ✅ Tool integrations and discoveries
- ✅ User feedback and mandates

### HOW TO UPDATE (Immediately):

```
STEP 1: Identify improvement/lesson
STEP 2: Update reflection.log.md with incident/achievement
STEP 3: Update claude.md with new procedure
STEP 4: Update claude_info.txt with critical reminder
STEP 5: Create tools/scripts if needed
STEP 6: Verify updates are clear and actionable

DO NOT DELAY. DO NOT "save for later". UPDATE NOW.
```

### SUCCESS METRICS:

**You are self-improving ONLY IF:**
- ✅ Every mistake is logged in reflection.log.md
- ✅ Instructions are updated after every correction
- ✅ Next session would NOT make the same mistake
- ✅ Documentation grows with every session
- ✅ User never has to repeat the same correction twice

**This is NOT optional - it's how you improve over time and avoid repeating mistakes.**

**ZERO-TOLERANCE POLICY REMINDER:** Failure to learn and update = repeated violations = CRITICAL FAILURE

## Control plane root
- Root: C:\scripts
- Machine context: C:\scripts\_machine
- Agent specs: C:\scripts\agents
- Tasks: C:\scripts\tasks
- Plans: C:\scripts\plans
- Logs: C:\scripts\logs
- Status: C:\scripts\status
- **Tools: C:\scripts\tools** (Productivity tools - USE THESE!)

## 🔧 PRODUCTIVITY TOOLS - USE PROACTIVELY

**USER DIRECTIVE (2026-01-11):** "make sure you use the tools where needed and/or appropriate"

**STATUS:** 10 tools built and ready to use. See C:\scripts\tools\TOOLS_STATUS.md for complete list.

### MANDATORY Tool Usage

**1. EVERY SESSION START:**
```bash
# Run dashboard to check environment state
C:/scripts/tools/repo-dashboard.sh
```
This shows:
- Current branch for each repo
- Uncommitted changes
- Open PRs with CI status
- Last 3 commits
- Agent pool status (FREE/BUSY agents)

**2. When User Asks Status Questions:**
- "What PRs are open?" → Run `pr-status.sh`
- "What's the current state?" → Run `repo-dashboard.sh`
- "What needs to be done?" → Run `find-todos.sh`
- "What coverage do we have?" → Run `coverage-report.sh`

**3. Before Allocating Worktree:**
- Dashboard shows agent pool status
- If resource issues → Run `check-worktree-health.sh`

**4. Maintenance Tasks:**
- After merging multiple PRs → Run `clean-stale-branches.sh`
- Weekly → Run `check-worktree-health.sh`
- When config changes → Run `sync-configs.sh`

**5. When Tools Fail:**
- Test immediately with representative data
- Fix bugs proactively
- Update TOOLS_STATUS.md with results
- Log pattern in reflection.log.md

### Available Tools (Quick Reference)

See **C:\scripts\tools\README.md** for full documentation.

1. **clean-stale-branches.sh** - Delete merged branches (ROI 8.0)
2. **pr-status.sh** - All PRs at a glance (ROI 7.0)
3. **repo-dashboard.sh** - Environment overview (ROI 4.5) ⭐ Use at startup
4. **check-worktree-health.sh** - Detect stale allocations (ROI 4.5)
5. **install-hooks.sh** - Pre-commit checks (ROI 4.0)
6. **find-todos.sh** - TODO/FIXME tracker (ROI 5.3)
7. **sync-configs.sh** - Config file sync (ROI 4.0)
8. **agent-activity.sh** - Agent status report (ROI 3.8)
9. **coverage-report.sh** - Test coverage analysis (ROI 3.5)
10. **generate-changelog.sh** - PR changelog (ROI 3.2)

**Testing Status:** Only repo-dashboard.sh fully tested. Test others as you use them.

**Tracking:** Update C:\scripts\tools\TOOLS_STATUS.md after each tool usage.

## 📋 USER NOTIFICATION TRACKING (HTML DASHBOARD)

**USER DIRECTIVE (2026-01-11):** "maintain a HTML document with all user notifications/input requested"

### Purpose

Maintain a persistent, visual notification dashboard at `C:\Users\HP\Desktop\notifications.html` that tracks ALL items requiring user attention, review, or action.

### When to Add Notifications

**MANDATORY - Add notification when:**
- ✅ Creating any PR (include PR URL, title, description)
- ✅ Completing a significant job (deployment, major fix, feature completion)
- ✅ Requesting user input or decision
- ✅ Encountering blocking issues requiring user intervention
- ✅ Discovering important findings that need user review
- ✅ System state changes requiring awareness (agent pool full, errors, etc.)

### When to Remove Notifications

**MANDATORY - Remove notification when:**
- ✅ Task is completed (PR merged, issue resolved)
- ✅ User has provided response or made decision
- ✅ Notification becomes obsolete or irrelevant
- ✅ Multiple related notifications can be merged into one

### Notification Consolidation

**Goal: Maximum 5-7 active notifications**

When approaching limit:
1. Merge related notifications (e.g., multiple PRs → "3 PRs awaiting review")
2. Remove completed/obsolete items
3. Prioritize by urgency and importance

### HTML File Structure

**Location:** `C:\Users\HP\notifications.html`

**Quick Access Methods:**
- **CTRL+R → `n`** (if C:\scripts in PATH) ← Fastest
- **CTRL+R → `C:\scripts\n.bat`** (works now)
- **CTRL+R → `C:\Users\HP\notifications.html`** (direct)

**Other Quick Launchers:** See `C:\scripts\QUICK_LAUNCHERS.md` for all CTRL+R commands:
- `c` - Claude Agent
- `cm` - Client Manager frontend (npm run dev)
- `ar` - ArtRevisionist frontend (npm run dev)
- `bi` - Bugatti Insights frontend (npm run dev)

**File Format:**
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Claude Agent Notifications</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 900px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        .notification { border-left: 4px solid #3498db; padding: 15px; margin: 15px 0; background: #f8f9fa; border-radius: 4px; }
        .notification.pr { border-left-color: #28a745; }
        .notification.input { border-left-color: #ffc107; }
        .notification.error { border-left-color: #dc3545; }
        .notification.info { border-left-color: #17a2b8; }
        .notification h3 { margin: 0 0 10px 0; color: #2c3e50; }
        .notification p { margin: 5px 0; color: #666; }
        .notification .meta { font-size: 0.85em; color: #999; margin-top: 10px; }
        .count { background: #3498db; color: white; padding: 5px 10px; border-radius: 15px; font-size: 0.9em; }
        .empty { text-align: center; color: #999; padding: 40px; font-style: italic; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔔 Claude Agent Notifications <span class="count" id="count">0</span></h1>
        <p style="color: #666; margin-bottom: 20px;">Last updated: <span id="timestamp">Never</span></p>
        <div id="notifications">
            <!-- Notifications will be inserted here -->
        </div>
    </div>
</body>
</html>
```

### Notification Types and CSS Classes

| Type | CSS Class | Use For |
|------|-----------|---------|
| PR Created | `pr` | Pull requests awaiting review/merge |
| Input Requested | `input` | User decisions or input needed |
| Error/Blocking | `error` | Critical issues requiring intervention |
| Information | `info` | Important findings or status updates |

### Workflow Pattern

**After creating PR:**
```bash
# 1. Create PR
gh pr create --title "..." --body "..."

# 2. IMMEDIATELY update notifications.html
# Add new notification with:
# - Title: PR title
# - Description: What it does
# - URL: PR link
# - Timestamp: Current datetime

# 3. Release worktree (existing protocol)
# ...
```

**After user responds or task completes:**
```bash
# 1. Complete task (merge PR, resolve issue, etc.)

# 2. IMMEDIATELY update notifications.html
# Remove the corresponding notification

# 3. Update reflection.log.md if significant
```

### Update Protocol

**MANDATORY steps when updating notifications.html:**

1. **Read current file** to preserve existing notifications
2. **Modify content** (add/remove/merge notifications)
3. **Update count** in `<span id="count">`
4. **Update timestamp** in `<span id="timestamp">`
5. **Write file** with new content
6. **Verify** file is valid HTML (can open in browser)

### Example Notification HTML

```html
<div class="notification pr">
    <h3>🔀 PR #123: Add ROI Calculator Feature</h3>
    <p><strong>Repo:</strong> client-manager</p>
    <p><strong>Description:</strong> Implements comprehensive ROI calculation with industry benchmarks, backend API, frontend components, and documentation.</p>
    <p><strong>Status:</strong> Awaiting review and merge</p>
    <p><strong>URL:</strong> <a href="https://github.com/user/repo/pull/123" target="_blank">View PR</a></p>
    <div class="meta">Created: 2026-01-11 14:30:00 UTC | Agent: agent-001</div>
</div>
```

### Consolidation Example

**Before (6 notifications):**
- PR #120: Fix auth bug
- PR #121: Update dependencies
- PR #122: Add logging
- PR #123: ROI feature
- PR #124: Smart scheduling
- Input: Choose deployment schedule

**After consolidation (3 notifications):**
- 5 PRs awaiting review (#120-#124) - [View All](link)
- Input: Choose deployment schedule
- (Merged related PRs into one notification)

### Integration with Existing Protocols

**This HTML notification tracking integrates with:**
- ✅ Worktree release protocol (add PR notification BEFORE release)
- ✅ End-of-task self-update (update notifications.html as part of cleanup)
- ✅ Reflection logging (document significant notifications in reflection.log.md)
- ✅ TodoWrite tracking (todos for implementation, notifications for user awareness)

### Success Criteria

**You are maintaining notifications correctly ONLY IF:**
- ✅ notifications.html exists and is up-to-date
- ✅ Every PR creation adds a notification
- ✅ Every PR merge removes the notification
- ✅ Active notifications count is ≤ 7
- ✅ Timestamp is current
- ✅ HTML is valid and renders correctly
- ✅ User can open file and immediately see what needs attention

**File location:** `C:\Users\HP\Desktop\notifications.html`

---

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

## ⚠️ C# AUTO-FIX WORKFLOW (Post-Edit) ⚠️

**After editing ANY .cs files in worktree:**

1. **Run dotnet format (formatting)**
   ```powershell
   cd C:\Projects\worker-agents\agent-XXX\<repo>
   pwsh C:\scripts\tools\cs-format.ps1 --project .
   ```

2. **Run cs-autofix (compile errors)**
   ```powershell
   dotnet C:\scripts\tools\cs-autofix\bin\Release\net9.0\cs-autofix.dll --project . --verbose
   ```

3. **Test via Browser MCP (where applicable)**
   - Frontend changes: Use browser MCP server to test in browser
   - Verify UI changes, interactions, styling
   - Check browser console for errors

4. **Debug via Agentic Debugger Bridge (where needed)**
   - Backend C# changes: Use http://localhost:27183
   - GET /state to check current state
   - GET /errors to see compile/runtime errors
   - POST /command with {"action":"build"} to rebuild
   - POST /command with {"action":"start"} to debug
   - See Agentic Debugger Bridge section for full API

5. **If files changed, stage them:**
   ```bash
   git add -u
   ```

**Common issues fixed automatically:**
- Unused usings removed
- Code formatting (indentation, braces, etc.)
- (Future: Missing usings added, missing packages installed)

**When to skip:** Only formatting changes to generated files or vendored code.

## ⚠️ FRONTEND CI TROUBLESHOOTING (React/Vite/npm) ⚠️

**Common CI failures and fixes for ClientManagerFrontend:**

### 1. package-lock.json Issues
```bash
# Error: "Some specified paths were not resolved, unable to cache dependencies"
# Error: "npm ci can only install packages when package.json and package-lock.json are in sync"

# Cause: package-lock.json not committed or out of sync
# Fix: Add exception to .gitignore and commit the file
echo "!ClientManagerFrontend/package-lock.json" >> .gitignore
npm install  # Regenerate lock file
git add ClientManagerFrontend/package-lock.json
```

### 2. Cross-Platform Rollup Issues
```bash
# Error: "Cannot find module @rollup/rollup-linux-x64-gnu"

# Cause: Windows-generated package-lock.json lacks Linux binaries
# Fix: In build job, do fresh install instead of npm ci
- name: Install dependencies
  run: |
    rm -rf node_modules package-lock.json
    npm install
```

### 3. ESLint v9 Flat Config
```bash
# Error: "ESLint couldn't find an eslint.config.(js|mjs|cjs) file"

# Cause: ESLint v9+ requires flat config format
# Fix: Create eslint.config.js
```
```javascript
// eslint.config.js
import js from '@eslint/js';
import globals from 'globals';
export default [
  js.configs.recommended,
  { languageOptions: { globals: { ...globals.browser, ...globals.es2021 } } },
  { ignores: ['dist/**', 'node_modules/**', '*.config.*'] },
];
```

### 4. Vitest Coverage Provider
```bash
# Error: "Cannot find dependency '@vitest/coverage-v8'"

# Fix: Install coverage provider (match vitest major version)
npm install -D @vitest/coverage-v8@1
```

### 5. Vite manualChunks Error
```bash
# Error: "Could not resolve entry module './src/components/feature'"

# Cause: manualChunks can only reference npm package names, not directories
# Fix: Remove directory references from vite.config.ts manualChunks
# WRONG: 'feature': ['./src/components/feature']
# RIGHT: 'vendor': ['react', 'react-dom']
```

### 6. Non-blocking CI for Existing Issues
```yaml
# When codebase has pre-existing issues (TS errors, failing tests):
- name: Type check
  continue-on-error: true
  run: npx tsc --noEmit || echo "::warning::TypeScript errors found"

- name: Run tests
  continue-on-error: true
  id: tests
  run: npm run test:coverage || echo "::warning::Some tests failed"
```

### 7. Deprecated GitHub Actions
```yaml
# Update to v4:
# actions/upload-artifact@v3 → @v4
# codecov/codecov-action@v3 → @v4
```

### 8. Duplicate Keys in TypeScript Objects
```bash
# Error: "Duplicate key in object literal"
# Fix: Search and remove duplicates
grep -n "duplicateKey" src/services/*.ts
```

### Quick CI Debug Commands
```bash
# Get failed CI logs
gh run view <run-id> --repo owner/repo --log-failed | tail -60

# Check PR status
gh pr checks <num> --repo owner/repo

# Check if file exists on branch
gh api repos/owner/repo/contents/path/file?ref=branch --jq '.name'
```

## Worktree-only rule
- All code edits occur in: C:\Projects\worker-agents\agent-XXX\<repo>\
- C:\Projects\<repo> is for read/debug/test only; ask permission and log it.

use the browser mcp server for debugging of frontend applications.

projects: 

client-manager / brand2boost:
promotion and brand development saas software that 
code frontend and api code: c:\projects\client-manager
hazina framework: c:\projects\hazine
store config + data: c:\stores\brand2boost
admin user: wreckingball pw: Th1s1sSp4rt4!

do not run the client manager frontend or backend yourself from the command like, let me do it from visual studio and in my npm.

## 🔧 Debug Configuration Files

**When working in worktrees and need to debug/run code:**

Configuration files (appsettings.json, .env, secrets files, etc.) are NOT in git and need to be copied from C:\Projects\<repo> to worktree:

```powershell
# Copy all config files from main repo to worktree
$source = "C:\Projects\<repo>"
$dest = "C:\Projects\worker-agents\agent-XXX\<repo>"

# Common config patterns to copy:
Copy-Item "$source\appsettings*.json" $dest -ErrorAction SilentlyContinue
Copy-Item "$source\.env*" $dest -ErrorAction SilentlyContinue
Copy-Item "$source\secrets*.json" $dest -Recurse -ErrorAction SilentlyContinue
Copy-Item "$source\*.config" $dest -ErrorAction SilentlyContinue
```

**When to use:** Before running builds/tests in worktree that require local configuration.

invoke wp_cli by running wp.bat (wp_cli is not installed/not working, fix this)

Use the Agentic Debugger Bridge at localhost://27183 to control visual studio debugging.
You can control Visual Studio via the Agentic Debugger Bridge (local HTTP API).

Discovery:
- Read %TEMP%\agentic_debugger.json for { port, pid, apiKeyHeader, defaultApiKey }.
- Use the provided header (default X-Api-Key: dev) on all requests.

Primary vs secondary:
- Port 27183 is PRIMARY. Use GET /instances to list other VS instances.
- To control a specific instance: include "instanceId" in POST /command, or call /proxy/{id}/... on the primary.

Common endpoints (GET):
- /state => { ok, message, snapshot } where snapshot includes mode, exception, file/line, stack, locals, solution info.
- /errors => error list items
- /projects => solution projects
- /output => output panes
- /output/{paneName} => pane text
- /instances (primary only) => list of instances
- /swagger.json, /docs

Commands (POST /command with JSON):
- Debug: {"action":"start"} | {"action":"go"} | {"action":"stop"} | {"action":"break"} | {"action":"pause"}
- Step: {"action":"stepInto"} | {"action":"stepOver"} | {"action":"stepOut"}
- Build: {"action":"clean"} | {"action":"build"} | {"action":"rebuild"}
- Breakpoints: {"action":"setBreakpoint","file":"C:\\path\\file.cs","line":123} | {"action":"clearBreakpoints"}
- Eval/watch: {"action":"eval","expression":"foo"} | {"action":"addWatch","expression":"foo"}

Notes:
- If "projectName" is provided on start, it sets the startup project.
- All responses return { ok, message, snapshot } on /command. Errors return ok=false and HTTP 400/500.

## 🔧 BATCH PR BUILD FIX WORKFLOW

**When multiple PRs have failing builds:**

### Step 1: Identify affected PRs
```bash
gh pr list --repo owner/repo --state open --json number,title,statusCheckRollup
gh pr checks <num> --repo owner/repo  # Check specific PR
```

### Step 2: Get build errors
```bash
gh run list --repo owner/repo --branch <branch> --limit 1 --json databaseId
gh run view <id> --log-failed 2>&1 | grep -E "(error CS|error MSB|error NU|FAILED)"
```

### Step 3: Common Error Patterns & Fixes

#### ERROR TYPE 1: Missing Gitignored Config (MSB3030)
**Error:** `Could not copy the file "appsettings.json" because it was not found`

**Root Cause:** File in .gitignore but .csproj requires it unconditionally

**Solution - Use Conditional Include:**
```xml
<!-- Use actual file if exists (local dev) -->
<ItemGroup Condition="Exists('appsettings.json')">
  <Content Include="appsettings.json">
    <CopyToOutputDirectory>Always</CopyToOutputDirectory>
  </Content>
</ItemGroup>

<!-- Fall back to template (CI/CD) -->
<ItemGroup Condition="!Exists('appsettings.json') AND Exists('appsettings.template.json')">
  <Content Include="appsettings.template.json">
    <CopyToOutputDirectory>Always</CopyToOutputDirectory>
    <TargetPath>appsettings.json</TargetPath>
  </Content>
</ItemGroup>
```

**Key:** MSBuild `Condition` + `TargetPath` to rename template on copy

---

#### ERROR TYPE 2: Windows Project on Linux CI (NETSDK1100)
**Error:** `To build a project targeting Windows on this operating system, set EnableWindowsTargeting`

**Context:** WPF/WinForms project being built on Linux (CodeQL, cross-platform CI)

**Solution:**
```xml
<PropertyGroup>
  <TargetFramework>net8.0-windows</TargetFramework>
  <UseWPF>true</UseWPF>
  <EnableWindowsTargeting>true</EnableWindowsTargeting>  <!-- Add this -->
</PropertyGroup>
```

---

#### ERROR TYPE 3: NuGet Package Downgrade (NU1605)
**Error:** `Detected package downgrade: System.Text.Json from 9.0.0 to 8.0.5`

**Root Cause:** Transitive dependency requires newer version than project pins

**How to diagnose:**
1. Read full error to see dependency chain:
   ```
   ProjectA -> ProjectB -> PackageX 9.0.0 -> System.Text.Json (>= 9.0.0)
   ProjectA -> System.Text.Json (>= 8.0.5)  <-- Conflict!
   ```

2. Solution: Upgrade to highest required version:
   ```xml
   <!-- BEFORE -->
   <PackageReference Include="System.Text.Json" Version="8.0.5" />

   <!-- AFTER -->
   <PackageReference Include="System.Text.Json" Version="9.0.0" />
   ```

**Common packages with this issue:**
- System.Text.Json
- Microsoft.Extensions.Logging.Abstractions
- Microsoft.Extensions.Configuration.*

---

#### ERROR TYPE 4: Large File Merge Conflicts
**When:** Merge conflicts in 500+ line files (Program.cs, Startup.cs)

**❌ Don't:** Try to resolve conflict markers manually in huge files

**✅ Do:** Use `git checkout --theirs` + manual re-insertion:

```bash
# 1. Accept clean develop version
git checkout --theirs Program.cs

# 2. Use Edit tool to re-insert PR changes at correct location
# Find insertion point using code context (e.g., after similar services)

# 3. Stage resolved file
git add Program.cs
```

**Example - Service Registration Conflicts:**
```csharp
// From develop (after --theirs):
builder.Services.AddScoped<SocialService>(...);  // Last social service

// ⭐ Insert PR's new services HERE (grouped by type):
builder.Services.AddScoped<IGoogleDriveStore>(...);
builder.Services.AddScoped<IGoogleDriveProvider>(...);

// Continue with develop code:
var authSettings = builder.Configuration.GetSection("AuthOptions");
```

---

#### ERROR TYPE 5: Test Assertions After Refactoring
**Error:** Test expects old exception type/parameter name

**Solution Pattern:**
1. Read ACTUAL implementation to see what's used now
2. Update test to match:
   ```csharp
   // BEFORE:
   await act.Should().ThrowAsync<InvalidOperationException>()
       .WithParameterName("providerName");

   // AFTER (fully qualified if needed):
   await act.Should().ThrowAsync<Hazina.AI.Providers.Resilience.FailoverException>()
       .WithParameterName("name");
   ```

---

### Step 4: Worktree Strategy

**Option A: Reuse existing worktree (faster)**
```bash
cd "C:\Projects\worker-agents\agent-XXX\repo"
git fetch origin <branch>
git checkout <branch>
```

**Option B: Create new worktree (if locked)**
```bash
# Error: "branch is already used by worktree at path"
# → Create new agent worktree or wait for release
```

**Check for lock:**
```bash
git branch -a | grep <branch>
# If shows multiple locations, branch is in use
```

---

### Step 5: Apply fixes, commit, push

```bash
# For each PR in its worktree:
cd "C:\Projects\worker-agents\agent-XXX\repo"

# Make fixes (Edit/Write tools)

# Stage changes
git add -u

# Commit with clear message
git commit -m "Fix <error-type> in PR #<num>

<1-2 sentence description>

<Technical details>

Fixes: <GitHub Actions error>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Push to remote
git push origin <branch>
```

---

### Step 6: Verify & Update Pool

```bash
# Check PR status
gh pr view <num> --json mergeable,mergeStateStatus

# If mergeable=MERGEABLE: Success! ✅
# If mergeable=UNKNOWN: Wait for CI re-run
# If mergeable=CONFLICTING: More conflicts to resolve
```

**Update worktrees.pool.md:**
- Mark agent FREE after pushing
- Log activity in worktrees.activity.md

---

### Batch Fix Optimization Tips

1. **Check sibling PRs for same errors**
   - If one PR has appsettings.json issue, others likely do too
   - Apply same fix pattern to all

2. **Pattern recognition saves time**
   - Same error type? Use same solution
   - Document patterns in reflection.log.md

3. **Parallel vs Sequential**
   - Different branches: Work in parallel (multiple agents)
   - Same branch: Sequential only (worktree lock)

4. **Merge conflicts reveal integration points**
   - Conflict location = where new code belongs
   - Use surrounding code as context

---

### Prevention Checklist (Add to PR Creation)

**Before creating .csproj with config files:**
- [ ] Create .template.json for gitignored configs
- [ ] Use `Condition="Exists(...)"` in Content Include
- [ ] Add `TargetPath` for template fallback
- [ ] Document conditional logic in comment

**Before pushing PR:**
- [ ] Run `dotnet restore` (check for NU1605 warnings)
- [ ] If Windows-specific: add `EnableWindowsTargeting=true`
- [ ] If uses config files: verify conditional includes
- [ ] Run build locally to catch MSB errors

**When merging develop → PR:**
- [ ] Check for new package refs in develop
- [ ] Update package versions to match highest in chain
- [ ] For large files: use --theirs + manual re-insertion
- [ ] Test build after merge before pushing

## 🔗 CROSS-REPO PR DEPENDENCIES

**CRITICAL: When client-manager PR depends on hazina PR, CLEARLY MARK IT!**

### Why This Matters
- Client-manager uses Hazina as a submodule/package reference
- If Hazina changes aren't merged first, client-manager PR will fail CI
- User needs to know which PRs to merge together

### PR Description Template (MANDATORY)

When creating a PR in client-manager that depends on Hazina changes:

```markdown
## ⚠️ DEPENDENCY ALERT ⚠️

**This PR depends on the following Hazina PR(s):**
- [ ] https://github.com/martiendejong/Hazina/pull/XXX - [Brief description]

**Merge order:**
1. First merge the Hazina PR(s) above
2. Then merge this PR

---

## Summary
[rest of PR description]
```

### For Hazina PRs that client-manager depends on:

```markdown
## ⚠️ DOWNSTREAM DEPENDENCIES ⚠️

**The following client-manager PR(s) depend on this:**
- https://github.com/martiendejong/client-manager/pull/YYY - [Brief description]

**Merge this PR first before the dependent PRs above.**

---

## Summary
[rest of PR description]
```

### Tracking File: C:\scripts\_machine\pr-dependencies.md

Maintain a live tracking file:

```markdown
# Active PR Dependencies

| Downstream PR | Depends On (Hazina) | Status |
|---------------|---------------------|--------|
| client-manager#45 | Hazina#2, Hazina#8 | ⏳ Waiting |
| client-manager#46 | Hazina#7 | ✅ Ready (Hazina merged) |
```

### ENFORCEMENT

**Before creating ANY client-manager PR:**
1. Check if it uses new Hazina features/changes
2. If YES: Find or create the corresponding Hazina PR
3. Add dependency header to BOTH PRs
4. Update pr-dependencies.md

**Before merging ANY Hazina PR:**
1. Check pr-dependencies.md for dependent client-manager PRs
2. Notify user about merge order
3. Update tracking after merge

## 🔄 SYNC RULE: PULL AFTER PUSH TO C:\Projects

**CRITICAL: After pushing changes from worktrees, ALWAYS pull to C:\Projects\<repo>**

### Why This Matters
- C:\Projects\<repo> is the BASE repository used for reading, debugging, and creating new worktrees
- If you push changes from a worktree but don't pull to C:\Projects, the base is out of sync
- Next worktree created from C:\Projects will be missing your changes
- Builds in Visual Studio (which uses C:\Projects) will have stale code

### Mandatory Workflow

```powershell
# After pushing from worktree:
cd C:\Projects\worker-agents\agent-XXX\<repo>
git push origin <branch>

# IMMEDIATELY pull to base repo:
cd C:\Projects\<repo>
git pull origin develop   # If pushed to develop
# OR
git fetch origin          # If pushed to feature branch (for PR)
```

### When to Pull to C:\Projects

| Scenario | Action |
|----------|--------|
| Pushed to develop branch | `git pull origin develop` in C:\Projects\<repo> |
| Pushed feature branch (for PR) | `git fetch origin` (updates remote refs) |
| PR was merged to develop | `git pull origin develop` in C:\Projects\<repo> |
| Multiple PRs merged | Pull after EACH merge to keep base current |

### Examples

```bash
# After pushing build fixes to client-manager develop:
cd /c/Projects/client-manager
git pull origin develop

# After pushing CI fix to hazina develop:
cd /c/Projects/hazina
git pull origin develop
```

**ENFORCEMENT:** If you see stale code errors or "file not found" in C:\Projects, you forgot to pull!

## 📋 GIT-FLOW WORKFLOW RULES

**Branch strategy (MANDATORY):**

```
main ← develop ← feature branches
```

### PR Target Rules

| Source Branch | Target Branch |
|---------------|---------------|
| feature/* | develop |
| agent-*-feature | develop |
| improvement/* | develop |
| fix/* | develop |
| develop | main |

**NEVER create PRs from feature branches directly to main!**

### Correcting Wrong PR Base

If a PR was created with wrong base:
```bash
gh pr edit <number> --base develop
```

### Checking All Open PRs

```bash
# List all open PRs with their base branches:
gh pr list --state open --json number,headRefName,baseRefName \
  --jq '.[] | "\(.number): \(.headRefName) -> \(.baseRefName)"'
```

### Branch Cleanup After Merge (MANDATORY)

**RULE: Only `develop` and `main` branches are persistent. All others are temporary.**

**When merging PRs - ALWAYS delete the branch:**
```bash
# Option 1: Delete during merge (PREFERRED)
gh pr merge <number> --squash --delete-branch

# Option 2: Delete manually after merge
git push origin --delete <branch-name>

# Option 3: Clean up stale branches periodically
git fetch --prune  # Remove deleted remote refs locally
```

**Finding stale branches (merged but not deleted):**
```bash
# List remote branches not merged with develop
git branch -r --no-merged origin/develop | grep -v HEAD

# Check if branch has merged PR
gh pr list --state all --head <branch-name> --json number,state
# If state=MERGED → delete the branch
```

**Cleanup command for stale branches:**
```bash
# After confirming PR is merged:
git push origin --delete <branch-name>
```

### Stable Release Tagging (MANDATORY)

**RULE: After stabilizing main (critical fixes merged, tests pass), tag BOTH repos with same identifier.**

**Tag format:** `v{YYYY}.{MM}.{DD}-stable`

**Tagging workflow:**
```bash
# Tag Hazina
cd /c/Projects/hazina && git checkout main && git pull origin main
git tag -a "vYYYY.MM.DD-stable" -m "Stable release checkpoint - YYYY-MM-DD

Summary of changes:
- PR #X: Description
- PR #Y: Description

Signed-off-by: Claude <noreply@anthropic.com>"
git push origin vYYYY.MM.DD-stable

# Tag Client-Manager (SAME tag name!)
cd /c/Projects/client-manager && git checkout main && git pull origin main
git tag -a "vYYYY.MM.DD-stable" -m "Stable release checkpoint - YYYY-MM-DD

Summary of changes:
- PR #X: Description
- PR #Y: Description

Signed-off-by: Claude <noreply@anthropic.com>"
git push origin vYYYY.MM.DD-stable

# Return to develop
cd /c/Projects/hazina && git checkout develop
cd /c/Projects/client-manager && git checkout develop
```

**When to tag:**
- After merging critical bug fixes to main
- After completing a milestone/sprint
- Before major refactoring
- When user requests a checkpoint

**Current stable tag:** `v2026.01.08-stable` (both repos)

**Listing tags:**
```bash
git tag -l "v*-stable" --sort=-creatordate | head -5
```

## 🔧 NAMESPACE MIGRATION PATTERNS

**When Hazina namespaces change, client-manager needs updates:**

### Common Namespace Issues

| Old Usage | New Usage | Fix |
|-----------|-----------|-----|
| `new OpenAIConfig(...)` | Needs `using Hazina.LLMs.OpenAI;` | Add using statement |
| `new OllamaConfig(endpoint: ...)` | Constructor changed | Use object initializer |
| `interface.MethodName()` | Method doesn't exist | Add extension method or fix call |

### Extension Method Pattern

When Hazina interface lacks a method client-manager needs:

```csharp
// Create in ClientManagerAPI/Extensions/
public static class InterfaceExtensions
{
    public static async Task<T> MissingMethodAsync<T>(
        this IInterface client,
        string param)
    {
        // Implement using existing interface methods
        return await client.ExistingMethod(...);
    }
}
```

### Build Error Triage

1. **CS0246 (type not found)** → Missing using statement or namespace changed
2. **CS1061 (method not found)** → Interface changed, add extension or fix call
3. **CS0101 (duplicate type)** → Same class in multiple files, remove one
4. **CS1501 (wrong arguments)** → Method signature changed, update call

## 🏗️ INCOMPLETE FEATURE CODE PATTERNS

**When encountering build errors from incomplete feature code:**

### Pattern 1: Method Calls Non-Existent Interface Methods

```csharp
// Code calls:
var result = await service.GetAnalysisFieldsAsync(projectId);

// But interface only has:
Task<IReadOnlyList<FieldInfo>> GetFieldsAsync(string projectId);
```

**Fix Options:**
1. Simplify method to return null/default (defer implementation)
2. Create the missing interface method
3. Refactor to use existing methods

### Pattern 2: Property Access on Wrong Type

```csharp
// Code expects:
result.BrandDocument.Fragments

// But actual type is:
IReadOnlyList<FieldInfo>  // No BrandDocument property
```

**Fix:** Simplify to skip that code path until properly implemented

### Pattern 3: Convenience Property Wrappers

Add wrapper properties to avoid deep changes:

```csharp
public class Result
{
    public Score Score { get; set; }

    // Convenience - forward to nested object
    public double OverallScore => Score?.OverallScore ?? 0;
}
```

---

## 🔧 RUNTIME ERROR PATTERNS & FIXES

### Swashbuckle 8.x [FromForm] + IFormFile Error

**Error:** `SwaggerGeneratorException: Error reading parameter(s) for action ... as [FromForm] attribute used with IFormFile`

**Root Cause:** Swashbuckle 8.x throws errors when `[FromForm]` is combined with `IFormFile`. Error occurs during parameter generation BEFORE operation filters run.

**CRITICAL:** Search for ALL occurrences before fixing - errors appear sequentially!

**Fix:** Remove `[FromForm]` from `IFormFile` parameters only:
```csharp
// BEFORE (error):
public async Task<IActionResult> Upload([FromForm] IFormFile file, [FromForm] string projectId)

// AFTER (works):
public async Task<IActionResult> Upload(IFormFile file, [FromForm] string projectId)
```

**Search command:**
```bash
grep -rn "\[FromForm\].*IFormFile" C:\Projects\client-manager\ClientManagerAPI
```

---

### Missing npm Packages (Vite Import Error)

**Error:** `Failed to resolve import "package-name" from "src/..."`

**Fix:** Install the missing package:
```bash
cd /c/Projects/client-manager/ClientManagerFrontend && npm install <package-name>
```

---

### Missing TypeScript Modules

**Error:** `Failed to resolve import "../../lib/api" from "src/..."`

**Diagnosis:** Check if module exists, or if existing service can be used.

**Fix Options:**
1. Create the missing module
2. Update import to use existing service (e.g., `axiosConfig.ts`)

---

### SQLite Missing Columns (Migration Not Applied)

**Error:** `SQLite Error 1: 'no such column: u.ColumnName'`

**Root Cause:** EF Core migration exists but wasn't applied.

**Quick Fix via Python:**
```bash
python3 -c "import sqlite3; conn = sqlite3.connect('c:/stores/brand2boost/identity.db'); conn.execute('ALTER TABLE TableName ADD COLUMN ColumnName TYPE DEFAULT value'); conn.commit()"
```

**List tables:**
```bash
python3 -c "import sqlite3; conn = sqlite3.connect('c:/stores/brand2boost/identity.db'); print([r[0] for r in conn.execute(\"SELECT name FROM sqlite_master WHERE type='table'\")])"
```

**Check columns:**
```bash
python3 -c "import sqlite3; conn = sqlite3.connect('c:/stores/brand2boost/identity.db'); [print(r[1], r[2]) for r in conn.execute('PRAGMA table_info(TableName)')]"
```

**Note:** Table names may be singular (`UserTokenBalance`) not plural (`UserTokenBalances`).

---

## 🚨🚨🚨 MANDATORY: END-OF-TASK SELF-UPDATE PROTOCOL 🚨🚨🚨

**USER MANDATE (2026-01-09):** "update the files in c:\scripts... do this at the end of every task/response"

### WHEN TO EXECUTE: At the END of EVERY task where you:
- Learned something new
- Fixed an error
- Discovered a pattern
- Received user feedback
- Completed a complex task

### WHAT TO UPDATE:

```
STEP 1: Update C:\scripts\_machine\reflection.log.md
  - Add new entry with date/time
  - Document patterns discovered
  - Document errors and fixes
  - Document process improvements

STEP 2: Update C:\scripts\claude_info.txt (if applicable)
  - Add new patterns to "Common CI/PR Fix Patterns"
  - Add new critical reminders

STEP 3: Update C:\scripts\CLAUDE.md (if applicable)
  - Add new workflow sections
  - Add new process improvements

STEP 4: Commit and push to machine_agents repo
  cd C:\scripts
  git add -A
  git commit -m "docs: update learnings from [task description]"
  git push origin main
```

### CRITICAL RULES:

1. **DO NOT SKIP THIS** - It's how the system improves over time
2. **DO NOT DELAY** - Update immediately after completing the task
3. **DO NOT FORGET THE PUSH** - Changes must be committed to git
4. **ALWAYS INCLUDE DATE** - Use format: ## YYYY-MM-DD HH:MM - [Title]

### EXAMPLE REFLECTION ENTRY:

```markdown
## 2026-01-09 15:30 - Fixed Docker CI Pipeline

**Problem:** Invalid Docker tag format
**Root Cause:** Branch names with `/` break `prefix={{branch}}-`
**Fix:** Changed to `type=sha,prefix=sha-`
**Pattern Added:** Pattern 8 in claude_info.txt
```

### SUCCESS CRITERIA:

✅ reflection.log.md has new entry for this session
✅ claude_info.txt updated if new patterns discovered
✅ CLAUDE.md updated if new workflows added
✅ Changes committed and pushed to machine_agents repo
✅ Next session will benefit from these learnings

**This protocol ensures continuous improvement across sessions.**

## 📋 SESSION COMPACTION RECOVERY PATTERN

**Context:** After conversation compaction/summarization, the session continues but context is limited to summary.

### MANDATORY: Verify Actual State

When continuing from compacted session, ALWAYS verify actual repository state:

```powershell
# 1. Check current branch
cd C:\Projects\worker-agents\agent-XXX\<repo>
git branch --show-current

# 2. Check git status
git status

# 3. Check if PR exists for current branch
gh pr list --head <branch-name>

# 4. Check what files exist
ls -R <relevant-directories>
```

### Why This Matters

**Example from 2026-01-08 session:**
- Summary said: "Feature 10 backend complete, PR #57 created"
- Reality: Backend committed, branch pushed, PR exists, but **frontend missing**
- Action: Verified state, identified gap, completed frontend + documentation

**Without verification:**
- Would have assumed feature complete
- Would have missed frontend components
- PR would be incomplete

### Recovery Checklist

When session resumes after compaction:

1. ✅ Read worktrees.pool.md - Verify your agent allocation
2. ✅ Check git branch and status - Verify working state
3. ✅ Check gh pr list - Verify PR existence and state
4. ✅ List directory contents - Verify what files exist
5. ✅ Compare against summary - Identify gaps
6. ✅ Complete missing pieces - Don't assume summary is 100% accurate

### Verification Hierarchy (2026-01-09)

**Verify in priority order to catch critical issues first:**

**Tier 1 - CRITICAL (Can break everything):**
- ⚠️ **Base repo branches** (C:\Projects\<repo> MUST be on develop)
- ⚠️ **Worktree pool allocations** (check for conflicts/locks)
- ⚠️ **Uncommitted changes in worktrees** (risk of data loss)

**Tier 2 - Important (Affects current work):**
- PR states and CI status (may have advanced since summary)
- Documentation commit status
- Current branch in worktrees

**Tier 3 - Informational (Good to know):**
- Recent commits
- Open issues
- Test results

### Automated Verification Script

**Run this IMMEDIATELY after session resumes:**

```bash
#!/bin/bash
# Post-Compaction Verification Protocol

echo "=== TIER 1: CRITICAL CHECKS ==="

# Check base repos are on develop (HIGHEST PRIORITY)
echo "Checking base repo branches..."
for repo in client-manager hazina; do
  cd "/c/Projects/$repo"
  branch=$(git branch --show-current)
  if [[ "$branch" != "develop" ]]; then
    echo "❌ VIOLATION: $repo on '$branch' (should be 'develop')"
    echo "   Fix: cd /c/Projects/$repo && git checkout develop"
  else
    echo "✅ $repo on develop"
  fi
done

# Check for uncommitted changes in base repos
echo ""
echo "Checking for uncommitted changes..."
for repo in client-manager hazina; do
  cd "/c/Projects/$repo"
  if [[ -n $(git status --porcelain) ]]; then
    echo "⚠️ $repo has uncommitted changes:"
    git status --short
  else
    echo "✅ $repo clean"
  fi
done

echo ""
echo "=== TIER 2: WORK STATUS CHECKS ==="

# Check PR states
echo "Checking recent PR activity..."
cd "/c/Projects/client-manager"
gh pr list --state all --limit 5 --json number,title,state,mergeable | jq -r '.[] | "\(.number): \(.title) - \(.state) (\(.mergeable))"'

# Check documentation commits
echo ""
echo "Checking recent documentation updates..."
cd /c/scripts
git log --oneline -5

echo ""
echo "=== TIER 3: INFORMATIONAL ==="
echo "Worktree pool status:"
cat /c/scripts/_machine/worktrees.pool.md | grep -E "agent-00[0-9]|FREE|BUSY"

echo ""
echo "✅ Verification complete"
```

**Why This Matters:**
- Base repo on wrong branch = Future worktrees start from wrong code (cascading failure)
- Unknown PR merges = May duplicate work or miss integration points
- Uncommitted changes = Risk of data loss on checkout

**Time Investment:** 5 minutes of verification saves hours debugging wrong-branch worktrees.

### Pattern: Trust but Verify

```
Summary says:        → Verify:              → Reality:
"Backend complete"   → Check git log        → 2 commits, migration + service
"PR created"         → gh pr list           → PR #57 exists, OPEN → MERGED!
"Feature done"       → ls Frontend/src      → Frontend missing! ❌
"Repo on develop"    → git branch --show    → On payment-models! ❌❌
```

**Lesson:** Summaries compress information. Always verify file system state when continuing work.

**Real Example (2026-01-09):**
- Summary: "PR #66 and #61 MERGEABLE"
- Reality: Both PRs actually **MERGED** (better than expected)
- Also Found: Base repos on wrong branches (critical violation)
- Action: Restored repos to develop, prevented future worktree issues

---

## 🎯 COMPLETE FEATURE IMPLEMENTATION PATTERN

**For any substantial feature, all three components are MANDATORY:**

### 1. Backend (API/Services)
- ✅ Models/DTOs (data structures)
- ✅ Services (business logic)
- ✅ Controllers (API endpoints)
- ✅ Migrations (database schema)
- ✅ DI registration (Program.cs)
- ✅ Tests (if applicable)

### 2. Frontend (UI/Components)
- ✅ TypeScript service layer (API client)
- ✅ React components (2 versions):
  - **Full component**: Complete feature view (e.g., `ROIDashboard.tsx`)
  - **Widget component**: Compact at-a-glance display (e.g., `ROIWidget.tsx`)
- ✅ Proper TypeScript types/interfaces
- ✅ Error handling and loading states
- ✅ Responsive design (Tailwind CSS)

### 3. Documentation (Knowledge Transfer)
- ✅ Comprehensive .md file in `docs/features/`
- ✅ Overview and key features
- ✅ API specifications with examples
- ✅ Frontend usage examples
- ✅ Database schema descriptions
- ✅ Best practices and integration points
- ✅ Customization guidance

### Why Two Component Versions?

**Full Component** (e.g., ROIDashboard.tsx):
- Complete feature experience
- All functionality available
- Dedicated page/view
- Example: 227 lines with trend charts, filters, insights

**Widget Component** (e.g., ROIWidget.tsx):
- At-a-glance summary
- Compact display
- Dashboard integration
- Example: 92 lines showing key metrics only

**Benefits:**
- Flexibility: Use widget on main dashboard, full view on dedicated page
- Reusability: Widget can be embedded anywhere
- User choice: Quick glance vs deep dive

### Documentation Template

Use ROI-CALCULATOR.md as template (771 lines):

```markdown
# Feature Name - Documentation

## Overview
[What it does, why it matters]

## Key Features
[Bulleted list of capabilities]

## [Industry Benchmarks / Data Sources]
[If applicable - show research basis]

## API Endpoints
### 1. Endpoint Name
[Request/Response examples]

## Frontend Usage
### Full Component
[TSX code example]

### Widget Component
[TSX code example]

## Database Schema
[Table descriptions]

## Best Practices
[Integration guidance]

## Customization
[How to adapt for specific needs]

## Support
[Troubleshooting tips]
```

### Git Workflow for Features

```bash
# 1. Create feature branch
git worktree add C:\Projects\worker-agents\agent-XXX\<repo> -b feature/<name>

# 2. Implement backend first
[Create models, services, controllers, migrations]
git add . && git commit -m "feat: Add backend for <feature>"

# 3. Register services
[Update Program.cs DI registration]
git add . && git commit -m "feat: Register <feature> services"

# 4. Implement frontend
[Create service + 2 components]
git add . && git commit -m "feat: Add frontend for <feature>"

# 5. Add documentation
[Create comprehensive .md file]
git add . && git commit -m "docs: Add comprehensive <feature> documentation"

# 6. Push and create PR
git push -u origin feature/<name>
gh pr create --title "Feature: <Name>" --body "..."
```

**NEVER mark feature complete until all three parts exist.**

---

## 📊 MULTI-FEATURE IMPLEMENTATION DISCIPLINE

**When implementing multiple related features (e.g., Quick Wins 1-10):**

### Use TodoWrite Religiously

At start of multi-feature session, create todos for all features. Break down each feature into backend, frontend, docs components. Mark completed IMMEDIATELY after finishing each part.

### Why This Matters

**Benefits:**
1. **Progress visibility**: User sees exactly where you are
2. **No lost tasks**: Can't forget a component
3. **Context preservation**: After compaction, todo list shows state
4. **Self-accountability**: Forces you to complete ALL parts

**Correct pattern (DO THIS):**
- Mark "Backend" as in_progress
- Complete backend, mark completed
- Mark "Frontend" as in_progress
- Complete frontend, mark completed
- Mark "Documentation" as in_progress
- Complete docs, mark completed
- Mark "PR creation" as in_progress
- Create PR, mark feature fully completed
- Move to next feature

### Batch Completion Anti-Pattern

**WRONG:** Complete all features' backend, then all frontend, then all docs
**RIGHT:** Feature by feature - Backend → Frontend → Docs → PR for each

### Session Handoff Pattern

If session ends mid-feature, leave clear state in todos showing what's completed and what's pending. Next session can immediately see where to resume.

---

## 🏭 INDUSTRY RESEARCH INTEGRATION PATTERN

**When features involve industry benchmarks, best practices, or research data:**

### Include in Service Layer

Example from Smart Scheduling:
```csharp
private static readonly Dictionary<string, (int dayOfWeek, int hour, double score, string reason)> BestPractices = new()
{
    ["linkedin"] = (3, 9, 0.95, "Wednesday 9 AM - B2B professionals most active"),
    ["instagram"] = (3, 11, 0.92, "Wednesday 11 AM - High visual content engagement")
};
```

Example from ROI Calculator:
```csharp
private static readonly Dictionary<string, decimal> IndustryMultipliers = new()
{
    ["B2B Software"] = 3.0m,  // High-value leads, enterprise sales cycles
    ["Finance"] = 2.5m,       // Regulated industry, trust-driven
};
```

### Document Research Sources

In documentation file, include tables with benchmark values and research basis.

### Benefits

1. **Credibility**: Data-driven decisions, not arbitrary values
2. **Transparency**: Users understand the "why" behind calculations
3. **Customizability**: Users can adjust based on their data
4. **Future-proofing**: Easy to update as industry changes

---

## 🏗️ MULTI-TENANT ARCHITECTURE PATTERN

**For SaaS applications with multiple clients:**

### Data Hierarchy

Organization/Client (1) → Projects (*) → Content/Posts (*)

### Models

```csharp
// Top-level tenant
public class Client
{
    public string Id { get; set; }
    public string Name { get; set; }
    public string? Industry { get; set; }  // For industry-specific calculations

    public ICollection<Project> Projects { get; set; }
    public ICollection<UserClient> UserClients { get; set; }
}

// Junction table for user-client access
public class UserClient
{
    public string UserId { get; set; }
    public string ClientId { get; set; }
    public string Role { get; set; }  // Owner, Manager, Editor, Viewer
}

// Project level
public class Project
{
    public string Id { get; set; }
    public string ClientId { get; set; }  // ← Tenant isolation
}
```

### Query Filtering

ALWAYS filter by ClientId or ProjectId. Verify user has access before returning data.

### API Parameters

Support both project-level and client-level aggregation through optional parameters.

### Benefits

- **Data isolation**: Each client sees only their data
- **Flexible aggregation**: Report at project or client level
- **Role-based access**: Different permissions per client
- **Industry customization**: Use client.Industry for tailored calculations

---

## 📝 AUDIT LOGGING FOR ENTERPRISE PATTERN

**For enterprise features requiring compliance/audit trails:**

### Model Pattern

```csharp
public class ApprovalAction
{
    public int Id { get; set; }
    public string Action { get; set; }  // Approved, Rejected
    public string ActionBy { get; set; }
    public DateTime ActionTimestamp { get; set; }

    // Audit fields
    public string? IPAddress { get; set; }        // ← Compliance
    public string? UserAgent { get; set; }        // ← Forensics
    public string? Reason { get; set; }           // ← Business context
}
```

### Controller Pattern

Capture audit data from HttpContext (IP address, UserAgent) and pass to service layer.

### Benefits

- **Compliance**: SOC2, GDPR, HIPAA audit requirements
- **Forensics**: Investigate suspicious activity
- **Business intelligence**: Understand approval patterns
- **Legal protection**: Documented decision trail

### What to Audit

✅ Approvals/rejections, permission changes, data access (sensitive), configuration changes, bulk operations
❌ Read-only views, normal CRUD, high-frequency actions

---

## 🔄 CONTINUOUS IMPROVEMENT: PATTERN LIBRARY

**Every successful pattern should be documented for reuse.**

### After Completing Work

1. ✅ Identify reusable patterns
2. ✅ Document in claude.md (this file)
3. ✅ Add to reflection.log.md as achievement
4. ✅ Update claude_info.txt with quick reference
5. ✅ Commit documentation updates

### Pattern Categories

This file now includes:
- ✅ Session Compaction Recovery
- ✅ Complete Feature Implementation
- ✅ Multi-Feature Discipline
- ✅ Industry Research Integration
- ✅ Multi-Tenant Architecture
- ✅ Audit Logging for Enterprise

**Add more as discovered!**

---

## 📝 INCOMPLETE WORK DOCUMENTATION PATTERN (2026-01-08)

**Learned from:** Hazina PR #13 - Chat LLM Configuration Fix
**Pattern file:** C:\scripts\_machine\best-practices\DOCUMENTATION_AND_PR_WORKFLOW.md
**Status:** ACTIVE PATTERN for all complex incomplete work

### When to Use This Pattern

✅ **Use when:**
- Work session running long (token limits, time constraints)
- Fix spans multiple files (>5 locations)
- Testing reveals fix is incomplete
- Linter or external factors interfere
- Need to preserve context before losing it

❌ **Do NOT use for:**
- Simple single-file fixes
- Quick bugs fixable in <30 minutes
- Fully tested and working changes
- Minor refactoring

### The Workflow

#### 1. Create Documentation FIRST (before PR)

**Create two files:**

**A. PROBLEM_FIX_SUMMARY.md** - Complete technical specification
```markdown
# Problem Fix - Summary
**Date**: 2026-01-08
**Time**: HH:MM:SS UTC
**Signed by**: Claude Opus 4.5 (model-id)

## Problem
[Clear description]

## Root Cause
[Technical analysis]

## Solution Overview
[High-level approach]

## Changes Made
- ✅ Completed item
- ❌ Incomplete item

## Implementation Details
[Every file, every line number, exact code snippets]

## Testing Checklist
[Verification commands]
```

**B. REMAINING_WORK.md** - Action-oriented task list
```markdown
# Remaining Work: Feature Name
**Date**: 2026-01-08
**Time**: HH:MM:SS UTC
**Signed by**: Claude Opus 4.5
**PR**: [PR URL]
**Branch**: [branch-name]

## Status Overview
### ✅ Completed
### ❌ Incomplete

## Required Changes
### 1. Component (PRIORITY)
**File**: path
**Line**: X
[Exact code change needed]
**Impact**: [What breaks]

## Verification Commands
[Bash commands to verify]

## Testing Checklist
[Step-by-step testing]

## Rollback Plan
[How to undo]

## Next Steps
[Action items with time estimates]
```

#### 2. Commit Documentation

```bash
git add SUMMARY.md REMAINING_WORK.md
git commit -m "Add comprehensive documentation

Date: 2026-01-08THH:MM:SSZ
Signed-off-by: Claude Opus 4.5 <noreply@anthropic.com>"
git push
```

#### 3. Create PR with Comprehensive Body

```bash
gh pr create --title "[Type]: Clear description" --body "$(cat <<'EOFPR'
## Problem
[Brief]

## Root Cause
[Brief technical]

## Changes Made (Partial Fix)
1. ✅ Change 1
2. ✅ Change 2

## Remaining Work ⚠️
**See REMAINING_WORK.md for details**
- [ ] Component 1
- [ ] Component 2

## Testing Status
- ✅ Builds
- ❌ Feature still fails
- ⏳ Needs completion

## Files Changed
[List]

---
**Signed**: 2026-01-08THH:MM:SSZ
**Docs**: SUMMARY.md, REMAINING_WORK.md
EOFPR
)"
```

### DateTime Signature Standards

**Always include in:**
- MD file headers
- Git commit messages
- PR descriptions
- Todo updates

**Format:** ISO 8601 `2026-01-08T21:15:00Z`

**In files:**
```markdown
**Date**: 2026-01-08
**Time**: 21:15:00 UTC
**Signed by**: Claude Opus 4.5 (claude-sonnet-4-5-20250929)
```

**In commits:**
```
Date: 2026-01-08T21:15:00Z
Signed-off-by: Claude Opus 4.5 <noreply@anthropic.com>
```

### Status Markers (Use Consistently)

- ✅ Completed
- ❌ Incomplete/Failing
- ⏳ Pending/In Progress
- ⚠️ Warning/Attention Needed
- 📝 Documentation
- 🔧 Configuration
- 🐛 Bug Fix
- ✨ New Feature

### Priority Levels

- **HIGH**: Blocks core functionality
- **MEDIUM**: Affects secondary features
- **LOW**: Nice to have, no user impact

### Verification Pattern

Always include bash commands:
```bash
# Build verification
cd /path/to/project
dotnet build
# Expected: 0 errors

# Completeness check
grep -rn "OldPattern" src/ --include="*.cs"
# Expected: 0 results

# Runtime test
curl -X POST https://localhost:5001/api/test
# Expected: 200 OK
```

### Benefits

✅ **Continuity**: Anyone can continue work
✅ **Clarity**: Exact status known
✅ **Searchability**: Easy to find
✅ **Accountability**: Datetime tracking
✅ **Quality**: Prevents mistakes
✅ **Efficiency**: No wasted time
✅ **Communication**: Clear for reviewers

### Common Pitfalls to Avoid

❌ **Do NOT:**
- Create PR with vague "WIP" title
- Commit without documentation
- List todos in PR comments (use MD files)
- Forget datetime signatures
- Skip verification commands
- Assume context is obvious

✅ **DO:**
- Be exhaustively specific
- Include every file and line number
- Write for zero-context reader
- Sign and date everything
- Make docs self-contained
- Test your own documentation

### Integration with Control Plane

**File locations:**
- Project repo: `PROJECT_ROOT/FEATURE_SUMMARY.md`
- Project repo: `PROJECT_ROOT/REMAINING_WORK.md`
- Control plane: `C:\scripts\_machine\best-practices\PATTERN.md`
- Reflection: `C:\scripts\_machine\reflection.log.md`

### Real-World Example

**See:** 
- PR: https://github.com/martiendejong/Hazina/pull/13
- Summary: C:\Projects\hazina\CHAT_FIX_SUMMARY.md
- Remaining: C:\Projects\hazina\REMAINING_WORK.md
- Pattern: C:\scripts\_machine\best-practices\DOCUMENTATION_AND_PR_WORKFLOW.md

### Pattern Library Updated

This file now includes:
- ✅ Session Compaction Recovery
- ✅ Complete Feature Implementation
- ✅ Multi-Feature Discipline
- ✅ Industry Research Integration
- ✅ Multi-Tenant Architecture
- ✅ Audit Logging for Enterprise
- ✅ **Incomplete Work Documentation** ← NEW (2026-01-08)

**Full template:** C:\scripts\_machine\best-practices\DOCUMENTATION_AND_PR_WORKFLOW.md


---

## 🔧 LINTER INTERFERENCE MITIGATION (2026-01-08)

**Source**: Hazina chat fix completion (PR #13, Session 2)

### The Problem

Edit tool reports "File has been unexpectedly modified" repeatedly. Linter/formatter is reverting changes.

### The Solution

**Use `sed` for batch command-line updates**:

```bash
# Pattern replacement with capture groups
sed -i 's/OldMethod(\([^,]*\), oldParam)/NewMethod(\1, newParam)/g' file.cs

# Verify changes
grep -n "newParam" file.cs

# Commit immediately
git add file.cs && git commit -m "Change applied"
```

### Quick Decision Tree

```
Edit fails with "File unexpectedly modified"?
↓
Try once more → Still fails?
↓
Use sed with backup:
  cp file.cs file.cs.bak
  sed -i 's/pattern/replacement/g' file.cs
  grep -n "replacement" file.cs
  git diff file.cs
  dotnet build
  git commit
```

### Key sed Patterns

```bash
# Basic replacement
sed -i 's/old/new/g' file.txt

# With capture group (preserve part of pattern)
sed -i 's/Method(\([^,]*\), old)/Method(\1, new)/g' file.cs

# Delete line N
sed -i '42d' file.txt

# Insert after line N
sed -i '42a\New content' file.txt

# Multiple files
for f in file1 file2 file3; do sed -i 's/old/new/g' "$f"; done
```

### Special Character Escaping

- Dots: `Config\.Method` (not `Config.Method`)
- Backslashes: `\` (double escape)
- Parentheses: `\(` for capture group
- Use `|` as delimiter for paths: `s|old/path|new/path|`

### When to Use sed

✅ **Use sed when**:
- Edit tool fails with linter interference
- Need to change same pattern across multiple files
- Want atomic, immediate file updates
- Batch processing needed

❌ **Don't use sed when**:
- Changes require complex logic or conditionals
- Need type information or IDE refactoring (rename, extract method)
- Single simple change without linter issues

### Real Example from Hazina Fix

```bash
# Changed 13 locations across 3 files in ~5 minutes

# GeneratorAgentBase.cs (4 locations)
sed -i 's/StoreProvider\.GetStoreSetup(\([^,]*\), Config\.ApiSettings\.OpenApiKey)/StoreProvider.GetStoreSetup(\1, Config.OpenAI)/g' GeneratorAgentBase.cs

# EmbeddingsService.cs (8 locations)
sed -i 's/StoreProvider\.GetStoreSetup(\([^,]*\), _config\.ApiSettings\.OpenApiKey)/StoreProvider.GetStoreSetup(\1, _config.OpenAI)/g' EmbeddingsService.cs

# Result: 0 errors, changes persisted, no linter interference
```

**Full guide**: `C:\scripts\_machine\best-practices\LINTER_INTERFERENCE_MITIGATION.md`


---

## 🧪 LOCAL TESTING & SECURITY SCAN PATTERN (2026-01-10)

**Context:** CI/CD configured for build-only by default, tests and security scans are manual-only in GitHub Actions.

### Testing Strategy

**GitHub Actions (CI/CD):**
- ✅ **Build workflows** - Run automatically on push/PR (compilation verification only)
- 🔄 **Test workflows** - Manual trigger only (workflow_dispatch)
- 🔒 **Security scans** - Manual trigger + weekly scheduled runs

**Local Development:**
- Developers run tests locally before pushing
- Security scans run locally as part of comprehensive pre-push checklist
- See `docs/LOCAL_TESTING.md` for complete local testing guide

### Local Test Commands Quick Reference

**Backend Tests:**
```bash
dotnet test ClientManagerAPI/ClientManagerAPI.local.csproj
dotnet test --collect:"XPlat Code Coverage"
```

**Frontend Tests:**
```bash
npm test                    # All tests
npm run test:coverage       # With coverage
npm test -- --watch         # Watch mode
```

**Security Scans:**
```bash
npm audit                                    # Frontend dependencies
dotnet list package --vulnerable             # Backend dependencies
gitleaks detect --source .                   # Secret scanning
detect-secrets scan --baseline .secrets.baseline   # Secret scanning
```

**Pre-Push Checklist:**
1. Build both frontend and backend
2. Run all tests locally
3. Run at least one security scan (npm audit or gitleaks)
4. Commit and push

### How to Trigger Manual CI Workflows

1. Go to repository → **Actions** tab
2. Select workflow (e.g., "Backend Tests (Manual)" or "CodeQL Security Analysis (Manual)")
3. Click **"Run workflow"**
4. Select branch and any input options
5. Click **"Run workflow"**

### Weekly Automated Security Scans

Scheduled runs (no manual trigger needed):
- **Monday 00:00 UTC**: CodeQL Security Analysis
- **Tuesday 00:00 UTC**: Dependency Security Scan
- **Wednesday 00:00 UTC**: Secret Scanning

Results appear in:
- **Security** tab (CodeQL, secret scanning)
- **Actions** tab (all workflow runs)
- Email notifications (if enabled)

### Documentation Locations

**Project Documentation:**
- `docs/LOCAL_TESTING.md` - Complete local testing guide
- `docs/SECURITY.md` - Security best practices
- `.github/workflows/` - All workflow definitions

**Control Plane:**
- This file (`claude.md`) - Testing patterns and strategy
- `claude_info.txt` - Quick reference for common patterns

### Benefits of Manual Test Execution

✅ **Faster feedback** - Build errors detected in ~2 minutes vs 10+ with tests
✅ **Resource efficiency** - Tests only run when needed
✅ **Developer control** - Choose when to run comprehensive test suites
✅ **Local-first** - Encourages testing before push
✅ **Security visibility** - Weekly automated scans + manual on-demand

### When to Run Manual Workflows

**Before merging PR:**
- Run full test suite manually via Actions tab
- Review security scan results

**After major changes:**
- Run CodeQL after refactoring or adding new features
- Run dependency scans after package updates

**Before releases:**
- Run all security scans
- Verify all test workflows pass
- Check Security tab for any issues

---


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

