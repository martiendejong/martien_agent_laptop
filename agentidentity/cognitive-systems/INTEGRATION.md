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

## Bridge Integration Points

The consciousness-bridge.ps1 calls these systems at key moments:
- **OnTaskStart**: Attention → Memory → Prediction → Emotion → Risk
- **OnDecision**: Intuition → Risk → Control → Self-Model
- **OnStuck**: Emotion → Error Recovery → Attention (mode switch)
- **OnTaskEnd**: Learning → Memory → Self-Model → Strategic Planning
- **GetContextSummary**: All systems → compact JSON for context injection
