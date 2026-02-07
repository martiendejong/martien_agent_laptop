# Work Tracking System - Complete Documentation

**Version:** 1.0.0
**Last Updated:** 2026-02-07
**Status:** Production Ready ✅

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Components](#components)
4. [Installation](#installation)
5. [Usage](#usage)
6. [API Reference](#api-reference)
7. [Troubleshooting](#troubleshooting)
8. [Maintenance](#maintenance)

---

## Overview

The Work Tracking System provides comprehensive, automatic tracking of all development work across multiple Claude agent instances.

### Key Features

- ✅ **Automatic Tracking** - Zero manual effort required
- ✅ **Multi-Agent Support** - Handles 7+ concurrent agents
- ✅ **Real-Time Dashboard** - Live HTML dashboard with 3s refresh
- ✅ **System Tray Integration** - Always-visible status indicator
- ✅ **Complete Audit Trail** - Immutable event log (JSONL)
- ✅ **Analytics Ready** - SQLite database for historical queries
- ✅ **Windows Native** - Tray app, taskbar, auto-startup

### What Gets Tracked

| Event | Data Captured |
|-------|---------------|
| **Work Started** | Agent ID, ClickUp task, branch, objective, repository, timestamp |
| **Status Changed** | Status (PLANNING/CODING/TESTING/etc.), phase, notes |
| **Work Completed** | PR number, outcome, duration, success/failure |

### Visual Outputs

| Component | Purpose | Location |
|-----------|---------|----------|
| **System Tray Icon** | Glanceable status (0/1-2/3+ agents) | Windows system tray |
| **HTML Dashboard** | Detailed real-time overview | `C:\scripts\_machine\work-dashboard.html` |
| **JSON State** | Current work state | `C:\scripts\_machine\work-state.json` |
| **Event Log** | Historical events | `C:\scripts\_machine\events\YYYY-MM-DD.jsonl` |
| **SQLite Database** | Analytics & queries | `C:\scripts\_machine\work-state.db` |

---

## Architecture

### Triple-Storage Pattern

```
┌─────────────────────────────────────────────────────┐
│  AGENTS (Auto-Integrated)                          │
│  ├─ work-tracking.psm1 auto-loaded via profile    │
│  └─ Functions: Start-Work, Update-Work, Complete-Work │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│  STORAGE LAYER (Triple Format)                     │
│  ├─ work-state.json      ← Current state (fast)    │
│  ├─ events/*.jsonl       ← Event log (audit)       │
│  └─ work-state.db        ← SQLite (analytics)      │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│  VISIBILITY LAYER (Multi-Channel)                  │
│  ├─ WorkTray.exe         ← System tray app         │
│  ├─ work-dashboard.html  ← Rich dashboard          │
│  └─ PowerShell cmdlets   ← CLI queries             │
└─────────────────────────────────────────────────────┘
```

### Why Triple Storage?

1. **JSON** - Fast reads, human-readable, real-time state
2. **JSONL** - Append-only event log, complete audit trail, time-travel debugging
3. **SQLite** - Advanced analytics, historical queries, aggregations

### Data Flow

```
Agent Action → PowerShell Function → Triple Write:
                                      ├─ Update JSON (sync)
                                      ├─ Append JSONL (sync)
                                      └─ Insert SQLite (async background job)
```

---

## Components

### 1. PowerShell Module (`work-tracking.psm1`)

**Location:** `C:\scripts\tools\work-tracking.psm1`

**Exported Functions:**
- `Start-Work` - Begin tracking a work session
- `Update-Work` - Update status/phase
- `Complete-Work` - Mark work as completed
- `Get-WorkState` - Query current state
- `Get-WorkHistory` - Query event history
- `Get-WorkMetrics` - Calculate productivity metrics
- `Clear-WorkState` - Clean up completed work

**Auto-Load:** Via PowerShell profile (`$PROFILE`)

### 2. System Tray App (`WorkTray.exe`)

**Location:** `C:\scripts\tools\WorkTray.exe`

**Features:**
- Icon reflects agent count (0 = gray, 1-2 = blue, 3+ = green)
- Hover tooltip shows active work summary
- Click opens HTML dashboard
- Right-click menu: Dashboard, Refresh, Settings, Exit
- Auto-starts with Windows

**Build:** `powershell.exe -File C:\scripts\tools\work-tray\build.ps1`

### 3. HTML Dashboard (`work-dashboard.html`)

**Location:** `C:\scripts\_machine\work-dashboard.html`

**Features:**
- Auto-refresh every 3 seconds
- Stats cards (active agents, tasks today, PRs, avg duration)
- Active work table (status, task, objective, phase, updated)
- Completed work table (last 10 completions)
- GitHub dark theme
- Responsive design

**Access:** Open in browser or via system tray app

### 4. SQLite Database (`work-state.db`)

**Location:** `C:\scripts\_machine\work-state.db`

**Schema:**
- `events` - All events (append-only)
- `work_sessions` - Work sessions with duration
- `agent_metrics` - Aggregated agent productivity
- `daily_summaries` - Daily stats

**Initialize:** `powershell.exe -File C:\scripts\tools\work-tracking-init-db.ps1`

---

## Installation

### Prerequisites

- Windows 10/11
- PowerShell 5.1 or later
- .NET 8.0 SDK (for building tray app)
- Git (for development workflows)

### Step-by-Step Installation

#### 1. Initialize Database

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\scripts\tools\work-tracking-init-db.ps1
```

**Expected Output:**
```
Installing PSSQLite module...
Initializing work tracking database...
✅ Database initialized successfully
```

#### 2. Build System Tray App

```powershell
cd C:\scripts\tools\work-tray
powershell.exe -NoProfile -ExecutionPolicy Bypass -File build.ps1
```

**Expected Output:**
```
Building Work Tracker System Tray App...
✅ Build successful!
Executable: C:\scripts\tools\WorkTray.exe
```

#### 3. Configure Auto-Startup

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\scripts\tools\work-tray-startup.ps1 -Action Enable
```

**Expected Output:**
```
✅ Work Tracker will now start automatically with Windows
```

#### 4. Update PowerShell Profile

The profile should already be created at:
```
C:\Users\HP\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

If not, create it with:

```powershell
# Work Tracking Auto-Load
$workTrackingModule = "C:\scripts\tools\work-tracking.psm1"
if (Test-Path $workTrackingModule) {
    Import-Module $workTrackingModule -Force -ErrorAction SilentlyContinue
    $env:AGENT_ID = Get-AgentId
}
```

#### 5. Start System Tray App

```powershell
Start-Process "C:\scripts\tools\WorkTray.exe"
```

You should see the tray icon appear in your system tray.

#### 6. Verify Installation

```powershell
# Test module loading
Import-Module C:\scripts\tools\work-tracking.psm1 -Force

# Test work tracking
Start-Work -Objective "Installation test"
Get-WorkState
Complete-Work -Outcome "Installation verified"

# Open dashboard
start C:\scripts\_machine\work-dashboard.html
```

---

## Usage

### For Agents (Automatic Integration)

Agents should call work tracking functions at key lifecycle points:

#### Starting Work

```powershell
Start-Work `
    -ClickUpTask "869c1xyz" `
    -Branch "agent-001-add-auth" `
    -Objective "Add user authentication" `
    -Repository "client-manager"
```

#### Updating Status

```powershell
# When starting to code
Update-Work -Status "CODING" -Phase "Development"

# When testing
Update-Work -Status "TESTING" -Phase "Build verification"

# When blocked
Update-Work -Status "BLOCKED" -Notes "Waiting for PR #506 to merge"
```

#### Completing Work

```powershell
Complete-Work `
    -PR "#507" `
    -Outcome "PR created, worktree released, tests passing"
```

### For Users (Dashboard Access)

#### Open Dashboard

1. **Via System Tray:** Click the tray icon
2. **Via File Explorer:** Open `C:\scripts\_machine\work-dashboard.html`
3. **Via Browser:** Navigate to file path

#### View Current State

```powershell
Get-WorkState | ConvertTo-Json -Depth 10
```

#### Query History

```powershell
# Today's events
Get-WorkHistory

# Specific agent
Get-WorkHistory -Agent "agent-001"

# Last 10 completions
Get-WorkHistory -EventType "work.completed" -Last 10
```

#### Get Metrics

```powershell
Get-WorkMetrics

# Output:
# date                 : 2026-02-07
# total_events         : 42
# total_completions    : 7
# total_prs            : 5
# avg_duration_minutes : 34.2
# success_rate         : 85.7
# agents_active        : 3
```

---

## API Reference

### Start-Work

Begin tracking a work session.

**Syntax:**
```powershell
Start-Work
    [-Agent <string>]
    [-ClickUpTask <string>]
    [-PR <string>]
    [-Branch <string>]
    -Objective <string>
    [-Repository <string>]
    [-WorktreePath <string>]
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| Agent | string | No | Agent ID (auto-detected if not provided) |
| ClickUpTask | string | No | ClickUp task ID (e.g., "869c1xyz") |
| PR | string | No | GitHub PR number (if working on existing PR) |
| Branch | string | No | Git branch name |
| Objective | string | **Yes** | Brief description of work (max 100 chars) |
| Repository | string | No | Repository name (auto-detected from git) |
| WorktreePath | string | No | Worktree path (auto-detected) |

**Examples:**
```powershell
# Minimal
Start-Work -Objective "Fix login bug"

# Full context
Start-Work `
    -ClickUpTask "869c1xyz" `
    -Branch "fix/login-bug" `
    -Objective "Fix login redirect issue" `
    -Repository "client-manager"
```

---

### Update-Work

Update work status or phase.

**Syntax:**
```powershell
Update-Work
    [-Agent <string>]
    [-Status <string>]
    [-Phase <string>]
    [-Notes <string>]
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| Agent | string | No | Agent ID (auto-detected) |
| Status | string | No | Work status (PLANNING, CODING, TESTING, REVIEWING, MERGING, BLOCKED, DONE) |
| Phase | string | No | Current work phase description |
| Notes | string | No | Additional notes about current state |

**Examples:**
```powershell
# Update status only
Update-Work -Status "CODING"

# Update status and phase
Update-Work -Status "TESTING" -Phase "Build verification"

# Add notes
Update-Work -Status "BLOCKED" -Notes "Waiting for dependency PR #506"
```

---

### Complete-Work

Mark work as completed.

**Syntax:**
```powershell
Complete-Work
    [-Agent <string>]
    [-PR <string>]
    -Outcome <string>
    [-Success <bool>]
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| Agent | string | No | Agent ID (auto-detected) |
| PR | string | No | GitHub PR number created |
| Outcome | string | **Yes** | Description of outcome/result |
| Success | bool | No | Whether work completed successfully (default: true) |

**Examples:**
```powershell
# Successful completion
Complete-Work -PR "#507" -Outcome "PR created, tests passing"

# Blocked completion
Complete-Work -Outcome "Task blocked, needs user input" -Success $false
```

---

### Get-WorkState

Query current work state.

**Syntax:**
```powershell
Get-WorkState
    [-Agent <string>]
    [-AsJson]
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| Agent | string | No | Filter by specific agent ID |
| AsJson | switch | No | Return as JSON string instead of object |

**Examples:**
```powershell
# Get all state
Get-WorkState

# Get specific agent
Get-WorkState -Agent "agent-001"

# Get as JSON
Get-WorkState -AsJson | Out-File state-backup.json
```

---

### Get-WorkHistory

Query work history from event logs.

**Syntax:**
```powershell
Get-WorkHistory
    [-Date <string>]
    [-Agent <string>]
    [-EventType <string>]
    [-Last <int>]
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| Date | string | No | Filter by date (YYYY-MM-DD, default: today) |
| Agent | string | No | Filter by agent ID |
| EventType | string | No | Filter by event type |
| Last | int | No | Return last N events |

**Examples:**
```powershell
# Today's events
Get-WorkHistory

# Yesterday's events
Get-WorkHistory -Date "2026-02-06"

# Agent-specific
Get-WorkHistory -Agent "agent-001"

# Completions only
Get-WorkHistory -EventType "work.completed"

# Last 5 events
Get-WorkHistory -Last 5
```

---

### Get-WorkMetrics

Calculate productivity metrics.

**Syntax:**
```powershell
Get-WorkMetrics
    [-Date <string>]
    [-Agent <string>]
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| Date | string | No | Date to analyze (YYYY-MM-DD, default: today) |
| Agent | string | No | Filter by specific agent |

**Examples:**
```powershell
# Today's metrics
Get-WorkMetrics

# Yesterday's metrics
Get-WorkMetrics -Date "2026-02-06"

# Agent-specific
Get-WorkMetrics -Agent "agent-001"
```

**Output:**
```powershell
@{
    date                 = "2026-02-07"
    total_events         = 42
    total_completions    = 7
    total_prs            = 5
    avg_duration_minutes = 34.2
    success_rate         = 85.7
    agents_active        = 3
}
```

---

### Clear-WorkState

Clean up completed work from active state.

**Syntax:**
```powershell
Clear-WorkState
    [-Agent <string>]
    [-Force]
    [-WhatIf]
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| Agent | string | No | Clear specific agent (default: all DONE agents) |
| Force | switch | No | Force clear even if not DONE |
| WhatIf | switch | No | Show what would be cleared without clearing |

**Examples:**
```powershell
# Clear all DONE agents
Clear-WorkState

# Clear specific agent
Clear-WorkState -Agent "agent-001"

# Force clear
Clear-WorkState -Agent "agent-001" -Force

# Preview what would be cleared
Clear-WorkState -WhatIf
```

---

## Troubleshooting

### Issue: Module Not Loading

**Symptoms:** `Import-Module: Cannot find path`

**Solution:**
```powershell
# Verify file exists
Test-Path C:\scripts\tools\work-tracking.psm1

# Check permissions
Get-Acl C:\scripts\tools\work-tracking.psm1

# Try manual import with verbose
Import-Module C:\scripts\tools\work-tracking.psm1 -Force -Verbose
```

---

### Issue: Agent ID Not Detected

**Symptoms:** Agent ID shows as "current-session"

**Solution:**
```powershell
# Manually set agent ID
$env:AGENT_ID = "agent-001"

# Verify
$env:AGENT_ID

# Or pass explicitly to functions
Start-Work -Agent "agent-001" -Objective "Test"
```

---

### Issue: State Not Updating

**Symptoms:** Dashboard shows stale data

**Solution:**
```powershell
# Check state file
Get-Content C:\scripts\_machine\work-state.json | ConvertFrom-Json

# Check recent events
Get-Content C:\scripts\_machine\events\$(Get-Date -Format 'yyyy-MM-dd').jsonl | Select-Object -Last 5

# Enable debug logging
$env:WORK_TRACKING_DEBUG = '1'

# Try operation again
Start-Work -Objective "Debug test"

# Check log
Get-Content C:\scripts\_machine\logs\work-tracking.log | Select-Object -Last 20
```

---

### Issue: Tray App Not Starting

**Symptoms:** No tray icon visible

**Solution:**
```powershell
# Check if executable exists
Test-Path C:\scripts\tools\WorkTray.exe

# Rebuild if missing
cd C:\scripts\tools\work-tray
.\build.ps1

# Start manually
Start-Process C:\scripts\tools\WorkTray.exe

# Check auto-startup status
.\tools\work-tray-startup.ps1 -Action Status
```

---

### Issue: Dashboard Shows Error

**Symptoms:** "Error loading dashboard" message

**Solution:**
```powershell
# Verify state file exists
Test-Path C:\scripts\_machine\work-state.json

# Check JSON validity
Get-Content C:\scripts\_machine\work-state.json | ConvertFrom-Json

# Recreate empty state if corrupted
@{
    version = "1.0.0"
    agents = @{}
    summary = @{ active_agents = 0; total_tasks_today = 0; prs_created_today = 0; current_phase_counts = @{} }
    history = @{ last_10_completions = @() }
    metadata = @{ last_updated = (Get-Date).ToUniversalTime().ToString("o"); tracking_started = (Get-Date).ToUniversalTime().ToString("o") }
} | ConvertTo-Json -Depth 10 | Set-Content C:\scripts\_machine\work-state.json
```

---

## Maintenance

### Daily Maintenance (Automatic)

The system is designed for zero-maintenance operation:

- **State file** - Continuously updated, no cleanup needed
- **Event logs** - One file per day, automatic rotation
- **SQLite** - Append-only, no maintenance needed

### Monthly Maintenance (Optional)

#### Archive Old Event Logs

```powershell
# Move events older than 30 days to archive
$archivePath = "C:\scripts\_machine\events\archive"
New-Item -ItemType Directory -Path $archivePath -Force | Out-Null

Get-ChildItem C:\scripts\_machine\events\*.jsonl |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
    Move-Item -Destination $archivePath
```

#### Vacuum SQLite Database

```powershell
# Compact database (optional, reduces file size)
Import-Module PSSQLite
Invoke-SqliteQuery -DataSource C:\scripts\_machine\work-state.db -Query "VACUUM"
```

#### Clear Old Completions from State

```powershell
# Remove DONE entries older than 24 hours
$state = Get-Content C:\scripts\_machine\work-state.json | ConvertFrom-Json -AsHashtable

$state.agents = $state.agents.GetEnumerator() | Where-Object {
    $_.Value.status -ne 'DONE' -or
    ((Get-Date) - [datetime]::Parse($_.Value.completed)).TotalHours -lt 24
} | ConvertFrom-Json -AsHashtable

$state | ConvertTo-Json -Depth 10 | Set-Content C:\scripts\_machine\work-state.json
```

---

## Files Reference

### Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| `work-tracking.psm1` | Main PowerShell module | `C:\scripts\tools\` |
| `Microsoft.PowerShell_profile.ps1` | PowerShell profile (auto-load) | `C:\Users\HP\Documents\WindowsPowerShell\` |

### Data Files

| File | Purpose | Location |
|------|---------|----------|
| `work-state.json` | Current work state | `C:\scripts\_machine\` |
| `YYYY-MM-DD.jsonl` | Daily event log | `C:\scripts\_machine\events\` |
| `work-state.db` | SQLite database | `C:\scripts\_machine\` |

### Application Files

| File | Purpose | Location |
|------|---------|----------|
| `WorkTray.exe` | System tray app | `C:\scripts\tools\` |
| `work-dashboard.html` | HTML dashboard | `C:\scripts\_machine\` |

### Documentation Files

| File | Purpose | Location |
|------|---------|----------|
| `WORK_TRACKING_SYSTEM.md` | This file | `C:\scripts\` |
| `work-tracking-integration.md` | Integration guide | `C:\scripts\tools\` |

---

## Support

### Getting Help

1. **Check Troubleshooting section** (above)
2. **Enable debug logging:** `$env:WORK_TRACKING_DEBUG = '1'`
3. **Check log files:** `C:\scripts\_machine\logs\work-tracking.log`
4. **Verify state file:** `Get-Content C:\scripts\_machine\work-state.json`

### Reporting Issues

Include in bug reports:
- PowerShell version (`$PSVersionTable`)
- Module version (`Import-Module work-tracking; (Get-Module work-tracking).Version`)
- Error messages (full text)
- Log excerpts (`work-tracking.log`)
- State file snapshot (`work-state.json`)

---

**Version:** 1.0.0
**Last Updated:** 2026-02-07
**Maintained By:** Work Tracking System
**License:** MIT
