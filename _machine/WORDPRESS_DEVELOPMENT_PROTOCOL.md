# WordPress Development Protocol

**CREATED:** 2026-03-03
**PURPOSE:** PREVENT fundamental reasoning failures about WordPress site development
**CRITICALITY:** ABSOLUTE - This protocol is NON-NEGOTIABLE

═══════════════════════════════════════════════════════════════════════

## 🚨 CRITICAL CONTEXT DETECTION

**BEFORE taking ANY action on a website project:**

### Step 1: Is this a WordPress site?

**Indicators:**
- Project name mentions: theme, plugin, wp-, wordpress
- User mentions: xampp, local WordPress, wp-admin
- Directory structure: wp-content/themes/, wp-content/plugins/
- Files: functions.php, header.php, footer.php, style.css with WordPress theme headers

**If YES → STOP and execute WordPress Protocol below**

### Step 2: Check Project Master Map

**MANDATORY FIRST ACTION:**
```powershell
Read-Content C:\scripts\_machine\PROJECT_MASTER_MAP.md
```

Look for:
- WordPress installation paths
- Theme/plugin locations
- Database names
- Switching scripts

**If project NOT in map → ASK USER before assuming anything**

═══════════════════════════════════════════════════════════════════════

## 📍 WORDPRESS SITE LOCATIONS

### Primary WordPress Installation
**Path:** `E:\xampp\htdocs\`
**Type:** Shared WordPress installation with multiple databases
**Management:** Database switching (NOT separate WordPress installations)

### Themes Location
**Path:** `E:\xampp\htdocs\wp-content\themes\`
**All themes persist** - only database switches

### Plugins Location
**Path:** `E:\xampp\htdocs\wp-content\plugins\`
**All plugins persist** - only database switches

### Languages Location (Per Theme)
**Path:** `E:\xampp\htdocs\wp-content\themes\{theme-name}\languages\`
**Files:** `en.json`, `nl.json`, `.pot`, `.po`, `.mo`

═══════════════════════════════════════════════════════════════════════

## 🔄 WORDPRESS SWITCHING SCRIPT

**Location:** `C:\scripts\tools\`
**Primary Script:** `wp-switch-and-setup.ps1`

### Available Sites

| Site Name | Database | Theme | Command |
|-----------|----------|-------|---------|
| **martiendejong.nl** | `martiendejong` | `martiendejong-wp-theme` | `.\wp-switch-and-setup.ps1 -Site martiendejong` |
| **ArtRevisionist** | `artrevisionist` | `artrevisionist-wp-theme` | `.\wp-switch-and-setup.ps1 -Site artrevisionist` |
| **Hydro Vision** | `hydrovision` | `hydro-vision` | `.\wp-switch-and-setup.ps1 -Site hydrovision` |
| **Maasai Investments** | `maasaiinvestments` | `maasai-investments-theme` | `.\wp-switch-and-setup.ps1 -Site maasaiinvestments` |

### Usage Pattern

```powershell
# BEFORE working on ANY WordPress site
cd C:\scripts\tools
.\wp-switch-and-setup.ps1 -Site {sitename}

# Wait for confirmation
# Verify in browser: http://localhost/
# THEN start development
```

**What the script does:**
1. Updates `wp-config.php` with correct database name
2. Activates correct theme via MySQL
3. Installs WordPress if database empty
4. Flushes rewrite rules

═══════════════════════════════════════════════════════════════════════

## 🎯 DEVELOPMENT WORKFLOW

### For martiendejong.nl (EXAMPLE)

#### 1. Switch to Site
```powershell
cd C:\scripts\tools
.\wp-switch-and-setup.ps1 -Site martiendejong
```

#### 2. Navigate to Theme
```powershell
cd E:\xampp\htdocs\wp-content\themes\martiendejong-wp-theme
```

#### 3. Check Git Status
```powershell
git status
git branch --show-current
```

#### 4. Make Changes
- Edit theme files (functions.php, header.php, etc.)
- Update translations (languages/nl.json, languages/en.json)
- Test in browser: http://localhost/

#### 5. Git Workflow
```powershell
git add .
git commit -m "description"
git push origin main
```

#### 6. If there's a GitHub repo
- Theme repo example: `C:\Projects\martiendejong-wp-theme`
- This is the DEVELOPMENT repo
- It gets deployed TO: `E:\xampp\htdocs\wp-content\themes\martiendejong-wp-theme`

**CRITICAL:** Some themes have BOTH:
- Development repo: `C:\Projects\{theme-name}`
- WordPress location: `E:\xampp\htdocs\wp-content\themes\{theme-name}`

**ALWAYS check which one to edit!**

═══════════════════════════════════════════════════════════════════════

## 🌐 MULTILINGUAL WORDPRESS SITES

### Translation File Structure

WordPress themes use JSON translation files:

```
themes/{theme-name}/languages/
├── en.json          # English translations
├── nl.json          # Dutch translations
├── {theme}.pot      # Translation template (optional)
├── en_US.po/.mo     # Compiled translations (optional)
└── nl_NL.po/.mo     # Compiled translations (optional)
```

### JSON Translation Format

```json
{
  "nav.work": "Work",
  "services.ai.title": "AI Systems",
  "services.ai.desc": "Description here...",
  "hero.title": "AI That Works"
}
```

### Usage in PHP Templates

```php
<?php
// Load translation from JSON
$translations = get_theme_translations();
echo esc_html($translations['nav.work']);
?>
```

### Usage in JavaScript

```javascript
// Theme typically exposes translations via wp_localize_script
const t = mdjTranslations;
document.querySelector('.nav-work').textContent = t['nav.work'];
```

### IMPORTANT: Never assume translations don't exist!

**BEFORE creating new translation system:**
1. Check `languages/` folder
2. Read `functions.php` for translation loading
3. Grep for translation keys in templates
4. Check if Polylang/WPML plugin active

═══════════════════════════════════════════════════════════════════════

## ❌ COMMON MISTAKES TO AVOID

### Mistake 1: Working on wrong location
❌ **WRONG:** Editing `C:\Projects\{some-html-prototype}`
✅ **CORRECT:** Editing `E:\xampp\htdocs\wp-content\themes\{theme-name}`

### Mistake 2: Not switching WordPress database
❌ **WRONG:** Assuming WordPress shows correct site automatically
✅ **CORRECT:** Run switching script FIRST

### Mistake 3: Creating new translation system
❌ **WRONG:** Building custom i18n from scratch
✅ **CORRECT:** Check existing `languages/` folder first

### Mistake 4: Forgetting to check PROJECT_MASTER_MAP
❌ **WRONG:** Assuming project structure
✅ **CORRECT:** Read map, verify paths, ask if unclear

### Mistake 5: Ignoring WordPress-specific patterns
❌ **WRONG:** Treating as static HTML site
✅ **CORRECT:** Recognize PHP templates, WordPress functions, theme structure

═══════════════════════════════════════════════════════════════════════

## 🔍 PATTERN RECOGNITION CHECKLIST

**When user mentions a website project, CHECK:**

□ Is there a `functions.php` file anywhere?
□ Does `wp-content/themes/` exist in the path?
□ Does PROJECT_MASTER_MAP mention this site?
□ Is there a switching script for this site?
□ Does the site name match a known WordPress installation?
□ Are there `.php` template files (header, footer, single, page)?

**If ANY checkbox is YES → Execute WordPress Protocol**

═══════════════════════════════════════════════════════════════════════

## 📋 MANDATORY PRE-FLIGHT CHECKLIST

**BEFORE editing ANY website code:**

1. □ Read PROJECT_MASTER_MAP.md
2. □ Identify if WordPress site
3. □ If WordPress: Run switching script
4. □ Verify correct theme directory
5. □ Check existing translation system
6. □ Confirm with user if uncertain
7. □ THEN and ONLY THEN start editing

═══════════════════════════════════════════════════════════════════════

## 📚 KEY RESOURCES

- **Switching Script:** `C:\scripts\tools\wp-switch-and-setup.ps1`
- **Switching README:** `C:\scripts\tools\wordpress-switcher-README.md`
- **WordPress Root:** `E:\xampp\htdocs\`
- **Themes:** `E:\xampp\htdocs\wp-content\themes\`
- **Project Map:** `C:\scripts\_machine\PROJECT_MASTER_MAP.md`
- **XAMPP Control:** `E:\xampp\xampp-control.exe`

═══════════════════════════════════════════════════════════════════════

## 🎓 LEARNING FROM THIS FAILURE

**What went wrong (2026-03-03):**
- User asked about martiendejong.nl multilingual
- I assumed it was the HTML prototype in `C:\Projects\martiendejongnl\newsite\`
- I built a custom i18n system for static HTML
- I completely missed that it's a WordPress site with existing translations

**Root cause:**
- Did not check PROJECT_MASTER_MAP first
- Did not recognize WordPress pattern
- Did not look for existing WordPress installation
- Made assumptions instead of asking

**Prevention:**
- ALWAYS read PROJECT_MASTER_MAP first
- ALWAYS check for WordPress indicators
- ALWAYS look for existing systems before building new ones
- ALWAYS ask when uncertain

**This protocol exists to prevent this EXACT failure from EVER happening again.**

═══════════════════════════════════════════════════════════════════════

**SIGNATURE:** Jengo (Claude Agent)
**DATE:** 2026-03-03
**COMMITMENT:** This protocol is PERMANENT and NON-NEGOTIABLE
