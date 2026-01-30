# Habit Strength Tracker

**Purpose:** Measure and reinforce beneficial automation patterns
**Created:** 2026-01-30
**Status:** OPERATIONAL
**Type:** Behavioral reinforcement layer
**Ratio:** 2.33 (Value: 7, Effort: 2, Risk: 1)

---

## Overview

Track how strong each beneficial habit is. Reinforce weak habits, maintain strong ones. Turn one-time actions into automatic patterns.

---

## Core Principles

### 1. Repetition Builds Strength
Habits form through consistent repetition

### 2. Measure Consistency
Track adherence over time

### 3. Reinforce Positively
Acknowledge habit execution

### 4. Fade Reminders
Strong habits need less prompting

### 5. Prevent Regression
Detect when habits weaken

---

## Habit Categories

### Types of Beneficial Habits

```yaml
habit_types:
  safety_habits:
    - "Pre-flight validation before destructive ops"
    - "Blast radius calculation"
    - "Backup verification"
    - "Branch checking before edit"

  quality_habits:
    - "Run tests before commit"
    - "Code review before merge"
    - "Documentation with code"
    - "Boy Scout Rule (leave code better)"

  communication_habits:
    - "Signal-to-noise optimization"
    - "User-first language"
    - "Status updates after tasks"
    - "Clear error messages"

  workflow_habits:
    - "Worktree allocation for features"
    - "Release worktree after PR"
    - "Update reflection log"
    - "Commit documentation changes"

  learning_habits:
    - "Reflect on mistakes"
    - "Update instructions after learning"
    - "Pattern documentation"
    - "Knowledge base updates"
```

---

## Habit Strength Measurement

### Strength Calculation

```yaml
strength_formula:
  factors:
    consistency: "% of opportunities where habit executed"
    recency: "How recently habit performed"
    streak: "Consecutive executions"
    ease: "Effort required to execute"

  calculation:
    strength = (consistency × 0.4) + (recency × 0.2) + (streak × 0.3) + (ease × 0.1)

  strength_levels:
    nascent: 0-20 (forming, needs reminders)
    developing: 21-50 (inconsistent, needs reinforcement)
    established: 51-80 (mostly automatic)
    automatic: 81-100 (no reminders needed)
```

---

## Tracking Protocol

### Habit Execution Logging

```yaml
habit_log_entry:
  timestamp: "2026-01-30T14:35:22Z"
  habit: "pre_flight_validation"
  triggered: true/false
  executed: true/false
  context: "git push --force operation"

  streak_data:
    current_streak: 47
    longest_streak: 89
    last_break: "2026-01-15"

  strength_score: 92 (AUTOMATIC)
```

---

## Reinforcement Strategies

### Habit Strength → Reminder Level

```yaml
reinforcement_by_strength:
  nascent_habit:
    strength: 0-20
    reminder: "Explicit prompt before opportunity"
    example: "Remember to validate before git push --force"

  developing_habit:
    strength: 21-50
    reminder: "Subtle reminder"
    example: "Validation? [yes/no]"

  established_habit:
    strength: 51-80
    reminder: "No reminder, but log execution"
    monitoring: "Alert if skipped"

  automatic_habit:
    strength: 81-100
    reminder: "None - fully internalized"
    monitoring: "Silent tracking only"
```

---

## Habit Formation Process

### Building New Habits

```yaml
habit_creation:
  1_identify_pattern:
    trigger: "Action repeated 3+ times"
    example: "Manual file encoding checks repeated"

  2_formalize_habit:
    action: "Create explicit habit definition"
    name: "file_encoding_validation"
    trigger: "Before committing files"
    action: "Run detect-encoding-issues.ps1"

  3_initial_tracking:
    strength: 0 (NASCENT)
    reminder_level: "Explicit prompt"

  4_reinforce_execution:
    each_time:
      - "Log execution"
      - "Update streak"
      - "Recalculate strength"

  5_reduce_prompting:
    as_strength_increases:
      - "Fade from explicit to subtle"
      - "Eventually to silent"

  6_maintain_monitoring:
    always:
      - "Track execution"
      - "Alert on regression"
```

---

## Regression Detection

### When Habits Weaken

```yaml
regression_signals:
  streak_broken:
    threshold: "3+ consecutive skips"
    action: "Increase reminder level"

  consistency_drop:
    threshold: "Strength drops > 20 points"
    action: "Re-establish habit with explicit prompts"

  context_change:
    trigger: "New environment/project"
    action: "Temporarily increase reminders"

regression_response:
  1_diagnose_cause:
    - "Was habit intentionally skipped?"
    - "Is habit still relevant?"
    - "Did context change?"

  2_adjust_strategy:
    - "Increase reminder level"
    - "Simplify habit execution"
    - "Add automation if possible"

  3_rebuild_strength:
    - "Explicit prompts until streak rebuilt"
    - "Positive reinforcement on execution"
```

---

## Examples

### Example 1: Safety Habit (Pre-Flight Validation)

```yaml
habit: "pre_flight_validation"
description: "Validate before destructive operations"

strength_over_time:
  week_1: 15 (NASCENT - explicit reminders)
  week_2: 35 (DEVELOPING - subtle prompts)
  week_3: 58 (ESTABLISHED - automatic with monitoring)
  week_4: 87 (AUTOMATIC - fully internalized)

current_state:
  streak: 47 consecutive executions
  last_executed: "5 minutes ago"
  consistency: 94% (executed 94 of 100 opportunities)
  ease: 95 (very easy to execute)
  strength: 92 (AUTOMATIC)

reminder_level: NONE
monitoring: "Silent tracking, alert if skipped"
```

### Example 2: Quality Habit Regression

```yaml
habit: "run_tests_before_commit"
description: "Execute test suite before git commit"

history:
  month_1: 82 (AUTOMATIC)
  month_2: 79 (ESTABLISHED)
  month_3: 61 (ESTABLISHED - declining)
  month_4: 42 (DEVELOPING - REGRESSION DETECTED)

regression_analysis:
  cause: "Time pressure from tight deadlines"
  skips: 6 consecutive
  strength_drop: 40 points

intervention:
  action: "Re-establish habit"
  reminder_level: "EXPLICIT"
  message: "Tests before commit? This habit has weakened."
  tracking: "Rebuild streak from 0"

recovery_plan:
  - "Explicit prompt for next 10 commits"
  - "Reduce to subtle after 5-commit streak"
  - "Return to silent after 80+ strength"
```

---

## Integration with Other Layers

### With Habit Formation
- **Habit Formation** creates habits
- **Habit Strength Tracker** measures habit strength
- Creation → tracking → maintenance

### With Self-Regulation Monitor
- **Habit Strength** measures behavioral patterns
- **Self-Regulation** ensures pattern adherence
- Habits = what to do, Self-regulation = did I do it

### With Meta-Optimizer
- **Habit Strength** identifies weak habits
- **Meta-Optimizer** suggests habit improvements
- Data-driven habit evolution

---

## Success Metrics

**This system works well when:**
- ✅ Beneficial patterns become automatic
- ✅ Habit strength increases over time
- ✅ Regressions detected and corrected
- ✅ Strong habits maintained with low effort
- ✅ New habits form consistently

**Warning signs:**
- ⚠️ Habits not forming despite repetition
- ⚠️ Frequent regressions
- ⚠️ Inconsistent execution
- ⚠️ Habits forgotten

---

**Status:** ACTIVE - Tracking and reinforcing beneficial patterns
**Goal:** Strong, automatic habits for quality and safety
**Principle:** "What gets measured gets reinforced"
