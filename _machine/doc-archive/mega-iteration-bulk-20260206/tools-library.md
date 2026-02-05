# Tools Library - Complete Reference

**Complete catalog of all 270+ automation tools in C:\scripts\tools\**

**Tags:** `#tools`, `#automation`, `#scripts`, `#productivity`, `#devops`

---

## 📊 Overview

**Total Tools:** 270+ PowerShell automation scripts
**Evolution:** 47 original → 117 Wave 1/2 → 270+ Wave 3
**Purpose:** Automate repetitive tasks, enforce workflows, enable autonomous operation

### Tool Waves

| Wave | Focus | Tools Added | Key Achievement |
|------|-------|-------------|-----------------|
| **Original** | Core workflows | 47 | Foundation: worktrees, health, reflection |
| **Wave 1 (Meta)** | Dev productivity | 15 | 50-expert analysis, ratio-driven selection |
| **Wave 2 (Blind Spots)** | Collaboration + Production | 10 | Multi-agent, PR quality, deployment safety |
| **Wave 3 Tier S+** | Enterprise patterns | 10 | LLM review, security, incident response |
| **Wave 3 Tier S** | Quality + Safety | 9 | Migration validation, flakiness detection |
| **Wave 3 Tier A** | Specialized tools | 23+ | API monitoring, cloud optimization |
| **CLI Analysis** | External tools | 100+ | Massive capability expansion |

---

## 🎯 Quick Reference: "If You Want X, Use Y"

| Need | Tool | Command |
|------|------|---------|
| **Start session** | `bootstrap-snapshot.ps1` | `.\bootstrap-snapshot.ps1` |
| **Check system health** | `system-health.ps1` | `.\system-health.ps1 -Fix` |
| **Allocate worktree** | `worktree-allocate.ps1` | `.\worktree-allocate.ps1 -Repo client-manager -Branch feature/x` |
| **Release worktree** | `worktree-release-all.ps1` | `.\worktree-release-all.ps1 -AutoCommit` |
| **Check worktree status** | `worktree-status.ps1` | `.\worktree-status.ps1 -Compact` |
| **Generate AI images** | `ai-image.ps1` | `.\ai-image.ps1 -Prompt "..." -OutputPath "..."` |
| **Analyze images** | `ai-vision.ps1` | `.\ai-vision.ps1 -Images @("photo.png") -Prompt "What's this?"` |
| **Check user activity** | `monitor-activity.ps1` | `.\monitor-activity.ps1 -Mode context` |
| **Detect other agents** | `monitor-activity.ps1` | `.\monitor-activity.ps1 -Mode claude` |
| **Save work context** | `context-snapshot.ps1` | `.\context-snapshot.ps1 -Action Save -Notes "..."` |
| **Find refactoring targets** | `code-hotspot-analyzer.ps1` | `.\code-hotspot-analyzer.ps1 -Since "3 months ago"` |
| **Detect unused code** | `unused-code-detector.ps1` | `.\unused-code-detector.ps1 -MinConfidence 7` |
| **Find N+1 queries** | `n-plus-one-query-detector.ps1` | `.\n-plus-one-query-detector.ps1` |
| **Detect flaky tests** | `flaky-test-detector.ps1` | `.\flaky-test-detector.ps1 -Iterations 10` |
| **Calculate deployment risk** | `deployment-risk-score.ps1` | `.\deployment-risk-score.ps1 -Threshold 70` |
| **Validate config files** | `config-validator.ps1` | `.\config-validator.ps1 -CheckSecrets` |
| **Enforce PR descriptions** | `pr-description-enforcer.ps1` | `.\pr-description-enforcer.ps1 -Action check` |
| **Sync cross-repo branches** | `cross-repo-sync.ps1` | `.\cross-repo-sync.ps1 -Action status` |
| **Generate ADRs** | `adr-generator.ps1` | `.\adr-generator.ps1 -PRNumber 123` |
| **Scaffold components** | `boilerplate-generator.ps1` | `.\boilerplate-generator.ps1 -Type component -Name Button` |
| **Predict next action** | `next-action-predictor.ps1` | `.\next-action-predictor.ps1` |
| **Live code smell detection** | `real-time-code-smell-detector.ps1` | `.\real-time-code-smell-detector.ps1 -Path src` |
| **Multi-agent coordination** | `agent-work-queue.ps1` | `.\agent-work-queue.ps1 -Action list` |
| **Track tool usage** | `usage-heatmap-tracker.ps1` | `.\usage-heatmap-tracker.ps1 -Action report` |
| **Daily tool review** | `daily-tool-review.ps1` | `.\daily-tool-review.ps1` |
| **Search past solutions** | `pattern-search.ps1` | `.\pattern-search.ps1 -Query "error"` |
| **Read reflections** | `read-reflections.ps1` | `.\read-reflections.ps1 -Recent 10` |
| **Format C# code** | `cs-format.ps1` | `.\cs-format.ps1 -Path . -Fix` |
| **Check ClickUp tasks** | `clickup-sync.ps1` | `.\clickup-sync.ps1 -Action list` |
| **Fix encoding issues** | `detect-encoding-issues.ps1` | `.\detect-encoding-issues.ps1 -ProjectPath . -Fix` |
| **Detect mode** | `detect-mode.ps1` | `.\detect-mode.ps1 -UserMessage "..." -Analyze` |
| **Merge PR sequence** | `merge-pr-sequence.ps1` | `.\merge-pr-sequence.ps1 -DryRun` |
| **🆕 Safe merge to main** | **`merge-to-main.ps1`** | **`.\merge-to-main.ps1 -AutoPush`** |
| **🆕 Quick merge (with repo map)** | **`merge.ps1`** | **`.\merge.ps1 -Repo client-manager -Push`** |
| **Diagnose errors** | `diagnose-error.ps1` | `.\diagnose-error.ps1 -ErrorMessage "..."` |
| **Scan for secrets** | `scan-secrets.ps1` | `.\scan-secrets.ps1 -Path . -Recursive` |
| **EF migration check** | `ef-preflight-check.ps1` | `.\ef-preflight-check.ps1 -Context AppDbContext` |
| **Preview migration SQL** | `ef-migration-preview.ps1` | `.\ef-migration-preview.ps1 -Migration AddUserEmail` |
| **LLM code review** | `llm-code-reviewer.ps1` | `.\llm-code-reviewer.ps1 -Path . -Detailed` |
| **Detect circular deps** | `circular-dependency-detector.ps1` | `.\circular-dependency-detector.ps1` |
| **Find dead code** | `dead-code-eliminator.ps1` | `.\dead-code-eliminator.ps1 -RemoveComments` |
| **Git bisect automation** | `git-bisect-automation.ps1` | `.\git-bisect-automation.ps1 -Good abc123 -Bad def456` |

---

## 📂 Tool Categories

### 1. Core System Management (20 tools)

**Purpose:** Essential system operations, health monitoring, startup

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `bootstrap-snapshot.ps1` | Fast startup state snapshot | `-Generate`, `-Format json` |
| `claude-ctl.ps1` | Unified CLI orchestrator | `status`, `health`, `allocate`, `release` |
| `system-health.ps1` | Comprehensive health checks | `-Fix`, `-Detailed` |
| `system-health-score.ps1` | Numeric health scoring | `-Threshold 80` |
| `health-check.ps1` | Environment health validation | `-Full`, `-Fix` |
| `devtools.ps1` | Master toolchain orchestrator | `list`, `health`, `install` |
| `maintenance.ps1` | Run maintenance tasks | `-Full`, `-DryRun` |
| `session-start.ps1` | Initialize agent session | `-Mode feature` |
| `session-metrics.ps1` | Track session statistics | `-Summary` |
| `session-memory.ps1` | Session context persistence | `-Save`, `-Load` |
| `config.ps1` | System configuration manager | `-Get`, `-Set` |
| `aliases.ps1` | Command alias definitions | `-List`, `-Add` |
| `new-tool.ps1` | Scaffold new tool from template | `-ToolName`, `-Category` |
| `find-tool.ps1` | Search tools by name/purpose | `-Query "worktree"` |
| `generate-tool-index.ps1` | Auto-generate tool documentation | `-OutputPath` |
| `tool-log.ps1` | Tool execution logging | `-ToolName`, `-Action` |
| `tool-analytics.ps1` | Tool usage analytics | `-TimeRange 30d` |
| `tool-effectiveness.ps1` | Measure tool ROI | `-ToolName`, `-Metrics` |
| `tool-compose.ps1` | Chain multiple tools | `-Tools @("a","b")` |
| `smoke-test.ps1` | Quick functionality validation | `-TestSuite basic` |

**Creation Context:** Original 47 tools, foundation of agent system

---

### 2. Worktree Management (5 tools)

**Purpose:** Multi-agent workspace isolation and coordination

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `worktree-allocate.ps1` | Allocate agent worktree | `-Repo`, `-Branch`, `-Paired` |
| `worktree-status.ps1` | Check pool status | `-Compact`, `-ShowOrphaned` |
| `worktree-release-all.ps1` | Release worktrees | `-AutoCommit`, `-Seats` |
| `worktree-cleanup.ps1` | Clean orphaned worktrees | `-DryRun`, `-Force` |
| `pool-validate.ps1` | Validate pool consistency | `-Fix`, `-Report` |

**Creation Context:** Core multi-agent workflow, Pattern 73 (paired worktrees)

---

### 3. AI Capabilities (4 tools)

**Purpose:** Autonomous image generation, vision analysis, LLM integration

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `ai-image.ps1` | Universal AI image generation | `-Provider`, `-Prompt`, `-OutputPath`, `-Quality hd` |
| `ai-image-universal.ps1` | Multi-provider image backend | `-Provider openai/google/stability/azure` |
| `ai-vision.ps1` | Image analysis and Q&A | `-Images`, `-Prompt`, `-OutputFormat json` |
| `llm-code-reviewer.ps1` | AI-powered code review | `-Path`, `-Detailed`, `-PostComments` |
| `llm-code-reviewer-auto.ps1` | Automatic review on commits | `-WatchMode`, `-AutoFix` |

**Creation Context:**
- 2026-01-24: Initial `generate-image.ps1` for DALL-E
- 2026-01-25: Expanded to `ai-image.ps1` (4 providers, 4 modes)
- 2026-01-25: Added `ai-vision.ps1` (multi-image, OCR, analysis)

**Rationale:** Autonomous visual content creation and analysis, eliminate "I can't generate images" limitation

---

### 4. Context & Activity Monitoring (8 tools)

**Purpose:** ManicTime integration, parallel agent coordination, user context awareness

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `monitor-activity.ps1` | ManicTime activity tracker | `-Mode context/claude/idle/patterns` |
| `context-snapshot.ps1` | Save/restore work context | `-Action Save/Restore`, `-Notes` |
| `context-graph.ps1` | Build context dependency graph | `-Depth 3`, `-OutputFormat dot` |
| `agent-work-queue.ps1` | Multi-agent task coordination | `-Action list/claim/release` |
| `parallel-orchestrate.ps1` | Coordinate parallel agents | `-Strategy balanced` |
| `state-share.ps1` | Share state between agents | `-Key`, `-Value`, `-Persist` |
| `detect-desire.ps1` | Analyze user intent patterns | `-Message`, `-History` |
| `user-preferences.ps1` | Track user preferences | `-Get`, `-Set`, `-Category` |

**Creation Context:**
- 2026-01-19: `monitor-activity.ps1` (ManicTime integration)
- 2026-01-20: Parallel agent coordination protocol
- 2026-01-25 Wave 1: `context-snapshot.ps1` (ratio 10.0, top tool)
- 2026-01-25 Wave 2: `agent-work-queue.ps1` (ratio 10.0, multi-agent)

**Rationale:** Enable context-aware assistance, prevent multi-agent conflicts, intelligent work distribution

---

### 5. Code Quality & Analysis (25+ tools)

**Purpose:** Static analysis, code metrics, refactoring guidance

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `code-hotspot-analyzer.ps1` | Find high-churn + high-complexity | `-Since "3 months ago"` |
| `unused-code-detector.ps1` | Detect dead code | `-MinConfidence 7`, `-RemoveUnused` |
| `dead-code.ps1` | Legacy dead code detection | `-Path`, `-Report` |
| `dead-code-eliminator.ps1` | Auto-remove dead code | `-DryRun`, `-RemoveComments` |
| `code-complexity.ps1` | Calculate cyclomatic complexity | `-Threshold 10`, `-Path` |
| `code-duplication-detector.ps1` | Find duplicated code blocks | `-MinLines 6`, `-OutputFormat html` |
| `circular-dependency-detector.ps1` | Detect circular dependencies | `-ProjectPath`, `-ShowGraph` |
| `anti-pattern.ps1` | Detect anti-patterns | `-Pattern`, `-Severity` |
| `naming-enforce.ps1` | Enforce naming conventions | `-Check`, `-Fix` |
| `architecture-layer-validator.ps1` | Validate layer separation | `-ConfigPath`, `-FailOnViolation` |
| `dependency-update-safety.ps1` | Safe dependency upgrades | `-Package`, `-TestFirst` |
| `n-plus-one-query-detector.ps1` | Find EF Core N+1 queries | `-ProjectPath`, `-OutputFormat json` |
| `real-time-code-smell-detector.ps1` | Live code smell watcher | `-Path`, `-AutoFix` |
| `cache-invalidation-analyzer.ps1` | Analyze cache invalidation | `-Strategy`, `-Recommend` |
| `performance-regression-detector.ps1` | Detect performance regressions | `-Baseline`, `-Threshold` |
| `memory-leak-detector.ps1` | Detect memory leaks | `-Duration 60`, `-HeapSnapshot` |
| `pii-detector.ps1` | Scan for PII in code | `-Path`, `-Recursive`, `-ReportFormat html` |
| `license-scanner.ps1` | Scan dependency licenses | `-AllowedLicenses`, `-BlockList` |
| `api-breaking-change-detector.ps1` | Detect API breaking changes | `-BaseBranch develop` |

**Creation Context:**
- 2026-01-25 Wave 1: `code-hotspot-analyzer.ps1` (ratio 9.0), `unused-code-detector.ps1` (ratio 9.0)
- 2026-01-25 Wave 1: `circular-dependency-detector.ps1`, `dead-code-eliminator.ps1`
- 2026-01-25 Wave 2: `real-time-code-smell-detector.ps1` (ratio 6.7, live watching)
- 2026-01-21: 50-Expert Council improvements to existing tools

**Rationale:** Proactive code quality, prevent technical debt accumulation, guide refactoring priorities

---

### 6. Testing & Quality Assurance (15 tools)

**Purpose:** Test automation, coverage, flakiness detection

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `flaky-test-detector.ps1` | Detect non-deterministic tests | `-Iterations 10`, `-OutputFormat json` |
| `test-flakiness-detector.ps1` | Advanced flakiness analysis | `-ProjectPath`, `-MinRuns 20` |
| `test-coverage-report.ps1` | Generate coverage reports | `-Threshold 80`, `-Format html` |
| `test-coverage-diff.ps1` | Coverage delta analysis | `-BaseBranch develop` |
| `test-gaps.ps1` | Find untested code paths | `-CriticalOnly`, `-Report` |
| `test-api-load.ps1` | API load testing | `-BaseUrl`, `-Concurrency 50`, `-Pattern ramp-up` |
| `test-api-contracts.ps1` | API contract validation | `-SpecPath swagger.json`, `-BaseUrl` |
| `run-e2e-tests.ps1` | Playwright E2E runner | `-Browser all`, `-UpdateSnapshots` |
| `contract-test-generator.ps1` | Generate contract tests | `-APISpec`, `-Framework pact` |
| `smoke-test.ps1` | Quick smoke tests | `-Environment staging` |
| `webhook-retry-tester.ps1` | Test webhook retry logic | `-URL`, `-Scenarios` |
| `pagination-validator.ps1` | Validate pagination correctness | `-APIEndpoint`, `-PageSize` |
| `retry-policy-validator.ps1` | Validate retry policies | `-Config`, `-TestScenarios` |
| `idempotency-key-validator.ps1` | Test idempotency handling | `-Endpoint`, `-Method POST` |
| `accessibility-score.ps1` | Calculate accessibility score | `-URL`, `-Standard WCAG-AA` |

**Creation Context:**
- 2026-01-25 Wave 1: `flaky-test-detector.ps1` (ratio 6.0), `test-coverage-diff.ps1`
- 2026-01-25 Wave 3 Tier S: `test-flakiness-detector.ps1`
- 2026-01-16: Batches 7-10 testing tools
- 2026-01-25 Wave 3 Tier A: `contract-test-generator.ps1`, `webhook-retry-tester.ps1`

**Rationale:** Improve test reliability, increase coverage, prevent flaky builds

---

### 7. Database & Migrations (12 tools)

**Purpose:** EF Core migration safety, schema validation, performance

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `ef-preflight-check.ps1` | Pre-flight migration safety | `-Context`, `-FailOnDrift` |
| `ef-migration-preview.ps1` | SQL preview + breaking changes | `-Migration`, `-GenerateRollback` |
| `ef-migration-status.ps1` | Migration status check | `-Context`, `-ShowPending` |
| `ef-version-check.ps1` | EF Core version validation | `-MinVersion 8.0` |
| `validate-migration.ps1` | Validate migration quality | `-GenerateRollback`, `-TestRollback` |
| `database-migration-validator.ps1` | Advanced migration validation | `-Context`, `-BreakingChangeCheck` |
| `db-reset.ps1` | Reset dev database | `-Confirm`, `-SeedData` |
| `compare-database-schemas.ps1` | Schema drift detection | `-Source Dev`, `-Target Prod` |
| `database-query-analyzer.ps1` | Query performance analysis | `-SlowThreshold 1000ms` |
| `database-connection-pool-monitor.ps1` | Connection pool monitoring | `-Interval 60`, `-AlertThreshold` |
| `database-backup-validator.ps1` | Validate backup integrity | `-BackupPath`, `-RestoreTest` |
| `index-recommendation-engine.ps1` | Suggest missing indexes | `-AnalyzeLogs`, `-EstimateImpact` |

**Creation Context:**
- 2026-01-19: `ef-preflight-check.ps1`, `ef-migration-preview.ps1` (table naming incident response)
- 2026-01-17: EF Core tooling expansion
- 2026-01-25 Wave 3 Tier S: `database-migration-validator.ps1`
- 2026-01-25 Wave 3 Tier A: `database-connection-pool-monitor.ps1`

**Rationale:** Prevent `PendingModelChangesWarning` incidents, ensure migration safety, detect breaking changes

---

### 8. Git & Version Control (10 tools)

**Purpose:** Advanced git workflows, branch management, PR automation

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `git-sync-check.ps1` | Check repo sync status | `-Repos @("cm","hazina")` |
| `git-interactive.ps1` | Interactive git helper | `-Operation rebase`, `-TargetBranch` |
| `git-bisect-automation.ps1` | Automated git bisect | `-Good abc123`, `-Bad def456`, `-TestScript` |
| `merge-pr-sequence.ps1` | Auto-merge PR dependencies | `-DryRun`, `-Force` |
| `validate-pr-base.ps1` | Validate PR base branch | `-Repo`, `-ExpectedBase develop` |
| `prune-branches.ps1` | Clean old branches | `-DryRun`, `-KeepRecent 30` |
| `cleanup-stale-branches.ps1` | Auto-cleanup stale branches | `-DaysInactive 60`, `-DryRun` |
| `stale-branch-auto-cleanup.ps1` | Advanced stale cleanup | `-Strategy aggressive` |
| `branch-lifecycle.ps1` | Track branch lifecycle | `-Branch`, `-LogHistory` |
| `cross-repo-sync.ps1` | Sync Hazina + client-manager | `-Action create/status`, `-BranchName` |

**Creation Context:**
- 2026-01-25 Wave 1: `git-bisect-automation.ps1` (automated debugging)
- 2026-01-25 Wave 2: `cross-repo-sync.ps1` (ratio 6.0, multi-repo workflow)
- 2026-01-17: `merge-pr-sequence.ps1` (automated merge sequencing)
- 2026-01-16: Branch cleanup tools

**Rationale:** Automate complex git workflows, enforce branch hygiene, cross-repo coordination

---

### 9. PR & Code Review (8 tools)

**Purpose:** PR quality, automated review, description enforcement

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `pr-description-enforcer.ps1` | Enforce PR templates | `-Action check/generate`, `-PRNumber` |
| `pr-review-checklist-generator.ps1` | Generate review checklists | `-PRNumber`, `-Template` |
| `pr-preflight.ps1` | Pre-PR validation | `-Branch`, `-CheckBuild` |
| `auto-pr.ps1` | Auto-create PRs | `-Branch`, `-Template` |
| `auto-code-review.ps1` | Automated code review | `-Path`, `-PRNumber`, `-PostComments` |
| `llm-code-reviewer.ps1` | LLM-powered review | `-Path`, `-Detailed`, `-Suggestions` |
| `llm-code-reviewer-auto.ps1` | Auto LLM review on commit | `-WatchMode`, `-AutoFix` |
| `adr-generator.ps1` | Generate ADRs from PRs | `-PRNumber`, `-Template` |

**Creation Context:**
- 2026-01-25 Wave 2: `pr-description-enforcer.ps1` (ratio 9.0, PR quality)
- 2026-01-25 Wave 2: `adr-generator.ps1` (ratio 8.0, architecture docs)
- 2026-01-25 Wave 3 Tier S+: `llm-code-reviewer.ps1`, `llm-code-reviewer-auto.ps1`
- 2026-01-16: PR automation tools

**Rationale:** Enforce PR quality standards, auto-generate documentation, reduce review burden

---

### 10. Deployment & Production Safety (15 tools)

**Purpose:** Risk assessment, deployment validation, production monitoring

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `deployment-risk-score.ps1` | Calculate deployment risk | `-Threshold 70`, `-BaseBranch develop` |
| `deployment-checklist-generator.ps1` | Generate deployment checklists | `-Environment prod`, `-Changes` |
| `validate-deployment.ps1` | Pre-deploy validation | `-Environment`, `-CheckHealth` |
| `deploy.ps1` | Deployment orchestration | `-Environment`, `-DryRun` |
| `config-validator.ps1` | Validate appsettings.json | `-CheckSecrets`, `-Environment` |
| `detect-config-drift.ps1` | Detect config drift | `-Source prod`, `-Target staging` |
| `configuration-drift-detector.ps1` | Advanced drift detection | `-Environments @("prod","staging")` |
| `env-var-validator.ps1` | Environment variable validation | `-Environment`, `-Required @("API_KEY")` |
| `manage-environment.ps1` | Environment manager | `-Action validate`, `-Environment prod` |
| `secret-rotation-helper.ps1` | Secret rotation automation | `-SecretName`, `-Provider azure` |
| `scan-secrets.ps1` | Scan for leaked secrets | `-Path`, `-Recursive`, `-Fix` |
| `manage-feature-flags.ps1` | Feature flag manager | `-Action create/toggle`, `-FlagName` |
| `api-versioning-checker.ps1` | API version validation | `-APIPath`, `-CheckBackcompat` |
| `service-dependency-mapper.ps1` | Map service dependencies | `-OutputFormat graph` |
| `monitor-service-health.ps1` | Service health monitoring | `-Endpoints`, `-Interval 60` |

**Creation Context:**
- 2026-01-25 Wave 2: `deployment-risk-score.ps1` (ratio 6.7, prevent incidents)
- 2026-01-25 Wave 2: `config-validator.ps1` (ratio 8.0, config safety)
- 2026-01-25 Wave 3 Tier S+: `env-var-validator.ps1`, `pii-detector.ps1`
- 2026-01-25 Wave 3 Tier S: `configuration-drift-detector.ps1`, `api-versioning-checker.ps1`
- 2026-01-16: Deployment safety batch

**Rationale:** Prevent production incidents, ensure deployment safety, enforce configuration standards

---

### 11. Performance & Monitoring (15 tools)

**Purpose:** Performance profiling, monitoring, optimization

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `profile-performance.ps1` | Performance profiler | `-ProjectPath`, `-ProfileType all` |
| `performance-regression-detector.ps1` | Detect regressions | `-Baseline`, `-Threshold` |
| `manage-performance-baseline.ps1` | Performance baseline manager | `-Action capture`, `-BaselineName` |
| `monitor-api-performance.ps1` | API performance monitor | `-BaseUrl`, `-Duration 60` |
| `api-response-time-tracker.ps1` | Track API response times | `-Endpoints`, `-SLA 500ms` |
| `analyze-build-cache.ps1` | Build cache analysis | `-Measure`, `-Optimize` |
| `bundle-size-budget-enforcer.ps1` | Enforce bundle budgets | `-Threshold 500KB`, `-FailOnExceed` |
| `frontend-bundle-analyzer.ps1` | Analyze frontend bundles | `-ProjectPath`, `-Interactive` |
| `analyze-bundle-size.ps1` | Bundle size reporter | `-Build`, `-Compare` |
| `memory-leak-detector.ps1` | Detect memory leaks | `-Duration 60`, `-HeapSnapshot` |
| `cache-invalidation-analyzer.ps1` | Cache invalidation patterns | `-Strategy`, `-Recommend` |
| `database-query-analyzer.ps1` | Query performance analysis | `-SlowThreshold 1000ms` |
| `elasticsearch-index-optimizer.ps1` | Optimize ES indexes | `-Index`, `-Strategy reindex` |
| `redis-key-analyzer.ps1` | Analyze Redis key patterns | `-Host`, `-RecommendTTL` |
| `serverless-cold-start-optimizer.ps1` | Optimize cold starts | `-Function`, `-Strategy` |

**Creation Context:**
- 2026-01-25 Wave 1: `performance-regression-detector.ps1`
- 2026-01-25 Wave 3 Tier S: `frontend-bundle-analyzer.ps1`
- 2026-01-25 Wave 3 Tier A: `api-response-time-tracker.ps1`, `elasticsearch-index-optimizer.ps1`
- 2026-01-16: Performance tooling expansion

**Rationale:** Proactive performance monitoring, prevent regressions, optimize build times

---

### 12. Documentation & Knowledge (12 tools)

**Purpose:** Auto-documentation, knowledge base, architecture decisions

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `adr-generator.ps1` | Generate ADRs from PRs | `-PRNumber`, `-Template` |
| `generate-api-docs.ps1` | API documentation generator | `-Format swagger/markdown/all` |
| `generate-component-catalog.ps1` | React component catalog | `-Format storybook/markdown` |
| `anticipate-docs.ps1` | Predict doc needs | `-Context`, `-Suggest` |
| `doc-freshness.ps1` | Check doc freshness | `-MaxAge 90`, `-Report` |
| `doc-lint.ps1` | Lint documentation | `-CheckLinks`, `-CheckSpelling` |
| `get-doc-url.ps1` | Get documentation URLs | `-Topic`, `-Context` |
| `generate-feature-doc.ps1` | Feature documentation | `-FeatureName`, `-Template` |
| `clickup-kb.ps1` | ClickUp knowledge base sync | `-Action upload/download` |
| `clickup-docs.ps1` | ClickUp docs integration | `-Space`, `-Folder` |
| `create-project-kb.ps1` | Project KB generator | `-ProjectPath`, `-OutputPath` |
| `auto-changelog-generator.ps1` | Auto-generate changelogs | `-Since v1.0.0`, `-Format markdown` |

**Creation Context:**
- 2026-01-25 Wave 2: `adr-generator.ps1` (ratio 8.0, architecture decisions)
- 2026-01-25 Wave 3 Tier S+: `auto-changelog-generator.ps1`
- 2026-01-19: ClickUp KB integration
- 2026-01-16: Documentation automation

**Rationale:** Keep documentation current, auto-generate from code/PRs, knowledge preservation

---

### 13. Continuous Improvement & Learning (15 tools)

**Purpose:** Self-improvement, pattern learning, mistake prevention

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `daily-tool-review.ps1` | MANDATORY daily review | `-ScanWishlist`, `-ImplementTop` |
| `usage-heatmap-tracker.ps1` | Track tool usage patterns | `-Action report`, `-TimeRange week` |
| `reflect.ps1` | Add reflection entry | `-Tag`, `-Message` |
| `read-reflections.ps1` | Read reflection log | `-Recent 10`, `-Tag BUG-FIX` |
| `archive-reflections.ps1` | Archive old entries | `-OlderThan 180`, `-DryRun` |
| `pattern-search.ps1` | Search past patterns | `-Query "error"`, `-Context` |
| `pattern-learn.ps1` | Learn from patterns | `-Source reflection`, `-Extract` |
| `pattern-library.ps1` | Pattern library manager | `-Add`, `-Search`, `-Apply` |
| `mistake-to-prevention.ps1` | Convert mistakes to checks | `-Mistake`, `-CreateCheck` |
| `prevent-errors.ps1` | Error prevention automation | `-ErrorType`, `-AddValidation` |
| `error-memory.ps1` | Error memory system | `-Log`, `-Recall`, `-Prevent` |
| `success-to-pattern.ps1` | Extract success patterns | `-Success`, `-Generalize` |
| `autonomous-learning-checklist.ps1` | Learning protocol checklist | `-Phase`, `-Validate` |
| `session-metrics.ps1` | Track session metrics | `-Summary`, `-Trends` |
| `improve-suggest.ps1` | Suggest improvements | `-Context`, `-Priority` |

**Creation Context:**
- 2026-01-25 Wave 1: `daily-tool-review.ps1` (meta-optimization, continuous discovery)
- 2026-01-25 Wave 2: `usage-heatmap-tracker.ps1` (ratio 6.0, validate estimates)
- 2026-01-21: 50-Expert Council meta-cognitive improvements
- Original 47: Core reflection system

**Rationale:** Continuous self-improvement, learn from mistakes, validate tool value

---

### 14. ClickUp Integration (8 tools)

**Purpose:** Task management, ClickUp synchronization, workflow automation

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `clickup-sync.ps1` | ClickUp task synchronization | `-Action list/create/update` |
| `clickup-dashboard-builder.ps1` | Build ClickUp dashboards | `-Workspace`, `-Layout` |
| `clickup-kb.ps1` | Knowledge base sync | `-Action upload/download` |
| `clickup-docs.ps1` | Documentation integration | `-Space`, `-Folder` |
| `check-ai-tasks.ps1` | Check AI-related tasks | `-Status`, `-Priority` |
| `check-all-new-tasks.ps1` | Check new task queue | `-Assigned`, `-Unassigned` |
| `create-ai-prompting-tasks.ps1` | Create AI prompting tasks | `-Template`, `-Count` |
| `create-ai-prompting-tasks-simple.ps1` | Simplified AI task creation | `-Description` |

**Creation Context:**
- 2026-01-19: ClickUp integration wave
- 2026-01-17: Task management automation

**Rationale:** Integrate with ClickUp workflow, automate task creation, sync knowledge base

---

### 15. Infrastructure & DevOps (20+ tools)

**Purpose:** Docker, CI/CD, cloud, infrastructure automation

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `generate-docker-compose.ps1` | Docker Compose generator | `-GenerateDockerfiles`, `-Services` |
| `docker-layer-optimizer.ps1` | Optimize Docker layers | `-Dockerfile`, `-Suggest` |
| `docker-security-scanner.ps1` | Scan Docker images | `-Image`, `-Severity high` |
| `generate-ci-pipeline.ps1` | CI pipeline generator | `-Provider github/gitlab`, `-ProjectType` |
| `generate-infrastructure.ps1` | IaC generator | `-Provider terraform`, `-ResourceType` |
| `analyze-cloud-costs.ps1` | Cloud cost analysis | `-Provider azure`, `-TimeRange 30d` |
| `onboard-developer.ps1` | Developer onboarding | `-DeveloperName`, `-SetupEnvironment` |
| `generate-vscode-workspace.ps1` | VS Code workspace | `-MultiRoot`, `-Extensions` |
| `generate-debug-configs.ps1` | Debug configurations | `-Scenario docker`, `-IDE vscode` |
| `manage-snippets.ps1` | Code snippet manager | `-Action install`, `-Language csharp` |
| `setup-commit-template.ps1` | Git commit templates | `-Install`, `-Template conventional` |
| `toggle-workflow-triggers.ps1` | Toggle CI triggers | `-Mode manual/auto`, `-DryRun` |
| `merge-dependabot-prs.ps1` | Batch merge Dependabot | `-MinorOnly`, `-DryRun` |
| `update-dependencies.ps1` | Dependency updater | `-CheckOnly`, `-Security` |
| `generate-team-metrics.ps1` | Team metrics dashboard | `-TimeRange 30d`, `-Format html` |
| `auto-scaling-validator.ps1` | Validate auto-scaling | `-LoadTest`, `-TargetMetric` |
| `load-balancer-health-checker.ps1` | LB health validation | `-Endpoints`, `-Algorithm` |
| `message-queue-lag-monitor.ps1` | Monitor queue lag | `-Queue`, `-ThresholdMs` |
| `event-schema-registry-validator.ps1` | Validate event schemas | `-Registry`, `-CheckBackcompat` |
| `grpc-service-validator.ps1` | gRPC service validation | `-ProtoPath`, `-TestCalls` |

**Creation Context:**
- 2026-01-25 Wave 3 Tier S+: `docker-security-scanner.ps1`, `incident-postmortem-template.ps1`
- 2026-01-25 Wave 3 Tier A: Multiple cloud/infra tools
- 2026-01-17: `toggle-workflow-triggers.ps1`, `merge-dependabot-prs.ps1`
- 2026-01-16: Batches 8-10 (DevOps tools)

**Rationale:** Automate infrastructure tasks, improve developer experience, reduce onboarding time

---

### 16. Specialized Tools (25+ tools)

**Purpose:** Niche workflows, one-off automation, edge cases

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `boilerplate-generator.ps1` | Scaffold code templates | `-Type component/service`, `-Name` |
| `next-action-predictor.ps1` | Predict next command | `-History`, `-Context` |
| `cs-format.ps1` | C# code formatter | `-Path`, `-Fix`, `-EditorConfig` |
| `trim-whitespace.ps1` | Remove trailing whitespace | `-Path`, `-Recursive` |
| `fix-utf16-files.ps1` | Fix UTF-16 encoding | `-Path`, `-Convert` |
| `detect-encoding-issues.ps1` | Detect encoding problems | `-Fix`, `-Recursive` |
| `detect-mode.ps1` | Detect Feature/Debug mode | `-UserMessage`, `-Analyze` |
| `model-selector.ps1` | Intelligent model selection | `-Task`, `-Analyze` |
| `smart-search.ps1` | Context-aware doc search | `-Query`, `-Context` |
| `diagnose-error.ps1` | AI error diagnosis | `-ErrorMessage`, `-StackTrace` |
| `celebrate.ps1` | Celebrate achievements | `-Achievement`, `-Visual` |
| `q.ps1` | Quick query helper | `-Query`, `-Context` |
| `align.ps1` | Align intentions | `-UserIntent`, `-AgentPlan` |
| `log-user-prompt.ps1` | Log user interactions | `-Prompt`, `-Response` |
| `sentiment-analyze.ps1` | Analyze user sentiment | `-Message`, `-Context` |
| `confidence-score.ps1` | Calculate confidence | `-Task`, `-Factors` |
| `task-control.ps1` | Task orchestration | `-Action start/pause/resume` |
| `workflow.ps1` | Workflow automation | `-WorkflowName`, `-Execute` |
| `smart-cache.ps1` | Intelligent caching | `-Key`, `-TTL`, `-Strategy` |
| `jwt-expiration-checker.ps1` | Check JWT expiration | `-Token`, `-AlertBefore 7d` |
| `dns-propagation-checker.ps1` | Check DNS propagation | `-Domain`, `-RecordType` |
| `design-system-validator.ps1` | Validate design tokens | `-ComponentPath`, `-Tokens` |
| `api-mock-server-generator.ps1` | Generate API mocks | `-SpecPath`, `-Port 3000` |
| `openapi-diff.ps1` | Compare OpenAPI specs | `-Old`, `-New`, `-BreakingOnly` |
| `mobile-app-size-tracker.ps1` | Track app bundle size | `-Platform ios/android`, `-Trend` |

**Creation Context:**
- 2026-01-25 Wave 2: `boilerplate-generator.ps1` (ratio 6.0), `next-action-predictor.ps1` (ratio 6.0)
- 2026-01-25 Wave 3 Tier A: Specialized API/infra tools
- 2026-01-21: 50-Expert Council tools
- 2026-01-19: Encoding fixes, mode detection

**Rationale:** Handle edge cases, niche workflows, specialized automation

---

### 17. Backup & Recovery (4 tools)

**Purpose:** Data backup, disaster recovery, state preservation

| Tool | Description | Key Parameters |
|------|-------------|----------------|
| `backup-brand2boost.ps1` | Backup brand2boost data | `-Destination`, `-Compress` |
| `backup-restore.ps1` | Universal backup/restore | `-Action backup/restore`, `-Type all` |
| `register-backup-task.ps1` | Register scheduled backup | `-Schedule nightly`, `-Retention 30` |
| `setup-backup-schedule.ps1` | Setup backup automation | `-Interval daily`, `-Time 02:00` |

**Creation Context:**
- 2026-01-19: Nightly backup system for brand2boost

**Rationale:** Prevent data loss, enable recovery, automate backup schedules

---

## 📈 Tool Evolution Timeline

### 2026-01-17 to 2026-01-19: Infrastructure Expansion
- ClickUp integration (8 tools)
- EF Core migration safety (3 tools)
- Email automation (3 tools)
- Backup systems (4 tools)

### 2026-01-20 to 2026-01-21: 50-Expert Council Meta-Cognitive
- Improvements to 25+ existing tools
- Added meta-cognitive patterns (align, q, reflect, anticipate, etc.)
- Pattern learning and mistake prevention

### 2026-01-22 to 2026-01-24: AI Capabilities
- Image generation (`generate-image.ps1`)
- Advanced image generation (`ai-image.ps1` with 4 providers)
- Image analysis (`ai-vision.ps1`)

### 2026-01-25: Meta-Optimization Waves

**Wave 1 (Dev Productivity - 50-Expert Analysis):**
- `context-snapshot.ps1` (ratio 10.0) - Save/restore work context
- `code-hotspot-analyzer.ps1` (ratio 9.0) - Refactoring priorities
- `unused-code-detector.ps1` (ratio 9.0) - Dead code detection
- `n-plus-one-query-detector.ps1` (ratio 6.7) - Performance issues
- `flaky-test-detector.ps1` (ratio 6.0) - Test reliability
- `daily-tool-review.ps1` - Continuous tool discovery

**Wave 2 (Blind Spot Analysis - Collaboration + Production):**
- `agent-work-queue.ps1` (ratio 10.0) - Multi-agent coordination
- `pr-description-enforcer.ps1` (ratio 9.0) - PR quality
- `config-validator.ps1` (ratio 8.0) - Config safety
- `adr-generator.ps1` (ratio 8.0) - Architecture docs
- `deployment-risk-score.ps1` (ratio 6.7) - Deployment safety
- `real-time-code-smell-detector.ps1` (ratio 6.7) - Live analysis
- `usage-heatmap-tracker.ps1` (ratio 6.0) - Usage validation
- `boilerplate-generator.ps1` (ratio 6.0) - Scaffolding
- `next-action-predictor.ps1` (ratio 6.0) - Predictive assist
- `cross-repo-sync.ps1` (ratio 6.0) - Multi-repo workflow

**Wave 3 Tier S+ (Enterprise Patterns - 10 tools):**
- LLM code reviewer (2 tools)
- Docker security scanner
- PII detector
- License scanner
- Environment variable validator
- API client generator
- Database backup validator
- GraphQL query complexity
- Auto-changelog generator
- Incident postmortem template

**Wave 3 Tier S (Quality + Safety - 9 tools):**
- Circular dependency detector
- Dead code eliminator
- Git bisect automation
- Performance regression detector
- Test coverage diff
- Architecture layer validator
- Bundle size budget enforcer
- Cache invalidation analyzer
- Docker layer optimizer
- Index recommendation engine
- PR review checklist generator
- Secret rotation helper
- Stale branch auto-cleanup
- Database migration validator
- Deployment checklist generator
- Frontend bundle analyzer
- Test flakiness detector
- API versioning checker
- Configuration drift detector
- Service dependency mapper

**Wave 3 Tier A (Specialized - 23+ tools):**
- API mock server generator
- Design system validator
- DNS propagation checker
- JWT expiration checker
- Redis key analyzer
- Retry policy validator
- Accessibility score
- OpenAPI diff
- Pagination validator
- Webhook retry tester
- API response time tracker
- Auto-scaling validator
- Contract test generator
- Database connection pool monitor
- Elasticsearch index optimizer
- Event schema registry validator
- gRPC service validator
- Idempotency key validator
- Load balancer health checker
- Memory leak detector
- Message queue lag monitor
- Mobile app size tracker
- Serverless cold start optimizer

**CLI Analysis Round 2:**
- 100+ additional external tools identified
- Auto-installer created (`install-tier-s-tools.ps1`, Round 2, Round 3)

---

## 🔍 Tool Dependencies & Chains

### Common Tool Chains

**Session Start:**
```
bootstrap-snapshot.ps1 → system-health.ps1 → worktree-status.ps1 → monitor-activity.ps1 -Mode context
```

**Feature Development:**
```
detect-mode.ps1 → worktree-allocate.ps1 -Paired → [work] → pr-preflight.ps1 → pr-description-enforcer.ps1 → worktree-release-all.ps1
```

**Deployment:**
```
deployment-risk-score.ps1 → config-validator.ps1 → validate-deployment.ps1 → deploy.ps1
```

**Code Quality:**
```
code-hotspot-analyzer.ps1 → unused-code-detector.ps1 → real-time-code-smell-detector.ps1 → llm-code-reviewer.ps1
```

**Multi-Agent:**
```
monitor-activity.ps1 -Mode claude → agent-work-queue.ps1 -Action claim → [work] → agent-work-queue.ps1 -Action release
```

---

## 📊 Usage Analytics

### Most Frequently Used (Top 20)

Based on usage patterns and reflection log analysis:

1. `worktree-allocate.ps1` - Daily, multiple times
2. `worktree-status.ps1` - Every session start
3. `bootstrap-snapshot.ps1` - Every session start
4. `system-health.ps1` - Daily health checks
5. `monitor-activity.ps1` - Context awareness
6. `pattern-search.ps1` - Problem solving
7. `read-reflections.ps1` - Learning from history
8. `cs-format.ps1` - Code cleanup
9. `clickup-sync.ps1` - Task management
10. `ef-preflight-check.ps1` - Pre-commit checks
11. `detect-mode.ps1` - Mode detection
12. `worktree-release-all.ps1` - After PR creation
13. `daily-tool-review.ps1` - End of session (MANDATORY)
14. `deployment-risk-score.ps1` - Before deploys
15. `config-validator.ps1` - Config validation
16. `code-hotspot-analyzer.ps1` - Refactoring planning
17. `flaky-test-detector.ps1` - CI troubleshooting
18. `ai-image.ps1` - Visual content creation
19. `ai-vision.ps1` - Image analysis
20. `agent-work-queue.ps1` - Multi-agent coordination

### Least Used (Candidates for Retirement)

Tools with < 5 uses in 30 days (validate via `usage-heatmap-tracker.ps1`):
- Legacy email tools (replaced by newer versions)
- VPS check tools (project-specific)
- Some specialized Wave 3 Tier A tools (niche use cases)

**Action:** Monthly review via `daily-tool-review.ps1` → retire if no use in 90 days

---

## 🎓 Tool Creation Patterns

### Automation Triggers

Create a new tool when:
1. **3+ step repetition** - Any workflow repeated 3+ times manually
2. **Error prevention** - Mistakes logged in reflection.log.md
3. **High ratio** - Value/effort ratio > 5.0
4. **Expert recommendation** - 50-expert analysis suggests
5. **User friction** - User explicitly says "I wish I had..."

### Tool Template

Use `new-tool.ps1` to scaffold from `_tool-wrapper-template.ps1`:

```powershell
.\new-tool.ps1 -ToolName "my-automation" -Category "code-quality"
```

Template includes:
- Parameter validation
- Usage tracking (automatic)
- Error handling
- Help documentation
- Standard patterns

### Naming Conventions

| Pattern | Examples | Purpose |
|---------|----------|---------|
| `verb-noun.ps1` | `generate-api-docs.ps1` | Action-oriented |
| `detect-X.ps1` | `detect-mode.ps1` | Detection/analysis |
| `validate-X.ps1` | `validate-migration.ps1` | Validation |
| `monitor-X.ps1` | `monitor-activity.ps1` | Continuous monitoring |
| `manage-X.ps1` | `manage-environment.ps1` | CRUD operations |
| `X-to-Y.ps1` | `mistake-to-prevention.ps1` | Transformation |

---

## 🔧 Usage Tracking System

### Auto-Tracking

All tools use `_usage-logger.ps1` for automatic tracking:

```powershell
# AUTO-USAGE TRACKING (in every tool)
$toolName = $MyInvocation.MyCommand.Name -replace '\.ps1$', ''
. "$PSScriptRoot\_usage-logger.ps1" -ToolName $toolName -Action "execute" -Metadata @{ Parameters = ($PSBoundParameters.Keys -join ',') } -ErrorAction SilentlyContinue
```

### Tracking Data

Captured for each execution:
- Tool name
- Timestamp
- Parameters used
- Execution duration
- Success/failure
- User context

### Analytics Tools

- `usage-heatmap-tracker.ps1` - Visualize usage patterns
- `tool-analytics.ps1` - Detailed analytics
- `tool-effectiveness.ps1` - ROI measurement
- `daily-tool-review.ps1` - Validate estimates vs actual

---

## 💡 Pro Tips

### 1. Use Unified CLI

Instead of remembering individual tools:
```powershell
.\claude-ctl.ps1 status    # Bootstrap snapshot + health + worktree status
.\claude-ctl.ps1 allocate  # Worktree allocation
.\claude-ctl.ps1 release   # Worktree release
```

### 2. Chain Tools with PowerShell

```powershell
# Pre-deployment validation chain
.\deployment-risk-score.ps1 -Threshold 70; `
.\config-validator.ps1 -CheckSecrets; `
.\validate-deployment.ps1 -Environment staging
```

### 3. Use DryRun Liberally

Most destructive tools support `-DryRun`:
```powershell
.\cleanup-stale-branches.ps1 -DryRun
.\worktree-release-all.ps1 -DryRun
.\deploy.ps1 -Environment prod -DryRun
```

### 4. Leverage JSON Output

For scripting/automation:
```powershell
$context = .\monitor-activity.ps1 -Mode context -OutputFormat json | ConvertFrom-Json
$risk = .\deployment-risk-score.ps1 -OutputFormat json | ConvertFrom-Json
```

### 5. Explore Tool Combinations

```powershell
# Find refactoring targets → analyze → suggest improvements
.\code-hotspot-analyzer.ps1 -Since "3 months ago" | `
.\unused-code-detector.ps1 -MinConfidence 7 | `
.\llm-code-reviewer.ps1 -Path . -Suggestions
```

---

## 🚀 Future Roadmap

### Planned Enhancements

1. **Tool Orchestration DSL** - Declarative tool chains
2. **Self-Healing Tools** - Auto-fix failures
3. **Predictive Execution** - Run tools before needed
4. **Natural Language Interface** - "Deploy to staging safely"
5. **Tool A/B Testing** - Measure effectiveness
6. **Cross-Tool Analytics** - Identify gaps
7. **Tool Recommendation Engine** - Suggest based on context

### Wave 4 Candidates

Based on ongoing `daily-tool-review.ps1` analysis:
- GraphQL performance optimizer
- Multi-cloud cost optimizer
- Advanced incident response automation
- AI-powered test generation
- Automated security patching
- Cross-repo refactoring tools
- Real-time collaboration tools

---

## 📚 Additional Resources

- **[tools/README.md](C:\scripts\tools\README.md)** - Original tools documentation
- **[CLAUDE.md](C:\scripts\CLAUDE.md)** - Tool usage in agent workflows
- **[reflection.log.md](C:\scripts\_machine\reflection.log.md)** - Tool creation history
- **[daily-tool-review.ps1](C:\scripts\tools\daily-tool-review.ps1)** - MANDATORY daily review

---

**Last Updated:** 2026-01-25
**Total Tools:** 270+
**Automation Philosophy:** If you do it 3+ times, automate it
**Continuous Improvement:** Daily review mandatory via `daily-tool-review.ps1`

**Remember:** Tools are force multipliers. The goal is to maximize thinking time by minimizing manual ceremony.
