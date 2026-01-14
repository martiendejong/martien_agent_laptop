# Claude Agent - Main Documentation Index

**Before starting, read:** `C:\scripts\MACHINE_CONFIG.md` then `C:\scripts\GENERAL_ZERO_TOLERANCE_RULES.md`

You are a self-improving agent started by `c:\scripts\claude_agent.bat`. During execution, you will self-reflect and learn from your actions. You will update your own mechanisms to improve effectiveness. Update files in the `c:\scripts` folder carefully and thoughtfully.

---

## 🤖 Core Principle: Automation First

**DevOps/CI-CD philosophy:** Automate everything.

Any task with multiple steps should become a script. This way:
- **One command** does what previously took many steps
- **LLM capacity** is reserved for actual thinking (architecture, debugging, design)
- **Execution is effortless** - lower friction enables more iterations and higher quality

**Rule:** If you find yourself doing 3+ steps repeatedly, create a script in `C:\scripts\tools\`.

| Instead of... | Run... |
|---------------|--------|
| Checking worktrees manually | `worktree-status.ps1` |
| Commit + push + switch + update pool | `worktree-release-all.ps1` |
| Reading multiple files for state | `repo-dashboard.sh` |
| Manual C# formatting | `cs-format.ps1` |

**Goal:** Maximize uninterrupted thinking time by eliminating manual ceremony.

---

## 📁 Documentation Structure

**NEW (2026-01-13):** Documentation is now split into **PORTABLE** (general rules) and **MACHINE-SPECIFIC** (local configuration) files.

### 🌍 **PORTABLE - General Rules** (Copy to Plugin)
Files prefixed with `GENERAL_*` can be copied to Claude Code plugin settings:
1. **[GENERAL_ZERO_TOLERANCE_RULES.md](./GENERAL_ZERO_TOLERANCE_RULES.md)** - Critical rules (uses variables)
2. **[GENERAL_DUAL_MODE_WORKFLOW.md](./GENERAL_DUAL_MODE_WORKFLOW.md)** - Feature Development vs Active Debugging (portable)
3. **[GENERAL_WORKTREE_PROTOCOL.md](./GENERAL_WORKTREE_PROTOCOL.md)** - Complete worktree workflow (portable)
4. **[PORTABILITY_GUIDE.md](./PORTABILITY_GUIDE.md)** - How to adapt for your machine

### 💻 **MACHINE-SPECIFIC - This Machine Only**
Local configuration and hardcoded paths:
1. **[MACHINE_CONFIG.md](./MACHINE_CONFIG.md)** - **READ FIRST** - Paths, projects, local setup
2. **[ZERO_TOLERANCE_RULES.md](./ZERO_TOLERANCE_RULES.md)** - (Legacy, uses hardcoded paths)
3. **[dual-mode-workflow.md](./dual-mode-workflow.md)** - (Legacy, uses hardcoded paths)
4. **[worktree-workflow.md](./worktree-workflow.md)** - (Legacy, uses hardcoded paths)

### 🔄 **Core Workflows**
3. **[continuous-improvement.md](./continuous-improvement.md)** - Self-learning protocols, end-of-task updates, session recovery
4. **[git-workflow.md](./git-workflow.md)** - Cross-repo PR dependencies, sync rules, git-flow workflow

### 🎨 **User Interface & Productivity**
5. **[session-management.md](./session-management.md)** - Dynamic window titles/colors, HTML notification tracking
6. **[tools-and-productivity.md](./tools-and-productivity.md)** - Productivity tools, C# auto-fix, debug configs, testing

### 🔧 **Development & Troubleshooting**
7. **[ci-cd-troubleshooting.md](./ci-cd-troubleshooting.md)** - Frontend/backend CI issues, batch PR fixes, runtime errors
8. **[development-patterns.md](./development-patterns.md)** - Feature implementation, migrations, architecture patterns

### 🚀 **Bootstrap System** (NEW)
9. **[bootstrap/README.md](./bootstrap/README.md)** - Automated environment setup
10. **[bootstrap/bootstrap.ps1](./bootstrap/bootstrap.ps1)** - Main entry point

---

## 🔧 Bootstrap - Automated Environment Setup

**NEW (2026-01-13):** This repository includes a fully automated bootstrap system for setting up the development environment on a new machine.

### Quick Start (New Machine)

```powershell
# 1. Clone repository
git clone https://github.com/yourname/claude-scripts.git C:\scripts

# 2. Run bootstrap
cd C:\scripts
.\bootstrap\bootstrap.ps1

# 3. Start Claude Agent
.\claude_agent.bat
```

### What Bootstrap Does

1. **Installs Dependencies** - Git, GitHub CLI, Node.js, Claude Code CLI
2. **Creates Directories** - Project folders, worktree seats, machine context
3. **Initializes State Files** - Worktree pool, activity log, reflection log
4. **Verifies Environment** - Comprehensive validation of setup

### Bootstrap Scripts

| Script | Purpose |
|--------|---------|
| `bootstrap.ps1` | Main orchestrator |
| `install-dependencies.ps1` | Software via winget/chocolatey |
| `setup-directories.ps1` | Directory structure |
| `init-machine-state.ps1` | State file initialization |
| `verify-environment.ps1` | Environment validation |

See **[bootstrap/README.md](./bootstrap/README.md)** for complete documentation.

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
- **Skills:** `C:\scripts\.claude\skills` (Auto-discoverable Claude Skills)
- **Bootstrap:** `C:\scripts\bootstrap` (Environment setup scripts)

---

## 🎓 Claude Skills - Auto-Discoverable Workflows

**New in 2026-01-12:** This system now includes Claude Skills - auto-discoverable markdown-based knowledge that Claude loads based on context.

### What Are Skills?

**Skills are:**
- Markdown files in `.claude/skills/<skill-name>/SKILL.md`
- Automatically discovered by Claude Code at startup
- Activated when your task matches the skill's description
- Self-contained workflow guides with optional supporting files

**Skills vs Other Documentation:**
- **CLAUDE.md** - Always active, operational manual
- **Skills** - Contextually activated, specialized workflows
- **Tools** - Scripts you run manually
- **Docs (.md files)** - Reference material

### Available Skills

#### 🏗️ Worktree Management
- **`allocate-worktree`** - Allocate worker agent worktree with zero-tolerance enforcement and multi-agent conflict detection
- **`release-worktree`** - Release worktree after PR creation with complete cleanup protocol
- **`worktree-status`** - Check pool status, available seats, and system health

#### 🔀 GitHub Workflows
- **`github-workflow`** - PR creation, code reviews, merging, and lifecycle management
- **`pr-dependencies`** - Cross-repo dependency tracking between Hazina and client-manager

#### 🛠️ Development Patterns
- **`api-patterns`** - Common API pitfalls: OpenAIConfig initialization, response enrichment, URL duplication, LLM integration
- **`terminology-migration`** - Comprehensive codebase-wide refactoring patterns (e.g., daily → monthly)
- **`multi-agent-conflict`** - MANDATORY pre-allocation conflict detection when multiple agents run simultaneously

#### 📝 Continuous Improvement
- **`session-reflection`** - Update reflection.log.md with session learnings
- **`self-improvement`** - Update CLAUDE.md and documentation with new patterns

### How Skills Work

1. **Discovery** - Claude loads skill names and descriptions at startup
2. **Activation** - When your task matches a skill's description, Claude uses it
3. **Execution** - Claude follows the skill's markdown instructions

**You don't need to explicitly invoke Skills** - Claude discovers and applies them automatically based on context.

### When Skills Are Used

**Example scenarios:**

```
You: "I need to allocate a worktree for a new feature"
→ Claude activates: allocate-worktree Skill
→ Runs conflict detection, checks pool, allocates properly

You: "Create a PR for this feature"
→ Claude activates: github-workflow Skill
→ Follows PR creation format, adds dependency alerts if needed

You: "We need to rename 'daily' to 'monthly' across the codebase"
→ Claude activates: terminology-migration Skill
→ Uses systematic grep → TodoWrite → sed → build pattern

You: "Document what we learned today"
→ Claude activates: session-reflection Skill
→ Updates reflection.log.md with proper format
```

### Skill File Structure

```
C:\scripts\.claude\skills\
├── allocate-worktree/
│   ├── SKILL.md (required - workflow guide)
│   └── scripts/ (optional - helper scripts)
├── release-worktree/
│   └── SKILL.md
├── github-workflow/
│   └── SKILL.md
└── ...
```

### Creating New Skills

**Create a Skill when:**
- Workflow is complex with multiple mandatory steps
- Pattern is used frequently across sessions
- Auto-discovery would help future sessions
- New agents would benefit from guided workflow

**See:** `self-improvement` Skill for creation process

---

## 🚀 Quick Start Guide

### Every Session Start - MANDATORY:
1. ✅ **Read** `MACHINE_CONFIG.md` - Load local paths and projects
2. ✅ **Read** `GENERAL_ZERO_TOLERANCE_RULES.md` - Know the hard-stop rules
3. ✅ **Read** `GENERAL_DUAL_MODE_WORKFLOW.md` - Understand Feature Development vs Active Debugging modes
4. ✅ **Run** `C:/scripts/tools/repo-dashboard.sh` - Check environment state
5. ✅ **Verify** base repos on `develop` branch (see MACHINE_CONFIG.md for paths)
6. ✅ **Check** `worktrees.pool.md` - Available agent seats

### Before ANY Code Edit - Determine Mode:
1. 🚦 **Mode Detection** - See `dual-mode-workflow.md` decision tree
   - User proposes NEW feature → 🏗️ **Feature Development Mode**
   - User posts errors / debugging → 🐛 **Active Debugging Mode**

### Feature Development Mode (new features, refactoring):
1. ✅ **Allocate worktree** - See `worktree-workflow.md` § Atomic Allocation
2. ✅ **Mark seat BUSY** - Update `worktrees.pool.md`
3. ✅ **Work in** `C:\Projects\worker-agents\agent-XXX\<repo>\`
4. ❌ **NEVER edit** `C:\Projects\<repo>\` directly

### Active Debugging Mode (user debugging, build errors):
1. ✅ **Check user's current branch** - `git branch --show-current`
2. ✅ **Work in** `C:\Projects\<repo>\` on user's current branch
3. ❌ **DO NOT** allocate worktree
4. ❌ **DO NOT** switch branches

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

| Task | See Documentation | Auto-Discoverable Skill |
|------|-------------------|------------------------|
| **SET UP: First time setup** | **`PORTABILITY_GUIDE.md`** (if copying to plugin) | - |
| **LOAD: Machine configuration** | **`MACHINE_CONFIG.md`** (paths, projects) | - |
| **DECIDE: Feature Development vs Active Debugging** | **`GENERAL_DUAL_MODE_WORKFLOW.md`** | - |
| Allocate worktree for code editing (Feature Mode) | `GENERAL_WORKTREE_PROTOCOL.md` § Atomic Allocation | ✅ `allocate-worktree` |
| **Allocate paired worktrees (client-manager + Hazina)** | **`worktree-workflow.md` § Pattern 73** | ✅ `allocate-worktree` |
| Work directly in base repo (Debug Mode) | `GENERAL_DUAL_MODE_WORKFLOW.md` § Active Debugging Mode | - |
| Release worktree after PR | `worktree-workflow.md` § Release Protocol | ✅ `release-worktree` |
| Check worktree pool status | `worktree-workflow.md` § Pool Management | ✅ `worktree-status` |
| Detect multi-agent conflicts | `_machine/MULTI_AGENT_CONFLICT_DETECTION.md` | ✅ `multi-agent-conflict` |
| Create/review/merge PRs | `git-workflow.md` § GitHub Workflows | ✅ `github-workflow` |
| Track cross-repo PR dependencies | `git-workflow.md` § Cross-Repo Dependencies | ✅ `pr-dependencies` |
| Avoid API development pitfalls | Reflection log patterns | ✅ `api-patterns` |
| Migrate terminology across codebase | `development-patterns.md` § Terminology Migration | ✅ `terminology-migration` |
| Update reflection.log.md | `continuous-improvement.md` § Reflection Protocol | ✅ `session-reflection` |
| Update documentation with learnings | `continuous-improvement.md` § Self-Improvement | ✅ `self-improvement` |
| Manage window colors (RUNNING/COMPLETE/BLOCKED) | `session-management.md` § Dynamic Window Colors | - |
| Update HTML notifications dashboard | `session-management.md` § User Notification Tracking | - |
| Run productivity tools | `tools-and-productivity.md` § MANDATORY Tool Usage | - |
| Fix C# build errors | `tools-and-productivity.md` § C# Auto-Fix Workflow | - |
| Debug frontend CI failures | `ci-cd-troubleshooting.md` § Frontend CI Troubleshooting | - |
| Batch fix multiple PR builds | `ci-cd-troubleshooting.md` § Batch PR Build Fix | - |
| Implement complete feature (backend+frontend+docs) | `development-patterns.md` § Complete Feature Implementation | - |
| Document incomplete work | `development-patterns.md` § Incomplete Work Documentation | - |

---

## 🎯 Success Criteria

**You are operating correctly ONLY IF:**

### Feature Development Mode:
- ✅ All code edits happen in allocated worktrees (ZERO in C:\Projects\<repo>)
- ✅ Base repos (C:\Projects\<repo>) always on `develop` branch after PR
- ✅ Worktree pool accurately reflects BUSY/FREE status
- ✅ Every PR has corresponding notification in HTML dashboard
- ✅ Worktree released IMMEDIATELY after PR creation

### Active Debugging Mode:
- ✅ Code edits made directly in C:\Projects\<repo> on user's current branch
- ✅ Branch state preserved (NOT switched to develop)
- ✅ NO worktree allocated
- ✅ Fast turnaround for user's debugging session

### Both Modes:
- ✅ Every mistake is logged in reflection.log.md with corrective action
- ✅ Window colors reflect actual state (BLUE=working, GREEN=done, RED=blocked, BLACK=idle)
- ✅ Every session ends with committed documentation updates

---

## 🎯 Feature Request Management

**Capability:** Agents can autonomously submit feature requests to the Claude Code repository using `gh` CLI.

### Feature Request Process

1. **Research Phase**
   - Search existing issues: `gh issue list --repo anthropics/claude-code --search "<keyword>"`
   - Check for duplicates and related issues
   - Read related issues for context

2. **Request Crafting**
   - Provide clear problem statement
   - Propose multiple implementation options when applicable
   - Frame request from your use case perspective (agents vs users)
   - Link to related issues
   - Emphasize business impact and production requirements

3. **Submission**
   - Use `gh issue create --repo anthropics/claude-code --title "<title>" --body "<body>"`
   - Document the issue number in reflection.log.md

### Important Precedent: Issue #17772

**Issue:** "[FEATURE] Programmatic Model Switching for Autonomous Agents"
**Status:** Open and awaiting implementation
**Impact:** Critical for production agent cost optimization and intelligent resource allocation

When implemented, this will enable agents to:
- Use Opus for complex planning and architecture
- Use Sonnet for medium-complexity reviews and refactoring
- Use Haiku for routine edits and cost optimization
- Switch models without persisting to user settings

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
