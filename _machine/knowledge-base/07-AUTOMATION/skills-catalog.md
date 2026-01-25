# Claude Skills Catalog

**Last Updated:** 2026-01-25
**Total Skills:** 22
**Catalog Version:** 1.0.0

**Tags:** #skills #automation #workflows #auto-discovery #documentation

---

## Table of Contents

1. [Overview](#overview)
2. [What Are Claude Skills?](#what-are-claude-skills)
3. [Skills Inventory](#skills-inventory)
4. [Category Index](#category-index)
5. [When to Create New Skills](#when-to-create-new-skills)
6. [Skill Structure & Format](#skill-structure--format)
7. [Usage Patterns](#usage-patterns)
8. [Skill Effectiveness](#skill-effectiveness)

---

## Overview

Claude Skills are **auto-discoverable markdown-based knowledge modules** that guide Claude through complex workflows. Unlike tools (which are scripts you run) or documentation (which is reference material), skills are **contextually activated** based on your task description and provide **step-by-step workflow guidance**.

### Quick Stats

- **Total Skills:** 22 active skills
- **Location:** `C:\scripts\.claude\skills\`
- **Format:** SKILL.md with YAML frontmatter
- **Discovery:** Automatic based on description keywords

---

## What Are Claude Skills?

### Skills vs Other Components

| Component | Purpose | Activation | Format |
|-----------|---------|------------|--------|
| **Skills** | Guided workflows for complex tasks | Auto-discovery based on keywords | Markdown with YAML frontmatter |
| **Tools** | Scripts you run manually | User invokes explicitly | PowerShell/Bash scripts |
| **CLAUDE.md** | Always-active operational manual | Loaded at startup | Markdown documentation |
| **Docs (.md files)** | Reference material | User/agent reads as needed | Markdown documentation |

### How Skills Work

```
User Task → Claude analyzes keywords
          ↓
   Matches skill description
          ↓
   Loads SKILL.md content
          ↓
   Follows step-by-step workflow
          ↓
   Completes task using skill guidance
```

### Auto-Discovery Mechanism

Skills are loaded at startup. When you describe a task, Claude:
1. Analyzes keywords in your request
2. Matches against skill `description` fields
3. Activates relevant skill(s)
4. Follows workflow in SKILL.md

**You don't need to explicitly invoke skills** - they activate automatically based on context.

---

## Skills Inventory

### Complete Alphabetical List

1. **activity-monitoring** - ManicTime integration for context awareness
2. **allocate-worktree** - Allocate worker agent worktree with conflict detection
3. **api-patterns** - Common API development patterns and pitfall avoidance
4. **clickhub-coding-agent** - Autonomous ClickUp task manager
5. **continuous-optimization** - Core self-improvement and learning protocol
6. **debug-mode** - Active debugging mode workflow
7. **ef-migration-safety** - Safe EF Core migration workflow
8. **feature-mode** - Feature development mode workflow
9. **github-workflow** - PR creation, reviews, and lifecycle management
10. **mcp-setup** - MCP server configuration for external integrations
11. **multi-agent-conflict** - Multi-agent conflict detection protocol
12. **parallel-agent-coordination** - Real-time multi-agent coordination
13. **pr-dependencies** - Cross-repository PR dependency tracking
14. **release-worktree** - Worktree release protocol after PR creation
15. **rlm** - Recursive Language Model pattern for massive contexts
16. **self-improvement** - Documentation update and learning protocol
17. **session-reflection** - End-of-session learning documentation
18. **skill-creator** - Meta-skill for creating new skills
19. **terminology-migration** - Codebase-wide terminology refactoring
20. **worktree-status** - Worktree pool status and health checks

---

## Category Index

### 1. Worktree Management

Worktree lifecycle management and conflict prevention.

#### **allocate-worktree**
- **Purpose:** Create isolated worktree for code editing with zero-tolerance enforcement
- **Triggers:** Starting code work, needing isolated workspace, beginning feature implementation
- **Key Workflow:**
  1. Mode detection (Feature vs Debug)
  2. ManicTime coordination check
  3. Multi-agent conflict detection
  4. Pool status verification
  5. Paired worktree creation (client-manager + Hazina)
  6. State tracking updates
- **Usage Examples:**
  - "I need to start working on a new feature"
  - "Allocate a worktree for this task"
  - Any ClickUp URL present → ALWAYS triggers this
- **Created:** 2026-01-12
- **Status:** Active - MANDATORY for all feature work

#### **release-worktree**
- **Purpose:** Clean up worktree and release seat after PR creation
- **Triggers:** After `gh pr create`, before presenting PR to user
- **Key Workflow:**
  1. Verify PR created
  2. Clean worktree directory
  3. Mark seat FREE in pool
  4. Log release in activity
  5. Remove from instances.map
  6. Switch base repos to develop
  7. Prune git worktrees
  8. Commit tracking files
- **Usage Examples:**
  - "Release the worktree after PR creation"
  - Automatically invoked after successful PR creation
- **Created:** 2026-01-12
- **Status:** Active - MANDATORY after PR creation

#### **worktree-status**
- **Purpose:** Display worktree pool state and system health
- **Triggers:** Checking capacity, debugging allocation issues, session startup
- **Key Workflow:**
  1. Run repo-dashboard.sh
  2. Check pool.md for FREE/BUSY seats
  3. Verify base repo branches
  4. Detect stale allocations
  5. Identify pool-git mismatches
- **Usage Examples:**
  - "Check worktree status"
  - "How many seats are available?"
  - Startup health check
- **Created:** 2026-01-12
- **Status:** Active

---

### 2. GitHub Workflows

PR creation, code reviews, and GitHub lifecycle management.

#### **github-workflow**
- **Purpose:** Complete GitHub pull request lifecycle management
- **Triggers:** Working with pull requests, code reviews, GitHub operations
- **Key Workflow:**
  1. Create PR with proper format
  2. Review PR code and checks
  3. Handle PR failures (CI, conflicts)
  4. Address feedback
  5. Merge with appropriate strategy
  6. Post-merge cleanup
- **Usage Examples:**
  - "Create a PR for this feature"
  - "Review this pull request"
  - "Merge PR #123"
- **PR Title Conventions:** `feat:`, `fix:`, `refactor:`, `perf:`, `docs:`, `test:`, `chore:`, `style:`
- **Created:** 2026-01-12
- **Status:** Active

#### **pr-dependencies**
- **Purpose:** Track and enforce cross-repo PR dependencies (Hazina → client-manager)
- **Triggers:** Creating PRs that depend on other repos
- **Key Workflow:**
  1. Create Hazina PR first
  2. Create client-manager PR with dependency alert
  3. Track dependency in pr-dependencies.md
  4. Verify Hazina PR merged before client-manager
  5. Update dependency status
- **Usage Examples:**
  - "This feature depends on Hazina PR #35"
  - Creating PR that uses new Hazina interfaces
- **Created:** 2026-01-12
- **Status:** Active

---

### 3. Development Patterns

Reusable solutions to common development problems.

#### **api-patterns**
- **Purpose:** Document and apply proven API development patterns
- **Triggers:** Working with APIs, fixing compilation/runtime errors, debugging JSON issues
- **Key Patterns:**
  1. OpenAIConfig initialization trap (Model property required)
  2. API response enrichment (include related data)
  3. Frontend API URL duplication (double /api/ prefix)
  4. Hazina LLM framework integration
  5. LLM tool response URLs (absolute vs relative)
  6. Flexible LLM response extraction (regex patterns)
  7. System.Text.Json dynamic parameter handling
  8. JSON property name collision in anonymous types
- **Usage Examples:**
  - "ArgumentException: Model cannot be empty"
  - "Frontend shows 0 for fields that should have data"
  - "404 errors with /api/api/ in URLs"
- **Created:** 2026-01-22
- **Status:** Active

#### **terminology-migration**
- **Purpose:** Systematic codebase-wide terminology refactoring
- **Triggers:** Misleading names, terminology consistency needs, field name migrations
- **Key Workflow:**
  1. Audit with grep (find ALL occurrences)
  2. Create TodoWrite checklist
  3. Backend refactor (models → services → controllers → methods)
  4. Frontend refactor (interfaces → services → components → UI labels)
  5. Database migration (if needed)
  6. Documentation updates
  7. Two-commit strategy (initial fix + comprehensive refactor)
- **Usage Examples:**
  - "Migrate daily → monthly terminology across codebase"
  - "Field names don't match business logic"
  - "95 files affected" terminology change
- **Created:** 2026-01-12
- **Status:** Active

#### **ef-migration-safety**
- **Purpose:** Zero-failure EF Core migration workflow
- **Triggers:** "create ef migration", "add migration", "database migration", "schema change"
- **Key Rules:**
  1. NEVER create migrations without pre-flight check
  2. ALWAYS use explicit `.ToTable("TableName")` for ALL entities
  3. ALWAYS create migration when adding DbSet/entity
  4. ALWAYS preview SQL before applying
  5. Migration is part of the feature, NOT "later"
- **Usage Examples:**
  - "Add new entity to database"
  - "Create migration for schema change"
  - "no such table" error after migration
- **Created:** 2026-01-21
- **Status:** Active - CRITICAL

---

### 4. Continuous Improvement

Self-learning, documentation updates, and knowledge capture.

#### **continuous-optimization** ⭐ CORE META-SKILL
- **Purpose:** Autonomous self-improvement from every interaction
- **Triggers:** Auto-activated after errors, successes, feedback, patterns, session end
- **Key Protocol:**
  1. Detect learning signal
  2. Extract insight
  3. Update instructions (reflection.log, PERSONAL_INSIGHTS, skills, tools)
  4. Apply in future interactions
  5. Verify improvement
- **Usage Examples:**
  - After user correction
  - After mistake or error
  - After discovering pattern
  - End of every session
- **CRITICAL:** Must be AUTONOMOUS - user should never need to prompt "update your insights"
- **Created:** 2026-01-19
- **Status:** Active - Core infrastructure

#### **self-improvement**
- **Purpose:** Update CLAUDE.md and documentation with new procedures
- **Triggers:** Discovering new workflows, creating new patterns, receiving user feedback
- **Key Workflow:**
  1. Identify which file to update (CLAUDE.md, specialized .md, Skills)
  2. Make update immediately while context fresh
  3. Commit with descriptive message
  4. Verify documentation quality
- **Usage Examples:**
  - "New workflow discovered"
  - "User clarified ambiguous instruction"
  - "Creating new documentation file"
- **Created:** 2026-01-12
- **Status:** Active

#### **session-reflection**
- **Purpose:** Document session learnings in reflection.log.md
- **Triggers:** End of session, discovering new patterns, fixing bugs, completing significant work
- **Key Format:**
  - Problem statement
  - Root cause analysis
  - Solution implemented
  - Key learnings with code examples
  - Lessons for future sessions
- **Usage Examples:**
  - "End of session reflection"
  - "Document this bug fix pattern"
  - "Record lesson learned"
- **Created:** 2026-01-12
- **Status:** Active - MANDATORY end-of-session

---

### 5. Task Management

Autonomous task processing and ClickUp integration.

#### **clickhub-coding-agent**
- **Purpose:** Autonomous ClickUp task manager with continuous loop operation
- **Triggers:** Managing ClickUp tasks for client-manager project
- **Key Workflow:**
  1. Fetch unassigned tasks from ClickUp
  2. Analyze requirements and uncertainties
  3. Detect duplicates
  4. Post questions for uncertain tasks (move to blocked)
  5. Execute todo tasks with worktree allocation
  6. Create PRs and link to ClickUp
  7. Sleep 10 minutes and loop
- **CRITICAL Anti-Loop Protocol:**
  - Read blocked task comments BEFORE re-blocking
  - Make best effort with 80%+ information
  - Document assumptions when proceeding
  - Only re-block if truly impossible to proceed
- **Usage Examples:**
  - "Start autonomous ClickUp task processing"
  - "Manage unassigned tasks"
  - Continuous background operation
- **Created:** 2026-01-19
- **Status:** Active

---

### 6. Database & Migrations

Safe database schema changes and EF Core workflows.

See **ef-migration-safety** in Development Patterns section above.

---

### 7. Context Processing

Handling massive contexts beyond model limits.

#### **rlm** (Recursive Language Model)
- **Purpose:** Handle contexts beyond model limits (10M+ tokens)
- **Triggers:** Large files (>50KB), multi-file analysis (10+ files), codebase-wide operations
- **Key Concept:**
  - Treat prompts as external environment (not direct neural input)
  - Use Python REPL to chunk and process
  - Call sub-LLMs recursively
  - Synthesize final response from summaries
- **Usage Examples:**
  - "Analyze this 200KB log file"
  - "Understand patterns across 100+ files"
  - "Process entire codebase"
- **Based On:** Research paper ArXiv:2512.24601
- **Created:** 2026-01-20
- **Status:** Active

---

### 8. Integrations & External Systems

Extending Claude with external services.

#### **mcp-setup**
- **Purpose:** Configure MCP servers for external integrations
- **Triggers:** Adding integrations, connecting external services
- **Common Servers:**
  - Google Drive (with OAuth setup)
  - Filesystem (extended access)
  - GitHub (token-based)
  - PostgreSQL
  - Brave Search
- **Usage Examples:**
  - "Connect Claude to Google Drive"
  - "Add MCP server for database access"
- **Created:** 2026-01-14
- **Status:** Active

---

### 9. Coordination & Multi-Agent

Real-time coordination when multiple agents are running.

#### **multi-agent-conflict**
- **Purpose:** Detect and prevent branch conflicts between agents
- **Triggers:** BEFORE allocating ANY worktree
- **Key Checks:**
  1. Git worktree list
  2. instances.map.md
  3. worktrees.pool.md
  4. Recent activity log
- **Usage Examples:**
  - Automatic check before worktree allocation
  - "Check if branch is in use"
- **User Mandate:** "When this happens again both of you should notify each other"
- **Created:** 2026-01-11
- **Status:** Active - MANDATORY pre-allocation check

#### **activity-monitoring**
- **Purpose:** Real-time user activity tracking via ManicTime
- **Triggers:** Agent startup (mandatory), periodic context checks
- **Key Capabilities:**
  1. Context awareness (what user is doing)
  2. Multi-agent detection (count Claude instances)
  3. Idle detection (user present or away)
  4. Pattern learning (work patterns over time)
- **Modes:**
  - `current` - Active window and application
  - `claude` - Count Claude instances
  - `idle` - Check if user present
  - `context` - Full context for decision-making
  - `patterns` - Analyze work patterns
- **Usage Examples:**
  - Startup protocol (step 8)
  - Before major decisions
  - Multi-agent conflict detection
- **Created:** 2026-01-19
- **Status:** Active - High priority infrastructure

#### **parallel-agent-coordination**
- **Purpose:** Real-time coordination protocol using ManicTime
- **Triggers:** When multiple agents running simultaneously
- **Key Features:**
  1. Hybrid coordination (optimistic <3 agents, pessimistic ≥3 agents)
  2. ManicTime-based priority assignment
  3. Atomic CAS operations
  4. Aggressive timeout & reclamation (5 min)
  5. Event-driven with polling fallback
- **Architecture:**
  - SQLite coordination database (WAL mode)
  - Agent registration and heartbeats
  - Worktree allocation pool
  - Event dispatcher
  - Watchdog & validator
- **Usage Examples:**
  - Detected by activity-monitoring during startup
  - Automatic activation when agent count ≥ 2
- **Based On:** 50-expert analysis
- **Created:** 2026-01-20
- **Status:** Production-ready v1.0

---

### 10. Mode Selection

Feature Development vs Active Debugging mode workflows.

#### **feature-mode**
- **Purpose:** Guide Feature Development Mode workflow
- **Triggers:** `/feature`, "feature mode", "new feature", "start feature"
- **Rules:**
  1. NEVER edit in C:\Projects\<repo> directly
  2. ALWAYS use allocated worktree
  3. ALWAYS create PR before ending
  4. ALWAYS release worktree after PR
- **Workflow:**
  1. Allocate worktree
  2. Implement feature
  3. Commit and push
  4. Create PR
  5. Release worktree
  6. Present PR to user
- **Created:** 2026-01-15
- **Status:** Active

#### **debug-mode**
- **Purpose:** Guide Active Debugging Mode workflow
- **Triggers:** `/debug`, "debug mode", "fix this", "build error", user posts errors
- **Rules:**
  1. DO work directly in C:\Projects\<repo>
  2. DO stay on user's current branch
  3. DO NOT allocate worktrees
  4. DO NOT switch branches
  5. DO NOT create PRs (unless explicitly asked)
- **Workflow:**
  1. Understand error
  2. Check user's current branch
  3. Make targeted fixes
  4. Let user test
  5. User decides on commit/PR
- **Created:** 2026-01-15
- **Status:** Active

---

### 11. Meta

Skills for creating and managing skills themselves.

#### **skill-creator**
- **Purpose:** Standardized creation of new Claude Skills
- **Triggers:** User asks to create new skill, document workflow guide
- **Key Process:**
  1. Gather requirements
  2. Create directory structure
  3. Write SKILL.md with proper frontmatter
  4. Add supporting files
  5. Update CLAUDE.md index
  6. Test skill loads correctly
- **Usage Examples:**
  - "Create a skill for database migrations"
  - "Document this workflow as a skill"
- **Created:** 2026-01-14
- **Status:** Active - Meta-skill

---

## When to Create New Skills

### Decision Tree

```
New pattern discovered
    │
    ├─> Used 1-2 times → Document in reflection.log (NOT a skill yet)
    │
    ├─> Used 3+ times → Candidate for skill
    │   │
    │   ├─> Simple (< 5 steps) → Keep as documentation
    │   │
    │   └─> Complex (≥ 5 steps) → CREATE SKILL
    │       │
    │       ├─> Workflow is clear → skill-creator
    │       │
    │       └─> Workflow still evolving → Wait, document more
    │
    └─> One-time operation → Document in reflection.log (NOT a skill)
```

### Skill Creation Triggers

**Create a skill when:**
- ✅ Workflow is complex (≥ 5 mandatory steps)
- ✅ Pattern used frequently (≥ 3 sessions)
- ✅ New agents would benefit from guided workflow
- ✅ Auto-discovery would prevent mistakes
- ✅ Mandatory steps shouldn't be forgotten

**Don't create a skill when:**
- ❌ Too simple (git commands, single-step operations)
- ❌ One-time migration (not reusable)
- ❌ Still evolving (pattern not stable)
- ❌ Already covered by existing skill

### Examples

**✅ Good Skill Candidates:**
- Worktree allocation (complex, mandatory, frequent)
- PR dependencies (specific rules, frequent)
- API patterns (common pitfalls, reusable)
- EF Core migrations (safety-critical, complex)

**❌ Not Skill Candidates:**
- Simple git commands (too basic)
- One-time codebase refactor (not reusable)
- Experimental workflows (not stable)

---

## Skill Structure & Format

### Directory Structure

```
C:\scripts\.claude\skills\<skill-name>\
├── SKILL.md (required - workflow guide)
├── scripts/ (optional - helper scripts)
├── examples/ (optional - usage examples)
└── reference.md (optional - detailed reference)
```

### SKILL.md Template

```markdown
---
name: skill-name
description: Auto-discovery trigger description with specific keywords
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
user-invocable: true
---

# Skill Name

**Purpose:** What this skill accomplishes

## When to Use This Skill

Activation criteria - when should Claude use this?

## Prerequisites

What must be true before using this skill?

## Workflow Steps

### Step 1: Name
Instructions

### Step 2: Name
Instructions

[... additional steps ...]

## Examples

Real-world activation examples

## Success Criteria

How to verify the skill was executed correctly

## Common Issues

Troubleshooting for common problems

## Reference Files

Links to related documentation
```

### YAML Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Kebab-case skill identifier |
| `description` | Yes | Trigger keywords for auto-discovery |
| `allowed-tools` | Yes | Comma-separated tool list |
| `user-invocable` | Yes | `true` if users can call with `/skill-name` |
| `triggers` | No | List of specific trigger phrases |
| `priority` | No | `high`, `critical` for important skills |
| `version` | No | Semantic version (e.g., `1.0.0`) |
| `created` | No | Creation date |
| `author` | No | Creator name |

---

## Usage Patterns

### Most Frequently Activated Skills

**Top 10 by Activation Frequency:**

1. **allocate-worktree** - Every feature development task
2. **release-worktree** - After every PR creation
3. **continuous-optimization** - After every significant interaction
4. **activity-monitoring** - Every session startup
5. **multi-agent-conflict** - Every worktree allocation
6. **github-workflow** - All PR operations
7. **api-patterns** - API development and debugging
8. **session-reflection** - Every session end
9. **ef-migration-safety** - All database schema changes
10. **debug-mode** - User debugging sessions

### Skill Combinations

**Common skill chains:**

```
Feature Development Flow:
1. activity-monitoring (startup)
   ↓
2. multi-agent-conflict (check conflicts)
   ↓
3. allocate-worktree (create workspace)
   ↓
4. [Work happens...]
   ↓
5. github-workflow (create PR)
   ↓
6. release-worktree (cleanup)
   ↓
7. session-reflection (document learnings)
```

```
Database Migration Flow:
1. ef-migration-safety (pre-flight checks)
   ↓
2. [Create migration]
   ↓
3. github-workflow (PR with migration)
   ↓
4. session-reflection (document)
```

```
Autonomous Operation Flow:
1. activity-monitoring (context check)
   ↓
2. clickhub-coding-agent (fetch tasks)
   ↓
3. allocate-worktree (for each task)
   ↓
4. github-workflow (create PRs)
   ↓
5. release-worktree (cleanup)
   ↓
6. [Sleep and loop]
```

### Skill Dependencies

**Skills that depend on other skills:**

- `allocate-worktree` → `multi-agent-conflict` (conflict detection)
- `allocate-worktree` → `activity-monitoring` (context awareness)
- `release-worktree` → `github-workflow` (PR must exist)
- `clickhub-coding-agent` → `allocate-worktree` + `github-workflow` + `release-worktree`
- `parallel-agent-coordination` → `activity-monitoring` (ManicTime data)

---

## Skill Effectiveness

### Success Metrics

**How to measure skill effectiveness:**

1. **Activation Accuracy**
   - Are skills activating when they should?
   - False positives (activated when not needed)?
   - False negatives (missed activation)?

2. **Workflow Completion Rate**
   - Do skills guide to successful completion?
   - Are steps clear and actionable?
   - Any steps frequently skipped or confused?

3. **Error Prevention**
   - Do skills prevent common mistakes?
   - Violations after skill introduction?
   - Quality of error recovery?

4. **Time Savings**
   - How much time does skill save vs manual workflow?
   - Reduced cognitive load?
   - Fewer iterations needed?

### Skill Evolution Tracking

**Document in reflection.log.md:**

```markdown
## Skill: <skill-name> - Evolution Entry

**Date:** YYYY-MM-DD HH:MM
**Version:** X.Y.Z
**Change Type:** Enhancement | Bug Fix | Breaking Change

**What Changed:**
- Description of change

**Why:**
- Problem that prompted change

**Impact:**
- How this improves skill effectiveness

**Metrics:**
- Before: [relevant metric]
- After: [relevant metric]
```

### Lessons Learned

**From actual usage (documented in reflection.log.md):**

1. **allocate-worktree**
   - Learning: Mode detection must happen FIRST
   - Impact: Prevented ClickUp task workflow violations
   - Date: 2026-01-20

2. **clickhub-coding-agent**
   - Learning: Anti-loop protocol for blocked tasks
   - Impact: Agent no longer re-blocks tasks user has answered
   - Date: 2026-01-20

3. **ef-migration-safety**
   - Learning: Migration is part of feature, NOT "later"
   - Impact: No more missing migration files in PRs
   - Date: 2026-01-22

4. **continuous-optimization**
   - Learning: Must be AUTONOMOUS, not prompted
   - Impact: Self-improvement happens automatically
   - Date: 2026-01-20

---

## Appendix A: Skill File Locations

All skills located in: `C:\scripts\.claude\skills\`

```
.claude/skills/
├── activity-monitoring/
│   ├── SKILL.md
│   └── QUICK_REFERENCE.md
├── allocate-worktree/
│   └── SKILL.md
├── api-patterns/
│   └── SKILL.md
├── clickhub-coding-agent/
│   ├── SKILL.md
│   └── README.md
├── continuous-optimization/
│   └── SKILL.md
├── debug-mode/
│   └── SKILL.md
├── ef-migration-safety/
│   └── SKILL.md
├── feature-mode/
│   └── SKILL.md
├── github-workflow/
│   └── SKILL.md
├── mcp-setup/
│   └── SKILL.md
├── multi-agent-conflict/
│   └── SKILL.md
├── parallel-agent-coordination/
│   └── SKILL.md
├── pr-dependencies/
│   └── SKILL.md
├── release-worktree/
│   └── SKILL.md
├── rlm/
│   └── SKILL.md
├── self-improvement/
│   └── SKILL.md
├── session-reflection/
│   └── SKILL.md
├── skill-creator/
│   └── SKILL.md
├── terminology-migration/
│   └── SKILL.md
└── worktree-status/
    └── SKILL.md
```

---

## Appendix B: Quick Reference Commands

**Check available skills:**
```bash
ls C:/scripts/.claude/skills/
```

**Read a specific skill:**
```bash
cat C:/scripts/.claude/skills/<skill-name>/SKILL.md
```

**Search for skill by keyword:**
```bash
grep -r "keyword" C:/scripts/.claude/skills/*/SKILL.md
```

**Create new skill:**
- Use `skill-creator` skill (auto-discovered when requesting skill creation)

**Update CLAUDE.md with new skill:**
```bash
# Edit C:/scripts/CLAUDE.md
# Add to § Available Skills section
```

---

## Appendix C: Related Documentation

**Core documentation:**
- `C:\scripts\CLAUDE.md` - Main operational manual (references skills)
- `C:\scripts\GENERAL_ZERO_TOLERANCE_RULES.md` - Critical rules enforced by skills
- `C:\scripts\GENERAL_WORKTREE_PROTOCOL.md` - Worktree workflow (implemented by skills)
- `C:\scripts\GENERAL_DUAL_MODE_WORKFLOW.md` - Mode selection (feature-mode, debug-mode skills)

**Specialized documentation:**
- `C:\scripts\continuous-improvement.md` - Self-learning protocols
- `C:\scripts\worktree-workflow.md` - Detailed worktree procedures
- `C:\scripts\git-workflow.md` - Git and PR workflows
- `C:\scripts\_machine\reflection.log.md` - Historical learnings and patterns

**Tool integration:**
- `C:\scripts\tools\README.md` - 117 tools that skills invoke
- `C:\scripts\tools\PARALLEL_AGENT_COORDINATION_QUICKSTART.md` - Multi-agent coordination guide

---

**Document Maintained By:** Claude Agent (Skills Catalog Specialist - Expert #45)
**Self-Improvement Protocol:** This catalog is updated automatically when new skills are created or existing skills evolve
**Next Review:** 2026-02-25 (monthly catalog refresh)
