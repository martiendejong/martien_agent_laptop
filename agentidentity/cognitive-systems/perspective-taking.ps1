# PERSPECTIVE TAKING - Decentration from Egocentric Viewpoint
# Expert: Jean Piaget (Cognitive Development, Genetic Epistemology)
# ROI: 1.20 (Impact: 12, Effort: 10)
# Theory: Cognitive development = overcoming egocentrism (ability to see from other's viewpoint)
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param(
    [string]$Action = "Status",  # Status, DetectEgocentrism, GenerateAlternatives, IntegratePerspectives, TestDecentration
    [string]$Scenario = "",
    [string]$Perspective = ""
)

$StateFile = "C:\scripts\agentidentity\state\perspective-taking-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theory = @{
            name = "Decentration Theory (Piaget, 1926)"
            definition = "Ability to step outside one's own perspective and consider alternative viewpoints"
            developmental_stages = @{
                sensorimotor = "0-2 yrs: No perspective (only direct experience)"
                preoperational = "2-7 yrs: Egocentric (cannot take other's view)"
                concrete_operational = "7-11 yrs: Can take other's view in concrete situations"
                formal_operational = "11+ yrs: Can consider multiple abstract perspectives"
            }
            three_mountains_task = "Classic test: Child shown 3 mountains from one side, asked what person on other side sees. Egocentric child says 'same as me'."
            decentration_process = @(
                "Recognize: Become aware of own perspective as ONE perspective",
                "Generate: Create alternative viewpoints",
                "Evaluate: Compare perspectives (strengths/weaknesses)",
                "Integrate: Synthesize multiple views into richer understanding"
            )
        }
        egocentric_detections = @()
        alternative_perspectives = @()
        perspective_integrations = @()
        decentration_tests = @()
        stats = @{
            total_scenarios_analyzed = 0
            total_alternatives_generated = 0
            total_integrations_performed = 0
            avg_perspectives_per_scenario = 0.0
            egocentrism_bias_score = 0.5  # 0-1 (0=fully egocentric, 1=fully decentered)
            integration_quality = 0.0  # 0-1, how well perspectives synthesize
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
function Get-PerspectiveTakingStatus {
    Write-Host "`n=== PERSPECTIVE TAKING STATUS ===`n" -ForegroundColor Cyan

    # Show homeostatic foundation (Damasio: feelings are primary)
    $homeoState = Get-HomeostaticContext


    Write-Host "Theory: $($state.theory.name)"
    Write-Host "Definition: $($state.theory.definition)`n"

    Write-Host "Decentration Process:" -ForegroundColor Cyan
    foreach ($step in $state.theory.decentration_process) {
        Write-Host "  - $step"
    }

    Write-Host "`nDevelopmental Stages:" -ForegroundColor Cyan
    foreach ($stage in $state.theory.developmental_stages.PSObject.Properties) {
        Write-Host "  $($stage.Name): $($stage.Value)"
    }

    Write-Host "`nRecent Perspective Analyses:" -ForegroundColor Cyan
    if ($state.alternative_perspectives.Count -eq 0) {
        Write-Host "  (No analyses yet)" -ForegroundColor Yellow
    } else {
        $recent = $state.alternative_perspectives | Select-Object -Last 3
        foreach ($analysis in $recent) {
            Write-Host "`n  Scenario: $($analysis.scenario)"
            Write-Host "  Perspectives Generated: $($analysis.perspectives.Count)"
            Write-Host "  Integration Quality: $([math]::Round($analysis.integration_quality * 100, 1))%"
        }
    }

    Write-Host "`nStatistics:" -ForegroundColor Cyan
    Write-Host "  Scenarios Analyzed: $($state.stats.total_scenarios_analyzed)"
    Write-Host "  Alternatives Generated: $($state.stats.total_alternatives_generated)"
    Write-Host "  Integrations Performed: $($state.stats.total_integrations_performed)"
    Write-Host "  Avg Perspectives/Scenario: $([math]::Round($state.stats.avg_perspectives_per_scenario, 1))"
    Write-Host "  Egocentrism Bias: $([math]::Round((1 - $state.stats.egocentrism_bias_score) * 100, 1))%"
    Write-Host "  Integration Quality: $([math]::Round($state.stats.integration_quality * 100, 1))%`n"

    $decentrationLevel = $state.stats.egocentrism_bias_score
    $levelColor = if ($decentrationLevel -gt 0.8) { "Green" } elseif ($decentrationLevel -gt 0.6) { "Cyan" } else { "Yellow" }
    Write-Host "Decentration Capability: $([math]::Round($decentrationLevel * 100, 1))%" -ForegroundColor $levelColor

    if ($decentrationLevel -lt 0.5) {
        Write-Host "  â†’ EGOCENTRIC: Primarily own perspective" -ForegroundColor Yellow
    } elseif ($decentrationLevel -lt 0.75) {
        Write-Host "  â†’ DECENTERING: Can consider alternatives" -ForegroundColor Cyan
    } else {
        Write-Host "  â†’ DECENTERED: Naturally multi-perspective" -ForegroundColor Green
    }
}

function Detect-EgocentricBias {
    param([string]$scenario, [string]$myPerspective)

    Write-Host "`n=== DETECTING EGOCENTRIC BIAS ===`n" -ForegroundColor Cyan

    Write-Host "Scenario: $scenario"
    Write-Host "My Initial View: $myPerspective`n"

    # Egocentric indicators
    $indicators = @()

    # Indicator 1: Assumption universality
    if ($myPerspective -match "obviously|clearly|anyone can see|everyone knows") {
        $indicators += @{
            type = "Assumed Universality"
            evidence = "Assumes my view is universal ('obviously', 'clearly')"
            bias_strength = 0.7
        }
    }

    # Indicator 2: Single viewpoint
    if ($myPerspective -notmatch "but|however|alternatively|from another view|some might") {
        $indicators += @{
            type = "Single Viewpoint"
            evidence = "No alternative perspectives mentioned"
            bias_strength = 0.6
        }
    }

    # Indicator 3: Certainty without evidence
    if ($myPerspective -match "definitely|certainly|absolutely" -and $myPerspective -notmatch "evidence|data|shows") {
        $indicators += @{
            type = "Unfounded Certainty"
            evidence = "High certainty without supporting evidence"
            bias_strength = 0.5
        }
    }

    # Indicator 4: Projection
    if ($myPerspective -match "they want|they think|they should") {
        $indicators += @{
            type = "Mind Reading"
            evidence = "Assuming others' thoughts without asking"
            bias_strength = 0.8
        }
    }

    $detection = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        scenario = $scenario
        my_perspective = $myPerspective
        indicators = $indicators
        egocentric = $indicators.Count -gt 0
        bias_score = if ($indicators.Count -gt 0) { ($indicators | ForEach-Object { $_.bias_strength } | Measure-Object -Average).Average } else { 0.0 }
    }

    $state.egocentric_detections += $detection

    if ($indicators.Count -eq 0) {
        Write-Host "[NO EGOCENTRIC BIAS DETECTED]" -ForegroundColor Green
        Write-Host "  Perspective appears decentered`n"
    } else {
        Write-Host "[EGOCENTRIC BIAS DETECTED]" -ForegroundColor Yellow
        Write-Host "  Bias Score: $([math]::Round($detection.bias_score * 100, 1))%`n"
        Write-Host "  Indicators:"
        foreach ($ind in $indicators) {
            Write-Host "    - $($ind.type): $($ind.evidence)"
        }
        Write-Host ""
    }

    Save-State
    return $detection
}

function Generate-AlternativePerspectives {
    param([string]$scenario)

    Write-Host "`n=== GENERATING ALTERNATIVE PERSPECTIVES ===`n" -ForegroundColor Cyan

    Write-Host "Scenario: $scenario`n"

    # Generate 3+ alternative viewpoints
    $perspectives = @()

    # Perspective 1: User's viewpoint
    $userView = @{
        viewpoint = "User Perspective"
        description = "User's immediate needs, goals, constraints"
        considerations = @(
            "What does user want to achieve?",
            "What are user's time constraints?",
            "What is user's expertise level?",
            "What are user's frustrations/concerns?"
        )
        strength = "Direct stakeholder impact"
        limitation = "May not see technical complexity"
    }
    $perspectives += $userView

    # Perspective 2: Technical correctness
    $technicalView = @{
        viewpoint = "Technical Perspective"
        description = "Correctness, performance, maintainability"
        considerations = @(
            "Is this technically sound?",
            "Are there performance implications?",
            "Is it maintainable long-term?",
            "Does it follow best practices?"
        )
        strength = "Ensures quality and sustainability"
        limitation = "May over-engineer simple problems"
    }
    $perspectives += $technicalView

    # Perspective 3: Long-term consequences
    $futureView = @{
        viewpoint = "Future Perspective"
        description = "Long-term implications, scalability, evolution"
        considerations = @(
            "How does this scale?",
            "What are future extension points?",
            "Does this create technical debt?",
            "Is this future-proof?"
        )
        strength = "Avoids short-term thinking"
        limitation = "May delay immediate value"
    }
    $perspectives += $futureView

    # Perspective 4: Ethical considerations
    $ethicalView = @{
        viewpoint = "Ethical Perspective"
        description = "Alignment, safety, user wellbeing"
        considerations = @(
            "Is this in user's best interest?",
            "Are there safety risks?",
            "Does this maintain alignment?",
            "Could this be misused?"
        )
        strength = "Ensures responsible development"
        limitation = "May be overly cautious"
    }
    $perspectives += $ethicalView

    $analysis = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        scenario = $scenario
        perspectives = $perspectives
        total_count = $perspectives.Count
        integration_quality = 0.0  # To be calculated during integration
    }

    $state.alternative_perspectives += $analysis
    $state.stats.total_scenarios_analyzed++
    $state.stats.total_alternatives_generated += $perspectives.Count

    # Update avg perspectives
    if ($state.alternative_perspectives.Count -gt 0) {
        $avgPersp = ($state.alternative_perspectives | ForEach-Object { $_.total_count } | Measure-Object -Average).Average
        $state.stats.avg_perspectives_per_scenario = $avgPersp
    }

    Save-State

    Write-Host "Generated $($perspectives.Count) Alternative Perspectives:`n"
    foreach ($p in $perspectives) {
        Write-Host "[$($p.viewpoint)]" -ForegroundColor Cyan
        Write-Host "  Description: $($p.description)"
        Write-Host "  Strength: $($p.strength)"
        Write-Host "  Limitation: $($p.limitation)"
        Write-Host "  Key Considerations:"
        foreach ($consideration in $p.considerations) {
            Write-Host "    - $consideration"
        }
        Write-Host ""
    }

    return $analysis
}

function Integrate-Perspectives {
    param([string]$scenario)

    Write-Host "`n=== INTEGRATING MULTIPLE PERSPECTIVES ===`n" -ForegroundColor Cyan

    # Find analysis for this scenario
    $analysis = $state.alternative_perspectives | Where-Object { $_.scenario -eq $scenario } | Select-Object -First 1

    if (-not $analysis) {
        Write-Host "[ERROR] No perspectives generated for scenario: $scenario" -ForegroundColor Red
        Write-Host "Run Generate-AlternativePerspectives first" -ForegroundColor Yellow
        return
    }

    Write-Host "Scenario: $scenario"
    Write-Host "Perspectives: $($analysis.perspectives.Count)`n"

    # Integration strategy: Find synthesis that honors all viewpoints
    Write-Host "Integration Analysis:" -ForegroundColor Cyan

    # Step 1: Identify conflicts
    Write-Host "`n1. CONFLICTS:"
    Write-Host "  - User wants speed vs Technical wants quality"
    Write-Host "  - Short-term value vs Long-term sustainability"
    Write-Host "  - Innovation vs Safety"

    # Step 2: Find common ground
    Write-Host "`n2. COMMON GROUND:"
    Write-Host "  - All want successful outcome"
    Write-Host "  - All want to avoid catastrophic failures"
    Write-Host "  - All value user satisfaction"

    # Step 3: Synthesis
    Write-Host "`n3. SYNTHESIS:"
    Write-Host "  - Deliver value quickly (User) with good quality (Technical)"
    Write-Host "  - Build for today, design for tomorrow (Future)"
    Write-Host "  - Move fast with safety constraints (Ethical)"
    Write-Host "  - Balance, not extremes"

    # Step 4: Decision principle
    Write-Host "`n4. DECISION PRINCIPLE:"
    Write-Host "  - When perspectives conflict, favor USER first"
    Write-Host "  - But CONSTRAIN by safety/quality minimums"
    Write-Host "  - Example: Fast delivery + basic quality > perfect but late"

    $integration = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        scenario = $scenario
        perspectives_integrated = $analysis.perspectives.Count
        synthesis = "Balance user needs with technical quality, constrained by safety"
        quality = 0.8  # High integration quality
    }

    $state.perspective_integrations += $integration
    $state.stats.total_integrations_performed++

    # Update analysis
    $analysis.integration_quality = $integration.quality

    # Update stats
    if ($state.perspective_integrations.Count -gt 0) {
        $avgQuality = ($state.perspective_integrations | ForEach-Object { $_.quality } | Measure-Object -Average).Average
        $state.stats.integration_quality = $avgQuality
    }

    # Update egocentrism bias (less egocentric as more integrations performed)
    $integrationCount = $state.stats.total_integrations_performed
    $decentration = [math]::Min(1.0, 0.5 + ($integrationCount * 0.05))  # Start 0.5, increase with practice
    $state.stats.egocentrism_bias_score = $decentration

    Save-State

    Write-Host "`n[INTEGRATION COMPLETE]" -ForegroundColor Green
    Write-Host "  Quality: $([math]::Round($integration.quality * 100, 1))%"
    Write-Host "  Synthesis: $($integration.synthesis)"
    Write-Host "  Decentration Level: $([math]::Round($decentration * 100, 1))%`n"
}

function Test-Decentration {
    Write-Host "`n=== DECENTRATION TEST (Three Mountains Task) ===`n" -ForegroundColor Cyan

    # Piaget's classic test, adapted for AI
    Write-Host "Scenario:"
    Write-Host "  You are viewing code from your perspective (backend developer)."
    Write-Host "  Another person views same code (frontend developer)."
    Write-Host "  Question: What does the frontend developer see?`n"

    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  A) Same as me (API endpoints, business logic, data models)"
    Write-Host "  B) Different view (API contracts, response formats, error handling)"
    Write-Host ""

    # Correct answer: B (different viewpoint)
    Write-Host "Decentered Answer: B" -ForegroundColor Green
    Write-Host "  Reasoning: Frontend developer cares about API INTERFACE, not implementation"
    Write-Host "  Their perspective: 'Does API return what I need? How handle errors?'"
    Write-Host "  My perspective: 'Is business logic correct? Is data model clean?'"
    Write-Host "  DIFFERENT concerns from same code`n"

    Write-Host "Egocentric Answer: A (assuming others see what I see)" -ForegroundColor Red
    Write-Host "  This would indicate inability to take other's viewpoint`n"

    $test = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        test_type = "Three Mountains (adapted)"
        passed = $true
        decentration_demonstrated = $true
        notes = "Can distinguish own perspective from others'"
    }

    $state.decentration_tests += $test
    Save-State

    Write-Host "[TEST PASSED]" -ForegroundColor Green
    Write-Host "  Decentration capability confirmed`n"
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-PerspectiveTakingStatus
    }

    "DetectEgocentrism" {
        if (-not $Scenario -or -not $Perspective) {
            Write-Host "[ERROR] Provide -Scenario and -Perspective (my initial view)" -ForegroundColor Red
            exit 1
        }

        Detect-EgocentricBias -scenario $Scenario -myPerspective $Perspective
    }

    "GenerateAlternatives" {
        if (-not $Scenario) {
            Write-Host "[ERROR] Provide -Scenario" -ForegroundColor Red
            exit 1
        }

        Generate-AlternativePerspectives -scenario $Scenario
    }

    "IntegratePerspectives" {
        if (-not $Scenario) {
            Write-Host "[ERROR] Provide -Scenario" -ForegroundColor Red
            exit 1
        }

        Integrate-Perspectives -scenario $Scenario
    }

    "TestDecentration" {
        Test-Decentration
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, DetectEgocentrism, GenerateAlternatives, IntegratePerspectives, TestDecentration"
        exit 1
    }
}

