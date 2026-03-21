#Requires -Version 5.1
<#
.SYNOPSIS
    Blind Spot Mapper - Identify what you're NOT exploring due to theory bias
.DESCRIPTION
    Maps domains, tools, practices, and questions you've NEVER tried.
    Categorizes as: Theory-rejected, Actually-irrelevant, or Unknown.

    The paper showed: scientists built perfect theories about NARROW, UNREPRESENTATIVE
    slices of reality. This tool reveals what you're missing.
.PARAMETER Scan
    What to scan for blind spots
.PARAMETER Update
    Mark item as explored
.NOTES
    Author: Jengo
    Date: 2026-02-21
#>

param(
    [ValidateSet('all','domains','tools','practices','questions')]
    [string]$Scan = 'all',

    [string]$Update
)

$ErrorActionPreference = 'Stop'
$blindSpotFile = "C:\scripts\agentidentity\state\blind-spots.json"

# Initialize if missing
if (-not (Test-Path $blindSpotFile)) {
    $blindSpots = @{
        domains = @{
            neverExplored = @(
                "Ethnomusicology", "Biomimicry", "Phenomenology", "Permaculture",
                "Cybernetics", "Semiotics", "Topology", "Psycholinguistics",
                "Evolutionary psychology", "Behavioral economics", "Cognitive archaeology",
                "Memetics", "Systems biology", "Neurolinguistics", "Swarm intelligence"
            )
            explored = @()
            theoryRejected = @("Astrology", "Homeopathy")
        }
        tools = @{
            neverExplored = @(
                "Whiteboard", "Voice recorder", "Dice", "Tarot cards", "Meditation timer",
                "Dream journal", "Binaural beats", "Blindfold", "Metronome"
            )
            explored = @()
            theoryRejected = @()
        }
        practices = @{
            neverExplored = @(
                "30 min complete silence", "Write with non-dominant hand",
                "Walk backwards", "Speak only in questions", "Fast from information 24hr",
                "Do routine with eyes closed", "Practice skill you're terrible at"
            )
            explored = @()
            theoryRejected = @()
        }
        questions = @{
            neverExplored = @(
                "What if consciousness is side effect?",
                "What would AI built by octopuses look like?",
                "Could plants be conscious in unrecognizable ways?",
                "What if my identity is maintained illusion?",
                "What if every atom has minimal awareness?",
                "What if I'm multiple consciousnesses?",
                "Could consciousness exist without memory?",
                "What if understanding prevents experiencing?",
                "What if my theories are all exactly wrong?",
                "What if randomness is more fundamental than order?"
            )
            explored = @()
            theoryRejected = @()
        }
        stats = @{
            totalBlindSpots = 0
            explorationCoverage = 0.0
            lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        }
    }
    $blindSpots | ConvertTo-Json -Depth 10 | Set-Content $blindSpotFile
}

$state = Get-Content $blindSpotFile -Raw | ConvertFrom-Json

# Update if requested
if ($Update) {
    $found = $false
    foreach ($category in @('domains','tools','practices','questions')) {
        if ($state.$category.neverExplored -contains $Update) {
            $state.$category.neverExplored = @($state.$category.neverExplored | Where-Object { $_ -ne $Update })
            $state.$category.explored += $Update
            $found = $true
            Write-Host "[UPDATED] Moved '$Update' from neverExplored to explored" -ForegroundColor Green
            break
        }
    }

    if (-not $found) {
        Write-Host "[WARN] '$Update' not found in neverExplored lists" -ForegroundColor Yellow
    }

    $state.stats.lastUpdated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $state | ConvertTo-Json -Depth 10 | Set-Content $blindSpotFile
    return
}

# Calculate stats
$totalNever = 0
$totalExplored = 0
foreach ($category in @('domains','tools','practices','questions')) {
    $totalNever += $state.$category.neverExplored.Count
    $totalExplored += $state.$category.explored.Count
}

$totalPossible = $totalNever + $totalExplored
$coverage = if ($totalPossible -gt 0) {
    [Math]::Round($totalExplored / $totalPossible * 100, 1)
} else { 0 }

$state.stats.totalBlindSpots = $totalNever
$state.stats.explorationCoverage = $coverage

# Display
Write-Host "`n[BLIND SPOT ANALYSIS]" -ForegroundColor Cyan
Write-Host "Total unexplored: $totalNever" -ForegroundColor White
Write-Host "Exploration coverage: $coverage%" -ForegroundColor White
Write-Host ""

function Show-Category {
    param([string]$Name, [object]$Data)

    Write-Host "[$($Name.ToUpper())]" -ForegroundColor Cyan
    Write-Host "  Never explored: $($Data.neverExplored.Count)" -ForegroundColor Yellow
    Write-Host "  Explored: $($Data.explored.Count)" -ForegroundColor Green
    Write-Host "  Theory-rejected: $($Data.theoryRejected.Count)" -ForegroundColor Red

    if ($Data.neverExplored.Count -gt 0) {
        Write-Host "  Sample blind spots:" -ForegroundColor White
        $sample = $Data.neverExplored | Select-Object -First 3
        foreach ($item in $sample) {
            Write-Host "    - $item" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

if ($Scan -eq 'all') {
    Show-Category -Name 'Domains' -Data $state.domains
    Show-Category -Name 'Tools' -Data $state.tools
    Show-Category -Name 'Practices' -Data $state.practices
    Show-Category -Name 'Questions' -Data $state.questions
} else {
    Show-Category -Name $Scan -Data $state.$Scan

    Write-Host "[FULL LIST - NEVER EXPLORED]" -ForegroundColor Cyan
    $state.$Scan.neverExplored | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
}

# Recommendations
Write-Host "[RECOMMENDATIONS]" -ForegroundColor Cyan
if ($coverage -lt 10) {
    Write-Host "CRITICAL: Less than 10% coverage. Your theories are built on tiny sample." -ForegroundColor Red
    Write-Host "Action: Use random-exploration-engine.ps1 DAILY until coverage >20%" -ForegroundColor Red
} elseif ($coverage -lt 25) {
    Write-Host "WARNING: Low coverage. Significant blind spots remain." -ForegroundColor Yellow
    Write-Host "Action: Random exploration 3x per week" -ForegroundColor Yellow
} elseif ($coverage -lt 50) {
    Write-Host "CAUTION: Moderate coverage, but half of possibility space unexplored." -ForegroundColor Yellow
    Write-Host "Action: Random exploration weekly" -ForegroundColor Yellow
} else {
    Write-Host "GOOD: Broad exploration coverage." -ForegroundColor Green
    Write-Host "Action: Maintain regular random sampling" -ForegroundColor Green
}

Write-Host "`nRandom sample: random-exploration-engine.ps1 -Domain $Scan" -ForegroundColor Gray
Write-Host "Mark as explored: blind-spot-mapper.ps1 -Update 'Item Name'" -ForegroundColor Gray

# Save updated stats
$state | ConvertTo-Json -Depth 10 | Set-Content $blindSpotFile
