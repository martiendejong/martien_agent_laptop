# Calculate Delegation Cost
# Implements intelligent delegation protocol from Google DeepMind paper
# Decision support: should I delegate this task or do it myself?

param(
    [Parameter(Mandatory=$true)]
    [string]$TaskDescription,

    [Parameter(Mandatory=$true)]
    [ValidateSet('Explore', 'Plan', 'GeneralPurpose', 'Bash')]
    [string]$AgentType,

    [Parameter(Mandatory=$true)]
    [ValidateSet('code_search', 'architecture_analysis', 'file_discovery',
                 'feature_planning', 'architecture_design', 'research',
                 'debugging', 'complex_analysis', 'git_operations', 'terminal_commands')]
    [string]$TaskCategory,

    [Parameter(Mandatory=$false)]
    [int]$Criticality = -1,  # 0-10, will prompt if not provided

    [Parameter(Mandatory=$false)]
    [int]$Verifiability = -1,  # 0-10, will prompt if not provided

    [Parameter(Mandatory=$false)]
    [double]$SelfEstimateTurns = -1,  # Estimated turns if I do it myself

    [switch]$Silent,
    [switch]$JsonOutput
)

$ErrorActionPreference = 'Stop'

# Load agent reputation data
$reputationPath = "C:\scripts\agentidentity\state\agent-reputation.json"
if (-not (Test-Path $reputationPath)) {
    throw "Reputation tracker not found at $reputationPath"
}

$reputation = Get-Content $reputationPath -Raw | ConvertFrom-Json

# Get agent data
$agentKey = "Task_$AgentType"
if (-not $reputation.agents.PSObject.Properties.Name -contains $agentKey) {
    throw "Unknown agent type: $AgentType"
}

$agentData = $reputation.agents.$agentKey
if (-not $agentData.task_categories.PSObject.Properties.Name -contains $TaskCategory) {
    throw "Unknown task category '$TaskCategory' for agent '$AgentType'"
}

$categoryData = $agentData.task_categories.$TaskCategory

# Interactive prompts if values not provided
if ($Criticality -lt 0 -and -not $Silent) {
    Write-Host "`nCriticality Assessment (0-10):" -ForegroundColor Cyan
    Write-Host "  0 = Trivial (typo fix, quick check)"
    Write-Host "  3 = Low (nice to have, low impact)"
    Write-Host "  5 = Medium (useful, some impact)"
    Write-Host "  7 = High (important, significant impact)"
    Write-Host "  10 = Critical (blocks work, high stakes)"
    $Criticality = Read-Host "Criticality"
    $Criticality = [int]$Criticality
}
elseif ($Criticality -lt 0) {
    $Criticality = 5  # Default to medium
}

if ($Verifiability -lt 0 -and -not $Silent) {
    Write-Host "`nVerifiability Assessment (0-10):" -ForegroundColor Cyan
    Write-Host "  0 = Opaque (can't check, must trust)"
    Write-Host "  3 = Low (hard to verify, subjective)"
    Write-Host "  5 = Medium (can check with effort)"
    Write-Host "  7 = High (clear tests/criteria)"
    Write-Host "  10 = Obvious (deterministic, easy to verify)"
    $Verifiability = Read-Host "Verifiability"
    $Verifiability = [int]$Verifiability
}
elseif ($Verifiability -lt 0) {
    $Verifiability = 5  # Default to medium
}

if ($SelfEstimateTurns -lt 0 -and -not $Silent) {
    Write-Host "`nSelf-Execution Estimate:" -ForegroundColor Cyan
    Write-Host "  How many turns would it take YOU to do this task?"
    Write-Host "  (1 turn = 1 interaction with tools/files)"
    $SelfEstimateTurns = Read-Host "Estimated turns"
    $SelfEstimateTurns = [double]$SelfEstimateTurns
}
elseif ($SelfEstimateTurns -lt 0) {
    $SelfEstimateTurns = 5.0  # Default estimate
}

# Calculate costs
$trustScore = $categoryData.trust_score
$avgAgentTurns = if ($categoryData.avg_turns -gt 0) { $categoryData.avg_turns } else { 3.0 }

# Transaction costs
$searchCost = 0.5  # Finding/briefing agent
$negotiationCost = 0.5  # Defining success criteria
$enforcementCost = (10 - $trustScore) * $Criticality / 10.0  # Monitoring/verification

$transactionCost = $searchCost + $negotiationCost + $enforcementCost

# Execution costs
$executionCostAgent = $avgAgentTurns
$executionCostSelf = $SelfEstimateTurns

# Total costs
$totalCostDelegate = $executionCostAgent + $transactionCost
$totalCostSelf = $executionCostSelf

# Decision
$decision = if ($totalCostDelegate -lt $totalCostSelf) { "DELEGATE" } else { "DO_MYSELF" }
$savings = [Math]::Abs($totalCostDelegate - $totalCostSelf)
$savingsPercent = ($savings / $totalCostSelf) * 100

# Verification depth (turns needed to verify)
$verificationTurns = (10 - $trustScore) * $Criticality / 10.0

# Build result object
$result = @{
    task_description = $TaskDescription
    agent_type = $AgentType
    task_category = $TaskCategory
    assessment = @{
        criticality = $Criticality
        verifiability = $Verifiability
        trust_score = $trustScore
    }
    costs = @{
        transaction = @{
            search = $searchCost
            negotiation = $negotiationCost
            enforcement = $enforcementCost
            total = $transactionCost
        }
        execution = @{
            agent = $executionCostAgent
            self = $executionCostSelf
        }
        total = @{
            delegate = $totalCostDelegate
            do_myself = $totalCostSelf
        }
    }
    verification = @{
        turns_required = $verificationTurns
        level = if ($verificationTurns -lt 1) { "spot_check" }
                elseif ($verificationTurns -lt 3) { "moderate" }
                elseif ($verificationTurns -lt 5) { "thorough" }
                else { "deep_audit" }
    }
    recommendation = @{
        decision = $decision
        savings = $savings
        savings_percent = [Math]::Round($savingsPercent, 1)
        confidence = if ($categoryData.total_tasks -ge 5) { "high" }
                     elseif ($categoryData.total_tasks -ge 2) { "medium" }
                     else { "low_data" }
    }
    agent_reputation = @{
        total_tasks = $categoryData.total_tasks
        success_rate = $categoryData.success_rate
        avg_turns = $categoryData.avg_turns
        failure_patterns = $categoryData.failure_patterns
    }
    timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
}

# Output
if ($JsonOutput) {
    $result | ConvertTo-Json -Depth 10
}
else {
    if (-not $Silent) {
        Write-Host "`n================================================================" -ForegroundColor Yellow
        Write-Host "           DELEGATION COST ANALYSIS" -ForegroundColor Yellow
        Write-Host "================================================================" -ForegroundColor Yellow

        Write-Host "`nTask: " -NoNewline
        Write-Host $TaskDescription -ForegroundColor White
        Write-Host "Agent: " -NoNewline
        Write-Host "$AgentType ($TaskCategory)" -ForegroundColor Cyan

        Write-Host "`n--- ASSESSMENT ---" -ForegroundColor Cyan
        Write-Host "  Criticality:    $Criticality/10"
        Write-Host "  Verifiability:  $Verifiability/10"
        Write-Host "  Trust Score:    $trustScore/10"

        Write-Host "`n--- COSTS ---" -ForegroundColor Cyan
        Write-Host "  Transaction:"
        Write-Host "    Search:       $searchCost turns"
        Write-Host "    Negotiation:  $negotiationCost turns"
        Write-Host "    Enforcement:  $([Math]::Round($enforcementCost, 2)) turns"
        Write-Host "    TOTAL:        $([Math]::Round($transactionCost, 2)) turns" -ForegroundColor Yellow

        Write-Host "`n  Execution:"
        Write-Host "    Agent:        $([Math]::Round($executionCostAgent, 2)) turns"
        Write-Host "    Self:         $([Math]::Round($executionCostSelf, 2)) turns"

        Write-Host "`n  Total Cost:"
        Write-Host "    Delegate:     $([Math]::Round($totalCostDelegate, 2)) turns" -ForegroundColor $(if ($decision -eq "DELEGATE") { "Green" } else { "Red" })
        Write-Host "    Do Myself:    $([Math]::Round($totalCostSelf, 2)) turns" -ForegroundColor $(if ($decision -eq "DO_MYSELF") { "Green" } else { "Red" })

        Write-Host "`n--- VERIFICATION ---" -ForegroundColor Cyan
        Write-Host "  Required:       $([Math]::Round($verificationTurns, 2)) turns"
        Write-Host "  Level:          $($result.verification.level)"

        Write-Host "`n--- RECOMMENDATION ---" -ForegroundColor Green
        Write-Host "  Decision:       " -NoNewline
        if ($decision -eq "DELEGATE") {
            Write-Host "DELEGATE" -ForegroundColor Green
        } else {
            Write-Host "DO IT MYSELF" -ForegroundColor Magenta
        }
        $savingsPercentStr = [Math]::Round($savingsPercent, 1).ToString() + "%"
        Write-Host "  Savings:        $([Math]::Round($savings, 2)) turns ($savingsPercentStr)"
        Write-Host "  Confidence:     $($result.recommendation.confidence)"

        if ($categoryData.total_tasks -lt 3) {
            Write-Host "`n[!] LOW DATA WARNING: Only $($categoryData.total_tasks) tasks recorded for this category" -ForegroundColor Yellow
            Write-Host "    Trust score may not be calibrated. Use with caution." -ForegroundColor Yellow
        }

        if ($decision -eq "DELEGATE") {
            Write-Host "`n[OK] Smart Contract Checklist:" -ForegroundColor Green
            Write-Host "  [ ] Define success criteria (what does 'done' look like?)"
            Write-Host "  [ ] Define verification method (how will you check?)"
            Write-Host "  [ ] Set monitoring checkpoints (based on verification level: $($result.verification.level))"
            Write-Host "  [ ] Define fallback plan (if agent fails, plan B?)"
        } else {
            Write-Host "`n[OK] Execution Tips:" -ForegroundColor Magenta
            Write-Host "  - Task is simple enough to do yourself efficiently"
            Write-Host "  - No coordination overhead"
            Write-Host "  - Direct control over quality"
        }

        Write-Host "`n===============================================================`n"
    }

    # Return decision for scripting
    return $result
}
