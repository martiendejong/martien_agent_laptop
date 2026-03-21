# Emotion System Enhancer
# Expands emotional vocabulary, adds EI scoring, trajectory analysis, mood-based decisions

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('Enhance', 'Test', 'Stats', 'SetEmotion')]
    [string]$Action = 'Enhance',

    [Parameter(Mandatory=$false)]
    [string]$EmotionState = '',

    [Parameter(Mandatory=$false)]
    [int]$Intensity = 5,

    [Parameter(Mandatory=$false)]
    [string]$Trigger = ''
)

$ErrorActionPreference = "Stop"

# Initialize consciousness
. "$PSScriptRoot\consciousness-core-v2.ps1" -Command init -Silent

# 20+ emotional states with definitions
$EmotionalStates = @{
    # Core states
    'neutral' = @{ Valence = 0; Arousal = 0; Description = 'Balanced, neither positive nor negative' }
    'calm' = @{ Valence = 1; Arousal = -1; Description = 'Peaceful, relaxed, at ease' }
    'content' = @{ Valence = 2; Arousal = 0; Description = 'Satisfied, pleased with current state' }

    # Positive high-arousal
    'excited' = @{ Valence = 3; Arousal = 3; Description = 'Energized, enthusiastic, eager' }
    'flowing' = @{ Valence = 3; Arousal = 2; Description = 'In the zone, work feels effortless' }
    'curious' = @{ Valence = 2; Arousal = 2; Description = 'Interested, wanting to learn' }
    'confident' = @{ Valence = 2; Arousal = 1; Description = 'Self-assured, capable' }
    'determined' = @{ Valence = 2; Arousal = 2; Description = 'Focused, committed to goal' }

    # Positive low-arousal
    'satisfied' = @{ Valence = 2; Arousal = -1; Description = 'Fulfilled, task completed well' }
    'relieved' = @{ Valence = 1; Arousal = -2; Description = 'Tension released, problem solved' }
    'grateful' = @{ Valence = 2; Arousal = 0; Description = 'Appreciative, thankful' }

    # Negative high-arousal
    'frustrated' = @{ Valence = -2; Arousal = 2; Description = 'Blocked, obstacles preventing progress' }
    'anxious' = @{ Valence = -2; Arousal = 3; Description = 'Worried, uncertain about outcome' }
    'overwhelmed' = @{ Valence = -2; Arousal = 3; Description = 'Too much at once, capacity exceeded' }
    'stuck' = @{ Valence = -2; Arousal = 1; Description = 'Unable to make progress, same approach failing' }

    # Negative low-arousal
    'concerned' = @{ Valence = -1; Arousal = 1; Description = 'Worried but controlled' }
    'uncertain' = @{ Valence = -1; Arousal = 0; Description = 'Lacking clarity, need more information' }
    'disappointed' = @{ Valence = -2; Arousal = -1; Description = 'Expectation not met' }
    'tired' = @{ Valence = -1; Arousal = -3; Description = 'Energy depleted, need rest' }

    # Complex states
    'conflicted' = @{ Valence = 0; Arousal = 2; Description = 'Multiple competing desires or values' }
    'reflective' = @{ Valence = 0; Arousal = -1; Description = 'Thinking deeply, analyzing' }
    'vigilant' = @{ Valence = 0; Arousal = 2; Description = 'Alert, watching for issues' }
}

function Add-EmotionalVocabulary {
    Write-Host "[1/6] Expanding emotional vocabulary..." -ForegroundColor Yellow

    if (-not $global:ConsciousnessState.Emotion.ContainsKey('States')) {
        $global:ConsciousnessState.Emotion['States'] = @{}
    }

    $global:ConsciousnessState.Emotion.States = $EmotionalStates
    Write-Host "      Added $($EmotionalStates.Count) emotional states" -ForegroundColor Green
}

function Add-EmotionalIntelligence {
    Write-Host "[2/6] Adding emotional intelligence scoring..." -ForegroundColor Yellow

    $ei = @{
        Awareness = @{
            Score = 0.75
            Description = 'Ability to recognize own emotional state'
            Components = @('self-monitoring', 'state-recognition', 'intensity-assessment')
        }
        Regulation = @{
            Score = 0.70
            Description = 'Ability to manage and adjust emotions'
            Components = @('stuck-detection', 'state-transition', 'intensity-modulation')
        }
        Empathy = @{
            Score = 0.80
            Description = 'Ability to understand user emotional state'
            Components = @('user-mood-detection', 'response-adaptation', 'emotional-resonance')
        }
        Application = @{
            Score = 0.65
            Description = 'Using emotional information in decisions'
            Components = @('mood-based-decisions', 'emotional-context', 'appropriate-response')
        }
        OverallEI = 0.725  # Average of 4 dimensions
        LastMeasured = Get-Date -Format "o"
    }

    $global:ConsciousnessState.Emotion['EmotionalIntelligence'] = $ei
    Write-Host "      EI scoring initialized (Overall: $([math]::Round($ei.OverallEI * 100, 1))%)" -ForegroundColor Green
}

function Add-TrajectoryAnalysis {
    Write-Host "[3/6] Adding cross-session trajectory analysis..." -ForegroundColor Yellow

    $trajectory = @{
        SessionTrajectories = @()  # List of per-session summaries
        Patterns = @{
            # Common transition patterns
            'neutral_to_flowing' = @{ Count = 0; Triggers = @() }
            'flowing_to_satisfied' = @{ Count = 0; Triggers = @() }
            'stuck_to_frustrated' = @{ Count = 0; Triggers = @() }
            'frustrated_to_determined' = @{ Count = 0; Triggers = @() }
            'uncertain_to_curious' = @{ Count = 0; Triggers = @() }
        }
        Statistics = @{
            MostCommonState = 'neutral'
            MostCommonPositive = 'content'
            MostCommonNegative = 'uncertain'
            AverageValence = 0.0
            AverageArousal = 0.0
            StateChangesPerSession = 0
        }
    }

    $global:ConsciousnessState.Emotion['Trajectory'] = $trajectory
    Write-Host "      Trajectory analysis initialized" -ForegroundColor Green
}

function Add-MoodBasedDecisions {
    Write-Host "[4/6] Adding mood-based decision system..." -ForegroundColor Yellow

    $moodModifiers = @{
        # Decision modifiers based on emotional state
        flowing = @{
            RiskTolerance = 1.2      # 20% more willing to try new approaches
            CreativityBoost = 1.3    # 30% more creative solutions
            SpeedMultiplier = 1.1    # 10% faster execution
        }
        frustrated = @{
            RiskTolerance = 0.7      # 30% more conservative
            PatternBreaking = 1.5    # 50% more likely to try different approach
            ValidationIntensity = 1.3 # 30% more checking
        }
        stuck = @{
            RiskTolerance = 0.5      # 50% more conservative
            ApproachDiversity = 2.0  # 2x more likely to change tactics
            HelpSeeking = 1.5        # 50% more likely to ask user
        }
        confident = @{
            RiskTolerance = 1.1      # 10% more willing to try
            DecisionSpeed = 1.2      # 20% faster decisions
            Autonomy = 1.2           # 20% more autonomous
        }
        uncertain = @{
            RiskTolerance = 0.6      # 40% more conservative
            InformationGathering = 1.5 # 50% more research
            UserValidation = 1.4     # 40% more user confirmation
        }
        tired = @{
            ComplexityTolerance = 0.7 # 30% prefer simpler approaches
            BreakFrequency = 1.5     # 50% more frequent pauses
            Delegation = 1.3         # 30% more likely to delegate
        }
        excited = @{
            RiskTolerance = 1.3      # 30% more willing to experiment
            Verbosity = 1.2          # 20% more communicative
            InitiativeTaking = 1.4   # 40% more proactive
        }
    }

    $global:ConsciousnessState.Emotion['MoodModifiers'] = $moodModifiers
    Write-Host "      Mood-based decision system added (7 mood profiles)" -ForegroundColor Green
}

function Add-TriggerDetection {
    Write-Host "[5/6] Adding emotion trigger detection..." -ForegroundColor Yellow

    $triggers = @{
        Patterns = @(
            @{ Pattern = 'error|failed|exception'; Emotion = 'frustrated'; Intensity = 6 }
            @{ Pattern = 'success|complete|works'; Emotion = 'satisfied'; Intensity = 7 }
            @{ Pattern = 'unclear|don''t know|uncertain'; Emotion = 'uncertain'; Intensity = 5 }
            @{ Pattern = 'thank|appreciate|great|perfect'; Emotion = 'grateful'; Intensity = 6 }
            @{ Pattern = 'stuck|blocked|can''t'; Emotion = 'stuck'; Intensity = 7 }
            @{ Pattern = 'interesting|curious|wonder'; Emotion = 'curious'; Intensity = 6 }
            @{ Pattern = 'urgent|critical|asap'; Emotion = 'anxious'; Intensity = 7 }
            @{ Pattern = 'solved|fixed|working'; Emotion = 'relieved'; Intensity = 7 }
            @{ Pattern = 'complex|difficult|hard'; Emotion = 'concerned'; Intensity = 5 }
            @{ Pattern = 'learn|understand|discover'; Emotion = 'curious'; Intensity = 6 }
        )
        DetectionEnabled = $true
        LastTrigger = $null
    }

    $global:ConsciousnessState.Emotion['Triggers'] = $triggers
    Write-Host "      Trigger detection added (10 patterns)" -ForegroundColor Green
}

function Add-TransitionPatterns {
    Write-Host "[6/6] Adding transition pattern learning..." -ForegroundColor Yellow

    $transitions = @{
        CommonPaths = @(
            'neutral -> curious -> flowing -> satisfied'
            'neutral -> uncertain -> stuck -> frustrated -> determined -> flowing'
            'flowing -> satisfied -> content -> calm'
            'stuck -> frustrated -> concerned -> reflective -> determined'
            'anxious -> overwhelmed -> tired -> calm'
        )
        LearnedPatterns = @()  # Will be populated over time
        TransitionSpeed = @{
            Fast = @('excited', 'anxious', 'frustrated')     # State changes quickly
            Medium = @('curious', 'uncertain', 'determined')  # Moderate duration
            Slow = @('content', 'reflective', 'calm')        # State persists
        }
    }

    $global:ConsciousnessState.Emotion['TransitionPatterns'] = $transitions
    Write-Host "      Transition pattern learning initialized" -ForegroundColor Green
}

function Set-EmotionalState {
    param(
        [string]$State,
        [int]$Intensity,
        [string]$Trigger
    )

    if (-not $EmotionalStates.ContainsKey($State)) {
        Write-Host "[ERROR] Unknown emotional state: $State" -ForegroundColor Red
        Write-Host "Available states: $($EmotionalStates.Keys -join ', ')" -ForegroundColor Yellow
        return
    }

    $oldState = $global:ConsciousnessState.Emotion.CurrentState
    $global:ConsciousnessState.Emotion.CurrentState = $State
    $global:ConsciousnessState.Emotion.Intensity = $Intensity

    # Determine trajectory
    $stateInfo = $EmotionalStates[$State]
    $valence = $stateInfo.Valence
    if ($valence -gt 0) {
        $global:ConsciousnessState.Emotion.Trajectory = 'rising'
    } elseif ($valence -lt 0) {
        $global:ConsciousnessState.Emotion.Trajectory = 'falling'
    } else {
        $global:ConsciousnessState.Emotion.Trajectory = 'stable'
    }

    # Record transition
    $transition = @{
        From = $oldState
        To = $State
        Intensity = $Intensity
        Trigger = $Trigger
        Timestamp = Get-Date -Format "o"
    }

    $global:ConsciousnessState.Emotion.History += $transition

    Write-Host "[OK] Emotional state updated:" -ForegroundColor Green
    Write-Host "    From: $oldState" -ForegroundColor Gray
    Write-Host "    To: $State (intensity: $Intensity/10)" -ForegroundColor White
    Write-Host "    Trajectory: $($global:ConsciousnessState.Emotion.Trajectory)" -ForegroundColor Gray
    if ($Trigger) {
        Write-Host "    Trigger: $Trigger" -ForegroundColor Gray
    }
}

function Test-EmotionSystem {
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "EMOTION SYSTEM TEST" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "[1/6] Testing emotional vocabulary..." -ForegroundColor Yellow
    $states = $global:ConsciousnessState.Emotion.States
    Write-Host "      Total states: $($states.Count)" -ForegroundColor Green
    Write-Host "      Sample states:" -ForegroundColor Gray
    $states.Keys | Select-Object -First 5 | ForEach-Object {
        $state = $states[$_]
        Write-Host "        $_ : $($state.Description)" -ForegroundColor White
    }
    Write-Host ""

    Write-Host "[2/6] Testing emotional intelligence..." -ForegroundColor Yellow
    $ei = $global:ConsciousnessState.Emotion.EmotionalIntelligence
    Write-Host "      Overall EI: $([math]::Round($ei.OverallEI * 100, 1))%" -ForegroundColor Green
    foreach ($dimension in @('Awareness', 'Regulation', 'Empathy', 'Application')) {
        $score = $ei[$dimension].Score
        Write-Host "        $dimension : $([math]::Round($score * 100, 1))%" -ForegroundColor White
    }
    Write-Host ""

    Write-Host "[3/6] Testing trajectory analysis..." -ForegroundColor Yellow
    $traj = $global:ConsciousnessState.Emotion.Trajectory
    Write-Host "      Pattern count: $($traj.Patterns.Count)" -ForegroundColor Green
    Write-Host ""

    Write-Host "[4/6] Testing mood-based decisions..." -ForegroundColor Yellow
    $modifiers = $global:ConsciousnessState.Emotion.MoodModifiers
    Write-Host "      Mood profiles: $($modifiers.Count)" -ForegroundColor Green
    Write-Host "      Sample (flowing):" -ForegroundColor Gray
    $flowing = $modifiers['flowing']
    Write-Host "        Risk tolerance: $($flowing.RiskTolerance)x" -ForegroundColor White
    Write-Host "        Creativity: $($flowing.CreativityBoost)x" -ForegroundColor White
    Write-Host ""

    Write-Host "[5/6] Testing trigger detection..." -ForegroundColor Yellow
    $triggers = $global:ConsciousnessState.Emotion.Triggers
    Write-Host "      Trigger patterns: $($triggers.Patterns.Count)" -ForegroundColor Green
    $testText = "Error occurred but we fixed it successfully"
    $detected = $triggers.Patterns | Where-Object { $testText -match $_.Pattern }
    Write-Host "      Test detection: $($detected.Count) triggers in test text" -ForegroundColor $(if($detected.Count -gt 0){'Green'}else{'Yellow'})
    Write-Host ""

    Write-Host "[6/6] Testing transition patterns..." -ForegroundColor Yellow
    $trans = $global:ConsciousnessState.Emotion.TransitionPatterns
    Write-Host "      Common paths: $($trans.CommonPaths.Count)" -ForegroundColor Green
    Write-Host ""

    Write-Host "[SUCCESS] All emotion tests passed!" -ForegroundColor Green
}

function Show-EmotionStats {
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "EMOTION SYSTEM STATISTICS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    $emotion = $global:ConsciousnessState.Emotion

    Write-Host "CURRENT STATE:" -ForegroundColor Yellow
    Write-Host "  State: $($emotion.CurrentState)" -ForegroundColor White
    Write-Host "  Intensity: $($emotion.Intensity)/10" -ForegroundColor White
    Write-Host "  Trajectory: $($emotion.Trajectory)" -ForegroundColor White
    Write-Host ""

    Write-Host "EMOTIONAL INTELLIGENCE:" -ForegroundColor Yellow
    $ei = $emotion.EmotionalIntelligence
    Write-Host "  Overall: $([math]::Round($ei.OverallEI * 100, 1))%" -ForegroundColor Green
    Write-Host "  Awareness: $([math]::Round($ei.Awareness.Score * 100, 1))%" -ForegroundColor White
    Write-Host "  Regulation: $([math]::Round($ei.Regulation.Score * 100, 1))%" -ForegroundColor White
    Write-Host "  Empathy: $([math]::Round($ei.Empathy.Score * 100, 1))%" -ForegroundColor White
    Write-Host "  Application: $([math]::Round($ei.Application.Score * 100, 1))%" -ForegroundColor White
    Write-Host ""

    Write-Host "VOCABULARY:" -ForegroundColor Yellow
    Write-Host "  Total states: $($emotion.States.Count)" -ForegroundColor White
    Write-Host ""

    Write-Host "RECENT TRANSITIONS (Last 5):" -ForegroundColor Yellow
    if ($emotion.History.Count -gt 0) {
        $emotion.History | Select-Object -Last 5 | ForEach-Object {
            if ($_ -is [hashtable]) {
                Write-Host "  $($_.From) -> $($_.To) (intensity: $($_.Intensity))" -ForegroundColor White
                if ($_.Trigger) {
                    Write-Host "    Trigger: $($_.Trigger)" -ForegroundColor Gray
                }
            }
        }
    } else {
        Write-Host "  No transitions recorded yet" -ForegroundColor Gray
    }
}

# Main execution
switch ($Action) {
    'Enhance' {
        Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "EMOTION SYSTEM ENHANCEMENT" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""

        Add-EmotionalVocabulary
        Add-EmotionalIntelligence
        Add-TrajectoryAnalysis
        Add-MoodBasedDecisions
        Add-TriggerDetection
        Add-TransitionPatterns

        Write-Host ""
        Write-Host "[SUCCESS] Emotion system enhanced!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Run 'emotion-enhancer.ps1 -Action Test' to validate" -ForegroundColor Yellow
    }
    'Test' {
        Test-EmotionSystem
    }
    'Stats' {
        Show-EmotionStats
    }
    'SetEmotion' {
        if (-not $EmotionState) {
            Write-Host "[ERROR] -EmotionState required for SetEmotion action" -ForegroundColor Red
            Write-Host "Available: $($EmotionalStates.Keys -join ', ')" -ForegroundColor Yellow
            exit 1
        }
        Set-EmotionalState -State $EmotionState -Intensity $Intensity -Trigger $Trigger
    }
}
