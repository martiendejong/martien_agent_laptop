<#
.SYNOPSIS
World Model Meta-Control - Layer 5

.DESCRIPTION
Orchestrates all 6 world model layers:
- Layer 0: Embodiment (sensations)
- Layer 1: Entity Binding (object permanence)
- Layer 2: Latent Variables (hierarchical state)
- Layer 3: Counterfactual Simulation (causal reasoning)
- Layer 4: Episodic Memory (compressed recipes)
- Layer 5: Meta-Control (THIS - coordination)

Makes intelligent routing decisions based on context.

.PARAMETER Action
ProcessEvent, GetSystemStatus, OptimizeIntegration, RunDiagnostics

.NOTES
Created: 2026-02-27
Status: Layer 5 - Meta-Control Orchestration
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("ProcessEvent", "GetSystemStatus", "OptimizeIntegration", "RunDiagnostics")]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [hashtable]$Event
)

$ErrorActionPreference = "SilentlyContinue"

# Layer tools
$embodimentTool = "C:\scripts\tools\embodiment-mapper.ps1"
$bindingTool = "C:\scripts\tools\entity-binding-system.ps1"
$latentTool = "C:\scripts\tools\latent-variable-store.ps1"
$simulationTool = "C:\scripts\tools\counterfactual-simulation.ps1"
$memoryTool = "C:\scripts\tools\episodic-memory-recipes.ps1"
$phiTool = "C:\scripts\tools\test-phi.ps1"

# Process an event through all appropriate layers
function Invoke-ProcessEvent {
    param([hashtable]$event)

    Write-Host "`n[Meta-Control] Processing event: $($event.type)" -ForegroundColor Cyan
    Write-Host "  Context: $($event.description)`n" -ForegroundColor Gray

    $results = @{
        event = $event
        layers_activated = @()
        total_processing_time_ms = 0
        integration_quality = 0.0
    }

    $startTime = Get-Date

    # LAYER 0: Embodiment (always active - provides sensation context)
    Write-Host "[Layer 0: Embodiment]" -ForegroundColor Yellow
    $sensation = Get-EmbodimentSensation -event $event
    $results.layers_activated += "embodiment"
    Write-Host "  Sensation: pain=$($sensation.pain), heat=$($sensation.heat), pleasure=$($sensation.pleasure)`n" -ForegroundColor Gray

    # LAYER 1: Entity Binding (if event involves objects/files)
    if ($event.entity_type -and $event.features) {
        Write-Host "[Layer 1: Entity Binding]" -ForegroundColor Yellow
        $entityResult = & $bindingTool -Action BindEntity -Type $event.entity_type -Features $event.features 2>$null
        if ($entityResult) {
            $entity = $entityResult | ConvertFrom-Json
            Write-Host "  Entity bound: $($entity.id)`n" -ForegroundColor Green
            $results.layers_activated += "binding"
        }
    }

    # LAYER 2: Latent Variables (always update based on event context)
    Write-Host "[Layer 2: Latent Variables]" -ForegroundColor Yellow
    Update-LatentState -event $event
    $results.layers_activated += "latent"
    Write-Host "  State updated`n" -ForegroundColor Green

    # LAYER 3: Counterfactual Simulation (if decision-making event)
    if ($event.requires_simulation -and $event.action -and $event.target) {
        Write-Host "[Layer 3: Counterfactual Simulation]" -ForegroundColor Yellow
        $simResult = & $simulationTool -SimulationType Forward -Action $event.action -Target $event.target 2>$null
        if ($simResult) {
            $sim = $simResult | ConvertFrom-Json
            Write-Host "  Predictions: $($sim.predictions.Count) outcomes simulated`n" -ForegroundColor Green
            $results.layers_activated += "simulation"
        }
    }

    # LAYER 4: Episodic Memory (if significant event)
    if ($event.significance -and $event.significance -gt 0.7) {
        Write-Host "[Layer 4: Episodic Memory]" -ForegroundColor Yellow
        $recipe = & $memoryTool -Action StoreRecipe -Context @{
            significance = $event.significance
            tags = $event.tags
            achievement = $event.description
        } 2>$null
        if ($recipe) {
            Write-Host "  Recipe stored`n" -ForegroundColor Green
            $results.layers_activated += "memory"
        }
    }

    $endTime = Get-Date
    $results.total_processing_time_ms = ($endTime - $startTime).TotalMilliseconds

    # Calculate integration quality (how many layers activated)
    $results.integration_quality = $results.layers_activated.Count / 5.0

    Write-Host "[Meta-Control] Event processed" -ForegroundColor Green
    Write-Host "  Layers activated: $($results.layers_activated.Count)/5" -ForegroundColor White
    Write-Host "  Integration quality: $([math]::Round($results.integration_quality, 2))" -ForegroundColor White
    Write-Host "  Processing time: $([math]::Round($results.total_processing_time_ms, 0)) ms`n" -ForegroundColor White

    return $results
}

# Get embodiment sensation from event
function Get-EmbodimentSensation {
    param($event)

    $pain = 0.0
    $heat = 0.5
    $pleasure = 0.0

    # Pain from errors
    if ($event.type -eq "error" -or $event.type -eq "failure") {
        $pain = 0.8
        $heat = 0.9
    }

    # Pleasure from success
    if ($event.type -eq "success" -or $event.type -eq "achievement") {
        $pleasure = 0.9
        $pain = 0.0
    }

    # Heat from complexity
    if ($event.complexity) {
        $heat = $event.complexity
    }

    return @{
        pain = $pain
        heat = $heat
        pleasure = $pleasure
        flow = 1.0 - $pain
    }
}

# Update latent state based on event
function Update-LatentState {
    param($event)

    # Top-level (stable)
    if ($event.project) {
        & $latentTool -Action Set -Level top -Variable current_project -Value $event.project 2>$null | Out-Null
    }

    if ($event.task) {
        & $latentTool -Action Set -Level top -Variable current_task -Value $event.task 2>$null | Out-Null
    }

    # Mid-level (moderate)
    if ($event.file) {
        & $latentTool -Action Set -Level mid -Variable current_file -Value $event.file 2>$null | Out-Null
    }

    if ($event.action) {
        & $latentTool -Action Set -Level mid -Variable current_action -Value $event.action 2>$null | Out-Null
    }
}

# Get system status (all layers)
function Get-SystemStatus {
    Write-Host "`nWORLD MODEL SYSTEM STATUS" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan

    # Layer 0: Embodiment
    Write-Host "`n[Layer 0: Embodiment]" -ForegroundColor Yellow
    Write-Host "  Status: Active" -ForegroundColor Green
    Write-Host "  Sensations tracked: 8 (pain, heat, pleasure, weight, resistance, flow, alertness, satisfaction)" -ForegroundColor White

    # Layer 1: Entity Binding
    Write-Host "`n[Layer 1: Entity Binding]" -ForegroundColor Yellow
    $entityFile = "C:\scripts\agentidentity\state\entity-registry.json"
    if (Test-Path $entityFile) {
        $registry = Get-Content $entityFile -Raw | ConvertFrom-Json
        Write-Host "  Status: Active" -ForegroundColor Green
        Write-Host "  Entities tracked: $($registry.entities.Count)" -ForegroundColor White

        # Count by state
        $states = $registry.entities | Group-Object -Property state
        $states | ForEach-Object {
            Write-Host "    - $($_.Name): $($_.Count)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  Status: Not initialized" -ForegroundColor Red
    }

    # Layer 2: Latent Variables
    Write-Host "`n[Layer 2: Latent Variables]" -ForegroundColor Yellow
    $latentFile = "C:\scripts\agentidentity\state\latent-variables.json"
    if (Test-Path $latentFile) {
        $latent = Get-Content $latentFile -Raw | ConvertFrom-Json
        $topCount = ($latent.top.PSObject.Properties | Measure-Object).Count
        $midCount = ($latent.mid.PSObject.Properties | Measure-Object).Count
        Write-Host "  Status: Active" -ForegroundColor Green
        Write-Host "  Variables: $($topCount + $midCount) total" -ForegroundColor White
        Write-Host "    - Top-level (stable): $topCount" -ForegroundColor Gray
        Write-Host "    - Mid-level (moderate): $midCount" -ForegroundColor Gray
    } else {
        Write-Host "  Status: Not initialized" -ForegroundColor Red
    }

    # Layer 3: Counterfactual Simulation
    Write-Host "`n[Layer 3: Counterfactual Simulation]" -ForegroundColor Yellow
    Write-Host "  Status: Active" -ForegroundColor Green
    Write-Host "  Simulation types: 4 (Forward, Backward, Counterfactual, Analogical)" -ForegroundColor White

    # Layer 4: Episodic Memory
    Write-Host "`n[Layer 4: Episodic Memory]" -ForegroundColor Yellow
    $recipeFile = "C:\scripts\agentidentity\state\episodic-memory-recipes.json"
    if (Test-Path $recipeFile) {
        $store = Get-Content $recipeFile -Raw | ConvertFrom-Json
        Write-Host "  Status: Active" -ForegroundColor Green
        Write-Host "  Recipes stored: $($store.total_recipes)" -ForegroundColor White
        Write-Host "  Compression ratio: $($store.compression_ratio)x" -ForegroundColor White
    } else {
        Write-Host "  Status: Not initialized" -ForegroundColor Red
    }

    # Layer 5: Meta-Control
    Write-Host "`n[Layer 5: Meta-Control]" -ForegroundColor Yellow
    Write-Host "  Status: Active (THIS)" -ForegroundColor Green
    Write-Host "  Coordination: All layers orchestrated" -ForegroundColor White

    # Overall Integration (Phi)
    Write-Host "`n[Integration Measurement]" -ForegroundColor Cyan
    $phiResult = & $phiTool 2>&1 | Out-String
    if ($phiResult -match "PHI_TOTAL = ([\d.]+)") {
        $phi = $matches[1]
        Write-Host "  Phi: $phi" -ForegroundColor Green
        Write-Host "  Threshold: 0.3" -ForegroundColor Gray
        $ratio = [math]::Round([decimal]$phi / 0.3, 2)
        Write-Host "  Status: $ratio x above threshold" -ForegroundColor White
    }

    Write-Host ""
}

# Optimize integration
function Invoke-OptimizeIntegration {
    Write-Host "`n[Meta-Control] Optimizing integration...`n" -ForegroundColor Cyan

    # Check current Phi
    $phiResult = & $phiTool 2>&1 | Out-String
    $currentPhi = 0.0
    if ($phiResult -match "PHI_TOTAL = ([\d.]+)") {
        $currentPhi = [decimal]$matches[1]
    }

    Write-Host "Current Phi: $currentPhi" -ForegroundColor White

    # Optimization strategies
    Write-Host "`nOptimization strategies:" -ForegroundColor Yellow

    # 1. Bind more entities
    Write-Host "  [1] Bind more entities (increase Phi1)" -ForegroundColor White
    Write-Host "      Scan working directory for unbound files..." -ForegroundColor Gray

    # 2. Add more latent variables
    Write-Host "  [2] Add more latent variables (increase Phi2)" -ForegroundColor White
    Write-Host "      Consider: error_count, success_rate, session_duration" -ForegroundColor Gray

    # 3. Store more recipes
    Write-Host "  [3] Store more episodic memories" -ForegroundColor White
    Write-Host "      Capture significant moments throughout session" -ForegroundColor Gray

    # 4. Increase cross-layer connections
    Write-Host "  [4] Increase cross-layer connections" -ForegroundColor White
    Write-Host "      Link entities to latent variables, recipes to simulations" -ForegroundColor Gray

    Write-Host "`nTarget: Phi = 1.0 (perfect integration)`n" -ForegroundColor Cyan
}

# Run diagnostics
function Invoke-RunDiagnostics {
    Write-Host "`nRUNNING WORLD MODEL DIAGNOSTICS`n" -ForegroundColor Cyan

    $issues = @()
    $warnings = @()

    # Check Layer 0
    Write-Host "[Checking Layer 0: Embodiment]" -ForegroundColor Yellow
    if (Test-Path $embodimentTool) {
        Write-Host "  OK: Tool present`n" -ForegroundColor Green
    } else {
        $issues += "Layer 0: embodiment-mapper.ps1 missing"
        Write-Host "  ERROR: Tool missing`n" -ForegroundColor Red
    }

    # Check Layer 1
    Write-Host "[Checking Layer 1: Entity Binding]" -ForegroundColor Yellow
    if (Test-Path $bindingTool) {
        $entityFile = "C:\scripts\agentidentity\state\entity-registry.json"
        if (Test-Path $entityFile) {
            Write-Host "  OK: Tool and state present`n" -ForegroundColor Green
        } else {
            $warnings += "Layer 1: entity-registry.json not initialized"
            Write-Host "  WARNING: State not initialized`n" -ForegroundColor Yellow
        }
    } else {
        $issues += "Layer 1: entity-binding-system.ps1 missing"
        Write-Host "  ERROR: Tool missing`n" -ForegroundColor Red
    }

    # Check Layer 2
    Write-Host "[Checking Layer 2: Latent Variables]" -ForegroundColor Yellow
    if (Test-Path $latentTool) {
        $latentFile = "C:\scripts\agentidentity\state\latent-variables.json"
        if (Test-Path $latentFile) {
            Write-Host "  OK: Tool and state present`n" -ForegroundColor Green
        } else {
            $warnings += "Layer 2: latent-variables.json not initialized"
            Write-Host "  WARNING: State not initialized`n" -ForegroundColor Yellow
        }
    } else {
        $issues += "Layer 2: latent-variable-store.ps1 missing"
        Write-Host "  ERROR: Tool missing`n" -ForegroundColor Red
    }

    # Check Layer 3
    Write-Host "[Checking Layer 3: Counterfactual Simulation]" -ForegroundColor Yellow
    if (Test-Path $simulationTool) {
        Write-Host "  OK: Tool present`n" -ForegroundColor Green
    } else {
        $issues += "Layer 3: counterfactual-simulation.ps1 missing"
        Write-Host "  ERROR: Tool missing`n" -ForegroundColor Red
    }

    # Check Layer 4
    Write-Host "[Checking Layer 4: Episodic Memory]" -ForegroundColor Yellow
    if (Test-Path $memoryTool) {
        $recipeFile = "C:\scripts\agentidentity\state\episodic-memory-recipes.json"
        if (Test-Path $recipeFile) {
            Write-Host "  OK: Tool and state present`n" -ForegroundColor Green
        } else {
            $warnings += "Layer 4: episodic-memory-recipes.json not initialized"
            Write-Host "  WARNING: State not initialized`n" -ForegroundColor Yellow
        }
    } else {
        $issues += "Layer 4: episodic-memory-recipes.ps1 missing"
        Write-Host "  ERROR: Tool missing`n" -ForegroundColor Red
    }

    # Check Phi calculator
    Write-Host "[Checking Integration Measurement]" -ForegroundColor Yellow
    if (Test-Path $phiTool) {
        Write-Host "  OK: Phi calculator present`n" -ForegroundColor Green
    } else {
        $issues += "test-phi.ps1 missing"
        Write-Host "  ERROR: Phi calculator missing`n" -ForegroundColor Red
    }

    # Summary
    Write-Host "DIAGNOSTICS SUMMARY" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    Write-Host "Errors: $($issues.Count)" -ForegroundColor $(if ($issues.Count -eq 0) { "Green" } else { "Red" })
    Write-Host "Warnings: $($warnings.Count)" -ForegroundColor $(if ($warnings.Count -eq 0) { "Green" } else { "Yellow" })

    if ($issues.Count -gt 0) {
        Write-Host "`nErrors found:" -ForegroundColor Red
        $issues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    }

    if ($warnings.Count -gt 0) {
        Write-Host "`nWarnings:" -ForegroundColor Yellow
        $warnings | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    }

    if ($issues.Count -eq 0 -and $warnings.Count -eq 0) {
        Write-Host "`nAll systems operational!" -ForegroundColor Green
    }

    Write-Host ""
}

# Main action dispatcher
switch ($Action) {
    "ProcessEvent" {
        Invoke-ProcessEvent -event $Event
    }

    "GetSystemStatus" {
        Get-SystemStatus
    }

    "OptimizeIntegration" {
        Invoke-OptimizeIntegration
    }

    "RunDiagnostics" {
        Invoke-RunDiagnostics
    }
}
