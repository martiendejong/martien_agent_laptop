# Projects & Applications - Index

**Location:** C:\scripts\_machine\knowledge-base\05-PROJECTS\
**Purpose:** Project-specific architecture, patterns, configurations, and business logic documentation
**Last Updated:** 2026-01-25

## Overview

This category contains deep technical documentation for specific projects under development. Each project has its own subdirectory with architecture docs, design patterns, component guides, and business logic explanations.

**Strategic Importance:** Project knowledge enables:
- Consistent architectural patterns across features
- Understanding of existing codebase structure
- Design pattern adherence
- Business logic comprehension
- Cross-project dependency management

---

## Project Structure

```
05-PROJECTS/
├── brand2boost/          # Marketing/brand materials (if needed)
├── client-manager/       # Primary SaaS application
│   └── architecture.md
└── hazina/               # Framework library
    └── framework-patterns.md
```

---

## Projects in This Category

### client-manager (brand2boost SaaS)
**Subdirectory:** `client-manager/`
**Repository:** github.com/martiendejong/brand2boost
**Location:** C:\Projects\client-manager\
**Type:** Full-stack SaaS application (ASP.NET Core + React)

#### Architecture Documentation
**File:** `client-manager/architecture.md`
**Purpose:** Complete architectural overview, component structure, design patterns, data flow
**Size:** 2,881 lines (~115 KB)
**Status:** ✅ Complete
**Key Topics:**
- **Backend Architecture:**
  - ASP.NET Core 8 Web API
  - Entity Framework Core (IdentityDbContext, AppDbContext)
  - Identity & Authentication (ASP.NET Core Identity)
  - Service layer patterns
  - Repository pattern (minimal, EF-based)
  - API endpoint organization
  - Dependency injection configuration

- **Frontend Architecture:**
  - React 18 + TypeScript
  - Vite build system
  - Component structure (pages, components, layouts)
  - State management (React Context, hooks)
  - API service layer pattern
  - Routing (React Router v6)
  - UI component library integration

- **Database Architecture:**
  - SQL Server / SQLite
  - EF Core migrations
  - Identity tables (AspNetUsers, AspNetRoles)
  - Application tables (domain-specific)
  - Relationship patterns

- **Key Patterns:**
  - UnifiedContent pattern (platform-agnostic multi-source integration)
  - Per-content-type import control
  - Service layer abstraction (frontend)
  - Controller → Service → DbContext flow (backend)
  - DTO patterns for API contracts

- **Configuration:**
  - appsettings.json / appsettings.Secrets.json
  - Environment-specific configuration
  - API key management (OpenAI, Claude, etc.)

- **Deployment:**
  - Production: C:\stores\brand2boost\
  - Frontend: Static files served by backend
  - Backend: Kestrel with Windows hosting

**Critical Architectural Rules:**
- ✅ Always use explicit `.ToTable("TableName")` for ALL entities
- ✅ Create migration when adding DbSet/entity
- ✅ Service layer for business logic (NOT in controllers)
- ✅ DTOs for API contracts (don't expose entities)
- ✅ appsettings.Secrets.json for API keys (gitignored)
- ❌ NEVER commit secrets or connection strings
- ❌ NEVER skip migrations for schema changes

---

### hazina (Framework Library)
**Subdirectory:** `hazina/`
**Repository:** github.com/martiendejong/Hazina
**Location:** C:\Projects\hazina\
**Type:** Reusable .NET library/framework

#### Framework Patterns Documentation
**File:** `hazina/framework-patterns.md`
**Purpose:** Reusable patterns, utilities, base classes provided by Hazina framework
**Size:** 1,332 lines (~53 KB)
**Status:** ✅ Complete
**Key Topics:**
- **Core Patterns:**
  - Base classes for common functionality
  - Generic repository patterns
  - Service abstractions
  - Utility classes
  - Extension methods

- **Integration with client-manager:**
  - How client-manager consumes Hazina
  - Dependency version management
  - Custom implementations vs framework defaults

- **Design Philosophy:**
  - Convention over configuration
  - Extensibility points
  - Framework vs application code boundaries

- **Common Utilities:**
  - Helper methods
  - Validation patterns
  - Data transformation utilities

**Critical Integration Rules:**
- ✅ client-manager PRs may depend on hazina PRs
- ✅ Merge hazina PRs FIRST, then client-manager
- ✅ Track dependencies in pr-dependencies.md
- ✅ Test hazina changes in client-manager before PR
- ❌ NEVER merge client-manager PR before dependent hazina PR

---

## Quick Reference

**Common Questions:**

| Question | Answer |
|----------|--------|
| What's the backend stack? | ASP.NET Core 8 + EF Core + SQL Server - See client-manager/architecture.md § Backend |
| What's the frontend stack? | React 18 + TypeScript + Vite - See client-manager/architecture.md § Frontend |
| Where are API keys stored? | appsettings.Secrets.json (gitignored) - See client-manager/architecture.md § Configuration |
| What's the service layer pattern? | Controller → Service → DbContext - See client-manager/architecture.md § Key Patterns |
| How does hazina integrate? | NuGet package dependency - See hazina/framework-patterns.md § Integration |
| What's the deployment location? | C:\stores\brand2boost\ - See client-manager/architecture.md § Deployment |

---

## Cross-References

**Related Categories:**
- **02-MACHINE** → Project file paths (file-system-map.md)
- **03-DEVELOPMENT** → Git repositories (git-repositories.md)
- **04-EXTERNAL-SYSTEMS** → GitHub integration, ClickUp tasks
- **06-WORKFLOWS** → Development workflows, EF migrations
- **07-AUTOMATION** → Project-specific tools

**Related Files:**
- `C:\Projects\client-manager\README.md` → Project-specific README
- `C:\Projects\hazina\README.md` → Framework documentation
- `C:\scripts\MACHINE_CONFIG.md` → Admin credentials (wreckingball/Th1s1sSp4rt4!)
- `C:\scripts\_machine\pr-dependencies.md` → Cross-repo PR tracking
- `C:\scripts\.claude\skills\ef-migration-safety\SKILL.md` → Database migration workflow

---

## Search Tips

**Tags in this category:** `#architecture`, `#design-patterns`, `#backend`, `#frontend`, `#database`, `#framework`, `#business-logic`, `#integration`

**Search examples:**
```bash
# Find architectural patterns
grep -r "pattern" C:\scripts\_machine\knowledge-base\05-PROJECTS\

# Find database schema info
grep -r "DbContext" C:\scripts\_machine\knowledge-base\05-PROJECTS\

# Find API endpoint patterns
grep -r "Controller" C:\scripts\_machine\knowledge-base\05-PROJECTS\

# Find frontend patterns
grep -r "React" C:\scripts\_machine\knowledge-base\05-PROJECTS\

# Find configuration info
grep -r "appsettings" C:\scripts\_machine\knowledge-base\05-PROJECTS\
```

---

## Maintenance

**Update triggers:**
- Major architectural changes (new layers, patterns)
- New framework patterns added (hazina updates)
- Database schema restructuring
- Frontend architecture changes (state management, routing)
- New integration patterns discovered
- Design pattern standardization
- Deployment configuration changes

**Review frequency:**
- **After architectural decisions** - Document immediately
- **After hazina updates** - Update framework-patterns.md
- **Monthly** - Review for consistency with actual codebase
- **After large refactorings** - Validate documentation accuracy

**Update protocol:**
1. Identify which project(s) affected
2. Update relevant architecture.md or framework-patterns.md
3. Document new patterns with examples
4. Add to "Key Patterns" section if reusable
5. Update cross-references if workflows affected
6. Create ADR if significant architectural decision
7. Commit to machine_agents repo

**Validation:**
```bash
# Verify project structure matches docs
ls C:\Projects\client-manager\ClientManagerAPI\
ls C:\Projects\client-manager\ClientManagerFrontend\

# Check for undocumented patterns (grep codebase)
# Then update architecture.md

# Verify hazina integration
dotnet list C:\Projects\client-manager\ClientManagerAPI\ClientManagerAPI.csproj package | grep -i hazina
```

---

## Success Metrics

**Project documentation is accurate ONLY IF:**
- ✅ Architecture docs match actual codebase structure
- ✅ New developers can understand system from docs
- ✅ Design patterns consistently applied
- ✅ All DbContext entities documented
- ✅ Service layer patterns clearly explained
- ✅ Frontend component structure matches docs
- ✅ Integration patterns (hazina) up to date
- ✅ Deployment configuration accurate

---

## Project-Specific Tools

**client-manager automation:**
```powershell
# Backend/frontend publishing
powershell -File "C:\scripts\publish-brand2boost-backend.ps1"
powershell -File "C:\scripts\publish-brand2boost-frontend.ps1"

# Database migrations
cd C:\Projects\client-manager\ClientManagerAPI
dotnet ef migrations add <Name> --context IdentityDbContext
dotnet ef database update

# Testing
dotnet test
npm test  # Frontend tests

# Build validation
dotnet build
npm run build
```

**hazina development:**
```powershell
# Build and test
cd C:\Projects\hazina
dotnet build
dotnet test

# Create NuGet package
dotnet pack -c Release

# Local testing in client-manager
# Update project reference temporarily, test, then restore to NuGet
```

---

## Development Guidelines

**When working on client-manager:**
1. ✅ Follow established architectural patterns
2. ✅ Use service layer for business logic
3. ✅ Create DTOs for API contracts
4. ✅ Add unit tests for new features
5. ✅ Create EF migration for schema changes
6. ✅ Update architecture.md for new patterns
7. ✅ Test frontend + backend integration
8. ✅ Follow Boy Scout Rule (leave code better)

**When working on hazina:**
1. ✅ Ensure backward compatibility (if possible)
2. ✅ Update framework-patterns.md
3. ✅ Test in client-manager before PR
4. ✅ Version bump appropriately (semver)
5. ✅ Document breaking changes prominently
6. ✅ Create NuGet package after merge
7. ✅ Update client-manager dependency

---

**Status:** Active - Living Documentation
**Owner:** Claude Agent (Self-maintaining)
**Quality:** HIGH - Reflects actual codebase structure
**Next Review:** After next architectural change
**Critical:** YES - Guides all feature development
