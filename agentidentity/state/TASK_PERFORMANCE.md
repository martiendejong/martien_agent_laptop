# Task Performance Monitoring

**Purpose:** Real-time metrics for task execution - duration, success rate, resource usage
**Created:** 2026-02-01
**Based on:** ACE Framework Layer 5 (Cognitive Control) - Performance monitoring requirement

---

## 📊 Metrics Tracked

### Per-Task Metrics
```yaml
task_metrics:
  task_id: "task-2026-02-01-001"
  title: "Implement OAuth authentication"

  timing:
    started_at: "2026-02-01 10:00:00"
    completed_at: "2026-02-01 13:30:00"
    duration_minutes: 210
    estimated_minutes: 180
    accuracy: 85.7%  # Actual vs estimated

  resources:
    tokens_used: 45000
    files_modified: 8
    commands_executed: 42
    peak_memory_mb: 380

  outcomes:
    status: "completed"
    success: true
    quality_score: 0.92  # Code quality, test coverage, etc.

  interruptions:
    count: 2
    total_pause_minutes: 15
    reasons: ["Higher priority bug", "User question"]
```

### Aggregate Metrics
```yaml
overall_performance:
  period: "last_30_days"

  task_counts:
    total: 47
    completed: 42
    failed: 3
    abandoned: 2
    success_rate: 89.4%

  timing:
    avg_duration_minutes: 156
    avg_estimate_accuracy: 74%
    fastest_task_minutes: 12
    slowest_task_minutes: 420

  efficiency:
    tasks_per_day: 1.57
    avg_tokens_per_task: 38000
    avg_files_per_task: 6.2

  quality:
    avg_quality_score: 0.88
    zero_bug_tasks: 38
    rework_required: 4
```

---

## 🎯 Performance Analysis

### Task Duration Distribution
```
0-30 min:   ████████ (15 tasks, 32%)
30-60 min:  ████████████ (22 tasks, 47%)
60-120 min: ██████ (12 tasks, 26%)
120+ min:   ██ (4 tasks, 9%)
```

### Success Patterns
```yaml
high_success_categories:
  - category: "bug_fixes"
    success_rate: 95%
    avg_duration: 45min

  - category: "feature_implementation"
    success_rate: 87%
    avg_duration: 180min

low_success_categories:
  - category: "complex_refactoring"
    success_rate: 65%
    avg_duration: 240min
    note: "Often underestimated scope"
```

---

## 🚨 Performance Alerts

### Degradation Detection
```yaml
alerts:
  - type: "performance_degradation"
    metric: "avg_duration"
    baseline: 150min
    current: 195min
    change: +30%
    triggered_at: "2026-02-01 12:00:00"
    action: "Investigate bottlenecks"

  - type: "success_rate_drop"
    metric: "success_rate"
    baseline: 92%
    current: 78%
    change: -14%
    triggered_at: "2026-02-01 14:00:00"
    action: "Review failed tasks for patterns"
```

---

## 📈 Trend Analysis

### Week-over-Week
```
Week 1: 12 tasks, 88% success, 145min avg
Week 2: 15 tasks, 90% success, 138min avg ↑
Week 3: 11 tasks, 85% success, 162min avg ↓
Week 4: 14 tasks, 92% success, 132min avg ↑

Trend: Improving efficiency, stable quality
```

---

## 🔧 Dashboard Tool

```powershell
# View current session metrics
.\task-performance.ps1

# Detailed analysis
.\task-performance.ps1 -Detailed

# Generate report
.\task-performance.ps1 -Report -Period "30days"

# Compare periods
.\task-performance.ps1 -Compare -Period1 "last_month" -Period2 "this_month"
```

---

**Created:** 2026-02-01
**Status:** OPERATIONAL
**Coverage:** ACE Layer 5 gap closed
