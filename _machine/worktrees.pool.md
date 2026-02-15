# worktrees.pool.md (machine-wide)
Allocation pool for worktree "seats". If all seats are BUSY, provision a new one.
Seat states:
- FREE / BUSY / STALE / BROKEN
| Seat | Agent start branch | Base repo path | Worktree root | Status | Current repo | Branch | Last activity (UTC) | Notes |
|---|---|---|---|---|---|---|---|---|
| agent-001 | agent001 | C:\Projects | C:\Projects\worker-agents\agent-001 | FREE | - | - | 2026-02-15T17:42:00Z | ✅ WordPress Publishing Provider MVP (PR #555) - Note: worktree locked, manual cleanup needed |
| agent-002 | agent002 | C:\Projects | C:\Projects\worker-agents\agent-002 | BUSY | client-manager | feature/869c3q8t3-ab-testing | 2026-02-16T00:35:00Z | A/B Testing for Posts (ClickUp #869c3q8t3) |
| agent-003 | agent003 | C:\Projects | C:\Projects\worker-agents\agent-003 | FREE | - | - | 2026-02-14T23:05:00Z | PR MERGED: Post Hub Refactoring (ClickUp #869c3q8k4) |
| agent-004 | agent004 | C:\Projects | C:\Projects\worker-agents\agent-004 | FREE | - | - | 2026-02-15T22:30:00Z | PR #571: Context Completeness Indicator (ClickUp #869bu9mer) |
| agent-005 | agent005 | C:\Projects | C:\Projects\worker-agents\agent-005 | FREE | - | - | 2026-02-15T16:10:00Z | PR #572: Prompt Builder Interface (ClickUp #869bu9meu) |
| agent-006 | agent006 | C:\Projects | C:\Projects\worker-agents\agent-006 | FREE | - | - | 2026-02-06T14:19:00Z | ✅ PR #173 MERGED: HazinaCoder Iterations 1-60 - Conflicts resolved & merged to develop |
| agent-007 | agent007 | C:\Projects | C:\Projects\worker-agents\agent-007 | FREE | - | - | 2026-02-06T08:00:00Z | ✅ PR #488: AI Image Alt Text Generator - Quick Win (ROI 3.50, ~1hr implementation) |
| agent-008 | agent008 | C:\Projects | C:\Projects\worker-agents\agent-008 | FREE | - | - | 2026-02-06T07:35:00Z | ✅ Hazina PR #174: Polly retry logic for LinkedInPublisher (Sprint 1 Task 3 enhancement) |
| agent-009 | agent009 | C:\Projects | C:\Projects\worker-agents\agent-009 | FREE | - | - | 2026-02-15T16:00:00Z | ✅ PR #567: WordPress Post Update Sync (ClickUp #869c3q8r1) |
| agent-010 | agent010 | C:\Projects | C:\Projects\worker-agents\agent-010 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-008-license-back-button branch (obsolete) |
| agent-011 | agent011 | C:\Projects | C:\Projects\worker-agents\agent-011 | FREE | - | - | 2026-01-10T16:00:00Z | ✅ Cleaned up: License back button (PR #79 MERGED), worktree released |
| agent-012 | agent012 | C:\Projects | C:\Projects\worker-agents\agent-012 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-012-tier1-implementation (PR #77 already merged on 2026-01-09) |
Provisioning rule:
1) Pick a FREE seat.
2) If none exist, append a new seat with next number and mark it FREE; log provision-seat.
3) Allocation must be recorded in worktrees.activity.md and instances.map.md.
