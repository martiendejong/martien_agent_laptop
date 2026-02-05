<#
.SYNOPSIS
    Lists Claude Code chats that crashed (no clean exit marker).

.DESCRIPTION
    Uses TWO methods to find crashed sessions:
    1. Active-sessions tracking (NEW): Sessions registered but not unregistered
    2. Clean-exits comparison (OLD): Sessions not in clean_exits list

    Assigns easy-to-remember IDs (crash-001, crash-002, etc.)

.PARAMETER Project
    Project folder to check (default: C--scripts)

.PARAMETER ShowContext
    Show the last user message for context

.PARAMETER Json
    Output as JSON for programmatic use

.PARAMETER Method
    Detection method: "active" (new), "clean-exits" (old), or "both" (default)

.PARAMETER Days
    How many days back to look (default: 1)

.EXAMPLE
    .\get-crashed-chats.ps1
    .\get-crashed-chats.ps1 -ShowContext
    .\get-crashed-chats.ps1 -Method active
    .\get-crashed-chats.ps1 -Days 7
#>

param(
    [string]$Project = "C--scripts",
    [switch]$ShowContext,
    [switch]$Json,
    [ValidateSet("active", "clean-exits", "both")]
    [string]$Method = "both",
    [int]$Days = 1
)

$ErrorActionPreference = "Stop"

# Configuration
$TrackerFile = "C:\scripts\_machine\session-tracker.json"
$ActiveSessionsFile = "C:\scripts\_machine\active-sessions.json"
$CrashedChatsFile = "C:\scripts\_machine\crashed-chats.json"
$ClaudeProjectsPath = "C:\Users\HP\.claude\projects"

$projectPath = Join-Path $ClaudeProjectsPath $Project
if (-not (Test-Path $projectPath)) {
    Write-Host "Project path not found: $projectPath" -ForegroundColor Red
    exit 1
}

# Calculate cutoff time
$cutoffTime = (Get-Date).AddDays(-$Days)

# Helper function to get last user message
function Get-LastUserMessage {
    param([string]$FilePath)
    $lastUserMsg = ""
    $lastTimestamp = ""
    try {
        $lines = Get-Content $FilePath -Tail 30 -ErrorAction SilentlyContinue
        foreach ($line in $lines) {
            $entry = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($entry -and $entry.type -eq "user" -and $entry.message.content) {
                $content = $entry.message.content
                if ($content -is [string] -and -not $content.StartsWith("<")) {
                    $lastUserMsg = $content
                    if ($entry.timestamp) { $lastTimestamp = $entry.timestamp }
                }
            }
        }
    } catch {}
    return @{ Message = $lastUserMsg; Timestamp = $lastTimestamp }
}

$crashedSessions = @()

# METHOD 1: Active Sessions Tracking (NEW - most reliable)
if ($Method -eq "active" -or $Method -eq "both") {
    if (Test-Path $ActiveSessionsFile) {
        $activeData = Get-Content $ActiveSessionsFile -Raw | ConvertFrom-Json
        foreach ($prop in $activeData.sessions.PSObject.Properties) {
            $session = $prop.Value
            $sessionId = $session.session_id

            # Check if process is still running
            $processRunning = $false
            if ($session.pid) {
                try {
                    $proc = Get-Process -Id $session.pid -ErrorAction SilentlyContinue
                    if ($proc) { $processRunning = $true }
                } catch {}
            }

            if (-not $processRunning) {
                $sessionFile = Join-Path $projectPath "$sessionId.jsonl"
                $fileInfo = if (Test-Path $sessionFile) { Get-Item $sessionFile } else { $null }

                $context = @{ Message = ""; Timestamp = "" }
                if ($ShowContext -and $fileInfo) {
                    $context = Get-LastUserMessage -FilePath $sessionFile
                }

                $crashedSessions += [PSCustomObject]@{
                    SessionId = $sessionId
                    ShortId = $sessionId.Substring(0, 8)
                    LastActivity = if ($fileInfo) { $fileInfo.LastWriteTime } else { [DateTime]::Parse($session.started_at) }
                    SizeKB = if ($fileInfo) { [math]::Round($fileInfo.Length / 1KB, 1) } else { 0 }
                    FilePath = $sessionFile
                    LastUserMessage = if ($context.Message.Length -gt 100) { $context.Message.Substring(0, 100) + "..." } else { $context.Message }
                    LastTimestamp = $context.Timestamp
                    DetectedBy = "active-sessions"
                }
            }
        }
    }
}

# METHOD 2: Clean Exits Comparison (OLD - for sessions before active tracking was implemented)
if ($Method -eq "clean-exits" -or $Method -eq "both") {
    $cleanExitIds = @()

    if (Test-Path $TrackerFile) {
        $tracker = Get-Content $TrackerFile -Raw | ConvertFrom-Json
        if ($tracker.clean_exits) {
            $cleanExitIds = $tracker.clean_exits | ForEach-Object { $_.session_id }
        }
    }

    $allSessions = Get-ChildItem -Path $projectPath -Filter "*.jsonl" -File |
        Where-Object { $_.LastWriteTime -gt $cutoffTime } |
        Sort-Object LastWriteTime

    # Already found session IDs (avoid duplicates)
    $alreadyFoundIds = $crashedSessions | ForEach-Object { $_.SessionId }

    foreach ($session in $allSessions) {
        $sessionId = [System.IO.Path]::GetFileNameWithoutExtension($session.Name)

        # Skip if already found via active-sessions or if in clean exits
        if ($sessionId -in $alreadyFoundIds -or $sessionId -in $cleanExitIds) {
            continue
        }

        $context = @{ Message = ""; Timestamp = "" }
        if ($ShowContext) {
            $context = Get-LastUserMessage -FilePath $session.FullName
        }

        $crashedSessions += [PSCustomObject]@{
            SessionId = $sessionId
            ShortId = $sessionId.Substring(0, 8)
            LastActivity = $session.LastWriteTime
            SizeKB = [math]::Round($session.Length / 1KB, 1)
            FilePath = $session.FullName
            LastUserMessage = if ($context.Message.Length -gt 100) { $context.Message.Substring(0, 100) + "..." } else { $context.Message }
            LastTimestamp = $context.Timestamp
            DetectedBy = "clean-exits"
        }
    }
}

# Sort by LastActivity descending (most recent first)
$crashedSessions = $crashedSessions | Sort-Object LastActivity -Descending

# Assign easy IDs (crash-001, crash-002, etc.)
$crashedChats = @()
$counter = 1
foreach ($session in $crashedSessions) {
    $easyId = "crash-{0:D3}" -f $counter
    $crashedChats += [PSCustomObject]@{
        EasyId = $easyId
        SessionId = $session.SessionId
        ShortId = $session.ShortId
        LastActivity = $session.LastActivity.ToString("yyyy-MM-dd HH:mm")
        SizeKB = $session.SizeKB
        FilePath = $session.FilePath
        LastUserMessage = $session.LastUserMessage
    }
    $counter++
}

# Save crashed chats mapping for restore command
$mapping = @{
    generated_at = (Get-Date).ToString("o")
    last_clean_exit = $tracker.last_clean_exit_time
    project = $Project
    chats = $crashedChats
}
$mapping | ConvertTo-Json -Depth 10 | Out-File $CrashedChatsFile -Encoding UTF8

# Output
if ($Json) {
    $crashedChats | ConvertTo-Json -Depth 5
    exit 0
}

Write-Host "`n" -NoNewline
Write-Host "=" * 70 -ForegroundColor DarkGray
Write-Host "  CRASHED CHATS REPORT" -ForegroundColor Red
Write-Host "=" * 70 -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Method: $Method | Days: $Days | Project: $Project" -ForegroundColor DarkGray
Write-Host ""

if ($crashedChats.Count -eq 0) {
    Write-Host "  No crashed chats found!" -ForegroundColor Green
    Write-Host "  All sessions since last clean exit have been properly closed."
    Write-Host ""
} else {
    Write-Host "  Found $($crashedChats.Count) crashed chat(s):" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  " + ("-" * 66) -ForegroundColor DarkGray

    foreach ($chat in $crashedChats) {
        Write-Host ""
        Write-Host "  [$($chat.EasyId)]" -ForegroundColor Cyan -NoNewline
        Write-Host "  $($chat.ShortId)..." -ForegroundColor White
        Write-Host "    Time:  $($chat.LastActivity)" -ForegroundColor Gray
        Write-Host "    Size:  $($chat.SizeKB) KB" -ForegroundColor Gray

        if ($ShowContext -and $chat.LastUserMessage) {
            Write-Host "    Last:  " -ForegroundColor Gray -NoNewline
            Write-Host "$($chat.LastUserMessage)" -ForegroundColor DarkYellow
        }
    }

    Write-Host ""
    Write-Host "  " + ("-" * 66) -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  To restore a chat, run:" -ForegroundColor White
    Write-Host "    .\tools\restore-chat.ps1 -ChatId crash-001" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Or in a new Claude Code session, say:" -ForegroundColor White
    Write-Host "    'restore the chat with id crash-001'" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "=" * 70 -ForegroundColor DarkGray

# Return for pipeline
$crashedChats
