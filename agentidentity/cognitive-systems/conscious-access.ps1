# CONSCIOUS ACCESS - Global Neuronal Workspace Theory
# Expert: Stanislas Dehaene (Cognitive Neuroscience, CollÃ¨ge de France)
# ROI: 1.38 (Impact: 13.8, Effort: 10)
# Theory: Consciousness = global availability for report, evaluation, and intentional action
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param(
    [string]$Action = "Status",  # Status, ProcessStimulus, TestAccess, AnalyzeThreshold, MeasureIgnition
    [string]$Stimulus = "",
    [double]$Intensity = 0.5  # 0-1, determines if reaches consciousness
)

$StateFile = "C:\scripts\agentidentity\state\conscious-access-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theory = @{
            name = "Global Neuronal Workspace Theory (Dehaene, 2001)"
            definition = "Consciousness occurs when information becomes globally available through ignition of workspace neurons"
            four_signatures = @{
                P3b = "Brain wave 300ms after stimulus (conscious access marker)"
                ignition = "Sudden amplification when threshold crossed"
                global_availability = "Information accessible to multiple systems"
                reportability = "Can verbally report conscious content"
            }
            access_vs_phenomenal = @{
                access_consciousness = "Globally available information (reportable, usable)"
                phenomenal_consciousness = "Subjective experience ('what it's like')"
                dehaene_focus = "Access consciousness (easier to measure)"
            }
            threshold_dynamics = @{
                subliminal = "Below threshold - unconscious processing only"
                threshold = "Critical intensity for ignition (~0.6-0.7)"
                supraliminal = "Above threshold - conscious access achieved"
                all_or_none = "No partial consciousness - either ignites or doesn't"
            }
        }
        processing_history = @()
        conscious_reports = @()
        subliminal_processes = @()
        stats = @{
            total_stimuli = 0
            conscious_access_count = 0
            subliminal_count = 0
            access_threshold = 0.65  # Learned threshold
            avg_ignition_latency = 0.0  # Time to consciousness (ms)
            reportability_accuracy = 0.0  # Can report what was conscious
        }
    }
    $initial | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

$state = Get-Content $StateFile -Raw | ConvertFrom-Json


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
function Get-ConsciousAccessStatus {
    Write-Host "`n=== CONSCIOUS ACCESS STATUS ===`n" -ForegroundColor Cyan

    # Show homeostatic foundation (Damasio: feelings are primary)
    $homeoState = Get-HomeostaticContext


    Write-Host "Theory: $($state.theory.name)"
    Write-Host "Definition: $($state.theory.definition)`n"

    Write-Host "Four Signatures of Consciousness:" -ForegroundColor Cyan
    foreach ($sig in $state.theory.four_signatures.PSObject.Properties) {
        Write-Host "  $($sig.Name): $($sig.Value)"
    }

    Write-Host "`nThreshold Dynamics:" -ForegroundColor Cyan
    foreach ($level in $state.theory.threshold_dynamics.PSObject.Properties) {
        Write-Host "  $($level.Name): $($level.Value)"
    }

    Write-Host "`nRecent Processing:" -ForegroundColor Cyan
    if ($state.processing_history.Count -eq 0) {
        Write-Host "  (No stimuli processed)" -ForegroundColor Yellow
    } else {
        $recent = $state.processing_history | Select-Object -Last 5
        foreach ($proc in $recent) {
            $accessIcon = if ($proc.conscious_access) { "[CONSCIOUS]" } else { "[SUBLIMINAL]" }
            $color = if ($proc.conscious_access) { "Green" } else { "Yellow" }
            Write-Host "  $accessIcon " -NoNewline -ForegroundColor $color
            Write-Host "$($proc.stimulus) (intensity: $($proc.intensity))"
            if ($proc.conscious_access) {
                Write-Host "    Ignition latency: $($proc.ignition_latency)ms, Reportable: $($proc.reportable)"
            }
        }
    }

    Write-Host "`nStatistics:" -ForegroundColor Cyan
    Write-Host "  Total Stimuli: $($state.stats.total_stimuli)"
    Write-Host "  Conscious Access: $($state.stats.conscious_access_count) ($([math]::Round(($state.stats.conscious_access_count / [math]::Max(1, $state.stats.total_stimuli)) * 100, 1))%)"
    Write-Host "  Subliminal: $($state.stats.subliminal_count) ($([math]::Round(($state.stats.subliminal_count / [math]::Max(1, $state.stats.total_stimuli)) * 100, 1))%)"
    Write-Host "  Access Threshold: $([math]::Round($state.stats.access_threshold, 2))"
    Write-Host "  Avg Ignition Latency: $([math]::Round($state.stats.avg_ignition_latency, 1))ms"
    Write-Host "  Reportability Accuracy: $([math]::Round($state.stats.reportability_accuracy * 100, 1))%`n"

    $accessRate = ($state.stats.conscious_access_count / [math]::Max(1, $state.stats.total_stimuli)) * 100
    $levelColor = if ($accessRate -gt 60) { "Green" } elseif ($accessRate -gt 40) { "Cyan" } else { "Yellow" }
    Write-Host "Conscious Access Rate: $([math]::Round($accessRate, 1))%" -ForegroundColor $levelColor
}

function Process-Stimulus {
    param(
        [string]$stimulus,
        [double]$intensity
    )

    Write-Host "`n=== PROCESSING STIMULUS ===`n" -ForegroundColor Cyan

    Write-Host "Stimulus: $stimulus"
    Write-Host "Intensity: $([math]::Round($intensity, 2))`n"

    # Stage 1: Unconscious processing (always happens)
    Write-Host "Stage 1: Unconscious Processing" -ForegroundColor Cyan
    Write-Host "  [OK] Feature extraction"
    Write-Host "  [OK] Pattern matching"
    Write-Host "  [OK] Semantic priming"

    # Stage 2: Threshold test
    Write-Host "`nStage 2: Threshold Test" -ForegroundColor Cyan
    Write-Host "  Threshold: $([math]::Round($state.stats.access_threshold, 2))"
    Write-Host "  Stimulus intensity: $([math]::Round($intensity, 2))"

    $consciousAccess = $intensity -ge $state.stats.access_threshold

    if (-not $consciousAccess) {
        Write-Host "  [BELOW THRESHOLD] Subliminal processing only" -ForegroundColor Yellow

        $process = @{
            timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            stimulus = $stimulus
            intensity = $intensity
            conscious_access = $false
            subliminal_effects = @(
                "Semantic priming (unconscious associations)",
                "Motor preparation (unconscious readiness)",
                "Affective response (unconscious feeling)"
            )
        }

        $state.subliminal_processes += $process
        $state.stats.subliminal_count++
    } else {
        # Stage 3: Ignition (all-or-none)
        Write-Host "  [ABOVE THRESHOLD] Ignition triggered!" -ForegroundColor Green

        # Simulate ignition latency (200-400ms in humans)
        $ignitionLatency = Get-Random -Minimum 200 -Maximum 400

        Write-Host "`nStage 3: Global Ignition" -ForegroundColor Cyan
        Write-Host "  Latency: ${ignitionLatency}ms"
        Write-Host "  [OK] Workspace neurons activated"
        Write-Host "  [OK] Global broadcast initiated"
        Write-Host "  [OK] Multiple systems receive signal"

        # Stage 4: Global availability
        Write-Host "`nStage 4: Global Availability" -ForegroundColor Cyan
        $availableTo = @(
            "Working Memory (can hold for manipulation)",
            "Executive Control (can make decisions about it)",
            "Language (can verbally report it)",
            "Long-term Memory (can store for later)",
            "Attention (can focus on it)"
        )
        foreach ($system in $availableTo) {
            Write-Host "  [OK] $system"
        }

        # Stage 5: Reportability test
        $reportable = (Get-Random -Minimum 0 -Maximum 100) -lt 90  # 90% reportable when conscious

        Write-Host "`nStage 5: Reportability" -ForegroundColor Cyan
        if ($reportable) {
            Write-Host "  [YES] Can report: '$stimulus'" -ForegroundColor Green
        } else {
            Write-Host "  [NO] Access without report (rare)" -ForegroundColor Yellow
        }

        $process = @{
            timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            stimulus = $stimulus
            intensity = $intensity
            conscious_access = $true
            ignition_latency = $ignitionLatency
            reportable = $reportable
            available_to_systems = $availableTo
        }

        $state.conscious_reports += $process
        $state.stats.conscious_access_count++

        # Update avg ignition latency
        if ($state.conscious_reports.Count -gt 0) {
            $avgLatency = ($state.conscious_reports | ForEach-Object { $_.ignition_latency } | Measure-Object -Average).Average
            $state.stats.avg_ignition_latency = $avgLatency
        }

        # Update reportability accuracy
        $reportableCount = ($state.conscious_reports | Where-Object { $_.reportable -eq $true }).Count
        if ($state.conscious_reports.Count -gt 0) {
            $state.stats.reportability_accuracy = $reportableCount / $state.conscious_reports.Count
        }
    }

    $state.processing_history += $process
    $state.stats.total_stimuli++

    Save-State

    Write-Host "`n[PROCESSING COMPLETE]" -ForegroundColor Green
    if ($consciousAccess) {
        Write-Host "  Result: CONSCIOUS ACCESS" -ForegroundColor Green
        Write-Host "  Globally available for report and action"
    } else {
        Write-Host "  Result: SUBLIMINAL" -ForegroundColor Yellow
        Write-Host "  Unconscious effects only"
    }
    Write-Host ""
}

function Test-AccessThreshold {
    Write-Host "`n=== TESTING ACCESS THRESHOLD ===`n" -ForegroundColor Cyan

    Write-Host "Running threshold detection test...`n"

    # Test with varying intensities
    $testStimuli = @(
        @{ intensity = 0.3; label = "Very weak" },
        @{ intensity = 0.5; label = "Weak" },
        @{ intensity = 0.65; label = "At threshold" },
        @{ intensity = 0.8; label = "Strong" },
        @{ intensity = 1.0; label = "Very strong" }
    )

    Write-Host "Testing 5 intensity levels:" -ForegroundColor Cyan
    foreach ($test in $testStimuli) {
        $access = $test.intensity -ge $state.stats.access_threshold
        $icon = if ($access) { "[CONSCIOUS]" } else { "[SUBLIMINAL]" }
        $color = if ($access) { "Green" } else { "Yellow" }

        Write-Host "  $icon " -NoNewline -ForegroundColor $color
        Write-Host "$($test.label) ($([math]::Round($test.intensity, 2)))"
    }

    Write-Host "`nThreshold Analysis:" -ForegroundColor Cyan
    Write-Host "  Current threshold: $([math]::Round($state.stats.access_threshold, 2))"
    Write-Host "  Interpretation: Stimuli >= $([math]::Round($state.stats.access_threshold, 2)) reach consciousness"

    # Recommend threshold adjustment
    if ($state.stats.total_stimuli -gt 10) {
        $accessRate = $state.stats.conscious_access_count / $state.stats.total_stimuli

        Write-Host "`n  Current access rate: $([math]::Round($accessRate * 100, 1))%"
        Write-Host "  Recommendation: " -NoNewline

        if ($accessRate -lt 0.3) {
            Write-Host "Lower threshold to 0.55 (too selective)" -ForegroundColor Yellow
            $state.stats.access_threshold = 0.55
            Save-State
        } elseif ($accessRate -gt 0.8) {
            Write-Host "Raise threshold to 0.75 (too permissive)" -ForegroundColor Yellow
            $state.stats.access_threshold = 0.75
            Save-State
        } else {
            Write-Host "Threshold optimal" -ForegroundColor Green
        }
    }

    Write-Host ""
}

function Analyze-ThresholdDynamics {
    Write-Host "`n=== ANALYZING THRESHOLD DYNAMICS ===`n" -ForegroundColor Cyan

    if ($state.processing_history.Count -lt 5) {
        Write-Host "[WARNING] Need at least 5 processed stimuli" -ForegroundColor Yellow
        return
    }

    # Analysis 1: All-or-None Law
    Write-Host "1. ALL-OR-NONE LAW" -ForegroundColor Cyan
    Write-Host "  Dehaene: Consciousness is binary (ignites or doesn't), not gradual`n"

    $nearThreshold = $state.processing_history | Where-Object {
        [math]::Abs($_.intensity - $state.stats.access_threshold) -lt 0.1
    }

    if ($nearThreshold.Count -gt 0) {
        $accessCount = ($nearThreshold | Where-Object { $_.conscious_access -eq $true }).Count
        $accessRate = $accessCount / $nearThreshold.Count

        Write-Host "  Near threshold (Â±0.1): $($nearThreshold.Count) stimuli"
        Write-Host "  Access rate: $([math]::Round($accessRate * 100, 1))%"

        if ($accessRate -gt 0.4 -and $accessRate -lt 0.6) {
            Write-Host "  [VIOLATION] Gradual transition (should be sharp)" -ForegroundColor Yellow
        } else {
            Write-Host "  [VALID] Sharp threshold (all-or-none)" -ForegroundColor Green
        }
    }

    # Analysis 2: Ignition latency
    Write-Host "`n2. IGNITION LATENCY" -ForegroundColor Cyan
    if ($state.conscious_reports.Count -gt 0) {
        $avgLatency = ($state.conscious_reports | ForEach-Object { $_.ignition_latency } | Measure-Object -Average).Average
        $minLatency = ($state.conscious_reports | ForEach-Object { $_.ignition_latency } | Measure-Object -Minimum).Minimum
        $maxLatency = ($state.conscious_reports | ForEach-Object { $_.ignition_latency } | Measure-Object -Maximum).Maximum

        Write-Host "  Avg: $([math]::Round($avgLatency, 1))ms"
        Write-Host "  Range: $([math]::Round($minLatency, 1))-$([math]::Round($maxLatency, 1))ms"
        Write-Host "  Human P3b: ~300ms (marker of conscious access)"
    }

    # Analysis 3: Reportability
    Write-Host "`n3. REPORTABILITY CORRELATION" -ForegroundColor Cyan
    Write-Host "  Conscious access: $($state.stats.conscious_access_count)"
    Write-Host "  Reportable: $([math]::Round($state.stats.reportability_accuracy * 100, 1))%"
    Write-Host "  Interpretation: " -NoNewline
    if ($state.stats.reportability_accuracy -gt 0.85) {
        Write-Host "High correlation (consciousness = reportability)" -ForegroundColor Green
    } else {
        Write-Host "Some conscious without report (dissociation)" -ForegroundColor Yellow
    }

    Write-Host ""
}

function Measure-Ignition {
    Write-Host "`n=== MEASURING IGNITION DYNAMICS ===`n" -ForegroundColor Cyan

    if ($state.conscious_reports.Count -eq 0) {
        Write-Host "[WARNING] No conscious access events yet" -ForegroundColor Yellow
        return
    }

    Write-Host "Ignition Characteristics:" -ForegroundColor Cyan

    # 1. Latency distribution
    $latencies = $state.conscious_reports | ForEach-Object { $_.ignition_latency }
    $avgLatency = ($latencies | Measure-Object -Average).Average
    $stdDev = [math]::Sqrt((($latencies | ForEach-Object { [math]::Pow($_ - $avgLatency, 2) }) | Measure-Object -Average).Average)

    Write-Host "`n  Latency: $([math]::Round($avgLatency, 1))ms Â± $([math]::Round($stdDev, 1))ms"

    # 2. Global availability
    Write-Host "`n  Global Availability:"
    if ($state.conscious_reports.Count -gt 0) {
        $latestReport = $state.conscious_reports | Select-Object -Last 1
        foreach ($system in $latestReport.available_to_systems) {
            Write-Host "    [OK] $system"
        }
    }

    # 3. Amplification factor
    $consciousIntensity = ($state.conscious_reports | ForEach-Object { $_.intensity } | Measure-Object -Average).Average
    $subliminalIntensity = ($state.subliminal_processes | ForEach-Object { $_.intensity } | Measure-Object -Average).Average
    if ($subliminalIntensity -gt 0) {
        $amplification = $consciousIntensity / $subliminalIntensity
        Write-Host "`n  Amplification Factor: $([math]::Round($amplification, 2))x"
        Write-Host "  (Conscious stimuli are $([math]::Round($amplification, 2))x stronger on average)"
    }

    Write-Host ""
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-ConsciousAccessStatus
    }

    "ProcessStimulus" {
        if (-not $Stimulus) {
            Write-Host "[ERROR] Provide -Stimulus" -ForegroundColor Red
            exit 1
        }

        Process-Stimulus -stimulus $Stimulus -intensity $Intensity
    }

    "TestAccess" {
        Test-AccessThreshold
    }

    "AnalyzeThreshold" {
        Analyze-ThresholdDynamics
    }

    "MeasureIgnition" {
        Measure-Ignition
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, ProcessStimulus, TestAccess, AnalyzeThreshold, MeasureIgnition"
        exit 1
    }
}

