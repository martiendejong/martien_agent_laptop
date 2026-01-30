# 🧪 Local CI Tools - Testing Suite

**GitHub Actions are now manual-only to save billing costs.**
**Use these scripts to test locally before committing.**

---

## 🚀 Quick Start

### **Before EVERY Commit** (3 minutes)
```powershell
.\pre-commit-check.ps1
```

### **Before Creating PR** (15 minutes)
```powershell
.\full-pre-pr-check.ps1
```

---

## 📁 Available Scripts

| Script | Purpose | Usage | Time |
|--------|---------|-------|------|
| **`pre-commit-check.ps1`** | Standard pre-commit validation | `.\pre-commit-check.ps1` | ~3 min |
| **`pre-commit-check.ps1 -Quick`** | Fast check (build + unit tests) | `.\pre-commit-check.ps1 -Quick` | ~1 min |
| **`pre-commit-check.ps1 -Comprehensive`** | Full validation (coverage + security) | `.\pre-commit-check.ps1 -Comprehensive` | ~10 min |
| **`pre-commit-check.ps1 -Fix`** | Auto-fix formatting issues | `.\pre-commit-check.ps1 -Fix` | ~3 min |
| **`full-pre-pr-check.ps1`** | Complete PR validation | `.\full-pre-pr-check.ps1` | ~15 min |
| **`full-pre-pr-check.ps1 -SkipDocker`** | Skip Docker builds | `.\full-pre-pr-check.ps1 -SkipDocker` | ~10 min |
| **`local-docker-build.ps1`** | Build Docker images locally | `.\local-docker-build.ps1 -Service backend` | ~10 min |
| **`local-security-scan.ps1`** | Run Trivy security scans | `.\local-security-scan.ps1 -Image app:local` | ~5 min |

---

## 🎯 Usage Scenarios

### **Scenario 1: Quick Bug Fix**
```powershell
# Make your fix
.\pre-commit-check.ps1 -Quick

# If passes
git add .
git commit -m "fix: description"
git push
```

### **Scenario 2: New Feature**
```powershell
# Develop feature
.\pre-commit-check.ps1 -Comprehensive

# If passes
git add .
git commit -m "feat: description"
git push
```

### **Scenario 3: Ready to Create PR**
```powershell
# Final validation
.\full-pre-pr-check.ps1

# If passes
gh pr create --title "..." --body "..."
```

### **Scenario 4: Docker/Infrastructure Change**
```powershell
# Build and scan
.\local-docker-build.ps1 -Service all -SecurityScan

# If passes
git add .
git commit -m "infra: docker changes"
git push
```

---

## 📊 What Each Script Checks

### **`pre-commit-check.ps1`** (Standard Mode)
- ✅ Git status validation
- ✅ Secret scanning
- ✅ Code formatting check
- ✅ Backend build (Release config)
- ✅ Unit tests
- ✅ Frontend lint & type check
- ✅ Migration validation (if changed)

### **`pre-commit-check.ps1 -Comprehensive`**
All standard checks **PLUS:**
- ✅ Integration tests
- ✅ Code coverage analysis (>80%)
- ✅ Security vulnerability scan

### **`full-pre-pr-check.ps1`**
- ✅ All comprehensive checks
- ✅ Backend tests (all)
- ✅ Frontend tests with coverage
- ✅ Docker builds
- ✅ Security scans
- ✅ PR readiness validation (branch, commits, etc.)

---

## 🔧 Script Options

### **pre-commit-check.ps1**
```powershell
# Standard check
.\pre-commit-check.ps1

# Quick mode (development)
.\pre-commit-check.ps1 -Quick

# Full mode (before PR)
.\pre-commit-check.ps1 -Comprehensive

# Auto-fix formatting
.\pre-commit-check.ps1 -Fix
```

### **full-pre-pr-check.ps1**
```powershell
# Complete check
.\full-pre-pr-check.ps1

# Skip Docker (faster)
.\full-pre-pr-check.ps1 -SkipDocker

# Backend only
.\full-pre-pr-check.ps1 -SkipFrontend

# Frontend only
.\full-pre-pr-check.ps1 -SkipBackend
```

---

## ✅ Success Output Examples

### **Passed Check**
```
═══════════════════════════════════════════════
  ✅ ALL CHECKS PASSED - READY TO COMMIT!
═══════════════════════════════════════════════

Next steps:
  git add .
  git commit -m 'your message'
  git push
```

### **Failed Check**
```
═══════════════════════════════════════════════
  ❌ COMMIT BLOCKED - FIX FAILURES FIRST
═══════════════════════════════════════════════

To auto-fix formatting issues, run:
  .\pre-commit-check.ps1 -Fix
```

---

## 🚨 Common Issues

### **"Build Failed"**
```powershell
# Check build output
dotnet build --configuration Release --verbosity normal

# Common fixes:
# - Restore dependencies: dotnet restore
# - Clean: dotnet clean
# - Check for pending migrations
```

### **"Tests Failed"**
```powershell
# See detailed test output
dotnet test --verbosity normal

# Run specific test
dotnet test --filter "TestClassName.TestMethodName"
```

### **"Formatting Failed"**
```powershell
# Auto-fix
dotnet format

# Or
.\pre-commit-check.ps1 -Fix
```

### **"Secrets Detected"**
```powershell
# Find secrets
C:\scripts\tools\scan-secrets.ps1 -Path . -Verbose

# Remove from code
# Never commit: API keys, passwords, tokens, connection strings
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **LOCAL_CI_TESTING_GUIDE.md** | Comprehensive testing instructions |
| **PRE_COMMIT_CHECKLIST.md** | Quick reference card |
| **CI_WORKFLOW_MIGRATION.md** | Migration overview |

**Location**: `C:\scripts\docs\`

---

## 💡 Tips

1. **Run checks frequently** - Don't wait until commit time
2. **Use `-Quick` during development** - Fast feedback loop
3. **Use `-Comprehensive` before PR** - Catch everything
4. **Auto-fix when possible** - Use `-Fix` flag
5. **Read error messages** - They tell you what's wrong
6. **Check documentation** - Most issues are documented

---

## 🎓 Remember

- **GitHub Actions are manual-only now**
- **YOU are the CI/CD pipeline**
- **Local tests = Production quality gate**
- **Test before commit, not after**
- **Fix issues locally, not in CI**

---

## 📞 Need Help?

```powershell
# Diagnose errors
C:\scripts\tools\diagnose-error.ps1 -ErrorMessage "your error"

# Search past solutions
grep -r "similar issue" C:\scripts\_machine\reflection.log.md

# Check documentation
code C:\scripts\docs\LOCAL_CI_TESTING_GUIDE.md
```

---

**Created**: 2026-01-30
**Purpose**: Save GitHub Actions billing by testing locally
**Maintained by**: Development team
