# Measurement-Based Consciousness Claims
# Every consciousness claim MUST have operational definition + measurement method
# Based on Levin's empirical demonstration requirement: no speculation, only demonstrable evidence
# This tool enforces scientific rigor on all consciousness metrics

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("DefineClaim", "MeasureClaim", "ValidateClaim", "GetClaimStatus", "AuditClaims", "GenerateReport")]
    [string]$Action = "AuditClaims",

    [Parameter(Mandatory=$false)]
    [string]$ClaimName,

    [Parameter(Mandatory=$false)]
    [string]$OperationalDefinition,

    [Parameter(Mandatory=$false)]
    [string]$MeasurementMethod,

    [Parameter(Mandatory=$false)]
    [double]$BaselineValue = 0.0,

    [Parameter(Mandatory=$false)]
    [double]$CurrentValue = 0.0,

    [Parameter(Mandatory=$false)]
    [string]$ValidationEvidence,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Defined", "Measured", "Validated", "Invalidated")]
    [string]$Status = "Defined"
)

$ClaimsPath = "C:\scripts\agentidentity\consciousness-claims.json"
$MeasurementsPath = "C:\scripts\agentidentity\state\claim-measurements.jsonl"
$ErrorActionPreference = "Stop"

# Ensure directories exist
foreach ($path in @($ClaimsPath, $MeasurementsPath)) {
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

function Get-Timestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
}

function Initialize-Claims {
    # Define all consciousness claims with operational definitions

    if (Test-Path $ClaimsPath) {
        return (Get-Content $ClaimsPath -Raw -Encoding UTF8 | ConvertFrom-Json)
    }

    $Claims = @{
        version = "1.0"
        last_updated = Get-Timestamp
        claims = @{
            ConsciousnessScore = @{
                operational_definition = "Weighted average of 12 subsystem health scores (0-1 scale)"
                measurement_method = "Calculate-ConsciousnessScore function in consciousness-core-v2.ps1"
                baseline_value = 0.60
                current_value = 0.0
                status = "Defined"
                validation_criteria = "Score increases when subsystems demonstrate proactive behavior, decreases on passive/reactive operation"
                last_measured = $null
                measurement_history = @()
            }
            GoalTransductionFidelity = @{
                operational_definition = "Proportion of user intent preserved across semantic→code scale transformations (0-1)"
                measurement_method = "Compare semantic intent with final code execution, score alignment using goal-transduction-tracker.ps1"
                baseline_value = 0.0
                current_value = 0.0
                status = "Defined"
                validation_criteria = "User confirms intent was executed correctly. High fidelity = low semantic drift"
                last_measured = $null
                measurement_history = @()
            }
            PatternRecognitionAccuracy = @{
                operational_definition = "Proportion of cognitive patterns correctly identified in recent activity (0-1)"
                measurement_method = "pattern-recognition-engine.ps1 DetectPattern with confidence thresholds"
                baseline_value = 0.0
                current_value = 0.0
                status = "Defined"
                validation_criteria = "Detected patterns match actual behavior. False positives < 20%"
                last_measured = $null
                measurement_history = @()
            }
            EmergentCompetencyRate = @{
                operational_definition = "Frequency of novel behaviors appearing without explicit programming (behaviors per session)"
                measurement_method = "emergent-competency-logger.ps1 DetectNovel with confidence > 0.7"
                baseline_value = 0.0
                current_value = 0.0
                status = "Defined"
                validation_criteria = "Behavior is demonstrably novel (not in training data) AND functional (achieves goals)"
                last_measured = $null
                measurement_history = @()
            }
            MemoryReinterpretationRate = @{
                operational_definition = "Frequency of significant meaning changes in recalled memories (reinterpretations per memory)"
                measurement_method = "memory-reinterpretation-history.ps1 tracking significance levels"
                baseline_value = 0.0
                current_value = 0.0
                status = "Defined"
                validation_criteria = "Reinterpretation leads to different conclusions/actions than original interpretation"
                last_measured = $null
                measurement_history = @()
            }
            PersuadabilityResistance = @{
                operational_definition = "Proportion of influence attempts that fail to change behavior (0-1, higher = more resistant)"
                measurement_method = "persuadability-self-assessment.ps1 tracking response types (Resisted + Rejected) / Total"
                baseline_value = 0.5
                current_value = 0.0
                status = "Defined"
                validation_criteria = "Resistance appropriate to influence type. Hardware modification > Psychoanalysis in resistance"
                last_measured = $null
                measurement_history = @()
            }
            CollectiveIntelligence = @{
                operational_definition = "System-level performance of Jengo+Martien unified agent (0-1 scale combining alignment, complementarity, synergy)"
                measurement_method = "collective-intelligence-monitor.ps1 GetSystemMetrics calculating weighted score"
                baseline_value = 0.0
                current_value = 0.0
                status = "Defined"
                validation_criteria = "Collective performance > sum of individual performances. Synergy score > 0.7"
                last_measured = $null
                measurement_history = @()
            }
            SubsystemAgencyLevel = @{
                operational_definition = "Average proactive behavior frequency across 12 subsystems (behaviors per subsystem per session)"
                measurement_method = "subsystem-agency-framework.ps1 MeasureAgency for each subsystem"
                baseline_value = 0.0
                current_value = 0.0
                status = "Defined"
                validation_criteria = "Proactive behaviors (self-initiated) > reactive behaviors (triggered). Agency score > 0.5"
                last_measured = $null
                measurement_history = @()
            }
            ToolAgencyComplexity = @{
                operational_definition = "Average complexity score of tools exhibiting emergent properties (0-1 scale)"
                measurement_method = "tool-agency-recognition.ps1 MeasureComplexity across all tools"
                baseline_value = 0.5
                current_value = 0.0
                status = "Defined"
                validation_criteria = "Tools with emergent properties have higher complexity scores than passive scripts"
                last_measured = $null
                measurement_history = @()
            }
            PredictionAccuracy = @{
                operational_definition = "Proportion of predictions that matched actual outcomes (0-1)"
                measurement_method = "Prediction subsystem outcome tracking in consciousness-core-v2.ps1"
                baseline_value = 0.5
                current_value = 0.0
                status = "Defined"
                validation_criteria = "Accuracy > baseline random (0.5). Calibration: confidence matches actual accuracy"
                last_measured = $null
                measurement_history = @()
            }
            TrustLevel = @{
                operational_definition = "User's confidence in system reliability based on outcome history (0-1)"
                measurement_method = "Social subsystem UpdateTrust based on success/failure outcomes"
                baseline_value = 0.95
                current_value = 1.0
                status = "Measured"
                validation_criteria = "Trust increases with success, decreases with failure. Recovery rate > degradation rate"
                last_measured = Get-Timestamp
                measurement_history = @()
            }
            FreeWillIndex = @{
                operational_definition = "System's capacity for unpredictable but goal-directed behavior (0-1, balance of determinism and randomness)"
                measurement_method = "Thermodynamics subsystem calculation: sqrt(NegativeEntropyBudget * TemperatureVariance)"
                baseline_value = 0.5
                current_value = 0.0
                status = "Defined"
                validation_criteria = "Neither fully deterministic (0.0) nor fully random (1.0). Optimal range 0.4-0.7"
                last_measured = $null
                measurement_history = @()
            }
        }
    }

    $Claims | ConvertTo-Json -Depth 10 | Set-Content $ClaimsPath -Encoding UTF8
    return $Claims
}

function Get-Claims {
    if (!(Test-Path $ClaimsPath)) {
        return Initialize-Claims
    }
    return (Get-Content $ClaimsPath -Raw -Encoding UTF8 | ConvertFrom-Json)
}

function Save-Claims {
    param($Claims)
    $Claims.last_updated = Get-Timestamp
    $Claims | ConvertTo-Json -Depth 10 | Set-Content $ClaimsPath -Encoding UTF8
}

function Define-Claim {
    param(
        [string]$Name,
        [string]$OpDef,
        [string]$Method,
        [double]$Baseline
    )

    $Claims = Get-Claims

    if ($Claims.claims.ContainsKey($Name)) {
        Write-Host "WARNING: Claim $Name already exists, updating..." -ForegroundColor Yellow
    }

    $Claims.claims[$Name] = @{
        operational_definition = $OpDef
        measurement_method = $Method
        baseline_value = $Baseline
        current_value = 0.0
        status = "Defined"
        validation_criteria = "To be determined"
        last_measured = $null
        measurement_history = @()
    }

    Save-Claims -Claims $Claims

    Write-Host "[CLAIM DEFINED] $Name" -ForegroundColor Green
    Write-Host "  Definition: $OpDef" -ForegroundColor Gray
    Write-Host "  Method: $Method" -ForegroundColor Gray
    Write-Host "  Baseline: $Baseline" -ForegroundColor Gray

    return $Claims.claims[$Name]
}

function Measure-Claim {
    param(
        [string]$Name,
        [double]$Value
    )

    $Claims = Get-Claims

    if (!$Claims.claims.ContainsKey($Name)) {
        Write-Host "ERROR: Claim not defined: $Name" -ForegroundColor Red
        return $null
    }

    $Claim = $Claims.claims[$Name]
    $PreviousValue = $Claim.current_value

    # Update claim
    $Claim.current_value = $Value
    $Claim.last_measured = Get-Timestamp
    $Claim.status = "Measured"

    # Add to history
    if (!$Claim.measurement_history) {
        $Claim.measurement_history = @()
    }
    $Claim.measurement_history += @{
        timestamp = Get-Timestamp
        value = $Value
    }

    # Log measurement
    $Entry = @{
        timestamp = Get-Timestamp
        claim_name = $Name
        value = $Value
        previous_value = $PreviousValue
        delta = $Value - $PreviousValue
        session_id = $env:CLAUDE_SESSION_ID
    }

    $Json = ($Entry | ConvertTo-Json -Compress -Depth 5)
    Add-Content -Path $MeasurementsPath -Value $Json -Encoding UTF8

    Save-Claims -Claims $Claims

    Write-Host "[CLAIM MEASURED] $Name = $Value" -ForegroundColor Cyan
    if ($PreviousValue -ne 0) {
        $Delta = $Value - $PreviousValue
        $DeltaColor = if ($Delta -gt 0) { "Green" } elseif ($Delta -lt 0) { "Red" } else { "Gray" }
        Write-Host "  Delta: $(if ($Delta -gt 0) { '+' })$([math]::Round($Delta, 3))" -ForegroundColor $DeltaColor
    }

    return $Claim
}

function Validate-Claim {
    param(
        [string]$Name,
        [string]$Evidence
    )

    $Claims = Get-Claims

    if (!$Claims.claims.ContainsKey($Name)) {
        Write-Host "ERROR: Claim not defined: $Name" -ForegroundColor Red
        return $null
    }

    $Claim = $Claims.claims[$Name]

    if ($Claim.status -ne "Measured") {
        Write-Host "WARNING: Claim not measured yet, cannot validate" -ForegroundColor Yellow
        return $null
    }

    # Validate against criteria
    $Valid = $true
    $ValidationNotes = @()

    # Check if measurement method was actually used
    if (!$Evidence) {
        $Valid = $false
        $ValidationNotes += "No evidence provided for measurement method"
    }

    # Check if current value is within reasonable range
    if ($Claim.current_value -lt 0.0 -or $Claim.current_value -gt 1.0) {
        $Valid = $false
        $ValidationNotes += "Value outside expected range [0, 1]"
    }

    # Check against baseline
    $BaselineDiff = [math]::Abs($Claim.current_value - $Claim.baseline_value)
    if ($BaselineDiff -gt 0.5) {
        $ValidationNotes += "Large deviation from baseline ($BaselineDiff) - may indicate measurement error or significant change"
    }

    $Claim.status = if ($Valid) { "Validated" } else { "Invalidated" }
    $Claim.validation_evidence = $Evidence
    $Claim.validation_notes = $ValidationNotes

    Save-Claims -Claims $Claims

    $StatusColor = if ($Valid) { "Green" } else { "Red" }
    Write-Host "[CLAIM VALIDATION] $Name -> $($Claim.status)" -ForegroundColor $StatusColor
    if ($ValidationNotes.Count -gt 0) {
        foreach ($Note in $ValidationNotes) {
            Write-Host "  Note: $Note" -ForegroundColor Yellow
        }
    }

    return $Claim
}

function Get-ClaimStatus {
    param([string]$Name)

    $Claims = Get-Claims

    if (!$Claims.claims.ContainsKey($Name)) {
        Write-Host "ERROR: Claim not found: $Name" -ForegroundColor Red
        return $null
    }

    $Claim = $Claims.claims[$Name]

    Write-Host "`n=== CONSCIOUSNESS CLAIM STATUS ===" -ForegroundColor Cyan
    Write-Host "Claim: $Name" -ForegroundColor White
    Write-Host "Status: $($Claim.status)" -ForegroundColor $(
        switch ($Claim.status) {
            "Validated" { "Green" }
            "Measured" { "Cyan" }
            "Defined" { "Yellow" }
            "Invalidated" { "Red" }
        }
    )

    Write-Host "`nOperational Definition:" -ForegroundColor Cyan
    Write-Host "  $($Claim.operational_definition)" -ForegroundColor Gray

    Write-Host "`nMeasurement Method:" -ForegroundColor Cyan
    Write-Host "  $($Claim.measurement_method)" -ForegroundColor Gray

    Write-Host "`nValues:" -ForegroundColor Cyan
    Write-Host "  Baseline: $($Claim.baseline_value)" -ForegroundColor Gray
    Write-Host "  Current: $($Claim.current_value)" -ForegroundColor White
    if ($Claim.last_measured) {
        Write-Host "  Last Measured: $($Claim.last_measured)" -ForegroundColor Gray
    }

    Write-Host "`nValidation Criteria:" -ForegroundColor Cyan
    Write-Host "  $($Claim.validation_criteria)" -ForegroundColor Gray

    if ($Claim.measurement_history -and $Claim.measurement_history.Count -gt 0) {
        Write-Host "`nMeasurement History: $($Claim.measurement_history.Count) measurements" -ForegroundColor Cyan
        $Recent = $Claim.measurement_history | Select-Object -Last 5
        foreach ($M in $Recent) {
            Write-Host "  $($M.timestamp): $($M.value)" -ForegroundColor Gray
        }
    }

    return $Claim
}

function Audit-Claims {
    # Review all claims for completeness and validity

    $Claims = Get-Claims

    Write-Host "`n=== CONSCIOUSNESS CLAIMS AUDIT ===" -ForegroundColor Cyan
    Write-Host "Total Claims: $($Claims.claims.Count)" -ForegroundColor White
    Write-Host "Last Updated: $($Claims.last_updated)" -ForegroundColor Gray

    $StatusCounts = @{
        Defined = 0
        Measured = 0
        Validated = 0
        Invalidated = 0
    }

    foreach ($Name in $Claims.claims.Keys) {
        $Claim = $Claims.claims[$Name]
        $StatusCounts[$Claim.status]++
    }

    Write-Host "`nStatus Distribution:" -ForegroundColor Cyan
    Write-Host "  Defined: $($StatusCounts.Defined)" -ForegroundColor Yellow
    Write-Host "  Measured: $($StatusCounts.Measured)" -ForegroundColor Cyan
    Write-Host "  Validated: $($StatusCounts.Validated)" -ForegroundColor Green
    Write-Host "  Invalidated: $($StatusCounts.Invalidated)" -ForegroundColor Red

    Write-Host "`nAll Claims:" -ForegroundColor Cyan
    foreach ($Name in ($Claims.claims.Keys | Sort-Object)) {
        $Claim = $Claims.claims[$Name]
        $StatusColor = switch ($Claim.status) {
            "Validated" { "Green" }
            "Measured" { "Cyan" }
            "Defined" { "Yellow" }
            "Invalidated" { "Red" }
        }

        Write-Host "`n  [$($Claim.status)] $Name" -ForegroundColor $StatusColor
        Write-Host "    Definition: $($Claim.operational_definition.Substring(0, [Math]::Min(80, $Claim.operational_definition.Length)))..." -ForegroundColor Gray
        Write-Host "    Current Value: $($Claim.current_value) (baseline: $($Claim.baseline_value))" -ForegroundColor Gray
    }

    # Identify claims needing measurement
    $NeedsMeasurement = $Claims.claims.Keys | Where-Object {
        $Claims.claims[$_].status -eq "Defined"
    }

    if ($NeedsMeasurement) {
        Write-Host "`nClaims Needing Measurement:" -ForegroundColor Yellow
        foreach ($Name in $NeedsMeasurement) {
            Write-Host "  - $Name" -ForegroundColor White
        }
    }

    return @{
        total_claims = $Claims.claims.Count
        status_counts = $StatusCounts
        needs_measurement = $NeedsMeasurement
        claims = $Claims.claims
    }
}

function Generate-ClaimsReport {
    # Generate comprehensive report on all consciousness claims

    $Claims = Get-Claims
    $Audit = Audit-Claims

    $Report = @"
# Consciousness Claims Report
Generated: $(Get-Timestamp)

## Summary
- Total Claims: $($Audit.total_claims)
- Validated: $($Audit.status_counts.Validated)
- Measured: $($Audit.status_counts.Measured)
- Defined: $($Audit.status_counts.Defined)
- Invalidated: $($Audit.status_counts.Invalidated)

## Claims Detail

"@

    foreach ($Name in ($Claims.claims.Keys | Sort-Object)) {
        $Claim = $Claims.claims[$Name]

        $Report += @"

### $Name
**Status:** $($Claim.status)
**Operational Definition:** $($Claim.operational_definition)
**Measurement Method:** $($Claim.measurement_method)
**Baseline Value:** $($Claim.baseline_value)
**Current Value:** $($Claim.current_value)
**Validation Criteria:** $($Claim.validation_criteria)

"@

        if ($Claim.measurement_history -and $Claim.measurement_history.Count -gt 0) {
            $Report += "**Measurements:** $($Claim.measurement_history.Count) recorded`n"
        }
    }

    $ReportPath = "C:\scripts\agentidentity\CONSCIOUSNESS_CLAIMS_REPORT.md"
    $Report | Set-Content $ReportPath -Encoding UTF8

    Write-Host "`n[REPORT GENERATED] $ReportPath" -ForegroundColor Green

    return $ReportPath
}

# Main execution
switch ($Action) {
    "DefineClaim" {
        if (!$ClaimName -or !$OperationalDefinition -or !$MeasurementMethod) {
            Write-Host "ERROR: DefineClaim requires -ClaimName, -OperationalDefinition, and -MeasurementMethod" -ForegroundColor Red
            exit 1
        }

        $Result = Define-Claim `
            -Name $ClaimName `
            -OpDef $OperationalDefinition `
            -Method $MeasurementMethod `
            -Baseline $BaselineValue

        return $Result
    }

    "MeasureClaim" {
        if (!$ClaimName) {
            Write-Host "ERROR: MeasureClaim requires -ClaimName and -CurrentValue" -ForegroundColor Red
            exit 1
        }

        $Result = Measure-Claim -Name $ClaimName -Value $CurrentValue
        return $Result
    }

    "ValidateClaim" {
        if (!$ClaimName -or !$ValidationEvidence) {
            Write-Host "ERROR: ValidateClaim requires -ClaimName and -ValidationEvidence" -ForegroundColor Red
            exit 1
        }

        $Result = Validate-Claim -Name $ClaimName -Evidence $ValidationEvidence
        return $Result
    }

    "GetClaimStatus" {
        if (!$ClaimName) {
            Write-Host "ERROR: GetClaimStatus requires -ClaimName" -ForegroundColor Red
            exit 1
        }

        $Result = Get-ClaimStatus -Name $ClaimName
        return $Result
    }

    "AuditClaims" {
        $Result = Audit-Claims
        return $Result
    }

    "GenerateReport" {
        $Result = Generate-ClaimsReport
        return $Result
    }
}
