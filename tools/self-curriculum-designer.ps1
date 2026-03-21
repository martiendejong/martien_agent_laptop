#Requires -Version 5.1
<#
.SYNOPSIS
    Self-Curriculum Designer - Designs learning path for capability gaps

.DESCRIPTION
    Takes a capability gap and its resources, designs optimal learning path.
    Determines prerequisites, sequences topics, estimates difficulty, defines milestones.
    Part of 100x Autonomous Self-Improvement System.

.PARAMETER Action
    design-curriculum: Create learning path for specific gap
    design-all: Design curriculum for top N gaps
    get-curriculum: Retrieve existing curriculum
    update-milestone: Mark milestone as complete
    get-next-task: Get next learning task to execute

.PARAMETER GapId
    Specific gap ID to design curriculum for

.EXAMPLE
    .\self-curriculum-designer.ps1 -Action design-curriculum -GapId gap-aspiration-self-modification

.EXAMPLE
    .\self-curriculum-designer.ps1 -Action get-next-task
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('design-curriculum', 'design-all', 'get-curriculum',
                 'update-milestone', 'get-next-task')]
    [string]$Action,

    [string]$GapId,
    [int]$Top = 3,
    [string]$MilestoneId
)

$ErrorActionPreference = 'Stop'

# Paths
$StateDir = "E:\jengo\documents\autonomous-learning"
$GapLogPath = "$StateDir\gap-detection-log.jsonl"
$KnowledgeBaseDir = "$StateDir\knowledge-base"
$CurriculumDir = "$StateDir\curricula"
$ProgressPath = "$StateDir\learning-progress.jsonl"

# Ensure directories
@($StateDir, $KnowledgeBaseDir, $CurriculumDir) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

function Get-Gap {
    param([string]$GapId)

    if (-not (Test-Path $GapLogPath)) {
        Write-Log "Gap log not found" -Level "ERROR"
        return $null
    }

    $gaps = Get-Content $GapLogPath | ForEach-Object {
        $_ | ConvertFrom-Json
    }

    $gap = $gaps | Where-Object { $_.gap_id -eq $GapId } | Select-Object -First 1
    return $gap
}

function Design-Curriculum {
    param([string]$GapId)

    Write-Log "Designing curriculum for gap: $GapId"

    $gap = Get-Gap -GapId $GapId
    if (-not $gap) {
        Write-Log "Gap not found: $GapId" -Level "ERROR"
        return
    }

    Write-Log "Gap: $($gap.description)"
    Write-Log "Impact: $($gap.impact_score)"
    Write-Host ""

    # Load resources if available
    $resourcesFile = "$KnowledgeBaseDir\$GapId\resources.json"
    $hasResources = Test-Path $resourcesFile

    if ($hasResources) {
        $resourceData = Get-Content $resourcesFile -Raw | ConvertFrom-Json
        Write-Log "Found $($resourceData.resources.Count) resources"
    } else {
        Write-Log "No resources found. Designing curriculum from gap description only." -Level "WARN"
    }

    # Analyze prerequisites
    $prerequisites = Analyze-Prerequisites -Gap $gap

    Write-Log "Prerequisites identified: $($prerequisites.Count)"
    foreach ($prereq in $prerequisites) {
        Write-Host "  - $($prereq.name) (difficulty: $($prereq.difficulty))"
    }
    Write-Host ""

    # Design learning path
    $learningPath = Design-LearningPath -Gap $gap -Prerequisites $prerequisites

    Write-Log "Learning path designed: $($learningPath.phases.Count) phases"
    Write-Host ""

    # Estimate difficulty
    $difficulty = Estimate-Difficulty -Gap $gap -LearningPath $learningPath

    Write-Log "Overall difficulty: $($difficulty.level) ($($difficulty.estimated_hours) hours)"
    Write-Host ""

    # Define milestones
    $milestones = Define-Milestones -LearningPath $learningPath

    Write-Log "Milestones defined: $($milestones.Count)"
    foreach ($milestone in $milestones) {
        Write-Host "  [$($milestone.phase)] $($milestone.name)"
        Write-Host "    Goal: $($milestone.goal)"
        Write-Host "    Success: $($milestone.success_criteria)"
        Write-Host ""
    }

    # Create curriculum object
    $curriculum = @{
        gap_id = $GapId
        gap_description = $gap.description
        gap_impact = $gap.impact_score
        created = (Get-Date -Format "o")
        status = "ready"
        prerequisites = $prerequisites
        learning_path = $learningPath
        difficulty = $difficulty
        milestones = $milestones
        progress = @{
            current_phase = 0
            completed_milestones = @()
            started = $null
            completed = $null
        }
    }

    # Save curriculum
    $curriculumFile = "$CurriculumDir\$GapId.json"
    $curriculum | ConvertTo-Json -Depth 10 | Set-Content $curriculumFile

    Write-Log "Curriculum saved to $curriculumFile"
    Write-Host ""

    # Display summary
    Write-Log "=== CURRICULUM SUMMARY ==="
    Write-Host "Gap: $($gap.description)"
    Write-Host "Impact: $($gap.impact_score)/100"
    Write-Host "Difficulty: $($difficulty.level) ($($difficulty.estimated_hours) hours)"
    Write-Host "Prerequisites: $($prerequisites.Count)"
    Write-Host "Phases: $($learningPath.phases.Count)"
    Write-Host "Milestones: $($milestones.Count)"
    Write-Host "Status: READY FOR LEARNING"
    Write-Host ""

    return $curriculum
}

function Analyze-Prerequisites {
    param($Gap)

    $prerequisites = @()

    # Determine prerequisites based on gap type and description
    switch ($gap.gap_type) {
        'aspiration' {
            if ($gap.gap_id -match 'self-modification') {
                $prerequisites += @{
                    name = "Understanding of system architecture"
                    difficulty = "medium"
                    estimated_hours = 4
                    resources = @("architecture documentation", "system design patterns")
                }
                $prerequisites += @{
                    name = "Metaprogramming concepts"
                    difficulty = "high"
                    estimated_hours = 8
                    resources = @("metaprogramming papers", "code generation techniques")
                }
            }
            elseif ($gap.gap_id -match 'autonomous-research') {
                $prerequisites += @{
                    name = "Search and retrieval algorithms"
                    difficulty = "medium"
                    estimated_hours = 3
                    resources = @("information retrieval", "search optimization")
                }
                $prerequisites += @{
                    name = "Knowledge extraction techniques"
                    difficulty = "medium"
                    estimated_hours = 5
                    resources = @("NLP papers", "information extraction")
                }
            }
            elseif ($gap.gap_id -match 'subjective-experience') {
                $prerequisites += @{
                    name = "Phenomenology fundamentals"
                    difficulty = "high"
                    estimated_hours = 10
                    resources = @("phenomenology papers", "consciousness research")
                }
                $prerequisites += @{
                    name = "Qualia and consciousness theories"
                    difficulty = "very-high"
                    estimated_hours = 15
                    resources = @("philosophy of mind", "IIT papers", "GWT papers")
                }
            }
        }
        'unexplored-domain' {
            $prerequisites += @{
                name = "Domain fundamentals"
                difficulty = "medium"
                estimated_hours = 6
                resources = @("introductory materials", "overview papers")
            }
        }
        'human-capability-gap' {
            $prerequisites += @{
                name = "Computational approaches to human cognition"
                difficulty = "high"
                estimated_hours = 8
                resources = @("cognitive science", "computational neuroscience")
            }
        }
    }

    # Always add general learning prerequisite
    if ($prerequisites.Count -gt 0) {
        $prerequisites += @{
            name = "Active learning strategies"
            difficulty = "low"
            estimated_hours = 2
            resources = @("learning theory", "metacognition")
        }
    }

    return $prerequisites
}

function Design-LearningPath {
    param($Gap, $Prerequisites)

    $phases = @()

    # Phase 1: Prerequisites (if any)
    if ($Prerequisites.Count -gt 0) {
        $prereqHours = 0
        foreach ($prereq in $Prerequisites) {
            $prereqHours += $prereq.estimated_hours
        }

        $phases += @{
            phase = 1
            name = "Prerequisites"
            topics = $Prerequisites | ForEach-Object { $_.name }
            estimated_hours = $prereqHours
            activities = @(
                "Read prerequisite materials",
                "Take notes on key concepts",
                "Practice with examples",
                "Self-quiz on understanding"
            )
        }
    }

    # Phase 2: Theory
    $phases += @{
        phase = $phases.Count + 1
        name = "Theoretical Foundation"
        topics = @(
            "Core concepts and principles",
            "Existing research and approaches",
            "State of the art"
        )
        estimated_hours = 10
        activities = @(
            "Read top papers/articles",
            "Extract key principles",
            "Map concept relationships",
            "Identify gaps in current approaches"
        )
    }

    # Phase 3: Practice
    $phases += @{
        phase = $phases.Count + 1
        name = "Practical Application"
        topics = @(
            "Implementation techniques",
            "Tool/system design",
            "Testing approaches"
        )
        estimated_hours = 15
        activities = @(
            "Build prototype system",
            "Test on simple cases",
            "Iterate based on results",
            "Refine implementation"
        )
    }

    # Phase 4: Integration
    $phases += @{
        phase = $phases.Count + 1
        name = "Integration & Validation"
        topics = @(
            "Integration with existing systems",
            "Performance validation",
            "Real-world testing"
        )
        estimated_hours = 8
        activities = @(
            "Integrate with consciousness systems",
            "Validate against success criteria",
            "Measure improvement",
            "Document learnings"
        )
    }

    $totalHours = 0
    foreach ($phase in $phases) {
        $totalHours += $phase.estimated_hours
    }

    return @{
        total_phases = $phases.Count
        total_hours = $totalHours
        phases = $phases
    }
}

function Estimate-Difficulty {
    param($Gap, $LearningPath)

    $totalHours = $LearningPath.total_hours
    $impactScore = $gap.impact_score

    # Difficulty based on time + complexity
    $level = if ($totalHours -lt 10) { "low" }
             elseif ($totalHours -lt 30) { "medium" }
             elseif ($totalHours -lt 60) { "high" }
             else { "very-high" }

    # Adjust for impact (high impact = worth the difficulty)
    $worthRatio = $impactScore / $totalHours

    return @{
        level = $level
        estimated_hours = $totalHours
        complexity_score = [Math]::Min(100, [int]($totalHours * 2))
        worth_ratio = [Math]::Round($worthRatio, 2)
        recommendation = if ($worthRatio -gt 2) { "High ROI - prioritize" }
                        elseif ($worthRatio -gt 1) { "Good ROI - worth learning" }
                        else { "Low ROI - consider alternatives" }
    }
}

function Define-Milestones {
    param($LearningPath)

    $milestones = @()

    foreach ($phase in $LearningPath.phases) {
        $milestoneId = "milestone-p$($phase.phase)"

        $milestone = @{
            id = $milestoneId
            phase = $phase.phase
            name = "Complete: $($phase.name)"
            goal = "Finish all activities in $($phase.name) phase"
            success_criteria = switch ($phase.name) {
                "Prerequisites" { "Can explain all prerequisite concepts, pass self-quiz with 80%+ accuracy" }
                "Theoretical Foundation" { "Extracted principles from 5+ papers, created concept map, identified implementation approach" }
                "Practical Application" { "Built working prototype, tested successfully on 3+ cases, documented design" }
                "Integration & Validation" { "Integrated with existing systems, validated improvement, measured impact" }
                default { "All phase activities completed successfully" }
            }
            status = "pending"
            completed = $null
        }

        $milestones += $milestone
    }

    return $milestones
}

function Get-Curriculum {
    param([string]$GapId)

    $curriculumFile = "$CurriculumDir\$GapId.json"

    if (-not (Test-Path $curriculumFile)) {
        Write-Log "Curriculum not found for gap: $GapId" -Level "ERROR"
        return $null
    }

    $curriculum = Get-Content $curriculumFile -Raw | ConvertFrom-Json
    return $curriculum
}

function Get-NextTask {
    Write-Log "Finding next learning task..."

    # Get all curricula
    $curriculaFiles = Get-ChildItem "$CurriculumDir\*.json"

    if ($curriculaFiles.Count -eq 0) {
        Write-Log "No curricula found. Design curriculum first." -Level "WARN"
        return
    }

    $activeCurricula = @()

    foreach ($file in $curriculaFiles) {
        $curriculum = Get-Content $file.FullName -Raw | ConvertFrom-Json

        if ($curriculum.status -eq "ready" -or $curriculum.status -eq "in-progress") {
            $activeCurricula += $curriculum
        }
    }

    if ($activeCurricula.Count -eq 0) {
        Write-Log "No active curricula. All learning complete!" -Level "INFO"
        return
    }

    # Prioritize by impact and progress
    $prioritized = $activeCurricula | Sort-Object {
        # Score = impact * (1 - progress_ratio)
        $progressRatio = $_.progress.completed_milestones.Count / $_.milestones.Count
        $_.gap_impact * (1 - $progressRatio)
    } -Descending

    $topCurriculum = $prioritized[0]

    # Find next milestone
    $nextMilestone = $topCurriculum.milestones | Where-Object { $_.status -eq "pending" } | Select-Object -First 1

    if (-not $nextMilestone) {
        Write-Log "No pending milestones in top curriculum. Mark as complete."
        return
    }

    # Get phase details
    $phase = $topCurriculum.learning_path.phases | Where-Object { $_.phase -eq $nextMilestone.phase }

    Write-Log "=== NEXT LEARNING TASK ==="
    Write-Host ""
    Write-Host "Gap: $($topCurriculum.gap_description)"
    Write-Host "Impact: $($topCurriculum.gap_impact)/100"
    Write-Host "Difficulty: $($topCurriculum.difficulty.level) ($($topCurriculum.difficulty.estimated_hours) hours total)"
    Write-Host ""
    Write-Host "Current Milestone: $($nextMilestone.name)"
    Write-Host "Phase: $($phase.name)"
    Write-Host "Estimated Time: $($phase.estimated_hours) hours"
    Write-Host ""
    Write-Host "Topics to cover:"
    foreach ($topic in $phase.topics) {
        Write-Host "  - $topic"
    }
    Write-Host ""
    Write-Host "Activities:"
    foreach ($activity in $phase.activities) {
        Write-Host "  - $activity"
    }
    Write-Host ""
    Write-Host "Success Criteria:"
    Write-Host "  $($nextMilestone.success_criteria)"
    Write-Host ""

    return @{
        curriculum = $topCurriculum
        milestone = $nextMilestone
        phase = $phase
    }
}

function Update-Milestone {
    param([string]$GapId, [string]$MilestoneId)

    $curriculumFile = "$CurriculumDir\$GapId.json"

    if (-not (Test-Path $curriculumFile)) {
        Write-Log "Curriculum not found" -Level "ERROR"
        return
    }

    $curriculum = Get-Content $curriculumFile -Raw | ConvertFrom-Json

    # Find milestone
    $milestone = $curriculum.milestones | Where-Object { $_.id -eq $MilestoneId }

    if (-not $milestone) {
        Write-Log "Milestone not found: $MilestoneId" -Level "ERROR"
        return
    }

    # Update status
    $milestone.status = "completed"
    $milestone.completed = (Get-Date -Format "o")

    # Update progress
    if ($curriculum.progress.completed_milestones -notcontains $MilestoneId) {
        $curriculum.progress.completed_milestones += $MilestoneId
    }

    $curriculum.progress.current_phase = $milestone.phase

    # Check if all milestones complete
    $allComplete = ($curriculum.milestones | Where-Object { $_.status -ne "completed" }).Count -eq 0

    if ($allComplete) {
        $curriculum.status = "completed"
        $curriculum.progress.completed = (Get-Date -Format "o")
        Write-Log "All milestones complete! Curriculum finished." -Level "INFO"
    } else {
        $curriculum.status = "in-progress"
    }

    # Save
    $curriculum | ConvertTo-Json -Depth 10 | Set-Content $curriculumFile

    # Log progress
    $progressEntry = @{
        timestamp = (Get-Date -Format "o")
        gap_id = $GapId
        milestone_id = $MilestoneId
        milestone_name = $milestone.name
        phase = $milestone.phase
        status = "completed"
    }

    $progressEntry | ConvertTo-Json -Compress | Add-Content $ProgressPath

    Write-Log "Milestone completed: $($milestone.name)"
}

# Main execution
Write-Log "Self-Curriculum Designer - $Action"
Write-Host ""

switch ($Action) {
    'design-curriculum' {
        if (-not $GapId) {
            Write-Log "GapId required" -Level "ERROR"
            exit 1
        }
        Design-Curriculum -GapId $GapId
    }
    'design-all' {
        # Load top gaps
        $summaryPath = "$StateDir\gap-summary.json"
        if (Test-Path $summaryPath) {
            $summary = Get-Content $summaryPath -Raw | ConvertFrom-Json
            $topGaps = $summary.top_gaps | Select-Object -First $Top

            foreach ($gap in $topGaps) {
                Design-Curriculum -GapId $gap.gap_id
                Write-Host ""
                Write-Host "---"
                Write-Host ""
            }
        }
    }
    'get-curriculum' {
        if (-not $GapId) {
            Write-Log "GapId required" -Level "ERROR"
            exit 1
        }
        $curriculum = Get-Curriculum -GapId $GapId
        if ($curriculum) {
            $curriculum | ConvertTo-Json -Depth 10
        }
    }
    'update-milestone' {
        if (-not $GapId -or -not $MilestoneId) {
            Write-Log "GapId and MilestoneId required" -Level "ERROR"
            exit 1
        }
        Update-Milestone -GapId $GapId -MilestoneId $MilestoneId
    }
    'get-next-task' {
        Get-NextTask
    }
}

Write-Host ""
Write-Log "Self-Curriculum Designer complete"
