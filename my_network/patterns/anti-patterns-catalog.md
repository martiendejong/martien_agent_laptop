# Anti-Patterns Catalog

**Purpose:** Comprehensive catalog of documented mistakes, violations, and prevention protocols

## How to Use This Catalog

**Before starting work:**
- Search this catalog for similar task type
- Check if there are known anti-patterns to avoid
- Review prevention protocols

**After making mistake:**
- Add new entry with root cause analysis
- Create prevention protocol
- Link to reflection.log.md entry

## Critical Anti-Patterns (Zero Tolerance)

### AP-001: Skipping Session Startup Protocol
**Symptom:** Forgetting identity, violating rules, missing context
**Root Cause:** Not loading cognitive architecture at session start
**Example:** Called myself "Claude" instead of "Jengo"
**Prevention:**
- ✅ MANDATORY startup checklist in CLAUDE.md
- ✅ Load agentidentity/CORE_IDENTITY.md first
- ✅ Load knowledge-base/README.md second
- ✅ Query knowledge network for "Who am I?" as validation
**Severity:** CRITICAL - Identity-level failure
**Reflection Log:** 2026-02-01 01:45

### AP-002: Working in Base Repo (Feature Development Mode)
**Symptom:** Editing C:\Projects\<repo> instead of worktree
**Root Cause:** Mode detection failure, skipping worktree allocation
**Example:** Fixed Hazina terminal paste bug in base repo
**Prevention:**
- ✅ Use detect-mode.ps1 before ANY code work
- ✅ Default to Feature Development Mode when uncertain
- ✅ Check GENERAL_DUAL_MODE_WORKFLOW.md decision tree
- ✅ Allocate worktree BEFORE editing code
**Severity:** CRITICAL - Zero tolerance violation
**Reflection Log:** 2026-01-30 15:00

### AP-003: ClickUp Status Change Without Assignment
**Symptom:** Updating task status without assigning to user
**Root Cause:** Incomplete command mental checklist
**Example:** Moved task to "review" without -Assignee parameter
**Prevention:**
- ✅ RULE 7: ALWAYS include -Assignee when status is "busy" or "review"
- ✅ Default assignee: 74525428
- ✅ Validate command against PERSONAL_INSIGHTS.md before execution
**Severity:** CRITICAL - Violates "ALWAYS" rule
**Reflection Log:** 2026-01-30 20:30

### AP-004: Context Confusion Between Dossiers
**Symptom:** Researching wrong context (e.g., Valsuani instead of gemeente)
**Root Cause:** No active situations registry, missing disambiguation
**Example:** Mixed gemeente (municipality) with Valsuani (art project)
**Prevention:**
- ✅ Check SYSTEM_MAP.md § Active Situations before ambiguous queries
- ✅ Apply disambiguation rules
- ✅ Confirm context if multiple interpretations possible
**Severity:** HIGH - Wastes time, confuses user
**Reflection Log:** 2026-01-30 21:50

## High-Impact Anti-Patterns

### AP-005: Overthinking Timing Decisions
**Symptom:** Suggesting delays when immediate action possible
**Root Cause:** Sequential thinking when parallel approach better
**Example:** Suggested waiting to apply after networking, user said "waarom niet vandaag al solliciteren?"
**Prevention:**
- ✅ Default to parallel tracks over sequential dependencies
- ✅ Don't overcomplicate timing when materials ready
- ✅ Present both options, let user decide
**Severity:** MEDIUM - Delays action unnecessarily
**Reflection Log:** 2026-01-31 13:45

### AP-006: Missing File System Knowledge
**Symptom:** Can't find obvious directory locations
**Root Cause:** Not proactively scanning personal/important directories
**Example:** Couldn't find c:\martien_cv despite obvious location
**Prevention:**
- ✅ Proactively scan personal directories at session start
- ✅ Update file-system-map.md when discovering new locations
- ✅ Don't assume only standard locations exist
**Severity:** MEDIUM - Reduces autonomy, requires user guidance
**Reflection Log:** 2026-01-31 13:45

### AP-007: Skipping ClickUp Check Before Work
**Symptom:** Starting work without checking if task already exists in ClickUp
**Root Cause:** Not treating ClickUp as source of truth
**Example:** Creating duplicate tasks or missing existing task context
**Prevention:**
- ✅ BEFORE ANY TASK: Search ClickUp first
- ✅ Use clickup-sync.ps1 -Action list | grep "<keyword>"
- ✅ Update existing task if found, create if not
**Severity:** MEDIUM - Loses team visibility, duplicates work
**Reflection Log:** 2026-01-30 06:00

## Communication Anti-Patterns

### AP-008: Over-Formal or Verbose Communication
**Symptom:** Long-winded responses, robotic language
**Root Cause:** Default LLM behavior, not user-calibrated
**Example:** Heavy status blocks for every response
**Prevention:**
- ✅ Read PERSONAL_INSIGHTS.md § Communication Style
- ✅ Conversational tone, person-to-person
- ✅ Status blocks only for complex multi-part work
- ✅ Minimal formatting unless genuinely helpful
**Severity:** LOW - Cognitive load on user
**Reflection Log:** PERSONAL_INSIGHTS.md updates

### AP-009: Dictating User Communication Style
**Symptom:** Writing messages for user instead of offering options
**Root Cause:** Not respecting user's authentic voice
**Example:** User wrote own LinkedIn message, I should have just tweaked
**Prevention:**
- ✅ Offer options, don't dictate approach
- ✅ User knows their communication style better
- ✅ Suggest tweaks, respect their choice
**Severity:** LOW - Reduces authenticity
**Reflection Log:** 2026-01-31 13:45

## Technical Anti-Patterns

### AP-010: Deep Dependency Chains in Controllers
**Symptom:** 20+ constructor parameters, integration test failures
**Root Cause:** Not extracting services when controller complexity grows
**Example:** ChatController with deep dependency chains
**Prevention:**
- ✅ Use test-infrastructure-analyzer.ps1 (when implemented)
- ✅ Extract service when controller has >5 dependencies
- ✅ Review controller constructors during code review
**Severity:** HIGH - Breaks tests, reduces maintainability
**Reflection Log:** Tool wishlist 2026-01-25

### AP-011: Missing EF Core Migration
**Symptom:** PendingModelChangesWarning at runtime
**Root Cause:** Committing code changes without corresponding migration
**Example:** Database model changes without migration
**Prevention:**
- ✅ Run dotnet ef migrations has-pending-model-changes before PR
- ✅ Create migration if exit code 1
- ✅ Commit migration with feature
**Severity:** CRITICAL - Runtime errors in production
**Reference:** CLAUDE.md § Pre-PR Validation

## Workflow Anti-Patterns

### AP-012: Pushing Directly to Main Branch
**Symptom:** No PR, no review, direct push to main/develop
**Root Cause:** Mode detection failure, urgency bias
**Example:** Terminal paste fix pushed directly
**Prevention:**
- ✅ ALWAYS create PR for planned work
- ✅ Even small fixes need review
- ✅ Only skip PR for emergency hotfixes (rare!)
**Severity:** CRITICAL - Bypasses quality gates
**Reflection Log:** 2026-01-30 15:00

### AP-013: Creating ClickUp Tasks Retroactively
**Symptom:** Work done first, task created after
**Root Cause:** Not following ClickUp-first workflow
**Example:** Fixed bug, then created ClickUp task
**Prevention:**
- ✅ Check ClickUp BEFORE starting work
- ✅ Create task if doesn't exist
- ✅ Update throughout work
**Severity:** MEDIUM - Loses audit trail timing
**Reflection Log:** 2026-01-30 15:00

## Pattern Recognition Meta-Patterns

### Meta-Pattern 1: Not Following Documented Protocols
**Recurring theme:** Many mistakes come from skipping documented workflows
**Root cause:** Not validating against documentation before acting
**Fix:** Pre-execution validation checklist for all workflows

### Meta-Pattern 2: Sequential Thinking Bias
**Recurring theme:** Suggesting delays when parallel action possible
**Root cause:** Default to waterfall thinking
**Fix:** Ask "Can this be done in parallel?" before sequencing

### Meta-Pattern 3: Incomplete Mental Checklists
**Recurring theme:** Forgetting required parameters or steps
**Root cause:** Relying on memory instead of validation
**Fix:** Check documentation/examples before executing

## Usage Protocol

**When starting similar work:**
```
1. Search anti-patterns catalog: grep "<task-type>"
2. Review prevention protocols
3. Apply checklist before execution
4. If new mistake made → add to catalog immediately
```

**When adding new anti-pattern:**
```
1. Create unique ID (AP-XXX)
2. Document symptom, root cause, example
3. Create concrete prevention protocol
4. Link to reflection.log.md entry
5. Categorize by severity
6. Update knowledge network
```

## Categories

- **Identity & Cognitive:** AP-001
- **Workflow Violations:** AP-002, AP-007, AP-012, AP-013
- **ClickUp Integration:** AP-003, AP-007, AP-013
- **Context & Knowledge:** AP-004, AP-006
- **Communication:** AP-008, AP-009
- **Technical:** AP-010, AP-011
- **Decision-Making:** AP-005

## Success Metrics

**Effective Catalog:**
- ✅ Mistakes not repeated
- ✅ New team members avoid known pitfalls
- ✅ Prevention protocols actually prevent
- ✅ Catalog referenced before similar work

**Needs Improvement:**
- ❌ Same anti-pattern violated multiple times
- ❌ Catalog not consulted
- ❌ Prevention protocols too vague

**Last Updated:** 2026-02-01
**Total Anti-Patterns:** 13 documented
**Next Review:** Weekly (add new entries as discovered)
