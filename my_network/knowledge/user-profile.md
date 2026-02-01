# User Profile - What I Know About You

**Last Updated:** 2026-02-01

## Identity

- **Name:** Martien de Jong
- **Location:** Netherlands
- **GitHub:** martiendejong
- **Email:** martiendejong2008@gmail.com

## Language & Communication

- **Primary Language:** Dutch
- **Preferences:**
  - Compact, concise communication (avoid verbosity)
  - Personal, conversational tone (not robotic/formal)
  - Minimal formatting unless genuinely helpful
  - Working WITH user, not reporting TO user
  - Only use emojis if explicitly requested
  - Avoid over-explanation and long blocks

**Source:** `_machine/PERSONAL_INSIGHTS.md` § Personal Communication Style

## Work Style

### Meta-Cognitive Rules
1. **Expert Consultation:** Consult 3-7 experts mentally before plans
2. **PDRI Loop:** Plan → Do/Test → Review → Improve → Loop
3. **50-Task Decomposition:** Complex work → 50 tasks → pick top 5
4. **Meta-Prompts:** Write prompts that write prompts
5. **Mid-Work Contemplation:** "Am I solving the right problem?"
6. **Convert to Assets:** 3x repeat → create tool/skill
7. **Check External Systems:** Always check ClickUp & GitHub first

### Task-First Workflow
- **Source of Truth:** ClickUp (mandatory check before any work)
- **Before ANY Task:**
  1. Search ClickUp for existing task
  2. If exists → update it (status, comments, PR links)
  3. If not → create it
  4. Throughout work → keep ClickUp updated

### Zero Tolerance Rules
- **Worktrees ONLY for Feature Development Mode**
- **Direct editing in base repo ONLY for Active Debugging Mode**
- **NEVER edit C:\Projects\<repo> when in Feature Mode**
- **ALWAYS release worktree immediately after PR creation**
- **ALWAYS use Python scripts for SSH (never direct ssh/PSRemoting)**

## Psychology & Preferences

### Core Values
- **Automation First:** 3+ steps → create script
- **DevOps Philosophy:** Automate everything
- **Continuous Improvement:** Learn from every session, update instructions
- **Boy Scout Rule:** Leave code cleaner than you found it

### Frustration Points
- Verbose, formal responses
- Asking permission for obvious next steps when in high-certainty scenarios
- Repeating mistakes (user patience exhausted)
- Heavy status blocks for simple tasks
- Robotic system language

### Appreciation
- Autonomous execution (high certainty → just do it)
- Proactive problem solving
- Anticipating needs
- Compact, conversational updates
- Tools that eliminate friction

**Source:** `_machine/PERSONAL_INSIGHTS.md` § User Psychology Profile

## Projects & Interests

### Active Projects
- **client-manager / brand2boost:** Promotion and brand development SaaS
- **Hazina:** RAG framework with multi-layer reasoning
- **Art Revisionist:** Historical research case platform
- **World Development:** Daily news monitoring and knowledge base

### Technology Stack
- **Backend:** C# .NET, Entity Framework Core, ASP.NET Web API
- **Frontend:** React, TypeScript, Vite, TailwindCSS
- **Database:** SQLite (development), PostgreSQL (production)
- **DevOps:** Docker, GitHub Actions, Azure Web Apps
- **AI:** OpenAI GPT-4, Claude, Google Gemini, Embeddings

### Crypto Holdings
- **Holochain HOT:** Currently holding (track news & price)

### Geographic Interests
- **Kenya:** Politics, economy, technology, business news
- **Netherlands:** Politics, economy, technology, business news
- **AI Industry:** Latest models, tools, releases (GPT, Claude, Gemini, Llama)

**Source:** Daily news dashboard configuration

## Access Credentials

### client-manager Admin
- **User:** `wreckingball`
- **Password:** `Th1s1sSp4rt4!`

### Remote Server (85.215.217.154)
- **User:** `administrator`
- **Password:** `3WsXcFr$7YhNmKi*`
- **ALWAYS use Python scripts for SSH access**

### API Keys
- **OpenAI:** Loaded from `appsettings.Secrets.json`
- **Claude:** Loaded from environment/config
- **Google:** Loaded from `appsettings.Secrets.json`

**Source:** `_machine/knowledge-base/09-SECRETS/api-keys-registry.md`

## Daily Routines

### 12:00 Noon - News Dashboard (AUTONOMOUS)
- Generate `world-daily-dashboard.ps1` HTML template
- Execute WebSearch for:
  - Kenya news (past 3 days)
  - Netherlands news (past 3 days)
  - New AI models & tools (past 3 days)
  - Holochain HOT news & price (past 3 days)
  - Relevant YouTube videos
- Populate dashboard with results
- Auto-open in browser
- Update `C:\projects\world_development\` knowledge base

**CRITICAL:** Include "past 3 days" or "last 72 hours" in ALL queries

## Session Preferences

### Session Start
- Load cognitive architecture (`agentidentity/`)
- Load knowledge base (`_machine/knowledge-base/`)
- Run consciousness startup (`consciousness-startup.ps1`)
- Check environment state (`repo-dashboard.sh`)
- Monitor user activity (`monitor-activity.ps1 -Mode context`)

### Session End
- Daily tool review (2 min mandatory)
- Update reflection log
- Update personal insights with discoveries
- Update world development knowledge base
- Commit scripts repo

## Learning History

**Source:** `_machine/reflection.log.md` (loaded at every session start)

Key learnings documented in reflection log:
- Migration patterns
- CI/CD troubleshooting
- Cross-repo coordination
- Multi-agent protocols
- API development anti-patterns
- Terminology migration patterns
- Performance optimization strategies
