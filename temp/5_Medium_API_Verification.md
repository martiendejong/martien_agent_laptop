# Medium API Verification Guide

**Date:** February 8, 2026
**Platform:** Medium Publishing API
**Portal:** https://medium.com/ (no dedicated developer portal)

---

## 🔴 CRITICAL WARNING

**Medium API is officially NO LONGER SUPPORTED as of March 2023.**

- ❌ GitHub repository archived (March 2, 2023)
- ❌ No active development or maintenance
- ❌ No guarantee of uptime or functionality
- ❌ Could disappear completely at any moment
- ⚠️ **NOT RECOMMENDED for production use**

---

## 📋 What's Still Available?

### Publishing API (Limited)

**Status:** Still works but "unsupported"

**Functionality:**
- ✅ Publish articles
- ✅ Fetch basic user info
- ❌ No reading/fetching articles
- ❌ No analytics/statistics
- ❌ No comment management
- ❌ No publications management

**API Endpoint:**
- Base URL: `https://api.medium.com/v1/`
- Rate limits: Unknown/not documented
- SLA: None

---

## 🔑 Getting Integration Token

If you still want to use the limited API:

### Process

1. **Log in to Medium**
   - URL: https://medium.com/
   - Log in with your account

2. **Go to Settings**
   - Click your profile (top right)
   - Select "Settings"

3. **Navigate to Security and Apps**
   - In left menu: "Security and apps"
   - Scroll down to "Integration tokens"

4. **Generate Token**
   - Click "Get integration token" or "New integration token"
   - Give token a description (e.g., "MyApp - Production")
   - Click "Get integration token"

5. **Store Token Securely**
   - ⚠️ Token shown only once
   - Copy and save in password manager
   - Token has **WRITE-ONLY** access
   - No expiration date (valid until deleted)

---

## 📚 Available API Endpoints

### 1. User Info

**Endpoint:** `GET /v1/me`

**Requires:** Bearer token in Authorization header

**Response:**
```json
{
  "data": {
    "id": "user_id",
    "username": "username",
    "name": "Display Name",
    "url": "https://medium.com/@username",
    "imageUrl": "profile_image_url"
  }
}
```

---

### 2. User Publications

**Endpoint:** `GET /v1/users/:userId/publications`

**Response:**
```json
{
  "data": [
    {
      "id": "publication_id",
      "name": "Publication Name",
      "description": "Description",
      "url": "https://medium.com/publication-name"
    }
  ]
}
```

---

### 3. Publish Article

**Endpoint:** `POST /v1/users/:userId/posts`

**Body:**
```json
{
  "title": "Article Title",
  "contentFormat": "html",
  "content": "<h1>Title</h1><p>Content...</p>",
  "tags": ["tag1", "tag2", "tag3"],
  "publishStatus": "draft"
}
```

**Parameters:**
- `title` (required): Article title
- `contentFormat` (required): "html" or "markdown"
- `content` (required): Article content
- `tags` (optional): Array of tags (max 5)
- `publishStatus` (required): "draft" or "public"
- `canonicalUrl` (optional): For cross-posting

---

## 💻 Example Code (JavaScript)

### Basic Setup

```javascript
const MEDIUM_TOKEN = 'your_integration_token';
const API_BASE = 'https://api.medium.com/v1';

const headers = {
  'Authorization': `Bearer ${MEDIUM_TOKEN}`,
  'Content-Type': 'application/json',
  'Accept': 'application/json'
};
```

### Get User Info

```javascript
async function getMediumUser() {
  const response = await fetch(`${API_BASE}/me`, {
    headers: headers
  });

  const data = await response.json();
  return data.data;
}
```

### Publish Article

```javascript
async function publishArticle(userId, article) {
  const response = await fetch(`${API_BASE}/users/${userId}/posts`, {
    method: 'POST',
    headers: headers,
    body: JSON.stringify({
      title: article.title,
      contentFormat: 'html',
      content: article.content,
      tags: article.tags || [],
      publishStatus: 'public'
    })
  });

  const data = await response.json();
  return data.data;
}
```

---

## ⚠️ Limitations & Issues

### No Verification Process
- ❌ No app registration
- ❌ No OAuth flow
- ❌ Only simple bearer token
- ❌ No scopes or permissions

### Limited Functionality
- ❌ Cannot fetch/read articles
- ❌ No analytics or statistics
- ❌ No comment management
- ❌ No draft updates
- ❌ No article deletion

### No Support
- ❌ No developer support
- ❌ No SLA or uptime guarantee
- ❌ GitHub repo archived
- ❌ No bug fixes or updates

### Rate Limits
- ⚠️ Unknown and not documented
- ⚠️ No rate limit headers in response
- ⚠️ Risk of unexpected blocking

---

## 🔄 Alternatives

### 1. Unofficial APIs

**MediumAPI.com**
- URL: https://mediumapi.com/
- Commercial product (paid)
- More features than official API
- Web scraping-based
- ⚠️ Against Medium ToS

### 2. RSS Feeds

**For Reading:**
- Each Medium publication has RSS feed
- Format: `https://medium.com/feed/@username`
- No authentication needed
- Free and stable

### 3. Other Platforms

**Consider:**
- **Dev.to:** Full API, developer-focused
- **Hashnode:** GraphQL API, developer blogs
- **Ghost:** Self-hosted, full API
- **WordPress:** REST API, very extensive

---

## 🚨 Why NOT Use Medium?

### For Production Apps: ❌ NOT RECOMMENDED

**Reasons:**
1. **No support** - API is abandoned
2. **No guarantees** - Could disappear anytime
3. **Limited functionality** - Write-only, no read
4. **No updates** - Bugs won't be fixed
5. **Business risk** - Could break your app without warning

---

## ✅ If You Still Use Medium

### Best Practices

#### Error Handling (CRITICAL)
```javascript
async function safePostToMedium(article) {
  try {
    return await postToMedium(article);
  } catch (error) {
    console.error('Medium API failed:', error);
    notifyUser('Medium posting failed, saved locally');
    saveArticleDraft(article);
    return null;
  }
}
```

#### Monitoring
- Monitor API uptime yourself
- Alert on failures
- Track error rates
- Have manual posting fallback

---

## 📞 Support & Resources

### Official (Archived)

**GitHub Repo:**
https://github.com/Medium/medium-api-docs (archived)

**Last Update:** March 2, 2023

**No Support:**
- No developer support
- No bug reports accepted
- No feature requests

---

## 🎯 Recommendation

**For new projects: ❌ DO NOT USE MEDIUM API**

**Consider:**
1. Choose Dev.to, Hashnode, or Ghost for blogging APIs
2. If Medium important: use RSS feeds for reading
3. For posting: offer manual posting flow
4. Focus on platforms with active API support

---

**Document Version:** 1.0
**Last Updated:** February 8, 2026
**Status:** API DEPRECATED - NOT RECOMMENDED
**Alternative:** Dev.to, Hashnode, Ghost
