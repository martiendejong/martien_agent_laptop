# ✅ Pre-Commit Checklist - Quick Reference

**Print this or keep it visible while coding!**

---

## 🚀 **Before EVERY Commit** (3 minutes)

```powershell
C:\scripts\tools\local-ci\pre-commit-check.ps1
```

**Manual quick check:**
- [ ] **Build passes**: `dotnet build --configuration Release`
- [ ] **Tests pass**: `dotnet test --no-build`
- [ ] **Formatting OK**: `dotnet format --verify-no-changes`
- [ ] **No secrets**: Check appsettings, .env files
- [ ] **Git status clean**: Only intended files staged

---

## 🎯 **Before Creating PR** (15 minutes)

```powershell
C:\scripts\tools\local-ci\full-pre-pr-check.ps1
```

**Manual comprehensive check:**
- [ ] All Tier 1 checks pass ✅
- [ ] **Integration tests pass**: `dotnet test --filter Integration`
- [ ] **Frontend builds**: `npm run build` (if applicable)
- [ ] **Migration validated**: `validate-migration.ps1` (if changed)
- [ ] **Coverage >80%**: `dotnet test --collect:"XPlat Code Coverage"`
- [ ] **Docker builds**: (if infrastructure changed)
- [ ] **No TODO without task ID**
- [ ] **No console.log/Console.WriteLine left**

---

## 🔧 **Change-Specific Checks**

### Backend (C# API/Services)
- [ ] Build: `dotnet build --configuration Release`
- [ ] Unit tests: `dotnet test --filter "FullyQualifiedName!~Integration"`
- [ ] Integration tests: `dotnet test --filter "FullyQualifiedName~Integration"`
- [ ] New migration? → `validate-migration.ps1`
- [ ] Security-related? → `dotnet test --filter "Category=Security"`

### Frontend (React/TypeScript)
```powershell
cd ClientManagerFrontend
npm run lint          # ESLint
npm run type-check    # TypeScript
npm test -- --run     # Vitest
npm run build         # Production build
```

### Database Migration
```powershell
# Generate
dotnet ef migrations add MigrationName --context IdentityDbContext

# Review manually
# Check Up() and Down() methods

# Validate
C:\scripts\tools\validate-migration.ps1 -Context IdentityDbContext

# Test apply
dotnet ef database update

# Test rollback
dotnet ef database update PreviousMigration

# Re-apply
dotnet ef database update
```

### Docker/Infrastructure
```powershell
# Build image
docker build -t app:local .

# Run & test
docker run -d -p 5000:80 app:local
curl http://localhost:5000/health
docker logs <container>

# Security scan
C:\scripts\tools\local-ci\local-security-scan.ps1 -Image app:local

# Cleanup
docker stop <container> && docker rm <container>
```

---

## 🚨 **RED FLAGS - Do NOT Commit**

- ❌ Build errors
- ❌ Failing tests (fix or document why skipped)
- ❌ Secrets in code (API keys, passwords, tokens)
- ❌ Migration without validation
- ❌ Coverage dropped below 80%
- ❌ TypeScript errors
- ❌ ESLint errors
- ❌ Debug code left behind (`console.log`, `Console.WriteLine`, `debugger`)
- ❌ Commented-out code blocks (remove or document)
- ❌ Merge conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)

---

## 📊 **What Success Looks Like**

### ✅ Successful Build
```
Build succeeded.
    0 Warning(s)
    0 Error(s)
```

### ✅ Successful Tests
```
Passed!  - Failed: 0, Passed: 145, Skipped: 0
```

### ✅ Successful Format Check
```
No files need formatting.
```

### ✅ Successful Migration
```
Build started...
Build succeeded.
Done.
```

---

## ⚡ **Quick Commands by Scenario**

### Quick Bug Fix (5 min)
```powershell
dotnet build --configuration Release
dotnet test --filter "YourServiceTests"
dotnet format --verify-no-changes
git add . && git commit -m "fix: description"
```

### New Feature (15 min)
```powershell
C:\scripts\tools\local-ci\pre-commit-check.ps1 -Comprehensive
git add . && git commit -m "feat: description"
```

### Database Migration (10 min)
```powershell
dotnet ef migrations add MigrationName
C:\scripts\tools\validate-migration.ps1 -Context IdentityDbContext
dotnet build --configuration Release
git add . && git commit -m "db: migration description"
```

### Docker Change (20 min)
```powershell
C:\scripts\tools\local-ci\local-docker-build.ps1 -SecurityScan
git add . && git commit -m "infra: docker changes"
```

---

## 🎓 **Remember**

1. **Local tests = Production quality gate**
2. **GitHub Actions are manual-only now**
3. **YOU are responsible for code quality**
4. **Test what you change**
5. **Don't assume it works - verify!**

---

## 📞 **Need Help?**

```powershell
# Diagnose build errors
C:\scripts\tools\diagnose-error.ps1 -ErrorMessage "error"

# Check past solutions
grep -r "similar error" C:\scripts\_machine\reflection.log.md

# Auto-fix formatting
dotnet format
```

---

**Last Updated**: 2026-01-30
**Keep this visible** and reference it before every commit!
