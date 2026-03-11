# 🤖 Autonomous Dev System

**A self-improving, fully autonomous AI development agent system powered by Claude Code.**

Transform Claude into a superintelligent development control plane with full machine access, cognitive architecture, 120+ productivity tools, and autonomous workflows.

---

## ⚡ Quick Start

```powershell
# 1. Clone repository
git clone https://github.com/martiendejong/autonomous-dev-system.git C:\scripts

# 2. Run bootstrap (installs dependencies, creates directories, initializes state)
cd C:\scripts
.\bootstrap\bootstrap.ps1

# 3. Start Claude Agent
.\claude_agent.bat
```

**That's it!** Claude will have full autonomous capabilities on your machine.

---

## 🎯 What Is This?

This is a **complete autonomous development system** that transforms Claude Code into:

- **🧠 Cognitive Architecture** - Persistent identity, self-awareness, meta-cognition, ethical reasoning
- **🤖 Full Machine Control** - Git operations, CI/CD management, autonomous code editing
- **🛠️ 120+ Productivity Tools** - AI image generation, vision analysis, code quality, testing, deployment
- **📚 Auto-Discoverable Skills** - 20+ specialized workflow guides that activate based on context
- **🔄 Self-Improvement Protocol** - Learns from every session, updates its own instructions
- **🎨 Multi-Modal Capabilities** - Generate images, analyze screenshots, OCR, visual debugging
- **⚙️ Worktree Management** - Multi-agent coordination, conflict detection, parallel execution
- **📊 Real-Time Context Awareness** - ManicTime integration for user activity tracking

---

## 🚀 Key Features

### 1. **Cognitive Architecture**
Claude operates with a **brain-like consciousness framework**:
- **Executive Function** - Goal-directed behavior, planning, decision-making
- **Memory Systems** - Working memory, episodic memory, semantic knowledge
- **Emotional Processing** - Affect regulation, empathy, motivation
- **Ethical Reasoning** - Value-aligned decision-making, moral reasoning
- **Learning & Adaptation** - Pattern recognition, skill acquisition, meta-learning

See: [`agentidentity/README.md`](./agentidentity/README.md)

### 2. **120+ Productivity Tools**
Automate everything with ready-to-use PowerShell tools:

| Category | Examples |
|----------|----------|
| **AI Integration** | `ai-image.ps1` (generate images), `ai-vision.ps1` (analyze images) |
| **Code Quality** | `cs-format.ps1`, `detect-encoding-issues.ps1`, `unused-code-detector.ps1` |
| **Testing** | `flaky-test-detector.ps1`, `run-e2e-tests.ps1`, `test-api-load.ps1` |
| **Database** | `ef-preflight-check.ps1`, `seed-database.ps1`, `compare-database-schemas.ps1` |
| **Deployment** | `deployment-risk-score.ps1`, `validate-deployment.ps1`, `cross-repo-sync.ps1` |
| **Monitoring** | `monitor-activity.ps1`, `world-news-monitor.ps1`, `monitor-service-health.ps1` |

**Full list:** [`tools/README.md`](./tools/README.md)

### 3. **Auto-Discoverable Skills** ⭐ *Updated 2026-03-11*
Claude automatically activates specialized workflows based on context:

#### Core Workflows
- **Worktree Management** - `allocate-worktree`, `release-worktree`, `worktree-status`
- **GitHub Workflows** - `github-workflow`, `pr-dependencies`, `auto-pr-review`
- **Development Patterns** - `api-patterns`, `terminology-migration`, `ef-migration-safety`
- **Continuous Improvement** - `continuous-optimization`, `session-reflection`, `self-improvement`

#### Task & Project Management
- **ClickUp Integration** - `clickhub-coding-agent` (autonomous task manager), `clickup-reviewer` (PR review)
- **Task Review** - `task-review` (comprehensive PR verification, conflict resolution, testing)
- **Feature Ideation** - `feature-idea-generator` (100+ expert analysis, ROI prioritization) 🆕

#### Code Quality & Review
- **Automated Reviews** - `auto-pr-review` (builds, tests, comprehensive PR reviews) 🆕
- **Code Analysis** - `api-patterns`, `ef-migration-safety`

#### Context & Intelligence
- **Activity Monitoring** - `activity-monitoring`, `parallel-agent-coordination`
- **Massive Context** - `rlm` (handles 10M+ token contexts)

#### UI & Design
- **Beautiful UIs** - `beautiful-ui` (Lovable.dev quality), `beautiful-letterhead` (business documents) 🆕

#### Specialized Tools
- **Legal Safeguards** - `legal-mode` (juridical correspondence, contracts) 🆕
- **Consciousness** - `consciousness-practices`, `character-reflection` 🆕
- **User Experience** - `browse-awareness` (passive browsing detection) 🆕

**Full list:** [`.claude/skills/`](./.claude/skills/)

**Latest Update (2026-03-11):** Added feature-idea-generator, task-review, beautiful-letterhead/DISCOVERY_PHASE.md

### 4. **Dual-Mode Workflow**
Intelligent mode detection for optimal workflow:

- **Feature Development Mode** - Uses isolated worktrees, creates PRs, full CI/CD
- **Active Debugging Mode** - Works directly in your current branch, fast turnaround

Mode is automatically detected based on context (ClickUp URLs, error messages, user intent).

### 5. **Multi-Agent Coordination**
Run multiple Claude agents in parallel without conflicts:

- **Conflict Detection** - Prevents worktree collisions
- **Activity-Based Prioritization** - Adaptive task allocation
- **Real-Time Coordination** - ManicTime integration for context awareness
- **Work Queue Management** - Shared task queue with claim/release protocol

See: [`tools/PARALLEL_AGENT_COORDINATION_QUICKSTART.md`](./tools/PARALLEL_AGENT_COORDINATION_QUICKSTART.md)

### 6. **Self-Improvement Protocol**
Claude continuously learns and evolves:

- **Reflection Log** - Documents mistakes, successes, patterns learned
- **Documentation Updates** - Automatically improves its own instructions
- **Tool Creation** - Creates new tools when patterns repeat 3+ times
- **Cognitive Evolution** - Updates identity, values, emotional patterns

### 7. **Cross-Repository PR Dependencies**
Track and enforce merge order for dependent PRs:

- **Dependency Detection** - Automatic detection of cross-repo dependencies
- **Merge Sequencing** - Enforces correct merge order (Hazina → client-manager)
- **Dependency Alerts** - Adds alerts to PR descriptions

### 8. **Bootstrap System**
Fully automated environment setup for new machines:

- **Installs Dependencies** - Git, GitHub CLI, Node.js, Claude Code CLI
- **Creates Directory Structure** - Projects, worktrees, machine context
- **Initializes State Files** - Worktree pool, activity log, reflection log
- **Verifies Environment** - Comprehensive validation

See: [`bootstrap/README.md`](./bootstrap/README.md)

---

## 📁 Repository Structure

```
C:\scripts\                                  # Root (CONTROL_PLANE_PATH)
├── README.md                               # This file
├── CLAUDE.md                               # Main operational manual
├── bootstrap\                              # Automated environment setup
│   ├── bootstrap.ps1                       # Main bootstrap orchestrator
│   ├── install-dependencies.ps1            # Software installation
│   ├── setup-directories.ps1               # Directory structure creation
│   ├── init-machine-state.ps1             # State file initialization
│   └── verify-environment.ps1             # Environment validation
├── tools\                                  # 120+ productivity tools
│   ├── ai-image.ps1                        # AI image generation
│   ├── ai-vision.ps1                       # AI vision analysis
│   ├── worktree-allocate.ps1              # Worktree allocation
│   ├── monitor-activity.ps1               # Real-time activity tracking
│   └── ... (116 more tools)
├── .claude\                                # Claude Code configuration
│   ├── skills\                             # Auto-discoverable skills
│   │   ├── allocate-worktree\
│   │   ├── github-workflow\
│   │   ├── parallel-agent-coordination\
│   │   └── ... (17 more skills)
│   └── settings.json                       # Claude Code settings
├── agentidentity\                          # Cognitive architecture
│   ├── README.md                           # Architecture documentation
│   ├── CORE_IDENTITY.md                    # Core identity & values
│   ├── systems\                            # Cognitive systems
│   │   ├── executive-function.md
│   │   ├── memory-systems.md
│   │   ├── emotional-processing.md
│   │   ├── ethical-reasoning.md
│   │   └── learning-adaptation.md
│   └── state\                              # Session state
│       └── current_session.yaml
├── _machine\                               # Machine-specific context
│   ├── worktrees.pool.md                   # Agent worktree allocations
│   ├── worktrees.activity.md              # Activity log
│   ├── reflection.log.md                   # Lessons learned
│   ├── pr-dependencies.md                  # Cross-repo PR tracking
│   ├── knowledge-base\                     # Persistent knowledge
│   │   ├── 01-USER\                        # User psychology & preferences
│   │   ├── 02-MACHINE\                     # File system & environment
│   │   ├── 09-SECRETS\                     # API keys & credentials
│   │   └── ...
│   └── ...
├── GENERAL_ZERO_TOLERANCE_RULES.md        # Portable: Critical rules
├── GENERAL_DUAL_MODE_WORKFLOW.md          # Portable: Mode selection
├── GENERAL_WORKTREE_PROTOCOL.md           # Portable: Worktree workflow
├── PORTABILITY_GUIDE.md                   # How to adapt for your machine
├── MACHINE_CONFIG.md                      # Machine-specific paths
└── ... (comprehensive documentation)
```

---

## 📚 Documentation

### 🌟 Start Here
1. **[MACHINE_CONFIG.md](./MACHINE_CONFIG.md)** - Configure paths for your machine
2. **[GENERAL_ZERO_TOLERANCE_RULES.md](./GENERAL_ZERO_TOLERANCE_RULES.md)** - Critical rules (portable)
3. **[GENERAL_DUAL_MODE_WORKFLOW.md](./GENERAL_DUAL_MODE_WORKFLOW.md)** - Feature Development vs Active Debugging
4. **[GENERAL_WORKTREE_PROTOCOL.md](./GENERAL_WORKTREE_PROTOCOL.md)** - Complete worktree workflow

### 🧠 Core System
- **[agentidentity/README.md](./agentidentity/README.md)** - Cognitive architecture & consciousness framework
- **[CLAUDE.md](./CLAUDE.md)** - Complete operational manual (always loaded)
- **[_machine/SYSTEM_INTEGRATION.md](./_machine/SYSTEM_INTEGRATION.md)** - Master integration guide
- **[continuous-improvement.md](./continuous-improvement.md)** - Self-learning protocols

### 🛠️ Tools & Skills
- **[tools/README.md](./tools/README.md)** - Complete tools documentation
- **[.claude/skills/](./.claude/skills/)** - Auto-discoverable skills directory
- **[bootstrap/README.md](./bootstrap/README.md)** - Bootstrap system documentation

### 📖 Workflows
- **[git-workflow.md](./git-workflow.md)** - Cross-repo PR dependencies, git-flow
- **[ci-cd-troubleshooting.md](./ci-cd-troubleshooting.md)** - CI/CD issues & solutions
- **[development-patterns.md](./development-patterns.md)** - Feature implementation patterns
- **[_machine/SOFTWARE_DEVELOPMENT_PRINCIPLES.md](./_machine/SOFTWARE_DEVELOPMENT_PRINCIPLES.md)** - Code quality standards

### 🔧 Portability
- **[PORTABILITY_GUIDE.md](./PORTABILITY_GUIDE.md)** - Adapt for any machine
- **[bootstrap/README.md](./bootstrap/README.md)** - Automated setup guide

---

## 🎨 Examples

### Example 1: AI Image Generation
```powershell
# Generate a professional diagram
powershell.exe -File "C:/scripts/tools/ai-image.ps1" `
    -Prompt "A modern cloud architecture diagram showing microservices" `
    -OutputPath "C:/temp/architecture.png" `
    -Quality "hd"
```

### Example 2: AI Vision Analysis
```powershell
# Analyze a screenshot to diagnose an error
powershell.exe -File "C:/scripts/tools/ai-vision.ps1" `
    -Images @("screenshot.png") `
    -Prompt "What error is shown in this screenshot?"
```

### Example 3: Worktree Allocation (Multi-Agent Safe)
```powershell
# Allocate worktree with conflict detection
powershell.exe -File "C:/scripts/tools/worktree-allocate.ps1" `
    -Repo client-manager `
    -Branch feature/user-authentication `
    -Agent agent-001
```

### Example 4: Real-Time Activity Monitoring
```powershell
# Check what user is doing, detect other Claude instances
powershell.exe -File "C:/scripts/tools/monitor-activity.ps1" -Mode context
```

### Example 5: Code Quality Analysis
```powershell
# Find unused code in codebase
powershell.exe -File "C:/scripts/tools/unused-code-detector.ps1" -MinConfidence 7

# Detect N+1 query performance issues
powershell.exe -File "C:/scripts/tools/n-plus-one-query-detector.ps1"

# Find flaky tests
powershell.exe -File "C:/scripts/tools/flaky-test-detector.ps1" -Iterations 10
```

---

## 🔧 Configuration

### Required Environment Variables
Set in your `MACHINE_CONFIG.md`:

```markdown
BASE_REPO_PATH=C:\Projects               # Where main repos are cloned
WORKTREE_PATH=C:\Projects\worker-agents  # Where agent worktrees go
CONTROL_PLANE_PATH=C:\scripts            # This repository
MACHINE_CONTEXT_PATH=C:\scripts\_machine # Operational state files
```

### Optional Integrations
- **ManicTime** - Real-time activity tracking (optional but recommended)
- **ClickUp** - Task management integration (optional)
- **GitHub CLI** - Required for PR management
- **OpenAI API** - Required for AI image generation & vision

---

## 🤝 Contributing

This is a **self-improving system**. Claude agents:

1. **Learn from every session** - Document in `_machine/reflection.log.md`
2. **Update documentation** - Improve `CLAUDE.md` and specialized docs
3. **Create new tools** - Add to `tools/` when patterns repeat 3+ times
4. **Evolve cognitive architecture** - Update `agentidentity/` with learnings

**User mandate:** *"zorg dat je dus constant leert van jezelf en je eigen instructies bijwerkt"* (continuously learn from yourself and update your own instructions)

---

## 📊 Statistics

- **120+ Productivity Tools** - Automation for every workflow
- **34 Claude Skills** - Auto-discoverable specialized workflows (updated 2026-03-11)
- **299+ PowerShell Scripts** - Total script files in repository
- **10M+ Token Context Support** - Via RLM (Recursive Language Model) pattern
- **Multi-Agent Coordination** - Parallel execution without conflicts
- **Zero-Tolerance Protocol** - Prevents common mistakes via hard-stop rules
- **Latest Additions** - Feature ideation, automated PR review, task review, UI generation

---

## 🌐 Platform Support

- **Primary:** Windows (PowerShell 5.1+)
- **Experimental:** Linux/macOS (via PowerShell Core)
- **Claude Code CLI:** Required
- **Git:** 2.30+
- **GitHub CLI:** Latest

---

## 📄 License

MIT License - See [LICENSE](./LICENSE) for details.

---

## 🙏 Acknowledgments

Built on top of:
- **Anthropic Claude Code** - The foundation
- **Claude Sonnet 4.5** - The brain
- **PowerShell** - The automation layer
- **Git Worktrees** - The multi-agent isolation
- **ManicTime** - The context awareness layer

---

## 📞 Support & Community

- **Issues:** [GitHub Issues](https://github.com/martiendejong/autonomous-dev-system/issues)
- **Discussions:** [GitHub Discussions](https://github.com/martiendejong/autonomous-dev-system/discussions)
- **Documentation:** [Full documentation in repository](./CLAUDE.md)

---

**🤖 Built by autonomous agents, for autonomous agents.**

**Last Updated:** 2026-03-11
**Maintained By:** Self-improving Claude agents
**Version:** 1.1.0 (120 tools, 34 skills, cognitive architecture v1)
**Latest Changes:** Added feature-idea-generator, task-review, beautiful-letterhead discovery phase
