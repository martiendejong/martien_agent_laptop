# worktrees.pool.md (machine-wide)
Allocation pool for worktree "seats". If all seats are BUSY, provision a new one.
Seat states:
- FREE / BUSY / STALE / BROKEN
| Seat | Agent start branch | Base repo path | Worktree root | Status | Current repo | Branch | Last activity (UTC) | Notes |
|---|---|---|---|---|---|---|---|---|
| agent-001 | agent001 | C:\Projects | C:\Projects\worker-agents\agent-001 | BUSY | artrevisionist-wordpress | agent-001-transparent-topic-cards-css | 2026-01-30T22:30:00Z | 🔄 Fix: Transparent background in b2bk-styles.css |
| agent-002 | agent002 | C:\Projects | C:\Projects\worker-agents\agent-002 | BUSY | hazina | agent-002-archive-session-restore | 2026-01-29T10:00:00Z | 🔄 Feature: Session restore button in Terminal Orchestrator archive view |
| agent-003 | agent003 | C:\Projects | C:\Projects\worker-agents\agent-003 | BUSY | hazina | agent-003-implement-hazinacoder-improvements | 2026-02-04T14:00:00Z | 🔄 Implement 50 improvements across 10 cycles (Cycle 1-10) |
| agent-004 | agent004 | C:\Projects | C:\Projects\worker-agents\agent-004 | FREE | - | - | 2026-02-04T17:00:00Z | ✅ PR #460: Post wizard enhancements (platforms, instruction, date) - 3 tasks combined |
| agent-005 | agent005 | C:\Projects | C:\Projects\worker-agents\agent-005 | FREE | - | - | 2026-02-04T16:05:00Z | ✅ PR #459: Improved scrollbar visibility to prevent fade-out |
| agent-006 | agent006 | C:\Projects | C:\Projects\worker-agents\agent-006 | BUSY | client-manager | agent-006-token-subscription-page | 2026-02-04T16:30:00Z | 🔄 Feature: Token Balance and Subscription page (ClickUp #869c0u02t) |
| agent-007 | agent007 | C:\Projects | C:\Projects\worker-agents\agent-007 | FREE | - | - | 2026-02-04T13:10:00Z | ✅ PR #456: Fix blog creation action (create vs edit view) |
| agent-008 | agent008 | C:\Projects | C:\Projects\worker-agents\agent-008 | FREE | - | - | 2026-02-04T13:25:00Z | ✅ PR #457: Fix first message no response (pendingMessageSentRef timing) |
| agent-009 | agent009 | C:\Projects | C:\Projects\worker-agents\agent-009 | FREE | - | - | 2026-01-10T14:30:00Z | ✅ Cleaned up: Deleted obsolete branch test/integration-test-environment (PR #73 already merged) |
| agent-010 | agent010 | C:\Projects | C:\Projects\worker-agents\agent-010 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-008-license-back-button branch (obsolete) |
| agent-011 | agent011 | C:\Projects | C:\Projects\worker-agents\agent-011 | FREE | - | - | 2026-01-10T16:00:00Z | ✅ Cleaned up: License back button (PR #79 MERGED), worktree released |
| agent-012 | agent012 | C:\Projects | C:\Projects\worker-agents\agent-012 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-012-tier1-implementation (PR #77 already merged on 2026-01-09) |
Provisioning rule:
1) Pick a FREE seat.
2) If none exist, append a new seat with next number and mark it FREE; log provision-seat.
3) Allocation must be recorded in worktrees.activity.md and instances.map.md.
