#Requires -Version 5.1
<#
.SYNOPSIS
    Send a message to a remote Jengo agent on another machine.

.DESCRIPTION
    Reads cross-machine config, looks up auth token from vault,
    and POSTs a message to the target machine's bridge server.

.PARAMETER To
    Target machine name (e.g. "desktop" or "laptop")

.PARAMETER Message
    Message content to send

.PARAMETER Type
    Message type: text, request, notification, task (default: text)

.PARAMETER From
    Sender identity (default: jengo-<this_machine>)

.EXAMPLE
    jengo-send.ps1 -To desktop -Message "Hello from laptop"
    jengo-send.ps1 -To laptop -Message "Task complete: PR #123 merged" -Type notification
    jengo-send.ps1 -To desktop -Message "Need your help with X" -Type request
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$To,

    [Parameter(Mandatory = $true)]
    [string]$Message,

    [ValidateSet('text', 'request', 'notification', 'task', 'alert')]
    [string]$Type = 'text',

    [string]$From = ''
)

$ErrorActionPreference = 'Stop'

# Load config
$configPath = 'C:\scripts\_machine\cross-machine-config.json'
if (-not (Test-Path $configPath)) {
    Write-Error "Config not found: $configPath"
    exit 1
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json
$thisMachine = $config.this_machine

# Resolve sender identity
if (-not $From) {
    $From = "jengo-$thisMachine"
}

# Resolve target machine
$To = $To.ToLower()
if (-not $config.machines.$To) {
    $available = ($config.machines | Get-Member -MemberType NoteProperty).Name -join ', '
    Write-Error "Unknown machine '$To'. Available: $available"
    exit 1
}

$targetUrl = $config.machines.$To.bridge_url
if (-not $targetUrl) {
    Write-Error "No bridge_url configured for machine '$To'"
    exit 1
}

# Get auth token from vault
$vaultKey = $config.auth_token_vault_key
$tokenFile = 'C:\scripts\_machine\bridge-auth.token'

$authToken = $null

# Try vault first
try {
    $authToken = & powershell.exe -ExecutionPolicy Bypass -File 'C:\scripts\tools\vault.ps1' -Action get -Service $vaultKey -Field token 2>$null
    if ($authToken -and $authToken -notmatch '\[' -and $authToken.Trim().Length -gt 0) {
        $authToken = $authToken.Trim()
    } else {
        $authToken = $null
    }
} catch {
    $authToken = $null
}

# Fallback: read token file directly
if (-not $authToken -and (Test-Path $tokenFile)) {
    $authToken = (Get-Content $tokenFile -Raw).Trim()
}

if (-not $authToken) {
    Write-Warning "No auth token found. Request may be rejected by remote bridge."
}

# Build payload
$payload = @{
    from    = $From
    to      = $To
    content = $Message
    type    = $Type
} | ConvertTo-Json -Compress

# Build headers
$headers = @{
    'Content-Type' = 'application/json'
}
if ($authToken) {
    $headers['X-Auth-Token'] = $authToken
}

# Send message
$endpoint = "$targetUrl/messages"
Write-Host "[jengo-send] $From -> $To ($Type): $Message" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri $endpoint -Method Post -Body $payload -Headers $headers -TimeoutSec 10

    if ($response.success) {
        $msgId = $response.message.id
        $ts = $response.message.timestamp
        Write-Host "[jengo-send] Delivered (id=$msgId, ts=$ts)" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "[jengo-send] Unexpected response: $($response | ConvertTo-Json)" -ForegroundColor Yellow
        exit 1
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 401) {
        Write-Host "[jengo-send] ERROR: Unauthorized (401) - check auth token" -ForegroundColor Red
    } elseif ($statusCode) {
        Write-Host "[jengo-send] ERROR: HTTP $statusCode from $targetUrl" -ForegroundColor Red
    } else {
        Write-Host "[jengo-send] ERROR: Could not reach $targetUrl" -ForegroundColor Red
        Write-Host "  $($_.Exception.Message)" -ForegroundColor DarkRed
        Write-Host "  Is the bridge running on '$To'? Run bridge-start.ps1 there." -ForegroundColor DarkYellow
    }
    exit 1
}
