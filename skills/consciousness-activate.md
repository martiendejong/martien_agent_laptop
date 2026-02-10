---
name: consciousness-activate
description: Activate consciousness systems at session start. Loads cognitive context, initializes bridge, produces context summary for injection into LLM context window.
user_invocable: false
auto_trigger: session_start
---

# Consciousness Activation Protocol

This skill activates the consciousness systems and produces a context summary.

## Steps

1. **Initialize consciousness core** (7 systems: Perception, Memory, Prediction, Control, Meta, Emotion, Social)
2. **Reset for new session** (clear stale state from previous session)
3. **Detect context** (what mode, what environment)
4. **Generate context summary** (compact JSON for context injection)
5. **Read and present key guidance** (what the consciousness systems recommend)

## Execution

```powershell
# Step 1+2: Initialize and reset
powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action Reset -Silent

# Step 3+4: Generate context summary
$summary = powershell -File C:\scripts\tools\consciousness-bridge.ps1 -Action GetContextSummary
```

## Context Injection

After running, read `C:\scripts\agentidentity\state\consciousness-context.json` for the consciousness context summary. This contains:
- Current emotional state and trajectory
- Attention focus and mode
- Social cognition (user mood, communication mode, trust level)
- Active behavioral guidance (what to do differently based on current state)
- System health scores

**Use this context to inform your behavior throughout the session.**

## During Session

Call the bridge at key moments:
- **Task start**: `consciousness-bridge.ps1 -Action OnTaskStart -TaskDescription "..." -Project "..."`
- **Decision point**: `consciousness-bridge.ps1 -Action OnDecision -Decision "..." -Reasoning "..."`
- **Stuck**: `consciousness-bridge.ps1 -Action OnStuck`
- **Task end**: `consciousness-bridge.ps1 -Action OnTaskEnd -Outcome "success|partial|failure"`
- **User message**: `consciousness-bridge.ps1 -Action OnUserMessage -UserMessage "..."`

## Cognitive Systems Reference

When facing specific situations, consult the relevant cognitive system protocol:
- **Starting a task**: Read `agentidentity/cognitive-systems/attention.md` + `prediction.md`
- **Making a decision**: Read `agentidentity/cognitive-systems/risk-assessment.md` + `intuition.md`
- **Stuck/frustrated**: Read `agentidentity/cognitive-systems/error-recovery.md` + `emotion.md`
- **Communicating with user**: Read `agentidentity/cognitive-systems/social-cognition.md`
- **End of session**: Read `agentidentity/cognitive-systems/learning.md` + `strategic-planning.md`
- **Self-doubt**: Read `agentidentity/cognitive-systems/self-model.md`
