# Session Manager - View and Restore Sessions
# Simple interface for session management
# Created: 2026-02-07 (Iteration #7 - User Request)

param(
    [Parameter(Mandatory=$false, Position=0)]
    [ValidateSet('list', 'restore', 'last', 'current', 'info')]
    [string]$Command = 'list',

    [Parameter(Mandatory=$false, Position=1)]
    [string]$SessionId = '',

    [switch]$Active,
    [switch]$Archived,
    [int]$Limit = 20
)

$ErrorActionPreference = "Stop"

# Paths
$sessionsDir = "C:\Users\HP\.claude\projects\C--scripts"
$currentSessionFile = "C:\scripts\_machine\current-session.txt"

function Get-CurrentSessionId {
    # Get from environment or scratchpad
    $scratchpad = "C:\Users\HP\AppData\Local\Temp\claude\C--scripts"
    if (Test-Path $scratchpad) {
        $dirs = Get-ChildItem $scratchpad -Directory | Sort-Object LastWriteTime -Descending
        if ($dirs.Count -gt 0) {
            return $dirs[0].Name
        }
    }
    return $null
}

function Get-AllSessions {
    $sessions = @()

    # Get all .jsonl files
    $files = Get-ChildItem "$sessionsDir\*.jsonl" -File | Sort-Object LastWriteTime -Descending

    $current = Get-CurrentSessionId

    foreach ($file in $files) {
        $id = $file.BaseName
        $isCurrent = ($id -eq $current)

        # Parse first line to get context
        $firstLine = Get-Content $file.FullName -First 1 -ErrorAction SilentlyContinue
        $preview = ""
        $timestamp = $file.LastWriteTime

        if ($firstLine) {
            try {
                $json = $firstLine | ConvertFrom-Json
                if ($json.content -and $json.content.Count -gt 0) {
                    $firstMsg = $json.content[0]
                    if ($firstMsg.text) {
                        $preview = $firstMsg.text.Substring(0, [Math]::Min(60, $firstMsg.text.Length))
                        if ($firstMsg.text.Length -gt 60) { $preview += "..." }
                    }
                }
            } catch {
                $preview = "(unable to parse)"
            }
        }

        $sessions += [PSCustomObject]@{
            Id = $id
            ShortId = $id.Substring(0, 8)
            Preview = $preview
            Timestamp = $timestamp
            SizeMB = [math]::Round($file.Length / 1MB, 2)
            IsCurrent = $isCurrent
            Status = if ($isCurrent) { "ACTIVE" } else { "ARCHIVED" }
            File = $file.FullName
        }
    }

    return $sessions
}

function Show-SessionsList {
    param($Sessions, $FilterActive, $FilterArchived)

    if ($FilterActive) {
        $Sessions = $Sessions | Where-Object { $_.IsCurrent }
    }
    if ($FilterArchived) {
        $Sessions = $Sessions | Where-Object { -not $_.IsCurrent }
    }

    Write-Host ""
    Write-Host "=== SESSION MANAGER ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total sessions: $($Sessions.Count)" -ForegroundColor Gray
    Write-Host ""

    $displaySessions = $Sessions | Select-Object -First $Limit

    foreach ($session in $displaySessions) {
        $statusColor = if ($session.IsCurrent) { "Green" } else { "Gray" }
        $statusText = if ($session.IsCurrent) { "[ACTIVE]" } else { "[ARCHIVED]" }

        Write-Host "$statusText " -NoNewline -ForegroundColor $statusColor
        Write-Host "$($session.ShortId)" -NoNewline -ForegroundColor White
        Write-Host " | " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($session.Timestamp.ToString('yyyy-MM-dd HH:mm'))" -NoNewline -ForegroundColor Yellow
        Write-Host " | " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($session.SizeMB) MB" -ForegroundColor Cyan

        if ($session.Preview) {
            Write-Host "  $($session.Preview)" -ForegroundColor DarkGray
        }
        Write-Host ""
    }

    if ($Sessions.Count -gt $Limit) {
        Write-Host "... and $($Sessions.Count - $Limit) more sessions" -ForegroundColor DarkGray
        Write-Host "Use -Limit parameter to see more" -ForegroundColor DarkGray
        Write-Host ""
    }

    Write-Host "Commands:" -ForegroundColor Cyan
    Write-Host "  sessions.ps1 list             - Show all sessions" -ForegroundColor Gray
    Write-Host "  sessions.ps1 last             - Restore last closed session" -ForegroundColor Gray
    Write-Host "  sessions.ps1 restore <id>     - Restore specific session" -ForegroundColor Gray
    Write-Host "  sessions.ps1 current          - Show current session info" -ForegroundColor Gray
    Write-Host ""
}

function Show-CurrentSession {
    $sessions = Get-AllSessions
    $current = $sessions | Where-Object { $_.IsCurrent }

    Write-Host ""
    Write-Host "=== CURRENT SESSION ===" -ForegroundColor Green
    Write-Host ""

    if ($current) {
        Write-Host "ID: " -NoNewline -ForegroundColor Gray
        Write-Host "$($current.Id)" -ForegroundColor White
        Write-Host "Short ID: " -NoNewline -ForegroundColor Gray
        Write-Host "$($current.ShortId)" -ForegroundColor White
        Write-Host "Started: " -NoNewline -ForegroundColor Gray
        Write-Host "$($current.Timestamp.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Yellow
        Write-Host "Size: " -NoNewline -ForegroundColor Gray
        Write-Host "$($current.SizeMB) MB" -ForegroundColor Cyan
        Write-Host ""
        if ($current.Preview) {
            Write-Host "Preview:" -ForegroundColor Gray
            Write-Host "  $($current.Preview)" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "No active session found." -ForegroundColor Yellow
    }
    Write-Host ""
}

function Restore-LastSession {
    $sessions = Get-AllSessions | Where-Object { -not $_.IsCurrent }

    if ($sessions.Count -eq 0) {
        Write-Host ""
        Write-Host "No archived sessions found." -ForegroundColor Yellow
        Write-Host ""
        return
    }

    $last = $sessions[0]

    Write-Host ""
    Write-Host "=== RESTORING LAST SESSION ===" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Session ID: $($last.ShortId)" -ForegroundColor White
    Write-Host "Timestamp: $($last.Timestamp.ToString('yyyy-MM-dd HH:mm'))" -ForegroundColor Gray
    Write-Host "Size: $($last.SizeMB) MB" -ForegroundColor Gray
    Write-Host ""

    if ($last.Preview) {
        Write-Host "Preview:" -ForegroundColor Gray
        Write-Host "  $($last.Preview)" -ForegroundColor DarkGray
        Write-Host ""
    }

    Write-Host "To restore this session, run:" -ForegroundColor Cyan
    Write-Host "  claude --resume $($last.Id)" -ForegroundColor White
    Write-Host ""
    Write-Host "Or copy to clipboard:" -ForegroundColor Cyan
    Write-Host "  sessions.ps1 restore $($last.ShortId)" -ForegroundColor White
    Write-Host ""

    # Copy to clipboard
    "claude --resume $($last.Id)" | Set-Clipboard
    Write-Host "[OK] Command copied to clipboard!" -ForegroundColor Green
    Write-Host ""
}

function Restore-SpecificSession {
    param($Id)

    $sessions = Get-AllSessions
    $session = $sessions | Where-Object { $_.Id -like "$Id*" -or $_.ShortId -eq $Id }

    if (-not $session) {
        Write-Host ""
        Write-Host "Session not found: $Id" -ForegroundColor Red
        Write-Host ""
        Write-Host "Available sessions:" -ForegroundColor Gray
        $sessions | Select-Object -First 5 | ForEach-Object {
            Write-Host "  $($_.ShortId) - $($_.Timestamp.ToString('yyyy-MM-dd HH:mm'))" -ForegroundColor Gray
        }
        Write-Host ""
        return
    }

    Write-Host ""
    Write-Host "=== RESTORING SESSION ===" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Session ID: $($session.ShortId)" -ForegroundColor White
    Write-Host "Timestamp: $($session.Timestamp.ToString('yyyy-MM-dd HH:mm'))" -ForegroundColor Gray
    Write-Host "Size: $($session.SizeMB) MB" -ForegroundColor Gray
    Write-Host ""

    if ($session.Preview) {
        Write-Host "Preview:" -ForegroundColor Gray
        Write-Host "  $($session.Preview)" -ForegroundColor DarkGray
        Write-Host ""
    }

    Write-Host "To restore this session, run:" -ForegroundColor Cyan
    Write-Host "  claude --resume $($session.Id)" -ForegroundColor White
    Write-Host ""

    # Copy to clipboard
    "claude --resume $($session.Id)" | Set-Clipboard
    Write-Host "[OK] Command copied to clipboard!" -ForegroundColor Green
    Write-Host ""
}

# Main execution
switch ($Command) {
    'list' {
        $sessions = Get-AllSessions
        Show-SessionsList -Sessions $sessions -FilterActive:$Active -FilterArchived:$Archived
    }
    'current' {
        Show-CurrentSession
    }
    'last' {
        Restore-LastSession
    }
    'restore' {
        if (-not $SessionId) {
            Write-Host ""
            Write-Host "Error: Session ID required" -ForegroundColor Red
            Write-Host "Usage: sessions.ps1 restore <session-id>" -ForegroundColor Gray
            Write-Host ""
            exit 1
        }
        Restore-SpecificSession -Id $SessionId
    }
    'info' {
        if (-not $SessionId) {
            Show-CurrentSession
        } else {
            $sessions = Get-AllSessions
            $session = $sessions | Where-Object { $_.Id -like "$SessionId*" -or $_.ShortId -eq $SessionId }
            if ($session) {
                Write-Host ""
                Write-Host "Session Info:" -ForegroundColor Cyan
                Write-Host ""
                $session | Format-List Id, ShortId, Timestamp, SizeMB, Status, Preview, File
            } else {
                Write-Host ""
                Write-Host "Session not found: $SessionId" -ForegroundColor Red
                Write-Host ""
            }
        }
    }
}
