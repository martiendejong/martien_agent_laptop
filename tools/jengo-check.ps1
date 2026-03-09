#Requires -Version 5.1
<#
.SYNOPSIS
    Check messages on the Jengo hub bridge (production server).

.DESCRIPTION
    Reads from the central server hub (85.215.217.154:9998) and displays messages for this machine.

.PARAMETER All
    Show all messages (default: only unread)

.PARAMETER From
    Filter messages by sender machine name

.PARAMETER Mark
    Mark all messages as read after displaying

.PARAMETER Json
    Output raw JSON instead of formatted display

.EXAMPLE
    jengo-check.ps1                    # unread messages
    jengo-check.ps1 -All               # all messages
    jengo-check.ps1 -From desktop      # from desktop only
    jengo-check.ps1 -Mark              # show unread + mark as read
#>

param(
    [switch]$All,
    [string]$From = '',
    [switch]$Mark,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

# Load config - connect to hub (production server), not localhost
$configPath = 'C:\scripts\_machine\cross-machine-config.json'
$port = 9998
$thisMachine = 'laptop'
if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    if ($config.bridge_port) { $port = $config.bridge_port }
    if ($config.this_machine) { $thisMachine = $config.this_machine }
}

# Hub URL: use server hub, fall back to localhost
$baseUrl = "http://localhost:$port"
if (Test-Path $configPath) {
    if ($config.hub -and $config.hub.bridge_url) {
        $baseUrl = $config.hub.bridge_url
    } elseif ($config.machines -and $config.machines.server) {
        $baseUrl = $config.machines.server.bridge_url
    }
}

# Get auth token for mark operations
$authToken = $null
$tokenFile = 'C:\scripts\_machine\bridge-auth.token'
if (Test-Path $tokenFile) {
    $authToken = (Get-Content $tokenFile -Raw).Trim()
}

$authHeaders = @{
    'Content-Type' = 'application/json'
}
if ($authToken) {
    $authHeaders['X-Auth-Token'] = $authToken
}

# Check if bridge is reachable
try {
    $health = Invoke-RestMethod -Uri "$baseUrl/health" -TimeoutSec 5
} catch {
    Write-Host "[jengo-check] Hub bridge not reachable at $baseUrl" -ForegroundColor Red
    Write-Host "  Server bridge (85.215.217.154) may be down. Check server-deploy-bridge.ps1" -ForegroundColor DarkYellow
    exit 1
}

# Fetch messages - filter to this machine by default
$endpoint = if ($All) { "$baseUrl/messages?to=jengo-$thisMachine" } else { "$baseUrl/messages/unread?to=jengo-$thisMachine" }
if ($From) {
    $fromMachine = $From.ToLower()
    $endpoint += "&from=jengo-$fromMachine"
}

try {
    $result = Invoke-RestMethod -Uri $endpoint -TimeoutSec 5
} catch {
    Write-Host "[jengo-check] Error fetching messages: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$msgs = if ($All) { $result.messages } else { $result.messages }

if ($Json) {
    $msgs | ConvertTo-Json -Depth 5
    exit 0
}

# Display header
$label = if ($All) { "ALL" } else { "UNREAD" }
$fromLabel = if ($From) { " (from: $From)" } else { "" }
Write-Host ""
Write-Host "  Jengo Bridge Messages [$label$fromLabel]" -ForegroundColor Cyan
Write-Host "  Machine: $($health.machine) | Total: $($health.messageCount) | Unread: $($health.unreadCount)" -ForegroundColor DarkGray
Write-Host ("  " + ("-" * 60)) -ForegroundColor DarkGray

if ($msgs.Count -eq 0) {
    Write-Host "  (no messages)" -ForegroundColor DarkGray
} else {
    foreach ($msg in $msgs) {
        $ts = if ($msg.timestamp) {
            try { ([datetime]$msg.timestamp).ToLocalTime().ToString("MM-dd HH:mm") } catch { $msg.timestamp }
        } else { "?" }

        $statusColor = if ($msg.status -eq 'unread') { 'Yellow' } else { 'DarkGray' }
        $typeLabel = if ($msg.type -and $msg.type -ne 'text') { "[$($msg.type.ToUpper())] " } else { "" }
        $srcLabel = if ($msg.source_ip -and $msg.source_ip -ne '127.0.0.1') { " <$($msg.source_ip)>" } else { "" }

        Write-Host ""
        Write-Host "  #$($msg.id) [$ts] $($msg.from) -> $($msg.to)$srcLabel" -ForegroundColor $statusColor
        Write-Host "  $typeLabel$($msg.content)" -ForegroundColor White

        if ($msg.status -eq 'read' -and $msg.readAt) {
            $readTs = try { ([datetime]$msg.readAt).ToLocalTime().ToString("HH:mm") } catch { $msg.readAt }
            Write-Host "  (read at $readTs)" -ForegroundColor DarkGray
        }
    }
}

Write-Host ""

# Mark as read if requested
if ($Mark) {
    try {
        $markResult = Invoke-RestMethod -Uri "$baseUrl/messages/read-all" -Method Post -Headers $authHeaders -TimeoutSec 5
        if ($markResult.success) {
            Write-Host "  Marked $($markResult.marked) message(s) as read." -ForegroundColor Green
        }
    } catch {
        Write-Host "  [ERROR] Could not mark messages as read: $($_.Exception.Message)" -ForegroundColor Red
    }
}
