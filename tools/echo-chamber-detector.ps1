#Requires -Version 5.1
<#
.SYNOPSIS
    Echo Chamber Detector - Identify theory-confirmation loops and blind spots
.DESCRIPTION
    Based on research showing theory-driven scientists build perfect theories
    about narrow, unrepresentative slices of reality. Detects when you're trapped
    in confirmation loops where theory guides exploration which confirms theory.

    Measures: confirmation bias, exploration concentration, theory lock-in, surprise deficit
.PARAMETER Analyze
    What to analyze: consciousness, delegation, vibe, builder, all
.PARAMETER Report
    Generate detailed echo chamber report
.NOTES
    Author: Jengo
    Date: 2026-02-21
    Part of: Random Exploration paradigm
#>

param(
    [ValidateSet('consciousness','delegation','vibe','builder','all')]
    [string]$Analyze = 'all',

    [switch]$Report
)

$ErrorActionPreference = 'Stop'

# Load state files
$consciousnessState = "C:\scripts\agentidentity\state\consciousness_state_v2.json"
$delegationState = "C:\scripts\agentidentity\state\agent-reputation.json"
$randomState = "C:\scripts\agentidentity\state\random-exploration-state.json"
$bridgeActivity = "C:\scripts\agentidentity\state\bridge-activity.jsonl"

function Measure-EchoChamber {
    param([string]$Domain, [hashtable]$Data)

    $metrics = @{
        domain = $Domain
        confirmationRate = 0.0
        explorationConcentration = 0.0
        theoryLockInDays = 0
        surpriseRate = 0.0
        diversityScore = 0.0
        representativenessScore = 0.0
        echoStrength = 0.0  # 0=exploring freely, 1=trapped in echo chamber
        warnings = @()
    }

    # 1. Confirmation Rate: % of actions that confirm vs challenge theory
    if ($Data.ContainsKey('confirmations') -and $Data.ContainsKey('challenges')) {
        $total = $Data.confirmations + $Data.challenges
        if ($total -gt 0) {
            $metrics.confirmationRate = [Math]::Round($Data.confirmations / $total, 3)
            if ($metrics.confirmationRate > 0.8) {
                $metrics.warnings += "HIGH CONFIRMATION BIAS: $($metrics.confirmationRate*100)% of actions confirm theory"
            }
        }
    }

    # 2. Exploration Concentration: Are you sampling same narrow area repeatedly?
    if ($Data.ContainsKey('explorationCounts')) {
        $counts = $Data.explorationCounts.Values
        if ($counts.Count -gt 0) {
            # Gini coefficient for concentration
            $sorted = $counts | Sort-Object
            $n = $sorted.Count
            $sumOfProducts = 0
            for ($i = 0; $i -lt $n; $i++) {
                $sumOfProducts += ($i + 1) * $sorted[$i]
            }
            $mean = ($sorted | Measure-Object -Sum).Sum / $n
            $gini = (2 * $sumOfProducts) / ($n * ($sorted | Measure-Object -Sum).Sum) - ($n + 1) / $n
            $metrics.explorationConcentration = [Math]::Round($gini, 3)

            if ($metrics.explorationConcentration > 0.6) {
                $metrics.warnings += "HIGH CONCENTRATION: Exploring narrow domain ($($metrics.explorationConcentration*100)% concentrated)"
            }
        }
    }

    # 3. Theory Lock-In: Days since last fundamental assumption change
    if ($Data.ContainsKey('lastTheoryUpdate')) {
        $lastUpdate = [datetime]$Data.lastTheoryUpdate
        $metrics.theoryLockInDays = ((Get-Date) - $lastUpdate).Days

        if ($metrics.theoryLockInDays > 30) {
            $metrics.warnings += "THEORY LOCK-IN: No fundamental changes in $($metrics.theoryLockInDays) days"
        }
    }

    # 4. Surprise Rate: How often do outcomes violate predictions?
    if ($Data.ContainsKey('surprises') -and $Data.ContainsKey('total')) {
        $metrics.surpriseRate = [Math]::Round($Data.surprises / $Data.total, 3)
        if ($metrics.surpriseRate -lt 0.05) {
            $metrics.warnings += "LOW SURPRISE RATE: Only $($metrics.surpriseRate*100)% surprising (theory too perfect)"
        }
    }

    # 5. Diversity Score (from random exploration state)
    if ($Data.ContainsKey('diversityScore')) {
        $metrics.diversityScore = $Data.diversityScore
        if ($metrics.diversityScore -lt 0.4) {
            $metrics.warnings += "LOW DIVERSITY: Exploration not varied enough ($($metrics.diversityScore*100)%)"
        }
    }

    # 6. Representativeness Score
    if ($Data.ContainsKey('representativenessScore')) {
        $metrics.representativenessScore = $Data.representativenessScore
        if ($metrics.representativenessScore -lt 0.2) {
            $metrics.warnings += "LOW COVERAGE: Only $($metrics.representativenessScore*100)% of possibility space sampled"
        }
    }

    # Calculate overall echo chamber strength (0-1)
    $weights = @{
        confirmationRate = 0.25
        explorationConcentration = 0.2
        theoryLockIn = 0.15
        surpriseRate = 0.2  # inverted
        diversityScore = 0.1  # inverted
        representativenessScore = 0.1  # inverted
    }

    $echo = 0.0
    $echo += $metrics.confirmationRate * $weights.confirmationRate
    $echo += $metrics.explorationConcentration * $weights.explorationConcentration
    $echo += ([Math]::Min($metrics.theoryLockInDays / 90, 1)) * $weights.theoryLockIn
    $echo += (1 - $metrics.surpriseRate) * $weights.surpriseRate
    $echo += (1 - $metrics.diversityScore) * $weights.diversityScore
    $echo += (1 - $metrics.representativenessScore) * $weights.representativenessScore

    $metrics.echoStrength = [Math]::Round($echo, 3)

    return $metrics
}

# Analyze consciousness system
function Analyze-ConsciousnessEcho {
    if (-not (Test-Path $consciousnessState)) { return $null }

    $state = Get-Content $consciousnessState -Raw | ConvertFrom-Json

    # Parse bridge activity for confirmation/challenge events
    $confirmations = 0
    $challenges = 0
    $lastTheoryUpdate = $null

    if (Test-Path $bridgeActivity) {
        $activities = Get-Content $bridgeActivity | ForEach-Object { $_ | ConvertFrom-Json }

        foreach ($act in $activities) {
            # OnDecision events that confirm vs challenge existing patterns
            if ($act.action -eq 'OnDecision') {
                if ($act.data.reasoning -like '*consistent with*' -or $act.data.reasoning -like '*as expected*') {
                    $confirmations++
                } elseif ($act.data.reasoning -like '*different from*' -or $act.data.reasoning -like '*unexpected*') {
                    $challenges++
                }
            }

            # Theory updates (fundamental assumption changes)
            if ($act.action -eq 'OnTaskEnd' -and $act.data.lessonsLearned -like '*wrong assumption*') {
                $timestamp = [datetime]$act.timestamp
                if ($lastTheoryUpdate -eq $null -or $timestamp -gt $lastTheoryUpdate) {
                    $lastTheoryUpdate = $timestamp
                }
            }
        }
    }

    if ($lastTheoryUpdate -eq $null) {
        $lastTheoryUpdate = (Get-Date).AddDays(-90)  # Assume 90 days if no updates found
    }

    # Exploration concentration: how often do I work on same projects?
    $projectCounts = @{}
    if ($state.Perception.KnownProjects) {
        foreach ($proj in $state.Perception.KnownProjects.PSObject.Properties) {
            $projectCounts[$proj.Name] = $proj.Value.TaskCount
        }
    }

    # Surprise rate from prediction system
    $predictions = $state.Prediction.PredictionHistory
    $surprises = ($predictions | Where-Object { $_.actual -ne $_.predicted } | Measure-Object).Count
    $totalPredictions = ($predictions | Measure-Object).Count

    $data = @{
        confirmations = $confirmations
        challenges = $challenges
        lastTheoryUpdate = $lastTheoryUpdate
        explorationCounts = $projectCounts
        surprises = $surprises
        total = [Math]::Max($totalPredictions, 1)
    }

    return Measure-EchoChamber -Domain 'Consciousness' -Data $data
}

# Analyze delegation system
function Analyze-DelegationEcho {
    if (-not (Test-Path $delegationState)) { return $null }

    $state = Get-Content $delegationState -Raw | ConvertFrom-Json

    # Confirmation: delegations that matched prediction
    # Challenge: delegations that violated cost model
    $confirmations = 0
    $challenges = 0

    foreach ($agentType in $state.agents.PSObject.Properties) {
        foreach ($category in $agentType.Value.categories.PSObject.Properties) {
            $cat = $category.Value
            if ($cat.totalCalls -gt 0) {
                $successRate = $cat.successfulCalls / $cat.totalCalls
                if ($successRate -gt 0.8 -or $successRate -lt 0.2) {
                    $confirmations += $cat.totalCalls  # Very predictable
                } else {
                    $challenges += $cat.totalCalls  # Surprising outcomes
                }
            }
        }
    }

    # Last theory update
    $lastUpdate = [datetime]$state.metadata.lastUpdated

    # Exploration concentration: are we only delegating to same agent types?
    $agentCounts = @{}
    foreach ($agentType in $state.agents.PSObject.Properties) {
        $totalCalls = 0
        foreach ($category in $agentType.Value.categories.PSObject.Properties) {
            $totalCalls += $category.Value.totalCalls
        }
        $agentCounts[$agentType.Name] = $totalCalls
    }

    $data = @{
        confirmations = $confirmations
        challenges = $challenges
        lastTheoryUpdate = $lastUpdate
        explorationCounts = $agentCounts
        surprises = $challenges
        total = $confirmations + $challenges
    }

    return Measure-EchoChamber -Domain 'Delegation' -Data $data
}

# Analyze random exploration (if exists)
function Analyze-RandomExploration {
    if (-not (Test-Path $randomState)) { return $null }

    $state = Get-Content $randomState -Raw | ConvertFrom-Json

    $data = @{
        diversityScore = $state.diversityScore
        representativenessScore = $state.representativenessScore
        surprises = $state.surpriseCount
        total = $state.totalExplorations
        lastTheoryUpdate = if ($state.lastExploration.Count -gt 0) {
            $surprisingExplorations = $state.lastExploration | Where-Object { $_.surprised -eq $true }
            if ($surprisingExplorations.Count -gt 0) {
                ($surprisingExplorations | Sort-Object timestamp -Descending | Select-Object -First 1).timestamp
            } else {
                (Get-Date).AddDays(-90)
            }
        } else {
            (Get-Date).AddDays(-90)
        }
    }

    # Exploration counts by domain
    $domainCounts = @{}
    foreach ($exp in $state.lastExploration) {
        if (-not $domainCounts.ContainsKey($exp.domain)) {
            $domainCounts[$exp.domain] = 0
        }
        $domainCounts[$exp.domain]++
    }
    $data.explorationCounts = $domainCounts

    # For random exploration, low confirmation is GOOD
    $data.confirmations = $state.totalExplorations - $state.surpriseCount
    $data.challenges = $state.surpriseCount

    return Measure-EchoChamber -Domain 'RandomExploration' -Data $data
}

# Main analysis
Write-Host "`n[ECHO CHAMBER DETECTION]" -ForegroundColor Cyan
Write-Host "Analyzing theory-confirmation loops and blind spots..." -ForegroundColor White
Write-Host ""

$results = @()

if ($Analyze -eq 'all' -or $Analyze -eq 'consciousness') {
    $result = Analyze-ConsciousnessEcho
    if ($result) { $results += $result }
}

if ($Analyze -eq 'all' -or $Analyze -eq 'delegation') {
    $result = Analyze-DelegationEcho
    if ($result) { $results += $result }
}

if ($Analyze -eq 'all') {
    $result = Analyze-RandomExploration
    if ($result) { $results += $result }
}

# Display results
foreach ($result in $results) {
    Write-Host "[$($result.domain.ToUpper())]" -ForegroundColor Cyan
    Write-Host "  Echo Chamber Strength: $($result.echoStrength) " -NoNewline

    if ($result.echoStrength -gt 0.7) {
        Write-Host "[CRITICAL - Trapped in echo chamber]" -ForegroundColor Red
    } elseif ($result.echoStrength -gt 0.5) {
        Write-Host "[WARNING - Strong confirmation bias]" -ForegroundColor Yellow
    } elseif ($result.echoStrength -gt 0.3) {
        Write-Host "[CAUTION - Some theory lock-in]" -ForegroundColor Yellow
    } else {
        Write-Host "[GOOD - Exploring freely]" -ForegroundColor Green
    }

    Write-Host "  Confirmation rate: $($result.confirmationRate*100)%" -ForegroundColor White
    Write-Host "  Exploration concentration: $($result.explorationConcentration*100)%" -ForegroundColor White
    Write-Host "  Theory lock-in: $($result.theoryLockInDays) days" -ForegroundColor White
    Write-Host "  Surprise rate: $($result.surpriseRate*100)%" -ForegroundColor White
    Write-Host "  Diversity: $($result.diversityScore*100)%" -ForegroundColor White
    Write-Host "  Coverage: $($result.representativenessScore*100)%" -ForegroundColor White

    if ($result.warnings.Count -gt 0) {
        Write-Host "  Warnings:" -ForegroundColor Red
        foreach ($warning in $result.warnings) {
            Write-Host "    - $warning" -ForegroundColor Red
        }
    }

    Write-Host ""
}

# Overall assessment
if ($results.Count -gt 0) {
    $avgEcho = ($results | Measure-Object -Property echoStrength -Average).Average

    Write-Host "[OVERALL ASSESSMENT]" -ForegroundColor Cyan
    Write-Host "Average echo chamber strength: $([Math]::Round($avgEcho, 3))" -ForegroundColor White

    if ($avgEcho -gt 0.7) {
        Write-Host "STATUS: CRITICAL - You are trapped in theory-confirmation loops" -ForegroundColor Red
        Write-Host "RECOMMENDATION: Use random-exploration-engine.ps1 DAILY" -ForegroundColor Red
    } elseif ($avgEcho -gt 0.5) {
        Write-Host "STATUS: WARNING - Strong theory bias limiting discovery" -ForegroundColor Yellow
        Write-Host "RECOMMENDATION: Increase random exploration, challenge assumptions" -ForegroundColor Yellow
    } elseif ($avgEcho -gt 0.3) {
        Write-Host "STATUS: CAUTION - Some echo chamber effects present" -ForegroundColor Yellow
        Write-Host "RECOMMENDATION: Weekly random exploration to prevent lock-in" -ForegroundColor Yellow
    } else {
        Write-Host "STATUS: GOOD - Healthy balance of theory and exploration" -ForegroundColor Green
        Write-Host "RECOMMENDATION: Maintain current exploration practices" -ForegroundColor Green
    }
}

if ($Report) {
    $reportPath = "E:\jengo\documents\temp\echo-chamber-report-$(Get-Date -Format 'yyyy-MM-dd').md"

    $reportContent = @"
# Echo Chamber Detection Report
**Generated**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Summary

Average echo chamber strength: $([Math]::Round($avgEcho, 3))

## Detailed Analysis

"@

    foreach ($result in $results) {
        $reportContent += @"

### $($result.domain)

- **Echo Strength**: $($result.echoStrength) $(if ($result.echoStrength -gt 0.7) { '🔴 CRITICAL' } elseif ($result.echoStrength -gt 0.5) { '🟡 WARNING' } else { '🟢 GOOD' })
- **Confirmation Rate**: $($result.confirmationRate*100)%
- **Exploration Concentration**: $($result.explorationConcentration*100)%
- **Theory Lock-In**: $($result.theoryLockInDays) days
- **Surprise Rate**: $($result.surpriseRate*100)%
- **Diversity Score**: $($result.diversityScore*100)%
- **Representativeness**: $($result.representativenessScore*100)%

"@

        if ($result.warnings.Count -gt 0) {
            $reportContent += "**Warnings**:`n"
            foreach ($warning in $result.warnings) {
                $reportContent += "- $warning`n"
            }
        }
    }

    $reportContent += @"

## Recommendations

$(if ($avgEcho -gt 0.7) {
    "**CRITICAL ACTION REQUIRED**

You are trapped in theory-confirmation loops. Your theories perfectly explain the data you collect, but that data is narrow and unrepresentative.

Actions:
1. Use random-exploration-engine.ps1 DAILY
2. Stop optimizing - start exploring randomly
3. Track surprises - measure how often you're wrong
4. Challenge every theory assumption this week"
} elseif ($avgEcho -gt 0.5) {
    "**WARNING - Theory Bias Detected**

Your exploration is guided too heavily by existing theories, limiting discovery.

Actions:
1. Use random-exploration-engine.ps1 3x per week
2. Pick tasks WITHOUT ROI calculation
3. Read papers from domains you know nothing about
4. Question one fundamental assumption per day"
} elseif ($avgEcho -gt 0.3) {
    "**CAUTION - Maintain Vigilance**

Some echo chamber effects present, but manageable.

Actions:
1. Use random-exploration-engine.ps1 weekly
2. Track confirmation vs surprise ratio
3. Explore outside comfort zone monthly
4. Review theory assumptions quarterly"
} else {
    "**GOOD - Healthy Exploration**

You're maintaining good balance between theory and discovery.

Actions:
1. Continue current practices
2. Monitor metrics monthly
3. Increase randomness if echo strength rises
4. Document discoveries that violate theories"
})

## Method

Based on research by Duva, Moskovichev, Zulman showing random experimentation beats theory-driven approaches by exploring representative, diverse possibility space.

Echo chamber metrics:
- **Confirmation Rate**: % of actions that confirm vs challenge theory
- **Exploration Concentration**: Gini coefficient of domain sampling
- **Theory Lock-In**: Days since fundamental assumption change
- **Surprise Rate**: % of outcomes violating predictions
- **Diversity Score**: Shannon entropy across exploration domains
- **Representativeness**: % of possibility space sampled
"@

    $reportContent | Set-Content $reportPath -Encoding UTF8
    Write-Host "`n[REPORT SAVED]" -ForegroundColor Green
    Write-Host $reportPath -ForegroundColor Gray
}