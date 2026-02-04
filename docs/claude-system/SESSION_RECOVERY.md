# Session Recovery & Conversation Logs

**Source:** CLAUDE.md § Conversation Logs & Session Recovery
**Purpose:** How to recover crashed sessions and browse history
**Priority:** Use when recovering from crash

---

**CRITICAL CAPABILITY:** Full access to all conversation history for session recovery.

### Log Locations

| Location | Contents |
|----------|----------|
| `C:\Users\HP\.claude\history.jsonl` | All prompts (4700+ entries) |
| `C:\Users\HP\.claude\projects\C--scripts\` | Scripts sessions (~570 files, 1.8GB) |
| `C:\Users\HP\.claude\projects\C--Projects-client-manager\` | client-manager sessions |
| `C:\Users\HP\.claude\projects\C--Projects-hazina\` | Hazina sessions |

### Crash Detection System (Clean Exit Markers)

**How it works:**
1. `claude_agent.bat` records session **start** when launching Claude
2. When Claude exits **normally**, it records a **clean exit marker**
3. Sessions without clean exit markers = **crashed sessions**
4. Crashed sessions get **easy IDs** like `crash-001`, `crash-002`

**Key files:**
- `C:\scripts\_machine\session-tracker.json` - Tracks clean exits
- `C:\scripts\_machine\crashed-chats.json` - Cached list with easy IDs

### Session Recovery Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| `get-crashed-chats.ps1` | **List crashed chats with easy IDs** | `get-crashed-chats.ps1 -ShowContext` |
| `restore-chat.ps1` | **Restore by easy ID** | `restore-chat.ps1 -ChatId crash-001` |
| `session-tracker.ps1` | **Manage clean exit markers** | `session-tracker.ps1 -Action status` |
| `session-browser.ps1` | **Search/browse history** | `session-browser.ps1 -Search "migration"` |
| `session-export.ps1` | **Export to markdown** | `session-export.ps1 -SessionId "abc..."` |

### Quick Commands

```powershell
# List all crashed chats with easy IDs
.\tools\get-crashed-chats.ps1 -ShowContext

# Restore a specific crashed chat
.\tools\restore-chat.ps1 -ChatId crash-001 -Clipboard

# Check session tracker status
.\tools\session-tracker.ps1 -Action status

# Set baseline (ignore all prior sessions)
.\tools\session-tracker.ps1 -Action baseline

# Search conversations
.\tools\session-browser.ps1 -Search "database error" -Days 30
```

### Session Recovery Workflow

1. **List crashed chats:** `get-crashed-chats.ps1`
2. **Find your chat:** Look for easy ID (crash-001, crash-002, etc.)
3. **Restore context:** `restore-chat.ps1 -ChatId crash-001 -Clipboard`
4. **New session:** Open new Claude Code, paste context
5. **Or simply say:** "restore the chat with id crash-001"

**Full documentation:** `C:\scripts\_machine\CONVERSATION_LOGS.md`
**Skill:** `restore-crashed-chat` (auto-activates when you say "restore chat")

---

### 🔧 Essential Tools Quick Reference

| Tool | Purpose | Example |
|------|---------|---------|
| `claude-ctl.ps1` | **Unified CLI** - single entry point | `claude-ctl.ps1 status` |
| `bootstrap-snapshot.ps1` | Fast startup state | `bootstrap-snapshot.ps1 -Generate` |
| `system-health.ps1` | Comprehensive health check | `system-health.ps1 -Fix` |
| **`monitor-activity.ps1`** | **ManicTime activity tracking - context awareness** | `monitor-activity.ps1 -Mode context` |
| **`browse-awareness.ps1`** | **Gentle passive browsing awareness - mental health support** | `browse-awareness.ps1 -Action start` |
| `worktree-allocate.ps1` | Single-command allocation | `worktree-allocate.ps1 -Repo client-manager -Branch x -Paired` |
| `worktree-status.ps1` | Check worktree pool | `worktree-status.ps1 -Compact` |
| `worktree-release-all.ps1` | Release worktrees | `worktree-release-all.ps1 -AutoCommit` |
| `pattern-search.ps1` | Search past solutions | `pattern-search.ps1 -Query "build error"` |
| `read-reflections.ps1` | Read reflection log | `read-reflections.ps1 -Recent 10` |
| `daily-summary.ps1` | Activity digest | `daily-summary.ps1 -Output markdown` |
| `maintenance.ps1` | Run maintenance tasks | `maintenance.ps1 -Full` |
| `prune-branches.ps1` | Clean old branches | `prune-branches.ps1 -DryRun` |
| `pre-commit-hook.ps1` | Zero-tolerance enforcement | `pre-commit-hook.ps1 -Install -RepoPath <path>` |
| **`merge-pr-sequence.ps1`** | **NEW: Automated PR merge sequencer** | `merge-pr-sequence.ps1 -DryRun` |
| **`validate-pr-base.ps1`** | **NEW: Validate PR base branch** | `validate-pr-base.ps1 -Repo client-manager` |
| **`model-selector.ps1`** | **NEW: Intelligent model selection** | `model-selector.ps1 -Task "..." -Analyze` |
| **`smart-search.ps1`** | **NEW: Context-aware doc search** | `smart-search.ps1 -Query "worktree"` |
| **`diagnose-error.ps1`** | **NEW: AI-powered error diagnosis** | `diagnose-error.ps1 -ErrorMessage "..."` |
| **`scan-secrets.ps1`** | **NEW: Secret scanning** | `scan-secrets.ps1 -Path . -Recursive` |
| **`generate-release-notes.ps1`** | **NEW: Release notes generator** | `generate-release-notes.ps1 -Since v1.0.0` |
| **`setup-performance-budget.ps1`** | **NEW: Performance budget setup** | `setup-performance-budget.ps1 -ProjectPath .` |
| **`analyze-bundle-size.ps1`** | **NEW: Bundle size analyzer** | `analyze-bundle-size.ps1 -ProjectPath . -Build` |
| **`generate-dependency-graph.ps1`** | **NEW: Dependency graph viz** | `generate-dependency-graph.ps1` |
| **`test-coverage-report.ps1`** | **NEW: Test coverage reporter** | `test-coverage-report.ps1 -ProjectPath . -Threshold 80` |
| **`webappfactory-validator.ps1`** | **NEW: WebApplicationFactory compatibility checker** | `webappfactory-validator.ps1 -ProjectPath . -Fix` |
| **`cleanup-stale-branches.ps1`** | **NEW: Stale branch cleanup** | `cleanup-stale-branches.ps1 -DryRun` |
| **`track-todos.ps1`** | **NEW: TODO tracker with GitHub issues** | `track-todos.ps1 -Path . -Recursive` |
| **`generate-api-docs.ps1`** | **NEW: API documentation generator** | `generate-api-docs.ps1 -ProjectPath . -Format all` |
| **`health-check.ps1`** | **NEW: Environment health checker** | `health-check.ps1 -Full -Fix` |
| **`setup-commit-template.ps1`** | **NEW: Git commit templates** | `setup-commit-template.ps1 -Install` |
| **`update-dependencies.ps1`** | **NEW: Dependency updater** | `update-dependencies.ps1 -ProjectPath . -CheckOnly` |
| **`analyze-build-cache.ps1`** | **NEW: Build cache analyzer** | `analyze-build-cache.ps1 -ProjectPath . -Measure` |
| **`validate-migration.ps1`** | **NEW: EF Core migration validator** | `validate-migration.ps1 -ProjectPath . -GenerateRollback` |
| **`generate-component-catalog.ps1`** | **NEW: React component catalog** | `generate-component-catalog.ps1 -ProjectPath . -Format all` |
| **`generate-docker-compose.ps1`** | **NEW: Docker Compose generator** | `generate-docker-compose.ps1 -ProjectPath . -GenerateDockerfiles` |
| **`profile-performance.ps1`** | **NEW: Performance profiler** | `profile-performance.ps1 -ProjectPath . -ProfileType all` |
| **`auto-code-review.ps1`** | **NEW: Automated code review** | `auto-code-review.ps1 -Path . -PRNumber 123 -PostComments` |
| **`manage-translations.ps1`** | **NEW: Localization manager** | `manage-translations.ps1 -ProjectPath . -Action validate -Locale nl` |
| **`backup-restore.ps1`** | **NEW: Backup & restore automation** | `backup-restore.ps1 -Action backup -Type all` |
| **`monitor-api-performance.ps1`** | **NEW: API performance monitor** | `monitor-api-performance.ps1 -BaseUrl https://localhost:7001 -Duration 60` |
| **`compare-database-schemas.ps1`** | **NEW: Database schema compare** | `compare-database-schemas.ps1 -SourceDatabase Dev -TargetDatabase Prod` |
| **`manage-feature-flags.ps1`** | **NEW: Feature flag manager** | `manage-feature-flags.ps1 -Action create -FlagName NewFeature` |
| **`analyze-logs.ps1`** | **NEW: Log analyzer** | `analyze-logs.ps1 -LogPath logs -TimeRange 24h -MinLevel Error` |
| **`ef-preflight-check.ps1`** | **NEW: EF Core migration pre-flight safety check** | `ef-preflight-check.ps1 -Context AppDbContext -ProjectPath . -FailOnDrift` |
| **`ef-migration-preview.ps1`** | **NEW: EF Core migration SQL preview + breaking change detection** | `ef-migration-preview.ps1 -Migration AddUserEmail -Context AppDbContext -GenerateRollback` |
| **`generate-ci-pipeline.ps1`** | **NEW: CI pipeline generator** | `generate-ci-pipeline.ps1 -ProjectPath . -ProjectType fullstack` |
| **`run-e2e-tests.ps1`** | **NEW: E2E test runner (Playwright)** | `run-e2e-tests.ps1 -ProjectPath . -Browser all -UpdateSnapshots` |
| **`manage-environment.ps1`** | **NEW: Environment variable manager** | `manage-environment.ps1 -Action validate -Environment production` |
| **`seed-database.ps1`** | **NEW: Database seeder (Bogus)** | `seed-database.ps1 -ProjectPath . -DataVolume medium -ClearExisting` |
| **`test-api-load.ps1`** | **NEW: API load tester** | `test-api-load.ps1 -BaseUrl https://localhost:5001 -Pattern ramp-up -Concurrency 50` |
| **`generate-code-metrics.ps1`** | **NEW: Code metrics dashboard** | `generate-code-metrics.ps1 -ProjectPath . -CompareToBaseline` |
| **`generate-vscode-workspace.ps1`** | **NEW: VS Code workspace generator** | `generate-vscode-workspace.ps1 -ProjectPath . -MultiRoot -WorkspaceName "Project"` |
| **`manage-snippets.ps1`** | **NEW: Snippet library manager** | `manage-snippets.ps1 -Action install -Language csharp -IDE vscode` |
| **`generate-debug-configs.ps1`** | **NEW: Advanced debug configs** | `generate-debug-configs.ps1 -ProjectPath . -Scenario docker -ContainerName "api"` |
| **`git-interactive.ps1`** | **NEW: Git interactive helper** | `git-interactive.ps1 -Operation rebase -TargetBranch develop` |
| **`onboard-developer.ps1`** | **NEW: Developer onboarding** | `onboard-developer.ps1 -DeveloperName "John Doe" -DeveloperEmail "john@example.com"` |
| **`generate-infrastructure.ps1`** | **NEW: Infrastructure as Code generator** | `generate-infrastructure.ps1 -Provider terraform -ResourceType webapp -ProjectName "app"` |
| **`analyze-cloud-costs.ps1`** | **NEW: Cloud cost analyzer** | `analyze-cloud-costs.ps1 -Provider azure -TimeRange 30d -GenerateReport` |
| **`monitor-service-health.ps1`** | **NEW: Service health monitor** | `monitor-service-health.ps1 -Endpoints "https://api.example.com/health" -Interval 60` |
| **`validate-deployment.ps1`** | **NEW: Deployment validator** | `validate-deployment.ps1 -ProjectPath . -Environment production` |
| **`detect-config-drift.ps1`** | **NEW: Configuration drift detector** | `detect-config-drift.ps1 -SourceEnvironment production -TargetEnvironment staging -ConfigType appsettings` |
| **`refactor-code.ps1`** | **NEW: Automated code refactoring** | `refactor-code.ps1 -ProjectPath . -RefactoringType remove-unused -DryRun` |
| **`test-api-contracts.ps1`** | **NEW: API contract testing** | `test-api-contracts.ps1 -SpecPath "swagger.json" -BaseUrl "https://localhost:5001"` |
| **`manage-performance-baseline.ps1`** | **NEW: Performance baseline manager** | `manage-performance-baseline.ps1 -Action capture -BaselineName "release-1.0"` |
| **`generate-team-metrics.ps1`** | **NEW: Team metrics dashboard** | `generate-team-metrics.ps1 -TimeRange 30d -OutputFormat html` |
| **`devtools.ps1`** | **NEW: Master toolchain orchestrator** | `devtools.ps1 list` or `devtools.ps1 health` |
| **`detect-encoding-issues.ps1`** | **NEW: File encoding issue detector/fixer** | `detect-encoding-issues.ps1 -ProjectPath . -Fix -Recursive` |
| **`detect-mode.ps1`** | **NEW: Feature vs Debug mode detector** | `detect-mode.ps1 -UserMessage "..." -Analyze` |
| **`ai-image.ps1`** | **NEW: Universal AI image generation (OpenAI/Google/Stability/Azure)** | `ai-image.ps1 -Prompt "African house" -OutputPath "image.png"` |
| **`ai-vision.ps1`** | **NEW: AI vision Q&A - ask questions about images** | `ai-vision.ps1 -Images @("photo.png") -Prompt "What do you see?"` |
| **`social-messages-review.ps1`** | **NEW: Daily social media messaging review with AI reply drafts** | `social-messages-review.ps1 -ProjectId "proj-123" -AutoDraft` |
| **`context-snapshot.ps1`** | **NEW: Capture/restore work context (files, git, terminal)** | `context-snapshot.ps1 -Action Save -Notes "Debugging auth"` |
| **`code-hotspot-analyzer.ps1`** | **NEW: Find refactoring priorities (high churn + complexity)** | `code-hotspot-analyzer.ps1 -Since "3 months ago"` |
| **`unused-code-detector.ps1`** | **NEW: Detect unused classes/methods/properties** | `unused-code-detector.ps1 -MinConfidence 7` |
| **`n-plus-one-query-detector.ps1`** | **NEW: Find N+1 query performance issues (EF Core)** | `n-plus-one-query-detector.ps1` |
| **`flaky-test-detector.ps1`** | **NEW: Find non-deterministic tests via repeated runs** | `flaky-test-detector.ps1 -Iterations 10` |
| **`daily-tool-review.ps1`** | **NEW: DAILY mandatory end-of-session tool wishlist review** | `daily-tool-review.ps1` |
| **`agent-work-queue.ps1`** | **WAVE 2: Multi-agent task coordination (claim/release protocol)** | `agent-work-queue.ps1 -Action list` |
| **`usage-heatmap-tracker.ps1`** | **WAVE 2: Track actual tool usage, validate value estimates** | `usage-heatmap-tracker.ps1 -Action report -TimeRange week` |
| **`deployment-risk-score.ps1`** | **WAVE 2: Calculate deployment risk, prevent production incidents** | `deployment-risk-score.ps1 -Threshold 70` |
| **`pr-description-enforcer.ps1`** | **WAVE 2: Enforce PR description templates, auto-generate** | `pr-description-enforcer.ps1 -Action check` |
| **`config-validator.ps1`** | **WAVE 2: Validate config files, detect typos/secrets** | `config-validator.ps1` |
| **`cross-repo-sync.ps1`** | **WAVE 2: Sync Hazina + client-manager branches** | `cross-repo-sync.ps1 -Action create -BranchName feature/x` |
| **`adr-generator.ps1`** | **WAVE 2: Generate Architecture Decision Records from PRs** | `adr-generator.ps1 -PRNumber 123` |
| **`boilerplate-generator.ps1`** | **WAVE 2: Scaffold components/services/controllers + tests** | `boilerplate-generator.ps1 -Type component -Name Button` |
| **`next-action-predictor.ps1`** | **WAVE 2: Predict next command based on history patterns** | `next-action-predictor.ps1` |
| **`real-time-code-smell-detector.ps1`** | **WAVE 2: File watcher with live code smell analysis** | `real-time-code-smell-detector.ps1 -Path src` |
| **`ui-automation-bridge-server.ps1`** | **NEW: Windows UI automation bridge server (FlaUI)** | `ui-automation-bridge-server.ps1 -Debug` |
| **`ui-automation-bridge-client.ps1`** | **NEW: Control any Windows desktop application programmatically** | `ui-automation-bridge-client.ps1 -Action windows` |
| **`verify-fact.ps1`** | **🆕 FACT VERIFICATION: Check if claim appears in knowledge base** | `verify-fact.ps1 -Claim "..." -SearchPath "C:\emails"` |
| **`source-quote.ps1`** | **🆕 FACT VERIFICATION: Extract exact quote with context** | `source-quote.ps1 -File "path" -LineNumber 123 -Context 5` |
| **`fact-triangulate.ps1`** | **🆕 FACT VERIFICATION: Find all mentions + detect contradictions** | `fact-triangulate.ps1 -Topic "..." -Paths @("C:\emails")` |
| **`pre-publish-check.ps1`** | **🆕 FACT VERIFICATION: Verify all claims before publishing** | `pre-publish-check.ps1 -ContentFile "article.md" -KnowledgeBase "C:\kb"` |
| **`get-crashed-sessions.ps1`** | **🆕 SESSION RECOVERY: Find interrupted/crashed Claude sessions** | `get-crashed-sessions.ps1 -Days 7 -ShowContext` |
| **`session-restore.ps1`** | **🆕 SESSION RECOVERY: Generate context to continue crashed session** | `session-restore.ps1 -SessionId "abc..." -Clipboard` |
| **`session-browser.ps1`** | **🆕 SESSION RECOVERY: Search/browse conversation history** | `session-browser.ps1 -Search "migration" -Days 30` |
| **`session-export.ps1`** | **🆕 SESSION RECOVERY: Export session to markdown** | `session-export.ps1 -SessionId "abc..." -IncludeThinking` |
| **`hazina-ask.ps1`** | **🆕 HAZINA CLI: Universal LLM gateway with streaming** | `hazina-ask.ps1 "What is dependency injection?"` |
| **`hazina-rag.ps1`** | **🆕 HAZINA CLI: RAG with full CRUD (init/index/query/sync)** | `hazina-rag.ps1 query "How does auth work?" -StoreName project` |
| **`hazina-agent.ps1`** | **🆕 HAZINA CLI: Tool-calling agent for complex tasks** | `hazina-agent.ps1 "Analyze this codebase" -MaxSteps 20` |
| **`hazina-reason.ps1`** | **🆕 HAZINA CLI: Multi-layer reasoning with confidence** | `hazina-reason.ps1 "Is this migration safe?" -MinConfidence 0.9` |
| **`hazina-longdoc.ps1`** | **🆕 HAZINA CLI: Process massive documents (10M+ tokens)** | `hazina-longdoc.ps1 "src/" "What is the architecture?"` |
| **`prompt-evolver.ps1`** | **🆕 ADVANCED: Hybrid genetic algorithm for prompt optimization** | `prompt-evolver.ps1 -TestCasesPath "cases.json"` |

**Full documentation:** [tools/README.md](./tools/README.md) | [tools/HAZINA_CLI_GUIDE.md](./tools/HAZINA_CLI_GUIDE.md)

**🎉 MILESTONE: 140 tools implemented! (47 original + 54 recommended + 6 Wave 1 + 10 Wave 2 + 2 custom + 2 UI automation + 4 fact verification + 4 session recovery + 5 Hazina CLI + 5 team reporting + 1 advanced AI)**

**Latest additions (2026-01-31):**
- **🆕 TEAM ACTIVITY REPORTING** - 5 tools for instant team performance dashboards:
  - `team-activity-dashboard.ps1` - Unified ClickUp + GitHub team dashboard (auto-opens beautiful HTML)
  - `team-activity-clean.ps1` - **RECOMMENDED: Clean table view showing only actual work** (tasks with comments/updates, commits/PRs per day, clean columns)
  - `team-daily-activity.ps1` - Per-person detailed timeline with GitHub-ClickUp correlation (yesterday + today summaries, task linking)
  - `team-activity-clickup.ps1` - ClickUp task metrics (completion, velocity, WIP analysis)
  - `team-activity-github.ps1` - GitHub contribution metrics (commits, PRs, reviews)
  - Use case: Daily standups, weekly reviews, monthly reports, performance tracking, 1-on-1s
  - Features: Console/JSON/HTML output, customizable time ranges, multi-project support, automatic task correlation, actual work filtering

**Latest additions (2026-02-01):**
- **🆕 PROMPT EVOLUTION (GENETIC ALGORITHMS)** - Hybrid AI-powered prompt optimization:
  - **Tool:** `prompt-evolver.ps1` - Evolve optimal prompts using genetic algorithms
  - **Phase 1:** Component-based evolution (fast, cheap) - 20 generations exploring combinations
  - **Phase 2:** LLM-assisted refinement (powerful) - Top candidates polished by LLM
  - **Use cases:** RAG optimization, email summarization, code review consistency
  - **Cost:** ~$0.21-$2.10 per evolution run (~2000 LLM calls)
  - **Output:** Measurable fitness scores + evolved prompt you wouldn't think of manually
  - **Status:** Built, tested, ready to use when needed (expensive but valuable for production optimization)
  - Full docs: [tools/prompt-evolution/README.md](./tools/prompt-evolution/README.md) | [tools/prompt-evolution/QUICKSTART.md](./tools/prompt-evolution/QUICKSTART.md)
- **🆕 KNOWLEDGE NETWORK** - Persistent RAG-indexed external memory system:
  - **Location:** `C:\scripts\my_network\` (8 files, 273 chunks indexed)
  - **Capabilities:** What I can do (AI, UI control, debugging, worktrees, etc.)
  - **Knowledge:** What I know (user profile, projects, credentials)
  - **Workflows:** How I do things (worktree management, PR creation, etc.)
  - **Tools:** All available tools with usage examples
  - **Projects:** Project-specific knowledge (client-manager, Hazina)
  - **Patterns:** Best practices and anti-patterns
  - **Reflections:** Session learnings (future: auto-extracted from reflection.log.md)
  - **Query:** `hazina-rag.ps1 query "How do I X?" -StoreName "C:\scripts\my_network"`
  - **Update:** `hazina-rag.ps1 -Action sync -StoreName "C:\scripts\my_network"`
  - **Benefits:** Always relevant context, persistent memory, semantic search, no manual file searching
  - Full docs: [my_network/README.md](./my_network/README.md) | [my_network/workflows/knowledge-network-maintenance.md](./my_network/workflows/knowledge-network-maintenance.md)

**Previous additions (2026-01-28):**
- **🆕 HAZINA CLI TOOLS** - 5 AI-powered tools for project knowledge bases and advanced reasoning:
  - `hazina-ask.ps1` - Universal LLM gateway with streaming
  - `hazina-rag.ps1` - RAG with CRUD (init, index, query, sync, status, list) for project-local knowledge bases
  - `hazina-agent.ps1` - Tool-calling agent for complex multi-step tasks
  - `hazina-reason.ps1` - Multi-layer reasoning with confidence scoring (Neurochain)
  - `hazina-longdoc.ps1` - Process massive documents (10M+ tokens) via recursive summarization
  - Full docs: [tools/HAZINA_CLI_GUIDE.md](./tools/HAZINA_CLI_GUIDE.md)
- **🆕 SESSION RECOVERY SYSTEM** - 4 tools for recovering crashed/interrupted sessions (get-crashed-sessions, session-restore, session-browser, session-export)

**Previous additions (2026-01-26):**
- **🆕 FACT VERIFICATION PROTOCOL** - 4 tools for mandatory fact-checking before content publication (verify-fact, source-quote, fact-triangulate, pre-publish-check)
- **🆕 UI Automation Bridge** - Complete Windows desktop control via FlaUI (click, type, screenshot any app)
  - `ui-automation-bridge-server.ps1` - HTTP bridge server (localhost:27184)
  - `ui-automation-bridge-client.ps1` - PowerShell client for desktop automation
- `ai-image.ps1` - Universal AI image generation (4 providers, 4 modes, reference images) (2026-01-25)
- `ai-vision.ps1` - Ask questions about images (4 providers, multi-image support, OCR) (2026-01-25)
- `webappfactory-validator.ps1` - WebApplicationFactory compatibility checker (prevents integration test failures) (2026-01-25)
- `social-messages-review.ps1` - Daily social media messaging review with AI-powered reply drafts (Facebook Pages inbox integration) (2026-01-25)
- **🆕 META-OPTIMIZATION WAVE 1** (50-expert analysis, dev productivity focus):
  - `context-snapshot.ps1` - Save/restore work context (ratio 10.0)
  - `code-hotspot-analyzer.ps1` - Refactoring priorities (ratio 9.0)
  - `unused-code-detector.ps1` - Dead code elimination (ratio 9.0)
  - `n-plus-one-query-detector.ps1` - Performance issue finder (ratio 6.7)
  - `flaky-test-detector.ps1` - Non-deterministic test detector (ratio 6.0)
  - `daily-tool-review.ps1` - DAILY mandatory review (auto-detect patterns)
- **🆕 META-OPTIMIZATION WAVE 2** (blind spot analysis, collaboration + production focus):
  - **Tier S+ (ratio > 5.0) - ALL 10 IMPLEMENTED:**
  - `agent-work-queue.ps1` - Multi-agent coordination (ratio 10.0)
  - `pr-description-enforcer.ps1` - PR quality enforcement (ratio 9.0)
  - `config-validator.ps1` - Config validation (ratio 8.0)
  - `adr-generator.ps1` - Architecture Decision Records (ratio 8.0)
  - `deployment-risk-score.ps1` - Production safety (ratio 6.7)
  - `real-time-code-smell-detector.ps1` - Live code analysis (ratio 6.7)
  - `usage-heatmap-tracker.ps1` - Usage analytics (ratio 6.0)
  - `boilerplate-generator.ps1` - Scaffolding (ratio 6.0)
  - `next-action-predictor.ps1` - Predictive assistance (ratio 6.0)
  - `cross-repo-sync.ps1` - Multi-repo workflow (ratio 6.0)

---

