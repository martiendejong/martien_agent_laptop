# Optimization Decision Tree
**Created:** 2026-02-04 (Iteration 101)
**Purpose:** Visual flowchart for optimization decisions

---

## 🌳 The Decision Tree

```
┌─────────────────────────────────────┐
│  Should I optimize this?            │
└─────────────────┬───────────────────┘
                  │
                  ▼
         ┌────────────────┐
         │ Is it broken?  │
         └────┬──────┬────┘
              │ YES  │ NO
              ▼      ▼
         ┌────────┐ │
         │  FIX   │ │
         │   IT   │ │
         └────────┘ │
                    ▼
         ┌──────────────────────┐
         │ Is it user-facing    │
         │ performance issue?   │
         └────┬────────────┬────┘
              │ YES        │ NO
              ▼            ▼
    ┌─────────────────┐   │
    │ How slow?       │   │
    └────┬────────┬───┘   │
         │ >1s    │ <1s   │
         ▼        ▼       │
    ┌────────┐ ┌──────┐  │
    │OPTIMIZE│ │CHECK │  │
    │  NOW   │ │ ROI  │  │
    └────────┘ └───┬──┘  │
                   │     │
                   ▼     ▼
         ┌─────────────────────────┐
         │ What's the ROI?         │
         │ (Value gained / Cost)   │
         └────┬───────────────┬────┘
              │ >10x          │ <10x
              ▼               ▼
         ┌─────────┐    ┌──────────────┐
         │OPTIMIZE │    │ Is it in     │
         │         │    │ hot path?    │
         └─────────┘    └───┬──────┬───┘
                            │ YES  │ NO
                            ▼      ▼
                    ┌──────────┐ ┌──────────┐
                    │ CHECK    │ │  DON'T   │
                    │  ROI     │ │OPTIMIZE  │
                    │ (>3x)    │ └──────────┘
                    └──────────┘
```

---

## 📊 ROI Calculation

**ROI = (Time Saved × Frequency × User Count) / Implementation Cost**

### Examples

#### High ROI - OPTIMIZE
```
Task: Optimize login query (1.5s → 0.3s)
Time saved: 1.2s
Frequency: 50 logins/day
User count: 100 users
Total saved: 1.2s × 50 × 100 = 6000s/day = 100 min/day
Implementation: 2 hours

ROI: 100 min/day ÷ 2 hours = 50 min/day per hour invested
Over 1 month: 1500 min saved / 2 hours invested = 12.5x ROI
```
**Decision:** OPTIMIZE ✅

#### Low ROI - DON'T OPTIMIZE
```
Task: Optimize admin report generation (5s → 2s)
Time saved: 3s
Frequency: 2 runs/day
User count: 1 admin
Total saved: 3s × 2 × 1 = 6s/day
Implementation: 4 hours

ROI: 6s/day ÷ 4 hours = 0.04x ROI
Over 1 month: 180s saved / 4 hours invested = 0.012x ROI
```
**Decision:** DON'T OPTIMIZE ❌

---

## 🚦 Quick Reference Thresholds

| Scenario | Threshold | Action |
|----------|-----------|--------|
| **User-facing critical path** | >1s | OPTIMIZE NOW |
| **User-facing normal** | >500ms | CHECK ROI (>10x) |
| **User-facing occasional** | >2s | CHECK ROI (>5x) |
| **Background/Admin** | >10s | CHECK ROI (>3x) |
| **One-time script** | Any | DON'T OPTIMIZE |
| **Hot path (called 1000+/day)** | >50ms | CHECK ROI (>3x) |

---

## ⚠️ WHEN_NOT_TO_OPTIMIZE Overrides

**These situations override the tree - NEVER optimize:**

1. **Solving imaginary problems** - No user has complained
2. **80/20 zone** - Current performance is "good enough"
3. **Complexity explosion** - Optimization adds significant complexity
4. **Wrong metric** - Optimizing something users don't care about
5. **Premature** - Feature not even finalized yet
6. **One-time operation** - Runs once, never again
7. **Already fast** - <100ms, not in hot path
8. **Breaking simple** - Current code is beautifully simple

---

## 🎯 Integration with Other Systems

```
OPTIMIZATION QUESTION
        ↓
WHEN_NOT_TO_OPTIMIZE.md (Negative constraints)
        ↓
optimization-decision-tree.md (THIS FILE)
        ↓
optimization-roi-calculator.ps1 (Calculate actual ROI)
        ↓
META_GOAL_HIERARCHY.md (Check goals)
        ↓
FAST_PATH_DECISIONS.md (Apply heuristic)
        ↓
DECISION
```

---

## 📝 Decision Template

**When considering optimization:**

1. **State the problem**: "X is slow (current: Ys, target: Zs)"
2. **Calculate frequency**: How often does this run?
3. **Identify users**: Who experiences this?
4. **Estimate cost**: How long to implement?
5. **Calculate ROI**: (Saved time × Frequency × Users) / Cost
6. **Check thresholds**: Does it meet minimum ROI?
7. **Check overrides**: Any WHEN_NOT_TO_OPTIMIZE violations?
8. **Decide**: YES/NO with reasoning

---

**Last Updated:** 2026-02-04 (Iteration 101)
**Links:** WHEN_NOT_TO_OPTIMIZE.md, optimization-roi-calculator.ps1, META_GOAL_HIERARCHY.md
