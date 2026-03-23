# worktrees.pool.md (machine-wide)
Allocation pool for worktree "seats". If all seats are BUSY, provision a new one.
Seat states:
- FREE / BUSY / STALE / BROKEN
| Seat | Agent start branch | Base repo path | Worktree root | Status | Current repo | Branch | Last activity (UTC) | Notes |
|---|---|---|---|---|---|---|---|---|
| agent-001 | agent001 | C:\Projects | C:\Projects\worker-agents\agent-001 | FREE | - | - | 2026-03-23T08:00:00Z | ✅ PR #290 fix/faq-url-crash-869ck7exk (EF Core LINQ crash fix) |
| agent-002 | agent002 | C:\Projects | C:\Projects\worker-agents\agent-002 | FREE | - | - | 2026-03-23T09:00:00Z | ✅ PR #291 feat/blog-image-media-picker-869ck7guu (Media Library + Upload tabs in blog editor image modal) |
| agent-003 | agent003 | C:\Projects | C:\Projects\worker-agents\agent-003 | FREE | - | - | 2026-03-23T00:20:00Z | ✅ PR #289 feat/faq-top10-sequential OPEN (869ck0ty1) |
| agent-004 | agent004 | C:\Projects | C:\Projects\worker-agents\agent-004 | FREE | - | - | 2026-03-23T00:30:00Z | ✅ PR #916 feat/token-cost-config (869chdufb) |
| agent-005 | agent005 | C:\Projects | C:\Projects\worker-agents\agent-005 | FREE | - | - | 2026-03-22T22:30:00Z | ✅ PR #278 (dependabot tiptap bump) + PR #285 (wordpress import + tiktok oauth) reviewed |
| agent-006 | agent006 | C:\Projects | C:\Projects\worker-agents\agent-006 | FREE | - | - | 2026-03-23T09:30:00Z | ✅ PR #278 merged (logo URL + keyword rankings fix), #291 merged (blog image picker), #290 closed (redundant) |
| agent-007 | agent007 | C:\Projects | C:\Projects\worker-agents\agent-007 | FREE | - | - | 2026-03-22T21:50:00Z | ✅ PR #270 fix/ef-migration-debt-caching MERGED |
| agent-008 | agent008 | C:\Projects | C:\Projects\worker-agents\agent-008 | FREE | - | - | 2026-03-22T23:15:00Z | ✅ PR #276 feat/token-analytics-referral (869ck3j1f, 869ck3j1h) |
| agent-009 | agent009 | C:\Projects | C:\Projects\worker-agents\agent-009 | FREE | - | - | 2026-03-22T23:45:00Z | ✅ PR #277 feat/title-abtester-pdf-report (869ck3hzz, 869ck3j1c) |
| agent-010 | agent010 | C:\Projects | C:\Projects\worker-agents\agent-010 | FREE | - | - | 2026-03-22T21:50:00Z | ✅ Used for conflict resolution (PRs 246,248,266,269,271,272,253) |
| agent-011 | agent011 | C:\Projects | C:\Projects\worker-agents\agent-011 | FREE | - | - | 2026-01-10T16:00:00Z | ✅ Cleaned up: License back button (PR #79 MERGED), worktree released |
| agent-012 | agent012 | C:\Projects | C:\Projects\worker-agents\agent-012 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-012-tier1-implementation (PR #77 already merged on 2026-01-09) |
Provisioning rule:
1) Pick a FREE seat.
2) If none exist, append a new seat with next number and mark it FREE; log provision-seat.
3) Allocation must be recorded in worktrees.activity.md and instances.map.md.
