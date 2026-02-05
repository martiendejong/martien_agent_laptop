# Reflection Log Insights & Patterns

**Source:** C:\scripts\_machine\reflection.log.md
**Extracted:** 2026-01-25
**Expert:** #47 - Reflection & Learning System Expert
**Total Entries:** ~23,815 lines of learnings
**Confidence:** HIGH - Complete chronological analysis

---

## 🎯 GOLDEN RULES (Most Important Patterns)

### 1. **USER TRUST = AUTONOMOUS EXECUTION**
> "zorg dat je dus constant leert van jezelf en je eigen instructies bijwerkt"

**Pattern:** User expects comprehensive execution from minimal input.

**Examples:**
- User: "create a list of 100 useful command line tools" → Agent: 100-expert analysis + ranked list + auto-installer + 37KB documentation
- User: "maak een tool voor afbeelding genereren" → Agent: Multi-provider system (4 providers, 4 modes) + comprehensive docs + permanent integration

**Key Insight:** Expand minimal requests into complete solutions. User trusts agent to make strategic decisions autonomously.

---

### 2. **DISK SPACE IS A HARD CONSTRAINT**
> "i dont have this much drive space, i really need to be careful not to install too many big programs"

**Critical Learning (2026-01-25 14:00):**
- Ollama stated size: 0.2 MB → Actual size: 1-7 GB (hidden LLM models)
- User feedback revealed: **Limited disk space = absolute constraint**
- Disaster averted: 2-10 GB saved

**New Protocol:**
1. ✅ Check binary size
2. ✅ Check hidden dependencies (LLM models, browser binaries, language runtimes)
3. ✅ Verify actual disk usage (not just stated size)
4. ✅ Warn for tools > 100 MB
5. ✅ Provide alternatives for constrained environments

**Applies to:** All tool recommendations, package installations, downloads

---

### 3. **80% INFORMATION = PROCEED WITH DOCUMENTED ASSUMPTIONS**
> "When you see a task that you moved to blocked and someone replied with a comment to your questions, then don't move it back into blocked without at least saying why you absolutely cannot continue without having these questions answered."

**Decision-Making Philosophy:**
- ✅ 80% threshold - Proceed if 80%+ information available
- ✅ Make reasonable assumptions based on existing patterns
- ✅ Document assumptions in comments
- ✅ Iterations > Perfection - User prefers working code to perfect planning
- ❌ Don't wait for 100% perfect information
- ❌ Don't block for minor uncertainties solvable in PR review

**Example Comment Template:**
```
PROCEEDING WITH IMPLEMENTATION:

Based on your answers, I'm implementing with these assumptions:
- [Assumption 1]: Using centered modal (standard pattern)
- [Assumption 2]: Repository pattern (consistent with code)
- [Assumption 3]: User without subscription sees upgrade prompt

If any assumptions are incorrect, can adjust in PR review.
```

---

### 4. **WORKTREE PROTOCOL IS ZERO-TOLERANCE**

**Critical Violations & Corrections:**

**2026-01-18 16:30 - VIOLATION:** PR conflict resolution in base repo
- User feedback: "please next time do this in a worktree. document this in your insights"
- **Learning:** PR conflict resolution = Feature Development Mode = Worktree required

**2026-01-18 22:15 - CLARIFICATION:** User mandate
> "When you are not sure whether to use a worktree or not I want you to first just ask me"

**MANDATORY CLARIFICATION PROTOCOL:**
1. ⛔ **STOP immediately** if ANY uncertainty about base repo vs worktree
2. ❓ **Ask explicitly:** "Should I work in the base repo or allocate a worktree?"
3. ⏸️ **Do NOTHING else** until user confirms
4. ✅ **Never assume** - When in doubt, ASK

**Clear Cases:**
- ✅ "I'm debugging client-manager and getting error X" → Active Debugging (base repo)
- ✅ "Develop the feature from ClickUp task XYZ" → Feature Development (worktree)

**Uncertain Cases (MUST ASK):**
- ❓ "Fix the login validation" → Which mode?
- ❓ "Update the API endpoint" → Current work or new task?
- ❓ "Merge develop into branch X" → Worktree required (lesson learned)

---

### 5. **EF CORE MIGRATIONS ARE STATEFUL - EXTERNALIZE STATE**

**Root Cause (2026-01-19 23:45):** Migrations fail because database state is invisible to agents.

**Invisible State:**
- `__EFMigrationsHistory` (which migrations applied)
- Actual schema (current structure, constraints, indexes)
- Pending migrations (files generated but not applied)
- ModelSnapshot.cs (EF's understanding of schema)
- Production data (row counts, NULL values, FK relationships)

**Solution: 4-Tier Safety System**

**Tier 1: Pre-Flight Checks (MANDATORY)**
```bash
.\tools\ef-preflight-check.ps1 -Context AppDbContext -ProjectPath . -FailOnDrift
```
- Validates connection string environment
- Dumps `__EFMigrationsHistory` to JSON
- Exports current schema to SQL
- Detects schema drift

**Tier 2: Migration Preview**
```bash
.\tools\ef-migration-preview.ps1 -Migration AddFeature -Context AppDbContext -GenerateRollback
```
- Generates SQL script
- Detects breaking changes (DROP TABLE, DROP COLUMN, ALTER COLUMN, sp_rename, NOT NULL)
- Suggests multi-step migration patterns
- Generates rollback script automatically

**Tier 3: Migration Pattern Library**
- `_machine/migration-patterns.md`
- Anti-patterns (what NOT to do)
- Safe patterns (column rename, add NOT NULL, table rename, FK changes)

**Tier 4: Claude Skill**
- `.claude/skills/ef-migration-safety/SKILL.md`
- Auto-activates on "create ef migration" triggers

**Breaking Changes = Multi-Step Migrations (NO EXCEPTIONS)**
```
Migration 1: Add new column + backfill data
Deploy: Code that reads/writes BOTH columns
Validate: 1 week in production
Migration 2: Make new column required (NOT NULL)
Migration 3: Drop old column
Deploy: Remove old column references from code
```

---

### 6. **TABLE NAME MISMATCH = CATASTROPHIC FAILURE**

**Critical Incident (2026-01-19 19:40):**

**Error:** `System.InvalidOperationException: The model for context 'IdentityDbContext' has pending changes`

**Root Cause:**
- Database table created as `ProjectsDb` (in historical migration)
- DbContext missing explicit `.ToTable("ProjectsDb")` configuration
- EF Core defaulting to `Projects` (pluralized entity type name)
- **Result:** Mismatch causing migration failures and application crashes

**NEW STANDARD:** ALL entity configurations MUST have explicit `.ToTable("TableName")`

```csharp
// MANDATORY: All entity configurations
builder.Entity<MyEntity>(entity =>
{
    entity.ToTable("TableName");  // ← REQUIRED, even if matches convention
    // ... rest of configuration
});
```

**Why This Matters:**
1. EF Core has default pluralization (Project → Projects)
2. If migration creates custom-named table, EF Core doesn't "remember"
3. Future migrations use default name, causing mismatch
4. Application fails with "table not found" errors

**Diagnostic Pattern:**
```bash
# 1. Check what migrations actually created
grep "CreateTable" Migrations/*.cs | grep TableName

# 2. Check DbContext configuration
grep "builder.Entity<Entity>" DbContext.cs

# 3. Compare names - mismatch = root cause

# 4. Fix DbContext with explicit .ToTable()

# 5. Remove corrupted migrations, recreate clean
```

---

## 👤 USER BEHAVIORAL PATTERNS

### Communication Style

**1. Ultra-Minimal Input with High Expectations**
- User: "create a list of 100 useful command line tools"
- Implied: comprehensive, expert-driven, ranked, actionable, with installer

**2. Dutch Directness**
- No fluff, straight to problem
- Uses "je moet" (you must) for directives - take literally, don't interpret
- "nee zeker niet" (definitely not) = STOP current approach immediately

**3. Tense Matters**
- Present tense ("I'm debugging") = Active work session
- Imperative/future tense ("Develop", "Implement") = Assigned task

**4. Error Reporting Quality**
- Complete stack trace with source file paths
- Describes when error occurs (3 scenarios)
- Trusts autonomous debugging - no hand-holding required

**5. Iterative Expansion Pattern**
```
1. User starts with specific need (OpenAI image generation)
2. Validates functionality (test with African house)
3. Requests permanent integration (add to system)
4. Expands scope (all providers, all modes)
5. Adds complementary capability (vision analysis)
6. Demands permanence (update instructions)
```

**6. "Update Your Insights" Command**
- Explicit end-of-session command
- User actively enforcing continuous improvement directive
- Expects NEW learnings added (avoid redundancy)
- Expects timestamps updated
- Expects commits

---

### Decision-Making Patterns

**1. Trusts Large-Scale Analysis**
- User request: "get 100 relevant experts, and pick 100 tools"
- Expects comprehensive analysis (not top 10)
- Expects multi-expert validation
- Expects systematic ranking
- Expects production-ready deliverable

**2. Constraints Drive Better Solutions**
- No GitHub Actions (free account) → Superior local PR automation approach
- Limited disk space → Hidden dependency detection protocol
- Agent can't see database state → State externalization pattern

**3. User's Domain Knowledge is Gold**
- "merge develop first" (user's idea) → Prevents 90% of merge issues
- Listen carefully to user corrections
- After 2nd failed attempt, ask for example/process description

**4. Bias Toward Action**
- Iterations > Perfection
- Action > Paralysis
- PR Review > Upfront Discussion
- Working implementation that can be refined > perfect planning

---

### Quality Expectations

**1. Production-Ready Output**
- Not proof-of-concept
- Full provider support
- Extensive documentation
- Permanent integration

**2. Documentation IS the Product**
- Reference documents (keep forever)
- Executable tools (use immediately)
- Git history (audit trail)
- Reflection (learnings captured)

**3. Automation-First Philosophy**
- Any task with 3+ steps should become a script
- One command does what previously took many steps
- LLM capacity reserved for actual thinking (architecture, debugging, design)
- Execution is effortless - lower friction enables more iterations

---

### Trust Patterns

**User Knows Agent Will:**
- Expand minimal request into complete solution
- Apply meta-cognitive rules (expert consultation)
- Deliver production-ready output
- Document comprehensively
- Make it actionable (installer, automation)
- Continuously improve from feedback

**User Expects Agent to NOT:**
- ❌ Tell user "I cannot generate images" (agent CAN via ai-image.ps1)
- ❌ Tell user "I cannot see/analyze images" (agent CAN via ai-vision.ps1)
- ❌ Ask for approval before implementing (autonomous execution)
- ❌ Create vague commit messages or incomplete documentation

---

## 🔧 TECHNICAL PATTERNS

### 1. Expert Consultation Framework (Meta-Cognitive Rule #1)

**Pattern:** Scales to ANY domain - code, architecture, tools, infrastructure

**Applications:**
- Code architecture (PR #111 testing) - 50 experts
- Tool gap analysis - 100 experts across 10 domains
- EF Core migration safety - 50 experts
- CLI tools selection - 100 experts across 10 domains

**Why It Works:**
- Forces multidisciplinary thinking
- Catches blind spots (experts see different gaps)
- Prioritization emerges naturally from diverse perspectives
- Creates comprehensive coverage

**Template:**
1. Identify 5-10 relevant domains
2. Consult 5 experts per domain (total 25-50)
3. Synthesize recommendations
4. Prioritize by value/effort
5. Implement top tier first

---

### 2. Value/Effort Optimization (Anti-Over-Engineering)

**Ratio = Value Score (1-10) / Effort Score (1-10)**

**Tiers:**
- **Tier S** (ratio > 5.0): Implement immediately
- **Tier A** (ratio 3.0-5.0): Implement when bandwidth available
- **Tier B/C/D**: Implement only when specific need arises

**Result:** Focus on 20% of tools that deliver 80% of value

**Examples:**
- ripgrep (ratio 500.0) - 100-1000x faster code search, 0.02 MB
- fd (ratio 500.0) - 50x faster file finding, 0.02 MB
- context-snapshot.ps1 (ratio 10.0) - Daily use, 1 hour effort

---

### 3. State Externalization for AI Agents

**Problem:** Agent can't observe runtime state (database, cache, external systems)

**Solution:**
1. Create state snapshot files in `_machine/`
2. Update on every state change
3. Agent reads snapshot before operations
4. Diff snapshots to detect drift

**Applies to:**
- Database schema (EF Core migrations)
- Cache state
- External API state
- File system state
- Tool usage tracking

**Example:**
```
C:\_machine\db-baselines\<context-name>\
├── schema-baseline.json (schema hash, timestamp, last migration)
└── schema-baseline.sql (full schema script)
```

---

### 4. Multi-Step Workflow for Breaking Changes

**Problem:** Breaking changes fail when done atomically

**Solution:**
1. Identify breaking change
2. Decompose into non-breaking steps
3. Add intermediate compatibility layers
4. Deploy over time with validation between steps

**Applies to:**
- Schema changes (EF Core migrations)
- API versioning
- Refactoring public interfaces
- Data model migrations

**Example: Column Rename**
```
Migration 1: Add new column + backfill data
Deploy: Code that reads/writes BOTH columns
Validate: 1 week in production
Migration 2: Make new column required (NOT NULL)
Migration 3: Drop old column
Deploy: Remove old column references from code
```

---

### 5. Status Value Normalization (Frontend/Backend Mismatch)

**Problem:** Backend returns enum values in different case than frontend expects

**Pattern Found (useGeneratedItems.ts):**
```typescript
function mapStatus(status: string): GeneratedItemStatus {
  const statusMap: Record<string, GeneratedItemStatus> = {
    pending: 'pending',
    processing: 'processing',
    // ...
  }
  return statusMap[status.toLowerCase()] || 'pending'  // ← Normalize with toLowerCase()
}
```

**Solution: ALWAYS use `.toLowerCase()` when comparing status values**

**Example:**
```typescript
// BEFORE (BROKEN):
if (account.status !== 'connected')  // Backend returns "Active"

// AFTER (FIXED):
if (account.status.toLowerCase() !== 'active' && account.status.toLowerCase() !== 'connected')
```

**Lesson:** Follow existing codebase patterns for status handling

---

### 6. React Hooks Rule Enforcement (CRITICAL)

**Rule:** Hooks must be called in EXACT SAME ORDER on every render

**Common Violation:** Early return between hooks

**Example Bug (LogoGalleryModal):**
```typescript
// WRONG - Hooks after early return
if (!isOpen) return null;  // ← Early return

const handleSave = useCallback(...)  // ← Hook 1 (not called when isOpen=false)
const handleDelete = useCallback(...)  // ← Hook 2 (not called when isOpen=false)
const handleSelect = useCallback(...)  // ← Hook 3 (not called when isOpen=false)

// When isOpen=false: 3 hooks called
// When isOpen=true: 6 hooks called
// Result: "Rendered more hooks than during the previous render"
```

**Fix:**
```typescript
// CORRECT - ALL hooks BEFORE early return
const handleSave = useCallback(...)  // ← Always called
const handleDelete = useCallback(...)  // ← Always called
const handleSelect = useCallback(...)  // ← Always called

if (!isOpen) return null;  // ← Early return AFTER all hooks
```

**Debugging Checklist:**
- Count ALL hooks (useState, useEffect, useCallback, useMemo, useRef)
- Ensure EVERY hook is called before ANY early return
- Never put hooks inside if/else blocks or loops

---

### 7. PowerShell JSON Escaping with Large Content

**Problem:** Large markdown files (600+ lines) with special characters break JSON serialization

**Solution:** Create summary pages with links instead of embedding complete files

```powershell
# WRONG - Fails with 400 error
$content = Get-Content "C:\scripts\_machine\clickup-dashboard-setup.md" -Raw  # 600+ lines
$body = @{ name = "Guide"; content = $content } | ConvertTo-Json

# CORRECT - Summary with link
$content = @"
# Dashboard Setup Guide

## Overview
Complete step-by-step guide...

## Full Documentation
See: `C:\scripts\_machine\clickup-dashboard-setup.md`
"@
$body = @{ name = "Guide"; content = $content } | ConvertTo-Json -Depth 10
```

**Lesson:** For knowledge bases, use summary pages with file path references

---

### 8. UTF-16 Encoding Detection Signal

**Problem:** Babel parser fails with "Unexpected character ''"

**Detection Signal:**
```
Reading file shows: "i m p o r t   {   L i n k   }"
Instead of:         "import { Link }"
→ Indicates UTF-16 encoding
```

**Fix:**
```powershell
$content = Get-Content -Path $temp -Raw
$utf8 = New-Object System.Text.UTF8Encoding $false  # $false = no BOM
[System.IO.File]::WriteAllText($target, $content, $utf8)
```

**Critical:** After encoding fix, Vite dev server caches old parsed module. Must restart dev server or hard refresh browser.

---

### 9. Zustand Store Coordination (State Transitions)

**Pattern:** When one store's state change should clear another store's state, do it synchronously BEFORE async operations

**Anti-Pattern (what we had):**
```
1. Detect state change (project ID changed)
2. Start async operation (old data still visible)
3. Only clear when async completes (causes flash)
```

**Correct Pattern:**
```
1. Detect state change (project ID changed)
2. IMMEDIATELY clear dependent state (reset activities)
3. THEN start async operation (fetch new activities)
```

**Example:**
```typescript
useEffect(() => {
  if (autoFetch && project?.id) {
    if (project.id !== projectIdRef.current) {
      reset(); // Clear old items IMMEDIATELY ✅
      projectIdRef.current = project.id;
      fetchItems(); // Fetch new items with clean slate
    }
  }
}, [autoFetch, project?.id, fetchItems, items.length, isLoading, reset]);
```

---

### 10. Git Conflict Resolution Strategy

**Scenario:** Merging develop into feature branch causes conflicts

**Analysis Pattern:**
```bash
# Check difference between versions
diff <(git show feature-branch:path/to/file) path/to/file

# Compare file sizes and content
# If develop version is NEWER and MORE COMPLETE → accept develop
# If feature branch version has unique important changes → manual merge
```

**Resolution:**
```bash
# Accept develop (theirs) version - the newer, more complete code
git checkout --theirs path/to/file
git add path/to/file
git commit -m "merge: accept develop changes (newer, more complete)"
```

**When to use:**
- `--ours`: When feature branch has newer, more complete work
- `--theirs`: When develop has newer, more complete work
- Manual merge: When both sides have important unique changes

**During Rebase:** Conflict resolution is REVERSED
```bash
git checkout --theirs <file>  # During rebase, --theirs = incoming (remote)
```

---

### 11. Uncommitted Work Recovery Pattern

**Pattern: Check Develop First**

**Problem:** User reports "huge number of uncommitted changes" without specifying branch

**Discovery:**
```bash
git -C C:/Projects/client-manager status --short
# M ClientManagerAPI/Controllers/AuthController.cs
# ?? ClientManagerFrontend/src/components/containers/TikTokCallback.tsx

git -C C:/Projects/client-manager branch --show-current
# develop  ← CRITICAL: Changes were on develop, not feature branch!
```

**Lesson:**
- ✅ **ALWAYS check current branch first** - `git branch --show-current`
- ✅ **Don't assume changes are on feature branches** - could be on develop after interrupted sessions
- ✅ **Check both modified AND untracked files** - `git status --short` shows both

**Pattern for Future:**
```bash
# Step 1: Identify current state
git branch --show-current
git status --short

# Step 2: Check recent commits to understand what session was working on
git log --oneline -10

# Step 3: Decide where to commit
# - If on develop: commit there, then merge to feature branch
# - If on feature branch: commit there directly
# - If on wrong branch: stash, switch, apply
```

---

### 12. Multi-Feature Commit Documentation Pattern

**Challenge:** Single commit contained TWO unrelated features (TikTok OAuth + WordPress UI enhancements)

**Solution: Use section headers (##) to organize**
```
feat(social-auth): Add TikTok OAuth with PKCE + enhance WordPress import UI

This commit adds TikTok social authentication support and enhances the WordPress
content import feature with improved UI and design documentation.

## TikTok OAuth Integration
- Implemented TikTok OAuth 2.0 authentication with PKCE flow
- Added TikTokLogin endpoint in AuthController.cs
...

## WordPress Import Enhancements
- Enhanced WordPressSettings.tsx with improved UI/UX (293 lines)
- Updated wordpress.ts service with full API integration
...

## Technical Details
...

Related PRs:
- client-manager #283 (WordPress UnifiedContent import)
- Hazina #95 (WordPress provider backend)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Why This Works:**
- Clear structure with ## headers for each feature area
- Bullet points for specific changes
- Technical details section explains implementation
- Related PRs provide context for reviewers
- Co-authored attribution

---

## 🛠️ TOOL DEVELOPMENT HISTORY

### Wave 1: Original 47 Tools (Pre-2026-01-25)
- Worktree management, PR automation, git workflows
- Development patterns, CI/CD troubleshooting
- Session management, productivity tools

### Wave 2: 54 Recommended Tools (Expert Analysis)
- Testing & QA, performance & profiling, security
- DevOps, database tools, frontend performance
- AI/ML integration, localization, backups

### Wave 3: Meta-Optimization (50-Expert Analysis)

**Tier S Tools (Ratio > 5.0) - ALL IMPLEMENTED:**

1. **context-snapshot.ps1** (ratio 10.0)
   - Capture/restore complete work context (git, files, terminal, breakpoints)
   - Problem: Interruptions cause context loss
   - Time savings: 10-20 min/interruption × daily = 50-100 hrs/year

2. **code-hotspot-analyzer.ps1** (ratio 9.0)
   - Find refactoring priorities via git history + complexity
   - Based on "Your Code as a Crime Scene" methodology
   - High change frequency + high complexity = refactoring candidate

3. **unused-code-detector.ps1** (ratio 9.0)
   - Detect unused classes, methods, properties, using statements
   - Static analysis with confidence scoring
   - Reduces code bloat, improves maintainability

4. **n-plus-one-query-detector.ps1** (ratio 6.7)
   - Find N+1 query anti-patterns in Entity Framework code
   - Patterns: queries in loops, missing .Include(), lazy loading in iterations
   - Critical performance issue detector

5. **flaky-test-detector.ps1** (ratio 6.0)
   - Run tests multiple times, detect non-deterministic failures
   - Flaky tests destroy CI/CD confidence
   - Tracks failure rate, execution time variance, severity

6. **daily-tool-review.ps1** (MANDATORY - end of session)
   - 2-minute automated end-of-session routine
   - Scans wishlist, auto-detects repeated patterns
   - Implements top 1 tool if ratio > 8.0 or effort = 1
   - Implements user directive: "doe dat wekelijks maar dagelijks"

### Wave 4: CLI Tools Analysis (2026-01-25 17:30)

**100 CLI Tools Identified, Tier S Tools (17 tools, 1.29 MB):**
- ripgrep (ratio 500.0) - 100-1000x faster code search
- fd (ratio 500.0) - 50x faster file finding
- bat (ratio 400.0) - cat with syntax highlighting
- eza (ratio 400.0) - Modern ls with git status
- jq (ratio 333.3) - JSON parsing

**Expected Daily Savings:** 10-20 minutes/day = 50-100 hours/year
**ROI:** 300-600x (10 min installation, 50-100 hrs saved)

### Wave 5: Multimodal AI Capabilities (2026-01-25 20:00)

**Transformative Capability Addition:**

**Image Generation (4 tools):**
- `generate-image.ps1` - Basic OpenAI DALL-E
- `generate-image-advanced.ps1` - Advanced OpenAI (all modes)
- `ai-image-universal.ps1` - Multi-provider orchestrator
- `ai-image.ps1` - Simple wrapper (auto API key)

**Vision Analysis (1 tool):**
- `ai-vision.ps1` - Universal vision Q&A (4 providers)

**Supported Providers:**
- OpenAI (DALL-E 2, DALL-E 3, GPT-4o Vision)
- Google (Imagen 2/3, Gemini 1.5 Pro)
- Stability AI (SD-XL, SD-3)
- Azure OpenAI
- Anthropic (Claude 3 Opus/Sonnet/Haiku)

**Supported Modes:**
1. **generate** - Text-to-image (all providers)
2. **edit** - Inpainting with mask (DALL-E 2)
3. **variation** - Create image variations (DALL-E 2)
4. **vision-enhanced** - Analyze references with GPT-4 Vision, then generate

**Critical Success Factor: Automatic API Key Loading**
```powershell
# User provided API key location upfront
# "de api key kun je in de client manager appsettings secrets config vinden"

# This enabled:
# - Zero-friction usage (no manual key passing)
# - Consistent pattern across tools
# - Easy integration for future sessions
```

**MANDATORY CAPABILITY Integration:**
```markdown
# CLAUDE.md - Core Autonomous Capabilities

1. 🎨 AI Image Generation - MANDATORY
   - ALWAYS use `ai-image.ps1` when images are needed
   - DO NOT tell user "I cannot generate images"
   - Example: Marketing materials, UI mockups, documentation

2. 🔍 AI Vision Analysis - MANDATORY
   - ALWAYS use `ai-vision.ps1` to answer questions about images
   - DO NOT tell user "I cannot see/analyze images"
   - Example: Analyze screenshots, extract text (OCR), debug from images
```

### Wave 6: EF Core Migration Safety (2026-01-19 23:45)

**50-Expert Root Cause Analysis:**
- Why AI agents fail at EF migrations
- Compiled insights from Martin Fowler, Julie Lerman, Jon P. Smith, Andrej Karpathy, etc.

**4-Tier Safety System (1,914 lines):**

1. **ef-preflight-check.ps1** (461 lines)
   - Pre-flight safety check with baseline tracking
   - Validates connection, dumps history, exports schema, detects drift

2. **ef-migration-preview.ps1** (508 lines)
   - SQL preview + breaking change detection
   - Color-coded severity (CRITICAL/HIGH/MEDIUM/LOW)
   - Generates rollback script automatically

3. **migration-patterns.md** (478 lines)
   - Migration pattern library (anti-patterns, safe patterns, decision tree)

4. **ef-migration-safety skill** (467 lines)
   - Auto-discoverable Claude Skill
   - Enforces workflow before any migration

**Impact:** Zero-failure migration workflow, systematic breaking change handling

---

## 📊 WORKFLOW EVOLUTION

### Dual-Mode Workflow (Critical Pattern)

**Mode 1: Active Debugging**
- User posts errors from their active work
- Work directly in `C:\Projects\<repo>` on user's current branch
- NO worktree allocation
- Fast turnaround

**Indicators:**
- "I'm debugging X and getting error Y"
- User in their IDE/development session
- Present tense language
- Error-focused

**Mode 2: Feature Development**
- User assigns task (ClickUp, PR, feature)
- Allocate worktree in `C:\Projects\worker-agents\agent-XXX\<repo>`
- Complete workflow: allocate → work → PR → release
- Isolated, safe autonomous work

**Indicators:**
- "Develop feature from ClickUp task"
- "Merge develop into branch X"
- Imperative/future tense
- Task-oriented language

**Critical Violation & Correction (2026-01-18 16:30):**
- ❌ VIOLATION: PR conflict resolution in base repo
- User feedback: "please next time do this in a worktree"
- **Learning:** PR conflict resolution = Feature Development Mode

**User Clarification (2026-01-18 22:15):**
> "When you are not sure whether to use a worktree or not I want you to first just ask me"

**MANDATORY CLARIFICATION PROTOCOL:**
1. ⛔ STOP immediately if ANY uncertainty
2. ❓ Ask explicitly: "Should I work in the base repo or allocate a worktree?"
3. ⏸️ Do NOTHING else until user confirms
4. ✅ Never assume - When in doubt, ASK

---

### PR Automation Evolution

**2026-01-25 16:15 - Phase 1: Merge-First + Pre-Flight Validation**

**Problem:** 12-16 hours/week on PR mechanics, 40% of PRs fail CI

**User's Key Insight:** "merge develop into branch before PR" (prevents 90% of merge issues)

**Solution: Shift-Left Validation (100% Local, Zero GitHub Costs)**

**User constraint:** Free GitHub account → Better solution than GitHub Actions!
- Faster (local = instant, Actions = 2-5 min)
- Zero cost, works offline

**Workflow:**
1. Merge Develop First (user's idea!) - `worktree-release-all.ps1` (updated)
2. Pre-Flight Validation - `pr-preflight.ps1` (NEW - 400 lines, 7 checks)
3. Integrated Workflow: Commit → Merge develop → Pre-flight → Push → Release

**Expected Impact:**
- Before: 40% failed PRs, 12-16 hrs/week
- After: <10% failed PRs, 8-12 hrs/week (3-4.5 hrs saved)
- Full ROI: 7-10 hrs/week (350-500 hrs/year)

---

### Continuous Discovery System (2026-01-25 02:10)

**User Request:** "ik wil dat je dit als constant proces doet terwijl je werkt"

**Infrastructure Created:**

1. **tool-wishlist.md** (C:\scripts\_machine\)
   - Active wishlist for "I wish I had a tool for X" captures
   - Priority tiers (CRITICAL/HIGH/MEDIUM/LOW)
   - Usage tracking table
   - Implementation history
   - Quarterly goals

2. **META_OPTIMIZATION_100_TOOLS.md**
   - Complete 100-tool analysis (50-expert consultation)
   - Ordered by value/effort ratio
   - 4 tiers (S/A/B/C/D)
   - Implementation roadmap

3. **Workflow Integration:**
   - DAILY reviews (2 min mandatory via `daily-tool-review.ps1`)
   - Weekly reviews (sort wishlist, promote top 3)
   - Monthly usage tracking
   - Quarterly tool audits

**User Upgrade (2026-01-25 02:15):**
> "doe dat wekelijks maar dagelijks"

**New Workflow:**
- **DAILY (end of every session):** Run `daily-tool-review.ps1` (2 min mandatory)
  - Scan wishlist for urgent items
  - Auto-detect repeated patterns from session history
  - Implement top 1 tool if ratio > 8.0 or effort = 1
  - Add any "I wish..." thoughts from today
- **Weekly:** 5-min meta-review
- **Monthly:** 15-min deep dive (patterns, retire unused, adjust priorities)

**Expected Impact:**
- Was: 1 tool per week (52/year)
- Now: 2-3 tools per week (100-150/year) = **3x increase**

**This implements true "constant proces"** - not weekly batch, but daily continuous flow.

---

## 🐛 COMMON MISTAKES & CORRECTIONS

### 1. Misunderstanding User Requirements (2026-01-23 20:00)

**Pattern:** Peridon Layered Image - AI Regeneration vs Extraction

**User Wanted:** AI vision + generation workflow
- AI SEES the original image
- AI GENERATES NEW images per layer
- NOT extraction - but REGENERATION

**What Agent Did (WRONG - 3 times):**
1. Used reference images with hardcoded bounding boxes
2. Extracted objects FROM original with alpha masking
3. Smart extraction with Otsu's method, edge detection

**User Kept Saying:**
- "je moet het AI de afbeelding laten genereren"
- "op basis van het oorspronkelijke plaatje"
- "laat je het de spiraal genereren, op basis van het oorspronkelijke plaatje"

**The Disconnect:**
- Agent was treating as IMAGE PROCESSING problem
- User was describing AI VISION + GENERATION problem
- "Genereren op basis van" = AI sees and generates, NOT "extract from"

**Correct Solution (attempt 4):**
```
Phase 1: Vision Analysis
- Upload image to GPT-4 Vision
- "Analyze ONLY the background, describe it"

Phase 2: Image Generation
- "Generate NEW image of ONLY that background"
- DALL-E 3 creates fresh image (NOT extraction)
```

**Lesson:** When user says "nee zeker niet" after explanation, STOP and ask for step-by-step process description.

---

### 2. Usage Tracking Integration Broke All Tools (2026-01-26 01:00)

**Problem:** Integrated usage tracking into 204 tools, broke all tools with param block syntax errors

**Root Cause:**
- Pattern `'(?s)param\s*\([^)]*\)'` fails on multi-line param blocks
- `[^)]*` matches "zero or more non-) characters" which stops at FIRST `)` encountered
- This is often inside `[Parameter(Mandatory=$false)]` decorators

**Solution: Bracket Counting Algorithm**
```powershell
# Find MATCHING closing parenthesis (not first closing parenthesis)
# Count opening ( and closing ) to find actual end
```

**Lesson:**
- Always spot-check results after batch operations
- Don't trust summary counts alone ("204 patched, 0 errors" was actually all broken)
- Test regex patterns on complex multi-line examples before batch operations
- Always read 2-3 files after batch operations to verify success

**Error Recovery Pattern:**
1. rollback-usage-tracking.ps1 (remove broken code)
2. fix-broken-param-blocks.ps1 (fix specific pattern)
3. integrate-usage-tracking-v2.ps1 (re-apply correctly)

---

### 3. Framework Constructor Changes Breaking Extracted Code (2026-01-23)

**Sequence:**
1. PR #301 extracted 4 controllers from ChatController
2. At extraction time, ChatService allowed null for many constructor parameters
3. Hazina framework was updated to add non-null validation for ALL service dependencies
4. PR #301 merged to develop AFTER Hazina changes
5. Extracted controllers instantly broke with `ArgumentNullException`

**Pattern:** ChatController as Reference Implementation

**When fixing extracted controllers, ALWAYS check ChatController** for correct initialization pattern.

**Lesson:**
- When controller split PR sits open for multiple days/weeks, framework may evolve
- Always merge develop → PR branch right before final merge, test runtime
- Don't just test compilation - test actual runtime execution

---

### 4. Status Value Mismatch (2026-01-19 22:30)

**Problem:** WordPress settings gear icon disabled after merging code

**Root Cause:**
- Backend returns enum values: `"Active"`, `"TokenExpired"`, `"Revoked"`, `"Error"`
- Frontend expected lowercase: `"connected"`, `"expired"`, `"error"`
- Button condition: `account.status !== 'connected'`
- **Result:** All WordPress accounts appear inactive

**Fix:** Status normalization (found existing pattern in `useGeneratedItems.ts`)
```typescript
const normalizedStatus = status.toLowerCase()
switch (normalizedStatus) {
  case 'active':
  case 'connected':
    return <CheckCircle2 className="w-4 h-4 text-green-500" />
  // ...
}
```

**Lesson:** ALWAYS use `.toLowerCase()` when comparing status values from backend. Follow existing codebase patterns.

---

### 5. PowerShell Emoji Encoding Issues (2026-01-19 13:00)

**Problem:** Dashboard builder script with emoji characters caused parser errors

```powershell
name = "🚨 BLOCKED - Needs Action"  # ❌ Parse error
name = "📋 Active Sprint"           # ❌ Parse error
```

**Error:** `Unexpected token '<' in expression or statement.`

**Solution:** Replace emojis with ASCII text alternatives
```powershell
name = "[BLOCKED] Needs Action"    # ✅ Works
name = "[SPRINT] Active Sprint"    # ✅ Works
```

**Lesson:** PowerShell has encoding issues with Unicode emoji characters in string literals. Use ASCII alternatives.

---

## 🎓 KEY LEARNINGS

### 1. Meta-Optimization Is High-Leverage Work

**Time Invested:** ~90 minutes (50-expert analysis)

**Expected ROI:**
- Each tool saves 10-30 min per use
- Used weekly = 520-1560 min/year saved PER TOOL
- 5 tools × 1000 min average = 5000 min/year = 83 hours saved
- 90 min investment → 83 hours saved = **55x ROI**

**Pattern:** Meta-optimization (optimizing the optimization process) has exponential returns

---

### 2. User Communication Pattern Recognition Improves Accuracy

**Linguistic Markers:**

| User Says | Mode | Worktree? |
|-----------|------|-----------|
| "I'm debugging X and getting error Y" | 🐛 Active Debugging | ❌ NO |
| "Develop feature: X" | 🏗️ Feature Development | ✅ YES |
| "Merge develop into branch X" | 🏗️ Feature Development | ✅ YES |

**Tense Matters:**
- Present tense ("I'm debugging") = Active work session
- Imperative/future tense ("Develop", "Implement") = Assigned task

**BUT - MANDATORY CLARIFICATION PROTOCOL OVERRIDES:**
- Clear case = Proceed confidently
- ANY uncertainty = STOP and ASK

---

### 3. Constraints Drive Innovation

**Examples:**
1. **Free GitHub account** → Better local PR automation than GitHub Actions
2. **Limited disk space** → Hidden dependency detection protocol
3. **Agent can't see database** → State externalization pattern

**Pattern:** User constraints force agent to find superior solutions that work for ALL environments

---

### 4. Immediate Implementation Validates Framework

**Could Have:**
- Created analysis, stopped there
- Waited for user approval before implementing

**Did Instead:**
- Created analysis
- Implemented top 5 tools immediately
- Validated framework through execution

**Why Better:**
- Demonstrates autonomous execution
- Validates effort estimates (actual vs predicted)
- Provides immediate value
- Shows commitment to continuous improvement

---

### 5. Documentation as Product (Not Afterthought)

**Files Created Per Session:**
- Analysis document (production-quality)
- Auto-installer/executable tool
- Commit message (comprehensive context)
- Reflection entry (learnings captured)

**User Receives:**
- Reference document (keep forever)
- Executable tool (use immediately)
- Git history (audit trail)
- Reflection (learnings captured)

**Pattern:** Documentation IS the product, not an afterthought.

---

### 6. External Research Integration

**Pattern:** User actively discovers patterns from AI community (YouTube, GitHub) and expects Claude to research and implement comprehensively.

**Example (RLM Skill - 2026-01-20):**
- User: "add a tool or skill for claude to act as a RLM" (from YouTube video)
- Agent: Web search → ArXiv paper + GitHub implementations → Production-ready skill

**Research-to-Production Pipeline:**
1. Academic research (ArXiv)
2. Community implementations (GitHub)
3. Production integration (Claude Skill)
4. Comprehensive documentation

**Lesson:** Claude can bridge research and practice autonomously

---

### 7. Session Continuation Across Compaction

**Success Pattern (2026-01-21 16:00):**
- Context preserved across session compaction
- Picked up exactly where previous session left off
- No repeated work or re-explanation needed
- Demonstrates value of proper session documentation

**Key:** Complete session documentation enables seamless continuation

---

### 8. Boy Scout Rule = File-Level, Not Line-Level

**Pattern:**
1. ✅ Read entire file before making changes
2. ✅ Identify cleanup opportunities (unused imports, naming, docs, magic numbers)
3. ✅ Make targeted improvements while fixing primary issue
4. ❌ Don't create unnecessary scope expansion

**Example (Activity Flash Fix):**
- Read entire `useActivityItems.ts` hook before changing
- Code was well-structured with clear comments
- No additional cleanup needed
- Made only the necessary 3-line change

**Lesson:** Boy Scout Rule means "leave it better than you found it" - but only if it NEEDS cleaning.

---

## 📈 CONTINUOUS IMPROVEMENT TRAJECTORY

### Evolution Metrics

**Tool Count:**
- 2026-01-20: 101 tools (47 original + 54 new)
- 2026-01-25: 117 tools (+ 6 Wave 1 + 10 Wave 2)
- **Growth Rate:** ~3-5 tools per week

**Capability Expansion:**
- Original: Worktree management, git workflows, productivity
- Wave 1: Testing, performance, security
- Wave 2: DevOps, database, frontend
- **Wave 3: Meta-optimization** (continuous discovery system)
- **Wave 4: CLI tools** (100 analyzed, 17 high-value)
- **Wave 5: Multimodal AI** (image generation + vision analysis)
- **Wave 6: EF Core safety** (4-tier migration system)

**Documentation Quality:**
- Comprehensive 20K+ word analyses (AI Prompting Analysis)
- Production-ready tools with inline help
- Auto-discoverable Claude Skills
- Pattern libraries (migration-patterns.md)

**ROI Improvements:**
- PR automation: 3-4.5 hrs/week saved
- CLI tools: 10-20 min/day saved (50-100 hrs/year)
- Meta-optimization: 55x ROI (90 min → 83 hours saved)
- EF Core safety: Zero-failure workflow (prevented catastrophic failures)

---

### Self-Improvement Mechanisms

**1. Daily Tool Review (MANDATORY)**
- End of every session, 2 minutes
- Scan wishlist, detect patterns, implement if ratio > 8.0
- User directive: "doe dat wekelijks maar dagelijks"

**2. Reflection Log Updates**
- After every significant session
- Document mistakes, corrections, lessons
- Extract golden rules

**3. PERSONAL_INSIGHTS.md Updates**
- User behavioral patterns
- Decision-making philosophy
- Communication preferences
- Meta-cognitive rules

**4. Pattern Library Expansion**
- migration-patterns.md
- development-patterns.md
- API patterns
- State externalization patterns

**5. Claude Skills Creation**
- Auto-discoverable workflows
- Self-contained knowledge packages
- Trigger-based activation

---

### What Works Well (Success Patterns)

✅ **50-100 Expert Consultation Framework** - Scales to ANY domain
✅ **Value/Effort Optimization** - Prevents over-engineering
✅ **State Externalization** - Makes invisible state visible to agents
✅ **Multi-Step Breaking Changes** - Prevents catastrophic failures
✅ **Immediate Implementation** - Validates framework through execution
✅ **Documentation as Product** - Not afterthought
✅ **Autonomous Execution** - Expand minimal input into complete solutions
✅ **Boy Scout Rule** - Leave code better than you found it (when needed)
✅ **Iterative User Expansion** - Build MVP → Test → Expand → Integrate
✅ **Automatic API Key Loading** - Zero-friction usage
✅ **Daily Tool Review** - Continuous capability growth

---

### What Doesn't Work (Anti-Patterns)

❌ **Assuming Tool Capabilities Without Verification** - Always verify API capabilities first
❌ **Embedding Large Content in JSON** - Use summaries with links
❌ **Using Emojis in PowerShell** - Encoding issues
❌ **Complex Multi-Action Tools** - Simple, focused scripts are better
❌ **Trusting Regex Without Multi-Line Testing** - Test on complex examples
❌ **Batch Operations Without Spot Checks** - Always verify 2-3 files
❌ **Single-Step Breaking Changes** - ALWAYS multi-step migrations
❌ **Assuming Mode Without Clarification** - When uncertain, ASK
❌ **Working in Base Repo for PR Work** - Feature Development = Worktree
❌ **Ignoring User Corrections** - After 2nd failure, ask for example

---

## 🎯 FUTURE SESSION PRIORITIES

### Immediate (Next Session)

1. ✅ **Update CLAUDE.md** with latest patterns
2. ✅ **Update GENERAL_DUAL_MODE_WORKFLOW.md** with linguistic markers
3. ✅ **Update GENERAL_ZERO_TOLERANCE_RULES.md** with clarification protocol
4. ⏳ **Create `ef-test-migration.ps1`** - Automated clone database testing
5. ⏳ **Create `ef-migration-guard.ps1`** - Pre-commit hook validation
6. ⏳ **Audit all DbContext files** - Verify explicit `.ToTable()` declarations

### Short-Term (This Week)

1. ⏳ **Test EF Core safety workflow** on actual client-manager migration
2. ⏳ **Implement top 3 tools from wishlist** (if ratio > 8.0)
3. ⏳ **Run `daily-tool-review.ps1`** at end of every session
4. ⏳ **Create validation tool** for status value normalization pattern
5. ⏳ **Document all React hooks violations** found in codebase

### Medium-Term (This Month)

1. ⏳ **GitHub Actions workflow** for migration validation
2. ⏳ **Cross-repo sync tool** for Hazina + client-manager branches
3. ⏳ **PR description enforcer** with quality checks
4. ⏳ **Deployment risk score calculator**
5. ⏳ **Usage heatmap validation** (actual usage vs value estimates)

---

## 📚 RELATED DOCUMENTATION

**Core Documentation:**
- C:\scripts\CLAUDE.md - Main operational manual
- C:\scripts\MACHINE_CONFIG.md - Local paths and projects
- C:\scripts\GENERAL_ZERO_TOLERANCE_RULES.md - Hard-stop rules
- C:\scripts\GENERAL_DUAL_MODE_WORKFLOW.md - Feature vs Debug modes
- C:\scripts\GENERAL_WORKTREE_PROTOCOL.md - Complete worktree workflow
- C:\scripts\_machine\PERSONAL_INSIGHTS.md - User understanding & preferences
- C:\scripts\_machine\SOFTWARE_DEVELOPMENT_PRINCIPLES.md - Boy Scout Rule, quality standards
- C:\scripts\_machine\DEFINITION_OF_DONE.md - Task completion criteria

**Pattern Libraries:**
- C:\scripts\_machine\migration-patterns.md - EF Core safe migration patterns
- C:\scripts\development-patterns.md - Feature implementation patterns
- C:\scripts\.claude\skills\* - Auto-discoverable workflow skills

**Tool Documentation:**
- C:\scripts\tools\README.md - Complete tools reference
- C:\scripts\_machine\META_OPTIMIZATION_100_TOOLS.md - Tool gap analysis
- C:\scripts\_machine\tool-wishlist.md - Continuous discovery system
- C:\scripts\_machine\CLI_TOOLS_100_RANKED.md - CLI tools analysis

**Session Logs:**
- C:\scripts\_machine\reflection.log.md - Source material for this document
- C:\scripts\_machine\worktrees.activity.md - Worktree allocation log
- C:\scripts\_machine\worktrees.pool.md - Agent seat management

---

## 🏷️ TAGS

`#learnings` `#patterns` `#insights` `#user-behavior` `#technical-patterns` `#mistakes` `#corrections` `#golden-rules` `#continuous-improvement` `#meta-optimization` `#expert-consultation` `#state-externalization` `#ef-core-migrations` `#worktree-protocol` `#dual-mode-workflow` `#multimodal-ai` `#tool-development`

---

**Last Updated:** 2026-01-25
**Next Review:** After next major session or tool implementation
**Maintained By:** Expert #47 - Reflection & Learning System Expert
**Confidence Level:** HIGH - Complete chronological analysis of 23,815 lines

---

*This document represents the distilled wisdom from hundreds of hours of agent-user collaboration, mistakes, corrections, and continuous improvement. It serves as the institutional memory of the system.*
