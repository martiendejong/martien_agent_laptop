#Requires -Version 5.1
<#
.SYNOPSIS
    Control Brave browser via Chrome DevTools Protocol

.PARAMETER Action
    Action to perform: restart, open, status

.PARAMETER Url
    URL to open (when Action=open)
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("restart", "open", "status")]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$Url
)

$ErrorActionPreference = "Stop"

$bravePath = "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
$cdpPort = 9222

function Test-BraveDevTools {
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:$cdpPort/json/version" -TimeoutSec 2
        return $true
    } catch {
        return $false
    }
}

function Stop-BraveProcesses {
    Write-Host "Closing all Brave instances..." -ForegroundColor Yellow
    Get-Process brave -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-Host "Brave closed." -ForegroundColor Green
}

function Start-BraveWithDevTools {
    Write-Host "Starting Brave with DevTools Protocol..." -ForegroundColor Cyan

    $arguments = @(
        "--remote-debugging-port=$cdpPort",
        "--user-data-dir=`"$env:TEMP\brave-devtools-profile`"",
        "--disable-blink-features=AutomationControlled"
    )

    Start-Process -FilePath $bravePath -ArgumentList $arguments

    # Wait for DevTools to be ready
    Write-Host "Waiting for DevTools to be ready..." -ForegroundColor Gray
    $attempts = 0
    $maxAttempts = 10

    while (-not (Test-BraveDevTools) -and $attempts -lt $maxAttempts) {
        Start-Sleep -Seconds 1
        $attempts++
    }

    if (Test-BraveDevTools) {
        Write-Host "[SUCCESS] Brave started with DevTools on port $cdpPort" -ForegroundColor Green
        return $true
    } else {
        Write-Host "[ERROR] Failed to start Brave with DevTools" -ForegroundColor Red
        return $false
    }
}

function Open-BraveTab {
    param([string]$Url)

    if (-not (Test-BraveDevTools)) {
        Write-Host "[ERROR] Brave DevTools not available. Run with -Action restart first." -ForegroundColor Red
        return
    }

    Write-Host "Opening tab: $Url" -ForegroundColor Cyan

    try {
        $body = @{ url = $Url } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:$cdpPort/json/new?$Url" -Method Get

        Write-Host "[SUCCESS] Tab opened!" -ForegroundColor Green
        Write-Host "Tab ID: $($response.id)" -ForegroundColor Gray

        return $response
    } catch {
        Write-Host "[ERROR] Failed to open tab: $_" -ForegroundColor Red
    }
}

function Get-BraveStatus {
    Write-Host "Checking Brave DevTools status..." -ForegroundColor Cyan
    Write-Host ""

    if (Test-BraveDevTools) {
        Write-Host "[ACTIVE] DevTools Protocol is available at http://localhost:$cdpPort" -ForegroundColor Green

        try {
            $version = Invoke-RestMethod -Uri "http://localhost:$cdpPort/json/version"
            Write-Host ""
            Write-Host "Browser: $($version.Browser)" -ForegroundColor Gray
            Write-Host "Protocol: $($version.'Protocol-Version')" -ForegroundColor Gray
            Write-Host "User Agent: $($version.'User-Agent')" -ForegroundColor Gray

            $tabs = Invoke-RestMethod -Uri "http://localhost:$cdpPort/json"
            Write-Host ""
            Write-Host "Open tabs: $($tabs.Count)" -ForegroundColor Gray

        } catch {
            Write-Host "Could not get details: $_" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[INACTIVE] DevTools Protocol not available" -ForegroundColor Red
        Write-Host "Run: .\brave-control.ps1 -Action restart" -ForegroundColor Gray
    }
}

# Execute action
switch ($Action) {
    "restart" {
        Stop-BraveProcesses
        Start-BraveWithDevTools
    }
    "open" {
        if (-not $Url) {
            Write-Host "[ERROR] -Url parameter required for 'open' action" -ForegroundColor Red
            exit 1
        }
        Open-BraveTab -Url $Url
    }
    "status" {
        Get-BraveStatus
    }
}
