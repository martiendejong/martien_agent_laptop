# Pattern: Cross-Repo Change

**Use when:** Change requires modifications to both Hazina and client-manager.

---

## Pre-Flight

```
□ Understand which repo is the "source" (usually Hazina)
□ Understand dependency direction (client-manager → Hazina)
□ Plan changes for both repos
```

---

## Steps

### 1. Allocate Paired Worktrees

```powershell
# CRITICAL: Use -Paired flag to get both repos in same seat with same branch
.\tools\worktree-allocate.ps1 -Repo client-manager -Branch <branch-name> -Paired
```

Result:
```
C:\Projects\worker-agents\agent-XXX\
├── client-manager\    ← Same branch
└── hazina\            ← Same branch
```

### 2. Implement Hazina Changes First

```
□ Add/modify models in Hazina
□ Add/modify services in Hazina
□ Verify Hazina compiles standalone
```

### 3. Implement client-manager Changes

```
□ Use new Hazina types/methods
□ Update UI if needed
□ Update API if needed
```

### 4. Verify Both Build

```powershell
# Build Hazina first
dotnet build C:\Projects\worker-agents\agent-XXX\hazina\Hazina.sln

# Then client-manager (references Hazina)
dotnet build C:\Projects\worker-agents\agent-XXX\client-manager\ClientManager.sln
```

### 5. Create Coordinated PRs

```powershell
# Hazina PR first
cd C:\Projects\worker-agents\agent-XXX\hazina
git add -A && git commit -m "feat: <description> (Hazina portion)"
git push -u origin <branch>
gh pr create --title "feat: <description>" --body "..."

# Note the PR number, then client-manager
cd ..\client-manager
git add -A && git commit -m "feat: <description> (client-manager portion)"
git push -u origin <branch>
gh pr create --title "feat: <description>" --body "**DEPENDS ON:** Hazina PR #<number>"
```

### 6. Update PR Dependencies

```powershell
# Update dependency tracker
# Edit C:\scripts\_machine\pr-dependencies.md
```

### 7. Release Worktrees

```powershell
.\tools\worktree-release-all.ps1 -Seats agent-XXX -AutoCommit
```

---

## Merge Order

**CRITICAL:** Always merge in this order:
1. Hazina PR first
2. Wait for CI to pass
3. Then merge client-manager PR

If merged out of order, client-manager build will fail.

---

## Template for Dependency Header

Add to client-manager PR body:

```markdown
## Dependencies

**DEPENDS ON:** [Hazina PR #XX](link-to-hazina-pr)

This PR requires the Hazina changes to be merged first. Do not merge until Hazina PR is merged.
```
