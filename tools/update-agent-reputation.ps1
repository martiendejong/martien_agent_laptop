# Update Agent Reputation
# Records delegation outcome and updates trust scores

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Explore', 'Plan', 'GeneralPurpose', 'Bash')]
    [string]$AgentType,

    [Parameter(Mandatory=$true)]
    [ValidateSet('code_search', 'architecture_analysis', 'file_discovery',
                 'feature_planning', 'architecture_design', 'research',
                 'debugging', 'complex_analysis', 'git_operations', 'terminal_commands')]
    [string]$TaskCategory,

    [Parameter(Mandatory=$true)]
    [ValidateSet('success', 'failure')]
    [string]$Outcome,

    [Parameter(Mandatory=$true)]
    [double]$TurnsUsed,

    [Parameter(Mandatory=$false)]
    [string]$FailurePattern = "",

    [Parameter(Mandatory=$false)]
    [string]$Notes = "",

    [switch]$Silent
)

$ErrorActionPreference = 'Stop'

# Load reputation data
$reputationPath = "C:\scripts\agentidentity\state\agent-reputation.json"
if (-not (Test-Path $reputationPath)) {
    throw "Reputation tracker not found at $reputationPath"
}

$reputation = Get-Content $reputationPath -Raw | ConvertFrom-Json

# Navigate to category data
$agentKey = "Task_$AgentType"
$agent = $reputation.agents.$agentKey
$category = $agent.task_categories.$TaskCategory

# Update statistics
$category.total_tasks++
if ($Outcome -eq 'success') {
    $category.successes++
} else {
    $category.failures++
    if ($FailurePattern -and -not ($category.failure_patterns -contains $FailurePattern)) {
        $category.failure_patterns += $FailurePattern
    }
}

# Recalculate success rate
$category.success_rate = if ($category.total_tasks -gt 0) {
    [Math]::Round($category.successes / $category.total_tasks, 3)
} else { 0.0 }

# Update average turns (exponential moving average, alpha=0.3)
if ($category.avg_turns -eq 0) {
    $category.avg_turns = $TurnsUsed
} else {
    $alpha = 0.3
    $category.avg_turns = [Math]::Round(($alpha * $TurnsUsed) + ((1 - $alpha) * $category.avg_turns), 2)
}

# Update trust score based on success rate
# Trust = 10 * success_rate, with decay for recent failures
$baseTrust = 10 * $category.success_rate

# Penalty for recent failure
if ($Outcome -eq 'failure') {
    $failurePenalty = 1.0
    $category.trust_score = [Math]::Max(0, $baseTrust - $failurePenalty)
} else {
    $category.trust_score = $baseTrust
}
$category.trust_score = [Math]::Round($category.trust_score, 1)

# Update notes
if ($Notes) {
    $category.notes = $Notes
}

# Add to delegation log
$logEntry = @{
    timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    agent_type = $AgentType
    task_category = $TaskCategory
    outcome = $Outcome
    turns_used = $TurnsUsed
    failure_pattern = $FailurePattern
    notes = $Notes
    new_trust_score = $category.trust_score
    new_success_rate = $category.success_rate
}

$reputation.delegation_log += $logEntry
$reputation.last_updated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")

# Save updated reputation
$reputation | ConvertTo-Json -Depth 10 | Set-Content $reputationPath

if (-not $Silent) {
    Write-Host "`n[✓] Agent reputation updated" -ForegroundColor Green
    Write-Host "    Agent:        $AgentType" -ForegroundColor Cyan
    Write-Host "    Category:     $TaskCategory" -ForegroundColor Cyan
    Write-Host "    Outcome:      " -NoNewline
    if ($Outcome -eq 'success') {
        Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "FAILURE" -ForegroundColor Red
    }
    Write-Host "    Turns Used:   $TurnsUsed"
    Write-Host ""
    Write-Host "    Updated Stats:" -ForegroundColor Yellow
    Write-Host "      Total Tasks:    $($category.total_tasks)"
    Write-Host "      Success Rate:   $($category.success_rate * 100)%"
    Write-Host "      Avg Turns:      $($category.avg_turns)"
    Write-Host "      Trust Score:    $($category.trust_score)/10"

    if ($FailurePattern) {
        Write-Host "      Failure Pattern: $FailurePattern" -ForegroundColor Red
    }
    Write-Host ""
}

# Return updated category data
return $category
