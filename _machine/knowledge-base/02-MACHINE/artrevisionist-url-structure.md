# Art Revisionist URL Structure

**CRITICAL:** Document the correct terminology and URL hierarchy.

## URL Hierarchy

```
http://localhost/topics/{topic}/{topicpage}/{detailpage}/{evidencepage}
```

### 1. Topics Page (Archive)
- **URL:** `/topics` or `http://localhost/topics`
- **Description:** List of ALL topics in the system
- **Template:** `archive-b2bk_topic.php`
- **Post Type:** Archive of `b2bk_topic`

### 2. Topic (Category Level)
- **URL:** `/topics/valsuani` or `/topics/senufo`
- **Description:** Not a page, just part of the hierarchy
- **Example:** valsuani, senufo

### 3. Topic Page (Individual Topic)
- **URL:** `/topic/valsuani/who-founded-the-valsuani-foundry`
- **Description:** A specific topic page under a topic category
- **Template:** `single-b2bk_topic.php`
- **Post Type:** `b2bk_topic` (singular)
- **Example:** "Who Founded the Valsuani Foundry"

### 4. Detail Page (Sub-page of Topic Page)
- **URL:** `/topic/valsuani/who-founded-the-valsuani-foundry/carlo-valsuani-the-real-father-of-claude/`
- **Description:** Detail page under a topic page
- **Template:** `single-b2bk_detail.php`
- **Post Type:** `b2bk_detail`
- **Example:** "Carlo Valsuani, the Real Father of Claude"

### 5. Evidence Page (Sub-page of Detail Page)
- **URL:** `/topic/valsuani/who-founded-the-valsuani-foundry/carlo-valsuani-the-real-father-of-claude/carlos-biography-municipal-secretary/`
- **Description:** Evidence page under a detail page
- **Template:** `single-b2bk_evidence.php`
- **Post Type:** `b2bk_evidence`
- **Example:** "Carlo's Biography: Municipal Secretary"

## Terminology Summary

| Term | What It Is | URL Pattern | Template |
|------|-----------|-------------|----------|
| **Topics Page** | Archive of all topics | `/topics` | `archive-b2bk_topic.php` |
| **Topic** | Category level (not a page) | `/topics/{topic}` | N/A |
| **Topic Page** | Individual topic | `/topic/{topic}/{topicpage}` | `single-b2bk_topic.php` |
| **Detail Page** | Sub-page of topic page | `/topic/{topic}/{topicpage}/{detailpage}` | `single-b2bk_detail.php` |
| **Evidence Page** | Sub-page of detail page | `/topic/{topic}/{topicpage}/{detailpage}/{evidencepage}` | `single-b2bk_evidence.php` |

## Featured Image Layout Requirements

**REQUIREMENT (2026-01-30):** Topic pages and detail pages MUST have the SAME featured image layout:
- Smaller image (medium size, not large)
- Float left (not right)
- Same wrapper classes and styling
- Image should look identical between topic page and detail page

## File Locations

- **Theme:** `C:\xampp\htdocs\wp-content\themes\artrevisionist-wp-theme\`
- **Plugin:** `C:\xampp\htdocs\wp-content\plugins\artrevisionist-wordpress\`
- **Data:** `C:\stores\artrevisionist\{topic}\pages.json`
