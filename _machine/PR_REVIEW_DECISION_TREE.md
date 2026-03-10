# PR Review Decision Tree
**QUICK REFERENCE FOR REVIEW VS MERGE DECISIONS**

---

## User Command → Action Mapping

```
User says "ga reviewen" or "review de PRs"
│
├─→ REVIEW-ONLY MODE
│   │
│   ├─ Allocate worktree
│   ├─ Check conflicts
│   ├─ Build & test
│   ├─ Analyze code
│   ├─ Post review comments to GitHub
│   ├─ Post summary to ClickUp
│   └─→ STOP HERE - DO NOT MERGE
│       │
│       └─ Present to user: "Reviewed 3 PRs. All approved. Ready for your decision."
│           │
│           └─ WAIT for user to say "merge"
```

```
User says "merge deze PRs" or "ga mergen"
│
├─→ MERGE MODE
│   │
│   ├─ Verify PRs were reviewed
│   ├─ Check which PRs to merge
│   ├─ Verify mergeable status
│   ├─ Execute gh pr merge
│   ├─ Update ClickUp status
│   └─ Confirm merge to user
```

```
User says "review en merge"
│
├─→ REVIEW-AND-MERGE MODE
│   │
│   ├─ Do complete review (as in REVIEW-ONLY)
│   ├─ If review APPROVED:
│   │   ├─ Merge PR to develop
│   │   └─ Update ClickUp to testing
│   │
│   └─ If review REJECTED:
│       ├─ Post issues found
│       ├─ DO NOT merge
│       └─ Update ClickUp to todo
```

```
User invokes "clickup-reviewer" skill
│
├─→ AUTOMATED REVIEW MODE
│   │
│   ├─ Find all tasks in "review" status
│   ├─ Review each task
│   ├─ If approved: Auto-merge
│   └─ If rejected: Move to todo
```

---

## Decision Matrix

| User Command | Mode | Review? | Comment? | Merge? | Wait? |
|--------------|------|---------|----------|--------|-------|
| "ga reviewen" | Manual | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes |
| "review de PRs" | Manual | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes |
| "check deze PRs" | Manual | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes |
| "merge deze PRs" | Merge-only | ⚠️ Quick check | ⚠️ Optional | ✅ Yes | ❌ No |
| "review en merge" | Review+Merge | ✅ Yes | ✅ Yes | ✅ If approved | ❌ No |
| "run automated reviewer" | Automated | ✅ Yes | ✅ Yes | ✅ If approved | ❌ No |
| Ambiguous command | ASK USER | ❓ Wait for clarification | | | |

---

## Keywords Guide

### Review-Only Keywords (DO NOT MERGE)
- reviewen
- review
- check
- kijk naar
- beoordeel
- analyseer

### Merge Keywords (OK TO MERGE)
- merge
- mergen
- ga mergen
- merge deze

### Combined Keywords (REVIEW THEN MERGE)
- review en merge
- reviewen en mergen
- als approved dan merge

---

## Critical Questions Before Merging

**Before executing `gh pr merge`:**

```
1. Did user explicitly say "merge"?
   └─ NO → DO NOT MERGE, STOP

2. Which PRs to merge?
   └─ Unclear → ASK USER

3. Am I in automated mode?
   └─ NO → DO NOT MERGE without explicit permission

4. Is PR approved?
   └─ NO → DO NOT MERGE

5. Are there conflicts or build errors?
   └─ YES → DO NOT MERGE
```

**If ANY answer triggers "DO NOT MERGE" → STOP and WAIT**

---

## Common Scenarios

### Scenario 1: User says "ga reviewen"
```
✅ CORRECT:
1. Review all PRs
2. Post comments
3. Present summary
4. STOP - wait for user

❌ WRONG:
1. Review all PRs
2. Post comments
3. Merge PRs ← VIOLATION
```

### Scenario 2: User says "merge PR #123"
```
✅ CORRECT:
1. Check PR #123 is approved
2. Verify mergeable
3. Execute gh pr merge 123
4. Confirm to user

❌ WRONG:
1. Review PR again (unnecessary)
2. Merge without checking status
```

### Scenario 3: User says "review and if ok merge"
```
✅ CORRECT:
1. Review PR
2. If APPROVED → Merge
3. If REJECTED → Post issues, don't merge

❌ WRONG:
1. Merge without reviewing
2. Review but ask before merging (explicit permission given)
```

### Scenario 4: Uncertain command
```
User: "what do you think of these PRs?"

✅ CORRECT:
Ask: "Do you want me to:
- Review and post comments only?
- Review and merge if approved?
- Just give quick opinion?"

❌ WRONG:
Assume intent and proceed
```

---

## STOP Gates (Never Skip)

```
Gate 1: After posting review comments
│
├─ In MANUAL mode?
│  └─ YES → STOP HERE, wait for "merge" command
│  └─ NO → Proceed to merge if approved
```

```
Gate 2: Before executing gh pr merge
│
├─ User said "merge"?
│  └─ NO → STOP, don't merge
│  └─ YES → Verify PR approved, then merge
```

---

## Related Files

- **Full Protocol:** C:\scripts\_machine\PR_REVIEW_PROTOCOL.md
- **Zero Tolerance:** C:\scripts\ZERO_TOLERANCE_RULES.md (Rule 3J)
- **Skill Documentation:** C:\scripts\.claude\skills\clickup-reviewer\SKILL.md
- **Memory:** MEMORY.md (Critical Failure entry 2026-02-28)
- **Reflection:** reflection.log.md (2026-02-28 22:30 entry)

---

**Last Updated:** 2026-02-28
**Purpose:** Quick reference to prevent unauthorized PR merges
