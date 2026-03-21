# WhatsApp EventBus Poller
# Polls WhatsApp API every 5 minutes and posts new messages to the EventBus API
# Usage: Run via scheduled task or as background service

param(
    [int]$LookbackMinutes = 10,  # How far back to look for messages
    [string]$StateFile = "C:\scripts\_machine\whatsapp-poller-state.json",
    [string]$EventBusUrl = "https://localhost:7087/api/events",  # DataDrivenAI EventOrchestrator
    [switch]$Silent
)

# Initialize state
if (-not (Test-Path $StateFile)) {
    @{
        lastPollTime = (Get-Date).AddMinutes(-$LookbackMinutes).ToString("o")
        processedMessageIds = @()
    } | ConvertTo-Json | Set-Content $StateFile
}

$state = Get-Content $StateFile | ConvertFrom-Json
$lastPollTime = [DateTime]::Parse($state.lastPollTime)
$processedIds = $state.processedMessageIds

if (-not $Silent) {
    Write-Host "[WhatsApp Poller] Starting poll cycle at $(Get-Date -Format 'HH:mm:ss')"
    Write-Host "Last poll: $($lastPollTime.ToString('yyyy-MM-dd HH:mm:ss'))"
}

# Get credentials from vault
# The vault script outputs "Credentials for: ..." followed by JSON string
$vaultRaw = & "C:\scripts\tools\vault.ps1" -Action get -Service whatsapp-bridge-api
# Find the JSON string (starts with {)
$jsonString = $vaultRaw | Where-Object { $_ -match '^\s*\{' } | Select-Object -First 1
if (-not $jsonString) {
    Write-Error "Failed to retrieve WhatsApp API credentials from vault"
    exit 1
}

$vault = $jsonString | ConvertFrom-Json

if (-not $vault -or -not $vault.password) {
    Write-Error "Invalid WhatsApp API credentials in vault"
    exit 1
}

$apiToken = $vault.password
$email = $vault.username
$baseUrl = "https://whatsapp.wreckingball.ai:5001/api/external"

$headers = @{
    'X-Api-Token' = $apiToken
    'X-Email' = $email
    'Content-Type' = 'application/json'
}

# Get all chats
try {
    $chats = Invoke-RestMethod -Uri "$baseUrl/whatsapp/chats" -Headers $headers -ErrorAction Stop

    if (-not $Silent) {
        Write-Host "Found $($chats.Count) chats total"
    }

    # Filter to chats with recent activity (within lookback window)
    $cutoffTimestamp = [int]([DateTimeOffset]$lastPollTime).ToUnixTimeSeconds()
    $activeChats = $chats | Where-Object { $_.timestamp -gt $cutoffTimestamp }

    if (-not $Silent) {
        Write-Host "Active chats since last poll: $($activeChats.Count)"
    }

    $newMessages = @()
    $newProcessedIds = @($processedIds)

    # Get messages from each active chat
    foreach ($chat in $activeChats) {
        try {
            $messages = Invoke-RestMethod -Uri "$baseUrl/whatsapp/messages?chatId=$($chat.id)&limit=50" -Headers $headers

            foreach ($msg in $messages) {
                # Skip if already processed
                if ($processedIds -contains $msg.id) {
                    continue
                }

                # Skip if before last poll time
                $msgTime = [DateTimeOffset]::FromUnixTimeSeconds($msg.timestamp).DateTime
                if ($msgTime -lt $lastPollTime) {
                    continue
                }

                # Add to new messages
                $newMessages += @{
                    messageId = $msg.id
                    chatId = $chat.id
                    chatName = $chat.name
                    isGroup = $chat.isGroup
                    from = $msg.from
                    to = $msg.to
                    body = $msg.body
                    timestamp = $msg.timestamp
                    timestampUtc = $msgTime.ToString("o")
                    isFromMe = $msg.from -eq "31633984381@c.us"  # Your number
                }

                # Add to processed IDs
                $newProcessedIds += $msg.id
            }
        }
        catch {
            Write-Warning "Failed to get messages for chat $($chat.id): $_"
        }
    }

    if (-not $Silent) {
        Write-Host "New messages found: $($newMessages.Count)"
    }

    # Post new messages to DataDrivenAI EventOrchestrator
    if ($newMessages.Count -gt 0) {
        foreach ($msg in $newMessages) {
            try {
                # Format according to DataDrivenAI event schema
                $eventPayload = @{
                    eventType = "whatsapp.message.received"
                    data = @{
                        message = $msg
                    }
                    correlationId = $msg.messageId
                } | ConvertTo-Json -Depth 5

                # Post to EventOrchestrator
                $response = Invoke-RestMethod -Uri $EventBusUrl -Method Post -Body $eventPayload -ContentType "application/json" -ErrorAction Stop

                if (-not $Silent) {
                    Write-Host "  [POSTED] $($msg.chatName): $($msg.body.Substring(0, [Math]::Min(50, $msg.body.Length)))..."
                }
            }
            catch {
                Write-Warning "Failed to post event for message $($msg.messageId): $_"
            }
        }
    }

    # Keep only last 1000 processed IDs (prevent state file from growing indefinitely)
    if ($newProcessedIds.Count -gt 1000) {
        $newProcessedIds = $newProcessedIds | Select-Object -Last 1000
    }

    # Update state
    @{
        lastPollTime = (Get-Date).ToString("o")
        processedMessageIds = $newProcessedIds
    } | ConvertTo-Json | Set-Content $StateFile

    if (-not $Silent) {
        Write-Host "[SUCCESS] Poll cycle complete. Processed IDs: $($newProcessedIds.Count)"
    }
}
catch {
    Write-Error "WhatsApp poller failed: $_"
    exit 1
}
