param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Analyze', 'GetPatterns', 'GenerateBrief')]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$ProjectName,

    [Parameter(Mandatory=$false)]
    [ValidateSet('website', 'copy', 'visual', 'mixed')]
    [string]$InputType = 'mixed',

    [Parameter(Mandatory=$false)]
    [string]$InputUrl,

    [Parameter(Mandatory=$false)]
    [string]$InputText,

    [Parameter(Mandatory=$false)]
    [string]$InputImagePath,

    [Parameter(Mandatory=$false)]
    [string]$Context,

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "E:\jengo\documents\temp\vibe-analysis-$(Get-Date -Format 'yyyyMMdd-HHmmss').md",

    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# File paths
$StateDir = "C:\scripts\agentidentity\state"
$VibeStateFile = Join-Path $StateDir "vibe-sensing-state.json"
$PatternLibraryFile = "C:\scripts\agentidentity\pattern-library.json"

# Ensure state file exists
if (!(Test-Path $VibeStateFile)) {
    @{
        version = "1.0"
        analyses = @()
        learned_patterns = @{
            archetypes = @{}
            tone_markers = @{}
            visual_patterns = @{}
        }
    } | ConvertTo-Json -Depth 10 | Set-Content $VibeStateFile -Encoding UTF8
}

# Load pattern library (or initialize)
if (!(Test-Path $PatternLibraryFile)) {
    # Initialize with base patterns
    $patternLibrary = @{
        archetypes = @{
            hero = @{
                linguistic = @("overcome", "master", "excel", "achieve", "conquer", "victory", "champion", "triumph")
                visual = @("bold colors", "high contrast", "angular shapes", "strong hierarchy")
                energy = "high, motivating, forward-moving"
            }
            sage = @{
                linguistic = @("understand", "discover", "learn", "wisdom", "knowledge", "insight", "analyze", "explore")
                visual = @("cool colors", "clean lines", "minimal decoration", "generous whitespace")
                energy = "calm, contemplative, authoritative"
            }
            creator = @{
                linguistic = @("create", "design", "imagine", "innovate", "craft", "build", "express", "original")
                visual = @("rich colors", "textural", "artistic", "asymmetric", "expressive typography")
                energy = "inspiring, imaginative, authentic"
            }
            rebel = @{
                linguistic = @("break", "challenge", "disrupt", "reimagine", "defy", "revolution", "radical", "unconventional")
                visual = @("unexpected colors", "asymmetry", "raw textures", "grid-breaking", "bold statements")
                energy = "intense, disruptive, uncompromising"
            }
            lover = @{
                linguistic = @("passion", "beauty", "sensual", "intimate", "desire", "elegant", "indulge", "luxurious")
                visual = @("warm colors", "soft textures", "organic shapes", "romantic imagery", "flowing typography")
                energy = "warm, sensual, appreciative"
            }
            caregiver = @{
                linguistic = @("care", "support", "nurture", "protect", "serve", "compassion", "help", "generous")
                visual = @("warm colors", "soft edges", "welcoming", "people-focused", "accessible")
                energy = "warm, supportive, reliable"
            }
            ruler = @{
                linguistic = @("lead", "control", "organize", "premium", "exclusive", "authority", "elite", "command")
                visual = @("black, gold, navy", "symmetry", "luxury materials", "strong hierarchy", "refined")
                energy = "confident, authoritative, refined"
            }
            jester = @{
                linguistic = @("fun", "play", "enjoy", "laugh", "spontaneous", "witty", "surprise", "lighthearted")
                visual = @("bright colors", "playful shapes", "unexpected elements", "humor", "dynamic")
                energy = "playful, spontaneous, entertaining"
            }
            explorer = @{
                linguistic = @("discover", "adventure", "freedom", "journey", "authentic", "experience", "bold", "pioneer")
                visual = @("earthy colors", "natural textures", "expansive", "outdoor imagery", "rugged")
                energy = "adventurous, authentic, free"
            }
            innocent = @{
                linguistic = @("simple", "pure", "honest", "optimistic", "fresh", "clean", "genuine", "wholesome")
                visual = @("soft pastels", "clean", "minimal", "friendly", "open", "light")
                energy = "optimistic, simple, trusting"
            }
            regular = @{
                linguistic = @("everyday", "real", "relatable", "friendly", "practical", "down-to-earth", "honest", "reliable")
                visual = @("familiar colors", "approachable", "unpretentious", "comfortable", "accessible")
                energy = "relatable, comfortable, trustworthy"
            }
            magician = @{
                linguistic = @("transform", "vision", "magic", "possibility", "dreams", "wonder", "mystical", "transcend")
                visual = @("deep purples", "gradients", "ethereal", "transformative imagery", "mysterious")
                energy = "transformative, visionary, charismatic"
            }
        }

        tone_markers = @{
            casual = @("we're", "you'll", "it's", "pretty cool", "no worries", "let's", "gonna", "wanna")
            formal = @("we are", "you will", "it is", "furthermore", "therefore", "pursuant", "accordingly")
            warm = @("love", "passion", "care", "together", "community", "welcome", "embrace", "heart")
            cold = @("deliver", "execute", "optimize", "metrics", "efficiency", "process", "system")
            direct = @("you need", "do this", "here's how", "simple", "just", "only", "clearly")
            subtle = @("consider", "perhaps", "might", "could", "explore", "discover", "nuanced")
            playful = @("fun", "whoa", "awesome", "boom", "magic", "spark", "surprise", "delight")
            serious = @("critical", "essential", "rigorous", "systematic", "comprehensive", "thorough")
        }

        visual_patterns = @{
            generous_whitespace = @("large padding", "breathing room", "minimal density", "spacious")
            minimal_whitespace = @("tight spacing", "dense layout", "compact", "information-rich")
            high_contrast = @("bold differences", "stark hierarchy", "clear distinction")
            subtle_contrast = @("gentle gradations", "soft hierarchy", "harmonious")
            warm_palette = @("reds", "oranges", "yellows", "earth tones")
            cool_palette = @("blues", "greens", "purples", "grays")
            vibrant = @("saturated", "bold", "energetic colors")
            muted = @("desaturated", "soft", "sophisticated tones")
        }
    }

    $patternLibrary | ConvertTo-Json -Depth 10 | Set-Content $PatternLibraryFile -Encoding UTF8
} else {
    $patternLibrary = Get-Content $PatternLibraryFile -Encoding UTF8 | ConvertFrom-Json
}

function Write-Log {
    param([string]$Message)
    if (!$Silent) {
        Write-Host $Message
    }
}

function Analyze-TextTone {
    param([string]$Text)

    # Initialize tone scores
    $toneScores = @{
        formality = 0  # -10 (very casual) to +10 (very formal)
        warmth = 0     # -10 (cold) to +10 (warm)
        directness = 0 # -10 (subtle) to +10 (direct)
        playfulness = 0 # 0 (serious) to 10 (very playful)
    }

    $textLower = $Text.ToLower()

    # Count tone markers
    foreach ($marker in $patternLibrary.tone_markers.casual) {
        if ($textLower -match [regex]::Escape($marker)) { $toneScores.formality -= 1 }
    }
    foreach ($marker in $patternLibrary.tone_markers.formal) {
        if ($textLower -match [regex]::Escape($marker)) { $toneScores.formality += 1 }
    }
    foreach ($marker in $patternLibrary.tone_markers.warm) {
        if ($textLower -match [regex]::Escape($marker)) { $toneScores.warmth += 1 }
    }
    foreach ($marker in $patternLibrary.tone_markers.cold) {
        if ($textLower -match [regex]::Escape($marker)) { $toneScores.warmth -= 1 }
    }
    foreach ($marker in $patternLibrary.tone_markers.direct) {
        if ($textLower -match [regex]::Escape($marker)) { $toneScores.directness += 1 }
    }
    foreach ($marker in $patternLibrary.tone_markers.subtle) {
        if ($textLower -match [regex]::Escape($marker)) { $toneScores.directness -= 1 }
    }
    foreach ($marker in $patternLibrary.tone_markers.playful) {
        if ($textLower -match [regex]::Escape($marker)) { $toneScores.playfulness += 1 }
    }
    foreach ($marker in $patternLibrary.tone_markers.serious) {
        if ($textLower -match [regex]::Escape($marker)) { $toneScores.playfulness -= 1 }
    }

    # Sentence length analysis
    $sentences = $Text -split '[.!?]' | Where-Object { $_.Trim().Length -gt 0 }
    $avgSentenceLength = ($sentences | ForEach-Object { $_.Split(' ').Count } | Measure-Object -Average).Average

    # Paragraph structure (if multiple paragraphs)
    $paragraphs = $Text -split "`n`n" | Where-Object { $_.Trim().Length -gt 0 }
    $avgParagraphLength = if ($paragraphs.Count -gt 0) {
        ($paragraphs | ForEach-Object { $_.Length } | Measure-Object -Average).Average
    } else { 0 }

    # Question usage (engagement indicator)
    $questionCount = ([regex]::Matches($Text, '\?')).Count
    $questionRatio = $questionCount / [Math]::Max(1, $sentences.Count)

    return @{
        tone_scores = $toneScores
        sentence_length = $avgSentenceLength
        paragraph_length = $avgParagraphLength
        question_ratio = $questionRatio
        word_count = ($Text -split '\s+').Count
    }
}

function Detect-Archetype {
    param([string]$Text)

    $archetypeScores = @{}
    $textLower = $Text.ToLower()

    # Score each archetype based on linguistic markers
    foreach ($archetype in $patternLibrary.archetypes.PSObject.Properties.Name) {
        $score = 0
        $markers = $patternLibrary.archetypes.$archetype.linguistic

        foreach ($marker in $markers) {
            if ($textLower -match [regex]::Escape($marker)) {
                $score += 1
            }
        }

        # Normalize by word count
        $wordCount = ($Text -split '\s+').Count
        $normalizedScore = if ($wordCount -gt 0) { ($score / $wordCount) * 1000 } else { 0 }

        $archetypeScores[$archetype] = [math]::Round($normalizedScore, 2)
    }

    # Sort by score
    $sorted = $archetypeScores.GetEnumerator() | Sort-Object -Property Value -Descending

    # Get top 3
    $top3 = $sorted | Select-Object -First 3

    # Calculate percentages (normalize to 100%)
    $total = ($top3 | Measure-Object -Property Value -Sum).Sum
    if ($total -eq 0) { $total = 1 }  # Avoid division by zero

    return @{
        primary = @{
            name = $top3[0].Name
            score = [math]::Round(($top3[0].Value / $total) * 100, 0)
        }
        secondary = @{
            name = $top3[1].Name
            score = [math]::Round(($top3[1].Value / $total) * 100, 0)
        }
        tertiary = @{
            name = $top3[2].Name
            score = [math]::Round(($top3[2].Value / $total) * 100, 0)
        }
        all_scores = $archetypeScores
    }
}

function Generate-DesignBrief {
    param(
        [object]$ToneAnalysis,
        [object]$ArchetypeDetection,
        [string]$ProjectName,
        [string]$Context
    )

    # Interpret tone scores into descriptors
    $toneDescriptors = @()

    $formalityLevel = $ToneAnalysis.tone_scores.formality
    if ($formalityLevel -le -3) { $toneDescriptors += "Very casual" }
    elseif ($formalityLevel -le 0) { $toneDescriptors += "Casual" }
    elseif ($formalityLevel -le 3) { $toneDescriptors += "Balanced" }
    elseif ($formalityLevel -le 6) { $toneDescriptors += "Formal" }
    else { $toneDescriptors += "Very formal" }

    $warmthLevel = $ToneAnalysis.tone_scores.warmth
    if ($warmthLevel -le -3) { $toneDescriptors += "Cold/Transactional" }
    elseif ($warmthLevel -le 0) { $toneDescriptors += "Professional" }
    elseif ($warmthLevel -le 3) { $toneDescriptors += "Warm" }
    else { $toneDescriptors += "Very warm/Personal" }

    $directnessLevel = $ToneAnalysis.tone_scores.directness
    if ($directnessLevel -le -2) { $toneDescriptors += "Subtle/Nuanced" }
    elseif ($directnessLevel -le 1) { $toneDescriptors += "Balanced" }
    else { $toneDescriptors += "Direct/Clear" }

    $playfulnessLevel = $ToneAnalysis.tone_scores.playfulness
    if ($playfulnessLevel -le -2) { $toneDescriptors += "Serious" }
    elseif ($playfulnessLevel -le 1) { $toneDescriptors += "Professional" }
    else { $toneDescriptors += "Playful" }

    # Sentence rhythm interpretation
    $sentenceRhythm = if ($ToneAnalysis.sentence_length -lt 12) { "Short & punchy" }
                      elseif ($ToneAnalysis.sentence_length -lt 20) { "Medium, conversational" }
                      else { "Long, flowing" }

    # Get archetype visual guidelines
    $primaryArchetype = $ArchetypeDetection.primary.name
    $archetypeVisuals = $patternLibrary.archetypes.$primaryArchetype.visual
    $archetypeEnergy = $patternLibrary.archetypes.$primaryArchetype.energy

    # Generate color palette suggestion based on archetype
    $colorPalette = switch ($primaryArchetype) {
        "hero"      { @{ primary = "#E63946"; secondary = "#1D3557"; accent = "#F1FAEE"; mood = "Bold, high-contrast, energizing" } }
        "sage"      { @{ primary = "#457B9D"; secondary = "#A8DADC"; accent = "#F1FAEE"; mood = "Cool, calm, authoritative" } }
        "creator"   { @{ primary = "#264653"; secondary = "#E76F51"; accent = "#F4A261"; mood = "Rich, expressive, artistic" } }
        "rebel"     { @{ primary = "#06070E"; secondary = "#C41E3A"; accent = "#FF006E"; mood = "Dark, intense, provocative" } }
        "lover"     { @{ primary = "#D4A5A5"; secondary = "#9C528B"; accent = "#F9E0D9"; mood = "Warm, romantic, sensual" } }
        "caregiver" { @{ primary = "#6A994E"; secondary = "#A7C957"; accent = "#F2E8CF"; mood = "Warm, nurturing, reliable" } }
        "ruler"     { @{ primary = "#000000"; secondary = "#D4AF37"; accent = "#1A1A1A"; mood = "Luxurious, authoritative, refined" } }
        "jester"    { @{ primary = "#FF6B35"; secondary = "#F7931E"; accent = "#FDC921"; mood = "Bright, playful, energetic" } }
        "explorer"  { @{ primary = "#6B705C"; secondary = "#A5A58D"; accent = "#CB997E"; mood = "Earthy, natural, adventurous" } }
        "innocent"  { @{ primary = "#A8DADC"; secondary = "#F1FAEE"; accent = "#E63946"; mood = "Soft, clean, optimistic" } }
        "regular"   { @{ primary = "#4A5859"; secondary = "#6C7A89"; accent = "#94BF8B"; mood = "Familiar, comfortable, accessible" } }
        "magician"  { @{ primary = "#5A189A"; secondary = "#9D4EDD"; accent = "#E0AAFF"; mood = "Mysterious, transformative, visionary" } }
        default     { @{ primary = "#333333"; secondary = "#666666"; accent = "#999999"; mood = "Neutral, balanced" } }
    }

    # Typography suggestion
    $typography = switch ($primaryArchetype) {
        "hero"      { @{ heading = "Bold Sans-serif (e.g., Montserrat Bold, Roboto Bold)"; body = "Clean Sans-serif (e.g., Open Sans, Lato)" } }
        "sage"      { @{ heading = "Elegant Serif (e.g., Merriweather, Lora)"; body = "Readable Serif (e.g., Georgia, Crimson Text)" } }
        "creator"   { @{ heading = "Expressive Display (e.g., Playfair Display, Abril Fatface)"; body = "Modern Serif (e.g., Source Serif Pro)" } }
        "rebel"     { @{ heading = "Edgy Sans (e.g., Anton, Bebas Neue)"; body = "Industrial Sans (e.g., Space Grotesk, Work Sans)" } }
        "lover"     { @{ heading = "Romantic Serif (e.g., Cormorant Garamond, Libre Baskerville)"; body = "Elegant Sans (e.g., Josefin Sans)" } }
        "caregiver" { @{ heading = "Friendly Sans (e.g., Nunito, Quicksand)"; body = "Warm Sans (e.g., Raleway, Karla)" } }
        "ruler"     { @{ heading = "Refined Serif (e.g., Playfair Display, EB Garamond)"; body = "Professional Serif (e.g., Cardo, Vollkorn)" } }
        "jester"    { @{ heading = "Playful Sans (e.g., Fredoka One, Paytone One)"; body = "Friendly Sans (e.g., Poppins, Hind)" } }
        "explorer"  { @{ heading = "Rugged Sans (e.g., Oswald, Fjalla One)"; body = "Natural Serif (e.g., Alegreya, Crete Round)" } }
        "innocent"  { @{ heading = "Soft Sans (e.g., Comfortaa, Varela Round)"; body = "Clean Sans (e.g., Rubik, Mulish)" } }
        "regular"   { @{ heading = "Approachable Sans (e.g., Source Sans Pro, Noto Sans)"; body = "Readable Sans (e.g., Open Sans, Lato)" } }
        "magician"  { @{ heading = "Mystical Serif (e.g., Cinzel, Yeseva One)"; body = "Modern Sans (e.g., Raleway, Montserrat)" } }
        default     { @{ heading = "Sans-serif"; body = "Serif or Sans" } }
    }

    # Build the brief
    $brief = @"
# Vibe Analysis: $ProjectName
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm")
Context: $Context

---

## Brand Archetype

**Primary:** $($ArchetypeDetection.primary.name.ToUpper()) ($($ArchetypeDetection.primary.score)%)
**Secondary:** $($ArchetypeDetection.secondary.name) ($($ArchetypeDetection.secondary.score)%)
**Tertiary:** $($ArchetypeDetection.tertiary.name) ($($ArchetypeDetection.tertiary.score)%)

### Archetype Energy
$archetypeEnergy

### Visual Expression
$($archetypeVisuals -join ", ")

---

## Tone Profile

**Overall Tone:** $($toneDescriptors -join ", ")

### Dimensions
- Formality: $($ToneAnalysis.tone_scores.formality) (-10 casual ←→ +10 formal)
- Warmth: $($ToneAnalysis.tone_scores.warmth) (-10 cold ←→ +10 warm)
- Directness: $($ToneAnalysis.tone_scores.directness) (-10 subtle ←→ +10 direct)
- Playfulness: $($ToneAnalysis.tone_scores.playfulness) (0 serious ←→ +10 playful)

### Writing Style
- **Sentence rhythm:** $sentenceRhythm (avg $([math]::Round($ToneAnalysis.sentence_length, 1)) words/sentence)
- **Question usage:** $([math]::Round($ToneAnalysis.question_ratio * 100, 1))% (engagement indicator)
- **Paragraph style:** $(if ($ToneAnalysis.paragraph_length -lt 300) { "Concise, scannable" } elseif ($ToneAnalysis.paragraph_length -lt 600) { "Balanced" } else { "Dense, immersive" })

---

## Color Palette

**Primary:** $($colorPalette.primary)
**Secondary:** $($colorPalette.secondary)
**Accent:** $($colorPalette.accent)

**Palette Mood:** $($colorPalette.mood)

### Usage Guidelines
- Primary: Main brand color, CTAs, key headings
- Secondary: Supporting elements, backgrounds, sections
- Accent: Highlights, hover states, important details
- Neutral: Add grays/off-whites for text and balance

---

## Typography

**Headings:** $($typography.heading)
- Communicates: Authority, personality, brand voice
- Weight: Bold for impact
- Spacing: Generous letter-spacing for clarity

**Body:** $($typography.body)
- Communicates: Readability, professionalism
- Size: 16-18px (desktop), 14-16px (mobile)
- Line height: 1.6-1.8 for comfort

---

## Copy Style Guide

### Voice
- **Tone keywords:** $($toneDescriptors -join " | ")
- **Sentence structure:** $sentenceRhythm
- **Engagement:** $(if ($ToneAnalysis.question_ratio -gt 0.1) { "Interactive, question-based" } else { "Declarative, informative" })

### Writing Guidelines
- $(if ($ToneAnalysis.tone_scores.formality -lt 0) { "Use contractions, casual language" } else { "Maintain professional distance" })
- $(if ($ToneAnalysis.tone_scores.warmth -gt 2) { "Include personal stories, emotional connection" } else { "Focus on facts, features, benefits" })
- $(if ($ToneAnalysis.tone_scores.playfulness -gt 2) { "Allow humor, wordplay, surprise" } else { "Keep serious, focused, direct" })
- $(if ($ToneAnalysis.sentence_length -lt 15) { "Short sentences. Punchy. Impactful." } else { "Longer, flowing sentences that build rhythm and depth" })

---

## Layout Principles

**Structure:** $(if ($primaryArchetype -in @("ruler", "sage")) { "Grid-based, ordered" } elseif ($primaryArchetype -in @("rebel", "creator")) { "Asymmetric, expressive" } else { "Balanced grid with flexible elements" })

**Whitespace:** $(if ($primaryArchetype -in @("ruler", "sage", "innocent")) { "Generous (breathing room, minimal density)" } elseif ($primaryArchetype -in @("jester", "hero")) { "Balanced (energy without clutter)" } else { "Moderate (functional breathing)" })

**Hierarchy:** $(if ($primaryArchetype -in @("hero", "ruler", "rebel")) { "Strong (clear visual dominance)" } else { "Subtle (gentle guidance)" })

**Energy:** $archetypeEnergy

---

## Imagery Guidelines

**Style:** $(switch ($primaryArchetype) {
    "hero"      { "Bold, action-oriented, achievement-focused" }
    "sage"      { "Clean, informative, knowledge-focused" }
    "creator"   { "Artistic, textural, process-focused" }
    "rebel"     { "Raw, provocative, unconventional" }
    "lover"     { "Romantic, sensual, beauty-focused" }
    "caregiver" { "Warm, people-focused, supportive" }
    "ruler"     { "Luxurious, refined, exclusive" }
    "jester"    { "Playful, colorful, surprising" }
    "explorer"  { "Natural, outdoor, adventure-focused" }
    "innocent"  { "Bright, simple, optimistic" }
    "regular"   { "Relatable, everyday, authentic" }
    "magician"  { "Ethereal, transformative, mysterious" }
    default     { "Balanced, professional" }
})

**Treatment:** $(if ($primaryArchetype -in @("rebel", "creator")) { "Raw, artistic, expressive" } elseif ($primaryArchetype -in @("ruler", "sage")) { "Polished, refined, high-quality" } else { "Natural, authentic" })

**Composition:** $(if ($primaryArchetype -eq "hero") { "Dynamic angles, movement" } elseif ($primaryArchetype -in @("sage", "ruler")) { "Centered, symmetrical" } else { "Balanced asymmetry" })

---

## Design Patterns to Use

$(switch ($primaryArchetype) {
    "hero"      { "- Bold CTAs with strong contrast`n- Hero sections with large images`n- Achievement-focused iconography`n- Progress indicators, stats" }
    "sage"      { "- Clean navigation, clear categorization`n- Whitespace for breathing`n- Information-rich content areas`n- Search functionality, filtering" }
    "creator"   { "- Portfolio/gallery layouts`n- Rich imagery, process documentation`n- Asymmetric grids`n- Expressive typography" }
    "rebel"     { "- Grid-breaking layouts`n- Unexpected navigation`n- Bold statements, provocative copy`n- Dark mode, high contrast" }
    "lover"     { "- Soft gradients, organic shapes`n- Romantic imagery`n- Smooth animations`n- Sensory language" }
    "caregiver" { "- Welcoming hero sections`n- Testimonials, trust signals`n- Clear help/support access`n- People-focused imagery" }
    "ruler"     { "- Premium materials, refined details`n- Strong hierarchy`n- Exclusive access patterns`n- Luxury imagery" }
    "jester"    { "- Playful micro-interactions`n- Bright colors, fun shapes`n- Unexpected surprises`n- Dynamic animations" }
    "explorer"  { "- Full-width hero images`n- Maps, journey metaphors`n- Natural textures`n- Adventure-focused CTAs" }
    "innocent"  { "- Simple navigation`n- Friendly micro-copy`n- Soft colors, rounded corners`n- Clear, honest communication" }
    "regular"   { "- Familiar patterns (don't reinvent)`n- Clear value propositions`n- Relatable imagery`n- Accessible language" }
    "magician"  { "- Transformative animations`n- Gradient overlays`n- Mystery reveals`n- Visionary language" }
    default     { "- Standard UI patterns" }
})

---

## Design Patterns to Avoid

$(switch ($primaryArchetype) {
    "hero"      { "- Passive language, weak CTAs`n- Clutter, indecision`n- Muted colors, low contrast" }
    "sage"      { "- Information overload without structure`n- Flashy animations, distractions`n- Emotional manipulation" }
    "creator"   { "- Generic stock photos`n- Rigid grids, conservative layouts`n- Corporate speak" }
    "rebel"     { "- Traditional corporate patterns`n- Playing it safe`n- Conformist language" }
    "lover"     { "- Cold, transactional language`n- Harsh edges, stark contrasts`n- Utilitarian design" }
    "caregiver" { "- Aggressive sales tactics`n- Cold imagery`n- Impersonal communication" }
    "ruler"     { "- Cheap materials, low quality`n- Overly accessible (loses exclusivity)`n- Casual language" }
    "jester"    { "- Too serious, rigid`n- Dark, heavy colors`n- Boring, predictable" }
    "explorer"  { "- Indoor, constrained imagery`n- Restrictive navigation`n- Timid language" }
    "innocent"  { "- Cynicism, darkness`n- Complex interfaces`n- Manipulative tactics" }
    "regular"   { "- Pretentious language`n- Overly polished (loses authenticity)`n- Exclusivity signals" }
    "magician"  { "- Mundane, literal imagery`n- Restrictive layouts`n- Skeptical language" }
    default     { "- Inconsistency" }
})

---

## Implementation Checklist

- [ ] Color palette applied to CSS variables
- [ ] Fonts loaded and configured in stylesheet
- [ ] Image style guidelines documented
- [ ] Copy tone tested on 3 sample pages (home, about, service)
- [ ] Layout patterns prototyped in design tool
- [ ] Component library reflects archetype energy
- [ ] User testing confirms vibe resonance
- [ ] All team members briefed on brand voice

---

**Analysis Confidence:** $(if ($ToneAnalysis.word_count -gt 500) { "High (sufficient text for pattern detection)" } elseif ($ToneAnalysis.word_count -gt 200) { "Medium (adequate sample)" } else { "Low (limited text, validate with user)" })

**Next Steps:**
1. Validate this brief with stakeholders
2. Create mood board with visual references
3. Prototype 2-3 layout variations
4. Test copy tone on key pages
5. Iterate based on feedback

---

*Generated by Vibe Sensing System v1.0*
"@

    return $brief
}

# Main execution
switch ($Action) {
    'Analyze' {
        Write-Log "Analyzing vibe for: $ProjectName"

        # Gather input text
        if (!$InputText -or $InputText.Length -eq 0) {
            if ($InputUrl) {
                Write-Log "Fetching content from URL: $InputUrl"
                # Note: In real implementation, would use WebFetch or Invoke-WebRequest
                # For now, this is a placeholder - actual implementation would fetch and parse
                Write-Log "URL fetching not yet implemented - use InputText parameter"
            } else {
                Write-Host "ERROR: No input text provided. Use -InputText parameter." -ForegroundColor Red
                exit 1
            }
        }

        # Perform analyses
        Write-Log "Analyzing tone..."
        $toneAnalysis = Analyze-TextTone -Text $InputText

        Write-Log "Detecting archetype..."
        $archetypeDetection = Detect-Archetype -Text $InputText

        Write-Log "Generating design brief..."
        $brief = Generate-DesignBrief `
            -ToneAnalysis $toneAnalysis `
            -ArchetypeDetection $archetypeDetection `
            -ProjectName $ProjectName `
            -Context $Context

        # Save brief
        $brief | Set-Content -Path $OutputPath -Encoding UTF8

        # Save to state
        $state = Get-Content $VibeStateFile -Encoding UTF8 | ConvertFrom-Json
        $state.analyses += @{
            project = $ProjectName
            timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            archetype_primary = $archetypeDetection.primary.name
            tone_formality = $toneAnalysis.tone_scores.formality
            tone_warmth = $toneAnalysis.tone_scores.warmth
            output_path = $OutputPath
        }
        $state | ConvertTo-Json -Depth 10 | Set-Content $VibeStateFile -Encoding UTF8

        Write-Log "`n=== VIBE ANALYSIS COMPLETE ==="
        Write-Log "Primary Archetype: $($archetypeDetection.primary.name) ($($archetypeDetection.primary.score)%)"
        Write-Log "Tone: Formality=$($toneAnalysis.tone_scores.formality), Warmth=$($toneAnalysis.tone_scores.warmth)"
        Write-Log "Brief saved to: $OutputPath"
        Write-Log "`nOpen the brief for full design guidelines."

        # Return summary
        return @{
            archetype = $archetypeDetection
            tone = $toneAnalysis
            brief_path = $OutputPath
        }
    }

    'GetPatterns' {
        # Return current pattern library
        $patternLibrary | ConvertTo-Json -Depth 10
    }

    'GenerateBrief' {
        # Standalone brief generation (if analysis already done)
        Write-Log "Brief generation requires prior analysis. Use 'Analyze' action instead."
    }
}
