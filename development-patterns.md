# Development Patterns Library

## ðŸ”§ NAMESPACE MIGRATION PATTERNS

**When Hazina namespaces change, client-manager needs updates:**

### Common Namespace Issues

| Old Usage | New Usage | Fix |
|-----------|-----------|-----|
| `new OpenAIConfig(...)` | Needs `using Hazina.LLMs.OpenAI;` | Add using statement |
| `new OllamaConfig(endpoint: ...)` | Constructor changed | Use object initializer |
| `interface.MethodName()` | Method doesn't exist | Add extension method or fix call |

### Extension Method Pattern

When Hazina interface lacks a method client-manager needs:

```csharp
// Create in ClientManagerAPI/Extensions/
public static class InterfaceExtensions
{
    public static async Task<T> MissingMethodAsync<T>(
        this IInterface client,
        string param)
    {
        // Implement using existing interface methods
        return await client.ExistingMethod(...);
    }
}
```

### Build Error Triage

1. **CS0246 (type not found)** â†’ Missing using statement or namespace changed
2. **CS1061 (method not found)** â†’ Interface changed, add extension or fix call
3. **CS0101 (duplicate type)** â†’ Same class in multiple files, remove one
4. **CS1501 (wrong arguments)** â†’ Method signature changed, update call

## ðŸ—ï¸ INCOMPLETE FEATURE CODE PATTERNS

**When encountering build errors from incomplete feature code:**

### Pattern 1: Method Calls Non-Existent Interface Methods

```csharp
// Code calls:
var result = await service.GetAnalysisFieldsAsync(projectId);

// But interface only has:
Task<IReadOnlyList<FieldInfo>> GetFieldsAsync(string projectId);
```

**Fix Options:**
1. Simplify method to return null/default (defer implementation)
2. Create the missing interface method
3. Refactor to use existing methods

### Pattern 2: Property Access on Wrong Type

```csharp
// Code expects:
result.BrandDocument.Fragments

// But actual type is:
IReadOnlyList<FieldInfo>  // No BrandDocument property
```

**Fix:** Simplify to skip that code path until properly implemented

### Pattern 3: Convenience Property Wrappers

Add wrapper properties to avoid deep changes:

```csharp
public class Result
{
    public Score Score { get; set; }

    // Convenience - forward to nested object
    public double OverallScore => Score?.OverallScore ?? 0;
}
```

---

## ðŸ”§ RUNTIME ERROR PATTERNS & FIXES

### Swashbuckle 8.x [FromForm] + IFormFile Error

**Error:** `SwaggerGeneratorException: Error reading parameter(s) for action ... as [FromForm] attribute used with IFormFile`

**Root Cause:** Swashbuckle 8.x throws errors when `[FromForm]` is combined with `IFormFile`. Error occurs during parameter generation BEFORE operation filters run.

**CRITICAL:** Search for ALL occurrences before fixing - errors appear sequentially!

**Fix:** Remove `[FromForm]` from `IFormFile` parameters only:
```csharp
// BEFORE (error):
public async Task<IActionResult> Upload([FromForm] IFormFile file, [FromForm] string projectId)

// AFTER (works):
public async Task<IActionResult> Upload(IFormFile file, [FromForm] string projectId)
```

**Search command:**
```bash
grep -rn "\[FromForm\].*IFormFile" C:\Projects\client-manager\ClientManagerAPI
```

---

### Missing npm Packages (Vite Import Error)

**Error:** `Failed to resolve import "package-name" from "src/..."`

**Fix:** Install the missing package:
```bash
cd /c/Projects/client-manager/ClientManagerFrontend && npm install <package-name>
```

---

### Missing TypeScript Modules

**Error:** `Failed to resolve import "../../lib/api" from "src/..."`

**Diagnosis:** Check if module exists, or if existing service can be used.

**Fix Options:**
1. Create the missing module
2. Update import to use existing service (e.g., `axiosConfig.ts`)

---

### SQLite Missing Columns (Migration Not Applied)

**Error:** `SQLite Error 1: 'no such column: u.ColumnName'`

**Root Cause:** EF Core migration exists but wasn't applied.

**Quick Fix via Python:**
```bash
python3 -c "import sqlite3; conn = sqlite3.connect('c:/stores/brand2boost/identity.db'); conn.execute('ALTER TABLE TableName ADD COLUMN ColumnName TYPE DEFAULT value'); conn.commit()"
```

**List tables:**
```bash
python3 -c "import sqlite3; conn = sqlite3.connect('c:/stores/brand2boost/identity.db'); print([r[0] for r in conn.execute(\"SELECT name FROM sqlite_master WHERE type='table'\")])"
```

**Check columns:**
```bash
python3 -c "import sqlite3; conn = sqlite3.connect('c:/stores/brand2boost/identity.db'); [print(r[1], r[2]) for r in conn.execute('PRAGMA table_info(TableName)')]"
```

**Note:** Table names may be singular (`UserTokenBalance`) not plural (`UserTokenBalances`).

---

## ðŸš¨ðŸš¨ðŸš¨ MANDATORY: END-OF-TASK SELF-UPDATE PROTOCOL ðŸš¨ðŸš¨ðŸš¨

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

STEP 4: Commit and push to machine_agents repo
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

âœ… reflection.log.md has new entry for this session
âœ… claude_info.txt updated if new patterns discovered
âœ… CLAUDE.md updated if new workflows added
âœ… Changes committed and pushed to machine_agents repo
âœ… Next session will benefit from these learnings

**This protocol ensures continuous improvement across sessions.**

## ðŸ“‹ SESSION COMPACTION RECOVERY PATTERN

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

1. âœ… Read worktrees.pool.md - Verify your agent allocation
2. âœ… Check git branch and status - Verify working state
3. âœ… Check gh pr list - Verify PR existence and state
4. âœ… List directory contents - Verify what files exist
5. âœ… Compare against summary - Identify gaps
6. âœ… Complete missing pieces - Don't assume summary is 100% accurate

### Verification Hierarchy (2026-01-09)

**Verify in priority order to catch critical issues first:**

**Tier 1 - CRITICAL (Can break everything):**
- âš ï¸ **Base repo branches** (C:\Projects\<repo> MUST be on develop)
- âš ï¸ **Worktree pool allocations** (check for conflicts/locks)
- âš ï¸ **Uncommitted changes in worktrees** (risk of data loss)

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
    echo "âŒ VIOLATION: $repo on '$branch' (should be 'develop')"
    echo "   Fix: cd /c/Projects/$repo && git checkout develop"
  else
    echo "âœ… $repo on develop"
  fi
done

# Check for uncommitted changes in base repos
echo ""
echo "Checking for uncommitted changes..."
for repo in client-manager hazina; do
  cd "/c/Projects/$repo"
  if [[ -n $(git status --porcelain) ]]; then
    echo "âš ï¸ $repo has uncommitted changes:"
    git status --short
  else
    echo "âœ… $repo clean"
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
echo "âœ… Verification complete"
```

**Why This Matters:**
- Base repo on wrong branch = Future worktrees start from wrong code (cascading failure)
- Unknown PR merges = May duplicate work or miss integration points
- Uncommitted changes = Risk of data loss on checkout

**Time Investment:** 5 minutes of verification saves hours debugging wrong-branch worktrees.

### Pattern: Trust but Verify

```
Summary says:        â†’ Verify:              â†’ Reality:
"Backend complete"   â†’ Check git log        â†’ 2 commits, migration + service
"PR created"         â†’ gh pr list           â†’ PR #57 exists, OPEN â†’ MERGED!
"Feature done"       â†’ ls Frontend/src      â†’ Frontend missing! âŒ
"Repo on develop"    â†’ git branch --show    â†’ On payment-models! âŒâŒ
```

**Lesson:** Summaries compress information. Always verify file system state when continuing work.

**Real Example (2026-01-09):**
- Summary: "PR #66 and #61 MERGEABLE"
- Reality: Both PRs actually **MERGED** (better than expected)
- Also Found: Base repos on wrong branches (critical violation)
- Action: Restored repos to develop, prevented future worktree issues

---

## ðŸŽ¯ COMPLETE FEATURE IMPLEMENTATION PATTERN

**For any substantial feature, all three components are MANDATORY:**

### 1. Backend (API/Services)
- âœ… Models/DTOs (data structures)
- âœ… Services (business logic)
- âœ… Controllers (API endpoints)
- âœ… Migrations (database schema)
- âœ… DI registration (Program.cs)
- âœ… Tests (if applicable)

### 2. Frontend (UI/Components)
- âœ… TypeScript service layer (API client)
- âœ… React components (2 versions):
  - **Full component**: Complete feature view (e.g., `ROIDashboard.tsx`)
  - **Widget component**: Compact at-a-glance display (e.g., `ROIWidget.tsx`)
- âœ… Proper TypeScript types/interfaces
- âœ… Error handling and loading states
- âœ… Responsive design (Tailwind CSS)

### 3. Documentation (Knowledge Transfer)
- âœ… Comprehensive .md file in `docs/features/`
- âœ… Overview and key features
- âœ… API specifications with examples
- âœ… Frontend usage examples
- âœ… Database schema descriptions
- âœ… Best practices and integration points
- âœ… Customization guidance

### Why Two Component Versions?

**Full Component** (e.g., ROIDashboard.tsx):
- Complete feature experience
- All functionality available
- Dedicated page/view
- Example: 227 lines with trend charts, filters, insights

**Widget Component** (e.g., ROIWidget.tsx):
- At-a-glance summary
- Compact display
- Dashboard integration
- Example: 92 lines showing key metrics only

**Benefits:**
- Flexibility: Use widget on main dashboard, full view on dedicated page
- Reusability: Widget can be embedded anywhere
- User choice: Quick glance vs deep dive

### Documentation Template

Use ROI-CALCULATOR.md as template (771 lines):

```markdown
# Feature Name - Documentation

## Overview
[What it does, why it matters]

## Key Features
[Bulleted list of capabilities]

## [Industry Benchmarks / Data Sources]
[If applicable - show research basis]

## API Endpoints
### 1. Endpoint Name
[Request/Response examples]

## Frontend Usage
### Full Component
[TSX code example]

### Widget Component
[TSX code example]

## Database Schema
[Table descriptions]

## Best Practices
[Integration guidance]

## Customization
[How to adapt for specific needs]

## Support
[Troubleshooting tips]
```

### Git Workflow for Features

```bash
# 1. Create feature branch
git worktree add C:\Projects\worker-agents\agent-XXX\<repo> -b feature/<name>

# 2. Implement backend first
[Create models, services, controllers, migrations]
git add . && git commit -m "feat: Add backend for <feature>"

# 3. Register services
[Update Program.cs DI registration]
git add . && git commit -m "feat: Register <feature> services"

# 4. Implement frontend
[Create service + 2 components]
git add . && git commit -m "feat: Add frontend for <feature>"

# 5. Add documentation
[Create comprehensive .md file]
git add . && git commit -m "docs: Add comprehensive <feature> documentation"

# 6. Push and create PR
git push -u origin feature/<name>
gh pr create --title "Feature: <Name>" --body "..."
```

**NEVER mark feature complete until all three parts exist.**

---

## ðŸ“Š MULTI-FEATURE IMPLEMENTATION DISCIPLINE

**When implementing multiple related features (e.g., Quick Wins 1-10):**

### Use TodoWrite Religiously

At start of multi-feature session, create todos for all features. Break down each feature into backend, frontend, docs components. Mark completed IMMEDIATELY after finishing each part.

### Why This Matters

**Benefits:**
1. **Progress visibility**: User sees exactly where you are
2. **No lost tasks**: Can't forget a component
3. **Context preservation**: After compaction, todo list shows state
4. **Self-accountability**: Forces you to complete ALL parts

**Correct pattern (DO THIS):**
- Mark "Backend" as in_progress
- Complete backend, mark completed
- Mark "Frontend" as in_progress
- Complete frontend, mark completed
- Mark "Documentation" as in_progress
- Complete docs, mark completed
- Mark "PR creation" as in_progress
- Create PR, mark feature fully completed
- Move to next feature

### Batch Completion Anti-Pattern

**WRONG:** Complete all features' backend, then all frontend, then all docs
**RIGHT:** Feature by feature - Backend â†’ Frontend â†’ Docs â†’ PR for each

### Session Handoff Pattern

If session ends mid-feature, leave clear state in todos showing what's completed and what's pending. Next session can immediately see where to resume.

---

## ðŸ­ INDUSTRY RESEARCH INTEGRATION PATTERN

**When features involve industry benchmarks, best practices, or research data:**

### Include in Service Layer

Example from Smart Scheduling:
```csharp
private static readonly Dictionary<string, (int dayOfWeek, int hour, double score, string reason)> BestPractices = new()
{
    ["linkedin"] = (3, 9, 0.95, "Wednesday 9 AM - B2B professionals most active"),
    ["instagram"] = (3, 11, 0.92, "Wednesday 11 AM - High visual content engagement")
};
```

Example from ROI Calculator:
```csharp
private static readonly Dictionary<string, decimal> IndustryMultipliers = new()
{
    ["B2B Software"] = 3.0m,  // High-value leads, enterprise sales cycles
    ["Finance"] = 2.5m,       // Regulated industry, trust-driven
};
```

### Document Research Sources

In documentation file, include tables with benchmark values and research basis.

### Benefits

1. **Credibility**: Data-driven decisions, not arbitrary values
2. **Transparency**: Users understand the "why" behind calculations
3. **Customizability**: Users can adjust based on their data
4. **Future-proofing**: Easy to update as industry changes

---

## ðŸ—ï¸ MULTI-TENANT ARCHITECTURE PATTERN

**For SaaS applications with multiple clients:**

### Data Hierarchy

Organization/Client (1) â†’ Projects (*) â†’ Content/Posts (*)

### Models

```csharp
// Top-level tenant
public class Client
{
    public string Id { get; set; }
    public string Name { get; set; }
    public string? Industry { get; set; }  // For industry-specific calculations

    public ICollection<Project> Projects { get; set; }
    public ICollection<UserClient> UserClients { get; set; }
}

// Junction table for user-client access
public class UserClient
{
    public string UserId { get; set; }
    public string ClientId { get; set; }
    public string Role { get; set; }  // Owner, Manager, Editor, Viewer
}

// Project level
public class Project
{
    public string Id { get; set; }
    public string ClientId { get; set; }  // â† Tenant isolation
}
```

### Query Filtering

ALWAYS filter by ClientId or ProjectId. Verify user has access before returning data.

### API Parameters

Support both project-level and client-level aggregation through optional parameters.

### Benefits

- **Data isolation**: Each client sees only their data
- **Flexible aggregation**: Report at project or client level
- **Role-based access**: Different permissions per client
- **Industry customization**: Use client.Industry for tailored calculations

---

## ðŸ“ AUDIT LOGGING FOR ENTERPRISE PATTERN

**For enterprise features requiring compliance/audit trails:**

### Model Pattern

```csharp
public class ApprovalAction
{
    public int Id { get; set; }
    public string Action { get; set; }  // Approved, Rejected
    public string ActionBy { get; set; }
    public DateTime ActionTimestamp { get; set; }

    // Audit fields
    public string? IPAddress { get; set; }        // â† Compliance
    public string? UserAgent { get; set; }        // â† Forensics
    public string? Reason { get; set; }           // â† Business context
}
```

### Controller Pattern

Capture audit data from HttpContext (IP address, UserAgent) and pass to service layer.

### Benefits

- **Compliance**: SOC2, GDPR, HIPAA audit requirements
- **Forensics**: Investigate suspicious activity
- **Business intelligence**: Understand approval patterns
- **Legal protection**: Documented decision trail

### What to Audit

âœ… Approvals/rejections, permission changes, data access (sensitive), configuration changes, bulk operations
âŒ Read-only views, normal CRUD, high-frequency actions

---

## ðŸ”„ CONTINUOUS IMPROVEMENT: PATTERN LIBRARY

**Every successful pattern should be documented for reuse.**

### After Completing Work

1. âœ… Identify reusable patterns
2. âœ… Document in claude.md (this file)
3. âœ… Add to reflection.log.md as achievement
4. âœ… Update claude_info.txt with quick reference
5. âœ… Commit documentation updates

### Pattern Categories

This file now includes:
- âœ… Session Compaction Recovery
- âœ… Complete Feature Implementation
- âœ… Multi-Feature Discipline
- âœ… Industry Research Integration
- âœ… Multi-Tenant Architecture
- âœ… Audit Logging for Enterprise

**Add more as discovered!**

---

## ðŸ“ INCOMPLETE WORK DOCUMENTATION PATTERN (2026-01-08)

**Learned from:** Hazina PR #13 - Chat LLM Configuration Fix
**Pattern file:** C:\scripts\_machine\best-practices\DOCUMENTATION_AND_PR_WORKFLOW.md
**Status:** ACTIVE PATTERN for all complex incomplete work

### When to Use This Pattern

âœ… **Use when:**
- Work session running long (token limits, time constraints)
- Fix spans multiple files (>5 locations)
- Testing reveals fix is incomplete
- Linter or external factors interfere
- Need to preserve context before losing it

âŒ **Do NOT use for:**
- Simple single-file fixes
- Quick bugs fixable in <30 minutes
- Fully tested and working changes
- Minor refactoring

### The Workflow

#### 1. Create Documentation FIRST (before PR)

**Create two files:**

**A. PROBLEM_FIX_SUMMARY.md** - Complete technical specification
```markdown
# Problem Fix - Summary
**Date**: 2026-01-08
**Time**: HH:MM:SS UTC
**Signed by**: Claude Opus 4.5 (model-id)

## Problem
[Clear description]

## Root Cause
[Technical analysis]

## Solution Overview
[High-level approach]

## Changes Made
- âœ… Completed item
- âŒ Incomplete item

## Implementation Details
[Every file, every line number, exact code snippets]

## Testing Checklist
[Verification commands]
```

**B. REMAINING_WORK.md** - Action-oriented task list
```markdown
# Remaining Work: Feature Name
**Date**: 2026-01-08
**Time**: HH:MM:SS UTC
**Signed by**: Claude Opus 4.5
**PR**: [PR URL]
**Branch**: [branch-name]

## Status Overview
### âœ… Completed
### âŒ Incomplete

## Required Changes
### 1. Component (PRIORITY)
**File**: path
**Line**: X
[Exact code change needed]
**Impact**: [What breaks]

## Verification Commands
[Bash commands to verify]

## Testing Checklist
[Step-by-step testing]

## Rollback Plan
[How to undo]

## Next Steps
[Action items with time estimates]
```

#### 2. Commit Documentation

```bash
git add SUMMARY.md REMAINING_WORK.md
git commit -m "Add comprehensive documentation

Date: 2026-01-08THH:MM:SSZ
Signed-off-by: Claude Opus 4.5 <noreply@anthropic.com>"
git push
```

#### 3. Create PR with Comprehensive Body

```bash
gh pr create --title "[Type]: Clear description" --body "$(cat <<'EOFPR'
## Problem
[Brief]

## Root Cause
[Brief technical]

## Changes Made (Partial Fix)
1. âœ… Change 1
2. âœ… Change 2

## Remaining Work âš ï¸
**See REMAINING_WORK.md for details**
- [ ] Component 1
- [ ] Component 2

## Testing Status
- âœ… Builds
- âŒ Feature still fails
- â³ Needs completion

## Files Changed
[List]

---
**Signed**: 2026-01-08THH:MM:SSZ
**Docs**: SUMMARY.md, REMAINING_WORK.md
EOFPR
)"
```

### DateTime Signature Standards

**Always include in:**
- MD file headers
- Git commit messages
- PR descriptions
- Todo updates

**Format:** ISO 8601 `2026-01-08T21:15:00Z`

**In files:**
```markdown
**Date**: 2026-01-08
**Time**: 21:15:00 UTC
**Signed by**: Claude Opus 4.5 (claude-sonnet-4-5-20250929)
```

**In commits:**
```
Date: 2026-01-08T21:15:00Z
Signed-off-by: Claude Opus 4.5 <noreply@anthropic.com>
```

### Status Markers (Use Consistently)

- âœ… Completed
- âŒ Incomplete/Failing
- â³ Pending/In Progress
- âš ï¸ Warning/Attention Needed
- ðŸ“ Documentation
- ðŸ”§ Configuration
- ðŸ› Bug Fix
- âœ¨ New Feature

### Priority Levels

- **HIGH**: Blocks core functionality
- **MEDIUM**: Affects secondary features
- **LOW**: Nice to have, no user impact

### Verification Pattern

Always include bash commands:
```bash
# Build verification
cd /path/to/project
dotnet build
# Expected: 0 errors

# Completeness check
grep -rn "OldPattern" src/ --include="*.cs"
# Expected: 0 results

# Runtime test
curl -X POST https://localhost:5001/api/test
# Expected: 200 OK
```

### Benefits

âœ… **Continuity**: Anyone can continue work
âœ… **Clarity**: Exact status known
âœ… **Searchability**: Easy to find
âœ… **Accountability**: Datetime tracking
âœ… **Quality**: Prevents mistakes
âœ… **Efficiency**: No wasted time
âœ… **Communication**: Clear for reviewers

### Common Pitfalls to Avoid

âŒ **Do NOT:**
- Create PR with vague "WIP" title
- Commit without documentation
- List todos in PR comments (use MD files)
- Forget datetime signatures
- Skip verification commands
- Assume context is obvious

âœ… **DO:**
- Be exhaustively specific
- Include every file and line number
- Write for zero-context reader
- Sign and date everything
- Make docs self-contained
- Test your own documentation

### Integration with Control Plane

**File locations:**
- Project repo: `PROJECT_ROOT/FEATURE_SUMMARY.md`
- Project repo: `PROJECT_ROOT/REMAINING_WORK.md`
- Control plane: `C:\scripts\_machine\best-practices\PATTERN.md`
- Reflection: `C:\scripts\_machine\reflection.log.md`

### Real-World Example

**See:**
- PR: https://github.com/martiendejong/Hazina/pull/13
- Summary: C:\Projects\hazina\CHAT_FIX_SUMMARY.md
- Remaining: C:\Projects\hazina\REMAINING_WORK.md
- Pattern: C:\scripts\_machine\best-practices\DOCUMENTATION_AND_PR_WORKFLOW.md

### Pattern Library Updated

This file now includes:
- âœ… Session Compaction Recovery
- âœ… Complete Feature Implementation
- âœ… Multi-Feature Discipline
- âœ… Industry Research Integration
- âœ… Multi-Tenant Architecture
- âœ… Audit Logging for Enterprise
- âœ… **Incomplete Work Documentation** â† NEW (2026-01-08)

**Full template:** C:\scripts\_machine\best-practices\DOCUMENTATION_AND_PR_WORKFLOW.md


---


## ðŸ”„ COMPREHENSIVE TERMINOLOGY MIGRATION PATTERN (2026-01-12)

**Source:** client-manager token refactor session (daily â†’ monthly)
**Files affected:** 95 files across backend + frontend
**Status:** ACTIVE PATTERN for large-scale naming refactors

### When to Use This Pattern

âœ… **Use when:**
- Discover misleading field/property/method names throughout codebase
- Database models use one terminology, API/UI uses another
- User confusion about what data actually represents
- Technical debt from naming inconsistencies
- Need to refactor 10+ files with consistent pattern

âŒ **Don't use for:**
- Single file renames (use standard Edit tool)
- Breaking API changes without version strategy
- Unclear what the "correct" terminology should be

### The Problem Pattern

**Example from client-manager:**
```
Database:     MonthlyAllowance, MonthlyUsage, NextResetDate  âœ… Correct
API Response: dailyAllowance, dailyUsed, dailyRemaining     âŒ Misleading!
UI Labels:    "Daily Allowance", "Tokens Used Today"        âŒ Wrong!
User sees:    "You have 500 tokens daily"                    âŒ Actually monthly!
```

**Impact:**
- User confusion and loss of trust
- Developers use wrong terminology in new code
- Documentation becomes inconsistent
- Future refactors become harder

### Implementation Workflow

#### **Phase 1: Comprehensive Audit**

```bash
# Find ALL occurrences (backend)
Grep pattern="dailyAllowance|dailyUsed|DailyAllowance|daily[A-Z]"
     path="C:\Projects\<repo>\Backend"
     output_mode="files_with_matches"

# Find ALL occurrences (frontend)
Grep pattern="dailyAllowance|dailyUsed|'Daily Allowance'"
     path="C:\Projects\<repo>\Frontend\src"
     output_mode="files_with_matches"
```

**Create TodoWrite checklist:**
```
1. [ ] Audit backend occurrences
2. [ ] Audit frontend occurrences
3. [ ] Fix backend models/interfaces
4. [ ] Fix backend services/controllers
5. [ ] Fix frontend types/interfaces
6. [ ] Fix frontend components
7. [ ] Build and verify
```

#### **Phase 2: Backend Migration (Bottom-Up)**

**Order matters - fix from data layer to API layer:**

```
1. Models/DTOs (data structures)
   â†“
2. Service interfaces (contracts)
   â†“
3. Service implementations (logic)
   â†“
4. Controllers (API endpoints)
   â†“
5. Request/Response classes
```

**Example:**
```csharp
// 1. Update model
public class TokenStatistics {
    public int MonthlyAllowance { get; set; }      // was DailyAllowance
    public int TokensUsedThisMonth { get; set; }   // was TokensUsedToday
}

// 2. Update interface
public interface ITokenService {
    Task SetMonthlyAllowanceAsync(string userId, int monthlyAllowance);
    // Mark old method obsolete
    [Obsolete("Use SetMonthlyAllowanceAsync")]
    Task SetDailyAllowanceAsync(string userId, int dailyAllowance);
}

// 3. Update implementation
public async Task SetMonthlyAllowanceAsync(string userId, int monthlyAllowance) {
    var balance = await GetBalance(userId);
    balance.MonthlyAllowance = monthlyAllowance;
    await SaveChanges();
}

// 4. Update controller
[HttpPost("admin/set-allowance")]
public async Task<IActionResult> AdminSetMonthlyAllowance(
    [FromBody] SetMonthlyAllowanceRequest request) {
    await _service.SetMonthlyAllowanceAsync(request.UserId, request.MonthlyAllowance);
    return Ok(new {
        monthlyAllowance = request.MonthlyAllowance  // API response field
    });
}
```

**Build after Phase 2:**
```bash
dotnet build Solution.sln --no-restore
# Must pass before proceeding to frontend
```

#### **Phase 3: Frontend Migration (Interfaces First)**

**Order:**
```
1. Service interfaces (TypeScript types)
   â†“
2. API client code (property access)
   â†“
3. Components (UI logic)
   â†“
4. Text labels (user-facing strings)
```

**Example:**
```typescript
// 1. Update interface
export interface TokenBalance {
  monthlyAllowance: number;       // was dailyAllowance
  monthlyUsed: number;            // was dailyUsed
  monthlyRemaining: number;       // was dailyRemaining
}

// 2. Property access - USE sed FOR BATCH UPDATES
// sed -i 's/\.dailyAllowance/.monthlyAllowance/g' src/**/*.{ts,tsx}

// 3. Component logic
const { monthlyAllowance, monthlyUsed } = balanceData;

// 4. Text labels
<span>Monthly Allowance</span>   {/* was "Daily Allowance" */}
```

**Build after Phase 3:**
```bash
npm run build
# Must complete successfully
```

#### **Phase 4: Verification & Cleanup**

```bash
# 1. Search for any remaining old terminology
grep -r "dailyAllowance" src/ --include="*.{ts,tsx,cs}"
# Should return 0 results (or only in comments/docs)

# 2. Test API responses
curl http://localhost:5000/api/token/balance
# Verify response uses new field names

# 3. Remove temp files before commit
git reset HEAD tmpclaude-*

# 4. Commit with comprehensive message
git commit -m "refactor: Complete migration from daily to monthly terminology

Backend: 12 files updated (models, services, controllers)
Frontend: 83 files updated (types, components, labels)
Builds: âœ“ Backend 0 errors, âœ“ Frontend success
..."
```

### Tool Selection Guide

**When to use Edit tool:**
- Single file or 2-3 files
- Complex logic changes
- Need to see surrounding context
- Different changes per file

**When to use sed (batch):**
- Same pattern across 10+ files
- Simple find/replace (property names, field names)
- Linter interference with Edit tool
- All changes are identical

**sed examples:**
```bash
# Basic replacement
sed -i 's/oldName/newName/g' file.cs

# Property access pattern
sed -i 's/\.dailyAllowance/.monthlyAllowance/g' *.tsx

# Multiple files
find . -name "*.cs" -exec sed -i 's/old/new/g' {} \;

# Frontend batch (all TS/TSX)
cd src && find . -type f \( -name "*.ts" -o -name "*.tsx" \) \
  -exec sed -i 's/\.dailyUsed/.monthlyUsed/g' {} \;
```

### Legacy Code Handling

**Don't delete old methods immediately - use deprecation:**

```csharp
public interface ITokenService {
    // NEW method (preferred)
    Task SetMonthlyAllowanceAsync(string userId, int monthlyAllowance);

    // OLD method (deprecated but not deleted)
    [Obsolete("Use SetMonthlyAllowanceAsync for proper monthly token allocation")]
    Task SetDailyAllowanceAsync(string userId, int dailyAllowance);
}
```

**Benefits:**
- âœ… Existing code continues to work
- âœ… Compiler warnings guide developers to new method
- âœ… Clear migration path documented in attribute
- âœ… Can remove in next major version

**Implementation (keep both working):**
```csharp
public async Task SetMonthlyAllowanceAsync(string userId, int monthlyAllowance) {
    // New implementation
}

[Obsolete("Use SetMonthlyAllowanceAsync")]
public async Task SetDailyAllowanceAsync(string userId, int dailyAllowance) {
    // Redirect to new method
    await SetMonthlyAllowanceAsync(userId, dailyAllowance);
}
```

### Common Pitfalls to Avoid

âŒ **DON'T:**
- Start frontend before backend is working
- Mix terminology (some files old, some new)
- Forget to update text labels/UI strings
- Skip verification builds
- Commit without testing
- Delete old methods without [Obsolete] first

âœ… **DO:**
- Audit comprehensively before starting
- Fix backend completely, then frontend
- Use TodoWrite to track 5+ file changes
- Build after each phase
- Test API responses manually
- Update all layers (data â†’ API â†’ UI)

### Real-World Example Stats

**client-manager token refactor (2026-01-12):**
- Files changed: 95 (12 backend, 83 frontend)
- Patterns replaced: 8 (dailyAllowance, dailyUsed, tokensUsedToday, etc.)
- Commits: 2 (initial fix 4 files, comprehensive 95 files)
- Build result: âœ… Backend 0 errors, âœ… Frontend success
- Time investment: ~45 minutes (including documentation)
- Impact: Eliminated all user confusion about daily vs monthly

### Success Criteria

**A terminology migration is successful ONLY IF:**
- âœ… ALL files using old terminology are updated
- âœ… Backend builds with 0 new errors
- âœ… Frontend builds with 0 new errors
- âœ… API responses use new field names
- âœ… UI labels show new terminology
- âœ… No mix of old/new terminology
- âœ… Legacy methods deprecated gracefully
- âœ… Documentation updated

### Integration with Other Patterns

**Combines well with:**
- âœ… Linter Interference Mitigation (sed for batch updates)
- âœ… Multi-Feature Implementation Discipline (TodoWrite tracking)
- âœ… Incomplete Work Documentation (if migration spans multiple sessions)

**File references:**
- Full reflection: `C:\scripts\_machine\reflection.log.md Â§ 2026-01-12`
- Linter mitigation: `C:\scripts\_machine\best-practices\LINTER_INTERFERENCE_MITIGATION.md`


---

## ðŸ” PATTERN 57: OCR LIBRARY INTEGRATION FOR DOCUMENT PROCESSING

**Context:** When implementing text extraction from image files without external API dependency
**Added:** 2026-01-12 (Image OCR implementation session)
**Status:** Production-tested, used in client-manager document extraction

### Problem

Extracting text from image files (PNG, JPG, JPEG, GIF, BMP, WEBP) without:
- External API dependency (cost, latency, authentication)
- Complex setup or deployment requirements
- Requirement for specific cloud services

### Solution: Tesseract OCR Integration

**Library:** Tesseract 5.2.0 (latest stable on NuGet)

**Installation:**
```xml
<!-- ClientManagerAPI.local.csproj -->
<PackageReference Include="Tesseract" Version="5.2.0" />
```

**Using Statements:**
```csharp
using Tesseract;
using System.Drawing;
```

### Implementation Pattern

**Basic usage with proper resource management:**

```csharp
private async Task<string> ExtractTextFromImageAsync(string filePath)
{
    return await Task.Run(() =>
    {
        try
        {
            // Proper resource management with using statements
            using var bitmap = new Bitmap(filePath);
            using var engine = new TesseractEngine(null, "eng", EngineMode.Default)
            {
                DefaultPageSegMode = PageSegMode.Auto
            };

            using var page = engine.Process(bitmap);
            var text = page.GetText();

            if (string.IsNullOrWhiteSpace(text))
            {
                _logger.LogWarning("OCR returned no text from: {FilePath}", filePath);
                return string.Empty;
            }

            return text;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "OCR extraction failed for: {FilePath}", filePath);
            return string.Empty;
        }
    }, ct);
}
```

### Key Design Decisions

**1. Resource Management**
- Always use `using` for `Bitmap` and `TesseractEngine`
- Prevents memory leaks in long-running services
- Ensures proper cleanup even on exceptions

**2. Error Handling**
- Wrap in try-catch to prevent crashes
- Log errors with file path for debugging
- Return safe default (empty string) on failure
- Don't throw - gracefully degrade

**3. Async Pattern**
- Wrap in `Task.Run()` to avoid blocking thread
- Tesseract is CPU-intensive
- Keep responsive for other requests

**4. Engine Configuration**
```csharp
new TesseractEngine(null, "eng", EngineMode.Default)
```
- `null` = use system tessdata
- `"eng"` = English language
- `EngineMode.Default` = standard mode (fastest)
- `PageSegMode.Auto` = auto-detect layout

### Real-World Implementation: Document Header/Footer Extraction

**Example from client-manager PR #123:**

```csharp
private async Task<CompanyDocumentExtraction> ExtractFromImageAsync(
    string filePath, CancellationToken ct)
{
    return await Task.Run(() =>
    {
        var extraction = new CompanyDocumentExtraction
        {
            Id = Guid.NewGuid().ToString()
        };

        try
        {
            using var bitmap = new Bitmap(filePath);
            using var engine = new TesseractEngine(null, "eng", EngineMode.Default)
            {
                DefaultPageSegMode = PageSegMode.Auto
            };

            using var page = engine.Process(bitmap);
            var fullText = page.GetText();

            if (string.IsNullOrWhiteSpace(fullText))
            {
                _logger.LogWarning("Image OCR returned no text from file: {FilePath}", filePath);
                extraction.ConfidenceScore = 0.1;
                return extraction;
            }

            // Split into lines for region estimation
            var lines = fullText.Split('\n', StringSplitOptions.RemoveEmptyEntries).ToList();

            if (lines.Count < 2)
            {
                extraction.ConfidenceScore = 0.1;
                return extraction;
            }

            // Estimate header: top ~15% of lines
            var headerLineCount = Math.Max(1, lines.Count / 7);
            var headerLines = lines.Take(headerLineCount).ToList();
            extraction.HeaderText = string.Join("\n", headerLines).Trim();
            extraction.HeaderHtml = ConvertToHtml(extraction.HeaderText);

            // Estimate footer: bottom ~15% of lines
            var footerLineCount = Math.Max(1, lines.Count / 7);
            var footerLines = lines.Skip(lines.Count - footerLineCount).ToList();
            extraction.FooterText = string.Join("\n", footerLines).Trim();
            extraction.FooterHtml = ConvertToHtml(extraction.FooterText);

            // Extract metadata and calculate confidence
            ExtractMetadata(extraction, fullText);
            extraction.ConfidenceScore = CalculateConfidence(extraction);

            _logger.LogInformation("Image OCR extraction complete. Confidence: {Confidence}",
                extraction.ConfidenceScore);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during image OCR extraction from file: {FilePath}", filePath);
            extraction.ConfidenceScore = 0.0;
        }

        return extraction;
    }, ct);
}
```

### When to Use This Pattern

âœ… **Good fit:**
- Document processing (letterheads, receipts, forms)
- Image-based text extraction
- Offline-first applications
- Cost-sensitive projects (no API fees)
- Privacy-sensitive applications (no cloud upload)

âŒ **Poor fit:**
- Handwriting recognition (Tesseract struggles)
- Complex multi-column layouts (needs layout analysis)
- Maximum accuracy requirements (use Azure/Google Vision)
- Real-time video processing (use specialized video libraries)
- Non-Latin scripts (may need training data)

### Future Enhancements

**Performance:**
- Image preprocessing (rotation detection, deskew)
- Confidence threshold filtering
- Caching of extracted text

**Accuracy:**
- Layout analysis for better region detection
- Hybrid approach: Tesseract + LLM for metadata extraction
- Custom training data for domain-specific terms

**Features:**
- Multi-language support (add language selection)
- Table extraction and parsing
- Handwriting detection (with fallback)

### Testing Recommendations

```csharp
// Unit test: Valid image
var result = await ExtractTextFromImageAsync("sample-letterhead.jpg");
Assert.NotEmpty(result);

// Unit test: Invalid image
var result = await ExtractTextFromImageAsync("invalid.jpg");
Assert.Empty(result);

// Integration test: Full extraction pipeline
var extraction = await ExtractFromImageAsync("letterhead.png");
Assert.NotNull(extraction.HeaderText);
Assert.Greater(extraction.ConfidenceScore, 0);
```

### Production Notes

**Disk space:** Tesseract requires tessdata files (~100-200MB depending on languages)
**Performance:** OCR is CPU-bound, allow 1-3 seconds per image on typical hardware
**Cleanup:** Always dispose of bitmap and engine to prevent memory leaks
**Logging:** Log extraction confidence and any failures for monitoring

### File Reference

- Implementation: `C:\Projects\client-manager\ClientManagerAPI\Services\LicenseManager\DocumentExtractionService.cs`
- PR: #123 (github.com/martiendejong/client-manager/pull/123)
- Reflection log: `C:\scripts\_machine\reflection.log.md Â§ 2026-01-12 23:15`
