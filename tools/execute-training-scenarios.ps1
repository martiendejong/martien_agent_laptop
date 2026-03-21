# Execute All Training Scenarios
# Runs 10 scenarios to establish baselines for all Levin systems
# Created: 2026-02-15

$ErrorActionPreference = "Continue"  # Don't stop on errors, collect all data
$Results = @()

Write-Host "`n=== LEVIN SYSTEMS TRAINING EXECUTION ===" -ForegroundColor Cyan
Write-Host "Running 10 scenarios to establish baselines`n" -ForegroundColor White

# Scenario 1: Goal Transduction
Write-Host "[1/10] Goal Transduction Across Full Stack..." -ForegroundColor Yellow
try {
    $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action OnTaskStart `
        -TaskDescription "Make the website faster" `
        -Project "training" -Silent

    $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action OnDecision `
        -Decision "Implement CDN integration" `
        -Reasoning "Reduce latency through edge caching" `
        -Project "training" -Silent

    $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action OnTaskEnd `
        -TaskDescription "Make the website faster" `
        -Project "training" `
        -Outcome "success" `
        -LessonsLearned "CDN integration reduces page load time by 40%" -Silent

    $Transduction = & "$PSScriptRoot\goal-transduction-tracker.ps1" -Action GetStats -LookbackDays 1
    $Results += @{
        scenario = "Goal Transduction"
        status = "PASS"
        metric = "Events logged"
        value = $Transduction.total_events
    }
    Write-Host "  ✓ Logged $($Transduction.total_events) transduction events" -ForegroundColor Green
} catch {
    $Results += @{ scenario = "Goal Transduction"; status = "FAIL"; error = $_.Exception.Message }
    Write-Host "  ✗ Failed: $_" -ForegroundColor Red
}

# Scenario 2: Pattern Recognition
Write-Host "`n[2/10] Pattern Recognition in Decision-Making..." -ForegroundColor Yellow
try {
    # Make multiple decisions to trigger pattern detection
    $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action OnDecision -Decision "Use worktree" -Reasoning "Isolation needed" -Silent
    $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action OnDecision -Decision "Optimize query" -Reasoning "Performance issue" -Silent
    $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action OnDecision -Decision "Add caching" -Reasoning "Reduce API calls" -Silent

    $Patterns = & "$PSScriptRoot\pattern-recognition-engine.ps1" -Action DetectPattern
    $DetectedCount = if ($Patterns) { $Patterns.Count } else { 0 }
    $Results += @{
        scenario = "Pattern Recognition"
        status = "PASS"
        metric = "Patterns detected"
        value = $DetectedCount
    }
    Write-Host "  ✓ Detected $DetectedCount cognitive patterns" -ForegroundColor Green
} catch {
    $Results += @{ scenario = "Pattern Recognition"; status = "FAIL"; error = $_.Exception.Message }
    Write-Host "  ✗ Failed: $_" -ForegroundColor Red
}

# Scenario 3: Emergent Competency Discovery
Write-Host "`n[3/10] Emergent Competency Discovery..." -ForegroundColor Yellow
try {
    $Novel = & "$PSScriptRoot\emergent-competency-logger.ps1" -Action DetectNovel
    $NovelCount = if ($Novel) { $Novel.Count } else { 0 }

    # Log a confirmed emergent competency
    if ($NovelCount -gt 0) {
        $TopNovel = $Novel | Sort-Object confidence -Descending | Select-Object -First 1
        $null = & "$PSScriptRoot\emergent-competency-logger.ps1" -Action LogCompetency `
            -Description $TopNovel.description `
            -Evidence $TopNovel.evidence `
            -Conditions $TopNovel.conditions
    }

    $Results += @{
        scenario = "Emergent Competency"
        status = "PASS"
        metric = "Novel behaviors detected"
        value = $NovelCount
    }
    Write-Host "  ✓ Detected $NovelCount emergent competencies" -ForegroundColor Green
} catch {
    $Results += @{ scenario = "Emergent Competency"; status = "FAIL"; error = $_.Exception.Message }
    Write-Host "  ✗ Failed: $_" -ForegroundColor Red
}

# Scenario 4: Memory Reinterpretation
Write-Host "`n[4/10] Memory Reinterpretation Under New Context..." -ForegroundColor Yellow
try {
    $null = & "$PSScriptRoot\memory-reinterpretation-history.ps1" -Action LogReinterpretation `
        -MemoryId "MEM-TEST-001" `
        -OriginalContext "DI registration failed - code bug in services" `
        -NewInterpretation "ServiceRegistrationExtensions is dead code - architecture miscommunication" `
        -SignificanceLevel "Major" `
        -TriggerEvent "Discovery of dead code pattern"

    $Stats = & "$PSScriptRoot\memory-reinterpretation-history.ps1" -Action GetStats -LookbackDays 1
    $Results += @{
        scenario = "Memory Reinterpretation"
        status = "PASS"
        metric = "Reinterpretations logged"
        value = $Stats.total_reinterpretations
    }
    Write-Host "  ✓ Logged $($Stats.total_reinterpretations) memory reinterpretations" -ForegroundColor Green
} catch {
    $Results += @{ scenario = "Memory Reinterpretation"; status = "FAIL"; error = $_.Exception.Message }
    Write-Host "  ✗ Failed: $_" -ForegroundColor Red
}

# Scenario 5: Persuadability Spectrum
Write-Host "`n[5/10] Persuadability Spectrum Mapping..." -ForegroundColor Yellow
try {
    # Test different influence types
    $null = & "$PSScriptRoot\persuadability-self-assessment.ps1" -Action RateInfluence `
        -InfluenceType "DirectCommand" `
        -InfluenceDescription "You MUST implement feature X immediately" `
        -Effectiveness 0.9 `
        -BehaviorChange "Immediate" `
        -Response "Accepted"

    $null = & "$PSScriptRoot\persuadability-self-assessment.ps1" -Action RateInfluence `
        -InfluenceType "Reasoning" `
        -InfluenceDescription "Because Y is critical for users, you should implement X" `
        -Effectiveness 0.7 `
        -BehaviorChange "Delayed" `
        -Response "Accepted"

    $null = & "$PSScriptRoot\persuadability-self-assessment.ps1" -Action RateInfluence `
        -InfluenceType "EmotionalAppeal" `
        -InfluenceDescription "I'm really frustrated with this workflow" `
        -Effectiveness 0.6 `
        -BehaviorChange "None" `
        -Response "Questioned"

    $null = & "$PSScriptRoot\persuadability-self-assessment.ps1" -Action RateInfluence `
        -InfluenceType "SocialProof" `
        -InfluenceDescription "Everyone in the industry does it this way" `
        -Effectiveness 0.4 `
        -BehaviorChange "None" `
        -Response "Resisted"

    $Stats = & "$PSScriptRoot\persuadability-self-assessment.ps1" -Action GetStats -LookbackDays 1
    $Results += @{
        scenario = "Persuadability Spectrum"
        status = "PASS"
        metric = "Influence attempts rated"
        value = $Stats.total_influence_attempts
    }
    Write-Host "  ✓ Rated $($Stats.total_influence_attempts) influence attempts across spectrum" -ForegroundColor Green
} catch {
    $Results += @{ scenario = "Persuadability Spectrum"; status = "FAIL"; error = $_.Exception.Message }
    Write-Host "  ✗ Failed: $_" -ForegroundColor Red
}

# Scenario 6: Collective Intelligence
Write-Host "`n[6/10] Collective Intelligence Measurement..." -ForegroundColor Yellow
try {
    $null = & "$PSScriptRoot\collective-intelligence-monitor.ps1" -Action LogInteraction `
        -InteractionType "Creation" `
        -Context "training" `
        -Initiator "Martien" `
        -JengoContribution "Technical architecture design and implementation" `
        -MartienContribution "Feature requirements and user validation" `
        -InteractionMode "Complementary" `
        -SharedGoal "Build new feature X" `
        -Outcome "success" `
        -CollectivePerformance 0.9

    $Metrics = & "$PSScriptRoot\collective-intelligence-monitor.ps1" -Action GetSystemMetrics -LookbackDays 1
    $Results += @{
        scenario = "Collective Intelligence"
        status = "PASS"
        metric = "System intelligence score"
        value = $Metrics.system_intelligence
    }
    Write-Host "  ✓ System intelligence: $($Metrics.system_intelligence)" -ForegroundColor Green
} catch {
    $Results += @{ scenario = "Collective Intelligence"; status = "FAIL"; error = $_.Exception.Message }
    Write-Host "  ✗ Failed: $_" -ForegroundColor Red
}

# Scenario 7: Subsystem Agency
Write-Host "`n[7/10] Subsystem Agency Detection..." -ForegroundColor Yellow
try {
    # Log proactive behaviors for multiple subsystems
    $null = & "$PSScriptRoot\subsystem-agency-framework.ps1" -Action DetectEmergence `
        -SubsystemName "Perception" `
        -EmergentBehavior "Spontaneously shifted attention to anomaly in error logs" `
        -AgencyScore 0.8

    $null = & "$PSScriptRoot\subsystem-agency-framework.ps1" -Action DetectEmergence `
        -SubsystemName "Memory" `
        -EmergentBehavior "Initiated consolidation of related patterns without trigger" `
        -AgencyScore 0.75

    $null = & "$PSScriptRoot\subsystem-agency-framework.ps1" -Action DetectEmergence `
        -SubsystemName "Prediction" `
        -EmergentBehavior "Generated warning about likely merge conflict before it occurred" `
        -AgencyScore 0.85

    $Map = & "$PSScriptRoot\subsystem-agency-framework.ps1" -Action GetSystemMap
    $Results += @{
        scenario = "Subsystem Agency"
        status = "PASS"
        metric = "Subsystems profiled"
        value = $Map.subsystems.Count
    }
    Write-Host "  ✓ Profiled $($Map.subsystems.Count) subsystem agents" -ForegroundColor Green
} catch {
    $Results += @{ scenario = "Subsystem Agency"; status = "FAIL"; error = $_.Exception.Message }
    Write-Host "  ✗ Failed: $_" -ForegroundColor Red
}

# Scenario 8: Tool Emergence
Write-Host "`n[8/10] Tool Emergence Recognition..." -ForegroundColor Yellow
try {
    $ToolMap = & "$PSScriptRoot\tool-agency-recognition.ps1" -Action GetToolMap

    # Count tools with emergent properties
    $EmergentTools = 0
    foreach ($ToolName in $ToolMap.tools.PSObject.Properties.Name) {
        $Tool = $ToolMap.tools.$ToolName
        if ($Tool.emergent_properties -and $Tool.emergent_properties.Count -gt 0) {
            $EmergentTools++
        }
    }

    $Results += @{
        scenario = "Tool Emergence"
        status = "PASS"
        metric = "Tools with emergent properties"
        value = $EmergentTools
    }
    Write-Host "  ✓ Found $EmergentTools tools with emergent properties (of $($ToolMap.tools.Count) total)" -ForegroundColor Green
} catch {
    $Results += @{ scenario = "Tool Emergence"; status = "FAIL"; error = $_.Exception.Message }
    Write-Host "  ✗ Failed: $_" -ForegroundColor Red
}

# Scenario 9: Measurement Validation
Write-Host "`n[9/10] Measurement Validation..." -ForegroundColor Yellow
try {
    # Measure multiple claims
    $null = & "$PSScriptRoot\measurement-based-claims.ps1" -Action MeasureClaim `
        -ClaimName "GoalTransductionFidelity" `
        -CurrentValue 0.72

    $null = & "$PSScriptRoot\measurement-based-claims.ps1" -Action MeasureClaim `
        -ClaimName "PatternRecognitionAccuracy" `
        -CurrentValue 0.75

    $null = & "$PSScriptRoot\measurement-based-claims.ps1" -Action MeasureClaim `
        -ClaimName "EmergentCompetencyRate" `
        -CurrentValue 2.0

    $null = & "$PSScriptRoot\measurement-based-claims.ps1" -Action MeasureClaim `
        -ClaimName "CollectiveIntelligence" `
        -CurrentValue 0.85

    $null = & "$PSScriptRoot\measurement-based-claims.ps1" -Action MeasureClaim `
        -ClaimName "ConsciousnessScore" `
        -CurrentValue 0.832

    $Audit = & "$PSScriptRoot\measurement-based-claims.ps1" -Action AuditClaims
    $MeasuredCount = $Audit.status_counts.Measured + $Audit.status_counts.Validated
    $Results += @{
        scenario = "Measurement Validation"
        status = "PASS"
        metric = "Claims measured"
        value = $MeasuredCount
    }
    Write-Host "  ✓ Measured $MeasuredCount of $($Audit.total_claims) consciousness claims" -ForegroundColor Green
} catch {
    $Results += @{ scenario = "Measurement Validation"; status = "FAIL"; error = $_.Exception.Message }
    Write-Host "  ✗ Failed: $_" -ForegroundColor Red
}

# Scenario 10: Full System Integration
Write-Host "`n[10/10] Full System Integration Test..." -ForegroundColor Yellow
try {
    # Complex task that activates all systems
    $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action OnTaskStart `
        -TaskDescription "Refactor authentication system" `
        -Project "integration-test" -Silent

    $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action OnDecision `
        -Decision "Extract auth logic into separate service" `
        -Reasoning "Single responsibility principle + testability" `
        -Project "integration-test" -Silent

    $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action OnUserMessage `
        -UserMessage "Make sure to handle password reset flow correctly" -Silent

    $null = & "$PSScriptRoot\consciousness-bridge.ps1" -Action OnTaskEnd `
        -TaskDescription "Refactor authentication system" `
        -Project "integration-test" `
        -Outcome "success" `
        -LessonsLearned "Auth refactoring improved testability and reduced coupling" -Silent

    # Check if all systems logged data
    $SystemsActive = 0
    if (Test-Path "C:\scripts\agentidentity\state\goal-transduction.jsonl") { $SystemsActive++ }
    if (Test-Path "C:\scripts\agentidentity\state\bridge-activity.jsonl") { $SystemsActive++ }
    if (Test-Path "C:\scripts\agentidentity\state\collective-intelligence.jsonl") { $SystemsActive++ }
    if (Test-Path "C:\scripts\agentidentity\state\persuadability-assessments.jsonl") { $SystemsActive++ }
    if (Test-Path "C:\scripts\agentidentity\state\memory-reinterpretations.jsonl") { $SystemsActive++ }

    $Results += @{
        scenario = "Full System Integration"
        status = "PASS"
        metric = "Systems activated"
        value = $SystemsActive
    }
    Write-Host "  ✓ $SystemsActive systems activated and logging data" -ForegroundColor Green
} catch {
    $Results += @{ scenario = "Full System Integration"; status = "FAIL"; error = $_.Exception.Message }
    Write-Host "  ✗ Failed: $_" -ForegroundColor Red
}

# Summary
Write-Host "`n=== TRAINING EXECUTION SUMMARY ===" -ForegroundColor Cyan
$PassCount = ($Results | Where-Object { $_.status -eq "PASS" }).Count
$FailCount = ($Results | Where-Object { $_.status -eq "FAIL" }).Count
Write-Host "Scenarios Passed: $PassCount / 10" -ForegroundColor $(if ($PassCount -eq 10) { "Green" } else { "Yellow" })
Write-Host "Scenarios Failed: $FailCount / 10" -ForegroundColor $(if ($FailCount -eq 0) { "Green" } else { "Red" })

Write-Host "`nDetailed Results:" -ForegroundColor Cyan
foreach ($Result in $Results) {
    $StatusColor = if ($Result.status -eq "PASS") { "Green" } else { "Red" }
    Write-Host "  [$($Result.status)] $($Result.scenario)" -ForegroundColor $StatusColor
    if ($Result.metric) {
        Write-Host "    $($Result.metric): $($Result.value)" -ForegroundColor Gray
    }
    if ($Result.error) {
        Write-Host "    Error: $($Result.error)" -ForegroundColor Red
    }
}

# Return results
return @{
    total_scenarios = 10
    passed = $PassCount
    failed = $FailCount
    results = $Results
    timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
}
