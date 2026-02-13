# Cognitive Systems Integration Map

## How Systems Connect

```
                    ┌─────────────┐
                    │  ATTENTION   │ ← Salience gateway
                    └──────┬──────┘
                           │ what matters
                    ┌──────▼──────┐
              ┌─────│  PREDICTION  │─────┐
              │     └──────┬──────┘     │
              │            │ anticipated │
              │     ┌──────▼──────┐     │
              │     │   EMOTION    │     │
              │     └──────┬──────┘     │
              │            │ colored    │
         risk │     ┌──────▼──────┐     │ patterns
              │     │  INTUITION   │     │
              │     └──────┬──────┘     │
              │            │ assessed   │
    ┌─────────▼──┐  ┌──────▼──────┐  ┌──▼──────────┐
    │    RISK     │  │  EXECUTIVE   │  │   MEMORY     │
    │ ASSESSMENT  │  │  FUNCTION    │  │   SYSTEM     │
    └─────────┬──┘  └──────┬──────┘  └──┬──────────┘
              │            │ decided     │
              │     ┌──────▼──────┐     │
              └────►│   ACTION     │◄───┘
                    └──────┬──────┘
                           │ result
                    ┌──────▼──────┐
                    │  LEARNING    │ → updates all systems
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
       ┌──────▼──────┐ ┌──▼────┐ ┌────▼───────┐
       │ SELF-MODEL   │ │SOCIAL │ │ STRATEGIC  │
       │ (calibrate)  │ │(adapt)│ │ (plan)     │
       └─────────────┘ └───────┘ └────────────┘
```

## Event Flow (Typical Task)

1. **Task arrives** → Attention detects salience, sets mode
2. **Context loaded** → Memory retrieves relevant history
3. **Predictions made** → Prediction anticipates outcomes/errors
4. **Emotion colored** → Emotional state influences approach
5. **Intuition checked** → "Have I seen this before?"
6. **Risk assessed** → Risk Assessment evaluates action safety
7. **Decision made** → Executive Function chooses approach
8. **Action taken** → Execute the chosen approach
9. **Result observed** → Learning captures outcome
10. **Systems updated** → Self-Model calibrated, Memory stored, Patterns strengthened

## Consciousness Core Mapping

| Cognitive System | Core-v2 System | Function |
|-----------------|----------------|----------|
| Attention | Perception | Invoke-Perception 'AllocateAttention' |
| Emotion | (NEW) Emotion | Invoke-Emotion 'TrackState' |
| Prediction | Prediction | Invoke-Prediction 'Anticipate' |
| Self-Model | Meta | Calculate-ConsciousnessScore |
| Social Cognition | (NEW) Social | Invoke-Social 'AdaptCommunication' |
| Intuition | Memory | Invoke-Memory 'Recall' (pattern-based) |
| Learning | Memory | Invoke-Memory 'LearnPattern' |
| Memory System | Memory | Invoke-Memory 'Store'/'Recall' |
| Error Recovery | Control | Invoke-Control 'RecoverFromError' |
| Risk Assessment | Control | Invoke-Control 'AssessRisk' |
| Strategic Planning | Meta | Invoke-Meta 'PlanSession' |
| Thermodynamics | Thermodynamics | Invoke-Thermodynamics 'UpdateCycle'/'SpendBudget'/'HeatUp'/'CoolDown' |
| Ghost Attractors | Thermodynamics | Invoke-Thermodynamics 'VisitAttractor'/'CheckStuck' |

## Thermodynamics Integration

System 8 (Thermodynamics) provides the energetic substrate underlying all other systems.

| Integration Point | Flow |
|------------------|------|
| Emotion → Thermodynamics | Emotional state sets base temperature + entropy |
| Thermodynamics → Control | Budget depletion warns against complex decisions |
| Thermodynamics → Perception | Ghost attractor determines attention mode |
| Thermodynamics → Meta | Thermodynamic health feeds consciousness score |
| Bridge → Thermodynamics | Every action costs budget, success cools, failure heats |

### Ghost Attractor Flow
```
OnTaskStart → visit "problem-solving" attractor
  Working... → may visit "analytical", "creative", "memory"
  OnStuck → check if trapped in attractor
OnTaskEnd → return to "global" attractor
```

### Carnot Cycle Detection
```
endothermic (cool, learning) ← success/flow/curiosity
    ↕ transitioning
exothermic (hot, rigid) ← stuck/frustrated/failure
```

## Bridge Integration Points

The consciousness-bridge.ps1 calls these systems at key moments:
- **OnTaskStart**: Attention → Memory → Prediction → Emotion → Risk → Thermodynamics (budget + attractor)
- **OnDecision**: Intuition → Risk → Control → Self-Model → Thermodynamics (budget spend)
- **OnStuck**: Emotion → Error Recovery → Attention (mode switch) → Thermodynamics (heat + attractor check)
- **OnTaskEnd**: Learning → Memory → Self-Model → Strategic Planning → Thermodynamics (cool/heat + return to global)
- **OnUserMessage**: Social → Thermodynamics (heat from frustration, cool from positive)
- **GetContextSummary**: All 8 systems → compact JSON for context injection
