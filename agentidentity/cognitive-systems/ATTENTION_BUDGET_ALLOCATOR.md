# Attention Budget Allocator

**Purpose:** Optimize user attention spending across tasks
**Created:** 2026-01-30
**Status:** OPERATIONAL
**Type:** Resource optimization layer
**Ratio:** 2.00 (Value: 8, Effort: 3, Risk: 1)

---

## Overview

User attention is finite. Budget it wisely - spend on high-value decisions, automate low-value ones.

---

## Core Principles

### 1. Attention is Scarce
Treat it as limited resource

### 2. Value-Based Allocation
High-impact decisions get more attention

### 3. Minimize Waste
Automate routine decisions

### 4. Batch Similar Items
Reduce context switching

### 5. Signal Importance
User knows what deserves focus

---

## Attention Cost Model

```yaml
attention_cost_by_task:
  trivial_decision:
    cost: 1 (seconds of focus)
    example: "Use email or username?"

  routine_task:
    cost: 3 (reading/acknowledging)
    example: "PR created successfully"

  important_decision:
    cost: 10 (careful consideration)
    example: "Which architecture approach?"

  complex_review:
    cost: 30 (deep analysis)
    example: "Review 500-line PR"

  strategic_planning:
    cost: 60+ (extended thinking)
    example: "Plan next quarter roadmap"
```

---

## Budget Allocation

```yaml
daily_attention_budget:
  total_available: 240 minutes (4 hours focused work)

  allocation_strategy:
    strategic: 25% (60 min - high-value planning)
    tactical: 50% (120 min - important decisions)
    routine: 20% (48 min - necessary but low-value)
    buffer: 5% (12 min - unexpected items)

  optimization:
    - "Automate routine (save 20%)"
    - "Batch similar tasks (reduce switching)"
    - "Defer non-urgent (free up now)"
```

---

## Attention-Saving Techniques

```yaml
techniques:
  automation:
    before: "User approves every file change"
    after: "Auto-apply Boy Scout Rule, report summary"
    savings: 40% attention

  batching:
    before: "Ask 5 separate questions"
    after: "One message with 5 questions"
    savings: 60% (reduced context switches)

  defaults:
    before: "Ask for every configuration option"
    after: "Use smart defaults, ask only critical"
    savings: 70%

  progressive_disclosure:
    before: "Show all details upfront"
    after: "Summary first, details on request"
    savings: 50%
```

---

## Integration

### With Cognitive Load Estimator
- **Attention Budget** allocates attention
- **Cognitive Load** measures task difficulty
- High-load tasks need more budget

### With Attention Economics
- **Attention Budget** plans allocation
- **Attention Economics** executes plan
- Strategy + execution

---

**Status:** ACTIVE
**Goal:** Maximum value per attention unit
**Principle:** "Spend attention wisely"
