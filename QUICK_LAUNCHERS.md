# Quick Launchers - CTRL+R Commands

All launchers are in `C:\scripts\` and work immediately with CTRL+R.

## Available Commands

### AI Agents & Dashboards
| Command | Description | Full Path |
|---------|-------------|-----------|
| **`n`** | Notifications dashboard | `C:\scripts\n.bat` |
| **`d`** | Work Tracking dashboard (real-time) | `C:\scripts\d.bat` |
| **`c`** | Claude Agent control plane | `C:\scripts\c.bat` |
| **`oc`** | OpenCode Agent control plane | `C:\scripts\oc.bat` |

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
- `C:\scripts\d.bat` → Opens work tracking dashboard (with WebSocket)
- `C:\scripts\c.bat` → Starts Claude Agent
- `C:\scripts\cm.bat` → Starts Client Manager frontend (npm run dev)
- `C:\scripts\ar.bat` → Starts ArtRevisionist frontend
- `C:\scripts\bi.bat` → Starts Bugatti Insights frontend

---

## Recommended: Add C:\scripts to PATH (One-Time Setup)

After adding `C:\scripts` to PATH, you can just type the short commands:

**CTRL+R → `n`** (notifications)
**CTRL+R → `d`** (work tracking dashboard)
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

### `d` - Work Tracking Dashboard
- Starts **WebSocket server** (ws://localhost:4243) for real-time updates
- Starts **HTTP server** (http://localhost:4242)
- Opens work tracking dashboard in your default browser
- **Features:**
  - Real-time updates (<100ms latency) via WebSocket
  - Dark/light theme toggle (`Ctrl+D`)
  - Keyboard shortcuts (press `?` to see all)
  - Search/filter agents and tasks (`Ctrl+K`)
  - Active work monitoring
  - Completed work history
  - Performance metrics
- Graceful fallback to 3s polling if WebSocket unavailable

### `c` - Claude Agent
- Opens new CMD window with **dynamic title**
- **Window title shows current git branch in ALL-CAPS** (e.g., "MAIN", "AGENT-002-ADD-PAGE-IMAGES")
- Falls back to "CLAUDE AGENT" if not in a git repository
- Navigates to `C:\scripts`
- Runs `claude_agent.bat`
- Starts the autonomous agent control plane
- **Benefit:** Prevents accidentally sending commands to wrong agent session

### `oc` - OpenCode Agent
- Opens new CMD window with **dynamic title**
- **Window title shows current git branch in ALL-CAPS** (same as Claude Agent)
- Falls back to "OPENCODE AGENT" if not in a git repository
- Navigates to `C:\scripts`
- Runs `opencode_agent.bat`
- Starts OpenCode in interactive TUI mode
- **Note:** OpenCode uses a different interface than Claude Code (TUI vs CLI)
- **Setup Guide:** See `C:\scripts\OPENCODE_SETUP.md` for configuration options
- **Benefit:** Alternative AI agent with access to same documentation and tools

### `cm` - Client Manager Frontend
- Opens new CMD window titled "Client Manager Frontend"
- Navigates to `C:\Projects\client-manager\ClientManagerFrontend`
- **Auto-validates node_modules** (runs npm install if corrupt)
- Runs `npm run dev`
- Starts Vite dev server (typically http://localhost:5173)

### `ar` - ArtRevisionist Frontend
- Opens new CMD window titled "ArtRevisionist Frontend"
- Navigates to `C:\Projects\artrevisionist\artrevisionist`
- **Auto-validates node_modules** (runs npm install if corrupt)
- Runs `npm run dev`
- Starts Vue/Vite dev server

### `bi` - Bugatti Insights Frontend
- Opens new CMD window titled "Bugatti Insights Frontend"
- Navigates to `C:\Projects\bugattiinsights\sourcecode\frontend`
- **Auto-validates node_modules** (runs npm install if corrupt)
- Runs `npm run dev`
- Starts frontend dev server

---

## 🪟 Dynamic Window Titles (New Feature - 2026-01-11)

**Claude Agent sessions now show their current branch name in the window title!**

### How It Works

When you run `claude_agent.bat` (via `c` command), the window title automatically updates to:

- **In a git repository:** Current branch name in **ALL-CAPS**
  - Examples: `MAIN`, `DEVELOP`, `AGENT-002-ADD-PAGE-IMAGES`, `FEATURE/NEW-FEATURE`

- **Outside git repository:** Falls back to `CLAUDE AGENT`

### Why This Matters

✅ **Prevents mistakes** - Easily identify which agent session you're working in
✅ **Visual distinction** - All-caps branch names stand out in the taskbar
✅ **Multi-session support** - Run multiple agents on different branches simultaneously
✅ **No more wrong-agent errors** - Window title shows exactly what branch you're on

### Example Workflow

```
# Session 1: Working on main branch
CTRL+R → c
Window title: "MAIN"

# Session 2: Working on feature branch (in another terminal)
cd C:\Projects\client-manager
git checkout agent-003-new-feature
CTRL+R → c
Window title: "AGENT-003-NEW-FEATURE"
```

Now you can easily tell your sessions apart and never send commands to the wrong agent!

---

## 🛡️ Auto-Validation (New Feature - 2026-01-15)

**All frontend launchers (cm, ar, bi) now automatically validate node_modules before starting!**

### How It Works

When you run any frontend launcher, it automatically:

1. **Checks node_modules health** using `npm list --depth=0`
2. **Auto-repairs if needed** by running `npm install`
3. **Starts dev server** once dependencies are validated

### Why This Matters

✅ **Prevents "vite is not recognized" errors** - Corrupt node_modules are fixed automatically
✅ **No manual intervention** - You don't need to remember to run npm install
✅ **Handles branch switches** - Auto-installs if dependencies changed
✅ **Recovers from interruptions** - Fixes incomplete npm install operations

### What You'll See

**Normal startup (node_modules OK):**
```
Checking node_modules...
[OK] Starting dev server...
> npm run dev
```

**Auto-repair (node_modules corrupt):**
```
Checking node_modules...
[WARNING] Running npm install...
(npm install output)
[OK] Starting dev server...
> npm run dev
```

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

### Auto-validation fails
- Close all VS Code instances and terminal windows
- Manually delete node_modules folder
- Run the launcher again (it will reinstall from scratch)

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

✅ **7 quick launchers created**
✅ **All work with CTRL+R immediately**
✅ **Short commands available after adding to PATH**
✅ **Each opens in its own window with proper title**
✅ **Automatically navigates to correct directory**

**Most used:** `n` (notifications), `d` (work tracking), `c` (claude agent), `oc` (opencode agent), `cm` (client manager)
