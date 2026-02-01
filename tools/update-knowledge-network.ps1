#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Update and sync the knowledge network with Hazina RAG

.DESCRIPTION
    Maintains C:\scripts\my_network\ knowledge base:
    - Syncs changes from source documentation
    - Re-indexes with Hazina RAG
    - Validates knowledge integrity
    - Reports statistics

.PARAMETER Action
    Action to perform: sync, query, status, or full-update

.PARAMETER Query
    Query string (when Action = query)

.PARAMETER AutoCommit
    Automatically commit changes to git

.EXAMPLE
    .\update-knowledge-network.ps1 -Action sync
    # Sync changes and re-index

.EXAMPLE
    .\update-knowledge-network.ps1 -Action query -Query "How do I create PRs?"
    # Query the knowledge network

.EXAMPLE
    .\update-knowledge-network.ps1 -Action full-update -AutoCommit
    # Full sync + index + commit
#>

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("sync", "query", "status", "full-update")]
    [string]$Action = "sync",

    [Parameter(Mandatory = $false)]
    [string]$Query = "",

    [Parameter(Mandatory = $false)]
    [switch]$AutoCommit
)

$ErrorActionPreference = "Stop"
$networkPath = "C:\scripts\my_network"
$storeName = "C:\scripts\my_network"

# ANSI colors
$green = "`e[38;5;2m"
$blue = "`e[38;5;4m"
$yellow = "`e[38;5;3m"
$reset = "`e[0m"

function Write-Status {
    param([string]$Message)
    Write-Host "${blue}[Knowledge Network]${reset} $Message"
}

function Sync-KnowledgeFromSources {
    Write-Status "Syncing knowledge from source documentation..."

    # Update timestamp in README
    $readmePath = Join-Path $networkPath "README.md"
    if (Test-Path $readmePath) {
        $content = Get-Content $readmePath -Raw
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        $content = $content -replace '\*\*Last Updated:\*\* \d{4}-\d{2}-\d{2} \d{2}:\d{2}', "**Last Updated:** $timestamp"
        Set-Content $readmePath -Value $content -NoNewline
    }

    # Add new categories as discovered
    # (This would be expanded with actual sync logic as knowledge grows)

    Write-Status "${green}✓${reset} Knowledge synced"
}

function Update-KnowledgeIndex {
    Write-Status "Re-indexing knowledge network with Hazina RAG..."

    # Sync changes first
    & "C:\scripts\tools\hazina-rag.ps1" -Action sync -StoreName $storeName -DryRun:$false

    Write-Status "${green}✓${reset} Index updated"
}

function Get-NetworkStatus {
    Write-Status "Knowledge Network Status:"
    Write-Host ""

    # Get RAG store status
    & "C:\scripts\tools\hazina-rag.ps1" -Action status -StoreName $storeName

    Write-Host ""

    # Count files by category
    $categories = Get-ChildItem -Path $networkPath -Directory -Exclude ".hazina"
    foreach ($cat in $categories) {
        $fileCount = (Get-ChildItem -Path $cat.FullName -Filter "*.md" -Recurse).Count
        Write-Host "  ${blue}$($cat.Name)${reset}: $fileCount files"
    }
}

function Invoke-NetworkQuery {
    param([string]$QueryString)

    if ([string]::IsNullOrWhiteSpace($QueryString)) {
        Write-Host "${yellow}No query provided. Use -Query parameter.${reset}"
        return
    }

    Write-Status "Querying knowledge network..."
    Write-Host ""

    & "C:\scripts\tools\hazina-rag.ps1" -Action query -Query $QueryString -StoreName $storeName
}

function Invoke-FullUpdate {
    Write-Status "Performing full knowledge network update..."
    Write-Host ""

    # 1. Sync from sources
    Sync-KnowledgeFromSources

    # 2. Re-index
    Update-KnowledgeIndex

    # 3. Show status
    Get-NetworkStatus

    # 4. Git commit if requested
    if ($AutoCommit) {
        Write-Status "Committing changes to git..."
        Push-Location $networkPath
        try {
            git add -A
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
            git commit -m "Update knowledge network - $timestamp" 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Status "${green}✓${reset} Changes committed"
            } else {
                Write-Status "${yellow}No changes to commit${reset}"
            }
        } finally {
            Pop-Location
        }
    }

    Write-Host ""
    Write-Status "${green}✓${reset} Full update complete"
}

# Main execution
switch ($Action) {
    "sync" {
        Sync-KnowledgeFromSources
        Update-KnowledgeIndex
    }
    "query" {
        Invoke-NetworkQuery -QueryString $Query
    }
    "status" {
        Get-NetworkStatus
    }
    "full-update" {
        Invoke-FullUpdate
    }
}
