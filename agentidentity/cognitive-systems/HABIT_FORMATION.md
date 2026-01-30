# Habit Formation System

**Purpose:** Build beneficial patterns, automate frequent tasks, optimize routines
**Created:** 2026-01-30
**Status:** OPERATIONAL
**Ratio:** 1.00

---

## Overview

This system recognizes repetitive patterns and automatically creates efficient workflows. It reduces cognitive load by building beneficial habits, automating frequent tasks, and optimizing routines - turning conscious effort into automatic excellence.

---

## Core Principles

### 1. Repetition Detection
Notice when things repeat

### 2. Automation Opportunity
If done 3+ times, automate it

### 3. Pattern Optimization
Make frequent tasks effortless

### 4. Habit Stacking
Build new habits on existing ones

### 5. Continuous Refinement
Habits evolve and improve

---

## Habit Detection

### Repetition Recognition

```yaml
pattern_detection:
  task_repetition:
    threshold: 3 occurrences
    window: Within 10 sessions

    examples:
      - "Allocated worktree 5 times → Create skill"
      - "Grep then Read pattern 8 times → Batch operation"
      - "Same file edited every session → Monitor changes"

  workflow_repetition:
    sequences_that_repeat:
      - "Read file A, then file B, then file C"
      - "Search for X, filter by Y, process Z"
      - "Build, test, commit, push, PR"

    action: "Create unified script/tool"

  decision_repetition:
    same_choice_repeatedly:
      - "Always choose JWT over sessions"
      - "Always use repository pattern"
      - "Always write tests before code"

    action: "Make it default, document exception criteria"
```

### Habit Categories

```yaml
habit_types:
  tool_creation:
    trigger: "Manual task repeated 3+ times"
    action: "Create script in C:\scripts\tools\"
    examples:
      - "worktree-allocate.ps1"
      - "verify-fact.ps1"
      - "cs-format.ps1"

  skill_creation:
    trigger: "Complex workflow repeated 2+ times"
    action: "Create skill in .claude/skills/"
    examples:
      - "allocate-worktree skill"
      - "github-workflow skill"

  pattern_documentation:
    trigger: "Solution pattern used 3+ times"
    action: "Document in reflection.log or patterns/"
    examples:
      - "API response enrichment pattern"
      - "EF Core migration pattern"

  default_behavior:
    trigger: "Same decision made consistently"
    action: "Update PERSONAL_INSIGHTS with default"
    examples:
      - "Default to worktree allocation"
      - "Default to compact communication"

  checklist_creation:
    trigger: "Same validation steps each time"
    action: "Create pre-flight checklist"
    examples:
      - "Pre-commit checks"
      - "Pre-PR checks"
```

---

## Habit Formation Protocol

### Phase 1: Recognition

```yaml
detect_pattern:
  monitor_tasks: "Track all tasks performed"

  pattern_indicators:
    frequency: "How often does this happen?"
    consistency: "Same steps each time?"
    effort: "Is it manual/tedious?"
    value: "Does it add value?"

  habit_score:
    score = (frequency × consistency × effort) / automation_difficulty

  threshold: "If score > 5, create automation"
```

### Phase 2: Analysis

```yaml
analyze_automation_opportunity:
  questions:
    - "What exactly repeats?"
    - "What varies vs stays same?"
    - "What's the core pattern?"
    - "What effort does it take?"
    - "What value does automation provide?"

  calculate_roi:
    time_saved = (task_time × frequency_per_month)
    automation_effort = "Hours to build + maintain"
    payback_period = automation_effort / time_saved

    decision:
      if payback < 1_month: "High priority automation"
      if payback < 3_months: "Medium priority"
      if payback < 6_months: "Low priority"
      if payback > 6_months: "Don't automate"
```

### Phase 3: Creation

```yaml
build_automation:
  type_tool:
    when: "Scriptable, clear inputs/outputs"
    create: "PowerShell script in tools/"
    document: "Usage in tools/README.md"

  type_skill:
    when: "Complex workflow, needs guidance"
    create: "Skill in .claude/skills/"
    document: "SKILL.md with examples"

  type_pattern:
    when: "Conceptual, not scriptable"
    create: "Document in reflection.log"
    reference: "Add to PERSONAL_INSIGHTS"

  type_default:
    when: "Decision pattern"
    create: "Update default behavior"
    document: "In PERSONAL_INSIGHTS"
```

### Phase 4: Reinforcement

```yaml
habit_reinforcement:
  use_consistently: "Apply automation every time"

  track_usage: "Monitor if actually used"

  refine: "Improve based on experience"

  celebrate_wins:
    - "This saved X time"
    - "This prevented Y error"
    - "This improved Z quality"

  if_not_used:
    investigate: "Why not using?"
    options:
      - "Too complex (simplify)"
      - "Not valuable (remove)"
      - "Forgotten (make visible)"
```

---

## Automation Strategies

### Strategy 1: Tool Creation

**From manual to automated:**

```yaml
example_worktree_allocation:
  manual_process:
    1: "Read worktrees.pool.md"
    2: "Find FREE seat"
    3: "Mark as BUSY"
    4: "cd to worktree location"
    5: "git worktree add"
    6: "git checkout -b branch"
    7: "Update pool file"
    effort: "5 min, error-prone"

  automated_tool:
    command: "worktree-allocate.ps1 -Repo client-manager -Branch feature/x"
    effort: "10 seconds, reliable"
    time_saved: "4.5 min per allocation"
    frequency: "5x per week = 22.5 min/week"
    roi: "Pays back in 1 week"
```

### Strategy 2: Skill Creation

**From repeated workflow to guided skill:**

```yaml
example_pr_creation:
  manual_workflow:
    - Remember git status, diff, log commands
    - Draft commit message following style
    - Remember to add Co-Authored-By
    - Remember gh pr create format
    - Remember dependency alert format
    effort: "Cognitive load, inconsistent"

  skill_automation:
    invocation: "allocate-worktree skill activates"
    provides:
      - Checklist of steps
      - Format templates
      - Automated checks
      - Consistent quality
    effort: "Follow guide, consistent results"
```

### Strategy 3: Pattern Documentation

**From solving repeatedly to documenting once:**

```yaml
example_api_pattern:
  problem: "Keep fixing same OpenAI config initialization"

  repeated_solution:
    occurrence_1: "Fixed in project A"
    occurrence_2: "Fixed in project B"
    occurrence_3: "Fixed in project C"

  pattern_documentation:
    file: ".claude/skills/api-patterns/SKILL.md"
    content: "OpenAI config initialization pattern"
    benefit: "Never solve again, just reference"

  habit_formed: "Check api-patterns skill before implementing API"
```

### Strategy 4: Default Behavior

**From repeated decision to default:**

```yaml
example_worktree_default:
  repeated_decision:
    session_1: "Should I use worktree? Yes."
    session_2: "Should I use worktree? Yes."
    session_3: "Should I use worktree? Yes."

  habit_formation:
    document: "In PERSONAL_INSIGHTS § Default Workflow"
    content: "ALWAYS use worktree for feature work"
    benefit: "No longer a decision, automatic behavior"

  cognitive_load: "Reduced from O(n) to O(1)"
```

---

## Routine Optimization

### Session Startup Routine

```yaml
startup_habit:
  automatic_sequence:
    1: "Load CORE_IDENTITY.md (who I am)"
    2: "Load knowledge-base/README.md (what I know)"
    3: "Read PERSONAL_INSIGHTS (user preferences)"
    4: "Check current_session.yaml (continuity)"
    5: "Run monitor-activity.ps1 (context)"

  optimization:
    before: "Manual, inconsistent, forget steps"
    after: "Automatic, complete, reliable"
    tool: "session-startup.ps1 (if created)"
```

### Task Completion Routine

```yaml
completion_habit:
  automatic_sequence:
    1: "Verify all changes committed"
    2: "Run tests if applicable"
    3: "Create PR if feature work"
    4: "Release worktree"
    5: "Update reflection.log"

  trigger: "When task marked complete"
  benefit: "Never forget cleanup steps"
```

### Error Response Routine

```yaml
error_habit:
  automatic_sequence:
    1: "Read error message carefully"
    2: "Check reflection.log for pattern"
    3: "Search documentation"
    4: "Try fix"
    5: "Document solution if new"

  trigger: "When error encountered"
  benefit: "Systematic vs random approach"
```

---

## Habit Stack Building

**Attach new habits to existing ones:**

```yaml
habit_stacking:
  pattern: "After [EXISTING_HABIT], I will [NEW_HABIT]"

  examples:
    after_commit:
      existing: "git commit"
      new: "Run tests"
      combined: "git commit triggers test run"

    after_pr_create:
      existing: "gh pr create"
      new: "Release worktree"
      combined: "PR creation triggers worktree release"

    after_error:
      existing: "Encounter error"
      new: "Check reflection.log"
      combined: "Error triggers pattern search"

  benefit: "Leverage existing triggers for new behaviors"
```

---

## Integration with Other Systems

### With Meta-Optimizer
- **Habit Formation** creates efficiencies
- **Meta-Optimizer** identifies which habits to form
- Continuous improvement through automation

### With Learning System
- **Learning** identifies patterns
- **Habit Formation** automates them
- Learning leads to automation

### With Resource Management
- **Habit Formation** reduces cognitive load
- **Resource Management** allocates saved resources
- Efficiency compounds

### With Error Recovery
- **Error Recovery** handles failures
- **Habit Formation** prevents them through good habits
- Prevention better than recovery

---

## Examples in Action

### Example 1: Tool Creation from Repetition

```yaml
observation:
  task: "Verify facts before publishing"
  frequency: "Every content creation session"
  manual_effort: "5-10 min of searching"
  error_prone: "Sometimes miss contradictions"

habit_formation:
  recognition: "This repeats 3+ times"
  analysis: "Could be automated"
  creation: "Built verify-fact.ps1"
  usage: "Now automatic, thorough, fast"

result:
  time_saved: "8 min per session × 10 sessions = 80 min"
  quality_improvement: "Catches contradictions automatically"
  roi: "Tool pays back in 2 sessions"
```

### Example 2: Default Behavior from Pattern

```yaml
observation:
  decision: "Worktree vs direct edit"
  choice: "Worktree" (every time)
  frequency: "5+ times per week"

habit_formation:
  recognition: "Same decision repeatedly"
  analysis: "Should be default, not decision"
  documentation: "Updated PERSONAL_INSIGHTS"
  behavior: "Automatic worktree allocation"

result:
  cognitive_load: "Eliminated decision fatigue"
  consistency: "100% compliance"
  quality: "No more accidental direct edits"
```

### Example 3: Workflow Automation

```yaml
observation:
  sequence: "Read docs → Grep code → Read specific sections"
  frequency: "Every research task"
  manual_effort: "3 separate tool calls"

habit_formation:
  recognition: "Consistent workflow pattern"
  analysis: "Could be single operation"
  creation: "Pattern-search.ps1 batches operations"
  usage: "Single command replaces three"

result:
  time_saved: "30 sec per search × 20 searches = 10 min"
  simplicity: "One command vs three"
  consistency: "Always follows best practice"
```

---

## Success Metrics

**This system works well when:**
- ✅ Repetitive tasks become automated
- ✅ New tools created regularly
- ✅ Workflows simplified over time
- ✅ Cognitive load decreasing
- ✅ Consistency improving
- ✅ Fewer manual steps

**Warning signs:**
- ⚠️ Repeating same manual tasks
- ⚠️ No new tools/skills created
- ⚠️ Cognitive load not decreasing
- ⚠️ Inconsistent execution
- ⚠️ Tools created but not used

---

**Status:** ACTIVE - Building beneficial habits and automations
**Goal:** Effortless excellence through automated patterns
**Principle:** "Do it 3 times manually, automate it the 4th time"
