# Client Manager / Brand2Boost - Deep Dive Documentation

**Project Name:** Brand2Boost (formerly Client Manager)
**Type:** Multi-Tenant SaaS Application
**Purpose:** AI-Powered Brand Development & Promotion Platform
**Status:** ✅ Active Development
**Generated:** 2026-01-08

---

## 📋 TABLE OF CONTENTS

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Technology Stack](#technology-stack)
4. [Backend API Structure](#backend-api-structure)
5. [Frontend Structure](#frontend-structure)
6. [Database & Data Storage](#database--data-storage)
7. [Key Features](#key-features)
8. [API Endpoints](#api-endpoints)
9. [Authentication & Authorization](#authentication--authorization)
10. [AI Integration](#ai-integration)
11. [Development Workflow](#development-workflow)
12. [Deployment](#deployment)
13. [Configuration](#configuration)

---

## OVERVIEW

### What is Brand2Boost?

Brand2Boost is a SaaS platform that uses AI to help businesses develop their brand identity through:
- **Interactive brand interviews** - AI-guided questionnaires to extract brand essence
- **Automated brand analysis** - Intelligent processing of business information
- **Visual identity generation** - AI-powered logo, color scheme, and typography recommendations
- **Content planning** - Social media content calendars and post generation
- **Multi-platform publishing** - Integration with WordPress, Facebook, and other platforms
- **Token-based pricing** - Pay-per-use AI token system with subscription tiers

### Business Model

- **Multi-tenant SaaS** - Each customer gets isolated data and settings
- **Token-based usage** - Users purchase token packages for AI operations
- **Subscription tiers** - Free, Pro, Enterprise with different feature sets
- **Role-based access** - Admin, Manager, Editor, Viewer roles

### Key Metrics

- **242 C# files** in backend API
- **223 TypeScript/TSX files** in frontend
- **46 API controllers** covering all feature domains
- **~50+ database tables** (Entity Framework migrations)
- **30+ AI prompt templates** in store configuration

---

## ARCHITECTURE

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Brand2Boost Platform                     │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
┌───────▼────────┐   ┌────────▼────────┐   ┌───────▼────────┐
│   React SPA    │   │   .NET Web API  │   │  Configuration │
│  (Frontend)    │◄──┤   (Backend)     │◄──┤     Store      │
│                │   │                 │   │                │
│  - Vite        │   │  - ASP.NET 9.0  │   │ C:\stores\     │
│  - React 18    │   │  - EF Core      │   │ brand2boost\   │
│  - TypeScript  │   │  - SignalR      │   │                │
│  - Tailwind    │   │  - Hangfire     │   │ - SQLite DBs   │
└────────────────┘   └─────────────────┘   │ - Prompts      │
                              │             │ - Settings     │
                     ┌────────▼────────┐   └────────────────┘
                     │                 │
                     │  Hazina AI      │
                     │  Framework      │
                     │                 │
                     │ C:\Projects\    │
                     │ hazina\         │
                     └─────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
┌───────▼────────┐   ┌────────▼────────┐   ┌───────▼────────┐
│   OpenAI API   │   │  WordPress API  │   │  Facebook API  │
│                │   │                 │   │                │
│  - GPT-4       │   │  - REST API     │   │  - Graph API   │
│  - DALL-E      │   │  - WP-CLI       │   │  - Pages       │
│  - Embeddings  │   │  - Custom theme │   │  - Publishing  │
└────────────────┘   └─────────────────┘   └────────────────┘
```

### Multi-Repository Architecture

Brand2Boost is part of a multi-repository ecosystem:

```
C:\Projects\
├── client-manager\          ← Main application (this project)
│   ├── ClientManagerAPI\    ← .NET backend
│   ├── ClientManagerFrontend\ ← React frontend
│   └── ClientManager.Tests\ ← Unit tests
│
├── hazina\                  ← AI framework (formerly DevGPT)
│   ├── Libraries\           ← Core AI libraries
│   ├── apps\               ← Sample apps
│   └── Tests\              ← Framework tests
│
└── devgpttools\            ← Legacy tools (being migrated to Hazina)
    ├── Common\
    ├── DevGPT.GenerationTools.*\
    └── Services\

C:\stores\
└── brand2boost\            ← Configuration & data store
    ├── identity.db         ← User auth database
    ├── llm-logs.db        ← AI usage logs
    ├── *.prompt.txt       ← AI prompt templates
    └── *.config.json      ← Feature configurations
```

### Solution Files

**Two solution files for different scenarios:**

1. **ClientManager.sln** (Production)
   - Uses NuGet packages for Hazina/DevGPT libraries
   - For CI/CD builds and production deployments
   - Faster builds, no local dependencies

2. **ClientManager.local.sln** (Development)
   - Uses local project references to Hazina
   - For debugging with full symbols
   - Edit framework code while debugging app
   - **Use this for local development!**

---

## TECHNOLOGY STACK

### Backend (.NET API)

**Core Framework:**
- **.NET 9.0** - Latest LTS release
- **ASP.NET Core** - Web API framework
- **Entity Framework Core** - ORM for database access
- **Serilog** - Structured logging
- **Hangfire** - Background job processing

**Authentication & Security:**
- **ASP.NET Core Identity** - User management
- **JWT (JSON Web Tokens)** - API authentication
- **Google OAuth** - Social login
- **Role-based authorization** - RBAC implementation

**Real-time Communication:**
- **SignalR** - WebSocket-based real-time updates
- Used for: chat, notifications, live progress updates

**AI & LLM Integration:**
- **Hazina AI Framework** - Multi-provider LLM abstraction
- **OpenAI SDK** - GPT-4, DALL-E integration
- **Anthropic SDK** - Claude integration
- **Custom embedding services** - Semantic search

**Background Jobs:**
- **Hangfire** - Recurring jobs, queued tasks
- **In-Memory storage** - Simple setup for development

**Database:**
- **SQLite** - Development and embedded storage
- **PostgreSQL** - Production-ready (supported)
- **Entity Framework migrations** - Schema versioning

### Frontend (React SPA)

**Core Framework:**
- **React 18.3** - Latest stable React
- **TypeScript 5.5** - Type-safe JavaScript
- **Vite 5.4** - Ultra-fast build tool
- **React Router 6** - Client-side routing

**UI Framework:**
- **Tailwind CSS 3.4** - Utility-first CSS
- **Radix UI** - Accessible component primitives
- **shadcn/ui** - Pre-built component library
- **Lucide React** - Icon library (427 icons)

**State Management:**
- **Zustand 5.0** - Lightweight state management
- **TanStack Query (React Query)** - Server state caching
- **Context API** - Theme, auth, i18n contexts

**Rich Text Editor:**
- **TipTap** - Headless editor framework
  - Image upload support
  - Link handling
  - Table support
  - Underline, bold, italic
  - Starter kit for markdown-like syntax

**Real-time:**
- **@microsoft/signalr** - SignalR client for React
- **WebSocket connection** to backend

**Drag & Drop:**
- **@dnd-kit** - Modern drag and drop
  - Core functionality
  - Sortable lists
  - Utilities for complex interactions

**Internationalization:**
- **i18next** - Translation framework
- **react-i18next** - React bindings
- **Multiple languages supported**

**UI Components:**
- **React Big Calendar** - Calendar views for content planning
- **Sonner** - Toast notifications
- **cmdk** - Command palette (Cmd+K)
- **next-themes** - Dark mode support

**Form Validation:**
- **Zod 4.3** - Schema validation
- Used for form validation and API response typing

**Testing:**
- **Vitest** - Fast unit test runner (Vite-native)
- **Testing Library** - React component testing
- **@faker-js/faker** - Test data generation
- **Storybook 8** - Component documentation
  - Accessibility addon
  - Interactions testing
  - Essential addons included

**Development Tools:**
- **ESLint 9** - Code linting
- **TypeScript** - Type checking
- **Autoprefixer** - CSS vendor prefixes
- **PostCSS** - CSS transformations

---

## BACKEND API STRUCTURE

### Project Structure

```
ClientManagerAPI/
├── Controllers/              ← 46 API controllers
│   ├── AuthController.cs    ← Authentication & registration
│   ├── OnboardingController.cs ← User onboarding workflow
│   ├── AnalysisController.cs ← Brand analysis
│   ├── ChatController.cs    ← AI chat interface
│   ├── ContentController.cs ← Content generation
│   ├── SocialMediaPostController.cs ← Social posts
│   ├── WordPressAioController.cs ← WordPress integration
│   ├── FacebookController.cs ← Facebook integration
│   ├── SubscriptionController.cs ← Subscription management
│   ├── TokenBalanceController.cs ← Token tracking
│   └── ...40 more controllers
│
├── Services/                ← Business logic layer
│   ├── TokenService.cs     ← Token consumption logic
│   ├── SubscriptionService.cs ← Subscription logic
│   ├── EmailService.cs     ← Email notifications
│   └── ...more services
│
├── Models/                  ← Data models & DTOs
│   ├── Brand.cs
│   ├── User.cs
│   ├── Subscription.cs
│   ├── TokenPackage.cs
│   └── ...entity models
│
├── Middleware/              ← Request pipeline middleware
│   ├── TokenTrackingMiddleware.cs ← Track API usage
│   ├── ErrorHandlingMiddleware.cs ← Global error handling
│   └── MIDDLEWARE_GUIDE.md
│
├── Infrastructure/          ← Cross-cutting concerns
│   ├── Database/           ← DbContext, migrations
│   ├── Authentication/     ← Auth configuration
│   └── Email/              ← Email templates
│
├── Migrations/              ← EF Core migrations (50+)
│   ├── 20250101_InitialCreate.cs
│   ├── 20250102_AddSubscriptions.cs
│   └── ...migration history
│
├── Jobs/                    ← Hangfire background jobs
│   ├── TokenResetJob.cs    ← Monthly token reset
│   └── ...scheduled jobs
│
├── Extensions/              ← Extension methods
│   ├── ServiceExtensions.cs ← DI registration helpers
│   └── ...extensions
│
├── Filters/                 ← Action filters
│   ├── ValidateModelAttribute.cs
│   └── ...filters
│
├── Attributes/              ← Custom attributes
│   ├── RequireRoleAttribute.cs
│   └── ...attributes
│
├── Helpers/                 ← Utility classes
│   └── ...helpers
│
├── Utilities/               ← Common utilities
│   └── ...utilities
│
├── Program.cs               ← Application entry point
├── Startup.cs               ← Service configuration (legacy)
├── appsettings.json        ← Configuration
├── appsettings.Secrets.json ← Secrets (gitignored)
└── ClientManagerAPI.csproj  ← Project file
```

### Key Files

**Program.cs** (400+ lines)
- Application bootstrap
- Service registration
- Middleware configuration
- Serilog setup
- Hangfire dashboard
- SignalR hubs
- CORS policies
- Authentication/authorization
- Static files serving
- Exception handling

**Controllers Overview** (46 controllers)

| Controller | Purpose |
|-----------|---------|
| **Core Business** | |
| OnboardingController | User onboarding workflow |
| AnalysisController | Brand analysis & questionnaires |
| GatheredDataController | User-provided data management |
| IntakeController | Initial data intake |
| **Content & Publishing** | |
| ContentController | Content generation |
| ContentPlanningController | Content calendar |
| SocialMediaPostController | Social media posts |
| BlogController | Blog post management |
| BlogCategoryController | Blog categories |
| PublishedPostsController | Publishing tracking |
| PostLinkingController | Cross-platform post linking |
| **AI & Chat** | |
| ChatController | AI chat interface |
| ConversationStartersController | Chat suggestions |
| DevGPTStoreAgentController | AI agents |
| DevGPTStoreController | AI store operations |
| EmbeddingsController | Semantic embeddings |
| PromptsController | AI prompt management |
| RolePromptController | Role-specific prompts |
| **WordPress Integration** | |
| WordPressAioController | All-in-one WordPress |
| WebsiteController | Website management |
| UploadController | File uploads |
| UploadedDocumentsController | Document management |
| **Social Media** | |
| FacebookController | Facebook integration |
| SocialMediaAnalyticsController | Analytics |
| SocialImportController | Import from socials |
| **User & Auth** | |
| AuthController | Authentication |
| UserController | User management |
| ProfileController | User profiles |
| RolePromptController | User roles |
| **Billing & Tokens** | |
| SubscriptionController | Subscription management |
| PaymentController | Payment processing (Stripe) |
| TokenBalanceController | Token balance queries |
| TokenManagementController | Token admin |
| TokenMetricsController | Token analytics |
| TokenPackageController | Token packages |
| TokenUsageController | Usage tracking |
| **Configuration** | |
| FeatureFlagsController | Feature toggles |
| MenuController | Dynamic menus |
| LanguageController | i18n support |
| ProjectsController | Project management |
| **Monitoring** | |
| HealthController | Health checks |
| LogController | Log management |
| StatisticsController | Platform statistics |
| **Other** | |
| ProductController | Product catalog |
| StoryController | Brand storytelling |
| MigrationController | Data migrations |
| AppVersionController | Version info |

---

## FRONTEND STRUCTURE

### Directory Structure

```
ClientManagerFrontend/src/
├── components/              ← React components
│   ├── auth/               ← Authentication UI
│   ├── brand/              ← Brand-related components
│   ├── chat/               ← Chat interface
│   ├── content/            ← Content creation UI
│   ├── dashboard/          ← Dashboard widgets
│   ├── editor/             ← Rich text editor
│   ├── onboarding/         ← Onboarding wizard
│   ├── social/             ← Social media UI
│   ├── subscription/       ← Subscription management
│   ├── ui/                 ← shadcn/ui components
│   └── ...feature folders
│
├── services/                ← API client services
│   ├── api.ts              ← Axios instance
│   ├── authService.ts      ← Auth API calls
│   ├── contentService.ts   ← Content API calls
│   ├── chatService.ts      ← Chat API calls
│   ├── subscriptionService.ts ← Subscription API
│   └── ...service files
│
├── stores/                  ← Zustand state stores
│   ├── authStore.ts        ← Auth state
│   ├── chatStore.ts        ← Chat state
│   ├── contentStore.ts     ← Content state
│   ├── subscriptionStore.ts ← Subscription state
│   └── ...state stores
│
├── hooks/                   ← Custom React hooks
│   ├── useAuth.ts          ← Authentication hook
│   ├── useChat.ts          ← Chat functionality
│   ├── useSubscription.ts  ← Subscription data
│   ├── useTokens.ts        ← Token balance
│   └── ...custom hooks
│
├── contexts/                ← React contexts
│   ├── ThemeContext.tsx    ← Dark/light mode
│   ├── I18nContext.tsx     ← Internationalization
│   └── ...contexts
│
├── types/                   ← TypeScript type definitions
│   ├── api.ts              ← API response types
│   ├── models.ts           ← Domain models
│   ├── subscription.ts     ← Subscription types
│   └── ...type files
│
├── lib/                     ← Utility libraries
│   ├── utils.ts            ← Utility functions
│   ├── cn.ts               ← Tailwind class merger
│   └── ...helpers
│
├── i18n/                    ← Internationalization
│   ├── config.ts           ← i18n configuration
│   └── ...i18n setup
│
├── locales/                 ← Translation files
│   ├── en/                 ← English translations
│   ├── nl/                 ← Dutch translations
│   └── ...languages
│
├── assets/                  ← Static assets
│   ├── images/
│   ├── icons/
│   └── ...assets
│
├── constants/               ← App constants
│   ├── routes.ts           ← Route constants
│   ├── api.ts              ← API endpoints
│   └── ...constants
│
├── data/                    ← Mock/seed data
│   └── ...data files
│
├── __tests__/               ← Test files
│   ├── components/
│   ├── services/
│   └── ...tests
│
├── App.tsx                  ← Root component
├── main.tsx                 ← Entry point
├── index.css                ← Global styles
├── design-tokens.ts         ← Design system tokens
└── vite-env.d.ts           ← Vite type definitions
```

### Key Components

**Onboarding Flow:**
- `OnboardingWizard.tsx` - Multi-step onboarding
- `BrandQuestionnaire.tsx` - Brand discovery questions
- `GoalSelection.tsx` - Business goals selection

**Content Creation:**
- `ContentEditor.tsx` - TipTap rich text editor
- `ContentCalendar.tsx` - React Big Calendar integration
- `PostScheduler.tsx` - Schedule posts for publishing
- `SocialMediaPreview.tsx` - Preview posts for each platform

**Chat Interface:**
- `ChatWindow.tsx` - Main chat UI
- `MessageList.tsx` - Chat message history
- `ChatInput.tsx` - Message input with typing indicators
- `ConversationStarters.tsx` - Suggested prompts

**Dashboard:**
- `DashboardOverview.tsx` - Analytics overview
- `TokenBalance.tsx` - Token usage widget
- `RecentActivity.tsx` - Activity feed
- `QuickActions.tsx` - Common actions

**Subscription:**
- `SubscriptionPlans.tsx` - Plan selection
- `TokenPackages.tsx` - Buy token packages
- `BillingHistory.tsx` - Invoice history
- `UsageMetrics.tsx` - Token usage charts

---

## DATABASE & DATA STORAGE

### Database Schema

**Core Entities:**

**Users & Authentication:**
- `AspNetUsers` - User accounts (Identity)
- `AspNetRoles` - User roles
- `AspNetUserRoles` - User-role mapping
- `UserProfiles` - Extended user data
- `UserSettings` - User preferences

**Subscriptions & Billing:**
- `Subscriptions` - Active subscriptions
- `SubscriptionPlans` - Available plans (Free, Pro, Enterprise)
- `TokenPackages` - Token purchase packages
- `TokenTransactions` - Token usage history
- `TokenBalances` - Current token balances per user
- `Payments` - Payment records (Stripe)

**Brand Development:**
- `Brands` - Brand entities
- `BrandAnalysis` - Analysis results
- `GatheredData` - User-provided brand data
- `OnboardingProgress` - Onboarding state
- `BrandStories` - Brand narratives
- `BrandProfiles` - Complete brand profiles

**Content Management:**
- `Contents` - Generated content
- `ContentPlans` - Content calendars
- `SocialMediaPosts` - Social posts
- `PublishedPosts` - Publishing tracking
- `BlogPosts` - Blog content
- `BlogCategories` - Blog categories
- `UploadedDocuments` - File uploads

**AI & Chat:**
- `Conversations` - Chat conversations
- `Messages` - Chat messages
- `ConversationStarters` - Suggested prompts
- `Prompts` - AI prompt templates
- `RolePrompts` - Role-specific prompts
- `Embeddings` - Vector embeddings

**WordPress Integration:**
- `WordPressSites` - Connected WP sites
- `WordPressPosts` - WP post sync
- `WordPressCategories` - WP categories

**Social Media:**
- `FacebookPages` - Connected FB pages
- `SocialMediaAnalytics` - Social analytics
- `SocialImports` - Imported social data

**Configuration:**
- `FeatureFlags` - Feature toggles
- `AppSettings` - Application settings
- `Languages` - Supported languages

**Audit & Logging:**
- `AuditLogs` - Audit trail
- `ApplicationLogs` - Application logs (via Serilog)

### External Data Store

**C:\stores\brand2boost\**

**Databases (SQLite):**
- `identity.db` - User authentication (3MB)
- `llm-logs.db` - LLM API call logs (3MB)

**Configuration Files:**
- `analysis-fields.config.json` - Brand analysis field definitions
- `interview.settings.json` - Interview workflow configuration
- `opening-questions.json` - Initial onboarding questions
- `tools.config.json` - AI tool configurations
- `users.json` - User management overrides

**AI Prompts (30+ files):**
- Brand prompts: `brand-*.prompt.txt`
- Business prompts: `business-*.prompt.txt`
- Visual prompts: `logo-*.prompt.txt`, `color-scheme.prompt.txt`
- Content prompts: `image-prompt-*.prompt.txt`
- Workflow: `step1_concept.txt`, `step2_identity.txt`, etc.

---

## KEY FEATURES

### 1. AI-Powered Brand Development

**Onboarding Interview:**
- AI-guided questionnaire to extract brand essence
- Dynamic question flow based on previous answers
- Conversation starters to help users express ideas
- Progress saving and resume capability

**Brand Analysis:**
- Automatic analysis of gathered data
- AI-generated insights and recommendations
- Sentiment analysis of brand descriptions
- Competitive positioning analysis

**Visual Identity Generation:**
- Logo concept generation (DALL-E)
- Color scheme recommendations
- Typography suggestions
- Brand style guide creation

### 2. Content Planning & Creation

**Content Calendar:**
- Visual calendar interface (React Big Calendar)
- Drag-and-drop post scheduling
- Multi-platform content planning
- Recurring post templates

**AI Content Generation:**
- Social media post generation
- Blog post writing assistance
- Image caption generation
- Hashtag recommendations

**Multi-Platform Publishing:**
- WordPress integration (REST API + WP-CLI)
- Facebook Page publishing
- Cross-platform post linking
- Publishing status tracking

### 3. Chat Interface

**AI Chat Assistant:**
- Real-time chat with GPT-4
- Context-aware responses about brand
- Conversation history
- Typing indicators (SignalR)

**Conversation Starters:**
- Pre-defined prompts for common tasks
- Dynamic suggestions based on context
- Quick actions from chat

### 4. Token-Based Pricing

**Token System:**
- Pay-per-use model for AI operations
- Different costs for different operations:
  - Chat message: X tokens
  - Image generation: Y tokens
  - Analysis: Z tokens
- Real-time balance tracking
- Low balance warnings

**Subscription Tiers:**
- **Free:** 100 tokens/month
- **Pro:** 1000 tokens/month + features
- **Enterprise:** Unlimited + priority support

**Token Packages:**
- Buy additional token packages
- Unused tokens roll over
- Gift tokens to team members

### 5. Multi-Tenant Architecture

**Tenant Isolation:**
- Each user has isolated data
- No cross-tenant data leakage
- Tenant-specific configuration

**Team Collaboration:**
- Invite team members
- Role-based permissions (Admin, Manager, Editor, Viewer)
- Shared brand workspaces

### 6. WordPress Integration

**WordPress All-in-One:**
- Connect multiple WP sites
- Sync posts bidirectionally
- Category mapping
- Media upload
- Custom theme integration

**WP-CLI Integration:**
- Server-side WP-CLI commands
- Bulk operations
- Plugin management

### 7. Real-Time Features

**SignalR Hubs:**
- Chat typing indicators
- Live notifications
- Progress updates for long operations
- Real-time collaboration

### 8. Internationalization

**Multi-Language Support:**
- English (en)
- Dutch (nl)
- Easy to add more languages
- Dynamic language switching
- Translated UI and prompts

---

## API ENDPOINTS

### Authentication & Users

```
POST   /api/auth/register          - Register new user
POST   /api/auth/login             - Login with credentials
POST   /api/auth/google-login      - Login with Google OAuth
POST   /api/auth/refresh           - Refresh JWT token
POST   /api/auth/logout            - Logout
GET    /api/user/profile           - Get user profile
PUT    /api/user/profile           - Update profile
GET    /api/user/settings          - Get user settings
PUT    /api/user/settings          - Update settings
```

### Onboarding & Analysis

```
GET    /api/onboarding/start       - Start onboarding
POST   /api/onboarding/submit      - Submit onboarding data
GET    /api/onboarding/progress    - Get progress
POST   /api/analysis/analyze       - Trigger brand analysis
GET    /api/analysis/results       - Get analysis results
GET    /api/gathered-data          - Get gathered data
POST   /api/gathered-data          - Save gathered data
```

### Content Management

```
GET    /api/content                - List content
POST   /api/content                - Create content
PUT    /api/content/{id}           - Update content
DELETE /api/content/{id}           - Delete content
GET    /api/content-planning       - Get content calendar
POST   /api/content-planning       - Schedule content
GET    /api/social-media-post      - List social posts
POST   /api/social-media-post      - Create social post
PUT    /api/social-media-post/{id} - Update post
POST   /api/social-media-post/{id}/publish - Publish post
```

### Chat

```
GET    /api/chat/conversations     - List conversations
POST   /api/chat/message           - Send message
GET    /api/chat/history/{id}      - Get conversation history
GET    /api/conversation-starters  - Get suggested prompts
```

### WordPress

```
GET    /api/wordpress/sites        - List connected sites
POST   /api/wordpress/connect      - Connect WP site
GET    /api/wordpress/posts        - List WP posts
POST   /api/wordpress/posts        - Create WP post
PUT    /api/wordpress/posts/{id}   - Update WP post
POST   /api/wordpress/sync         - Sync with WordPress
```

### Subscriptions & Tokens

```
GET    /api/subscription/current   - Get current subscription
POST   /api/subscription/upgrade   - Upgrade subscription
POST   /api/subscription/cancel    - Cancel subscription
GET    /api/token-balance          - Get token balance
GET    /api/token-usage            - Get usage history
GET    /api/token-package          - List packages
POST   /api/payment/checkout       - Create checkout session (Stripe)
POST   /api/payment/webhook        - Stripe webhook
```

### Feature Management

```
GET    /api/feature-flags          - Get feature flags
GET    /api/menu                   - Get dynamic menu
GET    /api/language               - Get available languages
GET    /api/statistics             - Get platform stats
GET    /api/health                 - Health check
```

---

## AUTHENTICATION & AUTHORIZATION

### JWT Authentication

**Flow:**
1. User submits credentials to `/api/auth/login`
2. Server validates credentials against `AspNetUsers`
3. Server generates JWT token with claims (userId, email, roles)
4. Client stores JWT in localStorage
5. Client includes JWT in `Authorization: Bearer <token>` header
6. Server validates JWT on each request
7. Token expires after configured time (default: 24 hours)
8. Client refreshes token using `/api/auth/refresh`

**JWT Claims:**
- `sub`: User ID
- `email`: User email
- `role`: User roles (comma-separated)
- `tenant`: Tenant ID (for multi-tenancy)
- `exp`: Expiration timestamp
- `iat`: Issued at timestamp

### Google OAuth

**Flow:**
1. User clicks "Sign in with Google"
2. Frontend redirects to Google OAuth consent screen
3. User approves
4. Google redirects back with authorization code
5. Frontend sends code to `/api/auth/google-login`
6. Backend exchanges code for Google access token
7. Backend fetches user info from Google
8. Backend creates or updates user in database
9. Backend generates JWT token
10. Client receives JWT and stores it

**Library:** `@react-oauth/google` (frontend), Google.Apis.Auth (backend)

### Role-Based Access Control (RBAC)

**Roles:**
- **Admin** - Full system access
- **Manager** - Manage team and content
- **Editor** - Create and edit content
- **Viewer** - Read-only access

**Implementation:**
- `[Authorize(Roles = "Admin")]` attribute on controllers/actions
- `RequireRoleAttribute` custom filter
- Frontend route guards based on user roles
- UI elements conditionally rendered based on roles

### Security Features

**Password Security:**
- ASP.NET Core Identity password hashing (PBKDF2)
- Configurable password requirements:
  - Minimum length: 8
  - Requires uppercase: Yes
  - Requires lowercase: Yes
  - Requires digit: Yes
  - Requires special char: Yes

**Token Security:**
- HTTPS enforced in production
- Secure cookie settings (HttpOnly, Secure, SameSite)
- Token rotation on refresh
- Token blacklisting on logout

**API Security:**
- CORS configured for frontend origin only
- Rate limiting (planned)
- Input validation (Zod schemas, ModelState)
- SQL injection prevention (EF Core parameterized queries)
- XSS prevention (React auto-escaping, CSP headers)

---

## AI INTEGRATION

### Hazina Framework

**Multi-Provider Support:**
- OpenAI (GPT-4, GPT-3.5, DALL-E)
- Anthropic (Claude)
- Google (Gemini)
- Mistral
- HuggingFace models

**Automatic Failover:**
- Primary provider: OpenAI
- Fallback provider: Anthropic
- Circuit breaker pattern
- Retry with exponential backoff

**Cost Tracking:**
- Automatic token counting
- Cost calculation per request
- Budget limits per user
- Usage analytics

### AI Operations

**Chat:**
- Streaming responses (SignalR)
- Context window management
- Conversation history
- System prompts from store config

**Content Generation:**
- Blog post generation
- Social media posts
- Image captions
- SEO descriptions

**Image Generation:**
- DALL-E integration
- Prompt optimization
- Multiple style variations
- Resolution selection

**Analysis:**
- Brand sentiment analysis
- Competitive analysis
- Audience insights
- Trend detection

**Embeddings:**
- Semantic search
- Similar content discovery
- Vector storage (PostgreSQL pgvector)

### Prompt Management

**Prompt Storage:**
- Prompts stored in `C:\stores\brand2boost\*.prompt.txt`
- Template variables: `{{brandName}}`, `{{industry}}`, etc.
- Version control via Git

**Prompt Types:**
- **System prompts:** Define AI personality
- **User prompts:** User input templates
- **Analysis prompts:** Brand analysis instructions
- **Generation prompts:** Content creation templates

**Dynamic Prompts:**
- Loaded from database or file system
- Admin UI for prompt editing (planned)
- A/B testing prompts (planned)

---

## DEVELOPMENT WORKFLOW

### Local Setup

**Prerequisites:**
- .NET 9.0 SDK
- Node.js 18+ and npm
- Visual Studio 2022 or VS Code
- Git

**Clone Repositories:**
```bash
cd C:\Projects
git clone https://github.com/martiendejong/client-manager.git
git clone <hazina-repo-url> hazina
```

**Backend Setup:**
```bash
cd C:\Projects\client-manager
# Open ClientManager.local.sln in Visual Studio
# Restore NuGet packages
dotnet restore ClientManager.local.sln
# Apply migrations
cd ClientManagerAPI
dotnet ef database update
# Run API
dotnet run
# API runs at https://localhost:54501
```

**Frontend Setup:**
```bash
cd C:\Projects\client-manager\ClientManagerFrontend
npm install
npm run dev
# Frontend runs at https://localhost:5173
```

**Configuration:**
```bash
# Copy secrets template
cp appsettings.example.json appsettings.Secrets.json
# Edit appsettings.Secrets.json with:
# - OpenAI API key
# - Anthropic API key
# - Google OAuth credentials
# - Stripe keys
# - Other secrets
```

### Git Workflow

**Branches:**
- `main` - Production-ready code
- `develop` - Integration branch
- `agent-XXX-feature-name` - Feature branches (in worktrees)

**Worktree Allocation:**
```bash
# ALWAYS allocate worktree before code edits!
# See C:\scripts\_machine\worktrees.protocol.md
```

**Commit Convention:**
```
<type>(<scope>): <subject>

<body>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

Types: feat, fix, docs, style, refactor, test, chore

**Pull Request Flow:**
1. Create feature branch in worktree
2. Make changes, commit regularly
3. Push to origin
4. Create PR to `develop` branch
5. Code review
6. Merge to `develop`
7. Periodically merge `develop` → `main`

### Testing

**Backend Tests:**
```bash
cd ClientManager.Tests
dotnet test
```

**Frontend Tests:**
```bash
cd ClientManagerFrontend
npm run test              # Run tests
npm run test:ui           # Open Vitest UI
npm run test:coverage     # Coverage report
```

**Storybook:**
```bash
npm run storybook         # Start Storybook dev server
npm run build-storybook   # Build static Storybook
```

### Debugging

**Backend:**
- Use Visual Studio debugger
- Set breakpoints in controllers/services
- Use `ClientManager.local.sln` for full symbols
- Agentic Debugger Bridge: http://localhost:27183

**Frontend:**
- Browser DevTools
- React DevTools extension
- Redux DevTools (for Zustand)
- Network tab for API calls

**Browser MCP:**
- Use Chrome DevTools MCP server
- Automated browser testing
- Screenshots and snapshots

---

## DEPLOYMENT

### Production Build

**Backend:**
```bash
cd ClientManagerAPI
dotnet publish -c Release -o ./publish
# Publishes to ./publish folder
```

**Frontend:**
```bash
cd ClientManagerFrontend
npm run build
# Builds to ./dist folder
```

### Deployment Targets

**IIS (Windows):**
1. Publish backend to folder
2. Build frontend
3. Copy frontend dist to backend wwwroot
4. Configure IIS site
5. Install .NET 9.0 Hosting Bundle
6. Configure app pool (No Managed Code)
7. Set environment variables

**Docker (Planned):**
- Dockerfile exists in Hazina framework
- Multi-stage build
- Production-ready image

**Azure App Service (Planned):**
- Deploy via GitHub Actions
- Automatic scaling
- Custom domain + SSL

### Environment Configuration

**Environment Variables:**
```bash
ASPNETCORE_ENVIRONMENT=Production
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
DATABASE_CONNECTION=...
JWT_SECRET=...
```

**appsettings.Production.json:**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Warning"
    }
  },
  "Database": {
    "Provider": "PostgreSQL",
    "ConnectionString": "..."
  },
  "Kestrel": {
    "Endpoints": {
      "Https": {
        "Url": "https://*:443"
      }
    }
  }
}
```

---

## CONFIGURATION

### Application Settings

**appsettings.json:**
```json
{
  "Kestrel": {
    "Endpoints": {
      "Http": { "Url": "http://*:5000" },
      "Https": { "Url": "https://*:54501" }
    }
  },
  "ApiSettings": {
    "OpenApiKey": "...",
    "AnthropicApiKey": "..."
  },
  "ProjectSettings": {
    "ProjectsFolder": "C:\\stores\\brand2boost"
  },
  "TokenSettings": {
    "FreeMonthlyTokens": 100,
    "ProMonthlyTokens": 1000,
    "EnterpriseMonthlyTokens": -1
  },
  "Stripe": {
    "PublishableKey": "pk_test_...",
    "SecretKey": "sk_test_...",
    "WebhookSecret": "whsec_..."
  }
}
```

**appsettings.Secrets.json (gitignored):**
```json
{
  "ApiSettings": {
    "OpenApiKey": "sk-...",
    "AnthropicApiKey": "sk-ant-..."
  },
  "Google": {
    "ClientId": "...",
    "ClientSecret": "..."
  },
  "Stripe": {
    "SecretKey": "sk_live_...",
    "WebhookSecret": "whsec_..."
  },
  "ConnectionStrings": {
    "DefaultConnection": "..."
  },
  "JWT": {
    "Secret": "...",
    "Issuer": "https://brand2boost.com",
    "Audience": "https://brand2boost.com"
  }
}
```

### Feature Flags

**Stored in:** Database (`FeatureFlags` table)

**Examples:**
- `enable_chat` - Enable chat feature
- `enable_wordpress` - Enable WordPress integration
- `enable_facebook` - Enable Facebook publishing
- `enable_image_generation` - Enable DALL-E
- `enable_advanced_analysis` - Enable advanced AI analysis

**Usage:**
```csharp
// Backend
var isEnabled = await _featureFlagService.IsEnabledAsync("enable_chat");

// Frontend
const isEnabled = useFeatureFlag('enable_chat');
```

---

## TROUBLESHOOTING

### Common Issues

**1. Symbols not loading in debugger**
- **Solution:** Use `ClientManager.local.sln` instead of `ClientManager.sln`

**2. CORS errors**
- **Solution:** Check CORS policy in `Program.cs`, ensure frontend origin is allowed

**3. JWT token expired**
- **Solution:** Implement token refresh logic, call `/api/auth/refresh`

**4. Database migration errors**
- **Solution:** Delete database, run `dotnet ef database update` again

**5. npm install fails**
- **Solution:** Delete `node_modules` and `package-lock.json`, run `npm install` again

**6. Vite HTTPS certificate issues**
- **Solution:** Run `npm run prepare-cert` to regenerate self-signed cert

**7. SignalR connection fails**
- **Solution:** Check WebSocket support, firewall rules, CORS policy

**8. Token balance not updating**
- **Solution:** Check `TokenTrackingMiddleware`, verify database writes

**9. AI responses slow or timing out**
- **Solution:** Check OpenAI API status, increase timeout, enable streaming

**10. WordPress publishing fails**
- **Solution:** Verify WP REST API enabled, check credentials, test with Postman

---

## NEXT STEPS & ROADMAP

### Planned Features

**Q1 2026:**
- [ ] Advanced analytics dashboard
- [ ] Team collaboration features
- [ ] Multi-brand support per user
- [ ] Instagram integration
- [ ] TikTok integration
- [ ] LinkedIn publishing

**Q2 2026:**
- [ ] Mobile app (React Native)
- [ ] White-label solution
- [ ] API for third-party integrations
- [ ] Zapier integration
- [ ] Chrome extension

**Q3 2026:**
- [ ] Video content generation
- [ ] Podcast planning
- [ ] Email marketing integration
- [ ] CRM integration (Salesforce, HubSpot)
- [ ] Advanced SEO tools

**Q4 2026:**
- [ ] Enterprise features (SSO, audit logs, compliance)
- [ ] On-premise deployment option
- [ ] Advanced AI models (GPT-5, Claude 4)
- [ ] Voice interface
- [ ] AR/VR brand experiences

### Technical Debt

**High Priority:**
- [ ] Migrate from DevGPT to Hazina fully
- [ ] Implement comprehensive error handling
- [ ] Add request rate limiting
- [ ] Improve test coverage (target: 80%)
- [ ] Database performance optimization
- [ ] Implement caching (Redis)

**Medium Priority:**
- [ ] Refactor large controllers (split into smaller services)
- [ ] Standardize API response format
- [ ] Improve TypeScript type coverage
- [ ] Add API documentation (Swagger/OpenAPI)
- [ ] Implement GraphQL (consider)

**Low Priority:**
- [ ] Migrate from Hangfire to background services
- [ ] Consider microservices architecture
- [ ] Implement event sourcing for audit
- [ ] Explore serverless functions for AI operations

---

## RELATED DOCUMENTATION

- [PROJECTS_INDEX.md](./PROJECTS_INDEX.md) - Master project index
- [HAZINA_DEEP_DIVE.md](./HAZINA_DEEP_DIVE.md) - Hazina framework documentation
- [STORES_INDEX.md](./STORES_INDEX.md) - Data stores documentation
- [TECH_STACK_REFERENCE.md](./TECH_STACK_REFERENCE.md) - Technology stack reference
- [worktrees.protocol.md](./worktrees.protocol.md) - Worktree allocation protocol
- [API_VERSIONING_GUIDE.md](../client-manager/ClientManagerAPI/API_VERSIONING_GUIDE.md)
- [MIDDLEWARE_GUIDE.md](../client-manager/ClientManagerAPI/MIDDLEWARE_GUIDE.md)
- [SECRETS_SETUP.md](../client-manager/ClientManagerAPI/SECRETS_SETUP.md)

---

**Last Updated:** 2026-01-08
**Document Version:** 1.0
**Maintained by:** Claude Agent System
