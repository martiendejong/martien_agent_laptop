#Requires -Version 5.1
<#
.SYNOPSIS
    Real Web Knowledge Seeker - Uses actual web search to find learning resources

.DESCRIPTION
    This script coordinates with Claude Code to perform REAL web searches.
    It saves queries to a file, Claude performs searches, saves results, script processes them.

.PARAMETER GapId
    Gap to search for

.PARAMETER Query
    Direct search query

.EXAMPLE
    .\web-knowledge-seeker.ps1 -GapId gap-aspiration-self-modification

.EXAMPLE
    .\web-knowledge-seeker.ps1 -Query "AI self-modification papers 2024 2025"
#>

param(
    [string]$GapId,
    [string]$Query,
    [int]$MaxResults = 5
)

$ErrorActionPreference = 'Stop'

# Paths
$StateDir = "E:\jengo\documents\autonomous-learning"
$KnowledgeBaseDir = "$StateDir\knowledge-base"
$WebSearchDir = "$StateDir\web-searches"

# Ensure directories
@($StateDir, $KnowledgeBaseDir, $WebSearchDir) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

if ($GapId) {
    # Load gap
    $gapLogPath = "$StateDir\gap-detection-log.jsonl"
    if (-not (Test-Path $gapLogPath)) {
        Write-Log "Gap log not found" -Level "ERROR"
        exit 1
    }

    $gaps = Get-Content $gapLogPath | ForEach-Object { $_ | ConvertFrom-Json }
    $gap = $gaps | Where-Object { $_.gap_id -eq $GapId } | Select-Object -First 1

    if (-not $gap) {
        Write-Log "Gap not found: $GapId" -Level "ERROR"
        exit 1
    }

    Write-Log "Gap: $($gap.description)"
    Write-Log "Generating search queries..."

    # Generate queries
    $description = $gap.description -replace '^(Want to|Never explored|Humans can|Other AI can|Capability gap inferred from failure):\s*', ''

    $queries = @(
        "$description research papers 2024 2025 2026"
        "$description implementation guide"
        "$description tutorial"
    )

} elseif ($Query) {
    $queries = @($Query)
} else {
    Write-Log "Must provide -GapId or -Query" -Level "ERROR"
    exit 1
}

# Save queries for Claude to process
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$requestFile = "$WebSearchDir\search-request-$timestamp.json"

$request = @{
    timestamp = Get-Date -Format "o"
    gap_id = $GapId
    queries = $queries
    max_results_per_query = $MaxResults
    status = "pending"
}

$request | ConvertTo-Json -Depth 5 | Set-Content $requestFile

Write-Log "Search request saved: $requestFile"
Write-Log ""
Write-Log "Queries to search:"
$queries | ForEach-Object { Write-Log "  - $_" }
Write-Log ""
Write-Log "========================================="
Write-Log "WAITING FOR CLAUDE TO PERFORM SEARCHES"
Write-Log "========================================="
Write-Log ""
Write-Log "Claude will:"
Write-Log "1. Read this request file"
Write-Log "2. Perform $($queries.Count) web searches"
Write-Log "3. Extract content from top results"
Write-Log "4. Save results to search-results-$timestamp.json"
Write-Log ""
Write-Log "Request file: $requestFile"
Write-Log "Results file: $WebSearchDir\search-results-$timestamp.json"
Write-Log ""

# Return request file path for Claude
Write-Output @{
    request_file = $requestFile
    results_file = "$WebSearchDir\search-results-$timestamp.json"
    timestamp = $timestamp
    status = "pending"
}
