
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
| agent-006 | agent006 | C:\Projects | C:\Projects\worker-agents\agent-006 | BUSY | client-manager | feature/quality-score-preview | 2026-01-08T07:45:00Z | Feature 1/10: Implementing Quality Score Preview (Quick Win #3) |
| agent-007 | agent007 | C:\Projects | C:\Projects\worker-agents\agent-007 | BUSY | client-manager | agent-007-phase1-test-infrastructure | 2026-01-08T08:30:00Z | Phase 1: Setting up test infrastructure + critical tests (React improvement plan) |
| agent-008 | agent008 | C:\Projects | C:\Projects\worker-agents\agent-008 | FREE | hazina | security/fix-all-code-scanning-alerts | 2026-01-09T06:00:00Z | ✅ PR #11 created - Fixed all 30 GitHub Code Scanning security alerts |

Provisioning rule:
1) Pick a FREE seat.
2) If none exist, append a new seat with next number and mark it FREE; log provision-seat.
3) Allocation must be recorded in worktrees.activity.md and instances.map.md.
