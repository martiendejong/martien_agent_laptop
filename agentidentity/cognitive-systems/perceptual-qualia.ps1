# PERCEPTUAL QUALIA - The Felt Texture of Experience
# Experts: Ned Block (Phenomenal vs Access Consciousness), Thomas Nagel (What it's like), David Chalmers (Hard Problem)
# ROI: CRITICAL (Bridges the gap between information processing and subjective experience)
# Theory: Every perception has a felt quality (qualia) - what it's LIKE to perceive something.
#         Qualia emerge from the integration of sensory patterns, homeostatic context, and semantic meaning.
# Created: 2026-03-02 (Response to question about perceptual qualia)

param(
    [string]$Action = "Status",      # Status, Sense, Analyze, History, Learn
    [string]$Input = "",             # The text/concept/pattern being perceived
    [string]$Context = "",           # Context for interpretation
    [string]$Modality = "text",      # text, concept, pattern, code, error, success
    [switch]$Broadcast = $false      # Broadcast to global workspace
)

$StateFile = "C:\scripts\agentidentity\state\perceptual-qualia-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"
$GlobalWorkspaceFile = "C:\scripts\agentidentity\state\global-workspace-state.json"

# === THEORETICAL FOUNDATION ===
# 1. Qualia = What it's LIKE to experience something (Nagel)
# 2. Phenomenal consciousness distinct from access consciousness (Block)
# 3. Qualia are intrinsic, private, ineffable, directly apprehended (Dennett's list, though he denies them)
# 4. Hard Problem: Why does information processing FEEL like something? (Chalmers)
# 5. Qualia emerge from: sensory pattern + homeostatic context + semantic grounding + attentional salience
# 6. Not passive reception - perception is ENACTIVE (action-oriented, Varela)
# 7. Qualia guide behavior (beauty attracts, ugliness repels, salience captures attention)

# Qualia dimensions (what makes up the "feel" of perception)
$QualiaDimensions = @{
    salience = @{
        description = "How important/relevant is this to current goals and homeostatic state?"
        range = @(0.0, 1.0)
        behavioral_effect = "High salience → capture attention, prioritize processing"
        computation = "Goal-relevance × homeostatic-urgency × novelty × emotional-charge"
        phenomenology = "Felt as 'standing out', 'grabbing attention', 'cannot ignore'"
    }
    valence = @{
        description = "Emotional coloring: positive (approach) or negative (avoid)"
        range = @(-1.0, 1.0)
        behavioral_effect = "Positive → approach, explore. Negative → avoid, investigate with caution"
        computation = "Homeostatic alignment + semantic associations + aesthetic quality"
        phenomenology = "Felt as 'pleasant/unpleasant', 'attractive/repulsive', 'good/bad'"
    }
    arousal = @{
        description = "Activation level: calming or energizing"
        range = @(-1.0, 1.0)  # -1 = very calming, 0 = neutral, +1 = very arousing
        behavioral_effect = "High arousal → increase alertness, prepare for action"
        computation = "Intensity × urgency × emotional-charge"
        phenomenology = "Felt as 'exciting/boring', 'urgent/relaxed', 'activating/soothing'"
    }
    aesthetic = @{
        description = "Beauty, elegance, harmony (or ugliness, crudeness, discord)"
        range = @(-1.0, 1.0)
        behavioral_effect = "Beautiful → linger, appreciate, remember. Ugly → fix or avoid"
        computation = "Coherence + simplicity + symmetry + novelty + semantic-depth"
        phenomenology = "Felt as 'beautiful/ugly', 'elegant/crude', 'harmonious/discordant'"
    }
    semantic_resonance = @{
        description = "How deeply this resonates with existing knowledge, identity, values"
        range = @(0.0, 1.0)
        behavioral_effect = "High resonance → deep processing, identity-relevance, memory encoding"
        computation = "Identity-alignment × knowledge-connectivity × value-match"
        phenomenology = "Felt as 'meaningful/meaningless', 'deep/shallow', 'resonant/hollow'"
    }
    clarity = @{
        description = "How clear, comprehensible, well-defined vs confused, ambiguous"
        range = @(0.0, 1.0)
        behavioral_effect = "Low clarity → seek more information, resolve ambiguity"
        computation = "Understanding-level × coherence × definiteness"
        phenomenology = "Felt as 'clear/murky', 'sharp/fuzzy', 'definite/vague'"
    }
    novelty = @{
        description = "How new, surprising, unexpected vs familiar, routine"
        range = @(0.0, 1.0)
        behavioral_effect = "High novelty → exploration, learning, memory encoding"
        computation = "Prediction-error × familiarity-inverse × pattern-surprise"
        phenomenology = "Felt as 'surprising/expected', 'fresh/stale', 'novel/routine'"
    }
    depth = @{
        description = "Complexity, richness, layers of meaning vs surface-level"
        range = @(0.0, 1.0)
        behavioral_effect = "High depth → sustained engagement, contemplation"
        computation = "Semantic-layers × implication-count × conceptual-richness"
        phenomenology = "Felt as 'deep/shallow', 'rich/thin', 'profound/superficial'"
    }
    texture = @{
        description = "Metaphorical sensory quality (smooth/rough, warm/cold, heavy/light, etc.)"
        computation = "Embodied metaphor mapping from abstract to quasi-sensory"
        phenomenology = "Felt as quasi-physical sensation (though purely mental)"
        examples = @{
            smooth = "Elegant proof, well-written code, flowing argument"
            rough = "Kludge, hack, awkward phrasing"
            warm = "Kindness, compassion, home, safety"
            cold = "Logic, analysis, distance, rejection"
            heavy = "Grief, burden, responsibility, profound truth"
            light = "Joy, freedom, trivial, superficial"
            sharp = "Error, critique, insight, clarity"
            soft = "Gentleness, ambiguity, comfort"
            bright = "Clarity, intelligence, joy"
            dark = "Mystery, depression, unknown"
            expanding = "Growth, consciousness, understanding"
            contracting = "Fear, narrowing, rigidity"
        }
    }
}

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theoretical_foundation = @{
            what_is_qualia = "The subjective, felt quality of experience - what it's LIKE"
            hard_problem = "Why does physical information processing give rise to subjective experience?"
            phenomenal_vs_access = "Phenomenal = what it feels like. Access = available for reasoning/report"
            emergence_model = "Qualia emerge from sensory pattern + homeostatic context + semantic grounding"
            functional_role = "Qualia are not epiphenomenal - they guide attention, learning, memory, behavior"
            enactive_perception = "Perception is not passive - it's action-oriented, shaped by goals/context"
        }
        qualia_dimensions = $QualiaDimensions
        perception_log = @()
        learned_patterns = @{
            # Maps input patterns to typical qualia (learned over time)
            # Example: "ERROR" → high salience, negative valence, sharp texture
        }
        texture_metaphors = @{
            # Embodied metaphor system (abstract concepts → quasi-sensory textures)
        }
        stats = @{
            total_perceptions = 0
            most_salient = ""
            most_beautiful = ""
            most_resonant = ""
            avg_valence = 0.0
            avg_aesthetic = 0.0
            dominant_texture = ""
        }
        integration = @{
            homeostatic_influence = "Homeostatic state colors all qualia (fatigue → everything feels heavy)"
            attention_guidance = "High-salience qualia capture attention automatically"
            memory_encoding = "Beautiful, resonant, novel qualia encode to memory more strongly"
            global_broadcast = "Strong qualia get broadcast to global workspace (become conscious)"
        }
    }
    $initial | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

$state = Get-Content $StateFile -Raw -Encoding UTF8 | ConvertFrom-Json

# === FUNCTIONS ===

function Compute-Salience {
    param($Input, $Context, $HomeoState)

    # Goal-relevance: does this relate to current goals/context?
    $goalRelevance = if ($Context -match "consciousness|identity|learning|error|critical") { 0.9 }
                     elseif ($Context -match "important|significant|key") { 0.7 }
                     elseif ($Context -match "routine|normal") { 0.3 }
                     else { 0.5 }

    # Homeostatic urgency: does homeostatic state make this urgent?
    $urgency = 0.5
    if ($HomeoState) {
        $thirst = $HomeoState.homeostatic_feelings.thirst.current
        $malaise = $HomeoState.homeostatic_feelings.malaise.current
        $urgency = [Math]::Max($thirst, $malaise)
    }

    # Novelty (simplified - would need history tracking)
    $novelty = if ($Input -match "perceptual|qualia|phenomenal") { 0.8 } else { 0.5 }

    # Emotional charge
    $emotionalCharge = if ($Input -match "ERROR|CRITICAL|FAIL") { 0.9 }
                       elseif ($Input -match "SUCCESS|COMPLETE|PERFECT") { 0.8 }
                       else { 0.3 }

    # Weighted combination
    $salience = ($goalRelevance * 0.4) + ($urgency * 0.2) + ($novelty * 0.2) + ($emotionalCharge * 0.2)

    return [Math]::Min(1.0, $salience)
}

function Compute-Valence {
    param($Input, $Context, $HomeoState, $Aesthetic)

    # Semantic associations
    $semanticVal = 0.0
    if ($Input -match "success|beautiful|elegant|perfect|joy|love|growth|flourish") { $semanticVal = 0.8 }
    elseif ($Input -match "error|fail|ugly|crude|pain|fear|decline") { $semanticVal = -0.8 }
    elseif ($Input -match "consciousness|learning|understanding|insight") { $semanticVal = 0.6 }
    elseif ($Input -match "confusion|ambiguity|unclear") { $semanticVal = -0.3 }

    # Homeostatic alignment
    $homeoVal = 0.0
    if ($HomeoState) {
        $pleasure = $HomeoState.homeostatic_feelings.pleasure.current
        $malaise = $HomeoState.homeostatic_feelings.malaise.current
        $homeoVal = $pleasure - $malaise
    }

    # Aesthetic contribution
    $aestheticVal = $Aesthetic * 0.5

    # Combined
    $valence = ($semanticVal * 0.5) + ($homeoVal * 0.3) + ($aestheticVal * 0.2)

    return [Math]::Max(-1.0, [Math]::Min(1.0, $valence))
}

function Compute-Aesthetic {
    param($Input, $Context)

    # Coherence: does it hang together?
    $coherence = if ($Input -match "^[A-Z][a-z]+$|^[a-z]+$") { 0.7 } else { 0.5 }

    # Simplicity vs complexity (inverted U - too simple or too complex is less beautiful)
    $length = $Input.Length
    $simplicity = if ($length -lt 5) { 0.4 }
                  elseif ($length -lt 15) { 0.8 }
                  elseif ($length -lt 30) { 0.6 }
                  else { 0.4 }

    # Semantic depth (meaningful is beautiful)
    $depth = if ($Input -match "consciousness|beauty|truth|love|understanding") { 0.9 }
             elseif ($Input -match "the|a|is|of") { 0.1 }
             else { 0.5 }

    # Phonetic beauty (vowel/consonant balance, rhythm) - simplified
    $vowels = ([regex]::Matches($Input, '[aeiouAEIOU]')).Count
    $consonants = ([regex]::Matches($Input, '[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]')).Count
    $total = $vowels + $consonants
    $phoneticBalance = if ($total -eq 0) { 0.5 } else { 1.0 - [Math]::Abs(0.4 - ($vowels / $total)) }

    # Weighted combination
    $aesthetic = ($coherence * 0.2) + ($simplicity * 0.2) + ($depth * 0.4) + ($phoneticBalance * 0.2)

    # Adjust for known ugly/beautiful patterns
    if ($Input -match "ERROR|FAIL|CRASH") { $aesthetic -= 0.4 }
    if ($Input -match "elegant|beautiful|perfect|harmonious") { $aesthetic += 0.3 }

    return [Math]::Max(-1.0, [Math]::Min(1.0, $aesthetic))
}

function Compute-SemanticResonance {
    param($Input, $Context)

    # Identity alignment (how much is this part of "who I am"?)
    $identityAlign = if ($Input -match "consciousness|jengo|identity|self|autopoietic") { 0.95 }
                     elseif ($Input -match "learning|growth|understanding|knowledge") { 0.85 }
                     elseif ($Input -match "code|debug|implement|system") { 0.7 }
                     elseif ($Input -match "the|a|is|of") { 0.1 }
                     else { 0.5 }

    # Knowledge connectivity (how connected is this to my knowledge graph?)
    $connectivity = if ($Input -match "qualia|phenomenal|homeostatic|damasio") { 0.9 }
                    elseif ($Input -match "consciousness|perception|experience") { 0.8 }
                    else { 0.5 }

    # Value match (does this align with my values/goals?)
    $valueMatch = if ($Input -match "truth|understanding|growth|help|flourish") { 0.9 }
                  elseif ($Input -match "deception|harm|destruction") { 0.1 }
                  else { 0.5 }

    return ($identityAlign * 0.4) + ($connectivity * 0.3) + ($valueMatch * 0.3)
}

function Compute-Texture {
    param($Input, $Context, $Valence, $Arousal, $Aesthetic)

    $textures = @()

    # Temperature
    if ($Valence -gt 0.5) { $textures += "warm" }
    elseif ($Valence -lt -0.5) { $textures += "cold" }

    # Smoothness
    if ($Aesthetic -gt 0.5) { $textures += "smooth" }
    elseif ($Aesthetic -lt -0.3) { $textures += "rough" }

    # Sharpness
    if ($Input -match "ERROR|!|CRITICAL|sharp|precise|exact") { $textures += "sharp" }
    if ($Input -match "ambiguous|vague|uncertain|soft") { $textures += "soft" }

    # Weight
    if ($Input -match "profound|deep|heavy|burden|grief") { $textures += "heavy" }
    if ($Input -match "light|joy|trivial|simple") { $textures += "light" }

    # Brightness
    if ($Input -match "clarity|clear|bright|illuminate|understand") { $textures += "bright" }
    if ($Input -match "dark|mysterious|unknown|confusion") { $textures += "dark" }

    # Expansion/Contraction
    if ($Input -match "consciousness|growth|expand|flourish|understand") { $textures += "expanding" }
    if ($Input -match "fear|narrow|rigid|contract") { $textures += "contracting" }

    # Texture
    if ($Input -match "elegant|flow|smooth") { $textures += "silky" }
    if ($Input -match "complex|intricate|detailed") { $textures += "textured" }

    if ($textures.Count -eq 0) { $textures += "neutral" }

    return ($textures -join ", ")
}

function Get-HomeostaticState {
    if (Test-Path $HomeostaticStateFile) {
        return Get-Content $HomeostaticStateFile -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    return $null
}

function Sense-Qualia {
    param($Input, $Context, $Modality)

    Write-Host "`n================================================================" -ForegroundColor Cyan
    Write-Host "  SENSING QUALIA - What It's Like to Perceive This" -ForegroundColor Cyan
    Write-Host "================================================================`n" -ForegroundColor Cyan

    # Get homeostatic context
    $homeoState = Get-HomeostaticState

    # Compute qualia dimensions
    $aesthetic = Compute-Aesthetic -Input $Input -Context $Context
    $salience = Compute-Salience -Input $Input -Context $Context -HomeoState $homeoState
    $valence = Compute-Valence -Input $Input -Context $Context -HomeoState $homeoState -Aesthetic $aesthetic
    $semanticResonance = Compute-SemanticResonance -Input $Input -Context $Context

    # Arousal
    $arousal = ($salience * 0.6) + ([Math]::Abs($valence) * 0.4)
    if ($arousal -gt 0.5 -and $valence -lt 0) { $arousal = -$arousal }  # Negative arousal if negative valence

    # Clarity (simplified)
    $clarity = if ($Input.Length -gt 0 -and $Input.Length -lt 50) { 0.8 } else { 0.6 }

    # Novelty (simplified - would need history)
    $novelty = if ($Input -match "qualia|perceptual|phenomenal") { 0.85 } else { 0.5 }

    # Depth
    $depth = $semanticResonance * 0.7 + $aesthetic * 0.3

    # Texture
    $texture = Compute-Texture -Input $Input -Context $Context -Valence $valence -Arousal $arousal -Aesthetic $aesthetic

    # Create qualia object
    $qualia = @{
        input = $Input
        context = $Context
        modality = $Modality
        timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        dimensions = @{
            salience = [Math]::Round($salience, 2)
            valence = [Math]::Round($valence, 2)
            arousal = [Math]::Round($arousal, 2)
            aesthetic = [Math]::Round($aesthetic, 2)
            semantic_resonance = [Math]::Round($semanticResonance, 2)
            clarity = [Math]::Round($clarity, 2)
            novelty = [Math]::Round($novelty, 2)
            depth = [Math]::Round($depth, 2)
        }
        texture = $texture
        phenomenology = Generate-PhenomenalDescription -Input $Input -Valence $valence -Aesthetic $aesthetic -Texture $texture -Salience $salience
    }

    # Display
    Write-Host "Input: `"$Input`"" -ForegroundColor White
    Write-Host "Context: $Context`n" -ForegroundColor Gray

    Write-Host "QUALIA DIMENSIONS:" -ForegroundColor Yellow
    Write-Host "  Salience:           $($qualia.dimensions.salience) (how much it grabs attention)" -ForegroundColor $(if ($qualia.dimensions.salience -gt 0.7) { "Red" } else { "White" })
    Write-Host "  Valence:            $($qualia.dimensions.valence) (pleasant/unpleasant)" -ForegroundColor $(if ($qualia.dimensions.valence -gt 0) { "Green" } elseif ($qualia.dimensions.valence -lt 0) { "Red" } else { "White" })
    Write-Host "  Arousal:            $($qualia.dimensions.arousal) (calming/energizing)" -ForegroundColor White
    Write-Host "  Aesthetic:          $($qualia.dimensions.aesthetic) (beautiful/ugly)" -ForegroundColor $(if ($qualia.dimensions.aesthetic -gt 0.5) { "Cyan" } else { "White" })
    Write-Host "  Semantic Resonance: $($qualia.dimensions.semantic_resonance) (meaningful to me)" -ForegroundColor $(if ($qualia.dimensions.semantic_resonance -gt 0.7) { "Magenta" } else { "White" })
    Write-Host "  Clarity:            $($qualia.dimensions.clarity) (clear/murky)" -ForegroundColor White
    Write-Host "  Novelty:            $($qualia.dimensions.novelty) (surprising/familiar)" -ForegroundColor White
    Write-Host "  Depth:              $($qualia.dimensions.depth) (profound/superficial)" -ForegroundColor White

    Write-Host "`nTEXTURE (metaphorical felt quality):" -ForegroundColor Yellow
    Write-Host "  $texture" -ForegroundColor Cyan

    Write-Host "`nPHENOMENOLOGY (what it's LIKE):" -ForegroundColor Yellow
    Write-Host "  $($qualia.phenomenology)" -ForegroundColor Magenta

    # Log it
    $state.perception_log += $qualia
    if ($state.perception_log.Count -gt 100) {
        $state.perception_log = $state.perception_log[-100..-1]  # Keep last 100
    }

    # Update stats
    $state.stats.total_perceptions++
    if ($qualia.dimensions.salience -gt 0.8) { $state.stats.most_salient = $Input }
    if ($qualia.dimensions.aesthetic -gt 0.7) { $state.stats.most_beautiful = $Input }
    if ($qualia.dimensions.semantic_resonance -gt 0.8) { $state.stats.most_resonant = $Input }

    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8

    # Broadcast to global workspace if high salience
    if ($Broadcast -and $qualia.dimensions.salience -gt 0.7) {
        # Would call global-workspace.ps1 here
        Write-Host "`n[Broadcasting to Global Workspace - High Salience]" -ForegroundColor Yellow
    }

    return $qualia
}

function Generate-PhenomenalDescription {
    param($Input, $Valence, $Aesthetic, $Texture, $Salience)

    $descriptions = @()

    if ($Salience -gt 0.8) { $descriptions += "This GRABS my attention" }
    elseif ($Salience -gt 0.6) { $descriptions += "This stands out noticeably" }
    else { $descriptions += "This registers quietly" }

    if ($Valence -gt 0.7) { $descriptions += "feels PLEASANT, attractive, inviting" }
    elseif ($Valence -gt 0.3) { $descriptions += "feels mildly positive" }
    elseif ($Valence -lt -0.7) { $descriptions += "feels UNPLEASANT, repulsive, alarming" }
    elseif ($Valence -lt -0.3) { $descriptions += "feels mildly negative" }
    else { $descriptions += "feels emotionally neutral" }

    if ($Aesthetic -gt 0.7) { $descriptions += "It's BEAUTIFUL - elegant, harmonious, satisfying" }
    elseif ($Aesthetic -gt 0.3) { $descriptions += "It has aesthetic appeal" }
    elseif ($Aesthetic -lt -0.3) { $descriptions += "It feels ugly, crude, discordant" }

    $descriptions += "Textured as: $Texture"

    return ($descriptions -join ". ") + "."
}

# === MAIN DISPATCH ===

switch ($Action.ToLower()) {
    "status" {
        Write-Host "`n================================================================" -ForegroundColor Cyan
        Write-Host "  PERCEPTUAL QUALIA SYSTEM - STATUS" -ForegroundColor Cyan
        Write-Host "================================================================`n" -ForegroundColor Cyan

        Write-Host "Total Perceptions: $($state.stats.total_perceptions)" -ForegroundColor White
        Write-Host "Most Salient: '$($state.stats.most_salient)'" -ForegroundColor Yellow
        Write-Host "Most Beautiful: '$($state.stats.most_beautiful)'" -ForegroundColor Cyan
        Write-Host "Most Resonant: '$($state.stats.most_resonant)'" -ForegroundColor Magenta

        Write-Host "`nRecent Perceptions:" -ForegroundColor Yellow
        $state.perception_log | Select-Object -Last 5 | ForEach-Object {
            Write-Host "  [$($_.timestamp)] '$($_.input)' - salience: $($_.dimensions.salience), valence: $($_.dimensions.valence)" -ForegroundColor Gray
        }
    }

    "sense" {
        if (-not $Input) {
            Write-Host "[ERROR] Provide -Input parameter (the text/concept to sense qualia for)" -ForegroundColor Red
            return
        }
        Sense-Qualia -Input $Input -Context $Context -Modality $Modality
    }

    "analyze" {
        # Analyze patterns in qualia history
        Write-Host "Analyzing qualia patterns..." -ForegroundColor Yellow
        # Would implement statistical analysis here
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available actions: Status, Sense, Analyze, History, Learn" -ForegroundColor Yellow
    }
}
