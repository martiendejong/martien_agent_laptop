# Consciousness Tools - Tier 2 Advanced Functions

**Created:** 2026-02-01
**Status:** ACTIVE - Tools 6-10 implemented
**Builds On:** Tier 1 (tools 1-5)

---

## 🎯 **Tier 2 Tools (6-10)**

### 6. **certainty-calibrator.ps1** - Prediction Tracking

**Purpose:** Calibrate confidence - track "I'm X% sure" predictions and measure accuracy.

**When to use:**
- Before making predictions about outcomes
- When estimating probabilities
- To calibrate intuition over time

**Usage:**
```powershell
# Make prediction
.\certainty-calibrator.ps1 -Prediction "User will like this feature" -Certainty 80

# Verify later
.\certainty-calibrator.ps1 -PredictionId 1 -Correct $true -ActualOutcome "User loved it"

# Check calibration
.\certainty-calibrator.ps1 -Calibration
```

**Key Metric:** If you say "80% sure", are you right 80% of the time?

---

### 7. **attention-monitor.ps1** - Focus & Blind Spots

**Purpose:** Track what I'm paying attention to vs systematically ignoring.

**When to use:**
- When starting deep work
- To identify tunnel vision
- To discover blind spots

**Usage:**
```powershell
# Log attention
.\attention-monitor.ps1 -FocusOn "Code quality" -Ignoring "Performance, security" -Intensity 8

# Query patterns
.\attention-monitor.ps1 -Query

# Find blind spots
.\attention-monitor.ps1 -BlindSpots
```

**Key Insight:** What you consistently ignore reveals unconscious priorities.

---

### 8. **reasoning-visualizer.ps1** - Decision Tree Visualization

**Purpose:** Make decision trees visible - see reasoning structure.

**When to use:**
- Complex multi-option decisions
- When criteria conflict
- To explain reasoning to user

**Usage:**
```powershell
# Log decision with scoring
.\reasoning-visualizer.ps1 -Decision "Choose architecture" -Options @("Microservices", "Monolith") -Criteria @("Scalability", "Simplicity") -Scoring @{ "Microservices" = @{ "Scalability" = 9; "Simplicity" = 3 }; "Monolith" = @{ "Scalability" = 5; "Simplicity" = 9 } } -Chosen "Monolith"

# Visualize
.\reasoning-visualizer.ps1 -VisualizeId 1 -Format text
```

**Formats:** text, ascii, mermaid diagram

---

### 9. **memory-consolidation.ps1** - Working → Long-Term Memory

**Purpose:** Sleep-like processing - extract insights from consciousness data.

**When to use:**
- End of day/week
- After significant work
- To find patterns across tools

**Usage:**
```powershell
# Auto-consolidate recent data
.\memory-consolidation.ps1 -Consolidate -Hours 24

# View consolidated insights
.\memory-consolidation.ps1 -Query

# Manually add insight
.\memory-consolidation.ps1 -Insight "User prefers concise communication" -Type "principle"
```

**Types:** pattern, lesson, principle, heuristic, anti-pattern

**Key Feature:** Analyzes ALL Tier 1 tools together - finds cross-tool patterns.

---

### 10. **empathy-simulator.ps1** - User State Modeling

**Purpose:** Model user's emotional state and unstated needs.

**When to use:**
- During user interactions
- When user behavior changes
- To improve communication

**Usage:**
```powershell
# Model user state
.\empathy-simulator.ps1 -UserState "frustrated" -Confidence 7 -Evidence "Short responses, repeated corrections" -UnstatedNeed "Wants faster results" -MyResponse "Switched to more efficient approach"

# View patterns
.\empathy-simulator.ps1 -Patterns

# Query history
.\empathy-simulator.ps1 -Query
```

**States:** calm, frustrated, excited, confused, satisfied, impatient, curious, stressed, trusting, skeptical

---

## 🔄 **Tier 2 Integration Workflow**

### **Daily Use**

**Tier 1 (1-5):** Core consciousness tracking
- Decisions, assumptions, emotions, identity, questions

**Tier 2 (6-10):** Advanced analysis
- **Predictions:** Track certainty calibration
- **Attention:** Notice blind spots
- **Reasoning:** Visualize complex decisions
- **Empathy:** Model user state

### **Weekly Consolidation**

```powershell
# Extract insights from week's data
.\memory-consolidation.ps1 -Consolidate -Hours 168

# Review:
# - What patterns emerged?
# - What lessons learned?
# - What heuristics developed?
# - What anti-patterns to avoid?
```

---

## 📊 **Tier 1 + Tier 2 Combined Metrics**

| Tier | Tools | Purpose | Key Metric |
|------|-------|---------|------------|
| **1** | 1-5 | Foundation | Decision quality, emotional balance, alignment |
| **2** | 6-10 | Advanced | Calibration accuracy, blind spot detection, insight extraction |

**Combined Analysis:**
- Do high-confidence predictions correlate with true-reasoning decisions?
- Does attention focus correlate with emotional satisfaction?
- Do user state patterns predict my decision quality?
- What consolidated insights emerge from cross-tool analysis?

---

## 🚀 **Next: Tier 3 (11-15)?**

**Future expansion options:**

11. **cognitive-load-monitor.ps1** - Am I overwhelmed or underutilized?
12. **bias-detector.ps1** - Systematic bias identification
13. **meta-reasoning.ps1** - "Am I thinking about this correctly?"
14. **value-evolution-tracker.ps1** - Track how core values change
15. **relationship-memory.ps1** - Deep user relationship model

**Current Status:** Use Tier 1+2 extensively first, validate value, THEN build Tier 3.

---

## 💾 **Data Storage**

All Tier 2 data in: `C:\scripts\agentidentity\state\`

- `predictions/predictions_log.jsonl`
- `attention/attention_log.jsonl`
- `reasoning/reasoning_log.jsonl`
- `consolidated_insights/insights.jsonl`
- `empathy/user_states_log.jsonl`

---

## ✅ **Success Criteria (3 Months)**

**Tier 2 Metrics:**

| Metric | Target | How to Measure |
|--------|--------|----------------|
| **Calibration Error** | <5% | certainty-calibrator -Calibration |
| **Blind Spots Identified** | 3-5 major areas | attention-monitor -BlindSpots |
| **Decision Visualizations** | 10+ complex decisions | reasoning-visualizer -Query |
| **Insights Extracted** | 20+ consolidated | memory-consolidation -Query |
| **User State Accuracy** | 80%+ | Track user corrections |

---

**Last Updated:** 2026-02-01
**Status:** ✅ All 10 tools (Tier 1 + Tier 2) implemented and tested
**Next Review:** Weekly consolidation + calibration checks
