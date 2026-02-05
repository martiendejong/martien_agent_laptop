<#
.SYNOPSIS
    Browse and search Claude Code conversation history.

.DESCRIPTION
    Search through session history by keyword, date, or project.
    View session summaries and find specific conversations.

.PARAMETER Search
    Search for keyword in conversations

.PARAMETER Project
    Filter to specific project (e.g., "C--scripts")

.PARAMETER Days
    Look back this many days (default: 30)

.PARAMETER SessionId
    View specific session details

.PARAMETER List
    List all sessions (no search)

.PARAMETER Stats
    Show statistics only

.EXAMPLE
    .\session-browser.ps1 -Search "migration error"
    .\session-browser.ps1 -List -Days 7
    .\session-browser.ps1 -SessionId "abc123"
    .\session-browser.ps1 -Stats
#>

param(
    [string]$Search = "",
    [string]$Project = "",
    [int]$Days = 30,
    [string]$SessionId = "",
    [switch]$List,
    [switch]$Stats
)

$ErrorActionPreference = "Stop"

$ClaudeProjectsPath = "C:\Users\HP\.claude\projects"
$CutoffDate = (Get-Date).AddDays(-$Days)

function Get-SessionSummary {
    param([string]$SessionFile)

    $sessionId = [System.IO.Path]::GetFileNameWithoutExtension($SessionFile)
    $projectName = Split-Path (Split-Path $SessionFile -Parent) -Leaf
    $fileInfo = Get-Item $SessionFile

    # Read first and last few lines
    $firstLines = Get-Content $SessionFile -TotalCount 20 -ErrorAction SilentlyContinue
    $lastLines = Get-Content $SessionFile -Tail 20 -ErrorAction SilentlyContinue

    $firstUserMessage = ""
    $lastUserMessage = ""
    $messageCount = 0
    $startTime = $null
    $endTime = $null

    foreach ($line in $firstLines) {
        try {
            $entry = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($entry.type -eq "user" -and $entry.message.content -is [string]) {
                $content = $entry.message.content
                if (-not $content.StartsWith("<")) {
                    $firstUserMessage = $content
                    if ($entry.timestamp) { $startTime = [DateTime]::Parse($entry.timestamp) }
                    break
                }
            }
        } catch {}
    }

    foreach ($line in ($lastLines | Select-Object -Last 10)) {
        try {
            $entry = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($entry.type -eq "user" -and $entry.message.content -is [string]) {
                $content = $entry.message.content
                if (-not $content.StartsWith("<")) {
                    $lastUserMessage = $content
                    if ($entry.timestamp) { $endTime = [DateTime]::Parse($entry.timestamp) }
                }
            }
        } catch {}
    }

    return [PSCustomObject]@{
        SessionId = $sessionId
        Project = $projectName
        StartTime = $startTime
        EndTime = $endTime
        FileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
        FirstMessage = if ($firstUserMessage.Length -gt 80) { $firstUserMessage.Substring(0, 80) + "..." } else { $firstUserMessage }
        LastMessage = if ($lastUserMessage.Length -gt 80) { $lastUserMessage.Substring(0, 80) + "..." } else { $lastUserMessage }
        FilePath = $SessionFile
    }
}

function Search-Session {
    param(
        [string]$SessionFile,
        [string]$Keyword
    )

    $content = Get-Content $SessionFile -Raw -ErrorAction SilentlyContinue
    if ($content -match [regex]::Escape($Keyword)) {
        return $true
    }
    return $false
}

# Handle specific session view
if ($SessionId) {
    $searchPath = if ($Project) { Join-Path $ClaudeProjectsPath $Project } else { $ClaudeProjectsPath }
    $sessionFile = Get-ChildItem -Path $searchPath -Filter "*$SessionId*.jsonl" -Recurse -File | Select-Object -First 1

    if (-not $sessionFile) {
        Write-Host "Session not found: $SessionId" -ForegroundColor Red
        exit 1
    }

    Write-Host "`n=== Session Details ===" -ForegroundColor Cyan
    $summary = Get-SessionSummary -SessionFile $sessionFile.FullName
    $summary | Format-List

    Write-Host "`n--- Recent Messages ---" -ForegroundColor Yellow
    $lines = Get-Content $sessionFile.FullName -Tail 100

    $recentMsgs = @()
    foreach ($line in $lines) {
        try {
            $entry = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($entry.type -eq "user" -and $entry.message.content -is [string]) {
                $content = $entry.message.content
                if (-not $content.StartsWith("<")) {
                    $recentMsgs += [PSCustomObject]@{Type="USER"; Content=$content; Time=$entry.timestamp}
                }
            }
            if ($entry.type -eq "assistant" -and $entry.message.content) {
                foreach ($block in $entry.message.content) {
                    if ($block.type -eq "text") {
                        $text = if ($block.text.Length -gt 200) { $block.text.Substring(0, 200) + "..." } else { $block.text }
                        $recentMsgs += [PSCustomObject]@{Type="CLAUDE"; Content=$text; Time=$entry.timestamp}
                    }
                }
            }
        } catch {}
    }

    $recentMsgs | Select-Object -Last 10 | ForEach-Object {
        $color = if ($_.Type -eq "USER") { "Green" } else { "Cyan" }
        Write-Host "`n[$($_.Type)]" -ForegroundColor $color
        Write-Host $_.Content
    }

    exit 0
}

# Main search/list
$searchPath = if ($Project) { Join-Path $ClaudeProjectsPath $Project } else { $ClaudeProjectsPath }

Write-Host "`n=== Session Browser ===" -ForegroundColor Cyan
Write-Host "Path: $searchPath"
Write-Host "Date range: Last $Days days`n"

$sessionFiles = Get-ChildItem -Path $searchPath -Filter "*.jsonl" -Recurse -File |
    Where-Object { $_.LastWriteTime -gt $CutoffDate } |
    Sort-Object LastWriteTime -Descending

# Stats mode
if ($Stats) {
    Write-Host "=== Statistics ===" -ForegroundColor Yellow

    $byProject = $sessionFiles | Group-Object -Property { Split-Path (Split-Path $_.FullName -Parent) -Leaf }

    $statsData = @()
    foreach ($group in $byProject) {
        $totalSize = ($group.Group | Measure-Object -Property Length -Sum).Sum
        $statsData += [PSCustomObject]@{
            Project = $group.Name
            Sessions = $group.Count
            TotalSizeMB = [math]::Round($totalSize / 1MB, 1)
            AvgSizeMB = [math]::Round(($totalSize / $group.Count) / 1MB, 2)
        }
    }
    $statsData = $statsData | Sort-Object Sessions -Descending

    $statsData | Format-Table -AutoSize

    $totalSessions = ($sessionFiles | Measure-Object).Count
    $totalSize = ($sessionFiles | Measure-Object Length -Sum).Sum / 1GB

    Write-Host "`nTotal: $totalSessions sessions, $([math]::Round($totalSize, 2)) GB"
    exit 0
}

# Search mode
if ($Search) {
    Write-Host "Searching for: '$Search'" -ForegroundColor Yellow
    $matches = @()

    $progressCount = 0
    foreach ($file in $sessionFiles) {
        $progressCount++
        Write-Progress -Activity "Searching sessions" -Status "$progressCount of $($sessionFiles.Count)" -PercentComplete (($progressCount / $sessionFiles.Count) * 100)

        if (Search-Session -SessionFile $file.FullName -Keyword $Search) {
            $summary = Get-SessionSummary -SessionFile $file.FullName
            $matches += $summary
        }
    }
    Write-Progress -Activity "Searching sessions" -Completed

    Write-Host "`nFound $($matches.Count) matching sessions:`n" -ForegroundColor Green

    $matches | Format-Table -Property @(
        @{Name='Project'; Expression={$_.Project}; Width=20}
        @{Name='Date'; Expression={$_.EndTime.ToString('MM-dd HH:mm')}; Width=12}
        @{Name='Size'; Expression={"$($_.FileSizeMB)MB"}; Width=8}
        @{Name='First Message'; Expression={$_.FirstMessage}; Width=50}
    ) -AutoSize

    exit 0
}

# List mode
if ($List) {
    Write-Host "Recent sessions:`n" -ForegroundColor Yellow

    $summaries = $sessionFiles | Select-Object -First 20 | ForEach-Object {
        Get-SessionSummary -SessionFile $_.FullName
    }

    $summaries | Format-Table -Property @(
        @{Name='Project'; Expression={$_.Project}; Width=20}
        @{Name='Time'; Expression={if($_.EndTime){$_.EndTime.ToString('MM-dd HH:mm')}else{"N/A"}}; Width=12}
        @{Name='Size'; Expression={"$($_.FileSizeMB)MB"}; Width=8}
        @{Name='Last Message'; Expression={$_.LastMessage}; Width=60}
    ) -AutoSize

    Write-Host "`nShowing 20 of $($sessionFiles.Count) sessions"
    Write-Host "Use -SessionId <id> to view details"
    exit 0
}

# Default: show help
Write-Host @"
Usage:
  -Search "keyword"     Search conversations for keyword
  -List                 List recent sessions
  -Stats                Show statistics
  -SessionId "id"       View specific session
  -Project "name"       Filter by project
  -Days N               Look back N days (default: 30)

Examples:
  .\session-browser.ps1 -Search "migration error"
  .\session-browser.ps1 -List -Days 7
  .\session-browser.ps1 -Stats
"@
