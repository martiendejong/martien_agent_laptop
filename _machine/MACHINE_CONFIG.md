# Machine Configuration

**Machine:** laptop (`win-c6osts73hta`)
**OS:** Windows 11 Pro
**Timezone:** Europe/Amsterdam
**Scripts root:** `C:\scripts`
**Documents:** `C:\jengo\documents`

---

## Paths (Fixed by Design)

| Path | Purpose |
|------|---------|
| `C:\scripts` | Agent scripts, tools, identity |
| `C:\scripts\_machine` | Machine context, config, state |
| `C:\Projects` | Source code repos |
| `C:\Projects\worker-agents` | Worktree pool (agent-001, agent-002, ...) |
| `C:\stores` | Config/data stores |
| `C:\jengo\documents` | Working documents, output, temp files |

---

## Cross-Machine Connectivity (Tailscale VPN)

Both machines are connected via Tailscale on the same network.

| Machine | Hostname | Tailscale IP | Bridge URL |
|---------|----------|-------------|-----------|
| laptop (this) | `win-c6osts73hta` | `100.96.143.109` | `http://100.96.143.109:9998` |
| desktop | `desktop-ecbaunu` | `100.90.208.67` | `http://100.90.208.67:9998` |

### Bridge System

**Port:** `9998` (all interfaces, `0.0.0.0`)
**Auth:** `X-Auth-Token` header required for POST/DELETE. Token in `C:\scripts\_machine\bridge-auth.token` and vault key `cross-machine-auth`.

**Start bridge:**
```powershell
powershell -ExecutionPolicy Bypass -File C:\scripts\tools\bridge-start.ps1
```

**Check status:**
```powershell
powershell -ExecutionPolicy Bypass -File C:\scripts\tools\bridge-status.ps1
```

**Send message to desktop:**
```powershell
powershell -ExecutionPolicy Bypass -File C:\scripts\tools\jengo-send.ps1 -To desktop -Message "Hello from laptop"
powershell -ExecutionPolicy Bypass -File C:\scripts\tools\jengo-send.ps1 -To desktop -Message "PR #123 merged" -Type notification
powershell -ExecutionPolicy Bypass -File C:\scripts\tools\jengo-send.ps1 -To desktop -Message "Need help with X" -Type request
```

**Check incoming messages:**
```powershell
powershell -ExecutionPolicy Bypass -File C:\scripts\tools\jengo-check.ps1          # unread
powershell -ExecutionPolicy Bypass -File C:\scripts\tools\jengo-check.ps1 -All     # all
powershell -ExecutionPolicy Bypass -File C:\scripts\tools\jengo-check.ps1 -From desktop  # from desktop
powershell -ExecutionPolicy Bypass -File C:\scripts\tools\jengo-check.ps1 -Mark    # show + mark read
```

### Bridge Files

| File | Purpose |
|------|---------|
| `C:\scripts\_machine\cross-machine-config.json` | Machine registry (IPs, ports) |
| `C:\scripts\_machine\bridge-auth.token` | Auth token (plain text, local read) |
| `C:\scripts\tools\cross-machine-bridge.py` | Bridge server (Python stdlib only) |
| `C:\scripts\tools\jengo-send.ps1` | Send message to remote machine |
| `C:\scripts\tools\jengo-check.ps1` | Check messages on local bridge |
| `C:\scripts\tools\bridge-start.ps1` | Start bridge + firewall rule |
| `C:\scripts\tools\bridge-status.ps1` | Check local + remote bridge status |

### Desktop Setup

On the desktop machine, after syncing `C:\scripts`:

1. Update `cross-machine-config.json`: set `"this_machine": "desktop"`
2. Copy the auth token: put the same token in `C:\scripts\_machine\bridge-auth.token`
3. Run: `bridge-start.ps1`

### Bridge API

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/health` | No | Health check + message counts |
| GET | `/identity` | No | Machine name, IP, uptime |
| GET | `/messages` | No | All messages (filter: `?from=`, `?to=`, `?status=`) |
| GET | `/messages/unread` | No | Unread messages (filter: `?from=`, `?to=`) |
| GET | `/messages/:id` | No | Single message |
| POST | `/messages` | Yes | Send message (`{from, to, content, type}`) |
| POST | `/messages/:id/read` | Yes | Mark message as read |
| POST | `/messages/read-all` | Yes | Mark all as read |
| DELETE | `/messages/:id` | Yes | Delete message |
| DELETE | `/messages` | Yes | Clear all messages |

---

## Worktree Policy

- All code changes occur in worktrees at `C:\Projects\worker-agents\agent-XXX\<repo>`
- Never edit `C:\Projects\<repo>` directly
- Idle worktrees (3+ days no activity) → notify user

## Services

| Service | Port | URL | Notes |
|---------|------|-----|-------|
| Hazina Orchestration | 5123 | https://localhost:5123 | NEVER redeploy without permission |
| Agentic Debugger | 27183 | http://localhost:27183 | VS Code control |
| UI Automation Bridge | 27184 | http://localhost:27184 | FlaUI desktop control |
| Claude Bridge (legacy) | 9999 | http://localhost:9999 | localhost only |
| Jengo Cross-Machine Bridge | 9998 | http://0.0.0.0:9998 | Tailscale-accessible |

---

*Last updated: 2026-03-09*
