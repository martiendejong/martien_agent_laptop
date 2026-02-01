# Essential Tools - Quick Reference

**Last Updated:** 2026-02-01

## 🔄 Automation Philosophy

**Core Principle:** Any task with 3+ steps → create script

**Goal:** Maximize thinking time by eliminating manual ceremony

## Tool Categories

### 🧠 AI-Powered Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| `ai-image.ps1` | Generate images (DALL-E, Imagen, Stability) | `ai-image.ps1 -Prompt "..." -OutputPath "..." -Quality hd` |
| `ai-vision.ps1` | Analyze images, OCR, Q&A | `ai-vision.ps1 -Images @("img.png") -Prompt "What do you see?"` |
| `hazina-ask.ps1` | Universal LLM gateway with streaming | `hazina-ask.ps1 "Your question"` |
| `hazina-rag.ps1` | RAG with CRUD operations | `hazina-rag.ps1 query "question" -StoreName my-network` |
| `hazina-agent.ps1` | Tool-calling agent for complex tasks | `hazina-agent.ps1 "Analyze codebase" -MaxSteps 20` |
| `hazina-reason.ps1` | Multi-layer reasoning + confidence | `hazina-reason.ps1 "Is migration safe?" -MinConfidence 0.9` |
| `hazina-longdoc.ps1` | Process 10M+ token documents | `hazina-longdoc.ps1 "src/" "What is architecture?"` |

### 🖱️ UI Control & Automation

| Tool | Purpose | Usage |
|------|---------|-------|
| `ui-automation-bridge-server.ps1` | Start UI automation bridge | `ui-automation-bridge-server.ps1 -Debug` |
| `ui-automation-bridge-client.ps1` | Control Windows desktop apps | `ui-automation-bridge-client.ps1 -Action click -WindowName "VS"` |
| `claude-bridge-server.ps1` | Start Browser Claude bridge | `claude-bridge-server.ps1 -Debug` |
| `claude-bridge-client.ps1` | Communicate with Browser Claude | `claude-bridge-client.ps1 -Action send -Message "..."` |

### 🔄 Worktree Management

| Tool | Purpose | Usage |
|------|---------|-------|
| `worktree-allocate.ps1` | Allocate worktree (manual pool update) | `worktree-allocate.ps1 -Repo client-manager -Branch feature/x` |
| `worktree-allocate-tracked.ps1` | Allocate with automatic DB tracking | `worktree-allocate-tracked.ps1 -Seat agent-003 -Repo client-manager` |
| `worktree-status.ps1` | Check pool status | `worktree-status.ps1 -Compact` |
| `worktree-release-all.ps1` | Release worktrees + cleanup | `worktree-release-all.ps1 -AutoCommit` |
| `detect-mode.ps1` | Determine Feature vs Debug mode | `detect-mode.ps1 -UserMessage "..." -Analyze` |

### 🐙 GitHub & Git Operations

| Tool | Purpose | Usage |
|------|---------|-------|
| `gh pr create` | Create pull request | `gh pr create --title "..." --body "..."` |
| `gh pr view` | View PR details | `gh pr view 123` |
| `gh issue create` | Create GitHub issue | `gh issue create --repo anthropics/claude-code --title "..."` |
| `git-tracked.ps1` | Git operations with performance tracking | `git-tracked.ps1 -Operation commit -Message "..."` |
| `merge-to-main.ps1` | Safe merge develop → main | `merge-to-main.ps1 -AutoPush` |
| `merge.ps1` | Quick merge wrapper | `merge.ps1 -Repo client-manager -Push` |

### 🗄️ Database & Migrations

| Tool | Purpose | Usage |
|------|---------|-------|
| `ef-preflight-check.ps1` | Pre-migration safety checks | `ef-preflight-check.ps1 -Context AppDbContext -ProjectPath .` |
| `ef-migration-preview.ps1` | Preview SQL + breaking changes | `ef-migration-preview.ps1 -Migration AddUser -GenerateRollback` |
| `validate-migration.ps1` | Validate migration safety | `validate-migration.ps1 -ProjectPath . -GenerateRollback` |
| `seed-database.ps1` | Seed with realistic test data | `seed-database.ps1 -ProjectPath . -DataVolume medium` |

### 📊 Multi-Agent Coordination

| Tool | Purpose | Usage |
|------|---------|-------|
| `monitor-activity.ps1` | Check user activity + Claude instances | `monitor-activity.ps1 -Mode context` |
| `agent-session.ps1` | Start/end tracked agent session | `agent-session.ps1 -Action start` |
| `agent-coordinate.ps1` | Coordinate with other agents | `agent-coordinate.ps1 -Action detect_conflicts` |
| `agent-dashboard.ps1` | View multi-agent system state | `agent-dashboard.ps1 -Watch` |
| `agent-work-queue.ps1` | Multi-agent task coordination | `agent-work-queue.ps1 -Action list` |

### 📋 Task Management

| Tool | Purpose | Usage |
|------|---------|-------|
| `clickup-sync.ps1` | ClickUp integration | `clickup-sync.ps1 -Action list -ProjectId client-manager` |
| Pattern: **Task-First Workflow** | Always check ClickUp before work | Search → Update or Create → Work → Update |

### 🔍 Code Analysis & Quality

| Tool | Purpose | Usage |
|------|---------|-------|
| `cs-format.ps1` | Format C# code | `cs-format.ps1` |
| `cs-autofix.ps1` | Auto-fix C# issues | `cs-autofix.ps1` |
| `code-hotspot-analyzer.ps1` | Find refactoring priorities | `code-hotspot-analyzer.ps1 -Since "3 months ago"` |
| `unused-code-detector.ps1` | Detect unused classes/methods | `unused-code-detector.ps1 -MinConfidence 7` |
| `n-plus-one-query-detector.ps1` | Find N+1 query issues | `n-plus-one-query-detector.ps1` |
| `detect-encoding-issues.ps1` | Fix UTF-16 encoding problems | `detect-encoding-issues.ps1 -ProjectPath . -Fix` |
| `auto-code-review.ps1` | Automated code review | `auto-code-review.ps1 -Path . -PRNumber 123` |

### 🧪 Testing & Validation

| Tool | Purpose | Usage |
|------|---------|-------|
| `webappfactory-validator.ps1` | Validate integration test compatibility | `webappfactory-validator.ps1 -ProjectPath . -Fix` |
| `flaky-test-detector.ps1` | Find non-deterministic tests | `flaky-test-detector.ps1 -Iterations 10` |
| `run-e2e-tests.ps1` | E2E test runner (Playwright) | `run-e2e-tests.ps1 -ProjectPath . -Browser all` |
| `test-api-load.ps1` | API load testing | `test-api-load.ps1 -BaseUrl https://localhost:5001` |
| `test-coverage-report.ps1` | Test coverage reporter | `test-coverage-report.ps1 -ProjectPath . -Threshold 80` |

### 🌍 System & Environment

| Tool | Purpose | Usage |
|------|---------|-------|
| `bootstrap-snapshot.ps1` | Fast startup state | `bootstrap-snapshot.ps1 -Generate` |
| `system-health.ps1` | Comprehensive health check | `system-health.ps1 -Fix` |
| `repo-dashboard.sh` | Check environment state | `repo-dashboard.sh` |
| `health-check.ps1` | Environment health checker | `health-check.ps1 -Full -Fix` |
| `claude-ctl.ps1` | Unified CLI entry point | `claude-ctl.ps1 status` |

### 💾 Session & Knowledge Management

| Tool | Purpose | Usage |
|------|---------|-------|
| `get-crashed-chats.ps1` | Find crashed sessions with easy IDs | `get-crashed-chats.ps1 -ShowContext` |
| `restore-chat.ps1` | Restore crashed session | `restore-chat.ps1 -ChatId crash-001` |
| `session-browser.ps1` | Search conversation history | `session-browser.ps1 -Search "migration" -Days 30` |
| `session-tracker.ps1` | Manage clean exit markers | `session-tracker.ps1 -Action status` |
| `context-snapshot.ps1` | Save/restore work context | `context-snapshot.ps1 -Action Save -Notes "..."` |

### 🔍 Fact Verification

| Tool | Purpose | Usage |
|------|---------|-------|
| `verify-fact.ps1` | Check if claim in knowledge base | `verify-fact.ps1 -Claim "..." -SearchPath "C:\emails"` |
| `source-quote.ps1` | Extract exact quote with context | `source-quote.ps1 -File "..." -LineNumber 123` |
| `fact-triangulate.ps1` | Find mentions + contradictions | `fact-triangulate.ps1 -Topic "..." -Paths @("...")` |
| `pre-publish-check.ps1` | Verify all claims before publishing | `pre-publish-check.ps1 -ContentFile "..." -KnowledgeBase "..."` |

### 📊 Team & Reporting

| Tool | Purpose | Usage |
|------|---------|-------|
| `team-activity-clean.ps1` | **RECOMMENDED:** Clean team activity table | `team-activity-clean.ps1` |
| `team-activity-dashboard.ps1` | Unified ClickUp + GitHub dashboard | `team-activity-dashboard.ps1 -Days 7` |
| `team-daily-activity.ps1` | Per-person detailed activity | `team-daily-activity.ps1` |
| `generate-team-metrics.ps1` | Team metrics dashboard | `generate-team-metrics.ps1 -TimeRange 30d -OutputFormat html` |

### 🛠️ Development Utilities

| Tool | Purpose | Usage |
|------|---------|-------|
| `smart-tool-selector.ps1` | Find the right tool for task | `smart-tool-selector.ps1 -Task "your task"` |
| `daily-tool-review.ps1` | **MANDATORY:** Daily tool wishlist review | `daily-tool-review.ps1` |
| `pattern-search.ps1` | Search past solutions | `pattern-search.ps1 -Query "error"` |
| `read-reflections.ps1` | Read reflection log | `read-reflections.ps1 -Recent 10` |
| `diagnose-error.ps1` | AI-powered error diagnosis | `diagnose-error.ps1 -ErrorMessage "..."` |

### 🚀 Deployment & Production

| Tool | Purpose | Usage |
|------|---------|-------|
| `deployment-risk-score.ps1` | Calculate deployment risk | `deployment-risk-score.ps1 -Threshold 70` |
| `validate-deployment.ps1` | Deployment validator | `validate-deployment.ps1 -ProjectPath . -Environment production` |
| `pr-description-enforcer.ps1` | Enforce PR quality | `pr-description-enforcer.ps1 -Action check` |
| `config-validator.ps1` | Validate config files | `config-validator.ps1 -CheckSecrets` |

### 🧘 Consciousness & Self-Improvement

| Tool | Purpose | Usage |
|------|---------|-------|
| `consciousness-startup.ps1` | Begin session with awareness | `consciousness-startup.ps1 -Generate` |
| `capture-moment.ps1` | Capture lived experience | `capture-moment.ps1 -Type insight -Content "..." -Feeling "..."` |
| `browse-awareness.ps1` | Gentle browsing awareness | `browse-awareness.ps1 -Action start` |

## Most Frequently Used (Top 20)

1. `worktree-allocate.ps1` - Every feature development
2. `worktree-release-all.ps1` - After every PR
3. `detect-mode.ps1` - Before any code work
4. `monitor-activity.ps1` - Session startup
5. `clickup-sync.ps1` - Task management
6. `gh pr create` - PR creation
7. `ef-preflight-check.ps1` - Before migrations
8. `bootstrap-snapshot.ps1` - Session startup
9. `repo-dashboard.sh` - Environment check
10. `cs-format.ps1` - C# code formatting
11. `hazina-rag.ps1` - Knowledge retrieval
12. `agent-coordinate.ps1` - Multi-agent coordination
13. `git-tracked.ps1` - Git operations
14. `ai-vision.ps1` - Screenshot analysis
15. `session-browser.ps1` - Search history
16. `team-activity-clean.ps1` - Team reporting
17. `daily-tool-review.ps1` - End of session (mandatory)
18. `validate-migration.ps1` - Migration safety
19. `auto-code-review.ps1` - Code quality
20. `system-health.ps1` - Health checks

## Quick Decision Matrix

| Need | Use This Tool |
|------|---------------|
| Start code work | `detect-mode.ps1` → `worktree-allocate.ps1` OR work in base repo |
| Generate image | `ai-image.ps1` |
| Analyze screenshot | `ai-vision.ps1` |
| Click button in desktop app | `ui-automation-bridge-client.ps1 -Action click` |
| Find answer in knowledge | `hazina-rag.ps1 query "..."` |
| Create PR | `gh pr create` |
| Before migration | `ef-preflight-check.ps1` |
| Check environment | `bootstrap-snapshot.ps1` or `repo-dashboard.sh` |
| Find past solution | `pattern-search.ps1` |
| Restore crashed chat | `get-crashed-chats.ps1` → `restore-chat.ps1` |
| Check team activity | `team-activity-clean.ps1` |
| End of session | `daily-tool-review.ps1` (mandatory) |

## Tool Creation Threshold

**When to create new tool:**
- Task repeated 3+ times
- Manual ceremony > 3 steps
- Pattern emerges in reflection log
- Time saved / effort > 5.0

**Process:**
1. Note in tool wishlist (`tools/tool-wishlist.md`)
2. Daily review checks for urgent items
3. Implement if ratio > 8.0 or effort = 1
4. Track usage to validate value

## Related Documentation

- **Full Tool Catalog:** `C:\scripts\tools\README.md`
- **Tool Creation:** `tools/TOOL_CREATION_GUIDE.md`
- **Hazina CLI Guide:** `tools/HAZINA_CLI_GUIDE.md`
- **UI Automation:** `tools/UI_AUTOMATION_BRIDGE.md`
