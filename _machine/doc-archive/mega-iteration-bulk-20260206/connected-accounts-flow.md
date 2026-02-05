# Connected Accounts Flow Diagram

## 🔄 Import Flow (All Providers)

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER ACTION                              │
│  "Connect Account" or "Import Content"                          │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│              DETERMINE PROVIDER & AUTH TYPE                      │
├─────────────────────────────────────────────────────────────────┤
│  Provider:  linkedin | facebook | instagram | wordpress |       │
│            generic-website                                       │
│                                                                  │
│  Auth Type: OAuth | WordPressAppPassword | NoAuth | ApiKey     │
└───────────────────────┬─────────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
   ┌────────┐     ┌────────┐     ┌────────┐
   │ OAuth  │     │WordPress│     │ NoAuth │
   │  Flow  │     │AppPass  │     │ Scrape │
   └────┬───┘     └────┬───┘     └────┬───┘
        │              │              │
        └──────┬───────┴──────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────────────┐
│               CONNECTED ACCOUNT CREATED                          │
├─────────────────────────────────────────────────────────────────┤
│  ConnectedAccount {                                             │
│    ProviderId: "wordpress"                                      │
│    AuthType: WordPressAppPassword                               │
│    Permissions: ImportPosts | ImportPages | ImportImages        │
│    BaseUrl: "https://myblog.com"                                │
│    Credentials: { username, appPassword }  [encrypted]          │
│  }                                                              │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                  IMPORT CONTENT                                  │
│  (User clicks "Import" or "Sync")                               │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│               CHECK PERMISSIONS                                  │
├─────────────────────────────────────────────────────────────────┤
│  ✅ CanImportPosts? Yes → Continue                              │
│  ✅ CanImportPages? Yes → Continue                              │
│  ✅ CanImportImages? Yes → Download images                      │
│  ❌ CanPublishPosts? No → Skip write operations                 │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│              PROVIDER-SPECIFIC IMPORT                            │
└─┬───────────────────┬───────────────────┬────────────────────┬──┘
  │                   │                   │                    │
  ▼                   ▼                   ▼                    ▼
┌─────────┐     ┌──────────┐      ┌──────────┐        ┌──────────┐
│LinkedIn │     │ Facebook │      │WordPress │        │ Generic  │
│Provider │     │ Provider │      │ Provider │        │ Website  │
├─────────┤     ├──────────┤      ├──────────┤        ├──────────┤
│ • OAuth │     │ • OAuth  │      │ • WP API │        │ • Crawl  │
│ • API   │     │ • Graph  │      │ • NoAuth │        │ • Scrape │
│ • Posts │     │   API    │      │   option │        │ • Detect │
│         │     │ • Posts  │      │ • Posts  │        │   blogs  │
└────┬────┘     └─────┬────┘      └─────┬────┘        └─────┬────┘
     │                │                  │                   │
     └────────────────┴──────────────────┴───────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│          CONVERT TO UNIFIED CONTENT                              │
├─────────────────────────────────────────────────────────────────┤
│  LinkedIn Article    → UnifiedContent { contentType: "article" }│
│  Facebook Post       → UnifiedContent { contentType: "post" }   │
│  WordPress Blog Post → UnifiedContent { contentType: "post" }   │
│  WordPress Page      → UnifiedContent { contentType: "page" }   │
│  Website Blog Post   → UnifiedContent { contentType: "post" }   │
│  Website Static Page → UnifiedContent { contentType: "page" }   │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│          SAVE TO UNIFIED CONTENT STORE                           │
│  (SQLite: social.db/unified_content table)                      │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│          OPTIONAL: DOWNLOAD IMAGES                               │
│  If ImportImages permission enabled:                            │
│   - Download image files                                        │
│   - Store in content_media table                                │
│   - Link to unified_content.id                                  │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│          UPDATE ACCOUNT METADATA                                 │
│   - LastImportAt = now                                          │
│   - ImportedItemCount += new items                              │
│   - Metadata["lastSync_post"] = timestamp                       │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│          RETURN RESULTS TO USER                                  │
│   {                                                             │
│     success: true,                                              │
│     postsImported: 25,                                          │
│     pagesImported: 8,                                           │
│     imagesDownloaded: 47,                                       │
│     totalImported: 33                                           │
│   }                                                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Auth Type Comparison

```
┌──────────────────────┬──────────────┬──────────────┬─────────────┐
│     Auth Type        │ Credentials  │  Use Case    │  Providers  │
├──────────────────────┼──────────────┼──────────────┼─────────────┤
│ OAuth                │ Access Token │ Social media │ LinkedIn,   │
│                      │              │ platforms    │ Facebook,   │
│                      │              │              │ Instagram   │
├──────────────────────┼──────────────┼──────────────┼─────────────┤
│ WordPressAppPassword │ Username +   │ WordPress    │ WordPress   │
│                      │ App Password │ sites with   │             │
│                      │              │ full access  │             │
├──────────────────────┼──────────────┼──────────────┼─────────────┤
│ NoAuth               │ None         │ Public       │ WordPress,  │
│                      │              │ content only │ Generic Web │
├──────────────────────┼──────────────┼──────────────┼─────────────┤
│ ApiKey (future)      │ API Key      │ Platforms    │ Twitter,    │
│                      │              │ with API     │ YouTube     │
└──────────────────────┴──────────────┴──────────────┴─────────────┘
```

---

## 🎛️ Permission Matrix

```
┌─────────────────┬────────────┬──────────────┬─────────────┬──────────────┐
│  Permission     │  Social    │  WordPress   │  WordPress  │   Generic    │
│                 │  OAuth     │  (NoAuth)    │  (AppPass)  │   Website    │
├─────────────────┼────────────┼──────────────┼─────────────┼──────────────┤
│ ImportPosts     │     ✅      │      ✅       │      ✅      │      ✅       │
│ PublishPosts    │     ✅      │      ❌       │      ✅      │      ❌       │
│ ImportPages     │     ❌      │      ✅       │      ✅      │      ✅       │
│ ImportImages    │  Optional  │   Optional   │   Optional  │   Optional   │
└─────────────────┴────────────┴──────────────┴─────────────┴──────────────┘
```

---

## 📊 Data Flow: Website → UnifiedContent

### Example: WordPress Blog Post

```
┌─────────────────────────────────────────────────────────────────┐
│          WORDPRESS REST API RESPONSE                             │
├─────────────────────────────────────────────────────────────────┤
│  {                                                              │
│    "id": 123,                                                   │
│    "title": { "rendered": "My Blog Post" },                    │
│    "content": { "rendered": "<p>Content...</p>" },             │
│    "excerpt": { "rendered": "Summary..." },                    │
│    "date": "2024-01-15T10:00:00",                              │
│    "featured_media": 456,                                       │
│    "categories": [1, 5],                                        │
│    "tags": [3, 7]                                               │
│  }                                                              │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│          CONVERT TO UNIFIED CONTENT                              │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│          UNIFIED CONTENT OBJECT                                  │
├─────────────────────────────────────────────────────────────────┤
│  {                                                              │
│    id: "uc-abc123",                                             │
│    project_id: "proj-456",                                      │
│    account_id: "acc-789",                                       │
│    source_type: "wordpress",                                    │
│    source_id: "123",                                            │
│    source_url: "https://myblog.com/my-blog-post",              │
│    content_type: "post",                                        │
│    title: "My Blog Post",                                       │
│    content: "Content...",                                       │
│    content_html: "<p>Content...</p>",                           │
│    content_plaintext: "Content...",                             │
│    summary: "Summary...",                                       │
│    published_at: "2024-01-15T10:00:00Z",                       │
│    imported_at: "2024-01-20T15:30:00Z",                        │
│    categories: ["Technology", "Tutorial"],                      │
│    tags: ["wordpress", "api"],                                  │
│    featured_image_url: "https://myblog.com/image.jpg",         │
│    media: [                                                     │
│      { type: "image", url: "...", ... }                         │
│    ]                                                            │
│  }                                                              │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│          SQLITE DATABASE (social.db)                             │
│  unified_content table                                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Import Modes Comparison

### WordPress with OAuth (Current - PR #95, #283)
```
User → OAuth Flow → AccessToken → WordPress REST API → Posts → UnifiedContent
```

### WordPress with NoAuth (NEW - This Architecture)
```
User → Provide URL → Public WordPress REST API → Posts → UnifiedContent
```

### WordPress with App Password (NEW - This Architecture)
```
User → Provide URL + Username + AppPassword
     → Authenticated WordPress REST API
     → Posts + Pages + Private Content
     → UnifiedContent
```

### Generic Website (NEW - This Architecture)
```
User → Provide URL → FireCrawl Scraper
     → Detect Blog Posts + Static Pages
     → UnifiedContent
```

---

## 🎯 User Journey Examples

### Journey 1: Import Public Blog Posts (NoAuth)
1. User clicks "Connect Account" → "WordPress"
2. Selects "No Authentication"
3. Enters website URL: `https://competitor.com`
4. Checks "Import Posts" ✅ and "Import Images" ✅
5. Clicks "Connect"
6. System creates `ConnectedAccount` with `AuthType.NoAuth`
7. User clicks "Import Content"
8. System fetches public posts from WordPress REST API
9. Posts stored in `unified_content` table
10. Success! 50 posts imported

### Journey 2: Full WordPress Integration (AppPassword)
1. User generates App Password in WordPress admin
2. Clicks "Connect Account" → "WordPress"
3. Selects "WordPress Application Password"
4. Enters:
   - URL: `https://myblog.com`
   - Username: `admin`
   - App Password: `xxxx xxxx xxxx xxxx`
5. Checks all permissions:
   - Import Posts ✅
   - Publish Posts ✅ (enables posting back to WordPress)
   - Import Pages ✅
   - Import Images ✅
6. Clicks "Connect"
7. System creates `ConnectedAccount` with credentials (encrypted)
8. User can now:
   - Import all posts and pages
   - Publish new posts to WordPress from client-manager
   - Schedule posts for WordPress
   - Use AI to draft WordPress content

### Journey 3: Competitor Analysis (Generic Website)
1. User wants to analyze competitor's blog
2. Clicks "Connect Account" → "Generic Website"
3. Enters URL: `https://competitor.com`
4. Checks "Import Posts" ✅ and "Import Pages" ✅
5. System crawls website using FireCrawl
6. Detects blog posts at `/blog/*` URLs
7. Detects static pages (About, Services, etc.)
8. All content stored in UnifiedContent
9. User can now:
   - Analyze competitor's content strategy
   - Compare posting frequency
   - Identify content gaps
   - Get AI-generated competitive insights

---

## 🎨 UI Mockup: Connect Account Dialog

```
┌───────────────────────────────────────────────────────┐
│  Connect Account                                  [X] │
├───────────────────────────────────────────────────────┤
│                                                       │
│  Choose Platform:                                     │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐       │
│  │LinkedIn│ │Facebook│ │WordPress│ │Website │       │
│  │   ✅   │ │        │ │    ●    │ │        │       │
│  └────────┘ └────────┘ └────────┘ └────────┘       │
│                                                       │
│  Authentication:                                      │
│  ○ No Authentication                                  │
│     Import public content only                        │
│                                                       │
│  ● WordPress Application Password                     │
│     Full access to private content and publishing     │
│                                                       │
│  ┌─────────────────────────────────────────────────┐ │
│  │ WordPress URL                                   │ │
│  │ https://myblog.com                              │ │
│  └─────────────────────────────────────────────────┘ │
│                                                       │
│  ┌─────────────────────────────────────────────────┐ │
│  │ Username                                        │ │
│  │ admin                                           │ │
│  └─────────────────────────────────────────────────┘ │
│                                                       │
│  ┌─────────────────────────────────────────────────┐ │
│  │ Application Password                            │ │
│  │ ••••••••••••••••••••                            │ │
│  └─────────────────────────────────────────────────┘ │
│                                                       │
│  Permissions:                                         │
│  ☑ Import Posts - Download blog posts and articles   │
│  ☑ Publish Posts - Create new posts on WordPress     │
│  ☑ Import Pages - Download static pages              │
│  ☑ Import Images - Download and store images         │
│                                                       │
│  ┌─────────────────────────────────────────────────┐ │
│  │           Connect WordPress Account             │ │
│  └─────────────────────────────────────────────────┘ │
│                                                       │
└───────────────────────────────────────────────────────┘
```

---

**See:** `enhanced-connected-accounts-architecture.md` for full technical specification.
