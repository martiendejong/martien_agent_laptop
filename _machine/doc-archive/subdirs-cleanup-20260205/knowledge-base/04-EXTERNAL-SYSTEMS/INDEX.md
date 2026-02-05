# External Systems Integration - Index

**Location:** C:\scripts\_machine\knowledge-base\04-EXTERNAL-SYSTEMS\
**Purpose:** Documentation for all external system integrations (GitHub, ClickUp, APIs, services)
**Last Updated:** 2026-01-25

## Overview

This category documents integrations with external systems that the agent interacts with programmatically. This includes GitHub (issues, PRs, actions), ClickUp (task management), and other third-party services.

**Strategic Importance:** Accurate external system knowledge enables:
- Automated PR creation and management
- Autonomous task tracking and updates
- Cross-system workflow orchestration
- API-driven integrations
- External context awareness

---

## Files in This Category

### GitHub Integration
**File:** `github-integration.md`
**Purpose:** GitHub API usage, gh CLI commands, PR workflows, issue management, GitHub Actions
**Size:** 1,187 lines (~47 KB)
**Status:** ✅ Complete
**Key Topics:**
- GitHub CLI (gh) command reference
- PR creation workflow (gh pr create, gh pr merge)
- Issue management (gh issue list, gh issue create)
- PR review and comments (gh pr review, gh pr comment)
- GitHub Actions integration (workflow triggers, status checks)
- Cross-repo PR dependencies (client-manager ↔ hazina)
- Authentication and token management
- Rate limiting and API best practices
- PR description templates and quality enforcement

**Critical Commands:**
```bash
# PR Creation
gh pr create --base develop \
  --title "feat: Feature description" \
  --body "..." \
  --repo martiendejong/brand2boost

# PR Management
gh pr list --state all --limit 10
gh pr view 123 --json baseRefName,headRefName,state
gh pr merge 123 --squash --delete-branch

# Issue Management
gh issue list --search "bug"
gh issue create --title "Bug: Description" --body "..."

# PR Reviews
gh pr review 123 --approve
gh pr review 123 --comment -b "Looks good!"
gh pr review 123 --request-changes -b "Fix needed"

# GitHub Actions
gh run list --workflow=ci.yml
gh run view --log
gh run rerun 123456789
```

**PR Description Template:**
```markdown
## Summary
<1-3 bullet points describing changes>

## Test Plan
- [ ] Unit tests pass
- [ ] Manual testing complete
- [ ] No regressions

## Dependencies
⚠️ **Depends on:** hazina#123 (if applicable)

🤖 Generated with Claude Code
```

**Cross-Repo Dependency Tracking:**
- client-manager PRs may depend on hazina PRs
- MUST add dependency alert in PR description
- Track in C:\scripts\_machine\pr-dependencies.md
- Merge order: hazina first, then client-manager

---

### ClickUp Integration
**File:** `clickup-structure.md`
**Purpose:** ClickUp workspace structure, task management, automation, API integration
**Size:** 1,182 lines (~47 KB)
**Status:** ✅ Complete
**Key Topics:**
- Workspace organization (spaces, folders, lists)
- Task structure (statuses, custom fields, tags)
- API integration (clickup-sync.ps1 tool)
- Automated task creation and updates
- Task prioritization and assignment
- Comment-based Q&A workflow
- Status transitions (todo → in_progress → complete)
- ClickUp CLI tools and automation

**Critical Tool:**
```powershell
# List tasks
powershell -File "C:\scripts\tools\clickup-sync.ps1" -Action list

# Create task
powershell -File "C:\scripts\tools\clickup-sync.ps1" -Action create `
  -TaskName "Feature: Description" `
  -Description "Detailed description"

# Update task status
powershell -File "C:\scripts\tools\clickup-sync.ps1" -Action update `
  -TaskId "abc123" `
  -Status "in_progress"

# Add comment
powershell -File "C:\scripts\tools\clickup-sync.ps1" -Action comment `
  -TaskId "abc123" `
  -Comment "Question or update"
```

**Workspace Structure:**
- **Space:** client-manager (Primary project space)
- **Lists:** Backlog, Sprint, In Progress, Done
- **Custom Fields:** Priority, Effort, Value, Dependencies
- **Tags:** #backend, #frontend, #infrastructure, #bug, #feature

**Autonomous Agent Integration:**
- **clickhub-coding-agent skill** - Autonomous task management
- Analyzes unassigned tasks
- Posts questions as comments for uncertainties
- Picks up todo tasks autonomously
- Executes code changes with worktree allocation
- Operates in continuous loop

**Status Workflow:**
```
todo → in_progress → in_review → done
         ↓
      blocked (with reason comment)
```

---

## Quick Reference

**Common Questions:**

| Question | Answer |
|----------|--------|
| How do I create a PR? | gh pr create --base develop --title "..." --body "..." - See github-integration.md § PR Creation |
| What's the PR target branch? | develop (always) - See github-integration.md § PR Workflow |
| How do I check CI status? | gh run list, gh run view --log - See github-integration.md § GitHub Actions |
| How do I create ClickUp task? | clickup-sync.ps1 -Action create - See clickup-structure.md § API Integration |
| What if PR depends on hazina? | Add dependency alert in PR body - See github-integration.md § Cross-Repo Dependencies |
| How do I update task status? | clickup-sync.ps1 -Action update -Status "in_progress" - See clickup-structure.md § Status Transitions |

---

## Cross-References

**Related Categories:**
- **03-DEVELOPMENT** → Git repositories (git-repositories.md)
- **06-WORKFLOWS** → PR creation workflow, task management workflow
- **07-AUTOMATION** → clickup-sync.ps1, github-related tools
- **09-SECRETS** → GitHub tokens, ClickUp API keys

**Related Files:**
- `C:\scripts\git-workflow.md` → PR creation process
- `C:\scripts\_machine\pr-dependencies.md` → Cross-repo dependency tracking
- `C:\scripts\.claude\skills\github-workflow\SKILL.md` → GitHub workflow automation
- `C:\scripts\.claude\skills\clickhub-coding-agent\SKILL.md` → Autonomous ClickUp task management
- `C:\scripts\tools\clickup-sync.ps1` → ClickUp API tool
- `C:\scripts\tools\pr-description-enforcer.ps1` → PR quality enforcement

**Related Skills:**
- `github-workflow` → PR creation, review, merge automation
- `pr-dependencies` → Cross-repo dependency management
- `clickhub-coding-agent` → Autonomous task pickup and execution

---

## Search Tips

**Tags in this category:** `#github`, `#gh-cli`, `#pull-requests`, `#issues`, `#github-actions`, `#clickup`, `#task-management`, `#api-integration`, `#external-systems`

**Search examples:**
```bash
# Find GitHub commands
grep -r "gh pr" C:\scripts\_machine\knowledge-base\04-EXTERNAL-SYSTEMS\

# Find ClickUp API usage
grep -r "clickup-sync.ps1" C:\scripts\_machine\knowledge-base\04-EXTERNAL-SYSTEMS\

# Find PR template
grep -r "Summary" C:\scripts\_machine\knowledge-base\04-EXTERNAL-SYSTEMS\github-integration.md

# Find dependency tracking
grep -r "Depends on" C:\scripts\_machine\knowledge-base\04-EXTERNAL-SYSTEMS\

# Check current PRs
gh pr list --state all --limit 10

# Check ClickUp tasks
powershell -File "C:\scripts\tools\clickup-sync.ps1" -Action list
```

---

## Maintenance

**Update triggers:**
- GitHub workflow changes (new PR templates, Actions)
- ClickUp workspace restructuring (new lists, custom fields)
- New external system integration added
- API endpoints or authentication changes
- Tool updates (gh CLI, clickup-sync.ps1)
- Cross-repo dependency patterns discovered

**Review frequency:**
- **After GitHub/ClickUp changes** - Update immediately
- **Weekly** - Verify API integrations working
- **Monthly** - Review automation effectiveness
- **After tool updates** - Validate command changes

**Update protocol:**
1. Identify what changed (GitHub/ClickUp/other system)
2. Update relevant file with new information
3. Test commands/API calls to verify accuracy
4. Update cross-references if workflows affected
5. Document any breaking changes prominently
6. Update tools if API changes require it

**Validation Commands:**
```powershell
# Test GitHub authentication
gh auth status

# Test GitHub PR operations
gh pr list --limit 1

# Test ClickUp integration
powershell -File "C:\scripts\tools\clickup-sync.ps1" -Action list

# Verify API tokens
$env:GH_TOKEN                          # Should be set
# ClickUp token in appsettings.Secrets.json
```

---

## Success Metrics

**External integrations working ONLY IF:**
- ✅ gh CLI authenticated and functional
- ✅ PR creation succeeds with correct base branch
- ✅ ClickUp API calls succeed (list, create, update)
- ✅ Cross-repo dependencies tracked accurately
- ✅ GitHub Actions status retrievable
- ✅ No authentication errors
- ✅ Rate limits not exceeded
- ✅ Autonomous task pickup working (clickhub-coding-agent)

---

## Integration Workflows

**This category enables:**

1. **Autonomous PR Creation** (06-WORKFLOWS/github-workflow)
   - Feature complete → Push to remote
   - gh pr create → PR with template
   - Add dependency alert if needed
   - Track in pr-dependencies.md
   - Release worktree

2. **Autonomous Task Management** (clickhub-coding-agent skill)
   - List unassigned tasks
   - Analyze task requirements
   - Post clarifying questions as comments
   - Pick up todo tasks
   - Allocate worktree
   - Execute code changes
   - Update task status
   - Loop continuously

3. **CI/CD Troubleshooting** (06-WORKFLOWS/ci-cd)
   - gh run list → Identify failures
   - gh run view --log → Analyze errors
   - Fix issues in worktree
   - Push → Trigger rerun
   - Verify success

4. **Cross-Repo Coordination** (pr-dependencies skill)
   - Track hazina → client-manager dependencies
   - Enforce merge order
   - Update pr-dependencies.md
   - Alert in PR descriptions

---

**Status:** Active - Living Documentation
**Owner:** Claude Agent (Self-maintaining)
**Quality:** HIGH - Tested with actual API calls
**Next Review:** After next GitHub or ClickUp change
**Critical:** YES - External integrations enable autonomous operation
