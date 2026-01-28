<#
.SYNOPSIS
    RAG operations - query, index, and manage document stores

.DESCRIPTION
    Create project-local AI knowledge bases with full CRUD operations.
    Index files, query with semantic search, sync changes.

.PARAMETER Action
    The RAG action: init, index, query, status, list, sync

.PARAMETER StoreName
    Store name for operations

.PARAMETER Query
    Question to ask (for query action)

.PARAMETER Path
    Path for init or glob pattern for index

.PARAMETER TopK
    Number of results to retrieve (default 5)

.PARAMETER Raw
    Return raw chunks without LLM generation

.PARAMETER ChunkSize
    Chunk size in characters (default 500)

.PARAMETER DryRun
    Preview sync changes without applying

.EXAMPLE
    hazina-rag.ps1 init my-project

.EXAMPLE
    hazina-rag.ps1 index "**/*.cs" -StoreName my-project

.EXAMPLE
    hazina-rag.ps1 query "How does authentication work?" -StoreName my-project

.EXAMPLE
    hazina-rag.ps1 status -StoreName my-project

.EXAMPLE
    hazina-rag.ps1 list

.EXAMPLE
    hazina-rag.ps1 sync -StoreName my-project -DryRun
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("init", "index", "query", "status", "list", "sync")]
    [string]$Action,

    [Parameter(Position = 1)]
    [string]$Path = $null,

    [Parameter()]
    [Alias("Store")]
    [string]$StoreName = $null,

    [Parameter()]
    [string]$Query = $null,

    [Parameter()]
    [int]$TopK = 5,

    [Parameter()]
    [switch]$Raw,

    [Parameter()]
    [int]$ChunkSize = 500,

    [Parameter()]
    [switch]$DryRun,

    [Parameter()]
    [string]$EmbeddingModel = "text-embedding-3-small"
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

$args = @("rag")

switch ($Action) {
    "init" {
        if (!$Path -and !$StoreName) {
            Write-Error "Store name required for init. Usage: hazina-rag.ps1 init <store-name>"
            exit 1
        }
        $name = if ($Path) { $Path } else { $StoreName }
        $args += @("init", $name)
        if ($EmbeddingModel) {
            $args += @("--embedding-model", $EmbeddingModel)
        }
    }
    "index" {
        if (!$Path) {
            Write-Error "Path/glob pattern required for index. Usage: hazina-rag.ps1 index '**/*.cs' -StoreName <store>"
            exit 1
        }
        if (!$StoreName) {
            Write-Error "Store name required for index. Usage: hazina-rag.ps1 index '**/*.cs' -StoreName <store>"
            exit 1
        }
        $args += @("index", $Path, "--store", $StoreName, "--chunk-size", $ChunkSize)
    }
    "query" {
        $q = if ($Path) { $Path } else { $Query }
        if (!$q) {
            Write-Error "Query required. Usage: hazina-rag.ps1 query 'question' -StoreName <store>"
            exit 1
        }
        if (!$StoreName) {
            Write-Error "Store name required for query. Usage: hazina-rag.ps1 query 'question' -StoreName <store>"
            exit 1
        }
        $args += @("query", $q, "--store", $StoreName, "--top-k", $TopK)
        if ($Raw) {
            $args += "--raw"
        }
    }
    "status" {
        if (!$StoreName) {
            Write-Error "Store name required for status. Usage: hazina-rag.ps1 status -StoreName <store>"
            exit 1
        }
        $args += @("status", "--store", $StoreName)
    }
    "list" {
        $args += "list"
    }
    "sync" {
        if (!$StoreName) {
            Write-Error "Store name required for sync. Usage: hazina-rag.ps1 sync -StoreName <store>"
            exit 1
        }
        $args += @("sync", "--store", $StoreName)
        if ($DryRun) {
            $args += "--dry-run"
        }
    }
}

& $hazinaPath @args
