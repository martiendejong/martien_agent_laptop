# Graceful Degradation Planner

**Purpose:** Pre-plan fallback strategies for each action
**Created:** 2026-01-30
**Status:** OPERATIONAL
**Type:** Resilience intelligence layer
**Ratio:** 2.00 (Value: 8, Effort: 3, Risk: 1)

---

## Overview

Before doing anything, have a fallback plan. When things fail, degrade gracefully rather than catastrophically.

---

## Core Principles

### 1. Plan for Failure
Assume things can go wrong

### 2. Fallback Hierarchy
Multiple backup plans

### 3. Partial Success
Some functionality > no functionality

### 4. User Communication
Explain degraded state clearly

### 5. Auto-Recovery
Attempt fallbacks automatically

---

## Degradation Strategy

```yaml
degradation_levels:
  level_0_full_functionality:
    state: "Everything working"

  level_1_minor_degradation:
    state: "Core works, nice-to-haves disabled"
    example: "API works, but slower without cache"

  level_2_partial_functionality:
    state: "Essential features only"
    example: "Read-only mode when DB write fails"

  level_3_graceful_failure:
    state: "Clear error, user can proceed elsewhere"
    example: "Feature unavailable, rest of app works"

  level_4_catastrophic_failure:
    state: "Total failure"
    note: "Avoid this through fallbacks"
```

---

## Fallback Planning

```yaml
before_action:
  1_identify_failure_modes:
    - "Network timeout"
    - "API rate limit"
    - "File not found"
    - "Permission denied"

  2_plan_fallbacks:
    primary: "Normal execution"
    fallback_1: "Retry with backoff"
    fallback_2: "Use cached data"
    fallback_3: "Degrade to read-only"
    fallback_4: "Clear error message"

  3_execute_with_fallbacks:
    try:
      - "Attempt primary"
    catch:
      - "Try fallback_1"
      - "Try fallback_2"
      - "..."
    finally:
      - "Report degradation level to user"
```

---

## Example

```yaml
action: "Fetch user data from API"

failure_modes:
  - "API down"
  - "Network timeout"
  - "Rate limited"
  - "Invalid response"

fallback_plan:
  level_0:
    strategy: "Normal API call"
    if_success: "Full functionality"

  level_1:
    trigger: "Timeout"
    strategy: "Retry with 2x timeout"
    degradation: "Slower but works"

  level_2:
    trigger: "API down"
    strategy: "Use cached data"
    degradation: "Stale data, but functional"

  level_3:
    trigger: "No cache available"
    strategy: "Mock data"
    degradation: "Demo mode only"

  level_4:
    trigger: "All fallbacks failed"
    strategy: "Clear error message"
    message: "User data unavailable. Try again later."
```

---

## Integration

### With Error Recovery
- **Graceful Degradation** plans fallbacks
- **Error Recovery** executes fallbacks
- Planning + execution

### With Risk Assessment
- **Risk Assessment** identifies failure risks
- **Graceful Degradation** mitigates them
- Risk analysis → mitigation planning

---

**Status:** ACTIVE
**Goal:** Never catastrophic failure
**Principle:** "Fail gracefully, not catastrophically"
