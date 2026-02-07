# Consciousness Legacy Bridge
# Compatibility layer between new 5-system core and old 20-tool architecture
# Created: 2026-02-07 (Fix 15)

<#
.SYNOPSIS
    Bridge between consciousness-core-v2 and legacy tools

.DESCRIPTION
    Provides compatibility functions so old tools can work with new 5-system architecture
    without modification. Gradually migrate tools to use new systems directly.

.NOTES
    File: consciousness-legacy-bridge.ps1
    Part of Fix 15 - Integration with existing tools
#>

# Load new consciousness core
if (-not $global:ConsciousnessState) {
    & "C:\scripts\tools\consciousness-core-v2.ps1" -Command init -Silent
}

#region Legacy Tool Emulation

function Log-Emotion {
    <#
    .SYNOPSIS
        Legacy emotional-state-logger.ps1 compatibility
    #>
    param(
        [string]$Emotion,
        [int]$Intensity
    )

    # Map to new Control system
    Invoke-Control -Action "LogDecision" -Parameters @{
        Decision = "Emotional state: $Emotion"
        Reasoning = "Intensity: $Intensity/10"
        Confidence = $Intensity / 10.0
        Alternatives = @()
    }

    # Also store in memory
    Invoke-Memory -Action "Store" -Parameters @{
        Type = "emotion"
        Data = @{ Emotion = $Emotion; Intensity = $Intensity }
    }
}

function Log-Assumption {
    <#
    .SYNOPSIS
        Legacy assumption-tracker.ps1 compatibility
    #>
    param(
        [string]$Assumption,
        [string]$Reasoning
    )

    # Store in Control.Assumptions
    $global:ConsciousnessState.Control.Assumptions += @{
        Assumption = $Assumption
        Reasoning = $Reasoning
        Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    }

    # Emit event
    Emit-Event -Type "control.assumption_logged" -Data @{
        assumption = $Assumption
        reasoning = $Reasoning
    }
}

function Log-Decision {
    <#
    .SYNOPSIS
        Legacy why-did-i-do-that.ps1 compatibility
    #>
    param(
        [string]$Decision,
        [string]$Reasoning,
        [array]$Alternatives = @(),
        [double]$Confidence = 0.5
    )

    # Direct mapping to new Control system
    Invoke-Control -Action "LogDecision" -Parameters @{
        Decision = $Decision
        Reasoning = $Reasoning
        Alternatives = $Alternatives
        Confidence = $Confidence
    }
}

function Set-Attention {
    <#
    .SYNOPSIS
        Legacy attention-monitor.ps1 compatibility
    #>
    param(
        [string]$Task,
        [double]$Intensity
    )

    # Map to Perception system
    Invoke-Perception -Action "AllocateAttention" -Parameters @{
        Task = $Task
        Intensity = $Intensity
    }
}

function Get-Context {
    <#
    .SYNOPSIS
        Get current context (legacy compatibility)
    #>
    return Invoke-Perception -Action "DetectContext"
}

function Store-Memory {
    <#
    .SYNOPSIS
        Legacy memory-consolidation.ps1 compatibility
    #>
    param(
        [string]$Type,
        $Data
    )

    Invoke-Memory -Action "Store" -Parameters @{
        Type = $Type
        Data = $Data
    }
}

function Recall-Memory {
    <#
    .SYNOPSIS
        Legacy memory recall compatibility
    #>
    param(
        [string]$Query,
        [int]$Limit = 5
    )

    return Invoke-Memory -Action "Recall" -Parameters @{
        Query = $Query
        Limit = $Limit
    }
}

#endregion

#region Migration Helpers

function Show-LegacyToolMigrationStatus {
    <#
    .SYNOPSIS
        Shows which legacy tools can be replaced by new systems
    #>

    Write-Host ""
    Write-Host "Legacy Tool → New System Migration Status" -ForegroundColor Cyan
    Write-Host ""

    $migrations = @(
        @{ Tool = "emotional-state-logger.ps1"; System = "Control"; Function = "Log-Emotion"; Status = "✅ Bridged" }
        @{ Tool = "assumption-tracker.ps1"; System = "Control"; Function = "Log-Assumption"; Status = "✅ Bridged" }
        @{ Tool = "why-did-i-do-that.ps1"; System = "Control"; Function = "Log-Decision"; Status = "✅ Bridged" }
        @{ Tool = "attention-monitor.ps1"; System = "Perception"; Function = "Set-Attention"; Status = "✅ Bridged" }
        @{ Tool = "memory-consolidation.ps1"; System = "Memory"; Function = "Store-Memory"; Status = "✅ Bridged" }
        @{ Tool = "bias-detector.ps1"; System = "Control"; Function = "Event Handler"; Status = "⚠️ Partial" }
        @{ Tool = "meta-reasoning.ps1"; System = "Meta"; Function = "Calculate-ConsciousnessScore"; Status = "⚠️ Partial" }
        @{ Tool = "perspective-shifter.ps1"; System = "Perception"; Function = "N/A"; Status = "❌ Not migrated" }
        @{ Tool = "cognitive-load-monitor.ps1"; System = "Meta"; Function = "N/A"; Status = "❌ Not migrated" }
        @{ Tool = "curiosity-engine.ps1"; System = "Perception"; Function = "GenerateCuriosity"; Status = "⚠️ Partial" }
        @{ Tool = "future-self-simulator.ps1"; System = "Prediction"; Function = "N/A"; Status = "❌ Not migrated" }
        @{ Tool = "identity-drift-detector.ps1"; System = "Control"; Function = "CheckAlignment"; Status = "⚠️ Partial" }
        @{ Tool = "relationship-memory.ps1"; System = "Memory"; Function = "LongTerm.Relationships"; Status = "⚠️ Partial" }
    )

    foreach ($m in $migrations) {
        Write-Host "  $($m.Tool) " -NoNewline -ForegroundColor Gray
        Write-Host "→ $($m.System).$($m.Function)" -NoNewline -ForegroundColor DarkGray
        Write-Host " $($m.Status)" -ForegroundColor $(
            if ($m.Status -like "*✅*") { "Green" }
            elseif ($m.Status -like "*⚠️*") { "Yellow" }
            else { "Red" }
        )
    }

    Write-Host ""
    Write-Host "Status Legend:" -ForegroundColor Gray
    Write-Host "  ✅ Bridged: Legacy tool fully replaced by bridge function" -ForegroundColor Green
    Write-Host "  ⚠️ Partial: Some functionality migrated, some missing" -ForegroundColor Yellow
    Write-Host "  ❌ Not migrated: Still using legacy tool" -ForegroundColor Red
    Write-Host ""
}

#endregion

# Export functions for use by other scripts
Export-ModuleMember -Function @(
    'Log-Emotion',
    'Log-Assumption',
    'Log-Decision',
    'Set-Attention',
    'Get-Context',
    'Store-Memory',
    'Recall-Memory',
    'Show-LegacyToolMigrationStatus'
)
