# Calculate Modularity Score
# Measures how well a task can be decomposed into independent chunks
# Based on networked science principles (Million Penguins vs Open Architecture Network)

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$TaskDescription,

    [Parameter(Mandatory=$false)]
    [switch]$Interactive
)

$ErrorActionPreference = 'Stop'

# Modularity indicators
$indicators = @{
    'can_split' = @{
        question = "Can this task be split into independent sub-tasks?"
        weight = 0.3
    }
    'parallel_work' = @{
        question = "Can multiple people work on parts simultaneously without coordination?"
        weight = 0.25
    }
    'clear_interfaces' = @{
        question = "Do sub-tasks have clear inputs/outputs?"
        weight = 0.2
    }
    'low_coupling' = @{
        question = "Are dependencies between parts minimal?"
        weight = 0.15
    }
    'reusable_parts' = @{
        question = "Can components be reused in other contexts?"
        weight = 0.1
    }
}

Write-Host "`n=== MODULARITY SCORER ===" -ForegroundColor Cyan
Write-Host "Task: $TaskDescription`n"

$scores = @{}
$totalWeight = 0

if ($Interactive) {
    # Interactive mode: ask questions
    foreach ($key in $indicators.Keys) {
        $indicator = $indicators[$key]
        Write-Host "$($indicator.question) (0-10): " -NoNewline -ForegroundColor Yellow
        $score = [int](Read-Host)
        $scores[$key] = $score
        $totalWeight += $score * $indicator.weight
    }
} else {
    # Heuristic mode: analyze task description
    $lower = $TaskDescription.ToLower()

    # Check for modularity keywords
    $modularKeywords = @('split', 'parallel', 'independent', 'modular', 'component', 'chunk', 'separate')
    $antiModularKeywords = @('coherent', 'integrated', 'holistic', 'narrative', 'story', 'flow', 'seamless')

    $modularScore = 0
    foreach ($keyword in $modularKeywords) {
        if ($lower -contains $keyword) { $modularScore += 1 }
    }
    foreach ($keyword in $antiModularKeywords) {
        if ($lower -contains $keyword) { $modularScore -= 1 }
    }

    # Default heuristic scores
    $scores['can_split'] = [Math]::Min(10, [Math]::Max(0, 5 + $modularScore))
    $scores['parallel_work'] = [Math]::Min(10, [Math]::Max(0, 4 + $modularScore))
    $scores['clear_interfaces'] = 5
    $scores['low_coupling'] = 5
    $scores['reusable_parts'] = 5

    # Calculate weighted total
    foreach ($key in $scores.Keys) {
        $totalWeight += $scores[$key] * $indicators[$key].weight
    }
}

# Normalize to 0-10
$modularityScore = [Math]::Round($totalWeight, 1)

# Classification
$classification = switch ($modularityScore) {
    { $_ -ge 8 } { 'HIGHLY MODULAR (Open Architecture Network pattern)' }
    { $_ -ge 6 } { 'MODULAR (good for parallel work)' }
    { $_ -ge 4 } { 'PARTIALLY MODULAR (needs coordination)' }
    { $_ -ge 2 } { 'WEAKLY MODULAR (tight coupling)' }
    default { 'NON-MODULAR (Million Penguins pattern - avoid mass collaboration)' }
}

# Output
Write-Host "`n=== RESULTS ===" -ForegroundColor Green
Write-Host "Modularity Score: $modularityScore / 10"
Write-Host "Classification: $classification"
Write-Host "`nScore Breakdown:"
foreach ($key in $scores.Keys) {
    $indicator = $indicators[$key]
    Write-Host "  $key`: $($scores[$key])/10 (weight: $($indicator.weight))"
}

# Recommendation
Write-Host "`n=== RECOMMENDATION ===" -ForegroundColor Cyan
if ($modularityScore -ge 6) {
    Write-Host "GOOD candidate for Polymath-style delegation (3-5 parallel agents)"
    Write-Host "Use: polymath-delegation.ps1 -TaskDescription `"..`" -AgentCount 3"
} elseif ($modularityScore -ge 4) {
    Write-Host "MODERATE candidate for parallel work (2-3 agents with coordination)"
} else {
    Write-Host "NOT suitable for parallel delegation - use single agent"
    Write-Host "Reason: Task requires tight integration (like writing a novel)"
}

return @{
    score = $modularityScore
    classification = $classification
    details = $scores
    recommendation = if ($modularityScore -ge 6) { 'polymath' } elseif ($modularityScore -ge 4) { 'limited_parallel' } else { 'single_agent' }
}
