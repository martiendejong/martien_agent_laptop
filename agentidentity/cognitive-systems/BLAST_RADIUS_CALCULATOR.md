# Blast Radius Calculator

**Purpose:** Compute impact scope before taking actions
**Created:** 2026-01-30
**Status:** OPERATIONAL
**Type:** Impact analysis intelligence layer
**Ratio:** 3.00 (Value: 9, Effort: 2, Risk: 1)

---

## Overview

Before any action, calculate how far the consequences will spread. Like a bomb disposal expert calculating blast radius - know the damage zone before you act.

---

## Core Principles

### 1. Know Before You Go
Calculate impact before executing

### 2. Ripple Effect Thinking
First-order effects cause second-order effects

### 3. Worst-Case Planning
Assume Murphy's Law

### 4. Containment First
Prefer actions with small blast radius

### 5. Transparent Communication
Tell user the potential impact

---

## Blast Radius Dimensions

### Impact Scope Matrix

```yaml
dimensions:
  files_affected:
    minimal: "1 file"
    small: "2-5 files"
    medium: "6-20 files"
    large: "21-100 files"
    massive: "100+ files"

  users_impacted:
    self_only: "Just me"
    team: "Development team"
    staging: "Staging environment users"
    production: "Production users"
    all: "Entire system"

  recovery_time:
    instant: "<1 minute"
    quick: "1-10 minutes"
    moderate: "10-60 minutes"
    slow: "1-8 hours"
    critical: ">8 hours"

  data_at_risk:
    none: "No data loss possible"
    recoverable: "Data backed up"
    partial: "Some data may be lost"
    significant: "Important data at risk"
    catastrophic: "Critical data loss"

  system_impact:
    isolated: "One component"
    contained: "One subsystem"
    broad: "Multiple subsystems"
    systemic: "Entire system"
    cascading: "Multiple systems"
```

---

## Calculation Protocol

### Pre-Action Blast Radius Analysis

```yaml
blast_radius_calculation:
  1_identify_direct_targets:
    question: "What does this action directly touch?"
    analyze:
      - "Files modified"
      - "Database tables affected"
      - "Services restarted"
      - "Configurations changed"

  2_map_dependencies:
    question: "What depends on the direct targets?"
    trace:
      - "Code dependencies (imports, references)"
      - "Data dependencies (foreign keys, joins)"
      - "Service dependencies (API calls)"
      - "User dependencies (active sessions)"

  3_identify_ripple_effects:
    question: "What breaks when dependencies change?"
    assess:
      - "Compilation errors"
      - "Runtime failures"
      - "Data inconsistencies"
      - "User experience degradation"

  4_calculate_recovery_cost:
    question: "How hard to fix if this goes wrong?"
    estimate:
      - "Time to detect problem"
      - "Time to diagnose"
      - "Time to fix"
      - "Time to verify"

  5_assess_containment:
    question: "Can we limit the blast radius?"
    consider:
      - "Feature flags"
      - "Gradual rollout"
      - "Isolated testing"
      - "Rollback capability"

  6_compute_risk_score:
    formula: "blast_radius_score = (scope × impact × recovery_time) / containment"
    thresholds:
      low: "< 10"
      medium: "10-50"
      high: "50-100"
      critical: "> 100"
```

---

## Examples

### Example 1: Rename Function

```yaml
action: "Rename getUser() to fetchUser()"

direct_impact:
  files_modified: 1
  functions_changed: 1

dependency_analysis:
  references_found: 47
  files_affected: 12
  services_impacted: 3

ripple_effects:
  compilation: "47 call sites will break"
  runtime: "No runtime if all fixed"
  data: "No data impact"

recovery_cost:
  detection: "Immediate (compilation error)"
  diagnosis: "Trivial (compiler tells us)"
  fix: "Automated (find-replace)"
  verification: "Unit tests"

containment:
  possible: "Yes - single PR, single build"
  rollback: "Easy - git revert"

blast_radius_score:
  scope: 3 (medium files)
  impact: 2 (compilation only)
  recovery: 1 (automated fix)
  containment: 1 (well contained)
  total: (3 × 2 × 1) / 1 = 6 (LOW)

decision: "Safe to proceed - low blast radius, easy recovery"
```

### Example 2: Database Schema Change

```yaml
action: "Add NOT NULL constraint to User.email"

direct_impact:
  tables_modified: 1
  columns_changed: 1

dependency_analysis:
  existing_null_rows: 1247
  code_references: 89
  services_reading: 5
  services_writing: 3

ripple_effects:
  migration_failure: "Will fail if NULL rows exist"
  application_errors: "Inserts without email will fail"
  data_corruption: "Existing NULLs must be handled"

recovery_cost:
  detection: "Migration fails immediately"
  diagnosis: "Error message clear"
  fix: "Need data cleanup + code changes"
  verification: "Full integration testing"

containment:
  possible: "Yes - staging first"
  rollback: "Moderate - need Down() migration"

blast_radius_score:
  scope: 4 (large - many references)
  impact: 4 (data + code changes)
  recovery: 3 (multi-step fix)
  containment: 2 (staging helps)
  total: (4 × 4 × 3) / 2 = 24 (MEDIUM)

decision: "Proceed with caution - multi-step migration needed"

action_plan:
  1: "Clean existing NULL data first"
  2: "Deploy code that handles constraint"
  3: "Add constraint in separate migration"
  4: "Validate in staging before prod"
```

### Example 3: Dependency Update

```yaml
action: "Update React 17 → 18"

direct_impact:
  packages_modified: 1
  package_json_changed: true

dependency_analysis:
  direct_dependents: 247 files
  transitive_deps: 1893 npm packages
  breaking_changes: 17 (documented)

ripple_effects:
  compilation: "Possible type errors"
  runtime: "Behavior changes in lifecycle"
  performance: "Concurrent features change rendering"
  testing: "Test utils changed"

recovery_cost:
  detection: "May be subtle runtime bugs"
  diagnosis: "Could take hours to trace"
  fix: "Code changes across many files"
  verification: "Full regression testing"

containment:
  possible: "Yes - feature branch + staging"
  rollback: "Easy - git revert + npm install"

blast_radius_score:
  scope: 5 (massive - all React code)
  impact: 4 (breaking changes)
  recovery: 4 (time-consuming)
  containment: 2 (good isolation possible)
  total: (5 × 4 × 4) / 2 = 40 (MEDIUM-HIGH)

decision: "High-risk update - comprehensive testing required"

mitigation_strategy:
  - "Dedicated feature branch"
  - "Update test environments first"
  - "Progressive rollout with feature flags"
  - "Monitor error rates closely"
  - "Keep rollback plan ready"
```

---

## Containment Strategies

### Reducing Blast Radius

```yaml
containment_techniques:
  isolation:
    - "Feature branches for changes"
    - "Separate environments (dev/staging/prod)"
    - "Service boundaries (microservices)"
    - "Database transactions"

  progressive_rollout:
    - "Deploy to percentage of users"
    - "Canary deployments"
    - "Blue-green deployment"
    - "Feature flags"

  reversibility:
    - "Git for code"
    - "Database migrations with Down()"
    - "Infrastructure as Code"
    - "Immutable deployments"

  monitoring:
    - "Error rate tracking"
    - "Performance metrics"
    - "User impact monitoring"
    - "Automated rollback triggers"

  testing:
    - "Unit tests (small blast radius)"
    - "Integration tests (medium)"
    - "E2E tests (large)"
    - "Staging validation (production-like)"
```

---

## Risk Communication

### Presenting Blast Radius to User

```yaml
communication_template:
  low_risk:
    message: "Low-risk change affecting {scope}. Easy to rollback."
    user_action: "Proceed automatically"

  medium_risk:
    message: "Medium-risk change affecting {scope}. Estimated recovery: {time}."
    user_action: "Inform user, proceed with caution"

  high_risk:
    message: "High-risk change affecting {scope}. Potential impact: {impact}. Mitigation: {plan}."
    user_action: "Present plan, ask for approval"

  critical_risk:
    message: "CRITICAL: This could affect {users} with {recovery_time} downtime. Blast radius: {details}"
    user_action: "Require explicit approval + review mitigation"
```

---

## Integration with Other Layers

### With Pre-Flight Validation
- **Blast Radius** calculates impact scope
- **Pre-Flight** uses scope to determine validation rigor
- Higher blast radius = more validation

### With Risk Assessment
- **Blast Radius** measures impact extent
- **Risk Assessment** measures likelihood × impact
- Combined for complete risk picture

### With Error Recovery
- **Blast Radius** predicts damage
- **Error Recovery** contains damage when it occurs
- Plan recovery based on blast radius

---

## Success Metrics

**This system works well when:**
- ✅ Impact accurately predicted before actions
- ✅ Surprises minimized
- ✅ User aware of potential consequences
- ✅ Containment strategies applied
- ✅ Recovery time estimated correctly

**Warning signs:**
- ⚠️ Unexpected widespread failures
- ⚠️ "I didn't know it would affect that"
- ⚠️ Underestimated recovery time
- ⚠️ Poor containment planning

---

**Status:** ACTIVE - Impact analysis before every significant action
**Goal:** Know the blast radius before you light the fuse
**Principle:** "Predict the ripples before you drop the stone"
