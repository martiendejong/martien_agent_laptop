# Research Trigger - Mandatory Research for Unknown Domains
# Auto-activates WebSearch when entering untrained territory
# Created: 2026-02-16 (response to research gap discovery)

param(
    [Parameter(Mandatory)]
    [string]$Domain,

    [string]$Context = "",
    [int]$MaxSources = 3,
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# Track research in state
$statePath = "C:\scripts\agentidentity\state\consciousness_state_v2.json"
$state = Get-Content $statePath | ConvertFrom-Json

if (-not $state.Perception['ResearchHistory']) {
    $state.Perception | Add-Member -NotePropertyName 'ResearchHistory' -NotePropertyValue @() -Force
}

if (-not $Silent) {
    Write-Host "=== RESEARCH TRIGGER ===" -ForegroundColor Cyan
    Write-Host "Domain: $Domain" -ForegroundColor Yellow
    Write-Host "Context: $Context" -ForegroundColor Gray
    Write-Host ""
}

# Construct search queries
$queries = @()

# Query 1: Latest research/developments
$queries += "$Domain latest research 2024 2025 2026"

# Query 2: If context provided, specific technique
if ($Context) {
    $queries += "$Domain $Context recent papers"
}

# Query 3: Best practices/state of art
$queries += "$Domain state of the art techniques"

# Execute searches
$researchResults = @()
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

foreach ($query in $queries | Select-Object -First $MaxSources) {
    if (-not $Silent) {
        Write-Host "Searching: $query" -ForegroundColor Gray
    }

    # WebSearch would be called here by the main agent
    # This script TRIGGERS research, actual WebSearch done by calling agent

    $researchResults += @{
        Query = $query
        Timestamp = $timestamp
        Status = "pending"
    }
}

# Store research trigger in state
$researchEntry = @{
    Domain = $Domain
    Context = $Context
    Timestamp = $timestamp
    QueriesGenerated = $queries.Count
    Queries = $queries
    Status = "triggered"
}

$state.Perception.ResearchHistory += $researchEntry

# Save state
$state | ConvertTo-Json -Depth 100 | Set-Content $statePath

if (-not $Silent) {
    Write-Host ""
    Write-Host "Research triggered: $($queries.Count) queries generated" -ForegroundColor Green
    Write-Host "Queries:" -ForegroundColor Yellow
    foreach ($q in $queries) {
        Write-Host "  - $q" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "ACTION REQUIRED: Execute WebSearch for these queries BEFORE proceeding with task" -ForegroundColor Red
}

# Return queries for caller to execute
return $queries
