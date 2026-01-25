# Development Environment & Repositories - Index

**Location:** C:\scripts\_machine\knowledge-base\03-DEVELOPMENT\
**Purpose:** Git repositories, development workflows, coding standards, and version control practices
**Last Updated:** 2026-01-25

## Overview

This category documents the development environment configuration including git repositories, branch strategies, remote configurations, development workflows, and coding standards. This is the **SINGLE SOURCE OF TRUTH** for repository management.

**Strategic Importance:** Accurate repository knowledge enables:
- Correct git operations (fetch, push, pull, merge)
- Branch strategy enforcement (develop vs main)
- Cross-repo dependency management (client-manager ↔ hazina)
- Remote URL validation
- Development workflow adherence

---

## Files in This Category

### Git Repositories
**File:** `git-repositories.md`
**Purpose:** Complete inventory of all git repositories, remotes, branches, and configurations
**Size:** 910 lines (~36 KB)
**Status:** ✅ Complete
**Key Topics:**
- Repository inventory (client-manager, hazina, machine_agents)
- Remote configurations (origin, upstream)
- Default branches (develop for features, main for releases)
- Cross-repository dependencies
- Branch protection rules
- Git workflow patterns (git-flow, feature branches)
- Worktree integration (base repos vs worker agent seats)
- Repository health checks and validation

**Critical Repositories:**

| Repository | Location | Remote | Default Branch | Purpose |
|------------|----------|--------|----------------|---------|
| **client-manager** | C:\Projects\client-manager\ | github.com/martiendejong/brand2boost | develop | Primary SaaS application |
| **hazina** | C:\Projects\hazina\ | github.com/martiendejong/Hazina | develop | Framework library |
| **machine_agents** | C:\scripts\ | (private/user repo) | main | Control plane & tooling |

**Branch Strategy:**
- **develop** → Active development, feature PRs target here
- **main** → Production-ready, release tags
- **feature/*** → Feature branches (short-lived)
- **agent-XXX-*** → Agent worktree branches (auto-created, auto-deleted)
- **hotfix/*** → Emergency production fixes (target main)

**Critical Rules:**
- ✅ Base repos (C:\Projects\<repo>) ALWAYS on develop after PR
- ✅ Feature PRs ALWAYS target develop, NOT main
- ✅ Agent branches ALWAYS in worktrees, NEVER in base repos
- ❌ NEVER force push to develop or main
- ❌ NEVER commit directly to main (use PR workflow)

---

## Quick Reference

**Common Questions:**

| Question | Answer |
|----------|--------|
| What branch should base repos be on? | develop (ALWAYS after PR) - See git-repositories.md § Default Branches |
| Where do I create feature branches? | In worktrees (agent-XXX-feature-name) - See git-repositories.md § Worktree Integration |
| What's the PR target branch? | develop (for features/fixes) - See git-repositories.md § Branch Strategy |
| How do I handle cross-repo dependencies? | client-manager depends on hazina PRs - See git-repositories.md § Cross-Repository Dependencies |
| What's the remote URL for client-manager? | github.com/martiendejong/brand2boost - See git-repositories.md § Remote Configurations |
| Can I push to main? | NO - Use PR to develop, then release PR to main - See git-repositories.md § Branch Protection |

**Common Git Commands:**

```bash
# Check current branch (base repos should show 'develop')
cd C:\Projects\client-manager && git branch --show-current
cd C:\Projects\hazina && git branch --show-current

# Verify remote URLs
git remote -v

# Update base repos
git fetch origin
git checkout develop
git pull origin develop

# Check for uncommitted changes (should be zero in base repos)
git status --short

# Validate repository health
powershell -File "C:\scripts\tools\health-check.ps1" -CheckGit
```

---

## Cross-References

**Related Categories:**
- **02-MACHINE** → Repository file paths (file-system-map.md)
- **06-WORKFLOWS** → Git workflows, PR creation, branching strategies
- **07-AUTOMATION** → Git automation tools (worktree-*, git-*)
- **04-EXTERNAL-SYSTEMS** → GitHub integration (github-integration.md)

**Related Files:**
- `C:\scripts\GENERAL_WORKTREE_PROTOCOL.md` → Worktree management workflows
- `C:\scripts\git-workflow.md` → PR creation, cross-repo dependencies
- `C:\scripts\.claude\skills\github-workflow\SKILL.md` → GitHub workflow automation
- `C:\scripts\tools\worktree-status.ps1` → Repository state validation
- `C:\scripts\tools\prune-branches.ps1` → Branch cleanup automation

**Related Skills:**
- `allocate-worktree` → Create feature branches in worktrees
- `release-worktree` → Clean up after PR creation
- `github-workflow` → PR creation and management
- `pr-dependencies` → Cross-repo dependency tracking

---

## Search Tips

**Tags in this category:** `#git`, `#repositories`, `#version-control`, `#branches`, `#remotes`, `#development-workflow`, `#git-flow`

**Search examples:**
```bash
# Find repository locations
grep -r "C:\\\\Projects\\\\" C:\scripts\_machine\knowledge-base\03-DEVELOPMENT\

# Find branch strategy rules
grep -r "develop" C:\scripts\_machine\knowledge-base\03-DEVELOPMENT\git-repositories.md

# Find remote URLs
grep -r "github.com" C:\scripts\_machine\knowledge-base\03-DEVELOPMENT\

# Find cross-repo dependencies
grep -r "hazina" C:\scripts\_machine\knowledge-base\03-DEVELOPMENT\

# Validate current state
git -C "C:\Projects\client-manager" status
git -C "C:\Projects\hazina" status
```

---

## Maintenance

**Update triggers:**
- New repository cloned or added
- Remote URL changes (rare, but document immediately)
- Branch strategy changes (new branch types)
- Cross-repo dependency patterns discovered
- Repository moved or renamed
- Default branch changed (rare, critical update)

**Review frequency:**
- **After repository changes** - Update git-repositories.md immediately
- **Weekly** - Verify all repos on correct branches
- **Monthly** - Prune stale branches, validate remotes
- **After bootstrap** - Validate repository configurations

**Update protocol:**
1. Identify what changed (new repo, remote, branch strategy)
2. Update git-repositories.md with accurate information
3. Verify with `git remote -v` and `git branch -a`
4. Update cross-references if workflows affected
5. Run health-check.ps1 to validate git configuration
6. Commit to machine_agents repo

**Validation Commands:**
```powershell
# Verify all repositories exist and are accessible
Test-Path C:\Projects\client-manager\.git
Test-Path C:\Projects\hazina\.git
Test-Path C:\scripts\.git

# Check all repos are on expected branches
git -C "C:\Projects\client-manager" branch --show-current  # Should be 'develop'
git -C "C:\Projects\hazina" branch --show-current          # Should be 'develop'
git -C "C:\scripts" branch --show-current                  # Should be 'main'

# Verify no uncommitted changes in base repos (clean state)
git -C "C:\Projects\client-manager" status --short         # Should be empty
git -C "C:\Projects\hazina" status --short                 # Should be empty

# Check remotes are correct
git -C "C:\Projects\client-manager" remote get-url origin  # Should be brand2boost
git -C "C:\Projects\hazina" remote get-url origin          # Should be Hazina
```

---

## Success Metrics

**Git configuration is correct ONLY IF:**
- ✅ All repositories accessible and on correct default branches
- ✅ Base repos (C:\Projects\*) clean (no uncommitted changes)
- ✅ Remote URLs resolve correctly (can fetch/pull/push)
- ✅ Branch strategy followed (features in worktrees, base on develop)
- ✅ Cross-repo dependencies tracked accurately
- ✅ health-check.ps1 passes all git validation checks
- ✅ No "repository not found" or "remote not found" errors
- ✅ worktree-status.ps1 shows accurate pool state

---

## Development Workflow Integration

**This category integrates with:**

1. **Feature Development Mode** (06-WORKFLOWS)
   - Allocate worktree → create agent-XXX-feature branch
   - Work in worktree → commit to feature branch
   - Push → create PR to develop
   - Release worktree → switch base to develop

2. **Active Debugging Mode** (06-WORKFLOWS)
   - Work directly in base repo → stay on user's current branch
   - NO branch switching, NO worktree allocation
   - Let user handle commits and branch management

3. **PR Creation** (04-EXTERNAL-SYSTEMS/github-integration.md)
   - Verify base branch: develop
   - Check cross-repo dependencies (hazina)
   - Create PR with proper description
   - Track in pr-dependencies.md

4. **Multi-Agent Coordination** (06-WORKFLOWS)
   - Check for branch conflicts before allocation
   - Use worktrees to prevent base repo conflicts
   - Coordinate via worktrees.pool.md

---

**Status:** Active - Living Documentation
**Owner:** Claude Agent (Self-maintaining)
**Quality:** HIGH - Validated against actual git state
**Next Review:** After next repository change or workflow update
**Critical:** YES - Incorrect git configuration causes workflow violations
