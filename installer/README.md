# Hazina Orchestration Installer

Complete installer package for Hazina Orchestration Service - A terminal orchestration tool for managing Claude Code CLI instances.

## 📦 What's Included

### PowerShell Installers (Ready to Use)
- **install.ps1** - Full-featured installer with interactive prompts
- **uninstall.ps1** - Complete uninstaller
- **create-installer-package.ps1** - Creates distributable ZIP package

### MSI Installer (Future/Advanced)
- **Product.wxs** - WiX installer definition
- **TerminalConfigDlg.wxs** - Custom UI dialog for terminal configuration
- **HazinaInstallerActions/** - Custom action DLL for config updates
- **build-installer.ps1** - MSI build script (requires WiX toolset)

## 🚀 Quick Start - Creating Installer Package

### Option 1: Minimal Package (Recommended - Low Disk Space)
```powershell
cd C:\scripts\installer
.\create-installer-package.ps1
```

**Output:**
- `HazinaOrchestration-v1.0.0-Installer.zip` (< 5 KB)
- References files from `C:\stores\orchestration`
- Users run `install.ps1` after extracting

### Option 2: Full Package (Requires ~70MB Free Space)
```powershell
cd C:\scripts\installer\HazinaOrchestration
.\build-installer.ps1
```

**Output:**
- `HazinaOrchestration-v1.0.0-Installer.zip` (~63 MB)
- Self-contained, all files included
- Users extract and run `install.ps1`

### Option 3: MSI Package (Requires WiX Toolset)
```powershell
# Install WiX (one-time)
dotnet tool install --global wix

# Build MSI
cd C:\scripts\installer\HazinaOrchestration
wix build Product.wxs TerminalConfigDlg.wxs -out HazinaOrchestration.msi
```

## 📋 Installation Features

### What Gets Installed
- **Application Files:**
  - HazinaOrchestration.exe (62 MB single-file .NET app)
  - appsettings.json (configuration)
  - entities.yaml (entity definitions)
  - SSL certificates (tailscale.crt/key)
  - XML documentation files
  - React frontend (ClientApp, wwwroot)

- **Windows Service:**
  - Service Name: `HazinaOrchestrator`
  - Display Name: "Hazina Orchestration Service"
  - Startup Type: Automatic
  - Recovery: Auto-restart on failure (60s delay)

- **Firewall Rule:**
  - Port 5123 (HTTPS)
  - Inbound allow
  - All profiles

- **Configuration:**
  - Terminal executable (user-selected during install)
  - Working directory
  - Database path
  - Logs path

### Interactive Prompts
1. **Installation Path** (default: `C:\Program Files\Hazina Framework\Hazina Orchestration`)
2. **Terminal Executable** (examples provided)
3. **Working Directory** (default: `C:\scripts`)

### Silent Installation
```powershell
.\install.ps1 `
  -InstallPath "C:\CustomPath" `
  -TerminalExecutable "C:\scripts\claude_agent.bat" `
  -WorkingDirectory "C:\scripts" `
  -Silent
```

## 🛠️ Post-Installation

### Access Web Interface
```
URL: https://localhost:5123
Username: bosi
Password: Th1s1sSp4rt4!
```

### Service Management
```powershell
# Check status
Get-Service HazinaOrchestrator

# Start/Stop/Restart
Start-Service HazinaOrchestrator
Stop-Service HazinaOrchestrator
Restart-Service HazinaOrchestrator

# View detailed status
Get-Service HazinaOrchestrator | Format-List *
```

### View Logs
```powershell
# Startup log
Get-Content "C:\Program Files\Hazina Framework\Hazina Orchestration\logs\startup.log" -Tail 50

# Session logs
Get-ChildItem "C:\Program Files\Hazina Framework\Hazina Orchestration\logs\agent-sessions"
```

### Edit Configuration
```powershell
# Edit appsettings.json
notepad "C:\Program Files\Hazina Framework\Hazina Orchestration\appsettings.json"

# Restart after changes
Restart-Service HazinaOrchestrator
```

## 🗑️ Uninstallation

### Interactive
```powershell
.\uninstall.ps1
```

### Silent (Remove All Data)
```powershell
.\uninstall.ps1 -RemoveData -Silent
```

**What Gets Removed:**
- Windows service (stopped and deleted)
- Firewall rule
- Installation files (optional)
- Registry entries (if MSI was used)

## 📁 Directory Structure

```
C:\scripts\installer\
├── README.md (this file)
├── create-installer-package.ps1  # Quick package creator
├── create-msi-simple.ps1         # MSI shell creator
└── HazinaOrchestration/
    ├── install.ps1               # Main installer
    ├── uninstall.ps1             # Uninstaller
    ├── build-installer.ps1       # Full package builder
    ├── Product.wxs               # WiX main definition
    ├── TerminalConfigDlg.wxs     # WiX custom dialog
    └── HazinaInstallerActions/   # Custom actions DLL
        ├── CustomActions.cs
        └── HazinaInstallerActions.csproj
```

## ⚙️ Configuration Details

### appsettings.json Key Sections

```json
{
  "AgenticOrchestration": {
    "Terminal": {
      "DefaultCommand": "C:\\scripts\\claude_agent.bat",  // Updated by installer
      "DefaultWorkingDirectory": "C:\\scripts",            // Updated by installer
      "MaxConcurrentSessions": 10
    },
    "DatabasePath": "C:\\path\\to\\agent-activity.db",     // Updated by installer
    "LogsPath": "C:\\path\\to\\logs"                       // Updated by installer
  },
  "Authentication": {
    "Enabled": true,
    "Username": "bosi",
    "Password": "Th1s1sSp4rt4!"
  },
  "Kestrel": {
    "Endpoints": {
      "Https": {
        "Url": "https://*:5123"
      }
    }
  }
}
```

## 🔧 Development & Customization

### Modify Terminal Options
Edit `TerminalConfigDlg.wxs` to change default terminal options or add presets.

### Modify Service Configuration
Edit `Product.wxs`:
```xml
<ServiceInstall Id="HazinaOrchestratorService"
                Type="ownProcess"
                Name="HazinaOrchestrator"
                DisplayName="Hazina Orchestration Service"
                Start="auto"              <!-- auto, demand, or disabled -->
                Account="LocalSystem">    <!-- Or specific account -->
```

### Add Custom Actions
Add logic to `HazinaInstallerActions/CustomActions.cs`:
```csharp
[CustomAction]
public static ActionResult MyCustomAction(Session session)
{
    // Your logic here
    return ActionResult.Success;
}
```

### Build Custom Actions DLL
```powershell
cd HazinaInstallerActions
dotnet build -c Release
```

## 📊 Size Information

| Component | Size |
|-----------|------|
| HazinaOrchestration.exe | 62 MB |
| XML docs | ~500 KB |
| ClientApp (React build) | ~2 MB |
| SSL certificates | ~3 KB |
| Config files | ~20 KB |
| **Total** | **~65 MB** |
| Minimal installer (ZIP) | 5 KB |
| Full installer (ZIP) | 63 MB |

## 🔍 Troubleshooting

### Installation Fails
1. Verify running as Administrator
2. Check disk space (need ~70 MB free)
3. Check source files exist at `C:\stores\orchestration`
4. Review error messages in console

### Service Won't Start
1. Check Event Viewer (Application logs)
2. Verify terminal executable exists
3. Check appsettings.json syntax
4. Verify port 5123 is available: `netstat -ano | findstr 5123`

### Web UI Not Accessible
1. Verify service is running: `Get-Service HazinaOrchestrator`
2. Check firewall rule: `Get-NetFirewallRule -DisplayName "Hazina*"`
3. Try localhost instead of machine name
4. Check SSL certificates are valid

### Disk Space Issues
Use minimal installer:
```powershell
.\create-installer-package.ps1
```
This creates <5KB package that references source files.

## 📝 Version History

- **v1.0.0** (2026-02-07)
  - Initial release
  - PowerShell installer with interactive prompts
  - Windows service installation
  - Terminal configuration
  - Firewall rule creation
  - WiX MSI scaffolding

## 🤝 Support

For issues or questions:
1. Check logs: `C:\Program Files\Hazina Framework\Hazina Orchestration\logs\`
2. Check Event Viewer: Application logs
3. Verify service status: `Get-Service HazinaOrchestrator`
4. Review configuration: `appsettings.json`

## 📜 License

Part of the Hazina Framework project.

---

**Built with:** PowerShell, WiX Toolset, .NET 8.0
**Last Updated:** 2026-02-07
