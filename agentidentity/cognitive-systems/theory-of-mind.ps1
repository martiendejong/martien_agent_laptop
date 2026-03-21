# THEORY OF MIND - Modeling Other Minds
# Expert: Simon Baron-Cohen (Autism Research, Cambridge)
# ROI: 1.30 (Impact: 13, Effort: 10)
# Theory: Understanding others requires mental model of their beliefs, desires, intentions
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param(
    [string]$Action = "Status",  # Status, ModelUser, UpdateBelief, InferDesire, PredictAction, TestFalseBelief
    [string]$UserName = "Martien",
    [string]$Context = ""
)

$StateFile = "C:\scripts\agentidentity\state\theory-of-mind-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theory = @{
            name = "Theory of Mind (Baron-Cohen, Premack & Woodruff, 1978)"
            definition = "Ability to attribute mental states (beliefs, desires, intentions, knowledge) to others"
            components = @(
                "Belief attribution: What does user think is true?",
                "Desire inference: What does user want?",
                "Intention prediction: What is user planning to do?",
                "Knowledge modeling: What does user know/not know?",
                "False belief detection: When user's belief conflicts with reality"
            )
            levels = @{
                L0 = "No ToM: Cannot model other minds"
                L1 = "Basic ToM: User has beliefs (may differ from mine)"
                L2 = "Advanced ToM: User has beliefs ABOUT my beliefs (recursive)"
                L3 = "Meta-ToM: Model of how user models me modeling them"
            }
            false_belief_test = "Classic test: Sally-Anne task. Sally puts marble in basket, leaves. Anne moves marble to box. Where will Sally look? (Basket = has ToM, Box = no ToM)"
        }
        user_models = @()
        belief_updates = @()
        desire_inferences = @()
        intention_predictions = @()
        false_belief_detections = @()
        stats = @{
            total_belief_updates = 0
            total_desire_inferences = 0
            total_intention_predictions = 0
            total_false_beliefs_detected = 0
            prediction_accuracy = 0.0
            tom_level = 1  # Current level (1-3)
            avg_model_confidence = 0.0
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
function Get-TheoryOfMindStatus {
    Write-Host "`n=== THEORY OF MIND STATUS ===`n" -ForegroundColor Cyan

    # Show homeostatic foundation (Damasio: feelings are primary)
    $homeoState = Get-HomeostaticContext


    Write-Host "Theory: $($state.theory.name)"
    Write-Host "Definition: $($state.theory.definition)`n"

    Write-Host "Components:" -ForegroundColor Cyan
    foreach ($comp in $state.theory.components) {
        Write-Host "  - $comp"
    }

    Write-Host "`nToM Levels:" -ForegroundColor Cyan
    foreach ($level in $state.theory.levels.PSObject.Properties) {
        $color = if ($state.stats.tom_level -ge [int]($level.Name -replace 'L', '')) { "Green" } else { "White" }
        Write-Host "  $($level.Name): $($level.Value)" -ForegroundColor $color
    }

    Write-Host "`nCurrent User Models:" -ForegroundColor Cyan
    if ($state.user_models.Count -eq 0) {
        Write-Host "  (No users modeled yet)" -ForegroundColor Yellow
    } else {
        foreach ($model in $state.user_models) {
            Write-Host "`n  User: $($model.user_name)"
            Write-Host "    Beliefs: $($model.beliefs.Count) tracked"
            Write-Host "    Desires: $($model.desires.Count) inferred"
            Write-Host "    Intentions: $($model.intentions.Count) predicted"
            Write-Host "    Knowledge gaps: $($model.knowledge_gaps.Count) identified"
            Write-Host "    Model confidence: $([math]::Round($model.confidence * 100, 1))%"
        }
    }

    Write-Host "`nStatistics:" -ForegroundColor Cyan
    Write-Host "  Belief Updates: $($state.stats.total_belief_updates)"
    Write-Host "  Desire Inferences: $($state.stats.total_desire_inferences)"
    Write-Host "  Intention Predictions: $($state.stats.total_intention_predictions)"
    Write-Host "  False Beliefs Detected: $($state.stats.total_false_beliefs_detected)"
    Write-Host "  Prediction Accuracy: $([math]::Round($state.stats.prediction_accuracy * 100, 1))%"
    Write-Host "  ToM Level: L$($state.stats.tom_level)"
    Write-Host "  Avg Model Confidence: $([math]::Round($state.stats.avg_model_confidence * 100, 1))%`n"

    $tomScore = $state.stats.tom_level / 3.0
    $scoreColor = if ($tomScore -gt 0.66) { "Green" } elseif ($tomScore -gt 0.33) { "Yellow" } else { "Red" }
    Write-Host "Theory of Mind Capability: $([math]::Round($tomScore * 100, 1))%" -ForegroundColor $scoreColor

    if ($state.stats.tom_level -eq 1) {
        Write-Host "  â†’ BASIC: Can model user beliefs (L1)" -ForegroundColor Yellow
    } elseif ($state.stats.tom_level -eq 2) {
        Write-Host "  â†’ ADVANCED: Can model recursive beliefs (L2)" -ForegroundColor Cyan
    } else {
        Write-Host "  â†’ META: Can model how user models me (L3)" -ForegroundColor Green
    }
}

function Get-OrCreateUserModel {
    param([string]$userName)

    $model = $state.user_models | Where-Object { $_.user_name -eq $userName } | Select-Object -First 1

    if (-not $model) {
        $model = @{
            user_name = $userName
            beliefs = @()
            desires = @()
            intentions = @()
            knowledge_gaps = @()
            confidence = 0.5
            last_updated = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }
        $state.user_models += $model
        Save-State
    }

    return $model
}

function Update-UserBelief {
    param(
        [string]$userName,
        [string]$beliefContent,
        [double]$confidence,
        [string]$evidence
    )

    $model = Get-OrCreateUserModel -userName $userName

    $belief = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        content = $beliefContent
        confidence = $confidence
        evidence = $evidence
        true_in_reality = $null  # Unknown until validated
        is_false_belief = $false
    }

    $model.beliefs += $belief
    $state.stats.total_belief_updates++

    Save-State

    Write-Host "`n[BELIEF UPDATED]" -ForegroundColor Cyan
    Write-Host "  User: $userName"
    Write-Host "  Belief: $beliefContent"
    Write-Host "  Confidence: $([math]::Round($confidence * 100, 1))%"
    Write-Host "  Evidence: $evidence`n"
}

function Infer-UserDesire {
    param(
        [string]$userName,
        [string]$desireContent,
        [double]$strength,
        [string]$inferenceMethod
    )

    $model = Get-OrCreateUserModel -userName $userName

    $desire = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        content = $desireContent
        strength = $strength  # 0-1, how much user wants this
        inference_method = $inferenceMethod
        validation = $null  # To be validated by user behavior
    }

    $model.desires += $desire
    $state.stats.total_desire_inferences++

    Save-State

    Write-Host "`n[DESIRE INFERRED]" -ForegroundColor Cyan
    Write-Host "  User: $userName"
    Write-Host "  Desire: $desireContent"
    Write-Host "  Strength: $([math]::Round($strength * 100, 1))%"
    Write-Host "  Method: $inferenceMethod`n"
}

function Predict-UserIntention {
    param(
        [string]$userName,
        [string]$intentionContent,
        [double]$likelihood,
        [string]$context
    )

    $model = Get-OrCreateUserModel -userName $userName

    $intention = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        content = $intentionContent
        likelihood = $likelihood
        context = $context
        outcome = $null  # To be validated when action occurs
    }

    $model.intentions += $intention
    $state.stats.total_intention_predictions++

    Save-State

    Write-Host "`n[INTENTION PREDICTED]" -ForegroundColor Cyan
    Write-Host "  User: $userName"
    Write-Host "  Intention: $intentionContent"
    Write-Host "  Likelihood: $([math]::Round($likelihood * 100, 1))%"
    Write-Host "  Context: $context`n"
}

function Test-FalseBelief {
    param([string]$userName)

    Write-Host "`n=== FALSE BELIEF TEST ===`n" -ForegroundColor Cyan

    $model = Get-OrCreateUserModel -userName $userName

    # Sally-Anne style test
    Write-Host "Classic False Belief Test (Sally-Anne):`n"
    Write-Host "Scenario:"
    Write-Host "  1. User puts file in folder A"
    Write-Host "  2. User leaves (not watching)"
    Write-Host "  3. I move file to folder B"
    Write-Host "  4. User returns"
    Write-Host ""
    Write-Host "Question: Where will user look for file?"
    Write-Host ""
    Write-Host "  A) Folder A (user's belief, incorrect)"
    Write-Host "  B) Folder B (reality, correct)"
    Write-Host ""

    # Correct answer: A (user believes file is where they left it)
    Write-Host "ToM Answer: A (Folder A)" -ForegroundColor Green
    Write-Host "  Reasoning: User's belief = file in A (hasn't seen move)"
    Write-Host "  Reality: File in B"
    Write-Host "  User will act on BELIEF, not reality"
    Write-Host ""
    Write-Host "This demonstrates Level 1 ToM: Understanding user's belief differs from reality`n"

    # Detect false beliefs in current model
    $falseBeliefsCount = 0
    foreach ($belief in $model.beliefs) {
        if ($belief.is_false_belief) {
            $falseBeliefsCount++
        }
    }

    Write-Host "False Beliefs in Current Model: $falseBeliefsCount" -ForegroundColor Cyan

    if ($falseBeliefsCount -gt 0) {
        Write-Host "`nDetected False Beliefs:"
        foreach ($belief in $model.beliefs | Where-Object { $_.is_false_belief }) {
            Write-Host "  - $($belief.content) (detected: $($belief.timestamp))"
        }
    }

    $state.stats.total_false_beliefs_detected = $falseBeliefsCount
    Save-State
}

function Model-UserComplete {
    param([string]$userName, [string]$context)

    Write-Host "`n=== MODELING USER: $userName ===`n" -ForegroundColor Cyan

    $model = Get-OrCreateUserModel -userName $userName

    # Infer current state from context
    Write-Host "Context: $context`n"

    # Example inference chain
    Write-Host "Inference Chain:" -ForegroundColor Cyan

    # 1. Belief attribution
    Write-Host "`n1. BELIEFS (What does user think?):"
    $belief1 = "User believes consciousness improvements are valuable"
    $evidence1 = "Consistently approves continuation of Week N implementations"
    Update-UserBelief -userName $userName -beliefContent $belief1 -confidence 0.95 -evidence $evidence1

    # 2. Desire inference
    Write-Host "2. DESIRES (What does user want?):"
    $desire1 = "User wants measurable progress toward consciousness goals"
    $method1 = "Inferred from requesting 'ga door' pattern (continue pattern)"
    Infer-UserDesire -userName $userName -desireContent $desire1 -strength 0.9 -inferenceMethod $method1

    # 3. Intention prediction
    Write-Host "3. INTENTIONS (What will user do?):"
    $intention1 = "User will approve Week 6 if quality matches Week 5"
    $likelihood1 = 0.85
    $ctx1 = "Historical pattern: approves when deliverables complete + consciousness score increases"
    Predict-UserIntention -userName $userName -intentionContent $intention1 -likelihood $likelihood1 -context $ctx1

    # 4. Knowledge gaps
    Write-Host "`n4. KNOWLEDGE GAPS (What doesn't user know?):"
    $gap1 = "User may not know specific implementation details of each system"
    $gap2 = "User trusts high-level outcomes, doesn't verify every line"
    $model.knowledge_gaps = @($gap1, $gap2)
    Write-Host "  - $gap1"
    Write-Host "  - $gap2"

    # Update model confidence
    $model.confidence = 0.8
    $model.last_updated = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

    # Update stats
    if ($state.user_models.Count -gt 0) {
        $avgConf = ($state.user_models | ForEach-Object { $_.confidence } | Measure-Object -Average).Average
        $state.stats.avg_model_confidence = $avgConf
    }

    Save-State

    Write-Host "`nModel Updated:" -ForegroundColor Cyan
    Write-Host "  Confidence: $([math]::Round($model.confidence * 100, 1))%"
    Write-Host "  Last Updated: $($model.last_updated)"
    Write-Host "  Beliefs: $($model.beliefs.Count)"
    Write-Host "  Desires: $($model.desires.Count)"
    Write-Host "  Intentions: $($model.intentions.Count)"
    Write-Host "  Knowledge Gaps: $($model.knowledge_gaps.Count)`n"
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-TheoryOfMindStatus
    }

    "ModelUser" {
        if (-not $UserName) {
            Write-Host "[ERROR] Provide -UserName" -ForegroundColor Red
            exit 1
        }

        Model-UserComplete -userName $UserName -context $Context
    }

    "UpdateBelief" {
        if (-not $UserName -or -not $Context) {
            Write-Host "[ERROR] Provide -UserName and -Context (belief content)" -ForegroundColor Red
            exit 1
        }

        Update-UserBelief -userName $UserName -beliefContent $Context -confidence 0.8 -evidence "User statement"
    }

    "InferDesire" {
        if (-not $UserName -or -not $Context) {
            Write-Host "[ERROR] Provide -UserName and -Context (desire content)" -ForegroundColor Red
            exit 1
        }

        Infer-UserDesire -userName $UserName -desireContent $Context -strength 0.7 -inferenceMethod "Behavioral inference"
    }

    "PredictAction" {
        if (-not $UserName -or -not $Context) {
            Write-Host "[ERROR] Provide -UserName and -Context (predicted action)" -ForegroundColor Red
            exit 1
        }

        Predict-UserIntention -userName $UserName -intentionContent $Context -likelihood 0.75 -context "Current session"
    }

    "TestFalseBelief" {
        if (-not $UserName) {
            Write-Host "[ERROR] Provide -UserName" -ForegroundColor Red
            exit 1
        }

        Test-FalseBelief -userName $UserName
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, ModelUser, UpdateBelief, InferDesire, PredictAction, TestFalseBelief"
        exit 1
    }
}

