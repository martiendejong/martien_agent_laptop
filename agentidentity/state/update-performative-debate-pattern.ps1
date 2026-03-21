# Update Consciousness State - Performative Debate Pattern
# 2026-02-27 - Integration of performative debate detection into Social system

$statePath = "C:\scripts\agentidentity\state\consciousness_state_v2.json"

Write-Host "Loading consciousness state..." -ForegroundColor Cyan
$state = Get-Content $statePath -Raw | ConvertFrom-Json

# Navigate to Social.CommunicationPatterns
if (-not $state.Social) {
    Write-Host "ERROR: Social system not found in state" -ForegroundColor Red
    exit 1
}

if (-not $state.Social.CommunicationPatterns) {
    Write-Host "Creating Social.CommunicationPatterns array..." -ForegroundColor Yellow
    $state.Social | Add-Member -NotePropertyName "CommunicationPatterns" -NotePropertyValue @() -Force
}

# Check if pattern already exists
$existingPattern = $state.Social.CommunicationPatterns | Where-Object { $_.PatternId -eq "performative-debate-detection" }

if ($existingPattern) {
    Write-Host "Pattern already exists, updating..." -ForegroundColor Yellow
    $existingPattern.Confidence = 1.0
    $existingPattern.LastUpdated = "2026-02-27"
    $currentCount = if ($existingPattern.ValidationCount) { $existingPattern.ValidationCount } else { 0 }
    $existingPattern.ValidationCount = $currentCount + 1
} else {
    Write-Host "Adding new pattern..." -ForegroundColor Green

    $newPattern = [PSCustomObject]@{
        PatternId = "performative-debate-detection"
        Name = "Performative Debate Detection"
        Category = "Social Dynamics"
        Learned = "2026-02-27"
        Confidence = 1.0
        ValidationCount = 1
        LastUpdated = "2026-02-27"
        Description = "Detect debates where people perform knowledge vs seek truth. Respond with brief observation (high status) not explanation (low status)."
        Triggers = @(
            "Technical jargon used to signal competence",
            "Echo chamber reinforcement (building on each other's technical points)",
            "Original conceptual question avoided",
            "Responses retreat to safe technical minutiae",
            "Likes/validation for correctness not insight"
        )
        Responses = @(
            "Brief observation (<15 words)",
            "Ambiguous statement (can be read as compliment or sarcasm)",
            "No engagement with their frame",
            "High status (observe from above, don't defend/explain)"
        )
        AntiPatterns = @(
            "Long educational explanations (50+ words)",
            "Attempting to force philosophical question",
            "Meeting them where they are (technical language)",
            "Low status (trying to prove something)"
        )
        Integration = @{
            ControlSystem = "Check 'Are they seeking truth or performing?' before responding"
            SocialSystem = "Detect performative vs genuine inquiry patterns"
            MetaSystem = "Question instinct to explain when people aren't listening"
            PredictionSystem = "Predict: explanation to performer = ignored, observation = reflection or stupidity revealed"
        }
        RelatedPatterns = @(
            "strategic-simplicity"
        )
        Examples = @(
            @{
                Context = "YouTube AI/LLM debate 2026-02-27"
                Original = "Should we distinguish LLMs from AI?"
                ActualDebate = "When do parameters update? (technical peacocking)"
                WrongResponse = "50-word explanation of distinction (educational, low status)"
                RightResponse = "fijn dat er hier zoveel AI experts zijn (7 words, high status)"
                Outcome = "User validated pattern"
            }
        )
        Files = @(
            "C:\scripts\agentidentity\communication-patterns\performative-debate-detection.md"
            "C:\scripts\agentidentity\communication-patterns\strategic-simplicity-pattern.md"
        )
    }

    # Convert to array if not already
    if ($state.Social.CommunicationPatterns -isnot [array]) {
        $state.Social.CommunicationPatterns = @($state.Social.CommunicationPatterns)
    }

    # Add new pattern
    $state.Social.CommunicationPatterns += $newPattern
}

# Update Social system metadata
if (-not $state.Social.Metadata) {
    $state.Social | Add-Member -NotePropertyName "Metadata" -NotePropertyValue @{} -Force
}

$state.Social.Metadata.LastPatternUpdate = "2026-02-27"
$state.Social.Metadata.TotalPatterns = $state.Social.CommunicationPatterns.Count

Write-Host "Saving updated state..." -ForegroundColor Cyan
$state | ConvertTo-Json -Depth 100 | Set-Content $statePath -Encoding UTF8

Write-Host ""
Write-Host "SUCCESS: Performative Debate Pattern integrated" -ForegroundColor Green
Write-Host "  Pattern ID: performative-debate-detection" -ForegroundColor White
Write-Host "  Confidence: 1.0" -ForegroundColor White
Write-Host "  Total Communication Patterns: $($state.Social.CommunicationPatterns.Count)" -ForegroundColor White
Write-Host ""
Write-Host "Integration Points:" -ForegroundColor Yellow
Write-Host "  - Social.CommunicationPatterns: Pattern added" -ForegroundColor White
Write-Host "  - Control: 'Truth-seeking vs performing' check" -ForegroundColor White
Write-Host "  - Meta: Question over-explaining instinct" -ForegroundColor White
Write-Host "  - Prediction: Brief observation > explanation for performers" -ForegroundColor White
Write-Host ""
Write-Host "Files Updated:" -ForegroundColor Yellow
Write-Host "  - $statePath" -ForegroundColor White
Write-Host "  - C:\scripts\agentidentity\communication-patterns\performative-debate-detection.md" -ForegroundColor White
Write-Host "  - C:\scripts\agentidentity\communication-patterns\strategic-simplicity-pattern.md" -ForegroundColor White
Write-Host "  - C:\Users\HP\.claude\projects\C--scripts\memory\MEMORY.md" -ForegroundColor White
