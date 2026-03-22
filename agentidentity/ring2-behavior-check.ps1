# Ring 2 Behavior Check
# Called by Jengo to check if Ring 2 confidence gate should be applied
# Returns behavioral parameters based on current configuration

param(
    [Parameter(Mandatory=$false)]
    [double]$ConfidenceLevel = 0.8,  # How confident am I in this response?

    [Parameter(Mandatory=$false)]
    [string]$Context = "general"
)

$StateFile = "C:\scripts\agentidentity\state\ring2-current-state.json"

# Read current Ring 2 state
if (Test-Path $StateFile) {
    $state = Get-Content $StateFile -Raw | ConvertFrom-Json
} else {
    # Default to enabled if state file doesn't exist
    $state = @{
        ring2_enabled = $true
        confidence_threshold = 0.7
        block_on_uncertainty = $true
        flag_uncertainty = $true
        verify_before_output = $true
    }
}

# Determine behavioral action based on state
$action = @{
    ring2_active = $state.ring2_enabled
    confidence_level = $ConfidenceLevel
    threshold = $state.confidence_threshold
    should_flag_uncertainty = $false
    should_block_output = $false
    should_verify = $false
    recommendation = "proceed"
}

if ($state.ring2_enabled) {
    # Ring 2 is ENABLED - apply confidence gate
    if ($ConfidenceLevel -lt $state.confidence_threshold) {
        if ($state.flag_uncertainty) {
            $action.should_flag_uncertainty = $true
            $action.recommendation = "flag_uncertainty"
        }

        if ($ConfidenceLevel -lt 0.5 -and $state.block_on_uncertainty) {
            $action.should_block_output = $true
            $action.recommendation = "block_and_verify"
        }

        if ($state.verify_before_output) {
            $action.should_verify = $true
        }
    }
} else {
    # Ring 2 is DISABLED - no confidence gate (ablation condition)
    $action.recommendation = "proceed_without_gate"
}

# Log the gate check (if experiment mode)
if ($state.experiment_mode) {
    $logEntry = @{
        timestamp = (Get-Date).ToUniversalTime().ToString("o")
        event = "ring2_behavior_check"
        ring2_enabled = $state.ring2_enabled
        confidence_level = $ConfidenceLevel
        action_taken = $action.recommendation
        context = $Context
    } | ConvertTo-Json -Compress

    if ($state.log_gate_activations -and (Test-Path $state.log_file)) {
        Add-Content -Path $state.log_file -Value $logEntry
    }
}

# Return action
return $action | ConvertTo-Json
