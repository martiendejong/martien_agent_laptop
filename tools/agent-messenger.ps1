# agent-messenger.ps1
# Inter-agent communication protocol
# Enables agents to send messages, share knowledge, and coordinate work

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Send", "Receive", "Subscribe", "Broadcast", "Status")]
    [string]$Action,

    [string]$FromAgent = "",
    [string]$ToAgent = "",
    [string]$Message = "",
    [string]$Channel = "general",
    [ValidateSet("info", "warning", "error", "task", "knowledge")]
    [string]$Type = "info",
    [switch]$Wait
)

$script:MessagesDir = "C:\scripts\_machine\messages"
$script:ChannelsFile = "C:\scripts\_machine\message-channels.json"

# Ensure messages directory exists
if (-not (Test-Path $script:MessagesDir)) {
    New-Item -ItemType Directory -Path $script:MessagesDir -Force | Out-Null
}

function Get-ChannelConfig {
    if (Test-Path $script:ChannelsFile) {
        return Get-Content $script:ChannelsFile -Raw | ConvertFrom-Json
    }
    return @{
        Channels = @{
            general = @{
                Subscribers = @()
                MessageCount = 0
            }
            coordination = @{
                Subscribers = @()
                MessageCount = 0
            }
            knowledge = @{
                Subscribers = @()
                MessageCount = 0
            }
        }
    }
}

function Set-ChannelConfig {
    param($Config)
    $Config | ConvertTo-Json -Depth 10 | Set-Content -Path $script:ChannelsFile -Force
}

function Send-Message {
    param(
        [string]$From,
        [string]$To,
        [string]$Channel,
        [string]$Type,
        [string]$MessageText
    )

    $message = @{
        Id = [guid]::NewGuid().ToString()
        From = $From
        To = $To
        Channel = $Channel
        Type = $Type
        Message = $MessageText
        Timestamp = (Get-Date).ToString("o")
        Read = $false
    }

    # Save to channel file
    $channelFile = Join-Path $script:MessagesDir "$Channel.jsonl"
    $json = $message | ConvertTo-Json -Compress
    Add-Content -Path $channelFile -Value $json

    # Update channel stats
    $config = Get-ChannelConfig
    if (-not $config.Channels.ContainsKey($Channel)) {
        $config.Channels[$Channel] = @{
            Subscribers = @()
            MessageCount = 0
        }
    }
    $config.Channels[$Channel].MessageCount++
    Set-ChannelConfig -Config $config

    Write-Host "✅ Message sent to $Channel" -ForegroundColor Green
    Write-Host "   From: $From" -ForegroundColor Gray
    Write-Host "   To: $To" -ForegroundColor Gray
    Write-Host "   Type: $Type" -ForegroundColor Gray
    Write-Host "   Message ID: $($message.Id)" -ForegroundColor DarkGray

    return $message.Id
}

function Receive-Messages {
    param(
        [string]$AgentId,
        [string]$Channel,
        [switch]$Wait
    )

    $channelFile = Join-Path $script:MessagesDir "$Channel.jsonl"

    if (-not (Test-Path $channelFile)) {
        if ($Wait) {
            Write-Host "⏳ Waiting for messages on $Channel..." -ForegroundColor Cyan
            while (-not (Test-Path $channelFile)) {
                Start-Sleep -Seconds 1
            }
        } else {
            Write-Host "⚠️ No messages in $Channel" -ForegroundColor Yellow
            return @()
        }
    }

    # Read all messages
    $content = Get-Content $channelFile
    $messages = $content | ForEach-Object {
        $_ | ConvertFrom-Json
    }

    # Filter for this agent (direct messages or broadcast)
    $relevantMessages = $messages | Where-Object {
        ($_.To -eq $AgentId -or $_.To -eq "all" -or $_.To -eq "") -and -not $_.Read
    }

    if ($relevantMessages.Count -eq 0) {
        Write-Host "📭 No new messages for $AgentId" -ForegroundColor Gray
        return @()
    }

    Write-Host "📬 $($relevantMessages.Count) new messages for $AgentId" -ForegroundColor Green

    foreach ($msg in $relevantMessages) {
        $typeEmoji = switch ($msg.Type) {
            "info" { "ℹ️" }
            "warning" { "⚠️" }
            "error" { "❌" }
            "task" { "📋" }
            "knowledge" { "🧠" }
            default { "📨" }
        }

        Write-Host "`n$typeEmoji [$($msg.Type.ToUpper())] From: $($msg.From)" -ForegroundColor Cyan
        Write-Host "   $($msg.Message)" -ForegroundColor White
        Write-Host "   Time: $($msg.Timestamp)" -ForegroundColor DarkGray
        Write-Host "   ID: $($msg.Id)" -ForegroundColor DarkGray
    }

    return $relevantMessages
}

function Add-Subscription {
    param(
        [string]$AgentId,
        [string]$Channel
    )

    $config = Get-ChannelConfig

    if (-not $config.Channels.ContainsKey($Channel)) {
        $config.Channels[$Channel] = @{
            Subscribers = @()
            MessageCount = 0
        }
    }

    if ($config.Channels[$Channel].Subscribers -notcontains $AgentId) {
        $config.Channels[$Channel].Subscribers += $AgentId
        Set-ChannelConfig -Config $config

        Write-Host "✅ $AgentId subscribed to $Channel" -ForegroundColor Green
    } else {
        Write-Host "⚠️ $AgentId already subscribed to $Channel" -ForegroundColor Yellow
    }
}

function Send-Broadcast {
    param(
        [string]$From,
        [string]$Channel,
        [string]$Type,
        [string]$MessageText
    )

    $message = Send-Message -From $From -To "all" -Channel $Channel -Type $Type -MessageText $MessageText

    Write-Host "📢 Broadcast sent to all subscribers on $Channel" -ForegroundColor Green

    return $message
}

function Show-MessagingStatus {
    $config = Get-ChannelConfig

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "📨 AGENT MESSAGING STATUS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

    Write-Host "`n📺 Channels: $($config.Channels.Count)" -ForegroundColor Cyan

    foreach ($channelName in $config.Channels.Keys) {
        $channel = $config.Channels[$channelName]

        Write-Host "`n   📺 $channelName" -ForegroundColor Yellow
        Write-Host "      Subscribers: $($channel.Subscribers.Count)" -ForegroundColor Gray
        Write-Host "      Messages: $($channel.MessageCount)" -ForegroundColor Gray

        if ($channel.Subscribers.Count -gt 0) {
            Write-Host "      Agents: $($channel.Subscribers -join ', ')" -ForegroundColor DarkGray
        }

        # Show recent messages
        $channelFile = Join-Path $script:MessagesDir "$channelName.jsonl"
        if (Test-Path $channelFile) {
            $content = Get-Content $channelFile -Tail 3
            if ($content) {
                Write-Host "      Recent messages:" -ForegroundColor DarkGray
                foreach ($line in $content) {
                    $msg = $line | ConvertFrom-Json
                    $age = ((Get-Date) - [DateTime]$msg.Timestamp).TotalMinutes
                    Write-Host "        [$([math]::Round($age, 0))m ago] $($msg.From) → $($msg.To): $($msg.Message.Substring(0, [Math]::Min(50, $msg.Message.Length)))..." -ForegroundColor DarkGray
                }
            }
        }
    }

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

# Main logic
switch ($Action) {
    "Send" {
        if (-not $FromAgent -or -not $Message) {
            Write-Host "❌ Send requires -FromAgent and -Message parameters" -ForegroundColor Red
            exit 1
        }

        if (-not $ToAgent) {
            $ToAgent = "all"
        }

        $messageId = Send-Message -From $FromAgent -To $ToAgent -Channel $Channel -Type $Type -MessageText $Message
        exit 0
    }

    "Receive" {
        if (-not $FromAgent) {
            Write-Host "❌ Receive requires -FromAgent parameter (agent ID checking messages)" -ForegroundColor Red
            exit 1
        }

        $messages = Receive-Messages -AgentId $FromAgent -Channel $Channel -Wait:$Wait
        exit 0
    }

    "Subscribe" {
        if (-not $FromAgent) {
            Write-Host "❌ Subscribe requires -FromAgent parameter" -ForegroundColor Red
            exit 1
        }

        Add-Subscription -AgentId $FromAgent -Channel $Channel
        exit 0
    }

    "Broadcast" {
        if (-not $FromAgent -or -not $Message) {
            Write-Host "❌ Broadcast requires -FromAgent and -Message parameters" -ForegroundColor Red
            exit 1
        }

        $messageId = Send-Broadcast -From $FromAgent -Channel $Channel -Type $Type -MessageText $Message
        exit 0
    }

    "Status" {
        Show-MessagingStatus
        exit 0
    }
}
