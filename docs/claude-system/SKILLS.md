# Claude Skills - Auto-Discoverable Workflows

**Source:** CLAUDE.md § Claude Skills
**Purpose:** Skill system documentation
**Priority:** Reference for creating new skills

---

**New in 2026-01-12:** This system now includes Claude Skills - auto-discoverable markdown-based knowledge that Claude loads based on context.

### What Are Skills?

**Skills are:**
- Markdown files in `.claude/skills/<skill-name>/SKILL.md`
- Automatically discovered by Claude Code at startup
- Activated when your task matches the skill's description
- Self-contained workflow guides with optional supporting files

**Skills vs Other Documentation:**
- **CLAUDE.md** - Always active, operational manual
- **Skills** - Contextually activated, specialized workflows
- **Tools** - Scripts you run manually
- **Docs (.md files)** - Reference material

### Available Skills

#### 🏗️ Worktree Management
- **`allocate-worktree`** - Allocate worker agent worktree with zero-tolerance enforcement and multi-agent conflict detection
- **`release-worktree`** - Release worktree after PR creation with complete cleanup protocol
- **`worktree-status`** - Check pool status, available seats, and system health

#### 🔄 Advanced Context Processing
- **`rlm`** - **NEW (2026-01-20):** Recursive Language Model pattern for handling massive contexts (10M+ tokens) by treating them as external variables. Auto-activates for large files (>50KB), multi-file analysis (10+ files), or codebase-wide operations. Enables unbounded context processing through Python REPL and recursive sub-LLM calls.

#### 🔀 GitHub Workflows
- **`github-workflow`** - PR creation, code reviews, merging, and lifecycle management
- **`pr-dependencies`** - Cross-repo dependency tracking between Hazina and client-manager

#### 🛠️ Development Patterns
- **`api-patterns`** - Common API pitfalls: OpenAIConfig initialization, response enrichment, URL duplication, LLM integration
- **`terminology-migration`** - Comprehensive codebase-wide refactoring patterns (e.g., daily → monthly)
- **`multi-agent-conflict`** - MANDATORY pre-allocation conflict detection when multiple agents run simultaneously

#### 📝 Continuous Improvement
- **`continuous-optimization`** - **CORE META-SKILL: Learns from every interaction, updates insights, optimizes behavior continuously. Fulfills user mandate: "learn from yourself and update your own instructions"**
- **`session-reflection`** - Update reflection.log.md with session learnings
- **`self-improvement`** - Update CLAUDE.md and documentation with new patterns

#### 📋 Task Management
- **`clickhub-coding-agent`** - Autonomous ClickUp task manager: analyze unassigned tasks, identify uncertainties, post questions, pick up todo tasks, execute code changes with worktrees, operate in continuous loop

#### 🔌 Integrations
- **`mcp-setup`** - Configure MCP servers for external integrations (Google Drive, GitHub, databases, APIs)

#### 🧠 Context Intelligence & System Awareness
- **`activity-monitoring`** - Real-time user activity tracking and context-aware intelligence using ManicTime integration. Detects what user is doing, counts Claude instances, identifies idle/unattended system, enables adaptive assistance.
- **`parallel-agent-coordination`** - **NEW (2026-01-20):** Real-time coordination protocol for multiple Claude agents using ManicTime. Prevents conflicts, enables intelligent work distribution, ensures efficient parallel operation. Based on 50-expert analysis. Use when multiple agents running simultaneously.

#### 🗄️ Database & Migrations
- **`ef-migration-safety`** - Safe EF Core migration workflow with pre-flight checks, breaking change detection, and multi-step migration patterns

#### 🔧 Meta
- **`skill-creator`** - Create new Claude Skills with proper format, YAML frontmatter, and best practices

#### 📚 Content Creation
- **`art-revisionist-case`** - **NEW (2026-01-29):** Complete workflow for creating Art Revisionist historical research cases. Covers pages.json structure, folder hierarchy (pages/details/evidence), content writing guidelines, and automated structure generation. Includes PowerShell script `create-case-structure.ps1` and JSON template.

### How Skills Work

1. **Discovery** - Claude loads skill names and descriptions at startup
2. **Activation** - When your task matches a skill's description, Claude uses it
3. **Execution** - Claude follows the skill's markdown instructions

**You don't need to explicitly invoke Skills** - Claude discovers and applies them automatically based on context.

### When Skills Are Used

**Example scenarios:**

```
You: "I need to allocate a worktree for a new feature"
→ Claude activates: allocate-worktree Skill
→ Runs conflict detection, checks pool, allocates properly

You: "Create a PR for this feature"
→ Claude activates: github-workflow Skill
→ Follows PR creation format, adds dependency alerts if needed

You: "We need to rename 'daily' to 'monthly' across the codebase"
→ Claude activates: terminology-migration Skill
→ Uses systematic grep → TodoWrite → sed → build pattern

You: "Document what we learned today"
→ Claude activates: session-reflection Skill
→ Updates reflection.log.md with proper format

You: "Add Google Drive integration to Claude"
→ Claude activates: mcp-setup Skill
→ Guides OAuth setup, configures MCP server, sets environment variables

You: "Create a skill for database migrations"
→ Claude activates: skill-creator Skill
→ Creates directory structure, SKILL.md with frontmatter, updates index

You: "Create content for a new Art Revisionist case about Senufo"
→ Claude activates: art-revisionist-case Skill
→ Plans page structure, creates pages.json, generates folder hierarchy
→ Claude activates: skill-creator Skill
→ Creates directory structure, SKILL.md with frontmatter, updates index
```

### Skill File Structure

```
C:\scripts\.claude\skills\
├── allocate-worktree/
│   ├── SKILL.md (required - workflow guide)
│   └── scripts/ (optional - helper scripts)
├── release-worktree/
│   └── SKILL.md
├── github-workflow/
│   └── SKILL.md
└── ...
```

### Creating New Skills

**Create a Skill when:**
- Workflow is complex with multiple mandatory steps
- Pattern is used frequently across sessions
- Auto-discovery would help future sessions
- New agents would benefit from guided workflow

**See:** `skill-creator` Skill for complete creation process and templates

---

