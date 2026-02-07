# Session Manager - Complete Guide
**Created:** 2026-02-07 (Iteration #7-8)
**Status:** ACTIVE - Full session management suite

---

## 🎯 Quick Commands (Dutch)

| Wat je wilt doen | Command |
|------------------|---------|
| **Toon alle sessies** | `toon-sessies` |
| **Toon laatste 20** | `toon-sessies -Aantal 20` |
| **Herstel laatste sessie** | `herstel-sessie` |
| **Herstel specifieke sessie** | `herstel-sessie fc0bbf6c` |
| **Zoek in sessies** | `zoek-sessies "worktree"` |
| **Preview sessie** | `preview-sessie fc0bbf6c` |
| **Export naar markdown** | `export-sessie fc0bbf6c` |
| **Toon statistieken** | `sessie-stats` |

---

## 📊 Feature Overview

### 1. List Sessions (`toon-sessies`)
**Toont alle actieve en gearchiveerde sessies**

```powershell
# Toon laatste 15 sessies
toon-sessies

# Toon laatste 50
toon-sessies -Aantal 50

# Alleen gearchiveerde
toon-sessies gearchiveerd

# Alleen actieve
toon-sessies actief
```

**Output:**
- Session ID (short: 8 chars)
- Timestamp (datum + tijd)
- Size (MB)
- Preview (eerste bericht)
- Status (ACTIVE/ARCHIVED)

**Example:**
```
[ARCHIVED] fc0bbf6c | 2026-02-07 15:13 | 0.82 MB
  kun je dit alles nog 1000x verbeteren? stel een groep van 1000...
```

---

### 2. Restore Session (`herstel-sessie`)
**Herstel een eerdere sessie**

```powershell
# Herstel laatst gesloten sessie
herstel-sessie

# Herstel specifieke sessie (by ID)
herstel-sessie fc0bbf6c

# Het commando wordt automatisch naar clipboard gekopieerd!
```

**Output:**
- Session info (ID, timestamp, size)
- Restore command: `claude --resume <full-id>`
- Command copied to clipboard ✅

**Usage:**
1. Run `herstel-sessie`
2. Paste in terminal (Ctrl+V)
3. Press Enter
4. Session restored!

---

### 3. Search Sessions (`zoek-sessies`)
**Zoek in ALLE sessies naar keyword**

```powershell
# Zoek naar "worktree"
zoek-sessies "worktree"

# Toon meer resultaten
zoek-sessies "ci-cd" -Aantal 20

# Case insensitive!
zoek-sessies "ERROR"
```

**Output:**
- Matching sessions
- Match count per session
- Context snippets (highlighted)

**Example:**
```
Found 47 sessions with 'worktree'

[ARCHIVED] 0b16c70d | 2026-02-07 14:39 | 124 matches
  Context:
    - ALWAYS release >>worktrees<< IMMEDIATELY after PR creation
    - 9-step protocol: PR verify -> clean directory -> mark FREE
```

**Performance:**
- Searches 578 sessions
- ~2-5 seconds for full corpus search
- Results ranked by match count

---

### 4. Preview Session (`preview-sessie`)
**Toon eerste N berichten van een sessie**

```powershell
# Toon eerste 10 berichten
preview-sessie fc0bbf6c

# Toon eerste 20 berichten
preview-sessie fc0bbf6c -Aantal 20
```

**Output:**
- Session metadata (ID, date, size)
- First N messages (role + content preview)
- Color-coded by role (USER=green, ASSISTANT=cyan)

**Use case:**
- Quick check: "wat was deze sessie over?"
- Before restore: verify it's the right session
- Session analysis: see conversation flow

---

### 5. Export Session (`export-sessie`)
**Export volledige sessie naar markdown**

```powershell
# Export sessie
export-sessie fc0bbf6c
```

**Output:**
- Markdown file: `C:\scripts\_machine\session-exports\<id>-export.md`
- Complete conversation history
- Message count
- File path (for easy access)

**Markdown Structure:**
```markdown
# Session Export: fc0bbf6c

**Date:** 2026-02-07 15:14:12
**Size:** 0.83 MB
**Status:** ARCHIVED

---

## Message 1 - USER

<full message text>

---

## Message 2 - ASSISTANT

<full message text>

---
...
```

**Use cases:**
- Archive important sessions
- Share conversation externally
- Analyze conversation patterns
- Create documentation from sessions

---

### 6. Session Statistics (`sessie-stats`)
**Dashboard met alle statistieken**

```powershell
# Toon complete dashboard
sessie-stats
```

**Output:**

**Overview:**
- Total sessions
- Total size (GB)
- Average session size

**Top 5 Largest:**
- Biggest sessions by size
- Great for finding "monster sessions"

**Top 5 Most Recent:**
- Latest sessions
- Quick check: what did I work on today?

**Sessions per Day (Last 7 days):**
- Daily breakdown
- Session count + total size
- Activity patterns visible

**Status Breakdown:**
- Active vs Archived count

**Example Output:**
```
=== SESSION STATISTICS ===

Total Sessions: 578
Total Size: 2174.51 MB
Average Size: 3.76 MB

TOP 5 LARGEST SESSIONS:
  e64b6707 | 159.7 MB | 2026-01-21
  af908040 | 66.53 MB | 2026-01-21
  ...

SESSIONS PER DAY (Last 7 days):
  2026-02-07 | 16 sessions | 49.89 MB
  2026-02-06 | 28 sessions | 43.01 MB
  ...
```

---

## 🔧 English Commands (Same Features)

All commands have English equivalents:

| Dutch | English |
|-------|---------|
| `toon-sessies` | `sessions.ps1 list` |
| `herstel-sessie` | `sessions.ps1 restore` / `sessions.ps1 last` |
| `zoek-sessies "x"` | `sessions.ps1 search -Query "x"` |
| `preview-sessie x` | `sessions.ps1 preview x` |
| `export-sessie x` | `sessions.ps1 export x` |
| `sessie-stats` | `sessions.ps1 stats` |

---

## 📂 File Locations

### Session Files
- **Primary:** `C:\Users\HP\.claude\projects\C--scripts\*.jsonl`
- **Format:** JSONL (one JSON object per line)
- **Naming:** UUID-based (e.g., `fc0bbf6c-b0b2-4378-9f6c-119bc06b7edd.jsonl`)

### Exports
- **Location:** `C:\scripts\_machine\session-exports\`
- **Format:** Markdown (`.md`)
- **Naming:** `<short-id>-export.md` (e.g., `fc0bbf6c-export.md`)

### Tools
- **Core tool:** `C:\scripts\tools\sessions.ps1`
- **Dutch wrappers:** `C:\scripts\tools\*-sessie*.ps1`

---

## 🎯 Common Use Cases

### Use Case 1: "Wat deed ik gisteren?"
```powershell
# Check latest sessions
toon-sessies -Aantal 10

# Preview one to verify
preview-sessie <id>
```

### Use Case 2: "Herstel die sessie over worktrees"
```powershell
# Search for worktree sessions
zoek-sessies "worktree"

# Restore the right one
herstel-sessie <id>
```

### Use Case 3: "Export die lange conversatie"
```powershell
# Find large sessions
sessie-stats

# Export it
export-sessie <id>

# File ready in session-exports/
```

### Use Case 4: "Hoeveel werk ik eigenlijk?"
```powershell
# Check stats
sessie-stats

# See daily breakdown
# Sessions per day (Last 7 days) section shows activity
```

### Use Case 5: "Crashte deze sessie?"
```powershell
# List all sessions, look for ACTIVE status
toon-sessies

# If none are ACTIVE but you're in a session → crashed
# Restore with:
herstel-sessie
```

---

## ⚡ Performance

| Operation | Time | Notes |
|-----------|------|-------|
| List sessions | <1s | Fast (metadata only) |
| Search sessions | 2-5s | Full corpus search (578 sessions) |
| Preview session | <1s | Reads first N lines only |
| Export session | 1-3s | Depends on size |
| Stats dashboard | 1-2s | Calculates aggregates |

**Index caching:** None currently (on-demand processing)
**Future:** Could add session index cache for instant search

---

## 🚀 Future Enhancements (Queued)

### Phase 2 Ideas:
1. **Semantic session naming** - Auto-generate session titles from content
2. **Session tagging** - Add tags like #worktree, #debugging, #feature
3. **Cross-session search** - Find patterns across multiple sessions
4. **Session diff** - Compare two sessions (what changed?)
5. **Session analytics** - Token usage trends, response times, etc.
6. **Smart restore** - "Restore last session about X"
7. **Session clustering** - Group related sessions automatically

---

## 📚 Integration with Other Systems

### Infinite Improvement Engine
- Session search helps find past learnings
- Export creates documentation artifacts
- Stats inform optimization decisions

### Reflection Log
- Sessions ARE the raw data
- Reflection log is the distilled learnings
- Cross-reference: reflection → session lookup

### Consciousness Architecture
- Past sessions = episodic memory
- Session search = memory retrieval
- Export = memory consolidation

---

## ✅ Success Metrics

**Iteration #7-8 Goals:**
- ✅ View all sessions (list)
- ✅ Restore last closed session (one command)
- ✅ Search sessions by keyword
- ✅ Preview session messages
- ✅ Export to markdown
- ✅ Statistics dashboard

**All goals achieved!**

**Total tools created:** 9
- 1 core engine (`sessions.ps1`)
- 4 Dutch wrappers (`toon-sessies`, `herstel-sessie`, `zoek-sessies`, `preview-sessie`, `export-sessie`, `sessie-stats`)

**Total features:** 6 major features
**Lines of code:** ~500 lines PowerShell

---

**Last Updated:** 2026-02-07 15:15 UTC
**Status:** PRODUCTION READY
**Next:** Phase 2 enhancements (semantic naming, tagging, analytics)
