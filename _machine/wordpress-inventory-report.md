# WordPress Plugin & Theme Symlink Migration - Discovery Report

**Date:** 2026-03-03
**Scanned By:** Claude Code Agent (agent-007)
**Task:** #869cb8r1j (Phase 1 Discovery)

---

## Executive Summary

- **Total Custom Plugins:** 2
- **Total Custom Themes:** 5
- **Total Items with Git:** 6
- **Total Items without Git:** 1
- **Ready for Immediate Symlink:** 4
- **Needs Commit First:** 2
- **Needs Git Initialization:** 1

---

## Complete Inventory

| # | Type | Folder Name | Current Path | Git | Remote URL | Uncommitted | Project Repo | Status |
|---|------|-------------|--------------|-----|------------|-------------|--------------|--------|
| 1 | Plugin | artrevisionist-wordpress | E:\xampp\htdocs\wp-content\plugins\artrevisionist-wordpress | ✅ Yes | github.com/martiendejong/artrevisionist-wordpress.git | 0 | C:\Projects\artrevisionist-wordpress | ✅ Ready |
| 2 | Plugin | simple-translation-manager | E:\xampp\htdocs\wp-content\plugins\simple-translation-manager | ✅ Yes | github.com/martiendejong/simple-translation-manager.git | 0 | ❌ NOT FOUND | ⚠️ Clone First |
| 3 | Theme | artrevisionist-wp-theme | E:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme | ✅ Yes | github.com/martiendejong/artrevisionist-wp-theme.git | 2 | C:\Projects\artrevisionist-wp-theme | ⚠️ Commit First |
| 4 | Theme | hydro-vision | E:\xampp\htdocs\wp-content\themes\hydro-vision | ✅ Yes | github.com/martiendejong/wp-pro-hydro.git | 0 | ❌ NOT FOUND | ⚠️ Clone First |
| 5 | Theme | martiendejong-wp-theme | E:\xampp\htdocs\wp-content\themes\martiendejong-wp-theme | ✅ Yes | github.com/martiendejong/martiendejong-wp-theme.git | 29 | C:\Projects\martiendejong-wp-theme | ⚠️ Commit First |
| 6 | Theme | prospergenics-wp-theme | E:\xampp\htdocs\wp-content\themes\prospergenics-wp-theme | ✅ Yes | github.com/martiendejong/prospergenics-theme.git | 0 | ❌ NOT FOUND | ⚠️ Clone First |
| 7 | Theme | maasai-investments-theme | E:\xampp\htdocs\wp-content\themes\maasai-investments-theme | ❌ No | N/A | N/A | N/A | 🔴 Init Git First |

---

## Category Breakdown

### ✅ Ready for Immediate Symlink (1 item)
**Can replace with symlink immediately - no uncommitted changes, repo exists**

1. **artrevisionist-wordpress** (Plugin)
   - Git repo exists at: `C:\Projects\artrevisionist-wordpress`
   - Current location: `E:\xampp\htdocs\wp-content\plugins\artrevisionist-wordpress`
   - Action: Replace with symlink
   - Risk: Low

---

### ⚠️ Needs Commit First (2 items)
**Has uncommitted changes - commit and push before symlinking**

2. **artrevisionist-wp-theme** (Theme)
   - Git repo exists at: `C:\Projects\artrevisionist-wp-theme`
   - Uncommitted changes: 2 files
     - Deleted: `assets/favicon.png`
     - Untracked: `add-faqs.php`
   - Action: Commit changes → Push → Replace with symlink
   - Risk: Low (small changes)

3. **martiendejong-wp-theme** (Theme)
   - Git repo exists at: `C:\Projects\martiendejong-wp-theme`
   - Uncommitted changes: 29 files
     - Modified: `assets/js/main.js`, `functions.php`, `languages/en.json`, `languages/nl.json`, `single.php`, ...
   - Action: Review changes → Commit → Push → Replace with symlink
   - Risk: Medium (many changes, needs review)

---

### ⚠️ Needs Clone First (3 items)
**Git repo exists on GitHub but not cloned to C:\Projects or E:\projects**

4. **simple-translation-manager** (Plugin)
   - Remote: `github.com/martiendejong/simple-translation-manager.git`
   - No uncommitted changes
   - Action: Clone to C:\Projects → Replace with symlink
   - Risk: Low

5. **hydro-vision** (Theme)
   - Remote: `github.com/martiendejong/wp-pro-hydro.git`
   - No uncommitted changes
   - Action: Clone to C:\Projects → Replace with symlink
   - Risk: Low

6. **prospergenics-wp-theme** (Theme)
   - Remote: `github.com/martiendejong/prospergenics-theme.git`
   - No uncommitted changes
   - Action: Clone to C:\Projects → Replace with symlink
   - Risk: Low

---

### 🔴 Needs Git Initialization (1 item)
**Not in Git - needs repository creation**

7. **maasai-investments-theme** (Theme)
   - Not a Git repository
   - Action: Review code → Create GitHub repo → Initialize Git → Push → Replace with symlink
   - Risk: Medium (requires Git setup)

---

## Recommended Migration Order

**Priority 1 - Immediate (Low Risk):**
1. ✅ artrevisionist-wordpress (Plugin) - Ready now

**Priority 2 - Quick Wins (Clone repos):**
2. ⚠️ simple-translation-manager (Plugin) - Clone first
3. ⚠️ hydro-vision (Theme) - Clone first
4. ⚠️ prospergenics-wp-theme (Theme) - Clone first

**Priority 3 - Needs Commits (Review required):**
5. ⚠️ artrevisionist-wp-theme (Theme) - 2 uncommitted changes
6. ⚠️ martiendejong-wp-theme (Theme) - 29 uncommitted changes (REVIEW CAREFULLY)

**Priority 4 - Needs Git Setup (Highest effort):**
7. 🔴 maasai-investments-theme (Theme) - Not in Git

---

## Detailed Status

### artrevisionist-wordpress (Plugin) ✅
```
Type: WordPress Plugin
Current: E:\xampp\htdocs\wp-content\plugins\artrevisionist-wordpress
Project: C:\Projects\artrevisionist-wordpress
Remote: https://github.com/martiendejong/artrevisionist-wordpress.git
Uncommitted: 0
Status: READY FOR SYMLINK
```

### simple-translation-manager (Plugin) ⚠️
```
Type: WordPress Plugin
Current: E:\xampp\htdocs\wp-content\plugins\simple-translation-manager
Project: NOT FOUND (needs clone)
Remote: https://github.com/martiendejong/simple-translation-manager.git
Uncommitted: 0
Status: CLONE REPO FIRST
Action: git clone https://github.com/martiendejong/simple-translation-manager.git C:\Projects\simple-translation-manager
```

### artrevisionist-wp-theme (Theme) ⚠️
```
Type: WordPress Theme
Current: E:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme
Project: C:\Projects\artrevisionist-wp-theme
Remote: https://github.com/martiendejong/artrevisionist-wp-theme.git
Uncommitted: 2 files
  - Deleted: assets/favicon.png
  - Untracked: add-faqs.php
Status: COMMIT FIRST
Action: Review → Commit → Push → Symlink
```

### hydro-vision (Theme) ⚠️
```
Type: WordPress Theme
Current: E:\xampp\htdocs\wp-content\themes\hydro-vision
Project: NOT FOUND (needs clone)
Remote: https://github.com/martiendejong/wp-pro-hydro.git
Uncommitted: 0
Status: CLONE REPO FIRST
Action: git clone https://github.com/martiendejong/wp-pro-hydro.git C:\Projects\wp-pro-hydro
```

### martiendejong-wp-theme (Theme) ⚠️
```
Type: WordPress Theme
Current: E:\xampp\htdocs\wp-content\themes\martiendejong-wp-theme
Project: C:\Projects\martiendejong-wp-theme
Remote: https://github.com/martiendejong/martiendejong-wp-theme.git
Uncommitted: 29 files (NEEDS REVIEW)
  - Modified: assets/js/main.js
  - Modified: functions.php
  - Modified: languages/en.json
  - Modified: languages/nl.json
  - Modified: single.php
  - ... (24 more files)
Status: COMMIT FIRST (REVIEW CAREFULLY)
Action: Review all changes → Commit → Push → Symlink
Risk: MEDIUM (many changes)
```

### prospergenics-wp-theme (Theme) ⚠️
```
Type: WordPress Theme
Current: E:\xampp\htdocs\wp-content\themes\prospergenics-wp-theme
Project: NOT FOUND (needs clone)
Remote: https://github.com/martiendejong/prospergenics-theme.git
Uncommitted: 0
Status: CLONE REPO FIRST
Action: git clone https://github.com/martiendejong/prospergenics-theme.git C:\Projects\prospergenics-theme
```

### maasai-investments-theme (Theme) 🔴
```
Type: WordPress Theme
Current: E:\xampp\htdocs\wp-content\themes\maasai-investments-theme
Project: NOT FOUND
Remote: NONE (not in Git)
Uncommitted: N/A
Status: NEEDS GIT INITIALIZATION
Action:
  1. Review code
  2. Create GitHub repo: martiendejong/maasai-investments-theme
  3. Initialize Git
  4. Commit all files
  5. Push to GitHub
  6. Clone to E:\Projects\maasai-investments-theme
  7. Replace with symlink
Risk: MEDIUM (requires complete Git setup)
```

---

## Next Steps

### Immediate Actions
1. ✅ Create individual ClickUp tasks for each plugin/theme (7 tasks)
2. ⚠️ Assign priority labels (P1, P2, P3, P4)
3. ⚠️ Start with P1 task (artrevisionist-wordpress) to validate process

### Per-Task Workflow
Each task will follow this pattern:
1. **Clone repo** (if needed)
2. **Commit changes** (if needed)
3. **Test WordPress** (ensure site works before symlink)
4. **Backup current folder** (safety measure)
5. **Replace with symlink** (use mklink /D)
6. **Test WordPress** (ensure site still works)
7. **Document** (update PROJECT_MASTER_MAP.md)
8. **Complete task** (move to review)

---

## Risk Assessment

**Low Risk (4 items):**
- artrevisionist-wordpress ✅
- simple-translation-manager (clone)
- hydro-vision (clone)
- prospergenics-wp-theme (clone)

**Medium Risk (2 items):**
- artrevisionist-wp-theme (2 uncommitted)
- martiendejong-wp-theme (29 uncommitted - NEEDS CAREFUL REVIEW)

**High Risk (1 item):**
- maasai-investments-theme (no Git repo)

---

## Success Criteria

- [x] Complete inventory of plugins/themes
- [x] Identify Git status for each
- [x] Categorize by readiness
- [x] Recommend migration order
- [ ] Create individual ClickUp tasks (next step)
- [ ] Execute migrations one by one
- [ ] Document all changes

---

**Report Status:** COMPLETE
**Ready for Phase 2:** YES
**Recommended Start:** artrevisionist-wordpress (Plugin) - Low risk, immediate ready