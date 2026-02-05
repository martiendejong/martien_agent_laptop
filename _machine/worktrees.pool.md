# worktrees.pool.md (machine-wide)
Allocation pool for worktree "seats". If all seats are BUSY, provision a new one.
Seat states:
- FREE / BUSY / STALE / BROKEN
| Seat | Agent start branch | Base repo path | Worktree root | Status | Current repo | Branch | Last activity (UTC) | Notes |
|---|---|---|---|---|---|---|---|---|
| agent-001 | agent001 | C:\Projects | C:\Projects\worker-agents\agent-001 | BUSY | client-manager + hazina | feature/infinite-improvement-v1 | 2026-02-05T20:00:00Z | 🔄 Infinite improvement loop (1000 iterations) |
| agent-002 | agent002 | C:\Projects | C:\Projects\worker-agents\agent-002 | BUSY | artrevisionist + hazina | feature/phase0-database-foundation | 2026-02-05T04:30:00Z | 🏗️ Phase 0: PostgreSQL + domain models (Artwork/Artist/Provenance) |
| agent-003 | agent003 | C:\Projects | C:\Projects\worker-agents\agent-003 | FREE | - | - | 2026-02-05T05:30:00Z | ✅ PR #480: Rich Text Editor (TipTap) - Sprint #869c1dnx2 |
| agent-004 | agent004 | C:\Projects | C:\Projects\worker-agents\agent-004 | FREE | - | - | 2026-02-05T21:00:00Z | ⏸️ Search & filtering: Basics already implemented, noted advanced features needed |
| agent-005 | agent005 | C:\Projects | C:\Projects\worker-agents\agent-005 | BUSY | client-manager + hazina | agent-005-dark-mode | 2026-02-06T01:50:00Z | 🌙 Dark mode (ROI 4.00 - autonomous 3.5h) |
| agent-006 | agent006 | C:\Projects | C:\Projects\worker-agents\agent-006 | BUSY | hazina | feature/iteration-001-foundation | 2026-02-06T04:30:00Z | 🔄 Iteration 1/1000: Foundation improvements |
| agent-007 | agent007 | C:\Projects | C:\Projects\worker-agents\agent-007 | BUSY | client-manager + hazina | feature/869c1dnxx-ai-hashtag-suggestions-mvp | 2026-02-05T21:05:00Z | 🏷️ ClickUp #869c1dnxx: AI Hashtag Suggestions MVP |
| agent-008 | agent008 | C:\Projects | C:\Projects\worker-agents\agent-008 | FREE | - | - | 2026-02-04T13:25:00Z | ✅ PR #457: Fix first message no response (pendingMessageSentRef timing) |
| agent-009 | agent009 | C:\Projects | C:\Projects\worker-agents\agent-009 | FREE | - | - | 2026-01-10T14:30:00Z | ✅ Cleaned up: Deleted obsolete branch test/integration-test-environment (PR #73 already merged) |
| agent-010 | agent010 | C:\Projects | C:\Projects\worker-agents\agent-010 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-008-license-back-button branch (obsolete) |
| agent-011 | agent011 | C:\Projects | C:\Projects\worker-agents\agent-011 | FREE | - | - | 2026-01-10T16:00:00Z | ✅ Cleaned up: License back button (PR #79 MERGED), worktree released |
| agent-012 | agent012 | C:\Projects | C:\Projects\worker-agents\agent-012 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-012-tier1-implementation (PR #77 already merged on 2026-01-09) |
Provisioning rule:
1) Pick a FREE seat.
2) If none exist, append a new seat with next number and mark it FREE; log provision-seat.
3) Allocation must be recorded in worktrees.activity.md and instances.map.md.
