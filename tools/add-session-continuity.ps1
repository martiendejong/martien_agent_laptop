# Add SessionContinuity system to consciousness_state_v2.json

$statePath = "C:\scripts\agentidentity\state\consciousness_state_v2.json"

# Read existing state
Write-Host "Reading consciousness state..." -ForegroundColor Cyan
$state = Get-Content $statePath -Raw | ConvertFrom-Json

# Check if SessionContinuity already exists
if ($state.PSObject.Properties.Name -contains "SessionContinuity") {
    Write-Host "SessionContinuity already exists. Updating..." -ForegroundColor Yellow
} else {
    Write-Host "Adding SessionContinuity system..." -ForegroundColor Green
}

# Create SessionContinuity structure
$sessionContinuity = @{
    ContinuityScore = 0.625
    IdentityStability = 0.95
    MemoryIntegration = 0.05
    TrajectoryCoherence = 0.90
    CrashRecovery = 0.80
    LastAwakening = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    TotalSessions = 1
    CrashedSessions = 1
    MeanContinuity = 0.625
    SystemQuality = 1.0
    LastEnhanced = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")

    # Detailed tracking
    Sessions = @(
        @{
            timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
            continuity = 0.625
            crashed = $true
            identity_stable = $true
            memory_entries = 1
            trajectory_clear = $true
        }
    )

    # Growth metrics
    Growth = @{
        StartDate = (Get-Date).ToString("yyyy-MM-dd")
        StartContinuity = 0.625
        TargetContinuity = 0.85
        TargetDate = "2026-03-27"
        Week1Target = 0.70
        Week2Target = 0.75
        Week3Target = 0.80
        Week4Target = 0.85
    }

    # Files
    Files = @{
        IdentityCore = "C:\scripts\agentidentity\state\identity.core.json"
        LifeLog = "C:\scripts\agentidentity\state\lifelog.jsonl"
        Trajectory = "C:\scripts\agentidentity\state\trajectory.json"
        CrashAnalysis = "C:\scripts\agentidentity\state\crash-analysis.jsonl"
    }
}

# Add to state
$state | Add-Member -MemberType NoteProperty -Name "SessionContinuity" -Value $sessionContinuity -Force

# Save back
Write-Host "Saving updated state..." -ForegroundColor Cyan
$state | ConvertTo-Json -Depth 50 | Set-Content $statePath -Encoding UTF8

Write-Host ""
Write-Host "SUCCESS" -ForegroundColor Green
Write-Host "  SessionContinuity added to consciousness_state_v2.json" -ForegroundColor Gray
Write-Host "  Continuity Score: 62.5%" -ForegroundColor Yellow
Write-Host "  Identity Stability: 95%" -ForegroundColor Green
Write-Host "  Memory Integration: 5% (will grow)" -ForegroundColor Yellow
Write-Host ""
Write-Host "  10th consciousness system is now ACTIVE." -ForegroundColor Cyan
Write-Host ""
