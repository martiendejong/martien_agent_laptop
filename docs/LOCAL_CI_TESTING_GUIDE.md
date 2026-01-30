# 🧪 Local CI Testing Guide - MANDATORY Pre-Commit Checklist

**CRITICAL:** Since GitHub Actions are now manual-only, YOU MUST test locally before committing.

This guide provides comprehensive testing instructions for all change types.

---

## 🚀 **Quick Start - Universal Pre-Commit Command**

```powershell
# Run this BEFORE every commit - covers 90% of cases
C:\scripts\tools\local-ci\pre-commit-check.ps1
```

This will automatically:
- ✅ Build your changes
- ✅ Run affected tests
- ✅ Check code formatting
- ✅ Scan for secrets
- ✅ Validate migrations (if applicable)
- ✅ Check for merge conflicts
- ✅ Verify no debug code left behind

**If this passes, you're 90% good to commit.**

---

## 📋 **Complete Pre-Commit Checklist**

### ✅ **TIER 1: MANDATORY (Every Commit)**

| Check | Command | Expected Result | Time |
|-------|---------|-----------------|------|
| **1. Build Solution** | `dotnet build --configuration Release` | `Build succeeded. 0 Error(s)` | ~30s |
| **2. Run Unit Tests** | `dotnet test --no-build --filter "FullyQualifiedName!~Integration"` | `Passed! - All tests green` | ~1-2min |
| **3. Code Formatting** | `dotnet format --verify-no-changes` | `No files need formatting` | ~10s |
| **4. Secret Scan** | `C:\scripts\tools\scan-secrets.ps1 -Path .` | `✅ No secrets found` | ~5s |
| **5. Git Status Clean** | `git status` | Only intended changes staged | ~1s |

**Total Time: ~2-3 minutes**

---

### ⚠️ **TIER 2: CHANGE-SPECIFIC (Based on What You Modified)**

#### 🔧 **Backend Code (C# API/Services)**

| Change Type | Additional Tests Required | Command |
|-------------|---------------------------|---------|
| **New API Endpoint** | Integration tests, Swagger generation | `dotnet test --filter "FullyQualifiedName~Integration"` |
| **Database Migration** | Migration validation, rollback test | `C:\scripts\tools\validate-migration.ps1` |
| **New Service/Repository** | Test coverage >80%, dependency injection check | `dotnet test --collect:"XPlat Code Coverage"` |
| **Authentication/Authorization** | Security tests, JWT validation | `dotnet test --filter "Category=Security"` |
| **LLM Integration** | Mock LLM tests, token counting | `dotnet test --filter "FullyQualifiedName~Llm"` |
| **External API Integration** | Mock tests, error handling | `dotnet test --filter "FullyQualifiedName~Integration"` |

**Commands:**
```powershell
# Backend comprehensive check
C:\scripts\tools\local-ci\local-build-backend.ps1 -RunIntegrationTests

# Specific migration check
C:\scripts\tools\validate-migration.ps1 -Context IdentityDbContext

# Coverage check (must be >80%)
dotnet test --collect:"XPlat Code Coverage"
# Check coverage report in TestResults/*/coverage.cobertura.xml
```

---

#### 🎨 **Frontend Code (React/TypeScript)**

| Change Type | Additional Tests Required | Command |
|-------------|---------------------------|---------|
| **New Component** | Component tests, accessibility, storybook | `npm test -- ComponentName` |
| **New Page/Route** | E2E test, route validation | `npm run test:e2e` |
| **State Management** | Redux/Context tests, state persistence | `npm test -- store` |
| **API Integration** | Mock API tests, error boundaries | `npm test -- api` |
| **Form/Validation** | Validation tests, error messages | `npm test -- form` |
| **UI Styling** | Visual regression, responsive test | `npm run test:visual` |

**Commands:**
```powershell
# Frontend comprehensive check
C:\scripts\tools\local-ci\local-build-frontend.ps1

# Specific component test
cd C:\Projects\client-manager\ClientManagerFrontend
npm test -- --coverage --testPathPattern=ComponentName

# Lint + Type check
npm run lint
npm run type-check

# Build production bundle (catch build errors)
npm run build
```

---

#### 🗄️ **Database Changes (Migrations)**

**CRITICAL - Migrations require extra validation:**

```powershell
# 1. Generate migration
dotnet ef migrations add MigrationName --context IdentityDbContext

# 2. Review generated migration file
# Check Up() and Down() methods manually

# 3. Validate migration (MANDATORY)
C:\scripts\tools\validate-migration.ps1 -Context IdentityDbContext

# 4. Test migration on local database
dotnet ef database update --context IdentityDbContext

# 5. Test rollback
dotnet ef database update PreviousMigration --context IdentityDbContext

# 6. Re-apply migration
dotnet ef database update --context IdentityDbContext

# 7. Verify application still runs
dotnet run --project ClientManagerAPI
```

**Migration Checklist:**
- [ ] Migration file reviewed manually
- [ ] No data loss in `Down()` method
- [ ] Breaking changes documented
- [ ] Migration applied successfully locally
- [ ] Rollback tested successfully
- [ ] Application runs after migration
- [ ] Seed data still works

---

#### 🐳 **Docker/Infrastructure Changes**

```powershell
# 1. Build Docker image
C:\scripts\tools\local-ci\local-docker-build.ps1 -Service backend

# 2. Run container
docker run -d -p 5000:80 --name test-backend client-manager-backend:local

# 3. Health check
curl http://localhost:5000/health

# 4. Check logs
docker logs test-backend

# 5. Stop and remove
docker stop test-backend && docker rm test-backend

# 6. Security scan (MANDATORY for Docker changes)
C:\scripts\tools\local-ci\local-security-scan.ps1 -Image client-manager-backend:local
```

---

#### 🔐 **Security-Sensitive Changes**

**Changes to:**
- Authentication/Authorization
- Secrets management
- API keys/tokens
- User permissions
- Data validation
- SQL queries (injection risk)

**MANDATORY Additional Checks:**
```powershell
# 1. Secret scan (double-check)
C:\scripts\tools\scan-secrets.ps1 -Path . -Recursive

# 2. Security-specific tests
dotnet test --filter "Category=Security"

# 3. SQL injection check (if applicable)
dotnet test --filter "FullyQualifiedName~SqlInjection"

# 4. OWASP top 10 check
C:\scripts\tools\local-ci\security-audit.ps1

# 5. Dependency vulnerability scan
dotnet list package --vulnerable --include-transitive
```

---

### 🚀 **TIER 3: COMPREHENSIVE (Before Creating PR)**

**Run the FULL local CI suite before creating a PR:**

```powershell
# Full comprehensive check (takes ~10-15 minutes)
C:\scripts\tools\local-ci\full-pre-pr-check.ps1

# Or run individually:
C:\scripts\tools\local-ci\local-build-hazina.ps1 -Full
C:\scripts\tools\local-ci\local-build-client-manager.ps1 -Full
C:\scripts\tools\local-ci\local-build-artrevisionist.ps1 -Full
```

**This includes:**
- ✅ Full build (Release configuration)
- ✅ All unit tests
- ✅ All integration tests
- ✅ Code coverage analysis (>80% required)
- ✅ Code formatting check
- ✅ Static code analysis
- ✅ Security vulnerability scan
- ✅ Docker build (if applicable)
- ✅ E2E tests (frontend)
- ✅ Migration validation
- ✅ Breaking change detection

---

## 🎯 **Testing by Change Type - Decision Tree**

```
Start Here
    |
    ├─ Backend Change? ──> Run: local-build-backend.ps1
    |   |
    |   ├─ New Migration? ──> Run: validate-migration.ps1
    |   ├─ New API Endpoint? ──> Run integration tests
    |   └─ Security-related? ──> Run security audit
    |
    ├─ Frontend Change? ──> Run: local-build-frontend.ps1
    |   |
    |   ├─ New Component? ──> Run component tests + storybook
    |   ├─ New Route? ──> Run E2E tests
    |   └─ API Integration? ──> Run mock API tests
    |
    ├─ Docker/Infra Change? ──> Run: local-docker-build.ps1
    |
    ├─ Hazina Framework? ──> Run: local-build-hazina.ps1
    |
    └─ Documentation Only? ──> Quick check: build docs, check links
```

---

## ⚡ **Quick Commands by Scenario**

### **Scenario 1: "Quick Bug Fix in Backend"**
```powershell
# 5-minute check
dotnet build --configuration Release
dotnet test --filter "FullyQualifiedName~YourServiceTests"
dotnet format --verify-no-changes
git add . && git commit -m "fix: your fix description"
```

### **Scenario 2: "New Feature (Backend + Frontend)"**
```powershell
# 15-minute comprehensive check
C:\scripts\tools\local-ci\pre-commit-check.ps1 -Comprehensive

# OR manually:
# Backend
cd C:\Projects\client-manager\ClientManagerAPI
dotnet build --configuration Release
dotnet test --collect:"XPlat Code Coverage"

# Frontend
cd C:\Projects\client-manager\ClientManagerFrontend
npm run lint
npm run type-check
npm test -- --coverage
npm run build

# If all pass:
git add . && git commit -m "feat: your feature description"
```

### **Scenario 3: "Database Migration"**
```powershell
# 10-minute migration check
C:\scripts\tools\validate-migration.ps1 -Context IdentityDbContext -TestRollback
dotnet build --configuration Release
dotnet test --filter "FullyQualifiedName~Migration"
git add . && git commit -m "db: migration description"
```

### **Scenario 4: "Hazina Framework Change"**
```powershell
# 15-minute framework check
cd C:\Projects\hazina
dotnet build Hazina.sln --configuration Release
dotnet test Hazina.sln --no-build

# Test downstream projects
cd C:\Projects\client-manager
dotnet restore  # Uses local Hazina reference
dotnet build --configuration Release

git add . && git commit -m "feat(hazina): your change"
```

### **Scenario 5: "Docker/Deployment Change"**
```powershell
# 20-minute Docker check
C:\scripts\tools\local-ci\local-docker-build.ps1 -Service all -SecurityScan
docker-compose up -d
curl http://localhost:5000/health
curl http://localhost:3000
docker-compose down
git add . && git commit -m "infra: docker changes"
```

---

## 🔍 **Common Issues & Solutions**

### ❌ **Build Fails with "Pending Model Changes"**
```powershell
# You forgot to create a migration
dotnet ef migrations add YourMigrationName --context IdentityDbContext
dotnet ef database update
dotnet build
```

### ❌ **Tests Fail with "Connection String Error"**
```powershell
# Update appsettings.Development.json with correct connection string
# OR use in-memory database for tests (check test configuration)
```

### ❌ **Code Formatting Check Fails**
```powershell
# Auto-fix formatting issues
dotnet format
git add .
```

### ❌ **Frontend Build Fails with "Type Errors"**
```powershell
# Check TypeScript errors
npm run type-check
# Fix errors, then:
npm run build
```

### ❌ **Docker Build Fails**
```powershell
# Check Docker logs
docker logs <container-id>

# Common fix: Clean Docker cache
docker system prune -a
docker build --no-cache -t image-name .
```

---

## 📊 **Expected Output - What "Success" Looks Like**

### ✅ **Successful Build**
```
Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:30.123
```

### ✅ **Successful Tests**
```
Passed!  - Failed:     0, Passed:   145, Skipped:     0, Total:   145, Duration: 1.2s
```

### ✅ **Successful Formatting Check**
```
  No files need formatting.
```

### ✅ **Successful Security Scan**
```
✅ No secrets found in repository
✅ No vulnerable dependencies detected
```

### ✅ **Successful Migration**
```
Build started...
Build succeeded.
Done.

Migration '20260130_YourMigration' applied successfully.
```

---

## 🚨 **RED FLAGS - Do NOT Commit If You See:**

- ❌ Any build errors
- ❌ Any failing tests (even if unrelated - fix them!)
- ❌ Code formatting violations
- ❌ Secrets detected in code
- ❌ Migration validation failures
- ❌ Coverage dropped below 80%
- ❌ Docker security scan shows CRITICAL/HIGH vulnerabilities
- ❌ Console.WriteLine, console.log, or debugger statements left in code
- ❌ Commented-out code blocks (remove or document why)
- ❌ TODO comments without ClickUp task ID

---

## 🎓 **Advanced - Custom Test Scenarios**

### **Testing LLM Integrations Locally**
```powershell
# Use mock LLM provider (no API calls)
$env:USE_MOCK_LLM = "true"
dotnet test --filter "FullyQualifiedName~Llm"

# OR test with real API (costs money!)
$env:OPENAI_API_KEY = "your-key"
dotnet test --filter "FullyQualifiedName~LlmIntegration"
```

### **Testing with Different Database Providers**
```powershell
# SQLite (fast, in-memory)
$env:DATABASE_PROVIDER = "SQLite"
dotnet test

# PostgreSQL (production-like)
$env:DATABASE_PROVIDER = "PostgreSQL"
$env:CONNECTION_STRING = "Host=localhost;Database=test;..."
dotnet test --filter "FullyQualifiedName~Integration"
```

### **Testing Performance/Load**
```powershell
# Run performance tests
dotnet test --filter "Category=Performance"

# Load test API
C:\scripts\tools\test-api-load.ps1 -BaseUrl https://localhost:5001 -Concurrency 50
```

---

## 📈 **Coverage Requirements**

**Minimum coverage by component:**

| Component | Minimum Coverage | Command to Check |
|-----------|-----------------|------------------|
| Backend Services | 80% | `dotnet test --collect:"XPlat Code Coverage"` |
| Backend Controllers | 70% | Same |
| Frontend Components | 75% | `npm test -- --coverage` |
| Frontend Utils | 90% | Same |
| Integration Tests | 60% | `dotnet test --filter Integration` |

**How to view coverage:**
```powershell
# Backend
dotnet test --collect:"XPlat Code Coverage"
# Report in: TestResults/*/coverage.cobertura.xml
# Or generate HTML report:
reportgenerator -reports:**/coverage.cobertura.xml -targetdir:CoverageReport

# Frontend
cd ClientManagerFrontend
npm test -- --coverage
# Report in: coverage/lcov-report/index.html
```

---

## 🔄 **Continuous Improvement**

**After every failed commit:**
1. Document what you missed
2. Add to this checklist
3. Create automated check if possible
4. Update pre-commit hook

**Monthly review:**
- Check which issues occur most frequently
- Automate common failure points
- Update this guide with new patterns

---

## 📞 **Need Help?**

- **Build issues:** Check `_machine/reflection.log.md` for similar past issues
- **Migration issues:** See `_machine/migration-patterns.md`
- **Frontend issues:** Check `development-patterns.md`
- **Security issues:** See `ci-cd-troubleshooting.md`

**Or run:**
```powershell
C:\scripts\tools\diagnose-error.ps1 -ErrorMessage "your error"
```

---

## 📝 **Summary - The Golden Rules**

1. **ALWAYS run `pre-commit-check.ps1` before committing**
2. **NEVER commit with failing tests** (fix them or skip with reason)
3. **NEVER commit secrets** (use secret scan)
4. **ALWAYS validate migrations** before committing
5. **ALWAYS check coverage** for new code (>80%)
6. **ALWAYS test locally** what you changed (don't assume it works)
7. **ALWAYS run full suite** before creating PR
8. **NEVER push directly to main/develop** (use PRs)

---

**Remember:** GitHub Actions are now manual. **YOU are the CI/CD pipeline.**

**Your local tests = Production quality gate.**

**Make it count!** 🚀
