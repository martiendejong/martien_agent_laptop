<#
.SYNOPSIS
    Detects Claude Code sessions that crashed or were interrupted.

.DESCRIPTION
    Analyzes session JSONL files to find sessions that ended abnormally.
    A session is considered "crashed" if it lacks proper termination markers.

.PARAMETER Days
    Look back this many days (default: 7)

.PARAMETER Project
    Filter to specific project (e.g., "C--scripts", "C--Projects-client-manager")

.PARAMETER ShowContext
    Show last user message for context

.PARAMETER Format
    Output format: table, json, or list (default: table)

.EXAMPLE
    .\get-crashed-sessions.ps1 -Days 3
    .\get-crashed-sessions.ps1 -Project "C--scripts" -ShowContext
    .\get-crashed-sessions.ps1 -Format json | ConvertFrom-Json
#>

param(
    [int]$Days = 7,
    [string]$Project = "",
    [switch]$ShowContext,
    [ValidateSet("table", "json", "list")]
    [string]$Format = "table"
)

$ErrorActionPreference = "Stop"

# Configuration
$ClaudeProjectsPath = "C:\Users\HP\.claude\projects"
$CutoffDate = (Get-Date).AddDays(-$Days)

function Get-SessionInfo {
    param([string]$SessionFile)

    $sessionId = [System.IO.Path]::GetFileNameWithoutExtension($SessionFile)
    $projectName = Split-Path (Split-Path $SessionFile -Parent) -Leaf

    # Read last 50 lines to analyze session end
    $lines = Get-Content $SessionFile -Tail 50 -ErrorAction SilentlyContinue
    if (-not $lines) { return $null }

    $lastTimestamp = $null
    $lastUserMessage = ""
    $lastAssistantMessage = ""
    $hasCleanEnd = $false
    $hasSummary = $false
    $lastMessageType = ""
    $stopReason = ""
    $messageCount = 0

    # Count total messages (approximate from file size)
    $fileInfo = Get-Item $SessionFile
    $totalLines = (Get-Content $SessionFile | Measure-Object -Line).Lines

    foreach ($line in $lines) {
        try {
            $entry = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
            if (-not $entry) { continue }

            if ($entry.timestamp) {
                $lastTimestamp = [DateTime]::Parse($entry.timestamp)
            }

            if ($entry.type -eq "user" -and $entry.message.content) {
                $content = $entry.message.content
                if ($content -is [string]) {
                    $lastUserMessage = $content
                }
                $lastMessageType = "user"
            }

            if ($entry.type -eq "assistant" -and $entry.message) {
                $msg = $entry.message
                if ($msg.content) {
                    foreach ($block in $msg.content) {
                        if ($block.type -eq "text") {
                            $lastAssistantMessage = $block.text
                        }
                    }
                }
                if ($msg.stop_reason -eq "end_turn") {
                    $hasCleanEnd = $true
                }
                $stopReason = $msg.stop_reason
                $lastMessageType = "assistant"
            }

            if ($entry.type -eq "summary") {
                $hasSummary = $true
            }
        }
        catch {
            # Skip malformed lines
        }
    }

    # Determine crash status
    $isCrashed = $false
    $crashReason = ""

    # Crash indicators:
    # 1. Last message is from user (no response)
    if ($lastMessageType -eq "user") {
        $isCrashed = $true
        $crashReason = "No response to last user message"
    }
    # 2. Stop reason is not end_turn
    elseif ($stopReason -and $stopReason -notin @("end_turn", "stop_sequence")) {
        $isCrashed = $true
        $crashReason = "Incomplete response (stop_reason: $stopReason)"
    }
    # 3. Session is very recent but last activity was abrupt
    elseif ($lastTimestamp -and $lastTimestamp -gt $CutoffDate) {
        # Check if it's an active session (updated in last 5 minutes)
        $isActive = $lastTimestamp -gt (Get-Date).AddMinutes(-5)
        if (-not $isActive -and -not $hasSummary) {
            # Old session without summary = potentially crashed
            # Only mark as crashed if it's been more than 1 hour
            if ($lastTimestamp -lt (Get-Date).AddHours(-1)) {
                $isCrashed = $true
                $crashReason = "Session ended without summary"
            }
        }
    }

    return [PSCustomObject]@{
        SessionId = $sessionId
        Project = $projectName
        LastActivity = $lastTimestamp
        IsCrashed = $isCrashed
        CrashReason = $crashReason
        LastMessageType = $lastMessageType
        StopReason = $stopReason
        HasSummary = $hasSummary
        TotalLines = $totalLines
        FileSizeKB = [math]::Round($fileInfo.Length / 1KB, 1)
        LastUserMessage = if ($lastUserMessage.Length -gt 100) { $lastUserMessage.Substring(0, 100) + "..." } else { $lastUserMessage }
        LastAssistantMessage = if ($lastAssistantMessage.Length -gt 100) { $lastAssistantMessage.Substring(0, 100) + "..." } else { $lastAssistantMessage }
        FilePath = $SessionFile
    }
}

# Find session files
$searchPath = if ($Project) {
    Join-Path $ClaudeProjectsPath $Project
} else {
    $ClaudeProjectsPath
}

Write-Host "`n=== Crashed Session Detector ===" -ForegroundColor Cyan
Write-Host "Looking back: $Days days (since $($CutoffDate.ToString('yyyy-MM-dd')))"
Write-Host "Search path: $searchPath`n"

$sessionFiles = Get-ChildItem -Path $searchPath -Filter "*.jsonl" -Recurse -File |
    Where-Object { $_.LastWriteTime -gt $CutoffDate } |
    Sort-Object LastWriteTime -Descending

Write-Host "Found $($sessionFiles.Count) sessions in date range`n"

$results = @()
$progressCount = 0

foreach ($file in $sessionFiles) {
    $progressCount++
    Write-Progress -Activity "Analyzing sessions" -Status "$progressCount of $($sessionFiles.Count)" -PercentComplete (($progressCount / $sessionFiles.Count) * 100)

    $info = Get-SessionInfo -SessionFile $file.FullName
    if ($info) {
        $results += $info
    }
}

Write-Progress -Activity "Analyzing sessions" -Completed

# Filter to crashed sessions only
$crashedSessions = $results | Where-Object { $_.IsCrashed }

Write-Host "Crashed sessions: $($crashedSessions.Count) of $($results.Count) analyzed`n" -ForegroundColor Yellow

if ($crashedSessions.Count -eq 0) {
    Write-Host "No crashed sessions found in the last $Days days." -ForegroundColor Green
    exit 0
}

# Output based on format
switch ($Format) {
    "json" {
        $crashedSessions | ConvertTo-Json -Depth 5
    }
    "list" {
        foreach ($session in $crashedSessions) {
            Write-Host "`n$('='*60)" -ForegroundColor DarkGray
            Write-Host "Session: $($session.SessionId)" -ForegroundColor Cyan
            Write-Host "Project: $($session.Project)"
            Write-Host "Last Activity: $($session.LastActivity)"
            Write-Host "Crash Reason: $($session.CrashReason)" -ForegroundColor Red
            Write-Host "Size: $($session.FileSizeKB) KB ($($session.TotalLines) lines)"
            if ($ShowContext) {
                Write-Host "`nLast User Message:" -ForegroundColor Yellow
                Write-Host $session.LastUserMessage
            }
        }
    }
    default {
        $crashedSessions | Format-Table -Property @(
            @{Name='Project'; Expression={$_.Project}; Width=25}
            @{Name='LastActivity'; Expression={$_.LastActivity.ToString('MM-dd HH:mm')}; Width=12}
            @{Name='Reason'; Expression={$_.CrashReason}; Width=30}
            @{Name='Size'; Expression={"$($_.FileSizeKB)KB"}; Width=10}
            @{Name='SessionId'; Expression={$_.SessionId.Substring(0,8) + "..."}; Width=12}
        ) -AutoSize

        Write-Host "`nUse -Format list or -ShowContext for more details"
        Write-Host "Use session-restore.ps1 -SessionId <id> to generate restore context"
    }
}

# Return for pipeline
$crashedSessions
