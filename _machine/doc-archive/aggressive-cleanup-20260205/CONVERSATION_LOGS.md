# Conversation Logs - Complete Reference

**Created:** 2026-01-28
**Purpose:** Document conversation log locations and recovery procedures

---

## 📍 Log Locations

### Primary Conversation Storage
```
C:\Users\HP\.claude\projects\<PROJECT-PATH>\<SESSION-ID>.jsonl
```

**Project paths are encoded:**
- `C:\scripts` → `C--scripts`
- `C:\Projects\client-manager` → `C--Projects-client-manager`
- `C:\Projects\hazina` → `C--Projects-hazina`

### Key Directories

| Directory | Purpose |
|-----------|---------|
| `C:\Users\HP\.claude\` | Claude Code user data root |
| `C:\Users\HP\.claude\history.jsonl` | All prompts (user messages only, 4700+ entries) |
| `C:\Users\HP\.claude\projects\` | Per-project conversation storage |
| `C:\Users\HP\.claude\projects\C--scripts\` | Scripts project sessions (~570 sessions, 1.8GB) |
| `C:\Users\HP\.claude\todos\` | Task lists per session |
| `C:\Users\HP\.claude\shell-snapshots\` | Shell state snapshots |
| `C:\Users\HP\.claude\file-history\` | File modification history |

### Session File Structure

Each session is stored as `<UUID>.jsonl` (JSON Lines format):

```jsonl
{"type":"file-history-snapshot","messageId":"...","snapshot":{...}}
{"type":"user","message":{"role":"user","content":"..."},"uuid":"...","timestamp":"..."}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"thinking","thinking":"..."},{"type":"text","text":"..."}]},"uuid":"...","timestamp":"..."}
```

**Message Types:**
- `user` - User messages
- `assistant` - Claude responses (includes thinking + text)
- `file-history-snapshot` - File state snapshots
- `summary` - Conversation summaries (indicates clean end)

**Key Fields:**
- `uuid` - Unique message ID
- `parentUuid` - Links to parent message (conversation threading)
- `timestamp` - ISO 8601 timestamp
- `sessionId` - Session identifier
- `message.content` - For assistant, array with `thinking` and `text` blocks

---

## 🔍 Detecting Crashed Sessions

A session is considered "crashed" if:
1. **No summary message** - Clean sessions end with a summary
2. **Abrupt timestamp gap** - Last message followed by nothing
3. **Incomplete assistant response** - `stop_reason` is not "end_turn"
4. **Active tool calls** - Last message was a tool call without result

---

## 🛠️ Available Tools

| Tool | Purpose |
|------|---------|
| `get-crashed-sessions.ps1` | List sessions that crashed/were interrupted |
| `session-browser.ps1` | Search and browse conversation history |
| `session-restore.ps1` | Generate context to restore a crashed session |
| `session-export.ps1` | Export session to readable markdown |

---

## 📋 Quick Commands

```powershell
# Find all crashed sessions from last 7 days
.\tools\get-crashed-sessions.ps1 -Days 7

# Search conversations for keyword
.\tools\session-browser.ps1 -Search "migration error"

# Get context to restore specific session
.\tools\session-restore.ps1 -SessionId "abc123..."

# Export session to markdown
.\tools\session-export.ps1 -SessionId "abc123..." -Output "session.md"
```

---

## 🔄 Session Recovery Workflow

1. **Detect crash:** Run `get-crashed-sessions.ps1`
2. **Review context:** Use `session-browser.ps1` to see what was happening
3. **Generate restore context:** Run `session-restore.ps1 -SessionId <id>`
4. **Start new session:** New Claude session with restore context pasted
5. **Continue work:** Claude picks up where it left off

---

## 📊 Statistics Commands

```powershell
# Count sessions per project
Get-ChildItem "C:\Users\HP\.claude\projects\*\*.jsonl" |
    Group-Object { Split-Path (Split-Path $_.FullName -Parent) -Leaf } |
    Sort-Object Count -Descending

# Total storage by project
Get-ChildItem "C:\Users\HP\.claude\projects\*" -Directory |
    ForEach-Object {
        [PSCustomObject]@{
            Project = $_.Name
            Size = "{0:N2} MB" -f ((Get-ChildItem $_.FullName -Recurse | Measure-Object Length -Sum).Sum / 1MB)
        }
    }
```
