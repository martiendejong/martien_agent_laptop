# Definition of Done Enforcement System

**ClickUp Task:** #869bu91ej
**ROI:** 225x | Effort: 2 days | Value: €18,000/year
**Purpose:** Ensure every task meets quality standards before marking "done"

---

## 🎯 Overview

The DoD Enforcement System prevents tasks from being marked "done" until ALL quality criteria are met. This reduces rework, eliminates shortcuts, and ensures consistent quality across all development work.

### Benefits
- ✅ **Consistent Quality:** Every task meets same standard
- ✅ **No Shortcuts:** Can't skip tests/docs/deployment
- ✅ **Clear Communication:** "Done" means truly done
- ✅ **20% Less Rework:** Catch issues early, reduce bugs
- ✅ **Team Alignment:** Everyone knows completion criteria

---

## 📦 Components

### 1. GitHub PR Template Enhancement
**File:** `.github/pull_request_template.md`

**Changes:**
- Added comprehensive "Definition of Done Checklist" section
- 7 phases with 32 checklist items
- Clear success criteria
- Reference to full DoD document

**Usage:**
- Automatically appears when creating new PRs
- Check off items as you complete them
- All items must be checked before merge

### 2. Pre-Commit Hook
**Files:**
- `C:\scripts\tools\dod-pre-commit-check.ps1` - Validation script
- `C:\scripts\tools\pre-commit.example` - Git hook template
- `C:\scripts\tools\install-dod-hook.ps1` - Installer

**Checks:**
- ✅ No hardcoded secrets (API keys, tokens)
- ✅ C# code formatted (cs-format.ps1)
- ✅ No pending EF migrations
- ✅ Build succeeds (dotnet build)
- ✅ Tests pass (dotnet test)
- ✅ No console.log in production code

**Installation:**
```powershell
# Install in client-manager repository
cd C:\Projects\client-manager
C:\scripts\tools\install-dod-hook.ps1

# Or manually
Copy-Item C:\scripts\tools\pre-commit.example .git\hooks\pre-commit
```

**Usage:**
```powershell
# Runs automatically on every commit
git commit -m "Your commit message"

# Manual check (before committing)
C:\scripts\tools\dod-pre-commit-check.ps1

# Fast mode (skip tests for WIP)
C:\scripts\tools\dod-pre-commit-check.ps1 -SkipTests

# Bypass (NOT RECOMMENDED)
git commit --no-verify
```

### 3. ClickUp Task Templates
**File:** `C:\scripts\tools\CLICKUP_DOD_TEMPLATE_SETUP.md`

**Setup:**
- Manual checklist (copy-paste into tasks)
- ClickUp task template (recommended)
- Automation rule (advanced)
- Bulk update script

**Checklist Structure:**
- Phase 1: Development (8 items)
- Phase 2: Quality Assurance (5 items)
- Phase 3: Version Control (5 items)
- Phase 4: Integration (3 items)
- Phase 5: Deployment (4 items)
- Phase 6: Documentation (4 items)
- Phase 7: Communication (3 items)

**Total:** 32 checklist items per task

---

## 🚀 Quick Start

### For Developers

**1. Install Pre-Commit Hook:**
```powershell
cd C:\Projects\client-manager
C:\scripts\tools\install-dod-hook.ps1
```

**2. Create Tasks with DoD Checklist:**
- Use "Standard Task with DoD" ClickUp template
- Or manually add checklist from `CLICKUP_DOD_TEMPLATE_SETUP.md`

**3. During Development:**
```powershell
# Before committing
C:\scripts\tools\dod-pre-commit-check.ps1

# If checks pass, commit
git commit -m "feat: Your feature"

# Create PR (template includes DoD checklist)
gh pr create
```

**4. Before Marking "Done":**
- Verify ALL 32 ClickUp checklist items are checked
- Verify ALL PR template DoD items are checked
- Only mark "done" when 100% complete

### For Claude Agents

**Workflow Integration:**
```powershell
# 1. Create worktree for feature
allocate-worktree -TaskId "869xyz"

# 2. Implement feature
# ... (code changes)

# 3. Pre-commit validation
dod-pre-commit-check.ps1

# 4. Commit (hook runs automatically)
git commit -m "feat: Feature name"

# 5. Create PR (template includes DoD)
gh pr create --base develop

# 6. Update ClickUp task with DoD checklist progress
clickup-sync.ps1 -Action update -TaskId "869xyz" -ChecklistProgress "28/32"

# 7. Mark done only when ALL items complete
clickup-sync.ps1 -Action update -TaskId "869xyz" -Status "done"
```

---

## 📋 Definition of Done Phases

### Phase 1: Development ✍️
- [ ] Code implemented according to requirements
- [ ] Unit tests written and passing
- [ ] Manual testing completed
- [ ] UI testing via Browser MCP (if UI changes)
- [ ] Code formatted (cs-format.ps1, ESLint/Prettier)
- [ ] Build succeeds without errors
- [ ] No pending EF migrations
- [ ] Security validated (no hardcoded secrets)

### Phase 2: Quality Assurance 🔍
- [ ] All tests passing (unit + integration)
- [ ] Code review completed
- [ ] Security scan passed
- [ ] Performance validated
- [ ] No compiler warnings

### Phase 3: Version Control 🔀
- [ ] Code committed with meaningful message
- [ ] Branch pushed to remote
- [ ] PR created with complete description
- [ ] PR base branch verified as `develop`
- [ ] PR approved by reviewer(s)

### Phase 4: Integration 🚀
- [ ] PR merged to `develop`
- [ ] Develop branch updated locally
- [ ] CI/CD pipeline passed on develop

### Phase 5: Deployment 🌐
- [ ] Deployed to staging (if applicable)
- [ ] Deployed to production
- [ ] Production verification completed
- [ ] Rollback plan ready

### Phase 6: Documentation 📚
- [ ] User documentation updated
- [ ] Technical documentation updated
- [ ] Changelog updated
- [ ] Release notes prepared (if needed)

### Phase 7: Communication 📢
- [ ] Stakeholder notified
- [ ] ClickUp task status updated to "done"
- [ ] Reflection log updated

---

## 🔧 Tools Reference

| Tool | Purpose | Command |
|------|---------|---------|
| **dod-pre-commit-check.ps1** | Pre-commit validation | `.\dod-pre-commit-check.ps1` |
| **install-dod-hook.ps1** | Install Git hook | `.\install-dod-hook.ps1` |
| **pre-commit.example** | Git hook template | Copy to `.git/hooks/pre-commit` |
| **CLICKUP_DOD_TEMPLATE_SETUP.md** | ClickUp configuration guide | Read for setup instructions |
| **DEFINITION_OF_DONE.md** | Full DoD reference | `C:\scripts\_machine\DEFINITION_OF_DONE.md` |

---

## 📊 Success Metrics

### Target Metrics (After 3 Months)

| Metric | Before DoD | After DoD | Target |
|--------|------------|-----------|--------|
| Tasks with DoD checklist | 0% | 100% | 100% |
| Tasks 100% complete before "done" | ~60% | 100% | 100% |
| Post-deployment bugs | Baseline | -20% | -20% |
| Code review time | Baseline | -15% | -15% |
| Documentation accuracy | ~70% | 95% | 95% |
| Rework rate | Baseline | -20% | -20% |

### Tracking

**ClickUp Report:**
```powershell
# Generate DoD compliance report
C:\scripts\tools\clickup-sync.ps1 -Action report -Metric dod-compliance

# Example output:
# Total tasks: 45
# With DoD checklist: 42 (93%)
# 100% complete: 38 (84%)
# Average completion: 28.5/32 items (89%)
```

**Quality Metrics:**
```powershell
# Check post-deployment bug rate
C:\scripts\tools\health-check.ps1 -Metric post-deployment-bugs

# Example output:
# Last 30 days: 12 bugs
# Previous 30 days: 15 bugs
# Reduction: 20% ✅
```

---

## 🎓 Training & Adoption

### For New Team Members

**Day 1: Introduction**
- Read `C:\scripts\_machine\DEFINITION_OF_DONE.md`
- Understand 7 phases and 32 criteria
- Learn "done" = in production, working, documented

**Day 2: Tools Setup**
- Install pre-commit hook (`install-dod-hook.ps1`)
- Test with empty commit
- Create first task with DoD checklist

**Day 3: Practice**
- Complete a small bug fix following DoD
- Check off all 32 items
- Experience full workflow

**Week 2: Review**
- Review DoD metrics
- Identify common blockers
- Refine workflow

### For Existing Team

**Rollout Plan:**
1. **Week 1:** Install pre-commit hooks
2. **Week 2:** Add DoD to new tasks only
3. **Week 3:** Backfill DoD to active tasks
4. **Week 4:** Enforce 100% completion requirement
5. **Month 2:** Review metrics, adjust criteria

---

## 🆘 Troubleshooting

### Common Issues

**Problem:** Pre-commit hook blocks commit
```powershell
# Check what failed
C:\scripts\tools\dod-pre-commit-check.ps1

# Fix issues, then retry
git commit -m "Your message"
```

**Problem:** Too many DoD items (overwhelming)
**Solution:**
- Group by phase, complete incrementally
- Use `-SkipTests` flag for fast WIP commits
- Focus on must-have items first

**Problem:** ClickUp checklist doesn't save
**Solution:**
- Check ClickUp permissions
- Refresh browser
- Use ClickUp API as fallback

**Problem:** Task marked "done" but DoD incomplete
**Solution:**
- Reopen task
- Complete missing items
- Add automation reminder (future enhancement)

---

## 🔄 Continuous Improvement

### Quarterly Review

**Review checklist items:**
- Are all 32 items still relevant?
- Should we add new criteria?
- Can we remove outdated checks?

**Update documentation:**
- `C:\scripts\_machine\DEFINITION_OF_DONE.md`
- `.github/pull_request_template.md`
- ClickUp task templates

**Analyze metrics:**
- DoD compliance rate
- Bug reduction
- Rework reduction
- Team feedback

---

## 📚 References

**Core Documentation:**
- `C:\scripts\_machine\DEFINITION_OF_DONE.md` - Full DoD specification
- `C:\scripts\GENERAL_ZERO_TOLERANCE_RULES.md` - Pre-flight checklists
- `C:\scripts\git-workflow.md` - PR workflow

**Tools:**
- `C:\scripts\tools\dod-pre-commit-check.ps1`
- `C:\scripts\tools\install-dod-hook.ps1`
- `C:\scripts\tools\CLICKUP_DOD_TEMPLATE_SETUP.md`

**External:**
- ClickUp API: https://clickup.com/api
- Git Hooks: https://git-scm.com/docs/githooks

---

## 🎯 Commitment

**No task is marked "done" until ALL DoD criteria are met.**

- Not done: Code on local machine
- Not done: PR merged but not deployed
- Not done: Deployed but causing errors
- **DONE:** In production, working, documented, verified

---

**Created:** 2026-02-07
**ClickUp Task:** #869bu91ej
**ROI:** 225x (€18,000/year value, 2 days effort)
**Status:** Active
