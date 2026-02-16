# Database Schema Documentation 🗄️

**Database:** Brand2Boost / Client Manager
**Type:** SQLite (dev) / PostgreSQL (production)
**ORM:** Entity Framework Core 9.0
**Migrations:** Code-first

---

## Entity Relationship Diagram

```
┌─────────────────┐       ┌──────────────────┐       ┌─────────────────┐
│   AspNetUsers   │───────│ AspNetUserRoles  │───────│  AspNetRoles    │
│                 │ 1   * │                  │ *   1 │                 │
│ - Id (PK)       │       │ - UserId (FK)    │       │ - Id (PK)       │
│ - UserName      │       │ - RoleId (FK)    │       │ - Name          │
│ - Email         │       └──────────────────┘       │ - Description   │
│ - PasswordHash  │                                  └─────────────────┘
└─────────────────┘
        │ 1
        │
        │ *
┌─────────────────┐       ┌──────────────────┐
│  UserProfiles   │       │  Subscriptions   │
│                 │       │                  │
│ - Id (PK)       │       │ - Id (PK)        │
│ - UserId (FK)   │───────│ - UserId (FK)    │
│ - DisplayName   │ 1   1 │ - PlanId         │
│ - Avatar        │       │ - Status         │
│ - Bio           │       │ - StartDate      │
└─────────────────┘       │ - EndDate        │
                          │ - AutoRenew      │
                          └──────────────────┘
        │ 1                       │ 1
        │                         │
        │ *                       │ *
┌─────────────────┐       ┌──────────────────┐       ┌─────────────────┐
│     Brands      │       │  TokenBalances   │       │ TokenTransactions│
│                 │       │                  │       │                 │
│ - Id (PK)       │       │ - Id (PK)        │       │ - Id (PK)       │
│ - UserId (FK)   │       │ - UserId (FK)    │───────│ - UserId (FK)   │
│ - Name          │       │ - Balance        │ 1   * │ - Amount        │
│ - Industry      │       │ - MonthlyAlloc   │       │ - Type          │
│ - Status        │       │ - LastReset      │       │ - Description   │
└─────────────────┘       └──────────────────┘       │ - Timestamp     │
        │ 1                                          │ - Cost          │
        │                                            └─────────────────┘
        │ *
┌─────────────────┐       ┌──────────────────┐
│ BrandAnalysis   │       │  GatheredData    │
│                 │       │                  │
│ - Id (PK)       │───────│ - Id (PK)        │
│ - BrandId (FK)  │ 1   * │ - BrandId (FK)   │
│ - AnalysisType  │       │ - FieldName      │
│ - Results       │       │ - FieldValue     │
│ - Timestamp     │       │ - AnalyzedBy     │
└─────────────────┘       └──────────────────┘


┌─────────────────┐       ┌──────────────────┐       ┌─────────────────┐
│   Contents      │       │ ContentPlans     │       │ PublishedPosts  │
│                 │       │                  │       │                 │
│ - Id (PK)       │       │ - Id (PK)        │       │ - Id (PK)       │
│ - BrandId (FK)  │───────│ - BrandId (FK)   │       │ - ContentId (FK)│
│ - Title         │ 1   * │ - ScheduledDate  │───────│ - Platform      │
│ - Body          │       │ - Status         │ 1   * │ - ExternalId    │
│ - Type          │       │ - ContentId (FK) │       │ - PublishedDate │
│ - Status        │       └──────────────────┘       │ - Status        │
└─────────────────┘                                  │ - URL           │
        │ 1                                          └─────────────────┘
        │
        │ *
┌─────────────────┐       ┌──────────────────┐
│SocialMediaPosts │       │    BlogPosts     │
│                 │       │                  │
│ - Id (PK)       │       │ - Id (PK)        │
│ - ContentId (FK)│       │ - BrandId (FK)   │
│ - Platform      │       │ - Title          │
│ - Caption       │       │ - Slug           │
│ - MediaUrl      │       │ - Content        │
│ - Hashtags      │       │ - CategoryId (FK)│
│ - Status        │       │ - PublishDate    │
└─────────────────┘       │ - Status         │
                          └──────────────────┘
                                  │ *
                                  │
                                  │ 1
                          ┌──────────────────┐
                          │ BlogCategories   │
                          │                  │
                          │ - Id (PK)        │
                          │ - Name           │
                          │ - Description    │
                          │ - Slug           │
                          └──────────────────┘


┌─────────────────┐       ┌──────────────────┐
│ Conversations   │       │    Messages      │
│                 │       │                  │
│ - Id (PK)       │───────│ - Id (PK)        │
│ - UserId (FK)   │ 1   * │ - ConversationId │
│ - Title         │       │ - Role           │
│ - StartedAt     │       │ - Content        │
│ - LastActivity  │       │ - Timestamp      │
└─────────────────┘       │ - TokensUsed     │
                          │ - Cost           │
                          └──────────────────┘


┌─────────────────┐       ┌──────────────────┐
│ WordPressSites  │       │  WordPressPosts  │
│                 │       │                  │
│ - Id (PK)       │───────│ - Id (PK)        │
│ - BrandId (FK)  │ 1   * │ - SiteId (FK)    │
│ - Url           │       │ - WpPostId       │
│ - ApiKey        │       │ - Title          │
│ - Status        │       │ - Content        │
└─────────────────┘       │ - Status         │
                          │ - LastSynced     │
                          └──────────────────┘


┌─────────────────┐       ┌──────────────────┐
│  FacebookPages  │       │SocialMediaAnalytics
│                 │       │                  │
│ - Id (PK)       │───────│ - Id (PK)        │
│ - BrandId (FK)  │ 1   * │ - PageId (FK)    │
│ - PageId        │       │ - MetricName     │
│ - AccessToken   │       │ - MetricValue    │
│ - Status        │       │ - Timestamp      │
└─────────────────┘       └──────────────────┘


┌─────────────────┐       ┌──────────────────┐
│UploadedDocuments│       │    Prompts       │
│                 │       │                  │
│ - Id (PK)       │       │ - Id (PK)        │
│ - BrandId (FK)  │       │ - Name           │
│ - FileName      │       │ - Template       │
│ - FileSize      │       │ - Category       │
│ - ContentType   │       │ - IsActive       │
│ - UploadDate    │       └──────────────────┘
│ - FilePath      │
└─────────────────┘
```

---

## Core Tables

### Authentication & Users

#### AspNetUsers
**Purpose:** User accounts (ASP.NET Core Identity)

| Column | Type | Description |
|--------|------|-------------|
| Id | string (PK) | User ID (GUID) |
| UserName | string | Username |
| Email | string | Email address |
| EmailConfirmed | bool | Email verified? |
| PasswordHash | string | Hashed password (PBKDF2) |
| PhoneNumber | string | Phone (optional) |
| TwoFactorEnabled | bool | 2FA enabled? |
| LockoutEnd | datetime | Lockout expiry |
| AccessFailedCount | int | Failed login attempts |

**Indexes:**
- `IX_Email` (unique)
- `IX_UserName` (unique)

#### AspNetRoles
**Purpose:** User roles

| Column | Type | Description |
|--------|------|-------------|
| Id | string (PK) | Role ID (GUID) |
| Name | string | Role name (Admin, Manager, Editor, Viewer) |
| Description | string | Role description |

**Default Roles:**
- `Admin` - Full system access
- `Manager` - Manage team and content
- `Editor` - Create and edit content
- `Viewer` - Read-only access

#### AspNetUserRoles
**Purpose:** User-role mapping (many-to-many)

| Column | Type | Description |
|--------|------|-------------|
| UserId | string (FK) | User ID |
| RoleId | string (FK) | Role ID |

**Composite PK:** (UserId, RoleId)

---

### User Profiles & Settings

#### UserProfiles
**Purpose:** Extended user information

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Profile ID |
| UserId | string (FK) | User ID |
| DisplayName | string | Display name |
| Avatar | string | Avatar URL |
| Bio | string | User bio |
| Language | string | Preferred language (en, nl) |
| Timezone | string | Timezone |
| CreatedAt | datetime | Profile creation date |

**Indexes:**
- `IX_UserId` (unique)

---

### Subscriptions & Billing

#### Subscriptions
**Purpose:** User subscriptions

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Subscription ID |
| UserId | string (FK) | User ID |
| PlanId | string | Plan ID (free, pro, enterprise) |
| Status | string | Status (active, canceled, expired) |
| StartDate | datetime | Subscription start |
| EndDate | datetime | Subscription end (nullable) |
| AutoRenew | bool | Auto-renew enabled? |
| StripeSubscriptionId | string | Stripe subscription ID |
| CreatedAt | datetime | Created timestamp |
| UpdatedAt | datetime | Last updated |

**Plans:**
- `free` - 100 tokens/month
- `pro` - 1000 tokens/month
- `enterprise` - Unlimited

**Indexes:**
- `IX_UserId`
- `IX_Status`

#### TokenBalances
**Purpose:** User token balances

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Balance ID |
| UserId | string (FK) | User ID |
| Balance | int | Current token balance |
| MonthlyAllocation | int | Monthly token grant |
| LastReset | datetime | Last monthly reset |
| CreatedAt | datetime | Created timestamp |
| UpdatedAt | datetime | Last updated |

**Indexes:**
- `IX_UserId` (unique)

#### TokenTransactions
**Purpose:** Token usage history

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Transaction ID |
| UserId | string (FK) | User ID |
| Amount | int | Token amount (+purchase, -usage) |
| Type | string | Transaction type (purchase, usage, grant, refund) |
| Description | string | Transaction description |
| Timestamp | datetime | Transaction time |
| Cost | decimal | Monetary cost (for analytics) |
| Operation | string | Operation (chat, image, analysis, etc.) |

**Indexes:**
- `IX_UserId_Timestamp`
- `IX_Type`

---

### Brand Management

#### Brands
**Purpose:** Brand entities

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Brand ID |
| UserId | string (FK) | Owner user ID |
| Name | string | Brand name |
| Industry | string | Industry/sector |
| Status | string | Status (draft, active, archived) |
| Description | string | Brand description |
| Mission | string | Mission statement |
| Vision | string | Vision statement |
| Values | JSON | Core values |
| TargetAudience | JSON | Target audience data |
| CreatedAt | datetime | Created timestamp |
| UpdatedAt | datetime | Last updated |

**Indexes:**
- `IX_UserId`
- `IX_Status`

#### BrandAnalysis
**Purpose:** Brand analysis results

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Analysis ID |
| BrandId | int (FK) | Brand ID |
| AnalysisType | string | Analysis type (sentiment, competitive, audience) |
| Results | JSON | Analysis results |
| Timestamp | datetime | Analysis timestamp |
| AnalyzedBy | string | LLM model used (GPT-4, Claude, etc.) |
| TokensUsed | int | Tokens consumed |
| Cost | decimal | Cost of analysis |

**Indexes:**
- `IX_BrandId`
- `IX_AnalysisType`

#### GatheredData
**Purpose:** User-provided brand data

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Data ID |
| BrandId | int (FK) | Brand ID |
| FieldName | string | Field name (business_goals, tone_of_voice, etc.) |
| FieldValue | string | Field value (user input) |
| AnalyzedBy | string | LLM model (if AI-analyzed) |
| CreatedAt | datetime | Created timestamp |
| UpdatedAt | datetime | Last updated |

**Indexes:**
- `IX_BrandId_FieldName`

---

### Content Management

#### Contents
**Purpose:** Generated content

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Content ID |
| BrandId | int (FK) | Brand ID |
| Title | string | Content title |
| Body | string | Content body (markdown/HTML) |
| Type | string | Content type (blog, social, email, ad) |
| Status | string | Status (draft, scheduled, published) |
| CreatedAt | datetime | Created timestamp |
| UpdatedAt | datetime | Last updated |
| GeneratedBy | string | LLM model used |
| TokensUsed | int | Tokens consumed |

**Indexes:**
- `IX_BrandId`
- `IX_Status`
- `IX_Type`

#### ContentPlans
**Purpose:** Content calendar/scheduling

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Plan ID |
| BrandId | int (FK) | Brand ID |
| ContentId | int (FK) | Content ID (nullable) |
| ScheduledDate | datetime | Scheduled publication date |
| Status | string | Status (planned, scheduled, published) |
| Notes | string | Planning notes |
| CreatedAt | datetime | Created timestamp |

**Indexes:**
- `IX_BrandId_ScheduledDate`
- `IX_Status`

#### PublishedPosts
**Purpose:** Published content tracking

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Post ID |
| ContentId | int (FK) | Content ID |
| Platform | string | Platform (wordpress, facebook, linkedin) |
| ExternalId | string | External post ID |
| PublishedDate | datetime | Publication timestamp |
| Status | string | Status (published, failed, deleted) |
| URL | string | Published URL |
| Engagement | JSON | Engagement metrics (likes, shares, etc.) |

**Indexes:**
- `IX_ContentId`
- `IX_Platform`

---

### Social Media

#### SocialMediaPosts
**Purpose:** Social media posts

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Post ID |
| ContentId | int (FK) | Content ID (nullable) |
| BrandId | int (FK) | Brand ID |
| Platform | string | Platform (facebook, instagram, linkedin, twitter) |
| Caption | string | Post caption |
| MediaUrl | string | Media URL |
| MediaType | string | Media type (image, video, carousel) |
| Hashtags | string | Hashtags (comma-separated) |
| Status | string | Status (draft, scheduled, published) |
| ScheduledDate | datetime | Scheduled date (nullable) |
| PublishedDate | datetime | Published date (nullable) |
| CreatedAt | datetime | Created timestamp |

**Indexes:**
- `IX_BrandId`
- `IX_Platform`
- `IX_Status`

#### FacebookPages
**Purpose:** Connected Facebook pages

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Connection ID |
| BrandId | int (FK) | Brand ID |
| PageId | string | Facebook Page ID |
| PageName | string | Page name |
| AccessToken | string | Access token (encrypted) |
| Status | string | Status (connected, expired, revoked) |
| ConnectedAt | datetime | Connection timestamp |
| LastSynced | datetime | Last sync timestamp |

**Indexes:**
- `IX_BrandId`
- `IX_PageId` (unique)

#### SocialMediaAnalytics
**Purpose:** Social media metrics

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Metric ID |
| PageId | int (FK) | Page ID (FacebookPages, etc.) |
| MetricName | string | Metric name (impressions, reach, engagement) |
| MetricValue | decimal | Metric value |
| Timestamp | datetime | Metric timestamp |
| Period | string | Period (daily, weekly, monthly) |

**Indexes:**
- `IX_PageId_Timestamp`

---

### Blogging

#### BlogPosts
**Purpose:** Blog posts

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Post ID |
| BrandId | int (FK) | Brand ID |
| Title | string | Post title |
| Slug | string | URL slug |
| Content | string | Post content (markdown/HTML) |
| CategoryId | int (FK) | Category ID |
| FeaturedImage | string | Featured image URL |
| ExcerptExcerpt | string | Post excerpt |
| PublishDate | datetime | Publish date |
| Status | string | Status (draft, published, archived) |
| ViewCount | int | View count |
| CreatedAt | datetime | Created timestamp |
| UpdatedAt | datetime | Last updated |

**Indexes:**
- `IX_BrandId`
- `IX_Slug` (unique)
- `IX_CategoryId`
- `IX_Status`

#### BlogCategories
**Purpose:** Blog categories

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Category ID |
| Name | string | Category name |
| Description | string | Category description |
| Slug | string | URL slug |
| ParentId | int (FK) | Parent category (for hierarchy) |

**Indexes:**
- `IX_Slug` (unique)

---

### Chat & Conversations

#### Conversations
**Purpose:** Chat conversations

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Conversation ID |
| UserId | string (FK) | User ID |
| BrandId | int (FK) | Brand ID (nullable) |
| Title | string | Conversation title |
| StartedAt | datetime | Start timestamp |
| LastActivity | datetime | Last activity timestamp |
| TotalTokensUsed | int | Total tokens used |
| TotalCost | decimal | Total cost |

**Indexes:**
- `IX_UserId`
- `IX_BrandId`

#### Messages
**Purpose:** Chat messages

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Message ID |
| ConversationId | int (FK) | Conversation ID |
| Role | string | Role (user, assistant, system) |
| Content | string | Message content |
| Timestamp | datetime | Message timestamp |
| TokensUsed | int | Tokens consumed |
| Cost | decimal | Cost of message |
| Model | string | LLM model used |

**Indexes:**
- `IX_ConversationId_Timestamp`

---

### WordPress Integration

#### WordPressSites
**Purpose:** Connected WordPress sites

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Site ID |
| BrandId | int (FK) | Brand ID |
| Url | string | WordPress URL |
| ApiKey | string | WP API key (encrypted) |
| Username | string | WP username |
| Status | string | Status (connected, error) |
| ConnectedAt | datetime | Connection timestamp |
| LastSynced | datetime | Last sync timestamp |

**Indexes:**
- `IX_BrandId`
- `IX_Url`

#### WordPressPosts
**Purpose:** WordPress post sync

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Sync ID |
| SiteId | int (FK) | Site ID |
| WpPostId | int | WordPress post ID |
| Title | string | Post title |
| Content | string | Post content |
| Status | string | Status (published, draft) |
| LastSynced | datetime | Last sync timestamp |
| SyncDirection | string | Sync direction (to_wp, from_wp) |

**Indexes:**
- `IX_SiteId_WpPostId`

---

### File Management

#### UploadedDocuments
**Purpose:** Uploaded files

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Document ID |
| BrandId | int (FK) | Brand ID |
| FileName | string | Original filename |
| FileSize | long | File size (bytes) |
| ContentType | string | MIME type |
| UploadDate | datetime | Upload timestamp |
| FilePath | string | Storage path/URL |
| Status | string | Status (active, deleted) |

**Indexes:**
- `IX_BrandId`
- `IX_FileName`

---

### AI & Prompts

#### Prompts
**Purpose:** AI prompt templates

| Column | Type | Description |
|--------|------|-------------|
| Id | int (PK) | Prompt ID |
| Name | string | Prompt name |
| Template | string | Prompt template with variables |
| Category | string | Category (brand, content, analysis) |
| IsActive | bool | Is active? |
| CreatedAt | datetime | Created timestamp |
| UpdatedAt | datetime | Last updated |

**Indexes:**
- `IX_Category`
- `IX_IsActive`

---

## Indexes Summary

**Performance-critical indexes:**
- `IX_UserId` - Nearly all user-related queries
- `IX_BrandId` - All brand-related queries
- `IX_ConversationId_Timestamp` - Chat history queries
- `IX_TokenTransactions_UserId_Timestamp` - Usage analytics

**Uniqueness constraints:**
- `IX_AspNetUsers_Email` (unique)
- `IX_AspNetUsers_UserName` (unique)
- `IX_BlogPosts_Slug` (unique)
- `IX_UserProfiles_UserId` (unique)

---

## JSON Fields

**Tables with JSON columns:**
- `Brands.Values` - Array of core values
- `Brands.TargetAudience` - Complex audience data
- `BrandAnalysis.Results` - Analysis output
- `PublishedPosts.Engagement` - Metrics
- `SocialMediaAnalytics.Metadata` - Additional metrics

**Why JSON?** Flexible schema for AI-generated data, avoid excessive normalization.

---

## Migration Commands

**Create new migration:**
```bash
cd ClientManagerAPI
dotnet ef migrations add MigrationName
```

**Apply migrations:**
```bash
dotnet ef database update
```

**Rollback migration:**
```bash
dotnet ef database update PreviousMigrationName
```

**Generate SQL script:**
```bash
dotnet ef migrations script > migration.sql
```

---

## Visual ER Diagram (dbdiagram.io format)

**Generate visual diagram:**
1. Go to https://dbdiagram.io/
2. Paste the following DBML:

```dbml
Table AspNetUsers {
  Id varchar [pk]
  UserName varchar [unique]
  Email varchar [unique]
  PasswordHash varchar
}

Table Brands {
  Id int [pk]
  UserId varchar [ref: > AspNetUsers.Id]
  Name varchar
  Industry varchar
}

Table Subscriptions {
  Id int [pk]
  UserId varchar [ref: > AspNetUsers.Id]
  PlanId varchar
  Status varchar
}

Table TokenBalances {
  Id int [pk]
  UserId varchar [ref: > AspNetUsers.Id]
  Balance int
}

Table Contents {
  Id int [pk]
  BrandId int [ref: > Brands.Id]
  Title varchar
  Type varchar
}

Table Conversations {
  Id int [pk]
  UserId varchar [ref: > AspNetUsers.Id]
  Title varchar
}

Table Messages {
  Id int [pk]
  ConversationId int [ref: > Conversations.Id]
  Role varchar
  Content text
}
```

3. Click "Generate Diagram"
4. Export as PNG/SVG

---

## Related Documentation

- [CLIENT_MANAGER_DEEP_DIVE.md](./CLIENT_MANAGER_DEEP_DIVE.md) - Full architecture
- [GETTING_STARTED.md](./GETTING_STARTED.md) - Setup guide
- EF Migrations folder - `ClientManagerAPI/Migrations/`

---

**Last Updated:** 2026-01-08
**ORM:** Entity Framework Core 9.0
**Total Tables:** 30+
**Total Indexes:** 40+
