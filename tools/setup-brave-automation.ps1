#Requires -Version 5.1
<#
.SYNOPSIS
    Setup Brave browser for automation (always start with DevTools Protocol)

.DESCRIPTION
    Creates a desktop shortcut that launches Brave with remote debugging enabled
    This allows Claude Code to control the browser programmatically

.EXAMPLE
    .\setup-brave-automation.ps1
#>

$ErrorActionPreference = "Stop"

Write-Host "Setting up Brave browser for automation..." -ForegroundColor Cyan
Write-Host ""

# Find Brave installation
$bravePaths = @(
    "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe",
    "C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe",
    "$env:LocalAppData\BraveSoftware\Brave-Browser\Application\brave.exe"
)

$bravePath = $null
foreach ($path in $bravePaths) {
    if (Test-Path $path) {
        $bravePath = $path
        break
    }
}

if (-not $bravePath) {
    Write-Host "[ERROR] Brave browser not found!" -ForegroundColor Red
    Write-Host "Please install Brave or update the paths in this script" -ForegroundColor Yellow
    exit 1
}

Write-Host "[FOUND] Brave at: $bravePath" -ForegroundColor Green
Write-Host ""

# Create desktop shortcut
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "Brave (Automation Mode).lnk"

$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $bravePath
$shortcut.Arguments = "--remote-debugging-port=9222 --user-data-dir=`"$env:TEMP\brave-devtools-profile`" --disable-blink-features=AutomationControlled"
$shortcut.Description = "Brave with DevTools Protocol for automation"
$shortcut.IconLocation = $bravePath
$shortcut.Save()

Write-Host "[SUCCESS] Created desktop shortcut: 'Brave (Automation Mode).lnk'" -ForegroundColor Green
Write-Host ""

# Create startup script
$startupScript = @"
@echo off
start "" "$bravePath" --remote-debugging-port=9222 --user-data-dir="%TEMP%\brave-devtools-profile" --disable-blink-features=AutomationControlled
"@

$startupScriptPath = Join-Path $PSScriptRoot "start-brave-automation.bat"
$startupScript | Out-File -FilePath $startupScriptPath -Encoding ASCII

Write-Host "[SUCCESS] Created startup script: $startupScriptPath" -ForegroundColor Green
Write-Host ""

# Show instructions
Write-Host "=" * 60 -ForegroundColor DarkGray
Write-Host "SETUP COMPLETE!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor DarkGray
Write-Host ""
Write-Host "How to use:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Launch Brave in Automation Mode:" -ForegroundColor White
Write-Host "   - Double-click 'Brave (Automation Mode)' on your desktop" -ForegroundColor Gray
Write-Host "   - OR run: $startupScriptPath" -ForegroundColor Gray
Write-Host ""
Write-Host "2. DevTools Protocol will be available at:" -ForegroundColor White
Write-Host "   http://localhost:9222" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. Claude Code can now:" -ForegroundColor White
Write-Host "   - Control the browser via Puppeteer/Playwright" -ForegroundColor Gray
Write-Host "   - Execute JavaScript in pages" -ForegroundColor Gray
Write-Host "   - Capture screenshots" -ForegroundColor Gray
Write-Host "   - Fill forms and click buttons" -ForegroundColor Gray
Write-Host "   - Navigate and interact with web pages" -ForegroundColor Gray
Write-Host ""
Write-Host "=" * 60 -ForegroundColor DarkGray
Write-Host ""

# Optional: Add to Windows startup
$addToStartup = Read-Host "Add to Windows startup? (y/n)"
if ($addToStartup -eq "y") {
    $startupFolder = [Environment]::GetFolderPath("Startup")
    $startupShortcut = Join-Path $startupFolder "Brave-Automation.lnk"

    $shortcut2 = $WScriptShell.CreateShortcut($startupShortcut)
    $shortcut2.TargetPath = $bravePath
    $shortcut2.Arguments = "--remote-debugging-port=9222 --user-data-dir=`"$env:TEMP\brave-devtools-profile`" --disable-blink-features=AutomationControlled"
    $shortcut2.WindowStyle = 7  # Minimized
    $shortcut2.Save()

    Write-Host "[SUCCESS] Added to Windows startup (will start minimized)" -ForegroundColor Green
    Write-Host ""
}

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
