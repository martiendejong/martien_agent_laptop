# Definition of Done (DoD) - ClickUp Format

**Copy this checklist to ClickUp tasks to ensure comprehensive completion.**

---

## ✅ DoD Checklist for All Tasks

### Development Phase
- [ ] Branch created from `develop` (not from feature branches)
- [ ] Code implemented according to requirements
- [ ] Unit tests written and passing (≥80% coverage)
- [ ] Manual testing completed locally
- [ ] Code formatted (C#: cs-format.ps1, TS/React: ESLint/Prettier)

### Quality Assurance Phase
- [ ] Build succeeds (backend: dotnet build, frontend: npm run build)
- [ ] All tests passing (unit + integration + E2E)
- [ ] Code review completed (1+ approval)
- [ ] Security scan passed (no new vulnerabilities)
- [ ] Performance validated (no significant degradation)

### Version Control Phase
- [ ] Code committed with meaningful messages (format: `<type>: <description>`)
- [ ] Branch pushed to remote (`git push -u origin <branch>`)
- [ ] Pull Request created with:
  - Clear title and description
  - Test plan included
  - Screenshots (for UI changes)
  - Dependencies documented (cross-repo PRs)
- [ ] PR base branch verified as `develop`
- [ ] PR approved by reviewer(s)
- [ ] All CI/CD checks passing

### Integration Phase
- [ ] PR merged to `develop`
- [ ] Develop branch updated locally
- [ ] CI/CD pipeline passed on develop branch

### Deployment Phase
- [ ] Deployed to staging (if applicable)
- [ ] Deployed to production
- [ ] Production verification completed
- [ ] Application health checks passing
- [ ] No critical errors in logs
- [ ] Rollback plan ready

### Documentation Phase
- [ ] User documentation updated (README, user guides)
- [ ] Technical documentation updated (API docs, architecture)
- [ ] CLAUDE.md updated with new patterns (if workflow changes)
- [ ] Changelog updated (version incremented if needed)
- [ ] Release notes prepared (for significant features)

### Communication Phase
- [ ] Stakeholder notified (user informed)
- [ ] Team members updated
- [ ] ClickUp task status: `done`
- [ ] ClickUp task completion date logged
- [ ] PR link added to ClickUp task
- [ ] Reflection log updated (`C:\scripts\_machine\reflection.log.md`)

---

## 🎯 Remember

**A task is NOT done until:**
- ✅ It's live in production
- ✅ It's working correctly
- ✅ It's documented
- ✅ It's verified

**"Works on my machine" ≠ Done**
**"PR merged" ≠ Done**
**"Deployed to staging" ≠ Done**

**DONE = In production + working + documented + verified**

---

## Project-Specific Additions

### Brand2Boost (client-manager)
- [ ] Paired worktree coordination (if Hazina changes included)
- [ ] Environment variables validated
- [ ] Database migrations applied (dev + production)
- [ ] Frontend + Backend compatibility verified

### Hazina Framework
- [ ] NuGet package versioning (if public release)
- [ ] Breaking changes documented in MIGRATION_GUIDE.md
- [ ] Client-manager compatibility verified
- [ ] Example code updated

---

**Full DoD Documentation:** `C:\scripts\_machine\DEFINITION_OF_DONE.md`
**Last Updated:** 2026-01-15
