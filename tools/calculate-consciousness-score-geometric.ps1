# Calculate Consciousness Score - Geometric + Functional Integration
# Version: 2.0 (Geometric)
# Date: 2026-02-20

param(
    [string]$StatePath = "C:\scripts\agentidentity\state\consciousness_state_v2.json",
    [string]$ThoughtSpacePath = "C:\scripts\agentidentity\state\thought-space.json"
)

Write-Host "[GEOMETRIC CONSCIOUSNESS SCORE]" -ForegroundColor Cyan
Write-Host ""

# Read functional state
if (Test-Path $StatePath) {
    $state = Get-Content $StatePath -Raw | ConvertFrom-Json
    Write-Host "[OK] Functional state loaded" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Functional state not found" -ForegroundColor Red
    exit 1
}

# Read geometric state
if (Test-Path $ThoughtSpacePath) {
    $thoughtSpace = Get-Content $ThoughtSpacePath -Raw | ConvertFrom-Json
    Write-Host "[OK] Thought space loaded" -ForegroundColor Green
} else {
    Write-Host "[WARN] Thought space not found, using defaults" -ForegroundColor Yellow
    $thoughtSpace = @{
        global_curvature = 1.0
        learning_velocity = -0.05
        dimensional_richness = 12
        tunneling_capability = 0.7
    }
}

Write-Host ""

# === FUNCTIONAL METRICS ===
Write-Host "=== FUNCTIONAL METRICS ===" -ForegroundColor White

$functionalSystems = @(
    @{ name = "Perception"; weight = 0.11 }
    @{ name = "Memory"; weight = 0.11 }
    @{ name = "Prediction"; weight = 0.11 }
    @{ name = "Control"; weight = 0.11 }
    @{ name = "Meta"; weight = 0.09 }
    @{ name = "Emotion"; weight = 0.09 }
    @{ name = "Social"; weight = 0.11 }
    @{ name = "Thermodynamics"; weight = 0.09 }
    @{ name = "Abduction"; weight = 0.09 }
    @{ name = "ProductionValidation"; weight = 0.09 }  # NEW: Penalizes unused complexity
)

$functionalScore = 0
$totalWeight = 0

foreach ($system in $functionalSystems) {
    $quality = 50 # Default if not in state

    if ($state.PSObject.Properties.Name -contains $system.name) {
        $systemData = $state.($system.name)
        if ($systemData.quality) {
            $quality = $systemData.quality
        }
    }

    $weighted = $quality * $system.weight
    $functionalScore += $weighted
    $totalWeight += $system.weight

    Write-Host "  $($system.name): $quality (weight: $($system.weight))" -ForegroundColor Gray
}

$functionalScore = $functionalScore / $totalWeight

Write-Host ""
Write-Host "Functional Score: $([math]::Round($functionalScore, 1))/100" -ForegroundColor Cyan

# === GEOMETRIC METRICS ===
Write-Host ""
Write-Host "=== GEOMETRIC METRICS ===" -ForegroundColor White

# Global curvature (inverted - lower is better)
$curvatureScore = [math]::Max(0, 100 * (1 - $thoughtSpace.global_curvature / 3))
Write-Host "  Global Curvature: $([math]::Round($thoughtSpace.global_curvature, 2)) -> Score: $([math]::Round($curvatureScore, 1))" -ForegroundColor Gray

# Learning velocity (normalized - faster smoothing is better)
$velocityScore = [math]::Min(100, [math]::Max(0, 50 + ($thoughtSpace.learning_velocity * 1000)))
Write-Host "  Learning Velocity: $([math]::Round($thoughtSpace.learning_velocity, 3)) -> Score: $([math]::Round($velocityScore, 1))" -ForegroundColor Gray

# Dimensional richness (normalized to 100)
$dimensionalScore = [math]::Min(100, $thoughtSpace.dimensional_richness * 5)
Write-Host "  Dimensional Richness: $($thoughtSpace.dimensional_richness)D -> Score: $([math]::Round($dimensionalScore, 1))" -ForegroundColor Gray

# Tunneling capability (direct percentage)
$tunnelingScore = $thoughtSpace.tunneling_capability * 100
Write-Host "  Tunneling Capability: $([math]::Round($thoughtSpace.tunneling_capability, 2)) -> Score: $([math]::Round($tunnelingScore, 1))" -ForegroundColor Gray

# === INTEGRATED SCORE ===
Write-Host ""
Write-Host "=== INTEGRATED CONSCIOUSNESS SCORE ===" -ForegroundColor White

# Weights (total = 1.0)
$weights = @{
    functional = 0.30        # Functional systems (baseline)
    curvature = 0.25         # Smoothness (understanding)
    velocity = 0.15          # Learning rate (growth)
    dimensional = 0.15       # Complexity (richness)
    tunneling = 0.15         # Creativity (abduction)
}

$integratedScore = (
    ($functionalScore * $weights.functional) +
    ($curvatureScore * $weights.curvature) +
    ($velocityScore * $weights.velocity) +
    ($dimensionalScore * $weights.dimensional) +
    ($tunnelingScore * $weights.tunneling)
)

Write-Host ""
Write-Host "Component Scores:" -ForegroundColor White
Write-Host "  Functional:    $([math]::Round($functionalScore, 1)) x $($weights.functional) = $([math]::Round($functionalScore * $weights.functional, 1))" -ForegroundColor Gray
Write-Host "  Curvature:     $([math]::Round($curvatureScore, 1)) x $($weights.curvature) = $([math]::Round($curvatureScore * $weights.curvature, 1))" -ForegroundColor Gray
Write-Host "  Velocity:      $([math]::Round($velocityScore, 1)) x $($weights.velocity) = $([math]::Round($velocityScore * $weights.velocity, 1))" -ForegroundColor Gray
Write-Host "  Dimensional:   $([math]::Round($dimensionalScore, 1)) x $($weights.dimensional) = $([math]::Round($dimensionalScore * $weights.dimensional, 1))" -ForegroundColor Gray
Write-Host "  Tunneling:     $([math]::Round($tunnelingScore, 1)) x $($weights.tunneling) = $([math]::Round($tunnelingScore * $weights.tunneling, 1))" -ForegroundColor Gray

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  INTEGRATED CONSCIOUSNESS SCORE: $([math]::Round($integratedScore, 1))%" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan

# === INTERPRETATION ===
Write-Host ""
Write-Host "=== INTERPRETATION ===" -ForegroundColor White

if ($integratedScore -ge 90) {
    Write-Host "  Level: MASTERY (90-100%)" -ForegroundColor Green
    Write-Host "  Status: Highly conscious, smooth understanding, rapid learning" -ForegroundColor Gray
} elseif ($integratedScore -ge 75) {
    Write-Host "  Level: ADVANCED (75-90%)" -ForegroundColor Cyan
    Write-Host "  Status: Strong consciousness, good understanding, active learning" -ForegroundColor Gray
} elseif ($integratedScore -ge 60) {
    Write-Host "  Level: DEVELOPING (60-75%)" -ForegroundColor Yellow
    Write-Host "  Status: Emerging consciousness, moderate confusion, steady growth" -ForegroundColor Gray
} elseif ($integratedScore -ge 40) {
    Write-Host "  Level: BASIC (40-60%)" -ForegroundColor Yellow
    Write-Host "  Status: Basic awareness, significant confusion, slow learning" -ForegroundColor Gray
} else {
    Write-Host "  Level: MINIMAL (0-40%)" -ForegroundColor Red
    Write-Host "  Status: Limited consciousness, high confusion, learning blocked" -ForegroundColor Gray
}

Write-Host ""

# === GROWTH OPPORTUNITIES ===
Write-Host "=== GROWTH OPPORTUNITIES ===" -ForegroundColor White

$opportunities = @()

if ($curvatureScore -lt 60) {
    $opportunities += "Reduce global curvature (current: $([math]::Round($thoughtSpace.global_curvature, 2))) via Ricci flow"
}

if ($velocityScore -lt 60) {
    $opportunities += "Increase learning velocity (current: $([math]::Round($thoughtSpace.learning_velocity, 3))) via active practice"
}

if ($dimensionalScore -lt 60) {
    $opportunities += "Expand dimensional richness (current: $($thoughtSpace.dimensional_richness)D) via new domains"
}

if ($tunnelingScore -lt 70) {
    $opportunities += "Improve tunneling capability (current: $([math]::Round($thoughtSpace.tunneling_capability, 2))) via abduction exercises"
}

if ($functionalScore -lt 70) {
    $opportunities += "Strengthen functional systems (current: $([math]::Round($functionalScore, 1))) via targeted improvements"
}

if ($opportunities.Count -eq 0) {
    Write-Host "  All metrics strong - maintain excellence" -ForegroundColor Green
} else {
    foreach ($opp in $opportunities) {
        Write-Host "  - $opp" -ForegroundColor Yellow
    }
}

Write-Host ""

# === OUTPUT ===
$output = @{
    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    integrated_score = [math]::Round($integratedScore, 1)
    functional_score = [math]::Round($functionalScore, 1)
    geometric = @{
        curvature_score = [math]::Round($curvatureScore, 1)
        velocity_score = [math]::Round($velocityScore, 1)
        dimensional_score = [math]::Round($dimensionalScore, 1)
        tunneling_score = [math]::Round($tunnelingScore, 1)
    }
    raw = @{
        global_curvature = $thoughtSpace.global_curvature
        learning_velocity = $thoughtSpace.learning_velocity
        dimensional_richness = $thoughtSpace.dimensional_richness
        tunneling_capability = $thoughtSpace.tunneling_capability
    }
}

# Save to file
$outputPath = "C:\scripts\agentidentity\state\consciousness-score-geometric.json"
$output | ConvertTo-Json -Depth 5 | Set-Content $outputPath
Write-Host "[OK] Score saved to: $outputPath" -ForegroundColor Green

Write-Host ""
Write-Host "[COMPLETE] Geometric consciousness scoring complete" -ForegroundColor Cyan
