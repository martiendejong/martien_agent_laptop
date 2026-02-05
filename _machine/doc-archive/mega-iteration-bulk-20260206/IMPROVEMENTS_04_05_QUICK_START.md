# Quick Start: Improvements #4 & #5

**TL;DR:** Two new tools help you manage documentation size and find related files.

---

## 1. Check Documentation Size

```powershell
.\tools\doc-size-monitor.ps1
```

**What it does:**
- Scans all .md files in C:\scripts
- Flags files > 25K tokens (100KB)
- Shows: MODERATE (>25K), HIGH (>37.5K), CRITICAL (>50K)
- Generates report: `_machine\doc-size-report.md`

**When to use:**
- Before starting session (check doc health)
- After creating new documentation
- When you suspect files are too large

---

## 2. Generate Summaries for Large Files

```powershell
# Single file
.\tools\doc-summarizer.ps1 -FilePath "C:\scripts\CLAUDE.md"

# All oversized files (from monitor report)
.\tools\doc-summarizer.ps1
```

**What it does:**
- Creates `{filename}_SUMMARY.md` files
- 80-90% size reduction
- Extracts key sections (headers, important notes, bold statements)

**When to use:**
- After doc-size-monitor finds CRITICAL files
- When file is too large to read quickly
- To create executive summaries

---

## 3. Find Related Files

```powershell
# By file name
.\tools\suggest-related.ps1 -File "CLAUDE.md"

# By topic
.\tools\suggest-related.ps1 -Topic "worktree"
.\tools\suggest-related.ps1 -Topic "PR workflow"
.\tools\suggest-related.ps1 -Topic "EF Core"
```

**What it does:**
- Shows 3-5 most relevant related files
- Includes descriptions
- Based on knowledge graph relationships

**When to use:**
- Starting new topic (find all related docs)
- Context switching (what else should I read?)
- Learning about unfamiliar area

---

## Common Workflows

### Workflow 1: Session Startup
```powershell
# Find recommended reading for session start
.\tools\suggest-related.ps1 -Topic "session startup"
```

**Returns:**
- STARTUP_PROTOCOL.md
- MACHINE_CONFIG.md
- CLAUDE.md
- consciousness-practices skill
- CONTEXT_KNOWLEDGE_GRAPH.yaml

### Workflow 2: Working on Client-Manager
```powershell
.\tools\suggest-related.ps1 -Topic "client-manager"
```

**Returns:**
- hazina docs
- brand2boost store
- MACHINE_CONFIG.md
- worktree-workflow.md
- MANDATORY_CODE_WORKFLOW.md

### Workflow 3: Before Creating PR
```powershell
.\tools\suggest-related.ps1 -Topic "PR workflow"
```

**Returns:**
- MANDATORY_CODE_WORKFLOW.md
- git-workflow.md
- github-workflow skill
- pr-dependencies skill
- clickup-sync.ps1

### Workflow 4: Documentation Health Check
```powershell
# Check current state
.\tools\doc-size-monitor.ps1

# Generate summaries for oversized files
.\tools\doc-summarizer.ps1

# Re-check to verify improvement
.\tools\doc-size-monitor.ps1
```

---

## Knowledge Graph Files

### RELATED_READING_MAP.yaml
Fast lookup for related reading suggestions.

**Structure:**
```yaml
when_reading:
  CLAUDE.md:
    consider_also: [MACHINE_CONFIG.md, GENERAL_ZERO_TOLERANCE_RULES.md, ...]
    reason: "Main index references these foundational files"
    read_order: [MACHINE_CONFIG.md, GENERAL_ZERO_TOLERANCE_RULES.md, ...]

by_topic:
  worktree:
    files: [worktree-workflow.md, allocate-worktree skill, ...]
    read_order: [worktree-workflow.md, worktrees.pool.md]
```

**Location:** `C:\scripts\_machine\RELATED_READING_MAP.yaml`

### CONTEXT_KNOWLEDGE_GRAPH_RELATED_READING.yaml
Extension to main knowledge graph with related_reading fields.

**Structure:**
```yaml
projects_related_reading:
  client-manager:
    related_reading:
      - "C:\Projects\hazina\README.md (framework dependency)"
      - "C:\stores\brand2boost (data store)"
      - ...
    priority_order: [hazina docs, MACHINE_CONFIG.md, worktree-workflow.md]
```

**Location:** `C:\scripts\_machine\CONTEXT_KNOWLEDGE_GRAPH_RELATED_READING.yaml`

---

## Tips & Tricks

1. **Prefer Summaries First**
   - If `{file}_SUMMARY.md` exists, read it first
   - Only read full file if you need complete details

2. **Follow Priority Orders**
   - RELATED_READING_MAP.yaml includes `read_order` field
   - Read in that order for optimal learning path

3. **Use Topics for Discovery**
   - More flexible than file names
   - Examples: "debugging", "feature development", "ClickUp", "EF Core"

4. **Monitor Before Creating**
   - Run doc-size-monitor before writing new docs
   - Aim to keep files under 25K tokens

5. **Update the Map**
   - When you discover new relationships, add to RELATED_READING_MAP.yaml
   - Keep it current as system evolves

---

## File Locations Reference

### Tools
- `C:\scripts\tools\doc-size-monitor.ps1`
- `C:\scripts\tools\doc-summarizer.ps1`
- `C:\scripts\tools\suggest-related.ps1`

### Knowledge Graph Files
- `C:\scripts\_machine\RELATED_READING_MAP.yaml`
- `C:\scripts\_machine\CONTEXT_KNOWLEDGE_GRAPH_RELATED_READING.yaml`
- `C:\scripts\_machine\CONTEXT_KNOWLEDGE_GRAPH.yaml` (main graph)

### Reports
- `C:\scripts\_machine\doc-size-report.md` (auto-generated)

### Documentation
- `C:\scripts\_machine\IMPROVEMENTS_04_05_IMPLEMENTATION.md` (full details)
- `C:\scripts\IMPROVEMENTS_04_05_QUICK_START.md` (this file)

---

## Common Topics You Can Search

Copy-paste these into `suggest-related.ps1 -Topic`:

- `worktree`
- `PR workflow`
- `ClickUp`
- `EF Core migrations`
- `debugging`
- `feature development`
- `multi-agent`
- `AI capabilities`
- `session startup`
- `client-manager`
- `hazina`
- `arjan` (legal case)
- `gemeente` (marriage case)

---

**Quick Reference Card**
**Created:** 2026-02-05
**For:** Improvements #4 & #5
**Status:** Ready for use ✅
