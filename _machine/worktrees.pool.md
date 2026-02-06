# worktrees.pool.md (machine-wide)
Allocation pool for worktree "seats". If all seats are BUSY, provision a new one.
Seat states:
- FREE / BUSY / STALE / BROKEN
| Seat | Agent start branch | Base repo path | Worktree root | Status | Current repo | Branch | Last activity (UTC) | Notes |
|---|---|---|---|---|---|---|---|---|
| agent-001 | agent001 | C:\Projects | C:\Projects\worker-agents\agent-001 | FREE | - | - | 2026-02-06T15:30:00Z | ✅ PR #5: Topic page/hero image field (separate from featured image) - ClickUp #869bz901c |
| agent-002 | agent002 | C:\Projects | C:\Projects\worker-agents\agent-002 | FREE | - | - | 2026-02-06T05:30:00Z | ✅ PR #175: HazinaCoder Top 5 High-ROI Improvements (10x Success Rate) |
| agent-003 | agent003 | C:\Projects | C:\Projects\worker-agents\agent-003 | FREE | - | - | 2026-02-06T19:12:00Z | ✅ Merged develop into fix/facebook-complete-integration (PR #503 already merged) |
| agent-004 | agent004 | C:\Projects | C:\Projects\worker-agents\agent-004 | FREE | - | - | 2026-02-05T17:55:31Z | ✅ PR #493 MERGED: Round 5 - Automatic OAuth token refresh |
| agent-005 | agent005 | C:\Projects | C:\Projects\worker-agents\agent-005 | FREE | - | - | 2026-02-05T05:04:00Z | ✅ PR #491: Integrations Dashboard - Comprehensive platform connection overview |
| agent-006 | agent006 | C:\Projects | C:\Projects\worker-agents\agent-006 | FREE | - | - | 2026-02-06T14:19:00Z | ✅ PR #173 MERGED: HazinaCoder Iterations 1-60 - Conflicts resolved & merged to develop |
| agent-007 | agent007 | C:\Projects | C:\Projects\worker-agents\agent-007 | FREE | - | - | 2026-02-06T08:00:00Z | ✅ PR #488: AI Image Alt Text Generator - Quick Win (ROI 3.50, ~1hr implementation) |
| agent-008 | agent008 | C:\Projects | C:\Projects\worker-agents\agent-008 | FREE | - | - | 2026-02-06T07:35:00Z | ✅ Hazina PR #174: Polly retry logic for LinkedInPublisher (Sprint 1 Task 3 enhancement) |
| agent-009 | agent009 | C:\Projects | C:\Projects\worker-agents\agent-009 | FREE | - | - | 2026-02-06T05:50:00Z | ✅ PR #484: Content Library UI Phase 1 (ClickUp #869c1dny3) |
| agent-010 | agent010 | C:\Projects | C:\Projects\worker-agents\agent-010 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-008-license-back-button branch (obsolete) |
| agent-011 | agent011 | C:\Projects | C:\Projects\worker-agents\agent-011 | FREE | - | - | 2026-01-10T16:00:00Z | ✅ Cleaned up: License back button (PR #79 MERGED), worktree released |
| agent-012 | agent012 | C:\Projects | C:\Projects\worker-agents\agent-012 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-012-tier1-implementation (PR #77 already merged on 2026-01-09) |
Provisioning rule:
1) Pick a FREE seat.
2) If none exist, append a new seat with next number and mark it FREE; log provision-seat.
3) Allocation must be recorded in worktrees.activity.md and instances.map.md.
