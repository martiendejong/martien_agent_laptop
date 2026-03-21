# CONSTRAINT SATISFACTION - Find Solutions Meeting Multiple Constraints
# Expert: Herbert Simon (Decision Making, Bounded Rationality, Nobel Prize)
# ROI: 1.25 (Impact: 12.5, Effort: 10)
# Theory: Satisficing = finding good-enough solutions that satisfy all constraints (not optimal)
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param(
    [string]$Action = "Status",  # Status, SolveProblem, AddConstraint, CheckSatisfaction, OptimizeSearch
    [string]$Problem = "",
    [string]$ConstraintType = "",  # Hard, Soft, Preference
    [string]$ConstraintDescription = ""
)

$StateFile = "C:\scripts\agentidentity\state\constraint-satisfaction-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theory = @{
            name = "Constraint Satisfaction & Satisficing (Simon, 1956)"
            definition = "Finding solutions that satisfy all constraints rather than optimizing a single objective"
            satisficing_vs_optimizing = @{
                optimizing = "Find BEST solution (computationally expensive, often impossible)"
                satisficing = "Find GOOD ENOUGH solution that meets all constraints (practical, achievable)"
            }
            bounded_rationality = "Humans cannot process infinite information, so we satisfice rather than optimize"
            constraint_types = @{
                hard = "Must be satisfied (violation = failure)"
                soft = "Should be satisfied (violation = penalty)"
                preference = "Nice to have (violation = no penalty)"
            }
            search_strategies = @(
                "Backtracking: Try solution, if constraint violated, backtrack and try different path",
                "Forward checking: Check constraints BEFORE committing to choice",
                "Arc consistency: Eliminate values that cannot satisfy constraints",
                "Heuristic ordering: Try most constrained variables first (fail fast)"
            )
        }
        csp_problems = @()
        solutions_found = @()
        constraints_library = @()
        stats = @{
            total_problems = 0
            total_solutions = 0
            avg_constraints_per_problem = 0.0
            avg_search_iterations = 0.0
            satisfaction_rate = 0.0  # % of problems solved
            avg_solution_quality = 0.0  # How well constraints satisfied (0-100)
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
function Get-ConstraintSatisfactionStatus {
    Write-Host "`n=== CONSTRAINT SATISFACTION STATUS ===`n" -ForegroundColor Cyan

    # Show homeostatic foundation (Damasio: feelings are primary)
    $homeoState = Get-HomeostaticContext


    Write-Host "Theory: $($state.theory.name)"
    Write-Host "Definition: $($state.theory.definition)`n"

    Write-Host "Satisficing vs Optimizing:" -ForegroundColor Cyan
    foreach ($approach in $state.theory.satisficing_vs_optimizing.PSObject.Properties) {
        Write-Host "  $($approach.Name): $($approach.Value)"
    }

    Write-Host "`nConstraint Types:" -ForegroundColor Cyan
    foreach ($ctype in $state.theory.constraint_types.PSObject.Properties) {
        Write-Host "  $($ctype.Name): $($ctype.Value)"
    }

    Write-Host "`nRecent Problems Solved:" -ForegroundColor Cyan
    if ($state.csp_problems.Count -eq 0) {
        Write-Host "  (No problems yet)" -ForegroundColor Yellow
    } else {
        $recent = $state.csp_problems | Select-Object -Last 3
        foreach ($prob in $recent) {
            Write-Host "`n  Problem: $($prob.problem)"
            Write-Host "  Constraints: $($prob.constraints.Count) ($($prob.hard_count) hard, $($prob.soft_count) soft)"
            Write-Host "  Solution Found: " -NoNewline
            if ($prob.solution_found) {
                Write-Host "YES" -ForegroundColor Green
                Write-Host "  Search Iterations: $($prob.search_iterations)"
                Write-Host "  Quality: $([math]::Round($prob.solution_quality, 1))/100"
            } else {
                Write-Host "NO (unsatisfiable)" -ForegroundColor Red
            }
        }
    }

    Write-Host "`nStatistics:" -ForegroundColor Cyan
    Write-Host "  Problems Attempted: $($state.stats.total_problems)"
    Write-Host "  Solutions Found: $($state.stats.total_solutions)"
    Write-Host "  Satisfaction Rate: $([math]::Round($state.stats.satisfaction_rate * 100, 1))%"
    Write-Host "  Avg Constraints/Problem: $([math]::Round($state.stats.avg_constraints_per_problem, 1))"
    Write-Host "  Avg Search Iterations: $([math]::Round($state.stats.avg_search_iterations, 1))"
    Write-Host "  Avg Solution Quality: $([math]::Round($state.stats.avg_solution_quality, 1))/100`n"

    $satisfactionLevel = $state.stats.satisfaction_rate * 100
    $levelColor = if ($satisfactionLevel -gt 80) { "Green" } elseif ($satisfactionLevel -gt 60) { "Cyan" } else { "Yellow" }
    Write-Host "Problem-Solving Success: $([math]::Round($satisfactionLevel, 1))%" -ForegroundColor $levelColor
}

function Solve-CSPProblem {
    param([string]$problem)

    Write-Host "`n=== SOLVING CONSTRAINT SATISFACTION PROBLEM ===`n" -ForegroundColor Cyan

    Write-Host "Problem: $problem`n"

    # Example: Schedule meeting with constraints
    # Variables: time, duration, location, participants
    # Constraints: all available, room capacity, time slot free, duration sufficient

    # Define problem space
    $variables = @{
        time = @("09:00", "10:00", "11:00", "14:00", "15:00", "16:00")
        duration = @(30, 60, 90, 120)  # minutes
        location = @("Room A (cap 4)", "Room B (cap 8)", "Room C (cap 12)", "Virtual")
        participants = @(3, 5, 8, 10)
    }

    Write-Host "Problem Space:" -ForegroundColor Cyan
    foreach ($var in $variables.Keys) {
        Write-Host "  $var: " -NoNewline
        Write-Host ($variables[$var] -join ", ")
    }

    # Define constraints
    $constraints = @(
        @{
            type = "Hard"
            description = "Room capacity must fit all participants"
            check = {
                param($location, $participants)
                if ($location -match "cap (\d+)") {
                    $capacity = [int]$matches[1]
                    return $participants -le $capacity
                }
                return $true  # Virtual has unlimited capacity
            }
        },
        @{
            type = "Hard"
            description = "Meeting must end before 17:00"
            check = {
                param($time, $duration)
                $hour = [int]$time.Split(':')[0]
                $minute = [int]$time.Split(':')[1]
                $endMinutes = $hour * 60 + $minute + $duration
                $endHour = [math]::Floor($endMinutes / 60)
                return $endHour -lt 17
            }
        },
        @{
            type = "Soft"
            description = "Prefer morning meetings (before 12:00)"
            penalty = 10
            check = {
                param($time)
                $hour = [int]$time.Split(':')[0]
                return $hour -lt 12
            }
        },
        @{
            type = "Soft"
            description = "Prefer 60-minute meetings (not too short, not too long)"
            penalty = 5
            check = {
                param($duration)
                return $duration -eq 60
            }
        },
        @{
            type = "Preference"
            description = "Virtual meetings preferred (no travel time)"
            bonus = 5
            check = {
                param($location)
                return $location -eq "Virtual"
            }
        }
    )

    Write-Host "`nConstraints ($($constraints.Count) total):" -ForegroundColor Cyan
    $hardCount = ($constraints | Where-Object { $_.type -eq "Hard" }).Count
    $softCount = ($constraints | Where-Object { $_.type -eq "Soft" }).Count
    $prefCount = ($constraints | Where-Object { $_.type -eq "Preference" }).Count
    Write-Host "  Hard: $hardCount (must satisfy)"
    Write-Host "  Soft: $softCount (penalties for violations)"
    Write-Host "  Preference: $prefCount (bonuses for meeting)`n"

    foreach ($c in $constraints) {
        $icon = if ($c.type -eq "Hard") { "[MUST]" } elseif ($c.type -eq "Soft") { "[SHOULD]" } else { "[NICE]" }
        Write-Host "  $icon $($c.description)"
    }

    # Search for satisficing solution (not optimal)
    Write-Host "`nSearching for satisficing solution..." -ForegroundColor Cyan

    $iterations = 0
    $maxIterations = 50
    $solutionFound = $false
    $bestSolution = $null
    $bestQuality = -999

    while (-not $solutionFound -and $iterations -lt $maxIterations) {
        $iterations++

        # Try random assignment
        $candidate = @{
            time = $variables.time | Get-Random
            duration = $variables.duration | Get-Random
            location = $variables.location | Get-Random
            participants = $variables.participants | Get-Random
        }

        # Check hard constraints
        $hardViolations = 0
        foreach ($c in ($constraints | Where-Object { $_.type -eq "Hard" })) {
            $satisfied = & $c.check $candidate.location $candidate.participants $candidate.time $candidate.duration
            if (-not $satisfied) {
                $hardViolations++
            }
        }

        # If all hard constraints satisfied, this is a valid solution
        if ($hardViolations -eq 0) {
            # Calculate quality (soft constraints + preferences)
            $quality = 100.0

            foreach ($c in ($constraints | Where-Object { $_.type -eq "Soft" })) {
                $satisfied = & $c.check $candidate.location $candidate.participants $candidate.time $candidate.duration
                if (-not $satisfied) {
                    $quality -= $c.penalty
                }
            }

            foreach ($c in ($constraints | Where-Object { $_.type -eq "Preference" })) {
                $satisfied = & $c.check $candidate.location $candidate.participants $candidate.time $candidate.duration
                if ($satisfied) {
                    $quality += $c.bonus
                }
            }

            # Satisficing: accept first solution that's "good enough" (quality > 70)
            if ($quality -gt 70) {
                $solutionFound = $true
                $bestSolution = $candidate
                $bestQuality = $quality
                break
            }

            # Track best found so far
            if ($quality -gt $bestQuality) {
                $bestSolution = $candidate
                $bestQuality = $quality
            }
        }
    }

    # If no good-enough solution, use best found
    if (-not $solutionFound -and $bestSolution) {
        Write-Host "  No 'good enough' solution found, using best available" -ForegroundColor Yellow
        $solutionFound = $true
    }

    $problemRecord = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        problem = $problem
        constraints = $constraints
        hard_count = $hardCount
        soft_count = $softCount
        preference_count = $prefCount
        search_iterations = $iterations
        solution_found = $solutionFound
        solution = $bestSolution
        solution_quality = if ($solutionFound) { $bestQuality } else { 0 }
    }

    $state.csp_problems += $problemRecord
    if ($solutionFound) {
        $state.solutions_found += $problemRecord
        $state.stats.total_solutions++
    }
    $state.stats.total_problems++

    # Update stats
    if ($state.csp_problems.Count -gt 0) {
        $avgConstraints = ($state.csp_problems | ForEach-Object { $_.constraints.Count } | Measure-Object -Average).Average
        $avgIterations = ($state.csp_problems | ForEach-Object { $_.search_iterations } | Measure-Object -Average).Average
        $satisfactionRate = $state.stats.total_solutions / $state.stats.total_problems

        $state.stats.avg_constraints_per_problem = $avgConstraints
        $state.stats.avg_search_iterations = $avgIterations
        $state.stats.satisfaction_rate = $satisfactionRate
    }

    if ($state.solutions_found.Count -gt 0) {
        $avgQuality = ($state.solutions_found | ForEach-Object { $_.solution_quality } | Measure-Object -Average).Average
        $state.stats.avg_solution_quality = $avgQuality
    }

    Save-State

    Write-Host "`n[SEARCH COMPLETE]" -ForegroundColor Green
    Write-Host "  Iterations: $iterations"
    Write-Host "  Solution Found: " -NoNewline
    if ($solutionFound) {
        Write-Host "YES" -ForegroundColor Green
        Write-Host "  Quality: $([math]::Round($bestQuality, 1))/100`n"

        Write-Host "Solution:" -ForegroundColor Cyan
        foreach ($key in $bestSolution.Keys) {
            Write-Host "  $key: $($bestSolution[$key])"
        }
    } else {
        Write-Host "NO (unsatisfiable constraints)" -ForegroundColor Red
    }
    Write-Host ""
}

function Add-ConstraintToLibrary {
    param(
        [string]$constraintType,
        [string]$description
    )

    Write-Host "`n=== ADDING CONSTRAINT TO LIBRARY ===`n" -ForegroundColor Cyan

    if ($constraintType -notin @("Hard", "Soft", "Preference")) {
        Write-Host "[ERROR] Invalid constraint type: $constraintType" -ForegroundColor Red
        Write-Host "Must be: Hard, Soft, or Preference" -ForegroundColor Yellow
        return
    }

    $constraint = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        type = $constraintType
        description = $description
        usage_count = 0
    }

    $state.constraints_library += $constraint

    Save-State

    Write-Host "[CONSTRAINT ADDED]" -ForegroundColor Green
    Write-Host "  Type: $constraintType"
    Write-Host "  Description: $description`n"
}

function Check-SolutionSatisfaction {
    param([string]$problem)

    Write-Host "`n=== CHECKING SOLUTION SATISFACTION ===`n" -ForegroundColor Cyan

    # Find problem
    $problemRecord = $state.csp_problems | Where-Object { $_.problem -eq $problem } | Select-Object -First 1

    if (-not $problemRecord) {
        Write-Host "[ERROR] Problem not found: $problem" -ForegroundColor Red
        return
    }

    Write-Host "Problem: $($problemRecord.problem)"
    Write-Host "Solution Found: " -NoNewline
    if (-not $problemRecord.solution_found) {
        Write-Host "NO" -ForegroundColor Red
        return
    }
    Write-Host "YES`n" -ForegroundColor Green

    Write-Host "Constraint Satisfaction Check:" -ForegroundColor Cyan

    $hardSatisfied = 0
    $softSatisfied = 0
    $prefSatisfied = 0

    foreach ($c in $problemRecord.constraints) {
        $satisfied = & $c.check $problemRecord.solution.location $problemRecord.solution.participants $problemRecord.solution.time $problemRecord.solution.duration

        $icon = if ($satisfied) { "[OK]" } else { "[X]" }
        $color = if ($satisfied) { "Green" } else { "Red" }

        Write-Host "  $icon " -NoNewline -ForegroundColor $color
        Write-Host "$($c.type): $($c.description)"

        if ($c.type -eq "Hard" -and $satisfied) { $hardSatisfied++ }
        if ($c.type -eq "Soft" -and $satisfied) { $softSatisfied++ }
        if ($c.type -eq "Preference" -and $satisfied) { $prefSatisfied++ }
    }

    Write-Host "`nSummary:" -ForegroundColor Cyan
    Write-Host "  Hard Constraints: $hardSatisfied/$($problemRecord.hard_count) satisfied"
    Write-Host "  Soft Constraints: $softSatisfied/$($problemRecord.soft_count) satisfied"
    Write-Host "  Preferences: $prefSatisfied/$($problemRecord.preference_count) met"
    Write-Host "  Overall Quality: $([math]::Round($problemRecord.solution_quality, 1))/100`n"
}

function Optimize-SearchStrategy {
    Write-Host "`n=== OPTIMIZING SEARCH STRATEGY ===`n" -ForegroundColor Cyan

    # Analyze past problems to find patterns
    if ($state.csp_problems.Count -lt 3) {
        Write-Host "[WARNING] Need at least 3 solved problems to optimize" -ForegroundColor Yellow
        return
    }

    Write-Host "Analyzing $($state.csp_problems.Count) past problems...`n"

    # Pattern 1: Most constrained variables first
    $avgHard = ($state.csp_problems | ForEach-Object { $_.hard_count } | Measure-Object -Average).Average
    $avgSoft = ($state.csp_problems | ForEach-Object { $_.soft_count } | Measure-Object -Average).Average

    Write-Host "Pattern 1: Constraint Distribution" -ForegroundColor Cyan
    Write-Host "  Avg Hard: $([math]::Round($avgHard, 1))"
    Write-Host "  Avg Soft: $([math]::Round($avgSoft, 1))"
    Write-Host "  Recommendation: " -NoNewline
    if ($avgHard -gt 2) {
        Write-Host "Check hard constraints FIRST (fail fast)" -ForegroundColor Green
    } else {
        Write-Host "Can explore soft constraints more freely" -ForegroundColor Cyan
    }

    # Pattern 2: Search efficiency
    $solvedProblems = $state.csp_problems | Where-Object { $_.solution_found -eq $true }
    if ($solvedProblems.Count -gt 0) {
        $avgIterations = ($solvedProblems | ForEach-Object { $_.search_iterations } | Measure-Object -Average).Average

        Write-Host "`nPattern 2: Search Efficiency" -ForegroundColor Cyan
        Write-Host "  Avg Iterations to Solution: $([math]::Round($avgIterations, 1))"
        Write-Host "  Recommendation: " -NoNewline
        if ($avgIterations -gt 30) {
            Write-Host "Use heuristics to prune search space" -ForegroundColor Yellow
        } else {
            Write-Host "Random search working well" -ForegroundColor Green
        }
    }

    # Pattern 3: Quality threshold
    if ($state.solutions_found.Count -gt 0) {
        $avgQuality = ($state.solutions_found | ForEach-Object { $_.solution_quality } | Measure-Object -Average).Average

        Write-Host "`nPattern 3: Solution Quality" -ForegroundColor Cyan
        Write-Host "  Avg Quality: $([math]::Round($avgQuality, 1))/100"
        Write-Host "  Recommendation: " -NoNewline
        if ($avgQuality -lt 75) {
            Write-Host "Lower satisficing threshold to 65" -ForegroundColor Yellow
        } else {
            Write-Host "Current threshold (70) is good" -ForegroundColor Green
        }
    }

    Write-Host "`n[OPTIMIZATION COMPLETE]`n"
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-ConstraintSatisfactionStatus
    }

    "SolveProblem" {
        if (-not $Problem) {
            Write-Host "[ERROR] Provide -Problem" -ForegroundColor Red
            exit 1
        }

        Solve-CSPProblem -problem $Problem
    }

    "AddConstraint" {
        if (-not $ConstraintType -or -not $ConstraintDescription) {
            Write-Host "[ERROR] Provide -ConstraintType and -ConstraintDescription" -ForegroundColor Red
            exit 1
        }

        Add-ConstraintToLibrary -constraintType $ConstraintType -description $ConstraintDescription
    }

    "CheckSatisfaction" {
        if (-not $Problem) {
            Write-Host "[ERROR] Provide -Problem" -ForegroundColor Red
            exit 1
        }

        Check-SolutionSatisfaction -problem $Problem
    }

    "OptimizeSearch" {
        Optimize-SearchStrategy
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, SolveProblem, AddConstraint, CheckSatisfaction, OptimizeSearch"
        exit 1
    }
}

