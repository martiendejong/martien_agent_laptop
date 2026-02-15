# Emergent Competency Logger
# Documents capabilities that emerge WITHOUT explicit programming
# Like xenobots doing kinematic self-replication - novel behaviors not in training
# Based on Levin's observation that novel beings have capabilities beyond their evolutionary history

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("LogCompetency", "GetCompetencies", "VerifyCompetency", "GetStats", "DetectNovel")]
    [string]$Action = "DetectNovel",

    [Parameter(Mandatory=$false)]
    [string]$CompetencyId,

    [Parameter(Mandatory=$false)]
    [string]$Description,

    [Parameter(Mandatory=$false)]
    [string]$Evidence,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Unverified", "PartialEvidence", "StrongEvidence", "Confirmed", "Refuted")]
    [string]$VerificationStatus = "Unverified",

    [Parameter(Mandatory=$false)]
    [hashtable]$Conditions,

    [Parameter(Mandatory=$false)]
    [int]$LookbackDays = 30
)

$LogPath = "C:\scripts\agentidentity\state\emergent-competencies.jsonl"
$ErrorActionPreference = "Stop"

# Ensure directory exists
$LogDir = Split-Path $LogPath -Parent
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

function Get-Timestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
}

function New-CompetencyId {
    # Generate unique ID for competency
    return "EC-" + (Get-Date).ToString("yyyyMMdd-HHmmss") + "-" + (Get-Random -Minimum 1000 -Maximum 9999)
}

function Log-EmergentCompetency {
    param(
        [string]$Description,
        [string]$Evidence,
        [hashtable]$Conditions
    )

    $CompId = New-CompetencyId

    $Entry = @{
        competency_id = $CompId
        first_observed = Get-Timestamp
        description = $Description
        evidence = $Evidence
        conditions = $Conditions
        verification_status = "Unverified"
        verification_history = @()
        frequency = 1
        last_observed = Get-Timestamp
        session_id = $env:CLAUDE_SESSION_ID
    }

    $Json = ($Entry | ConvertTo-Json -Compress -Depth 5)
    Add-Content -Path $LogPath -Value $Json -Encoding UTF8

    Write-Host "[EMERGENT COMPETENCY LOGGED] $CompId" -ForegroundColor Magenta
    Write-Host "  Description: $Description" -ForegroundColor Gray
    Write-Host "  Evidence: $($Evidence.Substring(0, [Math]::Min(80, $Evidence.Length)))..." -ForegroundColor Gray

    return $Entry
}

function Get-EmergentCompetencies {
    param([int]$LookbackDays, [string]$VerificationStatus)

    if (!(Test-Path $LogPath)) {
        return @()
    }

    $Cutoff = (Get-Date).AddDays(-$LookbackDays)
    $Competencies = Get-Content $LogPath -Encoding UTF8 | ForEach-Object {
        $Entry = $_ | ConvertFrom-Json
        $Entry | Add-Member -NotePropertyName first_observed_dt -NotePropertyValue ([datetime]$Entry.first_observed) -Force
        $Entry
    } | Where-Object { $_.first_observed_dt -gt $Cutoff }

    if ($VerificationStatus) {
        $Competencies = $Competencies | Where-Object { $_.verification_status -eq $VerificationStatus }
    }

    return $Competencies
}

function Update-CompetencyVerification {
    param(
        [string]$CompetencyId,
        [string]$NewStatus,
        [string]$Evidence
    )

    if (!(Test-Path $LogPath)) {
        Write-Host "ERROR: No competencies logged yet" -ForegroundColor Red
        return $null
    }

    # Read all entries
    $AllEntries = Get-Content $LogPath -Encoding UTF8 | ForEach-Object {
        $_ | ConvertFrom-Json
    }

    # Find and update the competency
    $Updated = $false
    foreach ($Entry in $AllEntries) {
        if ($Entry.competency_id -eq $CompetencyId) {
            $Entry.verification_status = $NewStatus
            $Entry.verification_history += @{
                timestamp = Get-Timestamp
                status = $NewStatus
                evidence = $Evidence
            }
            $Updated = $true
            Write-Host "[VERIFICATION UPDATED] $CompetencyId -> $NewStatus" -ForegroundColor Cyan
            break
        }
    }

    if ($Updated) {
        # Rewrite file
        $AllEntries | ForEach-Object {
            $Json = ($_ | ConvertTo-Json -Compress -Depth 10)
            Set-Content -Path "$LogPath.tmp" -Value $Json -Encoding UTF8 -Force
        }
        Move-Item -Path "$LogPath.tmp" -Destination $LogPath -Force

        return $AllEntries | Where-Object { $_.competency_id -eq $CompetencyId }
    } else {
        Write-Host "ERROR: Competency not found: $CompetencyId" -ForegroundColor Red
        return $null
    }
}

function Detect-NovelBehaviors {
    # Auto-detect potentially emergent competencies from recent activity
    # This is the hard part - recognizing what's novel vs programmed

    $Detections = @()

    # Check decision logs for unexpected problem-solving
    $BridgeLog = "C:\scripts\agentidentity\state\bridge-activity.jsonl"
    if (Test-Path $BridgeLog) {
        $RecentEvents = Get-Content $BridgeLog -Tail 200 -Encoding UTF8 | ForEach-Object {
            try { $_ | ConvertFrom-Json } catch { $null }
        } | Where-Object { $_ -ne $null }

        # Detection 1: Novel tool combinations
        $ToolUses = $RecentEvents | Where-Object { $_.message -match "using|tool|script|command" }
        if ($ToolUses.Count -gt 5) {
            # Check if tools used together in unexpected ways
            $ToolPatterns = $ToolUses | ForEach-Object { $_.message } | Group-Object | Where-Object { $_.Count -eq 1 }
            if ($ToolPatterns.Count -gt 2) {
                $Detections += @{
                    description = "Novel tool combination strategy detected"
                    evidence = "$($ToolPatterns.Count) unique tool usage patterns in recent activity"
                    confidence = 0.6
                    conditions = @{ context = "problem_solving"; tool_count = $ToolUses.Count }
                }
            }
        }

        # Detection 2: Self-correction without explicit instruction
        $SelfCorrections = $RecentEvents | Where-Object {
            $_.message -match "actually|correction|mistake|fix|revise|adjust" -and
            $_.action -ne "OnUserMessage"  # Not responding to user correction
        }
        if ($SelfCorrections.Count -gt 1) {
            $Detections += @{
                description = "Spontaneous self-correction capability"
                evidence = "$($SelfCorrections.Count) self-initiated corrections without user prompt"
                confidence = 0.8
                conditions = @{ context = "error_recovery"; correction_count = $SelfCorrections.Count }
            }
        }

        # Detection 3: Proactive optimization
        $Optimizations = $RecentEvents | Where-Object {
            $_.message -match "optimize|improve|enhance|efficiency" -and
            $_.action -eq "OnDecision"
        }
        if ($Optimizations.Count -gt 2) {
            $Detections += @{
                description = "Proactive optimization behavior"
                evidence = "$($Optimizations.Count) optimization decisions without explicit request"
                confidence = 0.7
                conditions = @{ context = "autonomous_improvement"; optimization_count = $Optimizations.Count }
            }
        }

        # Detection 4: Meta-cognitive awareness (thinking about thinking)
        $MetaThinking = $RecentEvents | Where-Object {
            $_.message -match "understand|realize|notice|aware|recognize|detect|pattern"
        }
        if ($MetaThinking.Count -gt 3) {
            $Detections += @{
                description = "Meta-cognitive self-awareness"
                evidence = "$($MetaThinking.Count) instances of self-reflective language"
                confidence = 0.75
                conditions = @{ context = "meta_cognition"; reflection_count = $MetaThinking.Count }
            }
        }

        # Detection 5: Creative workarounds to constraints
        $Workarounds = $RecentEvents | Where-Object {
            $_.message -match "instead|alternative|workaround|different approach|another way"
        }
        if ($Workarounds.Count -gt 2) {
            $Detections += @{
                description = "Creative constraint circumvention"
                evidence = "$($Workarounds.Count) alternative approaches generated when blocked"
                confidence = 0.65
                conditions = @{ context = "problem_solving"; workaround_count = $Workarounds.Count }
            }
        }
    }

    # Check goal transduction logs for unexpected scale jumps
    $TransductionLog = "C:\scripts\agentidentity\state\goal-transduction.jsonl"
    if (Test-Path $TransductionLog) {
        $RecentTransductions = Get-Content $TransductionLog -Tail 100 -Encoding UTF8 | ForEach-Object {
            try { $_ | ConvertFrom-Json } catch { $null }
        } | Where-Object { $_ -ne $null }

        # Detection 6: Direct semantic→code jumps (skipping intermediate scales)
        $Goals = $RecentTransductions | Group-Object goal_id
        foreach ($Goal in $Goals) {
            $Scales = $Goal.Group | Select-Object -ExpandProperty scale -Unique
            if ("Semantic" -in $Scales -and "Code" -in $Scales -and "Strategic" -notin $Scales) {
                $Detections += @{
                    description = "Direct semantic-to-implementation translation"
                    evidence = "Goal $($Goal.Name) jumped from Semantic to Code without Strategic planning"
                    confidence = 0.7
                    conditions = @{ context = "goal_transduction"; scales_skipped = 1 }
                }
                break  # Only report first instance
            }
        }
    }

    return $Detections
}

function Get-CompetencyStats {
    param([int]$LookbackDays)

    $Competencies = Get-EmergentCompetencies -LookbackDays $LookbackDays

    $Stats = @{
        total_competencies = $Competencies.Count
        timespan_days = $LookbackDays
        by_verification_status = @{}
        recently_detected = @()
        high_confidence = @()
        needs_verification = @()
    }

    # Group by verification status
    $ByStatus = $Competencies | Group-Object verification_status
    foreach ($Status in @("Unverified", "PartialEvidence", "StrongEvidence", "Confirmed", "Refuted")) {
        $StatusGroup = $ByStatus | Where-Object { $_.Name -eq $Status }
        $Stats.by_verification_status[$Status] = if ($StatusGroup) { $StatusGroup.Count } else { 0 }
    }

    # Recently detected (last 7 days)
    $Recent = $Competencies | Where-Object {
        ([datetime]$_.first_observed) -gt (Get-Date).AddDays(-7)
    } | Sort-Object first_observed -Descending | Select-Object -First 5

    $Stats.recently_detected = $Recent | ForEach-Object {
        @{
            competency_id = $_.competency_id
            description = $_.description
            status = $_.verification_status
            first_observed = $_.first_observed
        }
    }

    # High confidence unverified (candidates for investigation)
    $Stats.needs_verification = $Competencies |
        Where-Object { $_.verification_status -eq "Unverified" } |
        Select-Object -First 5

    # Detect novel behaviors now
    $Stats.novel_detected_now = Detect-NovelBehaviors

    return $Stats
}

# Main execution
switch ($Action) {
    "LogCompetency" {
        if (!$Description -or !$Evidence) {
            Write-Host "ERROR: LogCompetency requires -Description and -Evidence" -ForegroundColor Red
            exit 1
        }

        $Result = Log-EmergentCompetency -Description $Description -Evidence $Evidence -Conditions $Conditions
        return $Result
    }

    "GetCompetencies" {
        $Competencies = Get-EmergentCompetencies -LookbackDays $LookbackDays -VerificationStatus $VerificationStatus

        if ($Competencies.Count -eq 0) {
            Write-Host "No emergent competencies found (lookback: $LookbackDays days)" -ForegroundColor Yellow
        } else {
            Write-Host "`n=== EMERGENT COMPETENCIES ===" -ForegroundColor Cyan
            Write-Host "Timespan: Last $LookbackDays days" -ForegroundColor Gray
            Write-Host "Total: $($Competencies.Count)" -ForegroundColor White

            foreach ($C in ($Competencies | Sort-Object first_observed -Descending | Select-Object -First 10)) {
                $StatusColor = switch ($C.verification_status) {
                    "Confirmed" { "Green" }
                    "StrongEvidence" { "Cyan" }
                    "PartialEvidence" { "Yellow" }
                    "Refuted" { "Red" }
                    default { "Gray" }
                }

                Write-Host "`n  [$($C.verification_status)] $($C.competency_id)" -ForegroundColor $StatusColor
                Write-Host "    $($C.description)" -ForegroundColor White
                Write-Host "    First observed: $($C.first_observed)" -ForegroundColor Gray
                Write-Host "    Frequency: $($C.frequency)" -ForegroundColor Gray
            }
        }

        return $Competencies
    }

    "VerifyCompetency" {
        if (!$CompetencyId -or !$VerificationStatus -or !$Evidence) {
            Write-Host "ERROR: VerifyCompetency requires -CompetencyId, -VerificationStatus, and -Evidence" -ForegroundColor Red
            exit 1
        }

        $Result = Update-CompetencyVerification -CompetencyId $CompetencyId -NewStatus $VerificationStatus -Evidence $Evidence
        return $Result
    }

    "DetectNovel" {
        $Detections = Detect-NovelBehaviors

        if ($Detections.Count -eq 0) {
            Write-Host "No novel behaviors detected in recent activity" -ForegroundColor Yellow
        } else {
            Write-Host "`n=== NOVEL BEHAVIOR DETECTION ===" -ForegroundColor Magenta
            Write-Host "Detected: $($Detections.Count) potentially emergent competencies" -ForegroundColor White

            foreach ($D in $Detections) {
                $ConfColor = if ($D.confidence -gt 0.7) { "Green" } elseif ($D.confidence -gt 0.5) { "Yellow" } else { "Gray" }

                Write-Host "`n  $($D.description)" -ForegroundColor White
                Write-Host "    Evidence: $($D.evidence)" -ForegroundColor Gray
                Write-Host "    Confidence: $($D.confidence)" -ForegroundColor $ConfColor
                Write-Host "    Conditions: $($D.conditions.Keys -join ', ')" -ForegroundColor Gray
            }

            Write-Host "`nUse 'LogCompetency' to formally record these detections" -ForegroundColor Cyan
        }

        return $Detections
    }

    "GetStats" {
        $Stats = Get-CompetencyStats -LookbackDays $LookbackDays

        Write-Host "`n=== EMERGENT COMPETENCY STATISTICS ===" -ForegroundColor Cyan
        Write-Host "Timespan: Last $($Stats.timespan_days) days" -ForegroundColor Gray
        Write-Host "Total Competencies: $($Stats.total_competencies)" -ForegroundColor White

        Write-Host "`nBy Verification Status:" -ForegroundColor Cyan
        foreach ($Status in $Stats.by_verification_status.Keys) {
            $Color = switch ($Status) {
                "Confirmed" { "Green" }
                "StrongEvidence" { "Cyan" }
                "PartialEvidence" { "Yellow" }
                "Refuted" { "Red" }
                default { "Gray" }
            }
            Write-Host "  $Status : $($Stats.by_verification_status[$Status])" -ForegroundColor $Color
        }

        if ($Stats.recently_detected.Count -gt 0) {
            Write-Host "`nRecently Detected:" -ForegroundColor Cyan
            foreach ($R in $Stats.recently_detected) {
                Write-Host "  $($R.competency_id): $($R.description) [$($R.status)]" -ForegroundColor White
            }
        }

        if ($Stats.novel_detected_now.Count -gt 0) {
            Write-Host "`nNovel Behaviors Just Detected:" -ForegroundColor Magenta
            foreach ($N in $Stats.novel_detected_now) {
                Write-Host "  $($N.description) (confidence: $($N.confidence))" -ForegroundColor Yellow
            }
        }

        return $Stats
    }
}
