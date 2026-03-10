# ClickUp Task Execution Protocol

**Version:** 1.0 — 2026-03-10
**Purpose:** Authoritative reference for how to handle ClickUp tasks in `todo` or `feedback` status
**Summary in CLAUDE.md:** Section "ClickUp Task Execution Protocol"

---

## The Core Principle

Every task that comes to me in `todo` or `feedback` status must go through a full read → understand → implement → verify → PR → comment cycle before moving to `review`.

**There are no shortcuts.** A task is not done until:
- The work is implemented (or explained if no code is needed)
- A PR is open and reviewable (or a comment explains the exception)
- A ClickUp comment documents what happened and links the PR
- The status is moved to `review` only AFTER all of the above

---

## The Two Incoming Statuses

### `todo` — Fresh Work

A task in `todo` has not been started yet. No branch, no PR, no implementation.

**What to do:**
1. Read the task fully
2. Read all existing comments (there may be prior discussion even if no work was done)
3. Run clarity check — if requirements are ambiguous, post questions and move to `needs input`, STOP
4. If clear: allocate worktree, implement, PR, comment, move to `review`

### `feedback` — Came Back

A task in `feedback` was previously in `review` or `testing` and was sent back because:
- The reviewer found bugs
- The implementation didn't match requirements
- Something broke in testing
- Additional changes were requested

**What to do:**
1. Read the task fully — re-read, don't assume you remember it
2. Read ALL comments in chronological order — extract every piece of feedback
3. Build a mental (or written) checklist of every issue raised
4. Implement EVERY item on that list
5. Create a new PR (or push to existing branch if PR is still open)
6. Post a comment listing what was resolved
7. Move to `review`

---

## Phase-by-Phase Checklist

### Phase 1: Read & Understand

```
[ ] Read task title
[ ] Read full task description
[ ] Read acceptance criteria (if present)
[ ] Read ALL comments from oldest to newest
[ ] Note: what is the goal of this task?
[ ] Note: what has already been done (if anything)?
[ ] Note: what specific issues/requests are in the comments?
```

Do not skip comments. The last comment might be "actually ignore the previous feedback",
or the first comment might describe a constraint that changes everything.

### Phase 2: Determine Scenario

After reading everything, classify the task:

| Scenario | Condition | Action |
|----------|-----------|--------|
| A — Fresh todo | No prior branch, no PR, no code | Implement from scratch |
| B — Feedback | Prior work exists, comments have specific issues/requests | Resolve all feedback |
| C — No-PR exception | Task is handled without code changes | Do the action, post explanation comment |

**How to detect Scenario B:**
- Comments reference specific code, files, or behaviors
- Comments say "fix", "change", "doesn't work", "wrong", "please update"
- Task was previously in `review` or `testing`
- There is a linked PR (merged or closed) in the task

### Phase 3A: Implement (Fresh Todo)

1. **Clarity check** — if any requirement is unclear:
   - Post a comment on the ClickUp task listing specific questions
   - Move task to `needs input`
   - STOP — do not guess, do not implement partial work

2. **Allocate worktree** (use `allocate-worktree` skill):
   ```
   Repo: C:\Projects\<repo>
   Seat: agent-XXX (first FREE seat in worktrees.pool.md)
   Branch: feature/<task-name-slug>
   ```

3. **Implement** the feature/fix according to task description

4. **Verify locally** — build succeeds, relevant functionality works

5. **Commit** with message format:
   ```
   feat: <short description>

   Implements ClickUp task: <task-name>
   Task ID: <clickup-task-id>
   ```

### Phase 3B: Implement (Feedback)

1. **Extract all feedback items** from comments. For example:
   ```
   Feedback checklist from comments:
   - [comment 2026-03-09 by Marti] Button label says "Submit" should be "Save"
   - [comment 2026-03-09 by Marti] API returns 500 when name field is empty
   - [comment 2026-03-10 by reviewer] Missing loading state on form submit
   ```

2. **Address every item** — do not cherry-pick. If a comment seems minor, implement it anyway.

3. **If a comment is ambiguous:**
   - Post a reply in ClickUp asking for clarification
   - Do not implement a guess at what was meant
   - You can implement what is clear and ask about what isn't

4. **Allocate worktree** — even if a previous worktree existed, allocate fresh:
   ```
   Branch: fix/<task-name-slug>-v2  (or increment version)
   ```

5. **Commit** with message format:
   ```
   fix: address review feedback for <task-name>

   Resolved:
   - Fixed button label ("Submit" → "Save")
   - Handle empty name field in API (return 400 instead of 500)
   - Add loading state to form submit button

   Task ID: <clickup-task-id>
   ```

### Phase 3C: No-PR Exception

This applies when the task is resolved without a code PR (e.g., server config change,
content update, DNS change, manual deployment, infra setup).

1. Perform the action
2. Verify the result (screenshot, API call, manual test)
3. **Mandatory comment** must include:
   - What was done
   - How it was verified
   - Why there is no PR
   - Evidence (URL, screenshot reference, command output)

Example comment:
```
Completed without PR — this was a server configuration change.

Action: Updated CORS allowed origins in IIS application settings on production.
Verified: API call from app.brand2boost.nl to api.brand2boost.nl returns 200 (was 403).
No PR because: IIS config is managed outside of the codebase.
```

### Phase 4: Create PR

**For Scenarios A and B only.**

```bash
gh pr create \
  --title "<task name>" \
  --body "$(cat <<'EOF'
## What changed
- <bullet 1>
- <bullet 2>

## How to test
1. <step 1>
2. <step 2>

## ClickUp task
<task URL>

## Feedback addressed (Scenario B only)
- <feedback item 1> → resolved by <what you did>
- <feedback item 2> → resolved by <what you did>
EOF
)"
```

Verify PR was created:
```bash
gh pr view <pr-url> --json number,title,state
# Must return state: "OPEN"
```

### Phase 5: Post ClickUp Comment

**Mandatory before changing status.**

ClickUp comment API:
```bash
curl -X POST "https://api.clickup.com/api/v2/task/{task_id}/comment" \
  -H "Authorization: {api_key}" \
  -H "Content-Type: application/json" \
  -d '{
    "comment_text": "PR created: <pr-url>\n\nImplemented:\n- <bullet 1>\n- <bullet 2>\n\nReady for review."
  }'
# Must return HTTP 200
```

For Scenario B, the comment must also list which feedback was resolved:
```
PR created: https://github.com/org/repo/pull/123

Implemented:
- Fixed button label ("Submit" → "Save")
- Handle empty name field (returns 400 with error message)
- Loading spinner shown during form submit

Feedback resolved:
- Button label → done
- Empty field 500 error → done
- Missing loading state → done

Ready for review.
```

### Phase 6: Move to Review

**Only called after Phase 5 is confirmed.**

```bash
curl -X PUT "https://api.clickup.com/api/v2/task/{task_id}" \
  -H "Authorization: {api_key}" \
  -H "Content-Type: application/json" \
  -d '{"status": "review"}'
```

**Final gate — all must be true:**
```
[ ] Task description was fully read
[ ] All comments were read (oldest to newest)
[ ] All feedback items were addressed (Scenario B)
[ ] Work is implemented in a branch (Scenario A/B) OR action was completed (Scenario C)
[ ] PR is open and has correct content (Scenario A/B)
[ ] ClickUp comment was posted and returned 200 OK
[ ] Comment includes PR link (A/B) OR explanation of no-PR action (C)
```

If any box is unchecked: **do not change status, investigate what is missing first.**

---

## Status Flow

```
                    ┌─── needs input (unclear) ──┐
                    │                             │
todo ───────────────┤                             ├──→ review
                    └─── (work done, PR created) ─┘

feedback ──────────────── (all comments resolved,
                           new PR created) ────────→ review

review ────────────────── (PR merged) ─────────────→ testing  ← NEVER set manually

testing ───────────────── (user verified) ─────────→ done     ← user sets this
```

---

## Common Mistakes to Avoid

| Mistake | Why it's wrong | Correct action |
|---------|---------------|----------------|
| Moving task to `review` before PR is created | Board shows work done when nothing exists | Create PR first, then move |
| Moving task to `testing` manually | Testing requires a merged PR as evidence | Only moves there after PR is merged |
| Skipping old comments because "I know what this task is about" | Prior discussion may contradict your assumption | Always read all comments |
| Implementing only some feedback items | Task will just come back to feedback again | Address every single comment |
| Posting a vague comment ("done, moved to review") | No audit trail, reviewer can't see what changed | Always list what was implemented |
| Asking for clarity in a comment but moving status anyway | Task proceeds without answer | If clarity needed, move to `needs input` and STOP |

---

## API Quick Reference

```bash
# Get task details
curl "https://api.clickup.com/api/v2/task/{task_id}" \
  -H "Authorization: {api_key}"

# Get task comments
curl "https://api.clickup.com/api/v2/task/{task_id}/comment" \
  -H "Authorization: {api_key}"

# Post a comment
curl -X POST "https://api.clickup.com/api/v2/task/{task_id}/comment" \
  -H "Authorization: {api_key}" \
  -H "Content-Type: application/json" \
  -d '{"comment_text": "your comment here"}'

# Update status
curl -X PUT "https://api.clickup.com/api/v2/task/{task_id}" \
  -H "Authorization: {api_key}" \
  -H "Content-Type: application/json" \
  -d '{"status": "review"}'

# ClickUp config
API key: pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI
SEO God list ID: 901215927087
```
