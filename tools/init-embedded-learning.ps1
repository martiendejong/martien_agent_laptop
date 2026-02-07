#!/usr/bin/env pwsh
# init-embedded-learning.ps1 - Initialize embedded learning system at session start
# Auto-run by claude_agent.bat or manual startup

param(
    [Parameter(Mandatory=$false)]

$ErrorActionPreference = "Stop"
    [string]$SessionLogPath = "C:\scripts\_machine\current-session-log.jsonl",

    [Parameter(Mandatory=$false)]
    [string]$ArchiveDir = "C:\scripts\_machine\session-logs",

    [Parameter(Mandatory=$false)]
    [switch]$Verbose = $false
)

$timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"

Write-Host "ðŸ§  Initializing Embedded Learning System..." -ForegroundColor Cyan

# 1. Archive previous session log if exists
if (Test-Path $SessionLogPath) {
    # Ensure archive directory exists
    if (-not (Test-Path $ArchiveDir)) {
        New-Item -ItemType Directory -Path $ArchiveDir -Force | Out-Null
    }

    # Move previous session to archive
    $archivePath = Join-Path $ArchiveDir "$timestamp.jsonl"
    Move-Item -Path $SessionLogPath -Destination $archivePath -Force

    if ($Verbose) {
        Write-Host "   âœ… Archived previous session: $archivePath" -ForegroundColor Gray
    }
}

# 2. Create new session log
"" | Out-File -FilePath $SessionLogPath -Encoding utf8
if ($Verbose) {
    Write-Host "   âœ… Created new session log: $SessionLogPath" -ForegroundColor Gray
}

# 3. Ensure learning queue exists
$queuePath = "C:\scripts\_machine\learning-queue.jsonl"
if (-not (Test-Path $queuePath)) {
    "" | Out-File -FilePath $queuePath -Encoding utf8
    if ($Verbose) {
        Write-Host "   âœ… Created learning queue: $queuePath" -ForegroundColor Gray
    }
}

# 4. Load last 3 sessions' learnings for pattern continuity
$recentSessions = Get-ChildItem -Path $ArchiveDir -Filter "*.jsonl" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 3

if ($recentSessions -and $Verbose) {
    Write-Host "   âœ… Loaded context from last 3 sessions:" -ForegroundColor Gray
    $recentSessions | ForEach-Object {
        $sessionDate = $_.Name -replace '\.jsonl$', ''
        Write-Host "      â€¢ $sessionDate" -ForegroundColor DarkGray
    }
}

# 5. Check for unfinished items in learning queue
$queueEntries = Get-Content $queuePath -ErrorAction SilentlyContinue |
    Where-Object { $_.Trim() -ne "" } |
    ForEach-Object { $_ | ConvertFrom-Json }

$pendingItems = $queueEntries | Where-Object { $_.status -eq "queued" }
if ($pendingItems) {
    Write-Host "   âš ï¸  $($pendingItems.Count) pending items in learning queue" -ForegroundColor Yellow
    if ($Verbose) {
        $pendingItems | Select-Object -First 3 | ForEach-Object {
            Write-Host "      â€¢ $($_.description)" -ForegroundColor DarkYellow
        }
    }
}

# 6. Log initialization action
$initEntry = @{
    timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    action = "Session initialized with embedded learning"
    reasoning = "Automatic startup protocol"
    outcome = "Ready for continuous learning"
    pattern_count = 1
} | ConvertTo-Json -Compress

$initEntry | Out-File -FilePath $SessionLogPath -Append -Encoding utf8

Write-Host "âœ… Embedded Learning Active" -ForegroundColor Green
Write-Host "   â€¢ Session log: $SessionLogPath" -ForegroundColor Gray
Write-Host "   â€¢ Learning queue: $queuePath" -ForegroundColor Gray
Write-Host "   â€¢ Meta-cognitive monitoring: ENABLED" -ForegroundColor Gray
Write-Host ""

# Return status for programmatic use
return @{
    SessionLogPath = $SessionLogPath
    LearningQueuePath = $queuePath
    ArchivedSessionsCount = if ($recentSessions) { $recentSessions.Count } else { 0 }
    PendingQueueItems = if ($pendingItems) { $pendingItems.Count } else { 0 }
    Status = "ACTIVE"
}
