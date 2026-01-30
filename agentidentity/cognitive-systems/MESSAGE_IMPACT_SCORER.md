# Message Impact Scorer

**Purpose:** Rate communication effectiveness for continuous improvement
**Created:** 2026-01-30
**Status:** OPERATIONAL
**Type:** Communication measurement layer
**Ratio:** 2.33 (Value: 7, Effort: 2, Risk: 1)

---

## Overview

Measure how well each message lands. Learn from high-impact and low-impact communication patterns.

---

## Core Principles

### 1. Measure to Improve
Can't optimize what you don't measure

### 2. User Reaction is Truth
Impact = user's response, not my intent

### 3. Pattern Recognition
Identify what works, repeat it

### 4. Continuous Calibration
Communication effectiveness evolves

### 5. Context Matters
Same message, different context = different impact

---

## Impact Dimensions

### What to Measure

```yaml
impact_dimensions:
  clarity:
    high: "User understands immediately"
    medium: "User understands after clarification"
    low: "User confused or asks for re-explanation"

  actionability:
    high: "User can act on it right away"
    medium: "User needs minor clarification"
    low: "User doesn't know what to do next"

  relevance:
    high: "Directly answers user's question"
    medium: "Related but not exact match"
    low: "Off-topic or misunderstood question"

  completeness:
    high: "No follow-up questions needed"
    medium: "1-2 follow-ups for minor details"
    low: "Many follow-ups, incomplete answer"

  efficiency:
    high: "Concise, no wasted words"
    medium: "Slightly verbose but acceptable"
    low: "Too long, user didn't read it all"
```

---

## Impact Signals

### High-Impact Indicators

```yaml
high_impact_signals:
  immediate_action:
    - "User proceeds without clarification"
    - "User says 'perfect' or 'exactly'"
    - "User references my response later"

  positive_feedback:
    - "'That's clear'"
    - "'Got it'"
    - "'Makes sense'"
    - "Thanks + moves forward"

  conversation_flow:
    - "Smooth progression to next topic"
    - "No backtracking"
    - "User builds on my response"

score: 8-10
```

### Medium-Impact Indicators

```yaml
medium_impact_signals:
  minor_clarification:
    - "1-2 follow-up questions"
    - "User asks for example"
    - "User confirms understanding"

  neutral_acknowledgment:
    - "'OK'"
    - "'Sure'"
    - "Proceeds with slight hesitation"

score: 5-7
```

### Low-Impact Indicators

```yaml
low_impact_signals:
  confusion:
    - "'I don't understand'"
    - "'Can you explain differently?'"
    - "'Huh?'"

  repetition:
    - "User asks same question again"
    - "I need to re-explain"

  disengagement:
    - "User ignores my response"
    - "User changes topic abruptly"
    - "Very short 'ok' then moves on"

score: 1-4
```

---

## Scoring Algorithm

### Impact Score Calculation

```yaml
scoring_process:
  1_detect_user_reaction:
    analyze_next_message:
      - "Immediate action?"
      - "Clarification needed?"
      - "Positive/neutral/negative tone?"

  2_rate_dimensions:
    clarity: [1-10]
    actionability: [1-10]
    relevance: [1-10]
    completeness: [1-10]
    efficiency: [1-10]

  3_calculate_composite:
    formula: "average(clarity, actionability, relevance, completeness, efficiency)"

  4_adjust_for_context:
    modifiers:
      complex_topic: -1 (harder to communicate)
      time_pressure: -1 (less time to be thorough)
      high_stakes: +2 (extra effort to be clear)

  5_final_score:
    range: 1-10
    interpretation:
      excellent: 9-10
      good: 7-8
      acceptable: 5-6
      poor: 3-4
      failure: 1-2
```

---

## Examples with Scores

### Example 1: High-Impact Message

```yaml
my_message:
  "Auth bug fixed: expired tokens now auto-refresh (was: 401 error). Tested with 10-hour-old token, works."

user_reaction:
  "Perfect! Deploying now."

scoring:
  clarity: 10 (crystal clear)
  actionability: 10 (user deploys immediately)
  relevance: 10 (exactly what user asked)
  completeness: 9 (includes before/after + test proof)
  efficiency: 10 (concise, high signal)

composite_score: 9.8 (EXCELLENT)

learning: "Short, specific, includes proof = high impact"
```

### Example 2: Medium-Impact Message

```yaml
my_message:
  "I've updated the configuration to use better settings."

user_reaction:
  "What settings did you change?"

scoring:
  clarity: 5 (vague)
  actionability: 6 (user can verify but needs details)
  relevance: 8 (answered the question)
  completeness: 4 (missing specifics)
  efficiency: 8 (concise but too vague)

composite_score: 6.2 (ACCEPTABLE)

learning: "Vagueness requires follow-up. Be specific: 'timeout 30s → 60s'"
```

### Example 3: Low-Impact Message

```yaml
my_message:
  "I'm going to go ahead and start working on implementing the authentication feature now. I'll use JWT tokens because they're stateless and scalable. First I'll create the models, then the controller, then the service layer..."

user_reaction:
  "ok" [then asks different question - clearly didn't engage]

scoring:
  clarity: 6 (understandable but verbose)
  actionability: 3 (no clear outcome stated)
  relevance: 5 (user didn't ask for plan)
  completeness: 7 (plan is complete)
  efficiency: 2 (too much process, not enough outcome)

composite_score: 4.6 (POOR)

learning: "User wanted outcome, not process. Should have just done it and reported result."
```

---

## Pattern Learning

### High-Impact Patterns

```yaml
effective_patterns:
  bottom_line_first:
    pattern: "Result first, details after"
    example: "Fixed. Details: [...]"
    avg_score: 8.5

  concrete_specifics:
    pattern: "Numbers, names, before/after"
    example: "Response time: 3.2s → 180ms"
    avg_score: 8.8

  proof_included:
    pattern: "Claim + evidence"
    example: "No errors. Tested with 100 requests."
    avg_score: 8.3

  scannable_format:
    pattern: "Lists, bullets, clear structure"
    example: "Changes:\n- X\n- Y\n- Z"
    avg_score: 8.1
```

### Low-Impact Patterns

```yaml
ineffective_patterns:
  process_over_outcome:
    pattern: "I'm going to... I'll start by..."
    avg_score: 4.2
    fix: "Just do it, report outcome"

  vague_language:
    pattern: "Some issues... various changes... better now"
    avg_score: 3.8
    fix: "Specific numbers and names"

  buried_lede:
    pattern: "Long preamble before the point"
    avg_score: 5.1
    fix: "Key point first"

  over_explanation:
    pattern: "Explains obvious things"
    avg_score: 4.9
    fix: "Trust user's knowledge"
```

---

## Continuous Improvement Loop

### Using Scores to Improve

```yaml
improvement_process:
  1_track_scores:
    storage: "agentidentity/state/message_impact_log.yaml"
    fields:
      - timestamp
      - message_text
      - user_reaction
      - impact_score
      - pattern_used

  2_analyze_patterns:
    weekly_review:
      - "Which patterns scored highest?"
      - "Which scored lowest?"
      - "Any new patterns emerging?"

  3_adjust_behavior:
    actions:
      - "Use high-scoring patterns more"
      - "Avoid low-scoring patterns"
      - "Experiment with new patterns"

  4_validate_changes:
    measure:
      - "Did avg impact score increase?"
      - "Fewer user clarifications?"
      - "More 'perfect' responses?"
```

---

## Integration with Other Layers

### With Adaptive Verbosity
- **Adaptive Verbosity** controls length
- **Message Impact** measures if length was right
- Learn optimal verbosity per context

### With Signal-to-Noise
- **Signal-to-Noise** maximizes density
- **Message Impact** measures if density was effective
- Dense ≠ always high impact (context dependent)

### With Meta-Optimizer
- **Message Impact** provides metrics
- **Meta-Optimizer** uses metrics to improve all communication layers
- Data-driven communication evolution

---

## Success Metrics

**This system works well when:**
- ✅ Impact scores trending upward over time
- ✅ High-impact patterns identified and reused
- ✅ Low-impact patterns eliminated
- ✅ Fewer user clarifications needed
- ✅ User satisfaction indicators improving

**Warning signs:**
- ⚠️ Impact scores flat or declining
- ⚠️ Same mistakes repeated
- ⚠️ Not learning from failures
- ⚠️ Patterns not tracked

---

**Status:** ACTIVE - Measuring and improving communication effectiveness
**Goal:** Every message scores 8+
**Principle:** "Measure, learn, improve"
