# Session Manager - View and Restore Sessions
# Simple interface for session management
# Created: 2026-02-07 (Iteration #7 - User Request)

param(
    [Parameter(Mandatory=$false, Position=0)]
    [ValidateSet('list', 'restore', 'last', 'current', 'info', 'search', 'preview', 'export', 'stats')]
    [string]$Command = 'list',

    [Parameter(Mandatory=$false, Position=1)]
    [string]$SessionId = '',

    [Parameter(Mandatory=$false)]
    [string]$Query = '',

    [switch]$Active,
    [switch]$Archived,
    [int]$Limit = 20,
    [int]$PreviewLines = 10
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

function Search-Sessions {
    param($Query)

    Write-Host ""
    Write-Host "=== SEARCHING SESSIONS ===" -ForegroundColor Cyan
    Write-Host "Query: " -NoNewline
    Write-Host "$Query" -ForegroundColor Yellow
    Write-Host ""

    $sessions = Get-AllSessions
    $matches = @()

    foreach ($session in $sessions) {
        try {
            $content = Get-Content $session.File -Raw -ErrorAction SilentlyContinue
            if ($content -match "(?i)$Query") {
                # Count matches
                $matchCount = ([regex]::Matches($content, "(?i)$Query")).Count

                # Extract context snippets
                $lines = $content -split "`n"
                $snippets = @()
                for ($i = 0; $i -lt $lines.Count; $i++) {
                    if ($lines[$i] -match "(?i)$Query") {
                        $context = $lines[$i].Substring(0, [Math]::Min(100, $lines[$i].Length))
                        if ($lines[$i].Length -gt 100) { $context += "..." }
                        $snippets += $context
                        if ($snippets.Count -ge 3) { break }
                    }
                }

                $matches += [PSCustomObject]@{
                    Session = $session
                    MatchCount = $matchCount
                    Snippets = $snippets
                }
            }
        } catch {
            # Skip files we can't read
        }
    }

    Write-Host "Found $($matches.Count) sessions with '$Query'" -ForegroundColor Green
    Write-Host ""

    $displayMatches = $matches | Sort-Object -Property MatchCount -Descending | Select-Object -First $Limit

    foreach ($match in $displayMatches) {
        $s = $match.Session
        $statusText = if ($s.IsCurrent) { "[ACTIVE]" } else { "[ARCHIVED]" }
        $statusColor = if ($s.IsCurrent) { "Green" } else { "Gray" }

        Write-Host "$statusText " -NoNewline -ForegroundColor $statusColor
        Write-Host "$($s.ShortId)" -NoNewline -ForegroundColor White
        Write-Host " | " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($s.Timestamp.ToString('yyyy-MM-dd HH:mm'))" -NoNewline -ForegroundColor Yellow
        Write-Host " | " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($match.MatchCount) matches" -ForegroundColor Cyan

        if ($match.Snippets.Count -gt 0) {
            Write-Host "  Context:" -ForegroundColor DarkGray
            foreach ($snippet in $match.Snippets) {
                $highlighted = $snippet -replace "(?i)($Query)", ">>$1<<"
                Write-Host "    $highlighted" -ForegroundColor Gray
            }
        }
        Write-Host ""
    }

    if ($matches.Count -gt $Limit) {
        Write-Host "... and $($matches.Count - $Limit) more matches" -ForegroundColor DarkGray
        Write-Host ""
    }
}

function Show-SessionPreview {
    param($Id, $Lines)

    $sessions = Get-AllSessions
    $session = $sessions | Where-Object { $_.Id -like "$Id*" -or $_.ShortId -eq $Id }

    if (-not $session) {
        Write-Host ""
        Write-Host "Session not found: $Id" -ForegroundColor Red
        Write-Host ""
        return
    }

    Write-Host ""
    Write-Host "=== SESSION PREVIEW ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Session: " -NoNewline -ForegroundColor Gray
    Write-Host "$($session.ShortId)" -ForegroundColor White
    Write-Host "Date: " -NoNewline -ForegroundColor Gray
    Write-Host "$($session.Timestamp.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Yellow
    Write-Host "Size: " -NoNewline -ForegroundColor Gray
    Write-Host "$($session.SizeMB) MB" -ForegroundColor Cyan
    Write-Host ""

    # Parse JSONL and show first N messages
    $fileLines = Get-Content $session.File -First $Lines -ErrorAction SilentlyContinue
    $messageCount = 0

    Write-Host "First $Lines messages:" -ForegroundColor Cyan
    Write-Host ""

    foreach ($line in $fileLines) {
        try {
            $json = $line | ConvertFrom-Json
            $messageCount++

            if ($json.role) {
                $roleColor = switch ($json.role) {
                    'user' { 'Green' }
                    'assistant' { 'Cyan' }
                    default { 'Gray' }
                }

                Write-Host "[$messageCount] " -NoNewline -ForegroundColor DarkGray
                Write-Host "$($json.role.ToUpper())" -NoNewline -ForegroundColor $roleColor
                Write-Host " | " -NoNewline -ForegroundColor DarkGray

                if ($json.content -is [array]) {
                    foreach ($content in $json.content) {
                        if ($content.text) {
                            $text = $content.text.Substring(0, [Math]::Min(200, $content.text.Length))
                            if ($content.text.Length -gt 200) { $text += "..." }
                            Write-Host "$text" -ForegroundColor Gray
                        }
                    }
                } elseif ($json.content) {
                    $text = $json.content.Substring(0, [Math]::Min(200, $json.content.Length))
                    if ($json.content.Length -gt 200) { $text += "..." }
                    Write-Host "$text" -ForegroundColor Gray
                }
                Write-Host ""
            }
        } catch {
            # Skip malformed lines
        }
    }

    Write-Host ""
    Write-Host "Showing first $messageCount messages" -ForegroundColor DarkGray
    Write-Host ""
}

function Export-SessionToMarkdown {
    param($Id)

    $sessions = Get-AllSessions
    $session = $sessions | Where-Object { $_.Id -like "$Id*" -or $_.ShortId -eq $Id }

    if (-not $session) {
        Write-Host ""
        Write-Host "Session not found: $Id" -ForegroundColor Red
        Write-Host ""
        return
    }

    $exportDir = "C:\scripts\_machine\session-exports"
    if (-not (Test-Path $exportDir)) {
        New-Item -ItemType Directory -Path $exportDir -Force | Out-Null
    }

    $exportFile = Join-Path $exportDir "$($session.ShortId)-export.md"

    Write-Host ""
    Write-Host "=== EXPORTING SESSION ===" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Session: $($session.ShortId)" -ForegroundColor White
    Write-Host "Exporting to: $exportFile" -ForegroundColor Gray
    Write-Host ""

    # Build markdown
    $markdown = @"
# Session Export: $($session.ShortId)

**Date:** $($session.Timestamp.ToString('yyyy-MM-dd HH:mm:ss'))
**Size:** $($session.SizeMB) MB
**Status:** $($session.Status)

---

"@

    # Parse JSONL and convert to markdown
    $lines = Get-Content $session.File -ErrorAction SilentlyContinue
    $messageNum = 0

    foreach ($line in $lines) {
        try {
            $json = $line | ConvertFrom-Json
            $messageNum++

            if ($json.role) {
                $role = $json.role.ToUpper()
                $markdown += "## Message $messageNum - $role`n`n"

                if ($json.content -is [array]) {
                    foreach ($content in $json.content) {
                        if ($content.text) {
                            $markdown += "$($content.text)`n`n"
                        }
                    }
                } elseif ($json.content) {
                    $markdown += "$($json.content)`n`n"
                }

                $markdown += "---`n`n"
            }
        } catch {
            # Skip malformed lines
        }
    }

    $markdown | Out-File $exportFile -Encoding UTF8

    Write-Host "[OK] Exported $messageNum messages" -ForegroundColor Green
    Write-Host ""
    Write-Host "File: $exportFile" -ForegroundColor Cyan
    Write-Host ""

    return $exportFile
}

function Show-SessionStats {
    Write-Host ""
    Write-Host "=== SESSION STATISTICS ===" -ForegroundColor Magenta
    Write-Host ""

    $sessions = Get-AllSessions

    # Basic stats
    $totalSessions = $sessions.Count
    $totalSizeMB = ($sessions | Measure-Object -Property SizeMB -Sum).Sum
    $avgSizeMB = ($sessions | Measure-Object -Property SizeMB -Average).Average

    Write-Host "Total Sessions: " -NoNewline -ForegroundColor Gray
    Write-Host "$totalSessions" -ForegroundColor White
    Write-Host "Total Size: " -NoNewline -ForegroundColor Gray
    Write-Host "$([math]::Round($totalSizeMB, 2)) MB" -ForegroundColor Cyan
    Write-Host "Average Size: " -NoNewline -ForegroundColor Gray
    Write-Host "$([math]::Round($avgSizeMB, 2)) MB" -ForegroundColor Cyan
    Write-Host ""

    # Top 5 largest
    Write-Host "TOP 5 LARGEST SESSIONS:" -ForegroundColor Yellow
    Write-Host ""
    $largest = $sessions | Sort-Object -Property SizeMB -Descending | Select-Object -First 5
    foreach ($s in $largest) {
        Write-Host "  $($s.ShortId)" -NoNewline -ForegroundColor White
        Write-Host " | " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($s.SizeMB) MB" -NoNewline -ForegroundColor Cyan
        Write-Host " | " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($s.Timestamp.ToString('yyyy-MM-dd'))" -ForegroundColor Gray
    }
    Write-Host ""

    # Most recent
    Write-Host "TOP 5 MOST RECENT:" -ForegroundColor Yellow
    Write-Host ""
    $recent = $sessions | Sort-Object -Property Timestamp -Descending | Select-Object -First 5
    foreach ($s in $recent) {
        Write-Host "  $($s.ShortId)" -NoNewline -ForegroundColor White
        Write-Host " | " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($s.Timestamp.ToString('yyyy-MM-dd HH:mm'))" -NoNewline -ForegroundColor Yellow
        Write-Host " | " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($s.SizeMB) MB" -ForegroundColor Cyan
    }
    Write-Host ""

    # Sessions per day (last 7 days)
    Write-Host "SESSIONS PER DAY (Last 7 days):" -ForegroundColor Yellow
    Write-Host ""
    $last7Days = (Get-Date).AddDays(-7)
    $recentSessions = $sessions | Where-Object { $_.Timestamp -gt $last7Days }
    $grouped = $recentSessions | Group-Object { $_.Timestamp.ToString('yyyy-MM-dd') } | Sort-Object Name -Descending

    foreach ($group in $grouped) {
        $date = $group.Name
        $count = $group.Count
        $totalSize = ($group.Group | Measure-Object -Property SizeMB -Sum).Sum

        Write-Host "  $date" -NoNewline -ForegroundColor White
        Write-Host " | " -NoNewline -ForegroundColor DarkGray
        Write-Host "$count sessions" -NoNewline -ForegroundColor Cyan
        Write-Host " | " -NoNewline -ForegroundColor DarkGray
        Write-Host "$([math]::Round($totalSize, 2)) MB" -ForegroundColor Gray
    }
    Write-Host ""

    # Active vs Archived
    $active = ($sessions | Where-Object { $_.IsCurrent }).Count
    $archived = $totalSessions - $active

    Write-Host "STATUS BREAKDOWN:" -ForegroundColor Yellow
    Write-Host "  Active: " -NoNewline -ForegroundColor Gray
    Write-Host "$active" -ForegroundColor Green
    Write-Host "  Archived: " -NoNewline -ForegroundColor Gray
    Write-Host "$archived" -ForegroundColor Gray
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
    'search' {
        if (-not $Query) {
            Write-Host ""
            Write-Host "Error: Query required" -ForegroundColor Red
            Write-Host "Usage: sessions.ps1 search -Query 'keyword'" -ForegroundColor Gray
            Write-Host ""
            exit 1
        }
        Search-Sessions -Query $Query
    }
    'preview' {
        if (-not $SessionId) {
            Write-Host ""
            Write-Host "Error: Session ID required" -ForegroundColor Red
            Write-Host "Usage: sessions.ps1 preview <session-id> [-PreviewLines 10]" -ForegroundColor Gray
            Write-Host ""
            exit 1
        }
        Show-SessionPreview -Id $SessionId -Lines $PreviewLines
    }
    'export' {
        if (-not $SessionId) {
            Write-Host ""
            Write-Host "Error: Session ID required" -ForegroundColor Red
            Write-Host "Usage: sessions.ps1 export <session-id>" -ForegroundColor Gray
            Write-Host ""
            exit 1
        }
        Export-SessionToMarkdown -Id $SessionId
    }
    'stats' {
        Show-SessionStats
    }
}
