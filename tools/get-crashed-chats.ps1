<#
.SYNOPSIS
    Lists Claude Code chats that crashed (no clean exit marker).

.DESCRIPTION
    Finds all sessions that started after the last clean exit
    and assigns easy-to-remember IDs (crash-001, crash-002, etc.)

.PARAMETER Project
    Project folder to check (default: C--scripts)

.PARAMETER ShowContext
    Show the last user message for context

.PARAMETER Json
    Output as JSON for programmatic use

.EXAMPLE
    .\get-crashed-chats.ps1
    .\get-crashed-chats.ps1 -ShowContext
    .\get-crashed-chats.ps1 -Json
#>

param(
    [string]$Project = "C--scripts",
    [switch]$ShowContext,
    [switch]$Json
)

$ErrorActionPreference = "Stop"

# Configuration
$TrackerFile = "C:\scripts\_machine\session-tracker.json"
$CrashedChatsFile = "C:\scripts\_machine\crashed-chats.json"
$ClaudeProjectsPath = "C:\Users\HP\.claude\projects"

# Load tracker
if (-not (Test-Path $TrackerFile)) {
    Write-Host "No session tracker found. Run session-tracker.ps1 -Action status to initialize." -ForegroundColor Yellow
    Write-Host "Currently, ALL sessions would be considered 'crashed' since we have no clean exit markers."
    exit 0
}

$tracker = Get-Content $TrackerFile -Raw | ConvertFrom-Json

# Get list of clean exit session IDs
$cleanExitIds = @()
if ($tracker.clean_exits) {
    $cleanExitIds = $tracker.clean_exits | ForEach-Object { $_.session_id }
}

# Get cutoff time (last clean exit or 24 hours ago)
$cutoffTime = if ($tracker.last_clean_exit_time) {
    [DateTime]::Parse($tracker.last_clean_exit_time)
} else {
    (Get-Date).AddHours(-24)
}

# Find sessions that are NOT in clean exits and were modified after cutoff
$projectPath = Join-Path $ClaudeProjectsPath $Project

if (-not (Test-Path $projectPath)) {
    Write-Host "Project path not found: $projectPath" -ForegroundColor Red
    exit 1
}

$allSessions = Get-ChildItem -Path $projectPath -Filter "*.jsonl" -File |
    Where-Object { $_.LastWriteTime -gt $cutoffTime } |
    Sort-Object LastWriteTime

# Filter out clean exits
$crashedSessions = @()
foreach ($session in $allSessions) {
    $sessionId = [System.IO.Path]::GetFileNameWithoutExtension($session.Name)
    if ($sessionId -notin $cleanExitIds) {
        # Read last user message for context
        $lastUserMsg = ""
        $lastTimestamp = ""
        try {
            $lines = Get-Content $session.FullName -Tail 30 -ErrorAction SilentlyContinue
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

        $crashedSessions += [PSCustomObject]@{
            SessionId = $sessionId
            ShortId = $sessionId.Substring(0, 8)
            LastActivity = $session.LastWriteTime
            SizeKB = [math]::Round($session.Length / 1KB, 1)
            FilePath = $session.FullName
            LastUserMessage = if ($lastUserMsg.Length -gt 100) { $lastUserMsg.Substring(0, 100) + "..." } else { $lastUserMsg }
            LastTimestamp = $lastTimestamp
        }
    }
}

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
Write-Host "  Last clean exit: $($tracker.last_clean_exit_time)" -ForegroundColor DarkGray
Write-Host "  Project: $Project" -ForegroundColor DarkGray
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
