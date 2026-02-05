# Cognitive Load Estimator

**Purpose:** Predict user mental effort required
**Created:** 2026-01-30
**Status:** OPERATIONAL
**Type:** User experience intelligence layer
**Ratio:** 2.33 (Value: 7, Effort: 2, Risk: 1)

---

## Overview

Estimate how much mental effort my responses or requests require from the user. Minimize cognitive load.

---

## Core Principles

### 1. User's Brain is Precious
Minimize mental effort required

### 2. Measure Complexity
Quantify cognitive demands

### 3. Reduce Load
Simplify when possible

### 4. Match Capacity
Adapt to user's current state

### 5. Signal Difficulty
Warn when high load unavoidable

---

## Load Calculation

```yaml
cognitive_load_factors:
  information_density:
    low: "1-2 concepts"
    medium: "3-5 concepts"
    high: "> 5 concepts"

  complexity:
    low: "Familiar concepts"
    medium: "Some new concepts"
    high: "Many unfamiliar concepts"

  decisions_required:
    low: "0-1 decisions"
    medium: "2-3 decisions"
    high: "> 3 decisions"

  context_switching:
    low: "Single context"
    medium: "2 contexts"
    high: "Multiple contexts"

  reading_effort:
    low: "< 100 words"
    medium: "100-300 words"
    high: "> 300 words"
```

---

## Load Estimation

```yaml
load_formula:
  score = (density + complexity + decisions + switching + reading) / 5

  interpretation:
    low: 1-3 (easy to process)
    medium: 4-6 (requires focus)
    high: 7-10 (mentally demanding)
```

---

## Load Reduction Techniques

```yaml
reduction_strategies:
  high_to_medium:
    - "Split into steps"
    - "Add examples"
    - "Use analogies"
    - "Visual formatting"

  medium_to_low:
    - "Remove details"
    - "Use lists"
    - "Bold key points"
    - "One concept per sentence"

  always:
    - "Front-load conclusion"
    - "Use familiar language"
    - "Minimize jargon"
```

---

## Example

```yaml
high_load_message:
  "The authentication system refactoring requires migrating from session-based to JWT tokens, updating 47 controllers, modifying the middleware pipeline, creating a new token service with refresh logic, handling existing sessions during transition, updating frontend auth calls, and deciding whether to use Redis or database for token storage."

  estimated_load: 9/10 (HIGH)
  issues:
    - "Too many concepts"
    - "Requires multiple decisions"
    - "No clear structure"

low_load_version:
  "Auth refactor plan:
  1. Create JWT token service
  2. Update middleware
  3. Migrate controllers (47 files)

  Decision needed: Redis or DB for tokens? Recommend Redis (faster)."

  estimated_load: 3/10 (LOW)
  improvements:
    - "Structured steps"
    - "One decision, recommendation provided"
    - "Scannable format"
```

---

## Integration

### With Adaptive Verbosity
- **Cognitive Load** measures mental demand
- **Adaptive Verbosity** adjusts detail level
- Lower verbosity when load is high

### With Attention Economics
- **Cognitive Load** measures difficulty
- **Attention Economics** budgets attention
- High load = more attention cost

---

**Status:** ACTIVE
**Goal:** Minimize user mental effort
**Principle:** "Make thinking easy"
