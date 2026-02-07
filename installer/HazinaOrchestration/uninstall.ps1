#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Hazina Orchestration Service Uninstaller

.DESCRIPTION
    Removes Hazina Orchestration service and optionally removes installation files.

.EXAMPLE
    .\uninstall.ps1
    Interactive uninstall with prompts

.EXAMPLE
    .\uninstall.ps1 -RemoveData -Silent
    Silent uninstall removing all data
#>

param(
    [string]$InstallPath = "C:\Program Files\Hazina Framework\Hazina Orchestration",
    [switch]$RemoveData,
    [switch]$Silent
)

$ErrorActionPreference = 'Stop'

# Banner
Write-Host ""
Write-Host "=======================================================================" -ForegroundColor Red
Write-Host "           HAZINA ORCHESTRATION SERVICE UNINSTALLER                    " -ForegroundColor Red
Write-Host "=======================================================================" -ForegroundColor Red
Write-Host ""

# Check if running as administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This uninstaller must be run as Administrator" -ForegroundColor Red
    Write-Host "Please right-click and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

$serviceName = "HazinaOrchestrator"

if (-not $Silent) {
    Write-Host "This will remove the Hazina Orchestration service." -ForegroundColor Yellow
    Write-Host ""
    $confirm = Read-Host "Continue? (y/N)"
    if ($confirm -ne 'y') {
        Write-Host "Uninstall cancelled." -ForegroundColor Gray
        exit 0
    }
    Write-Host ""
}

Write-Host "[1/4] Stopping Service" -ForegroundColor Yellow

# Stop service if running
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service) {
    if ($service.Status -eq 'Running') {
        Write-Host "   Stopping service..."
        Stop-Service -Name $serviceName -Force
        Start-Sleep -Seconds 2
        Write-Host "   Service stopped" -ForegroundColor Green
    }
    else {
        Write-Host "   Service already stopped" -ForegroundColor Gray
    }
}
else {
    Write-Host "   Service not found" -ForegroundColor Gray
}

Write-Host ""

Write-Host "[2/4] Removing Service" -ForegroundColor Yellow

if ($service) {
    Write-Host "   Deleting service..."
    sc.exe delete $serviceName | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "   Service removed" -ForegroundColor Green
    }
    else {
        Write-Host "   WARNING: Failed to remove service" -ForegroundColor Yellow
    }
}
else {
    Write-Host "   No service to remove" -ForegroundColor Gray
}

Write-Host ""

Write-Host "[3/4] Removing Firewall Rule" -ForegroundColor Yellow

$firewallRuleName = "Hazina Orchestration HTTPS"
$existingRule = Get-NetFirewallRule -DisplayName $firewallRuleName -ErrorAction SilentlyContinue

if ($existingRule) {
    Write-Host "   Removing firewall rule..."
    Remove-NetFirewallRule -DisplayName $firewallRuleName
    Write-Host "   Firewall rule removed" -ForegroundColor Green
}
else {
    Write-Host "   No firewall rule to remove" -ForegroundColor Gray
}

Write-Host ""

Write-Host "[4/4] Removing Files" -ForegroundColor Yellow

if (Test-Path $InstallPath) {
    if (-not $Silent -and -not $RemoveData) {
        Write-Host "   Installation path: $InstallPath" -ForegroundColor Cyan
        $removeFiles = Read-Host "Remove installation files? (y/N)"

        if ($removeFiles -eq 'y') {
            $RemoveData = $true
        }
    }

    if ($RemoveData) {
        Write-Host "   Removing installation files..."

        # Give processes time to release file handles
        Start-Sleep -Seconds 2

        try {
            Remove-Item -Path $InstallPath -Recurse -Force -ErrorAction Stop
            Write-Host "   Installation files removed" -ForegroundColor Green
        }
        catch {
            Write-Host "   WARNING: Could not remove some files: $_" -ForegroundColor Yellow
            Write-Host "   You may need to manually delete: $InstallPath" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "   Installation files kept at: $InstallPath" -ForegroundColor Gray
    }
}
else {
    Write-Host "   Installation path not found: $InstallPath" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=======================================================================" -ForegroundColor Green
Write-Host "                   UNINSTALL COMPLETE                                  " -ForegroundColor Green
Write-Host "=======================================================================" -ForegroundColor Green
Write-Host ""

if (-not $RemoveData -and (Test-Path $InstallPath)) {
    Write-Host "NOTE: Installation files remain at: $InstallPath" -ForegroundColor Yellow
    Write-Host "      To remove manually: Remove-Item '$InstallPath' -Recurse -Force" -ForegroundColor Gray
    Write-Host ""
}
