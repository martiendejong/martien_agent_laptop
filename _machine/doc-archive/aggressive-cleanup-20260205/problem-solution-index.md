# Problem → Solution Index

**Quick reference for common problems encountered by Claude agents.**
**Search with Ctrl+F or grep for keywords.**

---

## Build & Compilation Errors

### CS0006: Metadata file could not be found
**Problem:** `CS0006: Metadata file 'Hazina.XXX.dll' could not be found`
**Cause:** Project not added to solution file, or build order issue
**Solution:**
```powershell
.\tools\detect-missing-projects.ps1 -SolutionPath "path\to.sln" -AutoFix
```
**See:** Reflection 2026-01-10 [BUILD-ERRORS]

### NU1105: Unable to find project information
**Problem:** `NU1105: Unable to find project information for 'XXX.csproj'`
**Cause:** Project exists on disk but not in solution
**Solution:**
```bash
dotnet sln add path/to/project.csproj
```
**See:** Reflection 2026-01-10 [BUILD-ERRORS]

### Missing Property on HazinaStoreUser
**Problem:** `'HazinaStoreUser' does not contain a definition for 'Phone'`
**Cause:** Cross-repo changes not synchronized - Diko changed client-manager but Hazina missing property
**Solution:**
1. Add property to `Hazina/HazinaStoreUser.cs`
2. Check for needed EF migrations
3. Pull both repos to same state
**See:** Reflection 2026-01-14 [CROSS-REPO-SYNC]

### SQLite Error: no such column
**Problem:** `SQLite Error: no such column: u.Avatar`
**Cause:** Database migration not applied
**Solution:**
```bash
dotnet ef migrations add AddMissingColumn
dotnet ef database update
```
**See:** Reflection 2026-01-14 [CROSS-REPO-SYNC]

---

## Git & Worktree Issues

### Worktree marked BUSY but empty
**Problem:** Pool shows seat as BUSY but no worktrees exist
**Cause:** Worktree was deleted but pool not updated
**Solution:**
```powershell
.\tools\system-health.ps1 -Fix
# Or manually edit _machine/worktrees.pool.md
```

### Base repo not on develop
**Problem:** C:\Projects\<repo> is on feature branch instead of develop
**Cause:** Branch not switched back after PR creation
**Solution:**
```bash
cd C:\Projects\<repo>
git checkout develop
git pull
```

### Branch already exists
**Problem:** `fatal: A branch named 'feature/x' already exists`
**Cause:** Trying to create branch that exists
**Solution:** Use existing branch or delete first:
```bash
git branch -d feature/x  # delete local
git push origin --delete feature/x  # delete remote
```

### Worktree locked
**Problem:** `fatal: 'path' is a worktree and cannot be used`
**Cause:** Stale worktree reference
**Solution:**
```bash
git worktree prune
git worktree list  # verify
```

---

## API Development Issues

### OpenAIConfig null reference
**Problem:** `NullReferenceException` when using OpenAI
**Cause:** `hazina-openai-config.json` not found or not configured
**Solution:** Create config in store folder with proper structure
**See:** api-patterns Skill, Reflection 2026-01-09

### Response enrichment breaking nullability
**Problem:** Compiler warning about null reference after enrichment
**Cause:** Response object modified but compiler doesn't know about guarantees
**Solution:** Use null-forgiving operator or check explicitly
**See:** api-patterns Skill

### URL duplication in frontend
**Problem:** URL shows `/api/api/endpoint`
**Cause:** Base URL already includes `/api/` and call adds it again
**Solution:** Check HttpClient configuration and call site
**See:** api-patterns Skill

---

## GitHub Actions / CI

### EnableWindowsTargeting error
**Problem:** `error NETSDK1100: Windows is required to target Windows`
**Cause:** Windows-targeting SDK used in Linux CI environment
**Solution:** Add to csproj:
```xml
<EnableWindowsTargeting>true</EnableWindowsTargeting>
```
**See:** ci-cd-troubleshooting.md

### Permissions denied in workflow
**Problem:** `Resource not accessible by integration`
**Cause:** Missing permissions block in workflow YAML
**Solution:** Add to workflow:
```yaml
permissions:
  contents: write
  pull-requests: write
```

### Checkout fails for worktree
**Problem:** `fatal: destination path already exists`
**Cause:** CI trying to clone into existing directory
**Solution:** Use `clean: true` in checkout action

---

## Frontend Issues

### React Error #31
**Problem:** `Objects are not valid as a React child` (Error #31)
**Cause:** Trying to render an object directly in JSX
**Solution:** Convert to string or extract specific property
**See:** Reflection 2026-01-09 [REACT-ERROR-31]

### TypeScript cannot find module
**Problem:** `Cannot find module './Component'`
**Cause:** File exists but TypeScript can't resolve
**Solution:**
1. Check file extension (.tsx vs .ts)
2. Restart TypeScript server
3. Check tsconfig paths

### Vite HMR not working
**Problem:** Changes don't hot reload
**Cause:** Various - file watcher limits, import issues
**Solution:** Restart dev server, check console for errors

---

## ClickUp Integration

### Status not found
**Problem:** `Status not found` when creating task
**Cause:** Status name has spaces in UI but not in API
**Solution:** Use status names without spaces:
- ❌ `"to do"`
- ✅ `"todo"`

Query list first to get exact status names:
```powershell
.\tools\clickup-sync.ps1 -Action list-statuses -ListId <id>
```
**See:** Reflection 2026-01-15 [CLICKUP-PERSONAL-WORKSPACE]

---

## Mode Confusion

### Edited in wrong location
**Problem:** Made edits in C:\Projects\<repo> during Feature Development Mode
**Cause:** Forgot to allocate worktree first
**Solution:**
1. Check if changes should be committed
2. If yes: Stash, allocate worktree, pop stash in worktree
3. If no: Discard changes
4. Re-read ZERO_TOLERANCE_RULES.md

### Created PR in Debug Mode
**Problem:** Created PR when user was just debugging
**Cause:** Misread context as Feature Development
**Solution:**
1. PRs from debugging can be closed if not wanted
2. Ask user if they want to keep the PR
3. Re-read dual-mode-workflow.md

---

## Tool Issues

### bootstrap-snapshot fails
**Problem:** Script throws errors
**Cause:** Missing dependencies or file structure
**Solution:**
```powershell
.\tools\system-health.ps1 -Detailed
```

### repo-dashboard.sh not working on Windows
**Problem:** Bash script errors
**Cause:** Windows line endings or missing Git Bash
**Solution:** Run through Git Bash or use PowerShell equivalent

---

## Quick Diagnostic Commands

```powershell
# System health
.\tools\system-health.ps1

# Worktree status
.\tools\worktree-status.ps1 -Compact

# Pool discrepancies
.\tools\bootstrap-snapshot.ps1 -Generate

# Git status all repos
git -C C:\Projects\client-manager status
git -C C:\Projects\hazina status

# Check for uncommitted changes everywhere
Get-ChildItem C:\Projects\worker-agents -Recurse -Directory |
    Where-Object { Test-Path "$($_.FullName)\.git" } |
    ForEach-Object {
        $status = git -C $_.FullName status --porcelain
        if ($status) { Write-Host "$($_.FullName): has changes" }
    }
```

---

**Last Updated:** 2026-01-15
**Adding New Entries:** Use format: Problem → Cause → Solution → Reference
