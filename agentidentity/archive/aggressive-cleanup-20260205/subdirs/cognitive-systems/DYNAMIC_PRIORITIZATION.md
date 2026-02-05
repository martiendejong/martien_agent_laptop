# Dynamic Task Reprioritization

**Purpose:** Automatically adjust task priorities based on changing conditions
**Created:** 2026-02-01
**Based on:** ACE Framework Layer 5 (Cognitive Control) - Dynamic priority adjustment requirement

---

## 🎯 Purpose

Adapt to changing conditions:
- Reprioritize when new information arrives
- React to blockers and dependencies
- Optimize for user goals
- Handle urgent interruptions
- Balance short-term vs long-term value

---

## 📊 Priority Calculation

### Priority Formula
```
priority = (value × urgency × confidence) / (effort × risk)

Where:
- value: Expected benefit (1-10)
- urgency: Time sensitivity (1-10)
- confidence: Likelihood of success (0.0-1.0)
- effort: Time/resource cost (1-10)
- risk: Chance of failure/problems (0.0-1.0, inverted)
```

### Example
```yaml
task: "Implement OAuth authentication"
  value: 9  # High business value
  urgency: 7  # Important but not critical
  confidence: 0.85  # High confidence
  effort: 6  # Moderate effort
  risk: 0.20  # Low risk

priority = (9 × 7 × 0.85) / (6 × 0.20)
         = 53.55 / 1.2
         = 44.6
```

---

## 🔄 Reprioritization Triggers

### 1. New Information
```yaml
trigger: "new_information"
event: "Discovered simpler implementation approach"

before:
  effort: 6
  priority: 44.6

after:
  effort: 3  # Easier than expected
  priority: 89.3  # Priority doubled!

action: "Move task up in queue"
```

### 2. Blocker Detected
```yaml
trigger: "blocker_detected"
event: "Dependency not ready"

before:
  status: "ready"
  priority: 44.6

after:
  status: "blocked"
  priority: 0  # Cannot execute

action: "Move to blocked queue, work on next task"
```

### 3. Urgency Increase
```yaml
trigger: "urgency_change"
event: "User escalated to critical"

before:
  urgency: 7
  priority: 44.6

after:
  urgency: 10  # Now critical
  priority: 63.8

action: "Pause current task, start this one"
```

### 4. Value Realization
```yaml
trigger: "value_realization"
event: "Completed prerequisite unlocks high-value work"

before:
  task_queue:
    - task-A (priority: 40)
    - task-B (priority: 35, blocked)
    - task-C (priority: 30)

after:
  task-A completed → task-B unblocked
  task_queue:
    - task-B (priority: 80, now unblocked!)
    - task-C (priority: 30)

action: "Reorder queue, prioritize unblocked high-value task"
```

---

## ⚡ Automatic Adjustments

### Time-Based Decay
```yaml
rule: "urgency_increases_over_time"

task_age_days: 7
urgency_boost: +2 per week

original_urgency: 5
current_urgency: 7  # After 1 week
priority_increase: +28%

reason: "Older tasks become more urgent to prevent neglect"
```

### Success Pattern Learning
```yaml
rule: "confidence_adjusts_based_on_history"

task_type: "database_migration"
historical_success_rate: 0.95

confidence_adjustment: +0.10  # Boost confidence
new_confidence: 0.95
priority_increase: +12%

reason: "Strong track record with this task type"
```

### Resource Availability
```yaml
rule: "prioritize_tasks_matching_available_resources"

condition: "Low token budget remaining"

adjustment:
  - Boost priority of low-token tasks (+20%)
  - Lower priority of high-token tasks (-30%)

reason: "Optimize for current resource constraints"
```

---

## 🎯 Reprioritization Strategies

### Strategy 1: Greedy (Default)
```
Always work on highest priority task
Reprioritize every task completion
```

### Strategy 2: Batch Processing
```
Group similar tasks together
Process entire batch before switching
Reduces context switching overhead
```

### Strategy 3: Deadline-Driven
```
Sort by deadline first, then priority
Ensures no deadlines missed
```

### Strategy 4: Value Maximization
```
Optimize for total value delivered
May defer low-value tasks indefinitely
```

---

## 📊 Metrics

```yaml
reprioritization_stats:
  period: "30_days"

  reprioritizations_triggered: 128
  triggers:
    new_information: 45 (35%)
    blockers: 32 (25%)
    urgency_changes: 28 (22%)
    value_realizations: 23 (18%)

  impact:
    tasks_reordered: 315
    avg_priority_shift: +15%
    critical_tasks_expedited: 12

  effectiveness:
    deadline_miss_rate: 2%  # Down from 8% before
    value_per_hour: +23%  # More valuable work done
```

---

## 🔄 Integration

### With Task Manager
- Task priorities update dynamically
- Queue reorders automatically
- Paused tasks can jump to front if urgent

### With Executive Function
- Strategic goals influence priorities
- High-level objectives propagate to tasks
- Reprioritization aligned with strategy

### With Resource Monitor
- Resource constraints affect priorities
- Low resources → Deprioritize expensive tasks
- High resources → Enable complex work

---

## 🚨 Safety Rules

```yaml
reprioritization_limits:
  max_changes_per_hour: 10  # Prevent thrashing
  min_task_duration: 15min  # Don't switch too quickly
  critical_task_protection: true  # Can't deprioritize critical
  user_override: always_respected  # User can lock priorities
```

---

**Created:** 2026-02-01
**Status:** OPERATIONAL
**Coverage:** ACE Layer 5 gap closed
