
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
| agent-007 | agent007 | C:\Projects | C:\Projects\worker-agents\agent-007 | FREE | client-manager | agent-007-typescript-cleanup | 2026-01-10T05:45:00Z | ✅ Phase 2 complete - All TS6133 errors fixed (56→0), PR #70 updated |
| agent-008 | agent008 | C:\Projects | C:\Projects\worker-agents\agent-008 | BUSY | client-manager | agent-008-build-fixes | 2026-01-09T11:15:00Z | Fixing build errors for PR #61 |
| agent-009 | agent009 | C:\Projects | C:\Projects\worker-agents\agent-009 | BUSY | client-manager | test/integration-test-environment | 2026-01-10T05:35:00Z | Configuring test environment for integration tests |
| agent-010 | agent010 | C:\Projects | C:\Projects\worker-agents\agent-010 | BUSY | client-manager | feature/auth-integration-tests | 2026-01-09T12:10:00Z | Fixing build errors for PR #68 |
| agent-011 | agent011 | C:\Projects | C:\Projects\worker-agents\agent-011 | FREE | client-manager | fix/token-adjustment-null-error | 2026-01-09T16:30:00Z | ✅ Fixed NULL PasswordHash error in AdminGetAllUsers - PR #72 |

Provisioning rule:
1) Pick a FREE seat.
2) If none exist, append a new seat with next number and mark it FREE; log provision-seat.
3) Allocation must be recorded in worktrees.activity.md and instances.map.md.
