# work-tray-startup.ps1
# Configure Work Tracker System Tray App to start with Windows

param(
    [ValidateSet('Enable', 'Disable', 'Status')]

$ErrorActionPreference = "Stop"
    [string]$Action = 'Enable'
)

$appPath = "C:\scripts\tools\WorkTray.exe"
$appName = "WorkTray"
$registryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

function Get-StartupStatus {
    try {
        $value = Get-ItemProperty -Path $registryPath -Name $appName -ErrorAction SilentlyContinue
        return $value -ne $null
    }
    catch {
        return $false
    }
}

function Enable-Startup {
    if (-not (Test-Path $appPath)) {
        Write-Host "âŒ WorkTray.exe not found at: $appPath" -ForegroundColor Red
        Write-Host "Build it first: powershell.exe -File C:\scripts\tools\work-tray\build.ps1" -ForegroundColor Yellow
        return $false
    }

    try {
        Set-ItemProperty -Path $registryPath -Name $appName -Value "`"$appPath`"" -Force
        Write-Host "âœ… Work Tracker will now start automatically with Windows" -ForegroundColor Green
        Write-Host "Location: $appPath" -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "âŒ Failed to enable startup: $_" -ForegroundColor Red
        return $false
    }
}

function Disable-Startup {
    try {
        Remove-ItemProperty -Path $registryPath -Name $appName -ErrorAction SilentlyContinue
        Write-Host "âœ… Work Tracker auto-startup disabled" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "âŒ Failed to disable startup: $_" -ForegroundColor Red
        return $false
    }
}

function Show-Status {
    $enabled = Get-StartupStatus

    Write-Host "`nWork Tracker Auto-Startup Status" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "Status: $(if ($enabled) { 'âœ… ENABLED' } else { 'âŒ DISABLED' })" -ForegroundColor $(if ($enabled) { 'Green' } else { 'Red' })
    Write-Host "App Path: $appPath" -ForegroundColor Gray
    Write-Host "Registry: $registryPath\$appName" -ForegroundColor Gray

    if ($enabled) {
        $registeredPath = (Get-ItemProperty -Path $registryPath -Name $appName).$appName
        Write-Host "Registered Path: $registeredPath" -ForegroundColor Gray

        if (Test-Path $appPath) {
            Write-Host "Executable: âœ… Found" -ForegroundColor Green
        }
        else {
            Write-Host "Executable: âŒ Not Found (rebuild required)" -ForegroundColor Red
        }
    }

    Write-Host ""
}

# Main logic
switch ($Action) {
    'Enable' {
        Enable-Startup
    }
    'Disable' {
        Disable-Startup
    }
    'Status' {
        Show-Status
    }
}
