<#
.SYNOPSIS
    Restores a crashed Claude Code chat by its easy ID.

.DESCRIPTION
    Generates restore context for a crashed chat that can be pasted
    into a new Claude Code session to continue the conversation.

.PARAMETER ChatId
    The easy ID (e.g., crash-001) or session ID prefix

.PARAMETER LastN
    Number of recent message exchanges to include (default: 15)

.PARAMETER Clipboard
    Copy restore context to clipboard

.PARAMETER OutputFile
    Save restore context to file

.PARAMETER ShowOnly
    Only show info about the chat, don't generate restore context

.EXAMPLE
    .\restore-chat.ps1 -ChatId crash-001
    .\restore-chat.ps1 -ChatId crash-001 -Clipboard
    .\restore-chat.ps1 -ChatId crash-001 -OutputFile restore.md
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ChatId,

    [int]$LastN = 15,

    [switch]$Clipboard,

    [string]$OutputFile = "",

    [switch]$ShowOnly
)

$ErrorActionPreference = "Stop"

# Configuration
$CrashedChatsFile = "C:\scripts\_machine\crashed-chats.json"

# Load crashed chats mapping
if (-not (Test-Path $CrashedChatsFile)) {
    Write-Host "No crashed chats registry found. Run get-crashed-chats.ps1 first." -ForegroundColor Red
    exit 1
}

$mapping = Get-Content $CrashedChatsFile -Raw | ConvertFrom-Json

# Find the chat
$chat = $null
foreach ($c in $mapping.chats) {
    if ($c.EasyId -eq $ChatId -or $c.SessionId -like "$ChatId*" -or $c.ShortId -eq $ChatId) {
        $chat = $c
        break
    }
}

if (-not $chat) {
    Write-Host "Chat not found: $ChatId" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available crashed chats:" -ForegroundColor Yellow
    foreach ($c in $mapping.chats) {
        Write-Host "  $($c.EasyId) - $($c.ShortId)... ($($c.LastActivity))"
    }
    exit 1
}

Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "  RESTORING CHAT: $($chat.EasyId)" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""
Write-Host "  Session ID: $($chat.SessionId)"
Write-Host "  Last Activity: $($chat.LastActivity)"
Write-Host "  Size: $($chat.SizeKB) KB"
Write-Host ""

if ($ShowOnly) {
    Write-Host "  Last user message:"
    Write-Host "  $($chat.LastUserMessage)" -ForegroundColor Yellow
    exit 0
}

# Parse session file
$sessionFile = $chat.FilePath

if (-not (Test-Path $sessionFile)) {
    Write-Host "Session file not found: $sessionFile" -ForegroundColor Red
    exit 1
}

Write-Host "  Reading session file..." -ForegroundColor Gray

$lines = Get-Content $sessionFile
$messages = @()
$sessionMeta = @{}

foreach ($line in $lines) {
    try {
        $entry = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
        if (-not $entry) { continue }

        # Capture session metadata
        if ($entry.sessionId -and -not $sessionMeta.sessionId) {
            $sessionMeta.sessionId = $entry.sessionId
            $sessionMeta.cwd = $entry.cwd
            $sessionMeta.gitBranch = $entry.gitBranch
        }

        # User messages
        if ($entry.type -eq "user" -and $entry.message.content) {
            $content = $entry.message.content
            if ($content -is [string] -and -not $content.StartsWith("<")) {
                $messages += [PSCustomObject]@{
                    Type = "user"
                    Content = $content
                    Timestamp = $entry.timestamp
                }
            }
        }

        # Assistant messages
        if ($entry.type -eq "assistant" -and $entry.message.content) {
            $text = ""
            foreach ($block in $entry.message.content) {
                if ($block.type -eq "text") {
                    $text = $block.text
                }
            }
            if ($text) {
                $messages += [PSCustomObject]@{
                    Type = "assistant"
                    Content = $text
                    Timestamp = $entry.timestamp
                }
            }
        }
    }
    catch {}
}

Write-Host "  Found $($messages.Count) messages" -ForegroundColor Gray

# Get last N messages
$recentMessages = $messages | Select-Object -Last ($LastN * 2)

# Build restore context
$restoreContext = @"
# CRASHED CHAT RESTORATION

**This is a continuation of a crashed session. Please review the context below and continue where it left off.**

## Session Info
- **Original Session ID:** $($chat.SessionId)
- **Crashed Chat ID:** $($chat.EasyId)
- **Working Directory:** $($sessionMeta.cwd)
- **Git Branch:** $($sessionMeta.gitBranch)
- **Last Activity:** $($chat.LastActivity)

---

## Previous Conversation

The following is the conversation from the crashed session:

"@

foreach ($msg in $recentMessages) {
    $timestamp = if ($msg.Timestamp) {
        try { [DateTime]::Parse($msg.Timestamp).ToString("HH:mm:ss") } catch { "" }
    } else { "" }

    if ($msg.Type -eq "user") {
        $restoreContext += "`n`n### User [$timestamp]`n`n$($msg.Content)"
    }
    else {
        # Truncate very long assistant messages
        $content = $msg.Content
        if ($content.Length -gt 3000) {
            $content = $content.Substring(0, 3000) + "`n`n[... message truncated for context restoration ...]"
        }
        $restoreContext += "`n`n### Claude [$timestamp]`n`n$content"
    }
}

$restoreContext += @"

---

## Continuation Instructions

**IMPORTANT:** This session was interrupted unexpectedly. Please:

1. Review the context above to understand what was being worked on
2. Check the current state of any files or tasks that were mentioned
3. Continue from where the previous session left off
4. If any operations were in progress, verify their completion status

**Ready to continue. What would you like me to do next?**
"@

# Output
if ($OutputFile) {
    $restoreContext | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Host ""
    Write-Host "  Restore context saved to: $OutputFile" -ForegroundColor Green
    Write-Host "  Open a new Claude Code session and paste the contents."
}
elseif ($Clipboard) {
    $restoreContext | Set-Clipboard
    Write-Host ""
    Write-Host "  Restore context copied to clipboard!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Next steps:" -ForegroundColor White
    Write-Host "    1. Open a new Claude Code terminal"
    Write-Host "    2. Paste the context (Ctrl+V)"
    Write-Host "    3. Claude will continue where it left off"
}
else {
    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor DarkGray
    Write-Host ""
    Write-Host $restoreContext
    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Use -Clipboard to copy to clipboard, or -OutputFile to save" -ForegroundColor Gray
}

Write-Host ""
Write-Host "  Context includes $($recentMessages.Count) messages" -ForegroundColor Gray
Write-Host "  Context length: $($restoreContext.Length) characters" -ForegroundColor Gray
Write-Host ""
