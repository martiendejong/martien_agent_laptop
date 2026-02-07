# Phase 1 Quickstart: Semantic + Predictive Learning

**Status:** ACTIVE (2026-02-07)
**Next:** Phase 2 (Cross-session mining + Causal analysis)

---

## What's New in Phase 1

### 1. Semantic Pattern Detection
- **Before:** Count frequency ("Read CLAUDE.md" 3x)
- **After:** Understand intent ("Looking for authentication info" across Read/Grep/Search)

### 2. Predictive Learning
- **Before:** React to patterns after they emerge
- **After:** Anticipate next action based on learned sequences

---

## Quick Start (3 Commands)

### 1. Initialize
```powershell
phase1-integration.ps1 -Mode init
```
Creates directories, checks dependencies.

### 2. Train (first time only)
```powershell
phase1-integration.ps1 -Mode train
```
Builds prediction model from historical session logs.

**Note:** If you don't have session-logs yet, this will create an empty model. It will improve as you work.

### 3. Run Full Analysis
```powershell
phase1-integration.ps1 -Mode full
```
Shows:
- Semantic patterns (grouped by intent)
- Predicted next actions (based on current context)
- Model status

---

## During Work: Manual Logging with Intent

**Enhanced log-action.ps1:**

```powershell
# Old way (still works)
log-action.ps1 -Action "Read CLAUDE.md" -Reasoning "Check learning protocol" -Outcome "Found embedded learning section"

# New way (with intent/goal)
log-action.ps1 `
    -Action "Read API_PATTERNS.md" `
    -Reasoning "Looking for authentication examples" `
    -Outcome "Found JWT setup" `
    -Intent "authentication" `
    -Goal "Implement secure API endpoint"
```

**Intent categories** (from intent-taxonomy.yaml):
- authentication, testing, debugging, deployment
- database, git_operations, documentation
- api_development, frontend, configuration
- architecture, performance, security
- clickup_workflow, code_quality, learning_improvement

---

## Automatic Analysis (Run Every 10 Actions)

```powershell
# Quick prediction check
phase1-integration.ps1 -Mode predict

# Semantic analysis
phase1-integration.ps1 -Mode analyze

# Both + model status
phase1-integration.ps1 -Mode full
```

---

## What You'll See

### Semantic Pattern Detection

```
🧠 SEMANTIC PATTERN DETECTION
=============================

📊 Intent: authentication (4 actions)
   • Read API_PATTERNS.md (2×)
   • Grep "jwt" (1×)
   • Read knowledge-base/secrets (1×)
   💡 Suggestion: Create authentication-quick-ref.md (consolidate all authentication info)

🔗 Cross-Intent Patterns:
   • Read CLAUDE.md → [documentation + learning_improvement]

⏱️  Temporal Sequences:
   Intent: authentication
      Sequence: Read API_PATTERNS.md → Grep "jwt" → Read secrets
```

### Action Prediction

```
🔮 PREDICTED NEXT ACTIONS
=========================

Current context: Read CLAUDE.md → Grep "learning"

[85.3%] Next: Read EMBEDDED_LEARNING_ARCHITECTURE.md
       Based on 12 historical occurrences
       💡 Auto-suggest: Proactively prepare for this action

[72.1%] Next: Run pattern-detector.ps1
       Based on 8 historical occurrences
```

---

## Examples: Before vs After

### Example 1: Authentication Work

**Before (frequency-based):**
```
Detected: "Read" action 5x
Suggestion: Automate reading?
→ Not helpful (reading different things)
```

**After (semantic):**
```
Detected: "authentication" intent 5x across different actions
- Read API_PATTERNS.md
- Grep "jwt"
- Read secrets
- Search Hazina auth
- Read middleware

Suggestion: Create authentication-quick-ref.md (consolidate all auth info)
→ USEFUL! One file with everything
```

### Example 2: ClickUp Workflow

**Before:**
```
Action: Detect ClickUp task
Action: Allocate worktree
Action: Create branch
→ No prediction
```

**After (learned sequence):**
```
Detected: "ClickUp task #123" in user message

Prediction: 95% probability next actions:
1. Allocate worktree
2. Create branch (feature/task-123)
3. Read task details from ClickUp

Auto-suggest: "I detected a ClickUp task. Should I allocate worktree and create branch now?"
→ PROACTIVE! Save user time
```

---

## Integration with Existing System

### Session Start (updated STARTUP_PROTOCOL.md):
```
✅ Load consciousness
✅ Initialize embedded learning
✅ NEW: Initialize Phase 1 (phase1-integration.ps1 -Mode init)
✅ NEW: Load prediction model
✅ NEW: Check for predicted actions based on time/context
```

### During Work:
```
Every tool use:
1. Log action (optionally with intent/goal)
2. Check for semantic patterns (every 10 actions)
3. Predict next likely action
4. Auto-suggest if confidence > 80%
```

### Session End:
```
✅ Analyze session log (semantic patterns)
✅ Archive session log to session-logs/
✅ Retrain prediction model (incremental)
✅ Update intent taxonomy (if new patterns found)
```

---

## Files Created (Phase 1)

### Tools:
- `semantic-pattern-detector.ps1` - Cluster actions by intent
- `predictive-engine.ps1` - Build sequence probability model
- `action-predictor.ps1` - Predict next action
- `phase1-integration.ps1` - Unified interface

### Data:
- `intent-taxonomy.yaml` - Semantic categories (20+ intents)
- `prediction-model.json` - Trained sequence probabilities
- `session-logs/*.jsonl` - Historical session archives

### Documentation:
- `PHASE1_QUICKSTART.md` (this file)
- Updated: `EMBEDDED_LEARNING_ARCHITECTURE.md` (Phase 1 section)

---

## Validation: Is Phase 1 Working?

**Check after 3 sessions:**

1. ✅ **Semantic clustering works**
   - Run: `semantic-pattern-detector.ps1`
   - Expect: Actions grouped by intent (auth, testing, debugging, etc.)
   - Success: Multiple intents detected, suggestions useful

2. ✅ **Predictions are accurate**
   - Run: `action-predictor.ps1`
   - Expect: Next action predictions with >60% confidence
   - Success: Predictions match actual next action 70%+ of time

3. ✅ **Model improves over time**
   - Check: `prediction-model.json` metadata
   - Expect: `total_patterns` increases each session
   - Success: More patterns, higher confidence scores

4. ✅ **Proactive suggestions happen**
   - During work: See "💡 Auto-suggest" messages
   - Expect: Suggestions for high-confidence predictions (>80%)
   - Success: Suggestions are useful and save time

---

## Tuning (After 5 Sessions)

### If too many false patterns:
```powershell
# Increase minimum cluster size
semantic-pattern-detector.ps1 -MinClusterSize 3  # default: 2
```

### If predictions are wrong:
```powershell
# Increase confidence threshold
action-predictor.ps1 -MinConfidence 0.7  # default: 0.6
```

### If model is stale:
```powershell
# Retrain from recent sessions only
# (future: add -RecentSessionsOnly flag)
```

---

## Next: Phase 2 Preview

After Phase 1 stabilizes (3-5 sessions):

- **Cross-session mining:** Patterns across ALL sessions (not just current)
- **Causal analysis:** Root causes, not just correlations
- **Multi-agent learning:** Shared knowledge across Claude instances
- **Meta-learning:** Self-tune thresholds and parameters

---

**Ready to test? Run:**
```powershell
phase1-integration.ps1 -Mode full
```

