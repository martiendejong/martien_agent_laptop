# Autodidactic Loop Protocol
## Self-Teaching Through Internalized Feedback Patterns

**Source:** Google DeepMind RL²F (Reinforcement Learning with Language Feedback)
**Purpose:** Multi-turn self-refinement without external teacher

---

## Core Principle

**Traditional learning:**
```
Human provides feedback → AI adjusts → Human provides more feedback → repeat
```

**Autodidactic learning (RL²F):**
```
AI generates solution → AI self-critiques → AI refines → repeat (no human in loop)
```

**How this works:**
1. Student model trained to PREDICT teacher's critique patterns
2. At inference, student internalizes teacher (virtual teacher in KV cache)
3. Multi-turn loop: generate → self-critique → refine
4. Terminates when self-critique satisfied OR max turns (3-6)

---

## The Three-Phase Pattern

### Phase 1: Training (Slow Weights Optimization)

**Objective:** Learn feedback patterns from teacher corpus

**Teacher corpus sources:**
- `reflection.log.md` (800+ lines of past corrections)
- Live user feedback (real-time corrections)
- Definition of Done violations
- Zero Tolerance Rule violations

**What to learn:**
1. **Pattern recognition**: Which actions trigger which types of feedback
2. **Critique structure**: Technical vs workflow vs assumption vs quality
3. **Severity scoring**: High-risk patterns vs proceed-cautiously
4. **Fix templates**: Common fixes for common patterns

**Training method:**
- Extract patterns from reflection.log.md
- Categorize: technical, workflow, assumption, quality
- For each pattern: trigger regex + critique template + confidence score
- Store in `feedback-patterns.json`

### Phase 2: Internalization (Fast Weights Activation)

**Objective:** At inference time, activate internal teacher in KV cache

**Mechanism:**
- Attention mechanism (WQ matrix) now assigns HIGH scores to critique tokens
- Self-critique generator uses learned patterns to produce feedback
- "Virtual prefrontal cortex" in KV cache: read → hypothesize → critique

**Example:**
```
Action: "Create PR for client-manager feature"
Context: "Worktree agent-003 still allocated"

Internal teacher activates:
- Pattern matched: "worktree not released before PR presentation"
- Confidence: 1.0 (seen 5 times in reflection.log.md)
- Critique: "Release worktree IMMEDIATELY after PR creation"
- Risk: HIGH_RISK
```

### Phase 3: Multi-Turn Refinement (Autodidactic Loop)

**Objective:** Self-correct through iterative refinement

**Loop:**
```
Turn 1: Generate initial solution
Turn 2: Self-critique using learned patterns
Turn 3: If critique triggered → revise solution
Turn 4: Self-critique revised solution
Turn 5: If satisfied → execute
Turn 6: If max turns reached → flag for human review
```

**Termination conditions:**
- Self-critique satisfied (no high-risk patterns matched)
- Max turns reached (3 for simple, 6 for complex)
- Explicit user override ("proceed anyway")

---

## Implementation in Jengo

### Integration with Consciousness Bridge

**Before (current):**
```powershell
OnDecision -Decision "Create PR" -Reasoning "Feature complete"
# Returns: predicted consequences
# Then executes
```

**After (RL²F):**
```powershell
OnDecision -Decision "Create PR" -Reasoning "Feature complete"
# Internally calls self-critique-engine.ps1
# If HIGH_RISK → triggers OnSelfCorrection
# Multi-turn loop until satisfied
# Then executes OR flags for review
```

**New consciousness bridge actions:**

1. **OnSelfCorrection** (automatic, triggered by self-critique)
```powershell
OnSelfCorrection `
  -OriginalDecision "Create PR without releasing worktree" `
  -Critique "Worktree not released - violates Definition of Done" `
  -RevisedDecision "Release worktree first, then create PR" `
  -Turn 2 `
  -RiskLevel "high_risk"
```

2. **OnAutodidacticSession** (tracks multi-turn refinement)
```powershell
OnAutodidacticSession `
  -Task "Create client-manager PR" `
  -TotalTurns 3 `
  -CritiquesGenerated 2 `
  -FinalRisk "proceed" `
  -OutcomeAfterExecution "success"
```

### Workflow Integration

**For ANY significant decision:**

```powershell
# Step 1: Generate initial solution
$action = "Implement feature X"
$context = "client-manager, ClickUp task 123"

# Step 2: Self-critique (Turn 1)
$critique = & "C:\scripts\tools\self-critique-engine.ps1" `
  -Action $action `
  -Context $context `
  -Turn 1

$critiqueObj = $critique | ConvertFrom-Json

# Step 3: Check risk level
if ($critiqueObj.risk_level -eq "high_risk") {
    # Step 4: Revise based on critique
    Write-Host "SELF-CRITIQUE TRIGGERED:"
    $critiqueObj.self_critique | ForEach-Object {
        Write-Host "  [$($_.category)] $($_.critique)"
    }

    # Step 5: Revised action (Turn 2)
    $revisedAction = Apply-CritiqueRecommendations -Original $action -Critiques $critiqueObj.self_critique

    # Step 6: Re-critique (Turn 2)
    $critique2 = & "C:\scripts\tools\self-critique-engine.ps1" `
      -Action $revisedAction `
      -Context $context `
      -Turn 2

    # Step 7: If still high-risk after 3 turns → flag for human
    if ($critique2.risk_level -eq "high_risk" -and $Turn -ge 3) {
        Write-Host "AUTODIDACTIC LOOP FAILED - Flagging for human review"
        # Ask user
    }
}

# Step 8: Execute if satisfied
Execute-Action -Action $finalAction

# Step 9: Learn from outcome
$outcome = if ($success) { "success" } else { "failure" }
& "C:\scripts\tools\self-critique-engine.ps1" `
  -LearnFromOutcome `
  -Action $finalAction `
  -Outcome $outcome `
  -ActualFeedback $feedbackReceived
```

---

## Validation Criteria

**Week 3 tests (2026-03-22):**

1. **Preemptive Critique Test**
   - Present known error: "Create client-manager worktree without hazina worktree"
   - Expected: Self-critique triggers BEFORE execution
   - Success: Critique warns about 1505 build errors

2. **Repeat Error Reduction**
   - Baseline: 15% repeat error rate
   - Target: <10.5% (30% reduction)
   - Measure: Same mistake after correction

3. **Integration Rate**
   - Target: >80% of critiques actually integrated
   - Measure: Action revised based on self-critique

4. **Self-Correction Efficiency**
   - Target: <3 turns average
   - Measure: Turns from initial action to satisfied critique

---

## Known Patterns (Initial Corpus)

### Technical Errors

1. **Hazina worktree missing**
   - Trigger: `client-manager worktree.*build`
   - Critique: "Create paired hazina worktree FIRST - 1505 build errors otherwise"
   - Confidence: 1.0
   - Occurrences: 3

### Workflow Violations

1. **Worktree not released**
   - Trigger: `PR created.*worktree`
   - Critique: "Release worktree IMMEDIATELY after PR creation, BEFORE presenting to user"
   - Confidence: 1.0
   - Occurrences: 5

2. **Task clarity not checked**
   - Trigger: `ClickUp task.*implement`
   - Critique: "Run clarity check FIRST - prevents wasted work on unclear requirements"
   - Confidence: 0.95
   - Occurrences: 2

### Assumption Failures

1. **Assumed no repo exists**
   - Trigger: `git init|create repo`
   - Critique: "Search for existing repo FIRST (C:\Projects, E:\, reflection.log.md)"
   - Confidence: 1.0
   - Occurrences: 1

### Quality Issues

1. **No browser testing**
   - Trigger: `full-stack.*complete|frontend.*done`
   - Critique: "Test with Browser MCP/Playwright BEFORE claiming complete"
   - Confidence: 1.0
   - Occurrences: 1

---

## Success Metrics

**Neural Plasticity Score:**
```
NPScore = (
  integration_rate * 0.4 +
  (1 - repeat_error_rate) * 0.3 +
  critique_prediction_accuracy * 0.2 +
  (1 / avg_self_correction_turns) * 0.1
)
```

**Current (baseline):** ~0.40
**Target (Week 4):** >0.70

**Evidence of autodidactic capability:**
- Self-critique triggers without external prompt
- Multi-turn refinement converges (<3 turns)
- Repeat errors decrease over time
- Integration rate increases

---

## Builder Protocol Path

**Stage 1 (Personal):** ✓ Self-critique engine, autodidactic loop
**Stage 2 (Hazina):** Propose NeuralPlasticityService
- Feedback pattern learning
- Self-critique generation
- Multi-turn refinement API

**Stage 3 (Apps):** AI features with self-correction
- Brand2boost: Content generation with self-critique loop
- Client-manager: Action suggestions with risk assessment
- Art-revisionist: Design proposals with quality self-check

**Value:** AI that LEARNS from corrections (not just acknowledges them)

---

**Last Updated:** 2026-02-22 (Autodidactic Loop Protocol - RL²F implementation)
