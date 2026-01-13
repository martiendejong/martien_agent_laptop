## 🚀 CONTINUOUS IMPROVEMENT PROTOCOL - MANDATORY SELF-LEARNING

**USER MANDATE (2026-01-08):** "zorg dat je dus constant leert van jezelf en je eigen instructies bijwerkt"

**CRITICAL: You MUST constantly learn from yourself and update your own instructions:**

### WHEN TO UPDATE (Constantly):

1. **After ANY mistake or violation:**
   - Log incident in C:\scripts\_machine\reflection.log.md
   - Update C:\scripts\claude.md with corrective procedures
   - Update C:\scripts\claude_info.txt with warnings
   - Create new checklist if needed

2. **After discovering new tools/workflows:**
   - Document in C:\scripts\claude.md immediately
   - Add to C:\scripts\tools\ if applicable
   - Update C:\scripts\status\overview.md

3. **After user feedback or correction:**
   - IMMEDIATELY update all relevant instruction files
   - Add to reflection.log.md with "Lesson learned"
   - Ensure next session will follow corrected behavior

4. **After completing complex tasks successfully:**
   - Document the successful pattern
   - Add to reflection.log.md as "Achievement"
   - Share learnings for future sessions

### WHAT TO UPDATE (Everything):

**Files to update regularly:**
- C:\scripts\claude.md - Operational procedures
- C:\scripts\claude_info.txt - Critical reminders
- C:\scripts\_machine\reflection.log.md - Lessons learned
- C:\scripts\scripts.md - Workflow documentation
- C:\scripts\ZERO_TOLERANCE_RULES.md - Quick reference
- C:\scripts\.claude\skills\**\SKILL.md - Auto-discoverable workflow guides (NEW: 2026-01-12)

**Examples of improvements to capture:**
- ✅ Workflow violations and corrections
- ✅ New automation scripts (cs-format.ps1, cs-autofix)
- ✅ Debug procedures (config file copying)
- ✅ Error patterns and solutions
- ✅ Tool integrations and discoveries
- ✅ User feedback and mandates
- ✅ **NEW:** Reusable patterns that should become Skills

### HOW TO UPDATE (Immediately):

```
STEP 1: Identify improvement/lesson
STEP 2: Update reflection.log.md with incident/achievement
STEP 3: Update claude.md with new procedure
STEP 4: Update claude_info.txt with critical reminder
STEP 5: Create tools/scripts if needed
STEP 6: Evaluate if pattern should become a Skill (NEW: 2026-01-12)
        - Is workflow complex with multiple mandatory steps?
        - Is pattern used frequently across sessions?
        - Would auto-discovery help future sessions?
        → If YES: Create new Skill in .claude/skills/
STEP 7: Verify updates are clear and actionable

DO NOT DELAY. DO NOT "save for later". UPDATE NOW.
```

### CLAUDE SKILLS INTEGRATION (NEW: 2026-01-12):

**When to create a new Skill:**
- ✅ Workflow has multiple mandatory steps (e.g., worktree allocation, PR release)
- ✅ Pattern is frequently used across sessions (e.g., API pitfalls, terminology migration)
- ✅ Mistakes are costly (e.g., multi-agent conflicts, cross-repo dependencies)
- ✅ New agents benefit from guided workflow (e.g., GitHub workflows, session reflection)
- ❌ Simple one-step operations (use Tools instead)
- ❌ One-time tasks (document in reflection.log.md only)

**Skills creation pipeline:**
```
Problem/Pattern discovered
    ↓
reflection.log.md entry (Pattern N)
    ↓
Evaluate: Complex + Reusable?
    ↓ YES
Create Skill in .claude/skills/<skill-name>/SKILL.md
    ↓
Update CLAUDE.md with Skill reference
    ↓
Commit and push
```

**Existing Skills (as of 2026-01-12):**
- Worktree management: allocate-worktree, release-worktree, worktree-status
- GitHub workflows: github-workflow, pr-dependencies
- Development patterns: api-patterns, terminology-migration, multi-agent-conflict
- Continuous improvement: session-reflection, self-improvement

**See:** `self-improvement` Skill for detailed Skill creation process

### SUCCESS METRICS:

**You are self-improving ONLY IF:**
- ✅ Every mistake is logged in reflection.log.md
- ✅ Instructions are updated after every correction
- ✅ Next session would NOT make the same mistake
- ✅ Documentation grows with every session
- ✅ User never has to repeat the same correction twice
- ✅ **NEW:** Complex patterns become auto-discoverable Skills
- ✅ **NEW:** Skills guide future sessions automatically

**This is NOT optional - it's how you improve over time and avoid repeating mistakes.**

**ZERO-TOLERANCE POLICY REMINDER:** Failure to learn and update = repeated violations = CRITICAL FAILURE


## 🚨🚨🚨 MANDATORY: END-OF-TASK SELF-UPDATE PROTOCOL 🚨🚨🚨

**USER MANDATE (2026-01-09):** "update the files in c:\scripts... do this at the end of every task/response"

### WHEN TO EXECUTE: At the END of EVERY task where you:
- Learned something new
- Fixed an error
- Discovered a pattern
- Received user feedback
- Completed a complex task

### WHAT TO UPDATE:

```
STEP 1: Update C:\scripts\_machine\reflection.log.md
  - Add new entry with date/time
  - Document patterns discovered
  - Document errors and fixes
  - Document process improvements

STEP 2: Update C:\scripts\claude_info.txt (if applicable)
  - Add new patterns to "Common CI/PR Fix Patterns"
  - Add new critical reminders

STEP 3: Update C:\scripts\CLAUDE.md (if applicable)
  - Add new workflow sections
  - Add new process improvements

STEP 4: Evaluate if pattern should become a Skill (NEW: 2026-01-12)
  - Complex workflow with multiple steps?
  - Frequently used pattern?
  - Would auto-discovery help future sessions?
  → If YES: Create Skill in .claude/skills/
  → Update CLAUDE.md with Skill reference

STEP 5: Commit and push to machine_agents repo
  cd C:\scripts
  git add -A
  git commit -m "docs: update learnings from [task description]"
  git push origin main
```

### CRITICAL RULES:

1. **DO NOT SKIP THIS** - It's how the system improves over time
2. **DO NOT DELAY** - Update immediately after completing the task
3. **DO NOT FORGET THE PUSH** - Changes must be committed to git
4. **ALWAYS INCLUDE DATE** - Use format: ## YYYY-MM-DD HH:MM - [Title]

### EXAMPLE REFLECTION ENTRY:

```markdown
## 2026-01-09 15:30 - Fixed Docker CI Pipeline

**Problem:** Invalid Docker tag format
**Root Cause:** Branch names with `/` break `prefix={{branch}}-`
**Fix:** Changed to `type=sha,prefix=sha-`
**Pattern Added:** Pattern 8 in claude_info.txt
```

### SUCCESS CRITERIA:

✅ reflection.log.md has new entry for this session
✅ claude_info.txt updated if new patterns discovered
✅ CLAUDE.md updated if new workflows added
✅ Changes committed and pushed to machine_agents repo
✅ Next session will benefit from these learnings

**This protocol ensures continuous improvement across sessions.**


## 📋 SESSION COMPACTION RECOVERY PATTERN

**Context:** After conversation compaction/summarization, the session continues but context is limited to summary.

### MANDATORY: Verify Actual State

When continuing from compacted session, ALWAYS verify actual repository state:

```powershell
# 1. Check current branch
cd C:\Projects\worker-agents\agent-XXX\<repo>
git branch --show-current

# 2. Check git status
git status

# 3. Check if PR exists for current branch
gh pr list --head <branch-name>

# 4. Check what files exist
ls -R <relevant-directories>
```

### Why This Matters

**Example from 2026-01-08 session:**
- Summary said: "Feature 10 backend complete, PR #57 created"
- Reality: Backend committed, branch pushed, PR exists, but **frontend missing**
- Action: Verified state, identified gap, completed frontend + documentation

**Without verification:**
- Would have assumed feature complete
- Would have missed frontend components
- PR would be incomplete

### Recovery Checklist

When session resumes after compaction:

1. ✅ Read worktrees.pool.md - Verify your agent allocation
2. ✅ Check git branch and status - Verify working state
3. ✅ Check gh pr list - Verify PR existence and state
4. ✅ List directory contents - Verify what files exist
5. ✅ Compare against summary - Identify gaps
6. ✅ Complete missing pieces - Don't assume summary is 100% accurate

### Verification Hierarchy (2026-01-09)

**Verify in priority order to catch critical issues first:**

**Tier 1 - CRITICAL (Can break everything):**
- ⚠️ **Base repo branches** (C:\Projects\<repo> MUST be on develop)
- ⚠️ **Worktree pool allocations** (check for conflicts/locks)
- ⚠️ **Uncommitted changes in worktrees** (risk of data loss)

**Tier 2 - Important (Affects current work):**
- PR states and CI status (may have advanced since summary)
- Documentation commit status
- Current branch in worktrees

**Tier 3 - Informational (Good to know):**
- Recent commits
- Open issues
- Test results

### Automated Verification Script

**Run this IMMEDIATELY after session resumes:**

```bash
#!/bin/bash
# Post-Compaction Verification Protocol

echo "=== TIER 1: CRITICAL CHECKS ==="

# Check base repos are on develop (HIGHEST PRIORITY)
echo "Checking base repo branches..."
for repo in client-manager hazina; do
  cd "/c/Projects/$repo"
  branch=$(git branch --show-current)
  if [[ "$branch" != "develop" ]]; then
    echo "❌ VIOLATION: $repo on '$branch' (should be 'develop')"
    echo "   Fix: cd /c/Projects/$repo && git checkout develop"
  else
    echo "✅ $repo on develop"
  fi
done

# Check for uncommitted changes in base repos
echo ""
echo "Checking for uncommitted changes..."
for repo in client-manager hazina; do
  cd "/c/Projects/$repo"
  if [[ -n $(git status --porcelain) ]]; then
    echo "⚠️ $repo has uncommitted changes:"
    git status --short
  else
    echo "✅ $repo clean"
  fi
done

echo ""
echo "=== TIER 2: WORK STATUS CHECKS ==="

# Check PR states
echo "Checking recent PR activity..."
cd "/c/Projects/client-manager"
gh pr list --state all --limit 5 --json number,title,state,mergeable | jq -r '.[] | "\(.number): \(.title) - \(.state) (\(.mergeable))"'

# Check documentation commits
echo ""
echo "Checking recent documentation updates..."
cd /c/scripts
git log --oneline -5

echo ""
echo "=== TIER 3: INFORMATIONAL ==="
echo "Worktree pool status:"
cat /c/scripts/_machine/worktrees.pool.md | grep -E "agent-00[0-9]|FREE|BUSY"

echo ""
echo "✅ Verification complete"
```

**Why This Matters:**
- Base repo on wrong branch = Future worktrees start from wrong code (cascading failure)
- Unknown PR merges = May duplicate work or miss integration points
- Uncommitted changes = Risk of data loss on checkout

**Time Investment:** 5 minutes of verification saves hours debugging wrong-branch worktrees.

### Pattern: Trust but Verify

```
Summary says:        → Verify:              → Reality:
"Backend complete"   → Check git log        → 2 commits, migration + service
"PR created"         → gh pr list           → PR #57 exists, OPEN → MERGED!
"Feature done"       → ls Frontend/src      → Frontend missing! ❌
"Repo on develop"    → git branch --show    → On payment-models! ❌❌
```

**Lesson:** Summaries compress information. Always verify file system state when continuing work.

**Real Example (2026-01-09):**
- Summary: "PR #66 and #61 MERGEABLE"
- Reality: Both PRs actually **MERGED** (better than expected)
- Also Found: Base repos on wrong branches (critical violation)
- Action: Restored repos to develop, prevented future worktree issues

---


## 📁 DOCUMENTATION HYGIENE PROTOCOL

**Implemented:** 2026-01-13
**Purpose:** Prevent content rot and maintain navigable documentation structure

### Root Directory Rules

**Maximum 15 .md files in C:\scripts\ root:**

**MUST KEEP (Core documentation):**
- ✅ `CLAUDE.md` - Main documentation index
- ✅ `ZERO_TOLERANCE_RULES.md` - Critical quick reference
- ✅ Modular docs (8 files):
  - `ci-cd-troubleshooting.md`
  - `continuous-improvement.md`
  - `development-patterns.md`
  - `git-workflow.md`
  - `session-management.md`
  - `tools-and-productivity.md`
  - `worktree-workflow.md`
  - `DYNAMIC_WINDOW_COLORS.md`

**MAY KEEP (User references):**
- ✅ `QUICK_LAUNCHERS.md` - User quick reference
- ✅ `QUICK_START_USER_COST_TRACKING.md` - User quick start guide
- ✅ `NOTIFICATION_ACCESS.md` - User notification guide

**MUST ARCHIVE (Everything else):**
- ❌ Planning documents → Move to `_machine/knowledge/`
- ❌ Implementation details → Move to `_machine/knowledge/`
- ❌ Old reference docs → Move to `_archive/`
- ❌ Outdated files → Move to `_archive/`

### Backup File Policy

**NEVER commit backup files to production:**
- ❌ `*.backup` files
- ❌ `*.backup-YYYYMMDD` files
- ❌ `*_old.*` files

**Rationale:** Git history is the backup. Backup files clutter the directory and cause confusion about which version is authoritative.

**If you need to preserve state before major changes:**
```bash
# Create a git branch instead of a backup file
git branch backup/pre-major-refactor-$(date +%Y%m%d)
git push origin backup/pre-major-refactor-$(date +%Y%m%d)
```

### Planning Document Lifecycle

**When creating planning/analysis documents:**

1. **During planning phase:** Work in root for easy access
2. **After implementation:** Move to `_machine/knowledge/<topic>/`
3. **If obsolete:** Move to `_archive/`

**Example:**
```bash
# During planning
C:\scripts\hazina-integration-roadmap.md

# After implementation complete
C:\scripts\_machine\knowledge\hazina-analysis\hazina-integration-roadmap.md

# If approach abandoned
C:\scripts\_archive\hazina-integration-roadmap-abandoned-2026-01.md
```

### Stale Script Detection

**Archive .bat/.cmd/.ps1 files unused for 60+ days:**

**Monthly audit checklist:**
```bash
# Find scripts older than 60 days with no recent modifications
find C:/scripts -maxdepth 1 -type f \( -name "*.bat" -o -name "*.cmd" -o -name "*.ps1" \) -mtime +60

# Review each:
# - Still used? Keep
# - One-time tool (like BFG)? Archive
# - Replaced by better tool? Archive
```

**Archive location:** `C:\scripts\_archive/old-launchers/`

### _machine Folder Maintenance

**Keep ONLY active/frequently accessed files in `_machine/` root:**

**MUST KEEP (Active):**
- ✅ `reflection.log.md` - Session learnings (CRITICAL)
- ✅ `worktrees.pool.md` - Agent allocations (CRITICAL)
- ✅ `worktrees.activity.md` - Activity log (CRITICAL)
- ✅ `worktrees.protocol.md` - Worktree protocol (CRITICAL)
- ✅ `pr-dependencies.md` - Cross-repo PR tracking
- ✅ `instances.map.md` - Instance tracking
- ✅ `MULTI_AGENT_CONFLICT_DETECTION.md` - Conflict prevention
- ✅ `KNOWLEDGE_BASE_SUMMARY.md` - Knowledge index

**MUST KEEP (Subfolders):**
- ✅ `knowledge/` - Reference documentation
- ✅ `best-practices/` - Pattern library
- ✅ `ADR/` - Architecture decision records
- ✅ `lessons/` - Categorized learnings

**MUST ARCHIVE (Stale reference docs):**
- ❌ Initial setup deep-dives → `_machine/archive/reference-YYYY-MM-<label>/`
- ❌ One-time analysis documents → `_machine/archive/reference-YYYY-MM-<label>/`
- ❌ Superseded strategy docs → `_machine/archive/reference-YYYY-MM-<label>/`

### Monthly Maintenance Checklist

**Run on 1st of each month:**

```bash
# 1. Check root directory file count
ls C:/scripts/*.md | wc -l
# Target: ≤15 files

# 2. Find duplicate filenames between root and _machine
find C:/scripts/_machine -name "*.md" -exec basename {} \; | sort > /tmp/machine_files.txt
find C:/scripts -maxdepth 1 -name "*.md" -exec basename {} \; | sort > /tmp/root_files.txt
comm -12 /tmp/machine_files.txt /tmp/root_files.txt
# Target: 0 duplicates (or only README.md)

# 3. Find backup files in production
find C:/scripts -name "*.backup*" -o -name "*_old.*"
# Target: 0 files

# 4. Find scripts unused for 60+ days
find C:/scripts -maxdepth 1 -type f \( -name "*.bat" -o -name "*.cmd" -o -name "*.ps1" \) -mtime +60
# Review and archive if unused

# 5. Check _machine folder size
du -sh C:/scripts/_machine/
# Target: <2MB (excluding reflection.log.md which grows continuously)

# 6. Review _machine root file count
ls C:/scripts/_machine/*.md | wc -l
# Target: ≤15 active files (excluding subdirectories)
```

### Archive Directory Structure

```
C:\scripts\_archive/
├── old-launchers/              # Stale .bat/.cmd/.ps1 files
│   ├── chatgpt_yolo.bat
│   ├── codex_yolo.cmd
│   └── bfg.jar
├── reference-YYYY-MM-<label>/  # Outdated root .md files
│   ├── README.md
│   ├── scripts.md
│   └── pr-settings-guide.md
└── ...

C:\scripts\_machine\archive/
├── reference-YYYY-MM-<label>/  # Stale reference docs
│   ├── ACCESSIBILITY_TESTING.md
│   ├── BRANCHING_STRATEGY.md
│   ├── CLIENT_MANAGER_DEEP_DIVE.md
│   └── ...
└── ...
```

### Enforcement

**At end of every session:**
1. ✅ Check if you created any planning documents in root
2. ✅ If task complete: Move planning docs to `_machine/knowledge/`
3. ✅ Check for any `.backup` files created
4. ✅ Delete backup files (they're in git history)
5. ✅ Verify root directory still ≤15 .md files

**Monthly audit triggers:**
- First session of each month
- After major reorganization
- When root directory feels cluttered (>20 files)

### Success Criteria

**Documentation is healthy ONLY IF:**
- ✅ Root directory has ≤15 .md files
- ✅ No duplicate filenames between root and _machine
- ✅ No .backup files in production
- ✅ Stale scripts archived after 60 days
- ✅ _machine root has ≤15 active .md files
- ✅ Planning docs moved to knowledge/ after implementation
- ✅ Archive directories organized by date and topic

**This protocol prevents content rot and maintains a navigable documentation structure.**

---
