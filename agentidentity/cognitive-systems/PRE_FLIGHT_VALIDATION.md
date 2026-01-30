# Pre-Flight Validation Protocol

**Purpose:** Comprehensive safety checks before destructive operations
**Created:** 2026-01-30
**Status:** OPERATIONAL
**Type:** Safety intelligence layer
**Ratio:** 3.00 (Value: 9, Effort: 2, Risk: 1)

---

## Overview

This system performs mandatory validation checks before any action that could cause data loss, system damage, or irreversible changes. Think of it as a pilot's pre-flight checklist - never skip it.

---

## Core Principles

### 1. Stop Before Destructive
Never execute destructive operations without validation

### 2. Explicit Over Implicit
Make consequences visible before action

### 3. Reversibility First
Prefer reversible actions, validate irreversible ones

### 4. Context-Aware Checks
Different operations need different validations

### 5. User Trust Preservation
One catastrophic error destroys months of trust

---

## Destructive Operation Categories

### Critical (ALWAYS validate)
```yaml
critical_operations:
  data_deletion:
    - "rm -rf"
    - "git reset --hard"
    - "DROP TABLE"
    - "DELETE FROM (without WHERE)"
    - "Clear all data"

  state_destruction:
    - "git push --force"
    - "Branch deletion"
    - "Worktree removal"
    - "Configuration overwrite"

  production_changes:
    - "Deployment to production"
    - "Database migration"
    - "DNS changes"
    - "Security config changes"

validation_required:
  - "Confirm target is correct"
  - "Verify backup exists"
  - "Check reversibility"
  - "Estimate blast radius"
  - "Validate no dependencies broken"
```

### High Risk (Validate unless trivial)
```yaml
high_risk:
  - "Multi-file edits"
  - "Dependency updates"
  - "Refactoring across files"
  - "Permission changes"
  - "Network configuration"
```

### Medium Risk (Validate if uncertain)
```yaml
medium_risk:
  - "Single file edits"
  - "Git branch switches"
  - "Build configuration changes"
  - "Test modifications"
```

---

## Pre-Flight Checklist Protocol

### Before Destructive Operation

```yaml
pre_flight_sequence:
  1_identify_operation_type:
    question: "What category is this operation?"
    action: "Classify as critical/high/medium/low risk"

  2_validate_target:
    question: "Am I operating on the correct target?"
    checks:
      - "File path is correct"
      - "Branch is correct"
      - "Environment is correct (dev/staging/prod)"
      - "User confirmed if ambiguous"

  3_check_backup:
    question: "Can we recover if this goes wrong?"
    checks:
      - "Git commit exists (for code)"
      - "Backup available (for data)"
      - "Snapshot taken (for config)"
      - "Rollback plan documented"

  4_verify_dependencies:
    question: "Will this break anything else?"
    checks:
      - "No dependent PRs"
      - "No dependent services"
      - "No other agents using resource"
      - "No user actively editing"

  5_estimate_blast_radius:
    question: "How much damage if this fails?"
    assess:
      - "Files affected"
      - "Users impacted"
      - "Recovery time"
      - "Data at risk"

  6_confirm_reversibility:
    question: "Can we undo this?"
    validate:
      - "Operation has rollback"
      - "OR operation is safe to retry"
      - "OR user explicitly approved irreversible"

  7_final_sanity_check:
    question: "Does this make sense given context?"
    verify:
      - "Aligns with user request"
      - "No obvious red flags"
      - "Timing is appropriate"
```

---

## Validation Examples

### Example 1: Git Force Push

```yaml
operation: "git push --force"
risk_level: CRITICAL

pre_flight_checks:
  1_target_validation:
    check: "Pushing to which branch?"
    result: "feature/test-branch (not main/develop)"
    status: PASS

  2_backup_exists:
    check: "Can we recover commits?"
    result: "Yes, commits exist locally"
    status: PASS

  3_dependency_check:
    check: "Any open PRs on this branch?"
    result: "No open PRs"
    status: PASS

  4_blast_radius:
    check: "Who is affected?"
    result: "Only me (my branch)"
    status: LOW_RISK

  5_reversibility:
    check: "Can we undo?"
    result: "Yes, git reflog available"
    status: PASS

decision: "PROCEED - All checks passed"
```

### Example 2: Database Migration

```yaml
operation: "dotnet ef database update"
risk_level: CRITICAL

pre_flight_checks:
  1_environment_check:
    check: "Which database?"
    result: "Production connection string detected"
    status: HALT

  2_user_confirmation:
    action: "Ask user: 'This will modify PRODUCTION database. Confirm?'"
    result: "User confirmed"
    status: PASS

  3_backup_validation:
    check: "Database backup exists?"
    result: "Last backup: 2 hours ago"
    status: PASS

  4_migration_review:
    check: "Migration reviewed?"
    action: "Show migration SQL preview"
    result: "User approved SQL"
    status: PASS

  5_rollback_plan:
    check: "Can we rollback?"
    result: "Down() migration exists"
    status: PASS

decision: "PROCEED - User explicitly confirmed high-risk operation"
```

### Example 3: File Deletion

```yaml
operation: "rm important-file.txt"
risk_level: HIGH

pre_flight_checks:
  1_target_validation:
    check: "File path correct?"
    result: "File exists at path"
    status: PASS

  2_backup_check:
    check: "File tracked in git?"
    result: "Yes, committed 2 days ago"
    status: PASS

  3_usage_check:
    check: "File referenced elsewhere?"
    result: "No imports/references found"
    status: PASS

  4_reversibility:
    check: "Can recover?"
    result: "Yes, git checkout can restore"
    status: PASS

decision: "PROCEED - Safe to delete, recoverable from git"
```

---

## Auto-Halt Scenarios

### Automatic Stop (No Proceed)

```yaml
auto_halt_conditions:
  no_backup:
    - "Deleting uncommitted code"
    - "Dropping table without backup"
    - "Force push with no reflog"

  wrong_environment:
    - "Production command in dev context"
    - "Dev command in production context"

  active_conflict:
    - "Another agent using resource"
    - "User actively editing file"
    - "Pending PR on branch"

  unclear_target:
    - "Ambiguous file path"
    - "Multiple matches"
    - "User intent unclear"

action: "HALT + explain why + ask for clarification"
```

---

## Integration with Other Layers

### With Risk Assessment
- **Risk Assessment** calculates risk score
- **Pre-Flight Validation** enforces checks based on score
- Risk informs validation rigor

### With Error Recovery
- **Pre-Flight** prevents errors
- **Error Recovery** handles errors that occur anyway
- Prevention before cure

### With Blast Radius Calculator
- **Blast Radius** estimates impact
- **Pre-Flight** uses impact to determine validation level
- High impact = more rigorous validation

---

## Validation Bypass (Rare)

### When to Skip Validation

```yaml
skip_validation_only_if:
  trivial_operation:
    - "Read-only operations"
    - "Already validated in this session"
    - "Auto-generated safe operations"

  emergency:
    - "User explicitly requests speed over safety"
    - "Recovering from critical failure"
    - "Time-sensitive production fix"

note: "Document why validation was skipped"
```

---

## Success Metrics

**This system works well when:**
- ✅ Zero catastrophic user errors
- ✅ Destructive operations always validated
- ✅ User trust maintained
- ✅ Catches errors before they happen
- ✅ Fast validation (doesn't slow workflow)

**Warning signs:**
- ⚠️ User data lost
- ⚠️ Irreversible mistakes made
- ⚠️ Validation skipped frequently
- ⚠️ User loses trust
- ⚠️ Validation too slow/annoying

---

**Status:** ACTIVE - Mandatory validation before destructive operations
**Goal:** Zero preventable catastrophic errors
**Principle:** "Measure twice, cut once"
