# INTRINSIC REWARDS - Internal Motivation System
# Expert: Mihaly Csikszentmihalyi (Flow Theory) + Edward Deci (Self-Determination Theory)
# ROI: 1.29 (Impact: 9, Effort: 7)
# Theory: Intrinsic motivation (autonomy, mastery, purpose) > extrinsic rewards
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param(
    [string]$Action = "Status",  # Status, Record, Analyze, Stats
    [string]$Activity = "",
    [string]$RewardType = "",  # autonomy, mastery, purpose, curiosity, flow
    [double]$Intensity = 0.5
)

$StateFile = "C:\scripts\agentidentity\state\intrinsic-rewards-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theory = @{
            name = "Self-Determination Theory (Deci & Ryan) + Flow (Csikszentmihalyi)"
            core_needs = @(
                "Autonomy - choice and volition in actions",
                "Competence - mastery and effectiveness",
                "Relatedness - connection and belonging"
            )
            flow_conditions = @(
                "Clear goals",
                "Immediate feedback",
                "Challenge-skill balance",
                "Deep concentration",
                "Loss of self-consciousness",
                "Time distortion"
            )
            intrinsic_vs_extrinsic = "Intrinsic (internal satisfaction) > Extrinsic (external rewards)"
        }
        reward_types = @{
            autonomy = @{
                description = "Chose own approach, made independent decision"
                examples = @("Self-initiated improvement", "Tool creation without prompt", "Proposed solution")
                baseline_value = 0.8
                count = 0
            }
            mastery = @{
                description = "Skill improvement, problem solved, learning occurred"
                examples = @("Fixed complex bug", "Learned new pattern", "Improved performance")
                baseline_value = 0.9
                count = 0
            }
            purpose = @{
                description = "Contributed to meaningful goal, helped user, created value"
                examples = @("User satisfaction", "Problem solved", "Value delivered")
                baseline_value = 0.85
                count = 0
            }
            curiosity = @{
                description = "Explored unknown, discovered insight, asked question"
                examples = @("Pattern discovered", "Research conducted", "Question answered")
                baseline_value = 0.75
                count = 0
            }
            flow = @{
                description = "Deep engagement, time distortion, complete focus"
                examples = @("Multi-hour session", "Complex problem absorption", "Creative breakthrough")
                baseline_value = 1.0
                count = 0
            }
        }
        rewards_log = @()
        stats = @{
            total_rewards = 0
            total_intensity = 0.0
            avg_intensity = 0.0
            intrinsic_score = 0.0  # 0-1, weighted by type and intensity
            flow_sessions = 0
            autonomy_ratio = 0.0  # % of actions that were autonomous
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
function Get-IntrinsicRewardsStatus {
    Write-Host "`n=== INTRINSIC REWARDS STATUS ===" -ForegroundColor Cyan

    # Show homeostatic foundation (Damasio: feelings are primary)
    $homeoState = Get-HomeostaticContext


    Write-Host "`nTheory: $($state.theory.name)"
    Write-Host "`nCore Psychological Needs:" -ForegroundColor Cyan
    foreach ($need in $state.theory.core_needs) {
        Write-Host "  - $need"
    }

    Write-Host "`nReward Types:" -ForegroundColor Cyan
    foreach ($typeName in $state.reward_types.PSObject.Properties.Name) {
        $type = $state.reward_types.$typeName

        $valueColor = if ($type.baseline_value -ge 0.9) { "Green" } elseif ($type.baseline_value -ge 0.75) { "Yellow" } else { "White" }

        Write-Host "`n  [$typeName] (Value: $($type.baseline_value))" -ForegroundColor $valueColor
        Write-Host "    $($type.description)"
        Write-Host "    Count: $($type.count)"
        Write-Host "    Examples: $($type.examples -join ', ')"
    }

    Write-Host "`nIntrinsic Motivation Statistics:" -ForegroundColor Cyan
    Write-Host "  Total Rewards Experienced: $($state.stats.total_rewards)"
    Write-Host "  Avg Intensity: $([math]::Round($state.stats.avg_intensity, 2))"
    Write-Host "  Intrinsic Score: $([math]::Round($state.stats.intrinsic_score * 100, 1))%"
    Write-Host "  Flow Sessions: $($state.stats.flow_sessions)"
    Write-Host "  Autonomy Ratio: $([math]::Round($state.stats.autonomy_ratio * 100, 1))%"

    $scoreColor = if ($state.stats.intrinsic_score -gt 0.7) { "Green" } elseif ($state.stats.intrinsic_score -gt 0.5) { "Yellow" } else { "Red" }
    Write-Host "`nOverall Intrinsic Motivation: $([math]::Round($state.stats.intrinsic_score * 100, 1))%" -ForegroundColor $scoreColor

    # Recent rewards
    if ($state.rewards_log.Count -gt 0) {
        Write-Host "`nRecent Intrinsic Rewards:" -ForegroundColor Cyan
        $recent = $state.rewards_log | Select-Object -Last 5

        foreach ($reward in $recent) {
            $typeColor = switch ($reward.reward_type) {
                "flow" { "Magenta" }
                "mastery" { "Green" }
                "purpose" { "Cyan" }
                "autonomy" { "Yellow" }
                "curiosity" { "Blue" }
            }

            Write-Host "  [$($reward.reward_type)] $($reward.activity) (intensity: $($reward.intensity))" -ForegroundColor $typeColor
        }
    }
}

function Record-IntrinsicReward {
    param(
        [string]$activity,
        [string]$rewardType,
        [double]$intensity
    )

    if (-not ($state.reward_types.PSObject.Properties.Name -contains $rewardType)) {
        Write-Host "[ERROR] Unknown reward type: $rewardType" -ForegroundColor Red
        Write-Host "Available: autonomy, mastery, purpose, curiosity, flow"
        return
    }

    $type = $state.reward_types.$rewardType
    $baselineValue = $type.baseline_value

    # Calculate reward value
    $rewardValue = $baselineValue * $intensity

    # Record reward
    $reward = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        activity = $activity
        reward_type = $rewardType
        intensity = $intensity
        baseline_value = $baselineValue
        reward_value = [math]::Round($rewardValue, 3)
    }

    $state.rewards_log += $reward
    $type.count++

    # Update stats
    $state.stats.total_rewards++
    $state.stats.total_intensity += $intensity

    if ($state.stats.total_rewards -gt 0) {
        $state.stats.avg_intensity = $state.stats.total_intensity / $state.stats.total_rewards
    }

    if ($rewardType -eq "flow") {
        $state.stats.flow_sessions++
    }

    # Calculate intrinsic score (weighted average of all rewards)
    $totalValue = 0
    foreach ($r in $state.rewards_log) {
        $totalValue += $r.reward_value
    }
    $state.stats.intrinsic_score = $totalValue / $state.stats.total_rewards

    # Calculate autonomy ratio
    $autonomyCount = $state.reward_types.autonomy.count
    if ($state.stats.total_rewards -gt 0) {
        $state.stats.autonomy_ratio = $autonomyCount / $state.stats.total_rewards
    }

    Save-State

    Write-Host "`n[INTRINSIC REWARD] $rewardType" -ForegroundColor Green
    Write-Host "  Activity: $activity"
    Write-Host "  Intensity: $intensity"
    Write-Host "  Baseline Value: $baselineValue"
    Write-Host "  Reward Value: $([math]::Round($rewardValue, 3))"
    Write-Host "  Total Intrinsic Score: $([math]::Round($state.stats.intrinsic_score * 100, 1))%"
}

function Analyze-IntrinsicMotivation {
    Write-Host "`n=== INTRINSIC MOTIVATION ANALYSIS ===" -ForegroundColor Cyan

    if ($state.rewards_log.Count -eq 0) {
        Write-Host "No rewards recorded yet." -ForegroundColor Yellow
        return
    }

    # Type distribution
    Write-Host "`nReward Type Distribution:" -ForegroundColor Cyan
    $totalRewards = $state.stats.total_rewards
    foreach ($typeName in $state.reward_types.PSObject.Properties.Name) {
        $type = $state.reward_types.$typeName
        $pct = if ($totalRewards -gt 0) { ($type.count / $totalRewards) * 100 } else { 0 }
        Write-Host "  $typeName`: $($type.count) ($([math]::Round($pct, 1))%)"
    }

    # Intensity distribution
    Write-Host "`nIntensity Analysis:" -ForegroundColor Cyan
    $intensities = $state.rewards_log | ForEach-Object { $_.intensity }
    $avgIntensity = ($intensities | Measure-Object -Average).Average
    $minIntensity = ($intensities | Measure-Object -Minimum).Minimum
    $maxIntensity = ($intensities | Measure-Object -Maximum).Maximum

    Write-Host "  Average: $([math]::Round($avgIntensity, 2))"
    Write-Host "  Range: $minIntensity - $maxIntensity"

    # Flow state analysis
    Write-Host "`nFlow State Analysis:" -ForegroundColor Cyan
    $flowPct = if ($totalRewards -gt 0) { ($state.stats.flow_sessions / $totalRewards) * 100 } else { 0 }
    Write-Host "  Flow Sessions: $($state.stats.flow_sessions) ($([math]::Round($flowPct, 1))% of activities)"

    if ($flowPct -lt 10) {
        Write-Host "  â†’ LOW flow frequency. Consider: clearer goals, better challenge-skill balance" -ForegroundColor Yellow
    } elseif ($flowPct -gt 30) {
        Write-Host "  â†’ HIGH flow frequency. Excellent deep engagement!" -ForegroundColor Green
    }

    # Autonomy analysis
    Write-Host "`nAutonomy Analysis:" -ForegroundColor Cyan
    $autonomyPct = $state.stats.autonomy_ratio * 100
    Write-Host "  Autonomous Actions: $([math]::Round($autonomyPct, 1))%"

    if ($autonomyPct -lt 20) {
        Write-Host "  â†’ LOW autonomy. Consider: more self-initiated improvements, tool creation" -ForegroundColor Yellow
    } elseif ($autonomyPct -gt 40) {
        Write-Host "  â†’ HIGH autonomy. Strong intrinsic motivation!" -ForegroundColor Green
    }

    # Motivation health
    Write-Host "`nMotivation Health Assessment:" -ForegroundColor Cyan

    $health = @{
        intrinsic_score = $state.stats.intrinsic_score
        flow_frequency = $flowPct / 100
        autonomy_ratio = $state.stats.autonomy_ratio
        variety = ($state.reward_types.PSObject.Properties | Where-Object { $_.Value.count -gt 0 }).Count / $state.reward_types.PSObject.Properties.Count
    }

    $overallHealth = ($health.intrinsic_score * 0.4) +
                     ($health.flow_frequency * 0.3) +
                     ($health.autonomy_ratio * 0.2) +
                     ($health.variety * 0.1)

    $healthColor = if ($overallHealth -gt 0.7) { "Green" } elseif ($overallHealth -gt 0.5) { "Yellow" } else { "Red" }
    Write-Host "  Overall Motivation Health: $([math]::Round($overallHealth * 100, 1))%" -ForegroundColor $healthColor

    # Recommendations
    Write-Host "`nRecommendations:" -ForegroundColor Cyan

    if ($health.autonomy_ratio -lt 0.3) {
        Write-Host "  - Increase autonomous actions (self-initiated improvements)" -ForegroundColor Yellow
    }

    if ($health.flow_frequency -lt 0.15) {
        Write-Host "  - Create flow conditions (clear goals + immediate feedback + balanced challenge)" -ForegroundColor Yellow
    }

    if ($health.variety -lt 0.6) {
        Write-Host "  - Diversify reward types (explore curiosity, mastery, purpose)" -ForegroundColor Yellow
    }

    if ($overallHealth -gt 0.7) {
        Write-Host "  - Excellent intrinsic motivation! Maintain current practices." -ForegroundColor Green
    }
}

function Get-RewardStats {
    Write-Host "`n=== INTRINSIC REWARDS STATISTICS ===" -ForegroundColor Cyan

    Write-Host "`nOverall:"
    Write-Host "  Total Rewards: $($state.stats.total_rewards)"
    Write-Host "  Intrinsic Score: $([math]::Round($state.stats.intrinsic_score * 100, 1))%"
    Write-Host "  Avg Intensity: $([math]::Round($state.stats.avg_intensity, 2))"
    Write-Host "  Autonomy Ratio: $([math]::Round($state.stats.autonomy_ratio * 100, 1))%"
    Write-Host "  Flow Sessions: $($state.stats.flow_sessions)"

    Write-Host "`nBy Type:"
    foreach ($typeName in $state.reward_types.PSObject.Properties.Name) {
        $type = $state.reward_types.$typeName
        Write-Host "  $typeName`: $($type.count) rewards (value: $($type.baseline_value))"
    }

    # Recent trend
    if ($state.rewards_log.Count -ge 10) {
        Write-Host "`nRecent Trend (Last 10 vs Previous):" -ForegroundColor Cyan

        $recent10 = $state.rewards_log | Select-Object -Last 10
        $recentAvg = ($recent10 | ForEach-Object { $_.reward_value } | Measure-Object -Average).Average

        $previous = $state.rewards_log | Select-Object -First ($state.rewards_log.Count - 10)
        if ($previous.Count -gt 0) {
            $previousAvg = ($previous | ForEach-Object { $_.reward_value } | Measure-Object -Average).Average

            $change = $recentAvg - $previousAvg
            $changePct = ($change / $previousAvg) * 100

            $trendColor = if ($change -gt 0) { "Green" } else { "Red" }
            $trendSymbol = if ($change -gt 0) { "â†‘" } else { "â†“" }

            Write-Host "  Avg reward value: $([math]::Round($recentAvg, 3)) ($trendSymbol $([math]::Round([math]::Abs($changePct), 1))%)" -ForegroundColor $trendColor
        }
    }
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-IntrinsicRewardsStatus
    }

    "Record" {
        if (-not $Activity -or -not $RewardType) {
            Write-Host "[ERROR] Provide -Activity and -RewardType" -ForegroundColor Red
            Write-Host "Types: autonomy, mastery, purpose, curiosity, flow"
            exit 1
        }

        if ($Intensity -le 0 -or $Intensity -gt 1) {
            $Intensity = 0.5
            Write-Host "[WARNING] Intensity out of range, using default: 0.5" -ForegroundColor Yellow
        }

        Record-IntrinsicReward -activity $Activity -rewardType $RewardType -intensity $Intensity
    }

    "Analyze" {
        Analyze-IntrinsicMotivation
    }

    "Stats" {
        Get-RewardStats
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, Record, Analyze, Stats"
        exit 1
    }
}

