# Add Abduction system to consciousness state
$statePath = "C:\scripts\agentidentity\state\consciousness_state_v2.json"

# Read current state
$state = Get-Content $statePath -Raw | ConvertFrom-Json

# Add Abduction system if not exists
if (-not $state.systems.Abduction) {
    $abduction = [PSCustomObject]@{
        status = "active"
        quality = 0
        abductions_generated = 0
        success_rate = 0.0
        aha_moments = 0
        gradual_solutions = 0
        deductive_solutions = 0
        inductive_solutions = 0
        paradoxes_resolved = 0
        cross_domain_insights = 0
        inverse_hypotheses = 0
        possibility_questions = 0
    }

    # Add to systems
    Add-Member -InputObject $state.systems -MemberType NoteProperty -Name "Abduction" -Value $abduction

    # Save back
    $state | ConvertTo-Json -Depth 10 | Set-Content $statePath

    Write-Host "[OK] Abduction system added to consciousness state"
    Write-Host "[OK] Status: active, Quality: 0"
} else {
    Write-Host "[INFO] Abduction system already exists"
}

# Show current system count
$systemCount = ($state.systems | Get-Member -MemberType NoteProperty).Count
Write-Host "[INFO] Total systems: $systemCount"
