# Definition of Done (DoD)

**Purpose:** Comprehensive checklist that must be satisfied before a task, feature, or bug fix is considered "complete" and ready for production deployment.

**Scope:** Applies to all projects managed by this control plane (Brand2Boost/client-manager, Hazina framework).

---

## 🎯 Overview

A task is **DONE** only when ALL of the following criteria are met:

1. ✅ **Development Complete** - Code implemented, tested locally
2. ✅ **Quality Checks Passed** - Build succeeds, tests pass, code reviewed
3. ✅ **Version Control** - Committed, pushed, PR created and approved
4. ✅ **Merged to Main Branch** - PR merged to `develop` (or `main`)
5. ✅ **Deployed to Production** - Changes live in production environment
6. ✅ **Documentation Updated** - User docs, technical docs, changelog updated
7. ✅ **Stakeholder Notified** - User/team aware of completion

---

## 📋 Complete DoD Checklist

### Phase 1: Development ✍️

- [ ] **Branch created from `develop`** (or `main` if configured)
  - Branch naming: `feature/<feature-name>` or `fix/<bug-name>` or `agent-XXX-<description>`
  - Never branch from outdated branches

- [ ] **Code implemented** according to requirements
  - Follows project coding standards
  - No hardcoded credentials or secrets
  - Error handling implemented
  - Logging added where appropriate

- [ ] **Unit tests written and passing**
  - New features have test coverage
  - Bug fixes include regression tests
  - Test coverage ≥ 80% for new code

- [ ] **Manual testing completed**
  - Feature works as expected in local development
  - Edge cases tested
  - User experience validated

- [ ] **UI testing via Browser Claude** (if UI changes present)
  - Request Browser Claude to test forms, workflows, visual appearance
  - Command: `powershell -File C:/scripts/tools/claude-bridge-client.ps1 -Action send -Message "Test [feature] at [URL]"`
  - Check results: `powershell -File C:/scripts/tools/claude-bridge-client.ps1 -Action check`
  - Browser Claude validates: form submission, error handling, responsive design, accessibility

- [ ] **Code formatted and linted**
  - C#: `cs-format.ps1` run and passed
  - TypeScript/React: ESLint and Prettier applied
  - No compiler warnings

### Phase 2: Quality Assurance 🔍

- [ ] **Build succeeds** without errors
  - Backend: `dotnet build` passes
  - Frontend: `npm run build` passes
  - No compilation errors or warnings

- [ ] **All tests passing**
  - Unit tests: `dotnet test` (backend), `npm test` (frontend)
  - Integration tests (if applicable)
  - E2E tests (if applicable)

- [ ] **Code review completed**
  - PR submitted with clear description
  - At least 1 approval from team member or Claude agent
  - All review comments addressed

- [ ] **Security scan passed**
  - No new vulnerabilities introduced
  - Secrets properly stored in environment variables or KeyVault
  - Input validation implemented

- [ ] **Performance validated**
  - No significant performance degradation
  - Database queries optimized
  - API response times acceptable

### Phase 3: Version Control 🔀

- [ ] **Code committed** with meaningful messages
  - Format: `<type>: <description>` (e.g., `feat: Add PDF export`, `fix: Resolve login timeout`)
  - Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`

- [ ] **Branch pushed** to remote repository
  - `git push -u origin <branch-name>`

- [ ] **Pull Request created** with complete description
  - Title: Clear, concise summary
  - Description:
    - **Summary** - What was changed and why
    - **Test Plan** - How to verify the changes
    - **Screenshots** - For UI changes
    - **Dependencies** - Cross-repo dependencies documented (see PR Dependencies Protocol)

- [ ] **PR base branch verified** as `develop` (not `main` or other branches)
  - Verify: `gh pr view <number> --json baseRefName`

- [ ] **PR approved** by reviewer(s)
  - All CI/CD checks passing
  - No blocking comments

### Phase 4: Integration 🚀

- [ ] **PR merged to `develop`** (or main branch)
  - Merge strategy: Squash and merge (or as per project standards)
  - Delete feature branch after merge

- [ ] **Develop branch updated locally**
  - `git checkout develop && git pull origin develop`

- [ ] **CI/CD pipeline passed** on develop branch
  - All automated tests passing
  - Build artifacts created successfully

### Phase 5: Deployment 🌐

- [ ] **Deployed to staging environment** (if applicable)
  - Smoke tests passed
  - Stakeholder review completed

- [ ] **Deployed to production**
  - Deployment completed without errors
  - Application health checks passing
  - No critical errors in logs

- [ ] **Production verification**
  - Feature accessible in production
  - User flows tested in production
  - No regression issues detected

- [ ] **Rollback plan ready**
  - Previous version documented
  - Rollback procedure known

### Phase 6: Documentation 📚

- [ ] **User documentation updated**
  - README.md updated (if user-facing changes)
  - User guides updated (if new features)

- [ ] **Technical documentation updated**
  - API documentation updated (if API changes)
  - Architecture diagrams updated (if structural changes)
  - CLAUDE.md updated with new patterns (if workflow changes)
  - **🆕 Folder network map updated** (`knowledge-base/02-MACHINE/folder-network.md`) if:
    - New folder created
    - Files moved/organized between folders
    - Sync relationships discovered (Google Drive, Git, etc.)
    - New workflows involving folders documented

- [ ] **Changelog updated**
  - Version number incremented (if applicable)
  - CHANGELOG.md entry added

- [ ] **Release notes prepared** (for significant features)
  - What's new
  - Known issues
  - Migration guide (if breaking changes)

### Phase 7: Communication 📢

- [ ] **Stakeholder notified**
  - User informed of completion
  - Team members updated in Slack/Teams/email

- [ ] **ClickUp task updated**
  - Status: `done`
  - Completion date logged
  - PR link added to task

- [ ] **Reflection log updated**
  - Lessons learned documented in `C:\scripts\_machine\reflection.log.md`
  - Patterns added to best practices (if applicable)

---

## 🔄 Workflow Summary

```
1. Create branch from develop
   ↓
2. Implement feature/fix
   ↓
3. Write tests + manual testing
   ↓
4. ★ CHECK: Pending migrations (EF Core projects) ★
   → dotnet ef migrations has-pending-model-changes
   → If pending: create migration BEFORE continuing
   ↓
5. Commit + push (include migrations!)
   ↓
6. Create PR (base: develop)
   ↓
7. Code review + approval
   ↓
8. Merge to develop
   ↓
9. CI/CD pipeline runs
   ↓
10. Deploy to staging (optional)
   ↓
11. Deploy to production
   ↓
12. Verify in production
   ↓
13. Update documentation
   ↓
14. Notify stakeholders
   ↓
15. Mark task as DONE ✅
```

---

## 🚫 NOT Done Until...

**The task is NOT done if:**
- ❌ Code only exists in local branch (not pushed)
- ❌ PR created but not merged
- ❌ Merged to develop but not deployed
- ❌ Deployed to staging but not production
- ❌ In production but causing errors
- ❌ Working but documentation not updated
- ❌ Everything done but stakeholder not notified

**"Works on my machine" ≠ Done**

**"PR merged" ≠ Done**

**"Deployed to staging" ≠ Done**

**DONE = In production, working, documented, and verified**

---

## 📊 Project-Specific DoD

### Brand2Boost (client-manager)

**Additional Requirements:**
- [ ] **Paired worktree coordination** (if Hazina changes included)
  - Hazina PR created/merged first (if dependencies exist)
  - client-manager PR references Hazina PR in description
  - See `C:\scripts\_machine\pr-dependencies.md` for tracking

- [ ] **Environment variables validated**
  - `.env` file updated (if new config required)
  - Azure KeyVault updated (if production secrets needed)

- [ ] **Database migrations created AND applied** (CRITICAL)
  - **STEP 1 - Pre-PR Check:** BEFORE creating PR, run: `dotnet ef migrations has-pending-model-changes --context IdentityDbContext`
    - If exit code = 0 → No pending changes, continue
    - If exit code ≠ 0 → STOP! Create migration first (Step 2)
  - **STEP 2 - Create Migration:** `dotnet ef migrations add <Name> --context IdentityDbContext`
  - **STEP 3 - Review:** Check `Migrations/*.cs` for correct Up/Down methods
  - **STEP 4 - Build:** `dotnet build` passes (migration compiles)
  - **STEP 5 - Apply:** `dotnet ef database update` (apply to local dev)
  - **STEP 6 - Commit:** Migration COMMITTED with the feature (not "do later")
  - **HARD RULE:** If you add a DbSet, change entity properties, or modify OnModelCreating, you MUST create the migration
  - **HARD RULE:** Never tell user "run migration later" - it's part of your job
  - **HARD RULE:** A PR with pending model changes that causes `PendingModelChangesWarning` at runtime is a CRITICAL FAILURE
  - **AUTOMATED CHECK:** Run `ef-preflight-check.ps1 -Context IdentityDbContext -ProjectPath <path>` before PR

- [ ] **Frontend + Backend compatibility verified**
  - API contract not broken
  - Frontend can consume API changes
  - CORS settings updated (if new endpoints)

### Hazina Framework

**Additional Requirements:**
- [ ] **NuGet package versioning** (if public release)
  - Version incremented in `.csproj`
  - Release notes prepared
  - NuGet package published

- [ ] **Breaking changes documented**
  - MIGRATION_GUIDE.md updated
  - Deprecation warnings added to code
  - Client-manager compatibility verified

- [ ] **Example code updated**
  - Demo projects reflect new features
  - README.md examples accurate

---

## 🔧 Tools for DoD Verification

| Check | Tool | Command |
|-------|------|---------|
| Build status | dotnet CLI | `dotnet build` |
| Test results | dotnet CLI | `dotnet test` |
| Code format | cs-format.ps1 | `C:\scripts\tools\cs-format.ps1 -Check` |
| PR base branch | GitHub CLI | `gh pr view <num> --json baseRefName` |
| PR status | GitHub CLI | `gh pr status` |
| CI/CD status | GitHub CLI | `gh run list --branch <branch>` |
| Deployment status | Azure CLI / Custom | Project-specific |
| ClickUp sync | clickup-sync.ps1 | `C:\scripts\tools\clickup-sync.ps1 -Action update` |

---

## 📝 Examples

### Example 1: Bug Fix "Create Website Not Working" (ClickUp #869bth09k)

**DoD Checklist:**
1. ✅ Branch created from `develop`: `fix/create-website-error`
2. ✅ Root cause identified: Null reference in WebsiteService.cs:145
3. ✅ Fix implemented: Added null check and error handling
4. ✅ Unit test added: `WebsiteServiceTests.cs` - test null input handling
5. ✅ Manual testing: Verified website creation flow works
6. ✅ Code formatted: `cs-format.ps1` passed
7. ✅ Build passed: `dotnet build` successful
8. ✅ Tests passed: All 487 tests green
9. ✅ Committed: `fix: Add null check in website creation`
10. ✅ Pushed: `git push -u origin fix/create-website-error`
11. ✅ PR created: #149 "fix: Resolve website creation null reference"
12. ✅ PR approved: Claude agent review + 1 team approval
13. ✅ Merged to `develop`: Squash and merge completed
14. ✅ CI/CD passed: GitHub Actions build successful on develop
15. ✅ Deployed to staging: Verified website creation works
16. ✅ Deployed to production: Released v1.2.3
17. ✅ Production verified: Smoke tests passed, no errors in logs
18. ✅ README updated: N/A (internal bug fix)
19. ✅ Reflection log updated: Lesson learned about null checks
20. ✅ ClickUp updated: Task #869bth09k marked "done"
21. ✅ User notified: "Website creation bug is now fixed in production"

**Result:** ✅ DONE

### Example 2: New Feature "PDF Export for Reports"

**DoD Checklist:**
1. ✅ Branch created from `develop`: `feature/pdf-export-reports`
2. ✅ Feature implemented: PdfExportService, new API endpoint
3. ✅ Unit tests: 12 new tests for PDF generation
4. ✅ Integration test: End-to-end PDF export flow
5. ✅ Manual testing: Generated PDFs for all report types
6. ✅ Code formatted and linted
7. ✅ Build passed (backend + frontend)
8. ✅ All tests passing (495 total)
9. ✅ Security review: No sensitive data in PDFs
10. ✅ Performance test: PDF generation < 2 seconds
11. ✅ Committed and pushed
12. ✅ PR created: #150 "feat: Add PDF export for reports"
13. ✅ Code review: 2 approvals
14. ✅ Merged to `develop`
15. ✅ CI/CD passed on develop
16. ✅ Deployed to staging: User acceptance testing completed
17. ✅ Deployed to production: v1.3.0 released
18. ✅ Production verified: PDF export working for all users
19. ✅ User docs updated: README + user guide with screenshots
20. ✅ API docs updated: OpenAPI spec includes new endpoint
21. ✅ Changelog updated: v1.3.0 entry added
22. ✅ Release notes: "What's New in v1.3.0"
23. ✅ ClickUp task marked done
24. ✅ Team notified via Slack: "PDF export feature live!"

**Result:** ✅ DONE

---

## 🎯 Success Metrics

**How to know if DoD is working:**

1. **No surprise bugs in production** - Issues caught before deployment
2. **Faster deployments** - Less back-and-forth, clear completion criteria
3. **Better documentation** - Docs always current with code
4. **Team alignment** - Everyone knows what "done" means
5. **User satisfaction** - Features work as expected when released

---

## 🔄 Continuous Improvement

**DoD is a living document:**
- Review quarterly or after major incidents
- Add new criteria based on lessons learned
- Remove outdated or non-valuable checks
- Adapt to team maturity and project needs

**Reflection Protocol:**
- After EVERY task completion, update `reflection.log.md` with:
  - What went well
  - What could be improved
  - New patterns discovered
  - Updates needed to DoD

---

**Last Updated:** 2026-01-15
**Maintained By:** Claude Agent + Team
**Version:** 1.0
**Status:** Active

**COMMITMENT:** No task is marked "done" until ALL DoD criteria are met.

---

## 🔀 Parallel Agent Coordination Criteria (NEW - 2026-01-20)

**Applies when:** Multiple Claude agents are running simultaneously (agentCount > 1)

### Before Starting Work

- [ ] **Activity context checked**
  - `monitor-activity.ps1 -Mode context` executed
  - Agent count determined
  - User focus state identified
  - Priority assigned (user-focused = 100, background = 50)

- [ ] **Coordination strategy selected**
  - < 3 agents → Optimistic allocation (fast path)
  - ≥ 3 agents → Pessimistic allocation with jitter (slow path)
  - Strategy documented in allocation log

- [ ] **Conflict detection passed**
  - `check-branch-conflicts.sh` executed successfully
  - No conflicts found (exit code 0)
  - If conflicts found → STOP, use different branch name

- [ ] **Heartbeat prepared** (if multi-agent)
  - Heartbeat mechanism ready to start
  - Heartbeat file location verified: `C:\scripts\_machine\heartbeats\<agent-id>.heartbeat`

### During Work

- [ ] **Heartbeat active** (if multi-agent)
  - Heartbeat updating every 10-60 seconds
  - Heartbeat includes: timestamp, PID, status, active allocations
  - No heartbeat stale warnings

- [ ] **No conflicts with other agents**
  - Working on unique branch (not used by others)
  - Worktree exclusively allocated to this agent
  - No duplicate allocation detected

- [ ] **Proper strategy used**
  - Followed optimistic or pessimistic path as determined
  - Added jitter if pessimistic (random 0-500ms delay)
  - Respected priority assignments

### After Work Complete

- [ ] **Metrics logged**
  - Allocation latency recorded
  - Strategy used logged (optimistic/pessimistic)
  - Agent count at time of allocation logged
  - Priority level logged
  - Any conflicts encountered logged

- [ ] **Heartbeat stopped**
  - Background heartbeat job terminated
  - Heartbeat file removed or marked inactive
  - No orphaned heartbeat processes

- [ ] **Validation passed**
  - Pool state consistent with git reality
  - No duplicate allocations detected
  - Agent properly unregistered from coordination system
  - No stale state left behind

### Quality Metrics (Target Values)

- [ ] **Allocation success rate** ≥ 95%
  - Your allocations succeed without conflicts
  - Retry count ≤ 3 per allocation

- [ ] **Allocation latency** (p99) < 10 seconds
  - Time from allocation start to worktree ready
  - Includes conflict detection, pool check, git worktree creation

- [ ] **Conflict rate** < 1%
  - Percentage of allocations that encounter conflicts
  - Zero duplicate allocations

- [ ] **Zero coordination violations**
  - No allocations without conflict detection
  - No releases without proper cleanup
  - No orphaned allocations
  - No stale heartbeats

### Troubleshooting Checklist

If coordination issues encountered:

- [ ] **Issue logged in reflection.log.md**
  - Root cause identified
  - Resolution documented
  - Prevention strategy defined

- [ ] **System state verified**
  - Pool.md consistent
  - Instances.map.md accurate
  - Activity.md complete
  - No corrupted state files

- [ ] **Validation run**
  - Manual validation executed: `Invoke-CoordinationValidation`
  - All issues auto-repaired or manually fixed
  - System health confirmed

---

## 🎯 Integration with Existing DoD

**Parallel coordination criteria AUGMENT existing DoD, not replace:**

- Use **General DoD** (original sections) for code quality, testing, PR, deployment
- Use **Coordination DoD** (this section) when multiple agents are running
- **Both must be satisfied** for task to be considered DONE

**Decision Flow:**
```
Task complete?
  ↓
General DoD satisfied? (code quality, tests, PR, etc.)
  ↓ YES
Agent count > 1?
  ↓ YES
Coordination DoD satisfied? (heartbeat, metrics, no conflicts, etc.)
  ↓ YES
✅ TASK IS DONE
```

**Single Agent Sessions:**
- General DoD only (skip coordination criteria)
- Faster completion (no coordination overhead)

**Multi-Agent Sessions:**
- General DoD + Coordination DoD
- Ensures no conflicts, proper metrics, clean handoff

---

---

## 📚 See Also

**Core workflow documentation:**
- **Zero Tolerance Rules:** `C:\scripts\GENERAL_ZERO_TOLERANCE_RULES.md` - Pre-flight checklists
- **Dual-Mode Workflow:** `C:\scripts\GENERAL_DUAL_MODE_WORKFLOW.md` - Feature vs Debug mode
- **Worktree Protocol:** `C:\scripts\GENERAL_WORKTREE_PROTOCOL.md` - Complete allocation protocol
- **Git Workflow:** `C:\scripts\git-workflow.md` - PR dependencies and merge rules
- **Software Principles:** `C:\scripts\_machine\SOFTWARE_DEVELOPMENT_PRINCIPLES.md` - Boy Scout Rule, SOLID

**Parallel coordination:**
- **System Integration:** `C:\scripts\_machine\SYSTEM_INTEGRATION.md` - Complete coordination protocol
- **Coordination Troubleshooting:** `C:\scripts\_machine\COORDINATION_TROUBLESHOOTING.md` - Quick fixes

**Automation tools for DoD validation:**
- **Pre-commit checks:** `C:\scripts\tools\pre-commit-hook.ps1`
- **Migration validation:** `C:\scripts\tools\validate-migration.ps1`, `ef-preflight-check.ps1`
- **PR validation:** `C:\scripts\tools\pr-description-enforcer.ps1`
- **Deployment risk:** `C:\scripts\tools\deployment-risk-score.ps1`
- **Health check:** `C:\scripts\tools\health-check.ps1`

**External systems:**
- **ClickUp Integration:** `C:\scripts\_machine\knowledge-base\04-EXTERNAL-SYSTEMS\clickup-structure.md`
- **GitHub Integration:** `C:\scripts\_machine\knowledge-base\04-EXTERNAL-SYSTEMS\github-integration.md`

**Last Updated:** 2026-01-25 (Added knowledge base references)
**Added:** Parallel Agent Coordination criteria (2026-01-20)
**Integration:** Mandatory when agentCount > 1
**Reference:** See `SYSTEM_INTEGRATION.md` for complete coordination protocol

