#Requires -Version 5.1
<#
.SYNOPSIS
    Start the cross-machine Jengo bridge server.

.DESCRIPTION
    - Generates auth token if not exists and stores in vault + token file
    - Starts cross-machine-bridge.py as a background job
    - Opens Windows Firewall rule for port 9998 on Tailscale interface
    - Reports status

.PARAMETER Force
    Kill any existing bridge on port 9998 before starting

.PARAMETER NoFirewall
    Skip firewall rule creation (use if you don't have admin rights)

.EXAMPLE
    bridge-start.ps1
    bridge-start.ps1 -Force
    bridge-start.ps1 -NoFirewall
#>

param(
    [switch]$Force,
    [switch]$NoFirewall
)

$ErrorActionPreference = 'Stop'

$configPath = 'C:\scripts\_machine\cross-machine-config.json'
$tokenFile = 'C:\scripts\_machine\bridge-auth.token'
$bridgeScript = 'C:\scripts\tools\cross-machine-bridge.js'
$port = 9998

# Load config for port
if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    if ($config.bridge_port) { $port = $config.bridge_port }
}

Write-Host ""
Write-Host "  Jengo Cross-Machine Bridge - Startup" -ForegroundColor Cyan
Write-Host "  Port: $port | Config: $configPath" -ForegroundColor DarkGray
Write-Host ""

# --- Step 1: Auth Token ---
Write-Host "[1/4] Auth Token..." -ForegroundColor White

if (Test-Path $tokenFile) {
    $existingToken = (Get-Content $tokenFile -Raw).Trim()
    if ($existingToken.Length -gt 10) {
        Write-Host "      Token already exists ($($existingToken.Substring(0,8))...)" -ForegroundColor Green
    } else {
        Write-Host "      Token file exists but looks invalid, regenerating..." -ForegroundColor Yellow
        $existingToken = $null
    }
} else {
    $existingToken = $null
}

if (-not $existingToken) {
    # Generate a new token
    $tokenBytes = [System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32)
    $newToken = [System.Convert]::ToBase64String($tokenBytes)

    # Save to token file
    $newToken | Out-File -FilePath $tokenFile -Encoding ASCII -NoNewline
    Write-Host "      Token generated and saved to $tokenFile" -ForegroundColor Green

    # Save to vault
    try {
        $vaultResult = & powershell.exe -ExecutionPolicy Bypass -File 'C:\scripts\tools\vault.ps1' `
            -Action set -Service 'cross-machine-auth' -Token $newToken `
            -Notes 'Shared auth token for cross-machine Jengo bridge (port 9998)' `
            -Tags 'cross-machine,security' 2>&1

        Write-Host "      Token saved to vault (service: cross-machine-auth)" -ForegroundColor Green
    } catch {
        Write-Host "      WARNING: Could not save to vault: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "      Token is in file only: $tokenFile" -ForegroundColor Yellow
    }
}

# --- Step 2: Check/kill existing bridge ---
Write-Host "[2/4] Port check ($port)..." -ForegroundColor White

$existing = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
if ($existing) {
    if ($Force) {
        $pid = ($existing | Select-Object -First 1).OwningProcess
        Write-Host "      Found existing process (PID $pid), killing..." -ForegroundColor Yellow
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 500
        Write-Host "      Killed." -ForegroundColor Green
    } else {
        Write-Host "      Port $port already in use! Use -Force to restart." -ForegroundColor Red
        $pid = ($existing | Select-Object -First 1).OwningProcess
        $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
        Write-Host "      Process: $($proc.ProcessName) (PID $pid)" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Bridge appears to already be running. Run bridge-status.ps1 to verify." -ForegroundColor Green
        exit 0
    }
}

# --- Step 3: Start bridge ---
Write-Host "[3/4] Starting bridge..." -ForegroundColor White

# Find Node.js
$node = $null
foreach ($candidate in @('node', 'node.exe')) {
    try {
        $ver = & $candidate --version 2>&1
        if ($ver -match 'v\d+') {
            $node = $candidate
            break
        }
    } catch { }
}

if (-not $node) {
    Write-Host "      ERROR: Node.js not found. Install Node.js and ensure it's in PATH." -ForegroundColor Red
    exit 1
}

Write-Host "      Node.js: $node ($( & $node --version 2>&1 ))" -ForegroundColor DarkGray

# Start as detached process
$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $node
$startInfo.Arguments = "`"$bridgeScript`" $port"
$startInfo.WorkingDirectory = 'C:\scripts\tools'
$startInfo.UseShellExecute = $false
$startInfo.RedirectStandardOutput = $false
$startInfo.RedirectStandardError = $false
$startInfo.CreateNoWindow = $true

$bridgeProcess = [System.Diagnostics.Process]::Start($startInfo)

# Give it a moment to start
Start-Sleep -Seconds 1

# Verify it's running
if ($bridgeProcess.HasExited) {
    Write-Host "      ERROR: Bridge process exited immediately (code $($bridgeProcess.ExitCode))" -ForegroundColor Red
    $stderr = $bridgeProcess.StandardError.ReadToEnd()
    if ($stderr) { Write-Host "      $stderr" -ForegroundColor Red }
    exit 1
}

Write-Host "      Bridge started (PID $($bridgeProcess.Id))" -ForegroundColor Green

# Quick health check
Start-Sleep -Milliseconds 500
try {
    $health = Invoke-RestMethod -Uri "http://localhost:$port/health" -TimeoutSec 3
    Write-Host "      Health OK: machine=$($health.machine), messages=$($health.messageCount)" -ForegroundColor Green
} catch {
    Write-Host "      WARNING: Could not verify health (bridge may still be starting)" -ForegroundColor Yellow
}

# --- Step 4: Firewall ---
Write-Host "[4/4] Firewall rule..." -ForegroundColor White

if ($NoFirewall) {
    Write-Host "      Skipped (-NoFirewall)" -ForegroundColor DarkGray
} else {
    $ruleName = "Jengo Cross-Machine Bridge (Port $port)"
    $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

    if ($existingRule) {
        Write-Host "      Rule already exists: '$ruleName'" -ForegroundColor Green
    } else {
        try {
            # Check if running as admin
            $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

            if ($isAdmin) {
                New-NetFirewallRule `
                    -DisplayName $ruleName `
                    -Direction Inbound `
                    -Protocol TCP `
                    -LocalPort $port `
                    -Action Allow `
                    -Profile Any `
                    -Description "Allow Jengo cross-machine bridge traffic on Tailscale VPN" `
                    | Out-Null
                Write-Host "      Firewall rule created: '$ruleName'" -ForegroundColor Green
            } else {
                Write-Host "      Not running as admin - creating rule via elevation..." -ForegroundColor Yellow
                $cmd = "New-NetFirewallRule -DisplayName '$ruleName' -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow -Profile Any -Description 'Allow Jengo cross-machine bridge traffic on Tailscale VPN'"
                Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -Command $cmd" -Verb RunAs -Wait
                Write-Host "      Firewall rule created (elevated)." -ForegroundColor Green
            }
        } catch {
            Write-Host "      WARNING: Could not create firewall rule: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "      Run manually as admin: New-NetFirewallRule -DisplayName '$ruleName' -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow" -ForegroundColor DarkYellow
        }
    }
}

Write-Host ""
Write-Host "  Bridge is RUNNING" -ForegroundColor Green
Write-Host "  Local:  http://localhost:$port" -ForegroundColor Cyan
Write-Host "  Verify: bridge-status.ps1" -ForegroundColor DarkGray
Write-Host "  Send:   jengo-send.ps1 -To desktop -Message 'Hello'" -ForegroundColor DarkGray
Write-Host "  Check:  jengo-check.ps1" -ForegroundColor DarkGray
Write-Host ""
