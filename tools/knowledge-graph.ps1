<#
.SYNOPSIS
    Visualize knowledge relationships

.DESCRIPTION
    Generates a visual graph of knowledge connections:
    - Topics and their relationships
    - Learning frequency heatmap
    - Error-to-solution pathways

.PARAMETER Format
    Output format: mermaid, dot, json (default: mermaid)

.PARAMETER OutputPath
    Where to save graph (default: stdout)

.EXAMPLE
    .\knowledge-graph.ps1

.EXAMPLE
    .\knowledge-graph.ps1 -Format dot -OutputPath graph.dot
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('mermaid', 'dot', 'json')]
    [string]$Format = 'mermaid',

    [Parameter(Mandatory=$false)]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Knowledge Graph Generator" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

# Gather learning categories and their frequencies
Write-Host "📊 Analyzing knowledge base..." -ForegroundColor Cyan

$categoriesSql = "SELECT category, COUNT(*) as count FROM learnings GROUP BY category ORDER BY count DESC LIMIT 20;"
$categories = Invoke-Sql -Sql $categoriesSql

$categoryData = @{}
if ($categories) {
    $categories -split "`n" | ForEach-Object {
        if ($_ -match '\|') {
            $parts = $_ -split '\|'
            $categoryData[$parts[0]] = [int]$parts[1]
        }
    }
}

# Gather error types
$errorTypesSql = "SELECT error_type, COUNT(*) as count FROM errors GROUP BY error_type ORDER BY count DESC LIMIT 15;"
$errorTypes = Invoke-Sql -Sql $errorTypesSql

$errorData = @{}
if ($errorTypes) {
    $errorTypes -split "`n" | ForEach-Object {
        if ($_ -match '\|') {
            $parts = $_ -split '\|'
            $errorData[$parts[0]] = [int]$parts[1]
        }
    }
}

Write-Host "  Categories: $($categoryData.Count)" -ForegroundColor Gray
Write-Host "  Error types: $($errorData.Count)" -ForegroundColor Gray
Write-Host ""

# Generate graph based on format
if ($Format -eq 'mermaid') {
    $graph = @"
graph TD
    subgraph Knowledge Base
        KB[Knowledge Base]
"@

    foreach ($cat in $categoryData.Keys) {
        $nodeId = $cat -replace '[^\w]', '_'
        $count = $categoryData[$cat]
        $graph += "`n        KB --> $nodeId[$cat<br/>$count learnings]"
    }

    $graph += "`n    end"

    $graph += "`n`n    subgraph Common Errors"
    $graph += "`n        ERR[Errors]"

    foreach ($err in $errorData.Keys) {
        $nodeId = $err -replace '[^\w]', '_'
        $count = $errorData[$err]
        $graph += "`n        ERR --> ERR_$nodeId[$err<br/>$count occurrences]"
    }

    $graph += "`n    end"

    $output = $graph
}
elseif ($Format -eq 'json') {
    $output = @{
        categories = $categoryData
        errors = $errorData
        generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    } | ConvertTo-Json -Depth 5
}
elseif ($Format -eq 'dot') {
    $graph = "digraph Knowledge {`n"
    $graph += "    rankdir=LR;`n"
    $graph += "    node [shape=box];`n`n"

    $graph += "    KB [label=`"Knowledge Base`" shape=ellipse];`n"

    foreach ($cat in $categoryData.Keys) {
        $nodeId = $cat -replace '[^\w]', '_'
        $count = $categoryData[$cat]
        $graph += "    $nodeId [label=`"$cat\n$count learnings`"];`n"
        $graph += "    KB -> $nodeId;`n"
    }

    $graph += "`n    ERR [label=`"Errors`" shape=ellipse];`n"

    foreach ($err in $errorData.Keys) {
        $nodeId = "ERR_" + ($err -replace '[^\w]', '_')
        $count = $errorData[$err]
        $graph += "    $nodeId [label=`"$err\n$count occurrences`"];`n"
        $graph += "    ERR -> $nodeId;`n"
    }

    $graph += "}`n"
    $output = $graph
}

# Output result
if ($OutputPath) {
    $output | Set-Content $OutputPath -Encoding UTF8
    Write-Host "✅ Graph saved to: $OutputPath" -ForegroundColor Green
    Write-Host ""

    if ($Format -eq 'mermaid') {
        Write-Host "View with:" -ForegroundColor Cyan
        Write-Host "  https://mermaid.live" -ForegroundColor Gray
    }
    elseif ($Format -eq 'dot') {
        Write-Host "View with:" -ForegroundColor Cyan
        Write-Host "  dot -Tpng $OutputPath -o graph.png" -ForegroundColor Gray
    }
} else {
    Write-Host "Generated Graph:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host $output
    Write-Host ""
}
