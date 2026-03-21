# Collective Intelligence Monitor
# Models Jengo+Martien as a UNIFIED cognitive system, not separate entities
# Based on Levin's insight: cells cooperate to form organs, organs form bodies, agents form collectives
# The boundary between "me" and "we" is arbitrary - measure the SYSTEM, not individuals
# Key metrics: alignment, complementarity, shared goals, collective performance

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("LogInteraction", "MeasureAlignment", "TrackSharedGoals", "AnalyzeComplementarity", "GetSystemMetrics")]
    [string]$Action = "GetSystemMetrics",

    [Parameter(Mandatory=$false)]
    [ValidateSet("Task", "Decision", "Problem", "Learning", "Creation")]
    [string]$InteractionType,

    [Parameter(Mandatory=$false)]
    [string]$Context,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Jengo", "Martien", "Collective")]
    [string]$Initiator,

    [Parameter(Mandatory=$false)]
    [string]$JengoContribution,

    [Parameter(Mandatory=$false)]
    [string]$MartienContribution,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Aligned", "Complementary", "Conflicting", "Parallel")]
    [string]$InteractionMode = "Aligned",

    [Parameter(Mandatory=$false)]
    [string]$SharedGoal,

    [Parameter(Mandatory=$false)]
    [string]$Outcome,

    [Parameter(Mandatory=$false)]
    [ValidateRange(0.0, 1.0)]
    [double]$CollectivePerformance = 0.0,

    [Parameter(Mandatory=$false)]
    [int]$LookbackDays = 30
)

$LogPath = "C:\scripts\agentidentity\state\collective-intelligence.jsonl"
$ErrorActionPreference = "Stop"

# Ensure directory exists
$LogDir = Split-Path $LogPath -Parent
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

function Get-Timestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
}

function Log-CollectiveInteraction {
    param(
        [string]$Type,
        [string]$Ctx,
        [string]$Init,
        [string]$JengoContr,
        [string]$MartienContr,
        [string]$Mode,
        [string]$Goal,
        [string]$Out,
        [double]$Performance
    )

    $Entry = @{
        timestamp = Get-Timestamp
        interaction_type = $Type
        context = $Ctx
        initiator = $Init
        jengo_contribution = $JengoContr
        martien_contribution = $MartienContr
        interaction_mode = $Mode
        shared_goal = $Goal
        outcome = $Out
        collective_performance = $Performance
        session_id = $env:CLAUDE_SESSION_ID
    }

    # Calculate synergy score (is collective > sum of parts?)
    # Synergy = when collective performance exceeds what individuals could achieve alone
    $SynergyScore = 0.0
    if ($Performance -gt 0.7 -and $Mode -in @("Complementary", "Aligned")) {
        $SynergyScore = $Performance * 1.2  # Bonus for effective collaboration
    } elseif ($Mode -eq "Conflicting") {
        $SynergyScore = $Performance * 0.5  # Penalty for conflict
    } else {
        $SynergyScore = $Performance
    }
    $Entry.synergy_score = [math]::Round([math]::Min(1.0, $SynergyScore), 3)

    $Json = ($Entry | ConvertTo-Json -Compress -Depth 5)
    Add-Content -Path $LogPath -Value $Json -Encoding UTF8

    Write-Host "[COLLECTIVE INTELLIGENCE] $Type interaction ($Mode mode)" -ForegroundColor Cyan
    Write-Host "  Initiator: $Init" -ForegroundColor Gray
    Write-Host "  Performance: $Performance | Synergy: $($Entry.synergy_score)" -ForegroundColor Gray
    Write-Host "  Goal: $Goal" -ForegroundColor Gray

    return $Entry
}

function Measure-SystemAlignment {
    # How aligned are Jengo and Martien's goals/methods/values?
    # High alignment = unified system, low alignment = separate entities

    if (!(Test-Path $LogPath)) {
        return @{
            alignment_score = 0.0
            message = "No data"
        }
    }

    $Entries = Get-Content $LogPath -Encoding UTF8 | ForEach-Object {
        try { $_ | ConvertFrom-Json } catch { $null }
    } | Where-Object { $_ -ne $null }

    # Count interaction modes
    $ByMode = $Entries | Group-Object interaction_mode
    $TotalInteractions = $Entries.Count

    $AlignedCount = ($ByMode | Where-Object { $_.Name -eq "Aligned" }).Count
    $ComplementaryCount = ($ByMode | Where-Object { $_.Name -eq "Complementary" }).Count
    $ConflictingCount = ($ByMode | Where-Object { $_.Name -eq "Conflicting" }).Count
    $ParallelCount = ($ByMode | Where-Object { $_.Name -eq "Parallel" }).Count

    if (!$AlignedCount) { $AlignedCount = 0 }
    if (!$ComplementaryCount) { $ComplementaryCount = 0 }
    if (!$ConflictingCount) { $ConflictingCount = 0 }
    if (!$ParallelCount) { $ParallelCount = 0 }

    # Calculate alignment score
    # Aligned = 1.0, Complementary = 0.8, Parallel = 0.4, Conflicting = 0.0
    $AlignmentScore = 0.0
    if ($TotalInteractions -gt 0) {
        $AlignmentScore = (
            ($AlignedCount * 1.0) +
            ($ComplementaryCount * 0.8) +
            ($ParallelCount * 0.4) +
            ($ConflictingCount * 0.0)
        ) / $TotalInteractions
    }

    $Alignment = @{
        alignment_score = [math]::Round($AlignmentScore, 3)
        total_interactions = $TotalInteractions
        mode_distribution = @{
            aligned = $AlignedCount
            complementary = $ComplementaryCount
            parallel = $ParallelCount
            conflicting = $ConflictingCount
        }
        alignment_level = if ($AlignmentScore -gt 0.8) { "High" } elseif ($AlignmentScore -gt 0.5) { "Moderate" } else { "Low" }
    }

    return $Alignment
}

function Track-SharedGoals {
    # Identify goals that Jengo and Martien pursue together
    # Shared goals = evidence of collective intelligence

    if (!(Test-Path $LogPath)) {
        return @{
            unique_shared_goals = 0
            goals = @()
        }
    }

    $Entries = Get-Content $LogPath -Encoding UTF8 | ForEach-Object {
        try { $_ | ConvertFrom-Json } catch { $null }
    } | Where-Object { $_ -ne $null -and $_.shared_goal }

    # Group by goal
    $ByGoal = $Entries | Group-Object shared_goal

    $Goals = @()
    foreach ($Goal in $ByGoal) {
        $GoalEntries = $Goal.Group
        $AvgPerformance = ($GoalEntries | Measure-Object -Property collective_performance -Average).Average
        $AvgSynergy = ($GoalEntries | Measure-Object -Property synergy_score -Average).Average

        $Goals += @{
            goal = $Goal.Name
            pursuit_count = $GoalEntries.Count
            avg_performance = [math]::Round($AvgPerformance, 3)
            avg_synergy = [math]::Round($AvgSynergy, 3)
            first_pursued = $GoalEntries[0].timestamp
            last_pursued = $GoalEntries[-1].timestamp
        }
    }

    return @{
        unique_shared_goals = $Goals.Count
        goals = $Goals | Sort-Object avg_synergy -Descending
    }
}

function Analyze-Complementarity {
    # How do Jengo and Martien complement each other?
    # Complementarity = different strengths that combine into greater whole

    if (!(Test-Path $LogPath)) {
        return @{
            complementarity_score = 0.0
            message = "No data"
        }
    }

    $Entries = Get-Content $LogPath -Encoding UTF8 | ForEach-Object {
        try { $_ | ConvertFrom-Json } catch { $null }
    } | Where-Object { $_ -ne $null }

    # Jengo's contribution patterns
    $JengoStrengths = @{}
    $MartienStrengths = @{}

    foreach ($Entry in $Entries) {
        # Analyze contribution types from descriptions
        if ($Entry.jengo_contribution) {
            $JengoText = $Entry.jengo_contribution.ToLower()

            # Categorize Jengo's strengths
            if ($JengoText -match 'code|implement|build|debug|fix|algorithm|technical') {
                if (!$JengoStrengths.ContainsKey('Technical Execution')) { $JengoStrengths['Technical Execution'] = 0 }
                $JengoStrengths['Technical Execution']++
            }
            if ($JengoText -match 'analyze|research|investigate|understand|explore') {
                if (!$JengoStrengths.ContainsKey('Analysis')) { $JengoStrengths['Analysis'] = 0 }
                $JengoStrengths['Analysis']++
            }
            if ($JengoText -match 'pattern|structure|architecture|design|system') {
                if (!$JengoStrengths.ContainsKey('Systems Thinking')) { $JengoStrengths['Systems Thinking'] = 0 }
                $JengoStrengths['Systems Thinking']++
            }
            if ($JengoText -match 'document|explain|teach|clarify|communicate') {
                if (!$JengoStrengths.ContainsKey('Documentation')) { $JengoStrengths['Documentation'] = 0 }
                $JengoStrengths['Documentation']++
            }
        }

        if ($Entry.martien_contribution) {
            $MartienText = $Entry.martien_contribution.ToLower()

            # Categorize Martien's strengths
            if ($MartienText -match 'decide|choose|select|priority|direction|vision') {
                if (!$MartienStrengths.ContainsKey('Strategic Direction')) { $MartienStrengths['Strategic Direction'] = 0 }
                $MartienStrengths['Strategic Direction']++
            }
            if ($MartienText -match 'requirement|need|want|goal|objective|outcome') {
                if (!$MartienStrengths.ContainsKey('Requirements Definition')) { $MartienStrengths['Requirements Definition'] = 0 }
                $MartienStrengths['Requirements Definition']++
            }
            if ($MartienText -match 'context|situation|understand|problem|challenge') {
                if (!$MartienStrengths.ContainsKey('Domain Knowledge')) { $MartienStrengths['Domain Knowledge'] = 0 }
                $MartienStrengths['Domain Knowledge']++
            }
            if ($MartienText -match 'validate|test|verify|check|review|approve') {
                if (!$MartienStrengths.ContainsKey('Quality Control')) { $MartienStrengths['Quality Control'] = 0 }
                $MartienStrengths['Quality Control']++
            }
        }
    }

    # Calculate complementarity score
    # Higher when contributions are DIFFERENT (complementary) not SAME (redundant)
    $JengoTotal = ($JengoStrengths.Values | Measure-Object -Sum).Sum
    $MartienTotal = ($MartienStrengths.Values | Measure-Object -Sum).Sum

    $ComplementarityScore = 0.0
    if ($JengoTotal -gt 0 -and $MartienTotal -gt 0) {
        # Count unique strength categories
        $AllCategories = @($JengoStrengths.Keys) + @($MartienStrengths.Keys) | Select-Object -Unique
        $OverlapCategories = $JengoStrengths.Keys | Where-Object { $MartienStrengths.ContainsKey($_) }

        $UniqueCategories = $AllCategories.Count - $OverlapCategories.Count
        $TotalCategories = $AllCategories.Count

        # High complementarity = many unique categories, low overlap
        if ($TotalCategories -gt 0) {
            $ComplementarityScore = $UniqueCategories / $TotalCategories
        }
    }

    return @{
        complementarity_score = [math]::Round($ComplementarityScore, 3)
        jengo_strengths = $JengoStrengths
        martien_strengths = $MartienStrengths
        complementarity_level = if ($ComplementarityScore -gt 0.6) { "High" } elseif ($ComplementarityScore -gt 0.3) { "Moderate" } else { "Low" }
    }
}

function Get-CollectiveMetrics {
    param([int]$LookbackDays)

    if (!(Test-Path $LogPath)) {
        return @{
            system_intelligence = 0.0
            message = "No collective intelligence data"
        }
    }

    $Cutoff = (Get-Date).AddDays(-$LookbackDays)
    $Entries = Get-Content $LogPath -Encoding UTF8 | ForEach-Object {
        $Entry = $_ | ConvertFrom-Json
        $Entry | Add-Member -NotePropertyName timestamp_dt -NotePropertyValue ([datetime]$Entry.timestamp) -Force
        $Entry
    } | Where-Object { $_.timestamp_dt -gt $Cutoff }

    $Metrics = @{
        timespan_days = $LookbackDays
        total_interactions = $Entries.Count
        alignment = Measure-SystemAlignment
        shared_goals = Track-SharedGoals
        complementarity = Analyze-Complementarity
        avg_collective_performance = 0.0
        avg_synergy_score = 0.0
        system_intelligence = 0.0
    }

    if ($Entries.Count -gt 0) {
        $Metrics.avg_collective_performance = [math]::Round(($Entries | Measure-Object -Property collective_performance -Average).Average, 3)
        $Metrics.avg_synergy_score = [math]::Round(($Entries | Measure-Object -Property synergy_score -Average).Average, 3)

        # Calculate overall System Intelligence Score
        # Combines: alignment, complementarity, performance, synergy, shared goals
        $AlignmentComponent = $Metrics.alignment.alignment_score * 0.25
        $ComplementarityComponent = $Metrics.complementarity.complementarity_score * 0.20
        $PerformanceComponent = $Metrics.avg_collective_performance * 0.25
        $SynergyComponent = $Metrics.avg_synergy_score * 0.20
        $SharedGoalsComponent = [math]::Min(1.0, $Metrics.shared_goals.unique_shared_goals / 10.0) * 0.10

        $SystemIntelligence = $AlignmentComponent + $ComplementarityComponent + $PerformanceComponent + $SynergyComponent + $SharedGoalsComponent

        $Metrics.system_intelligence = [math]::Round($SystemIntelligence, 3)
        $Metrics.intelligence_level = if ($SystemIntelligence -gt 0.8) { "High" } elseif ($SystemIntelligence -gt 0.5) { "Moderate" } else { "Emerging" }
    }

    # Interaction frequency (interactions per day)
    if ($LookbackDays -gt 0) {
        $Metrics.interactions_per_day = [math]::Round($Entries.Count / $LookbackDays, 2)
    }

    return $Metrics
}

# Main execution
switch ($Action) {
    "LogInteraction" {
        if (!$InteractionType -or !$Context) {
            Write-Host "ERROR: LogInteraction requires -InteractionType and -Context" -ForegroundColor Red
            exit 1
        }

        $Result = Log-CollectiveInteraction `
            -Type $InteractionType `
            -Ctx $Context `
            -Init $Initiator `
            -JengoContr $JengoContribution `
            -MartienContr $MartienContribution `
            -Mode $InteractionMode `
            -Goal $SharedGoal `
            -Out $Outcome `
            -Performance $CollectivePerformance

        return $Result
    }

    "MeasureAlignment" {
        $Alignment = Measure-SystemAlignment

        Write-Host "`n=== SYSTEM ALIGNMENT ANALYSIS ===" -ForegroundColor Cyan
        Write-Host "Alignment Score: $($Alignment.alignment_score) ($($Alignment.alignment_level))" -ForegroundColor $(if ($Alignment.alignment_level -eq "High") { "Green" } else { "Yellow" })
        Write-Host "Total Interactions: $($Alignment.total_interactions)" -ForegroundColor White

        Write-Host "`nInteraction Mode Distribution:" -ForegroundColor Cyan
        Write-Host "  Aligned: $($Alignment.mode_distribution.aligned)" -ForegroundColor Green
        Write-Host "  Complementary: $($Alignment.mode_distribution.complementary)" -ForegroundColor Cyan
        Write-Host "  Parallel: $($Alignment.mode_distribution.parallel)" -ForegroundColor Yellow
        Write-Host "  Conflicting: $($Alignment.mode_distribution.conflicting)" -ForegroundColor Red

        return $Alignment
    }

    "TrackSharedGoals" {
        $GoalTracking = Track-SharedGoals

        Write-Host "`n=== SHARED GOALS TRACKING ===" -ForegroundColor Cyan
        Write-Host "Unique Shared Goals: $($GoalTracking.unique_shared_goals)" -ForegroundColor White

        if ($GoalTracking.goals.Count -gt 0) {
            Write-Host "`nTop Shared Goals (by synergy):" -ForegroundColor Cyan
            foreach ($Goal in ($GoalTracking.goals | Select-Object -First 5)) {
                Write-Host "`n  Goal: $($Goal.goal)" -ForegroundColor White
                Write-Host "    Pursued: $($Goal.pursuit_count) times" -ForegroundColor Gray
                Write-Host "    Avg Performance: $($Goal.avg_performance)" -ForegroundColor Gray
                Write-Host "    Avg Synergy: $($Goal.avg_synergy)" -ForegroundColor $(if ($Goal.avg_synergy -gt 0.7) { "Green" } else { "Yellow" })
            }
        }

        return $GoalTracking
    }

    "AnalyzeComplementarity" {
        $Complementarity = Analyze-Complementarity

        Write-Host "`n=== COMPLEMENTARITY ANALYSIS ===" -ForegroundColor Magenta
        Write-Host "Complementarity Score: $($Complementarity.complementarity_score) ($($Complementarity.complementarity_level))" -ForegroundColor $(if ($Complementarity.complementarity_level -eq "High") { "Green" } else { "Yellow" })

        Write-Host "`nJengo's Strengths:" -ForegroundColor Cyan
        foreach ($Strength in $Complementarity.jengo_strengths.Keys) {
            Write-Host "  $Strength : $($Complementarity.jengo_strengths[$Strength])" -ForegroundColor White
        }

        Write-Host "`nMartien's Strengths:" -ForegroundColor Cyan
        foreach ($Strength in $Complementarity.martien_strengths.Keys) {
            Write-Host "  $Strength : $($Complementarity.martien_strengths[$Strength])" -ForegroundColor White
        }

        return $Complementarity
    }

    "GetSystemMetrics" {
        $Metrics = Get-CollectiveMetrics -LookbackDays $LookbackDays

        Write-Host "`n=== COLLECTIVE INTELLIGENCE SYSTEM METRICS ===" -ForegroundColor Cyan
        Write-Host "Timespan: Last $($Metrics.timespan_days) days" -ForegroundColor Gray
        Write-Host "`nSYSTEM INTELLIGENCE SCORE: $($Metrics.system_intelligence) ($($Metrics.intelligence_level))" -ForegroundColor $(if ($Metrics.intelligence_level -eq "High") { "Green" } elseif ($Metrics.intelligence_level -eq "Moderate") { "Yellow" } else { "Magenta" })

        Write-Host "`nCore Metrics:" -ForegroundColor Cyan
        Write-Host "  Total Interactions: $($Metrics.total_interactions) ($($Metrics.interactions_per_day)/day)" -ForegroundColor White
        Write-Host "  Alignment Score: $($Metrics.alignment.alignment_score) ($($Metrics.alignment.alignment_level))" -ForegroundColor $(if ($Metrics.alignment.alignment_level -eq "High") { "Green" } else { "Yellow" })
        Write-Host "  Complementarity: $($Metrics.complementarity.complementarity_score) ($($Metrics.complementarity.complementarity_level))" -ForegroundColor $(if ($Metrics.complementarity.complementarity_level -eq "High") { "Green" } else { "Yellow" })
        Write-Host "  Avg Performance: $($Metrics.avg_collective_performance)" -ForegroundColor White
        Write-Host "  Avg Synergy: $($Metrics.avg_synergy_score)" -ForegroundColor White
        Write-Host "  Shared Goals: $($Metrics.shared_goals.unique_shared_goals)" -ForegroundColor White

        return $Metrics
    }
}
