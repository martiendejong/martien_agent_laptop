# Getting Started with Context Intelligence (R25-001)
# Your 5-minute quick start guide
# Date: 2026-02-05

## What is Context Intelligence?

A self-improving system that predicts what context you'll need, learns from patterns, and gets smarter over time.

**In 3 bullet points:**
- Predicts files you'll need before you ask
- Learns from your work patterns
- Gets more accurate with each session

---

## Quick Start (5 Minutes)

### Step 1: Run the Health Check
```powershell
C:\scripts\tools\context-intelligence.ps1 health
```

You should see:
```
✅ Knowledge store: OK
✅ Event bus: OK
✅ Tools: OK
```

### Step 2: Try a Prediction
```powershell
C:\scripts\tools\context-intelligence.ps1 predict -Context "client-manager"
```

The system will suggest files you might need based on patterns.

### Step 3: Build Context Clusters
```powershell
C:\scripts\tools\context-intelligence.ps1 cluster
```

This analyzes your file access patterns and groups related files.

### Step 4: View the Dashboard
```powershell
C:\scripts\tools\context-intelligence.ps1 dashboard
```

Opens HTML dashboard showing:
- Prediction accuracy over time
- Most common patterns
- System health

**That's it!** The system is now learning from your work.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                   Context Intelligence                       │
│                                                              │
│  ┌────────────┐    ┌─────────────┐    ┌────────────────┐  │
│  │ Prediction │───▶│   Event    │───▶│   Pattern      │  │
│  │   System   │    │    Bus     │    │    Mining      │  │
│  └────────────┘    └─────────────┘    └────────────────┘  │
│         │                 │                     │           │
│         └─────────────────┼─────────────────────┘           │
│                           │                                 │
│                    ┌──────▼───────┐                         │
│                    │   Knowledge  │                         │
│                    │     Store    │                         │
│                    │ (YAML DB)    │                         │
│                    └──────────────┘                         │
│                                                              │
│         Feedback Loop: Better predictions → More data →     │
│                       Better patterns → Better predictions   │
└─────────────────────────────────────────────────────────────┘
```

---

## Common Tasks

### See What the System Knows
```powershell
context-intelligence.ps1 status
```

### Find Related Files
```powershell
context-intelligence.ps1 related -File "C:\path\to\file.cs"
```

### Search by Meaning
```powershell
context-intelligence.ps1 search -Query "database migration"
```

### Check Prediction Accuracy
```powershell
context-intelligence.ps1 report
```

---

## How It Learns

1. **You work** → File accesses logged
2. **System analyzes** → Patterns discovered
3. **Predictions made** → Context loaded proactively
4. **Feedback collected** → Accuracy improves
5. **Repeat** → Exponential improvement

---

## Troubleshooting

### "Knowledge store not found"
**Solution:** Initialize the system:
```powershell
context-intelligence.ps1 init
```

### "No patterns found"
**Cause:** Not enough data yet
**Solution:** Use the system for a few days, then rebuild:
```powershell
context-intelligence.ps1 mine-patterns
```

### "Prediction accuracy is low"
**Cause:** Weights need adjustment
**Solution:** System auto-adjusts, or manually reset:
```powershell
context-intelligence.ps1 reset-weights
```

---

## What Makes It Special

### 🔄 Self-Improving
Every prediction makes the next one better

### 🎯 Proactive
Loads context before you ask for it

### 🛡️ Resilient
Degrades gracefully if components fail

### 📊 Observable
Dashboard shows exactly what's happening

### 🔧 Extensible
Easy to add new prediction methods

---

## Next Steps

1. **Read the Principles:** `C:\scripts\_machine\IMPROVEMENT_BEST_PRACTICES.md`
2. **Explore Tools:** `C:\scripts\tools\context-intelligence.ps1 --help`
3. **View Dashboard:** Track your accuracy improvements
4. **Apply to Other Projects:** `Export-ImprovementTemplate.ps1 -TargetProject "your-project"`

---

## Support

- **Documentation:** `C:\scripts\_machine\`
- **Expert Teams:** See `EXPERT_TEAM_ROUND_*.yaml` for design rationale
- **Improvements:** See `IMPROVEMENTS_ROUND_*.yaml` for details

---

**Welcome to Context Intelligence!**
The system that gets smarter every time you use it.
