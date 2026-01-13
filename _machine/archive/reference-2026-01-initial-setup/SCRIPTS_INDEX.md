# Scripts Control Plane - Index & Documentation

**Location:** `C:\scripts\`
**Purpose:** Machine-Wide Control Plane for AI Agent Operations
**Status:** ✅ Active
**Generated:** 2026-01-08

---

## 📋 TABLE OF CONTENTS

1. [Overview](#overview)
2. [Directory Structure](#directory-structure)
3. [Core Documentation Files](#core-documentation-files)
4. [Agent Specifications](#agent-specifications)
5. [Worktree Management](#worktree-management)
6. [Tools & Automation](#tools--automation)
7. [Logs & Status](#logs--status)
8. [Entry Points & Commands](#entry-points--commands)
9. [Best Practices](#best-practices)

---

## OVERVIEW

### What is the Scripts Control Plane?

The **scripts control plane** is the command center for all AI agent operations on this machine. It provides:

- **🧠 Agent Instructions** - Core operational manuals (claude.md, claude_info.txt)
- **📋 Zero-Tolerance Rules** - Workflow enforcement policies
- **🔄 Worktree Allocation** - Git worktree pool for parallel agent execution
- **🤖 Agent Specifications** - Specialized agent role definitions
- **📊 State Tracking** - Machine-wide state, logs, reflection
- **🛠️ Automation Tools** - Scripts for common operations
- **📈 Observability** - Logs, metrics, activity tracking

### Purpose

**Primary Goal:** Enable multiple AI agents to work in parallel on code without conflicts, while maintaining strict workflow compliance and learning from past mistakes.

**Key Principles:**
1. **Isolation** - Each agent gets its own worktree
2. **Atomicity** - Worktree allocation is atomic (no race conditions)
3. **Learning** - All mistakes logged and documented in reflection.log.md
4. **Zero Tolerance** - Strict enforcement of workflows (no shortcuts)
5. **Self-Improvement** - Agents update their own instructions

---

## DIRECTORY STRUCTURE

```
C:\scripts\
├── _machine/                     ← Machine-wide state & tracking
│   ├── worktrees.pool.md         ← Worktree allocation table
│   ├── worktrees.activity.md     ← Activity log (allocations, releases)
│   ├── worktrees.protocol.md     ← Atomic allocation protocol
│   ├── instances.map.md          ← Agent instance mapping
│   ├── reflection.log.md         ← Lessons learned (CRITICAL!)
│   ├── machine.md                ← Machine configuration
│   ├── repos.index.md            ← Repository index
│   ├── stores.index.md           ← Data stores index
│   ├── tools.detected.md         ← Detected tools on machine
│   ├── tools.missing.md          ← Missing tools
│   ├── tools.proposals.md        ← Proposed tools
│   ├── workflow-check.md         ← Workflow validation
│   ├── GIT_WORKFLOW.md           ← Git workflow guide
│   ├── PROJECTS_INDEX.md         ← ✨ Master project index
│   ├── CLIENT_MANAGER_DEEP_DIVE.md ← ✨ Client Manager docs
│   ├── HAZINA_DEEP_DIVE.md       ← ✨ Hazina framework docs
│   └── SCRIPTS_INDEX.md          ← ✨ This file
│
├── agents/                       ← Agent role specifications
│   ├── architect.agent.md        ← Software architect agent
│   ├── machine_executor.agent.md ← Execution agent
│   ├── machine_planner.agent.md  ← Planning agent
│   ├── meta.agent.md             ← Meta-agent (coordinates)
│   ├── status.agent.md           ← Status reporting agent
│   ├── tool_curator.agent.md     ← Tool curation agent
│   ├── worktree_coordinator.agent.md ← Worktree coordination
│   └── README.md                 ← Agent system overview
│
├── tools/                        ← Automation scripts
│   ├── cs-format.ps1             ← C# code formatting
│   ├── cs-autofix/               ← C# compile error auto-fix
│   │   └── bin/Release/net9.0/cs-autofix.dll
│   └── ... (more tools planned)
│
├── tasks/                        ← Task tracking
│   ├── ACTIVE_TASKS.md
│   └── task-*.md
│
├── plans/                        ← Implementation plans
│   ├── information-compression.md
│   └── README.md
│
├── status/                       ← Status & health
│   └── overview.md
│
├── logs/                         ← Agent execution logs
│   ├── architect.log.md
│   ├── executor.log.md
│   ├── meta.log.md
│   ├── permissions.log.md
│   ├── status.log.md
│   ├── tool_curator.log.md
│   └── worktree_coordinator.log.md
│
├── prompts/                      ← Prompt templates
│   ├── base.prompt.md
│   └── reflection.prompt.md
│
├── .claude/                      ← Claude-specific config
│
├── playwright/                   ← Browser automation
│   ├── setup-playwright.cmd
│   └── start-playwright.cmd
│
├── claude.md                     ← 🚨 OPERATIONAL MANUAL (11KB)
├── claude_info.txt               ← 🚨 CRITICAL REMINDERS (5KB)
├── ZERO_TOLERANCE_RULES.md       ← 🚨 ENFORCEMENT POLICY (3KB)
├── scripts.md                    ← Workflow documentation
├── README.md                     ← Scripts overview
│
├── claude_agent.bat              ← Claude agent launcher
├── claude_yolo.bat               ← Claude YOLO mode
├── chatgpt_yolo.bat              ← ChatGPT launcher
├── codex_yolo.cmd                ← Codex launcher
├── browser.cmd                   ← Browser MCP launcher
├── playwright.cmd                ← Playwright launcher
├── wp.bat                        ← WordPress CLI wrapper
│
├── bfg.jar                       ← BFG Repo-Cleaner
├── bfg.bat                       ← BFG launcher
├── stripe.exe                    ← Stripe CLI
└── wp-cli.phar                   ← WordPress CLI
```

---

## CORE DOCUMENTATION FILES

### 1. claude.md (Operational Manual)

**Location:** `C:\scripts\claude.md`
**Size:** 11KB
**Purpose:** Complete operational manual for AI agents

**Contents:**
- 🚨 **ZERO-TOLERANCE ENFORCEMENT** - Policy header
- 🚀 **CONTINUOUS IMPROVEMENT PROTOCOL** - Self-learning mandate
- ⚠️ **PRE-FLIGHT CHECKLIST** - Before ANY code edit
- 🔄 **Worktree Allocation Protocol** - ATOMIC allocation steps
- 🔧 **C# Auto-Fix Workflow** - Post-edit formatting & fixing
- 📋 **Debug Configuration** - Config file copying for worktrees
- 🎯 **Project Listings** - client-manager, hazina, stores
- 🔗 **Tool Integrations** - Agentic Debugger Bridge, Browser MCP

**Key Sections:**
1. Continuous Improvement Protocol (WHEN, WHAT, HOW to update)
2. Zero-Tolerance Enforcement (NO EXCEPTIONS)
3. Pre-Flight Checklist (BEFORE ANY CODE EDIT)
4. Worktree Allocation (Atomic protocol)
5. C# Auto-Fix Workflow (format → autofix → test → stage)
6. Debug Config Files (copy appsettings, .env, etc.)
7. Agentic Debugger Bridge (Visual Studio control)

**Update Frequency:** After every violation, discovery, or user feedback

---

### 2. claude_info.txt (Critical Reminders)

**Location:** `C:\scripts\claude_info.txt`
**Size:** 5KB
**Purpose:** Quick reference, read FIRST by every agent

**Contents:**
- 🚨🚨🚨 **ZERO-TOLERANCE POLICY** - Top of file (most important!)
- 🔴 **4 HARD STOP RULES** - Non-negotiable rules
- 📋 **Control Plane Root** - Directory structure
- 🔧 **C# Auto-Fix** - Post-edit workflow
- 🎯 **Projects** - Quick project reference
- 🔗 **Debug Tools** - Agentic Debugger Bridge, Browser MCP

**4 HARD STOP RULES:**
1. **Worktree Allocation Mandatory** - BEFORE ANY CODE EDIT
2. **Session Cleanup Mandatory** - commit, push, PR, release
3. **Never Edit C:\Projects\<repo> Directly** - Only in worktrees
4. **Scripts Folder = Law** - Always follow instructions

**Update Frequency:** Immediately after any critical violation

---

### 3. ZERO_TOLERANCE_RULES.md (Enforcement Policy)

**Location:** `C:\scripts\ZERO_TOLERANCE_RULES.md`
**Size:** 3KB
**Purpose:** Quick reference card for zero-tolerance rules

**Contents:**
- 🚨 **The 4 Hard Stop Rules** - Detailed breakdown
- ✋ **Pre-Flight Checklist** - Before code edit
- ✋ **Session-End Checklist** - Before saying "done"
- 🎯 **Success Criteria** - What SUCCESS looks like
- ❌ **Failure Criteria** - What FAILURE looks like
- 🔴 **If You Violate** - Recovery steps

**User Mandate:**
"zorg dat je dit echt nooit meer doet" (2026-01-08)

**Update Frequency:** When new violations discovered or rules added

---

### 4. scripts.md (Workflow Documentation)

**Location:** `C:\scripts\scripts.md`
**Size:** 2.3KB
**Purpose:** Workflow documentation and procedures

**Contents:**
- Workflow steps
- Common procedures
- Tool usage

---

## AGENT SPECIFICATIONS

**Location:** `C:\scripts\agents\`

Agent specifications define **specialized AI agent roles** with specific responsibilities, tools, and workflows.

### Available Agents

**1. architect.agent.md**
- **Role:** Software architect
- **Responsibilities:** Design system architecture, plan implementations
- **Tools:** Read, Glob, Grep, planning tools
- **When to use:** Before implementing complex features

**2. machine_executor.agent.md**
- **Role:** Task execution agent
- **Responsibilities:** Execute planned tasks, write code
- **Tools:** Full tool access (Read, Write, Edit, Bash)
- **When to use:** After planning, for implementation

**3. machine_planner.agent.md**
- **Role:** Task planning agent
- **Responsibilities:** Break down tasks, create implementation plans
- **Tools:** Read, Grep, Glob (read-only)
- **When to use:** When user requests complex multi-step task

**4. meta.agent.md**
- **Role:** Meta-agent coordinator
- **Responsibilities:** Coordinate other agents, orchestrate workflows
- **Tools:** Task spawning, agent coordination
- **When to use:** Complex multi-agent workflows

**5. status.agent.md**
- **Role:** Status reporting agent
- **Responsibilities:** Report system status, health checks
- **Tools:** Read, system monitoring
- **When to use:** Status queries, health checks

**6. tool_curator.agent.md**
- **Role:** Tool management agent
- **Responsibilities:** Detect tools, propose new tools, maintain tool registry
- **Tools:** Read, Bash (tool detection)
- **When to use:** Tool discovery, tool maintenance

**7. worktree_coordinator.agent.md**
- **Role:** Worktree allocation coordinator
- **Responsibilities:** Allocate worktrees, manage pool, resolve conflicts
- **Tools:** Read, Write (pool management)
- **When to use:** Worktree allocation, pool health checks

---

## WORKTREE MANAGEMENT

### Purpose

**Problem:** Multiple AI agents running in parallel cannot share the same git working directory without conflicts.

**Solution:** Isolated git worktrees for each agent.

### Key Files

**1. worktrees.pool.md**
- **Purpose:** Allocation table tracking all worktrees
- **Format:** Markdown table
- **Columns:**
  - Seat (agent-001, agent-002, etc.)
  - Agent start branch
  - Base repo path
  - Worktree root
  - Status (FREE, BUSY, STALE, BROKEN)
  - Current repo
  - Branch
  - Last activity (UTC)
  - Notes

**2. worktrees.activity.md**
- **Purpose:** Append-only activity log
- **Format:** Timestamped log entries
- **Actions:** allocate, checkin, release, mark-stale, provision-seat, repair-seat

**3. worktrees.protocol.md**
- **Purpose:** Complete atomic allocation protocol documentation
- **Sections:**
  - Problem statement
  - Atomic allocation procedure (4 phases)
  - Concurrency rules
  - Error handling
  - File format reference
  - Decision tree
  - Implementation checklist

**4. instances.map.md**
- **Purpose:** Map Claude sessions to worktree seats
- **Format:** Markdown table
- **Columns:**
  - Instance ID
  - Seat
  - Repo
  - Branch
  - Task IDs
  - Started (UTC)
  - Last check-in (UTC)

### Worktree Workflow

**Allocation (BEFORE CODE EDIT):**
```
1. Read worktrees.pool.md
2. Find FREE seat (or provision new agent-00X)
3. Mark seat BUSY atomically
4. Log allocation in worktrees.activity.md
5. Update instances.map.md
6. Create/verify git worktree exists
7. NOW you can edit code in C:\Projects\worker-agents\agent-XXX\<repo>\
```

**During Work:**
```
- Update Last activity every 30 min (heartbeat)
- Append checkin to worktrees.activity.md
- All edits in worktree ONLY
```

**Release (AFTER WORK DONE):**
```
1. git add -u && git commit -m "..."
2. git push origin <branch>
3. gh pr create --title "..." --body "..."
4. Mark seat FREE in worktrees.pool.md
5. Log release in worktrees.activity.md
6. Clear entry in instances.map.md
```

### Seat Statuses

- **FREE** - Available for allocation
- **BUSY** - Locked by an agent (do not touch!)
- **STALE** - Last activity >2 hours, can be forcibly released
- **BROKEN** - Needs repair (directory missing, git corrupt, etc.)

---

## TOOLS & AUTOMATION

### C# Auto-Fix Tools

**1. cs-format.ps1**
- **Location:** `C:\scripts\tools\cs-format.ps1`
- **Purpose:** PowerShell wrapper for `dotnet format`
- **Usage:**
  ```powershell
  pwsh C:\scripts\tools\cs-format.ps1 --project .
  ```
- **Features:**
  - Detects .sln or .csproj automatically
  - Runs `dotnet format` with correct arguments
  - 150 lines, robust error handling

**2. cs-autofix**
- **Location:** `C:\scripts\tools\cs-autofix\bin\Release\net9.0\cs-autofix.dll`
- **Purpose:** Roslyn-based compile error auto-fixer
- **Usage:**
  ```bash
  dotnet C:\scripts\tools\cs-autofix\bin\Release\net9.0\cs-autofix.dll --project . --verbose
  ```
- **Features:**
  - Removes unused usings
  - Fixes simple compile errors
  - Foundation for more auto-fixes (missing usings, missing packages)
  - 238 lines of C# code

**Post-Edit Workflow:**
```
1. Edit C# files in worktree
2. Run cs-format.ps1 (formatting)
3. Run cs-autofix.dll (compile errors)
4. Test via Browser MCP or Agentic Debugger Bridge
5. git add -u (if files changed)
```

### Other Tools

**bfg.jar + bfg.bat**
- BFG Repo-Cleaner (remove sensitive data from git history)

**stripe.exe**
- Stripe CLI for payment testing

**wp-cli.phar + wp.bat**
- WordPress CLI (note: wp_cli not working, needs fix)

---

## LOGS & STATUS

### Agent Logs

**Location:** `C:\scripts\logs\`

**Purpose:** Track agent execution, decisions, and outcomes

**Files:**
- `architect.log.md` - Architecture agent logs
- `executor.log.md` - Execution agent logs
- `meta.log.md` - Meta-agent coordination logs
- `permissions.log.md` - Permission requests/grants
- `status.log.md` - Status checks
- `tool_curator.log.md` - Tool curation logs
- `worktree_coordinator.log.md` - Worktree management logs

### Reflection Log

**Location:** `C:\scripts\_machine\reflection.log.md`

**🚨 CRITICAL FILE 🚨**

**Purpose:** Machine learning from mistakes and achievements

**Format:**
```markdown
## YYYY-MM-DD HH:MM - Title

**Incident/Achievement:** Description

**What went wrong/right:** Analysis

**Root causes:** Why it happened

**Corrective actions taken:** What was done

**Lesson:** Key takeaway

**Priority:** 🚨 CRITICAL / ⚠️ HIGH / etc.
**Status:** ✅ RESOLVED / ⚠️ ACTIVE / etc.
```

**Current Entries (as of 2026-01-08):**
1. **2026-01-07** - Worktree-First Workflow Violation
2. **2026-01-07 19:30** - C# Auto-Fix Tools Implementation ✅
3. **2026-01-07 23:55** - Revolutionary UI Proposals (10 chat-centric designs) ✅
4. **2026-01-08 01:00** - Holographic Evolution (5 advanced UI designs) ✅
5. **2026-01-08 01:30** - CRITICAL: Parallel Agent Worktree Concurrency Issue ✅
6. **2026-01-08 02:00** - 🚨 CRITICAL: USER ESCALATION - Workflow Still Being Violated ⚠️

**Entry #6 - Zero-Tolerance Policy:**
- User mandate: "zorg dat je dit echt nooit meer doet"
- Introduced 4 HARD STOP RULES
- Created ZERO_TOLERANCE_RULES.md
- Updated claude.md and claude_info.txt
- NO EXCEPTIONS policy

**Update Frequency:** After EVERY mistake, achievement, or learning

---

## ENTRY POINTS & COMMANDS

### Claude Agent Launchers

**claude_agent.bat**
- Main Claude agent launcher
- Interactive mode
- Loads claude.md and claude_info.txt on start

**claude_yolo.bat**
- YOLO mode (no safety checks)
- Use with caution!

**chatgpt_yolo.bat**
- ChatGPT launcher (YOLO mode)

**codex_yolo.cmd**
- Codex launcher

### Browser & Testing

**browser.cmd**
- Browser MCP server launcher
- For automated browser testing
- Chrome DevTools integration

**playwright.cmd**
- Playwright launcher
- Scripts in `playwright/` folder

### WordPress

**wp.bat**
- WordPress CLI wrapper
- Invokes wp-cli.phar
- **Note:** Currently not working, needs fix

---

## BEST PRACTICES

### For AI Agents

**1. ALWAYS Read Instructions First**
```
1. Read C:\scripts\claude_info.txt (critical reminders)
2. Read C:\scripts\claude.md (operational manual)
3. Check C:\scripts\_machine\reflection.log.md (learn from past)
4. Then proceed with task
```

**2. BEFORE ANY CODE EDIT**
```
1. Read C:\scripts\_machine\worktrees.pool.md
2. Allocate worktree (mark BUSY)
3. Log allocation
4. THEN edit code in worktree
```

**3. AFTER MISTAKES**
```
1. Log incident in reflection.log.md
2. Update claude.md with corrective procedure
3. Update claude_info.txt with warning
4. Create new rule if needed
```

**4. BEFORE ENDING SESSION**
```
1. git add -u && git commit
2. git push origin <branch>
3. gh pr create
4. Mark worktree FREE
5. Log release
```

### For Users

**1. Adding New Instructions**
- Update `claude.md` (operational procedures)
- Update `claude_info.txt` (critical reminders)
- Log in `reflection.log.md` (for persistence)

**2. Checking Agent Behavior**
- Read `logs/*.log.md` (agent execution logs)
- Read `reflection.log.md` (lessons learned)
- Read `worktrees.activity.md` (worktree usage)

**3. Maintaining Control Plane**
- Keep instructions up-to-date
- Review reflection.log.md monthly
- Clean up stale worktrees
- Validate pool health

---

## RELATED DOCUMENTATION

- [PROJECTS_INDEX.md](./PROJECTS_INDEX.md) - Master project index
- [CLIENT_MANAGER_DEEP_DIVE.md](./CLIENT_MANAGER_DEEP_DIVE.md) - Client Manager details
- [HAZINA_DEEP_DIVE.md](./HAZINA_DEEP_DIVE.md) - Hazina framework details
- [STORES_INDEX.md](./STORES_INDEX.md) - Data stores documentation
- [worktrees.protocol.md](./worktrees.protocol.md) - Full worktree protocol
- [reflection.log.md](./reflection.log.md) - Lessons learned
- [claude.md](../claude.md) - Operational manual
- [ZERO_TOLERANCE_RULES.md](../ZERO_TOLERANCE_RULES.md) - Quick reference

---

**Last Updated:** 2026-01-08
**Document Version:** 1.0
**Maintained by:** Claude Agent System
**Critical Files:** claude.md, claude_info.txt, ZERO_TOLERANCE_RULES.md, reflection.log.md
