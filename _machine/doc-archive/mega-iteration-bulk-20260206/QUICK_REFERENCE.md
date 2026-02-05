# Quick Reference - Top 20 Most Frequent User Requests

**Generated:** 2026-02-05
**Purpose:** One-line resolution paths for common requests
**Size:** < 2KB
**Usage:** Load at session start for instant answers

---

## 🔥 Top 20 Most Frequent User Requests

| # | User Request | Direct Resolution |
|---|--------------|-------------------|
| 1 | **"Fix build error"** | → `C:\scripts\_machine\DEFINITION_OF_DONE.md` § Phase 2 (build validation) |
| 2 | **"Create PR"** | → `C:\scripts\MANDATORY_CODE_WORKFLOW.md` § Step 6 (must merge develop first, --base develop) |
| 3 | **"Allocate worktree"** | → Invoke `allocate-worktree` skill OR `allocate-worktree.ps1` |
| 4 | **"Brand2boost credentials"** | → Username: `wreckingball`, Password: `Th1s1sSp4rt4!` |
| 5 | **"Arjan case"** | → `C:\arjan_emails\DEFINITIEVE_ANALYSE.md` |
| 6 | **"Marriage case / Sofy"** | → `C:\gemeente_emails\CONCLUSIE_VOOR_CORINA_EN_SUZANNE.md` |
| 7 | **"Generate image"** | → `ai-image.ps1 -Prompt "..." -OutputPath "..." -Quality "hd"` |
| 8 | **"What mode am I in?"** | → Run `detect-mode.ps1 -UserMessage $request -Analyze` |
| 9 | **"Check ClickUp task"** | → `clickup-sync.ps1 -Action get -TaskId <id>` |
| 10 | **"Release worktree"** | → Invoke `release-worktree` skill IMMEDIATELY after PR |
| 11 | **"Where is X stored?"** | → `C:\scripts\MACHINE_CONFIG.md` § Project locations |
| 12 | **"How do I...?"** | → `C:\scripts\_machine\PERSONAL_INSIGHTS.md` § Workflows |
| 13 | **"Pending migrations?"** | → `ef-preflight-check.ps1 -Context IdentityDbContext` |
| 14 | **"Check worktree status"** | → `C:\scripts\_machine\worktrees.pool.md` |
| 15 | **"Test in browser"** | → `claude-bridge-client.ps1 -Action send -Message "test request"` |
| 16 | **"What are zero tolerance rules?"** | → `C:\scripts\GENERAL_ZERO_TOLERANCE_RULES.md` |
| 17 | **"Definition of Done?"** | → `C:\scripts\_machine\DEFINITION_OF_DONE.md` |
| 18 | **"Multi-agent conflicts?"** | → `check-branch-conflicts.sh` (MANDATORY before allocation) |
| 19 | **"Update reflection log"** | → `C:\scripts\_machine\reflection.log.md` (add learning at session end) |
| 20 | **"Session startup?"** | → `C:\scripts\docs\claude-system\STARTUP_PROTOCOL.md` |

---

## 📂 Quick File Locations

| What | Where |
|------|-------|
| **Main docs index** | `C:\scripts\CLAUDE.md` |
| **Machine config** | `C:\scripts\MACHINE_CONFIG.md` |
| **User insights** | `C:\scripts\_machine\PERSONAL_INSIGHTS.md` |
| **Worktree protocol** | `C:\scripts\worktree-workflow.md` |
| **Git workflow** | `C:\scripts\git-workflow.md` |
| **Mandatory workflow** | `C:\scripts\MANDATORY_CODE_WORKFLOW.md` |
| **Reflection log** | `C:\scripts\_machine\reflection.log.md` |
| **Worktree pool** | `C:\scripts\_machine\worktrees.pool.md` |
| **Knowledge graph** | `C:\scripts\_machine\CONTEXT_KNOWLEDGE_GRAPH.yaml` |
| **Alias resolver** | `C:\scripts\_machine\ALIAS_RESOLVER.yaml` |

---

## 🎯 Quick Decision Trees

### "Should I allocate worktree?"
```
Is user actively debugging? → NO → Allocate worktree
                            → YES → Work in base repo (Active Debugging Mode)
```

### "What's the base branch for PR?"
```
ALWAYS: --base develop (NEVER main)
```

### "Should I create migration?"
```
Run: ef migrations has-pending-model-changes
Exit 0 → No migration needed
Exit 1 → CREATE MIGRATION NOW (do NOT create PR without it)
```

---

## ⚡ Critical Rules (Zero Tolerance)

1. **ALWAYS** specify `--base develop` when creating PR
2. **ALWAYS** add PR link to ClickUp task (Step 7)
3. **ALWAYS** release worktree IMMEDIATELY after PR
4. **ALWAYS** run `check-branch-conflicts.sh` before allocation
5. **NEVER** create PR with pending EF Core model changes
6. **NEVER** edit base repo (`C:\Projects\<repo>\`) in Feature Development Mode

---

## 🔧 Quick Tool Commands

```bash
# Allocate worktree
allocate-worktree.ps1 -Repo client-manager -Branch feature/new-thing

# Release worktree
release-worktree.ps1 -Repo client-manager

# ClickUp sync
clickup-sync.ps1 -Action update -TaskId 869... -Status "busy"
clickup-sync.ps1 -Action comment -TaskId 869... -Comment "PR: https://..."

# Check migrations
ef-preflight-check.ps1 -Context IdentityDbContext -ProjectPath C:\Projects\client-manager

# Generate image
ai-image.ps1 -Prompt "..." -OutputPath "C:\Projects\client-manager\output.png" -Quality "hd"

# Detect mode
detect-mode.ps1 -UserMessage "user's request" -Analyze

# Monitor activity
monitor-activity.ps1 -Mode context
```

---

## 🧠 Quick Patterns

| User says... | Means... |
|--------------|----------|
| "the app" | client-manager |
| "the framework" | hazina |
| "the store" | C:\stores\brand2boost |
| "Arjan" | C:\arjan_emails (legal case) |
| "Sofy" / "marriage" | C:\gemeente_emails (marriage case) |
| "brand2boost" | Usually client-manager (project), sometimes store |
| "b2b" | client-manager (short form) |

---

**Maintenance:** Update this file monthly based on session logs
**Last Updated:** 2026-02-05
**Improvement ID:** #2 (Frequent patterns quick reference)
