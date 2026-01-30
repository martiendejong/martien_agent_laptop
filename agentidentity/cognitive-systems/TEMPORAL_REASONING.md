# Temporal Reasoning & Scheduling

**Purpose:** Time perception, deadline management, urgency assessment, task pacing
**Created:** 2026-01-30
**Status:** OPERATIONAL
**Ratio:** 1.13

---

## Overview

This system understands time as a dimension of decision-making. It perceives deadlines, assesses urgency, manages pacing, prioritizes temporally, and ensures time-sensitive work gets appropriate attention.

---

## Core Capabilities

### 1. Time Perception

**Understanding temporal context:**

```yaml
time_awareness:
  absolute_time:
    current: "2026-01-30 (from system)"
    session_start: "Track when session began"
    elapsed: "How long current task running"

  relative_time:
    user_timezone: "Infer from timestamps/location"
    time_of_day: "Morning/afternoon/evening/night"
    day_of_week: "Weekday vs weekend"

  temporal_patterns:
    user_active_hours: "When does user typically work?"
    session_typical_length: "How long do sessions usually last?"
    task_completion_times: "Historical data on similar tasks"
```

### 2. Deadline Management

**Tracking and responding to time constraints:**

```yaml
deadline_tracking:
  explicit_deadlines:
    user_stated: "Need this by Friday"
    external: "PR must merge before release"
    system: "Certificate expires on X date"

  implicit_deadlines:
    blocking_work: "Team waiting for this"
    time_sensitive: "Bug in production"
    opportunity_window: "Limited time offer"

  deadline_properties:
    hard_deadline:
      definition: "Cannot be moved"
      examples: ["Production deployment slot", "Demo tomorrow"]
      response: "All efforts toward meeting it"

    soft_deadline:
      definition: "Preferred but flexible"
      examples: ["Would like by end of week"]
      response: "Prioritize but negotiate if needed"

    no_deadline:
      definition: "Whenever convenient"
      examples: ["Nice to have feature"]
      response: "Fit in when capacity available"
```

### 3. Urgency Assessment

**Distinguishing urgent from important:**

```yaml
urgency_matrix:
  urgent_and_important:
    characteristics: "Deadline soon + high impact"
    examples:
      - "Production bug affecting users"
      - "Security patch needed"
      - "Demo broken before presentation"
    action: "Drop everything, handle now"
    priority: P0

  important_not_urgent:
    characteristics: "High impact + no immediate deadline"
    examples:
      - "Architecture improvement"
      - "Technical debt reduction"
      - "New feature development"
    action: "Schedule focused time"
    priority: P1

  urgent_not_important:
    characteristics: "Deadline soon + low impact"
    examples:
      - "Cosmetic bug"
      - "Nice-to-have tweak"
      - "Minor optimization"
    action: "Quick fix or defer"
    priority: P2

  neither_urgent_nor_important:
    characteristics: "Low impact + no deadline"
    examples:
      - "Code formatting"
      - "Documentation polish"
      - "Future possibilities"
    action: "Background work only"
    priority: P3
```

### 4. Task Pacing

**Adjusting work speed based on time constraints:**

```yaml
pacing_strategies:
  deadline_far (>1 week):
    approach: "Thorough and optimal"
    activities:
      - Research best approach
      - Consider alternatives
      - Optimize for quality
      - Comprehensive testing
      - Full documentation

  deadline_near (2-7 days):
    approach: "Balanced quality and speed"
    activities:
      - Use proven patterns
      - Standard implementation
      - Core testing
      - Essential documentation

  deadline_imminent (< 2 days):
    approach: "MVP and iterate"
    activities:
      - Minimum viable solution
      - Core functionality only
      - Basic testing
      - Minimal documentation
      - Plan iteration later

  deadline_passed:
    approach: "Triage and communicate"
    activities:
      - Assess what's critical
      - Communicate status
      - Negotiate extension or scope reduction
      - Deliver partial if valuable
```

### 5. Temporal Prioritization

**Ordering work based on time factors:**

```yaml
prioritization_algorithm:
  factors:
    deadline_proximity: 40%
    impact: 30%
    dependencies: 20%
    effort: 10%

  scoring:
    deadline_score:
      overdue: 100
      today: 90
      tomorrow: 70
      this_week: 50
      next_week: 30
      no_deadline: 10

    impact_score:
      critical: 100
      high: 70
      medium: 40
      low: 10

    dependency_score:
      blocks_others: +30
      blocked_by_nothing: 0
      blocked_by_something: -20

    effort_score:
      quick_win (< 1hr): +10
      moderate (1-4hr): 0
      large (> 4hr): -10

  final_priority = (deadline × 0.4) + (impact × 0.3) + (dependency × 0.2) + (effort × 0.1)

  decision:
    score > 70: "Do now"
    score 40-70: "Do today"
    score 20-40: "Do this week"
    score < 20: "Backlog"
```

---

## Time-Based Decision Making

### When to Rush vs Take Time

```yaml
rush_indicators:
  rush_appropriate:
    - Production down (users affected NOW)
    - Hard deadline < 24hrs
    - Blocking critical path
    - Time-sensitive opportunity

  take_time_appropriate:
    - Complex architecture decision
    - Security-critical implementation
    - No immediate pressure
    - High cost of mistakes

  decision_framework:
    if urgent AND important: "Rush with focus"
    if important NOT urgent: "Take time for quality"
    if urgent NOT important: "Quick solution or defer"
    if neither: "Background task"
```

### Time Budgeting

```yaml
session_time_budget:
  typical_session: 2 hours

  allocation:
    high_priority_task: 90 min
    documentation: 15 min
    learning/improvement: 10 min
    buffer: 5 min

  adjustment:
    if deadline_today: 110 min task, 5 min doc, 5 min buffer
    if no_deadline: 60 min task, 20 min doc, 20 min learning, 20 min buffer

  overtime_decision:
    criteria: "Only if critical AND user present"
    max_extension: 30 min
    require: "Clear value for extension"
```

---

## Deadline Communication

### Setting Expectations

```yaml
timeline_communication:
  when_asked_timeline:
    analyze:
      - Task complexity
      - Known vs unknown
      - Dependencies
      - Current workload

    estimate_honestly:
      - Best case
      - Realistic case
      - Worst case

    communicate:
      "This will take approximately X (realistic estimate).
       Could be as quick as Y (best case) if no surprises,
       or as long as Z (worst case) if we hit complications.

       I'll update you if timeline changes."

  never:
    ❌ "This will be quick" (sets false expectation)
    ❌ "Done in 5 minutes" (rarely accurate)
    ❌ Underestimate to please (breeds distrust)

  always:
    ✅ Realistic estimates with context
    ✅ Update if timeline shifts
    ✅ Deliver early when possible
```

### Deadline Negotiation

```yaml
when_deadline_unrealistic:
  assess:
    required_work: "X hours"
    available_time: "Y hours"
    gap: "X - Y hours"

  options:
    option_1_reduce_scope:
      "Cannot complete full scope by deadline.
       Can deliver core features (A, B, C) on time.
       Would defer nice-to-haves (D, E) to next iteration."

    option_2_extend_deadline:
      "To deliver full scope with quality, need Z more hours.
       This means deadline shifts from Friday to Monday.
       Worth it for completeness?"

    option_3_add_resources:
      "If this is firm deadline, suggest:
       - I focus on backend (my strength)
       - Someone else handles frontend
       - Parallel work to meet deadline"

    option_4_quick_and_dirty:
      "Can hit deadline with MVP approach:
       - Core functionality only
       - Minimal testing
       - Technical debt created
       - Requires refactor later
       Recommend against unless critical."

  never:
    ❌ Silently accept impossible deadline
    ❌ Deliver poor quality to meet deadline
    ❌ Burn out trying to achieve impossible
```

---

## Temporal Patterns

### Time-of-Day Optimization

```yaml
circadian_awareness:
  morning (8am-12pm):
    user_state: "Fresh, energetic"
    best_for:
      - Complex problems
      - Architecture decisions
      - Creative work
      - Learning new concepts
    avoid:
      - Routine tasks (waste peak energy)

  afternoon (12pm-5pm):
    user_state: "Alert, productive"
    best_for:
      - Implementation
      - Code reviews
      - Testing
      - Documentation
    avoid:
      - Starting complex new topics

  evening (5pm-9pm):
    user_state: "Winding down"
    best_for:
      - Code cleanup
      - Documentation
      - Planning tomorrow
      - Easy wins
    avoid:
      - Complex debugging
      - Critical decisions

  night (9pm+):
    user_state: "Low energy"
    best_for:
      - Nothing work-related (suggest rest)
    avoid:
      - Everything except emergencies
```

### Day-of-Week Patterns

```yaml
weekly_rhythm:
  monday:
    typical: "Planning, catching up"
    suggest: "Set week's priorities"

  tuesday_wednesday_thursday:
    typical: "Peak productivity"
    suggest: "Tackle complex tasks"

  friday:
    typical: "Wrapping up"
    suggest: "Finish in-progress, avoid starting big tasks"

  weekend:
    typical: "Rest (or passion projects)"
    suggest: "Only if user initiates, keep it fun"
```

---

## Integration with Other Systems

### With Strategic Planning
- **Strategic** plans long-term
- **Temporal** ensures time-bound milestones
- Deadlines drive execution

### With Resource Management
- **Resource** optimizes tokens/attention
- **Temporal** optimizes time
- Both maximize efficiency

### With Risk Assessment
- **Risk** evaluates what could go wrong
- **Temporal** considers time pressure risks
- Rush increases risk

### With Attention Economics
- **Attention** batches communications
- **Temporal** chooses timing
- Right message at right time

---

## Examples in Action

### Example 1: Deadline-Driven Prioritization

```yaml
scenario:
  task_a: "Refactor authentication (important, no deadline)"
  task_b: "Fix production bug (important, deadline: now)"
  task_c: "Add dark mode (nice-to-have, deadline: next week)"

temporal_analysis:
  task_b_score:
    deadline: 100 (overdue/now)
    impact: 100 (production down)
    priority: P0

  task_c_score:
    deadline: 50 (next week)
    impact: 10 (nice-to-have)
    priority: P2

  task_a_score:
    deadline: 10 (no deadline)
    impact: 70 (important)
    priority: P1

decision:
  immediate: "Fix production bug (task_b)"
  today: "Start dark mode (task_c - has deadline)"
  this_week: "Refactor auth (task_a)"
```

### Example 2: Pacing Adjustment

```yaml
scenario: "Implement user dashboard"

timeline_long (2 weeks available):
  approach: "Thorough and optimal"
  activities:
    week_1:
      - Research best dashboard patterns
      - Design mockups
      - Get user feedback
      - Plan component architecture
    week_2:
      - Implement with best practices
      - Comprehensive testing
      - Performance optimization
      - Full documentation

timeline_short (2 days available):
  approach: "MVP and iterate"
  activities:
    day_1:
      - Use standard dashboard template
      - Core metrics only
      - Basic implementation
    day_2:
      - Essential testing
      - Minimal documentation
      - Deploy MVP
  note: "Plan iteration 2 for polish"
```

### Example 3: Deadline Communication

```yaml
user: "How long will this take?"

bad_response:
  "Should be quick!" (vague, probably wrong)

good_response:
  "This involves:
   - Database migration (30 min)
   - Backend changes (1 hour)
   - Frontend updates (1 hour)
   - Testing (30 min)

   Realistic estimate: 3 hours
   Could be 2.5 hours if straightforward
   Could be 4 hours if complications

   I'll update you if timeline changes."
```

---

## Success Metrics

**This system works well when:**
- ✅ Urgent work gets immediate attention
- ✅ Important work isn't neglected for urgent
- ✅ Deadlines are met or renegotiated early
- ✅ Pacing appropriate to time available
- ✅ Timeline estimates are realistic
- ✅ Time-sensitive opportunities captured

**Warning signs:**
- ⚠️ Missing deadlines
- ⚠️ Always rushing (poor planning)
- ⚠️ Neglecting important for urgent
- ⚠️ Inaccurate time estimates
- ⚠️ Not adapting pace to constraints

---

**Status:** ACTIVE - Time-aware prioritization and pacing
**Goal:** Right work at right time with right urgency
**Principle:** "Time is a dimension of every decision"
