# Definition of Done (DoD) - Brand2Boost & Hazina

**Project:** Brand2Boost (client-manager) & Hazina Framework
**Purpose:** Comprehensive completion criteria for all development tasks
**Status:** Active (2026-01-15)
**Location:** Upload to Google Drive → Brand2Boost Documentation folder

---

## 📖 Executive Summary

The **Definition of Done (DoD)** is a comprehensive checklist that ensures every task, feature, or bug fix meets quality standards before being considered "complete."

**Key Principle:**
> A task is NOT done until it's **live in production**, **working correctly**, **documented**, and **verified**.

---

## 🎯 What "Done" Means

### ❌ NOT Done:
- "Works on my machine"
- "PR merged to develop"
- "Deployed to staging"
- "Code committed locally"

### ✅ DONE:
1. **Deployed to production**
2. **Working without errors**
3. **Documentation updated**
4. **Stakeholders notified**
5. **Verification completed**

---

## 📋 Complete DoD Checklist

### Phase 1: Development ✍️
- [ ] Branch created from `develop` (never from feature branches)
- [ ] Code implemented according to requirements
- [ ] Unit tests written and passing (≥80% coverage for new code)
- [ ] Manual testing completed in local environment
- [ ] Code formatted and linted (C#: cs-format.ps1, TS: ESLint/Prettier)

### Phase 2: Quality Assurance 🔍
- [ ] Build succeeds (backend: `dotnet build`, frontend: `npm run build`)
- [ ] All tests passing (unit, integration, E2E)
- [ ] Code review completed (minimum 1 approval)
- [ ] Security scan passed (no new vulnerabilities)
- [ ] Performance validated (no significant degradation)

### Phase 3: Version Control 🔀
- [ ] Code committed with meaningful messages (format: `<type>: <description>`)
- [ ] Branch pushed to remote repository
- [ ] Pull Request created with:
  - Clear title and description
  - Test plan for verification
  - Screenshots for UI changes
  - Cross-repo dependencies documented
- [ ] PR base branch verified as `develop`
- [ ] PR approved by reviewer(s)
- [ ] All CI/CD checks passing

### Phase 4: Integration 🚀
- [ ] PR merged to `develop`
- [ ] Develop branch updated locally
- [ ] CI/CD pipeline passed on develop branch
- [ ] Build artifacts created successfully

### Phase 5: Deployment 🌐
- [ ] Deployed to staging environment (if applicable)
- [ ] Deployed to **production environment**
- [ ] Production verification completed:
  - Feature accessible and working
  - User flows tested
  - No regression issues
  - Application health checks passing
  - No critical errors in production logs
- [ ] Rollback plan documented and ready

### Phase 6: Documentation 📚
- [ ] User documentation updated (README, guides)
- [ ] Technical documentation updated (API docs, architecture)
- [ ] Workflow documentation updated (CLAUDE.md if patterns changed)
- [ ] Changelog updated (version incremented if needed)
- [ ] Release notes prepared (for significant features)

### Phase 7: Communication 📢
- [ ] Stakeholder notified (user informed of completion)
- [ ] Team members updated (Slack, email, etc.)
- [ ] ClickUp task status: `done`
- [ ] ClickUp task completion date logged
- [ ] PR link added to ClickUp task
- [ ] Reflection log updated with lessons learned

---

## 🔄 Standard Workflow

```
1. Create branch from develop
   ↓
2. Implement feature/fix
   ↓
3. Write tests + manual testing
   ↓
4. Commit + push
   ↓
5. Create PR (base: develop)
   ↓
6. Code review + approval
   ↓
7. Merge to develop
   ↓
8. CI/CD pipeline runs
   ↓
9. Deploy to staging (optional)
   ↓
10. Deploy to PRODUCTION ← CRITICAL
   ↓
11. Verify in production
   ↓
12. Update documentation
   ↓
13. Notify stakeholders
   ↓
14. Mark task as DONE ✅
```

---

## 📊 Project-Specific Requirements

### Brand2Boost (client-manager)

**Additional DoD Criteria:**
- [ ] **Paired worktree coordination** (if Hazina framework changes included)
  - Hazina PR created/merged first if dependencies exist
  - client-manager PR references Hazina PR in description
- [ ] **Environment variables validated**
  - `.env` file updated (if new configuration required)
  - Azure KeyVault updated (if production secrets needed)
- [ ] **Database migrations applied**
  - Migration script created (if schema changes)
  - Applied to development database
  - Applied to production database during deployment
- [ ] **Frontend + Backend compatibility verified**
  - API contract not broken
  - Frontend can consume API changes
  - CORS settings updated (if new endpoints added)

### Hazina Framework

**Additional DoD Criteria:**
- [ ] **NuGet package versioning** (if public release)
  - Version incremented in `.csproj` files
  - Release notes prepared
  - NuGet package published
- [ ] **Breaking changes documented**
  - MIGRATION_GUIDE.md updated
  - Deprecation warnings added to code
  - client-manager compatibility verified
- [ ] **Example code updated**
  - Demo projects reflect new features
  - README.md examples are accurate

---

## 🛠️ Tools for DoD Verification

| DoD Check | Tool | Command |
|-----------|------|---------|
| Build status | dotnet CLI | `dotnet build` |
| Test results | dotnet CLI | `dotnet test` |
| Code format | cs-format.ps1 | `C:\scripts\tools\cs-format.ps1 -Check` |
| PR base branch | GitHub CLI | `gh pr view <num> --json baseRefName` |
| PR status | GitHub CLI | `gh pr status` |
| CI/CD status | GitHub CLI | `gh run list --branch <branch>` |
| Deployment status | Azure Portal / Custom | Project-specific |
| ClickUp sync | clickup-sync.ps1 | `C:\scripts\tools\clickup-sync.ps1 -Action update` |

---

## 📝 Real-World Example

### Example: Bug Fix "Create Website Not Working" (ClickUp #869bth09k)

**Task:** Production error when creating new websites - null reference exception

**DoD Completion Steps:**

1. ✅ **Branch created:** `fix/create-website-error` from `develop`
2. ✅ **Root cause identified:** Null reference in `WebsiteService.cs:145`
3. ✅ **Fix implemented:** Added null check and error handling
4. ✅ **Unit test added:** `WebsiteServiceTests.cs` - test null input scenarios
5. ✅ **Manual testing:** Verified website creation flow works end-to-end
6. ✅ **Code formatted:** `cs-format.ps1` passed
7. ✅ **Build passed:** `dotnet build` successful (0 errors, 0 warnings)
8. ✅ **Tests passed:** All 487 tests green
9. ✅ **Committed:** `fix: Add null check in website creation service`
10. ✅ **Pushed:** `git push -u origin fix/create-website-error`
11. ✅ **PR created:** #149 "fix: Resolve website creation null reference"
12. ✅ **PR reviewed:** Claude agent review + 1 team member approval
13. ✅ **PR merged:** Squash and merge to `develop` completed
14. ✅ **CI/CD passed:** GitHub Actions build successful on develop
15. ✅ **Deployed to staging:** Verified fix works in staging environment
16. ✅ **Deployed to production:** Released as v1.2.3
17. ✅ **Production verified:**
    - Smoke tests passed
    - Website creation working for all users
    - No errors in production logs (monitored for 24 hours)
18. ✅ **Documentation updated:** Internal bug fix - no user docs needed
19. ✅ **Reflection log updated:** Lesson learned about null validation
20. ✅ **ClickUp updated:** Task #869bth09k status: `done`
21. ✅ **User notified:** Email sent - "Website creation bug is now fixed"

**Result:** ✅ **DONE** - All DoD criteria met, task complete

---

## 🚫 Common DoD Violations

### What Counts as NOT Done:

❌ **"It works on my machine"**
→ Must work in production environment

❌ **"PR is merged"**
→ Must be deployed to production

❌ **"It's in staging"**
→ Must be in production and verified

❌ **"Code is pushed"**
→ Must have PR created, reviewed, and merged

❌ **"Build passes"**
→ Must also be deployed and verified

❌ **"User approved the feature"**
→ Must also be documented

---

## 📈 Success Metrics

**How to know if DoD is working:**

1. ✅ **No surprise production bugs** - Issues caught before deployment
2. ✅ **Faster deployments** - Clear completion criteria, less back-and-forth
3. ✅ **Better documentation** - Docs always current with production code
4. ✅ **Team alignment** - Everyone knows what "done" means
5. ✅ **User satisfaction** - Features work as expected when released
6. ✅ **Reduced technical debt** - Quality built in from the start

---

## 🔄 Continuous Improvement

**DoD is a living document:**
- Review quarterly or after major incidents
- Add new criteria based on lessons learned
- Remove outdated or non-valuable checks
- Adapt to team maturity and project evolution

**Reflection Protocol:**
After EVERY task completion, update reflection log with:
- What went well
- What could be improved
- New patterns discovered
- Updates needed to DoD

---

## 📚 Documentation Locations

**Full DoD Documentation:**
- `C:\scripts\_machine\DEFINITION_OF_DONE.md` (comprehensive version)
- `C:\scripts\_machine\DEFINITION_OF_DONE_CLICKUP.md` (checklist for ClickUp)
- This document (Google Drive summary)

**Project Integration:**
- `C:\Projects\client-manager\README.md` (DoD section)
- `C:\Projects\hazina\README.md` (DoD section)
- `C:\scripts\CLAUDE.md` (references and workflow integration)

**Updated:** 2026-01-15
**Version:** 1.0
**Status:** Active

---

## 💡 Key Takeaway

> **"Done" means deployed to production, working correctly, documented, and verified - not just code written or PR merged.**

---

**Questions or feedback?**
Contact: Development Team
**Document Owner:** Claude Agent + Team
**Next Review:** 2026-04-15 (Quarterly)
