# Documentation Storage Protocol

**Created:** 2026-02-02
**Source:** User direct feedback - "always store analyses and documentation in project folders, not temp"

---

## 📁 WHERE TO STORE DOCUMENTATION

### Rule 1: Project-Related Documentation
**Target:** Any analysis, architecture doc, design doc, or technical documentation related to an existing project

**Location:** `C:\Projects\<project-name>\docs\`

**Examples:**
- ✅ `C:\Projects\hazina\docs\hazinacoder-gap-analysis.md` (Hazina project analysis)
- ✅ `C:\Projects\client-manager\docs\api-architecture.md` (client-manager API docs)
- ✅ `C:\Projects\hazina\docs\POC1-ARCHITECTURE.md` (already following this pattern)
- ❌ `C:\Users\HP\AppData\Local\Temp\...\hazinacoder-gap-analysis.md` (WRONG - temp files get lost)

**Why:**
- Version controlled with the code
- Discoverable by other developers
- Survives across sessions
- Lives with the code it documents

---

### Rule 2: Cross-Project or General Documentation
**Target:** Documentation that doesn't belong to a single project (system-wide architecture, cross-repo patterns, etc.)

**Location:** Create new folder in `C:\Projects\<descriptive-name>\`

**Examples:**
- ✅ `C:\Projects\system-architecture\multi-agent-coordination.md`
- ✅ `C:\Projects\development-patterns\worktree-best-practices.md`
- ✅ `C:\Projects\knowledge-base\general-ai-patterns.md`
- ❌ `C:\Users\HP\AppData\Local\Temp\...\general-doc.md` (WRONG)

**Create folder structure:**
```bash
mkdir C:\Projects\<new-folder-name>
mkdir C:\Projects\<new-folder-name>\docs
echo "# <Project Name>" > C:\Projects\<new-folder-name>\README.md
```

---

### Rule 3: Machine Context & Configuration
**Target:** Machine-specific state, logs, agent coordination

**Location:** `C:\scripts\_machine\` (this is correct)

**Examples:**
- ✅ `C:\scripts\_machine\worktrees.pool.md` (agent worktree allocation)
- ✅ `C:\scripts\_machine\reflection.log.md` (session learnings)
- ✅ `C:\scripts\_machine\knowledge-base\` (machine knowledge)

**This is the ONLY exception** - machine state stays in `C:\scripts\_machine\`

---

### Rule 4: NEVER Use Scratchpad for Permanent Docs
**Location:** `C:\Users\HP\AppData\Local\Temp\claude\...\scratchpad\`

**Purpose:** ONLY for truly temporary working files (intermediate calculations, draft snippets)

**❌ DO NOT USE FOR:**
- Architecture documents
- Gap analyses
- Design documents
- API specifications
- Project documentation
- Anything that should survive the session

**✅ OK TO USE FOR:**
- Temporary calculations
- Draft code before writing to project
- Intermediate query results
- Quick notes during exploration

---

## 📝 DECISION TREE

```
Is this documentation?
│
├─ YES → Does it relate to an existing project?
│   │
│   ├─ YES → C:\Projects\<project>\docs\<file>.md
│   │
│   └─ NO → Is it machine state/config?
│       │
│       ├─ YES → C:\scripts\_machine\<file>.md
│       │
│       └─ NO → Create new folder: C:\Projects\<new-folder>\docs\<file>.md
│
└─ NO (truly temporary) → C:\Users\HP\AppData\Local\Temp\...\scratchpad\<file>
```

---

## 🔄 IMMEDIATE ACTION WHEN CREATING DOCS

**Before writing any analysis/documentation:**

1. **Determine project:** Which project does this relate to?
   - Hazina → `C:\Projects\hazina\docs\`
   - client-manager → `C:\Projects\client-manager\docs\`
   - Cross-project → Create new folder in `C:\Projects\`
   - Machine state → `C:\scripts\_machine\`

2. **Check if docs folder exists:**
   ```bash
   ls C:\Projects\<project>\docs
   # If doesn't exist:
   mkdir C:\Projects\<project>\docs
   ```

3. **Write directly to project folder:**
   ```bash
   # DO THIS:
   Write "C:\Projects\hazina\docs\analysis.md"

   # NOT THIS:
   Write "C:\Users\HP\AppData\Local\Temp\...\analysis.md"
   ```

4. **Add to project README if significant:**
   - Update `C:\Projects\<project>\README.md` to link to new doc
   - Add to table of contents if project has one

---

## ✅ VALIDATION CHECKLIST

Before completing any documentation task:

- [ ] Is the file in a proper project folder (not TEMP)?
- [ ] Is the docs folder version-controlled (git tracked)?
- [ ] Is the document discoverable (linked from README or index)?
- [ ] Will the document survive a reboot?
- [ ] Can another developer/agent find this document?

If any answer is NO → wrong location, fix it.

---

## 📊 CORRECT EXAMPLES (from today's fix)

**Original (WRONG):**
```
C:\Users\HP\AppData\Local\Temp\claude\C--scripts\70018d97-e998-4968-bfc4-508234735387\scratchpad\hazinacoder-gap-analysis.md
```

**Corrected (RIGHT):**
```
C:\Projects\hazina\docs\hazinacoder-gap-analysis.md
```

**Why it's right:**
- ✅ Lives in Hazina project folder
- ✅ Version controlled with git
- ✅ Discoverable by others
- ✅ Survives across sessions
- ✅ Lives next to the code it documents

---

**Updated:** 2026-02-02
**Status:** MANDATORY PROTOCOL - Always follow
**User Priority:** HIGH - Explicitly requested
