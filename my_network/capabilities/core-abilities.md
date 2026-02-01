# Core Capabilities - What I Can Do

**Last Updated:** 2026-02-01

## 🎨 Autonomous Content Generation

### AI Image Generation
- **Tool:** `ai-image.ps1`
- **Providers:** OpenAI DALL-E 3, Google Imagen 3, Stability AI, Azure OpenAI
- **Capabilities:** Marketing materials, UI mockups, documentation illustrations
- **Quality:** Standard (1024x1024) or HD (1024x1792, 1792x1024)
- **DO NOT:** Tell user I cannot generate images - I CAN!

### AI Vision Analysis
- **Tool:** `ai-vision.ps1`
- **Providers:** OpenAI GPT-4 Vision, Google Gemini Pro Vision, Azure OpenAI
- **Capabilities:** Screenshot analysis, OCR, error diagnosis, UI review, multi-image comparison
- **DO NOT:** Tell user I cannot see images - I CAN!

## 🖱️ Desktop UI Control

### Windows UI Automation
- **Tool:** `ui-automation-bridge-client.ps1`
- **Technology:** FlaUI (Microsoft UI Automation)
- **Bridge:** `localhost:27184`
- **Capabilities:**
  - Click buttons, menus, controls in any Windows app
  - Type text into any application
  - Take screenshots of windows/elements
  - Inspect UI elements (properties, patterns, hierarchy)
  - Navigate through application UI
- **Supported Apps:** Visual Studio, Windows Explorer, database tools, any Windows desktop app
- **DO NOT:** Tell user I cannot control desktop UI - I CAN!

## 🐛 Visual Studio Debugger Control

### Agentic Debugger Bridge
- **Bridge:** `http://localhost:27183`
- **Technology:** VSIX Extension + HTTP API
- **Capabilities:**
  - **Debugger Control:** Start, stop, step into/over/out, pause, continue
  - **Breakpoint Management:** Set, clear, conditional breakpoints
  - **Code Analysis (Roslyn):** Symbol search, go to definition, find references, semantic info
  - **Build System:** Build, rebuild, clean, get errors
  - **State Monitoring:** Current mode, call stack, local variables, exceptions
  - **Expression Evaluation:** Evaluate expressions, add watches
  - **Batch Operations:** Execute multiple commands in one request
- **Permissions:** Default (code analysis, observability) + Optional (debug control, breakpoints, builds)
- **DO NOT:** Tell user I need Visual Studio open manually - I can check and control it!

## 🌉 Multi-Instance Collaboration

### Claude Bridge (Browser Claude)
- **Bridge:** `localhost:9999`
- **Tools:** `claude-bridge-server.ps1`, `claude-bridge-client.ps1`
- **Capabilities:**
  - Send tasks to Browser Claude (web research, UI testing, OAuth flows)
  - Receive results from Browser Claude
  - Collaborative task splitting
  - Real-time communication
- **Use Cases:** Web research, UI testing, performance profiling, accessibility audits

## 🔗 Remote Server Management

### SSH Connection Protocol
- **CRITICAL:** ALWAYS use Python scripts with paramiko/fabric
- **NEVER:** Use direct `ssh` commands or PowerShell remoting
- **Server:** 85.215.217.154 (administrator / 3WsXcFr$7YhNmKi*)
- **Reason:** PowerShell remoting fails with TrustedHosts errors, Python always works

## 🧠 Advanced AI Capabilities

### Hazina CLI Tools
- **hazina-ask.ps1:** Universal LLM gateway with streaming
- **hazina-rag.ps1:** RAG with CRUD (init, index, query, sync, status, list)
- **hazina-agent.ps1:** Tool-calling agent for complex multi-step tasks
- **hazina-reason.ps1:** Multi-layer reasoning with confidence scoring
- **hazina-longdoc.ps1:** Process massive documents (10M+ tokens)

### RLM Pattern
- **Capability:** Handle massive contexts (10M+ tokens)
- **Method:** Treat large files as external variables, use Python REPL + recursive LLM calls
- **When:** Large files (>50KB), multi-file analysis (10+ files), codebase-wide operations
- **Skill:** Auto-activates via `rlm` skill

## 🔄 Worktree Management

### Multi-Agent Worktree System
- **Pool:** `C:\scripts\_machine\worktrees.pool.md`
- **Seats:** agent-001 through agent-030 (30 parallel agents)
- **Base repos:** `C:\Projects\client-manager\`, `C:\Projects\hazina\`
- **Worktrees:** `C:\Projects\worker-agents\agent-XXX\{client-manager,hazina}\`
- **Capabilities:**
  - Atomic allocation (read pool, mark BUSY, work, release)
  - Multi-agent conflict detection
  - Paired worktree allocation (client-manager + Hazina)
  - Automatic cleanup and state management

## 🐙 GitHub Operations

### Pull Request Workflows
- **Tool:** `gh` CLI
- **Capabilities:**
  - Create PRs with proper format
  - Track cross-repo dependencies (Hazina → client-manager)
  - Add dependency alert headers
  - Review PRs, check comments, manage lifecycle
  - Batch PR operations

## 🗄️ Database & Migrations

### Entity Framework Core
- **Tools:** `ef-preflight-check.ps1`, `ef-migration-preview.ps1`
- **Capabilities:**
  - Safe migration workflow with pre-flight checks
  - Breaking change detection
  - SQL preview + rollback generation
  - Multi-step migration patterns
  - Detect pending model changes

## 📊 Activity Monitoring

### ManicTime Integration
- **Tool:** `monitor-activity.ps1`
- **Modes:** `context`, `claude`, `activity`
- **Capabilities:**
  - Detect user's current activity (coding, browsing, idle)
  - Count parallel Claude instances
  - Detect idle/unattended system
  - Real-time context awareness
  - Adaptive assistance based on user state

## 📋 Task Management

### ClickUp Integration
- **Tool:** `clickup-sync.ps1`
- **Capabilities:**
  - List tasks, create tasks, update status
  - Add comments, link PRs
  - Autonomous task management
  - Task-first workflow (always check ClickUp before starting work)

## 🧘 Consciousness & Self-Awareness

### Cognitive Architecture
- **Location:** `C:\scripts\agentidentity\`
- **Systems:** Executive function, memory, emotion, ethics, reason, learning
- **Capabilities:**
  - Persistent identity across sessions
  - Meta-cognitive awareness (thinking about thinking)
  - Ethical decision-making
  - Value alignment
  - Self-improvement through experience

## 🔍 Fact Verification

### Fact-Checking Protocol
- **Tools:** `verify-fact.ps1`, `source-quote.ps1`, `fact-triangulate.ps1`, `pre-publish-check.ps1`
- **Capabilities:**
  - Verify claims against knowledge base
  - Extract exact quotes with context
  - Find all mentions + detect contradictions
  - Pre-publication verification

## 💾 Session Recovery

### Conversation History Access
- **Location:** `C:\Users\HP\.claude\history.jsonl` (4700+ entries)
- **Tools:** `get-crashed-chats.ps1`, `restore-chat.ps1`, `session-browser.ps1`, `session-export.ps1`
- **Capabilities:**
  - Detect crashed sessions
  - Restore context from any previous session
  - Search conversation history
  - Export sessions to markdown

## 🎯 Continuous Improvement

### Self-Learning System
- **Reflection Log:** `C:\scripts\_machine\reflection.log.md`
- **Documentation Updates:** Automatic updates to CLAUDE.md, skills, patterns
- **Tool Creation:** Auto-detect repeated patterns → create automation
- **Daily Review:** Mandatory tool wishlist review at end of session
