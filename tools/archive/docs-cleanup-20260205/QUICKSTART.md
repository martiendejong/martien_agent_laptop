# UI Automation Bridge - Quick Start

## 🚀 Getting Started (5 minutes)

### Step 1: Start the Bridge Server

Open PowerShell and run:

```powershell
cd C:\scripts\tools
.\ui-automation-bridge-server.ps1
```

You should see:
```
[UI-BRIDGE] UI Automation Bridge started on http://localhost:27184

Endpoints:
  GET    /health               - Health check
  GET    /windows              - List all windows
  ...

Press CTRL+C to stop
```

**Leave this window open** - the server must stay running.

### Step 2: Test the Connection

Open a **second** PowerShell window:

```powershell
cd C:\scripts\tools

# Health check
.\ui-automation-bridge-client.ps1 -Action health

# Expected output:
# ✓ UI Automation Bridge is healthy
# Version: 1.0.0
```

### Step 3: List All Windows

```powershell
.\ui-automation-bridge-client.ps1 -Action windows
```

You'll see all open windows with their IDs, names, and properties.

### Step 4: Try Your First Automation

```powershell
# Open Notepad first
notepad.exe

# Wait a moment, then get windows list
$windows = .\ui-automation-bridge-client.ps1 -Action windows -Json | ConvertFrom-Json
$notepad = $windows.windows | Where-Object { $_.name -like "*Notepad*" } | Select-Object -First 1

# Type into Notepad
.\ui-automation-bridge-client.ps1 -Action type -WindowId $notepad.id -Text "Hello from Claude!"

# Take screenshot
.\ui-automation-bridge-client.ps1 -Action screenshot -WindowId $notepad.id
```

**Success!** You now have complete UI automation working.

---

## 📖 Next Steps

1. **Read the full documentation:** `UI_AUTOMATION_BRIDGE.md`
2. **Try more examples:** See "Use Cases" section
3. **Integrate with Claude Code:** See CLAUDE.md integration section

---

## 🐛 Troubleshooting

**Server fails to start:**
- Run: `.\ui-automation-bridge-server.ps1 -Build` to rebuild
- Check .NET 9 is installed: `dotnet --version`

**Client says "can't connect":**
- Make sure server window is still open
- Check if server is listening: `netstat -an | findstr "27184"`

**Element not found:**
- Use inspect to find correct identifiers: `.\ui-automation-bridge-client.ps1 -Action inspect -X 800 -Y 400`
- Check element tree: `.\ui-automation-bridge-client.ps1 -Action tree -WindowId "..."`

---

## ✅ You're Ready!

Claude Code can now control **any Windows application** programmatically. This includes:
- Visual Studio
- Windows Explorer
- Database tools
- Your own applications
- System dialogs
- And more!

See `UI_AUTOMATION_BRIDGE.md` for complete API reference and advanced usage.
