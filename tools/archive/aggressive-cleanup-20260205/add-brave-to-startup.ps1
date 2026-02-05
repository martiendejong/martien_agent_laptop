#Requires -Version 5.1
<#
.SYNOPSIS
    Add Brave (Automation Mode) to Windows startup

.DESCRIPTION
    Creates a startup shortcut that launches Brave with DevTools Protocol on boot
#>

$ErrorActionPreference = "Stop"

Write-Host "Adding Brave (Automation Mode) to Windows startup..." -ForegroundColor Cyan

$bravePath = "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
if (-not (Test-Path $bravePath)) {
    Write-Host "[ERROR] Brave not found at: $bravePath" -ForegroundColor Red
    exit 1
}

$startupFolder = [Environment]::GetFolderPath("Startup")
$startupShortcut = Join-Path $startupFolder "Brave-Automation.lnk"

$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut($startupShortcut)
$shortcut.TargetPath = $bravePath
$shortcut.Arguments = "--remote-debugging-port=9222 --user-data-dir=`"$env:TEMP\brave-devtools-profile`" --disable-blink-features=AutomationControlled"
$shortcut.WindowStyle = 7  # Minimized
$shortcut.Description = "Brave with DevTools Protocol (auto-start)"
$shortcut.Save()

Write-Host "[SUCCESS] Added to Windows startup!" -ForegroundColor Green
Write-Host "Brave will start minimized with DevTools on next boot" -ForegroundColor Gray
Write-Host ""
Write-Host "To remove: Delete $startupShortcut" -ForegroundColor Gray
