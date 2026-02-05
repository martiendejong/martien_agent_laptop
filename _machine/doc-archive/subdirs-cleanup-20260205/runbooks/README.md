# Runbooks

**Step-by-step recovery procedures for common failure scenarios.**

---

## Index

| Runbook | Scenario | Severity |
|---------|----------|----------|
| [worktree-stuck.md](./worktree-stuck.md) | Worktree in inconsistent state | Medium |
| [pool-desync.md](./pool-desync.md) | Pool.md doesn't match reality | Medium |
| [base-repo-dirty.md](./base-repo-dirty.md) | Base repo has uncommitted changes | Low |
| [build-cascade-failure.md](./build-cascade-failure.md) | Hundreds of build errors | High |
| [pr-stuck.md](./pr-stuck.md) | PR creation failed mid-way | Medium |

---

## When to Use Runbooks

1. **Automated recovery failed** - `system-health.ps1 -Fix` couldn't resolve
2. **Unknown state** - Not sure what went wrong
3. **User reported issue** - Following up on user feedback
4. **Post-incident** - After something broke

---

## Runbook Format

Each runbook follows this structure:

```markdown
# Title
## Symptoms
## Diagnosis
## Recovery Steps
## Prevention
## Related
```

---
