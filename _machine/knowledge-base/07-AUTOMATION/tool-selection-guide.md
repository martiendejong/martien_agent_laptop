# Tool Selection Guide

**Scenario-based tool recommendations**

**Tags:** `#tools`, `#guide`, `#scenarios`, `#troubleshooting`

---

## 🎯 Purpose

This guide helps you choose the RIGHT tool for common scenarios. Instead of searching through 270+ tools, use this scenario-based index.

---

## 📋 By Scenario

### Session Management

**Starting a New Session:**
```powershell
# 1. Get startup state
.\bootstrap-snapshot.ps1

# 2. Check system health
.\system-health.ps1

# 3. Check user context & detect other agents
.\monitor-activity.ps1 -Mode context

# 4. Check worktree availability
.\worktree-status.ps1 -Compact
```

**Ending a Session:**
```powershell
# 1. MANDATORY tool review
.\daily-tool-review.ps1

# 2. Add reflection entry
.\reflect.ps1 -Tag "SESSION" -Message "Completed X, learned Y"

# 3. Save work context if interrupted
.\context-snapshot.ps1 -Action Save -Notes "Working on feature X"
```

---

### Code Quality & Refactoring

**Need to Refactor - Where to Start?**
```powershell
# 1. Find high-churn, high-complexity files
.\code-hotspot-analyzer.ps1 -Since "3 months ago"

# 2. Find unused/dead code
.\unused-code-detector.ps1 -MinConfidence 7

# 3. Detect circular dependencies
.\circular-dependency-detector.ps1

# 4. Get AI suggestions
.\llm-code-reviewer.ps1 -Path . -Suggestions
```

**Code Smells & Anti-Patterns:**
```powershell
# Real-time detection (file watcher)
.\real-time-code-smell-detector.ps1 -Path src -AutoFix

# One-time scan
.\anti-pattern.ps1 -Path . -Severity high

# Code duplication
.\code-duplication-detector.ps1 -MinLines 6
```

**Performance Issues:**
```powershell
# Find N+1 query problems (EF Core)
.\n-plus-one-query-detector.ps1

# Detect performance regressions
.\performance-regression-detector.ps1 -Baseline develop

# Memory leaks
.\memory-leak-detector.ps1 -Duration 60
```

**Code Complexity:**
```powershell
# Calculate cyclomatic complexity
.\code-complexity.ps1 -Threshold 10

# Architecture layer violations
.\architecture-layer-validator.ps1 -FailOnViolation
```

---

### Testing & Quality Assurance

**Tests Failing Randomly:**
```powershell
# Detect flaky tests (run multiple times)
.\flaky-test-detector.ps1 -Iterations 10

# Advanced flakiness analysis
.\test-flakiness-detector.ps1 -MinRuns 20
```

**Low Test Coverage:**
```powershell
# Generate coverage report
.\test-coverage-report.ps1 -Threshold 80 -Format html

# Find untested code paths
.\test-gaps.ps1 -CriticalOnly

# Compare coverage with base branch
.\test-coverage-diff.ps1 -BaseBranch develop
```

**API Testing:**
```powershell
# Load testing
.\test-api-load.ps1 -BaseUrl https://localhost:5001 -Concurrency 50

# Contract validation
.\test-api-contracts.ps1 -SpecPath swagger.json -BaseUrl https://localhost:5001

# Generate contract tests
.\contract-test-generator.ps1 -APISpec swagger.json
```

**E2E Testing:**
```powershell
# Run Playwright tests
.\run-e2e-tests.ps1 -Browser all -UpdateSnapshots

# Quick smoke tests
.\smoke-test.ps1 -Environment staging
```

---

### Database & Migrations

**Before Creating Migration:**
```powershell
# Pre-flight safety check
.\ef-preflight-check.ps1 -Context AppDbContext -FailOnDrift

# Check if migration needed
dotnet ef migrations has-pending-model-changes --context AppDbContext
```

**After Creating Migration:**
```powershell
# Preview SQL + detect breaking changes
.\ef-migration-preview.ps1 -Migration AddUserEmail -GenerateRollback

# Validate migration quality
.\validate-migration.ps1 -GenerateRollback -TestRollback

# Advanced validation
.\database-migration-validator.ps1 -Context AppDbContext
```

**Database Performance:**
```powershell
# Analyze slow queries
.\database-query-analyzer.ps1 -SlowThreshold 1000ms

# Suggest missing indexes
.\index-recommendation-engine.ps1 -AnalyzeLogs

# Monitor connection pool
.\database-connection-pool-monitor.ps1 -Interval 60
```

**Schema Drift:**
```powershell
# Compare schemas
.\compare-database-schemas.ps1 -Source Dev -Target Prod

# Validate backup integrity
.\database-backup-validator.ps1 -BackupPath "backup.bak" -RestoreTest
```

---

### Git & Version Control

**Starting Feature Work:**
```powershell
# Allocate worktree
.\worktree-allocate.ps1 -Repo client-manager -Branch feature/new-thing -Paired

# Check if other agents working
.\monitor-activity.ps1 -Mode claude
```

**After PR Created:**
```powershell
# Release worktree
.\worktree-release-all.ps1 -AutoCommit

# Validate PR base
.\validate-pr-base.ps1 -Repo client-manager
```

**Branch Cleanup:**
```powershell
# Preview stale branches
.\cleanup-stale-branches.ps1 -DryRun -DaysInactive 60

# Clean old branches
.\prune-branches.ps1 -KeepRecent 30

# Advanced stale cleanup
.\stale-branch-auto-cleanup.ps1 -Strategy aggressive
```

**Cross-Repo Work:**
```powershell
# Sync Hazina + client-manager
.\cross-repo-sync.ps1 -Action create -BranchName feature/x

# Check sync status
.\git-sync-check.ps1 -Repos @("client-manager","hazina")
```

**Git Debugging:**
```powershell
# Automated bisect
.\git-bisect-automation.ps1 -Good abc123 -Bad def456 -TestScript "test.ps1"

# Interactive git helper
.\git-interactive.ps1 -Operation rebase -TargetBranch develop
```

---

### PR & Code Review

**Before Creating PR:**
```powershell
# Pre-flight validation
.\pr-preflight.ps1 -Branch feature/x -CheckBuild

# Calculate deployment risk
.\deployment-risk-score.ps1 -Threshold 70
```

**PR Quality:**
```powershell
# Enforce PR description
.\pr-description-enforcer.ps1 -Action check

# Generate review checklist
.\pr-review-checklist-generator.ps1 -PRNumber 123

# LLM code review
.\llm-code-reviewer.ps1 -Path . -PRNumber 123 -PostComments
```

**Documentation:**
```powershell
# Generate ADR from PR
.\adr-generator.ps1 -PRNumber 123

# Auto-generate changelog
.\auto-changelog-generator.ps1 -Since v1.0.0
```

**Merging:**
```powershell
# Auto-merge PR sequence
.\merge-pr-sequence.ps1 -DryRun

# Batch merge Dependabot
.\merge-dependabot-prs.ps1 -MinorOnly -DryRun
```

---

### Deployment & Production

**Pre-Deployment Validation:**
```powershell
# Calculate risk score
.\deployment-risk-score.ps1 -Threshold 70

# Validate configuration
.\config-validator.ps1 -CheckSecrets -Environment production

# Validate environment variables
.\env-var-validator.ps1 -Environment production

# Pre-deploy validation
.\validate-deployment.ps1 -Environment production -CheckHealth
```

**Configuration Management:**
```powershell
# Detect config drift
.\detect-config-drift.ps1 -Source production -Target staging

# Advanced drift detection
.\configuration-drift-detector.ps1 -Environments @("prod","staging")

# Validate environment
.\manage-environment.ps1 -Action validate -Environment production
```

**Secret Management:**
```powershell
# Scan for leaked secrets
.\scan-secrets.ps1 -Path . -Recursive

# Secret rotation
.\secret-rotation-helper.ps1 -SecretName API_KEY -Provider azure
```

**Deployment Execution:**
```powershell
# Generate deployment checklist
.\deployment-checklist-generator.ps1 -Environment prod

# Deploy (with dry-run first!)
.\deploy.ps1 -Environment staging -DryRun
.\deploy.ps1 -Environment production
```

**Post-Deployment:**
```powershell
# Monitor service health
.\monitor-service-health.ps1 -Endpoints "https://api.example.com/health"

# Monitor API performance
.\monitor-api-performance.ps1 -BaseUrl https://api.example.com -Duration 60
```

---

### Performance & Monitoring

**Performance Profiling:**
```powershell
# Full performance profile
.\profile-performance.ps1 -ProjectPath . -ProfileType all

# Manage baseline
.\manage-performance-baseline.ps1 -Action capture -BaselineName "release-1.0"

# Detect regressions
.\performance-regression-detector.ps1 -Baseline develop
```

**Frontend Performance:**
```powershell
# Analyze bundle size
.\frontend-bundle-analyzer.ps1 -ProjectPath . -Interactive

# Enforce budget
.\bundle-size-budget-enforcer.ps1 -Threshold 500KB -FailOnExceed

# Build cache analysis
.\analyze-build-cache.ps1 -Measure -Optimize
```

**API Performance:**
```powershell
# Monitor response times
.\monitor-api-performance.ps1 -BaseUrl https://localhost:7001

# Track response time SLA
.\api-response-time-tracker.ps1 -Endpoints @("/api/users") -SLA 500ms
```

**Caching:**
```powershell
# Analyze cache patterns
.\cache-invalidation-analyzer.ps1 -Strategy -Recommend

# Redis key analysis
.\redis-key-analyzer.ps1 -Host localhost -RecommendTTL
```

**Memory & Resource:**
```powershell
# Detect memory leaks
.\memory-leak-detector.ps1 -Duration 60 -HeapSnapshot

# Monitor queue lag
.\message-queue-lag-monitor.ps1 -Queue "tasks" -ThresholdMs 1000
```

---

### AI & Image Generation

**Generate Images:**
```powershell
# Simple generation (OpenAI default)
.\ai-image.ps1 -Prompt "A sunset over mountains" -OutputPath "sunset.png"

# HD quality
.\ai-image.ps1 -Prompt "Professional logo" -OutputPath "logo.png" -Quality hd

# Different provider
.\ai-image.ps1 -Provider google -Prompt "Cat" -NegativePrompt "dog" -OutputPath "cat.png"

# Vision-enhanced (with reference images)
.\ai-image.ps1 -Mode vision-enhanced `
    -ReferenceImages @("style.png") `
    -ReferenceDescriptions @("Match this style") `
    -Prompt "Forest landscape" -OutputPath "forest.png"
```

**Analyze Images:**
```powershell
# Ask questions about images
.\ai-vision.ps1 -Images @("screenshot.png") -Prompt "What error is shown?"

# Extract text (OCR)
.\ai-vision.ps1 -Images @("document.png") -Prompt "Extract all text"

# Compare images
.\ai-vision.ps1 -Images @("before.png","after.png") -Prompt "What changed?"
```

---

### Multi-Agent Coordination

**Check for Other Agents:**
```powershell
# Detect Claude instances
.\monitor-activity.ps1 -Mode claude

# Get full context
.\monitor-activity.ps1 -Mode context -OutputFormat json
```

**Task Coordination:**
```powershell
# List available tasks
.\agent-work-queue.ps1 -Action list

# Claim task
.\agent-work-queue.ps1 -Action claim -TaskId 123

# Release task
.\agent-work-queue.ps1 -Action release -TaskId 123
```

**State Sharing:**
```powershell
# Share state between agents
.\state-share.ps1 -Key "current-feature" -Value "pdf-export" -Persist

# Get shared state
.\state-share.ps1 -Key "current-feature"
```

---

### Continuous Improvement

**Learning from Mistakes:**
```powershell
# Convert mistake to prevention check
.\mistake-to-prevention.ps1 -Mistake "Forgot to run migration" -CreateCheck

# Add to error memory
.\error-memory.ps1 -Log -ErrorType "PendingModelChanges" -Prevention "Run ef-preflight-check.ps1"
```

**Pattern Learning:**
```powershell
# Search past solutions
.\pattern-search.ps1 -Query "build error" -Context

# Learn from patterns
.\pattern-learn.ps1 -Source reflection -Extract

# Add to pattern library
.\pattern-library.ps1 -Add -Pattern "N+1 query fix" -Solution "Use Include()"
```

**Session Reflection:**
```powershell
# Read recent reflections
.\read-reflections.ps1 -Recent 10 -Tag "BUG-FIX"

# Add reflection
.\reflect.ps1 -Tag "LESSON" -Message "Always run pre-flight checks"

# Archive old entries
.\archive-reflections.ps1 -OlderThan 180 -DryRun
```

**Tool Usage Analysis:**
```powershell
# Track usage patterns
.\usage-heatmap-tracker.ps1 -Action report -TimeRange week

# Measure tool effectiveness
.\tool-effectiveness.ps1 -ToolName "deployment-risk-score"

# Daily review (MANDATORY)
.\daily-tool-review.ps1
```

---

### Documentation

**Auto-Documentation:**
```powershell
# Generate API docs
.\generate-api-docs.ps1 -ProjectPath . -Format swagger

# Generate component catalog
.\generate-component-catalog.ps1 -ProjectPath . -Format storybook

# Generate release notes
.\generate-release-notes.ps1 -Since v1.0.0
```

**Documentation Validation:**
```powershell
# Check freshness
.\doc-freshness.ps1 -MaxAge 90

# Lint documentation
.\doc-lint.ps1 -CheckLinks -CheckSpelling

# Get doc URLs
.\get-doc-url.ps1 -Topic "worktree" -Context
```

**Knowledge Base:**
```powershell
# Create project KB
.\create-project-kb.ps1 -ProjectPath . -OutputPath "kb.md"

# Upload to ClickUp
.\clickup-kb.ps1 -Action upload -Space "Brand2Boost"
```

---

### Infrastructure & DevOps

**Docker:**
```powershell
# Generate docker-compose
.\generate-docker-compose.ps1 -ProjectPath . -GenerateDockerfiles

# Optimize layers
.\docker-layer-optimizer.ps1 -Dockerfile "Dockerfile" -Suggest

# Security scan
.\docker-security-scanner.ps1 -Image "myapp:latest" -Severity high
```

**CI/CD:**
```powershell
# Generate CI pipeline
.\generate-ci-pipeline.ps1 -Provider github -ProjectType fullstack

# Toggle workflow triggers
.\toggle-workflow-triggers.ps1 -Mode manual -DryRun
```

**Cloud & Infrastructure:**
```powershell
# Generate Terraform
.\generate-infrastructure.ps1 -Provider terraform -ResourceType webapp

# Analyze cloud costs
.\analyze-cloud-costs.ps1 -Provider azure -TimeRange 30d

# Validate auto-scaling
.\auto-scaling-validator.ps1 -LoadTest -TargetMetric CPU
```

**Developer Experience:**
```powershell
# Onboard new developer
.\onboard-developer.ps1 -DeveloperName "John Doe" -SetupEnvironment

# Generate VS Code workspace
.\generate-vscode-workspace.ps1 -ProjectPath . -MultiRoot

# Generate debug configs
.\generate-debug-configs.ps1 -Scenario docker -IDE vscode
```

---

### Troubleshooting

**Build Errors:**
```powershell
# Diagnose error
.\diagnose-error.ps1 -ErrorMessage "CS0246: The type or namespace..."

# Fix all common issues
.\fix-all.ps1 -Path . -DryRun

# Format C# code
.\cs-format.ps1 -Path . -Fix
```

**Encoding Issues:**
```powershell
# Detect encoding problems
.\detect-encoding-issues.ps1 -ProjectPath . -Recursive

# Fix UTF-16 files
.\fix-utf16-files.ps1 -Path . -Convert
```

**Git Issues:**
```powershell
# Validate pool consistency
.\pool-validate.ps1 -Fix

# Clean orphaned worktrees
.\worktree-cleanup.ps1 -Force
```

**System Health:**
```powershell
# Full health check
.\system-health.ps1 -Fix -Detailed

# Numeric health score
.\system-health-score.ps1 -Threshold 80

# Environment validation
.\health-check.ps1 -Full -Fix
```

---

## 🔍 By Problem Type

### "I Need To..."

| Need | Tool(s) |
|------|---------|
| **...start a new feature** | `detect-mode.ps1` → `worktree-allocate.ps1 -Paired` |
| **...create a PR** | `pr-preflight.ps1` → `pr-description-enforcer.ps1` → `worktree-release-all.ps1` |
| **...deploy safely** | `deployment-risk-score.ps1` → `config-validator.ps1` → `validate-deployment.ps1` |
| **...find what to refactor** | `code-hotspot-analyzer.ps1` → `unused-code-detector.ps1` |
| **...fix flaky tests** | `flaky-test-detector.ps1 -Iterations 10` |
| **...prevent build failures** | `ef-preflight-check.ps1` → `pr-preflight.ps1` |
| **...generate an image** | `ai-image.ps1 -Prompt "..." -OutputPath "..."` |
| **...analyze a screenshot** | `ai-vision.ps1 -Images @("screenshot.png") -Prompt "..."` |
| **...coordinate with other agents** | `monitor-activity.ps1 -Mode claude` → `agent-work-queue.ps1` |
| **...save my work context** | `context-snapshot.ps1 -Action Save -Notes "..."` |
| **...find past solutions** | `pattern-search.ps1 -Query "..."` |
| **...validate configuration** | `config-validator.ps1 -CheckSecrets` |
| **...generate documentation** | `generate-api-docs.ps1` / `adr-generator.ps1` |
| **...optimize performance** | `code-hotspot-analyzer.ps1` → `n-plus-one-query-detector.ps1` |
| **...check test coverage** | `test-coverage-report.ps1 -Threshold 80` |

---

## ⚠️ Common Mistakes & Solutions

| Mistake | Prevention Tool | When to Use |
|---------|----------------|-------------|
| **Forgot to run migration** | `ef-preflight-check.ps1` | Before every commit |
| **PR to wrong base branch** | `validate-pr-base.ps1` | Before creating PR |
| **Deployed with high risk** | `deployment-risk-score.ps1` | Before deployment |
| **Committed secrets** | `scan-secrets.ps1` | Pre-commit hook |
| **Config drift production** | `detect-config-drift.ps1` | Weekly check |
| **Flaky test merged** | `flaky-test-detector.ps1` | During PR review |
| **Performance regression** | `performance-regression-detector.ps1` | CI pipeline |
| **Forgot to release worktree** | `worktree-status.ps1` | End of session |
| **Breaking API change** | `api-breaking-change-detector.ps1` | Before PR |
| **Low test coverage** | `test-coverage-diff.ps1` | CI gate |

---

## 📈 Workflow Examples

### Complete Feature Development Workflow

```powershell
# 1. Detect mode
.\detect-mode.ps1 -UserMessage "Implement PDF export" -Analyze

# 2. Allocate paired worktrees
.\worktree-allocate.ps1 -Repo client-manager -Branch feature/pdf-export -Paired

# 3. [DO THE WORK]

# 4. Pre-flight checks
.\ef-preflight-check.ps1 -Context AppDbContext
.\cs-format.ps1 -Path . -Fix
.\pr-preflight.ps1 -CheckBuild

# 5. Create PR
.\pr-description-enforcer.ps1 -Action generate
gh pr create --title "..." --body "..."

# 6. Release worktrees
.\worktree-release-all.ps1 -AutoCommit

# 7. Reflect
.\reflect.ps1 -Tag "FEATURE" -Message "Implemented PDF export, learned X"
```

### Safe Deployment Workflow

```powershell
# 1. Calculate risk
$risk = .\deployment-risk-score.ps1 -Threshold 70

if ($risk.Score -lt 70) {
    # 2. Validate configuration
    .\config-validator.ps1 -CheckSecrets -Environment production

    # 3. Validate environment
    .\env-var-validator.ps1 -Environment production

    # 4. Pre-deploy validation
    .\validate-deployment.ps1 -Environment production

    # 5. Deploy
    .\deploy.ps1 -Environment production

    # 6. Monitor
    .\monitor-service-health.ps1 -Endpoints "https://api.example.com/health"
} else {
    Write-Host "RISK TOO HIGH - Deployment blocked" -ForegroundColor Red
}
```

### Code Quality Improvement Workflow

```powershell
# 1. Find refactoring targets
.\code-hotspot-analyzer.ps1 -Since "3 months ago" | Tee-Object -Variable hotspots

# 2. Find unused code
.\unused-code-detector.ps1 -MinConfidence 7 | Tee-Object -Variable unused

# 3. Detect performance issues
.\n-plus-one-query-detector.ps1 | Tee-Object -Variable perfIssues

# 4. Get AI recommendations
.\llm-code-reviewer.ps1 -Path . -Suggestions

# 5. Create tasks for each issue
foreach ($hotspot in $hotspots) {
    .\clickup-sync.ps1 -Action create -Title "Refactor: $($hotspot.File)"
}
```

---

## 🎯 Decision Trees

### "Which Tool Should I Use?"

```
Need to work on code?
├─ Multiple agents? → monitor-activity.ps1 -Mode claude
│  ├─ Yes → agent-work-queue.ps1
│  └─ No → Continue
│
├─ Feature or Debug?
│  ├─ Feature → worktree-allocate.ps1
│  └─ Debug → Work in base repo
│
└─ Need to commit?
   ├─ EF Core project? → ef-preflight-check.ps1
   ├─ Secrets scan? → scan-secrets.ps1
   ├─ Format code? → cs-format.ps1
   └─ Create PR? → pr-preflight.ps1
```

### "How to Prevent This Issue?"

```
Issue occurred?
├─ Build failure → ef-preflight-check.ps1, pr-preflight.ps1
├─ Flaky test → flaky-test-detector.ps1
├─ Performance regression → performance-regression-detector.ps1
├─ Config drift → detect-config-drift.ps1
├─ Breaking change → api-breaking-change-detector.ps1
├─ High deployment risk → deployment-risk-score.ps1
└─ Other → diagnose-error.ps1
```

---

## 💡 Power User Tips

1. **Use JSON output for scripting:**
   ```powershell
   $context = .\monitor-activity.ps1 -Mode context -OutputFormat json | ConvertFrom-Json
   ```

2. **Chain tools with PowerShell:**
   ```powershell
   .\deployment-risk-score.ps1; .\config-validator.ps1; .\validate-deployment.ps1
   ```

3. **Always use -DryRun first:**
   ```powershell
   .\cleanup-stale-branches.ps1 -DryRun  # Preview changes
   .\cleanup-stale-branches.ps1          # Then execute
   ```

4. **Leverage tool composition:**
   ```powershell
   .\tool-compose.ps1 -Tools @("code-hotspot-analyzer", "unused-code-detector", "llm-code-reviewer")
   ```

5. **Save common workflows:**
   ```powershell
   # Create alias in profile
   function SafeDeploy { .\deployment-risk-score.ps1; .\config-validator.ps1; .\deploy.ps1 -Environment $args[0] }
   ```

---

**Last Updated:** 2026-01-25
**Total Scenarios:** 50+
**Remember:** When in doubt, use `.\find-tool.ps1 -Query "your need"` or check `tools-library.md`
