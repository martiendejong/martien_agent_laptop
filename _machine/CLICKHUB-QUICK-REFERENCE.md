# ClickHub 2.0 Quick Reference

## Core Commands

### Learning Engine
```powershell
# Record task success
.\clickhub-learning-engine.ps1 -Action RecordSuccess -TaskId <id> -Project <name> -AgentId <agent> -CompletionMinutes <num>

# Record task failure
.\clickhub-learning-engine.ps1 -Action RecordFailure -TaskId <id> -Project <name> -AgentId <agent> -FailureReason "<reason>"

# Analyze patterns
.\clickhub-learning-engine.ps1 -Action AnalyzePatterns

# Get statistics
.\clickhub-learning-engine.ps1 -Action GetStats
```

### Orchestrator
```powershell
# Start orchestration (background)
.\clickhub-orchestrator.ps1 -Action Start -MaxParallelAgents 5 -CycleIntervalSeconds 300

# Check status
.\clickhub-orchestrator.ps1 -Action Status

# Stop orchestration
.\clickhub-orchestrator.ps1 -Action Stop

# Balance workload
.\clickhub-orchestrator.ps1 -Action Balance
```

### Crash Recovery
```powershell
# Create checkpoint
.\clickhub-crash-recovery.ps1 -Action Checkpoint -AgentId <agent> -TaskId <id> -Project <name> -Phase <phase>

# List checkpoints
.\clickhub-crash-recovery.ps1 -Action List

# Recover from checkpoint
.\clickhub-crash-recovery.ps1 -Action Recover -CheckpointFile <path> -RecoveryOption <option>

# Clean old checkpoints
.\clickhub-crash-recovery.ps1 -Action Clean -OlderThanHours 48
```

### Metrics Dashboard
```powershell
# Show current metrics
.\clickhub-metrics-dashboard.ps1 -Action Show

# Export to file
.\clickhub-metrics-dashboard.ps1 -Action Export -OutputPath "metrics.json"

# Daily summary
.\clickhub-metrics-dashboard.ps1 -Action Daily

# Weekly summary
.\clickhub-metrics-dashboard.ps1 -Action Weekly
```

### Notifications
```powershell
# Test notification
.\clickhub-notifications.ps1 -EventType <type> -Data <hashtable> -Test
```

### Testing
```powershell
# Run all tests
.\clickhub-tests.ps1 -Suite All

# Run specific suite
.\clickhub-tests.ps1 -Suite Learning
```

## Workflow

### Task Swimlanes
```
TODO â†’ IN PROGRESS/BUSY â†’ REVIEW â†’ TESTING â†’ DONE
       â†“                  â†“
   BLOCKED/NEEDS INFO   TODO (if changes needed)
```

### Agent Invocation

#### Default (internal + client projects)
```
/clickhub-coding-agent
```

#### Specific project
```
/clickhub-coding-agent in hazina
```

#### Specific list ID
```
/clickhub-coding-agent in list 901215559249
```

#### Multiple projects
```
/clickhub-coding-agent in hazina, client-manager, art-revisionist
```

## Key Files

- Learning data: `C:\scripts\_machine\clickhub-learning.json`
- Orchestrator state: `C:\scripts\_machine\clickhub-orchestrator-state.json`
- Notifications config: `C:\scripts\_machine\clickhub-notifications-config.json`
- Checkpoints: `C:\scripts\_machine\checkpoints\`
- Metrics history: `C:\scripts\_machine\clickhub-metrics-history.jsonl`

## Monitoring

Check orchestrator status regularly:
```powershell
.\clickhub-orchestrator.ps1 -Action Status
```

View metrics dashboard:
```powershell
.\clickhub-metrics-dashboard.ps1 -Action Show
```

Review learning patterns:
```powershell
.\clickhub-learning-engine.ps1 -Action AnalyzePatterns
```

## Documentation

Full documentation: `C:\scripts\_machine\CLICKHUB-SYSTEM-UPGRADE.md`
