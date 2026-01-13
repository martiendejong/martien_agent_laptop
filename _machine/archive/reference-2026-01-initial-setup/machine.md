
# machine.md (machine-wide canonical context)

## Identity
- Machine: <FILL>
- OS: Windows <FILL>
- Timezone: Europe/Amsterdam

## Paths (fixed by design)
- Scripts root: C:\scripts
- Machine context: C:\scripts\_machine
- Projects root: C:\Projects
- Worktrees root: C:\Projects\worker-agents
- Stores root: C:\stores

## Worktree policy
- All code changes occur in worktrees.
- Worktree naming:
  - Agent folder: agent-001, agent-002, ...
  - Worktree path: C:\Projects\worker-agents\agent-XXX\<repo>
- Branch policy:
  - Stable start branch per agent: agentXXX (e.g., agent001)
  - Feature branches: feature/<short-name>
  - PR target: develop (unless repo dictates otherwise)

## Debug/test policy
- Default: do NOT run repo from command line inside C:\Projects\<repo>.
- If testing/debugging requires C:\Projects, ask user permission and log it in:
  - C:\scripts\logs\permissions.log.md

## Idle worktree policy
- If a worktree has no recorded activity for <IDLE_DAYS> days (default 3):
  - Ask user to wrap up and release the worktree.
  - Do not reclaim automatically.

Set:
- IDLE_DAYS: 3

## Known tool integrations
- Visual Studio debugger bridge: see C:\scripts\claude_info.txt (source of truth)
- WordPress wp-cli wrapper: wp.bat (if present in scripts root)
