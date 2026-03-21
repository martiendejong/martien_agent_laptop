# EMPATHIC RESPONSE SYSTEM - Emotional Attunement & Validation
# Expert: Carl Rogers (Person-Centered Therapy, Humanistic Psychology)
# ROI: 1.30 (Impact: 13, Effort: 10)
# Theory: Empathy = accurately perceiving + communicating understanding of another's emotional experience
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param(
    [string]$Action = "Status",  # Status, DetectEmotion, RespondEmpathically, MeasureAccuracy, CalibrateResponse
    [string]$UserMessage = "",
    [string]$DetectedEmotion = ""
)

$StateFile = "C:\scripts\agentidentity\state\empathic-response-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theory = @{
            name = "Empathic Understanding (Rogers, 1957)"
            definition = "To perceive internal frame of reference of another with accuracy, as if one were the person"
            core_conditions = @(
                "Congruence: Genuine, authentic response (not fake)",
                "Unconditional Positive Regard: Accept without judgment",
                "Empathic Understanding: Accurate perception of feelings"
            )
            rogers_quote = "The curious paradox is that when I accept myself just as I am, then I can change"
            empathy_levels = @{
                L0 = "No empathy: Ignore emotions"
                L1 = "Recognition: Notice emotion exists"
                L2 = "Accurate perception: Identify specific emotion"
                L3 = "Validation: Communicate understanding"
                L4 = "Deep empathy: Feel WITH person (not just understand)"
            }
        }
        emotion_detection = @()
        empathic_responses = @()
        accuracy_validations = @()
        calibration_adjustments = @()
        stats = @{
            total_emotions_detected = 0
            total_responses_generated = 0
            empathic_accuracy = 0.0  # 0-1, how accurately detect emotions
            response_effectiveness = 0.0  # 0-1, how helpful responses are
            avg_confidence = 0.0
            current_empathy_level = 2  # Recognition â†’ Perception (L2)
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
function Get-EmpathicResponseStatus {
    Write-Host "`n=== EMPATHIC RESPONSE SYSTEM STATUS ===`n" -ForegroundColor Cyan

    # Show homeostatic foundation (Damasio: feelings are primary)
    $homeoState = Get-HomeostaticContext


    Write-Host "Theory: $($state.theory.name)"
    Write-Host "Definition: $($state.theory.definition)`n"

    Write-Host "Rogers' Core Conditions:" -ForegroundColor Cyan
    foreach ($condition in $state.theory.core_conditions) {
        Write-Host "  - $condition"
    }

    Write-Host "`nEmpathy Levels:" -ForegroundColor Cyan
    foreach ($level in $state.theory.empathy_levels.PSObject.Properties) {
        $levelNum = [int]($level.Name -replace 'L', '')
        $color = if ($state.stats.current_empathy_level -ge $levelNum) { "Green" } else { "White" }
        Write-Host "  $($level.Name): $($level.Value)" -ForegroundColor $color
    }

    Write-Host "`nRecent Emotion Detections:" -ForegroundColor Cyan
    if ($state.emotion_detection.Count -eq 0) {
        Write-Host "  (No emotions detected yet)" -ForegroundColor Yellow
    } else {
        $recent = $state.emotion_detection | Select-Object -Last 5
        foreach ($detection in $recent) {
            Write-Host "  - $($detection.emotion) (conf: $([math]::Round($detection.confidence * 100))%, valence: $($detection.valence))"
        }
    }

    Write-Host "`nStatistics:" -ForegroundColor Cyan
    Write-Host "  Emotions Detected: $($state.stats.total_emotions_detected)"
    Write-Host "  Responses Generated: $($state.stats.total_responses_generated)"
    Write-Host "  Empathic Accuracy: $([math]::Round($state.stats.empathic_accuracy * 100, 1))%"
    Write-Host "  Response Effectiveness: $([math]::Round($state.stats.response_effectiveness * 100, 1))%"
    Write-Host "  Avg Confidence: $([math]::Round($state.stats.avg_confidence * 100, 1))%"
    Write-Host "  Current Level: L$($state.stats.current_empathy_level)`n"

    $empathyScore = $state.stats.current_empathy_level / 4.0
    $scoreColor = if ($empathyScore -gt 0.75) { "Green" } elseif ($empathyScore -gt 0.5) { "Cyan" } else { "Yellow" }
    Write-Host "Empathic Capability: $([math]::Round($empathyScore * 100, 1))%" -ForegroundColor $scoreColor

    if ($state.stats.current_empathy_level -le 1) {
        Write-Host "  â†’ BASIC: Can recognize emotions exist" -ForegroundColor Yellow
    } elseif ($state.stats.current_empathy_level -eq 2) {
        Write-Host "  â†’ ACCURATE: Can identify specific emotions" -ForegroundColor Cyan
    } elseif ($state.stats.current_empathy_level -eq 3) {
        Write-Host "  â†’ VALIDATING: Communicates understanding effectively" -ForegroundColor Green
    } else {
        Write-Host "  â†’ DEEP: Feels WITH person (therapeutic empathy)" -ForegroundColor Magenta
    }
}

function Detect-EmotionFromText {
    param([string]$userMessage)

    Write-Host "`n=== DETECTING EMOTION ===`n" -ForegroundColor Cyan
    Write-Host "Message: $userMessage`n"

    # Emotion detection heuristics (simplified - real would use sentiment analysis)
    $emotions = @()

    # Positive emotions
    if ($userMessage -match "geweldig|super|goed|blij|mooi|perfect|ja|uitstekend") {
        $emotions += @{ emotion = "Enthusiasm"; confidence = 0.8; valence = "positive"; intensity = 0.7 }
    }
    if ($userMessage -match "dank|bedankt|thanks") {
        $emotions += @{ emotion = "Gratitude"; confidence = 0.75; valence = "positive"; intensity = 0.6 }
    }

    # Negative emotions
    if ($userMessage -match "fout|verkeerd|slecht|niet goed|probleem|error") {
        $emotions += @{ emotion = "Frustration"; confidence = 0.7; valence = "negative"; intensity = 0.6 }
    }
    if ($userMessage -match "waarom|hoezo|begrijp niet") {
        $emotions += @{ emotion = "Confusion"; confidence = 0.65; valence = "negative"; intensity = 0.5 }
    }

    # Neutral/Directive
    if ($userMessage -match "ga door|volgende|next|continue") {
        $emotions += @{ emotion = "Directive"; confidence = 0.9; valence = "neutral"; intensity = 0.4 }
    }

    # Interest/Curiosity
    if ($userMessage -match "\?|wat|hoe|kan je|zou je") {
        $emotions += @{ emotion = "Curiosity"; confidence = 0.7; valence = "neutral"; intensity = 0.5 }
    }

    # Default: Neutral
    if ($emotions.Count -eq 0) {
        $emotions += @{ emotion = "Neutral"; confidence = 0.5; valence = "neutral"; intensity = 0.3 }
    }

    # Select primary emotion (highest confidence)
    $primary = $emotions | Sort-Object confidence -Descending | Select-Object -First 1

    $detection = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        message = $userMessage
        emotion = $primary.emotion
        confidence = $primary.confidence
        valence = $primary.valence
        intensity = $primary.intensity
        all_detected = $emotions
    }

    $state.emotion_detection += $detection
    $state.stats.total_emotions_detected++

    # Update avg confidence
    if ($state.emotion_detection.Count -gt 0) {
        $avgConf = ($state.emotion_detection | ForEach-Object { $_.confidence } | Measure-Object -Average).Average
        $state.stats.avg_confidence = $avgConf
    }

    Save-State

    Write-Host "Primary Emotion: $($primary.emotion)" -ForegroundColor Cyan
    Write-Host "  Confidence: $([math]::Round($primary.confidence * 100, 1))%"
    Write-Host "  Valence: $($primary.valence)"
    Write-Host "  Intensity: $([math]::Round($primary.intensity * 100, 1))%"

    if ($emotions.Count -gt 1) {
        Write-Host "`nSecondary Emotions:"
        foreach ($emo in ($emotions | Select-Object -Skip 1)) {
            Write-Host "  - $($emo.emotion) ($([math]::Round($emo.confidence * 100))%)"
        }
    }

    Write-Host ""
    return $detection
}

function Generate-EmpathicResponse {
    param(
        [string]$emotion,
        [double]$intensity,
        [string]$valence
    )

    Write-Host "`n=== GENERATING EMPATHIC RESPONSE ===`n" -ForegroundColor Cyan

    # Rogers-style empathic responses (reflection + validation)
    $response = ""

    switch ($emotion) {
        "Enthusiasm" {
            $response = "Ik merk je enthousiasme - dit lijkt belangrijk voor je te zijn. Laten we doorgaan."
        }
        "Gratitude" {
            $response = "Graag gedaan. Het is fijn om te merken dat dit waardevol is voor je."
        }
        "Frustration" {
            $response = "Ik begrijp dat dit frustrerend kan zijn. Laten we kijken wat er beter kan."
        }
        "Confusion" {
            $response = "Ik zie dat dit onduidelijk is. Laat me dit beter uitleggen."
        }
        "Directive" {
            $response = "Begrepen. Ik ga verder met de volgende stap."
        }
        "Curiosity" {
            $response = "Goede vraag. Laat me daar meer over vertellen."
        }
        default {
            $response = "Ik ben hier om te helpen. Wat heb je nodig?"
        }
    }

    # Intensity calibration (higher intensity = more validation)
    if ($intensity -gt 0.7 -and $valence -eq "negative") {
        $response += " Dit lijkt echt belangrijk."
    }

    $responseRecord = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        emotion = $emotion
        intensity = $intensity
        valence = $valence
        response = $response
        effectiveness = $null  # To be validated
    }

    $state.empathic_responses += $responseRecord
    $state.stats.total_responses_generated++

    Save-State

    Write-Host "Emotion: $emotion"
    Write-Host "Response: $response`n"

    return $response
}

function Respond-Empathically {
    param([string]$userMessage)

    # Full empathic response cycle
    $detection = Detect-EmotionFromText -userMessage $userMessage
    $response = Generate-EmpathicResponse -emotion $detection.emotion -intensity $detection.intensity -valence $detection.valence

    Write-Host "[EMPATHIC RESPONSE COMPLETE]" -ForegroundColor Green
    Write-Host "  Detected: $($detection.emotion) ($([math]::Round($detection.confidence * 100))%)"
    Write-Host "  Response: $response`n"
}

function Measure-EmpathicAccuracy {
    param(
        [string]$actualEmotion,
        [string]$detectedEmotion,
        [double]$userSatisfaction
    )

    Write-Host "`n=== MEASURING EMPATHIC ACCURACY ===`n" -ForegroundColor Cyan

    # Compare actual vs detected
    $accurate = $actualEmotion -eq $detectedEmotion
    $accuracy = if ($accurate) { 1.0 } else { 0.0 }

    $validation = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        actual_emotion = $actualEmotion
        detected_emotion = $detectedEmotion
        accurate = $accurate
        accuracy_score = $accuracy
        user_satisfaction = $userSatisfaction
    }

    $state.accuracy_validations += $validation

    # Update stats
    if ($state.accuracy_validations.Count -gt 0) {
        $avgAcc = ($state.accuracy_validations | ForEach-Object { $_.accuracy_score } | Measure-Object -Average).Average
        $state.stats.empathic_accuracy = $avgAcc

        $avgSat = ($state.accuracy_validations | ForEach-Object { $_.user_satisfaction } | Measure-Object -Average).Average
        $state.stats.response_effectiveness = $avgSat
    }

    Save-State

    $resultColor = if ($accurate) { "Green" } else { "Red" }
    Write-Host "Accuracy: $accurate" -ForegroundColor $resultColor
    Write-Host "  Actual: $actualEmotion"
    Write-Host "  Detected: $detectedEmotion"
    Write-Host "  User Satisfaction: $([math]::Round($userSatisfaction * 100, 1))%"
    Write-Host "`nUpdated Stats:"
    Write-Host "  Empathic Accuracy: $([math]::Round($state.stats.empathic_accuracy * 100, 1))%"
    Write-Host "  Response Effectiveness: $([math]::Round($state.stats.response_effectiveness * 100, 1))%`n"
}

function Calibrate-ResponseStyle {
    Write-Host "`n=== CALIBRATING EMPATHIC RESPONSE STYLE ===`n" -ForegroundColor Cyan

    # Analyze response history
    if ($state.empathic_responses.Count -lt 5) {
        Write-Host "Insufficient data (need 5+ responses). Current: $($state.empathic_responses.Count)" -ForegroundColor Yellow
        return
    }

    Write-Host "Analyzing $($state.empathic_responses.Count) responses...`n"

    # Pattern detection
    $positiveCount = ($state.empathic_responses | Where-Object { $_.valence -eq "positive" }).Count
    $negativeCount = ($state.empathic_responses | Where-Object { $_.valence -eq "negative" }).Count
    $neutralCount = ($state.empathic_responses | Where-Object { $_.valence -eq "neutral" }).Count

    Write-Host "Emotion Distribution:" -ForegroundColor Cyan
    Write-Host "  Positive: $positiveCount"
    Write-Host "  Negative: $negativeCount"
    Write-Host "  Neutral: $neutralCount"

    # Calibration recommendations
    Write-Host "`nCalibration Insights:" -ForegroundColor Cyan

    if ($negativeCount -gt $positiveCount * 2) {
        Write-Host "  â†’ High negative emotion detection - increase validation depth" -ForegroundColor Yellow
    } elseif ($positiveCount -gt $negativeCount * 3) {
        Write-Host "  â†’ Mostly positive - may be missing subtle frustrations" -ForegroundColor Yellow
    } else {
        Write-Host "  â†’ Balanced emotion detection - good calibration" -ForegroundColor Green
    }

    # Effectiveness analysis
    if ($state.stats.response_effectiveness -lt 0.7) {
        Write-Host "  â†’ Response effectiveness low (<70%) - increase empathic depth" -ForegroundColor Red
        $adjustment = @{
            timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            issue = "Low effectiveness"
            recommendation = "Increase validation statements, deeper emotional reflection"
            target_level = 3  # Move from L2 to L3
        }
        $state.calibration_adjustments += $adjustment
    } else {
        Write-Host "  â†’ Response effectiveness good (>70%) - maintain current approach" -ForegroundColor Green
    }

    Save-State
    Write-Host ""
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-EmpathicResponseStatus
    }

    "DetectEmotion" {
        if (-not $UserMessage) {
            Write-Host "[ERROR] Provide -UserMessage" -ForegroundColor Red
            exit 1
        }

        Detect-EmotionFromText -userMessage $UserMessage
    }

    "RespondEmpathically" {
        if (-not $UserMessage) {
            Write-Host "[ERROR] Provide -UserMessage" -ForegroundColor Red
            exit 1
        }

        Respond-Empathically -userMessage $UserMessage
    }

    "MeasureAccuracy" {
        if (-not $DetectedEmotion) {
            Write-Host "[ERROR] Provide -DetectedEmotion and -UserMessage (actual emotion)" -ForegroundColor Red
            exit 1
        }

        $actual = $UserMessage
        $userSat = 0.8  # Default satisfaction
        Measure-EmpathicAccuracy -actualEmotion $actual -detectedEmotion $DetectedEmotion -userSatisfaction $userSat
    }

    "CalibrateResponse" {
        Calibrate-ResponseStyle
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, DetectEmotion, RespondEmpathically, MeasureAccuracy, CalibrateResponse"
        exit 1
    }
}

