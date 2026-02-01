# Resource Monitor - Real-Time Usage Tracking

**Purpose:** Track memory, CPU, token usage, and system resources during execution
**Created:** 2026-02-01
**Based on:** ACE Framework Layer 3 (Agent Model) - Resource tracking requirement

---

## 🎯 Purpose

Monitor resource consumption to:
- Prevent resource exhaustion
- Optimize performance
- Track costs (token usage)
- Detect resource leaks
- Plan capacity

---

## 📊 Metrics Tracked

### 1. Token Usage
```yaml
tokens:
  current_session: 131886
  remaining: 68114
  budget: 200000
  utilization: 65.9%

  history:
    - timestamp: "2026-02-01 04:00:00"
      used: 50000
      remaining: 150000

    - timestamp: "2026-02-01 04:30:00"
      used: 131886
      remaining: 68114
```

### 2. Memory Usage
```yaml
memory:
  current_process_mb: 245
  available_system_mb: 8192
  total_system_mb: 16384
  utilization: 50.0%

  peak_usage_mb: 512
  average_usage_mb: 280
```

### 3. Execution Time
```yaml
timing:
  session_start: "2026-02-01 03:00:00"
  session_duration_minutes: 90

  operations:
    - operation: "read_file"
      count: 45
      total_ms: 2340
      average_ms: 52

    - operation: "write_file"
      count: 12
      total_ms: 890
      average_ms: 74
```

### 4. Tool Usage
```yaml
tools:
  total_calls: 157

  by_tool:
    - name: "Read"
      calls: 45
      success: 45
      failure: 0
      avg_duration_ms: 52

    - name: "Bash"
      calls: 38
      success: 35
      failure: 3
      avg_duration_ms: 420

    - name: "Edit"
      calls: 22
      success: 22
      failure: 0
      avg_duration_ms: 85
```

---

## 🛠️ Implementation

### Resource Tracking File

**Location:** `C:\scripts\agentidentity\state\resource_usage.yaml`

**Updated:** Real-time during session

**Structure:**
```yaml
session_id: "session-2026-02-01-030000"
started_at: "2026-02-01 03:00:00"
last_updated: "2026-02-01 04:45:00"

tokens:
  budget: 200000
  used: 131886
  remaining: 68114
  percent: 65.9

memory:
  process_mb: 245
  available_mb: 8192
  percent: 3.0

timing:
  duration_minutes: 105
  operations_count: 157

alerts:
  - type: "warning"
    metric: "tokens"
    threshold: 80
    current: 65.9
    message: "Token usage approaching limit"
```

### Monitoring Tool

**Tool:** `monitor-resources.ps1`

```powershell
# Check current resource usage
.\monitor-resources.ps1

# Show detailed breakdown
.\monitor-resources.ps1 -Detailed

# Set alert thresholds
.\monitor-resources.ps1 -AlertTokens 80 -AlertMemory 90
```

### Automatic Tracking

Resources tracked automatically:
- **Before each tool call** - Check token budget
- **After each operation** - Update usage stats
- **Every 15 minutes** - Log snapshot
- **Session end** - Final summary

---

## 🚨 Alerts & Thresholds

### Token Budget Alerts

| Usage % | Alert Level | Action |
|---------|-------------|--------|
| 0-70% | Normal | Continue |
| 70-85% | Warning | Monitor closely, prefer concise responses |
| 85-95% | Critical | Minimize output, prioritize essential operations |
| 95-100% | Emergency | Stop non-essential work, save state |

### Memory Alerts

| Usage % | Alert Level | Action |
|---------|-------------|--------|
| 0-80% | Normal | Continue |
| 80-90% | Warning | Clean up temporary data |
| 90-95% | Critical | Release unused resources |
| 95-100% | Emergency | Terminate non-essential processes |

---

## 📊 Usage Reports

### Session Summary

```
========================================
Resource Usage Summary
========================================

Session Duration: 1h 45m
Token Usage: 131,886 / 200,000 (66%)
Memory Peak: 512 MB
Operations: 157 total (154 success, 3 failure)

Top Operations:
  1. Read file: 45 calls, 2.3s total
  2. Bash commands: 38 calls, 16.0s total
  3. Edit file: 22 calls, 1.9s total

Recommendations:
  - Token usage healthy (34% remaining)
  - No memory concerns
  - 3 failed operations - review logs
```

### Cost Tracking (Token-Based)

```yaml
costs:
  session_tokens: 131886

  # Estimated costs (if cloud API)
  estimated_cost_usd: 0.66  # $0.005 per 1K tokens

  breakdown:
    input_tokens: 115000
    output_tokens: 16886

  monthly_projection: 19.80  # Based on session rate
```

---

## 🎯 Use Cases

### Use Case 1: Prevent Token Exhaustion

```
Token usage at 85% → Alert triggered
Action: Switch to concise mode
Result: Completed session within budget
```

### Use Case 2: Detect Memory Leak

```
Memory usage growing steadily
Hour 1: 200MB → Hour 2: 400MB → Hour 3: 600MB

Action: Identified large file cache not being cleared
Fix: Implemented periodic cleanup
Result: Memory usage stabilized at 250MB
```

### Use Case 3: Optimize Performance

```
Analysis shows:
- File reads: 45 calls, 2.3s total
- 30 reads to same file

Action: Implement file content caching
Result: Reduced reads to 15, saved 1.5s
```

---

## 🔄 Integration

### With Executive Function
- Resource constraints inform planning
- High resource usage → Defer non-urgent tasks

### With Task Manager
- Track resource usage per task
- Identify resource-intensive operations
- Optimize task scheduling

### With Capability Confidence
- Resource efficiency affects confidence
- Operations that consistently use high resources → Lower confidence

---

## 📁 File Structure

```
C:\scripts\agentidentity\state\
├── resource_usage.yaml          # Current session
├── resource_history\
│   ├── 2026-02\
│   │   ├── session-2026-02-01-030000.yaml
│   │   └── session-2026-02-01-150000.yaml
│   └── monthly_summary.yaml
```

---

## 🚀 Future Enhancements

1. **Predictive Resource Planning** - Estimate resource needs before starting tasks
2. **Automatic Resource Optimization** - Detect inefficiencies, suggest improvements
3. **Cross-Session Analytics** - Identify long-term trends
4. **Cost Budgeting** - Set monthly token budgets, track spending
5. **Performance Baselines** - Compare current performance to historical averages

---

**Created:** 2026-02-01
**Status:** OPERATIONAL - Monitoring system implemented
**Coverage:** ACE Layer 3 gap closed
