# worktrees.pool.md (machine-wide)
Allocation pool for worktree "seats". If all seats are BUSY, provision a new one.
Seat states:
- FREE / BUSY / STALE / BROKEN
| Seat | Agent start branch | Base repo path | Worktree root | Status | Current repo | Branch | Last activity (UTC) | Notes |
|---|---|---|---|---|---|---|---|---|
| agent-001 | agent001 | C:\Projects | C:\Projects\worker-agents\agent-001 | BUSY | client-manager | agent-001-orchestrator-integration | 2026-01-16T15:00:00Z | 🚧 Week 1-2: Integrating BackgroundTaskOrchestrator into Image/Blog/Analysis generation services |
| agent-002 | agent002 | C:\Projects | C:\Projects\worker-agents\agent-002 | BUSY | hazina+client-manager+artrevisionist | agent-002-layered-image-* | 2026-01-21T02:00:00Z | 🚧 LayeredImageTool: Hazina #102 (vision-enhanced), client-manager #293 (headers), artrevisionist #33 (text detection) |
| agent-003 | agent003 | C:\Projects | C:\Projects\worker-agents\agent-003 | BUSY | client-manager+hazina | agent-003-fix-all-test-failures | 2026-01-25T16:50:00Z | 🚧 Fix all 43 failing tests (integration DB provider conflict, unit test infrastructure, test/impl alignment) |
| agent-004 | agent004 | C:\Projects | C:\Projects\worker-agents\agent-004 | FREE | - | - | 2026-01-25T19:00:00Z | ✅ PR #362: Fix blog categories language translation |
| agent-005 | agent005 | C:\Projects | C:\Projects\worker-agents\agent-005 | FREE | - | - | 2026-01-25T16:07:00Z | ✅ PR #359: Add location/address prompt to workflow step 1 |
| agent-006 | agent006 | C:\Projects | C:\Projects\worker-agents\agent-006 | FREE | - | - | 2026-01-25T16:13:00Z | ✅ PR #360: Move Post Ideas Generator to Social Media section (UX fix) |
| agent-007 | agent007 | C:\Projects | C:\Projects\worker-agents\agent-007 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Security hardening (PR #61) and payment-models work completed and merged |
| agent-008 | agent008 | C:\Projects | C:\Projects\worker-agents\agent-008 | FREE | - | - | 2026-01-09T23:30:00Z | ✅ Fixed content hooks generation - pushed to client-manager payment-models branch (PR #82) |
| agent-009 | agent009 | C:\Projects | C:\Projects\worker-agents\agent-009 | FREE | - | - | 2026-01-10T14:30:00Z | ✅ Cleaned up: Deleted obsolete branch test/integration-test-environment (PR #73 already merged) |
| agent-010 | agent010 | C:\Projects | C:\Projects\worker-agents\agent-010 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-008-license-back-button branch (obsolete) |
| agent-011 | agent011 | C:\Projects | C:\Projects\worker-agents\agent-011 | FREE | - | - | 2026-01-10T16:00:00Z | ✅ Cleaned up: License back button (PR #79 MERGED), worktree released |
| agent-012 | agent012 | C:\Projects | C:\Projects\worker-agents\agent-012 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-012-tier1-implementation (PR #77 already merged on 2026-01-09) |
Provisioning rule:
1) Pick a FREE seat.
2) If none exist, append a new seat with next number and mark it FREE; log provision-seat.
3) Allocation must be recorded in worktrees.activity.md and instances.map.md.
