# Folder Network Map - Quick Reference

**Location:** `folder-network.md` (same directory)
**Purpose:** Fast lookup for when to update folder network map

---

## ⚡ WHEN TO UPDATE (During Work)

### ✅ File Operations
```
Copy/Move file → Update source AND destination folders
Create folder   → Add new entry immediately
Delete folder   → Archive entry, note deprecation
Rename folder   → Update all references
```

### ✅ Discovery Operations
```
Find sync (Google Drive, Git)  → Update "Sync Status"
Find related folders           → Update "Related Folders"
Discover workflow              → Add to "Workflows"
Notice access pattern          → Update "Access Patterns"
```

### ✅ Communication Operations
```
Email files from folder → Add "Email" to destinations
Upload to cloud         → Document cloud destination
Share files             → Note sharing mechanism
```

---

## 📋 TEMPLATE (Copy-Paste)

```markdown
## FOLDER_PATH

**Purpose:**

**Sources:**
-

**Destinations:**
-

**Related Folders:**
-

**Workflows:**
1.

**Sync Status:**
-

**Access Patterns:**
-

**Key Files:**
-

**Notes:**
-
```

---

## 🎯 QUICK EXAMPLES

### New Folder Created
```markdown
## C:\projects\new-project\
**Purpose:** [What is this folder for?]
**Sources:** - [Where will files come from?]
**Destinations:** - [Where will files go?]
**Related Folders:** - [Any related work folders?]
**Workflows:** 1. [Common operations?]
**Sync Status:** - ❌ No sync configured
**Access Patterns:** - New folder, high activity expected
```

### File Moved
```markdown
# Update source folder:
## C:\Users\HP\Downloads\
**Destinations:**
- C:\projects\new-project - Project files ← ADD

# Update destination folder:
## C:\projects\new-project\
**Sources:**
- C:\Users\HP\Downloads - Initial downloads ← ADD
```

### Sync Discovered
```markdown
## C:\projects\synced-folder\
**Destinations:**
- G:\Mijn Drive\Backup - Google Drive sync ← ADD

**Sync Status:**
- ✅ Google Drive Desktop - Bidirectional sync ← ADD
```

### Workflow Documented
```markdown
## C:\projects\work-folder\
**Workflows:**
1. Document intake: Download → organize → upload ← ADD
2. Email workflow: Select → attach → send ← ADD
```

---

## 🚫 COMMON MISTAKES

❌ **DON'T:**
- Wait until end of session (context lost)
- Skip temporary folders (they matter!)
- Forget to update BOTH source and destination
- Leave entries incomplete

✅ **DO:**
- Update immediately during operation
- Document ALL folders (even temporary)
- Update both sides of relationship
- Use template for structure

---

## 🔗 INTEGRATION POINTS

**Check folder-network.md BEFORE:**
- Moving files (understand existing relationships)
- Creating folders (check naming conventions)
- Organizing downloads (know where files should go)

**Update folder-network.md AFTER:**
- Every file operation
- Discovering new relationships
- Learning new workflows

---

## 📊 SELF-CHECK

Ask yourself after any file operation:
- [ ] Did I move/copy files between folders?
- [ ] Did I create a new folder?
- [ ] Did I discover a sync relationship?
- [ ] Did I use a workflow repeatedly?
- [ ] Did I email files from a folder?

If YES to any → Update folder-network.md NOW

---

**Location:** `C:\scripts\_machine\knowledge-base\02-MACHINE\folder-network.md`
**Also See:**
- `continuous-improvement.md` § Folder Network Map
- `DEFINITION_OF_DONE.md` § Documentation
- `agentidentity/cognitive-systems/EXECUTIVE_FUNCTION.md` § Operational Routines
