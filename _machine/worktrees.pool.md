# worktrees.pool.md (machine-wide)
Allocation pool for worktree "seats". If all seats are BUSY, provision a new one.
Seat states:
- FREE / BUSY / STALE / BROKEN
| Seat | Agent start branch | Base repo path | Worktree root | Status | Current repo | Branch | Last activity (UTC) | Notes |
|---|---|---|---|---|---|---|---|---|
| agent-001 | agent001 | C:\Projects | C:\Projects\worker-agents\agent-001 | BUSY | client-manager | agent-001-orchestrator-integration | 2026-01-16T15:00:00Z | 🚧 Week 1-2: Integrating BackgroundTaskOrchestrator into Image/Blog/Analysis generation services |
| agent-002 | agent002 | C:\Projects | C:\Projects\worker-agents\agent-002 | BUSY | hazina+client-manager+artrevisionist | agent-002-layered-image-* | 2026-01-21T02:00:00Z | 🚧 LayeredImageTool: Hazina #102 (vision-enhanced), client-manager #293 (headers), artrevisionist #33 (text detection) |
| agent-003 | agent003 | C:\Projects | C:\Projects\worker-agents\agent-003 | FREE | - | - | 2026-01-25T23:00:00Z | ✅ PR #356: Fixed all test failures - service extraction, integration tests (151/152 passing) |
| agent-004 | agent004 | C:\Projects | C:\Projects\worker-agents\agent-004 | FREE | - | - | 2026-01-25T21:15:00Z | ✅ PRs: Hazina #118, client-manager #373 - Social messaging integration (4 phases complete) |
| agent-005 | agent005 | C:\Projects | C:\Projects\worker-agents\agent-005 | FREE | - | - | 2026-01-25T20:57:00Z | ✅ PR #370: Welcome page i18n translations (5 languages: en, nl, de, es, fr) |
| agent-006 | agent006 | C:\Projects | C:\Projects\worker-agents\agent-006 | FREE | - | - | 2026-01-25T20:25:00Z | ✅ PR #369: Improve new project welcome screen UX |
| agent-007 | agent007 | C:\Projects | C:\Projects\worker-agents\agent-007 | FREE | - | - | 2026-01-25T21:15:00Z | ✅ PR #372: Fix image upload via paperclip (projectId prefix stripping) |
| agent-008 | agent008 | C:\Projects | C:\Projects\worker-agents\agent-008 | BUSY | client-manager | feature/869bwzx6q-fix-user-management-layout | 2026-01-25T21:20:00Z | 🚧 ClickHub #869bwzx6q: Fix user management screen layout (center positioning, full visibility) |
| agent-009 | agent009 | C:\Projects | C:\Projects\worker-agents\agent-009 | FREE | - | - | 2026-01-10T14:30:00Z | ✅ Cleaned up: Deleted obsolete branch test/integration-test-environment (PR #73 already merged) |
| agent-010 | agent010 | C:\Projects | C:\Projects\worker-agents\agent-010 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-008-license-back-button branch (obsolete) |
| agent-011 | agent011 | C:\Projects | C:\Projects\worker-agents\agent-011 | FREE | - | - | 2026-01-10T16:00:00Z | ✅ Cleaned up: License back button (PR #79 MERGED), worktree released |
| agent-012 | agent012 | C:\Projects | C:\Projects\worker-agents\agent-012 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-012-tier1-implementation (PR #77 already merged on 2026-01-09) |
Provisioning rule:
1) Pick a FREE seat.
2) If none exist, append a new seat with next number and mark it FREE; log provision-seat.
3) Allocation must be recorded in worktrees.activity.md and instances.map.md.
