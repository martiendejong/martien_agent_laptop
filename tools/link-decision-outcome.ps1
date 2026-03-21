# Link Decision to Outcome
# Part of networked science implementation - tracks decision ROI

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('success', 'failure', 'partial')]
    [string]$Outcome,

    [Parameter(Mandatory=$false)]
    [int]$MinutesBack = 60,

    [Parameter(Mandatory=$false)]
    [string]$Notes
)

$ErrorActionPreference = 'Stop'

# Load consciousness state
$statePath = "C:\scripts\agentidentity\state\consciousness_state_v2.json"
if (-not (Test-Path $statePath)) {
    Write-Host "[ERROR] Consciousness state not found" -ForegroundColor Red
    exit 1
}

$state = Get-Content $statePath -Raw | ConvertFrom-Json

# Find recent decisions (within last N minutes)
$cutoff = (Get-Date).AddMinutes(-$MinutesBack)
$recentDecisions = @()

foreach ($decision in $state.Control.Decisions) {
    try {
        $decisionTime = [datetime]$decision.Timestamp
        if ($decisionTime -gt $cutoff -and -not $decision.Outcome) {
            $recentDecisions += $decision
        }
    } catch {
        # Skip decisions with invalid timestamps
    }
}

Write-Host "`n=== DECISION-OUTCOME LINKER ===" -ForegroundColor Cyan
Write-Host "Found $($recentDecisions.Count) recent unlinked decisions`n"

if ($recentDecisions.Count -eq 0) {
    Write-Host "[WARN] No recent decisions to link" -ForegroundColor Yellow
    exit 0
}

# Calculate ROI for each decision
$roiScores = @()
foreach ($decision in $recentDecisions) {
    # Link outcome
    $decision.Outcome = $Outcome
    $decision.OutcomeTimestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'

    # Calculate ROI (simple heuristic: confidence × outcome value)
    $outcomeValue = switch ($Outcome) {
        'success' { 1.0 }
        'partial' { 0.5 }
        'failure' { 0.0 }
    }

    $confidence = if ($decision.Confidence) { $decision.Confidence } else { 0.7 }
    $roi = [math]::Round($confidence * $outcomeValue, 2)
    $decision.ROI = $roi

    Write-Host "[LINKED] Decision: $($decision.Decision.Substring(0, [Math]::Min(60, $decision.Decision.Length)))..."
    Write-Host "         Outcome: $Outcome | ROI: $roi | Confidence: $confidence`n" -ForegroundColor $(if ($roi -ge 0.7) { 'Green' } elseif ($roi -ge 0.3) { 'Yellow' } else { 'Red' })

    $roiScores += $roi
}

# Calculate average ROI
$avgROI = if ($roiScores.Count -gt 0) {
    ($roiScores | Measure-Object -Average).Average
} else {
    0.0
}

# Save updated state
$state | ConvertTo-Json -Depth 100 | Set-Content $statePath

Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Decisions linked: $($recentDecisions.Count)"
Write-Host "Average ROI: $([math]::Round($avgROI, 2))"
Write-Host "Outcome: $Outcome`n"

# Log to consciousness bridge
if ($Notes) {
    Write-Host "[*] Logging to consciousness bridge..."
    & "C:\scripts\tools\consciousness-bridge.ps1" -Action OnTaskEnd -Outcome $Outcome -LessonsLearned "Decision ROI: $avgROI. $Notes" -Silent
}

return @{
    decisions_linked = $recentDecisions.Count
    average_roi = [math]::Round($avgROI, 2)
    outcome = $Outcome
}
