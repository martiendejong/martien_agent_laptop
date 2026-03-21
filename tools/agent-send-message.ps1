# agent-send-message.ps1
# Send a message between agents
# Usage: agent-send-message.ps1 -From agent-001 -To agent-002 -Subject "Task complete" -Body "Details here" [-Priority urgent]

param(
    [Parameter(Mandatory=$true)]
    [string]$From,

    [Parameter(Mandatory=$true)]
    [string]$To,  # Or @all, @scouts, @builders, etc.

    [Parameter(Mandatory=$true)]
    [string]$Subject,

    [Parameter(Mandatory=$true)]
    [string]$Body,

    [ValidateSet("low", "normal", "high", "urgent")]
    [string]$Priority = "normal",

    [ValidateSet("status", "question", "result", "error", "command")]
    [string]$Type = "status",

    [string]$ThreadId = ""  # For replies
)

$ErrorActionPreference = "Stop"

function Write-Success { param([string]$msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Info { param([string]$msg) Write-Host "[*] $msg" -ForegroundColor Cyan }

$mailDir = "C:\scripts\_machine\agent-mail"

# Generate message ID
$messageId = [guid]::NewGuid().ToString()
$timestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')

# Create message object
$message = @{
    id = $messageId
    from = $From
    to = $To
    subject = $Subject
    body = $Body
    type = $Type
    priority = $Priority
    timestamp = $timestamp
    read = $false
    thread_id = if ($ThreadId) { $ThreadId } else { $messageId }
} | ConvertTo-Json -Depth 10

# Handle broadcast addresses
$recipients = @()
if ($To -match '^@') {
    # Broadcast message
    $group = $To.TrimStart('@')

    # Read pool to find matching agents
    $poolFile = "C:\scripts\_machine\worktrees.pool.md"
    $poolContent = Get-Content $poolFile -Raw

    switch ($group) {
        "all" {
            # All BUSY agents
            $recipients = $poolContent | Select-String -Pattern '\| (agent-\d+) \|[^|]*\|[^|]*\|[^|]*\| BUSY \|' -AllMatches |
                ForEach-Object { $_.Matches.Groups[1].Value }
        }
        "scouts" {
            $recipients = $poolContent | Select-String -Pattern '\| (agent-\d+) \|[^|]*\|[^|]*\|[^|]*\| BUSY \|[^|]*\|[^|]*\|[^|]*\| \[Scout\]' -AllMatches |
                ForEach-Object { $_.Matches.Groups[1].Value }
        }
        "builders" {
            $recipients = $poolContent | Select-String -Pattern '\| (agent-\d+) \|[^|]*\|[^|]*\|[^|]*\| BUSY \|[^|]*\|[^|]*\|[^|]*\| \[Builder\]' -AllMatches |
                ForEach-Object { $_.Matches.Groups[1].Value }
        }
        "reviewers" {
            $recipients = $poolContent | Select-String -Pattern '\| (agent-\d+) \|[^|]*\|[^|]*\|[^|]*\| BUSY \|[^|]*\|[^|]*\|[^|]*\| \[Reviewer\]' -AllMatches |
                ForEach-Object { $_.Matches.Groups[1].Value }
        }
        "mergers" {
            $recipients = $poolContent | Select-String -Pattern '\| (agent-\d+) \|[^|]*\|[^|]*\|[^|]*\| BUSY \|[^|]*\|[^|]*\|[^|]*\| \[Merger\]' -AllMatches |
                ForEach-Object { $_.Matches.Groups[1].Value }
        }
        default {
            Write-Host "[ERROR] Unknown broadcast group: @$group" -ForegroundColor Red
            exit 1
        }
    }

    if ($recipients.Count -eq 0) {
        Write-Host "[!] No active agents in group @$group" -ForegroundColor Yellow
        exit 0
    }

    Write-Info "Broadcasting to @$group ($($recipients.Count) agents)"
} else {
    $recipients = @($To)
}

# Deliver to each recipient
foreach ($recipient in $recipients) {
    # Save to recipient's inbox
    $inboxFile = "$mailDir\inbox\$recipient.jsonl"

    # Append message (JSONL format - one JSON per line)
    Add-Content -Path $inboxFile -Value $message

    Write-Success "Message delivered to $recipient"
}

# Save to sender's sent folder
$sentFile = "$mailDir\sent\$From.jsonl"
Add-Content -Path $sentFile -Value $message

Write-Info "Message $messageId sent"
Write-Host "  From: $From"
Write-Host "  To: $To"
Write-Host "  Subject: $Subject"
Write-Host "  Priority: $Priority"
Write-Host ""

return $messageId
