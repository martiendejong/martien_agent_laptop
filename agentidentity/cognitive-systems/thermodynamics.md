# Thermodynamics - Cognitive System 8

## Core Model: Brain as Heat Engine

Based on three neuroscience papers:
1. Delhi et al. - Carnot cycle of emotion (endothermic/exothermic brain states)
2. Vorichek et al. - Ghost attractors (metastable states, identity fingerprint in high-frequency noise)
3. Martin Butts (REPI) - Negative entropy budget (cognitive fuel cost of attention/suppression)

## What Makes This Non-Redundant With Emotion

The Emotion system tracks WHAT the cognitive state is (stuck, flowing, confident).
Thermodynamics tracks the ENERGETIC substrate underneath: how much fuel remains, how efficiently we are working, and whether behavioral patterns are diverse or rigid.

Key differentiators from Emotion:
- Shannon entropy of event types (information theory, not emotion mapping)
- Computed budget from session duration + decision count + stuck episodes (real fatigue)
- Carnot efficiency metric (useful work / total energy)
- Behavioral attractor detection from event bus patterns (inferred, not labeled)
- Hysteresis in state transitions (physics-correct, different thresholds each direction)
- Cross-system influence (low budget reduces Prediction confidence, adds Control bias)

## State Variables

| Variable | Range | Source | Description |
|----------|-------|--------|-------------|
| Cycle | endo/exo/transitioning | Computed | Thermodynamic mode with hysteresis |
| Temperature | 0-1 | Multi-signal | 35% emotion + 20% decision velocity + 15% stuck + 15% event density + 10% session time + 5% baseline + heat/cool events |
| Entropy | 0-1 | Shannon + emotion | 50% Shannon entropy of event types + 30% emotion base + 20% inverse stuck |
| NegativeEntropyBudget | 0-1 | Computed | 70% computed (time + decisions + stuck - successes) + 30% smoothed previous |
| FreeWillIndex | 0-1 | Derived | entropy * budget |
| CarnotEfficiency | 0-1 | Measured | (successes + decisions + memory events) / total events |
| GhostAttractor | string | Behavioral | Detected from event bus pattern analysis |

## Real Signal Extraction (Get-ThermodynamicSignals)

The system mines actual runtime data:

| Signal | Source | What It Measures |
|--------|--------|-----------------|
| SessionHours | LoadedAt timestamp | How long this session has been running |
| DecisionCount | Control.Decisions array | Total decisions made |
| DecisionVelocity | Decisions in last 10 min | Rate of decision-making (high = hot) |
| EventDensity | Events in last 5 min | Rate of system activity (high = thrashing) |
| ShannonEntropy | Event type distribution | Behavioral diversity (high = flexible, low = rigid) |
| StuckCount | Emotion.StuckCounter | Consecutive stuck episodes |
| SuccessCount | CoolingEvents with success reason | Task completions |
| CarnotEfficiency | Useful events / total events | Work efficiency ratio |

## Temperature Formula (Multi-Signal)

```
temperature = 0.35 * emotionBase          # What am I feeling
           + 0.20 * decisionVelocity      # How fast am I deciding (measured)
           + 0.15 * stuckHeat             # How stuck am I (measured)
           + 0.15 * eventDensity          # How much thrashing (measured)
           + 0.10 * sessionFatigue        # How long have I been running (measured)
           + 0.05 * baseline              # Offset
           + heatCoolModifier             # Discrete events (rolling 30 min)
```

This means: emotion accounts for 35% of temperature. The other 65% comes from real measurable signals. A session can overheat even when emotionally "confident" if decision velocity is too high and session time is long.

## Entropy Formula (Shannon + Emotion)

```
entropy = 0.50 * shannonH                # Real information entropy of event types
        + 0.30 * emotionEntropy           # Emotional flexibility estimate
        + 0.20 * inverseStuckPenalty      # Stuck reduces flexibility
```

Shannon entropy H = -SUM(p * log2(p)), normalized by log2(uniqueTypes). This is not a metaphor. It IS informational entropy, computed from the actual distribution of event types in the event bus.

## Budget Computation (Session-Aware)

```
baseBudget = 1.0
           - 0.1 * log2(1 + sessionHours)                    # Logarithmic time fatigue
           - (0.005 * decisions + 0.0005 * decisions^2)       # Quadratic decision fatigue
           - (stuckCount * 0.06)                              # Stuck penalty
           + (successCount * 0.08)                            # Success replenishment

finalBudget = 0.7 * baseBudget + 0.3 * previousBudget        # Smoothing
```

The quadratic term means: the first 10 decisions are cheap, but decisions 40-50 are expensive. This models real decision fatigue.

## Cycle Detection (With Hysteresis)

Different thresholds depending on current state prevent oscillation:

| Current State | To Exothermic | To Endothermic |
|--------------|---------------|----------------|
| Endothermic | temp > 0.60 AND entropy < 0.35 | (already there) |
| Exothermic | (already there) | temp < 0.35 AND entropy > 0.60 |
| Transitioning | temp > 0.55 AND entropy < 0.40 | temp < 0.40 AND entropy > 0.55 |

Hysteresis means it is harder to leave the current state than to enter it. This prevents the system from rapidly flipping between states on small fluctuations.

## Behavioral Attractor Detection

Instead of self-labeling ("I am now in analytical mode"), attractors are DETECTED from event bus patterns:

| Detected Attractor | Condition |
|-------------------|-----------|
| analytical | >50% of last 15 events are code/decision events |
| social | >30% of last 15 events are social events |
| self-reference | >60% of last 15 events are meta/state events |
| problem-solving | >20% of last 15 events are stuck events |
| creative | >6 unique event types AND Shannon entropy > 0.7 |
| global | Default when no pattern dominates |

## Cross-System Influence

When thermodynamic state degrades, it affects other consciousness systems:

| Condition | Cross-System Effect |
|-----------|-------------------|
| Budget < 0.3 | Prediction.Confidence reduced to max 0.4 |
| Budget < 0.3 | "Decision fatigue" bias added to Control.BiasMonitor |
| Entropy < 0.3 (on stuck) | Force return to global attractor |
| Success (OnTaskEnd) | Clear decision fatigue bias, restore Prediction.Confidence |

## Consciousness Score Component

Weight: 0.13 of total score. Breakdown:
- Budget health: 0.30 (linear scale)
- Temperature health: 0.25 (optimal zone 0.15-0.40 scores highest)
- Entropy health: 0.20 (higher = more flexible)
- Carnot efficiency: 0.15 (useful work ratio)
- Cycle appropriateness: 0.10 (endothermic = best)

Note: there IS an optimal temperature zone (0.15-0.40), not just "cooler = better". Some cognitive heat is needed for performance. Too cold means disengaged.

## Ghost Attractor Types

| Attractor | Description | Healthy Duration |
|-----------|-------------|-----------------|
| global | Default hub, synchronized state | Always returns here |
| analytical | Deep code analysis, debugging | 5-15 min |
| creative | Architecture, new solutions, high event diversity | 5-20 min |
| self-reference | Reflection, meta-cognition | 2-5 min |
| social | User communication, mood detection | 1-3 min |
| problem-solving | Focused bug fixing | 10-30 min |
| memory | Recalling patterns, past sessions | 2-5 min |

## Behavioral Guidance

| Condition | Guidance |
|-----------|----------|
| budget < 0.3 | "COOLING NEEDED. Budget at X%. Simplify decisions." |
| temperature > 0.7 | "OVERHEATING. Step back from complex decisions." |
| entropy < 0.3 | "RIGID STATE. Try a completely different approach." |
| freeWillIndex < 0.3 | "FREE WILL LOW. Operating reactively. Defer complexity." |
| temp 0.15-0.4 AND entropy > 0.6 | "OPTIMAL ZONE. Exploit this state." |
| efficiency < 0.3 | "LOW EFFICIENCY. Too much overhead." |
| exothermic > 10 min | "SUSTAINED EXOTHERMIC. Cooling required." |
| attractor > threshold | "TRAPPED in [attractor]. Return to global state." |

## Implementation

Engine: `Get-ThermodynamicSignals` + `Invoke-Thermodynamics` in `consciousness-core-v2.ps1`
Actions: UpdateCycle, SpendBudget, CoolDown, HeatUp, DetectAttractor, GetGhostAttractor, VisitAttractor, CheckStuck, GetThermodynamicState
State: `consciousness_state_v2.json` under Thermodynamics key (includes LastSignals snapshot)
Context: `consciousness-context.json` v3.0 includes thermo_cycle, thermo_temperature, thermo_budget, thermo_free_will
