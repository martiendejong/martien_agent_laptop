# ClickUp Task Operations v2 - Improvements

**Version:** 2.0
**Created:** 2026-02-15

## What's New in v2

### 1. DryRun Mode 🎯
Test operations without making actual changes:
```powershell
powershell -File C:\scripts\tools\clickup-task-operations-v2.ps1 `
    -Action StartWork `
    -TaskId 869abc123 `
    -DryRun
```

**Output:**
```
[DRY-RUN MODE - No actual changes will be made]
[DRY-RUN] Would call: PUT https://api.clickup.com/api/v2/task/869abc123
[DRY-RUN] Body: {"status":"busy"}
```

### 2. Automatic Retry Logic 🔄
Handles transient API failures with exponential backoff:
- Retries on timeout, connection errors, and rate limits (429)
- Configurable max retries (default: 3)
- Exponential backoff: 1s, 2s, 4s

```powershell
# Custom retry count
-MaxRetries 5
```

### 3. Rollback on Failure ↩️
If operation fails midway, automatically undos completed steps:

**Example:** StartWork fails at step 3 (assign):
1. Status changed todo → busy ✓
2. Assignee added ✓
3. Comment post FAILS ❌

**Rollback:**
- Remove assignee
- Revert status to todo
- Task returns to original state

### 4. State Validation ✅
Checks task is in expected state before operation:

**StartWork:**
- Expected: todo, backlog, needs refinement
- Warning if task is in different state

**SubmitForReview:**
- Expected: busy, in progress, doing
- Warning if task is in different state

```
WARNING: Task is in 'blocked' but expected one of: busy, in progress, doing
Proceeding anyway...
```

### 5. Custom Comments 💬
Override default comment text:
```powershell
powershell -File C:\scripts\tools\clickup-task-operations-v2.ps1 `
    -Action StartWork `
    -TaskId 869abc123 `
    -CustomComment "Implementing media library feature - Jengo"
```

### 6. History Logging 📝
Audit trail of all operations:

**History file:** `C:\scripts\_machine\clickup-operations-history.jsonl`

**View history:**
```powershell
powershell -File C:\scripts\tools\clickup-task-operations-v2.ps1 -Action GetHistory
```

**Output:**
```
=== Recent Operations (last 20) ===
[2026-02-15T22:15:30.123Z] StartWork on 869abc123 - success
[2026-02-15T22:20:45.456Z] SubmitForReview on 869abc123 - success
```

**With verbose:**
```powershell
-Action GetHistory -VerboseLogging
```

### 7. JSON Output Mode 📊
Machine-readable output for automation:
```powershell
powershell -File C:\scripts\tools\clickup-task-operations-v2.ps1 `
    -Action GetUnassigned `
    -Project client-manager `
    -Status todo `
    -JsonOutput
```

**Returns:**
```json
[
  {
    "id": "869abc123",
    "name": "Implement feature X",
    "status": {"status": "todo"},
    "url": "https://app.clickup.com/t/869abc123"
  }
]
```

### 8. Verbose Mode 🔍
Detailed logging for debugging:
```powershell
-VerboseLogging
```

**Output:**
```
[VERBOSE] API GET /task/869abc123 (attempt 1/3)
[VERBOSE] API call succeeded
[VERBOSE] Rollback action added: Revert status to todo
[VERBOSE] Logged to history: StartWork on 869abc123
```

### 9. Enhanced Validation 🛡️
- **TaskId format validation:** Must be 9+ alphanumeric characters
- **Project validation:** Checks project exists in config
- **Status validation:** Warns if task not in expected state

### 10. Better Error Messages 📢
More context in error messages:
```
ERROR: Invalid TaskId format: abc (expected 9+ alphanumeric characters)
ERROR: Task is in 'blocked' but expected one of: busy, in progress, doing
ERROR: API call failed: 429 Too Many Requests
```

---

## Comparison: v1 vs v2

| Feature | v1 | v2 |
|---------|----|----|
| DryRun mode | ❌ | ✅ |
| Retry logic | ❌ | ✅ (3 attempts) |
| Rollback on failure | ❌ | ✅ |
| State validation | ❌ | ✅ |
| Custom comments | ❌ | ✅ |
| History logging | ❌ | ✅ |
| JSON output | ❌ | ✅ |
| Verbose mode | ❌ | ✅ |
| TaskId validation | ❌ | ✅ |
| Error messages | Basic | Enhanced |

---

## Migration from v1 to v2

v2 is **backward compatible** - all v1 commands work in v2:

**v1 command:**
```powershell
powershell -File C:\scripts\tools\clickup-task-operations.ps1 -Action StartWork -TaskId 869abc123
```

**v2 equivalent (same command works):**
```powershell
powershell -File C:\scripts\tools\clickup-task-operations-v2.ps1 -Action StartWork -TaskId 869abc123
```

**Optional v2 enhancements:**
```powershell
# Add DryRun
-DryRun

# Add verbose logging
-VerboseLogging

# Add custom comment
-CustomComment "Starting implementation"

# Combine all
-DryRun -VerboseLogging -CustomComment "Test run"
```

---

## Usage Examples

### Safe Testing with DryRun
```powershell
# Test before executing
powershell -File C:\scripts\tools\clickup-task-operations-v2.ps1 `
    -Action StartWork `
    -TaskId 869abc123 `
    -DryRun -VerboseLogging

# If looks good, run without DryRun
powershell -File C:\scripts\tools\clickup-task-operations-v2.ps1 `
    -Action StartWork `
    -TaskId 869abc123
```

### Custom Comment
```powershell
powershell -File C:\scripts\tools\clickup-task-operations-v2.ps1 `
    -Action StartWork `
    -TaskId 869abc123 `
    -CustomComment "Started: Implementing user authentication system"
```

### Review with Custom Comment and PR
```powershell
powershell -File C:\scripts\tools\clickup-task-operations-v2.ps1 `
    -Action SubmitForReview `
    -TaskId 869abc123 `
    -PrUrl "https://github.com/user/repo/pull/456" `
    -CustomComment "Implementation complete. Added JWT auth with refresh tokens."
```

### JSON Output for Scripting
```powershell
$Tasks = powershell -File C:\scripts\tools\clickup-task-operations-v2.ps1 `
    -Action GetUnassigned `
    -Project client-manager `
    -Status todo `
    -JsonOutput | ConvertFrom-Json

foreach ($Task in $Tasks) {
    Write-Host "Task: $($Task.name) ($($Task.id))"
}
```

### Check History
```powershell
# Last 20 operations
powershell -File C:\scripts\tools\clickup-task-operations-v2.ps1 -Action GetHistory

# With verbose details
powershell -File C:\scripts\tools\clickup-task-operations-v2.ps1 -Action GetHistory -VerboseLogging
```

---

## Error Recovery Example

**Scenario:** Network fails during StartWork

```
=== Starting work on task 869abc123 ===
Fetching task details...
Task: Implement media library
Current status: todo
Moving to 'busy' status...
[VERBOSE] API PUT /task/869abc123 (attempt 1/3)
[VERBOSE] API call failed: timeout
Retrying in 1 seconds...
[VERBOSE] API PUT /task/869abc123 (attempt 2/3)
[VERBOSE] API call succeeded
Assigning to user 74525428...
[VERBOSE] API PUT /task/869abc123 (attempt 1/3)
[VERBOSE] API call failed: connection refused
Retrying in 2 seconds...
[VERBOSE] API PUT /task/869abc123 (attempt 2/3)
[VERBOSE] API call failed: connection refused
Retrying in 4 seconds...
[VERBOSE] API PUT /task/869abc123 (attempt 3/3)
[VERBOSE] API call failed: connection refused

[ROLLBACK] Undoing 1 actions...
  Undoing: Revert status to todo

ERROR: API call failed: connection refused
```

**Result:** Task returned to original state (todo, unassigned)

---

## Recommendations

1. **Always use DryRun first** for new operations
2. **Enable Verbose** when debugging issues
3. **Use JsonOutput** for automation scripts
4. **Check GetHistory** regularly to audit operations
5. **Keep v1 as backup** until v2 is fully tested

---

**Last Updated:** 2026-02-15
