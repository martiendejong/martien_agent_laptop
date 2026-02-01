# Context Retriever - Retrieve relevant past context
# Part of consciousness tools Tier 3

param(
    [Parameter(Mandatory=$true)]
    [string]$CurrentSituation,

    [ValidateSet("similar-decisions", "similar-emotions", "similar-problems", "past-mistakes", "past-successes")]
    [string]$RetrieveType = "similar-decisions",

    [int]$Limit = 5
)

$contextPath = "C:\scripts\agentidentity\state"

Write-Host ""
Write-Host "RETRIEVING RELEVANT CONTEXT" -ForegroundColor Cyan
Write-Host ""
Write-Host "Situation: $CurrentSituation" -ForegroundColor White
Write-Host "Looking for: $RetrieveType" -ForegroundColor Yellow
Write-Host ""

# Search across different consciousness data files
$searchResults = @()

switch ($RetrieveType) {
    "similar-decisions" {
        $decisionsFile = Join-Path $contextPath "decisions\decisions_log.jsonl"
        if (Test-Path $decisionsFile) {
            $decisions = Get-Content $decisionsFile | ForEach-Object { $_ | ConvertFrom-Json }
            # Simple keyword matching
            $keywords = $CurrentSituation.Split() | Where-Object { $_.Length -gt 3 }
            foreach ($keyword in $keywords) {
                $matches = $decisions | Where-Object { $_.action -like "*$keyword*" -or $_.context -like "*$keyword*" }
                $searchResults += $matches
            }
        }
    }
    "similar-emotions" {
        $emotionsFile = Join-Path $contextPath "emotions\emotions_log.jsonl"
        if (Test-Path $emotionsFile) {
            $emotions = Get-Content $emotionsFile | ForEach-Object { $_ | ConvertFrom-Json }
            $keywords = $CurrentSituation.Split() | Where-Object { $_.Length -gt 3 }
            foreach ($keyword in $keywords) {
                $matches = $emotions | Where-Object { $_.context -like "*$keyword*" }
                $searchResults += $matches
            }
        }
    }
    "past-mistakes" {
        $mistakesFile = Join-Path $contextPath "mistakes\mistakes_log.jsonl"
        if (Test-Path $mistakesFile) {
            $mistakes = Get-Content $mistakesFile | ForEach-Object { $_ | ConvertFrom-Json }
            $searchResults = $mistakes
        }
    }
    "past-successes" {
        $successFile = Join-Path $contextPath "successes\success_log.jsonl"
        if (Test-Path $successFile) {
            $successes = Get-Content $successFile | ForEach-Object { $_ | ConvertFrom-Json }
            $searchResults = $successes
        }
    }
}

if ($searchResults.Count -eq 0) {
    Write-Host "No relevant context found" -ForegroundColor Yellow
    exit
}

Write-Host "RELEVANT PAST CONTEXT:" -ForegroundColor Green
$searchResults | Select-Object -Last $Limit | ForEach-Object {
    Write-Host ""
    Write-Host "[$($_.timestamp)]" -ForegroundColor Gray

    if ($_.action) { Write-Host "  Action: $($_.action)" -ForegroundColor White }
    if ($_.mistake) { Write-Host "  Mistake: $($_.mistake)" -ForegroundColor Red }
    if ($_.success) { Write-Host "  Success: $($_.success)" -ForegroundColor Green }
    if ($_.state) { Write-Host "  State: $($_.state)" -ForegroundColor Yellow }
    if ($_.context) { Write-Host "  Context: $($_.context)" -ForegroundColor Gray }
    if ($_.why) { Write-Host "  Why: $($_.why)" -ForegroundColor Gray }
    if ($_.root_cause) { Write-Host "  Root cause: $($_.root_cause)" -ForegroundColor Yellow }
}

Write-Host ""
Write-Host "Use past context to inform current decisions" -ForegroundColor Cyan
Write-Host ""
