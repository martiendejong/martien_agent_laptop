# client-manager / brand2boost

**Last Updated:** 2026-02-01

## Overview

**Type:** Promotion and brand development SaaS software
**Status:** Active development
**Stack:** .NET + React + TypeScript

## Locations

- **Frontend + API:** `C:\Projects\client-manager\`
- **Hazina Framework:** `C:\Projects\hazina\`
- **Store Config + Data:** `C:\stores\brand2boost\`

## Architecture

### Backend (ClientManagerAPI)
- **Framework:** ASP.NET Core Web API
- **Language:** C# .NET 9
- **Database:** SQLite (dev), PostgreSQL (production)
- **ORM:** Entity Framework Core
- **Authentication:** ASP.NET Core Identity
- **Background Jobs:** Hangfire
- **AI Integration:** Hazina framework

### Frontend (ClientManagerFrontend)
- **Framework:** React 18
- **Language:** TypeScript
- **Build Tool:** Vite
- **Styling:** TailwindCSS
- **State Management:** React Query, Context API
- **Routing:** React Router v6

### Database Contexts
- **IdentityDbContext:** User authentication, roles, claims
- **ApplicationDbContext:** Business logic, clients, projects, campaigns
- **HangfireDbContext:** Background job scheduling

## Admin Access

- **Username:** `wreckingball`
- **Password:** `Th1s1sSp4rt4!`

## Development Workflow

### NEVER Run from Command Line
**Important:** User runs frontend and backend directly from:
- Visual Studio (backend)
- npm scripts (frontend)

DO NOT attempt to start services via CLI.

### Feature Development
1. Allocate paired worktrees (client-manager + Hazina)
2. Work in `C:\Projects\worker-agents\agent-XXX\`
3. Create PR
4. Release worktrees immediately

### Active Debugging
1. Work directly in `C:\Projects\client-manager\`
2. Use user's current branch
3. NO worktree allocation

## CI/CD

### GitHub Actions Workflows
- **Frontend Build:** `.github/workflows/frontend-build.yml`
- **Backend Build:** `.github/workflows/backend-build.yml`
- **Docker Build:** `.github/workflows/docker-build.yml`
- **Deploy Production:** `.github/workflows/deploy-production.yml`

### Common CI Issues
- **EnableWindowsTargeting:** Required for System.Drawing on Linux runners
- **Missing appsettings.json:** Must exist even if empty
- **Migration conflicts:** Always run `dotnet ef migrations has-pending-model-changes`

## Cross-Repo Dependencies

### Hazina → client-manager Flow
1. PR in Hazina (framework changes)
2. Merge Hazina PR first
3. Update Hazina package in client-manager
4. PR in client-manager (uses updated framework)

**CRITICAL:** Track dependencies in `C:\scripts\_machine\pr-dependencies.md`

## Key Files

### Configuration
- `appsettings.json` - Base configuration
- `appsettings.Development.json` - Dev overrides
- `appsettings.Secrets.json` - API keys, secrets (gitignored)

### Database Migrations
- `ClientManagerAPI/Data/Migrations/` - EF Core migrations
- Always verify with `ef-preflight-check.ps1` before committing

### Frontend Services
- `ClientManagerFrontend/src/services/` - API clients, embeddings, auth

## Common Operations

### Add Migration
```bash
cd C:\Projects\client-manager\ClientManagerAPI
dotnet ef migrations add MigrationName --context ApplicationDbContext
dotnet ef database update --context ApplicationDbContext
```

### Check Pending Changes
```bash
dotnet ef migrations has-pending-model-changes --context ApplicationDbContext
# Exit 0 = OK, Exit 1 = Missing migration
```

### Build
```bash
dotnet build ClientManagerAPI.sln
npm run build --prefix ClientManagerFrontend
```

## ClickUp Integration

**Project ID:** Check `clickup-sync.ps1` configuration
**Task-First Workflow:** Always search ClickUp before starting work

## Known Issues & Solutions

### PendingModelChangesWarning
- **Cause:** Code changed but migration not created
- **Solution:** Run `dotnet ef migrations add <Name> --context <Context>`

### Frontend Build Failures
- **Missing package-lock.json:** Restore from git history
- **Node version mismatch:** Check `.nvmrc` or CI config

### Docker Build Issues
- **EnableWindowsTargeting:** Add to .csproj for System.Drawing
- **Missing migrations:** Ensure migrations run in startup

## Testing

### Integration Tests
- **Tool:** `WebApplicationFactory`
- **Validation:** `webappfactory-validator.ps1`
- **Pattern:** In-memory database, isolated test context

### E2E Tests
- **Tool:** Playwright
- **Runner:** `run-e2e-tests.ps1`

## Deployment

### Production
- **Platform:** Azure Web Apps
- **Database:** Azure Database for PostgreSQL
- **Container Registry:** GitHub Container Registry (ghcr.io)
- **Deployment:** Automated via GitHub Actions

### Environment Variables
- Managed in Azure Portal
- Secrets stored in GitHub Secrets
- Local development uses `appsettings.Secrets.json`
