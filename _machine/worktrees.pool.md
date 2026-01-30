# worktrees.pool.md (machine-wide)
Allocation pool for worktree "seats". If all seats are BUSY, provision a new one.
Seat states:
- FREE / BUSY / STALE / BROKEN
| Seat | Agent start branch | Base repo path | Worktree root | Status | Current repo | Branch | Last activity (UTC) | Notes |
|---|---|---|---|---|---|---|---|---|
| agent-001 | agent001 | C:\Projects | C:\Projects\worker-agents\agent-001 | BUSY | artrevisionist-wordpress | agent-001-transparent-topic-cards-css | 2026-01-30T22:30:00Z | 🔄 Fix: Transparent background in b2bk-styles.css |
| agent-002 | agent002 | C:\Projects | C:\Projects\worker-agents\agent-002 | BUSY | hazina | agent-002-archive-session-restore | 2026-01-29T10:00:00Z | 🔄 Feature: Session restore button in Terminal Orchestrator archive view |
| agent-003 | agent003 | C:\Projects | C:\Projects\worker-agents\agent-003 | FREE | - | - | 2026-01-30T22:50:00Z | ✅ PR #2 (plugin): Smaller featured image on topic page (merged) |
| agent-004 | agent004 | C:\Projects | C:\Projects\worker-agents\agent-004 | FREE | - | - | 2026-01-30T12:00:00Z | ✅ PR #142: Reduce startup tokens 95k→15k (84% reduction) |
| agent-005 | agent005 | C:\Projects | C:\Projects\worker-agents\agent-005 | BUSY | client-manager | agent-005-website-connect-api | 2026-01-30T21:50:00Z | 🔄 Phase 4: Backend API - Connect Website (ClickUp #869bzf5pn) |
| agent-006 | agent006 | C:\Projects | C:\Projects\worker-agents\agent-006 | FREE | - | - | 2026-01-25T20:25:00Z | ✅ PR #369: Improve new project welcome screen UX |
| agent-007 | agent007 | C:\Projects | C:\Projects\worker-agents\agent-007 | FREE | - | - | 2026-01-25T21:15:00Z | ✅ PR #372: Fix image upload via paperclip (projectId prefix stripping) |
| agent-008 | agent008 | C:\Projects | C:\Projects\worker-agents\agent-008 | FREE | - | - | 2026-01-26T00:15:00Z | ✅ PR #374: Fix user management screen layout (wider modal, Coins icon, gradient button) |
| agent-009 | agent009 | C:\Projects | C:\Projects\worker-agents\agent-009 | FREE | - | - | 2026-01-10T14:30:00Z | ✅ Cleaned up: Deleted obsolete branch test/integration-test-environment (PR #73 already merged) |
| agent-010 | agent010 | C:\Projects | C:\Projects\worker-agents\agent-010 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-008-license-back-button branch (obsolete) |
| agent-011 | agent011 | C:\Projects | C:\Projects\worker-agents\agent-011 | FREE | - | - | 2026-01-10T16:00:00Z | ✅ Cleaned up: License back button (PR #79 MERGED), worktree released |
| agent-012 | agent012 | C:\Projects | C:\Projects\worker-agents\agent-012 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-012-tier1-implementation (PR #77 already merged on 2026-01-09) |
Provisioning rule:
1) Pick a FREE seat.
2) If none exist, append a new seat with next number and mark it FREE; log provision-seat.
3) Allocation must be recorded in worktrees.activity.md and instances.map.md.
