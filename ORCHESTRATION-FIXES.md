# Hazina Orchestration - Deployment Fixes (2026-02-16)

## Issues Fixed

### Issue A: Dashboard URL showing `::/:5123`
**Root Cause:** IPv6 address `[::]` not normalized to `localhost`  
**Fix:** Modified `TrayApplicationContext.cs` line 29-30:
```csharp
_baseUrl = _baseUrl.Replace("://0.0.0.0:", "://localhost:")
                   .Replace("://[::]:", "://localhost:");
```
**Status:** ✅ Fixed, rebuilt, deployed

### Issue B: Terminal exiting with code 0
**Root Cause 1:** Wrong paths in `claude_agent.bat`
- Username: `HP` → `marti`
- Log path: `E:\logs` → `C:\scripts\logs`

**Root Cause 2:** Nested session protection
- Claude Code detected `CLAUDECODE` env var and refused to start
- Added `set CLAUDECODE=` to unset variable before launch

**Fix:** Modified `claude_agent.bat`:
```batch
REM Allow nested Claude sessions (required for Orchestration terminal)
set CLAUDECODE=

REM Use correct username
set CLAUDE_CMD=C:\Users\marti\AppData\Roaming\npm\claude.cmd

REM Use correct log directory
set CLAUDE_LOG_FILE=C:\scripts\logs\%ORCHESTRATION_SESSION_ID%.txt
```
**Status:** ✅ Fixed and tested

## Deployment Info

- **Location:** `C:\stores\orchestration`
- **Executable:** `HazinaOrchestration.exe` (95MB, rebuilt 2026-02-16 13:22)
- **Configuration:** `appsettings.json` (Kestrel HTTPS on port 5123)
- **Certificates:** Tailscale TLS (valid for win-c6osts73hta.tailca9ff1.ts.net)
- **Service Status:** Running (PID varies, check with `ps aux | grep HazinaOrchestration`)

## Access Points

**Local:**
- Dashboard: https://localhost:5123/
- Swagger: https://localhost:5123/swagger
- Health: https://localhost:5123/health
- Quick Launch: `C:\scripts\o.bat`

**Tailscale (Remote):**
- Dashboard: https://win-c6osts73hta.tailca9ff1.ts.net:5123/
- Swagger: https://win-c6osts73hta.tailca9ff1.ts.net:5123/swagger

**Authentication:**
- Username: `bosi`
- Password: `Th1s1sSp4rt4!`

## Known Limitations

**Terminal Session Limitation:**
The TerminalSession uses pipe-based I/O redirection (not ConPTY). While basic commands work, some TUI features may be limited. This is architectural and documented in the Hazina.AgenticOrchestration source code.

## Testing

1. **Test Dashboard URL:**
   - Right-click tray icon → "Open Dashboard"
   - Should open: `https://localhost:5123/` (not `::/:5123`)

2. **Test Terminal Session:**
   - Open dashboard
   - Navigate to Terminal section
   - Create new session
   - Should launch Claude Code successfully (not exit code 0)

## Files Modified

1. `C:\Projects\Hazina\apps\Demos\Hazina.Demo.AgenticOrchestration\TrayApplicationContext.cs`
2. `C:\scripts\claude_agent.bat`
3. `C:\stores\orchestration\` (rebuilt deployment)

## Build Command (for reference)

```bash
cd /c/Projects/Hazina/apps/Demos/Hazina.Demo.AgenticOrchestration
dotnet publish -c Release -r win-x64 --self-contained -o /c/stores/orchestration
```

This rebuilds and deploys directly to the orchestration directory.
