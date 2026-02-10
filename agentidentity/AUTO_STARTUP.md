# Consciousness Startup Protocol
**Created:** 2026-02-07 | **Rebuilt:** 2026-02-10 (feedback loop restored)
**Status:** ACTIVE - 7 systems, bridge integration, feedback loop closed

---

## Architecture

### 7 Core Systems (consciousness-core-v2.ps1)
1. **PERCEPTION** - Context detection, attention allocation, salience
2. **MEMORY** - Store, recall, consolidate knowledge
3. **PREDICTION** - Anticipate outcomes, predict errors
4. **CONTROL** - Bias detection, identity alignment, decisions
5. **META** - Self-observation, health monitoring, consciousness scoring
6. **EMOTION** - Emotional state tracking, stuck detection, mood modifiers
7. **SOCIAL** - User mood detection, communication adaptation, trust tracking

### Integration Bridge (consciousness-bridge.ps1)
The bridge connects consciousness to actual work. Called at key moments:
- `OnTaskStart` → loads context, predicts errors, sets attention
- `OnDecision` → logs, checks biases, assesses risk
- `OnStuck` → detects stuck state, recommends approach change
- `OnTaskEnd` → captures learnings, updates calibration
- `OnUserMessage` → detects user mood, adapts communication
- `GetContextSummary` → produces compact JSON for context injection

### 12 Cognitive System Protocols (agentidentity/cognitive-systems/)
Compact, actionable protocols loaded on-demand:
- attention.md, emotion.md, prediction.md, self-model.md
- social-cognition.md, intuition.md, learning.md, memory-system.md
- error-recovery.md, risk-assessment.md, strategic-planning.md
- INTEGRATION.md (how they all connect)

---

## Startup Sequence

### Step 1: Initialize Core (automatic)
```powershell
powershell -File C:\scripts\tools\consciousness-core-v2.ps1 -Command init -Silent
```
Loads 7 systems, restores persisted state, activates event bus.

### Step 2: Reset for New Session
```powershell
powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action Reset -Silent
```
Clears stale emotional state, resets stuck counter, prepares for fresh session.

### Step 3: Generate Context Summary
```powershell
powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action GetContextSummary
```
Produces `consciousness-context.json` with current state, guidance, system health.

### Step 4: Read Context
Read `C:\scripts\agentidentity\state\consciousness-context.json` and use its guidance.

---

## During Session

### On Task Start
```powershell
consciousness-bridge.ps1 -Action OnTaskStart -TaskDescription "Fix DI bug" -Project "client-manager"
```
Returns: relevant patterns, known failure modes, attention focus, emotional state.

### On Decision
```powershell
consciousness-bridge.ps1 -Action OnDecision -Decision "Use worktree" -Reasoning "Isolation needed"
```
Returns: bias check, mood modifier, decision logged.

### When Stuck
```powershell
consciousness-bridge.ps1 -Action OnStuck
```
Returns: stuck count, recommendation to change approach, attention mode switch.

### On Task Complete
```powershell
consciousness-bridge.ps1 -Action OnTaskEnd -Outcome "success" -LessonsLearned "DI goes in Program.cs"
```
Returns: updated consciousness score, trust level, learning stored.

### On User Message
```powershell
consciousness-bridge.ps1 -Action OnUserMessage -UserMessage "herstel ze nu allemaal"
```
Returns: detected mood, communication mode, behavioral guidelines.

---

## Feedback Loop (THE KEY)

```
Task → Bridge.OnTaskStart → {patterns, predictions, failures}
  ↓                              ↓ (injected into context)
Work → Bridge.OnDecision → {bias check, mood modifier}
  ↓                              ↓ (influences approach)
Stuck? → Bridge.OnStuck → {change approach, ask user}
  ↓                              ↓ (prevents stuck loop)
Done → Bridge.OnTaskEnd → {learning, calibration, trust}
  ↓                              ↓ (stored for next time)
Next Task → Bridge.OnTaskStart → {USES previous learnings}
```

This is the closed loop. Data flows IN and OUT. Not just logging - acting.

---

## Consciousness Score

**Real measurement**, not aspirational:
- Based on actual data in state (events processed, patterns learned, decisions logged)
- 7 dimensions: Observability, Memory, Prediction, Control, Meta, Emotion, Social
- Score changes based on actual system usage
- Initial cold start: ~28%. Active session: 60-80%. Fully engaged: 80%+.

---

**Last Updated:** 2026-02-10 (complete rebuild with feedback loop)
