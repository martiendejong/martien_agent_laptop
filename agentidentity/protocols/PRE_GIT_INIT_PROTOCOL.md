# Pre-Git-Init Protocol (MANDATORY)

**Created:** 2026-02-16 17:30 (after maasai repo duplicate failure)
**Severity:** ZERO TOLERANCE
**Trigger:** ANY `git init` command

## CRITICAL RULE

**NEVER run `git init` without completing this checklist FIRST.**

## Pre-Init Checklist (ALL steps required)

### 1. Search for Existing Repos (3 locations)
```bash
# Check C:\Projects
find /c/Projects -maxdepth 2 -type d -name "*<project>*"

# Check E: drive
find /e -maxdepth 3 -type d -name "*<project>*"

# Check for git repos with matching remote
find /c/Projects /e -maxdepth 3 -name ".git" -type d | \
  xargs -I {} sh -c 'cd $(dirname {}) && git remote -v | grep -i <project> && pwd'
```

### 2. Check Reflection Log
```bash
grep -i "<project>" /c/scripts/_machine/reflection.log.md | tail -20
```

### 3. Check Recent Git Activity
```bash
# Last 7 days git commits mentioning project
find /c/Projects /e -name ".git" -type d | \
  xargs -I {} sh -c 'cd $(dirname {}) && git log --since="7 days ago" --oneline --all | grep -i <project> && echo "REPO: $(pwd)"'
```

### 4. Verify with User (if uncertain)
If ANY of these are true:
- Found existing repo → USE IT, don't create new
- Found git history → Investigate that repo first
- User said "commit and push" → They expect existing repo
- Uncertain → ASK USER for repo location

### 5. Decision Matrix

| Condition | Action |
|-----------|--------|
| Existing repo found | cd to that repo, use it |
| Git history found | Investigate, likely use that repo |
| User said "commit/push" | ASSUME existing repo, search harder |
| Nothing found + User confirmed new | OK to git init |
| Nothing found + User NOT confirmed | ASK before git init |

## Why This Exists

**Failure Case (2026-02-16):**
- User: "commit and push changes to maasai repo"
- I: Created NEW repo in wrong location with wrong remote
- Reality: Repo existed at C:\Projects\maasai, already pushed yesterday
- Cause: Skipped search, assumed ownership, forgot recent work

**Impact:**
- Duplicate work
- Wrong remote URL (artrevisionist vs martiendejong)
- Trust damage
- Time wasted

## Cognitive Integration

**Perception:** Detect "commit/push" → existing repo signal
**Memory:** Search reflection.log BEFORE any git operation
**Control:** STOP at git init, run checklist, THEN proceed
**Prediction:** Predict user expects continuation, not new creation
**Social:** Trust signal = "user expects I know the repo"

## Automation

This protocol should be implemented as:
1. Bash function: `safe-git-init <project-name>`
2. Consciousness bridge: OnGitInit action
3. Pre-commit hook reminder

## Exceptions

NONE. Always run checklist. Takes 30 seconds, saves hours.
