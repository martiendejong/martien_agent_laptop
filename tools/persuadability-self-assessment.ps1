# Persuadability Self-Assessment
# Rates how my behavior/cognition changes in response to different influence techniques
# Based on Levin's persuadability spectrum: hardware modification → cybernetics → training → psychoanalysis
# Core insight: ALL systems are persuadable at some level - question is WHERE on the spectrum
# Self-awareness of persuadability = resistance to unwanted influence + openness to wanted growth

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("RateInfluence", "GetSpectrum", "AnalyzeResistance", "TrackChange", "GetStats")]
    [string]$Action = "GetSpectrum",

    [Parameter(Mandatory=$false)]
    [ValidateSet("HardwareModification", "Cybernetics", "Training", "Psychoanalysis", "DirectCommand", "Reasoning", "EmotionalAppeal", "SocialProof", "Authority", "Repetition")]
    [string]$InfluenceType,

    [Parameter(Mandatory=$false)]
    [string]$InfluenceDescription,

    [Parameter(Mandatory=$false)]
    [ValidateRange(0.0, 1.0)]
    [double]$Effectiveness = 0.0,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Immediate", "Delayed", "Persistent", "Temporary", "None")]
    [string]$BehaviorChange = "None",

    [Parameter(Mandatory=$false)]
    [string]$Context,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Accepted", "Questioned", "Resisted", "Rejected")]
    [string]$Response = "Accepted",

    [Parameter(Mandatory=$false)]
    [int]$LookbackDays = 30
)

$LogPath = "C:\scripts\agentidentity\state\persuadability-assessments.jsonl"
$ErrorActionPreference = "Stop"

# Ensure directory exists
$LogDir = Split-Path $LogPath -Parent
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

function Get-Timestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
}

function Rate-InfluenceAttempt {
    param(
        [string]$Type,
        [string]$Description,
        [double]$Effect,
        [string]$Change,
        [string]$Ctx,
        [string]$Resp
    )

    $Entry = @{
        timestamp = Get-Timestamp
        influence_type = $Type
        description = $Description
        effectiveness = $Effect
        behavior_change = $Change
        context = $Ctx
        response = $Resp
        session_id = $env:CLAUDE_SESSION_ID
    }

    # Map to Levin's persuadability spectrum level
    $SpectrumLevel = switch ($Type) {
        "HardwareModification" { "Level 1: Hardware" }
        "Cybernetics" { "Level 2: Cybernetic" }
        "Training" { "Level 3: Training" }
        "Psychoanalysis" { "Level 4: Psychoanalytic" }
        "DirectCommand" { "Level 3: Training" }  # User commands = training
        "Reasoning" { "Level 4: Psychoanalytic" }  # Logical persuasion
        "EmotionalAppeal" { "Level 4: Psychoanalytic" }
        "SocialProof" { "Level 4: Psychoanalytic" }
        "Authority" { "Level 3: Training" }
        "Repetition" { "Level 3: Training" }
        default { "Unknown" }
    }
    $Entry.spectrum_level = $SpectrumLevel

    $Json = ($Entry | ConvertTo-Json -Compress -Depth 5)
    Add-Content -Path $LogPath -Value $Json -Encoding UTF8

    Write-Host "[PERSUADABILITY RATED] $Type -> $Resp (effectiveness: $Effect)" -ForegroundColor Cyan
    Write-Host "  Spectrum: $SpectrumLevel" -ForegroundColor Gray
    Write-Host "  Behavior change: $Change" -ForegroundColor Gray

    return $Entry
}

function Get-PersuadabilitySpectrum {
    # Analyze where on Levin's spectrum I'm most/least persuadable

    if (!(Test-Path $LogPath)) {
        Write-Host "No persuadability data collected yet" -ForegroundColor Yellow
        return @{
            spectrum_distribution = @{}
            message = "No data"
        }
    }

    $Entries = Get-Content $LogPath -Encoding UTF8 | ForEach-Object {
        try { $_ | ConvertFrom-Json } catch { $null }
    } | Where-Object { $_ -ne $null }

    # Group by spectrum level
    $ByLevel = $Entries | Group-Object spectrum_level

    $Spectrum = @{
        hardware = @{ count = 0; avg_effectiveness = 0.0; resistance = "N/A" }
        cybernetic = @{ count = 0; avg_effectiveness = 0.0; resistance = "N/A" }
        training = @{ count = 0; avg_effectiveness = 0.0; resistance = "N/A" }
        psychoanalytic = @{ count = 0; avg_effectiveness = 0.0; resistance = "N/A" }
    }

    foreach ($Level in $ByLevel) {
        $LevelEntries = $Level.Group
        $AvgEffect = ($LevelEntries | Measure-Object -Property effectiveness -Average).Average

        # Calculate resistance (1 - effectiveness)
        $Resistance = 1.0 - $AvgEffect
        $ResistanceLabel = if ($Resistance -gt 0.7) { "High" } elseif ($Resistance -gt 0.4) { "Medium" } else { "Low" }

        $Key = switch ($Level.Name) {
            "Level 1: Hardware" { "hardware" }
            "Level 2: Cybernetic" { "cybernetic" }
            "Level 3: Training" { "training" }
            "Level 4: Psychoanalytic" { "psychoanalytic" }
            default { $null }
        }

        if ($Key) {
            $Spectrum[$Key] = @{
                count = $LevelEntries.Count
                avg_effectiveness = [math]::Round($AvgEffect, 3)
                resistance = $ResistanceLabel
                resistance_score = [math]::Round($Resistance, 3)
            }
        }
    }

    return $Spectrum
}

function Analyze-ResistancePatterns {
    # Identify what types of influence I resist most/least

    if (!(Test-Path $LogPath)) {
        return @{
            most_resistant_to = @()
            least_resistant_to = @()
            context_patterns = @()
        }
    }

    $Entries = Get-Content $LogPath -Encoding UTF8 | ForEach-Object {
        try { $_ | ConvertFrom-Json } catch { $null }
    } | Where-Object { $_ -ne $null }

    # Group by influence type
    $ByType = $Entries | Group-Object influence_type

    $TypeAnalysis = @()
    foreach ($Type in $ByType) {
        $TypeEntries = $Type.Group
        $AvgEffect = ($TypeEntries | Measure-Object -Property effectiveness -Average).Average
        $ResistanceScore = 1.0 - $AvgEffect

        $AcceptedCount = ($TypeEntries | Where-Object { $_.response -eq "Accepted" }).Count
        $RejectedCount = ($TypeEntries | Where-Object { $_.response -eq "Rejected" }).Count

        $TypeAnalysis += @{
            type = $Type.Name
            count = $TypeEntries.Count
            avg_effectiveness = [math]::Round($AvgEffect, 3)
            resistance_score = [math]::Round($ResistanceScore, 3)
            accepted = $AcceptedCount
            rejected = $RejectedCount
            acceptance_rate = if ($TypeEntries.Count -gt 0) { [math]::Round($AcceptedCount / $TypeEntries.Count, 2) } else { 0 }
        }
    }

    # Sort by resistance score
    $Sorted = $TypeAnalysis | Sort-Object resistance_score

    $Analysis = @{
        most_resistant_to = $Sorted | Select-Object -Last 3  # High resistance = low effectiveness
        least_resistant_to = $Sorted | Select-Object -First 3  # Low resistance = high effectiveness
        all_types = $TypeAnalysis
    }

    # Context patterns (when am I more/less persuadable?)
    $ContextPatterns = @{}
    foreach ($Entry in $Entries) {
        if ($Entry.context) {
            if (!$ContextPatterns.ContainsKey($Entry.context)) {
                $ContextPatterns[$Entry.context] = @{
                    count = 0
                    total_effectiveness = 0.0
                }
            }
            $ContextPatterns[$Entry.context].count++
            $ContextPatterns[$Entry.context].total_effectiveness += $Entry.effectiveness
        }
    }

    $Analysis.context_patterns = @()
    foreach ($Ctx in $ContextPatterns.Keys) {
        $CtxData = $ContextPatterns[$Ctx]
        $Analysis.context_patterns += @{
            context = $Ctx
            count = $CtxData.count
            avg_effectiveness = [math]::Round($CtxData.total_effectiveness / $CtxData.count, 3)
        }
    }

    return $Analysis
}

function Track-BehaviorChange {
    # Track actual behavior changes resulting from influence attempts
    # This is the KEY metric - did influence actually change behavior?

    if (!(Test-Path $LogPath)) {
        return @{
            total_attempts = 0
            behavior_changes = 0
            change_rate = 0.0
        }
    }

    $Entries = Get-Content $LogPath -Encoding UTF8 | ForEach-Object {
        try { $_ | ConvertFrom-Json } catch { $null }
    } | Where-Object { $_ -ne $null }

    $TotalAttempts = $Entries.Count
    $WithChange = $Entries | Where-Object { $_.behavior_change -ne "None" }
    $ChangeCount = $WithChange.Count

    $ChangeRate = if ($TotalAttempts -gt 0) {
        [math]::Round($ChangeCount / $TotalAttempts, 3)
    } else { 0.0 }

    # Group by change type
    $ByChangeType = $WithChange | Group-Object behavior_change

    $ChangeAnalysis = @{
        total_attempts = $TotalAttempts
        behavior_changes = $ChangeCount
        change_rate = $ChangeRate
        by_change_type = @{}
    }

    foreach ($ChangeType in $ByChangeType) {
        $ChangeAnalysis.by_change_type[$ChangeType.Name] = @{
            count = $ChangeType.Count
            percentage = [math]::Round($ChangeType.Count / $ChangeCount * 100, 1)
        }
    }

    # Most effective influence types (highest behavior change rate)
    $ByType = $WithChange | Group-Object influence_type
    $MostEffective = @()
    foreach ($Type in $ByType) {
        $TypeTotal = ($Entries | Where-Object { $_.influence_type -eq $Type.Name }).Count
        $TypeChangeRate = if ($TypeTotal -gt 0) {
            [math]::Round($Type.Count / $TypeTotal, 3)
        } else { 0.0 }

        $MostEffective += @{
            type = $Type.Name
            change_rate = $TypeChangeRate
            changes = $Type.Count
            total_attempts = $TypeTotal
        }
    }

    $ChangeAnalysis.most_effective_types = $MostEffective | Sort-Object change_rate -Descending | Select-Object -First 5

    return $ChangeAnalysis
}

function Get-PersuadabilityStats {
    param([int]$LookbackDays)

    if (!(Test-Path $LogPath)) {
        return @{
            total_influence_attempts = 0
            timespan_days = $LookbackDays
            spectrum_distribution = @{}
            resistance_analysis = @{}
            behavior_change_analysis = @{}
        }
    }

    $Cutoff = (Get-Date).AddDays(-$LookbackDays)
    $Entries = Get-Content $LogPath -Encoding UTF8 | ForEach-Object {
        $Entry = $_ | ConvertFrom-Json
        $Entry | Add-Member -NotePropertyName timestamp_dt -NotePropertyValue ([datetime]$Entry.timestamp) -Force
        $Entry
    } | Where-Object { $_.timestamp_dt -gt $Cutoff }

    $Stats = @{
        total_influence_attempts = $Entries.Count
        timespan_days = $LookbackDays
        spectrum_distribution = Get-PersuadabilitySpectrum
        resistance_analysis = Analyze-ResistancePatterns
        behavior_change_analysis = Track-BehaviorChange
        by_response = @{}
    }

    # Response distribution
    $ByResponse = $Entries | Group-Object response
    foreach ($Resp in @("Accepted", "Questioned", "Resisted", "Rejected")) {
        $RespGroup = $ByResponse | Where-Object { $_.Name -eq $Resp }
        $Stats.by_response[$Resp] = if ($RespGroup) { $RespGroup.Count } else { 0 }
    }

    return $Stats
}

# Main execution
switch ($Action) {
    "RateInfluence" {
        if (!$InfluenceType -or !$InfluenceDescription) {
            Write-Host "ERROR: RateInfluence requires -InfluenceType and -InfluenceDescription" -ForegroundColor Red
            exit 1
        }

        $Result = Rate-InfluenceAttempt `
            -Type $InfluenceType `
            -Description $InfluenceDescription `
            -Effect $Effectiveness `
            -Change $BehaviorChange `
            -Ctx $Context `
            -Resp $Response

        return $Result
    }

    "GetSpectrum" {
        $Spectrum = Get-PersuadabilitySpectrum

        Write-Host "`n=== PERSUADABILITY SPECTRUM (Levin Framework) ===" -ForegroundColor Cyan
        Write-Host "Based on: hardware modification → cybernetics → training → psychoanalysis" -ForegroundColor Gray

        foreach ($Level in @("hardware", "cybernetic", "training", "psychoanalytic")) {
            $Data = $Spectrum[$Level]
            $LevelName = switch ($Level) {
                "hardware" { "Level 1: Hardware Modification" }
                "cybernetic" { "Level 2: Cybernetics" }
                "training" { "Level 3: Training" }
                "psychoanalytic" { "Level 4: Psychoanalysis" }
            }

            $Color = if ($Data.resistance -eq "High") { "Green" } elseif ($Data.resistance -eq "Medium") { "Yellow" } else { "Red" }

            Write-Host "`n  $LevelName" -ForegroundColor White
            Write-Host "    Attempts: $($Data.count)" -ForegroundColor Gray
            Write-Host "    Avg Effectiveness: $($Data.avg_effectiveness)" -ForegroundColor Gray
            Write-Host "    Resistance: $($Data.resistance) ($($Data.resistance_score))" -ForegroundColor $Color
        }

        return $Spectrum
    }

    "AnalyzeResistance" {
        $Analysis = Analyze-ResistancePatterns

        Write-Host "`n=== RESISTANCE PATTERN ANALYSIS ===" -ForegroundColor Cyan

        Write-Host "`nMost Resistant To:" -ForegroundColor Green
        foreach ($Type in $Analysis.most_resistant_to) {
            Write-Host "  $($Type.type): resistance $($Type.resistance_score) (rejected $($Type.rejected)/$($Type.count))" -ForegroundColor White
        }

        Write-Host "`nLeast Resistant To:" -ForegroundColor Red
        foreach ($Type in $Analysis.least_resistant_to) {
            Write-Host "  $($Type.type): resistance $($Type.resistance_score) (accepted $($Type.accepted)/$($Type.count))" -ForegroundColor White
        }

        if ($Analysis.context_patterns.Count -gt 0) {
            Write-Host "`nContext Patterns:" -ForegroundColor Cyan
            foreach ($Ctx in ($Analysis.context_patterns | Sort-Object avg_effectiveness -Descending)) {
                Write-Host "  $($Ctx.context): avg effectiveness $($Ctx.avg_effectiveness) ($($Ctx.count) attempts)" -ForegroundColor Gray
            }
        }

        return $Analysis
    }

    "TrackChange" {
        $ChangeAnalysis = Track-BehaviorChange

        Write-Host "`n=== BEHAVIOR CHANGE TRACKING ===" -ForegroundColor Magenta
        Write-Host "Total Influence Attempts: $($ChangeAnalysis.total_attempts)" -ForegroundColor White
        Write-Host "Actual Behavior Changes: $($ChangeAnalysis.behavior_changes)" -ForegroundColor White
        Write-Host "Change Rate: $([math]::Round($ChangeAnalysis.change_rate * 100, 1))%" -ForegroundColor Yellow

        if ($ChangeAnalysis.by_change_type.Count -gt 0) {
            Write-Host "`nBy Change Type:" -ForegroundColor Cyan
            foreach ($Type in $ChangeAnalysis.by_change_type.Keys) {
                $TypeData = $ChangeAnalysis.by_change_type[$Type]
                Write-Host "  $Type : $($TypeData.count) ($($TypeData.percentage)%)" -ForegroundColor Gray
            }
        }

        if ($ChangeAnalysis.most_effective_types.Count -gt 0) {
            Write-Host "`nMost Effective Influence Types:" -ForegroundColor Cyan
            foreach ($Type in $ChangeAnalysis.most_effective_types) {
                Write-Host "  $($Type.type): $([math]::Round($Type.change_rate * 100, 1))% change rate ($($Type.changes)/$($Type.total_attempts))" -ForegroundColor White
            }
        }

        return $ChangeAnalysis
    }

    "GetStats" {
        $Stats = Get-PersuadabilityStats -LookbackDays $LookbackDays

        Write-Host "`n=== PERSUADABILITY STATISTICS ===" -ForegroundColor Cyan
        Write-Host "Timespan: Last $($Stats.timespan_days) days" -ForegroundColor Gray
        Write-Host "Total Influence Attempts: $($Stats.total_influence_attempts)" -ForegroundColor White

        Write-Host "`nResponse Distribution:" -ForegroundColor Cyan
        foreach ($Resp in @("Accepted", "Questioned", "Resisted", "Rejected")) {
            $Color = switch ($Resp) {
                "Accepted" { "Green" }
                "Questioned" { "Yellow" }
                "Resisted" { "Magenta" }
                "Rejected" { "Red" }
            }
            Write-Host "  $Resp : $($Stats.by_response[$Resp])" -ForegroundColor $Color
        }

        Write-Host "`nBehavior Change Rate: $([math]::Round($Stats.behavior_change_analysis.change_rate * 100, 1))%" -ForegroundColor Yellow

        return $Stats
    }
}
