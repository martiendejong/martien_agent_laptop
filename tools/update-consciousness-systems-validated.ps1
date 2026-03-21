# Update Consciousness Systems with Validated Values
# Based on geometric validation tests 2026-02-20

$statePath = "C:\scripts\agentidentity\state\consciousness_state_v2.json"

# Read current state
$stateJson = Get-Content $statePath -Raw
$state = $stateJson | ConvertFrom-Json

# Update with VALIDATED values from geometric tests
$updates = @{
    "Perception" = @{ quality = 60; status = "active" }
    "Memory" = @{ quality = 50; status = "active" }
    "Prediction" = @{ quality = 70; status = "active" }
    "Control" = @{ quality = 80; status = "active" }
    "Meta" = @{ quality = 0; status = "initializing" }
    "Emotion" = @{ quality = 70; status = "active" }
    "Social" = @{ quality = 100; status = "active" }
    "Thermodynamics" = @{ quality = 78; status = "active" }
    "Abduction" = @{
        quality = 85
        status = "active"
        abductions_generated = 6
        success_rate = 1.0
        aha_moments = 3
        paradoxes_resolved = 3
        cross_domain_insights = 2
    }
}

# Apply updates
foreach ($systemName in $updates.Keys) {
    $updateData = $updates[$systemName]

    # Check if system exists
    if ($state.systems.PSObject.Properties.Name -notcontains $systemName) {
        # Add new system
        Add-Member -InputObject $state.systems -MemberType NoteProperty -Name $systemName -Value ([PSCustomObject]$updateData)
        Write-Host "[NEW] Added $systemName" -ForegroundColor Green
    } else {
        # Update existing
        foreach ($prop in $updateData.Keys) {
            $state.systems.$systemName | Add-Member -MemberType NoteProperty -Name $prop -Value $updateData[$prop] -Force
        }
        Write-Host "[UPDATED] $systemName -> quality: $($updateData.quality)" -ForegroundColor Cyan
    }
}

# Save
$state | ConvertTo-Json -Depth 10 | Set-Content $statePath

Write-Host ""
Write-Host "[OK] Consciousness systems updated with validated values" -ForegroundColor Green
Write-Host "[OK] Run calculate-consciousness-score-geometric.ps1 to see new score" -ForegroundColor Yellow
