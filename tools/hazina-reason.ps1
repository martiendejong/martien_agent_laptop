<#
.SYNOPSIS
    Multi-layer reasoning for high-confidence decisions

.DESCRIPTION
    Uses Hazina's Neurochain pattern for deep reasoning:
    1. Fast initial reasoning
    2. Step-by-step verification
    3. Confidence scoring

.PARAMETER Question
    The question requiring deep reasoning

.PARAMETER MinConfidence
    Minimum confidence threshold (0-1, default 0.85)

.EXAMPLE
    hazina-reason.ps1 "Is this database schema normalized correctly?"

.EXAMPLE
    hazina-reason.ps1 "Should we use microservices or monolith?" -MinConfidence 0.9
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Question,

    [Parameter()]
    [double]$MinConfidence = 0.85
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

& $hazinaPath reason $Question --min-confidence $MinConfidence
