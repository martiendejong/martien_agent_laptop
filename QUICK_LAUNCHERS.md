# Quick Launchers - CTRL+R Commands

All launchers are in `C:\scripts\` and work immediately with CTRL+R.

## Available Commands

### Claude Agent & Notifications
| Command | Description | Full Path |
|---------|-------------|-----------|
| **`n`** | Notifications dashboard | `C:\scripts\n.bat` |
| **`c`** | Claude Agent control plane | `C:\scripts\c.bat` |

### Frontend Development Servers

| Command | Description | Project Location | Full Path |
|---------|-------------|------------------|-----------|
| **`cm`** | Client Manager (Brand2Boost) | `C:\Projects\client-manager\ClientManagerFrontend` | `C:\scripts\cm.bat` |
| **`ar`** | ArtRevisionist | `C:\Projects\artrevisionist\artrevisionist` | `C:\scripts\ar.bat` |
| **`bi`** | Bugatti Insights | `C:\Projects\bugattiinsights\sourcecode\frontend` | `C:\scripts\bi.bat` |

---

## Quick Usage

**Works Right Now (No Setup):**

1. Press `CTRL+R`
2. Type: `C:\scripts\<command>.bat` (e.g., `C:\scripts\cm.bat`)
3. Press Enter

**Examples:**
- `C:\scripts\n.bat` → Opens notifications dashboard
- `C:\scripts\c.bat` → Starts Claude Agent
- `C:\scripts\cm.bat` → Starts Client Manager frontend (npm run dev)
- `C:\scripts\ar.bat` → Starts ArtRevisionist frontend
- `C:\scripts\bi.bat` → Starts Bugatti Insights frontend

---

## Recommended: Add C:\scripts to PATH (One-Time Setup)

After adding `C:\scripts` to PATH, you can just type the short commands:

**CTRL+R → `n`** (notifications)
**CTRL+R → `c`** (claude agent)
**CTRL+R → `cm`** (client manager)
**CTRL+R → `ar`** (artrevisionist)
**CTRL+R → `bi`** (bugatti insights)

### Add to PATH (PowerShell as Admin):

```powershell
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\scripts",
    "User"
)
```

**Verify it worked:**
```cmd
echo %PATH% | findstr scripts
```

**Then restart any open terminals/CMD windows.**

---

## What Each Command Does

### `n` - Notifications Dashboard
- Opens `C:\Users\HP\notifications.html` in your default browser
- Shows all PRs, tasks, and items requiring your attention
- Auto-refreshes every 30 seconds

### `c` - Claude Agent
- Opens new CMD window
- Navigates to `C:\scripts`
- Runs `claude_agent.bat`
- Starts the autonomous agent control plane

### `cm` - Client Manager Frontend
- Opens new CMD window titled "Client Manager Frontend"
- Navigates to `C:\Projects\client-manager\ClientManagerFrontend`
- Runs `npm run dev`
- Starts Vite dev server (typically http://localhost:5173)

### `ar` - ArtRevisionist Frontend
- Opens new CMD window titled "ArtRevisionist Frontend"
- Navigates to `C:\Projects\artrevisionist\artrevisionist`
- Runs `npm run dev`
- Starts Vue/Vite dev server

### `bi` - Bugatti Insights Frontend
- Opens new CMD window titled "Bugatti Insights Frontend"
- Navigates to `C:\Projects\bugattiinsights\sourcecode\frontend`
- Runs `npm run dev`
- Starts frontend dev server

---

## Troubleshooting

### Command not found
- Make sure you're using the full path: `C:\scripts\cm.bat`
- Or add C:\scripts to PATH as shown above

### npm not found
- Ensure Node.js is installed and in PATH
- Check with: `node --version` and `npm --version`

### Wrong directory
- Launchers automatically `cd` to the correct project directory
- No need to navigate manually

### Port already in use
- If a frontend is already running, you'll get a port conflict
- Close the existing process or use the new window

---

## Adding More Launchers

To add a new quick launcher:

1. Create `C:\scripts\<short-name>.bat`
2. Use this template:
```batch
@echo off
REM Quick launcher for <Project Name>
REM Usage: CTRL+R → <short-name>
start "<Window Title>" cmd /k "cd /d <project-path> && <command>"
```

3. Update this file with the new command
4. Commit to machine_agents repo

**Example - Add Hazina test runner:**
```batch
@echo off
REM Quick launcher for Hazina Tests
REM Usage: CTRL+R → ht
start "Hazina Tests" cmd /k "cd /d C:\Projects\hazina && dotnet test"
```

---

## Summary

✅ **5 quick launchers created**
✅ **All work with CTRL+R immediately**
✅ **Short commands available after adding to PATH**
✅ **Each opens in its own window with proper title**
✅ **Automatically navigates to correct directory**

**Most used:** `n` (notifications), `c` (claude agent), `cm` (client manager)
