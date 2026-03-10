# PR Review Protocol
**MANDATORY WORKFLOW FOR ALL PR REVIEWS**
**EFFECTIVE:** 2026-02-28
**PURPOSE:** Prevent unauthorized PR merges

---

## CRITICAL DISTINCTION

**"review" ≠ "merge"**

These are TWO SEPARATE operations with different permissions:

| Operation | What it means | Permission required | Reversibility |
|-----------|---------------|---------------------|---------------|
| **REVIEW** | Analyze code, check conflicts, build/test, POST COMMENTS | User says "review" | Fully reversible (just comments) |
| **MERGE** | Execute `gh pr merge`, change develop branch | User says "MERGE" | Hard to reverse (requires revert commits) |

---

## USER COMMAND INTERPRETATION

### Commands that mean "REVIEW ONLY" (DO NOT MERGE):
- "ga reviewen"
- "review de PRs"
- "check deze PRs"
- "kijk naar de code"
- "beoordeel deze changes"
- "analyseer de PRs"

### Commands that mean "REVIEW AND MERGE" (EXPLICIT PERMISSION):
- "merge deze PRs"
- "ga mergen"
- "als review goed is, merge dan"
- "review en merge"
- "merge PR #123"
- "approved, merge it"

### When in doubt → ASK
If command is ambiguous:
```
Agent: "Je vroeg om te reviewen. Wil je dat ik na de review ook direct merge,
of wacht je liever op jouw beslissing na de review?"
```

---

## REVIEW-ONLY WORKFLOW

**When user says "review" WITHOUT merge permission:**

### Phase 1: Preparation
```
□ Read user command carefully - did they say "merge"? NO → Review-only mode
□ Identify all PRs to review (from ClickUp "review" status or GitHub)
□ Allocate worktree for EACH PR (one at a time)
□ Mark worktree BUSY in pool.md
```

### Phase 2: Technical Review (PER PR)
```
□ Allocate worktree: agent-XXX for this PR
□ Checkout PR branch in worktree
□ Check merge conflicts: gh pr view <num> --json mergeable,mergeStateStatus
□ If conflicts: Document conflicts, SKIP build/test, proceed to Phase 3
□ If clean: Merge develop into branch (in worktree)
□ Build backend: dotnet build --configuration Release
□ Build frontend: npm run build (if applicable)
□ Run tests: dotnet test (if applicable)
□ Document all results (build success/fail, test pass/fail, warnings)
```

### Phase 3: Code Quality Analysis
```
□ Review changed files: gh pr view <num> --json files
□ Check for:
  - Security issues (SQL injection, XSS, secrets in code)
  - Code quality (patterns, maintainability)
  - Breaking changes (API changes, database migrations)
  - Missing tests (new code without tests)
  - Documentation (README updates needed?)
```

### Phase 4: Post Review Comments
```
□ Compose comprehensive review comment with:
  ✅ Merge status (clean/conflicting)
  ✅ Build status (success/errors)
  ✅ Test status (passing/failing/none)
  ✅ Code quality assessment
  ✅ Issues found (if any)
  ✅ Recommendations
  ✅ Final verdict: APPROVED / APPROVED WITH COMMENTS / CHANGES REQUESTED

□ Post review to GitHub PR: gh pr comment <num> --body "<review>"
□ Post summary to ClickUp task
```

### Phase 5: Release Worktree
```
□ Clean worktree: rm -rf C:/Projects/worker-agents/agent-XXX/*
□ Mark worktree FREE in pool.md
□ Log release in worktrees.activity.md
```

### Phase 6: STOP AND WAIT
```
⏸️  CRITICAL STOP GATE - DO NOT PROCEED TO MERGE
⏸️  Present review summary to user
⏸️  WAIT for user decision
⏸️  User must explicitly say "merge" to proceed
```

**Review summary format:**
```
═══ REVIEW COMPLETE ═══

PR #581: WordPress Connection Wizard
- Merge status: 6 conflicts (resolved in review)
- Build: ✅ Success
- Tests: ⚠️  No tests (acceptable for UI work)
- Code quality: ✅ Good
- Verdict: ✅ APPROVED
- GitHub: Review posted with details

PR #576: A/B Testing
- Merge status: 3 conflicts (resolved in review)
- Build: ✅ Success
- Tests: ✅ Passing
- Code quality: ✅ Good
- Verdict: ✅ APPROVED
- GitHub: Review posted with details

PR #580: WooCommerce Product-to-Post
- Merge status: ✅ Clean
- Build: ✅ Success
- Tests: ✅ Passing
- Code quality: ✅ Good
- Verdict: ✅ APPROVED
- GitHub: Review posted with details

⏸️  WAITING FOR YOUR DECISION
All 3 PRs are approved. Ready to merge when you give permission.

Commands:
- "merge all" → Merge all 3 PRs
- "merge PR #581" → Merge only that one
- "hold" → Don't merge yet
```

---

## MERGE WORKFLOW

**ONLY execute this workflow when user explicitly says "merge":**

### Pre-Merge Checklist
```
□ User gave explicit merge command? (not just "review")
□ Which PRs to merge? (all? specific numbers?)
□ PR(s) passed review? (approved verdict)
□ No blocking issues found in review?
```

### Merge Execution (PER PR)
```
□ Verify PR still mergeable: gh pr view <num> --json mergeable
□ Execute merge: gh pr merge <num> --merge --delete-branch
□ Verify merge succeeded: check output
□ Update ClickUp task status:
  - client-manager: "review" → "testing"
  - hazina: "review" → "complete"
  - art-revisionist: "review" → "done"
□ Post merge confirmation comment on ClickUp
```

### Post-Merge Verification
```
□ Check develop branch: git -C C:/Projects/<repo> pull origin develop
□ Verify merged commit appears in develop
□ Check for any immediate CI failures on develop
```

---

## DECISION TREE

```
User command received
  ↓
Contains "merge"?
  ↓
├─ YES → Check: Also says "review"?
│    ↓
│    ├─ YES → REVIEW-AND-MERGE workflow
│    │         (Review first, THEN merge if approved)
│    │
│    └─ NO → MERGE-ONLY workflow
│              (Merge without full review, if PR already reviewed)
│
└─ NO → Contains "review"?
     ↓
     ├─ YES → REVIEW-ONLY workflow
     │         (Review, post comments, STOP, WAIT)
     │
     └─ NO → AMBIGUOUS
               ASK USER: "Review only, or also merge?"
```

---

## FORBIDDEN PATTERNS

❌ **NEVER:**
- Merge when user only said "review"
- Assume "review approved = auto-merge"
- Merge based on ClickUp status alone
- Skip posting review comments before merging
- Merge without checking current mergeable status
- Use --force or --no-verify flags
- Merge failing PRs
- Merge PRs with conflicts

✅ **ALWAYS:**
- Wait for explicit merge permission
- Post review comments BEFORE any merge
- Check mergeable status immediately before merge
- Update ClickUp task status AFTER merge
- Verify merge succeeded before marking done

---

## AUTOMATED REVIEWER VS MANUAL REVIEW

**Two different modes:**

### Automated Reviewer (clickup-reviewer skill)
- Runs on schedule or via "run automated reviewer"
- Configured with auto-merge permissions
- Can merge PRs automatically after review
- User has opted into automation

### Manual Review (user requests "ga reviewen")
- User explicitly asks for review
- User retains decision authority
- Agent NEVER auto-merges
- Agent STOPS after posting comments
- User decides when/if to merge

**Critical:** When user says "ga reviewen" this is MANUAL mode, NOT automated mode.

---

## FAILURE RECOVERY

**If you accidentally merged without permission:**

1. STOP immediately
2. Notify user: "I merged PR #XXX without explicit permission. This was a violation. The PR is now in develop."
3. Offer options:
   - "I can create a revert commit if needed"
   - "I can document what was merged"
   - "Should I proceed with other PRs or stop?"
4. Document in reflection.log.md
5. Update this protocol if new patterns emerge

**DO NOT:**
- Hide the mistake
- Continue merging other PRs
- Assume "it's fine, it was approved anyway"

---

## EXAMPLES

### Example 1: Review-Only (CORRECT)
```
User: "ga reviewen"

Agent:
1. Reviews 3 PRs
2. Posts review comments on GitHub
3. Posts summaries on ClickUp
4. Presents summary to user
5. STOPS and WAITS

Agent: "Reviewed 3 PRs. All approved. Ready for your merge decision."

User: "merge all"

Agent:
6. Executes gh pr merge for all 3
7. Updates ClickUp statuses
8. Confirms merges
```

### Example 2: Review-Only (CORRECT - with issues)
```
User: "check de PRs"

Agent:
1. Reviews 2 PRs
2. Finds build errors in PR #123
3. Posts review comment explaining errors
4. Posts ClickUp comment
5. STOPS

Agent: "Reviewed 2 PRs. PR #123 has build errors (see GitHub comment). PR #124 approved. Recommend fixing #123 before merging."

User: (fixes errors, then later) "merge PR #124"

Agent:
6. Merges only PR #124
7. Waits for user to fix and request merge of #123
```

### Example 3: VIOLATION (WRONG - what happened 2026-02-28)
```
User: "ga reviewen"

Agent:
1. Reviews 3 PRs
2. Posts review comments
3. Executes gh pr merge for all 3 ← ❌ VIOLATION
4. Updates ClickUp to "testing"

User: "je hebt zomaar taken gemerged terwijl ik vroeg om te reviewen"

→ This is the failure pattern this protocol prevents
```

---

## VERIFICATION CHECKLIST

**Before considering review complete:**
```
□ All PRs reviewed?
□ Review comments posted on GitHub?
□ Summary comments posted on ClickUp?
□ Summary presented to user?
□ Worktrees released?
□ Did I execute ANY gh pr merge commands?
   └─ If YES: Did user explicitly say "merge"?
      └─ If NO: ❌ VIOLATION - document and notify user
```

---

**Last Updated:** 2026-02-28
**Related:** ZERO_TOLERANCE_RULES.md (Rule 3J), clickup-reviewer skill
