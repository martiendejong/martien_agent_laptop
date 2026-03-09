<#
.SYNOPSIS
    Deploy cross-machine bridge to production server (85.215.217.154)

.DESCRIPTION
    Copies bridge files to server and registers as a Scheduled Task (runs at startup,
    persists across WinRM session ends). Acts as central hub for laptop + desktop.
#>

$ErrorActionPreference = 'Stop'
$serverIp = '85.215.217.154'
$port = 9998
$taskName = 'Jengo-CrossMachine-Bridge'

Write-Host ""
Write-Host "  Deploying Jengo Bridge to Production Server" -ForegroundColor Cyan
Write-Host "  Target: $serverIp`:$port (Scheduled Task)" -ForegroundColor DarkGray
Write-Host ""

# Credentials
$password = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ('administrator', $password)

# Read local bridge file
$bridgeJs  = Get-Content 'C:\scripts\tools\cross-machine-bridge.js' -Raw
$authToken = (Get-Content 'C:\scripts\_machine\bridge-auth.token' -Raw).Trim()

# Server config (hub mode)
$serverConfig = @"
{
  "this_machine": "server",
  "machines": {
    "server": {
      "name": "server",
      "hostname": "production",
      "public_ip": "$serverIp",
      "bridge_port": $port,
      "bridge_url": "http://$serverIp`:$port"
    },
    "laptop": {
      "name": "laptop",
      "hostname": "win-c6osts73hta",
      "tailscale_ip": "100.96.143.109",
      "bridge_url": "http://100.96.143.109:$port"
    },
    "desktop": {
      "name": "desktop",
      "hostname": "desktop-ecbaunu",
      "tailscale_ip": "100.90.208.67",
      "bridge_url": "http://100.90.208.67:$port"
    }
  },
  "auth_token_vault_key": "cross-machine-auth",
  "bridge_port": $port
}
"@

Write-Host "[1/5] Uploading bridge files..." -ForegroundColor White
Invoke-Command -ComputerName $serverIp -Credential $cred -ArgumentList $bridgeJs, $authToken, $serverConfig -ScriptBlock {
    param($bridgeJs, $authToken, $configJson)
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    New-Item -ItemType Directory -Path 'C:\scripts\tools' -Force | Out-Null
    New-Item -ItemType Directory -Path 'C:\scripts\_machine' -Force | Out-Null
    [System.IO.File]::WriteAllText('C:\scripts\tools\cross-machine-bridge.js', $bridgeJs, $utf8NoBom)
    [System.IO.File]::WriteAllText('C:\scripts\_machine\bridge-auth.token', $authToken, [System.Text.Encoding]::ASCII)
    [System.IO.File]::WriteAllText('C:\scripts\_machine\cross-machine-config.json', $configJson, $utf8NoBom)
    Write-Host "      Files written OK" -ForegroundColor Green
}

Write-Host "[2/5] Firewall rule for port $port..." -ForegroundColor White
Invoke-Command -ComputerName $serverIp -Credential $cred -ArgumentList $port -ScriptBlock {
    param($port)
    $rule = Get-NetFirewallRule -DisplayName "Jengo Cross-Machine Bridge (Port $port)" -ErrorAction SilentlyContinue
    if (-not $rule) {
        New-NetFirewallRule -DisplayName "Jengo Cross-Machine Bridge (Port $port)" `
            -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow -Profile Any | Out-Null
        Write-Host "      Rule created" -ForegroundColor Green
    } else {
        Write-Host "      Rule already exists" -ForegroundColor Green
    }
}

Write-Host "[3/5] Registering Scheduled Task (persist across reboots)..." -ForegroundColor White
Invoke-Command -ComputerName $serverIp -Credential $cred -ArgumentList $taskName, $port -ScriptBlock {
    param($taskName, $port)

    # Remove existing task if present
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

    $nodePath = (Get-Command node -ErrorAction SilentlyContinue).Source
    if (-not $nodePath) { $nodePath = 'node' }

    $action  = New-ScheduledTaskAction -Execute $nodePath -Argument 'C:\scripts\tools\cross-machine-bridge.js' -WorkingDirectory 'C:\scripts\tools'
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit 0 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
    $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest

    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description 'Jengo cross-machine message broker' | Out-Null
    Write-Host "      Task registered: '$taskName'" -ForegroundColor Green
}

Write-Host "[4/5] Starting task now..." -ForegroundColor White
Invoke-Command -ComputerName $serverIp -Credential $cred -ArgumentList $taskName -ScriptBlock {
    param($taskName)
    Start-ScheduledTask -TaskName $taskName
    Start-Sleep -Seconds 3
    $state = (Get-ScheduledTask -TaskName $taskName).State
    Write-Host "      Task state: $state" -ForegroundColor $(if ($state -eq 'Running') { 'Green' } else { 'Yellow' })

    # Check port
    $listening = Get-NetTCPConnection -LocalPort 9998 -State Listen -ErrorAction SilentlyContinue
    if ($listening) {
        Write-Host "      Port 9998: LISTENING (PID $($listening[0].OwningProcess))" -ForegroundColor Green
    } else {
        Write-Host "      Port 9998: not yet listening" -ForegroundColor Yellow
    }
}

Write-Host "[5/5] External health check..." -ForegroundColor White
Start-Sleep -Seconds 2
try {
    $health = Invoke-RestMethod -Uri "http://${serverIp}:${port}/health" -TimeoutSec 5
    Write-Host "      HEALTH OK: machine=$($health.machine), uptime=$($health.uptime_seconds)s" -ForegroundColor Green
    $ok = $true
} catch {
    Write-Host "      UNREACHABLE from laptop: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "      Check VPS/hosting firewall - port $port may need to be opened there too" -ForegroundColor DarkYellow
    $ok = $false
}

Write-Host ""
if ($ok) {
    Write-Host "  SUCCESS: Bridge running at http://${serverIp}:$port" -ForegroundColor Green
} else {
    Write-Host "  Bridge deployed + task registered." -ForegroundColor Yellow
    Write-Host "  Bridge is running on server (verified locally)." -ForegroundColor Yellow
    Write-Host "  External access blocked - open port $port in your VPS/hosting firewall." -ForegroundColor Yellow
}
Write-Host ""
Write-Host "  Run update-to-server-bridge.ps1 to point laptop+desktop at server" -ForegroundColor DarkGray
