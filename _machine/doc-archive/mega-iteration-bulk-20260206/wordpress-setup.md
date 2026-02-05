# Art Revisionist - WordPress Setup

**Last Updated:** 2026-01-31
**System:** Local XAMPP development environment

---

## WordPress Installation

### Location
- **WordPress Root:** `C:\xampp\htdocs\`
- **Local URL:** `http://localhost/`
- **Server:** XAMPP (Apache + MySQL + PHP)

### Access
XAMPP runs WordPress locally for development and testing.

---

## Custom Plugin: artrevisionist-wordpress

### Location
`C:\xampp\htdocs\wp-content\plugins\artrevisionist-wordpress\`

### Purpose
WordPress plugin that handles display and querying of Art Revisionist custom post types published from the ArtRevisionistAPI.

### Directory Structure
```
artrevisionist-wordpress/
├── artrevisionist-wordpress.php  (Main plugin file)
├── includes/
│   ├── class-b2bk-post-types.php      (Custom post type registration)
│   ├── class-b2bk-rest-api.php        (REST API endpoints)
│   └── class-b2bk-templates.php       (Display queries and templates)
├── templates/
│   ├── single-b2bk-topic.php          (Topic page template)
│   ├── single-b2bk-topic-page.php     (Topic page detail template)
│   ├── single-b2bk-detail.php         (Detail page template)
│   ├── single-b2bk-evidence.php       (Evidence page template)
│   └── archive-b2bk-topic.php         (Topic archive template)
└── assets/
    └── css/
        └── b2bk-styles.css            (Frontend styles)
```

### Key Files

#### class-b2bk-templates.php
**Location:** `C:\xampp\htdocs\wp-content\plugins\artrevisionist-wordpress\includes\class-b2bk-templates.php`

**Purpose:** Handles display queries for retrieving child pages in correct order.

**Critical Method:** `get_child_pages()` (line 57-78)
- Used by `get_topic_pages()`, `get_detail_pages()`, `get_evidence_pages()`
- **IMPORTANT:** Uses `'orderby'=>'menu_order'` to respect narrative sequence (NOT alphabetical)
- Returns child posts for a given parent based on meta relationships

**Recent Fix (2026-01-31):** Changed line 75 from `'orderby'=>'title'` to `'orderby'=>'menu_order'` to fix display order issue.

---

## Custom Post Types

The plugin registers 4 custom post types for Art Revisionist content:

### 1. b2bk_topic
Main topics (e.g., "Valsuani", "Degas")

**Meta Fields:**
- None (top-level parent)

### 2. b2bk_topic_page
Topic pages (e.g., "Who Founded the Valsuani Foundry?", "Claude Valsuani: Master Bronze Founder")

**Meta Fields:**
- `b2bk_parent_topic_id` - Links to parent topic
- `menu_order` - Display order within topic

**Example URL:** `http://localhost/topic/valsuani/`

### 3. b2bk_detail
Detail pages (e.g., "The Marcello Valsuani Myth Debunked", "Carlo Valsuani: The Real Father of Claude")

**Meta Fields:**
- `b2bk_parent_topic_page_id` - Links to parent topic page
- `menu_order` - Display order within topic page

### 4. b2bk_evidence
Evidence items (e.g., "Claude's Birth Certificate (1876)", "Document Analysis Report")

**Meta Fields:**
- `b2bk_parent_detail_id` - Links to parent detail page
- `menu_order` - Display order within detail page

---

## REST API Endpoints

**Namespace:** `b2b-knowledge/v1`

The plugin exposes REST API endpoints for publishing content from ArtRevisionistAPI.

### Example Endpoints
- `POST /wp-json/b2b-knowledge/v1/topics` - Create topic
- `POST /wp-json/b2b-knowledge/v1/topic-pages` - Create topic page
- `POST /wp-json/b2b-knowledge/v1/details` - Create detail page
- `POST /wp-json/b2b-knowledge/v1/evidence` - Create evidence item

**Important:** All endpoints accept `menu_order` field to control display sequence.

---

## Data Flow: Art Revisionist → WordPress

### Publishing Workflow

1. **Source Data:** `C:\stores\artrevisionist\Valsuani\pages.json`
   - Contains hierarchical content structure
   - Each item has `order` field (1, 2, 3, etc.)

2. **API Layer:** `C:\Projects\artrevisionist\ArtRevisionistAPI\Services\WordPress\WordPressPublishService.cs`
   - Reads `order` field from pages.json
   - Sends to WordPress REST API as `menu_order` field
   - Methods: `CreateTopicPageAsync()`, `CreateDetailAsync()`, `CreateEvidenceAsync()`

3. **WordPress Database:** `wp_posts` table
   - Stores `menu_order` value for each post
   - WordPress core field, standard for custom ordering

4. **WordPress Plugin:** `class-b2bk-templates.php`
   - Queries posts using `'orderby'=>'menu_order'`
   - Returns items in correct narrative sequence (NOT alphabetical)

5. **Frontend Display:** WordPress templates render content in correct order

---

## Display Order Fix (2026-01-31)

### Problem
WordPress displayed items alphabetically by title instead of narrative sequence.

### Root Cause
`class-b2bk-templates.php` line 75 used `'orderby'=>'title'` instead of `'orderby'=>'menu_order'`.

### Solution (3-part fix)
1. ✅ Added `order` field to all 51 items in `pages.json`
2. ✅ Updated `WordPressPublishService.cs` to send `menu_order` in API payload
3. ✅ Updated `class-b2bk-templates.php` to query by `menu_order` instead of `title`

### Verification
After rebuilding API, restarting service, and re-publishing:
- Check `http://localhost/topic/valsuani/`
- Verify pages appear as: Who Founded → Claude → Lost-Wax → Authentication → Legacy
- Verify details and evidence also appear in correct narrative order

---

## Development Notes

### User's Workflow
User develops WordPress plugin locally using XAMPP, then publishes content from Art Revisionist frontend using "Publish to WordPress" or "Sync to WordPress" function.

### Testing After Changes
1. Edit plugin files in `C:\xampp\htdocs\wp-content\plugins\artrevisionist-wordpress\`
2. No need to restart XAMPP (PHP files are reloaded on each request)
3. Re-publish content from Art Revisionist frontend to see changes
4. Verify on `http://localhost/topic/<topic-name>/`

### Common Issues
- **Items still alphabetical after re-publishing:** Check that `WordPressPublishService.cs` includes `menu_order` in payload AND `class-b2bk-templates.php` queries by `menu_order`
- **Items missing after publish:** Check post_status (should be 'publish' or match parent status)
- **Breadcrumbs broken:** Check meta field relationships (`b2bk_parent_*_id` fields)

---

## Related Files

### Backend (C# API)
- `C:\Projects\artrevisionist\ArtRevisionistAPI\Services\WordPress\WordPressPublishService.cs`

### Data
- `C:\stores\artrevisionist\Valsuani\pages.json` (Valsuani topic)
- `C:\stores\artrevisionist\<topic>\pages.json` (Other topics)

### Frontend
- `C:\Projects\artrevisionist\` (React frontend)

### Documentation
- `C:\stores\valsuani\PUBLICATION_STRATEGY.md`

---

## WordPress Admin

### Access
- URL: `http://localhost/wp-admin/`
- User: (user manages credentials)

### Useful Admin Pages
- Posts > Topics (b2bk_topic)
- Posts > Topic Pages (b2bk_topic_page)
- Posts > Details (b2bk_detail)
- Posts > Evidence (b2bk_evidence)
- Plugins > Installed Plugins > Art Revisionist WordPress

---

## Knowledge Base References

- **Machine Setup:** `02-MACHINE/software-inventory.md` (XAMPP)
- **Projects:** `05-PROJECTS/INDEX.md`
- **URL Structure:** `02-MACHINE/artrevisionist-url-structure.md`
