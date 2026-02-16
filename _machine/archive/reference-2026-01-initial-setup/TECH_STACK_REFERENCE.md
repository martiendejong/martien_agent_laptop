# Technology Stack Reference

**Purpose:** Complete technology inventory across all projects
**Generated:** 2026-01-08
**Maintained by:** Claude Agent System

---

## 📋 TABLE OF CONTENTS

1. [Overview](#overview)
2. [Backend Technologies](#backend-technologies)
3. [Frontend Technologies](#frontend-technologies)
4. [AI & LLM Technologies](#ai--llm-technologies)
5. [Databases & Storage](#databases--storage)
6. [DevOps & Infrastructure](#devops--infrastructure)
7. [Testing & Quality](#testing--quality)
8. [Tools & Utilities](#tools--utilities)
9. [Version Matrix](#version-matrix)

---

## OVERVIEW

### Technology Summary

**Primary Stacks:**
- **Backend:** .NET 9.0 (C#)
- **Frontend:** React 18 + TypeScript + Vite
- **AI Framework:** Hazina (multi-provider LLM abstraction)
- **Database:** SQLite (dev), PostgreSQL (prod)
- **Cloud:** Azure-ready, Supabase-compatible

**Language Distribution:**
- **C#** - 350+ files (Backend, Hazina framework)
- **TypeScript/JavaScript** - 300+ files (Frontend, tooling)
- **PowerShell** - 20+ scripts (Automation)
- **Batch/CMD** - 10+ files (Launchers)
- **Markdown** - 100+ files (Documentation)

---

## BACKEND TECHNOLOGIES

### .NET Ecosystem

**Runtime & Framework:**
- **.NET 9.0** - Latest LTS (primary target)
  - Used in: Client Manager API, Hazina Framework
  - Release: November 2024
  - Support: Until November 2027
- **.NET 8.0** - Supported (compatibility target)
  - Used in: Legacy components
  - Support: Until November 2026

**Language:**
- **C# 13** - Latest language features
  - Pattern matching
  - Records and init-only properties
  - File-scoped namespaces
  - Global usings
  - Nullable reference types

**Web Framework:**
- **ASP.NET Core 9.0**
  - Minimal APIs
  - Web API controllers
  - Middleware pipeline
  - Dependency injection
  - Configuration system

**ORM & Data Access:**
- **Entity Framework Core 9.0**
  - Code-first migrations
  - LINQ queries
  - Change tracking
  - Lazy loading
  - SQLite, PostgreSQL providers

**Authentication & Authorization:**
- **ASP.NET Core Identity**
  - User management
  - Password hashing (PBKDF2)
  - Role-based authorization
- **JWT (JSON Web Tokens)**
  - Token-based auth
  - Refresh tokens
  - Claims-based security
- **Google OAuth 2.0**
  - Social login
  - OpenID Connect

**Real-Time Communication:**
- **SignalR**
  - WebSockets
  - Server-sent events
  - Long polling fallback
  - Used for: Chat, notifications, live updates

**Background Jobs:**
- **Hangfire**
  - Recurring jobs
  - Fire-and-forget jobs
  - Delayed jobs
  - Job dashboard

**Logging & Observability:**
- **Serilog**
  - Structured logging
  - Multiple sinks (Console, File, Application Insights)
  - Log levels and filtering
- **OpenTelemetry** (planned)
  - Distributed tracing
  - Metrics collection
- **Application Insights** (Azure)
  - APM (Application Performance Monitoring)
  - Log analytics

**Resilience & Fault Tolerance:**
- **Polly**
  - Retry policies
  - Circuit breaker
  - Timeout policies
  - Bulkhead isolation
  - Used extensively in Hazina

**Serialization:**
- **System.Text.Json** (primary)
  - High performance
  - Native .NET
- **Newtonsoft.Json** (fallback)
  - Backward compatibility
  - Complex scenarios

**HTTP Clients:**
- **HttpClient**
  - HTTP communications
  - Polly integration
- **Refit** (some providers)
  - Type-safe REST clients

---

## FRONTEND TECHNOLOGIES

### JavaScript/TypeScript Ecosystem

**Runtime & Build Tools:**
- **Node.js 18+** - JavaScript runtime
- **npm 9+** - Package manager
- **Vite 5.4** - Build tool & dev server
  - Ultra-fast HMR (Hot Module Replacement)
  - ES modules native
  - Optimized builds
  - Plugin ecosystem

**Framework:**
- **React 18.3**
  - Concurrent features
  - Automatic batching
  - Suspense
  - Server components (future)

**Language:**
- **TypeScript 5.5**
  - Static typing
  - Type inference
  - Generics
  - Decorators (experimental)

**Routing:**
- **React Router 6**
  - Client-side routing
  - Nested routes
  - Lazy loading
  - Data loading

**State Management:**
- **Zustand 5.0**
  - Lightweight state management
  - Simple API
  - TypeScript-first
  - Middleware support
- **TanStack Query (React Query) 5**
  - Server state caching
  - Automatic refetching
  - Optimistic updates
  - Devtools
- **Context API**
  - Theme context
  - Auth context
  - i18n context

**UI Framework & Styling:**
- **Tailwind CSS 3.4**
  - Utility-first CSS
  - JIT (Just-In-Time) compiler
  - Custom design system
- **PostCSS**
  - CSS transformations
  - Autoprefixer
- **Radix UI**
  - Accessible components (unstyled)
  - WAI-ARIA compliant
  - Keyboard navigation
- **shadcn/ui**
  - Pre-built Radix + Tailwind components
  - Copy-paste, not npm install
  - Customizable
- **Lucide React**
  - Icon library (427+ icons)
  - Tree-shakeable
  - Consistent design

**Rich Text Editor:**
- **TipTap 2.1**
  - Headless editor
  - Extensible
  - Markdown support
  - Extensions:
    - Image upload
    - Link handling
    - Tables
    - Underline, bold, italic

**Drag & Drop:**
- **@dnd-kit**
  - Modern drag and drop
  - Accessibility-first
  - Sortable lists
  - Virtual scrolling compatible

**Form Management:**
- **Zod 4.3**
  - Schema validation
  - TypeScript inference
  - Parse, don't validate

**Calendar & Scheduling:**
- **React Big Calendar 1.19**
  - Month/week/day/agenda views
  - Drag and drop
  - Localization

**Internationalization:**
- **i18next 25.6**
  - Translation framework
  - Interpolation
  - Pluralization
- **react-i18next 16.3**
  - React bindings
  - Hooks
  - Suspense support

**Real-Time:**
- **@microsoft/signalr 9.0**
  - SignalR client
  - WebSockets
  - Reconnection logic

**HTTP Client:**
- **Axios 1.13**
  - Promise-based HTTP client
  - Request/response interceptors
  - Automatic transforms

**Notifications:**
- **Sonner 1.5**
  - Toast notifications
  - Accessible
  - Customizable

**Theme:**
- **next-themes 0.3**
  - Dark mode support
  - System preference detection
  - No flash on load

**Utilities:**
- **date-fns 4.1**
  - Date manipulation
  - Localization
  - Tree-shakeable
- **clsx / tailwind-merge**
  - Conditional class names
  - Tailwind class merging
- **class-variance-authority**
  - Component variants

---

## AI & LLM TECHNOLOGIES

### LLM Providers

**Cloud Providers:**
1. **OpenAI**
   - SDK: Official OpenAI SDK for .NET
   - Models: GPT-4, GPT-3.5, GPT-4-Turbo, GPT-4o
   - Embeddings: text-embedding-ada-002, text-embedding-3-small/large
   - Images: DALL-E 3

2. **Anthropic**
   - SDK: Official Anthropic SDK for .NET
   - Models: Claude 3 Opus, Sonnet, Haiku
   - Features: 200K context window, tool use

3. **Google Gemini**
   - SDK: Google.GenerativeAI
   - Models: Gemini Pro, Gemini Ultra

4. **Mistral AI**
   - SDK: MistralAI SDK
   - Models: Mistral Large, Medium, Small

5. **HuggingFace**
   - SDK: Custom HTTP client
   - Models: Any HF Inference API model

**Local/Self-Hosted:**
6. **Ollama**
   - Run models locally (Llama 3, Mistral, etc.)
   - OpenAI-compatible API

7. **LM Studio**
   - Local model server
   - GUI for model management

**Frameworks:**
8. **Semantic Kernel**
   - Microsoft's AI framework
   - Plugin system
   - Hazina integration

### Hazina AI Framework

**Core Packages:**
- `Hazina.AI.FluentAPI` - Developer API
- `Hazina.AI.Providers` - Multi-provider orchestration
- `Hazina.AI.RAG` - RAG engine
- `Hazina.AI.Agents` - Agentic workflows
- `Hazina.AI.FaultDetection` - Hallucination detection

**LLM Clients:**
- `Hazina.LLMs.OpenAI`
- `Hazina.LLMs.Anthropic`
- `Hazina.LLMs.Gemini`
- `Hazina.LLMs.Mistral`
- `Hazina.LLMs.HuggingFace`
- `Hazina.LLMs.SemanticKernel`
- `Hazina.LLMs.Client` - Unified client
- `Hazina.LLMs.Helpers` - Utilities

**Reasoning:**
- `Hazina.Neurochain.Core` - Multi-layer reasoning
- `Hazina.Neurochain.Layers` - Reasoning layers
- `Hazina.Neurochain.Consensus` - Consensus algorithms

**Storage:**
- `Hazina.Store.EmbeddingStore` - Vector storage
- `Hazina.Store.DocumentStore` - Document storage

**Production:**
- `Hazina.Production.Monitoring` - Health checks, metrics
- `Hazina.Production.CostTracking` - Cost tracking
- `Hazina.Production.HealthChecks` - Health checks

**Observability:**
- `Hazina.Observability.Logging` - Structured logging
- `Hazina.Observability.Metrics` - Metrics
- `Hazina.Observability.Tracing` - Distributed tracing
- `Hazina.Observability.LLMLogs` - LLM call logging

---

## DATABASES & STORAGE

### Relational Databases

**SQLite**
- **Version:** Latest (via Microsoft.Data.Sqlite)
- **Use Cases:**
  - Development database
  - Embedded storage
  - Configuration storage
  - LLM logs
- **Features:**
  - Zero-configuration
  - Serverless
  - Single file
  - ACID compliant
- **Extensions:**
  - Full-text search (FTS5)
  - JSON support

**PostgreSQL**
- **Version:** 15+ (production)
- **Use Cases:**
  - Production database
  - Multi-tenant data
  - Vector storage (pgvector)
- **Extensions:**
  - **pgvector** - Vector similarity search
  - **pg_trgm** - Trigram similarity search
  - **Full-text search** - GIN indexes
- **Cloud Providers:**
  - Azure Database for PostgreSQL
  - Supabase (managed PostgreSQL)
  - AWS RDS

### Vector Databases

**pgvector (PostgreSQL extension)**
- Vector similarity search in PostgreSQL
- Up to 100M+ vectors
- HNSW index for fast search
- Cosine similarity, Euclidean distance, dot product

**Supabase Vector**
- Managed PostgreSQL with pgvector
- Built-in auth
- Real-time subscriptions
- RESTful API

**In-Memory (Development)**
- Fast, no setup
- Limited to RAM
- Not persistent
- Used in Hazina for dev/test

### File Storage

**Local File System**
- Configuration files
- Uploaded documents
- Generated images
- Logs

**Azure Blob Storage** (planned)
- Cloud file storage
- CDN integration
- Backup & archive

---

## DEVOPS & INFRASTRUCTURE

### Version Control

**Git**
- Distributed version control
- GitHub hosting
- Branching strategies:
  - `main` - Production
  - `develop` - Integration
  - `agent-XXX-feature` - Feature branches (in worktrees)

**Git Worktrees**
- Parallel development
- Isolated working directories
- Managed via `C:\scripts\_machine\worktrees.*` files

**GitHub**
- Repository hosting
- Pull requests
- GitHub Actions (CI/CD)
- Issue tracking

### Containerization

**Docker** (Hazina)
- Dockerfile for Hazina framework
- Multi-stage builds
- Production-ready images

**Docker Compose**
- Multi-container orchestration
- Development environments

### Cloud Platforms

**Azure** (primary target)
- Azure App Service
- Azure Functions
- Azure SQL Database / PostgreSQL
- Azure Blob Storage
- Application Insights
- Azure Key Vault

**Supabase** (alternative)
- PostgreSQL hosting
- Vector search
- Auth & storage
- Edge functions

### CI/CD

**GitHub Actions** (planned)
- Automated builds
- Test execution
- NuGet package publishing
- Deployment pipelines

**Manual Deployment** (current)
- PowerShell scripts
- `publish-all.ps1`, `pack-all.ps1`

---

## TESTING & QUALITY

### Backend Testing

**xUnit**
- Unit testing framework
- Theories and inline data
- Test collections

**Moq**
- Mocking library
- Mock interfaces and classes
- Verify method calls

**Testcontainers** (Hazina)
- Integration testing with containers
- PostgreSQL, Redis containers
- Cleanup after tests

### Frontend Testing

**Vitest**
- Fast unit test runner
- Vite-native (no bundler overhead)
- Jest-compatible API

**@testing-library/react**
- Component testing
- User-centric queries
- Accessibility testing

**@testing-library/user-event**
- Simulate user interactions
- Realistic event firing

**@vitest/ui**
- Test UI dashboard
- Coverage reports

**Storybook 8**
- Component documentation
- Isolated component development
- Visual testing
- Addons:
  - Accessibility (a11y)
  - Interactions
  - Essentials

### Code Quality

**ESLint 9** (frontend)
- JavaScript/TypeScript linting
- Custom rules
- Auto-fixing

**dotnet format** (backend)
- C# code formatting
- EditorConfig support
- Automated via `cs-format.ps1`

**cs-autofix** (backend)
- Custom Roslyn analyzer
- Remove unused usings
- Fix simple compile errors
- Automated via `cs-autofix.dll`

**TypeScript Compiler**
- Type checking
- Strict mode
- No implicit any

---

## TOOLS & UTILITIES

### Development Tools

**Visual Studio 2022**
- Primary .NET IDE
- Debugger
- NuGet package manager
- Agentic Debugger Bridge integration

**VS Code / Cursor**
- Alternative editor
- Extensions for .NET, React, TypeScript

**JetBrains Rider** (alternative)
- Cross-platform .NET IDE
- Better performance on large solutions

**Chrome DevTools**
- Browser debugging
- Network inspection
- Performance profiling
- MCP server integration

### Command-Line Tools

**PowerShell 7+**
- Automation scripts
- Build scripts
- Azure CLI integration

**Bash (Git Bash)**
- Unix-like environment on Windows
- Git operations
- File operations

**.NET CLI**
- `dotnet build`, `dotnet run`, `dotnet test`
- `dotnet ef` - Entity Framework migrations
- `dotnet publish` - Deployment

**npm / npx**
- Node package manager
- Script runner
- Package execution

**gh (GitHub CLI)**
- GitHub operations from CLI
- Create PRs: `gh pr create`
- View issues: `gh issue list`

**Stripe CLI**
- Payment testing
- Webhook forwarding
- Event triggering

**WP-CLI** (planned fix)
- WordPress management
- Plugin/theme operations
- Database operations

### Automation Tools

**cs-format.ps1**
- C# code formatting wrapper
- Solution/project detection
- 150 lines PowerShell

**cs-autofix.dll**
- Roslyn-based auto-fixer
- Removes unused usings
- 238 lines C#

**BFG Repo-Cleaner**
- Remove sensitive data from Git history
- Faster than git filter-branch

**Playwright**
- Browser automation
- E2E testing
- Cross-browser support

---

## VERSION MATRIX

### .NET Ecosystem

| Package | Version | Notes |
|---------|---------|-------|
| .NET Runtime | 9.0 | Primary target |
| .NET Runtime | 8.0 | Supported |
| C# | 13 | Latest |
| ASP.NET Core | 9.0 | Web framework |
| Entity Framework Core | 9.0 | ORM |
| Serilog | 3.x | Logging |
| Polly | 8.x | Resilience |
| Hangfire | 1.8 | Background jobs |
| xUnit | 2.x | Testing |
| Moq | 4.x | Mocking |

### Frontend Ecosystem

| Package | Version | Notes |
|---------|---------|-------|
| React | 18.3 | UI framework |
| TypeScript | 5.5 | Language |
| Vite | 5.4 | Build tool |
| React Router | 6 | Routing |
| Zustand | 5.0 | State management |
| TanStack Query | 5 | Server state |
| Tailwind CSS | 3.4 | Styling |
| Radix UI | Latest | Components |
| TipTap | 2.1 | Rich text editor |
| Vitest | 1.x | Testing |
| Storybook | 8.0 | Component docs |

### AI & LLM Ecosystem

| Package | Version | Notes |
|---------|---------|-------|
| Hazina.* | 1.0.16 | (DevGPT legacy) |
| OpenAI SDK | Latest | Official SDK |
| Anthropic SDK | Latest | Official SDK |
| Google.GenerativeAI | Latest | Gemini SDK |
| MistralAI SDK | Latest | Official SDK |

### Databases

| Database | Version | Notes |
|----------|---------|-------|
| SQLite | Latest | Embedded |
| PostgreSQL | 15+ | Production |
| pgvector | 0.5+ | Vector extension |

### Tools

| Tool | Version | Notes |
|------|---------|-------|
| Node.js | 18+ | JavaScript runtime |
| npm | 9+ | Package manager |
| Git | 2.40+ | Version control |
| PowerShell | 7+ | Automation |
| GitHub CLI | 2.x | GitHub operations |
| Stripe CLI | Latest | Payment testing |

---

## BROWSER COMPATIBILITY

### Client Manager Frontend

**Supported Browsers:**
- **Chrome/Edge** 90+ (recommended)
- **Firefox** 88+
- **Safari** 14+

**Required Features:**
- ES2020+
- WebSockets (SignalR)
- LocalStorage
- Fetch API
- CSS Grid & Flexbox

---

## RELATED DOCUMENTATION

- [PROJECTS_INDEX.md](./PROJECTS_INDEX.md) - Project overview
- [CLIENT_MANAGER_DEEP_DIVE.md](./CLIENT_MANAGER_DEEP_DIVE.md) - Client Manager stack details
- [HAZINA_DEEP_DIVE.md](./HAZINA_DEEP_DIVE.md) - Hazina framework stack details
- [SCRIPTS_INDEX.md](./SCRIPTS_INDEX.md) - Scripts & tools
- [STORES_INDEX.md](./STORES_INDEX.md) - Data stores

---

**Last Updated:** 2026-01-08
**Document Version:** 1.0
**Maintained by:** Claude Agent System
**Primary Stack:** .NET 9.0 + React 18 + Hazina AI Framework
