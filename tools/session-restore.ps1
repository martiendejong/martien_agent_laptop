<#
.SYNOPSIS
    Generates context to restore a crashed Claude Code session.

.DESCRIPTION
    Reads a session file and extracts the relevant context needed to
    continue the conversation in a new session.

.PARAMETER SessionId
    The session UUID to restore (or partial match)

.PARAMETER Project
    Project folder to search in (default: C--scripts)

.PARAMETER LastN
    Number of recent message pairs to include (default: 10)

.PARAMETER OutputFile
    Save restore context to file instead of console

.PARAMETER IncludeThinking
    Include Claude's thinking blocks (can be very long)

.PARAMETER Clipboard
    Copy restore context to clipboard

.EXAMPLE
    .\session-restore.ps1 -SessionId "abc123"
    .\session-restore.ps1 -SessionId "abc123" -Clipboard
    .\session-restore.ps1 -SessionId "abc123" -OutputFile "restore.md"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$SessionId,

    [string]$Project = "",

    [int]$LastN = 10,

    [string]$OutputFile = "",

    [switch]$IncludeThinking,

    [switch]$Clipboard
)

$ErrorActionPreference = "Stop"

$ClaudeProjectsPath = "C:\Users\HP\.claude\projects"

# Find session file
$searchPath = if ($Project) {
    Join-Path $ClaudeProjectsPath $Project
} else {
    $ClaudeProjectsPath
}

Write-Host "`n=== Session Restore Generator ===" -ForegroundColor Cyan
Write-Host "Searching for session: $SessionId"

$sessionFiles = Get-ChildItem -Path $searchPath -Filter "*.jsonl" -Recurse -File |
    Where-Object { $_.Name -like "*$SessionId*" }

if ($sessionFiles.Count -eq 0) {
    Write-Host "No session found matching '$SessionId'" -ForegroundColor Red
    exit 1
}

if ($sessionFiles.Count -gt 1) {
    Write-Host "Multiple sessions found:" -ForegroundColor Yellow
    $sessionFiles | ForEach-Object {
        Write-Host "  $($_.Name) - $($_.LastWriteTime)"
    }
    Write-Host "`nPlease provide a more specific SessionId"
    exit 1
}

$sessionFile = $sessionFiles[0]
Write-Host "Found: $($sessionFile.FullName)`n"

# Parse session
$lines = Get-Content $sessionFile.FullName
$messages = @()
$sessionMeta = @{}

foreach ($line in $lines) {
    try {
        $entry = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
        if (-not $entry) { continue }

        if ($entry.sessionId -and -not $sessionMeta.sessionId) {
            $sessionMeta.sessionId = $entry.sessionId
            $sessionMeta.cwd = $entry.cwd
            $sessionMeta.gitBranch = $entry.gitBranch
            $sessionMeta.version = $entry.version
        }

        if ($entry.type -eq "user" -and $entry.message.content) {
            $content = $entry.message.content
            # Skip meta/command messages
            if ($content -is [string] -and -not $content.StartsWith("<local-command") -and -not $content.StartsWith("<command-name>")) {
                $messages += [PSCustomObject]@{
                    Type = "user"
                    Content = $content
                    Timestamp = $entry.timestamp
                    UUID = $entry.uuid
                }
            }
        }

        if ($entry.type -eq "assistant" -and $entry.message.content) {
            $thinking = ""
            $text = ""

            foreach ($block in $entry.message.content) {
                if ($block.type -eq "thinking") {
                    $thinking = $block.thinking
                }
                if ($block.type -eq "text") {
                    $text = $block.text
                }
            }

            if ($text) {
                $messages += [PSCustomObject]@{
                    Type = "assistant"
                    Content = $text
                    Thinking = $thinking
                    Timestamp = $entry.timestamp
                    UUID = $entry.uuid
                    StopReason = $entry.message.stop_reason
                }
            }
        }
    }
    catch {
        # Skip malformed lines
    }
}

Write-Host "Parsed $($messages.Count) messages from session`n"

# Get last N message pairs
$recentMessages = $messages | Select-Object -Last ($LastN * 2)

# Build restore context
$restoreContext = @"
# Session Restore Context

**Original Session:** $($sessionMeta.sessionId)
**Working Directory:** $($sessionMeta.cwd)
**Git Branch:** $($sessionMeta.gitBranch)
**Last Activity:** $($sessionFile.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))
**Claude Code Version:** $($sessionMeta.version)

---

## Previous Conversation

This is a continuation of a previous session that was interrupted. Below is the context from that session:

"@

foreach ($msg in $recentMessages) {
    if ($msg.Type -eq "user") {
        $restoreContext += "`n`n### User:`n$($msg.Content)"
    }
    else {
        $restoreContext += "`n`n### Claude:"
        if ($IncludeThinking -and $msg.Thinking) {
            $restoreContext += "`n<thinking>`n$($msg.Thinking)`n</thinking>"
        }
        $restoreContext += "`n$($msg.Content)"
    }
}

# Add instructions for new session
$restoreContext += @"

---

## Continuation Instructions

**IMPORTANT:** This session was interrupted. Please:
1. Review the context above to understand what was being worked on
2. Check the current state of any files/tasks mentioned
3. Continue from where the previous session left off
4. If any commands were in progress, verify their completion status

**Last message type:** $($recentMessages[-1].Type)
**Stop reason:** $($recentMessages[-1].StopReason)

"@

# Output
if ($OutputFile) {
    $restoreContext | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Host "Restore context saved to: $OutputFile" -ForegroundColor Green
}
elseif ($Clipboard) {
    $restoreContext | Set-Clipboard
    Write-Host "Restore context copied to clipboard!" -ForegroundColor Green
    Write-Host "Paste this into a new Claude Code session to continue."
}
else {
    Write-Host $restoreContext
}

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Session: $($sessionMeta.sessionId)"
Write-Host "Messages included: $($recentMessages.Count)"
Write-Host "Context length: $($restoreContext.Length) characters"

if (-not $Clipboard -and -not $OutputFile) {
    Write-Host "`nTip: Use -Clipboard to copy to clipboard, or -OutputFile to save"
}
