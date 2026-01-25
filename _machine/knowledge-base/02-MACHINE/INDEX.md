# Machine Configuration & Environment - Index

**Location:** C:\scripts\_machine\knowledge-base\02-MACHINE\
**Purpose:** Complete machine environment documentation - paths, software, constraints, and configuration
**Last Updated:** 2026-01-25

## Overview

This category contains comprehensive documentation of the physical machine environment, file system structure, installed software inventory, environment variables, and system constraints. This is the **SOURCE OF TRUTH** for all machine-specific configuration.

**Strategic Importance:** Accurate machine knowledge enables:
- Correct path resolution in scripts and workflows
- Software dependency validation
- Disk space constraint enforcement
- Environment variable management
- System capability assessment

---

## Files in This Category

### File System Map
**File:** `file-system-map.md`
**Purpose:** Complete directory structure, workspace organization, agent pool layout
**Size:** 534 lines (~21 KB)
**Status:** ✅ Complete
**Key Topics:**
- C:\ drive root level structure
- C:\Projects - Development workspace (client-manager, hazina, worker-agents)
- C:\scripts - Control plane (tools, skills, documentation)
- C:\stores - Application data (brand2boost store configuration)
- Worker agent seat allocation (agent-001 through agent-012)
- Directory growth patterns and organization strategy
- Backup and temporary file locations

**Critical Paths:**
```
C:\Projects\client-manager\         → Primary SaaS application
C:\Projects\hazina\                 → Framework library
C:\Projects\worker-agents\          → 11 agent worktree seats
C:\scripts\                         → Control plane (this repo)
C:\stores\brand2boost\              → Application store data
```

**Key Statistics:**
- Total directories in C:\scripts: 2,048
- Total files in C:\scripts: 13,819
- PowerShell tools: 270+ scripts
- Worker agent seats: 11 allocated

---

### Software Inventory
**File:** `software-inventory.md`
**Purpose:** All installed development tools, versions, installation paths, disk usage
**Size:** 544 lines (~22 KB)
**Status:** ✅ Complete
**Key Topics:**
- Development tools (Git, Node.js, .NET SDK, Visual Studio)
- CLI tools (gh, claude-cli, winget, chocolatey)
- Language runtimes and frameworks
- Database tools (SQL Server, SQLite)
- Version control and deployment tools
- Hidden dependencies and disk space impact
- Installation methods and update procedures
- **CRITICAL:** Disk space constraints and size awareness

**Critical Tools:**
```
Git:             C:\Program Files\Git\
Node.js:         C:\Program Files\nodejs\
.NET 8 SDK:      C:\Program Files\dotnet\
Visual Studio:   [User's IDE - NOT controlled by agent]
GitHub CLI:      C:\Program Files\GitHub CLI\
Claude CLI:      C:\Users\<user>\AppData\Local\Programs\claude-cli\
PowerShell 7:    C:\Program Files\PowerShell\7\
```

**Disk Space Awareness Protocol:**
1. ✅ Check stated binary size
2. ✅ Check hidden dependencies (LLM models, browser binaries, runtimes)
3. ✅ Verify actual disk usage (not just package size)
4. ✅ Warn for tools >100 MB
5. ✅ Provide alternatives for constrained environments

**Known Hidden Dependencies:**
- Ollama: 0.2 MB binary → 1-7 GB LLM models
- Playwright: ~500 MB (includes Chromium, Firefox, WebKit browsers)
- Large npm packages: Check node_modules size after install

---

### Environment Variables
**File:** `environment-variables.md`
**Purpose:** System and user environment variables, API keys registry, secure configuration
**Size:** 646 lines (~26 KB)
**Status:** ✅ Complete
**Key Topics:**
- System PATH configuration
- User-level environment variables
- API key storage and retrieval (references to secrets registry)
- Development environment variables (NODE_ENV, ASPNETCORE_ENVIRONMENT)
- Tool-specific configuration (GH_TOKEN, OPENAI_API_KEY location)
- Security best practices (appsettings.Secrets.json usage)
- Environment variable precedence rules
- Variable modification procedures

**Critical Variables:**
```
PATH:           Includes Git, Node, .NET, PowerShell, tools
OPENAI_KEY:     → C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json
GH_TOKEN:       GitHub CLI authentication
CLAUDE_API_KEY: Claude Code CLI authentication
NODE_ENV:       Development/Production mode
```

**Security Rules:**
- ❌ NEVER store API keys directly in environment variables
- ✅ Always use appsettings.Secrets.json for API keys
- ✅ Reference secrets registry in 09-SECRETS category
- ✅ Use .gitignore for all secret files
- ⚠️ Check scan-secrets.ps1 before committing

---

## Quick Reference

**Common Questions:**

| Question | Answer |
|----------|--------|
| Where is client-manager? | C:\Projects\client-manager\ - See file-system-map.md § C:\Projects |
| Where are worker agent seats? | C:\Projects\worker-agents\agent-XXX\ - See file-system-map.md § Worker Agent Pool |
| What .NET version? | .NET 8 SDK - See software-inventory.md § Language Runtimes |
| Where are API keys stored? | C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json - See environment-variables.md § API Keys |
| Can I install tool X? | Check size + hidden deps first - See software-inventory.md § Disk Space Protocol |
| What's in PATH? | Git, Node, .NET, PowerShell, tools - See environment-variables.md § System PATH |
| How much disk space available? | **CONSTRAINED** - Always check before installing - See software-inventory.md § Critical Constraint |

---

## Cross-References

**Related Categories:**
- **01-USER** → User's disk space constraint (psychology-profile.md § Disk Space)
- **03-DEVELOPMENT** → Git repositories, development workflows
- **05-PROJECTS** → Project-specific paths and configurations
- **07-AUTOMATION** → Tools that depend on installed software
- **09-SECRETS** → API keys registry (referenced from environment-variables.md)

**Related Files:**
- `C:\scripts\MACHINE_CONFIG.md` → Legacy machine configuration (migrated to this category)
- `C:\scripts\bootstrap\bootstrap.ps1` → Environment setup automation
- `C:\scripts\bootstrap\install-dependencies.ps1` → Software installation script
- `C:\scripts\tools\health-check.ps1` → Environment validation tool

---

## Search Tips

**Tags in this category:** `#machine-config`, `#filesystem`, `#directories`, `#structure`, `#organization`, `#software`, `#installed-tools`, `#versions`, `#paths`, `#environment-variables`, `#api-keys`, `#configuration`, `#disk-space`

**Search examples:**
```bash
# Find specific path
grep -r "C:\\\\Projects\\\\client-manager" C:\scripts\_machine\knowledge-base\02-MACHINE\

# Find installed software versions
grep -r "version:" C:\scripts\_machine\knowledge-base\02-MACHINE\software-inventory.md

# Find environment variable
grep -r "OPENAI_KEY" C:\scripts\_machine\knowledge-base\02-MACHINE\

# Find disk space constraints
grep -r "disk space" C:\scripts\_machine\knowledge-base\02-MACHINE\

# Check worker agent seats
grep -r "agent-" C:\scripts\_machine\knowledge-base\02-MACHINE\file-system-map.md
```

---

## Maintenance

**Update triggers:**
- New software installed or uninstalled
- Directory structure changes (new repos, agent seats)
- Environment variables added or modified
- Path configuration changes
- Disk space constraints discovered
- Version upgrades for critical tools

**Review frequency:**
- **After software installation** - Update software-inventory.md immediately
- **After directory creation** - Update file-system-map.md
- **Weekly** - Verify PATH and environment variables
- **Monthly** - Full inventory audit
- **After bootstrap** - Validate all sections

**Update protocol:**
1. Identify which file(s) changed (filesystem/software/environment)
2. Update relevant sections with accurate information
3. Add version numbers and installation dates
4. Document disk space impact for new software
5. Update cross-references if paths changed
6. Run health-check.ps1 to validate changes

---

## Validation Tools

**Verify machine configuration:**

```powershell
# Comprehensive health check
powershell -File "C:\scripts\tools\health-check.ps1" -Full

# Check specific aspects
$env:PATH -split ';'                    # Verify PATH
Get-Command git, node, dotnet -ErrorAction SilentlyContinue  # Check tools
Get-ChildItem C:\Projects\worker-agents\ # Check agent seats
Test-Path C:\Projects\client-manager\   # Verify project paths

# Bootstrap validation
powershell -File "C:\scripts\bootstrap\verify-environment.ps1"
```

---

## Success Metrics

**Machine configuration is accurate ONLY IF:**
- ✅ All paths resolve correctly in scripts
- ✅ Software inventory matches installed tools (winget list matches docs)
- ✅ Environment variables accessible by tools
- ✅ health-check.ps1 passes all validation checks
- ✅ No "file not found" or "command not found" errors
- ✅ Disk space constraints respected (no surprise 5GB installations)
- ✅ Worker agent seats all accessible and functional
- ✅ Bootstrap process succeeds on fresh machine using these docs

---

**Status:** Active - Living Documentation
**Owner:** Claude Agent (Self-maintaining)
**Quality:** HIGH - Validated against actual system state
**Next Review:** After next software installation or directory change
**Bootstrap Tested:** ✅ Yes - Used for environment setup automation
