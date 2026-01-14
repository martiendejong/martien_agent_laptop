# Tools and Productivity

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
- Run `worktree-status.ps1` to see active worktrees and branches
- Dashboard shows agent pool status
- If resource issues → Run `check-worktree-health.sh`

**4. End of Session / After Creating PRs:**
- Run `worktree-release-all.ps1 -AutoCommit` to release all worktrees
- Or release specific seat: `worktree-release-all.ps1 -Seats "agent-003"`

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
4. **worktree-status.ps1** - Active worktrees & branches (ROI 7.0) ⭐ Use before allocation
5. **worktree-release-all.ps1** - Release all worktrees to resting branch (ROI 7.0) ⭐ Use after PRs
6. **check-worktree-health.sh** - Detect stale allocations (ROI 4.5)
6. **install-hooks.sh** - Pre-commit checks (ROI 4.0)
7. **find-todos.sh** - TODO/FIXME tracker (ROI 5.3)
8. **sync-configs.sh** - Config file sync (ROI 4.0)
9. **agent-activity.sh** - Agent status report (ROI 3.8)
10. **coverage-report.sh** - Test coverage analysis (ROI 3.5)
11. **generate-changelog.sh** - PR changelog (ROI 3.2)

**Testing Status:** Only repo-dashboard.sh fully tested. Test others as you use them.

**Tracking:** Update C:\scripts\tools\TOOLS_STATUS.md after each tool usage.


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


