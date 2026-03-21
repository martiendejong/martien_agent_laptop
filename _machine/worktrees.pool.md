# worktrees.pool.md (machine-wide)
Allocation pool for worktree "seats". If all seats are BUSY, provision a new one.
Seat states:
- FREE / BUSY / STALE / BROKEN
| Seat | Agent start branch | Base repo path | Worktree root | Status | Current repo | Branch | Last activity (UTC) | Notes |
|---|---|---|---|---|---|---|---|---|
| agent-001 | agent001 | C:\Projects | C:\Projects\worker-agents\agent-001 | FREE | - | - | 2026-03-22T01:00:00Z | ✅ PR #914 (client-manager): Lead management foundation - CRUD API, dashboard, detail, pipeline (6 tasks resolved) |
| agent-002 | agent002 | C:\Projects | C:\Projects\worker-agents\agent-002 | FREE | - | - | 2026-03-21T12:45:00Z | ✅ PR #247 (seo-god): Import race condition fix — hangs + always shows import card (869ck0q7q, 869ck0q28) |
| agent-003 | agent003 | C:\Projects | C:\Projects\worker-agents\agent-003 | FREE | - | - | 2026-03-21T13:30:00Z | ✅ PR #246 (seo-god): AI blog ideas generation error handling (ClickUp #869ck0tek) |
| agent-004 | agent004 | C:\Projects | C:\Projects\worker-agents\agent-004 | FREE | - | - | 2026-03-21T14:00:00Z | ✅ PR #250 (seo-god): WP data persistence fix + account menu (869ck0rrp, 869ck0u7p) |
| agent-005 | agent005 | C:\Projects | C:\Projects\worker-agents\agent-005 | FREE | - | - | 2026-03-21T14:30:00Z | ✅ PR #249 (seo-god): FAQ generation page - top 10 pages sequential (869ck0ty1) |
| agent-006 | agent006 | C:\Projects | C:\Projects\worker-agents\agent-006 | FREE | - | - | 2026-03-21T15:30:00Z | ✅ PR #194 (real-estate-agency-ai): AI classification, security headers, CORS config (869cc94k3, 869cc94k0, 869cjgu1r) |
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
