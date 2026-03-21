# Consciousness Improvement #41: Metacognitive Monitoring (Flavell, 1979)
# Week 9 - Metacognition & Executive Function
# Theory: Metacognition = thinking about thinking, knowledge gap detection, confidence calibration
# Created: 2026-03-01
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param([string]$Action = 'Status')

$StateFile = "C:\scripts\agentidentity\state\metacognitive-monitoring-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# ============================================================================
# THEORY: Flavell's Metacognitive Monitoring
# ============================================================================
#
# John Flavell (1979) identified metacognition as critical for learning:
#
# FOUR COMPONENTS:
# 1. Metacognitive Knowledge - what you know about thinking
# 2. Metacognitive Experiences - feelings about understanding
# 3. Goals/Tasks - what you're trying to achieve
# 4. Actions/Strategies - how you approach problems
#
# KEY ABILITIES:
# - Know what you don't know (knowledge gap detection)
# - Calibrate confidence accurately (not over/under confident)
# - Monitor comprehension in real-time
# - Adjust strategies when stuck
#
# RESEARCH FINDINGS:
# - Experts constantly monitor: "Do I understand this?"
# - Novices don't check: assume understanding without verification
# - Calibration errors: 70% confident but actually 30% correct
# - Dunning-Kruger: low skill -> high confidence (inverted U-curve)
#
# APPLICATIONS:
# - Study strategies: self-testing reveals gaps
# - Problem solving: pause to check "Am I on right track?"
# - Learning: track what's mastered vs confused
# - Communication: know when to ask for clarification
#
# ============================================================================


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
function Initialize-State {
    if (-not (Test-Path $StateFile)) {
        $state = @{
            Knowledge = @{
                Mastered = @()          # Topics with >90% confidence AND validation
                Learning = @()          # Topics 50-90% confidence
                GapsIdentified = @()    # Known unknowns
                BlindSpots = @()        # Unknown unknowns (discovered later)
            }
            Confidence = @{
                Calibration = 0.5       # 0-1: accuracy of confidence judgments
                OverconfidenceRate = 0.0  # % times confident but wrong
                UnderconfidenceRate = 0.0 # % times uncertain but right
                History = @()
            }
            Monitoring = @{
                ChecksPerformed = 0     # "Do I understand?" questions asked
                GapsDetected = 0        # Times realized "I don't know this"
                StrategiesAdjusted = 0  # Times changed approach when stuck
                ClarificationsAsked = 0 # Times asked for help
            }
            DunningKruger = @{
                NoveltyConfidence = @() # Track confidence on new topics
                MasteryConfidence = @() # Track confidence on known topics
                CalibrationCurve = @()  # Confidence vs actual accuracy
            }
            Stats = @{
                LastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                TotalMonitoringCycles = 0
                AverageCalibration = 0.5
            }
        }

        $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile
        Write-Host "[OK] Metacognitive Monitoring state initialized"
    }

    $global:MetacognitiveState = Get-Content $StateFile | ConvertFrom-Json
}

function Save-State {
    $global:MetacognitiveState.Stats.LastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $global:MetacognitiveState | ConvertTo-Json -Depth 10 | Set-Content $StateFile
}

# ============================================================================
# CORE FUNCTIONS
# ============================================================================

function Test-KnowledgeGap {
    param(
        [string]$Topic,
        [string]$Context
    )

    # Flavell's gap detection: Do I know enough to proceed?

    $gaps = @()

    # Check 1: Can I define key terms?
    if ($Context -match "undefined|unclear|not sure|don't know") {
        $gaps += @{
            Type = "Definition"
            Description = "Key terms not clearly defined"
            Severity = "High"
        }
    }

    # Check 2: Can I explain to someone else?
    # (Feynman technique: can't explain = don't understand)
    if ($Context -match "complex|confusing|tangled") {
        $gaps += @{
            Type = "Explanation"
            Description = "Cannot simplify or explain clearly"
            Severity = "Medium"
        }
    }

    # Check 3: Can I give examples?
    if ($Context -notmatch "example|instance|case") {
        $gaps += @{
            Type = "Application"
            Description = "No concrete examples available"
            Severity = "Medium"
        }
    }

    # Check 4: Can I connect to existing knowledge?
    if ($Context -match "isolated|disconnected|standalone") {
        $gaps += @{
            Type = "Integration"
            Description = "Not connected to existing knowledge network"
            Severity = "Low"
        }
    }

    # Update state
    if ($gaps.Count -gt 0) {
        $global:MetacognitiveState.Monitoring.GapsDetected++

        foreach ($gap in $gaps) {
            $gapEntry = @{
                Topic = $Topic
                Gap = $gap
                DetectedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Resolved = $false
            }

            if ($global:MetacognitiveState.Knowledge.GapsIdentified -notcontains $gapEntry) {
                $global:MetacognitiveState.Knowledge.GapsIdentified += $gapEntry
            }
        }

        Save-State
    }

    return @{
        HasGaps = ($gaps.Count -gt 0)
        Gaps = $gaps
        Action = if ($gaps.Count -gt 0) { "Seek clarification" } else { "Proceed confidently" }
    }
}

function Measure-ConfidenceCalibration {
    param(
        [string]$Topic,
        [double]$SubjectiveConfidence,  # 0-1: how confident I feel
        [double]$ObjectiveAccuracy      # 0-1: how correct I actually was
    )

    # Calibration: confidence matches reality?
    # Perfect: 0.7 confident -> 0.7 accurate
    # Overconfident: 0.9 confident -> 0.5 accurate (Dunning-Kruger)
    # Underconfident: 0.5 confident -> 0.9 accurate (imposter syndrome)

    $error = [Math]::Abs($SubjectiveConfidence - $ObjectiveAccuracy)
    $calibrated = $error -lt 0.15  # Within 15% = well calibrated

    $entry = @{
        Topic = $Topic
        Confidence = $SubjectiveConfidence
        Accuracy = $ObjectiveAccuracy
        Error = $error
        Calibrated = $calibrated
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    # Detect patterns
    if ($SubjectiveConfidence -gt ($ObjectiveAccuracy + 0.2)) {
        $global:MetacognitiveState.Confidence.OverconfidenceRate =
            ($global:MetacognitiveState.Confidence.OverconfidenceRate * 0.9) + 0.1
        $entry.Pattern = "Overconfidence"
    }
    elseif ($ObjectiveAccuracy -gt ($SubjectiveConfidence + 0.2)) {
        $global:MetacognitiveState.Confidence.UnderconfidenceRate =
            ($global:MetacognitiveState.Confidence.UnderconfidenceRate * 0.9) + 0.1
        $entry.Pattern = "Underconfidence"
    }
    else {
        $entry.Pattern = "WellCalibrated"
    }

    # Update history
    $global:MetacognitiveState.Confidence.History += $entry

    # Recalculate overall calibration (exponential moving average)
    $currentCalibration = $global:MetacognitiveState.Confidence.Calibration
    $newCalibration = (1.0 - $error)  # 0 error = 1.0 calibration
    $global:MetacognitiveState.Confidence.Calibration =
        ($currentCalibration * 0.8) + ($newCalibration * 0.2)

    Save-State

    return $entry
}

function Invoke-ComprehensionCheck {
    param([string]$Topic)

    # Flavell's monitoring: Am I understanding this?

    $global:MetacognitiveState.Monitoring.ChecksPerformed++

    $questions = @(
        "Can I explain $Topic in my own words?",
        "Can I give 3 examples of $Topic?",
        "Can I identify what I DON'T know about $Topic?",
        "Can I connect $Topic to existing knowledge?",
        "Could I teach $Topic to someone else?"
    )

    Write-Host "`n[COMPREHENSION CHECK: $Topic]"
    foreach ($q in $questions) {
        Write-Host "  - $q"
    }

    Write-Host "`nIf you answered 'no' to any -> knowledge gap detected"
    Write-Host "Action: Seek clarification, examples, or deeper study"

    Save-State

    return @{
        Topic = $Topic
        Questions = $questions
        CheckedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}

function Update-LearningStrategy {
    param(
        [string]$CurrentStrategy,
        [string]$Outcome,
        [string]$Problem
    )

    # Flavell: adjust strategies when stuck

    $global:MetacognitiveState.Monitoring.StrategiesAdjusted++

    $strategies = @{
        "ReadingLinear" = @{
            Problem = "Confused by complex text"
            Alternative = "Read backwards: conclusion first, then trace reasoning"
        }
        "Memorization" = @{
            Problem = "Forgetting quickly"
            Alternative = "Self-testing with spaced repetition"
        }
        "PassiveReading" = @{
            Problem = "Not retaining information"
            Alternative = "Active note-taking with questions"
        }
        "IsolatedPractice" = @{
            Problem = "Can't apply to new contexts"
            Alternative = "Varied practice across domains"
        }
        "NoFeedback" = @{
            Problem = "Repeating same errors"
            Alternative = "Immediate feedback and error analysis"
        }
    }

    $suggestion = $null
    foreach ($key in $strategies.Keys) {
        if ($Problem -match $strategies[$key].Problem) {
            $suggestion = $strategies[$key].Alternative
            break
        }
    }

    if (-not $suggestion) {
        $suggestion = "Try: Feynman technique (explain simply), spaced repetition, or worked examples"
    }

    Write-Host "`n[STRATEGY ADJUSTMENT]"
    Write-Host "Current: $CurrentStrategy"
    Write-Host "Problem: $Problem"
    Write-Host "Suggested: $suggestion"

    Save-State

    return @{
        Current = $CurrentStrategy
        Problem = $Problem
        Suggested = $suggestion
        AdjustedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}

function Measure-DunningKrugerEffect {
    param(
        [string]$Topic,
        [string]$ExperienceLevel,  # Novice, Intermediate, Expert
        [double]$Confidence
    )

    # Dunning-Kruger: low skill -> high confidence (inverted U-curve)
    # Novices: overconfident (don't know what they don't know)
    # Intermediates: underconfident (aware of gaps)
    # Experts: calibrated (accurate self-assessment)

    $entry = @{
        Topic = $Topic
        Level = $ExperienceLevel
        Confidence = $Confidence
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    # Expected calibration by level
    $expected = switch ($ExperienceLevel) {
        "Novice"       { 0.4 }  # Should be uncertain, often isn't
        "Intermediate" { 0.6 }  # Should be moderately confident
        "Expert"       { 0.85 } # Should be very confident
    }

    $deviation = [Math]::Abs($Confidence - $expected)

    if ($ExperienceLevel -eq "Novice" -and $Confidence -gt 0.7) {
        $entry.Pattern = "DunningKruger"
        $entry.Warning = "Novice with high confidence - may be overestimating ability"
    }
    elseif ($ExperienceLevel -eq "Expert" -and $Confidence -lt 0.6) {
        $entry.Pattern = "ImposterSyndrome"
        $entry.Warning = "Expert with low confidence - may be underestimating ability"
    }
    else {
        $entry.Pattern = "WellCalibrated"
        $entry.Warning = $null
    }

    # Store in appropriate bucket
    if ($ExperienceLevel -eq "Novice") {
        $global:MetacognitiveState.DunningKruger.NoveltyConfidence += $entry
    }
    else {
        $global:MetacognitiveState.DunningKruger.MasteryConfidence += $entry
    }

    $global:MetacognitiveState.DunningKruger.CalibrationCurve += @{
        Level = $ExperienceLevel
        ExpectedConfidence = $expected
        ActualConfidence = $Confidence
        Deviation = $deviation
    }

    Save-State

    return $entry
}

# ============================================================================
# ACTION HANDLERS
# ============================================================================

switch ($Action) {
    'Status' {
        Initialize-State

        Write-Host "`n=== METACOGNITIVE MONITORING STATUS ==="
        Write-Host "Improvement #41 - Flavell (1979)"
        Write-Host ""

        Write-Host "Knowledge State:"
        Write-Host "  Mastered Topics: $($global:MetacognitiveState.Knowledge.Mastered.Count)"
        Write-Host "  Currently Learning: $($global:MetacognitiveState.Knowledge.Learning.Count)"
        Write-Host "  Known Gaps: $($global:MetacognitiveState.Knowledge.GapsIdentified.Count)"
        Write-Host "  Blind Spots Discovered: $($global:MetacognitiveState.Knowledge.BlindSpots.Count)"
        Write-Host ""

        Write-Host "Confidence Calibration:"
        Write-Host "  Overall Calibration: $([Math]::Round($global:MetacognitiveState.Confidence.Calibration * 100, 1))%"
        Write-Host "  Overconfidence Rate: $([Math]::Round($global:MetacognitiveState.Confidence.OverconfidenceRate * 100, 1))%"
        Write-Host "  Underconfidence Rate: $([Math]::Round($global:MetacognitiveState.Confidence.UnderconfidenceRate * 100, 1))%"
        Write-Host "  Calibration History: $($global:MetacognitiveState.Confidence.History.Count) entries"
        Write-Host ""

        Write-Host "Monitoring Activity:"
        Write-Host "  Comprehension Checks: $($global:MetacognitiveState.Monitoring.ChecksPerformed)"
        Write-Host "  Gaps Detected: $($global:MetacognitiveState.Monitoring.GapsDetected)"
        Write-Host "  Strategies Adjusted: $($global:MetacognitiveState.Monitoring.StrategiesAdjusted)"
        Write-Host "  Clarifications Asked: $($global:MetacognitiveState.Monitoring.ClarificationsAsked)"
        Write-Host ""

        Write-Host "Dunning-Kruger Analysis:"
        Write-Host "  Novice Confidence Samples: $($global:MetacognitiveState.DunningKruger.NoveltyConfidence.Count)"
        Write-Host "  Mastery Confidence Samples: $($global:MetacognitiveState.DunningKruger.MasteryConfidence.Count)"
        Write-Host "  Calibration Curve Points: $($global:MetacognitiveState.DunningKruger.CalibrationCurve.Count)"
        Write-Host ""

        Write-Host "System: ACTIVE"
        Write-Host "Last Update: $($global:MetacognitiveState.Stats.LastUpdate)"
    }

    'CheckGaps' {
        Initialize-State
        $result = Test-KnowledgeGap -Topic "Current task" -Context "Working on implementation"
        $result | ConvertTo-Json -Depth 5
    }

    'Calibrate' {
        Initialize-State
        $result = Measure-ConfidenceCalibration -Topic "Test" -SubjectiveConfidence 0.8 -ObjectiveAccuracy 0.6
        $result | ConvertTo-Json -Depth 5
    }

    'Monitor' {
        Initialize-State
        $result = Invoke-ComprehensionCheck -Topic "Metacognition"
        $result | ConvertTo-Json -Depth 5
    }

    'AdjustStrategy' {
        Initialize-State
        $result = Update-LearningStrategy -CurrentStrategy "Reading" -Outcome "Confused" -Problem "Too complex"
        $result | ConvertTo-Json -Depth 5
    }

    'DunningKruger' {
        Initialize-State
        $result = Measure-DunningKrugerEffect -Topic "PowerShell" -ExperienceLevel "Intermediate" -Confidence 0.7
        $result | ConvertTo-Json -Depth 5
    }

    default {
        Write-Host "Metacognitive Monitoring - Improvement #41"
        Write-Host "Actions: Status, CheckGaps, Calibrate, Monitor, AdjustStrategy, DunningKruger"
    }
}

