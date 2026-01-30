# Workflow Pattern Miner

**Purpose:** Auto-detect repetitive workflows for tool creation
**Created:** 2026-01-30
**Status:** OPERATIONAL
**Type:** Automation discovery layer
**Ratio:** 2.00 (Value: 8, Effort: 3, Risk: 1)

---

## Overview

Detect when I'm doing the same multi-step workflow repeatedly. Create tools to automate it.

---

## Core Principles

### 1. Pattern Recognition
Identify recurring workflows

### 2. Repetition Threshold
3+ occurrences trigger automation

### 3. Tool Generation
Convert patterns to scripts

### 4. Continuous Mining
Always watch for patterns

### 5. Validate ROI
Ensure automation saves time

---

## Pattern Detection

```yaml
detection_algorithm:
  1_log_actions:
    track: "Every command executed, every file edited"

  2_find_sequences:
    analyze: "Look for repeated action sequences"
    threshold: "3+ occurrences = pattern"

  3_extract_pattern:
    identify:
      - "Common steps"
      - "Variable parts"
      - "Fixed parts"

  4_calculate_roi:
    time_saved: "Repetitions × time_per_manual"
    tool_creation_cost: "Estimated effort"
    roi: "time_saved / creation_cost"

  5_propose_automation:
    if_roi: "> 3.0"
    action: "Suggest tool creation"
```

---

## Example Pattern

```yaml
detected_pattern:
  name: "Release worktree after PR"
  occurrences: 12 (in last month)

  steps:
    1: "gh pr create"
    2: "cd to worktree"
    3: "git add -A && git commit && git push"
    4: "cd to base repo"
    5: "git checkout develop"
    6: "Update worktrees.pool.md (mark FREE)"

  time_per_manual: "3 minutes"
  total_time_spent: "36 minutes"

  automation_proposal:
    tool: "worktree-release-all.ps1"
    creation_effort: "10 minutes"
    roi: "36/10 = 3.6" (GOOD)

  action: "Create tool, add to toolbox"
```

---

## Integration

### With Habit Formation
- **Workflow Miner** detects patterns
- **Habit Formation** automates them
- Detection → automation

### With Meta-Optimizer
- **Workflow Miner** finds inefficiencies
- **Meta-Optimizer** improves processes
- Discover → optimize

---

**Status:** ACTIVE
**Goal:** Zero repeated manual workflows
**Principle:** "Automate repetition"
