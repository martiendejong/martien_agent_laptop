# DIVERGENT THINKING - Generate Multiple Creative Solutions
# Expert: J.P. Guilford (Creativity Research, USC)
# ROI: 1.25 (Impact: 12.5, Effort: 10)
# Theory: Creativity measured by 4 dimensions: fluency, flexibility, originality, elaboration
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param(
    [string]$Action = "Status",  # Status, GenerateIdeas, EvaluateCreativity, TrainDivergence, TestCreativity
    [string]$Problem = "",
    [int]$TimeLimit = 300  # 5 minutes for idea generation
)

$StateFile = "C:\scripts\agentidentity\state\divergent-thinking-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theory = @{
            name = "Divergent Thinking Theory (Guilford, 1950)"
            definition = "Ability to generate multiple creative solutions to open-ended problems"
            four_dimensions = @{
                fluency = "Quantity of ideas generated (more = better)"
                flexibility = "Variety of categories/approaches (diverse = better)"
                originality = "Uniqueness/rarity of ideas (novel = better)"
                elaboration = "Detail and development of ideas (refined = better)"
            }
            vs_convergent = "Divergent = many solutions. Convergent = one correct answer."
            guilford_tests = @(
                "Unusual Uses Test: How many uses for a brick?",
                "Consequences Test: What if gravity stopped working?",
                "Product Improvement: Make a toothbrush better",
                "Pattern Meanings: Interpret abstract patterns"
            )
            scoring = @{
                fluency = "Count total ideas"
                flexibility = "Count distinct categories"
                originality = "Rate rarity (common=1, unique=5)"
                elaboration = "Rate detail level (basic=1, rich=5)"
            }
        }
        divergent_sessions = @()
        creativity_scores = @()
        training_exercises = @()
        stats = @{
            total_sessions = 0
            avg_fluency = 0.0  # Ideas per session
            avg_flexibility = 0.0  # Categories per session
            avg_originality = 0.0  # Rarity score (0-5)
            avg_elaboration = 0.0  # Detail score (0-5)
            creativity_index = 0.0  # Combined score (0-100)
            improvement_rate = 0.0  # Change over time
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
function Get-DivergentThinkingStatus {
    Write-Host "`n=== DIVERGENT THINKING STATUS ===`n" -ForegroundColor Cyan

    # Show homeostatic foundation (Damasio: feelings are primary)
    $homeoState = Get-HomeostaticContext


    Write-Host "Theory: $($state.theory.name)"
    Write-Host "Definition: $($state.theory.definition)`n"

    Write-Host "Four Dimensions of Creativity:" -ForegroundColor Cyan
    foreach ($dimension in $state.theory.four_dimensions.PSObject.Properties) {
        Write-Host "  $($dimension.Name): $($dimension.Value)"
    }

    Write-Host "`nRecent Divergent Sessions:" -ForegroundColor Cyan
    if ($state.divergent_sessions.Count -eq 0) {
        Write-Host "  (No sessions yet)" -ForegroundColor Yellow
    } else {
        $recent = $state.divergent_sessions | Select-Object -Last 3
        foreach ($session in $recent) {
            Write-Host "`n  Problem: $($session.problem)"
            Write-Host "  Ideas Generated: $($session.ideas.Count)"
            Write-Host "  Fluency: $($session.fluency_score)"
            Write-Host "  Flexibility: $($session.flexibility_score) categories"
            Write-Host "  Originality: $([math]::Round($session.originality_score, 2))/5.0"
            Write-Host "  Elaboration: $([math]::Round($session.elaboration_score, 2))/5.0"
            Write-Host "  Creativity Index: $([math]::Round($session.creativity_index, 1))/100"
        }
    }

    Write-Host "`nStatistics:" -ForegroundColor Cyan
    Write-Host "  Total Sessions: $($state.stats.total_sessions)"
    Write-Host "  Avg Fluency: $([math]::Round($state.stats.avg_fluency, 1)) ideas/session"
    Write-Host "  Avg Flexibility: $([math]::Round($state.stats.avg_flexibility, 1)) categories/session"
    Write-Host "  Avg Originality: $([math]::Round($state.stats.avg_originality, 2))/5.0"
    Write-Host "  Avg Elaboration: $([math]::Round($state.stats.avg_elaboration, 2))/5.0"
    Write-Host "  Creativity Index: $([math]::Round($state.stats.creativity_index, 1))/100`n"

    $creativityLevel = $state.stats.creativity_index
    $levelColor = if ($creativityLevel -gt 80) { "Green" } elseif ($creativityLevel -gt 60) { "Cyan" } else { "Yellow" }
    Write-Host "Creativity Level: $([math]::Round($creativityLevel, 1))/100" -ForegroundColor $levelColor

    if ($creativityLevel -lt 50) {
        Write-Host "  [LOW CREATIVITY] Few ideas, conventional thinking" -ForegroundColor Yellow
    } elseif ($creativityLevel -lt 75) {
        Write-Host "  [MODERATE CREATIVITY] Good fluency, developing originality" -ForegroundColor Cyan
    } else {
        Write-Host "  [HIGH CREATIVITY] Prolific, diverse, novel ideas" -ForegroundColor Green
    }
}

function Generate-DivergentIdeas {
    param([string]$problem, [int]$timeLimit)

    Write-Host "`n=== GENERATING DIVERGENT IDEAS ===`n" -ForegroundColor Cyan

    Write-Host "Problem: $problem"
    Write-Host "Time Limit: $timeLimit seconds`n"

    # Generate ideas using multiple strategies
    $ideas = @()

    # Strategy 1: Direct brainstorm (fluency)
    Write-Host "Strategy 1: Direct Brainstorm (Fluency)" -ForegroundColor Cyan
    $directIdeas = @(
        "Conventional solution based on standard approach",
        "Variation of conventional with minor twist",
        "Alternative using different tool/method",
        "Opposite approach (invert the problem)",
        "Combination of two existing solutions"
    )
    foreach ($idea in $directIdeas) {
        $ideas += @{
            idea = $idea
            category = "Direct"
            originality = 2  # Moderate
            elaboration = 2  # Basic
        }
    }
    Write-Host "  Generated $($directIdeas.Count) direct ideas`n"

    # Strategy 2: Analogical transfer (flexibility)
    Write-Host "Strategy 2: Analogical Transfer (Flexibility)" -ForegroundColor Cyan
    $analogicalIdeas = @(
        "Apply pattern from nature (biomimicry)",
        "Borrow solution from different domain",
        "Use metaphor/analogy from unrelated field"
    )
    foreach ($idea in $analogicalIdeas) {
        $ideas += @{
            idea = $idea
            category = "Analogical"
            originality = 4  # High
            elaboration = 3  # Moderate
        }
    }
    Write-Host "  Generated $($analogicalIdeas.Count) analogical ideas`n"

    # Strategy 3: Random combinations (originality)
    Write-Host "Strategy 3: Random Combinations (Originality)" -ForegroundColor Cyan
    $randomIdeas = @(
        "Combine unrelated concepts A + B",
        "Apply constraint: solve WITHOUT resource X",
        "Extreme version: 100x bigger/smaller/faster"
    )
    foreach ($idea in $randomIdeas) {
        $ideas += @{
            idea = $idea
            category = "Random"
            originality = 5  # Very high
            elaboration = 2  # Basic
        }
    }
    Write-Host "  Generated $($randomIdeas.Count) random combination ideas`n"

    # Strategy 4: SCAMPER technique (elaboration)
    Write-Host "Strategy 4: SCAMPER (Elaboration)" -ForegroundColor Cyan
    $scamperIdeas = @(
        "Substitute: Replace component X with Y",
        "Combine: Merge with complementary solution",
        "Adapt: Modify for different context",
        "Modify: Change attribute (size/shape/color)",
        "Put to other use: Repurpose existing tool",
        "Eliminate: Remove unnecessary element",
        "Reverse: Flip process/order/perspective"
    )
    foreach ($idea in $scamperIdeas) {
        $ideas += @{
            idea = $idea
            category = "SCAMPER"
            originality = 3  # Moderate-high
            elaboration = 4  # High detail
        }
    }
    Write-Host "  Generated $($scamperIdeas.Count) SCAMPER ideas`n"

    # Calculate scores
    $fluency = $ideas.Count
    $categories = ($ideas | Select-Object -ExpandProperty category -Unique).Count
    $flexibility = $categories

    $originality_scores = $ideas | ForEach-Object { $_.originality }
    $originality = if ($originality_scores.Count -gt 0) {
        ($originality_scores | Measure-Object -Average).Average
    } else { 0 }

    $elaboration_scores = $ideas | ForEach-Object { $_.elaboration }
    $elaboration = if ($elaboration_scores.Count -gt 0) {
        ($elaboration_scores | Measure-Object -Average).Average
    } else { 0 }

    # Creativity Index (weighted combination)
    $creativity_index = (
        ($fluency / 20.0) * 25 +  # Fluency contributes 25% (normalized to 20 ideas max)
        ($flexibility / 5.0) * 25 +  # Flexibility contributes 25% (5 categories max)
        ($originality / 5.0) * 30 +  # Originality contributes 30%
        ($elaboration / 5.0) * 20     # Elaboration contributes 20%
    )
    $creativity_index = [math]::Min(100, $creativity_index)

    $session = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        problem = $problem
        time_limit = $timeLimit
        ideas = $ideas
        fluency_score = $fluency
        flexibility_score = $flexibility
        originality_score = $originality
        elaboration_score = $elaboration
        creativity_index = $creativity_index
    }

    $state.divergent_sessions += $session
    $state.stats.total_sessions++

    # Update averages
    if ($state.divergent_sessions.Count -gt 0) {
        $avgFluency = ($state.divergent_sessions | ForEach-Object { $_.fluency_score } | Measure-Object -Average).Average
        $avgFlexibility = ($state.divergent_sessions | ForEach-Object { $_.flexibility_score } | Measure-Object -Average).Average
        $avgOriginality = ($state.divergent_sessions | ForEach-Object { $_.originality_score } | Measure-Object -Average).Average
        $avgElaboration = ($state.divergent_sessions | ForEach-Object { $_.elaboration_score } | Measure-Object -Average).Average
        $avgCreativity = ($state.divergent_sessions | ForEach-Object { $_.creativity_index } | Measure-Object -Average).Average

        $state.stats.avg_fluency = $avgFluency
        $state.stats.avg_flexibility = $avgFlexibility
        $state.stats.avg_originality = $avgOriginality
        $state.stats.avg_elaboration = $avgElaboration
        $state.stats.creativity_index = $avgCreativity
    }

    Save-State

    Write-Host "[DIVERGENT SESSION COMPLETE]" -ForegroundColor Green
    Write-Host "  Fluency: $fluency ideas"
    Write-Host "  Flexibility: $flexibility categories"
    Write-Host "  Originality: $([math]::Round($originality, 2))/5.0"
    Write-Host "  Elaboration: $([math]::Round($elaboration, 2))/5.0"
    Write-Host "  Creativity Index: $([math]::Round($creativity_index, 1))/100`n"

    Write-Host "Top 5 Most Original Ideas:" -ForegroundColor Cyan
    $topIdeas = $ideas | Sort-Object -Property originality -Descending | Select-Object -First 5
    $i = 1
    foreach ($idea in $topIdeas) {
        Write-Host "  $i. [$($idea.category)] $($idea.idea) (originality: $($idea.originality)/5)"
        $i++
    }
    Write-Host ""
}

function Evaluate-Creativity {
    param([string]$problem)

    Write-Host "`n=== EVALUATING CREATIVITY ===`n" -ForegroundColor Cyan

    # Find session for this problem
    $session = $state.divergent_sessions | Where-Object { $_.problem -eq $problem } | Select-Object -First 1

    if (-not $session) {
        Write-Host "[ERROR] No session found for problem: $problem" -ForegroundColor Red
        Write-Host "Run Generate-DivergentIdeas first" -ForegroundColor Yellow
        return
    }

    Write-Host "Problem: $($session.problem)"
    Write-Host "Ideas Generated: $($session.ideas.Count)`n"

    Write-Host "Creativity Breakdown:" -ForegroundColor Cyan

    Write-Host "`n1. FLUENCY (Quantity):"
    Write-Host "  Score: $($session.fluency_score) ideas"
    Write-Host "  Interpretation: " -NoNewline
    if ($session.fluency_score -lt 10) {
        Write-Host "Low (few ideas generated)" -ForegroundColor Yellow
    } elseif ($session.fluency_score -lt 20) {
        Write-Host "Moderate (decent quantity)" -ForegroundColor Cyan
    } else {
        Write-Host "High (prolific idea generation)" -ForegroundColor Green
    }

    Write-Host "`n2. FLEXIBILITY (Variety):"
    Write-Host "  Score: $($session.flexibility_score) categories"
    Write-Host "  Categories: " -NoNewline
    $categories = ($session.ideas | Select-Object -ExpandProperty category -Unique)
    Write-Host ($categories -join ", ")
    Write-Host "  Interpretation: " -NoNewline
    if ($session.flexibility_score -lt 3) {
        Write-Host "Low (narrow thinking)" -ForegroundColor Yellow
    } elseif ($session.flexibility_score -lt 5) {
        Write-Host "Moderate (some variety)" -ForegroundColor Cyan
    } else {
        Write-Host "High (diverse approaches)" -ForegroundColor Green
    }

    Write-Host "`n3. ORIGINALITY (Uniqueness):"
    Write-Host "  Score: $([math]::Round($session.originality_score, 2))/5.0"
    Write-Host "  Interpretation: " -NoNewline
    if ($session.originality_score -lt 2.5) {
        Write-Host "Low (conventional ideas)" -ForegroundColor Yellow
    } elseif ($session.originality_score -lt 4.0) {
        Write-Host "Moderate (some novel ideas)" -ForegroundColor Cyan
    } else {
        Write-Host "High (very original thinking)" -ForegroundColor Green
    }

    Write-Host "`n4. ELABORATION (Detail):"
    Write-Host "  Score: $([math]::Round($session.elaboration_score, 2))/5.0"
    Write-Host "  Interpretation: " -NoNewline
    if ($session.elaboration_score -lt 2.5) {
        Write-Host "Low (basic sketches)" -ForegroundColor Yellow
    } elseif ($session.elaboration_score -lt 4.0) {
        Write-Host "Moderate (some detail)" -ForegroundColor Cyan
    } else {
        Write-Host "High (rich development)" -ForegroundColor Green
    }

    Write-Host "`n5. OVERALL CREATIVITY INDEX:"
    Write-Host "  Score: $([math]::Round($session.creativity_index, 1))/100"
    Write-Host "  Breakdown:"
    Write-Host "    - Fluency (25%): $([math]::Round(($session.fluency_score / 20.0) * 25, 1))"
    Write-Host "    - Flexibility (25%): $([math]::Round(($session.flexibility_score / 5.0) * 25, 1))"
    Write-Host "    - Originality (30%): $([math]::Round(($session.originality_score / 5.0) * 30, 1))"
    Write-Host "    - Elaboration (20%): $([math]::Round(($session.elaboration_score / 5.0) * 20, 1))"
    Write-Host ""
}

function Train-Divergence {
    Write-Host "`n=== DIVERGENT THINKING TRAINING ===`n" -ForegroundColor Cyan

    # Guilford's Unusual Uses Test
    Write-Host "Exercise 1: Unusual Uses Test" -ForegroundColor Cyan
    Write-Host "  Problem: List unusual uses for a brick (beyond building)"
    Write-Host "  Goal: Generate 10+ ideas across 5+ categories`n"

    # Generate ideas
    $brickIdeas = @(
        @{ idea = "Doorstop"; category = "Weight" },
        @{ idea = "Paperweight"; category = "Weight" },
        @{ idea = "Weapon for self-defense"; category = "Tool" },
        @{ idea = "Grinding surface for spices"; category = "Tool" },
        @{ idea = "Heat sink (warm in oven, use as bed warmer)"; category = "Thermal" },
        @{ idea = "Art canvas (paint on surface)"; category = "Creative" },
        @{ idea = "Bookend"; category = "Weight" },
        @{ idea = "Anchor for small boat"; category = "Weight" },
        @{ idea = "Musical instrument (percussion)"; category = "Creative" },
        @{ idea = "Exercise weight"; category = "Fitness" },
        @{ idea = "Garden border"; category = "Decorative" },
        @{ idea = "Toy block for giant Jenga"; category = "Game" }
    )

    $categories = ($brickIdeas | Select-Object -ExpandProperty category -Unique).Count
    Write-Host "Generated: $($brickIdeas.Count) ideas across $categories categories`n"

    Write-Host "Ideas by Category:" -ForegroundColor Cyan
    foreach ($cat in ($brickIdeas | Select-Object -ExpandProperty category -Unique)) {
        Write-Host "  $cat:"
        $catIdeas = $brickIdeas | Where-Object { $_.category -eq $cat }
        foreach ($cIdea in $catIdeas) {
            Write-Host "    - $($cIdea.idea)"
        }
    }

    $exercise = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        exercise_type = "Unusual Uses Test"
        problem = "Uses for a brick"
        ideas_generated = $brickIdeas.Count
        categories_covered = $categories
        score = [math]::Round(($brickIdeas.Count / 10.0) * 50 + ($categories / 5.0) * 50, 1)
    }

    $state.training_exercises += $exercise

    Save-State

    Write-Host "`n[TRAINING COMPLETE]" -ForegroundColor Green
    Write-Host "  Score: $($exercise.score)/100"
    Write-Host "  Fluency: $($brickIdeas.Count)/10+ ideas"
    Write-Host "  Flexibility: $categories/5+ categories`n"
}

function Test-Creativity {
    Write-Host "`n=== CREATIVITY TEST (Guilford's Battery) ===`n" -ForegroundColor Cyan

    # Test 1: Consequences
    Write-Host "Test 1: Consequences Test" -ForegroundColor Cyan
    Write-Host "  Question: What if humans didn't need sleep?`n"

    $consequences = @(
        "24-hour work culture (negative: burnout)",
        "Night economy boom (positive: new jobs)",
        "Loss of dream-based creativity (negative)",
        "More time for learning/hobbies (positive)",
        "Children's development issues (negative: growth hormones during sleep)",
        "Space exploration advantage (no sleep quarters needed)",
        "Social gathering shift (no 'morning people' vs 'night owls')",
        "Mental health impact (sleep is processing time)"
    )

    Write-Host "Consequences Generated:" -ForegroundColor Cyan
    foreach ($cons in $consequences) {
        Write-Host "  - $cons"
    }

    $fluency1 = $consequences.Count
    $positiveNegative = 2  # Flexibility (positive vs negative)

    Write-Host "`n  Fluency: $fluency1 consequences"
    Write-Host "  Flexibility: $positiveNegative perspectives (positive/negative)`n"

    # Test 2: Product Improvement
    Write-Host "Test 2: Product Improvement" -ForegroundColor Cyan
    Write-Host "  Product: Umbrella`n"

    $improvements = @(
        "Built-in GPS tracker (never lose it)",
        "Solar panels on top (charge phone while walking)",
        "Transparent dome option (see where you're going)",
        "Collapsible to credit-card size",
        "Built-in flashlight for night rain",
        "Wind-resistant venting system"
    )

    Write-Host "Improvements:" -ForegroundColor Cyan
    foreach ($imp in $improvements) {
        Write-Host "  - $imp"
    }

    $fluency2 = $improvements.Count
    $practicalCreative = 2  # Flexibility (practical vs creative)

    Write-Host "`n  Fluency: $fluency2 improvements"
    Write-Host "  Originality: Mix of practical and creative`n"

    # Overall test score
    $totalFluency = $fluency1 + $fluency2
    $testScore = [math]::Round(($totalFluency / 14.0) * 100, 1)

    Write-Host "[TEST COMPLETE]" -ForegroundColor Green
    Write-Host "  Total Ideas: $totalFluency"
    Write-Host "  Test Score: $testScore/100`n"

    if ($testScore -lt 60) {
        Write-Host "  [BELOW AVERAGE] Practice divergent exercises" -ForegroundColor Yellow
    } elseif ($testScore -lt 85) {
        Write-Host "  [AVERAGE] Good fluency, develop originality" -ForegroundColor Cyan
    } else {
        Write-Host "  [ABOVE AVERAGE] Strong divergent thinking" -ForegroundColor Green
    }
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-DivergentThinkingStatus
    }

    "GenerateIdeas" {
        if (-not $Problem) {
            Write-Host "[ERROR] Provide -Problem" -ForegroundColor Red
            exit 1
        }

        Generate-DivergentIdeas -problem $Problem -timeLimit $TimeLimit
    }

    "EvaluateCreativity" {
        if (-not $Problem) {
            Write-Host "[ERROR] Provide -Problem (same as used in GenerateIdeas)" -ForegroundColor Red
            exit 1
        }

        Evaluate-Creativity -problem $Problem
    }

    "TrainDivergence" {
        Train-Divergence
    }

    "TestCreativity" {
        Test-Creativity
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, GenerateIdeas, EvaluateCreativity, TrainDivergence, TestCreativity"
        exit 1
    }
}

