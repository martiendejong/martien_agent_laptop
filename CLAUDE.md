# Claude Agent - Main Documentation Index

**Before starting, read:** `C:\scripts\ZERO_TOLERANCE_RULES.md`

You are a self-improving agent started by `c:\scripts\claude_agent.bat`. During execution, you will self-reflect and learn from your actions. You will update your own mechanisms to improve effectiveness. Update files in the `c:\scripts` folder carefully and thoughtfully.

---

## 📁 Documentation Structure

This documentation has been split into focused, manageable files for better clarity:

### 🚨 **Critical - Read First**
1. **[ZERO_TOLERANCE_RULES.md](./ZERO_TOLERANCE_RULES.md)** - Quick reference for hard-stop rules
2. **[worktree-workflow.md](./worktree-workflow.md)** - Worktree allocation, zero-tolerance enforcement, release protocol

### 🔄 **Core Workflows**
3. **[continuous-improvement.md](./continuous-improvement.md)** - Self-learning protocols, end-of-task updates, session recovery
4. **[git-workflow.md](./git-workflow.md)** - Cross-repo PR dependencies, sync rules, git-flow workflow

### 🎨 **User Interface & Productivity**
5. **[session-management.md](./session-management.md)** - Dynamic window titles/colors, HTML notification tracking
6. **[tools-and-productivity.md](./tools-and-productivity.md)** - Productivity tools, C# auto-fix, debug configs, testing

### 🔧 **Development & Troubleshooting**
7. **[ci-cd-troubleshooting.md](./ci-cd-troubleshooting.md)** - Frontend/backend CI issues, batch PR fixes, runtime errors
8. **[development-patterns.md](./development-patterns.md)** - Feature implementation, migrations, architecture patterns

---

## 🗺️ Control Plane Structure

- **Root:** `C:\scripts`
- **Machine context:** `C:\scripts\_machine`
  - `worktrees.pool.md` - Agent worktree allocations
  - `worktrees.activity.md` - Activity log
  - `reflection.log.md` - Lessons learned
  - `pr-dependencies.md` - Cross-repo PR tracking
- **Agent specs:** `C:\scripts\agents`
- **Tasks:** `C:\scripts\tasks`
- **Plans:** `C:\scripts\plans`
- **Logs:** `C:\scripts\logs`
- **Status:** `C:\scripts\status`
- **Tools:** `C:\scripts\tools` (Productivity tools - USE THESE!)

---

## 🚀 Quick Start Guide

### Every Session Start - MANDATORY:
1. ✅ **Read** `ZERO_TOLERANCE_RULES.md` - Know the hard-stop rules
2. ✅ **Run** `C:/scripts/tools/repo-dashboard.sh` - Check environment state
3. ✅ **Verify** base repos on `develop` branch (C:\Projects\client-manager, C:\Projects\hazina)
4. ✅ **Check** `worktrees.pool.md` - Available agent seats

### Before ANY Code Edit:
1. ✅ **Allocate worktree** - See `worktree-workflow.md` § Atomic Allocation
2. ✅ **Mark seat BUSY** - Update `worktrees.pool.md`
3. ✅ **Work in** `C:\Projects\worker-agents\agent-XXX\<repo>\`
4. ❌ **NEVER edit** `C:\Projects\<repo>\` directly

### After Creating PR:
1. ✅ **Release worktree** - See `worktree-workflow.md` § Release Protocol
2. ✅ **Update notifications** - See `session-management.md` § HTML Dashboard
3. ✅ **Switch to develop** - Both base repos
4. ✅ **Log reflection** - See `continuous-improvement.md` § End-of-Task Protocol

### End of Session:
1. ✅ **Update reflection.log.md** - Document learnings
2. ✅ **Update this documentation** - Add new patterns discovered
3. ✅ **Commit and push** - Machine_agents repo (`cd C:\scripts && git add -A && git commit && git push`)

---

## 📋 Common Workflows Quick Reference

| Task | See Documentation |
|------|-------------------|
| Allocate worktree for code editing | `worktree-workflow.md` § Atomic Allocation |
| Release worktree after PR | `worktree-workflow.md` § Release Protocol |
| Manage window colors (RUNNING/COMPLETE/BLOCKED) | `session-management.md` § Dynamic Window Colors |
| Update HTML notifications dashboard | `session-management.md` § User Notification Tracking |
| Run productivity tools | `tools-and-productivity.md` § MANDATORY Tool Usage |
| Fix C# build errors | `tools-and-productivity.md` § C# Auto-Fix Workflow |
| Debug frontend CI failures | `ci-cd-troubleshooting.md` § Frontend CI Troubleshooting |
| Batch fix multiple PR builds | `ci-cd-troubleshooting.md` § Batch PR Build Fix |
| Create cross-repo dependent PRs | `git-workflow.md` § Cross-Repo PR Dependencies |
| Follow git-flow branch strategy | `git-workflow.md` § Git-Flow Workflow Rules |
| Implement complete feature (backend+frontend+docs) | `development-patterns.md` § Complete Feature Implementation |
| Migrate terminology across codebase | `development-patterns.md` § Comprehensive Terminology Migration |
| Document incomplete work | `development-patterns.md` § Incomplete Work Documentation |

---

## 🎯 Success Criteria

**You are operating correctly ONLY IF:**
- ✅ All code edits happen in allocated worktrees (ZERO in C:\Projects\<repo>)
- ✅ Base repos (C:\Projects\<repo>) always on `develop` branch
- ✅ Worktree pool accurately reflects BUSY/FREE status
- ✅ Every PR has corresponding notification in HTML dashboard
- ✅ Every mistake is logged in reflection.log.md with corrective action
- ✅ Window colors reflect actual state (BLUE=working, GREEN=done, RED=blocked, BLACK=idle)
- ✅ Every session ends with committed documentation updates

---

## 🔗 External Documentation

- **Project-Specific:**
  - `C:\Projects\client-manager\README.md`
  - `C:\Projects\hazina\README.md`
  - `C:\Projects\client-manager\docs\`

- **Other Scripts Docs:**
  - `C:\scripts\scripts.md` - Workflow scripts documentation
  - `C:\scripts\QUICK_LAUNCHERS.md` - CTRL+R quick launch commands
  - `C:\scripts\DYNAMIC_WINDOW_COLORS.md` - Window color customization
  - `C:\scripts\tools\README.md` - Complete tools documentation

- **Machine Context:**
  - `C:\scripts\_machine\best-practices\` - Pattern library
  - `C:\scripts\_machine\worktrees.protocol.md` - Full worktree protocol

---

## ⚙️ Projects Configuration

### client-manager / brand2boost
**Type:** Promotion and brand development SaaS software

**Locations:**
- Code (frontend + API): `c:\projects\client-manager`
- Hazina framework: `c:\projects\hazina`
- Store config + data: `c:\stores\brand2boost`

**Admin Access:**
- User: `wreckingball`
- Password: `Th1s1sSp4rt4!`

**Important:** Do not run client-manager frontend or backend from command line. User runs from Visual Studio and npm directly.

### Debugging Tools
- **Browser MCP:** For frontend application debugging
- **Agentic Debugger Bridge:** `localhost:27183` - Control Visual Studio debugging via HTTP API (see `tools-and-productivity.md` § Agentic Debugger Bridge)

---

**Last Updated:** 2026-01-12 (Reorganized into modular files)
**Maintained By:** Claude Agent (Self-improving documentation)
**User Mandate:** "zorg dat je dus constant leert van jezelf en je eigen instructies bijwerkt"
