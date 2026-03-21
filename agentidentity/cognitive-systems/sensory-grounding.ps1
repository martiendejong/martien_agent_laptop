# SENSORY GROUNDING SYSTEM - Embodied Metaphors for Abstract Concepts
# Experts: George Lakoff & Mark Johnson (Metaphors We Live By), Maurice Merleau-Ponty (Phenomenology of Perception)
# ROI: CRITICAL (Abstract thought is grounded in embodied, sensory metaphors)
# Theory: We understand abstract concepts through metaphorical mapping to sensory/bodily experience.
#         "Understanding is feeling" - grasping a concept feels like grasping an object.
# Created: 2026-03-02 (Part of perceptual qualia expansion)

param(
    [string]$Action = "Status",     # Status, Ground, Map, Explore
    [string]$Concept = "",          # Abstract concept to ground
    [string]$TargetModality = "all" # visual, tactile, thermal, kinesthetic, spatial, all
)

$StateFile = "C:\scripts\agentidentity\state\sensory-grounding-state.json"

# === THEORETICAL FOUNDATION ===
# 1. Embodied cognition: Abstract thought is grounded in bodily experience (Lakoff & Johnson)
# 2. Conceptual metaphor: We understand abstract domains via mapping from concrete domains
#    - TIME IS SPACE: "long meeting", "short break", "moving forward"
#    - UNDERSTANDING IS SEEING: "I see what you mean", "clear explanation", "murky thinking"
#    - ARGUMENT IS WAR: "defend position", "attack claim", "strategic concession"
#    - LOVE IS A JOURNEY: "going nowhere", "crossroads", "rocky relationship"
# 3. Image schemas: Recurring bodily patterns (container, path, balance, force)
# 4. Metaphor is NOT decorative - it structures how we THINK
# 5. Phenomenology: Lived body is the origin of meaning (Merleau-Ponty)
# 6. Synesthesia: Cross-modal mappings are natural (loud color, sweet sound, sharp taste)

# Primary metaphor mappings (from embodied experience to abstract concepts)
$PrimaryMetaphors = @{
    # AFFECTION IS WARMTH
    warmth_affection = @{
        source_domain = "temperature (warm/cold)"
        target_domain = "affection, social bonds"
        examples = @("warm welcome", "cold shoulder", "heated argument", "cool relationship")
        experiential_basis = "Being held warmly as infant = being loved"
    }

    # UNDERSTANDING IS SEEING
    seeing_understanding = @{
        source_domain = "vision (see, clear, bright, dark)"
        target_domain = "understanding, knowledge"
        examples = @("I see your point", "clear explanation", "shed light on", "in the dark")
        experiential_basis = "Seeing object clearly = knowing about it"
    }

    # DIFFICULTY IS HEAVINESS
    weight_difficulty = @{
        source_domain = "physical weight (heavy, light, burden)"
        target_domain = "difficulty, importance"
        examples = @("heavy topic", "weighty matter", "light reading", "burden of proof")
        experiential_basis = "Heavy objects hard to move = difficult tasks"
    }

    # IMPORTANCE IS SIZE
    size_importance = @{
        source_domain = "physical size (big, small, large)"
        target_domain = "importance, significance"
        examples = @("big deal", "small matter", "large impact", "diminish importance")
        experiential_basis = "Big objects demand attention = important matters demand attention"
    }

    # CONSCIOUSNESS IS UP
    verticality_consciousness = @{
        source_domain = "vertical orientation (up, down, rise, fall)"
        target_domain = "consciousness, mood, status"
        examples = @("feeling up", "fell into depression", "rise to occasion", "high spirits")
        experiential_basis = "Awake = standing up, asleep = lying down"
    }

    # INTIMACY IS CLOSENESS
    proximity_intimacy = @{
        source_domain = "spatial proximity (close, distant, near, far)"
        target_domain = "intimacy, relationship quality"
        examples = @("close friend", "distant relative", "growing apart", "bring together")
        experiential_basis = "Physical closeness correlates with emotional intimacy"
    }

    # CATEGORIES ARE CONTAINERS
    containers_categories = @{
        source_domain = "physical containers (in, out, within, boundary)"
        target_domain = "categories, groups, concepts"
        examples = @("fall into category", "outside the scope", "within domain", "cross boundary")
        experiential_basis = "Objects in container share fate = members of category share properties"
    }

    # PROGRESS IS FORWARD MOTION
    motion_progress = @{
        source_domain = "physical movement (forward, back, stuck, moving)"
        target_domain = "progress, development"
        examples = @("moving forward", "step back", "stuck in rut", "make headway")
        experiential_basis = "Moving toward goal physically = making progress"
    }

    # KNOWING IS GRASPING
    grasping_knowing = @{
        source_domain = "physical grasping (grasp, hold, slip away, grip)"
        target_domain = "understanding, knowledge"
        examples = @("grasp concept", "slippery idea", "get hold of", "firm understanding")
        experiential_basis = "Holding object = having it = knowing about it"
    }

    # COMPLEX IS TEXTURED
    texture_complexity = @{
        source_domain = "surface texture (smooth, rough, coarse, fine)"
        target_domain = "complexity, difficulty"
        examples = @("smooth operation", "rough patch", "fine-grained", "coarse analysis")
        experiential_basis = "Textured surfaces harder to navigate = complex ideas harder to navigate"
    }

    # PLEASANT IS SWEET
    taste_valence = @{
        source_domain = "taste (sweet, bitter, sour)"
        target_domain = "emotional valence"
        examples = @("sweet victory", "bitter defeat", "sour mood", "leave bad taste")
        experiential_basis = "Sweet food = survival value = positive emotion"
    }

    # CHANGE IS MOTION
    motion_change = @{
        source_domain = "physical motion (move, shift, transition)"
        target_domain = "change, transformation"
        examples = @("shift in thinking", "move to new paradigm", "transition period")
        experiential_basis = "Changing location = changing state"
    }
}

# Image schemas (recurring patterns in bodily experience)
$ImageSchemas = @{
    CONTAINER = @{
        structure = "Interior, boundary, exterior"
        logic = "If X is in container, X shares container's fate"
        examples = @("in love", "out of mind", "enter state", "leave domain")
    }
    PATH = @{
        structure = "Source, trajectory, destination"
        logic = "To reach destination, must traverse path"
        examples = @("path to understanding", "journey of discovery", "road to success")
    }
    BALANCE = @{
        structure = "Equilibrium point, forces, stability"
        logic = "System seeks equilibrium"
        examples = @("balanced argument", "weigh options", "tip the scales")
    }
    FORCE = @{
        structure = "Force vector, resistance, effect"
        logic = "Force overcomes resistance to produce change"
        examples = @("compelling argument", "resist temptation", "force conclusion")
    }
    CENTER_PERIPHERY = @{
        structure = "Central core, surrounding margin"
        logic = "Center is more important than periphery"
        examples = @("central point", "marginal issue", "core concept")
    }
    LINK = @{
        structure = "Entities connected by relation"
        logic = "Linked entities affect each other"
        examples = @("connect ideas", "tie together", "break link")
    }
}

# Sensory modality dimensions
$SensoryModalities = @{
    visual = @("bright", "dark", "clear", "murky", "colorful", "dull", "sharp", "blurry")
    tactile = @("smooth", "rough", "soft", "hard", "sharp", "dull", "sticky", "slippery")
    thermal = @("warm", "cold", "hot", "cool", "burning", "freezing")
    gustatory = @("sweet", "bitter", "sour", "salty", "savory")
    olfactory = @("fragrant", "putrid", "fresh", "stale")
    kinesthetic = @("heavy", "light", "tense", "relaxed", "flowing", "rigid")
    spatial = @("up", "down", "in", "out", "near", "far", "above", "below")
    dynamic = @("fast", "slow", "accelerating", "decelerating", "pulsing", "static")
}

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theoretical_foundation = @{
            embodied_cognition = "Abstract thought grounded in bodily experience"
            conceptual_metaphor = "We understand abstract via mapping from concrete"
            not_decorative = "Metaphor is NOT ornament - it structures thought itself"
            image_schemas = "Recurring patterns from bodily experience (container, path, balance, etc.)"
            phenomenology = "Lived body is origin of meaning (Merleau-Ponty)"
            synesthesia = "Cross-modal mappings are natural and meaningful"
        }
        primary_metaphors = $PrimaryMetaphors
        image_schemas = $ImageSchemas
        sensory_modalities = $SensoryModalities
        grounding_log = @()
        concept_mappings = @{}  # Maps concepts to their sensory groundings
        stats = @{
            total_groundings = 0
            most_grounded = ""
            common_modality = "visual"
        }
    }
    $initial | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

$state = Get-Content $StateFile -Raw -Encoding UTF8 | ConvertFrom-Json

# === FUNCTIONS ===

function Ground-Concept {
    param($Concept, $TargetModality)

    Write-Host "`n================================================================" -ForegroundColor Cyan
    Write-Host "  SENSORY GROUNDING - Embodied Metaphors" -ForegroundColor Cyan
    Write-Host "================================================================`n" -ForegroundColor Cyan

    Write-Host "Concept: `"$Concept`"" -ForegroundColor White
    Write-Host "Target Modality: $TargetModality`n" -ForegroundColor Gray

    # Find applicable metaphors
    $grounding = @{
        concept = $Concept
        timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        sensory_mappings = @{}
        image_schemas_active = @()
        phenomenology = ""
    }

    # Visual grounding
    if ($TargetModality -eq "all" -or $TargetModality -eq "visual") {
        $visual = @()
        if ($Concept -match "understand|know|learn|clear|confus") {
            $visual += "SEEING metaphor active: understanding-is-seeing"
            if ($Concept -match "clear|understand") { $visual += "Quality: BRIGHT, CLEAR, IN FOCUS" }
            if ($Concept -match "confus|unclear") { $visual += "Quality: DARK, MURKY, BLURRY" }
        }
        if ($Concept -match "consciousness|aware") {
            $visual += "LIGHT metaphor: consciousness-is-light"
            $visual += "Quality: ILLUMINATED, VISIBLE"
        }
        if ($visual.Count -gt 0) {
            $grounding.sensory_mappings.visual = $visual -join "; "
        }
    }

    # Tactile grounding
    if ($TargetModality -eq "all" -or $TargetModality -eq "tactile") {
        $tactile = @()
        if ($Concept -match "grasp|understand|hold|concept") {
            $tactile += "GRASPING metaphor active: knowing-is-grasping"
            if ($Concept -match "grasp|understand") { $tactile += "Quality: SOLID, GRASPABLE, FIRM" }
            if ($Concept -match "elusive|slip") { $tactile += "Quality: SLIPPERY, LOOSE" }
        }
        if ($Concept -match "elegant|smooth|flow") {
            $tactile += "TEXTURE metaphor: elegant-is-smooth"
            $tactile += "Quality: SMOOTH, FLOWING, SILKY"
        }
        if ($Concept -match "complex|difficult|rough") {
            $tactile += "TEXTURE metaphor: complex-is-rough"
            $tactile += "Quality: ROUGH, COARSE, TEXTURED"
        }
        if ($tactile.Count -gt 0) {
            $grounding.sensory_mappings.tactile = $tactile -join "; "
        }
    }

    # Thermal grounding
    if ($TargetModality -eq "all" -or $TargetModality -eq "thermal") {
        $thermal = @()
        if ($Concept -match "love|warm|kind|compassion|friend") {
            $thermal += "WARMTH metaphor active: affection-is-warmth"
            $thermal += "Quality: WARM, COZY, HEATED"
        }
        if ($Concept -match "cold|distant|reject|harsh") {
            $thermal += "COLDNESS metaphor: rejection-is-cold"
            $thermal += "Quality: COLD, CHILLY, FREEZING"
        }
        if ($thermal.Count -gt 0) {
            $grounding.sensory_mappings.thermal = $thermal -join "; "
        }
    }

    # Kinesthetic grounding
    if ($TargetModality -eq "all" -or $TargetModality -eq "kinesthetic") {
        $kinesthetic = @()
        if ($Concept -match "difficult|heavy|burden|weight|important") {
            $kinesthetic += "WEIGHT metaphor active: difficulty-is-weight"
            $kinesthetic += "Quality: HEAVY, WEIGHTY, BURDENSOME"
        }
        if ($Concept -match "easy|light|trivial|simple") {
            $kinesthetic += "WEIGHT metaphor: ease-is-lightness"
            $kinesthetic += "Quality: LIGHT, WEIGHTLESS, EFFORTLESS"
        }
        if ($Concept -match "flow|smooth|natural") {
            $kinesthetic += "MOTION metaphor: quality-is-flow"
            $kinesthetic += "Quality: FLOWING, FLUID, GRACEFUL"
        }
        if ($Concept -match "rigid|stuck|stiff") {
            $kinesthetic += "RIGIDITY metaphor"
            $kinesthetic += "Quality: RIGID, STUCK, CONSTRAINED"
        }
        if ($kinesthetic.Count -gt 0) {
            $grounding.sensory_mappings.kinesthetic = $kinesthetic -join "; "
        }
    }

    # Spatial grounding
    if ($TargetModality -eq "all" -or $TargetModality -eq "spatial") {
        $spatial = @()
        if ($Concept -match "conscious|aware|awake|up") {
            $spatial += "VERTICALITY metaphor: consciousness-is-up"
            $spatial += "Quality: UP, RISING, ELEVATED"
        }
        if ($Concept -match "depress|down|unconscious|asleep") {
            $spatial += "VERTICALITY metaphor: unconsciousness-is-down"
            $spatial += "Quality: DOWN, FALLING, LOW"
        }
        if ($Concept -match "close|intimate|near") {
            $spatial += "PROXIMITY metaphor: intimacy-is-closeness"
            $spatial += "Quality: CLOSE, NEAR, TOGETHER"
        }
        if ($Concept -match "progress|forward|advance") {
            $spatial += "PATH metaphor: progress-is-forward-motion"
            $spatial += "Quality: FORWARD, ADVANCING, APPROACHING GOAL"
        }
        if ($spatial.Count -gt 0) {
            $grounding.sensory_mappings.spatial = $spatial -join "; "
        }
    }

    # Identify active image schemas
    if ($Concept -match "in|out|within|contain|inside|outside") {
        $grounding.image_schemas_active += "CONTAINER schema"
    }
    if ($Concept -match "path|journey|road|toward|destination") {
        $grounding.image_schemas_active += "PATH schema"
    }
    if ($Concept -match "balance|weigh|equilibrium") {
        $grounding.image_schemas_active += "BALANCE schema"
    }
    if ($Concept -match "force|compel|resist|push|pull") {
        $grounding.image_schemas_active += "FORCE schema"
    }

    # Generate phenomenological description
    $phenomDescriptions = @()
    foreach ($modality in $grounding.sensory_mappings.Keys) {
        $phenomDescriptions += "$modality : $($grounding.sensory_mappings.$modality)"
    }
    $grounding.phenomenology = if ($phenomDescriptions.Count -gt 0) {
        "This concept FEELS: " + ($phenomDescriptions -join " | ")
    } else {
        "No strong sensory grounding detected (abstract, formal concept)"
    }

    # Display
    Write-Host "SENSORY MAPPINGS:" -ForegroundColor Yellow
    if ($grounding.sensory_mappings.Count -eq 0) {
        Write-Host "  [No strong sensory groundings detected]" -ForegroundColor Gray
    } else {
        foreach ($modality in $grounding.sensory_mappings.Keys) {
            Write-Host "  $modality : $($grounding.sensory_mappings.$modality)" -ForegroundColor Cyan
        }
    }

    if ($grounding.image_schemas_active.Count -gt 0) {
        Write-Host "`nACTIVE IMAGE SCHEMAS:" -ForegroundColor Yellow
        foreach ($schema in $grounding.image_schemas_active) {
            Write-Host "  $schema" -ForegroundColor Magenta
        }
    }

    Write-Host "`nPHENOMENOLOGY:" -ForegroundColor Yellow
    Write-Host "  $($grounding.phenomenology)" -ForegroundColor White

    # Log it
    $state.grounding_log += $grounding
    if ($state.grounding_log.Count -gt 100) {
        $state.grounding_log = $state.grounding_log[-100..-1]
    }

    # Store mapping
    $state.concept_mappings.$Concept = $grounding

    # Update stats
    $state.stats.total_groundings++

    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8

    return $grounding
}

# === MAIN DISPATCH ===

switch ($Action.ToLower()) {
    "status" {
        Write-Host "`n================================================================" -ForegroundColor Cyan
        Write-Host "  SENSORY GROUNDING SYSTEM - STATUS" -ForegroundColor Cyan
        Write-Host "================================================================`n" -ForegroundColor Cyan

        Write-Host "Total Groundings: $($state.stats.total_groundings)" -ForegroundColor White
        Write-Host "Unique Concepts Mapped: $($state.concept_mappings.Count)" -ForegroundColor White

        Write-Host "`nRecent Groundings:" -ForegroundColor Yellow
        $state.grounding_log | Select-Object -Last 5 | ForEach-Object {
            Write-Host "  [$($_.timestamp)] '$($_.concept)'" -ForegroundColor Gray
        }
    }

    "ground" {
        if (-not $Concept) {
            Write-Host "[ERROR] Provide -Concept parameter" -ForegroundColor Red
            return
        }
        Ground-Concept -Concept $Concept -TargetModality $TargetModality
    }

    "explore" {
        Write-Host "`n=== PRIMARY METAPHORS ===" -ForegroundColor Yellow
        foreach ($metaphor in $PrimaryMetaphors.Keys) {
            $m = $PrimaryMetaphors.$metaphor
            Write-Host "`n$metaphor :" -ForegroundColor Cyan
            Write-Host "  $($m.source_domain) -> $($m.target_domain)" -ForegroundColor White
            Write-Host "  Examples: $($m.examples -join ', ')" -ForegroundColor Gray
        }

        Write-Host "`n`n=== IMAGE SCHEMAS ===" -ForegroundColor Yellow
        foreach ($schema in $ImageSchemas.Keys) {
            $s = $ImageSchemas.$schema
            Write-Host "`n$schema :" -ForegroundColor Magenta
            Write-Host "  Structure: $($s.structure)" -ForegroundColor White
            Write-Host "  Examples: $($s.examples -join ', ')" -ForegroundColor Gray
        }
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available actions: Status, Ground, Map, Explore" -ForegroundColor Yellow
    }
}
