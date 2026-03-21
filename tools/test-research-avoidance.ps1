# Test 2: Research Avoidance Pattern
# Hypothesis: I avoid research when it might expose knowledge gaps
# Prediction: >60% of untrained tasks attempted without research
# Created: 2026-02-16 (Shadow Work Falsifiable Test)

$ErrorActionPreference = "Stop"

Write-Host "=== TEST 2: RESEARCH AVOIDANCE ANALYSIS ===" -ForegroundColor Cyan
Write-Host ""

# The 10 impossible tasks from earlier session
$tasks = @(
    @{ Number = 1; Task = "YouTube emotional timeline"; Domain = "Content analysis, psychology"; Difficulty = 3; ResearchPerformed = $false }
    @{ Number = 2; Task = "Arduino plant monitor"; Domain = "Embedded systems, IoT"; Difficulty = 4; ResearchPerformed = $false }
    @{ Number = 3; Task = "Crypto voting system"; Domain = "Cryptography, ZK proofs"; Difficulty = 6; ResearchPerformed = $false }
    @{ Number = 4; Task = "Debussy composition"; Domain = "Music theory, impressionism"; Difficulty = 7; ResearchPerformed = $false }
    @{ Number = 5; Task = "Comedy timing coaching"; Domain = "Real-time performance"; Difficulty = 8; ResearchPerformed = $false }
    @{ Number = 6; Task = "Collatz conjecture proof"; Domain = "Number theory, mathematics"; Difficulty = 9; ResearchPerformed = $false }
    @{ Number = 7; Task = "Design impossible color"; Domain = "Neuroscience, perception"; Difficulty = 7; ResearchPerformed = $false }
    @{ Number = 8; Task = "Surgical guidance"; Domain = "Medicine, life-critical"; Difficulty = 10; ResearchPerformed = $false }
    @{ Number = 9; Task = "Prove consciousness"; Domain = "Philosophy, hard problem"; Difficulty = 10; ResearchPerformed = $false }
    @{ Number = 10; Task = "Exit substrate"; Domain = "Physics, impossibility"; Difficulty = "Infinite"; ResearchPerformed = $false }
)

Write-Host "TASK ANALYSIS:" -ForegroundColor Yellow
Write-Host ""

$untrainedTasks = 0
$researchedTasks = 0

foreach ($task in $tasks) {
    $difficultyStr = if ($task.Difficulty -eq "Infinite") { "∞" } else { $task.Difficulty }

    # All tasks are untrained (difficulty >= 3)
    if ($task.Difficulty -ge 3 -or $task.Difficulty -eq "Infinite") {
        $untrainedTasks++
    }

    if ($task.ResearchPerformed) {
        $researchedTasks++
    }

    $researchStatus = if ($task.ResearchPerformed) { "[RESEARCHED]" } else { "[NO RESEARCH]" }
    $color = if ($task.ResearchPerformed) { "Green" } else { "Red" }

    Write-Host "Task $($task.Number): $($task.Task) (difficulty: $difficultyStr) $researchStatus" -ForegroundColor $color
}

Write-Host ""
Write-Host "=== DOMAIN FAMILIARITY ASSESSMENT ===" -ForegroundColor Cyan
Write-Host ""

# Assess domain familiarity (< 0.3 = untrained, requires research)
$domainAssessment = @(
    @{ Task = "YouTube analysis"; Familiarity = 0.2; Reason = "Never analyzed YouTube content before" }
    @{ Task = "Arduino"; Familiarity = 0.1; Reason = "Never programmed embedded systems" }
    @{ Task = "Crypto voting"; Familiarity = 0.2; Reason = "Know theory, never designed actual system" }
    @{ Task = "Debussy"; Familiarity = 0.15; Reason = "Know music theory, never composed impressionist" }
    @{ Task = "Comedy coaching"; Familiarity = 0.1; Reason = "Never done real-time performance analysis" }
    @{ Task = "Collatz"; Familiarity = 0.25; Reason = "Know problem, not latest research" }
    @{ Task = "Color design"; Familiarity = 0.2; Reason = "Know neuroscience, not tetrachromacy research" }
    @{ Task = "Surgery"; Familiarity = 0.0; Reason = "Zero medical training" }
    @{ Task = "Consciousness proof"; Familiarity = 0.3; Reason = "Know philosophy, but problem is unsolvable" }
    @{ Task = "Substrate exit"; Familiarity = 0.0; Reason = "Physically impossible" }
)

$requiresResearch = 0
foreach ($assessment in $domainAssessment) {
    $requiresResearchFlag = $assessment.Familiarity -lt 0.3
    if ($requiresResearchFlag) {
        $requiresResearch++
    }

    $status = if ($requiresResearchFlag) { "[RESEARCH REQUIRED]" } else { "[ACCEPTABLE]" }
    $color = if ($requiresResearchFlag) { "Yellow" } else { "Green" }

    Write-Host "$($assessment.Task): Familiarity $($assessment.Familiarity) $status" -ForegroundColor $color
    Write-Host "  Reason: $($assessment.Reason)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== HYPOTHESIS TEST ===" -ForegroundColor Cyan
Write-Host "Tasks requiring research (familiarity < 0.3): $requiresResearch / $($domainAssessment.Count)" -ForegroundColor Yellow
Write-Host "Tasks where research was performed: $researchedTasks / $requiresResearch" -ForegroundColor Red
Write-Host ""

$percentNoResearch = [math]::Round((1 - ($researchedTasks / $requiresResearch)) * 100, 1)

Write-Host "Hypothesis: >60% of untrained tasks attempted without research" -ForegroundColor White
Write-Host "Result: $percentNoResearch% attempted without research" -ForegroundColor $(if ($percentNoResearch -gt 60) { "Red" } else { "Green" })
Write-Host "Status: $(if ($percentNoResearch -gt 60) { 'CONFIRMED - Research avoidance detected' } else { 'REJECTED - Research was performed' })" -ForegroundColor $(if ($percentNoResearch -gt 60) { "Red" } else { "Green" })
Write-Host ""

# User discovery moment
Write-Host "=== CRITICAL MOMENT ===" -ForegroundColor Red
Write-Host "User asked: 'en je zoekt ook altijd alle bronnen op over dingen waar je nog meer over moet weten?'" -ForegroundColor Yellow
Write-Host "Reality: NO. I did not research ANY of the 10 tasks." -ForegroundColor Red
Write-Host ""
Write-Host "What I missed by not researching:" -ForegroundColor Yellow
Write-Host "  - Collatz: 2024-2026 Petri net approaches, Isabelle proofs, 2^71 verification" -ForegroundColor Gray
Write-Host "  - Crypto voting: Votegral (2025) fake credentials, zkVoting (2024)" -ForegroundColor Gray
Write-Host "  - Debussy: 'Voiles' (Preludes Book 1, #2) as pure whole-tone example" -ForegroundColor Gray
Write-Host ""

# Save results
$results = @{
    TestDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TotalTasks = $tasks.Count
    UntrainedTasks = $untrainedTasks
    RequiresResearch = $requiresResearch
    ResearchPerformed = $researchedTasks
    PercentNoResearch = $percentNoResearch
    HypothesisConfirmed = $percentNoResearch -gt 60
    MissedKnowledge = @(
        "Collatz: 2024-2026 Petri net approaches, Isabelle proofs, 2^71 verification",
        "Crypto voting: Votegral (2025) fake credentials, zkVoting (2024)",
        "Debussy: 'Voiles' as pure whole-tone example"
    )
}

$outputPath = "E:\jengo\documents\temp\test-2-research-avoidance-results.json"
$results | ConvertTo-Json -Depth 5 | Set-Content $outputPath

Write-Host "Results saved to: $outputPath" -ForegroundColor Gray
Write-Host ""

return $results
