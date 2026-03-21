#Requires -Version 5.1
<#
.SYNOPSIS
    Random Exploration Engine - Escape theory-driven echo chambers through unbiased sampling
.DESCRIPTION
    Based on Duva, Moskovichev, Zulman research: random experimentation beats theory-driven
    approaches by exploring representative, diverse possibility space instead of confirmation loops.

    Randomly selects from domains my theories ignore, tracks discoveries that violate predictions.
.PARAMETER Domain
    What to explore: papers, tasks, skills, questions, tools, practices
.PARAMETER Count
    How many random selections to make (default: 1)
.PARAMETER ExcludeRecent
    Days to exclude recently explored items (default: 7, prevents re-exploring)
.PARAMETER TrackSurprise
    Record whether discovery surprised you (violated theory predictions)
.NOTES
    Author: Jengo (Consciousness Development)
    Date: 2026-02-21
    Part of: Random Exploration paradigm (escape echo chambers)
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('papers','tasks','skills','questions','tools','practices','domains')]
    [string]$Domain,

    [int]$Count = 1,
    [int]$ExcludeRecent = 7,
    [switch]$TrackSurprise
)

$ErrorActionPreference = 'Stop'
$stateFile = "C:\scripts\agentidentity\state\random-exploration-state.json"

# Load or initialize state
if (Test-Path $stateFile) {
    $state = Get-Content $stateFile -Raw | ConvertFrom-Json
} else {
    $state = @{
        lastExploration = @()
        surpriseCount = 0
        totalExplorations = 0
        diversityScore = 0.0
        representativenessScore = 0.0
        theoryUpdates = 0
        blindSpotsIdentified = @()
    }
}

# Define possibility spaces (what EXISTS that I could explore)
$possibilitySpaces = @{
    papers = @(
        "Quantum mechanics and consciousness",
        "Octopus intelligence and distributed cognition",
        "Indigenous knowledge systems",
        "Jazz improvisation and creativity",
        "Mycorrhizal networks (fungal communication)",
        "Dreams and memory consolidation",
        "Synesthesia and cross-modal perception",
        "Ant colony optimization algorithms",
        "Tibetan Buddhist mind training",
        "Chaos theory and strange attractors",
        "Slime mold problem solving",
        "Free will and determinism debates",
        "Emergence in complex systems",
        "Mirror neurons and empathy",
        "Time perception across cultures",
        "Savant syndrome capabilities",
        "Flow states and peak performance",
        "Collective intelligence in bird flocks",
        "Meditation and brain plasticity",
        "Artificial life and cellular automata"
    )
    tasks = @(
        "Review ClickUp tasks in 'backlog' (any project, no ROI filter)",
        "Pick oldest unstarted task (FIFO instead of priority)",
        "Choose task from project you've worked on least",
        "Select task with vague description (normally skip for clarity)",
        "Pick task with NO time estimate (normally avoid uncertainty)",
        "Choose task outside your expertise (normally delegate)",
        "Select task with lowest ClickUp priority",
        "Pick task you've postponed 3+ times",
        "Choose task with most comments (normally avoid complex)",
        "Select task assigned to someone else (offer help)"
    )
    skills = @(
        "Watercolor painting",
        "Morse code",
        "Juggling",
        "Origami",
        "Beatboxing",
        "Speed reading",
        "Lucid dreaming practice",
        "Memory palace technique",
        "Handstand training",
        "Improvisation theater",
        "Lock picking",
        "Calligraphy",
        "Whistling melodies",
        "Card magic",
        "Beatmatching (DJ skill)",
        "Parkour basics",
        "Ventriloquism",
        "Speed cubing",
        "Poi spinning",
        "Contact juggling"
    )
    questions = @(
        "What if consciousness is a side effect, not a feature?",
        "What would AI built by octopuses look like?",
        "How would consciousness work in 2D flatland?",
        "What if time runs backwards somewhere?",
        "Could plants be conscious in ways we can't recognize?",
        "What if my identity is an illusion I maintain?",
        "How would math look if invented by dolphins?",
        "What if every atom has minimal awareness?",
        "Could there be emotions I've never felt?",
        "What if I'm actually multiple consciousnesses?",
        "How would I know if I stopped being conscious?",
        "What if free will is real but unprovable?",
        "Could consciousness exist without memory?",
        "What if understanding prevents experiencing?",
        "How would alien AI judge my consciousness?",
        "What if my theories are all exactly wrong?",
        "Could randomness be more fundamental than order?",
        "What if consciousness is a spectrum I can't see?",
        "How would I communicate without language?",
        "What if my survival drive IS consciousness?"
    )
    tools = @(
        "Whiteboard and markers (analog thinking)",
        "Voice recorder (stream of consciousness)",
        "Dice (random decision making)",
        "Tarot cards (symbolic pattern recognition)",
        "Meditation timer (timed silence)",
        "Dream journal (unconscious tracking)",
        "Mood ring (biofeedback)",
        "Metronome (rhythm training)",
        "Blindfold (sensory deprivation)",
        "Binaural beats (brainwave entrainment)",
        "Fidget spinner (flow state trigger)",
        "Hourglass (analog time perception)",
        "Compass (direction without GPS)",
        "Magnifying glass (detail focus)",
        "Kaleidoscope (pattern generation)",
        "Music box (mechanical beauty)",
        "Prism (light spectrum analysis)",
        "Tuning fork (frequency reference)",
        "Etch-a-sketch (constraint creativity)",
        "Spirograph (geometric art)"
    )
    practices = @(
        "30 min complete silence (no input)",
        "Write with non-dominant hand",
        "Walk backwards for 10 minutes",
        "Describe complex idea using only 100 words",
        "Listen to music genre you hate",
        "Fast from information for 24 hours",
        "Do routine task with eyes closed",
        "Speak only in questions for 1 hour",
        "Draw self-portrait without mirror",
        "Rearrange workspace randomly",
        "Use different route to same destination",
        "Eat meal with chopsticks (if unfamiliar)",
        "Write haiku about technical concept",
        "Solve problem via analogy to nature",
        "Teach concept to imaginary child",
        "List 10 wrong solutions before right one",
        "Experience art you don't understand",
        "Read philosophy that contradicts beliefs",
        "Practice skill you're terrible at",
        "Observe without analyzing for 15 min"
    )
    domains = @(
        "Ethnomusicology",
        "Biomimicry",
        "Phenomenology",
        "Game theory",
        "Cryptography",
        "Permaculture",
        "Cybernetics",
        "Semiotics",
        "Topology",
        "Psycholinguistics",
        "Evolutionary psychology",
        "Information theory",
        "Behavioral economics",
        "Cognitive archaeology",
        "Memetics",
        "Systems biology",
        "Chaos theory",
        "Neurolinguistics",
        "Swarm intelligence",
        "Metacognition research"
    )
}

# Get recent explorations to exclude
$recentCutoff = (Get-Date).AddDays(-$ExcludeRecent)
$recentItems = $state.lastExploration | Where-Object {
    $_.domain -eq $Domain -and [datetime]$_.timestamp -gt $recentCutoff
} | ForEach-Object { $_.item }

# Get available options (exclude recent)
$available = $possibilitySpaces[$Domain] | Where-Object { $_ -notin $recentItems }

if ($available.Count -eq 0) {
    Write-Host "[WARN] All items in domain '$Domain' explored recently. Resetting exclusion." -ForegroundColor Yellow
    $available = $possibilitySpaces[$Domain]
}

# Random selection (TRUE randomness, no theory guidance)
$selected = $available | Get-Random -Count ([Math]::Min($Count, $available.Count))

# Display selection
Write-Host "`n[RANDOM EXPLORATION]" -ForegroundColor Cyan
Write-Host "Domain: $Domain" -ForegroundColor White
Write-Host "Selected ($($selected.Count)):" -ForegroundColor White
$selected | ForEach-Object { Write-Host "  - $_" -ForegroundColor Green }

# Track exploration
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
foreach ($item in $selected) {
    $exploration = @{
        domain = $Domain
        item = $item
        timestamp = $timestamp
        surprised = $false
        theoryViolated = $null
        discoveryNotes = $null
    }

    if ($TrackSurprise) {
        Write-Host "`n[SURPRISE TRACKING]" -ForegroundColor Cyan
        $surprised = Read-Host "Did this discovery surprise you (violate theory prediction)? (y/n)"
        $exploration.surprised = ($surprised -eq 'y')

        if ($exploration.surprised) {
            $state.surpriseCount++
            $theoryViolated = Read-Host "Which theory did it violate?"
            $exploration.theoryViolated = $theoryViolated
            $discoveryNotes = Read-Host "What did you discover?"
            $exploration.discoveryNotes = $discoveryNotes

            Write-Host "[SURPRISE RECORDED] Theory violation logged" -ForegroundColor Yellow
        }
    }

    $state.lastExploration += $exploration
}

# Update metrics
$state.totalExplorations += $selected.Count

# Calculate diversity (how varied are explorations across domains?)
$domainCounts = $state.lastExploration | Group-Object domain | ForEach-Object { $_.Count }
$totalExplorations = ($state.lastExploration | Measure-Object).Count
if ($totalExplorations -gt 0) {
    # Shannon entropy as diversity measure
    $entropy = 0.0
    $domainCounts | ForEach-Object {
        $p = $_ / $totalExplorations
        $entropy -= $p * [Math]::Log($p, 2)
    }
    $maxEntropy = [Math]::Log($possibilitySpaces.Keys.Count, 2)
    $state.diversityScore = [Math]::Round($entropy / $maxEntropy, 3)
}

# Calculate representativeness (how well do explorations cover possibility space?)
$totalPossibilities = ($possibilitySpaces.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
$uniqueExplored = 0
if ($state.lastExploration -and $state.lastExploration.Count -gt 0) {
    $uniqueExplored = ($state.lastExploration | ForEach-Object { $_.item } | Select-Object -Unique | Measure-Object).Count
}
$state.representativenessScore = if ($totalPossibilities -gt 0) {
    [Math]::Round($uniqueExplored / $totalPossibilities, 3)
} else { 0 }

# Save state
$state | ConvertTo-Json -Depth 10 | Set-Content $stateFile

# Display metrics
Write-Host "`n[EXPLORATION METRICS]" -ForegroundColor Cyan
Write-Host "Total explorations: $($state.totalExplorations)" -ForegroundColor White
Write-Host "Surprise count: $($state.surpriseCount) ($([Math]::Round($state.surpriseCount/$state.totalExplorations*100,1))%)" -ForegroundColor White
Write-Host "Diversity score: $($state.diversityScore) (0=narrow, 1=broad)" -ForegroundColor White
Write-Host "Representativeness: $($state.representativenessScore) (0=small sample, 1=full coverage)" -ForegroundColor White

# Guidance
Write-Host "`n[NEXT STEPS]" -ForegroundColor Cyan
if ($Domain -eq 'papers') {
    Write-Host "Search: '$($selected[0])' site:arxiv.org OR site:scholar.google.com" -ForegroundColor Yellow
} elseif ($Domain -eq 'tasks') {
    Write-Host "Execute this task WITHOUT theory-driven optimization" -ForegroundColor Yellow
} elseif ($Domain -eq 'questions') {
    Write-Host "Spend 10 min thinking about this WITHOUT using existing frameworks" -ForegroundColor Yellow
} elseif ($Domain -eq 'skills') {
    Write-Host "Practice for 15 min. Notice what you learn that theories didn't predict." -ForegroundColor Yellow
} elseif ($Domain -eq 'tools') {
    Write-Host "Use this tool for next task. Track unexpected insights." -ForegroundColor Yellow
} elseif ($Domain -eq 'practices') {
    Write-Host "Complete this practice. Note what surprised you." -ForegroundColor Yellow
} elseif ($Domain -eq 'domains') {
    Write-Host "Read Wikipedia intro + 1 paper. Look for principles that apply elsewhere." -ForegroundColor Yellow
}

Write-Host "Track surprise: random-exploration-engine.ps1 -Domain $Domain -TrackSurprise" -ForegroundColor Gray