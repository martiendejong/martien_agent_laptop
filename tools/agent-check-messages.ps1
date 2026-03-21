# agent-check-messages.ps1
# Check messages for an agent
# Usage: agent-check-messages.ps1 -Agent agent-001 [-Unread] [-Inject]

param(
    [Parameter(Mandatory=$true)]
    [string]$Agent,

    [switch]$Unread,  # Only show unread
    [switch]$Inject,  # Inject into conversation (for Claude Code)
    [int]$Limit = 10  # Max messages to show
)

$ErrorActionPreference = "Stop"

function Write-Success { param([string]$msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Info { param([string]$msg) Write-Host "[*] $msg" -ForegroundColor Cyan }

$mailDir = "C:\scripts\_machine\agent-mail"
$inboxFile = "$mailDir\inbox\$Agent.jsonl"

if (-not (Test-Path $inboxFile)) {
    Write-Host "[*] No messages for $Agent" -ForegroundColor Yellow
    return @()
}

# Read messages (JSONL format)
$messages = Get-Content $inboxFile | ForEach-Object {
    $_ | ConvertFrom-Json
}

# Filter unread if requested
if ($Unread) {
    $messages = $messages | Where-Object { -not $_.read }
}

# Sort by timestamp (newest first)
$messages = $messages | Sort-Object -Property timestamp -Descending

# Limit
if ($messages.Count -gt $Limit) {
    $messages = $messages | Select-Object -First $Limit
}

if ($messages.Count -eq 0) {
    if ($Unread) {
        Write-Host "[*] No unread messages for $Agent" -ForegroundColor Yellow
    } else {
        Write-Host "[*] No messages for $Agent" -ForegroundColor Yellow
    }
    return @()
}

Write-Info "$($messages.Count) message(s) for $Agent"
Write-Host ""

foreach ($msg in $messages) {
    $priorityColor = switch ($msg.priority) {
        "urgent" { "Red" }
        "high" { "Yellow" }
        default { "White" }
    }

    $readStatus = if ($msg.read) { "" } else { "[UNREAD] " }

    Write-Host "$readStatus[$($msg.type.ToUpper())] " -NoNewline -ForegroundColor $priorityColor
    Write-Host "$($msg.subject)" -ForegroundColor Cyan
    Write-Host "  From: $($msg.from) | Priority: $($msg.priority) | Time: $($msg.timestamp)"
    Write-Host "  $($msg.body)"
    Write-Host "  Message ID: $($msg.id)"
    Write-Host ""
}

# Inject into conversation if requested
if ($Inject) {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "INCOMING MESSAGES" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""

    foreach ($msg in $messages) {
        Write-Host "From: $($msg.from)" -ForegroundColor Green
        Write-Host "Subject: $($msg.subject)" -ForegroundColor Green
        Write-Host "Priority: $($msg.priority) | Type: $($msg.type)" -ForegroundColor Gray
        Write-Host ""
        Write-Host $msg.body
        Write-Host ""
        Write-Host "---" -ForegroundColor Gray
        Write-Host ""
    }

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
}

return $messages
