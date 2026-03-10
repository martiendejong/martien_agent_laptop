# SESSION STARTUP CHECKLIST
**Purpose:** MANDATORY checks at start of EVERY session
**Location:** C:\scripts\_machine\SESSION_STARTUP_CHECKLIST.md
**Usage:** Claude reads this file at session start

---

## CRITICAL STARTUP PROTOCOL

### 1. Project Mapping Refresh (MANDATORY if doing project work)

**When:** ANY session involving code/projects

**Action:**
```powershell
# Quick validation
powershell -ExecutionPolicy Bypass -File C:\scripts\tools\project-validate.ps1
```

**If errors:** Run `project-update.ps1 -AutoFix`

**Why:** Ensures accurate paths, GitHub URLs, ClickUp boards

**Files to be aware of:**
- `C:\scripts\_machine\PROJECT_MASTER_MAP.md` - Master reference
- `C:\scripts\_machine\clickup-config.json` - Project mappings
- `C:\scripts\_machine\project-inventory.json` - Latest scan

### 2. Reflection Log Check (ALWAYS)

**When:** EVERY session

**Action:** Read last 5 entries from `C:\scripts\_machine\reflection.log.md`

**Why:** Learn from recent mistakes/successes

### 3. Worktree Pool Status (if coding)

**When:** Sessions with code changes

**Action:** Read `C:\scripts\_machine\worktrees.pool.md`

**Why:** Know which agent seats are free/busy

### 4. PR Dependencies Check (if doing PRs)

**When:** Creating or merging PRs

**Action:** Read `C:\scripts\_machine\pr-dependencies.md`

**Why:** Understand cross-repo dependencies

### 5. Active Tasks (if applicable)

**When:** Continuing previous work

**Action:** Check for any active TODO items or incomplete tasks

**Why:** Know what's in progress

---

## PROJECT WORK SPECIFIC CHECKS

If user mentions ANY project name:

1. **Look it up FIRST:**
   ```
   Read PROJECT_MASTER_MAP.md
   Search for project name
   ```

2. **Verify current state:**
   - Path exists? (check filesystem)
   - Git status clean? (git status)
   - ClickUp board known? (check config)

3. **If not found:**
   - Run `project-update.ps1` to scan
   - If still not found, offer `project-new.ps1`

4. **NEVER assume:**
   - ❌ "It's probably in C:\Projects"
   - ❌ "I remember it's at E:\projects"
   - ✅ "Let me check PROJECT_MASTER_MAP.md"
   - ✅ "Let me verify the path"

---

## NEW PROJECT WORKFLOW

User says: "maak een nieuw project"

**MANDATORY steps:**
1. Ask for: name, type, description
2. Run: `project-new.ps1 -Name X -Type Y -Description Z`
3. Verify: `project-validate.ps1`
4. Report: All paths, GitHub URL, ClickUp status

**NEVER:**
- Create folder manually
- Init git manually
- Add to config manually
- ❌ ALL of that = use project-new.ps1!

---

## MODIFIED PROJECT WORKFLOW

User: "ik heb de folder verplaatst" or "github remote is gewijzigd"

**MANDATORY steps:**
1. Run: `project-update.ps1 -AutoFix`
2. Verify: `project-validate.ps1`
3. Confirm: "Updated all mappings"

**NEVER:**
- Just update one file
- Assume other files will sync
- ❌ Manual updates = inconsistency!

---

## VALIDATION PASSING CRITERIA

**GOOD (ready to work):**
```
Errors: 0
Warnings: 0-3 (only "TBD" items)
```

**ATTENTION NEEDED:**
```
Errors: 1+
Action: Fix immediately with project-update.ps1
```

**CRITICAL FAILURE:**
```
Errors: 5+
Action: Full audit, manual fixes needed
```

---

## QUICK REFERENCE COMMANDS

```powershell
# Validate all projects
C:\scripts\tools\project-validate.ps1

# Scan and auto-fix inconsistencies
C:\scripts\tools\project-update.ps1 -AutoFix

# Create new project
C:\scripts\tools\project-new.ps1 -Name "my-app" -Type fullstack

# Rescan all repos
C:\scripts\temp\scan-all-projects.ps1
```

---

**Last Updated:** 2026-03-01
**Compliance:** ZERO TOLERANCE - Session startup without validation = risk of inconsistency
