<#
.SYNOPSIS
    Process massive documents (10M+ tokens) with AI

.DESCRIPTION
    Uses Hazina's recursive summarization for processing documents
    that exceed context limits. Supports single files or directories.

.PARAMETER Document
    Path to document or directory to process

.PARAMETER Query
    Question to answer about the document

.PARAMETER Strategy
    Processing strategy: 'single' or 'recursive' (default)

.PARAMETER ChunkSize
    Chunk size in characters (default 50000)

.EXAMPLE
    hazina-longdoc.ps1 "large-codebase/" "What are the main architectural patterns?"

.EXAMPLE
    hazina-longdoc.ps1 "book.txt" "Summarize the main themes" -Strategy single

.EXAMPLE
    hazina-longdoc.ps1 "docs/" "Find all API endpoints" -ChunkSize 30000
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Document,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$Query,

    [Parameter()]
    [ValidateSet("single", "recursive")]
    [string]$Strategy = "recursive",

    [Parameter()]
    [int]$ChunkSize = 50000
)

$ErrorActionPreference = "Stop"

# Find hazina CLI
$hazinaPath = "C:\Projects\hazina\apps\CLI\Hazina.CLI\bin\Debug\net9.0\hazina.exe"
if (!(Test-Path $hazinaPath)) {
    $hazinaPath = "C:\Projects\worker-agents\agent-002\hazina\apps\CLI\Hazina.CLI\bin\Debug\net9.0\hazina.exe"
}
if (!(Test-Path $hazinaPath)) {
    Write-Error "Hazina CLI not found. Build it first: cd C:\Projects\hazina\apps\CLI\Hazina.CLI && dotnet build"
    exit 1
}

& $hazinaPath longdoc $Document $Query --strategy $Strategy --chunk-size $ChunkSize
