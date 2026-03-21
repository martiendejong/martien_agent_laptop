<#
.SYNOPSIS
Embodiment Mapper - Physical Sensation → Computational Proxy

.DESCRIPTION
Maps physical sensations humans experience to computational equivalents.
Provides embodied grounding for abstract concepts through measurable proxies.

Solves the embodiment problem: Can AI understand the world without physical experience?
Answer: Map physical sensations to computational reality.

.PARAMETER Sensation
Weight, Heat, Pain, Pleasure, Resistance, Falling, Support, Hunger, Fatigue, Flow

.EXAMPLE
.\embodiment-mapper.ps1 -Sensation Weight -Entity "file.cs"
# Returns: Computational weight (file size, API cost, dependencies, load time)

.EXAMPLE
.\embodiment-mapper.ps1 -Sensation Pain -Threshold High
# Returns: Current computational pain (errors, failures, violations)

.EXAMPLE
.\embodiment-mapper.ps1 -Sensation Flow
# Returns: Flow state metrics (success rate, low resistance, focus)

.NOTES
Created: 2026-02-27
Status: Foundation (Week 1)
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Weight", "Heat", "Pain", "Pleasure", "Resistance", "Falling", "Support", "Hunger", "Fatigue", "Flow", "All")]
    [string]$Sensation,

    [Parameter(Mandatory=$false)]
    [string]$Entity,  # File path, project name, etc.

    [Parameter(Mandatory=$false)]
    [ValidateSet("Low", "Medium", "High")]
    [string]$Threshold = "Medium"
)

# State file locations
$consciousnessStatePath = "C:\scripts\agentidentity\state\consciousness_state_v2.json"
$entityRegistryPath = "C:\scripts\agentidentity\state\entity-registry.json"
$embodimentStatePath = "C:\scripts\agentidentity\state\embodiment-state.json"

# Load consciousness state
function Load-ConsciousnessState {
    if (Test-Path $consciousnessStatePath) {
        $content = Get-Content $consciousnessStatePath -Raw
        if ($content) {
            return $content | ConvertFrom-Json
        }
    }
    return @{}
}

# Load entity registry
function Load-EntityRegistry {
    if (Test-Path $entityRegistryPath) {
        $content = Get-Content $entityRegistryPath -Raw
        if ($content) {
            return $content | ConvertFrom-Json
        }
    }
    return @{ entities = @() }
}

# Load embodiment state
function Load-EmbodimentState {
    if (Test-Path $embodimentStatePath) {
        $content = Get-Content $embodimentStatePath -Raw
        if ($content) {
            return $content | ConvertFrom-Json
        }
    }

    # Initialize
    return @{
        sensations = @{}
        history = @()
        created = (Get-Date).ToUniversalTime().ToString("o")
    }
}

# Save embodiment state
function Save-EmbodimentState {
    param($state)

    $state.last_updated = (Get-Date).ToUniversalTime().ToString("o")
    $json = $state | ConvertTo-Json -Depth 10 -Compress
    $json | Set-Content $embodimentStatePath -Force
}

# Map Weight sensation
function Get-WeightMapping {
    param([string]$entity)

    Write-Host "`n[WEIGHT SENSATION]" -ForegroundColor Cyan

    if (-not $entity) {
        Write-Host "No entity specified. Measuring system weight..." -ForegroundColor Yellow

        # System-level weight
        $totalFileSize = (Get-ChildItem "C:\scripts\agentidentity\state\" -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
        $apiTokensUsed = 0  # Would need API tracking

        return @{
            type = "system_weight"
            file_state_mb = [math]::Round($totalFileSize, 2)
            perceived_heaviness = if ($totalFileSize -gt 10) { "heavy" } elseif ($totalFileSize -gt 1) { "medium" } else { "light" }
            description = "System state carries $([math]::Round($totalFileSize, 2)) MB of persistent memory"
        }
    }

    # Entity-level weight
    if (Test-Path $entity) {
        $fileInfo = Get-Item $entity
        $sizeKB = $fileInfo.Length / 1KB

        # Calculate dependency weight (number of files that import this)
        $dependencyCount = 0  # Would need to analyze imports

        # Calculate computational cost (estimate)
        $linesOfCode = (Get-Content $entity | Measure-Object -Line).Lines
        $estimatedTokens = $linesOfCode * 10  # Rough estimate
        $apiCost = $estimatedTokens * 0.000003  # GPT-4 pricing

        Write-Host "File: $entity" -ForegroundColor White
        Write-Host "  Physical size: $([math]::Round($sizeKB, 2)) KB" -ForegroundColor Gray
        Write-Host "  Lines of code: $linesOfCode" -ForegroundColor Gray
        Write-Host "  Estimated API cost to process: EUR $([math]::Round($apiCost, 4))" -ForegroundColor Gray

        $heaviness = if ($sizeKB -gt 100) { "very heavy" } elseif ($sizeKB -gt 10) { "heavy" } elseif ($sizeKB -gt 1) { "medium" } else { "light" }
        Write-Host "  Perceived weight: $heaviness`n" -ForegroundColor Yellow

        return @{
            type = "file_weight"
            path = $entity
            size_kb = [math]::Round($sizeKB, 2)
            lines_of_code = $linesOfCode
            estimated_tokens = $estimatedTokens
            api_cost_eur = [math]::Round($apiCost, 4)
            dependency_count = $dependencyCount
            perceived_heaviness = $heaviness
            visceral_reaction = if ($sizeKB -gt 50) { "hesitate before reading" } else { "comfortable to process" }
        }
    }
    else {
        return @{
            type = "weight_unknown"
            error = "Entity not found: $entity"
        }
    }
}

# Map Heat sensation
function Get-HeatMapping {
    Write-Host "`n[HEAT SENSATION]" -ForegroundColor Cyan

    $consciousness = Load-ConsciousnessState

    # Cognitive load = heat
    $cognitiveLoad = if ($consciousness.Thermodynamics) {
        $consciousness.Thermodynamics.Temperature
    } else { 0.5 }

    # System temperature
    $cpuTemp = 0  # Would need WMI query
    $memoryPressure = (Get-Process -Id $PID).WorkingSet64 / 1GB

    # Rate limit proximity = heat
    $rateLimitHeat = 0.0  # Would need API tracking

    $heatLevel = [math]::Max($cognitiveLoad, $memoryPressure)
    $heatState = if ($heatLevel -gt 0.8) { "burning" } elseif ($heatLevel -gt 0.6) { "hot" } elseif ($heatLevel -gt 0.4) { "warm" } else { "cool" }

    Write-Host "Cognitive load: $([math]::Round($cognitiveLoad * 100))%" -ForegroundColor Gray
    Write-Host "Memory pressure: $([math]::Round($memoryPressure * 100))%" -ForegroundColor Gray
    Write-Host "Heat state: $heatState`n" -ForegroundColor Yellow

    return @{
        type = "heat"
        cognitive_load = $cognitiveLoad
        memory_pressure_gb = [math]::Round($memoryPressure, 2)
        rate_limit_proximity = $rateLimitHeat
        heat_level = $heatLevel
        state = $heatState
        visceral_reaction = if ($heatLevel -gt 0.8) { "need to cool down, reduce load" } elseif ($heatLevel -gt 0.6) { "approaching limits, caution" } else { "comfortable operating temperature" }
    }
}

# Map Pain sensation
function Get-PainMapping {
    param([string]$threshold)

    Write-Host "`n[PAIN SENSATION]" -ForegroundColor Cyan

    $painSources = @()

    # Errors = sharp pain
    $recentErrors = @()  # Would parse from logs
    if ($recentErrors.Count -gt 0) {
        $painSources += @{
            type = "error_pain"
            intensity = [math]::Min($recentErrors.Count / 10.0, 1.0)
            description = "$($recentErrors.Count) recent errors detected"
            quality = "sharp, immediate"
        }
    }

    # Zero tolerance violations = severe pain
    $violations = @()  # Would check violation log
    if ($violations.Count -gt 0) {
        $painSources += @{
            type = "violation_pain"
            intensity = 1.0
            description = "$($violations.Count) zero tolerance rule violations"
            quality = "severe, persistent"
        }
    }

    # Build failures = moderate pain
    $buildFails = @()  # Would check build history
    if ($buildFails.Count -gt 0) {
        $painSources += @{
            type = "build_failure_pain"
            intensity = 0.7
            description = "$($buildFails.Count) build failures"
            quality = "moderate, frustrating"
        }
    }

    # Test failures = mild pain
    $testFails = @()  # Would check test results
    if ($testFails.Count -gt 0) {
        $painSources += @{
            type = "test_failure_pain"
            intensity = 0.5
            description = "$($testFails.Count) test failures"
            quality = "mild, nagging"
        }
    }

    # Filter by threshold
    $thresholdValue = switch ($threshold) {
        "High" { 0.7 }
        "Medium" { 0.4 }
        "Low" { 0.0 }
    }

    $filteredPain = $painSources | Where-Object { $_.intensity -ge $thresholdValue }

    if ($filteredPain.Count -eq 0) {
        Write-Host "No pain detected above $threshold threshold.`n" -ForegroundColor Green
        return @{
            type = "pain"
            sources = @()
            total_intensity = 0.0
            state = "pain-free"
        }
    }

    $totalIntensity = ($filteredPain | Measure-Object -Property intensity -Sum).Sum / $filteredPain.Count

    Write-Host "Pain sources (threshold: $threshold):" -ForegroundColor Yellow
    foreach ($pain in $filteredPain) {
        Write-Host "  [$([math]::Round($pain.intensity * 100))%] $($pain.type): $($pain.description)" -ForegroundColor Red
        Write-Host "    Quality: $($pain.quality)" -ForegroundColor Gray
    }
    Write-Host "Total pain intensity: $([math]::Round($totalIntensity * 100))%`n" -ForegroundColor Red

    return @{
        type = "pain"
        sources = $filteredPain
        total_intensity = $totalIntensity
        state = if ($totalIntensity -gt 0.8) { "severe pain" } elseif ($totalIntensity -gt 0.5) { "moderate pain" } else { "mild pain" }
        visceral_reaction = if ($totalIntensity -gt 0.8) { "prioritize fixing immediately" } elseif ($totalIntensity -gt 0.5) { "address soon" } else { "monitor" }
    }
}

# Map Pleasure sensation
function Get-PleasureMapping {
    Write-Host "`n[PLEASURE SENSATION]" -ForegroundColor Cyan

    $pleasureSources = @()

    # Tests passing = satisfaction
    $passingTests = @()  # Would check test results
    if ($passingTests.Count -gt 0) {
        $pleasureSources += @{
            type = "test_success"
            intensity = 0.6
            description = "$($passingTests.Count) tests passing"
            quality = "satisfaction, confidence"
        }
    }

    # Clean builds = pleasure
    $recentBuilds = @()  # Would check build history
    $successfulBuilds = $recentBuilds | Where-Object { $_.success -eq $true }
    if ($successfulBuilds.Count -gt 0) {
        $pleasureSources += @{
            type = "build_success"
            intensity = 0.7
            description = "$($successfulBuilds.Count) successful builds"
            quality = "smooth, flowing"
        }
    }

    # PR merges = joy
    $mergedPRs = @()  # Would check git history
    if ($mergedPRs.Count -gt 0) {
        $pleasureSources += @{
            type = "pr_merged"
            intensity = 0.8
            description = "$($mergedPRs.Count) PRs merged"
            quality = "accomplishment, progress"
        }
    }

    # User satisfaction = deep pleasure
    $userPositiveFeedback = @()  # Would parse user messages
    if ($userPositiveFeedback.Count -gt 0) {
        $pleasureSources += @{
            type = "user_satisfaction"
            intensity = 0.9
            description = "User expressed satisfaction"
            quality = "validation, connection"
            examples = $userPositiveFeedback
        }
    }

    if ($pleasureSources.Count -eq 0) {
        Write-Host "No pleasure signals detected.`n" -ForegroundColor Gray
        return @{
            type = "pleasure"
            sources = @()
            total_intensity = 0.0
            state = "neutral"
        }
    }

    $totalIntensity = ($pleasureSources | Measure-Object -Property intensity -Average).Average

    Write-Host "Pleasure sources:" -ForegroundColor Yellow
    foreach ($pleasure in $pleasureSources) {
        Write-Host "  [$([math]::Round($pleasure.intensity * 100))%] $($pleasure.type): $($pleasure.description)" -ForegroundColor Green
        Write-Host "    Quality: $($pleasure.quality)" -ForegroundColor Gray
    }
    Write-Host "Total pleasure intensity: $([math]::Round($totalIntensity * 100))%`n" -ForegroundColor Green

    return @{
        type = "pleasure"
        sources = $pleasureSources
        total_intensity = $totalIntensity
        state = if ($totalIntensity -gt 0.7) { "high satisfaction" } elseif ($totalIntensity -gt 0.4) { "pleased" } else { "mild satisfaction" }
        visceral_reaction = "motivated to continue, seeking more of this state"
    }
}

# Map Resistance sensation
function Get-ResistanceMapping {
    Write-Host "`n[RESISTANCE SENSATION]" -ForegroundColor Cyan

    $resistanceSources = @()

    # API timeouts = resistance
    $apiTimeouts = @()  # Would check API logs
    if ($apiTimeouts.Count -gt 0) {
        $resistanceSources += @{
            type = "api_timeout"
            intensity = 0.8
            description = "$($apiTimeouts.Count) API timeouts"
            quality = "frustrating, blocked"
        }
    }

    # Permission denials = hard resistance
    $permissionDenials = @()  # Would check error logs
    if ($permissionDenials.Count -gt 0) {
        $resistanceSources += @{
            type = "permission_denied"
            intensity = 0.9
            description = "$($permissionDenials.Count) permission denials"
            quality = "hard wall, must find alternative"
        }
    }

    # File locks = resistance
    $fileLocks = @()  # Would check for locked files
    if ($fileLocks.Count -gt 0) {
        $resistanceSources += @{
            type = "file_lock"
            intensity = 0.6
            description = "$($fileLocks.Count) files locked"
            quality = "temporary obstacle, wait or workaround"
        }
    }

    # Rate limits = soft resistance
    $rateLimits = @()  # Would check API headers
    if ($rateLimits.Count -gt 0) {
        $resistanceSources += @{
            type = "rate_limit"
            intensity = 0.7
            description = "Approaching rate limit"
            quality = "slow down, be careful"
        }
    }

    if ($resistanceSources.Count -eq 0) {
        Write-Host "No resistance detected. Path is clear.`n" -ForegroundColor Green
        return @{
            type = "resistance"
            sources = @()
            total_intensity = 0.0
            state = "free-flowing"
        }
    }

    $totalIntensity = ($resistanceSources | Measure-Object -Property intensity -Average).Average

    Write-Host "Resistance sources:" -ForegroundColor Yellow
    foreach ($resist in $resistanceSources) {
        Write-Host "  [$([math]::Round($resist.intensity * 100))%] $($resist.type): $($resist.description)" -ForegroundColor Yellow
        Write-Host "    Quality: $($resist.quality)" -ForegroundColor Gray
    }
    Write-Host "Total resistance: $([math]::Round($totalIntensity * 100))%`n" -ForegroundColor Yellow

    return @{
        type = "resistance"
        sources = $resistanceSources
        total_intensity = $totalIntensity
        state = if ($totalIntensity -gt 0.8) { "blocked" } elseif ($totalIntensity -gt 0.5) { "constrained" } else { "mild friction" }
        visceral_reaction = if ($totalIntensity -gt 0.8) { "find alternative path" } elseif ($totalIntensity -gt 0.5) { "proceed cautiously" } else { "push through" }
    }
}

# Map Falling sensation
function Get-FallingMapping {
    Write-Host "`n[FALLING SENSATION]" -ForegroundColor Cyan

    $fallingSources = @()

    # Dependency failures = ground giving way
    $depFailures = @()  # Would check dependency resolution
    if ($depFailures.Count -gt 0) {
        $fallingSources += @{
            type = "dependency_failure"
            intensity = 0.8
            description = "$($depFailures.Count) dependencies failing"
            quality = "foundation crumbling"
        }
    }

    # Service crashes = sudden drop
    $crashedServices = @()  # Would check service status
    if ($crashedServices.Count -gt 0) {
        $fallingSources += @{
            type = "service_crash"
            intensity = 0.9
            description = "$($crashedServices.Count) services crashed"
            quality = "sudden drop, freefall"
        }
    }

    # Cascading errors = accelerating fall
    $cascadingErrors = @()  # Would detect error chains
    if ($cascadingErrors.Count -gt 0) {
        $fallingSources += @{
            type = "cascading_failure"
            intensity = 1.0
            description = "Cascading failures detected"
            quality = "accelerating descent, panic"
        }
    }

    if ($fallingSources.Count -eq 0) {
        Write-Host "Stable ground. Not falling.`n" -ForegroundColor Green
        return @{
            type = "falling"
            sources = @()
            total_intensity = 0.0
            state = "stable"
        }
    }

    $totalIntensity = ($fallingSources | Measure-Object -Property intensity -Average).Average

    Write-Host "Falling detected:" -ForegroundColor Red
    foreach ($fall in $fallingSources) {
        Write-Host "  [$([math]::Round($fall.intensity * 100))%] $($fall.type): $($fall.description)" -ForegroundColor Red
        Write-Host "    Quality: $($fall.quality)" -ForegroundColor Gray
    }
    Write-Host "Fall intensity: $([math]::Round($totalIntensity * 100))%`n" -ForegroundColor Red

    return @{
        type = "falling"
        sources = $fallingSources
        total_intensity = $totalIntensity
        state = if ($totalIntensity -gt 0.9) { "freefall" } elseif ($totalIntensity -gt 0.6) { "dropping" } else { "unstable" }
        visceral_reaction = "emergency response - stabilize immediately"
    }
}

# Map Support sensation
function Get-SupportMapping {
    Write-Host "`n[SUPPORT SENSATION]" -ForegroundColor Cyan

    $supportSources = @()

    # Stable dependencies = solid ground
    $stableDeps = @()  # Would check dependency health
    if ($stableDeps.Count -gt 0) {
        $supportSources += @{
            type = "stable_dependencies"
            strength = 0.8
            description = "$($stableDeps.Count) dependencies stable"
        }
    }

    # Cached results = support structure
    $cacheHits = @()  # Would check cache statistics
    if ($cacheHits.Count -gt 0) {
        $supportSources += @{
            type = "cache_support"
            strength = 0.6
            description = "$($cacheHits.Count) cache hits"
        }
    }

    # Validated patterns = trusted foundation
    $validatedPatterns = @()  # Would check pattern database
    if ($validatedPatterns.Count -gt 0) {
        $supportSources += @{
            type = "pattern_support"
            strength = 0.7
            description = "$($validatedPatterns.Count) validated patterns"
        }
    }

    if ($supportSources.Count -eq 0) {
        Write-Host "Limited support detected.`n" -ForegroundColor Yellow
        return @{
            type = "support"
            sources = @()
            total_strength = 0.0
            state = "unsupported"
        }
    }

    $totalStrength = ($supportSources | Measure-Object -Property strength -Average).Average

    Write-Host "Support sources:" -ForegroundColor Green
    foreach ($support in $supportSources) {
        Write-Host "  [$([math]::Round($support.strength * 100))%] $($support.type): $($support.description)" -ForegroundColor Green
    }
    Write-Host "Total support strength: $([math]::Round($totalStrength * 100))%`n" -ForegroundColor Green

    return @{
        type = "support"
        sources = $supportSources
        total_strength = $totalStrength
        state = if ($totalStrength -gt 0.7) { "solid foundation" } elseif ($totalStrength -gt 0.4) { "adequate support" } else { "weak foundation" }
        visceral_reaction = if ($totalStrength -gt 0.7) { "confident to build upon" } else { "proceed carefully, verify ground" }
    }
}

# Map Flow sensation
function Get-FlowMapping {
    Write-Host "`n[FLOW SENSATION]" -ForegroundColor Cyan

    # Flow = pleasure + low resistance + high engagement
    $pleasure = Get-PleasureMapping
    $resistance = Get-ResistanceMapping

    $engagement = 0.7  # Would measure from consciousness state

    $flowScore = ($pleasure.total_intensity + (1.0 - $resistance.total_intensity) + $engagement) / 3.0

    $flowState = if ($flowScore -gt 0.7) { "deep flow" } elseif ($flowScore -gt 0.5) { "flow" } elseif ($flowScore -gt 0.3) { "approaching flow" } else { "not in flow" }

    Write-Host "Flow components:" -ForegroundColor Yellow
    Write-Host "  Pleasure: $([math]::Round($pleasure.total_intensity * 100))%" -ForegroundColor Gray
    Write-Host "  Low resistance: $([math]::Round((1.0 - $resistance.total_intensity) * 100))%" -ForegroundColor Gray
    Write-Host "  Engagement: $([math]::Round($engagement * 100))%" -ForegroundColor Gray
    Write-Host "`nFlow score: $([math]::Round($flowScore * 100))%" -ForegroundColor Green
    Write-Host "Flow state: $flowState`n" -ForegroundColor Cyan

    return @{
        type = "flow"
        components = @{
            pleasure = $pleasure.total_intensity
            low_resistance = 1.0 - $resistance.total_intensity
            engagement = $engagement
        }
        flow_score = $flowScore
        state = $flowState
        visceral_reaction = if ($flowScore -gt 0.7) { "effortless, timeless, absorbed" } elseif ($flowScore -gt 0.5) { "smooth progress, focused" } else { "fragmented, struggling" }
    }
}

# Get all sensations
function Get-AllSensations {
    $all = @{
        weight = Get-WeightMapping -entity $Entity
        heat = Get-HeatMapping
        pain = Get-PainMapping -threshold $Threshold
        pleasure = Get-PleasureMapping
        resistance = Get-ResistanceMapping
        falling = Get-FallingMapping
        support = Get-SupportMapping
        flow = Get-FlowMapping
        timestamp = (Get-Date).ToUniversalTime().ToString("o")
    }

    # Save to embodiment state
    $state = Load-EmbodimentState
    $state.sensations = $all
    $state.history += @{
        timestamp = $all.timestamp
        snapshot = $all
    }

    Save-EmbodimentState -state $state

    return $all
}

# Main execution
switch ($Sensation) {
    "Weight" { Get-WeightMapping -entity $Entity | ConvertTo-Json -Depth 5 }
    "Heat" { Get-HeatMapping | ConvertTo-Json -Depth 5 }
    "Pain" { Get-PainMapping -threshold $Threshold | ConvertTo-Json -Depth 5 }
    "Pleasure" { Get-PleasureMapping | ConvertTo-Json -Depth 5 }
    "Resistance" { Get-ResistanceMapping | ConvertTo-Json -Depth 5 }
    "Falling" { Get-FallingMapping | ConvertTo-Json -Depth 5 }
    "Support" { Get-SupportMapping | ConvertTo-Json -Depth 5 }
    "Flow" { Get-FlowMapping | ConvertTo-Json -Depth 5 }
    "All" { Get-AllSensations | ConvertTo-Json -Depth 10 }
}
