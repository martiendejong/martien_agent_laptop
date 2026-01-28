# File-Based Session Logging Pattern

**Created:** 2026-01-28
**Context:** Hazina Agentic Orchestration - Terminal Session Logging
**Applicable To:** Any multi-session system requiring audit trails

---

## Problem Statement

Multi-session systems (agent terminals, user sessions, API request logs) generate many log files. Flat directory structures become unmanageable:
- Hard to find logs by time
- Slow directory listing
- Difficult cleanup (can't easily delete old logs)
- No natural organization

---

## Solution: Hierarchical Date-Based Directory Structure

### Directory Pattern

```
{BasePath}/{yyyy-MM-dd}/{HH}/session-{sessionId}.log
```

### Example Structure

```
C:\scripts\logs\agent-sessions\
├── 2026-01-28\
│   ├── 14\
│   │   ├── session-20260128-143052-abc12345.log
│   │   └── session-20260128-145530-def67890.log
│   └── 15\
│       └── session-20260128-150102-ghi11111.log
└── 2026-01-29\
    └── 09\
        └── session-20260129-091523-jkl22222.log
```

### Benefits

| Benefit | Explanation |
|---------|-------------|
| **Bounded file count** | Max ~60 files per hour-folder (realistic for most systems) |
| **Easy cleanup** | Delete old date folders: `Remove-Item -Recurse 2026-01-20` |
| **Easy browsing** | Find sessions by date/time intuitively |
| **No index needed** | Filesystem IS the index |
| **Parallel-safe** | Different sessions write different files |

### Implementation (C#)

```csharp
private string BuildFilePath(string sessionId, DateTime timestamp)
{
    var datePart = timestamp.ToString("yyyy-MM-dd");
    var hourPart = timestamp.ToString("HH");
    var fileName = $"session-{sessionId}.log";

    return Path.Combine(_basePath, datePart, hourPart, fileName);
}
```

---

## Pattern: Null Implementation for Optional Services

### Problem

Optional services require null checks everywhere:
```csharp
// Bad - null checks everywhere
if (_logger != null) await _logger.LogAsync(...);
```

### Solution

Register a NullLogger when logging is disabled:

```csharp
if (options.EnableSessionLogging)
    services.AddSingleton<IAgentSessionLogger>(new AgentSessionLogger(path));
else
    services.TryAddSingleton<IAgentSessionLogger>(new NullAgentSessionLogger());
```

```csharp
// NullAgentSessionLogger - all methods are no-ops
public class NullAgentSessionLogger : IAgentSessionLogger
{
    public Task StartSessionAsync(...) => Task.CompletedTask;
    public Task LogOutputAsync(...) => Task.CompletedTask;
    public Task LogInputAsync(...) => Task.CompletedTask;
    public Task EndSessionAsync(...) => Task.CompletedTask;
}
```

### Benefits

- Zero null checks in consuming code
- Feature toggles work seamlessly
- DI container always provides valid implementation
- Clean separation of concerns

---

## Pattern: Control Character Visualization

### Problem

Raw control characters (Ctrl+C, CR/LF, ESC) are invisible in logs, making debugging difficult.

### Solution

Format input for human readability:

```csharp
private static string FormatInputForDisplay(string text)
{
    var sb = new StringBuilder();
    foreach (var c in text)
    {
        switch (c)
        {
            case '\r': sb.Append("[CR]"); break;
            case '\n': sb.Append("[LF]"); break;
            case '\t': sb.Append("[TAB]"); break;
            case '\x03': sb.Append("[Ctrl+C]"); break;
            case '\x04': sb.Append("[Ctrl+D]"); break;
            case '\x1B': sb.Append("[ESC]"); break;
            case '\x7F': sb.Append("[DEL]"); break;
            default:
                if (c < 32)
                    sb.Append($"[^{(char)(c + 64)}]");
                else
                    sb.Append(c);
                break;
        }
    }
    return sb.ToString();
}
```

### Log Output Example

```
[14:31:15.012] [INPUT] >>> fix the bug[CR][LF]
[14:32:00.456] [INPUT] >>> [Ctrl+C]
[14:32:05.789] [INPUT] >>> y[CR][LF]
```

---

## Pattern: SignalR Event Interception for Logging

### Problem

Need to log I/O flowing through existing SignalR hub without breaking existing flow or adding complexity.

### Solution

Add logging calls BEFORE forwarding to existing handlers:

```csharp
session.OnOutput += async (data) =>
{
    // Log first (non-critical - failures shouldn't break main flow)
    await _sessionLogger.LogOutputAsync(sessionId, data);

    // Then forward to existing SignalR handler
    var intArray = data.Select(b => (int)b).ToArray();
    await _hubContext.Clients.Group($"terminal-{sessionId}")
        .SendAsync("OnOutput", sessionId, intArray);
};
```

### Key Decisions

| Decision | Rationale |
|----------|-----------|
| **Log before forward** | Capture even if forward fails |
| **Don't await logging** | Logging failure shouldn't block main flow |
| **Same handler chain** | No new event infrastructure needed |

---

## Log File Format

### Header (Session Start)

```
═══════════════════════════════════════════════════════════════════
AGENT SESSION LOG
═══════════════════════════════════════════════════════════════════
Session ID:        20260128-143052-abc12345
Command:           claude_agent.bat
Working Directory: C:\scripts
Started:           2026-01-28 14:30:52.123
═══════════════════════════════════════════════════════════════════
```

### Body (During Session)

```
[14:30:52.456] [OUT] Starting Claude agent...
[14:30:53.789] [OUT] > Ready for input

[14:31:15.012] [INPUT] >>> fix the bug[CR][LF]

[14:31:15.234] [OUT] Analyzing code...
```

### Footer (Session End)

```
═══════════════════════════════════════════════════════════════════
SESSION ENDED
═══════════════════════════════════════════════════════════════════
Ended:    2026-01-28 15:45:30.789
Duration: 01:14:38.666
Exit Code: 0
═══════════════════════════════════════════════════════════════════
```

---

## Configuration Pattern

### appsettings.json

```json
"SessionLogging": {
  "Enabled": true,
  "BasePath": "C:\\scripts\\logs\\agent-sessions"
}
```

### Design Decision: Default Enabled

Logging should be **opt-out, not opt-in**:
- Debugging without logs is painful
- Storage is cheap
- Enable by default, let users disable if needed

---

## Implementation Reference

**Hazina Implementation:**
- Interface: `Hazina.AgenticOrchestration.Services.IAgentSessionLogger`
- Implementation: `AgentSessionLogger` (file-based)
- Null Implementation: `NullAgentSessionLogger`
- Integration: `TerminalSessionManager` (output) + `TerminalHub` (input)
- Config: `AgenticOrchestrationOptions.EnableSessionLogging`, `.AgentSessionLogsPath`

---

## When to Use This Pattern

| Scenario | Use This Pattern? |
|----------|-------------------|
| Multi-agent terminal sessions | ✅ Yes |
| API request/response logging | ✅ Yes (by date/hour) |
| User session audit trails | ✅ Yes |
| High-volume event streams | ⚠️ Consider database instead |
| Single-process debug logging | ❌ Use standard ILogger |

---

## Related Patterns

- **Structured Logging** (Serilog, seq) - For searchable logs
- **Event Sourcing** - For replay capability
- **Audit Trails** - For compliance requirements
- **Centralized Logging** (ELK, Splunk) - For distributed systems
