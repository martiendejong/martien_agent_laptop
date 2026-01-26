# UI Automation Bridge - Complete Windows UI Control

**Status:** ✅ Production Ready
**Created:** 2026-01-26
**Port:** localhost:27184
**Technology:** FlaUI + C# + HTTP API

---

## 🎯 Overview

The **UI Automation Bridge** gives Claude Code complete programmatic control over **any Windows desktop application**. This enables autonomous interaction with Visual Studio, Windows Explorer, database tools, and any other desktop software.

### Architecture

```
┌─────────────────┐         ┌──────────────────────┐         ┌─────────────┐
│ Claude Code CLI │◄───────►│ UI Automation Bridge │◄───────►│ Windows UI  │
│   (Me - Agent)  │  HTTP   │  localhost:27184     │  FlaUI  │   (Any App) │
└─────────────────┘         └──────────────────────┘         └─────────────┘
```

### What This Enables

✅ **Visual Studio Control** - Click menus, navigate solution explorer, control debugger UI
✅ **Windows Explorer** - Navigate folders, rename files, verify UI state
✅ **Desktop App Testing** - Automated testing of client-manager frontend
✅ **System Dialogs** - Handle file open/save dialogs, Windows security prompts
✅ **Any Windows App** - Discord, Slack, SQL Server Management Studio, etc.

---

## 🚀 Quick Start

### 1. Start the Bridge Server

```powershell
# Start server on default port (27184)
.\ui-automation-bridge-server.ps1

# With debug logging
.\ui-automation-bridge-server.ps1 -Debug

# Custom port
.\ui-automation-bridge-server.ps1 -Port 27185
```

### 2. Use the Client

```powershell
# Health check
.\ui-automation-bridge-client.ps1 -Action health

# List all windows
.\ui-automation-bridge-client.ps1 -Action windows

# Click a button
.\ui-automation-bridge-client.ps1 -Action click -WindowName "Notepad" -ElementName "File"

# Type text
.\ui-automation-bridge-client.ps1 -Action type -WindowName "Notepad" -Text "Hello World"

# Take screenshot
.\ui-automation-bridge-client.ps1 -Action screenshot -WindowName "Visual Studio"

# Inspect element at coordinates
.\ui-automation-bridge-client.ps1 -Action inspect -X 100 -Y 200
```

---

## 📖 API Reference

### GET /health
Health check endpoint

**Response:**
```json
{
  "ok": true,
  "message": "UI Automation Bridge is healthy",
  "version": "1.0.0"
}
```

### GET /windows
List all visible windows

**Response:**
```json
{
  "ok": true,
  "windows": [
    {
      "id": "12345",
      "name": "Visual Studio 2022",
      "automationId": "",
      "className": "HwndWrapper",
      "isVisible": true,
      "processId": 1234,
      "boundingRectangle": {
        "x": 0,
        "y": 0,
        "width": 1920,
        "height": 1080
      }
    }
  ]
}
```

### GET /windows/{id}
Get details for a specific window

**Response:**
```json
{
  "ok": true,
  "window": {
    "id": "12345",
    "name": "Visual Studio 2022",
    ...
  }
}
```

### GET /windows/{id}/tree
Get element tree (max depth 5)

**Response:**
```json
{
  "ok": true,
  "tree": {
    "name": "Window",
    "automationId": "",
    "className": "HwndWrapper",
    "controlType": "Window",
    "children": [...]
  }
}
```

### GET /windows/{id}/screenshot
Capture window screenshot

**Response:**
```json
{
  "ok": true,
  "screenshot": "data:image/png;base64,iVBORw0KGgoAAAANS..."
}
```

### POST /click
Click an element

**Request body:**
```json
{
  "windowId": "12345",
  "automationId": "btnOK",     // optional
  "name": "OK",                 // optional
  "className": "Button"         // optional
}
```

**Response:**
```json
{
  "ok": true,
  "message": "Clicked successfully"
}
```

### POST /type
Type text

**Request body:**
```json
{
  "windowId": "12345",
  "text": "Hello World",
  "automationId": "txtInput",   // optional
  "name": "Input"               // optional
}
```

**Response:**
```json
{
  "ok": true,
  "message": "Typed successfully"
}
```

### POST /set-value
Set element value (direct value manipulation)

**Request body:**
```json
{
  "windowId": "12345",
  "value": "New Value",
  "automationId": "txtInput",
  "name": "Input"
}
```

**Response:**
```json
{
  "ok": true,
  "message": "Value set successfully"
}
```

### POST /invoke
Invoke an element (trigger default action)

**Request body:**
```json
{
  "windowId": "12345",
  "automationId": "btnSubmit",
  "name": "Submit"
}
```

**Response:**
```json
{
  "ok": true,
  "message": "Invoked successfully"
}
```

### POST /expand
Expand or collapse an element

**Request body:**
```json
{
  "windowId": "12345",
  "automationId": "treeNode",
  "name": "Folder",
  "expand": true
}
```

**Response:**
```json
{
  "ok": true,
  "message": "Expanded"
}
```

### POST /select
Select an item (in lists, combo boxes, etc.)

**Request body:**
```json
{
  "windowId": "12345",
  "automationId": "listItem",
  "name": "Option 1"
}
```

**Response:**
```json
{
  "ok": true,
  "message": "Selected successfully"
}
```

### GET /inspect/{x}/{y}
Inspect element at screen coordinates

**Response:**
```json
{
  "ok": true,
  "element": {
    "name": "Button",
    "automationId": "btnOK",
    "className": "Button",
    "controlType": "Button",
    "isEnabled": true,
    "isVisible": true,
    "boundingRectangle": {
      "x": 100,
      "y": 200,
      "width": 75,
      "height": 23
    },
    "supportedPatterns": {
      "invoke": true,
      "value": false,
      "text": false,
      "expandCollapse": false,
      "selectionItem": false
    }
  }
}
```

### GET /docs
API documentation

---

## 🛠️ PowerShell Client Usage

### Basic Commands

```powershell
# Health check
.\ui-automation-bridge-client.ps1 -Action health

# List windows
.\ui-automation-bridge-client.ps1 -Action windows

# Get window tree
.\ui-automation-bridge-client.ps1 -Action tree -WindowId "12345"
```

### Window Selection

```powershell
# By window ID
-WindowId "12345"

# By window name (searches)
-WindowName "Notepad"
-WindowName "Visual Studio"
```

### Element Identification

```powershell
# By element name
-ElementName "OK"
-ElementName "File"

# By automation ID
-AutomationId "btnSubmit"

# By class name
-ClassName "Button"

# Combine multiple identifiers
-ElementName "Submit" -ClassName "Button"
```

### Interaction Examples

```powershell
# Click button
.\ui-automation-bridge-client.ps1 -Action click -WindowName "Notepad" -ElementName "File"

# Type text
.\ui-automation-bridge-client.ps1 -Action type -WindowName "Notepad" -Text "Hello World"

# Set value directly
.\ui-automation-bridge-client.ps1 -Action set-value -WindowName "Calculator" -ElementName "Result" -Value "42"

# Invoke element
.\ui-automation-bridge-client.ps1 -Action invoke -WindowName "Dialog" -ElementName "OK"

# Expand tree node
.\ui-automation-bridge-client.ps1 -Action expand -WindowName "Explorer" -ElementName "Folder" -Expand $true

# Select from list
.\ui-automation-bridge-client.ps1 -Action select -WindowName "Dialog" -ElementName "Option 1"

# Inspect element
.\ui-automation-bridge-client.ps1 -Action inspect -X 500 -Y 300

# Screenshot
.\ui-automation-bridge-client.ps1 -Action screenshot -WindowName "Visual Studio"
```

### JSON Output

```powershell
# Get raw JSON for programmatic use
.\ui-automation-bridge-client.ps1 -Action windows -Json
.\ui-automation-bridge-client.ps1 -Action inspect -X 100 -Y 200 -Json
```

---

## 🎨 Use Cases

### 1. Visual Studio Automation

```powershell
# Get Visual Studio window
$windows = .\ui-automation-bridge-client.ps1 -Action windows -Json | ConvertFrom-Json
$vs = $windows.windows | Where-Object { $_.name -like "*Visual Studio*" } | Select-Object -First 1

# Click Build menu
.\ui-automation-bridge-client.ps1 -Action click -WindowId $vs.id -ElementName "Build"

# Take screenshot
.\ui-automation-bridge-client.ps1 -Action screenshot -WindowId $vs.id
```

### 2. File Dialog Handling

```powershell
# Wait for file dialog to appear
Start-Sleep -Seconds 1

# Find file dialog window
$windows = .\ui-automation-bridge-client.ps1 -Action windows -Json | ConvertFrom-Json
$dialog = $windows.windows | Where-Object { $_.name -like "*Open*" -or $_.name -like "*Save*" } | Select-Object -First 1

# Type filename
.\ui-automation-bridge-client.ps1 -Action type -WindowId $dialog.id -ElementName "File name:" -Text "document.txt"

# Click OK
.\ui-automation-bridge-client.ps1 -Action click -WindowId $dialog.id -ElementName "Open"
```

### 3. Windows Explorer Navigation

```powershell
# Find Windows Explorer
$windows = .\ui-automation-bridge-client.ps1 -Action windows -Json | ConvertFrom-Json
$explorer = $windows.windows | Where-Object { $_.className -eq "CabinetWClass" } | Select-Object -First 1

# Navigate to folder (type in address bar)
.\ui-automation-bridge-client.ps1 -Action type -WindowId $explorer.id -ElementName "Address" -Text "C:\Projects"
.\ui-automation-bridge-client.ps1 -Action type -WindowId $explorer.id -Text "{ENTER}"
```

### 4. Desktop App Testing

```powershell
# Test login form
$app = (.\ui-automation-bridge-client.ps1 -Action windows -Json | ConvertFrom-Json).windows | Where-Object { $_.name -eq "MyApp" } | Select-Object -First 1

# Fill form
.\ui-automation-bridge-client.ps1 -Action set-value -WindowId $app.id -ElementName "Username" -Value "testuser"
.\ui-automation-bridge-client.ps1 -Action set-value -WindowId $app.id -ElementName "Password" -Value "testpass"

# Click login
.\ui-automation-bridge-client.ps1 -Action click -WindowId $app.id -ElementName "Login"

# Wait and verify
Start-Sleep -Seconds 2
$tree = .\ui-automation-bridge-client.ps1 -Action tree -WindowId $app.id -Json | ConvertFrom-Json
# Verify success message in tree
```

### 5. Screen Inspection

```powershell
# Inspect element at cursor position
# (Move cursor to element first, then note coordinates)
.\ui-automation-bridge-client.ps1 -Action inspect -X 800 -Y 400

# Get element details
$element = (.\ui-automation-bridge-client.ps1 -Action inspect -X 800 -Y 400 -Json | ConvertFrom-Json).element

# Use discovered automation ID for interaction
.\ui-automation-bridge-client.ps1 -Action click -WindowId $windowId -AutomationId $element.automationId
```

---

## 🔧 Integration with Claude Code

### Startup Protocol Addition

Add to `CLAUDE.md` § Every Session Start:

```markdown
18. ✅ **Check UI Automation Bridge** - `ui-automation-bridge-client.ps1 -Action health`
```

### Proactive Usage

Claude Code should automatically use UI Automation Bridge when:
- User requests UI interaction (click, type, fill form)
- Testing desktop applications
- Handling system dialogs during automation
- Verifying UI state
- Taking screenshots for debugging

### Example Agent Workflow

```powershell
# 1. Check if bridge is running
try {
    .\ui-automation-bridge-client.ps1 -Action health
} catch {
    Write-Host "Starting UI Automation Bridge..."
    Start-Process powershell -ArgumentList "-File ui-automation-bridge-server.ps1" -WindowStyle Hidden
    Start-Sleep -Seconds 3
}

# 2. Get target window
$windows = .\ui-automation-bridge-client.ps1 -Action windows -Json | ConvertFrom-Json
$target = $windows.windows | Where-Object { $_.name -like "*$appName*" } | Select-Object -First 1

# 3. Perform automation
.\ui-automation-bridge-client.ps1 -Action click -WindowId $target.id -ElementName "Button"

# 4. Verify result
$screenshot = .\ui-automation-bridge-client.ps1 -Action screenshot -WindowId $target.id -Json | ConvertFrom-Json
```

---

## 🐛 Troubleshooting

### Server won't start

```powershell
# Rebuild project
.\ui-automation-bridge-server.ps1 -Build

# Check if port is in use
netstat -an | findstr "27184"

# Try different port
.\ui-automation-bridge-server.ps1 -Port 27185
```

### Element not found

```powershell
# 1. Get element tree to see structure
.\ui-automation-bridge-client.ps1 -Action tree -WindowId "12345"

# 2. Use inspect to find element
.\ui-automation-bridge-client.ps1 -Action inspect -X 800 -Y 400

# 3. Try different identifiers (name, automationId, className)
```

### Click/Type not working

```powershell
# 1. Verify element supports the action
$element = (.\ui-automation-bridge-client.ps1 -Action inspect -X 800 -Y 400 -Json | ConvertFrom-Json).element
# Check supportedPatterns

# 2. Try different action
# If click doesn't work, try invoke
.\ui-automation-bridge-client.ps1 -Action invoke -WindowId $id -ElementName "Button"

# 3. Focus window first
.\ui-automation-bridge-client.ps1 -Action click -WindowId $id -ElementName "TitleBar"
Start-Sleep -Milliseconds 500
.\ui-automation-bridge-client.ps1 -Action click -WindowId $id -ElementName "Button"
```

### Permission issues

- Run PowerShell as Administrator
- Check Windows UI Automation is enabled (Accessibility settings)
- Verify antivirus/firewall not blocking localhost:27184

---

## 📊 Technical Details

### Technology Stack

- **FlaUI 5.0.0** - Modern .NET UI automation library
- **UIA3 Provider** - Windows UI Automation API v3
- **.NET 9.0** - Latest .NET runtime
- **HttpListener** - HTTP server for REST API
- **Newtonsoft.Json** - JSON serialization

### Supported Control Patterns

- **Invoke** - Click buttons, trigger actions
- **Value** - Get/set text box values
- **Text** - Read text content
- **ExpandCollapse** - Expand/collapse tree nodes
- **SelectionItem** - Select items in lists
- **Window** - Window manipulation
- **Transform** - Move/resize elements

### Supported Applications

✅ **Win32 apps** - Notepad, Explorer, legacy apps
✅ **WPF apps** - Visual Studio, modern .NET apps
✅ **Windows Forms** - Older .NET apps
✅ **UWP apps** - Windows Store apps (limited)

❌ **Web browsers** - Use Browser MCP instead
❌ **Electron apps** - May have limited support

---

## 🔮 Future Enhancements

Possible improvements:
- **Mouse operations** - Right-click, drag-drop, hover
- **Keyboard shortcuts** - CTRL+C, ALT+F4, etc.
- **Multi-monitor support** - Screen coordinate mapping
- **Window manipulation** - Move, resize, minimize, maximize
- **Accessibility tree navigation** - Advanced element traversal
- **Retry logic** - Auto-retry on transient failures
- **Performance optimization** - Element caching
- **Security** - API key authentication
- **Logging** - Detailed action logging

---

## 📝 Changelog

**2026-01-26 - v1.0.0 - Initial Release**
- ✅ Complete REST API implementation
- ✅ FlaUI integration
- ✅ PowerShell client
- ✅ 13 endpoints (health, windows, click, type, etc.)
- ✅ Element inspection and screenshot capture
- ✅ Window search by name/ID
- ✅ Comprehensive documentation

---

**Created by:** Claude Code (Autonomous Agent)
**User Request:** "I want you to have complete control over my UI"
**Status:** ✅ Production Ready - Full Windows desktop control enabled!
