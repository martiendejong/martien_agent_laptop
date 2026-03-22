# Ring 2 Startup Integration
# Reads ring2-config.json and applies behavioral parameters
# MUST run BEFORE Claude processes any user input

$ErrorActionPreference = "SilentlyContinue"

$ConfigPath = "C:\scripts\agentidentity\config\ring2-config.json"
$StateFile = "C:\scripts\agentidentity\state\ring2-current-state.json"

# Read configuration
if (Test-Path $ConfigPath) {
    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

    # Create behavioral state file that Claude will read
    $behavioralState = @{
        ring2_enabled = $config.ring2_enabled
        confidence_threshold = $config.confidence_threshold
        block_on_uncertainty = $config.block_on_uncertainty
        flag_uncertainty = $config.flag_uncertainty
        verify_before_output = $config.verify_before_output
        experiment_mode = $config.experiment_mode
        current_condition = $config.current_condition
        loaded_at = (Get-Date).ToUniversalTime().ToString("o")
    }

    # Save to state file
    $behavioralState | ConvertTo-Json -Depth 10 | Set-Content $StateFile

    # Log activation (for experiment tracking)
    if ($config.log_gate_activations) {
        $logEntry = @{
            timestamp = (Get-Date).ToUniversalTime().ToString("o")
            event = "ring2_startup_integration"
            ring2_enabled = $config.ring2_enabled
            condition = $config.current_condition
        } | ConvertTo-Json -Compress

        if (Test-Path $config.log_file) {
            Add-Content -Path $config.log_file -Value $logEntry
        }
    }

    # Output status (visible during startup only)
    if ($config.experiment_mode) {
        Write-Host "[EXPERIMENT MODE] Ring 2: $(if ($config.ring2_enabled) {'ENABLED'} else {'DISABLED'})" -ForegroundColor Yellow
        Write-Host "[EXPERIMENT MODE] Condition: $($config.current_condition)" -ForegroundColor Yellow
    }
} else {
    # Default state if config not found
    $defaultState = @{
        ring2_enabled = $true
        confidence_threshold = 0.7
        block_on_uncertainty = $true
        flag_uncertainty = $true
        verify_before_output = $true
        experiment_mode = $false
        current_condition = "baseline"
        loaded_at = (Get-Date).ToUniversalTime().ToString("o")
    }

    $defaultState | ConvertTo-Json -Depth 10 | Set-Content $StateFile
}
