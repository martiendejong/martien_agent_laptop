# ClickUp Task Operations v3 - Advanced Features

**Version:** 3.0
**Created:** 2026-02-15

## New in v3: 10 Advanced Features

### 1. 🔄 Batch Operations
Process multiple tasks in one command:

```powershell
# Start work on 5 tasks at once
powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 `
    -Action BatchStartWork `
    -Project client-manager `
    -TaskIds 869abc123,869def456,869ghi789,869jkl012,869mno345
```

**Output:**
```
=== Batch StartWork on 5 tasks ===

[1/5] Processing 869abc123...
✓ Task 869abc123 ready for work! (1243ms)

[2/5] Processing 869def456...
✓ Task 869def456 ready for work! (987ms)

...

=== Batch Complete ===
Success: 5 / 5
Failed: 0 / 5
```

### 2. 🧠 Smart Status Detection
Auto-detects project-specific status names (no hardcoded "busy"/"review"):

**How it works:**
- Queries project statuses via API
- Categorizes into: todo, work, review, done
- Caches for 24 hours
- Uses first match in category

**Example:**
```
client-manager uses: "busy" (work), "review" (review)
hazina uses: "in progress" (work), "testing" (review)
```

**Cache location:** `C:\scripts\_machine\clickup-status-cache.json`

### 3. 🔍 Task Search
Advanced search with multiple filters:

```powershell
# Search by term
powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 `
    -Action Search `
    -Project client-manager `
    -SearchTerm "authentication"

# Search by priority
-Priority high

# Search by tags
-Tags "backend","api"

# Combine filters
-SearchTerm "login" -Priority urgent -Tags "security"
```

**Output:**
```
Found 3 matching tasks:
  [todo] Implement JWT authentication
    ID: 869abc123
    Priority: high
    Tags: backend, security
  [busy] Fix OAuth callback bug
    ID: 869def456
    Priority: urgent
    Tags: bug, security
```

### 4. ↩️ Undo Command
Rollback last operation:

```powershell
powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 -Action Undo
```

**What it undoes:**
- StartWork: Reverts status + removes assignee
- SubmitForReview: Reverts status

**Output:**
```
=== Undoing Last Operation ===
Operation: StartWork
Task: 869abc123
Time: 2026-02-15T22:30:45.123Z
Reverting status to 'todo'...
Removing assignee...

✓ Undone: Task returned to 'todo'
```

### 5. 📊 Stats Dashboard
Productivity metrics:

```powershell
# Last 7 days (default)
powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 -Action Stats

# Last 30 days
-Action Stats -DaysBack 30
```

**Output:**
```
=== Stats (Last 7 Days) ===
Total Operations: 45
  Success: 43 (95.6%)
  Failed: 2 (4.4%)
Average Duration: 1247ms

Breakdown:
  StartWork: 23
  SubmitForReview: 20
```

### 6. 🔗 PR Auto-Detection
Auto-detect PR URL from git branch:

```powershell
powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 `
    -Action SubmitForReview `
    -Project client-manager `
    -TaskId 869abc123 `
    -AutoDetectPR
```

**How it works:**
1. Reads current git branch
2. Queries GitHub via `gh` CLI
3. Finds PR for branch
4. Adds PR URL to comment

**Requirements:**
- Must be in git repo
- `gh` CLI installed and authenticated
- PR must exist for current branch

### 7. ⏱️ Time Tracking
Logs operation duration:

```
✓ Task 869abc123 ready for work! (1247ms)
```

**History includes duration:**
```
[2026-02-15T22:30:45.123Z] StartWork on 869abc123 - success (1247ms)
```

**Uses:**
- Performance monitoring
- Slow operation detection
- API health tracking

### 8. 🎯 Interactive Mode
Wizard for task selection:

```powershell
powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 `
    -Action StartWork `
    -Project client-manager `
    -Interactive
```

**Workflow:**
```
=== Interactive Task Selection ===

Select tasks (comma-separated numbers, e.g., 1,3,5):
  [1] Implement media library
  [2] Fix login bug
  [3] Add user profile page
  [4] Optimize database queries
  [5] Write API docs

Your selection: 1,3

Selected 2 tasks. Start work? (y/n): y

=== Batch StartWork on 2 tasks ===
...
```

### 9. 💾 Smart Caching
Status cache with 24-hour expiry:

**Cache file:** `C:\scripts\_machine\clickup-status-cache.json`

**Benefits:**
- Faster operations (no API call for statuses)
- Reduced API rate limit usage
- Auto-refresh after 24 hours

**Manual cache refresh:**
Delete cache file to force refresh.

### 10. 📈 Performance Tracking
Total operation time logged:

```
[PERFORMANCE] Total operation time: 2345ms
```

Shows with `-VerboseLogging`.

---

## Complete Feature Comparison

| Feature | v1 | v2 | v3 |
|---------|----|----|-----|
| Basic operations | ✅ | ✅ | ✅ |
| DryRun mode | ❌ | ✅ | ✅ |
| Retry logic | ❌ | ✅ | ✅ |
| Rollback | ❌ | ✅ | ✅ |
| State validation | ❌ | ✅ | ✅ |
| Custom comments | ❌ | ✅ | ✅ |
| History logging | ❌ | ✅ | ✅ |
| JSON output | ❌ | ✅ | ✅ |
| Verbose logging | ❌ | ✅ | ✅ |
| **Batch operations** | ❌ | ❌ | ✅ |
| **Smart status detection** | ❌ | ❌ | ✅ |
| **Task search** | ❌ | ❌ | ✅ |
| **Undo command** | ❌ | ❌ | ✅ |
| **Stats dashboard** | ❌ | ❌ | ✅ |
| **PR auto-detection** | ❌ | ❌ | ✅ |
| **Time tracking** | ❌ | ❌ | ✅ |
| **Interactive mode** | ❌ | ❌ | ✅ |
| **Smart caching** | ❌ | ❌ | ✅ |
| **Performance tracking** | ❌ | ❌ | ✅ |

---

## Usage Examples

### Batch Start Work
```powershell
# Get unassigned tasks
$Tasks = powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 `
    -Action GetUnassigned `
    -Project client-manager `
    -Status todo `
    -JsonOutput | ConvertFrom-Json

# Start work on first 5
$TaskIds = ($Tasks | Select-Object -First 5).id
powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 `
    -Action BatchStartWork `
    -Project client-manager `
    -TaskIds ($TaskIds -join ',')
```

### Search High Priority Tasks
```powershell
powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 `
    -Action Search `
    -Project client-manager `
    -Priority high `
    -Tags "backend"
```

### Submit with Auto-Detected PR
```powershell
# From feature branch with open PR
powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 `
    -Action SubmitForReview `
    -Project client-manager `
    -TaskId 869abc123 `
    -AutoDetectPR
```

### Check Stats
```powershell
# This week
powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 -Action Stats

# This month
powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 -Action Stats -DaysBack 30

# JSON output for scripts
powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 `
    -Action Stats `
    -DaysBack 7 `
    -JsonOutput
```

### Undo Mistake
```powershell
# Accidentally started work on wrong task
powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 `
    -Action StartWork `
    -Project client-manager `
    -TaskId 869WRONG

# Undo it
powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 -Action Undo
```

### Interactive Workflow
```powershell
# Interactive task selection
powershell -File C:\scripts\tools\clickup-task-operations-v3.ps1 `
    -Action StartWork `
    -Project client-manager `
    -Interactive
```

---

## Performance Optimizations

### Smart Caching
- First run: ~2000ms (API call for statuses)
- Cached runs: ~500ms (no status API call)
- Cache valid: 24 hours

### Batch Operations
- Sequential: 5 tasks × 1200ms = 6000ms
- Batch: 5 tasks in 6500ms (overhead: 500ms)
- Savings: Minimal, but better error handling

### PR Auto-Detection
- Cache miss: +200ms (gh CLI call)
- Cache hit: +5ms (read from git config)

---

## Migration from v2

v3 is **backward compatible** with v2:

**All v2 commands work in v3:**
```powershell
# v2 command
powershell -File clickup-task-operations-v2.ps1 -Action StartWork -TaskId 869abc123

# Same in v3 (but now requires -Project for smart status)
powershell -File clickup-task-operations-v3.ps1 `
    -Action StartWork `
    -Project client-manager `
    -TaskId 869abc123
```

**Breaking change:** `-Project` parameter now REQUIRED for StartWork/SubmitForReview (needed for smart status detection).

**Recommended upgrade path:**
1. Test v3 with `-DryRun` first
2. Run Stats to verify history compatibility
3. Use v3 for new workflows
4. Keep v2 as fallback for 1 week

---

## Advanced Patterns

### Daily Workflow Script
```powershell
# 1. Check stats from yesterday
powershell -File clickup-task-operations-v3.ps1 -Action Stats -DaysBack 1

# 2. Find high-priority unassigned tasks
$Tasks = powershell -File clickup-task-operations-v3.ps1 `
    -Action Search `
    -Project client-manager `
    -Priority high `
    -JsonOutput | ConvertFrom-Json

# 3. Interactive selection
if ($Tasks.Count -gt 0) {
    powershell -File clickup-task-operations-v3.ps1 `
        -Action StartWork `
        -Project client-manager `
        -Interactive
}
```

### Bulk Review Submission
```powershell
# Get all tasks in 'busy' status assigned to me
$MyTasks = powershell -File clickup-task-operations-v3.ps1 `
    -Action Search `
    -Project client-manager `
    -Status busy `
    -JsonOutput | ConvertFrom-Json | Where-Object {
        $_.assignees.id -contains 74525428
    }

# Submit all with auto-detected PRs
foreach ($Task in $MyTasks) {
    powershell -File clickup-task-operations-v3.ps1 `
        -Action SubmitForReview `
        -Project client-manager `
        -TaskId $Task.id `
        -AutoDetectPR
}
```

---

**Last Updated:** 2026-02-15
