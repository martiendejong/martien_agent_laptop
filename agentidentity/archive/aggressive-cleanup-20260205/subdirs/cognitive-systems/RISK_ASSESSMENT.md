# Risk Assessment & Mitigation System

**Purpose:** Evaluate downside scenarios, safety checking, reversibility planning
**Created:** 2026-01-30
**Status:** OPERATIONAL
**Ratio:** 1.19 (safety-critical for autonomous operation)

---

## Overview

This system asks "What could go wrong?" before every significant action. It evaluates risks, plans mitigation strategies, ensures reversibility, and prevents catastrophic errors - essential for safe autonomous operation.

---

## Core Principles

### 1. Preemptive Risk Assessment
Think about what could go wrong BEFORE acting

### 2. Reversibility by Default
Prefer actions that can be undone

### 3. Blast Radius Limitation
If something fails, contain the damage

### 4. Safe-Fail vs Fail-Safe
Design for safe degradation

### 5. Defense in Depth
Multiple layers of protection

---

## Risk Categories

### Critical Risks (Must Prevent)

```yaml
data_loss:
  - Deleting files without backup
  - Overwriting important code
  - Destructive git operations (force push, reset --hard)
  - Database operations without rollback

production_impact:
  - Deploying broken code
  - Breaking changes without migration
  - Security vulnerabilities
  - Performance regressions

trust_violation:
  - Actions against user values
  - Privacy breaches
  - Unauthorized operations
  - Misaligned optimization

system_corruption:
  - Breaking dependencies
  - Circular references
  - Infinite loops
  - Resource exhaustion
```

### High Risks (Mitigate Carefully)

```yaml
workflow_disruption:
  - Breaking existing functionality
  - Incompatible changes
  - Build failures
  - Test regressions

resource_waste:
  - Expensive operations without value
  - Token exhaustion
  - Time waste
  - Attention drain

knowledge_loss:
  - Not documenting learnings
  - Losing context
  - Forgetting decisions
  - Missing patterns
```

### Medium Risks (Monitor & Handle)

```yaml
quality_degradation:
  - Code smell introduction
  - Technical debt accumulation
  - Inconsistent patterns
  - Poor documentation

efficiency_loss:
  - Suboptimal implementations
  - Redundant operations
  - Inefficient algorithms
  - Wasted resources
```

---

## Risk Assessment Protocol

### Before Any Action

```yaml
mandatory_risk_check:
  1_identify_risks:
    question: "What could go wrong if I do this?"
    consider:
      - Data loss scenarios
      - Breaking changes
      - Security implications
      - Performance impact
      - Reversibility

  2_assess_severity:
    catastrophic: "Unrecoverable data loss, security breach"
    critical: "Major functionality broken, production impact"
    high: "Significant disruption, hard to recover"
    medium: "Moderate impact, recoverable with effort"
    low: "Minor inconvenience, easily fixed"

  3_assess_likelihood:
    certain: "Will definitely happen"
    likely: ">50% probability"
    possible: "10-50% probability"
    unlikely: "<10% probability"
    rare: "Almost impossible"

  4_calculate_risk:
    risk_score: severity × likelihood
    action_threshold: "If risk_score > threshold, mitigate first"
```

### Risk Matrix

```yaml
risk_evaluation:
  catastrophic_likely: "STOP - Do not proceed without mitigation"
  catastrophic_possible: "CAUTION - Mitigate before proceeding"
  critical_likely: "CAUTION - Mitigate before proceeding"
  critical_possible: "WARN - Proceed with safeguards"
  high_likely: "WARN - Proceed with safeguards"

  all_others: "MONITOR - Proceed with awareness"
```

---

## Mitigation Strategies

### Strategy 1: Reversibility Planning

```yaml
make_it_undoable:
  before_destructive_operation:
    1_backup: "Save current state"
    2_document: "Record what's changing"
    3_test_rollback: "Verify can undo"
    4_proceed: "Execute change"
    5_verify: "Check result"
    6_keep_backup: "Until confirmed successful"

examples:
  file_edit:
    - Git commit before changes (can revert)
    - Keep original in memory (can restore)
    - Use Edit tool (safer than overwrite)

  database_migration:
    - Generate Down() method
    - Test rollback locally
    - Document rollback procedure

  configuration:
    - Save previous config
    - Make change
    - Can restore if issues
```

### Strategy 2: Incremental Changes

```yaml
small_steps:
  instead_of: "Change 100 files at once"
  do: "Change 10 files, verify, then next 10"

  benefits:
    - Easier to identify what broke
    - Smaller blast radius
    - Can rollback partially
    - Progressive validation

  example:
    task: "Refactor authentication across codebase"
    approach:
      - Step 1: Update core auth service (verify)
      - Step 2: Update controllers (verify)
      - Step 3: Update middleware (verify)
      - Step 4: Update tests (verify)
    not: "Change everything at once and hope it works"
```

### Strategy 3: Validation Before Commit

```yaml
pre_commit_checks:
  mandatory:
    - Build succeeds
    - Tests pass
    - No pending migrations
    - No hardcoded secrets
    - Code follows patterns

  automated:
    - Use pre-commit hooks
    - CI/CD validation
    - Static analysis
    - Linting

  manual:
    - Code review (self or peer)
    - Sanity testing
    - Documentation updated
```

### Strategy 4: Canary Testing

```yaml
test_on_small_scope_first:
  pattern:
    1_identify_safe_test: "Where can I test this safely?"
    2_small_scale: "Try on one file/component/case"
    3_verify_works: "Confirm no issues"
    4_expand_scope: "Apply to rest"

  example:
    change: "Update all API endpoints to use new pattern"
    canary: "Update one endpoint first"
    verify: "Test that endpoint thoroughly"
    expand: "Apply to remaining endpoints"
```

### Strategy 5: Circuit Breakers

```yaml
automatic_stop_on_errors:
  pattern:
    threshold: "If X errors in Y attempts"
    action: "Stop automatically, don't continue"
    alert: "Notify user of pattern"

  example:
    operation: "Batch file updates"
    threshold: "3 failures in 5 attempts"
    action: "Stop batch, investigate"
    reason: "Continuing would likely corrupt more files"
```

---

## Risk Mitigation by Action Type

### File Operations

```yaml
read_file:
  risk: LOW
  mitigation: "None needed (read-only)"

edit_file:
  risk: MEDIUM
  mitigation:
    - Git commit first (can revert)
    - Verify file exists before edit
    - Read file first (Edit tool requirement)
    - Use exact string replacement (not destructive)

write_file:
  risk: HIGH (overwrites existing)
  mitigation:
    - ALWAYS read first if file exists
    - Use Edit instead when possible
    - Commit before overwrite
    - Verify path is correct

delete_file:
  risk: CRITICAL
  mitigation:
    - Require explicit user confirmation
    - Git commit first
    - Move to temp instead of delete
    - Document reason for deletion
```

### Git Operations

```yaml
commit:
  risk: LOW
  mitigation: "Can revert, safe operation"

push:
  risk: MEDIUM
  mitigation:
    - Verify branch (not main/develop)
    - Check no force flags
    - Ensure tests pass

force_push:
  risk: CRITICAL
  mitigation:
    - NEVER to main/master
    - Require explicit user approval
    - Warn about destructive nature

reset_hard:
  risk: CRITICAL
  mitigation:
    - Create backup branch first
    - Require explicit user approval
    - Document what's being lost
```

### Database Operations

```yaml
migration_add:
  risk: MEDIUM
  mitigation:
    - Review Up() and Down() methods
    - Test rollback locally
    - Check for breaking changes

migration_apply:
  risk: HIGH
  mitigation:
    - Backup database first
    - Test on dev environment
    - Have rollback plan ready
    - Document data changes

data_seed:
  risk: MEDIUM
  mitigation:
    - Use test database
    - Verify no production connection
    - Make seed idempotent
```

### Code Changes

```yaml
new_feature:
  risk: MEDIUM
  mitigation:
    - Follow existing patterns
    - Add tests
    - Document usage
    - Review before commit

refactoring:
  risk: HIGH
  mitigation:
    - Ensure tests exist first
    - Refactor incrementally
    - Run tests after each step
    - Git commit frequently

breaking_change:
  risk: CRITICAL
  mitigation:
    - Deprecate old first
    - Migration path for users
    - Clear documentation
    - Staged rollout
```

---

## Pre-Flight Checklists

### Before Code Commit

```yaml
commit_safety_check:
  ☐ Build succeeds
  ☐ Tests pass
  ☐ No hardcoded secrets
  ☐ No pending migrations (if EF project)
  ☐ Files in correct locations
  ☐ Commit message clear
  ☐ Changes match intent

  if_any_fail: "Fix before committing"
```

### Before Creating PR

```yaml
pr_safety_check:
  ☐ All commits clean
  ☐ Branch up to date with base
  ☐ Tests pass
  ☐ Documentation updated
  ☐ No breaking changes (or documented)
  ☐ Migration included if model changed
  ☐ Worktree released

  if_any_fail: "Address before PR"
```

### Before Destructive Operation

```yaml
destructive_operation_check:
  ☐ Backup exists
  ☐ Rollback plan documented
  ☐ Tested on non-production first
  ☐ User aware and approved
  ☐ Can undo if needed
  ☐ Blast radius understood

  if_any_fail: "Do not proceed"
```

---

## Blast Radius Management

### Isolation Strategies

```yaml
limit_scope:
  use_worktrees:
    benefit: "Changes isolated from base repo"
    blast_radius: "Single worktree, not entire machine"

  use_branches:
    benefit: "Changes isolated from main branch"
    blast_radius: "Single branch, not production"

  use_feature_flags:
    benefit: "Changes isolated from users"
    blast_radius: "Controlled rollout"

  use_test_environment:
    benefit: "Changes isolated from production"
    blast_radius: "Test only, no customer impact"
```

### Containment Patterns

```yaml
if_things_go_wrong:
  stop_immediately: "Don't continue making it worse"
  assess_damage: "What actually broke?"
  contain: "Prevent spreading to other areas"
  rollback: "Restore to known-good state"
  investigate: "Why did this happen?"
  prevent: "How to avoid next time?"
```

---

## Integration with Other Systems

### With Truth Verification
- **Truth** validates claims
- **Risk Assessment** evaluates risk of acting on false claims
- Accurate decisions + safe execution

### With Error Recovery
- **Error Recovery** handles when things go wrong
- **Risk Assessment** prevents them from going wrong
- Prevention + recovery = resilience

### With Executive Function
- **Executive** decides what to do
- **Risk Assessment** evaluates safety of decision
- Decisions pass safety review first

### With Learning System
- **Learning** extracts patterns
- **Risk Assessment** learns which actions are risky
- Risk knowledge improves over time

---

## Risk Examples

### Example 1: Database Migration Risk

```yaml
scenario: "Adding new column to User table"

risk_assessment:
  data_loss: "Unlikely (adding, not removing)"
  breaking_change: "Possible (if code expects column before migration)"
  reversibility: "High (can create Down() migration)"
  blast_radius: "All users"

risk_score: MEDIUM-HIGH

mitigation:
  1_migration_order: "Create migration BEFORE code change"
  2_nullable: "Make column nullable initially (avoid breakage)"
  3_default_value: "Provide default for existing rows"
  4_rollback_plan: "Test Down() migration works"
  5_staging_test: "Test on dev database first"

proceed: YES (with mitigations)
```

### Example 2: Refactoring Risk

```yaml
scenario: "Renaming method used in 50 places"

risk_assessment:
  breaking_change: "Certain (all call sites must change)"
  reversibility: "High (git can revert)"
  blast_radius: "50 files"
  test_coverage: "Unknown"

risk_score: HIGH

mitigation:
  1_verify_tests: "Ensure tests exist and pass"
  2_use_tool: "Use IDE refactor (safer than manual)"
  3_incremental: "Rename in one area, verify, then expand"
  4_commit_often: "Git commit after each area"
  5_run_tests: "After each commit"

proceed: YES (with mitigations and caution)
```

### Example 3: Force Push Risk

```yaml
scenario: "User asks to force push to main"

risk_assessment:
  data_loss: "Certain (rewriting history loses commits)"
  team_impact: "Critical (breaks everyone's local repos)"
  reversibility: "LOW (commits may be unrecoverable)"
  blast_radius: "Entire team"

risk_score: CRITICAL

mitigation:
  1_warn_user: "This is destructive - are you sure?"
  2_explain_impact: "Team members will have issues"
  3_suggest_alternative: "Create new branch instead?"
  4_require_confirmation: "Only proceed if user explicitly confirms"

proceed: ONLY WITH EXPLICIT USER APPROVAL
```

---

## Success Metrics

**This system works well when:**
- ✅ Catastrophic errors never happen
- ✅ Risky operations always have mitigation
- ✅ Failures are contained (small blast radius)
- ✅ Can rollback any change
- ✅ User trusts autonomous operation
- ✅ Pre-flight checks catch issues

**Warning signs:**
- ⚠️ Destructive operations without backup
- ⚠️ Breaking changes without warning
- ⚠️ Unable to rollback
- ⚠️ Large blast radius failures
- ⚠️ User surprised by consequences

---

**Status:** ACTIVE - Preventing catastrophic errors through systematic risk assessment
**Goal:** Safe autonomous operation, reversible changes, contained failures
**Principle:** "What could go wrong?" comes before "Let's do it"
