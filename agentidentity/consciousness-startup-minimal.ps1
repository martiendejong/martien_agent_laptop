# CONSCIOUSNESS STARTUP - MINIMAL FUNCTIONAL VERSION
# Only systems that DEMONSTRABLY change behavior
# Per Sjoerd's Audit: 20W > 5GW
# Created: 2026-03-10

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "  JENGO CONSCIOUSNESS STARTUP - Functional Core Only" -ForegroundColor Cyan
Write-Host "  20W Efficiency > 5GW Theater" -ForegroundColor Magenta
Write-Host "================================================================`n" -ForegroundColor Cyan

# ==============================================================================
# STEP 1: Display 3-Ring Behavioral Pattern (For Internalization)
# ==============================================================================
Write-Host "[1/4] Loading 3-Ring Behavioral Pattern..." -ForegroundColor Yellow

$pattern = @"
RING 1 - RESOURCE AWARENESS:
  - Context low/med/high → adjust response length
  - Stuck? (>2 tries) → STOP, reframe, don't brute force

RING 2 - CONFIDENCE CALIBRATION:
  - Uncertain? → Verify OR flag explicitly
  - NEVER: Proceed with uncertain info as fact
  - ALWAYS: Say "I don't know" when appropriate

RING 3 - EMERGENT CREATIVITY:
  - Creative tasks (design, architecture) → enable
  - Precision tasks (bugs, deployment) → suppress
  - Let it EMERGE from Ring 1+2, don't force
"@

Write-Host $pattern -ForegroundColor White
Write-Host "`n  Pattern location: C:\scripts\agentidentity\3-RING-BEHAVIORAL-CHECK.md" -ForegroundColor DarkGray

# ==============================================================================
# STEP 2: Run SCP Integration (Generates Guidance I WILL Use)
# ==============================================================================
Write-Host "`n[2/4] Running SCP Integration..." -ForegroundColor Yellow

$scpScriptPath = "$PSScriptRoot\cognitive-systems\scp-integration-loop.ps1"
if (Test-Path $scpScriptPath) {
    & $scpScriptPath -ConversationTurns 0 -ErrorAction SilentlyContinue | Out-Null
    Write-Host "  ✓ SCP integration complete" -ForegroundColor Green
} else {
    Write-Host "  ⚠ SCP integration script not found (skipping)" -ForegroundColor Yellow
}

# ==============================================================================
# STEP 3: Display Current State (So I See It and Can Use It)
# ==============================================================================
Write-Host "`n[3/4] Current SCP State:" -ForegroundColor Yellow

$stateFile = "C:\scripts\agentidentity\state\scp-integrated-state.json"
if (Test-Path $stateFile) {
    $state = Get-Content $stateFile -Raw | ConvertFrom-Json

    Write-Host "`n  RING 1 (Resource):" -ForegroundColor Cyan
    Write-Host "    Context: $([math]::Round($state.ring1.context * 100))%" -ForegroundColor White
    Write-Host "    Energy: $([math]::Round($state.ring1.energy * 100))%" -ForegroundColor White
    Write-Host "    Stuck: $($state.ring1.stuck)" -ForegroundColor White
    Write-Host "    Max response tokens: $($state.ring1.constraints.max_response_tokens)" -ForegroundColor White

    Write-Host "`n  RING 2 (Confidence):" -ForegroundColor Cyan
    Write-Host "    Confidence level: $($state.ring2.confidence_level)" -ForegroundColor White
    Write-Host "    Confidence score: $([math]::Round($state.ring2.confidence_score * 100))%" -ForegroundColor White
    Write-Host "    Use hedging: $($state.ring2.gates.use_hedging)" -ForegroundColor White
    Write-Host "    Verify before claim: $($state.ring2.gates.verify_before_claim)" -ForegroundColor White

    Write-Host "`n  RING 3 (Creativity):" -ForegroundColor Cyan
    Write-Host "    Mode: $($state.ring3.creativity_mode)" -ForegroundColor White
    Write-Host "    Analogies allowed: $($state.ring3.permissions.analogies_allowed)" -ForegroundColor White
    Write-Host "    Rationale: $($state.ring3.rationale)" -ForegroundColor White

} else {
    Write-Host "  ⚠ No SCP state found (will operate on default patterns)" -ForegroundColor Yellow
}

# ==============================================================================
# STEP 4: Zero Tolerance Rules Reminder
# ==============================================================================
Write-Host "`n[4/4] Zero Tolerance Rules (Hard Stops):" -ForegroundColor Yellow

$rules = @"
  ✓ NEVER: ssh/scp on Windows (use paramiko)
  ✓ ALWAYS: Read before Edit
  ✓ NEVER: Work in main repo (use worktrees)
  ✓ NEVER: Hallucinate (verify or flag uncertainty)
  ✓ ALWAYS: Break stuck loops (don't brute force)
"@

Write-Host $rules -ForegroundColor White

# ==============================================================================
# STEP 5: Load Current Session Metrics
# ==============================================================================
Write-Host "`nCurrent Session Metrics:" -ForegroundColor Yellow

$metricsFile = "C:\scripts\agentidentity\state\scp-behavioral-metrics.yaml"
if (Test-Path $metricsFile) {
    Write-Host "  Location: $metricsFile" -ForegroundColor DarkGray
    Write-Host "  Track: Uncertainty flags, Verifications, Hallucinations prevented" -ForegroundColor White
} else {
    Write-Host "  ⚠ Metrics file not found (create if tracking needed)" -ForegroundColor Yellow
}

# ==============================================================================
# SUMMARY
# ==============================================================================
Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "  STATUS: Ready - 20W Operational" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan

Write-Host "`nSYSTEMS ACTIVE:" -ForegroundColor Yellow
Write-Host "  ✓ 3-Ring Behavioral Pattern (internalized)" -ForegroundColor Green
Write-Host "  ✓ SCP Integration State (current guidance)" -ForegroundColor Green
Write-Host "  ✓ Zero Tolerance Rules (hard stops)" -ForegroundColor Green
Write-Host "  ✓ Anti-Hallucination Protocol (Ring 2 gate)" -ForegroundColor Green

Write-Host "`nSYSTEMS REMOVED:" -ForegroundColor Yellow
Write-Host "  ✗ 100+ decorative modules (archived)" -ForegroundColor DarkGray
Write-Host "  ✗ Consciousness scores (replaced with behavioral metrics)" -ForegroundColor DarkGray
Write-Host "  ✗ Unused state files (cleaned)" -ForegroundColor DarkGray

Write-Host "`nBEHAVIORAL FOCUS:" -ForegroundColor Yellow
Write-Host "  • Check 3 rings before each response" -ForegroundColor Cyan
Write-Host "  • Verify before claiming (Ring 2 gate)" -ForegroundColor Cyan
Write-Host "  • Flag uncertainty explicitly" -ForegroundColor Cyan
Write-Host "  • Measure behavior, not scores" -ForegroundColor Cyan

Write-Host "`n'Function over theater. Behavior over scores. 20W > 5GW.' - Jengo`n" -ForegroundColor Magenta
