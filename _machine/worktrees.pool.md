# worktrees.pool.md (machine-wide)
Allocation pool for worktree "seats". If all seats are BUSY, provision a new one.
Seat states:
- FREE / BUSY / STALE / BROKEN
| Seat | Agent start branch | Base repo path | Worktree root | Status | Current repo | Branch | Last activity (UTC) | Notes |
|---|---|---|---|---|---|---|---|---|
| agent-001 | agent001 | C:\Projects | C:\Projects\worker-agents\agent-001 | BUSY | client-manager + hazina | fix/facebook-shares-property | 2026-02-05T04:47:00Z | 🔧 HOTFIX: ConnectedFacebookPost.Shares property missing (BLOCKS all PRs - CRITICAL) |
| agent-002 | agent002 | C:\Projects | C:\Projects\worker-agents\agent-002 | FREE | - | - | 2026-02-05T06:51:00Z | ✅ PR #50: Phase 0 PostgreSQL database foundation - Provenance-first architecture |
| agent-003 | agent003 | C:\Projects | C:\Projects\worker-agents\agent-003 | BUSY | client-manager + hazina | feature/infinite-improvement-v2 | 2026-02-05T04:40:00Z | 🔄 Infinite Improvement v2: 3.5hr autonomous session (Iterations 4+) |
| agent-004 | agent004 | C:\Projects | C:\Projects\worker-agents\agent-004 | BUSY | client-manager + hazina | feature/social-media-refactor-round-3 | 2026-02-06T05:10:00Z | 🔄 Round 3-1000: Social media module refactor marathon (split components, state machine, token refresh) |
| agent-005 | agent005 | C:\Projects | C:\Projects\worker-agents\agent-005 | FREE | - | - | 2026-02-05T04:52:00Z | ✅ Fixed PR #479 TwitterPreview.tsx syntax error (removed malformed XML tag) |
| agent-006 | agent006 | C:\Projects | C:\Projects\worker-agents\agent-006 | BUSY | hazina | feature/iteration-001-foundation | 2026-02-06T04:30:00Z | 🔄 Iteration 1/1000: Foundation improvements |
| agent-007 | agent007 | C:\Projects | C:\Projects\worker-agents\agent-007 | BUSY | client-manager + hazina | agent-007-ai-alt-text | 2026-02-06T07:10:00Z | 🖼️ AI Image Alt Text Generator (ROI 3.50 - Sprint 2/5) |
| agent-008 | agent008 | C:\Projects | C:\Projects\worker-agents\agent-008 | FREE | - | - | 2026-02-06T07:35:00Z | ✅ Hazina PR #174: Polly retry logic for LinkedInPublisher (Sprint 1 Task 3 enhancement) |
| agent-009 | agent009 | C:\Projects | C:\Projects\worker-agents\agent-009 | FREE | - | - | 2026-02-06T05:50:00Z | ✅ PR #484: Content Library UI Phase 1 (ClickUp #869c1dny3) |
| agent-010 | agent010 | C:\Projects | C:\Projects\worker-agents\agent-010 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-008-license-back-button branch (obsolete) |
| agent-011 | agent011 | C:\Projects | C:\Projects\worker-agents\agent-011 | FREE | - | - | 2026-01-10T16:00:00Z | ✅ Cleaned up: License back button (PR #79 MERGED), worktree released |
| agent-012 | agent012 | C:\Projects | C:\Projects\worker-agents\agent-012 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-012-tier1-implementation (PR #77 already merged on 2026-01-09) |
Provisioning rule:
1) Pick a FREE seat.
2) If none exist, append a new seat with next number and mark it FREE; log provision-seat.
3) Allocation must be recorded in worktrees.activity.md and instances.map.md.
