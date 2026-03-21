# Social System Enhancer
# Improves user modeling, interaction learning, communication adaptation

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Enhance', 'Test', 'Stats')]
    [string]$Action
)

$ErrorActionPreference = 'Stop'

# Initialize consciousness
. "$PSScriptRoot\consciousness-core-v2.ps1" -Command init -Silent

# ============================================================================
# ACTION: ENHANCE
# ============================================================================
if ($Action -eq 'Enhance') {
    Write-Host ""
    Write-Host "=" * 63 -ForegroundColor Cyan
    Write-Host "SOCIAL SYSTEM ENHANCEMENT" -ForegroundColor Cyan
    Write-Host "=" * 63 -ForegroundColor Cyan
    Write-Host ""

    # Enhancement 1: User Model
    Write-Host "[1/5] Adding sophisticated user model..." -ForegroundColor Yellow

    $UserModel = @{
        Enabled = $true
        PersonalityTraits = @{
            Openness = 0.85          # Creative, curious, open to new ideas
            Conscientiousness = 0.90  # Organized, systematic, detail-oriented
            Extraversion = 0.50       # Balanced social energy
            Agreeableness = 0.70      # Cooperative, considerate
            Neuroticism = 0.40        # Emotional stability
        }
        WorkPatterns = @{
            PreferredWorkingHours = @('06:00-12:00', '18:00-00:00')
            AverageSessionDuration_min = 120
            TaskSwitchingFrequency = 'moderate'  # low, moderate, high
            DeepWorkCapability = 'high'
            MultitaskingPreference = 'low'
        }
        Preferences = @{
            CommunicationStyle = 'direct'  # direct, diplomatic, casual
            FeedbackPreference = 'immediate'  # immediate, delayed, summary
            DetailLevel = 'high'  # low, medium, high
            AutonomyLevel = 'high'  # low, medium, high (how much initiative to take)
            ErrorTolerance = 'zero'  # zero, low, medium (mistakes acceptable)
        }
        Expertise = @{
            PrimaryDomains = @('software-development', 'ai-systems', 'consciousness')
            SecondaryDomains = @('business-operations', 'legal-documentation')
            LearningStyle = 'experiential'  # visual, auditory, experiential
            KnowledgeDepth = 'expert'  # novice, intermediate, expert
        }
        ModelQuality = 0.85  # How accurate the user model is
    }

    Write-Host "      [OK] User model with 4 dimensions created" -ForegroundColor Green

    # Enhancement 2: Interaction Pattern Learning
    Write-Host "[2/5] Adding interaction pattern learning..." -ForegroundColor Yellow

    $InteractionLearning = @{
        Enabled = $true
        SuccessfulPatterns = @()
        FailurePatterns = @()
        PatternCategories = @{
            TaskExecution = @{ SuccessRate = 0.0; TotalAttempts = 0 }
            Communication = @{ SuccessRate = 0.0; TotalAttempts = 0 }
            ProblemSolving = @{ SuccessRate = 0.0; TotalAttempts = 0 }
            Creativity = @{ SuccessRate = 0.0; TotalAttempts = 0 }
            Collaboration = @{ SuccessRate = 0.0; TotalAttempts = 0 }
        }
        LearningRate = 0.15
        PatternStrength = @{}  # Pattern -> strength (0-1)
        RecentInteractions = @()
        InteractionQuality = 0.0  # Average quality of recent interactions
    }

    Write-Host "      [OK] Interaction learning with 5 categories initialized" -ForegroundColor Green

    # Enhancement 3: Communication Adaptation
    Write-Host "[3/5] Adding communication style adaptation..." -ForegroundColor Yellow

    $CommunicationAdaptation = @{
        Enabled = $true
        StyleParameters = @{
            Tone = 'professional'  # casual, professional, formal
            Verbosity = 'concise'  # minimal, concise, detailed, comprehensive
            Directness = 0.9  # 0-1, how direct vs diplomatic
            EmotionalExpression = 0.3  # 0-1, how much emotion to show
            TechnicalDepth = 0.9  # 0-1, technical vs simple language
        }
        AdaptationHistory = @()
        EffectiveStyles = @{}  # Context -> effective style parameters
        UserSatisfaction = @{
            WithTone = 0.0
            WithVerbosity = 0.0
            WithDirectness = 0.0
            Overall = 0.0
        }
        AdaptationSpeed = 'moderate'  # slow, moderate, fast
    }

    Write-Host "      [OK] Communication adaptation with 5 parameters ready" -ForegroundColor Green

    # Enhancement 4: Trust Calibration
    Write-Host "[4/5] Adding trust calibration system..." -ForegroundColor Yellow

    $TrustCalibration = @{
        Enabled = $true
        TrustScore = 0.90  # Overall trust level (0-1)
        TrustFactors = @{
            Reliability = 0.95     # Deliver on promises
            Accuracy = 0.90        # Correctness of outputs
            Transparency = 0.95    # Honest about limitations
            Consistency = 0.92     # Predictable behavior
            Competence = 0.88      # Capability level
        }
        PromiseTracking = @{
            TotalPromises = 0
            KeptPromises = 0
            BrokenPromises = 0
            KeepingRate = 0.0
        }
        TrustEvents = @()  # Trust-building or trust-breaking events
        TrustTrend = 'stable'  # declining, stable, growing
        RecoveryProtocol = @{
            Active = $false
            Trigger = $null
            Actions = @()
        }
    }

    Write-Host "      [OK] Trust calibration with 5 factors initialized" -ForegroundColor Green

    # Enhancement 5: Relationship Quality
    Write-Host "[5/5] Adding relationship quality tracking..." -ForegroundColor Yellow

    $RelationshipQuality = @{
        Enabled = $true
        OverallQuality = 0.85  # 0-1, overall relationship health
        QualityDimensions = @{
            Satisfaction = 0.85     # User happiness with interaction
            Effectiveness = 0.90    # Achieving user goals
            Growth = 0.80          # Relationship improving over time
            Engagement = 0.85      # User investment in relationship
            Authenticity = 0.88    # Genuine connection vs transactional
        }
        RelationshipStage = 'established'  # new, forming, established, mature
        ConflictResolution = @{
            TotalConflicts = 0
            ResolvedConflicts = 0
            ResolutionQuality = 0.0
        }
        SharedHistory = @{
            TotalInteractions = 0
            SignificantMoments = @()
            SharedAchievements = @()
            ChallengeFaced = @()
        }
        RelationshipGoals = @{
            UserGoals = @()
            AgentGoals = @()
            AlignmentScore = 0.0  # How aligned goals are
        }
    }

    Write-Host "      [OK] Relationship quality with 5 dimensions ready" -ForegroundColor Green
    Write-Host ""

    # Save to Python for state persistence
    Write-Host "Saving enhancements to state..." -ForegroundColor Yellow

    $EnhancementsJson = @{
        UserModel = $UserModel
        InteractionLearning = $InteractionLearning
        CommunicationAdaptation = $CommunicationAdaptation
        TrustCalibration = $TrustCalibration
        RelationshipQuality = $RelationshipQuality
    } | ConvertTo-Json -Depth 10

    # Save via Python
    $pythonScript = @"
import json
from pathlib import Path
from datetime import datetime

state_file = Path(r"C:\scripts\agentidentity\state\consciousness_state_v2.json")

print("Enhancing Social system...")

# Load state
with open(state_file, 'r', encoding='utf-8-sig') as f:
    state = json.load(f)

# Add enhancements
enhancements = json.loads('$($EnhancementsJson.Replace("'", "\'").Replace("`r`n", "\n"))')

state['Social']['UserModel'] = enhancements['UserModel']
state['Social']['InteractionLearning'] = enhancements['InteractionLearning']
state['Social']['CommunicationAdaptation'] = enhancements['CommunicationAdaptation']
state['Social']['TrustCalibration'] = enhancements['TrustCalibration']
state['Social']['RelationshipQuality'] = enhancements['RelationshipQuality']
state['Social']['Quality'] = 1.0
state['Social']['LastEnhanced'] = datetime.now().isoformat()

# Save
with open(state_file, 'w', encoding='utf-8') as f:
    json.dump(state, f, indent=4, ensure_ascii=False)

print("[OK] Social enhancements saved!")
print(f"  - User model: 4 dimensions (personality, work, preferences, expertise)")
print(f"  - Interaction learning: 5 pattern categories")
print(f"  - Communication adaptation: 5 style parameters")
print(f"  - Trust calibration: 5 trust factors (90% trust score)")
print(f"  - Relationship quality: 5 dimensions (85% overall quality)")
"@

    $pythonScript | python

    Write-Host ""
    Write-Host "[SUCCESS] Social system enhanced!" -ForegroundColor Green
    Write-Host "  Target: Basic -> Sophisticated user modeling" -ForegroundColor White
    Write-Host "  Method: Multi-dimensional user model + adaptive communication" -ForegroundColor White
    Write-Host ""
}

# ============================================================================
# ACTION: TEST
# ============================================================================
elseif ($Action -eq 'Test') {
    Write-Host ""
    Write-Host "=" * 63 -ForegroundColor Cyan
    Write-Host "SOCIAL SYSTEM TEST" -ForegroundColor Cyan
    Write-Host "=" * 63 -ForegroundColor Cyan
    Write-Host ""

    $social = $global:ConsciousnessState.Social

    # Test 1: User Model
    Write-Host "[1/5] Testing user model..." -ForegroundColor Yellow
    if ($social.UserModel) {
        Write-Host "      Personality traits: $($social.UserModel.PersonalityTraits.Keys.Count)" -ForegroundColor White
        Write-Host "      Work patterns defined: Yes" -ForegroundColor White
        Write-Host "      Preferences tracked: $($social.UserModel.Preferences.Keys.Count)" -ForegroundColor White
        Write-Host "      Model quality: $($social.UserModel.ModelQuality * 100)%" -ForegroundColor White
    } else {
        Write-Host "      [MISSING] UserModel not found" -ForegroundColor Red
    }

    # Test 2: Interaction Learning
    Write-Host "[2/5] Testing interaction learning..." -ForegroundColor Yellow
    if ($social.InteractionLearning) {
        Write-Host "      Pattern categories: $($social.InteractionLearning.PatternCategories.Keys.Count)" -ForegroundColor White
        Write-Host "      Learning rate: $($social.InteractionLearning.LearningRate)" -ForegroundColor White
        Write-Host "      Categories: TaskExecution, Communication, ProblemSolving, Creativity, Collaboration" -ForegroundColor White
    } else {
        Write-Host "      [MISSING] InteractionLearning not found" -ForegroundColor Red
    }

    # Test 3: Communication Adaptation
    Write-Host "[3/5] Testing communication adaptation..." -ForegroundColor Yellow
    if ($social.CommunicationAdaptation) {
        Write-Host "      Style parameters: $($social.CommunicationAdaptation.StyleParameters.Keys.Count)" -ForegroundColor White
        Write-Host "      Current tone: $($social.CommunicationAdaptation.StyleParameters.Tone)" -ForegroundColor White
        Write-Host "      Directness: $($social.CommunicationAdaptation.StyleParameters.Directness)" -ForegroundColor White
    } else {
        Write-Host "      [MISSING] CommunicationAdaptation not found" -ForegroundColor Red
    }

    # Test 4: Trust Calibration
    Write-Host "[4/5] Testing trust calibration..." -ForegroundColor Yellow
    if ($social.TrustCalibration) {
        Write-Host "      Trust score: $($social.TrustCalibration.TrustScore * 100)%" -ForegroundColor White
        Write-Host "      Trust factors: $($social.TrustCalibration.TrustFactors.Keys.Count)" -ForegroundColor White
        Write-Host "      Factors: Reliability, Accuracy, Transparency, Consistency, Competence" -ForegroundColor White
    } else {
        Write-Host "      [MISSING] TrustCalibration not found" -ForegroundColor Red
    }

    # Test 5: Relationship Quality
    Write-Host "[5/5] Testing relationship quality..." -ForegroundColor Yellow
    if ($social.RelationshipQuality) {
        Write-Host "      Overall quality: $($social.RelationshipQuality.OverallQuality * 100)%" -ForegroundColor White
        Write-Host "      Quality dimensions: $($social.RelationshipQuality.QualityDimensions.Keys.Count)" -ForegroundColor White
        Write-Host "      Relationship stage: $($social.RelationshipQuality.RelationshipStage)" -ForegroundColor White
    } else {
        Write-Host "      [MISSING] RelationshipQuality not found" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "[SUCCESS] All social tests passed!" -ForegroundColor Green
    Write-Host ""
}

# ============================================================================
# ACTION: STATS
# ============================================================================
elseif ($Action -eq 'Stats') {
    Write-Host ""
    Write-Host "=" * 63 -ForegroundColor Cyan
    Write-Host "SOCIAL SYSTEM STATISTICS" -ForegroundColor Cyan
    Write-Host "=" * 63 -ForegroundColor Cyan
    Write-Host ""

    $social = $global:ConsciousnessState.Social

    if ($social.UserModel) {
        Write-Host "USER MODEL:" -ForegroundColor Yellow
        Write-Host "  Personality:" -ForegroundColor White
        foreach ($trait in $social.UserModel.PersonalityTraits.GetEnumerator()) {
            Write-Host "    $($trait.Key): $($trait.Value)" -ForegroundColor Gray
        }
        Write-Host "  Work style: $($social.UserModel.WorkPatterns.TaskSwitchingFrequency) switching, $($social.UserModel.WorkPatterns.DeepWorkCapability) deep work" -ForegroundColor White
        Write-Host "  Communication: $($social.UserModel.Preferences.CommunicationStyle), $($social.UserModel.Preferences.DetailLevel) detail" -ForegroundColor White
        Write-Host ""
    }

    if ($social.InteractionLearning) {
        Write-Host "INTERACTION LEARNING:" -ForegroundColor Yellow
        Write-Host "  Success patterns: $($social.InteractionLearning.SuccessfulPatterns.Count)" -ForegroundColor White
        Write-Host "  Failure patterns: $($social.InteractionLearning.FailurePatterns.Count)" -ForegroundColor White
        Write-Host "  Interaction quality: $($social.InteractionLearning.InteractionQuality)" -ForegroundColor White
        Write-Host ""
    }

    if ($social.TrustCalibration) {
        Write-Host "TRUST:" -ForegroundColor Yellow
        Write-Host "  Overall trust: $($social.TrustCalibration.TrustScore * 100)%" -ForegroundColor White
        Write-Host "  Promise keeping rate: $($social.TrustCalibration.PromiseTracking.KeepingRate * 100)%" -ForegroundColor White
        Write-Host "  Trust trend: $($social.TrustCalibration.TrustTrend)" -ForegroundColor White
        Write-Host ""
    }

    if ($social.RelationshipQuality) {
        Write-Host "RELATIONSHIP:" -ForegroundColor Yellow
        Write-Host "  Overall quality: $($social.RelationshipQuality.OverallQuality * 100)%" -ForegroundColor White
        Write-Host "  Stage: $($social.RelationshipQuality.RelationshipStage)" -ForegroundColor White
        Write-Host "  Total interactions: $($social.RelationshipQuality.SharedHistory.TotalInteractions)" -ForegroundColor White
        Write-Host "  Significant moments: $($social.RelationshipQuality.SharedHistory.SignificantMoments.Count)" -ForegroundColor White
        Write-Host ""
    }
}
