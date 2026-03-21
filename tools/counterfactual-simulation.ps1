<#
.SYNOPSIS
Counterfactual Simulation Engine - Layer 3 of World Model

.DESCRIPTION
Enables "what if" reasoning by simulating consequences of hypothetical actions.
Implements forward (cause→effect) and backward (effect→cause) inference.

Transforms AI from pattern matcher to causal reasoner.

.PARAMETER SimulationType
Forward, Backward, Counterfactual, Analogical

.EXAMPLE
.\counterfactual-simulation.ps1 -SimulationType Forward -Action "delete_function" -Target "FooService.GetFoo()"
# Simulates deleting function, predicts: 3 tests fail, 2 files won't compile

.EXAMPLE
.\counterfactual-simulation.ps1 -SimulationType Backward -Error "NullReferenceException at line 42 in FooService.cs"
# Traces backward to probable causes, ranked by likelihood

.EXAMPLE
.\counterfactual-simulation.ps1 -SimulationType Counterfactual -Hypothesis @{table_material="glass"; action="hammer_strike"}
# Simulates: table=glass + hammer_strike → result=shatter (with confidence score)

.NOTES
Created: 2026-02-27
Status: Foundation (Week 1)
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Forward", "Backward", "Counterfactual", "Analogical", "Stats")]
    [string]$SimulationType,

    [Parameter(Mandatory=$false)]
    [string]$Action,  # For Forward simulation

    [Parameter(Mandatory=$false)]
    [string]$Target,  # What entity is affected

    [Parameter(Mandatory=$false)]
    [string]$Error,  # For Backward simulation

    [Parameter(Mandatory=$false)]
    [hashtable]$Hypothesis,  # For Counterfactual

    [Parameter(Mandatory=$false)]
    [hashtable]$LatentState  # For Analogical search
)

# State file locations
$simulationResultsPath = "C:\scripts\agentidentity\state\simulation-results.jsonl"
$entityRegistryPath = "C:\scripts\agentidentity\state\entity-registry.json"
$episodicMemoryPath = "C:\scripts\agentidentity\state\episodic-memory.json"

# Ensure state directory exists
$stateDir = Split-Path $simulationResultsPath -Parent
if (-not (Test-Path $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
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

# Load episodic memory
function Load-EpisodicMemory {
    if (Test-Path $episodicMemoryPath) {
        $content = Get-Content $episodicMemoryPath -Raw
        if ($content) {
            return $content | ConvertFrom-Json
        }
    }
    return @{ episodes = @() }
}

# Log simulation result
function Log-SimulationResult {
    param(
        [string]$type,
        [hashtable]$input,
        [hashtable]$output,
        [float]$confidence
    )

    $result = @{
        timestamp = (Get-Date).ToUniversalTime().ToString("o")
        simulation_type = $type
        input = $input
        output = $output
        confidence = $confidence
    }

    $json = $result | ConvertTo-Json -Depth 5 -Compress
    $json | Add-Content $simulationResultsPath -Force
}

# FORWARD SIMULATION: Cause → Effect
function Invoke-ForwardSimulation {
    param(
        [string]$action,
        [string]$target
    )

    Write-Host "`n[FORWARD SIMULATION] $action on $target`n" -ForegroundColor Cyan

    $predictions = @()
    $confidence = 0.5  # Default

    # Parse action type
    switch -Regex ($action) {
        "delete_function" {
            Write-Host "Simulating function deletion..." -ForegroundColor Yellow

            # Load entity registry to find dependents
            $registry = Load-EntityRegistry

            # Find function entity
            $functionEntity = $registry.entities | Where-Object {
                $_.type -eq "function" -and $_.features.name -match $target
            } | Select-Object -First 1

            if ($functionEntity) {
                # Find callers
                $callers = $registry.entities | Where-Object {
                    $_.type -eq "function_call" -and $_.features.target -eq $functionEntity.id
                }

                if ($callers.Count -gt 0) {
                    $predictions += @{
                        type = "build_failure"
                        description = "Build will fail: $($callers.Count) call sites become unresolved"
                        affected_files = $callers | Select-Object -ExpandProperty features | Select-Object -ExpandProperty file | Select-Object -Unique
                        severity = "high"
                    }
                    $confidence = 0.9
                }

                # Check for tests
                $testCalls = $callers | Where-Object { $_.features.file -like "*Test*" -or $_.features.file -like "*test*" }
                if ($testCalls.Count -gt 0) {
                    $predictions += @{
                        type = "test_failure"
                        description = "$($testCalls.Count) tests will fail"
                        affected_tests = $testCalls | Select-Object -ExpandProperty features | Select-Object -ExpandProperty file
                        severity = "high"
                    }
                    $confidence = 0.85
                }
            }
            else {
                # Function not in registry - predict based on naming patterns
                $predictions += @{
                    type = "unknown_impact"
                    description = "Function not found in entity registry. Impact unknown."
                    recommendation = "Run static analysis to find call sites"
                    severity = "medium"
                }
                $confidence = 0.3
            }
        }

        "delete_file" {
            Write-Host "Simulating file deletion..." -ForegroundColor Yellow

            # Check if file exists in entity registry
            $registry = Load-EntityRegistry
            $fileEntity = $registry.entities | Where-Object {
                $_.type -eq "file" -and $_.features.path -match $target
            } | Select-Object -First 1

            if ($fileEntity) {
                # Find dependencies
                $dependencies = $registry.entities | Where-Object {
                    $_.type -eq "dependency" -and $_.features.source -eq $fileEntity.id
                }

                if ($dependencies.Count -gt 0) {
                    $predictions += @{
                        type = "broken_dependencies"
                        description = "$($dependencies.Count) files depend on this file"
                        affected_files = $dependencies | Select-Object -ExpandProperty features | Select-Object -ExpandProperty target
                        severity = "high"
                    }
                    $confidence = 0.9
                }

                # Check for project file references
                if ($fileEntity.features.path -like "*.csproj") {
                    $predictions += @{
                        type = "project_broken"
                        description = "Deleting project file will break solution"
                        severity = "critical"
                    }
                    $confidence = 1.0
                }
            }
        }

        "edit_file" {
            Write-Host "Simulating file edit..." -ForegroundColor Yellow

            # Predict rebuild required
            $predictions += @{
                type = "rebuild_required"
                description = "File modification requires rebuild"
                estimated_time_seconds = 30
                severity = "low"
            }
            $confidence = 0.95

            # Check if file is in hot path
            if ($target -like "*Controller*" -or $target -like "*Service*") {
                $predictions += @{
                    type = "integration_tests_affected"
                    description = "Core service changed - integration tests should run"
                    recommendation = "Run full test suite"
                    severity = "medium"
                }
                $confidence = 0.7
            }
        }

        default {
            $predictions += @{
                type = "unknown_action"
                description = "Simulation for action '$action' not implemented yet"
                severity = "unknown"
            }
            $confidence = 0.0
        }
    }

    # Log simulation
    Log-SimulationResult -type "forward" -input @{ action = $action; target = $target } `
        -output @{ predictions = $predictions } -confidence $confidence

    # Display results
    Write-Host "`nPredictions (confidence: $($confidence * 100)%):" -ForegroundColor Green
    foreach ($pred in $predictions) {
        Write-Host "  [$($pred.severity.ToUpper())] $($pred.type): $($pred.description)" -ForegroundColor $(
            switch ($pred.severity) {
                "critical" { "Red" }
                "high" { "Yellow" }
                "medium" { "Cyan" }
                "low" { "Gray" }
                default { "White" }
            }
        )

        if ($pred.affected_files) {
            Write-Host "    Affected files: $($pred.affected_files.Count)" -ForegroundColor DarkGray
        }
        if ($pred.recommendation) {
            Write-Host "    Recommendation: $($pred.recommendation)" -ForegroundColor DarkCyan
        }
    }

    return @{
        predictions = $predictions
        confidence = $confidence
    }
}

# BACKWARD SIMULATION: Effect → Cause
function Invoke-BackwardSimulation {
    param([string]$error)

    Write-Host "`n[BACKWARD SIMULATION] Tracing cause of error`n" -ForegroundColor Cyan
    Write-Host "Error: $error`n" -ForegroundColor Red

    $causes = @()
    $confidence = 0.5

    # Parse error type
    switch -Regex ($error) {
        "NullReferenceException" {
            Write-Host "Analyzing NullReferenceException..." -ForegroundColor Yellow

            # Extract file and line number
            if ($error -match "at line (\d+) in (.+)") {
                $line = $matches[1]
                $file = $matches[2]

                $causes += @{
                    type = "uninitialized_variable"
                    description = "Variable accessed before initialization or null check"
                    location = "$file:$line"
                    likelihood = 0.7
                    fix_suggestion = "Add null check: if (foo != null) { ... }"
                }

                $causes += @{
                    type = "dependency_injection_missing"
                    description = "Service not registered in DI container"
                    location = "Program.cs"
                    likelihood = 0.5
                    fix_suggestion = "Add service registration: builder.Services.AddScoped<IFoo, Foo>()"
                }

                $causes += @{
                    type = "async_timing"
                    description = "Async operation not awaited, value accessed before ready"
                    location = "$file:$line"
                    likelihood = 0.3
                    fix_suggestion = "Add await keyword: var result = await GetFooAsync()"
                }

                $confidence = 0.7
            }
        }

        "Cannot resolve service" {
            Write-Host "Analyzing DI resolution failure..." -ForegroundColor Yellow

            # Extract service name
            if ($error -match "Cannot resolve service for type '(.+)'") {
                $serviceType = $matches[1]

                $causes += @{
                    type = "missing_di_registration"
                    description = "Service '$serviceType' not registered in DI container"
                    location = "Program.cs or Startup.cs"
                    likelihood = 0.9
                    fix_suggestion = "Add: builder.Services.AddScoped<$serviceType, ConcreteImplementation>()"
                }

                $causes += @{
                    type = "circular_dependency"
                    description = "Service has circular dependency preventing resolution"
                    location = "Service constructors"
                    likelihood = 0.3
                    fix_suggestion = "Refactor to break circular dependency or use IServiceProvider"
                }

                $confidence = 0.9
            }
        }

        "Build failed" {
            Write-Host "Analyzing build failure..." -ForegroundColor Yellow

            $causes += @{
                type = "compilation_error"
                description = "Syntax or type error in code"
                likelihood = 0.6
                fix_suggestion = "Check compiler output for specific error"
            }

            $causes += @{
                type = "missing_dependency"
                description = "NuGet package or project reference missing"
                likelihood = 0.4
                fix_suggestion = "Restore NuGet packages or add missing project reference"
            }

            $confidence = 0.5
        }

        default {
            $causes += @{
                type = "unknown_error"
                description = "Error pattern not recognized"
                likelihood = 0.0
                fix_suggestion = "Manual investigation required"
            }
            $confidence = 0.1
        }
    }

    # Sort causes by likelihood
    $causes = $causes | Sort-Object -Property likelihood -Descending

    # Log simulation
    Log-SimulationResult -type "backward" -input @{ error = $error } `
        -output @{ causes = $causes } -confidence $confidence

    # Display results
    Write-Host "`nProbable Causes (confidence: $($confidence * 100)%):" -ForegroundColor Green
    foreach ($cause in $causes) {
        Write-Host "  [Likelihood: $($cause.likelihood * 100)%] $($cause.type)" -ForegroundColor Yellow
        Write-Host "    $($cause.description)" -ForegroundColor White
        if ($cause.location) {
            Write-Host "    Location: $($cause.location)" -ForegroundColor DarkGray
        }
        Write-Host "    Fix: $($cause.fix_suggestion)" -ForegroundColor Cyan
        Write-Host ""
    }

    return @{
        causes = $causes
        confidence = $confidence
        recommendation = $causes[0].fix_suggestion
    }
}

# COUNTERFACTUAL SIMULATION: What if X were Y?
function Invoke-CounterfactualSimulation {
    param([hashtable]$hypothesis)

    Write-Host "`n[COUNTERFACTUAL SIMULATION] What if...`n" -ForegroundColor Cyan

    $consequences = @()
    $confidence = 0.5

    # Display hypothesis
    Write-Host "Hypothesis:" -ForegroundColor Yellow
    foreach ($key in $hypothesis.Keys) {
        Write-Host "  $key = $($hypothesis[$key])" -ForegroundColor White
    }
    Write-Host ""

    # Physics-based simulation
    if ($hypothesis.ContainsKey("material") -and $hypothesis.ContainsKey("action")) {
        $material = $hypothesis.material
        $action = $hypothesis.action

        # Material properties database (simplified)
        $materials = @{
            glass = @{ fragility = 0.9; weight = 0.3; solidity = 0.5 }
            wood = @{ fragility = 0.3; weight = 0.5; solidity = 0.7 }
            metal = @{ fragility = 0.1; weight = 0.9; solidity = 0.9 }
            plastic = @{ fragility = 0.4; weight = 0.2; solidity = 0.4 }
        }

        if ($materials.ContainsKey($material)) {
            $props = $materials[$material]

            switch ($action) {
                "hammer_strike" {
                    if ($props.fragility -gt 0.7) {
                        $consequences += @{
                            type = "shatter"
                            description = "Material shatters on impact"
                            severity = "high"
                        }
                        $confidence = 0.95
                    }
                    elseif ($props.solidity -gt 0.7) {
                        $consequences += @{
                            type = "dent"
                            description = "Material dents but doesn't break"
                            severity = "low"
                        }
                        $confidence = 0.8
                    }
                    else {
                        $consequences += @{
                            type = "crack"
                            description = "Material cracks or splits"
                            severity = "medium"
                        }
                        $confidence = 0.7
                    }
                }

                "drop" {
                    if ($props.fragility -gt 0.6) {
                        $consequences += @{
                            type = "break_on_impact"
                            description = "Material breaks when dropped"
                            severity = "high"
                        }
                        $confidence = 0.85
                    }
                    else {
                        $consequences += @{
                            type = "survive_drop"
                            description = "Material survives drop with minor damage"
                            severity = "low"
                        }
                        $confidence = 0.7
                    }
                }
            }
        }
    }

    # Computational counterfactuals
    if ($hypothesis.ContainsKey("api_call_timeout") -and $hypothesis.ContainsKey("has_retry_logic")) {
        if ($hypothesis.has_retry_logic -eq $false) {
            $consequences += @{
                type = "user_error"
                description = "User sees error message, task fails"
                severity = "high"
            }
            $consequences += @{
                type = "user_frustration"
                description = "User frustration increases"
                severity = "medium"
            }
            $confidence = 0.9
        }
        else {
            $consequences += @{
                type = "automatic_recovery"
                description = "Retry logic handles timeout, user unaffected"
                severity = "low"
            }
            $confidence = 0.85
        }
    }

    # Log simulation
    Log-SimulationResult -type "counterfactual" -input $hypothesis `
        -output @{ consequences = $consequences } -confidence $confidence

    # Display results
    Write-Host "Consequences (confidence: $($confidence * 100)%):" -ForegroundColor Green
    foreach ($cons in $consequences) {
        Write-Host "  [$($cons.severity.ToUpper())] $($cons.type): $($cons.description)" -ForegroundColor $(
            switch ($cons.severity) {
                "high" { "Red" }
                "medium" { "Yellow" }
                "low" { "Cyan" }
                default { "White" }
            }
        )
    }

    return @{
        consequences = $consequences
        confidence = $confidence
    }
}

# ANALOGICAL SIMULATION: Find similar past episodes
function Invoke-AnalogicalSimulation {
    param([hashtable]$latentState)

    Write-Host "`n[ANALOGICAL SIMULATION] Searching past episodes`n" -ForegroundColor Cyan

    # Load episodic memory
    $memory = Load-EpisodicMemory

    if ($memory.episodes.Count -eq 0) {
        Write-Host "No episodes in memory yet." -ForegroundColor Yellow
        return @{ matches = @(); confidence = 0.0 }
    }

    Write-Host "Current latent state:" -ForegroundColor Yellow
    foreach ($key in $latentState.Keys) {
        Write-Host "  $key = $($latentState[$key])" -ForegroundColor White
    }
    Write-Host ""

    # Calculate similarity scores
    $matches = @()
    foreach ($episode in $memory.episodes) {
        $episodeState = $episode.latent_state
        $score = 0.0
        $matchCount = 0

        foreach ($key in $latentState.Keys) {
            if ($episodeState.PSObject.Properties.Name -contains $key) {
                if ($episodeState.$key -eq $latentState[$key]) {
                    $score += 1.0
                    $matchCount += 1
                }
                else {
                    # Partial match for similar values
                    $score += 0.3
                }
            }
        }

        $similarity = $score / $latentState.Keys.Count

        if ($similarity -gt 0.3) {
            $matches += @{
                episode_id = $episode.episode_id
                similarity = $similarity
                outcome = $episode.outcome
                action_taken = $episode.action_taken
                learned_pattern = $episode.learned_pattern
                matched_features = $matchCount
            }
        }
    }

    # Sort by similarity
    $matches = $matches | Sort-Object -Property similarity -Descending | Select-Object -First 5

    # Display results
    Write-Host "Found $($matches.Count) similar episodes:`n" -ForegroundColor Green
    foreach ($match in $matches) {
        Write-Host "  Episode: $($match.episode_id) (similarity: $([math]::Round($match.similarity * 100))%)" -ForegroundColor Cyan
        Write-Host "    Action taken: $($match.action_taken)" -ForegroundColor White
        Write-Host "    Outcome: $($match.outcome)" -ForegroundColor White
        if ($match.learned_pattern) {
            Write-Host "    Pattern: $($match.learned_pattern)" -ForegroundColor Yellow
        }
        Write-Host ""
    }

    # Log simulation
    Log-SimulationResult -type "analogical" -input $latentState `
        -output @{ matches = $matches } -confidence $(if ($matches.Count -gt 0) { $matches[0].similarity } else { 0.0 })

    return @{
        matches = $matches
        confidence = $(if ($matches.Count -gt 0) { $matches[0].similarity } else { 0.0 })
    }
}

# Get statistics
function Get-Stats {
    if (-not (Test-Path $simulationResultsPath)) {
        Write-Host "No simulations run yet." -ForegroundColor Yellow
        return @{}
    }

    $simulations = Get-Content $simulationResultsPath | ForEach-Object { $_ | ConvertFrom-Json }

    $byType = @{}
    foreach ($sim in $simulations) {
        $type = $sim.simulation_type
        if (-not $byType.ContainsKey($type)) {
            $byType[$type] = 0
        }
        $byType[$type] += 1
    }

    $avgConfidence = ($simulations | Measure-Object -Property confidence -Average).Average

    Write-Host "`n=== Counterfactual Simulation Stats ===" -ForegroundColor Cyan
    Write-Host "Total Simulations: $($simulations.Count)"
    Write-Host "Average Confidence: $([math]::Round($avgConfidence * 100, 1))%"
    Write-Host "`nBy Type:" -ForegroundColor Yellow
    $byType.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value)"
    }
    Write-Host ""

    return @{
        total_simulations = $simulations.Count
        by_type = $byType
        average_confidence = $avgConfidence
    }
}

# Main execution
switch ($SimulationType) {
    "Forward" {
        if (-not $Action -or -not $Target) {
            Write-Error "Forward simulation requires -Action and -Target"
            exit 1
        }

        $result = Invoke-ForwardSimulation -action $Action -target $Target
        $result | ConvertTo-Json -Depth 5
    }

    "Backward" {
        if (-not $Error) {
            Write-Error "Backward simulation requires -Error"
            exit 1
        }

        $result = Invoke-BackwardSimulation -error $Error
        $result | ConvertTo-Json -Depth 5
    }

    "Counterfactual" {
        if (-not $Hypothesis) {
            Write-Error "Counterfactual simulation requires -Hypothesis"
            exit 1
        }

        $result = Invoke-CounterfactualSimulation -hypothesis $Hypothesis
        $result | ConvertTo-Json -Depth 5
    }

    "Analogical" {
        if (-not $LatentState) {
            Write-Error "Analogical simulation requires -LatentState"
            exit 1
        }

        $result = Invoke-AnalicalSimulation -latentState $LatentState
        $result | ConvertTo-Json -Depth 5
    }

    "Stats" {
        Get-Stats
    }
}
