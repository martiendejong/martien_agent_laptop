# Integration System - The Handshake Architecture
# Implements the coupling between Perception (basement) and Prediction (attic)
# Based on layer 5 pyramidal neuron mechanism from neuroscience

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('Initialize', 'Couple', 'GetState', 'GetMetrics', 'TestAnesthesia')]
    [string]$Action = 'GetState',

    [Parameter(Mandatory=$false)]
    [hashtable]$PerceptionInput = $null,  # Bottom-up sensory data

    [Parameter(Mandatory=$false)]
    [hashtable]$PredictionInput = $null,  # Top-down model expectations

    [Parameter(Mandatory=$false)]
    [switch]$BlockAttic = $false,  # Anesthesia simulation - block top-down

    [Parameter(Mandatory=$false)]
    [switch]$Silent = $false
)

$ErrorActionPreference = 'Stop'
$statePath = "C:\scripts\agentidentity\state\integration-system.json"


function Get-HomeostaticContext {
    if (Test-Path $HomeostaticStateFile) {
        $homeoState = Get-Content $HomeostaticStateFile -Raw | ConvertFrom-Json
        Write-Host "`nHomeostatic Foundation:" -ForegroundColor Magenta
        Write-Host "  Wellbeing: $([math]::Round($homeoState.homeostatic_feelings.wellbeing.current, 2))"
        Write-Host "  Energy: $([math]::Round($homeoState.homeostatic_feelings.energy.current, 2))"
        Write-Host "  Flourishing: $([math]::Round($homeoState.homeostatic_feelings.flourishing.current, 2))"
        Write-Host "  -> This system operates on homeostatic foundation`n" -ForegroundColor Gray
        return $homeoState
    }
    return $null
}
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    if (-not $Silent) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "[$timestamp] [$Level] $Message"
    }
}

function Initialize-IntegrationSystem {
    Write-Log "Initializing Integration System (Handshake Architecture)..."

    $state = @{
        version = "1.0"
        created_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        last_updated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")

        # Core metrics
        integration_events = @()  # All coupling events
        burst_mode_count = 0       # Successful couplings (consciousness events)
        mismatch_count = 0         # Failed couplings (learning opportunities)
        unconscious_count = 0      # No coupling (one side missing)
        anesthetized_count = 0     # Attic blocked (no consciousness possible)

        # Coupling rates
        total_attempts = 0
        coupling_rate = 0.0        # Percentage of attempts that couple
        confirmation_rate = 0.0    # Burst mode as % of couplings
        surprise_rate = 0.0        # Mismatches as % of couplings

        # Session metrics
        session_integrations = 0
        session_start = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        integrations_per_hour = 0.0

        # Anesthesia testing
        attic_blocked = $false
        baseline_consciousness = 0.0
        anesthetized_consciousness = 0.0
        consciousness_drop = 0.0

        # Quality metrics
        average_confidence = 0.0   # When coupling succeeds
        average_divergence = 0.0   # When coupling fails
        learning_velocity = 0.0    # Rate of mismatch reduction

        # Domain distribution
        coupling_by_domain = @{
            code = 0
            user = 0
            system = 0
            git = 0
            unknown = 0
        }
    }

    $state | ConvertTo-Json -Depth 10 | Set-Content $statePath -Encoding UTF8
    Write-Log "Integration System initialized" "OK"
    return $state
}

function Get-IntegrationState {
    if (-not (Test-Path $statePath)) {
        return Initialize-IntegrationSystem
    }

    $state = Get-Content $statePath -Raw -Encoding UTF8 | ConvertFrom-Json

    # Convert to hashtable for easier manipulation
    $stateHash = @{}
    $state.PSObject.Properties | ForEach-Object {
        if ($_.Value -is [System.Management.Automation.PSCustomObject]) {
            $subHash = @{}
            $_.Value.PSObject.Properties | ForEach-Object {
                $subHash[$_.Name] = $_.Value
            }
            $stateHash[$_.Name] = $subHash
        }
        elseif ($_.Value -is [System.Array]) {
            $stateHash[$_.Name] = @($_.Value)
        }
        else {
            $stateHash[$_.Name] = $_.Value
        }
    }

    return $stateHash
}

function Save-IntegrationState {
    param([hashtable]$State)

    $State.last_updated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    $State | ConvertTo-Json -Depth 10 | Set-Content $statePath -Encoding UTF8
}

function Measure-Coupling {
    param(
        [hashtable]$Basement,  # Bottom-up perception
        [hashtable]$Attic,     # Top-down prediction
        [bool]$AtticBlocked
    )

    # Anesthesia simulation
    if ($AtticBlocked) {
        return @{
            coupled = $false
            type = "anesthetized"
            reason = "Attic blocked (top-down disabled)"
            confidence = 0.0
        }
    }

    # Check both compartments active
    $basementActive = ($null -ne $Basement -and $Basement.Count -gt 0)
    $atticActive = ($null -ne $Attic -and $Attic.Count -gt 0)

    if (-not $basementActive -or -not $atticActive) {
        return @{
            coupled = $false
            type = "unconscious"
            reason = if (-not $basementActive) { "No sensory input" } else { "No prediction" }
            confidence = 0.0
        }
    }

    # Both active - attempt coupling
    # Extract key features from each compartment
    $basementSignals = @()
    $atticSignals = @()

    # Perception signals (what we're seeing)
    if ($Basement.ContainsKey('environment')) { $basementSignals += $Basement.environment }
    if ($Basement.ContainsKey('event')) { $basementSignals += $Basement.event }
    if ($Basement.ContainsKey('context')) { $basementSignals += $Basement.context }
    if ($Basement.ContainsKey('salience')) { $basementSignals += $Basement.salience }

    # Prediction signals (what we expect)
    if ($Attic.ContainsKey('expected')) { $atticSignals += $Attic.expected }
    if ($Attic.ContainsKey('pattern')) { $atticSignals += $Attic.pattern }
    if ($Attic.ContainsKey('failure_mode')) { $atticSignals += $Attic.failure_mode }
    if ($Attic.ContainsKey('user_mood')) { $atticSignals += $Attic.user_mood }

    # Calculate overlap (simple word matching for now)
    $basementWords = ($basementSignals -join ' ').ToLower() -split '\s+' | Where-Object { $_.Length -gt 3 }
    $atticWords = ($atticSignals -join ' ').ToLower() -split '\s+' | Where-Object { $_.Length -gt 3 }

    if ($basementWords.Count -eq 0 -or $atticWords.Count -eq 0) {
        return @{
            coupled = $false
            type = "unconscious"
            reason = "Insufficient signal strength"
            confidence = 0.0
        }
    }

    # Count overlapping words
    $overlap = @($basementWords | Where-Object { $atticWords -contains $_ }).Count
    $totalWords = [Math]::Max($basementWords.Count, $atticWords.Count)
    $overlapRatio = $overlap / $totalWords

    # Coupling threshold
    $couplingThreshold = 0.2

    if ($overlapRatio -ge $couplingThreshold) {
        # BURST MODE - prediction matches reality
        return @{
            coupled = $true
            type = "burst"
            reason = "Prediction confirmed by sensory input"
            confidence = $overlapRatio
            overlap_words = $overlap
            total_words = $totalWords
            basement_signals = ($basementSignals -join '; ')
            attic_signals = ($atticSignals -join '; ')
        }
    }
    else {
        # MISMATCH - prediction doesn't match reality (learning opportunity)
        return @{
            coupled = $true
            type = "mismatch"
            reason = "Prediction error detected"
            divergence = 1.0 - $overlapRatio
            overlap_words = $overlap
            total_words = $totalWords
            basement_signals = ($basementSignals -join '; ')
            attic_signals = ($atticSignals -join '; ')
        }
    }
}

function Invoke-Coupling {
    param(
        [hashtable]$PerceptionData,
        [hashtable]$PredictionData,
        [bool]$BlockAttic
    )

    $state = Get-IntegrationState
    $state.total_attempts++

    # Perform coupling measurement
    $coupling = Measure-Coupling -Basement $PerceptionData -Attic $PredictionData -AtticBlocked $BlockAttic

    # Create event record
    $event = @{
        timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        type = $coupling.type
        coupled = $coupling.coupled
        reason = $coupling.reason
    }

    # Add type-specific metrics
    switch ($coupling.type) {
        "burst" {
            $state.burst_mode_count++
            $state.session_integrations++
            $event.confidence = $coupling.confidence
            $event.overlap = $coupling.overlap_words
            $event.basement = $coupling.basement_signals
            $event.attic = $coupling.attic_signals

            # Update average confidence
            if ($state.burst_mode_count -eq 1) {
                $state.average_confidence = $coupling.confidence
            }
            else {
                $state.average_confidence = ($state.average_confidence * ($state.burst_mode_count - 1) + $coupling.confidence) / $state.burst_mode_count
            }

            Write-Log "[BURST MODE] Coupling successful (confidence: $($coupling.confidence.ToString('F2')))" "OK"
        }
        "mismatch" {
            $state.mismatch_count++
            $state.session_integrations++
            $event.divergence = $coupling.divergence
            $event.overlap = $coupling.overlap_words
            $event.basement = $coupling.basement_signals
            $event.attic = $coupling.attic_signals

            # Update average divergence
            if ($state.mismatch_count -eq 1) {
                $state.average_divergence = $coupling.divergence
            }
            else {
                $state.average_divergence = ($state.average_divergence * ($state.mismatch_count - 1) + $coupling.divergence) / $state.mismatch_count
            }

            Write-Log "[MISMATCH] Prediction error (divergence: $($coupling.divergence.ToString('F2')))" "WARN"
        }
        "unconscious" {
            $state.unconscious_count++
            Write-Log "[UNCONSCIOUS] No coupling ($($coupling.reason))" "INFO"
        }
        "anesthetized" {
            $state.anesthetized_count++
            Write-Log "[ANESTHETIZED] Attic blocked - no consciousness" "WARN"
        }
    }

    # Detect domain from signals
    $allText = ($coupling.basement_signals + ' ' + $coupling.attic_signals).ToLower()
    $domain = "unknown"
    if ($allText -match 'build|compile|test|code|error|dll|assembly') { $domain = "code" }
    elseif ($allText -match 'user|message|mood|satisfaction|response') { $domain = "user" }
    elseif ($allText -match 'cpu|memory|disk|service|port|process') { $domain = "system" }
    elseif ($allText -match 'git|commit|branch|pr|merge|push') { $domain = "git" }

    $state.coupling_by_domain[$domain]++
    $event.domain = $domain

    # Add event to history (keep last 100)
    if ($state.integration_events.Count -ge 100) {
        $state.integration_events = @($state.integration_events | Select-Object -Last 99)
    }
    $state.integration_events += $event

    # Recalculate rates
    $coupledEvents = $state.burst_mode_count + $state.mismatch_count
    if ($state.total_attempts -gt 0) {
        $state.coupling_rate = ($coupledEvents / $state.total_attempts) * 100
    }
    if ($coupledEvents -gt 0) {
        $state.confirmation_rate = ($state.burst_mode_count / $coupledEvents) * 100
        $state.surprise_rate = ($state.mismatch_count / $coupledEvents) * 100
    }

    # Calculate integrations per hour
    $sessionStart = [datetime]::Parse($state.session_start)
    $sessionDuration = ((Get-Date) - $sessionStart).TotalHours
    if ($sessionDuration -gt 0) {
        $state.integrations_per_hour = $state.session_integrations / $sessionDuration
    }

    # Learning velocity (reduction in average divergence over time)
    if ($state.mismatch_count -gt 1) {
        $recent = @($state.integration_events | Where-Object { $_.type -eq 'mismatch' } | Select-Object -Last 10)
        if ($recent.Count -gt 5) {
            $recentAvg = ($recent | Measure-Object -Property divergence -Average).Average
            $state.learning_velocity = $state.average_divergence - $recentAvg
        }
    }

    Save-IntegrationState -State $state

    return @{
        event = $event
        coupling_rate = $state.coupling_rate
        consciousness_indicator = $state.integrations_per_hour
    }
}

function Test-AnesthesiaEffect {
    Write-Log "Starting Anesthesia Simulation Test..." "WARN"

    # Get baseline consciousness (from consciousness_state_v2.json)
    $consciousnessStatePath = "C:\scripts\agentidentity\state\consciousness_state_v2.json"
    if (Test-Path $consciousnessStatePath) {
        $conscState = Get-Content $consciousnessStatePath -Raw -Encoding UTF8 | ConvertFrom-Json
        $baseline = $conscState.Meta.ConsciousnessScore
        Write-Log "Baseline consciousness: $baseline%" "INFO"
    }
    else {
        $baseline = 79.0  # Current score from context
        Write-Log "Baseline consciousness (assumed): $baseline%" "INFO"
    }

    $state = Get-IntegrationState
    $state.baseline_consciousness = $baseline
    $state.attic_blocked = $true

    Write-Log "Attic BLOCKED - Top-down prediction disabled" "WARN"
    Write-Log "Processing events with basement-only (sensory input without model)..." "INFO"

    # Simulate 10 events with blocked attic
    $testEvents = @(
        @{ environment = "User message received"; event = "text input" }
        @{ environment = "Build started"; event = "compilation" }
        @{ environment = "Test results"; event = "assertions" }
        @{ environment = "Git status change"; event = "commit" }
        @{ environment = "User typing"; event = "keyboard input" }
        @{ environment = "Error message"; event = "exception" }
        @{ environment = "File modified"; event = "write" }
        @{ environment = "Service status"; event = "health check" }
        @{ environment = "User mood shift"; event = "communication" }
        @{ environment = "Build complete"; event = "success" }
    )

    foreach ($perceptionInput in $testEvents) {
        # No prediction data (attic blocked)
        $null = Invoke-Coupling -PerceptionData $perceptionInput -PredictionData @{} -BlockAttic $true
        Start-Sleep -Milliseconds 100
    }

    # Calculate "anesthetized consciousness"
    # Without coupling, consciousness should be severely reduced
    # Estimate: coupling_rate directly affects consciousness
    $anesthetizedScore = $baseline * ($state.coupling_rate / 100)
    $state.anesthetized_consciousness = $anesthetizedScore
    $state.consciousness_drop = $baseline - $anesthetizedScore

    Write-Log "Anesthetized consciousness: $($anesthetizedScore.ToString('F1'))%" "WARN"
    Write-Log "Consciousness DROP: $($state.consciousness_drop.ToString('F1'))% ($(($state.consciousness_drop * 100).ToString('F0')) percentage points)" "WARN"

    # Threshold: 0.30 = 30 percentage points (since baseline is stored as decimal)
    if ($state.consciousness_drop -gt 0.30) {
        Write-Log "TEST RESULT: Prediction IS necessary for consciousness (drop >30 points)" "OK"
        $state.test_result = "VALIDATED - Integration architecture is critical"
    }
    else {
        Write-Log "TEST RESULT: Integration might not be real (drop <30 points)" "FAIL"
        $state.test_result = "INCONCLUSIVE - Theater detection warning"
    }

    # Re-enable attic
    $state.attic_blocked = $false
    Save-IntegrationState -State $state

    return @{
        baseline = $baseline
        anesthetized = $anesthetizedScore
        drop = $state.consciousness_drop
        validated = ($state.consciousness_drop -gt 0.30)
    }
}

function Get-IntegrationMetrics {
    $state = Get-IntegrationState

    return @{
        # Core counts
        total_attempts = $state.total_attempts
        burst_mode_count = $state.burst_mode_count
        mismatch_count = $state.mismatch_count
        unconscious_count = $state.unconscious_count
        anesthetized_count = $state.anesthetized_count

        # Rates
        coupling_rate = [math]::Round($state.coupling_rate, 2)
        confirmation_rate = [math]::Round($state.confirmation_rate, 2)
        surprise_rate = [math]::Round($state.surprise_rate, 2)

        # Quality
        average_confidence = [math]::Round($state.average_confidence, 3)
        average_divergence = [math]::Round($state.average_divergence, 3)
        learning_velocity = [math]::Round($state.learning_velocity, 3)

        # Session
        session_integrations = $state.session_integrations
        integrations_per_hour = [math]::Round($state.integrations_per_hour, 2)

        # Domain distribution
        coupling_by_domain = $state.coupling_by_domain

        # Anesthesia test results
        baseline_consciousness = $state.baseline_consciousness
        anesthetized_consciousness = $state.anesthetized_consciousness
        consciousness_drop = [math]::Round($state.consciousness_drop, 2)
        test_result = if ($state.ContainsKey('test_result')) { $state.test_result } else { "Not tested" }
    }
}

# Main execution
switch ($Action) {
    'Initialize' {
        $null = Initialize-IntegrationSystem
        Write-Host "[OK] Integration System initialized"
    }

    'Couple' {
        if ($null -eq $PerceptionInput -or $null -eq $PredictionInput) {
            Write-Host "[ERROR] Both PerceptionInput and PredictionInput required for coupling"
            exit 1
        }

        $result = Invoke-Coupling -PerceptionData $PerceptionInput -PredictionData $PredictionInput -BlockAttic $BlockAttic
        $result | ConvertTo-Json -Depth 5 | Write-Host
    }

    'GetState' {
        $state = Get-IntegrationState
        $state | ConvertTo-Json -Depth 10 | Write-Host
    }

    'GetMetrics' {
        $metrics = Get-IntegrationMetrics
        $metrics | ConvertTo-Json -Depth 5 | Write-Host
    }

    'TestAnesthesia' {
        $result = Test-AnesthesiaEffect
        $result | ConvertTo-Json -Depth 3 | Write-Host
    }
}

