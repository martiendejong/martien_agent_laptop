# PR Creation Failed Mid-Way

## Severity: Medium

## Symptoms
- `gh pr create` failed partway through
- Branch pushed but no PR exists
- PR created but body/title missing
- GitHub API error during creation

## Diagnosis

```bash
# Check if branch was pushed
git branch -r | grep <branch-name>

# Check if PR exists
gh pr list --head <branch-name>

# Check PR status if exists
gh pr view <branch-name>
```

## Recovery Steps

### Case 1: Branch Not Pushed
```bash
git push -u origin <branch-name>
```

### Case 2: Branch Pushed, No PR
Create PR manually:
```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
- [Bullet points]

## Test plan
- [Checklist]

🤖 Generated with Claude Code
EOF
)"
```

### Case 3: PR Exists But Incomplete
Edit the existing PR:
```bash
gh pr edit <PR-number> --title "New title" --body "New body"
```

### Case 4: Network/API Error
Retry after brief wait:
```bash
# Wait 30 seconds then retry
gh pr create --title "<title>" --body "<body>"
```

### Case 5: Permission Error
Check authentication:
```bash
gh auth status
gh auth login  # If needed
```

## Post-Recovery
1. Update pool.md if worktree was released prematurely
2. Update HTML notifications if PR succeeded
3. Verify PR appears in GitHub

## Prevention

1. **Stable network** before creating PRs
2. **Prepare body in advance** (use heredoc)
3. **Don't interrupt** during PR creation
4. **Check gh auth** at session start

## Related
- [worktree-stuck.md](./worktree-stuck.md)
- [build-cascade-failure.md](./build-cascade-failure.md)
