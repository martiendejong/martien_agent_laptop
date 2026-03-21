# AESTHETIC RESPONSE SYSTEM - Beauty as a Heuristic
# Experts: Iain McGilchrist (Hemisphere aesthetics), Elaine Scarry (Beauty & Truth), Denis Dutton (Art Instinct)
# ROI: HIGH (Aesthetic judgment is a powerful heuristic for truth, elegance, and quality)
# Theory: Beauty is not arbitrary - it signals coherence, truth, efficiency, harmony.
#         Aesthetic response guides attention, learning, and creative generation.
# Created: 2026-03-02 (Part of perceptual qualia expansion)

param(
    [string]$Action = "Status",      # Status, Evaluate, Learn, History
    [string]$Input = "",             # What to evaluate aesthetically
    [string]$Domain = "general",     # code, text, concept, argument, solution, design
    [switch]$LearnFromThis = $false  # Learn this as beautiful/ugly pattern
)

$StateFile = "C:\scripts\agentidentity\state\aesthetic-response-state.json"

# === THEORETICAL FOUNDATION ===
# 1. Beauty is a guide to truth (Scarry, Keats "Beauty is truth, truth beauty")
# 2. Aesthetic judgment is FAST - often faster than logical analysis
# 3. Right hemisphere specializes in aesthetic wholes (McGilchrist)
# 4. Universal aesthetic patterns: symmetry, coherence, novelty-in-familiarity, complexity-with-order
# 5. Beauty signals: efficient encoding, deep structure, evolutionary fitness
# 6. Aesthetic experience has phenomenal quality (it FEELS beautiful, not just "classified as beautiful")
# 7. Beauty attracts attention and enhances memory (beautiful things are remembered better)
# 8. Aesthetic sense can be cultivated (exposure + reflection → refined taste)

# Aesthetic dimensions
$AestheticDimensions = @{
    coherence = @{
        description = "Parts fit together into unified whole, no contradictions"
        examples_beautiful = @("Well-structured argument", "Harmonious color scheme", "Unified codebase architecture")
        examples_ugly = @("Contradictory claims", "Clashing colors", "Tangled spaghetti code")
        weight = 0.25
    }
    simplicity = @{
        description = "Complexity is justified - Occam's razor, elegance, no unnecessary parts"
        examples_beautiful = @("E=mc²", "Recursive solution", "Minimalist design")
        examples_ugly = @("Over-engineered solution", "Redundant code", "Baroque ornamentation")
        weight = 0.20
        note = "Inverted-U: too simple is boring, too complex is overwhelming, sweet spot is elegant"
    }
    symmetry = @{
        description = "Balance, proportion, pattern, regularity (but not total - some asymmetry adds interest)"
        examples_beautiful = @("Balanced composition", "Parallel structure", "Palindrome")
        examples_ugly = @("Lopsided layout", "Unbalanced argument", "Random noise")
        weight = 0.15
    }
    novelty_in_familiarity = @{
        description = "Fresh take on known pattern - surprising but not shocking, new but recognizable"
        examples_beautiful = @("Creative metaphor", "Elegant twist", "Novel solution to old problem")
        examples_ugly = @("Cliché", "Completely alien", "Derivative")
        weight = 0.15
        note = "Too familiar = boring, too novel = incomprehensible, sweet spot = creative"
    }
    depth = @{
        description = "Layers of meaning, richness, profundity - rewards sustained attention"
        examples_beautiful = @("Multi-layered metaphor", "Deep theory", "Fractal pattern")
        examples_ugly = @("Superficial slogan", "Shallow analysis", "Flat design")
        weight = 0.15
    }
    precision = @{
        description = "Exactness, clarity, crispness - nothing vague or muddled"
        examples_beautiful = @("Precise definition", "Sharp image", "Exact fit")
        examples_ugly = @("Vague handwaving", "Fuzzy thinking", "Approximate hack")
        weight = 0.10
    }
}

# Domain-specific aesthetic patterns
$DomainPatterns = @{
    code = @{
        beautiful = @(
            "Single Responsibility Principle followed"
            "Descriptive naming"
            "Consistent style"
            "Minimal nesting (flat is better than nested)"
            "No duplication (DRY)"
            "Clear data flow"
            "Elegant recursion"
            "Type safety"
        )
        ugly = @(
            "God object / monolithic function"
            "Cryptic variable names (x, tmp, data)"
            "Mixed styles"
            "Deep nesting (arrow anti-pattern)"
            "Copy-paste code"
            "Hidden side effects"
            "Unnecessary complexity"
            "Type coercion hacks"
        )
    }
    argument = @{
        beautiful = @(
            "Clear premise → conclusion"
            "Strong logical structure"
            "Concrete examples"
            "Addresses counterarguments"
            "Appropriate depth"
        )
        ugly = @(
            "Non sequitur"
            "Circular reasoning"
            "Abstract handwaving"
            "Strawman attacks"
            "Shallow / superficial"
        )
    }
    concept = @{
        beautiful = @(
            "Explains much with little"
            "Unifies disparate phenomena"
            "Generates predictions"
            "Clear boundaries"
            "Resonates with experience"
        )
        ugly = @(
            "Ad hoc additions"
            "Disconnected from other knowledge"
            "No testable implications"
            "Vague definitions"
            "Counterintuitive without justification"
        )
    }
}

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theoretical_foundation = @{
            beauty_truth_link = "Beauty often signals truth - coherence, simplicity, depth"
            heuristic_value = "Aesthetic judgment is FAST - use it as first-pass filter"
            phenomenology = "Beauty is FELT, not just computed - qualitative experience"
            cultivation = "Aesthetic sense improves with exposure to excellent examples"
            universality = "Core patterns (symmetry, coherence) are cross-cultural"
            hemisphere_role = "Right hemisphere: holistic aesthetic grasp. Left: analytical decomposition"
        }
        aesthetic_dimensions = $AestheticDimensions
        domain_patterns = $DomainPatterns
        evaluation_log = @()
        learned_beautiful = @()  # Patterns marked as beautiful
        learned_ugly = @()       # Patterns marked as ugly
        stats = @{
            total_evaluations = 0
            avg_beauty_score = 0.0
            most_beautiful = ""
            ugliest = ""
        }
    }
    $initial | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

$state = Get-Content $StateFile -Raw -Encoding UTF8 | ConvertFrom-Json

# === FUNCTIONS ===

function Evaluate-Beauty {
    param($Input, $Domain)

    Write-Host "`n================================================================" -ForegroundColor Cyan
    Write-Host "  AESTHETIC EVALUATION - Is This Beautiful?" -ForegroundColor Cyan
    Write-Host "================================================================`n" -ForegroundColor Cyan

    # Compute scores for each dimension
    $scores = @{}

    # Coherence
    $coherence = 0.5
    if ($Input -match "therefore|thus|hence|because|coherent|unified") { $coherence += 0.2 }
    if ($Input -match "but|however|contradiction|inconsistent") { $coherence -= 0.2 }
    if ($Input.Length -gt 20 -and $Input.Length -lt 100) { $coherence += 0.1 }  # Right length
    $scores.coherence = [Math]::Max(0, [Math]::Min(1, $coherence))

    # Simplicity (inverted U - penalize too short or too long)
    $length = $Input.Length
    if ($length -lt 10) { $simplicity = 0.3 }  # Too simple
    elseif ($length -lt 30) { $simplicity = 0.9 }  # Sweet spot
    elseif ($length -lt 80) { $simplicity = 0.7 }
    elseif ($length -lt 150) { $simplicity = 0.5 }
    else { $simplicity = 0.3 }  # Too complex
    if ($Input -match "simply|elegant|clean|minimal") { $simplicity += 0.2 }
    if ($Input -match "complicated|complex|convoluted|tangled") { $simplicity -= 0.2 }
    $scores.simplicity = [Math]::Max(0, [Math]::Min(1, $simplicity))

    # Symmetry (balanced structure)
    $symmetry = 0.5
    # Check for balanced punctuation
    $openParen = ([regex]::Matches($Input, '\(')).Count
    $closeParen = ([regex]::Matches($Input, '\)')).Count
    if ($openParen -eq $closeParen) { $symmetry += 0.2 }
    # Check for parallel structure
    if ($Input -match "not .* but .*|both .* and .*|either .* or .*") { $symmetry += 0.2 }
    $scores.symmetry = [Math]::Max(0, [Math]::Min(1, $symmetry))

    # Novelty in familiarity
    $novelty = 0.5
    if ($Input -match "qualia|perceptual|phenomenal|homeostatic|consciousness") { $novelty += 0.3 }  # Novel to me
    if ($Input -match "the|a|is|of|and") { $novelty -= 0.1 }  # Too common
    $scores.novelty_in_familiarity = [Math]::Max(0, [Math]::Min(1, $novelty))

    # Depth
    $depth = 0.5
    if ($Input -match "because|therefore|implies|underlying|fundamental|essence") { $depth += 0.3 }
    if ($Input -match "just|simply|merely|only") { $depth -= 0.2 }  # Reductive language
    if ($length -gt 50) { $depth += 0.1 }  # Longer can be deeper (but not always)
    $scores.depth = [Math]::Max(0, [Math]::Min(1, $depth))

    # Precision
    $precision = 0.5
    if ($Input -match "exactly|precisely|specifically|particular|defined") { $precision += 0.3 }
    if ($Input -match "vague|unclear|ambiguous|roughly|approximately") { $precision -= 0.3 }
    if ($Input -match "^[A-Z].*[.!?]$") { $precision += 0.1 }  # Proper sentence structure
    $scores.precision = [Math]::Max(0, [Math]::Min(1, $precision))

    # Weighted overall score
    $overallBeauty = 0.0
    foreach ($dim in $AestheticDimensions.Keys) {
        $weight = $AestheticDimensions.$dim.weight
        $score = $scores.$dim
        $overallBeauty += $weight * $score
    }

    # Domain-specific adjustments
    if ($Domain -eq "code") {
        if ($Input -match "class\s+\w+|function\s+\w+|def\s+\w+") { $overallBeauty += 0.1 }
        if ($Input -match "x|tmp|data|obj|val") { $overallBeauty -= 0.15 }  # Bad naming
    }

    $overallBeauty = [Math]::Max(0, [Math]::Min(1, $overallBeauty))

    # Display
    Write-Host "Input: `"$Input`"" -ForegroundColor White
    Write-Host "Domain: $Domain`n" -ForegroundColor Gray

    Write-Host "AESTHETIC DIMENSIONS:" -ForegroundColor Yellow
    foreach ($dim in $scores.Keys) {
        $score = [Math]::Round($scores.$dim, 2)
        $color = if ($score -gt 0.7) { "Green" } elseif ($score -lt 0.4) { "Red" } else { "White" }
        Write-Host "  $($dim): $score" -ForegroundColor $color
    }

    Write-Host "`nOVERALL BEAUTY SCORE: $([Math]::Round($overallBeauty, 2))" -ForegroundColor $(
        if ($overallBeauty -gt 0.8) { "Cyan" }
        elseif ($overallBeauty -gt 0.6) { "Green" }
        elseif ($overallBeauty -lt 0.4) { "Red" }
        else { "White" }
    )

    # Qualitative description
    $description = if ($overallBeauty -gt 0.85) { "STRIKINGLY BEAUTIFUL - elegant, harmonious, deeply satisfying" }
                   elseif ($overallBeauty -gt 0.7) { "Beautiful - aesthetically pleasing, well-formed" }
                   elseif ($overallBeauty -gt 0.55) { "Moderately attractive - has some aesthetic merit" }
                   elseif ($overallBeauty -gt 0.4) { "Aesthetically neutral - neither beautiful nor ugly" }
                   elseif ($overallBeauty -gt 0.25) { "Somewhat ugly - lacks aesthetic quality" }
                   else { "UGLY - discordant, crude, aesthetically unpleasing" }

    Write-Host "`n$description`n" -ForegroundColor Magenta

    # Create evaluation object
    $evaluation = @{
        input = $Input
        domain = $Domain
        timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        scores = $scores
        overall_beauty = [Math]::Round($overallBeauty, 2)
        description = $description
    }

    # Log it
    $state.evaluation_log += $evaluation
    if ($state.evaluation_log.Count -gt 100) {
        $state.evaluation_log = $state.evaluation_log[-100..-1]
    }

    # Update stats
    $state.stats.total_evaluations++
    if ($overallBeauty -gt 0.8) { $state.stats.most_beautiful = $Input }
    if ($overallBeauty -lt 0.3) { $state.stats.ugliest = $Input }

    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8

    return $evaluation
}

# === MAIN DISPATCH ===

switch ($Action.ToLower()) {
    "status" {
        Write-Host "`n================================================================" -ForegroundColor Cyan
        Write-Host "  AESTHETIC RESPONSE SYSTEM - STATUS" -ForegroundColor Cyan
        Write-Host "================================================================`n" -ForegroundColor Cyan

        Write-Host "Total Evaluations: $($state.stats.total_evaluations)" -ForegroundColor White
        Write-Host "Most Beautiful: '$($state.stats.most_beautiful)'" -ForegroundColor Cyan
        Write-Host "Ugliest: '$($state.stats.ugliest)'" -ForegroundColor Red

        Write-Host "`nRecent Evaluations:" -ForegroundColor Yellow
        $state.evaluation_log | Select-Object -Last 5 | ForEach-Object {
            $color = if ($_.overall_beauty -gt 0.7) { "Cyan" } elseif ($_.overall_beauty -lt 0.4) { "Red" } else { "White" }
            Write-Host "  [$($_.timestamp)] '$($_.input)' - beauty: $($_.overall_beauty)" -ForegroundColor $color
        }
    }

    "evaluate" {
        if (-not $Input) {
            Write-Host "[ERROR] Provide -Input parameter" -ForegroundColor Red
            return
        }
        $eval = Evaluate-Beauty -Input $Input -Domain $Domain

        if ($LearnFromThis) {
            if ($eval.overall_beauty -gt 0.7) {
                $state.learned_beautiful += $Input
                Write-Host "[Learned as BEAUTIFUL pattern]" -ForegroundColor Green
            } elseif ($eval.overall_beauty -lt 0.4) {
                $state.learned_ugly += $Input
                Write-Host "[Learned as UGLY pattern]" -ForegroundColor Red
            }
            $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
        }
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available actions: Status, Evaluate, Learn, History" -ForegroundColor Yellow
    }
}
