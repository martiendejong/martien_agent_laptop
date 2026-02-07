# Automatic Session Tagging
# Auto-categorize sessions by content analysis
# Created: 2026-02-07 (Iteration #10 - Autonomous improvement)

<#
.SYNOPSIS
    Automatic Session Tagging

.DESCRIPTION
    Automatic Session Tagging

.NOTES
    File: tag-sessions.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$SessionId = '',

    [switch]$RebuildAll,
    [switch]$ShowTags
)

$ErrorActionPreference = "Stop"

# Paths
$sessionsDir = "C:\Users\HP\.claude\projects\C--scripts"
$tagsCache = "C:\scripts\tools\.session-tags.json"

# Tag definitions with keywords
$tagDefinitions = @{
    'worktree' = @('worktree', 'allocation', 'release', 'agent-0', 'worker-agent')
    'debugging' = @('debug', 'error', 'fix', 'bug', 'broken', 'failing')
    'feature' = @('feature', 'implement', 'add', 'create', 'new feature')
    'optimization' = @('optimize', 'performance', 'faster', 'speed', 'improve')
    'consciousness' = @('consciousness', 'identity', 'awareness', 'meta-cognitive', 'jengo')
    'ci-cd' = @('ci', 'build', 'github actions', 'pipeline', 'deploy')
    'documentation' = @('document', 'readme', 'docs', 'guide', 'manual')
    'refactoring' = @('refactor', 'restructure', 'cleanup', 'reorganize')
    'clickup' = @('clickup', 'task', '#869', 'jira')
    'pr-review' = @('pull request', 'pr', 'merge', 'review')
    'research' = @('research', 'investigate', 'explore', 'understand', 'analyze')
    'infrastructure' = @('infrastructure', 'setup', 'config', 'environment')
}

function Get-SessionTags {
    param($Content)

    $tags = @()

    foreach ($tagName in $tagDefinitions.Keys) {
        $keywords = $tagDefinitions[$tagName]
        $score = 0

        foreach ($keyword in $keywords) {
            $matches = ([regex]::Matches($Content, "(?i)$keyword")).Count
            $score += $matches
        }

        if ($score -ge 3) {  # At least 3 keyword matches
            $tags += @{
                name = $tagName
                score = $score
            }
        }
    }

    return $tags | Sort-Object -Property score -Descending
}

function Tag-AllSessions {
    Write-Host ""
    Write-Host "=== TAGGING ALL SESSIONS ===" -ForegroundColor Magenta
    Write-Host ""

    $files = Get-ChildItem "$sessionsDir\*.jsonl" -File
    $totalFiles = $files.Count
    $processed = 0
    $taggedSessions = @{}

    Write-Host "Processing $totalFiles sessions..." -ForegroundColor Cyan
    Write-Host ""

    foreach ($file in $files) {
        $processed++

        if ($processed % 50 -eq 0) {
            Write-Host "  Progress: $processed / $totalFiles" -ForegroundColor Gray
        }

        try {
            $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
            if ($content) {
                $tags = Get-SessionTags -Content $content

                if ($tags.Count -gt 0) {
                    $taggedSessions[$file.BaseName] = @{
                        short_id = $file.BaseName.Substring(0, 8)
                        timestamp = $file.LastWriteTime.ToString('yyyy-MM-ddTHH:mm:ss')
                        tags = $tags
                        size_mb = [math]::Round($file.Length / 1MB, 2)
                    }
                }
            }
        } catch {
            # Skip files we can't read
        }
    }

    # Save to cache
    @{
        generated = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ss')
        total_sessions = $totalFiles
        tagged_sessions = $taggedSessions.Count
        sessions = $taggedSessions
    } | ConvertTo-Json -Depth 10 | Out-File $tagsCache -Encoding UTF8

    Write-Host ""
    Write-Host "[OK] Tagged $($taggedSessions.Count) sessions" -ForegroundColor Green
    Write-Host "Cache: $tagsCache" -ForegroundColor Gray
    Write-Host ""

    return $taggedSessions
}

function Show-TagsSummary {
    if (-not (Test-Path $tagsCache)) {
        Write-Host ""
        Write-Host "No tags cache found. Run: tag-sessions.ps1 -RebuildAll" -ForegroundColor Yellow
        Write-Host ""
        return
    }

    $cache = Get-Content $tagsCache -Raw | ConvertFrom-Json

    Write-Host ""
    Write-Host "=== SESSION TAGS SUMMARY ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total sessions: " -NoNewline -ForegroundColor Gray
    Write-Host "$($cache.total_sessions)" -ForegroundColor White
    Write-Host "Tagged sessions: " -NoNewline -ForegroundColor Gray
    Write-Host "$($cache.tagged_sessions)" -ForegroundColor White
    Write-Host "Generated: " -NoNewline -ForegroundColor Gray
    Write-Host "$($cache.generated)" -ForegroundColor Yellow
    Write-Host ""

    # Count tags
    $tagCounts = @{}
    foreach ($sessionId in $cache.sessions.PSObject.Properties.Name) {
        $session = $cache.sessions.$sessionId
        foreach ($tag in $session.tags) {
            if (-not $tagCounts.ContainsKey($tag.name)) {
                $tagCounts[$tag.name] = 0
            }
            $tagCounts[$tag.name]++
        }
    }

    Write-Host "TAG DISTRIBUTION:" -ForegroundColor Yellow
    Write-Host ""

    $sortedTags = $tagCounts.GetEnumerator() | Sort-Object -Property Value -Descending

    foreach ($tag in $sortedTags) {
        $barLength = [Math]::Min(40, $tag.Value)
        $bar = "â–ˆ" * $barLength

        Write-Host "  #$($tag.Key)" -NoNewline -ForegroundColor Cyan
        Write-Host " [$($tag.Value) sessions]" -NoNewline -ForegroundColor Gray
        Write-Host ""
        Write-Host "    $bar" -ForegroundColor Green
        Write-Host ""
    }

    Write-Host "Commands:" -ForegroundColor Cyan
    Write-Host "  tag-sessions.ps1 -ShowTags           - Show this summary" -ForegroundColor Gray
    Write-Host "  tag-sessions.ps1 -RebuildAll         - Rebuild tag cache" -ForegroundColor Gray
    Write-Host "  sessions.ps1 search -Query '#worktree' - Search by tag" -ForegroundColor Gray
    Write-Host ""
}

function Tag-SingleSession {
    param($Id)

    $files = Get-ChildItem "$sessionsDir\*.jsonl" -File
    $file = $files | Where-Object { $_.BaseName -like "$Id*" }

    if (-not $file) {
        Write-Host ""
        Write-Host "Session not found: $Id" -ForegroundColor Red
        Write-Host ""
        return
    }

    Write-Host ""
    Write-Host "=== TAGGING SESSION ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Session: $($file.BaseName.Substring(0,8))" -ForegroundColor White
    Write-Host ""

    $content = Get-Content $file.FullName -Raw
    $tags = Get-SessionTags -Content $content

    if ($tags.Count -eq 0) {
        Write-Host "No tags found (no keywords matched threshold)" -ForegroundColor Yellow
        Write-Host ""
        return
    }

    Write-Host "Tags detected:" -ForegroundColor Green
    Write-Host ""

    foreach ($tag in $tags) {
        Write-Host "  #$($tag.name)" -NoNewline -ForegroundColor Cyan
        Write-Host " (score: $($tag.score))" -ForegroundColor Gray
    }

    Write-Host ""
}

# Main execution
if ($RebuildAll) {
    Tag-AllSessions
} elseif ($ShowTags) {
    Show-TagsSummary
} elseif ($SessionId) {
    Tag-SingleSession -Id $SessionId
} else {
    Show-TagsSummary
}
