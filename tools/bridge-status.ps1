#Requires -Version 5.1
<#
.SYNOPSIS
    Check status of the cross-machine Jengo bridge - local and remote.

.DESCRIPTION
    Reports:
    - Whether the local bridge is running on port 9998
    - Reachability of all configured remote machines
    - Message queue stats

.EXAMPLE
    bridge-status.ps1
#>

param()

$ErrorActionPreference = 'SilentlyContinue'

$configPath = 'C:\scripts\_machine\cross-machine-config.json'
$port = 9998

# Load config
$config = $null
$machines = @{}
$thisMachine = 'unknown'

if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    if ($config.bridge_port) { $port = $config.bridge_port }
    $thisMachine = $config.this_machine
    if ($config.machines) {
        $config.machines | Get-Member -MemberType NoteProperty | ForEach-Object {
            $machines[$_.Name] = $config.machines.($_.Name)
        }
    }
}

Write-Host ""
Write-Host "  Jengo Bridge Status" -ForegroundColor Cyan
Write-Host "  This machine: $thisMachine | Port: $port" -ForegroundColor DarkGray
Write-Host ""

# Check local bridge
Write-Host "  --- Local Bridge ---" -ForegroundColor White

$localUrl = "http://localhost:$port"
$sw = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $health = Invoke-RestMethod -Uri "$localUrl/health" -TimeoutSec 3
    $sw.Stop()
    $ms = $sw.ElapsedMilliseconds

    Write-Host "  [LOCAL]   bridge on 0.0.0.0:$port - RUNNING ($ms ms)" -ForegroundColor Green
    Write-Host "            Machine: $($health.machine) | Messages: $($health.messageCount) | Unread: $($health.unreadCount)" -ForegroundColor DarkGray

    if ($health.uptime_seconds) {
        $uptime = [TimeSpan]::FromSeconds($health.uptime_seconds)
        $uptimeStr = if ($uptime.TotalHours -ge 1) { "$([int]$uptime.TotalHours)h $($uptime.Minutes)m" } else { "$($uptime.Minutes)m $($uptime.Seconds)s" }
        Write-Host "            Uptime: $uptimeStr" -ForegroundColor DarkGray
    }
} catch {
    $sw.Stop()
    Write-Host "  [LOCAL]   bridge on 0.0.0.0:$port - NOT RUNNING" -ForegroundColor Red
    Write-Host "            Run: bridge-start.ps1" -ForegroundColor DarkYellow
}

Write-Host ""

# Check process listening on port
$tcpConn = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
if ($tcpConn) {
    $pid = ($tcpConn | Select-Object -First 1).OwningProcess
    $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
    $procName = if ($proc) { "$($proc.ProcessName) (PID $pid)" } else { "PID $pid" }
    Write-Host "  Process:  $procName" -ForegroundColor DarkGray
    Write-Host ""
}

# Check remote machines
if ($machines.Count -gt 0) {
    Write-Host "  --- Remote Machines ---" -ForegroundColor White

    foreach ($machineName in $machines.Keys) {
        $machineInfo = $machines[$machineName]
        $url = $machineInfo.bridge_url
        if (-not $url) { continue }

        $sw2 = [System.Diagnostics.Stopwatch]::StartNew()

        try {
            $remoteHealth = Invoke-RestMethod -Uri "$url/health" -TimeoutSec 5
            $sw2.Stop()
            $ms2 = $sw2.ElapsedMilliseconds

            $isLocal = ($machineName -eq $thisMachine)
            $tag = if ($isLocal) { "$machineName (this)" } else { $machineName }
            $note = if ($isLocal) { " (local)" } else { "" }

            $tagUpper = $tag.ToUpper().PadRight(8)
            Write-Host "  [$tagUpper] $url/health - REACHABLE ($ms2 ms)$note" -ForegroundColor Green
            Write-Host "             Machine: $($remoteHealth.machine) | Unread: $($remoteHealth.unreadCount)" -ForegroundColor DarkGray
        } catch {
            $sw2.Stop()
            $tagUpper = $machineName.ToUpper().PadRight(8)
            Write-Host "  [$tagUpper] $url/health - UNREACHABLE" -ForegroundColor Red
            Write-Host "             Check: is bridge-start.ps1 running on $machineName?" -ForegroundColor DarkYellow
        }
    }
} else {
    Write-Host "  (no machines configured in $configPath)" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "  --- Commands ---" -ForegroundColor White
Write-Host "  jengo-send.ps1 -To desktop -Message 'Hello'"  -ForegroundColor DarkGray
Write-Host "  jengo-check.ps1                               # unread messages"  -ForegroundColor DarkGray
Write-Host "  jengo-check.ps1 -All -From desktop            # all from desktop"  -ForegroundColor DarkGray
Write-Host "  jengo-check.ps1 -Mark                         # mark all as read"  -ForegroundColor DarkGray
Write-Host ""
