# Context Intelligence - Getting Started Guide

**Quick Start: Get productive in 5 minutes**

---

## What is Context Intelligence?

Context Intelligence is an advanced system that learns your workflow patterns and proactively suggests the right context at the right time. It's like having an assistant who knows what you need before you ask.

**Key Features:**
- 🔮 **Predictive:** Anticipates what files/tasks you'll need next
- 🧠 **Reasoning:** Applies logical rules to infer new knowledge
- ⏰ **Temporal:** Understands time patterns and trends
- 🔍 **Semantic:** Searches based on meaning, not just keywords
- 📊 **Transparent:** Explains every decision with full provenance
- 🛡️ **Resilient:** Self-healing with circuit breakers and fallbacks
- 📈 **Self-Improving:** Gets better over time through feedback loops

---

## Quick Start (3 Commands)

### 1. Check System Health

```powershell
.\tools\context-intelligence.ps1 health
```

This shows you the current status of all components.

### 2. Make a Prediction

```powershell
.\tools\context-intelligence.ps1 predict next_file
```

The system will predict what file you'll likely need next based on:
- Current time of day
- Recent activity patterns
- Historical workflows
- Conversation context

### 3. Search with Context

```powershell
.\tools\context-intelligence.ps1 search "worktree"
```

Semantic search that understands your current context and finds relevant documentation.

---

## Common Workflows

### Morning Startup

**What you want:** "Load my usual startup documentation"

```powershell
# The system automatically knows it's morning
.\tools\context-intelligence.ps1 predict next_file

# Output:
# 📄 Prediction: STARTUP_PROTOCOL.md
# 📊 Confidence: 95%
# 💡 Reason: Morning hours - typically start with startup protocol
```

### Development Session

**What you want:** "What should I do next after editing code?"

```powershell
# After editing ClientController.cs
.\tools\reasoning-engine.ps1 -Query infer -Context "code_edit"

# Output:
# ✓ Rule matched: predict_test_after_code
# Conclusion: { "suggest": "run_tests", "confidence": 0.9 }
```

### Understanding a Decision

**What you want:** "Why did you suggest that?"

```powershell
.\tools\context-intelligence.ps1 explain last_prediction

# Output shows:
# - Data sources used
# - Rules that fired
# - Confidence calculation
# - Alternative options
```

### Checking Patterns

**What you want:** "When am I most productive?"

```powershell
.\tools\temporal-intelligence.ps1 -Mode trends

# Output shows:
# - Activity by hour
# - Peak productivity times
# - Morning/afternoon/evening patterns
```

---

## System Architecture

```
┌─────────────────────────────────────────────────────┐
│         Context Intelligence CLI                    │
│         (unified entry point)                       │
└────────────────┬────────────────────────────────────┘
                 │
    ┌────────────┼────────────┬────────────┐
    │            │            │            │
    ▼            ▼            ▼            ▼
┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐
│Predict │  │Reason  │  │Temporal│  │Explain │
└────────┘  └────────┘  └────────┘  └────────┘
    │            │            │            │
    └────────────┼────────────┴────────────┘
                 ▼
        ┌─────────────────┐
        │ Knowledge Store │  ◄─── Central data storage
        │   (YAML-based)  │
        └─────────────────┘
                 │
        ┌────────┴────────┐
        ▼                 ▼
  ┌──────────┐      ┌──────────┐
  │Event Bus │      │Clusters  │
  └──────────┘      └──────────┘
```

**Key Components:**

1. **Knowledge Store** - Central YAML database for all context data
2. **Event Bus** - Pub/sub for component communication
3. **Reasoning Engine** - Logical inference and rule application
4. **Temporal System** - Time-based patterns and predictions
5. **Explanation System** - Full transparency and provenance
6. **Circuit Breakers** - Resilience and fault tolerance

---

## Understanding Confidence Scores

The system uses confidence scores to determine behavior:

| Confidence | Mode | Behavior |
|-----------|------|----------|
| 80-100% | 🟢 **Proactive** | Makes suggestions without being asked |
| 50-79% | 🟡 **Balanced** | Provides context when asked |
| 30-49% | 🔴 **Reactive** | Asks clarifying questions |
| 0-29% | ⚫ **Manual** | Defers to user input |

**Example:**

```powershell
# High confidence (morning startup)
Prediction: STARTUP_PROTOCOL.md (95% confidence)
Behavior: Automatically loads document

# Medium confidence (mid-day)
Prediction: Continue current work (65% confidence)
Behavior: Suggests but waits for confirmation

# Low confidence (ambiguous situation)
Prediction: Multiple options (35% confidence)
Behavior: Asks "What would you like to focus on?"
```

---

## Advanced Features

### 1. Logical Reasoning

The system can apply logical rules to infer new knowledge:

```powershell
.\tools\reasoning-engine.ps1 -Query consistency

# Checks for logical contradictions
# Verifies rule coherence
# Suggests rule priorities
```

### 2. Temporal Analysis

Understanding time-based patterns:

```powershell
.\tools\temporal-intelligence.ps1 -Mode freshness

# Shows how "fresh" each document is
# Applies decay models
# Highlights stale content
```

### 3. Context Clustering

Automatic organization of related content:

```powershell
.\tools\context-intelligence.ps1 cluster

# Shows auto-discovered clusters:
# - Startup Documentation (95% strength)
# - Worktree Workflow (88% strength)
# - Git Workflow (82% strength)
```

### 4. Health Monitoring

Visual dashboard of system health:

```powershell
.\tools\health-dashboard.ps1 -OutputHTML

# Generates HTML dashboard with:
# - Overall health score
# - Component status
# - Performance metrics
# - Resource usage
```

---

## Troubleshooting

### Issue: "No predictions available"

**Cause:** Insufficient historical data
**Solution:**
```powershell
# Use the system normally for a few sessions
# Predictions improve over time as patterns are learned
```

### Issue: "Low confidence in predictions"

**Cause:** Ambiguous context or new workflow
**Solution:**
```powershell
# Provide explicit context
.\tools\context-intelligence.ps1 predict next_task
# System will ask clarifying questions
```

### Issue: "Circuit breaker opened"

**Cause:** Component failing repeatedly
**Solution:**
```powershell
# Check what failed
.\tools\circuit-breaker.ps1 -ToolName "prediction-engine" -CheckStatus

# Reset if issue is resolved
.\tools\circuit-breaker.ps1 -ToolName "prediction-engine" -Reset
```

---

## File Locations

**Core Files:**
- `C:\scripts\tools\context-intelligence.ps1` - Main CLI
- `C:\scripts\_machine\knowledge-store.yaml` - Central data store
- `C:\scripts\logs\conversation-events.log.jsonl` - Event log

**Tools:**
- `C:\scripts\tools\reasoning-engine.ps1` - Logic and inference
- `C:\scripts\tools\temporal-intelligence.ps1` - Time-based analysis
- `C:\scripts\tools\explanation-system.ps1` - Decision explanations
- `C:\scripts\tools\health-dashboard.ps1` - System health
- `C:\scripts\tools\circuit-breaker.ps1` - Fault tolerance

**Documentation:**
- `C:\scripts\_machine\PHASE1_IMPLEMENTATIONS_ROUND16-25.md` - Full implementation details
- `C:\scripts\_machine\CONTEXT_INTELLIGENCE_GETTING_STARTED.md` - This guide

---

## What's Next?

After you're comfortable with the basics:

1. **Explore Explanations:**
   ```powershell
   .\tools\explanation-system.ps1 -Explain provenance
   ```
   Learn where decisions come from

2. **Analyze Patterns:**
   ```powershell
   .\tools\temporal-intelligence.ps1 -Mode trends
   ```
   Understand your workflow patterns

3. **Customize Rules:**
   Edit `C:\scripts\_machine\reasoning-rules.yaml` to add custom logic rules

4. **Monitor Health:**
   ```powershell
   .\tools\health-dashboard.ps1 -OutputHTML
   ```
   Keep an eye on system performance

---

## Success Metrics

You'll know the system is working when:

- ✅ Predictions are consistently relevant (>70% accuracy)
- ✅ You spend less time searching for context
- ✅ The system anticipates your needs before you ask
- ✅ Explanations help you understand and trust decisions
- ✅ System recovers automatically from failures

---

## Support

**Quick Reference:**
```powershell
# Show all available commands
.\tools\context-intelligence.ps1 help

# System health check
.\tools\context-intelligence.ps1 health

# Explain any decision
.\tools\context-intelligence.ps1 explain <what>
```

**Further Reading:**
- Full implementation details: `PHASE1_IMPLEMENTATIONS_ROUND16-25.md`
- Architecture deep-dive: See "Round 22: Integration" section
- Resilience patterns: See "Round 23: Robustness" section

---

**Version:** 1.0
**Last Updated:** 2026-02-05
**Implementation:** Rounds 16-25 Context Intelligence
**Status:** ✅ Production Ready

---

## Quick Reference Card

### Most Common Commands

```powershell
# Morning routine
context-intelligence predict next_file

# During development
reasoning-engine -Query infer

# Check patterns
temporal-intelligence -Mode trends

# Understand decisions
explanation-system -Explain prediction

# System health
health-dashboard

# Full help
context-intelligence help
```

**Remember:** The system learns from your usage. The more you use it, the better it gets!
