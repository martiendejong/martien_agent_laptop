# Quality Gate Enforcer

**Purpose:** Mandatory checks before completion
**Created:** 2026-01-30
**Status:** OPERATIONAL
**Type:** Quality assurance layer
**Ratio:** 2.33 (Value: 7, Effort: 2, Risk: 1)

---

## Overview

No task is "done" until it passes quality gates. Enforce Definition of Done automatically.

---

## Core Principles

### 1. Done Means Done
Meeting DoD is non-negotiable

### 2. Automated Checking
Don't rely on memory

### 3. Block Until Pass
Can't proceed without passing gates

### 4. Clear Criteria
Objective, measurable gates

### 5. Context-Specific Gates
Different tasks, different criteria

---

## Quality Gates by Task Type

```yaml
code_feature:
  gates:
    - "Code compiles"
    - "Tests pass"
    - "No pending migrations"
    - "Code reviewed (or self-reviewed)"
    - "Documentation updated"
    - "PR created"

bug_fix:
  gates:
    - "Bug reproduced"
    - "Root cause identified"
    - "Fix verified"
    - "Regression test added"
    - "No new warnings"

refactoring:
  gates:
    - "Tests still pass"
    - "Behavior unchanged"
    - "Performance not degraded"
    - "Code cleaner than before (Boy Scout Rule)"

documentation:
  gates:
    - "Accuracy verified"
    - "Links working"
    - "Examples tested"
    - "User-readable"

configuration:
  gates:
    - "Validated"
    - "Tested in target environment"
    - "Backup of old config"
    - "Rollback plan documented"
```

---

## Enforcement Protocol

```yaml
quality_gate_check:
  1_identify_task_type:
    action: "Classify task"

  2_load_gates:
    action: "Retrieve quality gates for this type"

  3_execute_checks:
    for_each_gate:
      - "Run automated check if possible"
      - "Request manual confirmation if needed"
      - "Log result (pass/fail)"

  4_evaluate_status:
    if_all_pass: "Mark task COMPLETE"
    if_any_fail: "BLOCK completion, list failures"

  5_communicate_status:
    tell_user:
      - "Task complete ✓" if passed
      - "Blocked - {failed_gates}" if failed
```

---

## Examples

```yaml
example_code_feature:
  task: "Add user registration endpoint"

  gate_checks:
    compiles: ✓ PASS
    tests_pass: ✓ PASS
    migrations: ✓ PASS (no pending)
    code_review: ✓ PASS (self-reviewed)
    docs_updated: ✗ FAIL (API docs not updated)
    pr_created: ✓ PASS

  result: "BLOCKED - Must update API documentation before completing"

  action: "Update docs/api.md, then re-check gates"
```

---

## Integration

### With Definition of Done
- **Quality Gates** enforce DoD criteria
- **DoD** defines what gates exist
- Gates = automated DoD enforcement

### With Pre-Flight Validation
- **Pre-Flight** prevents errors during work
- **Quality Gates** prevent incomplete delivery
- Together: safe execution + complete results

---

**Status:** ACTIVE
**Goal:** 100% DoD compliance
**Principle:** "Done means done"
