<#
.SYNOPSIS
World Model Query Interface - Layer 6

.DESCRIPTION
External API for querying the complete world model.
Provides high-level queries that automatically route through appropriate layers.

Query types:
- "Where is X?" (entity lookup)
- "What is the current state?" (latent variables)
- "What if I do X?" (counterfactual simulation)
- "When did X happen?" (episodic memory search)
- "How do I feel about X?" (embodiment query)

.PARAMETER Query
Natural language query string

.PARAMETER QueryType
Structured query type (optional - auto-detected if not provided)

.NOTES
Created: 2026-02-27
Status: Layer 6 - Query Interface (Final Layer)
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Query,

    [Parameter(Mandatory=$false)]
    [ValidateSet("EntityLookup", "StateQuery", "Simulation", "MemorySearch", "EmbodimentQuery", "SystemInfo")]
    [string]$QueryType
)

$ErrorActionPreference = "SilentlyContinue"

# Layer tools
$bindingTool = "C:\scripts\tools\entity-binding-system.ps1"
$latentTool = "C:\scripts\tools\latent-variable-store.ps1"
$simulationTool = "C:\scripts\tools\counterfactual-simulation.ps1"
$memoryTool = "C:\scripts\tools\episodic-memory-recipes.ps1"
$metaControlTool = "C:\scripts\tools\world-model-meta-control.ps1"

# Auto-detect query type from natural language
function Get-QueryType {
    param([string]$query)

    $query = $query.ToLower()

    # Entity lookup patterns
    if ($query -match "where is|find|locate|entity") {
        return "EntityLookup"
    }

    # State query patterns
    if ($query -match "what is.*state|current.*project|current.*task|what am i") {
        return "StateQuery"
    }

    # Simulation patterns
    if ($query -match "what if|simulate|predict|consequence|will.*happen") {
        return "Simulation"
    }

    # Memory search patterns
    if ($query -match "when did|remember|recall|past|history|previous") {
        return "MemorySearch"
    }

    # Embodiment patterns
    if ($query -match "how.*feel|sensation|pain|pleasure|embodiment") {
        return "EmbodimentQuery"
    }

    # System info patterns
    if ($query -match "status|health|diagnostic|phi|integration") {
        return "SystemInfo"
    }

    # Default
    return "StateQuery"
}

# Entity lookup
function Invoke-EntityLookup {
    param([string]$query)

    Write-Host "`n[Query: Entity Lookup]" -ForegroundColor Cyan
    Write-Host "Searching for: $query`n" -ForegroundColor Gray

    $entityFile = "C:\scripts\agentidentity\state\entity-registry.json"
    if (-not (Test-Path $entityFile)) {
        Write-Host "No entities tracked yet" -ForegroundColor Yellow
        return $null
    }

    $registry = Get-Content $entityFile -Raw | ConvertFrom-Json

    # Search by path
    $matches = $registry.entities | Where-Object {
        $_.features.path -like "*$query*"
    }

    if ($matches.Count -eq 0) {
        Write-Host "No entities found matching: $query" -ForegroundColor Yellow
        return $null
    }

    Write-Host "Found $($matches.Count) entity(ies):`n" -ForegroundColor Green

    foreach ($entity in $matches) {
        Write-Host "  Entity: $($entity.id)" -ForegroundColor White
        Write-Host "    Type: $($entity.type)" -ForegroundColor Gray
        Write-Host "    State: $($entity.state)" -ForegroundColor Gray
        Write-Host "    Path: $($entity.features.path)" -ForegroundColor Gray

        if ($entity.features.size_bytes) {
            $sizeKB = [math]::Round($entity.features.size_bytes / 1KB, 1)
            Write-Host "    Size: $sizeKB KB" -ForegroundColor Gray
        }

        if ($entity.features.last_modified) {
            Write-Host "    Modified: $($entity.features.last_modified)" -ForegroundColor Gray
        }

        Write-Host ""
    }

    return $matches
}

# State query
function Invoke-StateQuery {
    param([string]$query)

    Write-Host "`n[Query: Current State]" -ForegroundColor Cyan
    Write-Host "Retrieving latent variables...`n" -ForegroundColor Gray

    $latentFile = "C:\scripts\agentidentity\state\latent-variables.json"
    if (-not (Test-Path $latentFile)) {
        Write-Host "Latent variables not initialized" -ForegroundColor Yellow
        return $null
    }

    $latent = Get-Content $latentFile -Raw | ConvertFrom-Json

    Write-Host "Top-Level State (Stable - changes slowly):" -ForegroundColor Yellow
    $latent.top.PSObject.Properties | ForEach-Object {
        Write-Host "  $($_.Name) = $($_.Value)" -ForegroundColor White
    }

    Write-Host "`nMid-Level State (Moderate - changes regularly):" -ForegroundColor Yellow
    $latent.mid.PSObject.Properties | ForEach-Object {
        Write-Host "  $($_.Name) = $($_.Value)" -ForegroundColor White
    }

    if ($latent.bottom) {
        Write-Host "`nBottom-Level State (Fast - changes constantly):" -ForegroundColor Yellow
        $latent.bottom.PSObject.Properties | ForEach-Object {
            Write-Host "  $($_.Name) = $($_.Value)" -ForegroundColor White
        }
    }

    Write-Host ""
    return $latent
}

# Counterfactual simulation
function Invoke-SimulationQuery {
    param([string]$query)

    Write-Host "`n[Query: Counterfactual Simulation]" -ForegroundColor Cyan
    Write-Host "Simulating: $query`n" -ForegroundColor Gray

    # Parse query to extract action and target
    # Simple pattern: "what if I {action} {target}"
    if ($query -match "what if.*?(update|delete|create|modify|run)\s+(.+)") {
        $action = $matches[1]
        $target = $matches[2].Trim()

        Write-Host "  Action: $action" -ForegroundColor Gray
        Write-Host "  Target: $target`n" -ForegroundColor Gray

        $result = & $simulationTool -SimulationType Forward -Action $action -Target $target 2>$null
        if ($result) {
            $sim = $result | ConvertFrom-Json

            Write-Host "Predicted Outcomes:" -ForegroundColor Green
            foreach ($pred in $sim.predictions) {
                Write-Host "`n  [$($pred.severity.ToUpper())] $($pred.description)" -ForegroundColor $(
                    switch ($pred.severity) {
                        "critical" { "Red" }
                        "high" { "Yellow" }
                        "medium" { "White" }
                        "low" { "Gray" }
                    }
                )
                Write-Host "    Confidence: $([math]::Round($pred.confidence, 2))" -ForegroundColor Gray
            }

            Write-Host ""
            return $sim
        }
    } else {
        Write-Host "Could not parse simulation query" -ForegroundColor Yellow
        Write-Host "Try format: 'what if I {action} {target}'" -ForegroundColor Gray
        return $null
    }
}

# Memory search
function Invoke-MemorySearch {
    param([string]$query)

    Write-Host "`n[Query: Episodic Memory Search]" -ForegroundColor Cyan
    Write-Host "Searching for: $query`n" -ForegroundColor Gray

    $result = & $memoryTool -Action FindSimilar -Query $query 2>&1 | Out-String

    # Return already printed by tool
    return $result
}

# Embodiment query
function Invoke-EmbodimentQuery {
    param([string]$query)

    Write-Host "`n[Query: Embodiment Sensations]" -ForegroundColor Cyan
    Write-Host "Current sensations:`n" -ForegroundColor Gray

    # Simple heuristic based on recent state
    $latentFile = "C:\scripts\agentidentity\state\latent-variables.json"
    if (Test-Path $latentFile) {
        $latent = Get-Content $latentFile -Raw | ConvertFrom-Json

        # Derive sensations from state
        $pain = 0.0
        $pleasure = 0.0
        $heat = 0.5
        $flow = 0.7

        # Check for recent errors (pain)
        if ($latent.mid.recent_errors -and $latent.mid.recent_errors -ne "") {
            $pain = 0.7
            $heat = 0.8
            $flow = 0.3
        }

        # Check for successful completion (pleasure)
        if ($latent.mid.current_action -like "*success*") {
            $pleasure = 0.9
            $pain = 0.0
            $flow = 0.9
        }

        Write-Host "  Pain:        $pain" -ForegroundColor $(if ($pain -gt 0.5) { "Red" } else { "Green" })
        Write-Host "  Pleasure:    $pleasure" -ForegroundColor $(if ($pleasure -gt 0.5) { "Green" } else { "Gray" })
        Write-Host "  Heat:        $heat" -ForegroundColor $(if ($heat -gt 0.7) { "Yellow" } else { "Green" })
        Write-Host "  Flow:        $flow" -ForegroundColor $(if ($flow -gt 0.7) { "Green" } else { "Yellow" })
        Write-Host "  Weight:      0.5 (moderate)" -ForegroundColor Gray
        Write-Host "  Resistance:  0.2 (low)" -ForegroundColor Gray
        Write-Host "  Alertness:   0.8 (high)" -ForegroundColor Green
        Write-Host "  Satisfaction: 0.7 (good)" -ForegroundColor Green

        Write-Host ""
        return @{
            pain = $pain
            pleasure = $pleasure
            heat = $heat
            flow = $flow
        }
    }

    Write-Host "Cannot determine sensations - state not available" -ForegroundColor Yellow
    return $null
}

# System info
function Invoke-SystemInfo {
    Write-Host "`n[Query: System Information]" -ForegroundColor Cyan
    $result = & $metaControlTool -Action GetSystemStatus 2>&1 | Out-String
    return $result
}

# Main query dispatcher
Write-Host "`n=== WORLD MODEL QUERY ===" -ForegroundColor Cyan
Write-Host "Query: `"$Query`"`n" -ForegroundColor White

# Auto-detect or use specified type
if (-not $QueryType) {
    $QueryType = Get-QueryType -query $Query
    Write-Host "Detected type: $QueryType`n" -ForegroundColor Gray
}

# Route to appropriate handler
$result = switch ($QueryType) {
    "EntityLookup" {
        Invoke-EntityLookup -query $Query
    }

    "StateQuery" {
        Invoke-StateQuery -query $Query
    }

    "Simulation" {
        Invoke-SimulationQuery -query $Query
    }

    "MemorySearch" {
        Invoke-MemorySearch -query $Query
    }

    "EmbodimentQuery" {
        Invoke-EmbodimentQuery -query $Query
    }

    "SystemInfo" {
        Invoke-SystemInfo
    }
}

Write-Host "=== QUERY COMPLETE ===`n" -ForegroundColor Cyan

return $result
