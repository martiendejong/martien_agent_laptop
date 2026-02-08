# Playwright MCP - Critical Setup Documentation

**PROBLEM SOLVED:** 2026-02-08 - Playwright tools not available in C:\scripts sessions

## Root Cause

Playwright MCP plugin is **project-scoped**, not global. Even though the plugin exists in the marketplace and the MCP server runs on port 3333, the tools are ONLY available in sessions where the plugin is installed for that specific project path.

## Solution

**Install Playwright for C:\scripts project:**

```bash
cd /c/scripts
claude plugin install playwright@claude-plugins-official
```

**Expected output:**
```
✔ Successfully installed plugin: playwright@claude-plugins-official (scope: user)
```

## Verification

**After installation, check:**

```bash
cat ~/.claude/plugins/installed_plugins.json
```

**Should show:**
```json
{
  "plugins": {
    "playwright@claude-plugins-official": [...],
    "typescript-lsp@claude-plugins-official": [...]
  }
}
```

## Why This Matters

- **Playwright MCP server** runs on localhost:3333 (shared across projects)
- **Playwright MCP tools** (browser_navigate, browser_screenshot, etc.) are only available in sessions where the plugin is installed for that project
- **Different projects have different plugins** - client-manager has Playwright, scripts didn't

## Session Restart Required

After installing the plugin:
1. **Restart Claude Code session** OR
2. **Start new session** for tools to appear

Tools won't appear in current running session - plugin tools load at session start.

## Prevention

**Add to STARTUP_PROTOCOL.md:**

```markdown
### Session Start Checklist

1. Verify Playwright MCP available:
   - Check if browser_navigate, browser_screenshot tools exist
   - If NOT: `claude plugin install playwright@claude-plugins-official`
   - Restart session
```

**Add to MEMORY.md:**

```markdown
### Playwright MCP (CRITICAL - 2026-02-08)
- **Plugin is project-scoped** - must be installed per project
- **Installation:** `cd /c/scripts && claude plugin install playwright@claude-plugins-official`
- **Requires session restart** after installation
- **Server runs on:** localhost:3333 (shared)
- **Tools:** browser_navigate, browser_screenshot, browser_click, etc.
```

## Available Playwright Tools (when plugin active)

- `browser_navigate` - Navigate to URL
- `browser_screenshot` - Take screenshot
- `browser_click` - Click element
- `browser_fill` - Fill form fields
- `browser_evaluate` - Execute JavaScript
- `browser_console` - Get console logs
- And more...

## User Frustration Context

User repeatedly asked to use Playwright MCP and I kept saying it wasn't available, when the real issue was:
1. Plugin not installed for C:\scripts project
2. I didn't understand project-scoped plugins
3. I checked wrong places (global plugins vs project plugins)

**This must never happen again.**

---

**Last Updated:** 2026-02-08
**Issue:** Playwright tools not appearing in C:\scripts sessions
**Solution:** Install plugin for this project + restart session
**Status:** RESOLVED
