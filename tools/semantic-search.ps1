# Semantic Search for Reflection Log
# Query past learnings instantly: "show me all worktree mistakes"
# Created: 2026-02-07 (Iteration #3 recommendation)

<#
.SYNOPSIS
    Semantic Search for Reflection Log

.DESCRIPTION
    Semantic Search for Reflection Log

.NOTES
    File: semantic-search.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Query,

    [Parameter(Mandatory=$false)]
    [int]$Limit = 5,

    [switch]$AllMatches
)

$ErrorActionPreference = "Stop"

# Paths
$reflectionLog = "C:\scripts\_machine\reflection.log.md"
$indexCache = "C:\scripts\tools\.search-index.json"

function Build-SemanticIndex {
    $content = Get-Content $reflectionLog -Raw

    # Split into sessions (by ## headers)
    $sessions = [regex]::Split($content, '(?m)^## ')

    $entries = @()
    foreach ($session in $sessions) {
        if ($session -match '^(\d{4}-\d{2}-\d{2}[^\n]+)') {
            $date = $matches[1]

            # Extract key information
            $entry = @{
                date = $date
                content = $session
                keywords = @()
                category = ""
            }

            # Auto-categorize
            if ($session -match '(?i)(worktree|allocation|release)') {
                $entry.keywords += "worktree"
                $entry.category = "worktree-management"
            }
            if ($session -match '(?i)(PR|pull request|merge)') {
                $entry.keywords += "pr"
                $entry.category = "git-workflow"
            }
            if ($session -match '(?i)(CI|build|test|failing)') {
                $entry.keywords += "ci-cd"
                $entry.category = "ci-cd"
            }
            if ($session -match '(?i)(mistake|error|violation|failed)') {
                $entry.keywords += "mistake"
            }
            if ($session -match '(?i)(learn|pattern|insight)') {
                $entry.keywords += "learning"
            }
            if ($session -match '(?i)(optimization|improvement|speed)') {
                $entry.keywords += "optimization"
            }

            $entries += $entry
        }
    }

    $idx = @{
        built_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        entries = $entries
        total = $entries.Count
    }

    $idx | ConvertTo-Json -Depth 10 | Out-File $indexCache -Encoding UTF8

    Write-Host "[+] Index built: $($entries.Count) sessions indexed" -ForegroundColor Green
    return $idx
}

function Search-Index {
    param($Index, $Query)

    $queryLower = $Query.ToLower()
    $results = @()

    foreach ($entry in $Index.entries) {
        $score = 0
        $reasons = @()

        # Check keywords
        foreach ($keyword in $entry.keywords) {
            if ($queryLower -match $keyword) {
                $score += 10
                $reasons += "keyword:$keyword"
            }
        }

        # Check category
        if ($queryLower -match $entry.category) {
            $score += 5
            $reasons += "category:$($entry.category)"
        }

        # Check content (fuzzy)
        if ($entry.content -match "(?i)$queryLower") {
            $score += 3
            $reasons += "content-match"
        }

        if ($score -gt 0) {
            $results += @{
                date = $entry.date
                score = $score
                reasons = $reasons
                preview = ($entry.content -split "`n" | Select-Object -First 5) -join "`n"
                full = $entry.content
            }
        }
    }

    return $results | Sort-Object -Property score -Descending
}

# Load or build index
$index = if (Test-Path $indexCache) {
    Get-Content $indexCache -Raw | ConvertFrom-Json
} else {
    Write-Host "[*] Building semantic index..." -ForegroundColor Yellow
    Build-SemanticIndex
}

# Execute search
Write-Host ""
Write-Host "=== SEMANTIC SEARCH ===" -ForegroundColor Cyan
Write-Host "Query: " -NoNewline; Write-Host $Query -ForegroundColor Yellow
Write-Host ""

$results = Search-Index -Index $index -Query $Query

if ($results.Count -eq 0) {
    Write-Host "No results found." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Try broader queries like:" -ForegroundColor Gray
    Write-Host "  - worktree" -ForegroundColor Gray
    Write-Host "  - mistake" -ForegroundColor Gray
    Write-Host "  - ci-cd" -ForegroundColor Gray
    Write-Host "  - optimization" -ForegroundColor Gray
    exit 0
}

Write-Host "Found $($results.Count) results:" -ForegroundColor Green
Write-Host ""

$displayCount = if ($AllMatches) { $results.Count } else { [Math]::Min($Limit, $results.Count) }

for ($i = 0; $i -lt $displayCount; $i++) {
    $result = $results[$i]
    Write-Host "[$($i+1)] " -NoNewline -ForegroundColor Cyan
    Write-Host "$($result.date)" -ForegroundColor White
    Write-Host "    Score: $($result.score) | Reasons: $($result.reasons -join ', ')" -ForegroundColor Gray
    Write-Host ""
    Write-Host "    Preview:" -ForegroundColor DarkGray
    $preview = $result.preview -split "`n" | Select-Object -First 3
    foreach ($line in $preview) {
        if ($line.Trim()) {
            Write-Host "    $line" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

if ($results.Count -gt $displayCount) {
    Write-Host "... and $($results.Count - $displayCount) more results" -ForegroundColor DarkGray
    Write-Host "Use -AllMatches to see all results" -ForegroundColor DarkGray
    Write-Host ""
}

# Return results for programmatic use
return $results
