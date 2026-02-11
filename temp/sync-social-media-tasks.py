"""
Sync Social Media Architecture Plan to ClickUp tasks.
Creates new tasks and updates existing ones based on the architecture document.
"""
import subprocess
import json
import time
import sys

API_KEY = "pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI"
LIST_ID = "901214097647"
ASSIGNEE = "74525428"
BASE_URL = "https://api.clickup.com/api/v2"

def api_call(method, endpoint, data=None):
    """Make ClickUp API call."""
    cmd = ['curl', '-s', '-X', method, '-H', f'Authorization: {API_KEY}',
           '-H', 'Content-Type: application/json']
    if data:
        cmd.extend(['-d', json.dumps(data)])
    cmd.append(f'{BASE_URL}/{endpoint}')
    result = subprocess.run(cmd, capture_output=True)
    return json.loads(result.stdout.decode('utf-8'))

def create_task(name, description, priority=3, status="todo", tags=None, parent=None):
    """Create a ClickUp task. Priority: 1=urgent, 2=high, 3=normal, 4=low"""
    payload = {
        "name": name,
        "description": description,
        "assignees": [int(ASSIGNEE)],
        "status": status,
        "priority": priority,
        "tags": tags or ["social-media-pipeline"]
    }
    if parent:
        payload["parent"] = parent

    result = api_call("POST", f"list/{LIST_ID}/task", payload)
    task_id = result.get("id", "ERROR")
    task_name = result.get("name", name)
    if "err" in result:
        print(f"  ERROR creating '{name}': {result['err']}")
        return None
    print(f"  CREATED: {task_id} | {task_name}")
    time.sleep(0.3)  # Rate limiting
    return task_id

def update_task(task_id, name=None, description=None, status=None, priority=None):
    """Update an existing ClickUp task."""
    payload = {}
    if name: payload["name"] = name
    if description: payload["description"] = description
    if status: payload["status"] = status
    if priority: payload["priority"] = priority

    result = api_call("PUT", f"task/{task_id}", payload)
    if "err" in result:
        print(f"  ERROR updating {task_id}: {result['err']}")
        return False
    print(f"  UPDATED: {task_id} | {result.get('name', '?')}")
    time.sleep(0.3)
    return True

# ============================================================================
# EXISTING TASKS TO UPDATE
# ============================================================================
print("=" * 70)
print("PHASE 0: UPDATING EXISTING TASKS")
print("=" * 70)

# Update Platform Publishing Integration (currently blocked)
update_task("869c1dnww",
    name="Platform Publishing Integration - IPublishingProvider + WordPress First",
    description="""## Updated: Social Media Pipeline v2

**Original scope:** Hazina ISocialPublisher Pipeline for 4 Major Platforms
**New scope:** IPublishingProvider abstraction in client-manager with WordPress as FIRST provider.

### Architecture Change
Instead of relying solely on Hazina ISocialPublisher (which targets social platforms), we now create a client-manager-level `IPublishingProvider` interface that supports:
- WordPress (Application Password auth, REST API)
- LinkedIn, Facebook, Twitter, Instagram (OAuth via Hazina ISocialPublisher)

### What Changed
- WordPress publishing uses direct REST API calls (not Hazina provider)
- Social platforms still use Hazina ISocialPublisher under the hood
- Unified interface: ConnectAsync, PublishPostAsync, UpdatePostAsync, GetMetricsAsync

### Dependencies
- Depends on: Phase 1 tasks (IPublishingProvider interface, WordPress provider)
- Blocks: Phase 3 tasks (WordPress Connection Wizard, Post Editor Publishing Sidebar)

### Reference
See `docs/SOCIAL_MEDIA_ARCHITECTURE.md` Section 5.1""",
    status="todo",
    priority=1)

# Update Integration Testing (currently blocked)
update_task("869bzf5qc",
    name="Integration Testing & Documentation - WordPress Publishing + E2E Test Suite",
    description="""## Updated: Social Media Pipeline v2

**Scope expanded:** Now includes comprehensive WordPress publishing tests + E2E Playwright tests.

### Test Requirements
1. **WordPress Integration Tests:**
   - Connect to WordPress site (Application Password)
   - Publish post → verify on WordPress via REST API
   - Update published post → verify changes
   - Upload featured image → verify media endpoint
   - Category mapping → verify categories created/assigned

2. **Unit Tests:**
   - PostStateMachine: all state transitions (draft→approved→scheduled→published→failed)
   - ScheduledPublishingHostedService: polling logic, error handling
   - IPublishingProvider: mock provider tests

3. **E2E Tests (Playwright):**
   - Create post (Quick mode) → Edit → Publish to WordPress
   - Connect WordPress site via wizard → verify connection
   - Batch generate posts → approve → publish

4. **Test Environments:**
   - Local XAMPP WordPress (dev)
   - Production WordPress site (staging)

### Reference
See `docs/SOCIAL_MEDIA_ARCHITECTURE.md` Section 5.4""",
    status="backlog",
    priority=3)

# Update Platform Publisher with AI Image Matching (currently blocked)
update_task("869bz3gzc",
    name="Platform Publisher with AI Image Matching - Smart Visual Content for WordPress & Social",
    description="""## Updated: Social Media Pipeline v2

**Scope refined:** Image matching/generation integrated into the unified Post Editor (Screen 3).

### Implementation
- ImagePicker modal in Post Editor allows selecting from:
  - Uploaded images (drag & drop)
  - AI-suggested images (keyword matching via ImageSuggestionService)
  - Future: DALL-E generated images (Phase 4+)
- WordPress featured image: auto-upload to /wp-json/wp/v2/media
- Social platforms: platform-specific image requirements (aspect ratio, size)

### Dependencies
- Phase 1: WordPress media upload endpoint
- Phase 3: Post Editor with PublishPanel (ImagePicker integration)
- Phase 4+: DALL-E integration (nice-to-have)

### Reference
See `docs/SOCIAL_MEDIA_SCREEN_PLAN.md` Screen 3 (Post Editor) - Image Section""",
    status="backlog",
    priority=4)

print()

# ============================================================================
# PHASE 1: FOUNDATION (Week 1-2) - Priority: URGENT
# ============================================================================
print("=" * 70)
print("PHASE 1: FOUNDATION (Week 1-2)")
print("=" * 70)

p1_1 = create_task(
    "P1.1: Create IPublishingProvider Interface & WordPress Implementation",
    """## Overview
Create the core publishing abstraction and WordPress as the first concrete provider.

## Tasks
1. **Create `IPublishingProvider` interface** in `Services/Publishing/`:
   ```csharp
   Task<ConnectionResult> ConnectAsync(ProviderConnectionConfig config);
   Task<ConnectionTestResult> TestConnectionAsync(int projectId);
   Task DisconnectAsync(int projectId);
   Task<PublishResult> PublishPostAsync(SocialMediaPost post, PublishOptions options);
   Task<PublishResult> UpdatePostAsync(SocialMediaPost post);
   Task DeletePostAsync(string externalPostId);
   Task<ProviderMetrics> GetMetricsAsync(int projectId);
   Task<ImportResult> ImportPostsAsync(int projectId, ImportOptions options);
   ```

2. **Create `WordPressPublishingProvider`** implementing IPublishingProvider:
   - WordPress REST API client (HttpClient)
   - Auth: Basic Authentication with Application Password (base64)
   - POST /wp-json/wp/v2/posts (create)
   - PUT /wp-json/wp/v2/posts/{id} (update)
   - DELETE /wp-json/wp/v2/posts/{id} (delete)
   - POST /wp-json/wp/v2/media (image upload)
   - GET /wp-json/wp/v2/categories (list categories)
   - GET /wp-json/ (site info + connection test)

3. **Create WordPress API endpoints** in a new `WordPressProviderController`:
   - POST /api/providers/wordpress/connect
   - POST /api/providers/wordpress/test
   - POST /api/providers/wordpress/disconnect
   - POST /api/providers/wordpress/publish/{postId}
   - PUT /api/providers/wordpress/update/{postId}
   - GET /api/providers/wordpress/categories
   - GET /api/providers/{provider}/status

4. **Register in DI** (Program.cs, NOT ServiceRegistrationExtensions.cs!)

## Acceptance Criteria
- [ ] IPublishingProvider interface defined with all methods
- [ ] WordPressPublishingProvider connects to a real WordPress site
- [ ] Can publish a post to WordPress and get back the external URL
- [ ] Can upload a featured image
- [ ] Connection test returns site name + WP version
- [ ] All endpoints return proper error responses

## Architecture Decision
WordPress uses Application Password (not OAuth) because:
- Simpler setup (no callback URLs needed)
- WordPress 5.6+ built-in support
- No token expiration to manage
- Users control permissions directly

## References
- Gap: G2 (Enable WordPress Publishing Pipeline)
- Architecture: `docs/SOCIAL_MEDIA_ARCHITECTURE.md` Section 5.1.1 + 7.1
- Phase: 1 (Foundation)
- Priority: CRITICAL""",
    priority=1,
    tags=["social-media-pipeline", "phase-1", "backend", "wordpress"])

p1_2 = create_task(
    "P1.2: WordPress Database Migration - Tracking Fields",
    """## Overview
Add database fields to track the WordPress external post ID and site URL per published post.

## Database Changes (EF Core Migration)
```sql
ALTER TABLE SocialMediaPosts ADD ExternalWordPressPostId INTEGER NULL;
ALTER TABLE SocialMediaPosts ADD ExternalWordPressSiteUrl TEXT NULL;
```

## Entity Changes
In `SocialMediaPost.cs`:
```csharp
public int? ExternalWordPressPostId { get; set; }
public string? ExternalWordPressSiteUrl { get; set; }
```

## Migration Steps
1. Create migration: `dotnet ef migrations add AddWordPressTracking`
2. Verify migration script - no data loss
3. Update DbContext if needed (no special configuration needed for nullable fields)
4. Test against dev database

## Acceptance Criteria
- [ ] Migration created and applied successfully
- [ ] Existing data unaffected
- [ ] Fields nullable (not all posts go to WordPress)
- [ ] Can query posts by ExternalWordPressPostId

## References
- Architecture: Section 7.2 (Database Changes)
- Phase: 1 (Foundation)
- Priority: CRITICAL""",
    priority=1,
    tags=["social-media-pipeline", "phase-1", "backend", "database"])

p1_3 = create_task(
    "P1.3: Background Scheduler - ScheduledPublishingHostedService",
    """## Overview
Create an IHostedService that automatically publishes posts when their scheduled date arrives.
Currently there is a ScheduledDate field but NOTHING polls it.

## Implementation
Create `Services/Publishing/ScheduledPublishingHostedService.cs`:

```csharp
public class ScheduledPublishingHostedService : BackgroundService
{
    // Poll every 60 seconds
    // Query: WHERE Status = 'scheduled' AND ScheduledDate <= DateTime.UtcNow
    // For each: call IPublishingProvider.PublishPostAsync()
    // On success: Status = 'published', set PublishedDate
    // On failure: Status = 'failed', log error, increment retry count
}
```

## Key Decisions
- **IHostedService over Hangfire**: No external dependency needed. Accepted trade-off: up to 60 second delay after app restart.
- **Polling interval**: 60 seconds (configurable via appsettings.json)
- **Retry logic**: 3 retries with exponential backoff (1min, 5min, 15min)
- **Provider resolution**: Determine target provider from post's Platform field

## Registration
In `Program.cs`:
```csharp
builder.Services.AddHostedService<ScheduledPublishingHostedService>();
```

## Acceptance Criteria
- [ ] Service starts with the application
- [ ] Polls every 60 seconds for due posts
- [ ] Successfully publishes to WordPress when scheduled time arrives
- [ ] Updates post status to 'published' with timestamp
- [ ] Handles failures gracefully (status = 'failed', error logged)
- [ ] Does not double-publish (uses database transaction or status check)
- [ ] Logs all publish attempts (success + failure)

## References
- Gap: G3 (Implement Background Scheduler)
- Architecture Decision: AD3 (IHostedService over Hangfire)
- Phase: 1 (Foundation)
- Priority: CRITICAL""",
    priority=1,
    tags=["social-media-pipeline", "phase-1", "backend"])

p1_4 = create_task(
    "P1.4: Consolidate Status Fields - Remove ApprovalStatus",
    """## Overview
SocialMediaPost currently has TWO status fields: `Status` and `ApprovalStatus`. This causes confusion.
Merge into single `Status` field.

## Current State
- `Status`: draft, approved, scheduled, published, failed, cancelled
- `ApprovalStatus`: Pending, Approved, Rejected, NeedsRevision (separate enum)
- Both updated independently → inconsistent states possible

## Target State
Single `Status` field with values:
- `draft` (initial state, replaces 'initial')
- `approved` (replaces ApprovalStatus.Approved)
- `rejected` (replaces ApprovalStatus.Rejected)
- `scheduled` (date set, awaiting publish)
- `published` (successfully published)
- `failed` (publish attempt failed)
- `cancelled` (user cancelled)

## Migration Steps
1. **Data migration:**
   ```sql
   -- Copy ApprovalStatus into Status where applicable
   UPDATE SocialMediaPosts SET Status = 'approved' WHERE ApprovalStatus = 'Approved' AND Status = 'initial';
   UPDATE SocialMediaPosts SET Status = 'rejected' WHERE ApprovalStatus = 'Rejected';
   ```

2. **Mark ApprovalStatus as [Obsolete]** in entity (don't remove yet)

3. **Update PostStateMachine.cs:**
   - Remove all ApprovalStatus checks
   - Use single Status for all transitions
   - Valid transitions:
     - draft → approved, rejected, cancelled
     - approved → scheduled, published (immediate), cancelled
     - scheduled → published, failed, cancelled
     - failed → scheduled (retry), draft (edit)

4. **Update all services/controllers** referencing ApprovalStatus

5. **Update frontend** - remove all ApprovalStatus references

## Acceptance Criteria
- [ ] Single Status field drives all workflow
- [ ] ApprovalStatus marked [Obsolete] (not deleted yet for safety)
- [ ] PostStateMachine uses only Status
- [ ] All API responses use Status only
- [ ] Frontend shows correct status badges
- [ ] Existing data migrated correctly

## References
- Gap: G5 (Consolidate Status Fields)
- Architecture: Section 5.1.3
- Phase: 1 (Foundation)
- Priority: CRITICAL""",
    priority=1,
    tags=["social-media-pipeline", "phase-1", "backend", "database"])

p1_5 = create_task(
    "P1.5: Persist Wizard Sessions to Database",
    """## Overview
PostGenerationWizardService uses `ConcurrentDictionary` for wizard sessions.
These are lost on app restart. Move to database-backed persistence.

## Current State
```csharp
// PostGenerationWizardService.cs
private readonly ConcurrentDictionary<string, WizardSession> _sessions = new();
```

## Solution Options
**Option A (Recommended): JSON column in existing table**
- Add `WizardSessionData` (JSON text) column to a new `WizardSessions` table
- Simple CRUD, no complex schema needed
- Session ID = GUID, stored with ProjectId + CreatedAt + ExpiresAt

**Option B: Distributed cache (Redis)**
- Overkill for current scale, adds dependency

## Implementation
1. Create `WizardSession` entity:
   ```csharp
   public class WizardSession {
       public string Id { get; set; } // GUID
       public int ProjectId { get; set; }
       public string SessionData { get; set; } // JSON
       public DateTime CreatedAt { get; set; }
       public DateTime ExpiresAt { get; set; }
       public string Status { get; set; } // active, completed, expired
   }
   ```

2. Create EF migration for WizardSessions table
3. Update PostGenerationWizardService to use DbContext
4. Add cleanup: delete expired sessions (ExpiresAt < now) on startup + hourly

## Acceptance Criteria
- [ ] Wizard sessions survive app restart
- [ ] Session data stored as JSON in database
- [ ] Expired sessions auto-cleaned
- [ ] No performance regression (< 50ms for session CRUD)

## References
- Gap: G4 (Migrate Wizard Sessions to Database)
- Phase: 1 (Foundation)
- Priority: CRITICAL""",
    priority=1,
    tags=["social-media-pipeline", "phase-1", "backend", "database"])

print()

# ============================================================================
# PHASE 2: MERGE GENERATION FLOWS (Week 2-3) - Priority: HIGH
# ============================================================================
print("=" * 70)
print("PHASE 2: MERGE GENERATION FLOWS (Week 2-3)")
print("=" * 70)

p2_1 = create_task(
    "P2.1: Unified Post Generator - Quick Mode & Batch Mode",
    """## Overview
Merge 5 separate generation screens into ONE unified PostGenerator component with two modes.

## Current State (5 overlapping generators)
1. `SocialMediaPostGenerator.tsx` - Quick single post generation
2. `MultiPlatformPostCreator.tsx` - Multi-platform creation
3. `PostGenerationWizard.tsx` - Bulk wizard with categories/hooks
4. `PostIdeasGenerator.tsx` - Idea brainstorming
5. `ParentPostManager.tsx` - Parent/child management

## Target: New `PostGenerator.tsx`
**Two modes via toggle:**

### Quick Mode (default)
- Platform selector (button grid: LinkedIn, Twitter, Facebook, Instagram, WordPress, TikTok, YouTube)
- Topic input (textarea, required)
- Advanced options (collapsible): Tone, CTA, Hashtags toggle, Emojis toggle
- [Generate 4 Options] button
- 4 option cards with: content, hashtags, character count, AI reasoning
- [Save as Draft] per option → calls existing POST /api/social-posts/generate

### Batch Mode
Step 1 - Configure:
- Category multi-select (chips with ✕)
- Content hook multi-select (chips with ✕)
- Optional instruction text
- Target date picker
- Number of ideas: 6/12/18/24
- [Generate N Ideas] button

Step 2 - Review:
- [Select All] / [Deselect All]
- Idea cards (3-column grid) with checkbox, image area, title, content, category/hook tags
- [Create N Drafts] button

Step 3 - Done:
- Success message + list of created posts with [Edit] links
- [View All Posts] / [Create More] buttons

## Backend
No backend changes needed - reuses existing endpoints:
- POST /api/social-posts/generate
- POST /api/social-posts/generate-batch

## Acceptance Criteria
- [ ] Single component replaces 5 old generators
- [ ] Quick Mode: topic → 4 options → save as draft
- [ ] Batch Mode: configure → review → create drafts
- [ ] Loading states with estimated times
- [ ] Character count color-coded per platform
- [ ] Responsive (desktop 2x2 grid, mobile single column)

## References
- Gap: G1 (Create Unified Post Generator)
- Screen Plan: Screen 2 (Post Generator)
- Phase: 2 (Merge Generation Flows)
- Priority: CRITICAL""",
    priority=2,
    tags=["social-media-pipeline", "phase-2", "frontend"])

p2_2 = create_task(
    "P2.2: Post Hub Refactoring - SocialMediaPosts.tsx",
    """## Overview
Refactor the main posts list page to remove the embedded generator tab and create a clean post management hub.

## Current State
`SocialMediaPosts.tsx` (892 lines) has an embedded generator tab mixed with the post list.

## Target State
Clean hub page with:

### Header
- Title "Posts" + [+ Create New Post] button (opens PostGenerator overlay/slide-in)

### Filter Bar
- Status filter dropdown (All, Draft, Approved, Scheduled, Published, Failed)
- Platform filter dropdown (All, LinkedIn, Twitter, Facebook, WordPress, etc.)
- Search input (debounced 300ms)
- Sort dropdown (Newest First, Oldest First, Scheduled Date, Platform)
- View toggle (Grid / List)
- Post count display

### Post Cards (grouped by status)
- Platform icon + name (color-coded)
- Status badge with date
- Content preview (3-line clamp)
- Hashtags (first 3, "+N more")
- Character count
- Engagement metrics (published posts only)
- Actions: [Edit], [⋮ More] dropdown (Duplicate, Adapt, Delete, View Details)

### Parent Post Cards (special variant)
- Multi-platform icon
- Child count badge
- [Edit] → Parent Post Editor

### Empty State
- Icon + message + [Create Your First Post] button

## Acceptance Criteria
- [ ] Generator tab removed from hub
- [ ] [+ Create New Post] button opens PostGenerator
- [ ] Filter bar with all filter options working
- [ ] Post cards show all required info
- [ ] Click card → opens Post Editor
- [ ] Duplicate/Adapt/Delete actions work
- [ ] Empty state when no posts

## References
- Screen Plan: Screen 1 (Post Hub)
- Phase: 2 (Merge Generation Flows)
- Priority: CRITICAL""",
    priority=2,
    tags=["social-media-pipeline", "phase-2", "frontend"])

p2_3 = create_task(
    "P2.3: Route Cleanup & Navigation Update",
    """## Overview
Remove old routes, rename for consistency, update navigation menu.

## Route Changes
| Old Route | New Route | Action |
|-----------|-----------|--------|
| /:projectId/post-ideas | REMOVED | Merged into PostGenerator |
| /:projectId/multi-platform-creator | REMOVED | Merged into Post Editor |
| /:projectId/social/parent-posts | /:projectId/posts/parents | Renamed |
| /:projectId/social/accounts | /:projectId/providers | Renamed |
| /:projectId/wordpress-connect | /:projectId/providers/wordpress/connect | Scoped |
| /:projectId/posts | KEEP | Main hub |
| /:projectId/posts/create | NEW | Post Generator |
| /:projectId/posts/:postId/edit | KEEP | Post Editor |

## Navigation Menu Updates
- Remove links to deleted pages
- Add "Providers" to navigation
- Ensure breadcrumbs work with new routes

## Acceptance Criteria
- [ ] Old routes removed (with 301 redirect if accessed directly)
- [ ] New routes working
- [ ] Navigation menu updated
- [ ] No broken links in the application

## References
- Architecture: Section 7.4 (Frontend Route Changes)
- Phase: 2 (Merge Generation Flows)
- Priority: Important""",
    priority=2,
    tags=["social-media-pipeline", "phase-2", "frontend"])

p2_4 = create_task(
    "P2.4: Deprecate Old Generator Components",
    """## Overview
Mark old generation components as deprecated (Phase 2) and delete them (Phase 4).

## Components to Deprecate
1. `SocialMediaPostGenerator.tsx` (~250 lines) - replaced by PostGenerator Quick Mode
2. `PostGenerationWizard.tsx` (~710 lines) - replaced by PostGenerator Batch Mode
3. `PostIdeasGenerator.tsx` (~200 lines) - merged into PostGenerator
4. `MultiPlatformPostCreator.tsx` (~640 lines) - merged into Post Editor

## Phase 2 Actions
- Add `@deprecated` JSDoc comment to each component
- Add console.warn if component is rendered
- Keep files in codebase (safety net during transition)
- Remove imports from App.tsx routing

## Phase 4 Actions (separate task)
- Delete all 4 files
- Remove any remaining references

## Acceptance Criteria
- [ ] All 4 components marked @deprecated
- [ ] Not reachable via any route
- [ ] No TypeScript/ESLint errors from deprecation

## References
- Architecture: Section 5.2.3
- Phase: 2 (Merge Generation Flows)
- Priority: Important""",
    priority=2,
    tags=["social-media-pipeline", "phase-2", "frontend", "cleanup"])

print()

# ============================================================================
# PHASE 3: WORDPRESS CONNECTION FLOW (Week 3-4) - Priority: NORMAL
# ============================================================================
print("=" * 70)
print("PHASE 3: WORDPRESS CONNECTION & PUBLISHING UI (Week 3-4)")
print("=" * 70)

p3_1 = create_task(
    "P3.1: WordPress Connection Wizard - 3-Step Flow",
    """## Overview
Rewrite `WordPressConnect.tsx` (currently ~80 lines, minimal) as a proper 3-step wizard.

## Current State
Simple form with URL + credentials. No validation, no feedback, no import.

## Target: 3-Step Wizard

### Step 1: Site URL
- WordPress icon + title
- URL input (placeholder: https://myblog.com)
- [Check Site →] button
- Auto-detect: calls GET {url}/wp-json/
  - Success: show site name + WP version, advance to Step 2
  - Failure: "Could not connect" error with troubleshooting tips
- Info text about REST API requirement

### Step 2: Credentials
- ✅ Site verified message
- Username input
- Application Password input (password field)
- ℹ️ Instructions for generating Application Password (WP 5.6+)
- [← Back] / [Test & Connect →] buttons
- Calls POST /api/providers/wordpress/connect
  - Success: save + advance to Step 3
  - Failure: "Authentication failed" error

### Step 3: Import Options
- ✅ Connected message with site name + username
- Checkbox: Import existing posts (N posts found)
- Checkbox: Import categories (N categories found)
- [← Back] / [Complete Setup →] buttons
- Progress bar during import
- [Skip - I'll import later] link
- On completion: redirect to Provider Management + success toast

## Acceptance Criteria
- [ ] 3-step wizard with back/forward navigation
- [ ] Auto-detect WordPress site (REST API check)
- [ ] Clear error messages for each failure type
- [ ] Application Password instructions shown
- [ ] Optional post/category import works
- [ ] Redirect + toast on success

## References
- Screen Plan: Screen 6 (WordPress Connection Wizard)
- Gap: G7 (WordPress Category Mapping - import part)
- Phase: 3 (WordPress Connection)
- Priority: CRITICAL""",
    priority=3,
    tags=["social-media-pipeline", "phase-3", "frontend", "wordpress"])

p3_2 = create_task(
    "P3.2: Post Editor with Publishing Sidebar",
    """## Overview
Create the main post editing screen with a 2-column layout: content editor (left) + publishing sidebar (right).

## Layout: 2/3 Content + 1/3 Sidebar

### Header Bar
- [← Back to Posts] link (unsaved changes confirmation)
- Title "Edit Post"
- Status badge dropdown (shows valid transitions)
- [Save] / [Preview] buttons

### Content Editor (Left Panel)
- Platform selector dropdown (updates character limits)
- Rich text editor (bold, italic, links, line breaks)
  - Auto-save every 5 seconds
- Character counter (progress bar, color-coded)
- Hashtags section (tag input, type + Enter, ✕ to remove)
- Image area (select/drag-drop, preview, change/remove)
- CTA input (optional)

### Publishing Sidebar (Right Panel)

**Publishing Section:**
- Provider checkboxes (multi-select):
  - WordPress: ☐ + sub-options (Status: Draft/Publish, Category dropdown)
  - LinkedIn: ☐ + connection status
  - Twitter: ☐ + char limit warning
  - Facebook: ☐ + page selector
- Schedule date + time picker
- [🚀 Publish Now] button → confirmation dialog → publish
- [📅 Schedule] button → set status to "scheduled"

**After Publishing:**
- ✅ Published! message
- External URLs (clickable, "View on Site" / "View on WP" buttons)
- Published timestamp

**Quality Score Section:**
- Overall score (0-100, color-coded circle)
- Sub-scores: Engagement, Clarity, Brand, Length
- 2-3 actionable suggestions
- Real-time updates (debounced 2 sec)

**Post Info Section:**
- Created date, created by
- Hook + category (clickable to change)
- [🔄 Regenerate] / [📋 Adapt to...] / [🗑️ Delete] buttons

### Responsive
- Desktop: 2/3 + 1/3 columns
- Tablet: stacked vertically
- Mobile: full-width content + bottom sheet sidebar

## Acceptance Criteria
- [ ] 2-column layout with content editor + sidebar
- [ ] Platform-aware character counting
- [ ] Auto-save every 5 seconds
- [ ] Multi-provider publishing (WordPress + social)
- [ ] Scheduling with date/time picker
- [ ] Post-publish URL feedback
- [ ] Quality score real-time updates
- [ ] Responsive layout

## References
- Screen Plan: Screen 3 (Post Editor)
- Phase: 3 (WordPress Connection)
- Priority: CRITICAL""",
    priority=3,
    tags=["social-media-pipeline", "phase-3", "frontend"])

p3_3 = create_task(
    "P3.3: Provider Management Screen",
    """## Overview
New screen showing all connected and available publishing providers.

## Route: `/:projectId/providers`

### Connected Providers Section
Cards for each connected provider:
- Provider icon + name (color-coded)
- Connection details:
  - WordPress: Site URL, connected user, last tested (✅/❌)
  - Social: Profile name, connection date, token expiry
- Token warning (icon if <7 days, red if expired)
- Buttons: [Test Connection] [Settings] [Refresh Token] [Disconnect]

### Available Providers Section
Grayed-out cards for unconnected providers:
- Provider icon + name
- [Connect] button:
  - WordPress → opens WordPress Connection Wizard
  - Social media → opens OAuth popup
  - On success: card moves to Connected section

## Acceptance Criteria
- [ ] Shows all connected providers with status
- [ ] Shows available (not connected) providers
- [ ] Test connection works (shows ✅/❌)
- [ ] Disconnect with confirmation dialog
- [ ] Connect WordPress → wizard
- [ ] Connect social → OAuth flow
- [ ] Token expiry warnings

## References
- Screen Plan: Screen 5 (Provider Management)
- Phase: 3 (WordPress Connection)
- Priority: Important""",
    priority=3,
    tags=["social-media-pipeline", "phase-3", "frontend"])

p3_4 = create_task(
    "P3.4: Post-Publish URL Feedback & External Links",
    """## Overview
After publishing to WordPress (or any platform), show the external URL with actionable links.

## Implementation

### In Post Editor (after publish)
- ✅ "Published!" success message
- For each published platform:
  - 🔗 External URL (clickable, opens new tab)
  - [View on Site] button (frontend URL)
  - [Edit on WordPress] button (wp-admin edit URL)
  - Published timestamp

### WordPress URL Construction
- Frontend URL: `{siteUrl}/?p={externalPostId}` (or permalink if available)
- Admin URL: `{siteUrl}/wp-admin/post.php?post={externalPostId}&action=edit`
- Store both `ExternalWordPressPostId` and `ExternalWordPressSiteUrl` on publish

### In Post Hub
- Published posts show external link icon
- Click icon → opens external URL

## Acceptance Criteria
- [ ] External URL displayed after successful publish
- [ ] View on Site opens frontend URL in new tab
- [ ] Edit on WordPress opens admin edit page
- [ ] URLs stored in database for later access
- [ ] Works for re-opened posts (not just after publish)

## References
- Gap: G10 (Post-Publish URL Feedback)
- Phase: 3 (WordPress Connection)
- Priority: Important""",
    priority=3,
    tags=["social-media-pipeline", "phase-3", "frontend", "wordpress"])

p3_5 = create_task(
    "P3.5: WordPress Category Mapping",
    """## Overview
Map client-manager blog categories to WordPress categories. Support auto-creating missing categories.

## Implementation

### Backend
- GET /api/providers/wordpress/categories → fetches from WordPress REST API
- POST /api/providers/wordpress/categories/map → saves mapping
- Auto-create: if a category doesn't exist on WordPress, create it via POST /wp-json/wp/v2/categories

### Frontend
- In WordPress Connection Wizard Step 3: side-by-side category mapper
- In Post Editor WordPress options: category dropdown (fetched from WP)
- In Provider Settings: category mapping management

### Data Model
```csharp
public class CategoryMapping {
    public int LocalCategoryId { get; set; }
    public int WordPressCategoryId { get; set; }
    public string WordPressCategoryName { get; set; }
}
```

## Acceptance Criteria
- [ ] Fetch WordPress categories via REST API
- [ ] Map local categories to WP categories
- [ ] Auto-create categories on WordPress if missing
- [ ] Category dropdown in Post Editor works
- [ ] Mapping persists and survives reconnection

## References
- Gap: G7 (WordPress Category Mapping)
- Phase: 3 (WordPress Connection)
- Priority: Important""",
    priority=3,
    tags=["social-media-pipeline", "phase-3", "backend", "wordpress"])

p3_6 = create_task(
    "P3.6: OAuth Token Auto-Refresh for Social Platforms",
    """## Overview
Add background token refresh mechanism for OAuth providers (LinkedIn, Facebook, etc.) to prevent "reconnect required" errors.

## Implementation

### Token Refresh Service
- Check token expiry for all connected OAuth accounts
- Refresh tokens BEFORE they expire (e.g., when <24 hours remaining)
- Log refresh attempts and failures
- Send notification to user when manual reconnect required (refresh token expired)

### Per-Platform Refresh
- **LinkedIn:** Access token expires in 60 days, refresh token in 365 days
- **Facebook:** Short-lived token (1 hour) → exchange for long-lived (60 days)
- **Twitter:** OAuth 2.0 with PKCE, refresh token available
- **Instagram:** Uses Facebook token (same refresh flow)

### Frontend
- Token expiry warning in Provider Management (yellow <7 days, red if expired)
- [Refresh Token] button as fallback for manual re-auth

## Acceptance Criteria
- [ ] Background service checks token expiry regularly
- [ ] Auto-refresh before expiry
- [ ] Clear indication when manual reconnect needed
- [ ] No silent auth failures during publish

## References
- Gap: G9 (Token Auto-Refresh)
- Phase: 3
- Priority: Important""",
    priority=3,
    tags=["social-media-pipeline", "phase-3", "backend"])

print()

# ============================================================================
# PHASE 4: POLISH & PRODUCTION READY (Week 4-5) - Priority: NORMAL
# ============================================================================
print("=" * 70)
print("PHASE 4: POLISH & PRODUCTION READY (Week 4-5)")
print("=" * 70)

p4_1 = create_task(
    "P4.1: Error Handling & Toast Notifications",
    """## Overview
Add comprehensive error handling and user feedback across all social media screens.

## Toast Notifications
- ✅ Success: "Post saved as draft!", "Post published to WordPress!", "WordPress site connected!"
- ❌ Error: "Failed to publish: {error}", "Connection failed: {details}"
- ℹ️ Info: "Post scheduled for Feb 14 at 10:00", "Auto-saved"
- Auto-dismiss after 4-5 seconds

## Error Categories
1. **WordPress REST API not available** → "WordPress REST API not found. Ensure it's enabled."
2. **Invalid credentials** → "Authentication failed. Check username and application password."
3. **Network error** → "Could not reach WordPress site. Check the URL and try again."
4. **Rate limited** → "Too many requests. Please wait a moment and retry."
5. **Token expired (OAuth)** → "Your {platform} connection expired. Reconnect in Provider settings."

## Retry Mechanism
- Failed publishes show [Retry] button
- Exponential backoff: 1s, 5s, 15s
- Max 3 retries before giving up

## Acceptance Criteria
- [ ] Toast notifications for all publish/save/schedule actions
- [ ] Distinguishable error types with actionable messages
- [ ] Retry button for transient failures
- [ ] No unhandled exceptions reaching the user

## References
- Architecture: Section 5.4.1
- Phase: 4 (Polish)
- Priority: Important""",
    priority=3,
    tags=["social-media-pipeline", "phase-4", "frontend"])

p4_2 = create_task(
    "P4.2: Remove Deprecated Code & Legacy Controller",
    """## Overview
Final cleanup: delete deprecated components, legacy controller, and old routes.

## Components to Delete
1. `SocialMediaPostGenerator.tsx` (~250 lines)
2. `PostGenerationWizard.tsx` (~710 lines)
3. `PostIdeasGenerator.tsx` (~200 lines)
4. `MultiPlatformPostCreator.tsx` (~640 lines)

## Backend to Delete
- `PublishedPostsController.cs` (~159 lines) - legacy controller with separate entity
- Related `HazinaStore.Models.PublishedContent` entity references
- `ApprovalStatus` field (if migration complete + verified)

## Routes to Delete
- /:projectId/post-ideas
- /:projectId/multi-platform-creator
- Old /wordpress-connect (replaced by /:projectId/providers/wordpress/connect)

## Navigation Updates
- Remove menu items for deleted pages
- Update any internal links referencing old routes

## Acceptance Criteria
- [ ] All 4 deprecated components deleted
- [ ] PublishedPostsController deleted
- [ ] No dead routes in App.tsx
- [ ] No broken imports
- [ ] Application builds and runs without errors
- [ ] No console warnings from deprecated code

## References
- Gap: G6 (Remove Legacy PublishedPostsController)
- Architecture: Section 5.4.3
- Phase: 4 (Polish)
- Priority: Important""",
    priority=3,
    tags=["social-media-pipeline", "phase-4", "cleanup"])

p4_3 = create_task(
    "P4.3: Preview Modal - Platform-Specific Previews",
    """## Overview
Modal showing how a post will look on each platform before publishing.

## Implementation
Modal with platform selector dropdown showing live preview:

### LinkedIn Preview
- Profile pic + author name + title + "1st"
- Full post text + hashtags
- Featured image (if attached)
- Like/Comment/Repost/Send buttons (decorative)

### Twitter/X Preview
- 280-char indicator with thread preview if >280
- Tweet card format
- Image preview

### WordPress Preview
- Blog post format: title + featured image + content excerpt
- Category tags

### Facebook Preview
- Author name + profile pic
- Text content + featured image
- Reaction buttons

### Instagram Preview
- Square image preview + caption below

## Behavior
- Visual preview only (no publishing from modal)
- Platform selector switches preview instantly
- Character count per platform
- [✕] close button

## Acceptance Criteria
- [ ] 5 platform-specific preview templates
- [ ] Platform selector switches live
- [ ] Accurate character count display
- [ ] Images render correctly
- [ ] Modal closes on ✕ or Escape

## References
- Screen Plan: Screen 7 (Preview Modal)
- Phase: 4 (Polish)
- Priority: Important""",
    priority=3,
    tags=["social-media-pipeline", "phase-4", "frontend"])

p4_4 = create_task(
    "P4.4: Parent Post Manager Screen Enhancement",
    """## Overview
Enhance the Parent Post Manager with expandable cards and platform-specific generation.

## Route: `/:projectId/posts/parents`

## Features
- Header with [← Back to Posts] + title + [Refresh]
- Introduction text explaining parent/child concept

### Parent Post Cards (expandable)
- Header: title + expand/collapse toggle
- Content preview (2-line clamp collapsed, full expanded)
- Platform checkboxes (multi-select): LinkedIn, WordPress, Twitter, Facebook, etc.
- [🤖 Generate Platform Posts] button
  - Loading state per parent
  - On success: child cards appear

### Child Post Cards (under parent)
- Platform icon + name
- Adapted content
- Character count + hashtags
- Actions: [Edit] [Regenerate] [Publish] [Publish to WP]

## Acceptance Criteria
- [ ] Expandable parent cards
- [ ] Platform selection for child generation
- [ ] Child posts generated via AI adaptation
- [ ] Each child links to Post Editor
- [ ] Quick publish per child

## References
- Screen Plan: Screen 4 (Parent Post Manager)
- Phase: 4 (Polish)
- Priority: Important""",
    priority=4,
    tags=["social-media-pipeline", "phase-4", "frontend"])

p4_5 = create_task(
    "P4.5: Reusable UI Components (ImagePicker, Confirmations, Skeletons)",
    """## Overview
Build shared UI components used across multiple social media screens.

## Components

### ImagePicker Modal
- File upload area with drag-and-drop
- Browse button
- Image preview with crop tool (optional)
- [Select] / [Cancel] buttons
- Used by: Post Generator (Batch), Post Editor, Parent Post Manager

### Confirmation Dialogs (generic)
- Title + message
- [Cancel] / [Confirm] buttons
- Warning text variant ("This action cannot be undone")
- Used by: Delete, Publish, Disconnect flows

### Toast Notification System
- Success (green), Error (red), Info (blue)
- Auto-dismiss 4-5 seconds
- Stack multiple toasts

### Skeleton Loaders
- Card grid shimmer (Post Hub loading)
- Quality score shimmer (Post Editor loading)
- Animated placeholder elements

### Progress Indicators
- Step progress (1 of 3, 2 of 3)
- Loading spinners with text
- Progress bars (character count, import progress)

## Acceptance Criteria
- [ ] ImagePicker works with drag-drop + browse
- [ ] Confirmation dialogs reusable across screens
- [ ] Toast system with 3 types
- [ ] Skeleton loaders for main screens
- [ ] Consistent styling across all components

## References
- Screen Plan: Additional Modals & Components section
- Phase: 4 (Polish)
- Priority: Important""",
    priority=4,
    tags=["social-media-pipeline", "phase-4", "frontend", "ui-components"])

print()

# ============================================================================
# NICE-TO-HAVE / FUTURE (Phase 4+)
# ============================================================================
print("=" * 70)
print("NICE-TO-HAVE / FUTURE (Phase 4+)")
print("=" * 70)

create_task(
    "FUTURE: WordPress Post Update Sync",
    """## Overview
Allow editing a local post and pushing updates back to the already-published WordPress post.

## Implementation
- Detect if post has ExternalWordPressPostId (already published)
- Show [Update on WordPress] button instead of [Publish]
- PUT /wp-json/wp/v2/posts/{id} with updated content
- Sync: title, content, excerpt, categories, featured image

## References
- Gap: G11
- Priority: Nice-to-have""",
    priority=4,
    status="backlog",
    tags=["social-media-pipeline", "future", "wordpress"])

create_task(
    "FUTURE: WooCommerce Product-to-Post Generation",
    """## Overview
Auto-generate social posts from WooCommerce products.

## Implementation
- Fetch products from /wp-json/wc/v3/products
- Extract: title, description, price, images
- AI prompt: "Generate a social media post promoting this product: {product}"
- Support batch generation from product catalog

## References
- Gap: G12
- Priority: Nice-to-have""",
    priority=4,
    status="backlog",
    tags=["social-media-pipeline", "future", "wordpress", "ai"])

create_task(
    "FUTURE: A/B Testing for Posts",
    """## Overview
Compare variants of a post (different copy, images, CTAs) and track which performs better.

## Implementation
- Generate 2+ variants of the same post
- Publish at same time to same audience (or split audience)
- Track engagement metrics per variant
- Auto-promote winner after N hours

## References
- Gap: G13
- Priority: Nice-to-have""",
    priority=4,
    status="backlog",
    tags=["social-media-pipeline", "future", "ai"])

create_task(
    "FUTURE: AI Image Generation (DALL-E) Integration",
    """## Overview
Add DALL-E integration to generate images directly in the ImagePicker modal.

## Implementation
- "Generate Image" tab in ImagePicker
- Prompt input + [Generate] button
- Uses OpenAI DALL-E 3 API
- Preview generated images
- Select → use as post image / featured image

## References
- Gap: G14
- Priority: Nice-to-have""",
    priority=4,
    status="backlog",
    tags=["social-media-pipeline", "future", "ai"])

create_task(
    "FUTURE: Content Calendar Drag-and-Drop Rescheduling",
    """## Overview
Allow rescheduling posts by dragging them on the calendar to a different date/time.

## Implementation
- Calendar view shows scheduled posts as blocks
- Drag post block to new date/time
- Auto-update ScheduledDate in database
- Confirmation on drop

## References
- Gap: G15
- Priority: Nice-to-have""",
    priority=4,
    status="backlog",
    tags=["social-media-pipeline", "future", "frontend"])

print()
print("=" * 70)
print("DONE! All tasks created/updated.")
print("=" * 70)
