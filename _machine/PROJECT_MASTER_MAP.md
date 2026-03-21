# PROJECT MASTER MAP - Complete Overview
**Last Updated:** 2026-03-02 19:45
**Purpose:** Single source of truth for ALL project mappings

---

## ACTIVE PRODUCTION PROJECTS

### Client-Manager (Brand2Boost / Brand Designer)
- **Local Path:** `C:\Projects\client-manager`
- **GitHub:** https://github.com/martiendejong/client-manager
- **Branch:** main
- **ClickUp Boards:**
  - Primary: `901214097647` (Brand Designer)
  - Strategic: `901215573347` (Brand2Boost - Birdseye View)
- **Type:** Full-stack (ASP.NET Core 9.0 + React/Vite)
- **Ports:**
  - Frontend (Vite): TBD (needs audit)
  - Backend (ASP.NET): HTTP 54502, HTTPS 54501
  - Frontend Config: `C:\Projects\client-manager\frontend\vite.config.ts` (needs strictPort check)
  - Backend Config: `C:\Projects\client-manager\ClientManagerAPI\Properties\launchSettings.json`
- **Related Repos:** Hazina (framework dependency)
- **Environment:** Visual Studio 2022
- **Deployment:**
  - **Server:** 85.215.217.154 (SSH: administrator / SpaceElevator1tam!)
  - **API Path:** `C:\stores\brand2boost\backend`
  - **Frontend Path:** `C:\stores\brand2boost\www`
  - **App Pool:** Brand2boost
  - **Production URL:** https://api.brand2boost.com
  - **Deploy Method:** Python SSH (deploy-dotnet-to-iis.py)
  - **Deploy Command:** `python3 C:/scripts/tools/deploy-dotnet-to-iis.py "C:/projects/client-manager/ClientManagerAPI" "C:\stores\brand2boost\backend" "Brand2boost"`
- **Status:** Active production - Deployed 2026-03-03 (Python SSH deployment)

### Hazina Framework
- **Local Path:** `C:\Projects\hazina`
- **GitHub:** https://github.com/martiendejong/Hazina
- **Branch:** develop
- **ClickUp Board:** `901215559249` (Hazina Framework)
- **Type:** C# Framework (.NET 9.0)
- **Related Repos:** Used by client-manager, seo-god, learningtool
- **Environment:** Visual Studio 2022
- **Deployment:** NuGet package (local) + MSI installer (C:\Program Files (x86)\Hazina Orchestration\)
- **MSI Port:** HTTPS:5123
- **Status:** Core framework - active development

### Art Revisionist
- **Local Paths:**
  - React Frontend: `C:\Projects\artrevisionist` (GitHub: martiendejong/artrevisionist)
  - WordPress Theme: `C:\Projects\artrevisionist-wp-theme` (GitHub: martiendejong/artrevisionist-wp-theme)
  - WordPress Core: `E:\xampp\htdocs\art-revisionist`
  - WordPress Plugin: `C:\Projects\artrevisionist-wordpress` (GitHub: martiendejong/artrevisionist-wordpress)
- **GitHub Repos:**
  - Frontend: https://github.com/martiendejong/artrevisionist
  - WP Theme: https://github.com/martiendejong/artrevisionist-wp-theme
  - WP Plugin: https://github.com/martiendejong/artrevisionist-wordpress
- **Branch:** develop (all repos)
- **ClickUp Board:** `901211612245` (Art Revisionist Project)
- **Type:** WordPress + React hybrid
- **Environment:** XAMPP (E:\xampp\)
- **Deployment:** FTP (vault:ftp-artrevisionist)
- **WordPress Credentials:** vault:wordpress-artrevisionist
- **Status:** Active client project (28 backlog tasks refined 2026-03-01)

### SEO God
- **Local Path:** `E:\projects\seo-god`
- **GitHub:** https://github.com/martiendejong/seo-god
- **Branch:** develop
- **ClickUp Board:** `901215927087` (SEO God)
- **Type:** Full-stack WordPress SEO automation (ASP.NET Core + AI)
- **Ports:**
  - Frontend (Vite): HTTPS 5198 (strictPort: true ✅)
  - Backend (ASP.NET): HTTP 5104, HTTPS 7057
  - Config: `E:\projects\seo-god\frontend\vite.config.ts`
- **Related Repos:** Hazina (framework dependency)
- **Environment:** VS Code
- **Deployment:** TBD
- **Status:** Active development - Port management fixed (2026-03-02)

### LearningTool
- **Local Path:** `E:\projects\learningtool`
- **GitHub:** https://github.com/martiendejong/learningtool
- **Branch:** master
- **ClickUp Board:** `901215905273` (LearningTool)
- **Type:** Full-stack AI learning platform (ASP.NET Core + React/Vite)
- **Ports:**
  - Frontend (Vite): HTTP 5190 (strictPort: true ✅)
  - Backend (ASP.NET): TBD (needs audit)
  - Config: `E:\projects\learningtool\frontend\vite.config.ts`
- **Related Repos:** Hazina (framework dependency)
- **Environment:** VS Code
- **Deployment:** TBD
- **Status:** Active development - Port management fixed (2026-03-02)

### Simple Translation Manager (STM Plugin)
- **Local Path:** `E:\xampp\htdocs\wp-content\plugins\simple-translation-manager`
- **GitHub:** TBD (not in scan results)
- **Branch:** TBD
- **ClickUp Board:** `901216036563` (STM Plugin WordPress)
- **Type:** WordPress Plugin
- **Environment:** XAMPP
- **Deployment:** WordPress plugin directory / FTP
- **Status:** Active development

### Real Estate Agency AI
- **Local Path:** `E:\projects\bliek`
- **GitHub:** https://github.com/martiendejong/real-estate-agency-ai
- **Branch:** feature/button-styling-869ca51ff
- **ClickUp Board:** `901216032110` (from project-locations.md)
- **Type:** Full-stack (ASP.NET Core 9.0 + React/Vite)
- **Ports:**
  - Frontend (Vite): HTTP 3500 (strictPort: true ✅)
  - Backend (ASP.NET): HTTP 5000/5028, HTTPS 7000
  - Frontend Config: `E:\projects\bliek\frontend-react\vite.config.ts`
  - Backend Config: `E:\projects\bliek\src\Bliek.API\Properties\launchSettings.json`
- **Environment:** VS Code
- **Deployment:** TBD
- **Status:** Active development - Port management fixed (2026-03-02)

### CodeHub
- **Local Path:** `E:\projects\CodeHub`
- **GitHub:** https://github.com/matchy123/CodeHub
- **Branch:** feature/bundle-system
- **ClickUp Board:** NOT IN CONFIG (needs to be added)
- **Type:** Full-stack (ASP.NET Core 9.0 + React/Vite/Tailwind + PostgreSQL)
- **Ports:**
  - Frontend (Vite): HTTP 3020 (strictPort: true ✅)
  - Backend (ASP.NET): HTTP 5028, HTTPS 7133
  - Frontend Config: `E:\projects\codehub\frontend\vite.config.ts`
  - Backend Config: `E:\projects\CodeHub\CodeHub.Api\Properties\launchSettings.json`
- **Environment:** VS Code
- **Deployment:** TBD
- **Status:** Active development - All ports documented (2026-03-02)

### Promotiemeester
- **Local Path:** `E:\projects\promotiemeester`
- **GitHub:** https://github.com/martiendejong/promotiemeester
- **Branch:** main
- **ClickUp Board:** TBD (needs to be created)
- **Type:** Frontend landing page (React + Vite + Tailwind CSS)
- **Ports:**
  - Frontend (Vite): HTTP 3100 (strictPort: true ✅)
  - Config: `E:\projects\promotiemeester\vite.config.js`
- **Environment:** VS Code
- **Deployment:** TBD (promotiemeester.nl)
- **Status:** Initial release - Complete landing page (2026-03-02)

---

## INFRASTRUCTURE & TOOLS

### DataDrivenAI
- **Local Path:** `E:\projects\datadrivenai`
- **GitHub:** https://github.com/martiendejong/datadrivenai
- **Branch:** master
- **ClickUp Board:** None
- **Type:** C# AI dashboard
- **Ports:**
  - API: HTTP 7088, HTTPS 7087
  - Dashboard: HTTP 9990 (needs launchSettings verification)
  - API Config: `E:\projects\datadrivenai\backend\DataDrivenAI.API\Properties\launchSettings.json`
- **Environment:** VS Code
- **Deployment:** Local only
- **Status:** Operational - API ports documented (2026-03-02)

### WhatsApp Bridge
- **Local Path:** `E:\projects\whatsappbridge`
- **GitHub:** https://github.com/martiendejong/whatsappbridge
- **Branch:** master
- **ClickUp Board:** None
- **Type:** C# API service
- **Deployment:** https://whatsapp.wreckingball.ai:5001/api/external
- **Credentials:** vault:whatsapp-bridge-api
- **Environment:** VS Code
- **Status:** Production deployed

### Email Bridge
- **Local Path:** `E:\projects\mailproxy`
- **GitHub:** https://github.com/martiendejong/email-bridge
- **Branch:** master
- **ClickUp Board:** None
- **Type:** ASP.NET Core 9.0 API service (Email proxy with SMTP/IMAP)
- **Deployment:**
  - **Server:** 85.215.217.154 (SSH: administrator / SpaceElevator1tam!)
  - **API Path:** `C:\inetpub\mailbridge`
  - **Database:** `C:\inetpub\mailbridge\data\emailbridge.db`
  - **App Pool:** EmailBridgePool (.NET 9.0, No Managed Code)
  - **Site Name:** EmailBridgeAPI
  - **Production URLs:**
    - HTTP: http://mailbridge.wreckingball.ai
    - HTTPS: https://mailbridge.wreckingball.ai (SSL pending configuration)
  - **Deploy Method:** Python SSH (manual deployment scripts in C:\Temp\)
- **Features:**
  - JWT authentication for user management
  - Token-based external API (X-Api-Token header)
  - SMTP/IMAP email operations (send, fetch, search, folders)
  - Background email sync worker (5-minute intervals)
  - SQLite database with EF Core migrations
- **Environment:** Visual Studio Code
- **Status:** Production deployed (2026-03-09)

### Password Manager (Vault)
- **Local Path:** `E:\projects\passwordmanager\backend\PasswordManager.API`
- **GitHub:** https://github.com/martiendejong/passwordmanager
- **Branch:** master
- **ClickUp Board:** `901216204895` (DataDrivenAI - Password Manager Extension)
- **Type:** Full-stack (ASP.NET Core 8.0 + React/Vite/Tailwind + Browser Extension)
- **Components:**
  - **Backend:** `E:\projects\passwordmanager\backend\PasswordManager.API` (.NET 8.0, JWT auth, EF Core, SQLite)
  - **Frontend:** `E:\projects\passwordmanager\frontend` (React + TypeScript + Vite + Tailwind CSS)
  - **Extension:** `E:\projects\passwordmanager\extension` (Chrome Manifest V3 browser extension)
- **Deployment:**
  - **Server:** 85.215.217.154 (SSH: administrator / SpaceElevator1tam!)
  - **API Path:** `C:\inetpub\vault\backend`
  - **Frontend Path:** `C:\inetpub\vault\www`
  - **Database:** `C:\inetpub\vault\backend\passwordmanager.db`
  - **App Pool:** VaultPool
  - **Production URL:** https://vault.prospergenics.com
  - **Deploy Method:** Python SSH (deploy-dotnet-to-iis.py)
  - **Deploy Command:** `python C:\scripts\tools\deploy-dotnet-to-iis.py passwordmanager`
- **Features:**
  - JWT authentication with ASP.NET Core Identity
  - Password encryption (AES)
  - Project-linked credentials
  - Browser extension integration
  - Credential auto-save/update detection
  - SQLite database with EF Core migrations
- **Environment:** VS Code
- **Status:** Ready for deployment (2026-03-11)

### Personality Test
- **Local Path:** `E:\projects\personalitytest`
- **GitHub:** https://github.com/martiendejong/personalitytest
- **Branch:** main
- **ClickUp Board:** `901216266641` (GigsHub > Team Tasks > Internal)
- **Type:** Full-stack (ASP.NET Core 9.0 + React/Vite/Tailwind + PostgreSQL)
- **Components:**
  - **Backend:** `E:\projects\personalitytest\backend` (.NET 9.0, JWT auth, EF Core, PostgreSQL)
  - **Frontend:** `E:\projects\personalitytest\frontend` (React + TypeScript + Vite + Tailwind CSS v4)
- **Deployment:**
  - **Server:** 85.215.217.154 (SSH: administrator / SpaceElevator1tam!)
  - **API Path:** `C:\stores\personalitytest\backend`
  - **Frontend Path:** `C:\stores\personalitytest\www`
  - **Database:** PostgreSQL (connection string in appsettings.Production.json)
  - **App Pool:** PersonalityTest
  - **Production URL:** https://personalitytest.prospergenics.com
  - **Deploy Method:** Python SSH (deploy-dotnet-to-iis.py)
- **Features:**
  - Multi-axis personality test scoring
  - PlugAndPay payment integration
  - AI-powered analysis (Hazina LLM + OpenAI GPT-4 fallback)
  - Email service with magic login links
  - Admin dashboard with test editor
  - PDF export capabilities
- **Environment:** VS Code
- **Status:** Production ready (2026-03-14)

### MastermindGroupAI
- **Local Path:** `C:\Projects\mastermindgroupAI`
- **GitHub:** https://github.com/martiendejong/mastermindgroupAI
- **Branch:** feature/mastermind-active-council
- **ClickUp Board:** `901216408061` (Jengo's Board)
- **Type:** Full-stack (ASP.NET Core 9.0 + React 19 + Vite/Tailwind + SQLite)
- **Components:**
  - **Backend:** `C:\Projects\mastermindgroupAI\src\MastermindGroup.Api` (.NET 9.0, JWT auth, EF Core, SQLite)
  - **Frontend:** `C:\Projects\mastermindgroupAI\ui` (React 19 + TypeScript + Vite + Tailwind CSS)
- **Ports:**
  - Frontend (Vite): HTTP 8084
  - Backend (ASP.NET): HTTP 7000, HTTPS 7001
- **Deployment:**
  - **Server:** 85.215.217.154 (SSH: administrator / SpaceElevator1tam!)
  - **API Path:** `C:\stores\mastermind\backend`
  - **Frontend Path:** `C:\stores\mastermind\www`
  - **Database:** `C:\stores\mastermind\backend\mastermind.db` (SQLite)
  - **App Pool:** MastermindGroup
  - **Production URL:** https://mastermind.prospergenics.com
  - **Deploy Method:** Python SSH (deploy-dotnet-to-iis.py)
  - **Deploy Command:** `python C:\scripts\tools\deploy-dotnet-to-iis.py "C:\Projects\mastermindgroupAI\src\MastermindGroup.Api" "C:\stores\mastermind\backend" "MastermindGroup"`
- **Features:**
  - Mastermind group facilitation platform
  - Password reset with email verification (PR #5)
  - JWT authentication with BCrypt hashing
  - Email service integration
  - SQLite database with EF Core migrations
  - Hazina framework integration (LLM client, observability, security)
- **Related Repos:** Hazina (framework dependency)
- **Environment:** VS Code
- **Status:** Active development - Password reset implemented (2026-03-14)

### Autonomous Dev System (Claude Scripts)
- **Local Path:** `C:\Projects\claudescripts` (also C:\scripts symlinked?)
- **GitHub:** https://github.com/martiendejong/autonomous-dev-system
- **Branch:** master
- **ClickUp Board:** `901215818012` (General & Meta Tasks)
- **Type:** PowerShell + C# automation
- **Environment:** VS Code
- **Deployment:** Local only (C:\scripts\ working directory)
- **Status:** Core infrastructure - daily use

### Agentic Debugger VSIX
- **Local Path:** `C:\Projects\AgenticDebuggerVsix`
- **GitHub:** https://github.com/martiendejong/AgenticDebuggerVsix
- **Branch:** feature/vs-automation-poc
- **ClickUp Board:** None (General & Meta Tasks?)
- **Type:** Visual Studio Extension (C#)
- **Environment:** Visual Studio 2022
- **Deployment:** VSIX package
- **Status:** POC development

### Claude Terminal
- **Local Path:** `C:\Projects\claude-terminal`
- **GitHub:** None (local only)
- **Branch:** master
- **ClickUp Board:** None
- **Type:** ConPTY wrapper (C#)
- **Environment:** Visual Studio 2022
- **Deployment:** Local only
- **Status:** Utility tool

### FolderTool
- **Local Path:** `E:\projects\foldertool`
- **GitHub:** TBD (not in scan)
- **Branch:** TBD
- **ClickUp Board:** NOT IN CONFIG (needs to be added)
- **Type:** ASP.NET Core 8.0 + React 18 + Vite + OpenAI
- **Environment:** VS Code
- **Deployment:** TBD
- **Status:** Unknown

---

## ARCHIVED / INACTIVE PROJECTS

### DevGPT
- **Local Path:** `C:\Projects\devgpt`
- **GitHub:** https://github.com/martiendejong/devgpt
- **Branch:** main
- **Status:** Archived/superseded

### DevGPT Tools
- **Local Path:** `E:\projects\DevGPTTools`
- **GitHub:** https://github.com/martiendejong/devgpttools
- **Branch:** main
- **Status:** Archived/superseded

### SCP
- **Local Path:** `C:\Projects\scp`
- **GitHub:** https://github.com/martiendejong/SCP
- **Branch:** main
- **Status:** Archived

### Local Ledger / Ledger App
- **Local Paths:** `C:\Projects\localledger`, `E:\projects\ledgerapp`
- **GitHub:** https://github.com/martiendejong/LocalLedger (localledger only, ledgerapp has no remote)
- **Status:** Archived

---

## EXTERNAL / FORKED PROJECTS

### Agent Zero
- **Local Path:** `E:\projects\agent-zero`
- **GitHub:** https://github.com/frdel/agent-zero (forked)
- **Status:** External dependency/reference

### OpenClaw
- **Local Path:** `E:\projects\openclaw`
- **GitHub:** https://github.com/openclaw/openclaw (forked)
- **Status:** External dependency/reference

### MCP Server C# SDK
- **Local Path:** `C:\Projects\mcp-server-csharp-sdk`
- **GitHub:** https://github.com/modelcontextprotocol/csharp-sdk (forked)
- **Status:** External dependency

---

## CLICKUP BOARDS NOT MAPPED TO REPOS

### Team Projects
- **ClickUp Board:** `901216031418` (Team Projects)
- **Purpose:** Major project milestones and initiatives for daily team review
- **Mapped Repos:** None (meta-level planning)

### General & Meta Tasks
- **ClickUp Board:** `901215818012` (General & Meta Tasks)
- **Purpose:** Platform experiments, agent development, external integrations, meta work
- **Mapped Repos:** Likely autonomous-dev-system, agentic debugger, etc.

### Nijeveen (Personal)
- **ClickUp Board:** `901519266250` (household tasks)
- **Workspace:** Personal
- **Purpose:** Home maintenance, cleaning, improvements
- **Mapped Repos:** None

### Vera AI (Legacy)
- **ClickUp Board:** `901506248257` (Vera AI - legacy)
- **Note:** Not actively used
- **Mapped Repos:** None

### SocraNext
- **ClickUp Board:** `901511986511` (SocraNext)
- **Status:** 3 tasks, possibly E:\projects has socranext.zip
- **Mapped Repos:** None found (may need to be unzipped)

### CloudGrafo
- **ClickUp Board:** `901213168637` (CloudGrafo)
- **Task Count:** 14
- **Mapped Repos:** None found

### Vloerenhuis
- **ClickUp Board:** `901213305955` (Vloerenhuis)
- **Task Count:** 33
- **Mapped Repos:** None found

### Wreckingball.ai
- **ClickUp Board:** `901211218756` (wreckingball.ai)
- **Task Count:** 19
- **Mapped Repos:** Possibly whatsappbridge?

---

## INCONSISTENCIES FOUND (NEEDS RESOLUTION)

### CodeHub
- ❌ **MISSING from clickup-config.json**
- ✅ Path: E:\projects\CodeHub
- ✅ GitHub: matchy123/CodeHub
- ✅ Active development (PR #20)
- 🔧 **ACTION:** Add to clickup-config.json with new list

### Real Estate Agency AI
- ❌ **MISSING from clickup-config.json projects section**
- ✅ List ID mentioned in project-locations.md: 901216032110
- ✅ Path: E:\projects\bliek
- ✅ GitHub: martiendejong/real-estate-agency-ai
- 🔧 **ACTION:** Add to clickup-config.json

### FolderTool
- ❌ **MISSING from clickup-config.json**
- ✅ Path: E:\projects\foldertool
- ❌ GitHub: unknown
- 🔧 **ACTION:** Determine status, add to config or archive

### Simple Translation Manager
- ✅ In clickup-config.json
- ❌ **GitHub repo not found in scan**
- ✅ Path mentioned: E:\xampp\htdocs\wp-content\plugins\simple-translation-manager
- 🔧 **ACTION:** Verify GitHub repo exists and add remote

### Art Revisionist - Multiple Repos
- ⚠️ **4 separate repositories for one project**
  1. artrevisionist (React frontend)
  2. artrevisionist-wp-theme (WordPress theme)
  3. artrevisionist-wordpress (WordPress plugin)
  4. WordPress installation (E:\xampp\htdocs\art-revisionist)
- ✅ ClickUp board maps only to main project
- 🔧 **ACTION:** Document relationships in clickup-config.json

### Autonomous Dev System Path
- ⚠️ Repo at `C:\Projects\claudescripts`
- ⚠️ Working directory at `C:\scripts`
- 🔧 **ACTION:** Clarify relationship (symlink? copy? separate?)

---

## GITHUB REPOS WITHOUT LOCAL CLONES

(Run `gh repo list martiendejong --limit 100` to find missing repos)

---

## RECOMMENDED ACTIONS

### Immediate
1. ✅ Add CodeHub to clickup-config.json with new ClickUp list
2. ✅ Add Bliek Vastgoed to clickup-config.json projects section
3. ✅ Document Art Revisionist multi-repo relationship
4. ✅ Add FolderTool to config or mark as archived
5. ✅ Find/create Simple Translation Manager GitHub repo

### Process Improvements
1. ✅ Create `project-new.ps1` script that IMMEDIATELY:
   - Creates ClickUp list
   - Creates GitHub repo
   - Adds to clickup-config.json
   - Adds to PROJECT_MASTER_MAP.md
   - Documents in project-locations.md

2. ✅ Create `project-update.ps1` script that:
   - Scans for changes (new repos, moved folders)
   - Updates all documentation files
   - Validates consistency

3. ✅ Add pre-commit hook that validates:
   - ClickUp config consistency
   - GitHub remotes exist
   - PROJECT_MASTER_MAP is current

---

## NOTES

- **Default Assignee:** 74525428 (Martien de Jong)
- **Team Member:** Frank Kobaai (ID: 88553909)
- **Vault Location:** C:\scripts\_machine\vault.secure.json
- **ClickUp API Config:** C:\scripts\_machine\clickup-config.json
- **Worker Agents:** C:\Projects\worker-agents\agent-001 through agent-010
- **Worktree Pool:** C:\scripts\_machine\worktrees.pool.md
- **Jengo Brain Repo:** E:\jengo (2147+ text files, master branch)

---

**Maintained by:** Jengo (Claude Agent)
**Update Frequency:** After ANY project creation, modification, or discovery
**Validation:** Run `C:\scripts\temp\scan-all-projects.ps1` to regenerate inventory

### promotiemeester
- **Local Path:** `E:\projects\promotiemeester`
- **GitHub:** https://github.com/martiendejong/promotiemeester
- **Branch:** main
- **ClickUp Board:** `TBD`
- **Type:** frontend
- **Environment:** vscode
- **Deployment:** TBD
- **Status:** Active development
- **Description:** Landing page voor promotiemeester.nl met SEO Meester en Social Media Meester producten
- **Created:** 2026-03-02

### websearch
- **Local Path:** `E:\projects\websearch`
- **GitHub:** https://github.com/martiendejong/websearch
- **Branch:** main
- **ClickUp Board:** `TBD`
- **Type:** framework
- **Environment:** visual-studio
- **Deployment:** TBD
- **Status:** Active development
- **Description:** Ultimate Web Search Library - Multi-engine search with Google, Bing, and more
- **Created:** 2026-03-14
