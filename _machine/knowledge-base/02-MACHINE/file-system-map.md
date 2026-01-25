# File System Map - Complete Directory Structure

**Last Updated:** 2026-01-25
**Tags:** #filesystem #directories #structure #organization #machine-config

---

## 📊 Executive Summary

This machine uses a sophisticated multi-workspace file system architecture designed for **autonomous agent operations**, **parallel development**, and **continuous learning**.

### Quick Stats
- **Total directories in C:\scripts**: 2,048
- **Total files in C:\scripts**: 13,819
- **PowerShell tools**: 270+ scripts
- **Documentation files**: 31+ markdown files in root
- **Worker agent seats**: 11 allocated (agent-001 through agent-012)
- **Claude Skills**: 21 auto-discoverable workflows
- **Primary development repos**: 2 (client-manager, hazina)

---

## 🗂️ Root Level Structure (C:\ Drive)

```
C:\
├── Projects\               # All development work (repositories, experiments)
│   ├── client-manager\     # Primary SaaS application (brand2boost)
│   ├── hazina\             # Framework library
│   └── worker-agents\      # Agent worktree pool (11 seats)
├── scripts\                # Control plane & tooling (THIS REPOSITORY)
├── stores\                 # Application data & configurations
├── backups\                # Backup storage
├── Temp\                   # Temporary files
└── [other system dirs]     # Windows system directories
```

---

## 📁 C:\Projects - Development Workspace

**Purpose:** All code repositories, development experiments, and active work.

### Key Statistics
- **Type:** Development workspace with multiple repositories
- **Organization:** Flat structure for main repos + dedicated agent pool
- **Primary repos:** client-manager, hazina (on develop branch when idle)
- **Growth pattern:** Repos added as needed, projects archived when complete

### Directory Structure

<details>
<summary>Click to expand full C:\Projects structure</summary>

```
C:\Projects\
├── client-manager\                    # Primary SaaS application (brand2boost)
│   ├── .git\                          # Git repository
│   ├── .github\                       # GitHub Actions workflows
│   ├── .vscode\                       # VS Code configuration
│   ├── ClientManagerAPI\              # ASP.NET Core backend
│   ├── client-manager-ui\             # React frontend
│   ├── docs\                          # Documentation
│   ├── tests\                         # Test projects
│   └── [50+ root-level files]         # Config, docs, analysis
│
├── hazina\                            # Framework library (dependency of client-manager)
│   ├── .git\                          # Git repository
│   ├── .github\                       # GitHub Actions workflows
│   ├── src\                           # Source code
│   ├── apps\                          # Example applications
│   ├── build\                         # Build output
│   └── docs\                          # Documentation
│
├── worker-agents\                     # Agent worktree pool (CRITICAL)
│   ├── agent-001\                     # Seat 1
│   │   └── client-manager\            # Git worktree checkout
│   ├── agent-002\                     # Seat 2
│   │   ├── client-manager\            # Git worktree checkout
│   │   ├── hazina\                    # Git worktree checkout
│   │   └── artrevisionist\            # Git worktree checkout
│   ├── agent-003\                     # Seat 3 (paired allocation)
│   │   ├── client-manager\
│   │   └── hazina\
│   ├── agent-004\                     # Seat 4
│   │   └── hazina\
│   ├── agent-005\                     # Seat 5
│   │   └── hazina\
│   ├── agent-006\                     # Seat 6 (FREE)
│   ├── agent-007\                     # Seat 7 (FREE)
│   ├── agent-008\                     # Seat 8 (FREE)
│   ├── agent-010\                     # Seat 10 (FREE)
│   ├── agent-011\                     # Seat 11 (FREE)
│   └── agent-012\                     # Seat 12 (FREE)
│
├── AgenticDebuggerVsix\               # Visual Studio debugging extension
├── artrevisionist\                    # WordPress site project
├── artrevisionist-wordpress\          # WordPress theme
├── bugattiinsights\                   # Analytics project
├── corinaAI\                          # AI assistant project
├── devgpt\                            # Development AI tool
├── hydro-vision-website\              # Client website
├── layered-image-test\                # Image processing experiment
├── mastermindgroupAI\                 # AI mastermind project
├── nexus-stream-74\                   # Streaming project
├── prospergenics\                     # Business project
├── subdomainchecker\                  # DNS tool
├── VeraAI\                            # AI assistant
├── woo-final-price\                   # WooCommerce plugin
└── [50+ other projects]               # Experiments, client work, archived projects
```

</details>

### Naming Conventions
- **Base repositories:** lowercase-with-hyphens (client-manager, hazina)
- **Worker agents:** `agent-NNN` (zero-padded 3 digits)
- **Worktrees within agents:** Same name as parent repo

### Storage Notes
- Agent worktrees contain full git checkouts (can be large)
- Base repos should always be on `develop` branch when idle
- Worker agent directories may be empty (seat available) or contain one/more worktrees

---

## 🛠️ C:\scripts - Control Plane & Tooling

**Purpose:** Autonomous agent control plane, tools, documentation, and machine state.

**THIS IS THE CORE REPOSITORY** - All agent intelligence and automation lives here.

### Key Statistics
- **Git repository:** Yes (tracked in GitHub)
- **Total directories:** 2,048
- **Total files:** 13,819
- **PowerShell tools:** 270+
- **Documentation:** 31+ markdown files
- **Skills:** 21 auto-discoverable workflows

### Root Level Structure

```
C:\scripts\
├── .git\                              # Git repository
├── .gitignore                         # Git ignore rules
├── .claude\                           # Claude Code configuration
│   ├── settings.json                  # Claude settings
│   └── skills\                        # Auto-discoverable workflows (21 skills)
│
├── _machine\                          # Machine-specific state & config (CRITICAL)
│   ├── reflection.log.md              # Learning log (878 KB - primary learning artifact)
│   ├── worktrees.pool.md              # Agent seat allocations
│   ├── worktrees.activity.md          # Activity log
│   ├── pr-dependencies.md             # Cross-repo PR tracking
│   ├── PERSONAL_INSIGHTS.md           # User understanding & preferences
│   ├── DEFINITION_OF_DONE.md          # DoD checklist
│   ├── SOFTWARE_DEVELOPMENT_PRINCIPLES.md  # Code quality standards
│   ├── SYSTEM_INTEGRATION.md          # Master integration guide
│   ├── best-practices\                # Pattern library
│   ├── knowledge-base\                # Structured knowledge system
│   │   ├── 01-USER\                   # User preferences & insights
│   │   ├── 02-MACHINE\                # Machine config & file system
│   │   ├── 03-DEVELOPMENT\            # Development processes
│   │   ├── 04-EXTERNAL-SYSTEMS\       # External integrations
│   │   ├── 05-PROJECTS\               # Project-specific knowledge
│   │   ├── 06-WORKFLOWS\              # Standard workflows
│   │   ├── 07-AUTOMATION\             # Automation patterns
│   │   ├── 08-KNOWLEDGE\              # General knowledge
│   │   ├── 09-SECRETS\                # Secrets & credentials
│   │   └── MASTER_PLAN.md             # Knowledge base roadmap
│   ├── context-snapshots\             # Saved work contexts
│   └── [80+ files]                    # Config, analysis, tracking
│
├── tools\                             # 270+ PowerShell automation tools
│   ├── README.md                      # Complete tools documentation
│   ├── *.ps1                          # PowerShell scripts (270+)
│   ├── *.sh                           # Bash scripts (20+)
│   ├── *.js                           # Node.js scripts (20+)
│   ├── *.py                           # Python scripts (10+)
│   └── node_modules\                  # Node dependencies (for email tools)
│
├── bootstrap\                         # Environment setup automation
│   ├── README.md                      # Setup guide
│   ├── bootstrap.ps1                  # Main orchestrator
│   ├── install-dependencies.ps1       # Software installation
│   ├── setup-directories.ps1          # Directory creation
│   ├── init-machine-state.ps1         # State initialization
│   └── verify-environment.ps1         # Validation
│
├── agents\                            # Agent specifications (experimental)
├── tasks\                             # Task tracking & plans
├── plans\                             # Long-term planning documents
├── logs\                              # Operational logs
├── status\                            # Status tracking
├── templates\                         # Document templates
├── analysis\                          # Analysis reports
├── docs\                              # Additional documentation
├── code-samples\                      # Code examples
├── correspondence\                    # External communications
├── emails\                            # Email exports & tracking
│
└── [31+ .md files]                    # Core documentation (see below)
```

### Core Documentation Files

<details>
<summary>Click to expand documentation inventory</summary>

#### Foundation
- `CLAUDE.md` - **Main documentation index** (44 KB - ALWAYS READ FIRST)
- `MACHINE_CONFIG.md` - Machine-specific paths & projects
- `GENERAL_ZERO_TOLERANCE_RULES.md` - Critical hard-stop rules
- `GENERAL_DUAL_MODE_WORKFLOW.md` - Feature vs Debug mode
- `GENERAL_WORKTREE_PROTOCOL.md` - Worktree workflow
- `PORTABILITY_GUIDE.md` - Cross-machine setup

#### Workflows
- `continuous-improvement.md` - Self-learning protocols
- `git-workflow.md` - Cross-repo PR dependencies
- `session-management.md` - Window colors & notifications
- `worktree-workflow.md` - Complete worktree documentation
- `development-patterns.md` - Feature implementation patterns
- `ci-cd-troubleshooting.md` - CI/CD debugging

#### Reference
- `tools-and-productivity.md` - Tools & debugging
- `clickup-integration.md` - ClickUp API integration
- `clickup-github-workflow.md` - ClickUp + GitHub workflow
- `QUICK_LAUNCHERS.md` - CTRL+R quick launch
- `DYNAMIC_WINDOW_COLORS.md` - Window customization
- `TAXONOMY.md` - Documentation taxonomy
- `ROADMAP.md` - Future enhancements

#### Setup
- `QUICKSTART.md` - Quick start guide
- `NAVIGATION.md` - Navigation guide
- `NOTIFICATION_ACCESS.md` - Notification system

</details>

### Naming Conventions
- **Documentation:** kebab-case.md (lowercase-with-hyphens.md)
- **Tools:** kebab-case.ps1 (lowercase-with-hyphens.ps1)
- **Machine state:** UPPERCASE.md or lowercase.md depending on visibility
- **Batch files:** lowercase.bat
- **Config files:** .json, .txt

### Storage Notes
- `reflection.log.md` is the largest file (878 KB) - primary learning artifact
- `_machine/` directory contains all persistent state
- Tools directory has Node.js dependencies (~20 MB in node_modules)
- Git history can be large (use git gc periodically)

---

## 💾 C:\stores - Application Data & Configurations

**Purpose:** Store configuration files and application data separate from code.

### Directory Structure

```
C:\stores\
├── brand2boost\                       # Primary SaaS application store
│   ├── .git\                          # Git repository (data versioning)
│   ├── .hazina\                       # Hazina framework state
│   ├── bin\                           # Binary files
│   ├── analysis-fields.config.json    # Analysis configuration
│   ├── appsettings.json               # Application settings
│   ├── appsettings.Secrets.json       # Secrets (gitignored)
│   ├── brand2boost.csproj             # Project file
│   └── [50+ prompt files]             # AI prompt templates
│
├── artrevisionist\                    # WordPress site store
├── config\                            # Shared configurations
├── mastermindgroup\                   # Mastermind AI store
└── SCP\                               # SCP project store
```

### Naming Conventions
- **Store directories:** Match project names (lowercase)
- **Config files:** appsettings.json, *.config.json

### Storage Notes
- Stores are often Git repositories themselves (data versioning)
- Secrets files must be gitignored
- Prompt files are text-based templates for AI

---

## 🔄 C:\backups - Backup Storage

**Purpose:** Automated and manual backups of critical data.

### Structure
```
C:\backups\
└── [timestamped backup archives]
```

### Backup Strategy
- Automated nightly backups via `setup-backup-schedule.ps1`
- Manual backups via `backup-restore.ps1`
- Target: brand2boost store, machine state, critical configs

---

## 📊 Storage Statistics & Growth Patterns

### Disk Usage by Major Directory

| Directory | Approximate Size | Growth Pattern |
|-----------|-----------------|----------------|
| `C:\Projects\` | Large (GB scale) | **High** - Active development, node_modules, builds |
| `C:\Projects\worker-agents\` | Medium-Large | **Medium** - Grows with active worktrees |
| `C:\scripts\` | Medium (~500 MB) | **Low** - Primarily text files, controlled growth |
| `C:\scripts\_machine\` | Small-Medium | **Medium** - Reflection log grows continuously |
| `C:\stores\` | Small-Medium | **Low** - Configuration data, slow growth |
| `C:\backups\` | Variable | **Medium** - Depends on backup retention |

### Largest Files
1. `C:\scripts\_machine\reflection.log.md` - 878 KB (continuous growth)
2. `C:\scripts\_machine\PERSONAL_INSIGHTS.md` - 114 KB (periodic updates)
3. `C:\scripts\_machine\worktrees.activity.md` - 83 KB (continuous growth)
4. Various build outputs in Projects (can be GB scale)

### Growth Drivers
- **Node modules:** Frontend projects with npm dependencies
- **Build outputs:** Compiled binaries, intermediate files
- **Git history:** Large repos with binary files
- **Reflection log:** Continuous learning entries
- **Worktree checkouts:** Full repository clones

---

## 🎯 Directory Purposes & Organization Principles

### C:\Projects - Development Philosophy
- **Isolation:** Each project is self-contained
- **Flat structure:** No deep nesting (easier to navigate)
- **Worker agents:** Dedicated pool for parallel agent work
- **Experiment-friendly:** Easy to create new projects

### C:\scripts - Control Plane Philosophy
- **Single source of truth:** All agent behavior defined here
- **Portable core:** GENERAL_* files can be copied to other machines
- **Machine-specific state:** _machine\ directory for local state
- **Tool-first:** Automate everything (270+ tools)
- **Self-improving:** Agents update their own documentation

### C:\stores - Data Philosophy
- **Code/data separation:** Configuration separate from logic
- **Version control:** Store directories are often Git repos
- **Secrets management:** Sensitive data gitignored
- **Project-aligned:** One store per major application

---

## 🔍 Key File Locations Reference

### Configuration Files
```
C:\scripts\MACHINE_CONFIG.md                              # Machine paths & projects
C:\scripts\.claude\settings.json                          # Claude Code settings
C:\stores\brand2boost\appsettings.json                    # App configuration
C:\stores\brand2boost\appsettings.Secrets.json            # API keys, secrets
C:\stores\config\                                         # Shared configs
```

### State Files
```
C:\scripts\_machine\worktrees.pool.md                     # Agent seat allocations
C:\scripts\_machine\worktrees.activity.md                 # Activity log
C:\scripts\_machine\reflection.log.md                     # Learning log
C:\scripts\_machine\pr-dependencies.md                    # PR tracking
C:\scripts\_machine\PERSONAL_INSIGHTS.md                  # User understanding
```

### Data Files
```
C:\stores\brand2boost\analysis-fields.config.json         # Analysis configuration
C:\scripts\_machine\bootstrap-snapshot.json               # Environment snapshot
C:\scripts\_machine\clickup-config.json                   # ClickUp integration
C:\scripts\_machine\credentials.md                        # Encrypted credentials
```

### Temporary Files
```
C:\Temp\                                                  # System temp
C:\scripts\logs\                                          # Operational logs
C:\Users\HP\AppData\Local\Temp\claude\                    # Claude temp files
```

### Output/Artifacts
```
C:\Projects\client-manager\ClientManagerAPI\bin\          # Build output
C:\Projects\client-manager\client-manager-ui\build\       # Frontend build
C:\scripts\analysis\                                      # Analysis reports
C:\scripts\status\                                        # Status tracking
C:\testresults\                                           # Test results
```

---

## 📐 Naming Conventions Summary

### Directories
- **Projects:** lowercase-with-hyphens
- **Worker agents:** `agent-NNN` (zero-padded)
- **System directories:** PascalCase (Windows standard)

### Files
- **Documentation:** kebab-case.md
- **PowerShell tools:** kebab-case.ps1
- **Bash scripts:** kebab-case.sh
- **Python scripts:** snake_case.py
- **JavaScript:** kebab-case.js
- **Configuration:** camelCase.json or kebab-case.json
- **Batch files:** lowercase.bat

### Special Conventions
- **Portable docs:** `GENERAL_*.md` (uppercase prefix)
- **Machine-specific:** `MACHINE_*.md` or `_machine/*`
- **Legacy/deprecated:** Often suffixed with `.backup` or `.bak`

---

## 🚀 Quick Reference - Common Paths

### Most Frequently Used
```bash
# Control plane
cd C:/scripts

# Primary repos (base)
cd C:/Projects/client-manager
cd C:/Projects/hazina

# Agent worktree (example)
cd C:/Projects/worker-agents/agent-001/client-manager

# Tools
cd C:/scripts/tools

# Machine state
cd C:/scripts/_machine

# Application store
cd C:/stores/brand2boost
```

### Tool Quick Launch
```bash
# From anywhere, these are in PATH or aliased:
worktree-status.ps1
system-health.ps1
bootstrap-snapshot.ps1
claude-ctl.ps1 status
```

---

## 🔗 Cross-References

### Related Documentation
- [MACHINE_CONFIG.md](../MACHINE_CONFIG.md) - Machine-specific configuration
- [GENERAL_WORKTREE_PROTOCOL.md](../../GENERAL_WORKTREE_PROTOCOL.md) - Worktree workflow
- [tools/README.md](../../tools/README.md) - Complete tools documentation
- [SYSTEM_INTEGRATION.md](../SYSTEM_INTEGRATION.md) - System architecture

### Related Skills
- `allocate-worktree` - Allocate worker agent worktree
- `worktree-status` - Check worktree pool status
- `release-worktree` - Release worktree after PR

### Related Tools
- `bootstrap-snapshot.ps1` - Generate environment snapshot
- `worktree-status.ps1` - Check agent seat availability
- `system-health.ps1` - Comprehensive health check
- `detect-missing-projects.ps1` - Validate project existence

---

## 📝 Maintenance Notes

### Regular Maintenance Tasks
1. **Weekly:** Run `maintenance.ps1` to clean temp files, prune git repos
2. **Monthly:** Run `cleanup-stale-branches.ps1` to remove old branches
3. **Quarterly:** Review `C:\Projects\` for archived projects to delete
4. **As needed:** Run `git gc` in large repos to compress history

### Growth Management
- Monitor `reflection.log.md` size (archive when > 1 MB)
- Clean `node_modules` in unused projects
- Remove old build artifacts (`bin\`, `obj\`, `build\`)
- Archive completed worker agent worktrees

### Backup Strategy
- **Critical:** `C:\scripts\_machine\`, `C:\stores\brand2boost\`
- **Important:** `C:\Projects\client-manager\`, `C:\Projects\hazina\`
- **Optional:** Other projects (backup before archival)

---

## 🎓 Understanding This File System

### Design Philosophy
This file system is optimized for:
1. **Autonomous agent operations** - Clear separation of control plane (scripts) and workspaces (projects)
2. **Parallel development** - Worker agent pool enables multiple agents working simultaneously
3. **Continuous learning** - Machine state directory captures all learnings
4. **Automation-first** - 270+ tools eliminate manual ceremony
5. **Portability** - GENERAL_* files can be copied to other machines

### Key Insights
- **Control plane as code:** Everything in C:\scripts is version controlled
- **State separation:** Machine-specific state in _machine\ directory
- **Worktree isolation:** Agent worktrees prevent branch conflicts
- **Tool-driven:** Scripts handle repetitive tasks, agents handle thinking
- **Self-documenting:** Tools generate their own documentation

### Navigation Tips
- Use `CTRL+R` quick launchers for common paths
- Tools are in PATH or have batch file shortcuts
- Documentation uses markdown linking for cross-references
- Git repositories are shallow clones where possible (faster checkout)

---

**Document Status:** ✅ Complete
**Confidence:** High (based on actual directory exploration)
**Next Review:** When significant directory structure changes occur
