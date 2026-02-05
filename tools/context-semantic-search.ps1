# Context-Aware Semantic Search (R21-002)
# Combines semantic search with predictive loading

param(
    [string]$Query,
    [switch]$Preload,
    [int]$MaxResults = 10
)

$ClusterFile = "C:\scripts\_machine\context-clusters.yaml"
$PatternsFile = "C:\scripts\_machine\universal-patterns.yaml"

function Search-BySemantics {
    param(
        [string]$SearchQuery,
        [int]$Limit
    )

    # Simple semantic search using keyword expansion
    $queryTerms = $SearchQuery.ToLower() -split '\s+'

    # Expand query with synonyms/related terms
    $expandedTerms = @()
    $expandedTerms += $queryTerms

    # Domain-specific expansions
    $expansions = @{
        "database" = @("db", "sql", "entity", "migration")
        "frontend" = @("ui", "component", "react", "vue", "angular")
        "backend" = @("api", "controller", "service", "endpoint")
        "auth" = @("authentication", "authorization", "login", "user")
        "config" = @("configuration", "settings", "appsettings", "environment")
    }

    foreach ($term in $queryTerms) {
        if ($expansions.ContainsKey($term)) {
            $expandedTerms += $expansions[$term]
        }
    }

    # Search across documentation and code
    $searchPaths = @(
        "C:\scripts\_machine\*.md",
        "C:\scripts\docs\*.md",
        "C:\Projects\client-manager\*.md",
        "C:\Projects\hazina\*.md"
    )

    $results = @()

    foreach ($pattern in $searchPaths) {
        Get-ChildItem -Path $pattern -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            $content = Get-Content $_.FullName -Raw
            $relevance = 0

            foreach ($term in $expandedTerms | Select-Object -Unique) {
                $matches = [regex]::Matches($content, $term, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
                $relevance += $matches.Count
            }

            if ($relevance -gt 0) {
                $results += @{
                    path = $_.FullName
                    relevance = $relevance
                    preview = ($content -split "`n" | Select-Object -First 3) -join " " | ForEach-Object { $_.Substring(0, [Math]::Min(150, $_.Length)) }
                }
            }
        }
    }

    return $results | Sort-Object -Property relevance -Descending | Select-Object -First $Limit
}

function Get-RelatedContexts {
    param([string[]]$FoundFiles)

    # Use cluster analysis to find related files
    if (!(Test-Path $ClusterFile)) {
        return @()
    }

    $clusters = Get-Content $ClusterFile -Raw | ConvertFrom-Yaml
    $related = @()

    foreach ($file in $FoundFiles) {
        $fileName = Split-Path $file -Leaf

        foreach ($clusterName in $clusters.clusters.Keys) {
            $cluster = $clusters.clusters[$clusterName]
            if ($cluster.files -match $fileName) {
                $related += $cluster.files | Where-Object { $_ -notmatch $fileName }
            }
        }
    }

    return $related | Select-Object -Unique
}

# Main execution
if ($Query) {
    Write-Host "Searching for: $Query" -ForegroundColor Cyan

    $results = Search-BySemantics -SearchQuery $Query -Limit $MaxResults

    if ($results.Count -eq 0) {
        Write-Host "No results found" -ForegroundColor Yellow
        exit
    }

    Write-Host "`nFound $($results.Count) results:`n" -ForegroundColor Green

    $results | ForEach-Object {
        Write-Host "[$($_.relevance)] $($_.path)" -ForegroundColor Yellow
        Write-Host "  $($_.preview)...`n"
    }

    if ($Preload) {
        Write-Host "`nPreloading related contexts..." -ForegroundColor Cyan

        $foundPaths = $results | Select-Object -ExpandProperty path
        $relatedFiles = Get-RelatedContexts -FoundFiles $foundPaths

        if ($relatedFiles.Count -gt 0) {
            Write-Host "Related contexts to preload:" -ForegroundColor Green
            $relatedFiles | Select-Object -First 5 | ForEach-Object {
                Write-Host "  - $_"
            }
        }
        else {
            Write-Host "No related contexts found" -ForegroundColor Yellow
        }
    }
}
else {
    Write-Host "Usage: context-semantic-search.ps1 -Query <search terms> [-Preload] [-MaxResults <n>]"
    Write-Host "  -Query <terms>    : Search query"
    Write-Host "  -Preload          : Also show related contexts for preloading"
    Write-Host "  -MaxResults <n>   : Maximum results to return (default: 10)"
}
