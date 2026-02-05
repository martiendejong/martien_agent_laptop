# Enhanced Connected Accounts Architecture

**Task:** Unify website import and social media import with flexible auth levels and permissions

**ClickUp:** https://app.clickup.com/t/869buxcq7 (related to WordPress AI Inspiration)

## 📋 Requirements

### 1. Authentication Types
Accounts can connect with different auth methods:
- **NoAuth** - Public scraping (no credentials needed)
- **OAuth** - Standard OAuth flow (LinkedIn, Facebook, Instagram)
- **WordPressAppPassword** - WordPress Application Password
- **ApiKey** - Generic API key authentication

### 2. Permission Levels
Each connected account has granular permissions:
- **ImportPosts** - Can read and import posts/articles
- **PublishPosts** - Can publish new content to the platform
- **ImportPages** - Can import website pages (WordPress pages, static pages)
- **ImportImages** - Whether to download images during import

### 3. Provider Types
- **Social Networks**: linkedin, facebook, instagram, twitter
- **Websites**: wordpress, generic-website

### 4. Unified Content Model
All imported content (blog posts, social posts, pages) goes to UnifiedContent:
- WordPress blog post → UnifiedContent (contentType: "post")
- WordPress page → UnifiedContent (contentType: "page")
- Facebook post → UnifiedContent (contentType: "post")
- LinkedIn article → UnifiedContent (contentType: "article")

---

## 🏗️ Architecture Changes

### Phase 1: Enhance ConnectedAccount Model (Hazina)

**File:** `Hazina.Tools.Services.Social/Abstractions/ISocialAccountStore.cs`

```csharp
/// <summary>
/// Authentication method used for this account.
/// </summary>
public enum AuthType
{
    /// <summary>No authentication - public scraping only</summary>
    NoAuth,

    /// <summary>OAuth 2.0 flow (LinkedIn, Facebook, etc.)</summary>
    OAuth,

    /// <summary>WordPress Application Password</summary>
    WordPressAppPassword,

    /// <summary>Generic API key</summary>
    ApiKey
}

/// <summary>
/// Permissions flags for what the account can do.
/// </summary>
[Flags]
public enum AccountPermissions
{
    None = 0,

    /// <summary>Can import posts/articles</summary>
    ImportPosts = 1,

    /// <summary>Can publish new posts to platform</summary>
    PublishPosts = 2,

    /// <summary>Can import pages (WordPress pages, static website pages)</summary>
    ImportPages = 4,

    /// <summary>Download and store images during import</summary>
    ImportImages = 8,

    /// <summary>Full read access (posts + pages + images)</summary>
    FullRead = ImportPosts | ImportPages | ImportImages,

    /// <summary>Full control (read + write)</summary>
    FullControl = FullRead | PublishPosts
}

/// <summary>
/// Enhanced ConnectedAccount with auth types and permissions.
/// </summary>
public class ConnectedAccount
{
    // ... existing properties ...

    /// <summary>
    /// Authentication type for this connection.
    /// </summary>
    public AuthType AuthType { get; set; } = AuthType.OAuth;

    /// <summary>
    /// What operations are allowed for this account.
    /// Default: ImportPosts | ImportImages (read-only with images)
    /// </summary>
    public AccountPermissions Permissions { get; set; } =
        AccountPermissions.ImportPosts | AccountPermissions.ImportImages;

    /// <summary>
    /// Provider category (social-network, website, etc.)
    /// </summary>
    public string ProviderCategory { get; set; } = "social-network";

    /// <summary>
    /// Base URL for website providers (e.g., "https://example.com")
    /// </summary>
    public string? BaseUrl { get; set; }

    /// <summary>
    /// Credentials storage (encrypted).
    /// For WordPress: { "username": "admin", "appPassword": "xxxx xxxx xxxx" }
    /// For ApiKey: { "apiKey": "secret" }
    /// For NoAuth: empty
    /// </summary>
    public Dictionary<string, string> Credentials { get; set; } = new();

    // Helper methods
    public bool CanImportPosts => Permissions.HasFlag(AccountPermissions.ImportPosts);
    public bool CanPublishPosts => Permissions.HasFlag(AccountPermissions.PublishPosts);
    public bool CanImportPages => Permissions.HasFlag(AccountPermissions.ImportPages);
    public bool CanImportImages => Permissions.HasFlag(AccountPermissions.ImportImages);

    public bool IsWebsite => ProviderCategory == "website";
    public bool IsSocialNetwork => ProviderCategory == "social-network";
}
```

---

### Phase 2: Generic Website Provider (Hazina)

**File:** `Hazina.Tools.Services.Social/Providers/GenericWebsiteProvider.cs` (NEW)

```csharp
using Hazina.Tools.Services.Social.Abstractions;
using Hazina.Tools.Services.Web.Abstractions; // IFireCrawlService
using Microsoft.Extensions.Logging;

namespace Hazina.Tools.Services.Social.Providers;

/// <summary>
/// Generic website provider - works with any website (with or without auth).
/// Scrapes content from public pages or authenticated APIs.
/// </summary>
public class GenericWebsiteProvider : ISocialProvider
{
    public string ProviderId => "generic-website";
    public string ProviderName => "Generic Website";
    public bool SupportsOAuth => false;
    public bool RequiresAuth => false; // Optional auth

    private readonly IFireCrawlService _fireCrawl;
    private readonly ILogger<GenericWebsiteProvider> _logger;

    public GenericWebsiteProvider(
        IFireCrawlService fireCrawl,
        ILogger<GenericWebsiteProvider> logger)
    {
        _fireCrawl = fireCrawl;
        _logger = logger;
    }

    /// <summary>
    /// Import content from website (crawls sitemap, discovers blog posts and pages).
    /// </summary>
    public async Task<SocialImportResult> ImportContentAsync(
        string accessToken, // Can be empty for NoAuth
        SocialImportOptions options)
    {
        // 1. Determine base URL from metadata
        var baseUrl = options.Metadata?.GetValueOrDefault("baseUrl") ?? "";
        if (string.IsNullOrEmpty(baseUrl))
            throw new InvalidOperationException("baseUrl is required for website import");

        // 2. Crawl website (FireCrawl map endpoint)
        var crawlResult = await _fireCrawl.CrawlAsync(new FireCrawlCrawlRequest
        {
            Url = baseUrl,
            MaxDepth = 3,
            IncludeHtml = true,
            OnlyMainContent = true
        });

        if (!crawlResult.Success)
            throw new Exception($"Crawl failed: {crawlResult.Error}");

        // 3. Filter for blog posts and pages
        var blogPosts = crawlResult.Pages
            .Where(p => IsBlogPost(p.Url))
            .ToList();

        var pages = crawlResult.Pages
            .Where(p => IsStaticPage(p.Url) && !IsBlogPost(p.Url))
            .ToList();

        // 4. Convert to UnifiedContent
        var unifiedContent = new List<UnifiedContent>();

        // Blog posts
        if (options.ContentTypes.Contains("posts"))
        {
            foreach (var post in blogPosts)
            {
                unifiedContent.Add(ConvertToUnifiedContent(
                    post,
                    contentType: "post",
                    baseUrl,
                    options));
            }
        }

        // Pages
        if (options.ContentTypes.Contains("pages"))
        {
            foreach (var page in pages)
            {
                unifiedContent.Add(ConvertToUnifiedContent(
                    page,
                    contentType: "page",
                    baseUrl,
                    options));
            }
        }

        return new SocialImportResult
        {
            Success = true,
            UnifiedContent = unifiedContent,
            TotalImported = unifiedContent.Count
        };
    }

    private bool IsBlogPost(string url)
    {
        var lowerUrl = url.ToLowerInvariant();
        return lowerUrl.Contains("/blog/") ||
               lowerUrl.Contains("/post/") ||
               lowerUrl.Contains("/article/") ||
               lowerUrl.Contains("/news/") ||
               Regex.IsMatch(url, @"/\d{4}/\d{2}/"); // Date pattern
    }

    private bool IsStaticPage(string url)
    {
        var lowerUrl = url.ToLowerInvariant();
        return lowerUrl.EndsWith("/about") ||
               lowerUrl.EndsWith("/contact") ||
               lowerUrl.EndsWith("/services") ||
               lowerUrl.EndsWith("/privacy") ||
               lowerUrl.EndsWith("/terms") ||
               !lowerUrl.Contains("/blog/");
    }

    private UnifiedContent ConvertToUnifiedContent(
        FireCrawlPage page,
        string contentType,
        string baseUrl,
        SocialImportOptions options)
    {
        // Extract metadata
        var title = page.Metadata?.GetValueOrDefault("title") ?? "Untitled";
        var description = page.Metadata?.GetValueOrDefault("description") ?? "";
        var publishedDate = ExtractPublishDate(page);

        // Extract images if enabled
        var images = new List<ContentMedia>();
        if (options.ImportImages)
        {
            images = ExtractImages(page.Html, baseUrl);
        }

        return new UnifiedContent
        {
            Id = Guid.NewGuid().ToString(),
            SourceType = "generic-website",
            SourceId = GenerateSourceId(page.Url),
            SourceUrl = page.Url,
            ContentType = contentType,
            Title = title,
            Content = page.Markdown ?? page.Html ?? "",
            ContentHtml = page.Html,
            ContentPlaintext = page.Markdown, // Markdown as plaintext
            Summary = description,
            PublishedAt = publishedDate,
            ImportedAt = DateTime.UtcNow,
            Media = images
        };
    }

    private DateTime ExtractPublishDate(FireCrawlPage page)
    {
        // Try meta tags first
        if (page.Metadata?.TryGetValue("article:published_time", out var published) == true &&
            DateTime.TryParse(published, out var date))
        {
            return date;
        }

        // Try URL date pattern (/2024/01/15/)
        var match = Regex.Match(page.Url, @"/(\d{4})/(\d{2})/(\d{2})/");
        if (match.Success)
        {
            return new DateTime(
                int.Parse(match.Groups[1].Value),
                int.Parse(match.Groups[2].Value),
                int.Parse(match.Groups[3].Value));
        }

        // Default to now
        return DateTime.UtcNow;
    }

    private string GenerateSourceId(string url)
    {
        // Use URL hash as source ID
        using var sha256 = System.Security.Cryptography.SHA256.Create();
        var hash = sha256.ComputeHash(Encoding.UTF8.GetBytes(url));
        return Convert.ToBase64String(hash).Substring(0, 16);
    }

    // ... more helper methods ...
}
```

---

### Phase 3: Enhanced WordPress Provider (Hazina)

**File:** `Hazina.Tools.Services.Social/Providers/WordPressProvider.cs` (ENHANCE)

Add support for NoAuth mode (public WordPress REST API):

```csharp
public async Task<SocialImportResult> ImportContentAsync(
    string accessToken,
    SocialImportOptions options)
{
    var baseUrl = options.Metadata?.GetValueOrDefault("baseUrl") ?? "";
    var authType = DetermineAuthType(accessToken);

    if (authType == AuthType.NoAuth)
    {
        // Use public WordPress REST API
        return await ImportPublicContentAsync(baseUrl, options);
    }
    else if (authType == AuthType.WordPressAppPassword)
    {
        // Use authenticated WordPress REST API
        return await ImportAuthenticatedContentAsync(accessToken, baseUrl, options);
    }

    throw new NotSupportedException($"Auth type {authType} not supported");
}

private async Task<SocialImportResult> ImportPublicContentAsync(
    string baseUrl,
    SocialImportOptions options)
{
    var httpClient = _httpClientFactory.CreateClient();
    var content = new List<UnifiedContent>();

    // Fetch posts (public endpoint)
    if (options.ContentTypes.Contains("posts"))
    {
        var postsUrl = $"{baseUrl}/wp-json/wp/v2/posts?per_page=100";
        var response = await httpClient.GetStringAsync(postsUrl);
        var posts = JsonSerializer.Deserialize<List<WordPressPost>>(response);

        foreach (var post in posts)
        {
            content.Add(await ConvertPostToUnifiedContent(
                post,
                baseUrl,
                includeImages: options.ImportImages));
        }
    }

    // Fetch pages (public endpoint)
    if (options.ContentTypes.Contains("pages"))
    {
        var pagesUrl = $"{baseUrl}/wp-json/wp/v2/pages?per_page=100";
        var response = await httpClient.GetStringAsync(pagesUrl);
        var pages = JsonSerializer.Deserialize<List<WordPressPage>>(response);

        foreach (var page in pages)
        {
            content.Add(await ConvertPageToUnifiedContent(
                page,
                baseUrl,
                includeImages: options.ImportImages));
        }
    }

    return new SocialImportResult
    {
        Success = true,
        UnifiedContent = content,
        TotalImported = content.Count
    };
}
```

---

### Phase 4: Enhanced Frontend UI (client-manager)

**File:** `ClientManagerFrontend/src/components/containers/ConnectAccountDialog.tsx` (ENHANCE)

Add UI for choosing auth type and permissions:

```tsx
interface ConnectAccountOptions {
  authType: 'oauth' | 'wordpress-app-password' | 'no-auth';
  permissions: {
    importPosts: boolean;
    publishPosts: boolean;
    importPages: boolean;
    importImages: boolean;
  };
  credentials?: {
    baseUrl?: string;
    username?: string;
    appPassword?: string;
  };
}

export default function ConnectAccountDialog({ provider }: Props) {
  const [authType, setAuthType] = useState<'oauth' | 'wordpress-app-password' | 'no-auth'>('oauth');
  const [permissions, setPermissions] = useState({
    importPosts: true,
    publishPosts: false,
    importPages: provider === 'wordpress' || provider === 'generic-website',
    importImages: true
  });

  return (
    <Dialog>
      {/* Provider selection */}
      <ProviderSelector onChange={setProvider} />

      {/* Auth type (for websites only) */}
      {(provider === 'wordpress' || provider === 'generic-website') && (
        <div className="space-y-2">
          <label className="font-semibold">Authentication</label>
          <RadioGroup value={authType} onChange={setAuthType}>
            <Radio value="no-auth">
              <div>
                <div className="font-medium">No Authentication</div>
                <div className="text-sm text-gray-500">
                  Import public content only (blog posts, pages)
                </div>
              </div>
            </Radio>

            <Radio value="wordpress-app-password">
              <div>
                <div className="font-medium">WordPress Application Password</div>
                <div className="text-sm text-gray-500">
                  Full access to private content and publishing
                </div>
              </div>
            </Radio>
          </RadioGroup>
        </div>
      )}

      {/* WordPress App Password fields */}
      {authType === 'wordpress-app-password' && (
        <div className="space-y-3">
          <Input
            label="WordPress URL"
            placeholder="https://example.com"
            value={credentials.baseUrl}
            onChange={(e) => setCredentials({ ...credentials, baseUrl: e.target.value })}
          />
          <Input
            label="Username"
            placeholder="admin"
            value={credentials.username}
            onChange={(e) => setCredentials({ ...credentials, username: e.target.value })}
          />
          <Input
            label="Application Password"
            type="password"
            placeholder="xxxx xxxx xxxx xxxx"
            value={credentials.appPassword}
            onChange={(e) => setCredentials({ ...credentials, appPassword: e.target.value })}
          />
        </div>
      )}

      {/* Permissions */}
      <div className="space-y-2">
        <label className="font-semibold">Permissions</label>

        <Checkbox
          checked={permissions.importPosts}
          onChange={(checked) => setPermissions({ ...permissions, importPosts: checked })}
        >
          <div>
            <div className="font-medium">Import Posts</div>
            <div className="text-sm text-gray-500">
              Download blog posts and articles
            </div>
          </div>
        </Checkbox>

        {authType !== 'no-auth' && (
          <Checkbox
            checked={permissions.publishPosts}
            onChange={(checked) => setPermissions({ ...permissions, publishPosts: checked })}
          >
            <div>
              <div className="font-medium">Publish Posts</div>
              <div className="text-sm text-gray-500">
                Create new posts on the platform
              </div>
            </div>
          </Checkbox>
        )}

        {(provider === 'wordpress' || provider === 'generic-website') && (
          <Checkbox
            checked={permissions.importPages}
            onChange={(checked) => setPermissions({ ...permissions, importPages: checked })}
          >
            <div>
              <div className="font-medium">Import Pages</div>
              <div className="text-sm text-gray-500">
                Download static pages (About, Contact, etc.)
              </div>
            </div>
          </Checkbox>
        )}

        <Checkbox
          checked={permissions.importImages}
          onChange={(checked) => setPermissions({ ...permissions, importImages: checked })}
        >
          <div>
            <div className="font-medium">Import Images</div>
            <div className="text-sm text-gray-500">
              Download and store images from posts/pages
            </div>
          </div>
        </Checkbox>
      </div>

      {/* Connect button */}
      <Button onClick={handleConnect}>
        {authType === 'oauth' ? 'Connect with OAuth' : 'Connect'}
      </Button>
    </Dialog>
  );
}
```

---

### Phase 5: Enhanced API Endpoints (client-manager)

**File:** `ClientManagerAPI/Controllers/SocialImportController.cs` (ENHANCE)

Add endpoint for connecting websites:

```csharp
/// <summary>
/// Connect a website (with or without authentication).
/// </summary>
[HttpPost("websites/connect")]
public async Task<IActionResult> ConnectWebsite(
    [FromBody] ConnectWebsiteRequest request)
{
    if (NotFound(request.ProjectId) is IActionResult notFound) return notFound;

    try
    {
        // Create connected account
        var account = new ConnectedAccount
        {
            Id = Guid.NewGuid().ToString(),
            ProjectId = request.ProjectId,
            ProviderId = request.ProviderType, // "wordpress" or "generic-website"
            ProviderCategory = "website",
            AuthType = request.AuthType,
            DisplayName = request.DisplayName ?? new Uri(request.BaseUrl).Host,
            BaseUrl = request.BaseUrl,
            ConnectedAt = DateTime.UtcNow,
            Status = AccountStatus.Active,
            Permissions = request.Permissions
        };

        // Store credentials (encrypted)
        if (request.AuthType == AuthType.WordPressAppPassword)
        {
            account.Credentials = new Dictionary<string, string>
            {
                ["username"] = request.Username,
                ["appPassword"] = request.AppPassword // TODO: Encrypt
            };

            // Build access token for WordPress REST API
            var credentials = $"{request.Username}:{request.AppPassword}";
            var encoded = Convert.ToBase64String(Encoding.UTF8.GetBytes(credentials));
            account.AccessToken = $"Basic {encoded}";
        }
        else if (request.AuthType == AuthType.NoAuth)
        {
            account.AccessToken = ""; // No token needed
        }

        // Save account
        await _accountStore.SaveAccountAsync(request.ProjectId, account);

        _logger.LogInformation(
            "Connected website {BaseUrl} with auth type {AuthType} for project {ProjectId}",
            request.BaseUrl, request.AuthType, request.ProjectId);

        return Ok(new
        {
            accountId = account.Id,
            providerId = account.ProviderId,
            authType = account.AuthType.ToString(),
            permissions = new
            {
                canImportPosts = account.CanImportPosts,
                canPublishPosts = account.CanPublishPosts,
                canImportPages = account.CanImportPages,
                canImportImages = account.CanImportImages
            }
        });
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error connecting website {BaseUrl}", request.BaseUrl);
        return StatusCode(500, new { message = "Failed to connect website", error = ex.Message });
    }
}

public class ConnectWebsiteRequest
{
    public string ProjectId { get; set; }
    public string ProviderType { get; set; } // "wordpress" or "generic-website"
    public AuthType AuthType { get; set; }
    public string BaseUrl { get; set; }
    public string? DisplayName { get; set; }
    public string? Username { get; set; }
    public string? AppPassword { get; set; }
    public AccountPermissions Permissions { get; set; }
}
```

---

## 🎯 Implementation Plan

### ✅ Phase 1: Core Model Changes (Hazina) - 2-3 hours
- [ ] Add `AuthType`, `AccountPermissions` enums
- [ ] Enhance `ConnectedAccount` with new properties
- [ ] Update SqliteAccountStore to persist new fields
- [ ] Add migration for existing accounts (default OAuth + ImportPosts)

### ✅ Phase 2: Generic Website Provider (Hazina) - 4-5 hours
- [ ] Create `GenericWebsiteProvider.cs`
- [ ] Implement website crawling (FireCrawl integration)
- [ ] Add blog post detection logic
- [ ] Add static page detection logic
- [ ] Convert to UnifiedContent
- [ ] Support ImportImages flag

### ✅ Phase 3: Enhance WordPress Provider (Hazina) - 2-3 hours
- [ ] Add NoAuth mode (public REST API)
- [ ] Add WordPressAppPassword mode
- [ ] Support ImportPages permission
- [ ] Support ImportImages permission

### ✅ Phase 4: Backend API (client-manager) - 3-4 hours
- [ ] Add `/api/social/websites/connect` endpoint
- [ ] Add credential encryption for AppPassword
- [ ] Update existing social endpoints to check permissions
- [ ] Add permission validation middleware

### ✅ Phase 5: Frontend UI (client-manager) - 5-6 hours
- [ ] Create `ConnectWebsiteDialog.tsx`
- [ ] Add auth type selector (NoAuth, AppPassword)
- [ ] Add permissions checkboxes
- [ ] Update `WordPressSettings.tsx` to show auth status
- [ ] Add "Import Images" toggle to all import dialogs
- [ ] Update account list to show auth type and permissions

### ✅ Phase 6: Testing & Documentation - 2-3 hours
- [ ] Test NoAuth website import
- [ ] Test WordPress AppPassword import
- [ ] Test permission enforcement
- [ ] Update API documentation
- [ ] Create user guide

**Total Estimate:** ~20-25 hours

---

## 🔄 Migration Strategy

### Existing Accounts
All existing OAuth accounts will be migrated with:
- `AuthType` = `OAuth`
- `Permissions` = `ImportPosts | ImportImages`
- `ProviderCategory` = `"social-network"`

### Backward Compatibility
- All existing social import endpoints continue to work
- Permissions default to safe values (read-only with images)
- OAuth flow unchanged

---

## 📊 Examples

### Example 1: Connect WordPress with NoAuth
```json
POST /api/social/websites/connect
{
  "projectId": "proj-123",
  "providerType": "wordpress",
  "authType": "NoAuth",
  "baseUrl": "https://myblog.com",
  "displayName": "My Blog",
  "permissions": 5  // ImportPosts | ImportPages
}
```

### Example 2: Connect WordPress with App Password
```json
POST /api/social/websites/connect
{
  "projectId": "proj-123",
  "providerType": "wordpress",
  "authType": "WordPressAppPassword",
  "baseUrl": "https://myblog.com",
  "username": "admin",
  "appPassword": "xxxx xxxx xxxx xxxx",
  "permissions": 15  // ImportPosts | PublishPosts | ImportPages | ImportImages
}
```

### Example 3: Connect Generic Website (NoAuth)
```json
POST /api/social/websites/connect
{
  "projectId": "proj-123",
  "providerType": "generic-website",
  "authType": "NoAuth",
  "baseUrl": "https://competitor.com",
  "permissions": 13  // ImportPosts | ImportPages | ImportImages
}
```

---

## 🎉 Benefits

1. **Unified Architecture** - All content (social + websites) flows to UnifiedContent
2. **Flexible Auth** - Support public scraping, OAuth, API keys
3. **Granular Permissions** - Users control exactly what gets imported/published
4. **WordPress Parity** - WordPress treated same as LinkedIn/Facebook
5. **Future-Proof** - Easy to add new providers (Twitter, YouTube, etc.)
6. **Security** - Credentials encrypted, permissions enforced

---

## 🔐 Security Considerations

1. **Encrypt Credentials** - Use ASP.NET Data Protection for AppPassword storage
2. **Permission Checks** - Validate permissions before every import/publish operation
3. **Rate Limiting** - Prevent abuse of public scraping
4. **Token Expiry** - Handle WordPress App Password expiration
5. **Audit Log** - Track all permission changes and sensitive operations

---

**Next Steps:**
1. Review and approve this design
2. Create feature branch in Hazina
3. Create feature branch in client-manager
4. Implement Phase 1 (model changes)
5. Continue through phases sequentially

**Dependencies:**
- Hazina changes must be merged before client-manager changes
- Frontend depends on backend API endpoints
- FireCrawl service must be configured and working

**Questions:**
1. Should we support API key auth for other platforms (Twitter, YouTube)?
2. Should ImportImages download images to local storage or just store URLs?
3. Should we add a "dry run" mode to preview what would be imported?
4. Should we support scheduled imports (daily/weekly auto-sync)?
