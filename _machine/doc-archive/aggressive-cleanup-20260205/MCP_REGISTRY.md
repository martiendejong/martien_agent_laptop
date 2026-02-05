# MCP Server Registry

**Central documentation of configured MCP (Model Context Protocol) servers.**

---

## Overview

MCP servers extend Claude's capabilities by providing access to external systems and APIs.

```
CONFIGURED MCP SERVERS
│
├── Google Drive (gdrive)
│   └── File search and access
│
├── Browser MCP
│   └── Frontend debugging
│
└── Agentic Debugger Bridge
    └── VS debugging control
```

---

## Active Servers

### 1. Google Drive (gdrive)

**Purpose:** Access files in Google Drive
**Status:** Active

**Capabilities:**
| Tool | Description |
|------|-------------|
| `mcp__gdrive__search` | Search for files by name/content |

**Configuration:**
- OAuth authentication required
- Credentials stored securely
- Access: Read files, search

**Usage Examples:**
```
# Search for files
Search query: "project proposal"
Search query: "2026 budget"
```

**Troubleshooting:**
- If auth fails: Re-run OAuth flow
- If rate limited: Wait and retry
- See: `mcp-setup` skill

---

### 2. Browser MCP

**Purpose:** Control browser for frontend debugging
**Status:** Available

**Capabilities:**
- Navigate to URLs
- Take screenshots
- Inspect elements
- Execute JavaScript

**Configuration:**
- Runs headless Chrome/Chromium
- Port: Default MCP port

**Usage:**
- Frontend application testing
- Screenshot capture
- Visual debugging

---

### 3. Agentic Debugger Bridge

**Purpose:** Control Visual Studio debugging sessions
**Status:** Available when VS running

**Endpoint:** `http://localhost:27183`

**Capabilities:**
| Endpoint | Description |
|----------|-------------|
| `GET /status` | Debugger status |
| `POST /breakpoint` | Set breakpoint |
| `POST /step` | Step execution |
| `GET /variables` | Inspect variables |
| `POST /continue` | Continue execution |

**Usage:**
```bash
# Check if debugger is active
curl http://localhost:27183/status

# Set breakpoint
curl -X POST http://localhost:27183/breakpoint \
  -H "Content-Type: application/json" \
  -d '{"file": "Program.cs", "line": 42}'
```

**Note:** Only available when user has Visual Studio running with the debugger bridge extension.

---

## Planned Servers

### Database Access
- **Purpose:** Query development databases
- **Status:** Planned
- **Capabilities:** Read-only SQL queries

### ClickUp Native
- **Purpose:** Native ClickUp integration
- **Status:** Using REST API instead
- **Note:** Current `clickup-sync.ps1` works well

### Slack/Teams
- **Purpose:** Team notifications
- **Status:** Planned
- **Capabilities:** Send messages, read channels

---

## Adding New MCP Servers

### Prerequisites
1. MCP server implementation
2. Authentication credentials
3. Configuration in Claude Code settings

### Setup Process
1. Install server: `npm install -g @mcp/server-name`
2. Configure auth: Follow server docs
3. Add to Claude Code: Update settings
4. Test: Verify tools appear
5. Document: Add entry to this registry

### Configuration Location
Claude Code MCP configuration:
- Windows: `%APPDATA%\Claude\settings.json`
- Linux: `~/.config/claude/settings.json`

---

## Security Notes

### Authentication
- OAuth tokens stored securely
- API keys in environment variables or secure storage
- Never commit credentials to git

### Access Control
- MCP servers run with limited permissions
- Read-only access preferred where possible
- Audit log of MCP tool usage

### Troubleshooting
| Issue | Solution |
|-------|----------|
| Server not appearing | Check Claude Code logs |
| Auth expired | Re-run authentication flow |
| Connection refused | Verify server is running |
| Rate limited | Implement backoff/retry |

---

## Tool Discovery

To list available MCP tools at runtime:
```
Use ListMcpResourcesTool to see all configured MCP resources
```

---

**Last Updated:** 2026-01-15
**Registry Version:** 1.0
