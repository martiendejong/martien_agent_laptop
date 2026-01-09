
# worktrees.pool.md (machine-wide)

Allocation pool for worktree "seats". If all seats are BUSY, provision a new one.

Seat states:
- FREE / BUSY / STALE / BROKEN

| Seat | Agent start branch | Base repo path | Worktree root | Status | Current repo | Branch | Last activity (UTC) | Notes |
|---|---|---|---|---|---|---|---|---|
| agent-001 | agent001 | C:\Projects | C:\Projects\worker-agents\agent-001 | BUSY | client-manager | agent-001-license-manager | 2026-01-08T06:00:00Z | Implementing License Manager feature |
| agent-002 | agent002 | C:\Projects | C:\Projects\worker-agents\agent-002 | BUSY | hazina | agent-002-context-compression | 2026-01-07T23:55:00Z | Implementing LLM context compression module |
| agent-003 | agent003 | C:\Projects | C:\Projects\worker-agents\agent-003 | BUSY | client-manager | improvement/CM-054-quality-scoring | 2026-01-08T20:30:00Z | Resolved PR #31 merge conflicts - Quality Scoring Model (TASK-006) |
| agent-004 | agent004 | C:\Projects | C:\Projects\worker-agents\agent-004 | BUSY | scp | agent-004-revolutionary-transformation | 2026-01-08T11:00:00Z | Transforming SCP into multi-agent superintelligence system |
| agent-005 | agent005 | C:\Projects | C:\Projects\worker-agents\agent-005 | BUSY | client-manager | agent-005-documentation-improvements | 2026-01-08T19:45:00Z | Adding 25 documentation files (ADRs, guides, best practices) |
| agent-006 | agent006 | C:\Projects | C:\Projects\worker-agents\agent-006 | BUSY | client-manager | bugfix/chat-issues | 2026-01-09T13:20:00Z | Documented 8 chat issues + worktree workflow (PR #60) |
| agent-007 | agent007 | C:\Projects | C:\Projects\worker-agents\agent-007 | FREE | client-manager | agent-008-security-hardening | 2026-01-10T13:00:00Z | ✅ PR #61: Resolved conflicts, fixed createContext error, fixed auth.test.ts (12 tests) - 41 pre-existing integration test failures remain |
| agent-008 | agent008 | C:\Projects | C:\Projects\worker-agents\agent-008 | FREE | - | - | 2026-01-10T14:30:00Z | ✅ Cleaned up: Deleted obsolete branch agent-008-tier1-features (planning doc only), Hazina content-hooks branch merged as PR #24 |
| agent-009 | agent009 | C:\Projects | C:\Projects\worker-agents\agent-009 | FREE | - | - | 2026-01-10T14:30:00Z | ✅ Cleaned up: Deleted obsolete branch test/integration-test-environment (PR #73 already merged) |
| agent-010 | agent010 | C:\Projects | C:\Projects\worker-agents\agent-010 | FREE | client-manager | agent-008-license-back-button | 2026-01-10T13:00:00Z | ✅ PR #63 complete: Fixed frontend tests (11), backend build error (SignalRGatheredDataNotifier), merged develop |
| agent-011 | agent011 | C:\Projects | C:\Projects\worker-agents\agent-011 | FREE | client-manager | feature/license-manager-back-button | 2026-01-10T14:00:00Z | ✅ PR #79 ready: Fixed PR base (main→develop), now MERGEABLE with 1 file changed |
| agent-012 | agent012 | C:\Projects | C:\Projects\worker-agents\agent-012 | FREE | client-manager | agent-012-tier1-implementation | 2026-01-10T08:00:00Z | ✅ PR #77: Tier 1 Quick Wins complete - 4 features integrated (Quality Score, Alt Text, Templates, Multi-Platform) |

Provisioning rule:
1) Pick a FREE seat.
2) If none exist, append a new seat with next number and mark it FREE; log provision-seat.
3) Allocation must be recorded in worktrees.activity.md and instances.map.md.
