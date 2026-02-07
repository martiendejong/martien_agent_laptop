# Keyword Memory Search - Honest Implementation
# Uses word-overlap matching (NOT semantic/embedding-based)
# This is lexical search, not semantic - renamed for honesty
# Future: Upgrade to real semantic search with embeddings (Phase 3.2)
# Created: 2026-02-07 | Renamed: 2026-02-07 (honesty fix)

<#
.SYNOPSIS
    Keyword Memory Search - Honest Implementation

.DESCRIPTION
    Keyword Memory Search - Honest Implementation

.NOTES
    File: keyword-memory.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Position=0)]
    [string]$Query = '',

    [ValidateSet('reflection', 'patterns', 'decisions', 'all')]
    [string]$Source = 'all',

    [int]$Limit = 5,

    [switch]$Detail
)

$ErrorActionPreference = "Stop"

#region Configuration

$script:Config = @{
    ReflectionLog = "C:\scripts\_machine\reflection.log.md"
    PatternsDir = "C:\scripts\_machine\best-practices"
    StateDir = "C:\scripts\agentidentity\state"
    CacheFile = "C:\scripts\agentidentity\semantic_cache.json"
}

#endregion

#region Search Functions

function Search-ReflectionLog {
    param([string]$Query, [int]$Limit = 5)

    if (-not (Test-Path $Config.ReflectionLog)) {
        if ($Detail) { Write-Host } "Reflection log not found"
        return @()
    }

    $content = Get-Content $Config.ReflectionLog -Raw
    $sections = $content -split "(?m)^##\s+"

    $results = @()

    foreach ($section in $sections) {
        if ([string]::IsNullOrWhiteSpace($section)) { continue }

        $lines = $section -split "`n"
        $title = $lines[0].Trim()
        $body = ($lines[1..($lines.Length-1)] -join " ").Trim()

        # Simple relevance scoring (word overlap)
        $score = Calculate-Relevance -Text $body -Query $Query

        if ($score -gt 0) {
            $results += @{
                Source = "reflection.log"
                Title = $title
                Score = $score
                Preview = Get-Preview -Text $body -MaxLength 200
                FullText = $body
            }
        }
    }

    return $results | Sort-Object -Property Score -Descending | Select-Object -First $Limit
}

function Search-Patterns {
    param([string]$Query, [int]$Limit = 5)

    $results = @()

    if (-not (Test-Path $Config.PatternsDir)) {
        return @()
    }

    $patternFiles = Get-ChildItem $Config.PatternsDir -Filter "*.md" -Recurse

    foreach ($file in $patternFiles) {
        $content = Get-Content $file.FullName -Raw
        $score = Calculate-Relevance -Text $content -Query $Query

        if ($score -gt 0) {
            $results += @{
                Source = "patterns"
                Title = $file.BaseName
                Score = $score
                Preview = Get-Preview -Text $content -MaxLength 200
                FilePath = $file.FullName
            }
        }
    }

    return $results | Sort-Object -Property Score -Descending | Select-Object -First $Limit
}

function Search-Decisions {
    param([string]$Query, [int]$Limit = 5)

    # Load consciousness core (has decision log)
    if ($global:ConsciousnessState -and $global:ConsciousnessState.Control.Decisions) {
        $decisions = $global:ConsciousnessState.Control.Decisions
    } else {
        # Fallback: search decision logs if they exist
        return @()
    }

    $results = @()

    foreach ($decision in $decisions) {
        $text = "$($decision.decision) $($decision.reasoning)"
        $score = Calculate-Relevance -Text $text -Query $Query

        if ($score -gt 0) {
            $results += @{
                Source = "decisions"
                Title = $decision.decision
                Score = $score
                Preview = $decision.reasoning
                Confidence = $decision.confidence
            }
        }
    }

    return $results | Sort-Object -Property Score -Descending | Select-Object -First $Limit
}

function Calculate-Relevance {
    param(
        [string]$Text,
        [string]$Query
    )

    if ([string]::IsNullOrWhiteSpace($Text) -or [string]::IsNullOrWhiteSpace($Query)) {
        return 0
    }

    $text = $Text.ToLower()
    $query = $Query.ToLower()

    # Split into words
    $textWords = $text -split '\W+' | Where-Object { $_.Length -gt 2 }
    $queryWords = $query -split '\W+' | Where-Object { $_.Length -gt 2 }

    if ($queryWords.Count -eq 0) { return 0 }

    # Calculate word overlap score
    $matches = 0
    foreach ($qword in $queryWords) {
        if ($textWords -contains $qword) {
            $matches++
        }
    }

    # Exact phrase match bonus
    if ($text -match [regex]::Escape($query)) {
        $matches += 5
    }

    # Normalize by query length
    $score = [math]::Round(($matches / $queryWords.Count) * 100, 2)

    return $score
}

function Get-Preview {
    param([string]$Text, [int]$MaxLength = 200)

    if ($Text.Length -le $MaxLength) {
        return $Text
    }

    return $Text.Substring(0, $MaxLength) + "..."
}

#endregion

#region Main Search

function Invoke-SemanticSearch {
    param(
        [string]$Query,
        [string]$Source,
        [int]$Limit
    )

    if ([string]::IsNullOrWhiteSpace($Query)) {
        Write-Host "[!] Query required" -ForegroundColor Red
        return
    }

    Write-Host ""
    Write-Host "Semantic Search: '$Query'" -ForegroundColor Cyan
    Write-Host ""

    $allResults = @()

    # Search each source
    if ($Source -eq 'all' -or $Source -eq 'reflection') {
        if ($Detail) { Write-Host } "Searching reflection.log..."
        $allResults += Search-ReflectionLog -Query $Query -Limit $Limit
    }

    if ($Source -eq 'all' -or $Source -eq 'patterns') {
        if ($Detail) { Write-Host } "Searching patterns..."
        $allResults += Search-Patterns -Query $Query -Limit $Limit
    }

    if ($Source -eq 'all' -or $Source -eq 'decisions') {
        if ($Detail) { Write-Host } "Searching decisions..."
        $allResults += Search-Decisions -Query $Query -Limit $Limit
    }

    # Sort all results by score
    $topResults = $allResults | Sort-Object -Property Score -Descending | Select-Object -First $Limit

    if ($topResults.Count -eq 0) {
        Write-Host "No results found for '$Query'" -ForegroundColor Yellow
        return
    }

    # Display results
    Write-Host "Found $($topResults.Count) results:" -ForegroundColor Green
    Write-Host ""

    $rank = 1
    foreach ($result in $topResults) {
        Write-Host "[$rank] " -NoNewline -ForegroundColor Yellow
        Write-Host "$($result.Title)" -ForegroundColor White
        Write-Host "    Source: $($result.Source) | Relevance: $($result.Score)%" -ForegroundColor Gray
        Write-Host "    $($result.Preview)" -ForegroundColor DarkGray
        Write-Host ""
        $rank++
    }

    return $topResults
}

#endregion

#region Command Handler

if (-not [string]::IsNullOrWhiteSpace($Query)) {
    Invoke-SemanticSearch -Query $Query -Source $Source -Limit $Limit
} else {
    Write-Host ""
    Write-Host "Keyword Memory Search - Usage" -ForegroundColor Cyan
    Write-Host "  (Lexical word-matching, NOT semantic/embedding-based)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  keyword-memory.ps1 'your query' [-Source <source>] [-Limit <n>]" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Sources:" -ForegroundColor Yellow
    Write-Host "  reflection  - Search reflection.log.md" -ForegroundColor Gray
    Write-Host "  patterns    - Search best-practices/" -ForegroundColor Gray
    Write-Host "  decisions   - Search decision log (in consciousness core)" -ForegroundColor Gray
    Write-Host "  all         - Search all sources (default)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  keyword-memory.ps1 'worktree mistakes'" -ForegroundColor Gray
    Write-Host "  keyword-memory.ps1 'consciousness optimization' -Source reflection" -ForegroundColor Gray
    Write-Host "  keyword-memory.ps1 'PR dependencies' -Limit 10" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Note: For true semantic search, use embeddings (future upgrade)" -ForegroundColor DarkYellow
    Write-Host ""
}

#endregion
