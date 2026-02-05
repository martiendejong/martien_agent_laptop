# Pattern: Feature Implementation

**Use when:** Adding a new feature to client-manager or hazina.

---

## Pre-Flight

```
□ Confirm we're in Feature Development Mode
□ User explicitly requested feature (not debugging)
□ Requirements are clear (or clarified via questions)
```

---

## Steps

### 1. Allocate Worktree

```powershell
.\tools\worktree-allocate.ps1 -Repo client-manager -Branch feature/<name> -Paired -Description "<description>"
```

### 2. Understand Context

```
□ Read relevant existing code
□ Identify files to modify
□ Identify files to create (if any)
□ Check for related patterns in reflection log
```

### 3. Implement

```
□ Create/modify backend code (if applicable)
□ Create/modify frontend code (if applicable)
□ Add any needed database migrations
□ Follow existing code patterns
```

### 4. Verify

```
□ Code compiles without errors
□ No obvious runtime issues
□ Follows coding conventions
```

### 5. Create PR

```powershell
# Commit
git -C <worktree-path> add -A
git -C <worktree-path> commit -m "feat: <description>"
git -C <worktree-path> push -u origin <branch>

# Create PR
gh pr create --title "feat: <description>" --body "..."
```

### 6. Release Worktree

```powershell
# Use release-worktree skill or:
.\tools\worktree-release-all.ps1 -Seats <seat> -AutoCommit
```

### 7. Present to User

```
□ Provide PR link
□ Summarize what was implemented
□ Note any follow-up items
```

---

## Template Commit Message

```
feat: <short description>

- <bullet point of change>
- <bullet point of change>

Closes #<issue-number> (if applicable)
```

---

## Template PR Body

```markdown
## Summary
<1-2 sentences describing the feature>

## Changes
- <file>: <what changed>
- <file>: <what changed>

## Testing
- [ ] Tested <scenario>
- [ ] Tested <scenario>

## Screenshots (if UI)
<screenshots>
```
