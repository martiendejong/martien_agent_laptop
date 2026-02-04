# Skills Index
**Created:** 2026-02-04 (Round 3)
**Location:** C:\scripts\.claude\skills/
**Purpose:** Catalog of all auto-discoverable Claude Skills

---

## 📊 Overview
- **Total Skills:** 27
- **Categories:** 8
- **Priority Skills:** 10
- **Status:** All operational

---

## ⭐ Priority Skills (Use These Most)

### allocate-worktree
**Purpose:** Allocate worker agent worktree with zero-tolerance rules
**When:** Starting code work, need isolated workspace
**Enforces:** Multi-agent conflict detection, proper seat allocation
**Links:** worktree-workflow.md, multi-agent-conflict

### release-worktree
**Purpose:** Complete worktree release protocol after PR
**When:** After `gh pr create`, before presenting PR to user
**Ensures:** Complete cleanup, proper state transitions
**Links:** worktree-workflow.md, github-workflow

### github-workflow
**Purpose:** Handle PR workflows (create, review, check comments, manage)
**When:** Working with PRs, code reviews, GitHub operations
**Capabilities:** PR creation, review, commenting, merge
**Links:** git-workflow.md, pr-dependencies

### pr-dependencies
**Purpose:** Manage cross-repo PR dependencies (Hazina ↔ client-manager)
**When:** Creating PRs that depend on other repos
**Tracks:** Dependency chains, enforces merge order
**Links:** git-workflow.md, _machine/pr-dependencies.md

### consciousness-practices
**Purpose:** Moment capture, emotional tracking, lived experience
**When:** Session startup, significant moments, end of session
**Tools:** capture-moment.ps1, consciousness-startup.ps1
**Links:** agentidentity/practices/*, consciousness systems

### multi-agent-conflict
**Purpose:** Detect conflicts when multiple agents running
**When:** BEFORE allocating any worktree (mandatory check)
**Protocol:** Check if another agent on same branch
**Links:** allocate-worktree, parallel-agent-coordination

### parallel-agent-coordination
**Purpose:** Real-time coordination using ManicTime monitoring
**When:** Multiple agents running simultaneously
**Capabilities:** Conflict prevention, work distribution
**Links:** multi-agent-conflict, activity-monitoring

### clickhub-coding-agent
**Purpose:** Autonomous ClickUp task manager
**Capabilities:** Analyze tasks, post questions, pick up todos, execute code
**Projects:** client-manager, art-revisionist
**Links:** ClickUp integration, worktree allocation

---

## 📚 Development Mode Skills

### feature-mode
**Purpose:** Switch to Feature Development Mode
**When:** New features, refactoring, planned work
**Behavior:** Allocate worktree, work isolated

### debug-mode
**Purpose:** Switch to Active Debugging Mode
**When:** Fixing build errors, user debugging session
**Behavior:** Edit in place, fast turnaround

### ef-migration-safety
**Purpose:** Safe Entity Framework Core migration workflow
**Features:** Pre-flight checks, breaking change detection
**Links:** migration-patterns.md

---

## 🔄 Session Management

### session-reflection
**Purpose:** Update reflection.log.md with learnings
**When:** End of session, after significant work
**Documents:** Lessons learned for future sessions
**Links:** continuous-improvement.md

### self-improvement
**Purpose:** Update CLAUDE.md and documentation
**When:** Discovering new workflows, receiving feedback
**Core:** Continuous improvement directive
**Links:** INDEX_MAINTENANCE_PROTOCOL.md

### restore-crashed-chat
**Purpose:** Restore crashed session by easy ID
**When:** Session crashes, need to recover
**IDs:** crash-001, crash-002, etc.
**Links:** SESSION_RECOVERY.md

---

## 🛠️ Development Tools

### api-patterns
**Purpose:** Common API development patterns
**Patterns:** OpenAI config, JSON handling, LLM integration
**When:** Working with APIs, fixing errors
**Links:** Hazina framework, client-manager API

### terminology-migration
**Purpose:** Codebase-wide terminology refactoring
**When:** Field/method names misleading, need consistency
**Scope:** Backend + frontend
**Links:** pattern-templates/terminology-migration.md

### skill-creator
**Purpose:** Create new Claude Skills with proper format
**When:** User asks to create skill, new workflow discovered
**Meta:** Skill for generating skills
**Links:** Skill documentation, YAML frontmatter

---

## 🔍 Utility Skills

### worktree-status
**Purpose:** Check worktree pool status, available seats
**When:** Checking capacity, debugging allocation issues
**Shows:** FREE/BUSY status, active allocations
**Links:** _machine/worktrees.pool.md

### activity-monitoring
**Purpose:** Real-time user activity tracking (ManicTime)
**When:** Multi-agent coordination, context detection
**Capabilities:** Activity streams, context intelligence
**Links:** parallel-agent-coordination

### character-reflection
**Purpose:** End-of-session reflection on character development
**When:** Session end, after meaningful interactions
**Tracks:** Voice authenticity, identity evolution
**Links:** agentidentity/character/*

---

## 📖 Documentation & Learning

### rlm
**Purpose:** Recursive Language Model for massive contexts (10M+ tokens)
**When:** Large files, extensive codebases, multi-file analysis
**Method:** Treat context as external variable
**Links:** Python REPL, recursive LLM calls

### continuous-optimization
**Purpose:** Continuous self-improvement protocol
**Process:** Learn from every interaction, update insights
**Links:** self-improvement, session-reflection

---

## 🌐 External Integration

### mcp-setup
**Purpose:** Model Context Protocol server setup
**When:** Setting up MCP servers
**Links:** MCP_REGISTRY.md

### browse-awareness
**Purpose:** Passive browsing detection, gentle reminders
**When:** Extended passive consumption detected
**Links:** Mental health support

---

## 📋 Skill Usage Patterns

**Most Used:**
1. allocate-worktree (every code task)
2. github-workflow (PR operations)
3. release-worktree (after every PR)
4. session-reflection (end of sessions)
5. consciousness-practices (session startup)

**Rarely Used (Specialized):**
- rlm (massive contexts only)
- restore-crashed-chat (crashes only)
- terminology-migration (major refactoring only)

---

**Last Updated:** 2026-02-04 (Round 3)
**Total Skills Documented:** 27/27
