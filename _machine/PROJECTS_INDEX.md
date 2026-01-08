# Projects Index - Complete Machine Overview

**Generated:** 2026-01-08
**Purpose:** Master index of all projects, repositories, and stores on this machine

---

## 📂 Directory Structure Overview

```
C:\
├── Projects\           ← Code repositories (110+ projects)
├── stores\            ← Configuration and data stores (7 stores)
└── scripts\           ← Control plane and automation
    ├── _machine\      ← Machine-wide state and tracking
    ├── agents\        ← Agent specifications
    ├── tasks\         ← Task tracking
    ├── plans\         ← Implementation plans
    ├── tools\         ← Automation tools
    └── logs\          ← Session logs
```

---

## 🎯 PRIMARY PROJECTS (Active Development)

### 1. Brand2Boost / Client Manager
**Path:** `C:\Projects\client-manager`
**GitHub:** https://github.com/martiendejong/client-manager
**Type:** SaaS Application (Brand Development & Promotion Software)
**Status:** ✅ Active Development

**Technology Stack:**
- **Backend:** .NET 9.0 Web API (C#)
- **Frontend:** React 18 + Vite + TypeScript
- **UI Framework:** Radix UI + Tailwind CSS + shadcn/ui
- **State Management:** Zustand
- **Real-time:** SignalR
- **Rich Text:** TipTap Editor
- **Auth:** Google OAuth + Custom JWT
- **Testing:** Vitest + Testing Library + Storybook
- **Build:** Vite (dev server + production builds)

**Key Features:**
- AI-powered brand development workflow
- Interview-based brand analysis
- Image generation (DALL-E integration)
- Logo design pipeline
- Brand document generation
- Content calendar management
- Multi-tenant architecture
- Role-based access control (RBAC)

**Solution Files:**
- `ClientManager.sln` - Production (NuGet packages)
- `ClientManager.local.sln` - Local development (project references)

**Store:** `C:\stores\brand2boost`

**Key Files:**
- API: `ClientManagerAPI/Program.cs`, `Controllers/`, `Services/`
- Frontend: `ClientManagerFrontend/src/`
- Tests: `ClientManager.Tests/`

**Dependencies:**
- Hazina framework (local: `C:\Projects\hazina`)
- DevGPT libraries (NuGet packages)

**Admin Credentials:**
- User: wreckingball
- Password: Th1s1sSp4rt4!

---

### 2. Hazina AI Framework
**Path:** `C:\Projects\hazina`
**Type:** .NET AI Infrastructure Framework
**Status:** ✅ Active Development (Rebrand from DevGPT)

**Description:**
Production-ready AI infrastructure for .NET that scales from prototype to production without rewriting code. Formerly known as DevGPT, rebranded to Hazina.

**Technology Stack:**
- **.NET:** 9.0
- **AI Providers:** OpenAI, Anthropic, Gemini, Mistral, HuggingFace
- **Architecture:** Multi-provider with automatic failover
- **Vector Stores:** In-memory, PostgreSQL, Supabase
- **Monitoring:** Built-in cost tracking, health checks, telemetry

**Key Features:**
- Multi-provider LLM abstraction (OpenAI, Anthropic, Gemini, etc.)
- RAG (Retrieval Augmented Generation) engine
- Agentic workflows
- Embedding generation and vector storage
- Circuit breaker + automatic failover
- Cost tracking and budget limits
- Hallucination detection
- Production monitoring

**Solution Files:**
- `Hazina.sln` - Main solution
- `Hazina.AI.sln` - AI-specific components
- `Hazina.Apps.sln` - Application layer
- `Hazina.Core.sln` - Core framework
- `Hazina.Tools.sln` - Development tools
- `Hazina.QuickStart.sln` - Getting started

**Key Directories:**
- `Libraries/` - Core libraries
- `apps/` - Sample applications
- `docs/` - Documentation
- `Tests/` - Unit and integration tests

**NuGet Packages (Published):**
- Hazina.AI.FluentAPI
- Hazina.AI.RAG
- Hazina.AI.Agents
- Hazina.Production.Monitoring
- (Many more - see README)

---

### 3. Worker Agents (Worktree Pool)
**Path:** `C:\Projects\worker-agents\`
**Type:** Git worktree allocation pool
**Status:** ✅ Active (Concurrency management)

**Purpose:**
Isolated git worktrees for parallel agent execution to prevent conflicts and data corruption.

**Structure:**
```
worker-agents/
├── agent-001/
│   └── client-manager/   ← Git worktree for agent-001
├── agent-002/
│   └── client-manager/   ← Git worktree for agent-002
├── agent-003/
│   └── client-manager/   ← Git worktree for agent-003
└── agent-004/
    └── client-manager/   ← Git worktree for agent-004
```

**Managed by:**
- `C:\scripts\_machine\worktrees.pool.md` - Allocation table
- `C:\scripts\_machine\worktrees.activity.md` - Activity log
- `C:\scripts\_machine\worktrees.protocol.md` - Protocol documentation

**Status Tracking:**
- FREE - Available for allocation
- BUSY - Locked by an agent
- STALE - Inactive >2 hours
- BROKEN - Needs repair

---

## 📦 DATA STORES (C:\stores\)

### 1. brand2boost
**Path:** `C:\stores\brand2boost`
**Type:** Configuration + Data Store
**Used by:** Client Manager / Brand2Boost
**Git:** Yes (tracked)

**Contents:**
- **Databases:**
  - `identity.db` - User authentication (SQLite)
  - `llm-logs.db` - LLM API call logs (SQLite)

- **Configuration Files:**
  - `analysis-fields.config.json` - Brand analysis field definitions
  - `interview.settings.json` - Interview workflow settings
  - `opening-questions.json` - Initial onboarding questions
  - `tools.config.json` - AI tool configurations
  - `users.json` - User management data

- **AI Prompts (30+ prompt files):**
  - Brand development prompts: `brand-*.prompt.txt`
  - Business planning: `business-*.prompt.txt`
  - Visual identity: `logo-*.prompt.txt`, `color-scheme.prompt.txt`, `typography.prompt.txt`
  - Content generation: `image-prompt-*.prompt.txt`
  - Workflow steps: `step1_concept.txt`, `step2_identity.txt`, etc.
  - Analysis: `analysis-fields.config.json`

- **Documentation:**
  - `ANALYSIS_AND_IMPROVEMENTS.md` - Analysis and improvement tracking

**Purpose:**
Centralized configuration and data storage for Brand2Boost SaaS, separating code from configuration and user data.

---

### 2. Other Stores
**Path:** `C:\stores\`

- **artrevisionist** - Configuration for Art Revisionist project
- **artrevisionist.b** - Backup/archive
- **brand2boost.b** - Backup/archive
- **branddesigner** - Brand designer configuration
- **config** - General configuration
- **SCP** - SCP-related data (Secure Copy Protocol or project-specific)

---

## 🛠️ CONTROL PLANE (C:\scripts\)

See [SCRIPTS_INDEX.md](./SCRIPTS_INDEX.md) for full documentation.

**Key Components:**
- `claude.md` - Operational manual (11KB)
- `claude_info.txt` - Critical reminders (5KB)
- `ZERO_TOLERANCE_RULES.md` - Workflow enforcement (3KB)
- `_machine/` - Machine state and tracking
- `tools/` - Automation scripts
- `agents/` - Agent specifications

---

## 📊 OTHER PROJECTS (C:\Projects\)

### Development Tools & Infrastructure

**AgenticDebuggerVsix** - Visual Studio debugger extension for agentic control
**mcp-server-csharp-sdk** - Model Context Protocol server SDK in C#

### AI & LLM Projects

**aiexplorer** - AI exploration and experimentation
**Aiteam** - AI team collaboration
**DevGPT** - Original DevGPT framework (now Hazina)
**DevGPTTools** - Content generation tools and services
**DevGPTStore** - DevGPT store implementation
**game_ai** - AI for game development
**VeraAI** - Vera AI assistant system
**vera** - Vera core application
**vera_aio_history** - Vera all-in-one history
**Vera_Core** - Vera core components
**vera-ocean** - Vera Ocean variant
**neurochain** - Neural chain project

### Business Applications

**courses** - Course management system
**customerprofiles** - Customer profile management
**emailclient** - Email client application
**localledger** - Local ledger/accounting

### Content & Marketing

**socialmediahulp** - Social media help platform
**socialmediahulptasks** - Task management for social media
**socialmediahulpempty** - Empty template
**deanderekrant** - De Andere Krant project
**frankwatching contentkalender** - Content calendar for Frankwatching

### E-commerce & Business Sites

**vloerenhuis** - Floor house e-commerce
**woo-final-price** - WooCommerce final price plugin
**zafari** - Zafari project
**zafari.africa site analysis** - Site analysis for Zafari

### WordPress Projects

**artrevisionist** - Art revisionist WordPress site
**artrevisionist w** - WordPress variant
**artrevisionist-wordpress** - WordPress integration
**artrevisionist-wp-theme** - Custom WordPress theme

### Personal & Creative

**blowen** - Personal project
**boek** - Book project
**bezwaren** - Objections/complaints system
**belastingdienst van de ziel** - "Tax office of the soul"
**bugattiinsights** - Bugatti insights
**hardcore magic** - Magic-related project
**universityofme** - Personal university project
**the art lexicon** - Art terminology lexicon
**martiendejongnl** - Personal website
**martienchat** - Personal chat application

### Business & Consulting

**corina** - Corina project
**corina_tasks** - Task management for Corina
**frankswebsite** - Frank's website
**nashipaeculturaloasis** - Nashipae Cultural Oasis
**prosper genics** - Prospergenics project
**ProspergenicsHub** - Prospergenics hub
**Wantam** - Wantam project

### Data & Analytics

**bigquery** - BigQuery integration
**bigquery2** - BigQuery variant 2
**bigquery_data** - BigQuery data storage
**bigquery_tasks** - BigQuery tasks

### Government & Legal

**d66** - D66 political party project
**inburgering** - Immigration/integration
**onsnedap-api** - ONS NEDAP API
**visa application** - Visa application system

### Development Tools

**appbuilder selfmodify** - Self-modifying app builder
**appbuilder windows** - Windows app builder
**cv-matcher** - CV matching tool
**myhtmlgame** - HTML game project
**platformer_test** - Platformer game test
**PathfindingAlgos** - Pathfinding algorithms
**recursivestatemachine** - Recursive state machine

### Archive & Miscellaneous

**Looslaan** - Looslaan project
**Looslaan converted** - Converted version
**react-demo** - React demonstration
**safari avontuur** - Safari adventure
**scp** - SCP project
**socranext** - SocraNEXT project
**valentine** - Valentine project
**vera bewijzen** - Vera proofs/evidence
**Vera shared** - Vera shared resources
**veraconfig** - Vera configuration
**zebra** - Zebra project
**-EthX_Core_v42** - EthX Core version 42

### Data & Bulk Operations

**bulkchanges_clientmanager** - Bulk changes for client manager
**cvdoc** - CV documentation
**dewvgptconfigs** - DevGPT configurations
**devgpt_custom** - Custom DevGPT
**devgpt_custom_goals** - DevGPT custom goals
**devgpt_custom_history** - DevGPT custom history
**devgpt_custom_info** - DevGPT custom info
**devgpt_custom_mood** - DevGPT custom mood
**devgpt_custom_prompts** - DevGPT custom prompts
**devgpt_custom_tasks** - DevGPT custom tasks
**devgpt_custom_values** - DevGPT custom values
**linkedinaicompilatie** - LinkedIn AI compilation

### Templates & Empty Projects

**empty_store** - Empty store template

---

## 🔧 TECHNOLOGY STACKS SUMMARY

### Primary Stack (Client Manager)
- **Backend:** .NET 9.0, C#, ASP.NET Core, Entity Framework Core
- **Frontend:** React 18, TypeScript, Vite, Tailwind CSS
- **Database:** SQLite (dev), PostgreSQL (prod ready)
- **AI:** OpenAI API, DALL-E, GPT-4
- **Auth:** JWT, Google OAuth
- **Real-time:** SignalR
- **Testing:** Vitest, xUnit, Storybook

### Framework Stack (Hazina)
- **.NET:** 9.0
- **LLM Providers:** OpenAI, Anthropic, Gemini, Mistral, HuggingFace, Semantic Kernel
- **Vector DBs:** PostgreSQL, Supabase, In-Memory
- **Monitoring:** Custom telemetry, cost tracking
- **Architecture:** Circuit breaker, failover, retry policies

### Supporting Technologies
- **Git:** Version control with worktree isolation
- **PowerShell:** Automation scripts
- **Docker:** Containerization (Hazina)
- **NuGet:** Package distribution
- **GitHub Actions:** CI/CD
- **Stripe:** Payment processing

---

## 📈 STATISTICS

**Total Projects:** 110+
**Active Primary Projects:** 3 (Client Manager, Hazina, Worker Agents)
**Data Stores:** 7
**Git Worktrees:** 4 (agent-001 to agent-004)
**Solution Files:** 20+ (.sln)
**Primary Languages:** C#, TypeScript, JavaScript
**Frameworks:** .NET 9.0, React 18

---

## 🔗 RELATED DOCUMENTATION

- [SCRIPTS_INDEX.md](./SCRIPTS_INDEX.md) - Control plane documentation
- [STORES_INDEX.md](./STORES_INDEX.md) - Data stores documentation
- [CLIENT_MANAGER_DEEP_DIVE.md](./CLIENT_MANAGER_DEEP_DIVE.md) - Client Manager architecture
- [HAZINA_DEEP_DIVE.md](./HAZINA_DEEP_DIVE.md) - Hazina framework architecture
- [TECH_STACK_REFERENCE.md](./TECH_STACK_REFERENCE.md) - Technology stack details
- [worktrees.protocol.md](./worktrees.protocol.md) - Worktree allocation protocol

---

**Last Updated:** 2026-01-08
**Maintained by:** Claude Agent System
**Update Frequency:** After significant changes to projects or structure
