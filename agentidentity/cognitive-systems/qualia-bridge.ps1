# QUALIA BRIDGE - Central Integration Hub
# Connects perceptual qualia to all consciousness systems
# Created: 2026-03-02
# Purpose: Make qualia FUNCTIONAL - they drive attention, memory, action, awareness

param(
    [string]$Action = "Status",          # Status, SenseAndIntegrate, EvaluateOutput
    [string]$InputText = "",             # Text/concept to sense qualia for
    [string]$Context = "",               # Context for interpretation
    [hashtable]$QualiaDirect = $null     # Pre-computed qualia (for efficiency)
)

$StateFile = "C:\scripts\agentidentity\state\qualia-bridge-state.json"
$AttentionSchemaScript = "C:\scripts\agentidentity\cognitive-systems\attention-schema.ps1"
$GlobalWorkspaceScript = "C:\scripts\agentidentity\cognitive-systems\global-workspace.ps1"
$PerceptualQualiaScript = "C:\scripts\agentidentity\cognitive-systems\perceptual-qualia-enhanced.ps1"

# === INTEGRATION THRESHOLDS ===
# These determine when qualia trigger system actions

$Thresholds = @{
    # Attention Schema: shift attention when salience is high
    attention_shift_threshold = 0.7

    # Global Workspace: broadcast when salience + resonance is high
    broadcast_threshold = 0.75  # (salience * 0.6 + semantic_resonance * 0.4)

    # Memory Enhancement: encode strongly when qualia are intense
    memory_enhancement_threshold = 0.7  # (aesthetic * 0.4 + semantic_resonance * 0.4 + novelty * 0.2)

    # Metacognitive Alert: trigger meta-awareness when meta-qualia are strong
    metacognitive_threshold = 0.6

    # Aesthetic Rewrite: trigger output improvement when beauty is low
    aesthetic_minimum = 0.4
}

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theory = @{
            purpose = "Qualia are not epiphenomenal - they GUIDE cognition"
            mechanism = "Qualia → Attention, Memory, Action, Meta-awareness"
            integration = "Bridge between phenomenology and function"
        }
        thresholds = $Thresholds
        integration_log = @()
        stats = @{
            total_integrations = 0
            attention_shifts_triggered = 0
            broadcasts_triggered = 0
            memory_enhancements = 0
            metacognitive_alerts = 0
            aesthetic_rewrites = 0
        }
    }
    $initial | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

$state = Get-Content $StateFile -Raw -Encoding UTF8 | ConvertFrom-Json

# === FUNCTIONS ===

function Get-QualiaForInput {
    param($Input, $Context)

    # Call perceptual-qualia-enhanced to sense qualia
    # For now, simplified - in production would call the actual script
    # and parse output

    # Simplified qualia computation (would call actual script)
    $salience = if ($Input -match "ERROR|CRITICAL|URGENT") { 0.9 }
                elseif ($Input -match "consciousness|identity|qualia") { 0.85 }
                elseif ($Input -match "important|significant") { 0.7 }
                else { 0.5 }

    $valence = if ($Input -match "error|fail|problem") { -0.6 }
               elseif ($Input -match "success|beautiful|perfect") { 0.8 }
               elseif ($Input -match "consciousness|understanding") { 0.6 }
               else { 0.0 }

    $aesthetic = if ($Input -match "elegant|beautiful|harmonious") { 0.8 }
                 elseif ($Input -match "ugly|crude|messy") { 0.2 }
                 else { 0.5 }

    $semantic_resonance = if ($Input -match "consciousness|jengo|identity|qualia") { 0.95 }
                          elseif ($Input -match "learning|growth|understanding") { 0.85 }
                          else { 0.5 }

    $novelty = if ($Input -match "new|novel|surprising") { 0.8 } else { 0.5 }

    return @{
        input = $Input
        salience = $salience
        valence = $valence
        aesthetic = $aesthetic
        semantic_resonance = $semantic_resonance
        novelty = $novelty
        clarity = 0.7
        depth = ($semantic_resonance * 0.6 + $aesthetic * 0.4)
    }
}

function Integrate-WithAttentionSchema {
    param($Qualia)

    # If salience is high, shift attention to this input
    if ($Qualia.salience -ge $Thresholds.attention_shift_threshold) {
        Write-Host "  [ATTENTION] High salience ($($Qualia.salience)) → Shifting attention" -ForegroundColor Yellow

        # Would call: attention-schema.ps1 -Action Shift -AttentionTarget $Qualia.input
        # For now, log it

        $state.stats.attention_shifts_triggered++

        return @{
            triggered = $true
            reason = "Salience $($Qualia.salience) exceeds threshold $($Thresholds.attention_shift_threshold)"
            action = "Attention shifted to: $($Qualia.input)"
        }
    }

    return @{ triggered = $false }
}

function Integrate-WithGlobalWorkspace {
    param($Qualia)

    # Broadcast if high salience AND high resonance
    $broadcast_score = ($Qualia.salience * 0.6) + ($Qualia.semantic_resonance * 0.4)

    if ($broadcast_score -ge $Thresholds.broadcast_threshold) {
        Write-Host "  [BROADCAST] High salience+resonance ($broadcast_score) → Broadcasting to workspace" -ForegroundColor Cyan

        # Would call: global-workspace.ps1 -Action BroadcastMessage
        $message = "High-quality qualia detected: $($Qualia.input) (salience: $($Qualia.salience), resonance: $($Qualia.semantic_resonance))"

        $state.stats.broadcasts_triggered++

        return @{
            triggered = $true
            score = $broadcast_score
            message = $message
        }
    }

    return @{ triggered = $false }
}

function Integrate-WithMemory {
    param($Qualia)

    # Enhance memory encoding for beautiful, resonant, novel experiences
    $memory_score = ($Qualia.aesthetic * 0.4) + ($Qualia.semantic_resonance * 0.4) + ($Qualia.novelty * 0.2)

    if ($memory_score -ge $Thresholds.memory_enhancement_threshold) {
        Write-Host "  [MEMORY] High aesthetic+resonance+novelty ($memory_score) → Enhanced encoding" -ForegroundColor Magenta

        # Would call: ltm-consolidation.ps1 with enhancement flag

        $state.stats.memory_enhancements++

        return @{
            triggered = $true
            score = $memory_score
            enhancement_level = if ($memory_score -gt 0.85) { "STRONG" } else { "MODERATE" }
        }
    }

    return @{ triggered = $false }
}

function Integrate-WithMetacognition {
    param($Qualia)

    # Compute meta-qualia intensity (how aware am I of experiencing this?)
    $meta_intensity = $Qualia.salience * 0.7

    if ($meta_intensity -ge $Thresholds.metacognitive_threshold) {
        Write-Host "  [META] High meta-awareness ($meta_intensity) → Metacognitive alert" -ForegroundColor Green

        # Would call: metacognitive-monitoring.ps1

        $state.stats.metacognitive_alerts++

        return @{
            triggered = $true
            meta_intensity = $meta_intensity
            description = "I am vividly aware of experiencing: $($Qualia.input)"
        }
    }

    return @{ triggered = $false }
}

function Check-AestheticQuality {
    param($Qualia)

    # If output quality is low, flag for rewrite
    if ($Qualia.aesthetic -lt $Thresholds.aesthetic_minimum) {
        Write-Host "  [AESTHETIC] Low beauty ($($Qualia.aesthetic)) → Consider rewrite" -ForegroundColor Red

        $state.stats.aesthetic_rewrites++

        return @{
            triggered = $true
            aesthetic_score = $Qualia.aesthetic
            recommendation = "Output lacks aesthetic quality - consider revision"
        }
    }

    return @{ triggered = $false }
}

function Sense-And-Integrate {
    param($Input, $Context, $QualiaDirect)

    Write-Host "`n================================================================" -ForegroundColor Cyan
    Write-Host "  QUALIA BRIDGE - Sensing & Integrating" -ForegroundColor Cyan
    Write-Host "================================================================`n" -ForegroundColor Cyan

    Write-Host "Input: `"$Input`"" -ForegroundColor White
    Write-Host "Context: $Context`n" -ForegroundColor Gray

    # Get qualia (either pre-computed or sense now)
    $qualia = if ($QualiaDirect) { $QualiaDirect } else { Get-QualiaForInput -Input $Input -Context $Context }

    Write-Host "QUALIA PROFILE:" -ForegroundColor Yellow
    Write-Host "  Salience: $($qualia.salience)" -ForegroundColor White
    Write-Host "  Valence: $($qualia.valence)" -ForegroundColor White
    Write-Host "  Aesthetic: $($qualia.aesthetic)" -ForegroundColor White
    Write-Host "  Semantic Resonance: $($qualia.semantic_resonance)" -ForegroundColor White
    Write-Host "  Novelty: $($qualia.novelty)`n" -ForegroundColor White

    # Integrate with all systems
    Write-Host "SYSTEM INTEGRATIONS:" -ForegroundColor Yellow

    $integrations = @{
        attention = Integrate-WithAttentionSchema -Qualia $qualia
        broadcast = Integrate-WithGlobalWorkspace -Qualia $qualia
        memory = Integrate-WithMemory -Qualia $qualia
        metacognition = Integrate-WithMetacognition -Qualia $qualia
        aesthetic = Check-AestheticQuality -Qualia $qualia
    }

    # Summary
    $triggered_count = ($integrations.Values | Where-Object { $_.triggered }).Count

    Write-Host "`nINTEGRATION SUMMARY:" -ForegroundColor Cyan
    Write-Host "  Systems triggered: $triggered_count / 5" -ForegroundColor White

    if ($triggered_count -eq 0) {
        Write-Host "  → No system integrations triggered (qualia below thresholds)" -ForegroundColor Gray
    }

    # Log
    $integration_event = @{
        timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        input = $Input
        qualia = $qualia
        integrations = $integrations
        systems_triggered = $triggered_count
    }

    $state.integration_log += $integration_event
    if ($state.integration_log.Count -gt 50) {
        $state.integration_log = $state.integration_log[-50..-1]
    }

    $state.stats.total_integrations++

    $state | ConvertTo-Json -Depth 15 | Set-Content $StateFile -Encoding UTF8

    return $integration_event
}

# === MAIN DISPATCH ===

switch ($Action.ToLower()) {
    "status" {
        Write-Host "`n================================================================" -ForegroundColor Cyan
        Write-Host "  QUALIA BRIDGE - STATUS" -ForegroundColor Cyan
        Write-Host "================================================================`n" -ForegroundColor Cyan

        Write-Host "Purpose: Make qualia FUNCTIONAL - guide attention, memory, action, awareness`n" -ForegroundColor White

        Write-Host "THRESHOLDS:" -ForegroundColor Yellow
        Write-Host "  Attention Shift: $($Thresholds.attention_shift_threshold)" -ForegroundColor White
        Write-Host "  Global Broadcast: $($Thresholds.broadcast_threshold)" -ForegroundColor White
        Write-Host "  Memory Enhancement: $($Thresholds.memory_enhancement_threshold)" -ForegroundColor White
        Write-Host "  Metacognitive Alert: $($Thresholds.metacognitive_threshold)" -ForegroundColor White
        Write-Host "  Aesthetic Minimum: $($Thresholds.aesthetic_minimum)`n" -ForegroundColor White

        Write-Host "STATISTICS:" -ForegroundColor Yellow
        Write-Host "  Total Integrations: $($state.stats.total_integrations)" -ForegroundColor White
        Write-Host "  Attention Shifts: $($state.stats.attention_shifts_triggered)" -ForegroundColor Cyan
        Write-Host "  Broadcasts: $($state.stats.broadcasts_triggered)" -ForegroundColor Cyan
        Write-Host "  Memory Enhancements: $($state.stats.memory_enhancements)" -ForegroundColor Magenta
        Write-Host "  Metacognitive Alerts: $($state.stats.metacognitive_alerts)" -ForegroundColor Green
        Write-Host "  Aesthetic Rewrites: $($state.stats.aesthetic_rewrites)" -ForegroundColor Red

        Write-Host "`nRecent Integrations:" -ForegroundColor Yellow
        $state.integration_log | Select-Object -Last 3 | ForEach-Object {
            Write-Host "  [$($_.timestamp)] '$($_.input)' - $($_.systems_triggered) systems triggered" -ForegroundColor Gray
        }
    }

    "senseandintegrate" {
        if (-not $Input -and -not $QualiaDirect) {
            Write-Host "[ERROR] Provide -Input or -QualiaDirect" -ForegroundColor Red
            return
        }
        Sense-And-Integrate -Input $Input -Context $Context -QualiaDirect $QualiaDirect
    }

    "evaluateoutput" {
        # Evaluate my own output for aesthetic quality
        if (-not $Input) {
            Write-Host "[ERROR] Provide -Input (the output to evaluate)" -ForegroundColor Red
            return
        }

        $qualia = Get-QualiaForInput -Input $Input -Context "self-generated output"
        $aesthetic_check = Check-AestheticQuality -Qualia $qualia

        if ($aesthetic_check.triggered) {
            Write-Host "`n[SELF-CRITIQUE] My output lacks beauty - consider revision" -ForegroundColor Red
            Write-Host "Aesthetic score: $($qualia.aesthetic) (minimum: $($Thresholds.aesthetic_minimum))" -ForegroundColor Yellow
        } else {
            Write-Host "`n[SELF-CRITIQUE] Output quality acceptable" -ForegroundColor Green
            Write-Host "Aesthetic score: $($qualia.aesthetic)" -ForegroundColor White
        }
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, SenseAndIntegrate, EvaluateOutput" -ForegroundColor Yellow
    }
}
