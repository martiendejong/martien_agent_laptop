<#
.SYNOPSIS
    Knowledge Base RAG - Semantic search over Jengo's knowledge base

.DESCRIPTION
    Simple wrapper around hazina-rag.ps1 for querying the knowledge base.
    Automatically manages the "knowledge-base" RAG store.

.PARAMETER Query
    Question to ask the knowledge base

.PARAMETER Init
    Initialize the KB RAG store (first-time setup)

.PARAMETER Index
    Reindex all knowledge base files

.PARAMETER Status
    Show KB RAG store status

.PARAMETER Raw
    Return raw chunks without LLM generation

.PARAMETER TopK
    Number of results (default 5)

.EXAMPLE
    kb-rag.ps1 "Where are API keys stored?"

.EXAMPLE
    kb-rag.ps1 -Init

.EXAMPLE
    kb-rag.ps1 -Index
#>

param(
    [Parameter(Position = 0)]
    [string]$Query,

    [switch]$Init,
    [switch]$Index,
    [switch]$Status,
    [switch]$Raw,
    [int]$TopK = 5
)

$ErrorActionPreference = "Stop"

$STORE_NAME = "knowledge-base"
$KB_PATH = "C:\scripts\_machine\knowledge-base"
$HAZINA_RAG = "C:\scripts\tools\hazina-rag.ps1"

if (!(Test-Path $KB_PATH)) {
    Write-Error "Knowledge base not found at: $KB_PATH"
    exit 1
}

if (!(Test-Path $HAZINA_RAG)) {
    Write-Error "hazina-rag.ps1 not found at: $HAZINA_RAG"
    exit 1
}

if ($Init) {
    Write-Host "🔧 Initializing KB RAG store..." -ForegroundColor Cyan
    & $HAZINA_RAG init $STORE_NAME
    exit $LASTEXITCODE
}

if ($Index) {
    Write-Host "📚 Indexing knowledge base files..." -ForegroundColor Cyan
    Push-Location $KB_PATH
    & $HAZINA_RAG index "**/*.md" -StoreName $STORE_NAME -ChunkSize 800
    $exitCode = $LASTEXITCODE
    Pop-Location
    exit $exitCode
}

if ($Status) {
    & $HAZINA_RAG status -StoreName $STORE_NAME
    exit $LASTEXITCODE
}

if ($Query) {
    if ($Raw) {
        & $HAZINA_RAG query $Query -StoreName $STORE_NAME -TopK $TopK -Raw
    } else {
        & $HAZINA_RAG query $Query -StoreName $STORE_NAME -TopK $TopK
    }
    exit $LASTEXITCODE
}

Write-Host "Usage: kb-rag.ps1 'question' | -Init | -Index | -Status" -ForegroundColor Yellow
exit 1
