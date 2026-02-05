<#
.SYNOPSIS
    RAG-powered semantic search for ALL 379 tools

.DESCRIPTION
    Uses Hazina RAG to search all tools by natural language.
    Much more powerful than keyword matching.

.PARAMETER Query
    What you need to do (natural language)

.PARAMETER Init
    Initialize tools RAG store

.PARAMETER Index
    Reindex all 379 tools

.EXAMPLE
    tool-search "check database schema differences"

.EXAMPLE
    tool-search "safe worktree allocation"
#>

param(
    [Parameter(Position = 0)]
    [string]$Query,
    [switch]$Init,
    [switch]$Index,
    [int]$TopK = 5
)

$STORE = "tools"
$TOOLS_PATH = "C:\scripts\tools"
$RAG = "C:\scripts\tools\hazina-rag.ps1"

if ($Init) {
    Write-Host "Initializing tools RAG..." -ForegroundColor Cyan
    & $RAG init $STORE
    exit $LASTEXITCODE
}

if ($Index) {
    Write-Host "Indexing 379 tools..." -ForegroundColor Cyan
    Push-Location $TOOLS_PATH
    & $RAG index "*.ps1" -StoreName $STORE -ChunkSize 400
    Pop-Location
    exit $LASTEXITCODE
}

if ($Query) {
    & $RAG query $Query -StoreName $STORE -TopK $TopK
    exit $LASTEXITCODE
}

Write-Host "Usage: tool-search 'what you need'" -ForegroundColor Yellow
exit 1
