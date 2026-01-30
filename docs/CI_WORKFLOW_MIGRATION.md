# 🔄 CI/CD Workflow Migration - GitHub Actions to Local

**Date**: 2026-01-30
**Reason**: GitHub Actions billing - No subscription, compute minutes exhausted
**Impact**: All CI workflows now manual-only, must test locally before committing

---

## 📊 **Summary of Changes**

### **Problem**
GitHub Actions workflows were running automatically on every PR and push, consuming free tier compute minutes rapidly. Without a paid subscription, we hit billing limits causing all builds to fail.

### **Solution**
Migrate expensive CI operations to local development with comprehensive testing scripts. GitHub Actions workflows are now **manual-only** (`workflow_dispatch`), preserving free minutes for critical manual validation before merges.

---

## ✅ **What Changed**

### **Hazina Repository**

| Workflow | Before | After | Local Alternative |
|----------|--------|-------|-------------------|
| `build-and-test.yml` | Auto on push/PR | Manual only | `pre-commit-check.ps1` |
| `docker.yml` | Auto on push/PR | Manual only | `local-docker-build.ps1` |
| `codeql.yml` | Auto | Manual only | N/A (security-only) |
| `deploy-docs.yml` | Auto | Manual only | Build docs locally |

### **client-manager Repository**

| Workflow | Before | After | Local Alternative |
|----------|--------|-------|-------------------|
| `backend-build.yml` | ✅ Already manual | No change | `pre-commit-check.ps1` |
| `frontend-build.yml` | ✅ Already manual | No change | `pre-commit-check.ps1` |
| `docker-build.yml` | Auto on push/PR | Manual only | `local-docker-build.ps1` |
| `deploy-production.yml` | Auto on push/PR | Manual only | `full-pre-pr-check.ps1` |
| `backend-test.yml` | ✅ Already manual | No change | `dotnet test` |
| `frontend-test.yml` | ✅ Already manual | No change | `npm test` |

### **artrevisionist Repository**

| Workflow | Before | After | Local Alternative |
|----------|--------|-------|-------------------|
| `backend-build.yml` | Auto on push/PR | Manual only | `pre-commit-check.ps1` |
| `frontend-build.yml` | Auto on push/PR | Manual only | `pre-commit-check.ps1` |
| `deploy-production.yml` | Auto on push/PR | Manual only | `full-pre-pr-check.ps1` |

---

## 🛠️ **New Local CI Tools**

### **Created Scripts**

| Script | Purpose | Usage | Time |
|--------|---------|-------|------|
| **`pre-commit-check.ps1`** | Standard pre-commit validation | Before every commit | ~3 min |
| **`full-pre-pr-check.ps1`** | Comprehensive PR validation | Before creating PR | ~15 min |
| **`local-docker-build.ps1`** | Docker build & security scan | For Docker changes | ~10 min |
| **`local-security-scan.ps1`** | Trivy vulnerability scan | Security audit | ~5 min |

### **Created Documentation**

| Document | Purpose |
|----------|---------|
| **`LOCAL_CI_TESTING_GUIDE.md`** | Comprehensive testing instructions (35+ pages) |
| **`PRE_COMMIT_CHECKLIST.md`** | Quick reference card (printable) |
| **`CI_WORKFLOW_MIGRATION.md`** | This document |

---

## 📋 **New Developer Workflow**

### **Before (Automatic CI)**
```
1. Make changes
2. Commit & push
3. Wait for GitHub Actions
4. Fix if CI fails
5. Push again
```

**Problem**: Wastes compute minutes, slow feedback loop

### **After (Local CI)**
```
1. Make changes
2. Run: pre-commit-check.ps1
3. Fix any issues locally
4. Commit & push
5. (Optional) Manually trigger GitHub Actions if needed
```

**Benefits**: Fast feedback, no wasted minutes, higher quality commits

---

## 🚀 **How to Use - Quick Start**

### **Every Commit (Mandatory)**
```powershell
# From any repo directory
C:\scripts\tools\local-ci\pre-commit-check.ps1

# If passes:
git add .
git commit -m "your message"
git push
```

### **Before Creating PR (Mandatory)**
```powershell
# Comprehensive check
C:\scripts\tools\local-ci\full-pre-pr-check.ps1

# If passes:
gh pr create --title "..." --body "..."
```

### **Manual GitHub Actions (Optional)**
```
1. Go to GitHub Actions tab
2. Select workflow (e.g., "Build and Test")
3. Click "Run workflow"
4. Select branch
5. Provide reason
6. Click "Run workflow"
```

---

## 📖 **Testing Requirements by Change Type**

### **Backend Changes (C# API)**
```powershell
# Minimum
dotnet build --configuration Release
dotnet test --no-build --filter "FullyQualifiedName!~Integration"
dotnet format --verify-no-changes

# Comprehensive (before PR)
dotnet test --collect:"XPlat Code Coverage"
dotnet test --filter "FullyQualifiedName~Integration"
```

### **Frontend Changes (React/TypeScript)**
```powershell
cd ClientManagerFrontend

# Minimum
npm run lint
npm run type-check
npm test -- --run

# Comprehensive (before PR)
npm test -- --coverage
npm run build
```

### **Database Migrations**
```powershell
# Generate
dotnet ef migrations add MigrationName --context IdentityDbContext

# Validate (MANDATORY)
C:\scripts\tools\validate-migration.ps1 -Context IdentityDbContext -TestRollback

# Test
dotnet ef database update
dotnet ef database update PreviousMigration  # Test rollback
dotnet ef database update  # Re-apply
```

### **Docker/Infrastructure**
```powershell
# Build
C:\scripts\tools\local-ci\local-docker-build.ps1 -Service backend

# Test
docker run -d -p 5000:80 --name test app:local
curl http://localhost:5000/health
docker logs test
docker stop test && docker rm test

# Security scan
C:\scripts\tools\local-ci\local-security-scan.ps1 -Image app:local
```

---

## 🔒 **What's Still Automatic**

These workflows remain automatic (lightweight, essential):

✅ **secret-scan.yml** - Critical security
✅ **pr-size-check.yml** - PR review helper
✅ **dependency-scan.yml** - Security alerts (if exists)

**Why**: These are lightweight (<30s each) and provide critical safety nets.

---

## 💰 **Cost Savings**

### **Before**
- Every PR: ~15-20 minutes of compute
- 10 PRs/day × 20 min = **200 minutes/day**
- Free tier: 2000 minutes/month
- **Ran out after ~10 days**

### **After**
- Manual triggers only
- Average usage: ~50 minutes/month
- **Never hit free tier limit**
- Can run critical workflows when truly needed

---

## 🚨 **Important Rules**

### **DO**
✅ **ALWAYS run `pre-commit-check.ps1` before committing**
✅ **ALWAYS run `full-pre-pr-check.ps1` before creating PR**
✅ Test locally what you changed
✅ Validate migrations before committing
✅ Check coverage for new code (>80%)
✅ Run security scans for sensitive changes

### **DON'T**
❌ **NEVER commit without local testing**
❌ **NEVER assume GitHub Actions will catch issues**
❌ **NEVER commit with failing tests**
❌ **NEVER commit secrets**
❌ **NEVER skip migration validation**
❌ **NEVER push directly to main/develop**

---

## 📊 **Quality Metrics - What We Maintain**

| Metric | Target | How to Check |
|--------|--------|--------------|
| **Build Success** | 100% | `dotnet build --configuration Release` |
| **Test Pass Rate** | 100% | `dotnet test` |
| **Code Coverage** | >80% | `dotnet test --collect:"XPlat Code Coverage"` |
| **Code Formatting** | Clean | `dotnet format --verify-no-changes` |
| **Secret Detection** | 0 secrets | `scan-secrets.ps1` |
| **Migration Validation** | 100% | `validate-migration.ps1` |
| **Docker Security** | No CRITICAL/HIGH | `local-security-scan.ps1` |

---

## 🔍 **Troubleshooting**

### **"I forgot to run pre-commit check and pushed"**
```powershell
# Run check now
C:\scripts\tools\local-ci\pre-commit-check.ps1

# If failures, fix and commit again
git add .
git commit -m "fix: issues from pre-commit check"
git push
```

### **"GitHub Actions still running automatically"**
- Check if workflow file has `on: workflow_dispatch` only
- If not, the migration wasn't applied to that workflow
- Contact team to update workflow file

### **"Local tests pass but I want to validate on GitHub"**
```
1. Go to GitHub → Actions
2. Select workflow
3. Click "Run workflow"
4. Provide reason (e.g., "Final validation before merge")
5. Run
```

### **"Pre-commit check is too slow"**
```powershell
# Use quick mode during development
C:\scripts\tools\local-ci\pre-commit-check.ps1 -Quick

# Use full mode before PR
C:\scripts\tools\local-ci\full-pre-pr-check.ps1
```

---

## 📚 **Documentation Reference**

| Document | Purpose | Location |
|----------|---------|----------|
| **Testing Guide** | Complete testing instructions | `docs/LOCAL_CI_TESTING_GUIDE.md` |
| **Quick Checklist** | Pre-commit reference card | `docs/PRE_COMMIT_CHECKLIST.md` |
| **This Document** | Migration overview | `docs/CI_WORKFLOW_MIGRATION.md` |
| **Reflection Log** | Common issues & solutions | `_machine/reflection.log.md` |
| **Migration Patterns** | Database migration guide | `_machine/migration-patterns.md` |

---

## 🎯 **Success Criteria**

**You're doing it right if:**
- ✅ You run local checks before every commit
- ✅ All commits have passing tests locally
- ✅ PRs are created only after full validation
- ✅ GitHub Actions usage stays under free tier
- ✅ Code quality remains high
- ✅ No secrets in commits
- ✅ Migrations are validated before merge

**You're doing it wrong if:**
- ❌ Committing without running pre-commit check
- ❌ Creating PRs without full validation
- ❌ Assuming "it'll be fine"
- ❌ Relying on GitHub Actions to catch issues
- ❌ Skipping tests because "they probably pass"

---

## 🔄 **Future Improvements**

**Planned:**
1. Pre-commit Git hooks (auto-run checks)
2. VS Code tasks for one-click validation
3. Coverage reporting dashboard
4. Automated local CI in Docker containers
5. Performance benchmarking

---

## 📞 **Need Help?**

**Quick diagnosis:**
```powershell
C:\scripts\tools\diagnose-error.ps1 -ErrorMessage "your error"
```

**Check past solutions:**
```powershell
grep -r "similar issue" C:\scripts\_machine\reflection.log.md
```

**Ask the team:**
- Check documentation first
- Search reflection.log.md for similar issues
- Review PRE_COMMIT_CHECKLIST.md
- If still stuck, ask in team chat

---

## 🎓 **Key Takeaway**

> **GitHub Actions are now manual.**
> **YOU are the CI/CD pipeline.**
> **Local testing = Production quality gate.**

Test thoroughly. Test locally. Test before commit.

**Make every commit count.** 🚀

---

**Last Updated**: 2026-01-30
**Migration Status**: ✅ Complete
**Rollback Plan**: Revert workflow files to add back `push:` and `pull_request:` triggers
