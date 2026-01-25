# Git Repositories - Complete Version Control Documentation

**Generated:** 2026-01-25
**Purpose:** Comprehensive documentation of all Git repositories, branches, worktrees, and version control configuration
**Scope:** All development repositories on this machine

---

## 📋 Table of Contents

1. [Repository Overview](#repository-overview)
2. [Base Repositories](#base-repositories)
3. [Worktree System](#worktree-system)
4. [Git Configuration](#git-configuration)
5. [Branch Strategies](#branch-strategies)
6. [Cross-References](#cross-references)

---

## 🗂️ Repository Overview

**Primary Development Repositories (4):**

| Repository | Location | Remote | Main Branch | Current Branch | Purpose |
|------------|----------|--------|-------------|----------------|---------|
| **client-manager** | `C:\Projects\client-manager` | `martiendejong/client-manager` | `main` | `feature/mvp-epic-5-integration-testing` | Brand2Boost SaaS application |
| **hazina** | `C:\Projects\hazina` | `martiendejong/Hazina` | `main` | `develop` | Framework/foundation library |
| **hydro-vision-website** | `C:\Projects\hydro-vision-website` | `martiendejong/hydro-vision-website` | `main` | `link_to_wordpress` | Hydro Vision WordPress website |
| **machine_agents** | `C:\scripts` | `martiendejong/machine_agents` | `main` | `main` | Claude agent control plane |

**Supporting Projects (100+):**
- Located in `C:\Projects\*`
- Various personal/experimental repositories
- See [Projects folder listing](#projects-folder-listing) below

---

## 📦 Base Repositories

### 1. client-manager (Brand2Boost)

**Repository Details:**
- **Location:** `C:\Projects\client-manager`
- **Remote:** `https://github.com/martiendejong/client-manager.git`
- **Type:** Full-stack SaaS application (ASP.NET Core + React)
- **Main Branch:** `main` (but develop-based workflow)
- **Current Branch:** `feature/mvp-epic-5-integration-testing`

**Branch Structure:**
```
Main branches:
  main            - Production releases
  develop         - Integration branch (primary development)

Feature branches (97 total):
  Activity-flash-when-switching-projects
  Generating-message-in-chat
  agent-001-architectural-improvements
  agent-001-deprecate-bat-files
  agent-001-orchestrator-integration (worktree: agent-001)
  agent-001-publish-scripts-migration
  agent-001-user-cost-tracking
  agent-002-50-expert-improvements
  agent-002-ai-dynamic-actions
  agent-002-fix-activity-flash
  agent-002-fix-activity-timestamp
  agent-002-fix-activity-timestamp-develop
  agent-002-fix-profiles-route
  agent-002-framework-url-enrichment
  agent-002-frontend-refactoring-phase1
  agent-002-frontend-refactoring-phase2
  agent-002-frontend-refactoring-phase3
  agent-002-frontend-refactoring-phase4
  agent-002-language-per-project
  agent-002-layered-image-integration (worktree: agent-002)
  agent-002-nexus-visual-migration-plan
  agent-002-phase2-3-modal-editors
  agent-002-phase3-versioning-bundles
  agent-002-reddit-create-post
  agent-002-round3-top20
  agent-002-round5-uiux
  agent-002-tumblr-create-post
  agent-002-unified-field-catalog
  agent-002-week1-quick-wins
  agent-002-wordpress-content-import
  agent-002-wordpress-integration
  agent-003-ai-dynamic-actions
  agent-003-context-aware-sidebar
  agent-003-context-aware-sidebar-phase2
  agent-003-fix-all-test-failures (worktree: agent-003)
  agent-003-hangfire-security-comprehensive
  agent-003-image-upload-fix
  agent-003-layout-perfection-top10
  agent-003-loading-animation-complete-fix
  agent-003-registry-integration
  agent-003-round5-part2
  agent-003-signalr-improvement
  agent-003-snapchat-create-post
  agent-003-url-content-extraction
  agent-003-user-ui-language
  agent-004-backend-genericness
  agent-004-complete-dtos
  agent-004-docfx-integration
  agent-004-fix-activities-list-update
  agent-004-pinterest-create-post
  agent-004-round4-top25
  agent-005-extract-chat-controllers
  agent-005-extract-chat-guidance
  agent-007-typescript-cleanup

  feature/869brntyj-chat-url-routing
  feature/869btgw94-dual-language-settings
  feature/869btq487-legal-pages-links
  feature/869bu91d8-pr-template
  feature/869bu91dn-code-review-guide
  feature/869bu9cnd-account-settings-scroll
  feature/869bucvk2-token-balance-userprofile
  feature/869bueb3q-activity-project-scoping
  feature/869buxcru-wordpress-incremental-sync
  feature/869buxcv6-wordpress-batch-import
  feature/869buxczc-wordpress-error-handling
  feature/869bverkf-analysis-search-nav
  feature/869bvf2xa-image-lightbox
  feature/869bvf38q-chat-image-display
  feature/869bvw9wd-typing-indicator-fix
  feature/actions-json-refactor
  feature/chat-id-url-routing
  feature/chat-token-verification
  feature/db-connection-pooling
  feature/environment-variables
  feature/facebook-instagram-auth-fix
  feature/github-secrets-deployment
  feature/mvp-epic-3-workflow-engine
  feature/mvp-epic-4-core-workflow
  feature/mvp-epic-5-integration-testing (current)
  feature/restaurant-menu
  feature/unified-social-settings

  bugfix/blog-category-modelselector-missing
  bugfix/react-dom-client-undefined-S

  fix/869bvervf-missing-translations
  fix/create-website-variable-mismatch
  fix/develop-issues-systematic
  fix/imageset-signalr-loading
  fix/prompts-frontend-display

  test/fix-frontend-unit-tests
```

**Recent Commits (Last 10):**
```
bd5c2f89 docs: Add Master MVP Implementation Plan - Complete synthesis of all 5 epics
d0b01946 docs: Add Epic 5 Integration & Testing MVP implementation breakdown
2c0f5b96 test: Add Playwright E2E testing infrastructure (Phase 2 - Task 1)
5a917b81 feat: Add integrated development dashboard (Phase 1 - Quick Wins)
e9832a54 fix: Correct Sentry configuration for v6.0.0 API
9ec16d0a test: Add 30 critical path integration tests (Phase 1 - Quick Wins)
d2895d17 perf: Optimize Vite HMR configuration for <1 second feedback loop
d2257206 feat: Sentry error monitoring (Phase 1 - Quick Wins)
5c748857 fix problem with hangfire db (occurred after merging the hangfire security fix)
a8b1c8fe add example secrets file
```

**Uncommitted Changes:**
```
?? ClientManagerFrontend/playwright-report/
?? ClientManagerFrontend/test-results/
```

**Worktrees (3 active):**
```
C:/Projects/client-manager                          bd5c2f89 [feature/mvp-epic-5-integration-testing] (BASE)
C:/Projects/worker-agents/agent-001/client-manager  b70520a5 [agent-001-orchestrator-integration]
C:/Projects/worker-agents/agent-002/client-manager  a417384d [agent-002-layered-image-integration]
C:/Projects/worker-agents/agent-003/client-manager  18d77a21 [agent-003-fix-all-test-failures]
```

---

### 2. hazina (Framework)

**Repository Details:**
- **Location:** `C:\Projects\hazina`
- **Remote:** `https://github.com/martiendejong/Hazina`
- **Type:** .NET framework/library (ASP.NET Core components)
- **Main Branch:** `main`
- **Current Branch:** `develop`

**Branch Structure:**
```
Main branches:
  main            - Stable releases
  develop         - Active development (current)

Feature branches (55 total):
  Generating-message-in-chat
  agent-002-ai-dynamic-actions
  agent-002-docfx-integration
  agent-002-framework-url-enrichment
  agent-002-frontend-refactoring-phase1
  agent-002-frontend-refactoring-phase2
  agent-002-frontend-refactoring-phase3
  agent-002-layered-image-enhanced (worktree: agent-002)
  agent-002-layered-image-tool
  agent-002-reddit-create-post
  agent-002-tumblr-create-post
  agent-002-wordpress-content-import
  agent-002-wordpress-integration
  agent-003-ai-dynamic-actions
  agent-003-ai-native-stack
  agent-003-context-aware-sidebar
  agent-003-context-aware-sidebar-phase2
  agent-003-fix-all-test-failures (worktree: agent-003)
  agent-003-github-pages-deployment
  agent-003-hangfire-security-comprehensive
  agent-003-image-upload-fix
  agent-003-incremental-sync
  agent-003-loading-animation-complete-fix
  agent-003-provider-registry
  agent-003-registry-integration
  agent-003-signalr-improvement
  agent-003-snapchat-create-post
  agent-003-test-infrastructure
  agent-003-wordpress-batch
  agent-004-backend-genericness
  agent-004-complete-dtos
  agent-004-pdok-integration
  agent-004-pinterest-create-post
  agent-004-split-agentfactory
  agent-005-extract-chat-controllers
  agent-005-extract-chat-guidance

  docs/xml-documentation

  feature/869bucvk2-token-balance
  feature/869bucvk2-token-balance-userprofile
  feature/869bueb3q-activity-project-scoping
  feature/869buxczc-wordpress-error-handling
  feature/coding-standards-analyzers
  feature/dynamic-api (worktree: agent-004)
  feature/generic-api-demo
  feature/hazina-coder-cli
  feature/hazinacoder-agentic-loop (worktree: agent-005)
  feature/metamodel-report-system
  feature/workflow-v2-phase1-foundation
  feature/workflow-v2-phase1-week2-engine
  feature/workflow-v2-phase1-week3-guardrails
  feature/workflow-v2-phase1-week4-testing

  fix/chat-llm-config-loading

  pr-76
  pr-77
```

**Recent Commits (Last 10):**
```
d28e1d5 fixes quick setup project
b2d419d Merge pull request #116 from martiendejong/main
11612f1 Merge pull request #115 from martiendejong/feature/dynamic-api
d89dc92 feat(api): Add zero-code Dynamic API and Code Generator
c81853d Merge pull request #114 from martiendejong/feature/generic-api-demo
6770ff0 feat(demo): Add Hazina.Demo.GenericApi - Document storage with semantic search
71d533a Merge pull request #113 from martiendejong/aspnetgenerics
64ced45 feat(api): Add Hazina.API.Generic - Convention-over-configuration CRUD framework
70f5970 Merge pull request #112 from martiendejong/agent-003-incremental-sync
480e98f Merge pull request #110 from martiendejong/agent-002-layered-image-enhanced
```

**Uncommitted Changes:**
```
(clean)
```

**Worktrees (4 active):**
```
C:/Projects/hazina                          d28e1d5 [develop] (BASE)
C:/Projects/worker-agents/agent-002/hazina  7d6f74e [agent-002-layered-image-enhanced]
C:/Projects/worker-agents/agent-003/hazina  d28e1d5 [agent-003-fix-all-test-failures]
C:/Projects/worker-agents/agent-004/hazina  d89dc92 [feature/dynamic-api]
C:/Projects/worker-agents/agent-005/hazina  9ca3e17 [feature/hazinacoder-agentic-loop]
```

**Key Features:**
- Used as a submodule/package by client-manager
- Foundation library for framework components
- Dynamic API and generic CRUD framework
- Semantic search and document storage

---

### 3. hydro-vision-website

**Repository Details:**
- **Location:** `C:\Projects\hydro-vision-website`
- **Remote:** `https://github.com/martiendejong/hydro-vision-website.git`
- **Type:** React website with WordPress integration
- **Main Branch:** `main`
- **Current Branch:** `link_to_wordpress`

**Branch Structure:**
```
Main branches:
  main                - Production site
  link_to_wordpress   - WordPress CMS integration (current)

Feature branches:
  agent-003-about-rewrite
  agent-003-blue-rebrand
  agent-003-color-consistency
  agent-003-fix-transparent-images
  agent-003-footer-logo
  agent-003-header-padding
  agent-003-slogan-color-fix
  agent-003-update-contact-info
```

**Recent Commits (Last 10):**
```
cd96b6c feat: Complete WordPress headless CMS integration
a18f581 docs: add comprehensive WordPress production setup guide
c9f8585 feat: integrate Hero component with WordPress CMS
9854008 fix: use custom_fields instead of acf in WordPress API
a8e3c1d docs: add comprehensive WordPress integration completion status
520c7d3 feat: integrate ProductWaterfilter detail page with WordPress REST API
ef474c0 feat: integrate ProductOverview with WordPress REST API
6348f5f feat: integrate About page with WordPress REST API
ca26b1a feat: integrate Services page with WordPress REST API
c87cc56 feat: integrate WordPress headless CMS with REST API
```

**Uncommitted Changes:**
```
(clean)
```

**Worktrees:**
```
C:/Projects/hydro-vision-website  cd96b6c [link_to_wordpress] (BASE only - no agent worktrees)
```

**Status:** Completed WordPress headless CMS integration

---

### 4. machine_agents (Control Plane)

**Repository Details:**
- **Location:** `C:\scripts`
- **Remote:** `https://github.com/martiendejong/machine_agents.git`
- **Type:** Claude agent control plane and tooling
- **Main Branch:** `main`
- **Current Branch:** `main`

**Branch Structure:**
```
Main branches:
  main - Single-branch workflow (no develop)
```

**Recent Commits (Last 10):**
```
824c63a checkpoint before agent session
1944c03 chore: Release agent-004 after PR #357 (fix activities list update)
e17960e docs: Wave 3 meta-optimization insights and philosophy
0b5b25e docs: Complete Wave 3 documentation - comprehensive tools catalog and best practices
b4f20c0 checkpoint before agent session
43a6fe4 checkpoint before agent session
73cbb73 feat: Wave 3 Tier A COMPLETE (23/23) - All Tier A tools implemented! 🎉
3b6b507 reflection: Add CLI tools session entry (200 tools, disk space learning)
44066e7 reflection: Document WordPress headless CMS integration success
e839ace feat: Wave 3 Tier A tools (10/23) - Second batch complete
```

**Uncommitted Changes:**
```
 M .gitignore
?? _machine/knowledge-base/
```
*(Current knowledge base generation in progress)*

**Worktrees:**
```
C:/scripts  824c63a [main] (BASE only - no agent worktrees)
```

**Purpose:**
- Agent documentation (CLAUDE.md, skills, protocols)
- Productivity tools (117 PowerShell scripts)
- Worktree pool management
- Machine-specific configuration
- Reflection and activity logs

---

## 🔧 Worktree System

### Overview

**Purpose:** Enable multiple agents to work on different features simultaneously without conflicts.

**Architecture:**
- **Base Repository** (`C:\Projects\<repo>`) - Stays on main/develop branch, read-only for code edits
- **Worktrees** (`C:\Projects\worker-agents\agent-XXX\<repo>`) - Isolated working directories per agent

### Seat Pool Status

**Location:** `C:\scripts\_machine\worktrees.pool.md`

| Seat | Status | Repository | Branch | Last Activity | Notes |
|------|--------|------------|--------|---------------|-------|
| **agent-001** | BUSY | client-manager | agent-001-orchestrator-integration | 2026-01-16T15:00:00Z | 🚧 Week 1-2: Integrating BackgroundTaskOrchestrator |
| **agent-002** | BUSY | hazina+client-manager+artrevisionist | agent-002-layered-image-* | 2026-01-21T02:00:00Z | 🚧 LayeredImageTool: Multi-repo feature |
| **agent-003** | BUSY | client-manager+hazina | agent-003-fix-all-test-failures | 2026-01-25T16:50:00Z | 🚧 Fix all 43 failing tests |
| **agent-004** | FREE | - | - | 2026-01-25T16:02:02Z | ✅ PR #357: Fix activities list |
| **agent-005** | FREE | - | - | 2026-01-24T02:15:00Z | ✅ PR #111: Continuation hooks test suite |
| **agent-006** | FREE | - | - | 2026-01-20T03:00:00Z | ✅ Code Review Guide |
| **agent-007** | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Security hardening |
| **agent-008** | FREE | - | - | 2026-01-09T23:30:00Z | ✅ Content hooks generation |
| **agent-009** | FREE | - | - | 2026-01-10T14:30:00Z | ✅ Cleaned up |
| **agent-010** | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up |
| **agent-011** | FREE | - | - | 2026-01-10T16:00:00Z | ✅ License back button |
| **agent-012** | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up |

**Capacity:** 12 seats total, 3 currently BUSY (75% free)

### Active Worktrees

**client-manager:**
```
Base:      C:/Projects/client-manager                          bd5c2f89 [feature/mvp-epic-5-integration-testing]
Worktree:  C:/Projects/worker-agents/agent-001/client-manager  b70520a5 [agent-001-orchestrator-integration]
Worktree:  C:/Projects/worker-agents/agent-002/client-manager  a417384d [agent-002-layered-image-integration]
Worktree:  C:/Projects/worker-agents/agent-003/client-manager  18d77a21 [agent-003-fix-all-test-failures]
```

**hazina:**
```
Base:      C:/Projects/hazina                          d28e1d5 [develop]
Worktree:  C:/Projects/worker-agents/agent-002/hazina  7d6f74e [agent-002-layered-image-enhanced]
Worktree:  C:/Projects/worker-agents/agent-003/hazina  d28e1d5 [agent-003-fix-all-test-failures]
Worktree:  C:/Projects/worker-agents/agent-004/hazina  d89dc92 [feature/dynamic-api]
Worktree:  C:/Projects/worker-agents/agent-005/hazina  9ca3e17 [feature/hazinacoder-agentic-loop]
```

**hydro-vision-website:**
```
Base:      C:/Projects/hydro-vision-website  cd96b6c [link_to_wordpress]
(No active worktrees)
```

**machine_agents:**
```
Base:      C:/scripts  824c63a [main]
(No worktrees - single-agent control plane)
```

### Worktree Activity Log

**Location:** `C:\scripts\_machine\worktrees.activity.md`

**Recent allocations (last 5):**
```
2026-01-25T03:45:00Z — release — agent-003 — client-manager — agent-003-image-upload-fix
2026-01-25T02:20:00Z — allocate — agent-003 — client-manager+hazina — agent-003-image-upload-fix
2026-01-23T02:30:00Z — release — agent-003 — client-manager+hazina — agent-003-signalr-improvement
2026-01-22T04:15:00Z — release — agent-005 — hazina — feature/hazina-coder-cli
2026-01-21T23:30:00Z — release — agent-005 — client-manager — agent-005-extract-chat-controllers
```

**Total activity entries:** 50+ allocate/release operations logged

### Worktree Protocol

**See:** `C:\scripts\GENERAL_WORKTREE_PROTOCOL.md` for complete workflow

**Key Rules:**
1. ✅ **Always allocate** before code edits in Feature Development Mode
2. ✅ **Check conflicts** with `check-branch-conflicts.sh` before allocation
3. ✅ **Mark seat BUSY** immediately in pool.md (atomic lock)
4. ✅ **Log allocation** in worktrees.activity.md
5. ✅ **Release immediately** after PR creation
6. ✅ **Update pool.md** to FREE status after release

---

## ⚙️ Git Configuration

### Global Configuration

**Location:** `~/.gitconfig`

**User Identity:**
```ini
user.name=martiendejong
user.email=martiendejong2008@gmail.com
```

**Core Settings:**
```ini
core.whitespace=cr-at-eol
core.autocrlf=true          # Windows-style line endings (CRLF)
```

**Diff Tool:** Visual Studio DiffMerge
```ini
diff.tool=vsdiffmerge
diff.wserrorhighlight=none
difftool.prompt=true
difftool.vsdiffmerge.cmd="C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\vsdiffmerge.exe" "$LOCAL" "$REMOTE" //t
difftool.vsdiffmerge.keepbackup=false
```

**Merge Tool:** Visual Studio DiffMerge
```ini
merge.tool=vsdiffmerge
mergetool.prompt=true
mergetool.vsdiffmerge.cmd="C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\vsdiffmerge.exe" "$REMOTE" "$LOCAL" "$BASE" "$MERGED" //m
mergetool.vsdiffmerge.keepbackup=false
mergetool.vsdiffmerge.trustexitcode=true
```

**Alternative Tool:** Beyond Compare 5
```ini
difftool.bc.cmd="C:/Program Files/Beyond Compare 5/BCompare.exe" "$LOCAL" "$REMOTE"
mergetool.bc.cmd="C:/Program Files/Beyond Compare 5/BCompare.exe" "$LOCAL" "$REMOTE" "$BASE" "$MERGED"
```

**SourceTree (unused):**
```ini
difftool.sourcetree.cmd=''
mergetool.sourcetree.cmd=''
mergetool.sourcetree.trustexitcode=false
mergetool.sourcetree.keepbackup=false
```

### Repository-Specific Hooks

**Pre-commit hooks:**
- Located in `.git/hooks/pre-commit` (if installed)
- Managed by `C:\scripts\tools\pre-commit-hook.ps1`
- Zero-tolerance enforcement for worktree violations

**Installation:**
```powershell
C:\scripts\tools\pre-commit-hook.ps1 -Install -RepoPath C:\Projects\client-manager
```

---

## 🌳 Branch Strategies

### client-manager Strategy

**Main Branches:**
- `main` - Production releases (but primarily develop-based workflow)
- `develop` - Integration branch for all feature work

**Feature Branches:**
- `feature/<clickup-id>-<description>` - ClickUp-tracked features
- `feature/<description>` - Non-ClickUp features
- `agent-XXX-<feature>` - Agent-developed features

**Fix Branches:**
- `fix/<clickup-id>-<description>` - Bug fixes
- `bugfix/<description>` - Legacy bug fix format

**Test Branches:**
- `test/<description>` - Testing infrastructure

**Naming Patterns:**
```
feature/869brntyj-chat-url-routing      (ClickUp ID prefix)
feature/mvp-epic-5-integration-testing  (Epic-based)
agent-003-fix-all-test-failures         (Agent-developed)
fix/869bvervf-missing-translations      (Bug fix)
bugfix/react-dom-client-undefined-S     (Legacy format)
test/fix-frontend-unit-tests            (Test infrastructure)
```

**Workflow:**
1. Branch from `develop`
2. Feature development in worktree
3. PR to `develop`
4. CI/CD runs tests
5. Merge to `develop`
6. Periodic release to `main`

**Branch Count:**
- Local: 97 branches
- Remote: 39 branches
- Active agent branches: 3

---

### hazina Strategy

**Main Branches:**
- `main` - Stable releases
- `develop` - Active development (current working branch)

**Feature Branches:**
- `feature/<description>` - Framework features
- `agent-XXX-<feature>` - Agent-developed features
- `docs/<description>` - Documentation branches

**PR Branches:**
- `pr-76`, `pr-77` - Direct PR branches

**Naming Patterns:**
```
feature/dynamic-api                     (Feature)
feature/hazinacoder-agentic-loop        (Tool development)
agent-003-test-infrastructure           (Agent-developed)
docs/xml-documentation                  (Documentation)
pr-76                                   (PR branch)
```

**Workflow:**
1. Branch from `develop`
2. Feature development (often in worktree)
3. PR to `develop`
4. GitHub Actions CI
5. Merge to `develop`
6. Release to `main` when stable

**Branch Count:**
- Local: 55 branches
- Remote: 51 branches
- Active agent branches: 4

**Key Consideration:** Changes to hazina often require coordinated client-manager PRs

---

### hydro-vision-website Strategy

**Main Branches:**
- `main` - Production site
- No develop branch (simpler workflow)

**Feature Branches:**
- `link_to_wordpress` - Major WordPress integration (current)
- `agent-003-<feature>` - Agent-developed improvements

**Naming Patterns:**
```
link_to_wordpress                       (Major feature)
agent-003-about-rewrite                 (Agent improvement)
agent-003-blue-rebrand                  (Design update)
agent-003-update-contact-info           (Content update)
```

**Workflow:**
1. Branch from `main`
2. Feature development (usually single-agent)
3. PR to `main`
4. Deploy to production

**Branch Count:**
- Local: 9 branches
- Remote: 10 branches
- Active agent branches: 0 (WordPress integration complete)

**Status:** WordPress headless CMS integration recently completed

---

### machine_agents Strategy

**Main Branches:**
- `main` - Single-branch workflow

**No Feature Branches:**
- Direct commits to main
- Checkpoints before agent sessions
- Continuous documentation updates

**Commit Patterns:**
```
checkpoint before agent session                     (Session boundaries)
feat: Wave 3 Tier A tools (10/23)                  (Tool implementation)
docs: Complete Wave 3 documentation                 (Documentation)
reflection: Add CLI tools session entry            (Learning capture)
chore: Release agent-004 after PR #357             (Agent releases)
```

**Workflow:**
1. Edit directly on main branch
2. Commit frequently
3. Push after each session
4. No PRs (single-user control plane)

**Branch Count:**
- Local: 1 branch (main)
- Remote: 1 branch (main)

**Purpose:** Control plane repository, not production code

---

## 🔗 Cross-Repo Dependencies

### hazina → client-manager Dependency Flow

**Pattern:** Framework changes in hazina must merge BEFORE client-manager changes

**Tracking:** `C:\scripts\_machine\pr-dependencies.md`

**Example Dependency Chain:**
```
Hazina PR #115 (dynamic-api)
    ↓ MUST MERGE FIRST
client-manager PR #XXX (use dynamic-api)
```

**PR Template Format:**

**In client-manager PR:**
```markdown
## ⚠️ DEPENDENCY ALERT ⚠️

**This PR depends on the following Hazina PR(s):**
- [ ] https://github.com/martiendejong/Hazina/pull/XXX - [Brief description]

**Merge order:**
1. First merge the Hazina PR(s) above
2. Then merge this PR
```

**In hazina PR:**
```markdown
## ⚠️ DOWNSTREAM DEPENDENCIES ⚠️

**The following client-manager PR(s) depend on this:**
- https://github.com/martiendejong/client-manager/pull/YYY - [Brief description]

**Merge this PR first before the dependent PRs above.**
```

**Common Dependency Scenarios:**
1. New framework features in hazina → Used by client-manager
2. API changes in hazina → Client-manager updates
3. Tool additions in hazina → Client-manager integration
4. Bug fixes in hazina → Client-manager relies on fix

**See:** `C:\scripts\git-workflow.md` § Cross-Repo PR Dependencies

---

## 📊 Repository Statistics

### Branch Count Summary

| Repository | Local Branches | Remote Branches | Active Worktrees |
|------------|----------------|-----------------|------------------|
| client-manager | 97 | 39 | 3 |
| hazina | 55 | 51 | 4 |
| hydro-vision-website | 9 | 10 | 0 |
| machine_agents | 1 | 1 | 0 |
| **Total** | **162** | **101** | **7** |

### Commit Activity

**Recent commits across all repos (last 7 days):**
- client-manager: 10+ commits (MVP Epic 5 focus)
- hazina: 5+ commits (Dynamic API, generic CRUD)
- hydro-vision-website: 10 commits (WordPress integration)
- machine_agents: 10+ commits (Wave 3 tools, documentation)

### Uncommitted Changes

**client-manager:**
- Playwright test reports (untracked)
- Test results (untracked)

**machine_agents:**
- Modified: `.gitignore`
- Untracked: `_machine/knowledge-base/` (this document being generated)

**hazina:** Clean
**hydro-vision-website:** Clean

---

## 🗂️ Projects Folder Listing

**Additional repositories in `C:\Projects\`:**

**Personal Projects:**
- `aiexplorer` - AI exploration project
- `Aiteam` - AI team collaboration
- `artrevisionist` - Art revision application (has worktrees)
- `artrevisionist-wordpress` - WordPress integration
- `bugattiinsights` - Analytics project
- `corinaAI` - Corina AI assistant
- `mastermindgroupAI` - Mastermind group AI
- `neurochain` - Blockchain project
- `nexus-stream-74` - Streaming project
- `socialmediahulp` - Social media help
- `subdomainchecker` - Subdomain checking tool
- `VeraAI` - Vera AI assistant
- `woo-final-price` - WooCommerce pricing plugin

**Development Tools:**
- `AgenticDebuggerVsix` - Visual Studio extension
- `claudescripts` - Claude scripts
- `DevGPTTools` - DevGPT tools
- `examples` - Code examples
- `mcp-server-csharp-sdk` - MCP server SDK

**Websites:**
- `frankswebsite` - Frank's website
- `martiendejongnl` - Personal website
- `Looslaan` - Looslaan project
- `prospergenics` - Prospergenics site
- `socranext` - Socra next project
- `vloerenhuis` - Flooring house site
- `Wantam` - Wantam project

**Other:**
- `bezwaren` - Objections/appeals
- `bigquery` - BigQuery projects
- `courses` - Course materials
- `cv-matcher` - CV matching tool
- `game_ai` - Game AI
- `linkedinaicompilatie` - LinkedIn AI compilation
- `PathfindingAlgos` - Pathfinding algorithms
- Multiple document/CV files

**Total:** 100+ directories in Projects folder

---

## 📖 Cross-References

### Related Documentation

**Worktree System:**
- `C:\scripts\GENERAL_WORKTREE_PROTOCOL.md` - Complete worktree allocation/release protocol
- `C:\scripts\_machine\worktrees.pool.md` - Live seat pool status
- `C:\scripts\_machine\worktrees.activity.md` - Activity log
- `C:\scripts\.claude\skills\allocate-worktree\SKILL.md` - Allocation skill
- `C:\scripts\.claude\skills\release-worktree\SKILL.md` - Release skill

**Git Workflow:**
- `C:\scripts\git-workflow.md` - PR management and cross-repo dependencies
- `C:\scripts\_machine\pr-dependencies.md` - Active PR dependency tracking
- `C:\scripts\.claude\skills\github-workflow\SKILL.md` - GitHub operations skill
- `C:\scripts\.claude\skills\pr-dependencies\SKILL.md` - Dependency tracking skill

**Development Workflows:**
- `C:\scripts\GENERAL_DUAL_MODE_WORKFLOW.md` - Feature Development vs Active Debugging
- `C:\scripts\_machine\DEFINITION_OF_DONE.md` - Completion criteria
- `C:\scripts\development-patterns.md` - Implementation patterns

**Project Documentation:**
- `C:\Projects\client-manager\README.md` - Client-manager documentation
- `C:\Projects\hazina\README.md` - Hazina framework documentation
- `C:\Projects\client-manager\docs\` - Additional documentation

**Tools:**
- `C:\scripts\tools\worktree-allocate.ps1` - Automated allocation
- `C:\scripts\tools\worktree-release-all.ps1` - Automated release
- `C:\scripts\tools\worktree-status.ps1` - Pool status checker
- `C:\scripts\tools\check-branch-conflicts.sh` - Conflict detection
- `C:\scripts\tools\pre-commit-hook.ps1` - Zero-tolerance enforcement

### Knowledge Base Integration

**This document is part of:**
- `03-DEVELOPMENT/` - Development environment documentation
  - `git-repositories.md` (this file)
  - `development-tools.md`
  - `ci-cd-systems.md`
  - `testing-frameworks.md`

**Related sections:**
- `01-SYSTEM/hardware-software.md` - System configuration
- `01-SYSTEM/file-structure.md` - Directory structure
- `02-PROJECTS/client-manager.md` - Project details
- `02-PROJECTS/hazina.md` - Framework details

---

## 🔄 Maintenance Notes

**Last Updated:** 2026-01-25 by Expert #21 (Git & Version Control Expert)

**Update Frequency:**
- Worktree pool: Real-time (after every allocation/release)
- Worktree activity: Real-time (append-only log)
- Branch listings: Weekly (or after major refactoring)
- Remote URLs: Only when changed

**Automation:**
- `C:\scripts\tools\worktree-status.ps1 -Compact` - Quick pool check
- `C:\scripts\tools\repo-dashboard.sh` - Multi-repo status
- `C:\scripts\tools\bootstrap-snapshot.ps1 -Generate` - Full state snapshot

**Manual Updates Needed:**
- New repository additions to Projects folder
- Remote URL changes
- Major branch strategy changes
- Git configuration updates

---

**End of Git Repositories Documentation**
