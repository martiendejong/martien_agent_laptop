# worktrees.pool.md (machine-wide)
Allocation pool for worktree "seats". If all seats are BUSY, provision a new one.
Seat states:
- FREE / BUSY / STALE / BROKEN
| Seat | Agent start branch | Base repo path | Worktree root | Status | Current repo | Branch | Last activity (UTC) | Notes |
|---|---|---|---|---|---|---|---|---|
| agent-001 | agent001 | C:\Projects | C:\Projects\worker-agents\agent-001 | BUSY | seo-god | fix/build-errors-869ck6xch-869ck6xw9 | 2026-03-22T21:30:00Z | Fix: Hazina compile errors + OpenAIService/WebSearch build failures (869ck6xch, 869ck6xw9) |
| agent-002 | agent002 | C:\Projects | C:\Projects\worker-agents\agent-002 | BUSY | seo-god | fix/auth-ui-bugs | 2026-03-22T21:30:00Z | Fix: date-fns, invisible buttons, error messages, /login route, auth/me 500, ToS links, /register (869ck6xcj,xcx,xcw,xcr,xcz,xd1,869ck764r) |
| agent-003 | agent003 | C:\Projects | C:\Projects\worker-agents\agent-003 | BUSY | seo-god | fix/feature-bugs | 2026-03-22T21:30:00Z | Fix: AI Blogs generate, importing hangs, content calendar layout (869ck0tek, 869ck0q7q, 869ck0tce) |
| agent-004 | agent004 | C:\Projects | C:\Projects\worker-agents\agent-004 | BUSY | seo-god | fix/ux-improvements | 2026-03-22T21:30:00Z | Fix: blog editor alignment, SEO analysis implement, source crawl all pages, no-website banner (869ck7c2e, 869ck7dt1, 869ck7dvh, 869ck765h) |
| agent-005 | agent005 | C:\Projects | C:\Projects\worker-agents\agent-005 | BUSY | seo-god | feature/content-tools | 2026-03-22T21:30:00Z | Feature: Unified Content Editor + Readability Scorer + Keyword Intent Classifier (869ck3j0k, 869ck3j0w, 869ck3j0j) |
| agent-006 | agent006 | C:\Projects | C:\Projects\worker-agents\agent-006 | BUSY | seo-god | feature/seo-tools | 2026-03-22T21:30:00Z | Feature: One-Click SEO Fix + Multi-Website Dashboard + GSC Keyword Ranking (869ck3j0b, 869ck3j19, 869ck3j1p) |
| agent-007 | agent007 | C:\Projects | C:\Projects\worker-agents\agent-007 | BUSY | seo-god | fix/ef-migration-debt+caching | 2026-03-22T21:45:00Z | Fix: EF Core migration tech debt cleanup + API response caching layer (869ck766g, 869ck3j17) |
| agent-008 | agent008 | C:\Projects | C:\Projects\worker-agents\agent-008 | BUSY | seo-god | feature/token-analytics+referral | 2026-03-22T21:45:00Z | Feature: Token usage analytics dashboard + Referral program infrastructure (869ck3j1f, 869ck3j1h) |
| agent-009 | agent009 | C:\Projects | C:\Projects\worker-agents\agent-009 | BUSY | seo-god | feature/title-abtester+pdf-report | 2026-03-22T21:45:00Z | Feature: AI Title A/B Tester + White-label PDF SEO Report (869ck3hzz, 869ck3j1c) |
| agent-010 | agent010 | C:\Projects | C:\Projects\worker-agents\agent-010 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-008-license-back-button branch (obsolete) |
| agent-011 | agent011 | C:\Projects | C:\Projects\worker-agents\agent-011 | FREE | - | - | 2026-01-10T16:00:00Z | ✅ Cleaned up: License back button (PR #79 MERGED), worktree released |
| agent-012 | agent012 | C:\Projects | C:\Projects\worker-agents\agent-012 | FREE | - | - | 2026-01-10T15:30:00Z | ✅ Cleaned up: Deleted agent-012-tier1-implementation (PR #77 already merged on 2026-01-09) |
Provisioning rule:
1) Pick a FREE seat.
2) If none exist, append a new seat with next number and mark it FREE; log provision-seat.
3) Allocation must be recorded in worktrees.activity.md and instances.map.md.
