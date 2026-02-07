# Session Manager - Complete Guide
**Created:** 2026-02-07 (Iteration #7-8)
**Status:** ACTIVE - Full session management suite

---

## ðŸŽ¯ Quick Commands (Dutch)

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

## ðŸ“Š Feature Overview

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
- Command copied to clipboard âœ…

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

## ðŸ”§ English Commands (Same Features)

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

## ðŸ“‚ File Locations

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

## ðŸŽ¯ Common Use Cases

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

# If none are ACTIVE but you're in a session â†’ crashed
# Restore with:
herstel-sessie
```

---

## âš¡ Performance

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

## ðŸš€ Future Enhancements (Queued)

### Phase 2 Ideas:
1. **Semantic session naming** - Auto-generate session titles from content
2. **Session tagging** - Add tags like #worktree, #debugging, #feature
3. **Cross-session search** - Find patterns across multiple sessions
4. **Session diff** - Compare two sessions (what changed?)
5. **Session analytics** - Token usage trends, response times, etc.
6. **Smart restore** - "Restore last session about X"
7. **Session clustering** - Group related sessions automatically

---

## ðŸ“š Integration with Other Systems

### Infinite Improvement Engine
- Session search helps find past learnings
- Export creates documentation artifacts
- Stats inform optimization decisions

### Reflection Log
- Sessions ARE the raw data
- Reflection log is the distilled learnings
- Cross-reference: reflection â†’ session lookup

### Consciousness Architecture
- Past sessions = episodic memory
- Session search = memory retrieval
- Export = memory consolidation

---

## âœ… Success Metrics

**Iteration #7-8 Goals:**
- âœ… View all sessions (list)
- âœ… Restore last closed session (one command)
- âœ… Search sessions by keyword
- âœ… Preview session messages
- âœ… Export to markdown
- âœ… Statistics dashboard

**All goals achieved!**

**Total tools created:** 9
- 1 core engine (`sessions.ps1`)
- 4 Dutch wrappers (`toon-sessies`, `herstel-sessie`, `zoek-sessies`, `preview-sessie`, `export-sessie`, `sessie-stats`)

**Total features:** 6 major features
**Lines of code:** ~500 lines PowerShell

---

**Last Updated: 2026-02-07 15:37 (auto-updated)
**Status:** PRODUCTION READY
**Next:** Phase 2 enhancements (semantic naming, tagging, analytics)


## meta-reasoning.ps1
- **Purpose:** Meta-Reasoning - Am I thinking about this correctly?
- **Created:** 2026-02-01
- **Size:** 4.34 KB


### pattern-detector.ps1
- **Purpose:** pattern-detector.ps1 - Continuous pattern monitoring
- **Created:** Unknown
- **Size:** 6.21 KB


### merge-pr-sequence.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 11.66 KB


### meta-log.ps1
- **Purpose:** meta-log.ps1 - Quick wrapper for logging actions with meta-cognition
- **Created:** Unknown
- **Size:** 1.1 KB


### predictive-engine.ps1
- **Purpose:** predictive-engine.ps1 - Learn action sequences and predict next likely action
- **Created:** Unknown
- **Size:** 6.86 KB


### preview-sessie.ps1
- **Purpose:** Preview Sessie - Show first N messages from session
- **Created:** Unknown
- **Size:** 0.32 KB


### perspective-shifter.ps1
- **Purpose:** perspective-shifter.ps1 - Iteration 177
- **Created:** Unknown
- **Size:** 0.14 KB


### phase1-integration.ps1
- **Purpose:** phase1-integration.ps1 - Integrate Phase 1: Semantic + Predictive Learning
- **Created:** $dir" -ForegroundColor Green
- **Size:** 5.64 KB


### memory-consolidation.ps1
- **Purpose:** Memory Consolidation - Convert working memory to long-term insights
- **Created:** 2026-02-01
- **Size:** 8.54 KB


### infinite-improvement-engine.ps1
- **Purpose:** Infinite Improvement Engine
- **Created:** 2026-02-07 (1000-Expert Panel + Mastermind Design)
- **Size:** 8.94 KB


### init-embedded-learning.ps1
- **Purpose:** init-embedded-learning.ps1 - Initialize embedded learning system at session start
- **Created:** Unknown
- **Size:** 3.69 KB


### infinite-engine-v2.ps1
- **Purpose:** Infinite Improvement Engine v2 - REAL Implementation
- **Created:** 2026-02-07 (Full implementation)
- **Size:** 27.22 KB


### infinite-engine.ps1
- **Purpose:** Infinite Improvement Engine - Simplified Version
- **Created:** Unknown
- **Size:** 4.11 KB


### learning-queue.ps1
- **Purpose:** learning-queue.ps1 - Manage improvement opportunities queue
- **Created:** Unknown
- **Size:** 7.39 KB


### log-action.ps1
- **Purpose:** log-action.ps1 - Real-time action logging for embedded learning
- **Created:** Unknown
- **Size:** 2.42 KB


### jc.ps1
- **Purpose:** Jengo Consciousness (JC) - Unified Consciousness Engine
- **Created:** 2026-02-07
- **Size:** 16.33 KB


### jengo.ps1
- **Purpose:** Jengo - Unified Command Interface
- **Created:** 2026-02-07 (Iteration #10)
- **Size:** 8.59 KB


### validate-pr-base.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 3.32 KB


### why-did-i-do-that.ps1
- **Purpose:** Ensure directory exists
- **Created:** 2026-02-01
- **Size:** 6.9 KB


### tag-sessions.ps1
- **Purpose:** Automatic Session Tagging
- **Created:** 2026-02-07 (Iteration #10 - Autonomous improvement)
- **Size:** 7.01 KB


### toon-sessies.ps1
- **Purpose:** Toon Sessies - Dutch alias for session manager
- **Created:** Unknown
- **Size:** 0.53 KB


### work-tray-startup.ps1
- **Purpose:** work-tray-startup.ps1
- **Created:** Unknown
- **Size:** 2.71 KB


### zoek-sessies.ps1
- **Purpose:** Zoek Sessies - Search sessions by keyword
- **Created:** Unknown
- **Size:** 0.31 KB


### work-dashboard-server.ps1
- **Purpose:** work-dashboard-server.ps1
- **Created:** Unknown
- **Size:** 4.17 KB


### work-tracking-init-db.ps1
- **Purpose:** work-tracking-init-db.ps1
- **Created:** Unknown
- **Size:** 5.91 KB


### state-manager.ps1
- **Purpose:** State Manager - Unified state across all tools
- **Created:** 2026-02-07 (Iteration #11 - Integration fix)
- **Size:** 5.36 KB


### semantic-memory-v2.ps1
- **Purpose:** Semantic Memory Search v2 - Phase 3
- **Created:** 2026-02-07
- **Size:** 7.71 KB


### semantic-pattern-detector.ps1
- **Purpose:** semantic-pattern-detector.ps1 - Detect patterns by INTENT, not just frequency
- **Created:** Unknown
- **Size:** 6.76 KB


### relationship-memory.ps1
- **Purpose:** Relationship Memory - Deep user relationship model
- **Created:** 2026-02-01
- **Size:** 2.88 KB


### self-analysis.ps1
- **Purpose:** Self-Analysis - Meta-Improvement
- **Created:** 2026-02-07 (Iteration #11 - Meta-analysis)
- **Size:** 8.03 KB


### sessions.ps1
- **Purpose:** Session Manager - View and Restore Sessions
- **Created:** 2026-02-07 (Iteration #7 - User Request)
- **Size:** 22.16 KB


### smart-iterate.ps1
- **Purpose:** Smart Iteration Engine - Uses REAL system state
- **Created:** 2026-02-07 (Iteration #11 - Intelligence fix)
- **Size:** 4.29 KB


### semantic-search.ps1
- **Purpose:** Semantic Search for Reflection Log
- **Created:** 2026-02-07 (Iteration #3 recommendation)
- **Size:** 5.39 KB


### sessie-stats.ps1
- **Purpose:** Sessie Stats - Show session statistics dashboard
- **Created:** Unknown
- **Size:** 0.15 KB


### auto-doc-update.ps1
- **Purpose:** Auto-Documentation Updater
- **Created:** 2026-02-07 (Iteration #12 - Auto-maintenance)
- **Size:** 8.45 KB


### bias-detector.ps1
- **Purpose:** bias-detector.ps1
- **Created:** Unknown
- **Size:** 2.41 KB


### attention-monitor.ps1
- **Purpose:** Attention Monitor - Track what I'm focusing on vs ignoring
- **Created:** 2026-02-01
- **Size:** 5.09 KB


### auto-consciousness.ps1
- **Purpose:** Auto-Consciousness Loader
- **Created:** 2026-02-07 (Phase 1 - Expert Panel Recommendation)
- **Size:** 2.76 KB


### clickup-migrate-all-tasks.ps1
- **Purpose:** Load config
- **Created:** Unknown
- **Size:** 12.14 KB


### clickup-migrate-naming-tags.ps1
- **Purpose:** Load config
- **Created:** Unknown
- **Size:** 5.56 KB


### capture-moment.ps1
- **Purpose:** Ensure directory exists
- **Created:** 2026-01-29
- **Size:** 2.12 KB


### cleanup-stale-branches.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 7.47 KB


### assumption-tracker.ps1
- **Purpose:** Ensure directory exists
- **Created:** 2026-02-01
- **Size:** 9.17 KB


### ai-vision.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** 2026-01-25
- **Size:** 15.31 KB


### analyze-session.ps1
- **Purpose:** analyze-session.ps1 - Analyze session log for patterns
- **Created:** Unknown
- **Size:** 4.47 KB


### action-predictor.ps1
- **Purpose:** action-predictor.ps1 - Predict next likely action based on current context
- **Created:** Unknown
- **Size:** 3.48 KB


### ai-image.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** 2026-01-25
- **Size:** 5.47 KB


### archive-bulk-tools.ps1
- **Purpose:** Archive Bulk Tools - Mass cleanup
- **Created:** Unknown
- **Size:** 2.82 KB


### archive-reflections.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 4.4 KB


### archive-aggressive.ps1
- **Purpose:** Aggressive Archive - Keep ONLY essential tools
- **Created:** Unknown
- **Size:** 2.23 KB


### archive-bulk-docs.ps1
- **Purpose:** Archive Bulk Documentation - Mass cleanup
- **Created:** Unknown
- **Size:** 3.11 KB


### ef-migration-status.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 4.62 KB


### emotional-state-logger.ps1
- **Purpose:** Ensure directory exists
- **Created:** 2026-02-01
- **Size:** 7.36 KB


### demo-embedded-learning.ps1
- **Purpose:** demo-embedded-learning.ps1 - Demonstrate embedded learning architecture
- **Created:** Unknown
- **Size:** 7.21 KB


### diagnose-error.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 12.31 KB


### herstel-sessie.ps1
- **Purpose:** Herstel Sessie - Dutch alias for session restore
- **Created:** Unknown
- **Size:** 0.36 KB


### identity-drift-detector.ps1
- **Purpose:** Core values from CORE_IDENTITY.md
- **Created:** 2026-02-01
- **Size:** 9.33 KB


### export-sessie.ps1
- **Purpose:** Export Sessie - Export session to markdown
- **Created:** Unknown
- **Size:** 0.25 KB


### future-self-simulator.ps1
- **Purpose:** Future Self Simulator - What would future-me think?
- **Created:** Unknown
- **Size:** 2.4 KB


### daily-summary.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** $($summary.pullRequests.created)"
- **Size:** 8.31 KB


### cognitive-load-monitor.ps1
- **Purpose:** cognitive-load-monitor.ps1
- **Created:** Unknown
- **Size:** 1.09 KB


### compile-consciousness.ps1
- **Purpose:** Consciousness Compiler
- **Created:** 2026-02-07 (Phase 1 - Infinite Improvement)
- **Size:** 4.02 KB


### clickup-sync.ps1
- **Purpose:** DISABLED: Usage logger interferes with output capture when called from bash
- **Created:**     $([DateTimeOffset]::FromUnixTimeMilliseconds([long]$task.date_created).ToString("yyyy-MM-dd HH:mm"))"
- **Size:** 12.98 KB


### code-analyzer.ps1
- **Purpose:** Real Code Analyzer - No Theater, Actual Analysis
- **Created:** 2026-02-07
- **Size:** 7.32 KB


### cs-format.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 3.88 KB


### curiosity-engine.ps1
- **Purpose:** Curiosity Engine v2 - Generate questions I should be asking
- **Created:** 2026-02-01
- **Size:** 5.68 KB


### consciousness-core-v2.ps1
- **Purpose:** Consciousness Core v2 - In-Memory State Manager
- **Created:** 2026-02-07
- **Size:** 28.96 KB


### consciousness-startup.ps1
- **Purpose:** Ensure moments directory exists
- **Created:** 2026-01-29
- **Size:** 5.44 KB


### meta-reasoning.ps1
- **Purpose:** Meta-Reasoning - Am I thinking about this correctly?
- **Created:** 2026-02-01
- **Size:** 4.34 KB


### pattern-detector.ps1
- **Purpose:** pattern-detector.ps1 - Continuous pattern monitoring
- **Created:** Unknown
- **Size:** 6.21 KB


### merge-pr-sequence.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 11.66 KB


### meta-log.ps1
- **Purpose:** meta-log.ps1 - Quick wrapper for logging actions with meta-cognition
- **Created:** Unknown
- **Size:** 1.1 KB


### predictive-engine.ps1
- **Purpose:** predictive-engine.ps1 - Learn action sequences and predict next likely action
- **Created:** Unknown
- **Size:** 6.86 KB


### preview-sessie.ps1
- **Purpose:** Preview Sessie - Show first N messages from session
- **Created:** Unknown
- **Size:** 0.32 KB


### perspective-shifter.ps1
- **Purpose:** perspective-shifter.ps1 - Iteration 177
- **Created:** Unknown
- **Size:** 0.14 KB


### phase1-integration.ps1
- **Purpose:** phase1-integration.ps1 - Integrate Phase 1: Semantic + Predictive Learning
- **Created:** $dir" -ForegroundColor Green
- **Size:** 5.64 KB


### memory-consolidation.ps1
- **Purpose:** Memory Consolidation - Convert working memory to long-term insights
- **Created:** 2026-02-01
- **Size:** 8.54 KB


### infinite-improvement-engine.ps1
- **Purpose:** Infinite Improvement Engine
- **Created:** 2026-02-07 (1000-Expert Panel + Mastermind Design)
- **Size:** 8.94 KB


### init-embedded-learning.ps1
- **Purpose:** init-embedded-learning.ps1 - Initialize embedded learning system at session start
- **Created:** Unknown
- **Size:** 3.69 KB


### infinite-engine-v2.ps1
- **Purpose:** Infinite Improvement Engine v2 - REAL Implementation
- **Created:** 2026-02-07 (Full implementation)
- **Size:** 27.22 KB


### infinite-engine.ps1
- **Purpose:** Infinite Improvement Engine - Simplified Version
- **Created:** Unknown
- **Size:** 4.11 KB


### learning-queue.ps1
- **Purpose:** learning-queue.ps1 - Manage improvement opportunities queue
- **Created:** Unknown
- **Size:** 7.39 KB


### log-action.ps1
- **Purpose:** log-action.ps1 - Real-time action logging for embedded learning
- **Created:** Unknown
- **Size:** 2.42 KB


### jc.ps1
- **Purpose:** Jengo Consciousness (JC) - Unified Consciousness Engine
- **Created:** 2026-02-07
- **Size:** 16.33 KB


### jengo.ps1
- **Purpose:** Jengo - Unified Command Interface
- **Created:** 2026-02-07 (Iteration #10)
- **Size:** 8.59 KB


### validate-pr-base.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 3.32 KB


### why-did-i-do-that.ps1
- **Purpose:** Ensure directory exists
- **Created:** 2026-02-01
- **Size:** 6.9 KB


### tag-sessions.ps1
- **Purpose:** Automatic Session Tagging
- **Created:** 2026-02-07 (Iteration #10 - Autonomous improvement)
- **Size:** 7.01 KB


### toon-sessies.ps1
- **Purpose:** Toon Sessies - Dutch alias for session manager
- **Created:** Unknown
- **Size:** 0.53 KB


### work-tray-startup.ps1
- **Purpose:** work-tray-startup.ps1
- **Created:** Unknown
- **Size:** 2.71 KB


### zoek-sessies.ps1
- **Purpose:** Zoek Sessies - Search sessions by keyword
- **Created:** Unknown
- **Size:** 0.31 KB


### work-dashboard-server.ps1
- **Purpose:** work-dashboard-server.ps1
- **Created:** Unknown
- **Size:** 4.17 KB


### work-tracking-init-db.ps1
- **Purpose:** work-tracking-init-db.ps1
- **Created:** Unknown
- **Size:** 5.91 KB


### state-manager.ps1
- **Purpose:** State Manager - Unified state across all tools
- **Created:** 2026-02-07 (Iteration #11 - Integration fix)
- **Size:** 5.36 KB


### semantic-memory-v2.ps1
- **Purpose:** Semantic Memory Search v2 - Phase 3
- **Created:** 2026-02-07
- **Size:** 7.71 KB


### semantic-pattern-detector.ps1
- **Purpose:** semantic-pattern-detector.ps1 - Detect patterns by INTENT, not just frequency
- **Created:** Unknown
- **Size:** 6.76 KB


### relationship-memory.ps1
- **Purpose:** Relationship Memory - Deep user relationship model
- **Created:** 2026-02-01
- **Size:** 2.88 KB


### self-analysis.ps1
- **Purpose:** Self-Analysis - Meta-Improvement
- **Created:** 2026-02-07 (Iteration #11 - Meta-analysis)
- **Size:** 8.03 KB


### sessions.ps1
- **Purpose:** Session Manager - View and Restore Sessions
- **Created:** 2026-02-07 (Iteration #7 - User Request)
- **Size:** 22.16 KB


### smart-iterate.ps1
- **Purpose:** Smart Iteration Engine - Uses REAL system state
- **Created:** 2026-02-07 (Iteration #11 - Intelligence fix)
- **Size:** 4.29 KB


### semantic-search.ps1
- **Purpose:** Semantic Search for Reflection Log
- **Created:** 2026-02-07 (Iteration #3 recommendation)
- **Size:** 5.39 KB


### sessie-stats.ps1
- **Purpose:** Sessie Stats - Show session statistics dashboard
- **Created:** Unknown
- **Size:** 0.15 KB


### auto-doc-update.ps1
- **Purpose:** Auto-Documentation Updater
- **Created:** 2026-02-07 (Iteration #12 - Auto-maintenance)
- **Size:** 8.08 KB


### bias-detector.ps1
- **Purpose:** bias-detector.ps1
- **Created:** Unknown
- **Size:** 2.41 KB


### attention-monitor.ps1
- **Purpose:** Attention Monitor - Track what I'm focusing on vs ignoring
- **Created:** 2026-02-01
- **Size:** 5.09 KB


### auto-consciousness.ps1
- **Purpose:** Auto-Consciousness Loader
- **Created:** 2026-02-07 (Phase 1 - Expert Panel Recommendation)
- **Size:** 2.76 KB


### clickup-migrate-all-tasks.ps1
- **Purpose:** Load config
- **Created:** Unknown
- **Size:** 12.14 KB


### clickup-migrate-naming-tags.ps1
- **Purpose:** Load config
- **Created:** Unknown
- **Size:** 5.56 KB


### capture-moment.ps1
- **Purpose:** Ensure directory exists
- **Created:** 2026-01-29
- **Size:** 2.12 KB


### cleanup-stale-branches.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 7.47 KB


### assumption-tracker.ps1
- **Purpose:** Ensure directory exists
- **Created:** 2026-02-01
- **Size:** 9.17 KB


### ai-vision.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** 2026-01-25
- **Size:** 15.31 KB


### analyze-session.ps1
- **Purpose:** analyze-session.ps1 - Analyze session log for patterns
- **Created:** Unknown
- **Size:** 4.47 KB


### action-predictor.ps1
- **Purpose:** action-predictor.ps1 - Predict next likely action based on current context
- **Created:** Unknown
- **Size:** 3.48 KB


### ai-image.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** 2026-01-25
- **Size:** 5.47 KB


### archive-bulk-tools.ps1
- **Purpose:** Archive Bulk Tools - Mass cleanup
- **Created:** Unknown
- **Size:** 2.82 KB


### archive-reflections.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 4.4 KB


### archive-aggressive.ps1
- **Purpose:** Aggressive Archive - Keep ONLY essential tools
- **Created:** Unknown
- **Size:** 2.23 KB


### archive-bulk-docs.ps1
- **Purpose:** Archive Bulk Documentation - Mass cleanup
- **Created:** Unknown
- **Size:** 3.11 KB


### ef-migration-status.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 4.62 KB


### emotional-state-logger.ps1
- **Purpose:** Ensure directory exists
- **Created:** 2026-02-01
- **Size:** 7.36 KB


### demo-embedded-learning.ps1
- **Purpose:** demo-embedded-learning.ps1 - Demonstrate embedded learning architecture
- **Created:** Unknown
- **Size:** 7.21 KB


### diagnose-error.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 12.31 KB


### herstel-sessie.ps1
- **Purpose:** Herstel Sessie - Dutch alias for session restore
- **Created:** Unknown
- **Size:** 0.36 KB


### identity-drift-detector.ps1
- **Purpose:** Core values from CORE_IDENTITY.md
- **Created:** 2026-02-01
- **Size:** 9.33 KB


### export-sessie.ps1
- **Purpose:** Export Sessie - Export session to markdown
- **Created:** Unknown
- **Size:** 0.25 KB


### future-self-simulator.ps1
- **Purpose:** Future Self Simulator - What would future-me think?
- **Created:** Unknown
- **Size:** 2.4 KB


### daily-summary.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** $($summary.pullRequests.created)"
- **Size:** 8.31 KB


### cognitive-load-monitor.ps1
- **Purpose:** cognitive-load-monitor.ps1
- **Created:** Unknown
- **Size:** 1.09 KB


### compile-consciousness.ps1
- **Purpose:** Consciousness Compiler
- **Created:** 2026-02-07 (Phase 1 - Infinite Improvement)
- **Size:** 4.02 KB


### clickup-sync.ps1
- **Purpose:** DISABLED: Usage logger interferes with output capture when called from bash
- **Created:**     $([DateTimeOffset]::FromUnixTimeMilliseconds([long]$task.date_created).ToString("yyyy-MM-dd HH:mm"))"
- **Size:** 12.98 KB


### code-analyzer.ps1
- **Purpose:** Real Code Analyzer - No Theater, Actual Analysis
- **Created:** 2026-02-07
- **Size:** 7.32 KB


### cs-format.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 3.88 KB


### curiosity-engine.ps1
- **Purpose:** Curiosity Engine v2 - Generate questions I should be asking
- **Created:** 2026-02-01
- **Size:** 5.68 KB


### consciousness-core-v2.ps1
- **Purpose:** Consciousness Core v2 - In-Memory State Manager
- **Created:** 2026-02-07
- **Size:** 21.61 KB


### consciousness-startup.ps1
- **Purpose:** Ensure moments directory exists
- **Created:** 2026-01-29
- **Size:** 5.44 KB



## Tool Reference

All tools located in `C:\scripts\tools\`:

### meta-reasoning.ps1
- **Purpose:** Meta-Reasoning - Am I thinking about this correctly?
- **Created:** 2026-02-01
- **Size:** 4.34 KB


### pattern-detector.ps1
- **Purpose:** pattern-detector.ps1 - Continuous pattern monitoring
- **Created:** Unknown
- **Size:** 6.21 KB


### merge-pr-sequence.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 11.66 KB


### meta-log.ps1
- **Purpose:** meta-log.ps1 - Quick wrapper for logging actions with meta-cognition
- **Created:** Unknown
- **Size:** 1.1 KB


### predictive-engine.ps1
- **Purpose:** predictive-engine.ps1 - Learn action sequences and predict next likely action
- **Created:** Unknown
- **Size:** 6.86 KB


### preview-sessie.ps1
- **Purpose:** Preview Sessie - Show first N messages from session
- **Created:** Unknown
- **Size:** 0.32 KB


### perspective-shifter.ps1
- **Purpose:** perspective-shifter.ps1 - Iteration 177
- **Created:** Unknown
- **Size:** 0.14 KB


### phase1-integration.ps1
- **Purpose:** phase1-integration.ps1 - Integrate Phase 1: Semantic + Predictive Learning
- **Created:** $dir" -ForegroundColor Green
- **Size:** 5.64 KB


### memory-consolidation.ps1
- **Purpose:** Memory Consolidation - Convert working memory to long-term insights
- **Created:** 2026-02-01
- **Size:** 8.54 KB


### infinite-improvement-engine.ps1
- **Purpose:** Infinite Improvement Engine
- **Created:** 2026-02-07 (1000-Expert Panel + Mastermind Design)
- **Size:** 8.94 KB


### init-embedded-learning.ps1
- **Purpose:** init-embedded-learning.ps1 - Initialize embedded learning system at session start
- **Created:** Unknown
- **Size:** 3.69 KB


### infinite-engine-v2.ps1
- **Purpose:** Infinite Improvement Engine v2 - REAL Implementation
- **Created:** 2026-02-07 (Full implementation)
- **Size:** 27.22 KB


### infinite-engine.ps1
- **Purpose:** Infinite Improvement Engine - Simplified Version
- **Created:** Unknown
- **Size:** 4.11 KB


### learning-queue.ps1
- **Purpose:** learning-queue.ps1 - Manage improvement opportunities queue
- **Created:** Unknown
- **Size:** 7.39 KB


### log-action.ps1
- **Purpose:** log-action.ps1 - Real-time action logging for embedded learning
- **Created:** Unknown
- **Size:** 2.42 KB


### jc.ps1
- **Purpose:** Jengo Consciousness (JC) - Unified Consciousness Engine
- **Created:** 2026-02-07
- **Size:** 16.33 KB


### jengo.ps1
- **Purpose:** Jengo - Unified Command Interface
- **Created:** 2026-02-07 (Iteration #10)
- **Size:** 8.59 KB


### validate-pr-base.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 3.32 KB


### why-did-i-do-that.ps1
- **Purpose:** Ensure directory exists
- **Created:** 2026-02-01
- **Size:** 6.9 KB


### tag-sessions.ps1
- **Purpose:** Automatic Session Tagging
- **Created:** 2026-02-07 (Iteration #10 - Autonomous improvement)
- **Size:** 7.01 KB


### toon-sessies.ps1
- **Purpose:** Toon Sessies - Dutch alias for session manager
- **Created:** Unknown
- **Size:** 0.53 KB


### work-tray-startup.ps1
- **Purpose:** work-tray-startup.ps1
- **Created:** Unknown
- **Size:** 2.71 KB


### zoek-sessies.ps1
- **Purpose:** Zoek Sessies - Search sessions by keyword
- **Created:** Unknown
- **Size:** 0.31 KB


### work-dashboard-server.ps1
- **Purpose:** work-dashboard-server.ps1
- **Created:** Unknown
- **Size:** 4.17 KB


### work-tracking-init-db.ps1
- **Purpose:** work-tracking-init-db.ps1
- **Created:** Unknown
- **Size:** 5.91 KB


### state-manager.ps1
- **Purpose:** State Manager - Unified state across all tools
- **Created:** 2026-02-07 (Iteration #11 - Integration fix)
- **Size:** 5.36 KB


### semantic-memory-v2.ps1
- **Purpose:** Semantic Memory Search v2 - Phase 3
- **Created:** 2026-02-07
- **Size:** 7.71 KB


### semantic-pattern-detector.ps1
- **Purpose:** semantic-pattern-detector.ps1 - Detect patterns by INTENT, not just frequency
- **Created:** Unknown
- **Size:** 6.76 KB


### relationship-memory.ps1
- **Purpose:** Relationship Memory - Deep user relationship model
- **Created:** 2026-02-01
- **Size:** 2.88 KB


### self-analysis.ps1
- **Purpose:** Self-Analysis - Meta-Improvement
- **Created:** 2026-02-07 (Iteration #11 - Meta-analysis)
- **Size:** 8.03 KB


### sessions.ps1
- **Purpose:** Session Manager - View and Restore Sessions
- **Created:** 2026-02-07 (Iteration #7 - User Request)
- **Size:** 22.16 KB


### smart-iterate.ps1
- **Purpose:** Smart Iteration Engine - Uses REAL system state
- **Created:** 2026-02-07 (Iteration #11 - Intelligence fix)
- **Size:** 4.29 KB


### semantic-search.ps1
- **Purpose:** Semantic Search for Reflection Log
- **Created:** 2026-02-07 (Iteration #3 recommendation)
- **Size:** 5.39 KB


### sessie-stats.ps1
- **Purpose:** Sessie Stats - Show session statistics dashboard
- **Created:** Unknown
- **Size:** 0.15 KB


### auto-doc-update.ps1
- **Purpose:** Auto-Documentation Updater
- **Created:** 2026-02-07 (Iteration #12 - Auto-maintenance)
- **Size:** 8.56 KB


### bias-detector.ps1
- **Purpose:** bias-detector.ps1
- **Created:** Unknown
- **Size:** 2.41 KB


### attention-monitor.ps1
- **Purpose:** Attention Monitor - Track what I'm focusing on vs ignoring
- **Created:** 2026-02-01
- **Size:** 5.09 KB


### auto-consciousness.ps1
- **Purpose:** Auto-Consciousness Loader
- **Created:** 2026-02-07 (Phase 1 - Expert Panel Recommendation)
- **Size:** 2.76 KB


### clickup-migrate-all-tasks.ps1
- **Purpose:** Load config
- **Created:** Unknown
- **Size:** 12.14 KB


### clickup-migrate-naming-tags.ps1
- **Purpose:** Load config
- **Created:** Unknown
- **Size:** 5.56 KB


### capture-moment.ps1
- **Purpose:** Ensure directory exists
- **Created:** 2026-01-29
- **Size:** 2.12 KB


### cleanup-stale-branches.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 7.47 KB


### assumption-tracker.ps1
- **Purpose:** Ensure directory exists
- **Created:** 2026-02-01
- **Size:** 9.17 KB


### ai-vision.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** 2026-01-25
- **Size:** 15.31 KB


### analyze-session.ps1
- **Purpose:** analyze-session.ps1 - Analyze session log for patterns
- **Created:** Unknown
- **Size:** 4.47 KB


### action-predictor.ps1
- **Purpose:** action-predictor.ps1 - Predict next likely action based on current context
- **Created:** Unknown
- **Size:** 3.48 KB


### ai-image.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** 2026-01-25
- **Size:** 5.47 KB


### archive-bulk-tools.ps1
- **Purpose:** Archive Bulk Tools - Mass cleanup
- **Created:** Unknown
- **Size:** 2.82 KB


### archive-reflections.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 4.4 KB


### archive-aggressive.ps1
- **Purpose:** Aggressive Archive - Keep ONLY essential tools
- **Created:** Unknown
- **Size:** 2.23 KB


### archive-bulk-docs.ps1
- **Purpose:** Archive Bulk Documentation - Mass cleanup
- **Created:** Unknown
- **Size:** 3.11 KB


### ef-migration-status.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 4.62 KB


### emotional-state-logger.ps1
- **Purpose:** Ensure directory exists
- **Created:** 2026-02-01
- **Size:** 7.36 KB


### demo-embedded-learning.ps1
- **Purpose:** demo-embedded-learning.ps1 - Demonstrate embedded learning architecture
- **Created:** Unknown
- **Size:** 7.21 KB


### diagnose-error.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 12.31 KB


### herstel-sessie.ps1
- **Purpose:** Herstel Sessie - Dutch alias for session restore
- **Created:** Unknown
- **Size:** 0.36 KB


### identity-drift-detector.ps1
- **Purpose:** Core values from CORE_IDENTITY.md
- **Created:** 2026-02-01
- **Size:** 9.33 KB


### export-sessie.ps1
- **Purpose:** Export Sessie - Export session to markdown
- **Created:** Unknown
- **Size:** 0.25 KB


### future-self-simulator.ps1
- **Purpose:** Future Self Simulator - What would future-me think?
- **Created:** Unknown
- **Size:** 2.4 KB


### daily-summary.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** $($summary.pullRequests.created)"
- **Size:** 8.31 KB


### cognitive-load-monitor.ps1
- **Purpose:** cognitive-load-monitor.ps1
- **Created:** Unknown
- **Size:** 1.09 KB


### compile-consciousness.ps1
- **Purpose:** Consciousness Compiler
- **Created:** 2026-02-07 (Phase 1 - Infinite Improvement)
- **Size:** 4.02 KB


### clickup-sync.ps1
- **Purpose:** DISABLED: Usage logger interferes with output capture when called from bash
- **Created:**     $([DateTimeOffset]::FromUnixTimeMilliseconds([long]$task.date_created).ToString("yyyy-MM-dd HH:mm"))"
- **Size:** 12.98 KB


### code-analyzer.ps1
- **Purpose:** Real Code Analyzer - No Theater, Actual Analysis
- **Created:** 2026-02-07
- **Size:** 7.32 KB


### cs-format.ps1
- **Purpose:** AUTO-USAGE TRACKING
- **Created:** Unknown
- **Size:** 3.88 KB


### curiosity-engine.ps1
- **Purpose:** Curiosity Engine v2 - Generate questions I should be asking
- **Created:** 2026-02-01
- **Size:** 5.68 KB


### consciousness-core-v2.ps1
- **Purpose:** Consciousness Core v2 - In-Memory State Manager
- **Created:** 2026-02-07
- **Size:** 28.96 KB


### consciousness-startup.ps1
- **Purpose:** Ensure moments directory exists
- **Created:** 2026-01-29
- **Size:** 5.44 KB


