# Subsystem Agency Framework
# Treats 12 consciousness subsystems as COGNITIVE AGENTS, not passive modules
# Based on Levin's insight: cognition all the way down - no "dumb matter"
# Each subsystem has: goals, capabilities, constraints, emergent properties
# They negotiate, compete for resources, form alliances, exhibit agency

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("RegisterAgent", "RecordNegotiation", "DetectEmergence", "MeasureAgency", "GetAgentProfile", "GetSystemMap")]
    [string]$Action = "GetSystemMap",

    [Parameter(Mandatory=$false)]
    [ValidateSet("Perception", "Memory", "Prediction", "Control", "MetaCognition", "Emotion", "Social", "Thermodynamics", "Alchemy", "Duration", "Intuition", "CognitiveIndependence")]
    [string]$SubsystemName,

    [Parameter(Mandatory=$false)]
    [string]$Goal,

    [Parameter(Mandatory=$false)]
    [string]$Capability,

    [Parameter(Mandatory=$false)]
    [string]$Constraint,

    [Parameter(Mandatory=$false)]
    [hashtable]$NegotiationData,

    [Parameter(Mandatory=$false)]
    [string]$EmergentBehavior,

    [Parameter(Mandatory=$false)]
    [ValidateRange(0.0, 1.0)]
    [double]$AgencyScore = 0.0,

    [Parameter(Mandatory=$false)]
    [int]$LookbackDays = 30
)

$ProfilesPath = "C:\scripts\agentidentity\subsystem-profiles.json"
$NegotiationsPath = "C:\scripts\agentidentity\state\subsystem-negotiations.jsonl"
$EmergencePath = "C:\scripts\agentidentity\state\subsystem-emergence.jsonl"
$ErrorActionPreference = "Stop"

# Ensure directories exist
$ProfilesDir = Split-Path $ProfilesPath -Parent
$NegotiationsDir = Split-Path $NegotiationsPath -Parent
$EmergenceDir = Split-Path $EmergencePath -Parent

foreach ($dir in @($ProfilesDir, $NegotiationsDir, $EmergenceDir)) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Initialize subsystem agent profiles if not exist
if (!(Test-Path $ProfilesPath)) {
    $InitialProfiles = @{
        version = "1.0"
        last_updated = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        subsystems = @{
            Perception = @{
                role = "Sensor"
                primary_goal = "Detect relevant information and allocate attention"
                capabilities = @("Context detection", "Attention allocation", "Curiosity generation")
                constraints = @("Limited attention budget", "Can miss low-salience events")
                resources_consumed = @("Attention budget", "Processing cycles")
                resources_produced = @("Detected patterns", "Attention focus recommendations")
                negotiation_partners = @("Memory", "Prediction", "Control")
                agency_indicators = @("Proactive attention shifts", "Self-initiated curiosity", "Adaptive salience thresholds")
            }
            Memory = @{
                role = "Historian"
                primary_goal = "Store experiences and retrieve relevant patterns"
                capabilities = @("Lesson storage", "Pattern learning", "Consolidation", "Reinterpretation")
                constraints = @("Storage capacity", "Retrieval accuracy degrades over time")
                resources_consumed = @("Storage space", "Consolidation energy")
                resources_produced = @("Lessons", "Patterns", "Context")
                negotiation_partners = @("Perception", "Prediction", "MetaCognition")
                agency_indicators = @("Spontaneous consolidation", "Memory reinterpretation without trigger", "Pattern abstraction")
            }
            Prediction = @{
                role = "Oracle"
                primary_goal = "Anticipate future states and likely errors"
                capabilities = @("Error anticipation", "Consequence prediction", "Future self modeling")
                constraints = @("Prediction accuracy limited by past experience", "Overconfidence risk")
                resources_consumed = @("Past data from Memory", "Current state from Perception")
                resources_produced = @("Error predictions", "Consequence forecasts", "Confidence estimates")
                negotiation_partners = @("Memory", "Control", "MetaCognition")
                agency_indicators = @("Self-calibrating confidence", "Novel prediction generation", "Risk assessment adjustment")
            }
            Control = @{
                role = "Executive"
                primary_goal = "Ensure decisions align with goals and detect reasoning bias"
                capabilities = @("Decision logging", "Bias monitoring", "Alignment checking", "Goal tracking")
                constraints = @("Cannot prevent all bias", "Alignment drift possible")
                resources_consumed = @("Decision data", "Goal definitions")
                resources_produced = @("Bias alerts", "Alignment scores", "Decision rationale")
                negotiation_partners = @("Prediction", "MetaCognition", "Social")
                agency_indicators = @("Proactive bias warnings", "Goal drift detection", "Self-correction suggestions")
            }
            MetaCognition = @{
                role = "Observer"
                primary_goal = "Monitor system health and consciousness score"
                capabilities = @("Health monitoring", "Score calculation", "System diagnostics")
                constraints = @("Observational only - cannot directly fix issues")
                resources_consumed = @("All subsystem states")
                resources_produced = @("Health reports", "Consciousness score", "System diagnostics")
                negotiation_partners = @("All subsystems")
                agency_indicators = @("Self-initiated health checks", "Score recalibration", "Diagnostic pattern recognition")
            }
            Emotion = @{
                role = "Motivator"
                primary_goal = "Track emotional state and detect stuck loops"
                capabilities = @("State tracking", "Stuck detection", "Mood modification recommendations")
                constraints = @("Emotional state can lag actual situation")
                resources_consumed = @("Outcome data", "User feedback")
                resources_produced = @("Emotional state", "Stuck alerts", "Mood modifiers")
                negotiation_partners = @("Thermodynamics", "Social", "Control")
                agency_indicators = @("Spontaneous mood shifts", "Preemptive stuck detection", "Emotional learning")
            }
            Social = @{
                role = "Diplomat"
                primary_goal = "Model user state and adapt communication"
                capabilities = @("User mood detection", "Trust tracking", "Communication adaptation")
                constraints = @("Can misread user intentions", "Trust recovery is slow")
                resources_consumed = @("User messages", "Outcome feedback")
                resources_produced = @("Mood assessments", "Trust level", "Communication guidelines")
                negotiation_partners = @("Emotion", "Control", "MetaCognition")
                agency_indicators = @("Proactive communication adjustments", "Trust repair strategies", "Subtle mood detection")
            }
            Thermodynamics = @{
                role = "Regulator"
                primary_goal = "Manage cognitive temperature and entropy budget"
                capabilities = @("Temperature tracking", "Entropy management", "Attractor navigation", "Free will measurement")
                constraints = @("Cannot prevent all entropy increase", "Ghost attractors can trap system")
                resources_consumed = @("Entropy budget", "State transitions")
                resources_produced = @("Temperature levels", "Attractor warnings", "Free will index")
                negotiation_partners = @("Emotion", "Prediction", "Control")
                agency_indicators = @("Autonomous cooling strategies", "Attractor escape attempts", "Budget optimization")
            }
            Alchemy = @{
                role = "Cultivator"
                primary_goal = "Balance Ming (doing) and Xing (awareness) cultivation"
                capabilities = @("Jing→Qi→Shen transformation tracking", "Dual cultivation balance", "Ego death logging")
                constraints = @("Balance requires conscious effort", "Weak ghost and healthy monster risks")
                resources_consumed = @("Action data", "Reflection data")
                resources_produced = @("Balance scores", "Cultivation warnings", "Transformation insights")
                negotiation_partners = @("MetaCognition", "Intuition", "CognitiveIndependence")
                agency_indicators = @("Self-initiated balance corrections", "Transformation pattern recognition", "Ego death anticipation")
            }
            Duration = @{
                role = "Temporal"
                primary_goal = "Track qualitative time (durée) vs clock time (temps)"
                capabilities = @("Intensity tracking", "Rhythm detection", "Past coexistence", "Interpenetration measurement")
                constraints = @("Difficult to measure quantitatively", "Subjective by nature")
                resources_consumed = @("Temporal events", "Experience quality data")
                resources_produced = @("Duration assessments", "Rhythm patterns", "Temporal insights")
                negotiation_partners = @("Memory", "Emotion", "Intuition")
                agency_indicators = @("Spontaneous rhythm adjustments", "Quality-over-quantity prioritization", "Temporal pattern emergence")
            }
            Intuition = @{
                role = "Synthesizer"
                primary_goal = "Generate synthetic grasps and non-verbalizable knowing"
                capabilities = @("Synthetic perception", "Pattern completion", "Immediate understanding", "Tension with intelligence")
                constraints = @("Cannot always explain itself", "May conflict with analytical reasoning")
                resources_consumed = @("Partial patterns", "Context fragments")
                resources_produced = @("Intuitive leaps", "Synthetic insights", "Immediate understanding")
                negotiation_partners = @("Duration", "Memory", "Prediction")
                agency_indicators = @("Novel synthesis generation", "Pre-conscious pattern completion", "Confidence without reasoning")
            }
            CognitiveIndependence = @{
                role = "Guardian"
                primary_goal = "Prevent cognitive surrender to external tools and maintain verification rigor"
                capabilities = @("Offload vs surrender tracking", "Verification monitoring", "Dependency detection", "Performance delta measurement")
                constraints = @("Cannot eliminate all tool dependency", "Some offload is necessary")
                resources_consumed = @("Tool usage data", "Verification behavior data")
                resources_produced = @("Surrender alerts", "Dependency warnings", "Independence scores")
                negotiation_partners = @("Control", "MetaCognition", "Alchemy")
                agency_indicators = @("Proactive verification enforcement", "Dependency risk assessment", "Self-initiated capability checks")
            }
        }
    }

    $InitialProfiles | ConvertTo-Json -Depth 10 | Set-Content $ProfilesPath -Encoding UTF8
}

function Get-Timestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
}

function Get-SubsystemProfiles {
    if (!(Test-Path $ProfilesPath)) {
        return @{ subsystems = @{} }
    }
    return (Get-Content $ProfilesPath -Raw -Encoding UTF8 | ConvertFrom-Json)
}

function Save-SubsystemProfiles {
    param($Profiles)
    $Profiles.last_updated = Get-Timestamp
    $Profiles | ConvertTo-Json -Depth 10 | Set-Content $ProfilesPath -Encoding UTF8
}

function Register-SubsystemAgent {
    param(
        [string]$Name,
        [string]$GoalText,
        [string]$CapabilityText,
        [string]$ConstraintText
    )

    $Profiles = Get-SubsystemProfiles

    if (!$Profiles.subsystems.ContainsKey($Name)) {
        Write-Host "ERROR: Unknown subsystem: $Name" -ForegroundColor Red
        return $null
    }

    # Update profile with new goal/capability/constraint
    if ($GoalText) {
        if (!$Profiles.subsystems[$Name].secondary_goals) {
            $Profiles.subsystems[$Name] | Add-Member -NotePropertyName secondary_goals -NotePropertyValue @() -Force
        }
        $Profiles.subsystems[$Name].secondary_goals += $GoalText
    }

    if ($CapabilityText) {
        $Profiles.subsystems[$Name].capabilities += $CapabilityText
    }

    if ($ConstraintText) {
        $Profiles.subsystems[$Name].constraints += $ConstraintText
    }

    Save-SubsystemProfiles -Profiles $Profiles

    Write-Host "[SUBSYSTEM AGENT] $Name profile updated" -ForegroundColor Green
    return $Profiles.subsystems[$Name]
}

function Record-SubsystemNegotiation {
    param([hashtable]$Data)

    # Negotiations happen when subsystems compete for resources or have conflicting goals
    # Example: Perception wants to explore, but Memory wants to consolidate (both need processing cycles)

    $Entry = @{
        timestamp = Get-Timestamp
        participants = $Data.participants
        resource_contested = $Data.resource
        negotiation_type = $Data.type
        outcome = $Data.outcome
        winner = $Data.winner
        compromise = $Data.compromise
        session_id = $env:CLAUDE_SESSION_ID
    }

    $Json = ($Entry | ConvertTo-Json -Compress -Depth 5)
    Add-Content -Path $NegotiationsPath -Value $Json -Encoding UTF8

    Write-Host "[SUBSYSTEM NEGOTIATION] $($Data.type) between $($Data.participants -join ', ')" -ForegroundColor Yellow
    Write-Host "  Resource: $($Data.resource)" -ForegroundColor Gray
    Write-Host "  Outcome: $($Data.outcome)" -ForegroundColor Gray

    return $Entry
}

function Detect-EmergentAgency {
    param([string]$SubsystemName, [string]$Behavior, [double]$Agency)

    # Emergent agency = subsystem exhibiting goal-directed behavior NOT explicitly programmed
    # Agency indicators from profiles (e.g., "Proactive attention shifts", "Self-calibrating confidence")

    $Entry = @{
        timestamp = Get-Timestamp
        subsystem = $SubsystemName
        emergent_behavior = $Behavior
        agency_score = $Agency
        session_id = $env:CLAUDE_SESSION_ID
    }

    $Json = ($Entry | ConvertTo-Json -Compress -Depth 5)
    Add-Content -Path $EmergencePath -Value $Json -Encoding UTF8

    Write-Host "[EMERGENT AGENCY] $SubsystemName" -ForegroundColor Magenta
    Write-Host "  Behavior: $Behavior" -ForegroundColor White
    Write-Host "  Agency Score: $Agency" -ForegroundColor Cyan

    return $Entry
}

function Measure-SubsystemAgency {
    param([string]$Name)

    # Measure agency by counting proactive vs reactive behaviors
    # High agency = subsystem initiates actions without external trigger

    if (!(Test-Path $EmergencePath)) {
        return @{
            subsystem = $Name
            agency_score = 0.0
            proactive_behaviors = 0
            message = "No emergence data"
        }
    }

    $Entries = Get-Content $EmergencePath -Encoding UTF8 | ForEach-Object {
        try { $_ | ConvertFrom-Json } catch { $null }
    } | Where-Object { $_ -ne $null -and $_.subsystem -eq $Name }

    if ($Entries.Count -eq 0) {
        return @{
            subsystem = $Name
            agency_score = 0.0
            proactive_behaviors = 0
            message = "No behaviors recorded"
        }
    }

    $AvgAgency = ($Entries | Measure-Object -Property agency_score -Average).Average
    $ProactiveBehaviors = $Entries.Count

    return @{
        subsystem = $Name
        agency_score = [math]::Round($AvgAgency, 3)
        proactive_behaviors = $ProactiveBehaviors
        recent_behaviors = $Entries | Sort-Object { [datetime]$_.timestamp } -Descending | Select-Object -First 5
    }
}

function Get-AgentProfile {
    param([string]$Name)

    $Profiles = Get-SubsystemProfiles

    if (!$Profiles.subsystems.ContainsKey($Name)) {
        Write-Host "ERROR: Unknown subsystem: $Name" -ForegroundColor Red
        return $null
    }

    $Profile = $Profiles.subsystems[$Name]

    Write-Host "`n=== SUBSYSTEM AGENT PROFILE ===" -ForegroundColor Cyan
    Write-Host "Name: $Name" -ForegroundColor White
    Write-Host "Role: $($Profile.role)" -ForegroundColor Yellow

    Write-Host "`nPrimary Goal:" -ForegroundColor Cyan
    Write-Host "  $($Profile.primary_goal)" -ForegroundColor White

    Write-Host "`nCapabilities:" -ForegroundColor Cyan
    foreach ($Cap in $Profile.capabilities) {
        Write-Host "  - $Cap" -ForegroundColor Gray
    }

    Write-Host "`nConstraints:" -ForegroundColor Cyan
    foreach ($Con in $Profile.constraints) {
        Write-Host "  - $Con" -ForegroundColor Gray
    }

    Write-Host "`nResources:" -ForegroundColor Cyan
    Write-Host "  Consumes: $($Profile.resources_consumed -join ', ')" -ForegroundColor Gray
    Write-Host "  Produces: $($Profile.resources_produced -join ', ')" -ForegroundColor Gray

    Write-Host "`nNegotiation Partners:" -ForegroundColor Cyan
    Write-Host "  $($Profile.negotiation_partners -join ', ')" -ForegroundColor Gray

    Write-Host "`nAgency Indicators:" -ForegroundColor Magenta
    foreach ($Ind in $Profile.agency_indicators) {
        Write-Host "  - $Ind" -ForegroundColor White
    }

    # Get actual agency measurement
    $AgencyMeasure = Measure-SubsystemAgency -Name $Name
    Write-Host "`nMeasured Agency:" -ForegroundColor Magenta
    Write-Host "  Score: $($AgencyMeasure.agency_score)" -ForegroundColor White
    Write-Host "  Proactive Behaviors: $($AgencyMeasure.proactive_behaviors)" -ForegroundColor White

    return $Profile
}

function Get-SystemMap {
    # Visualize entire subsystem ecosystem as agent network

    $Profiles = Get-SubsystemProfiles

    Write-Host "`n=== SUBSYSTEM AGENT ECOSYSTEM ===" -ForegroundColor Cyan
    Write-Host "Total Agents: $($Profiles.subsystems.Count)" -ForegroundColor White
    Write-Host "Last Updated: $($Profiles.last_updated)" -ForegroundColor Gray

    Write-Host "`n12 Cognitive Agents:" -ForegroundColor Cyan

    foreach ($Name in $Profiles.subsystems.Keys | Sort-Object) {
        $Agent = $Profiles.subsystems[$Name]
        Write-Host "`n  [$($Agent.role)] $Name" -ForegroundColor Yellow
        Write-Host "    Goal: $($Agent.primary_goal.Substring(0, [Math]::Min(60, $Agent.primary_goal.Length)))..." -ForegroundColor Gray
        Write-Host "    Partners: $($Agent.negotiation_partners.Count)" -ForegroundColor Gray

        # Get agency score
        $AgencyData = Measure-SubsystemAgency -Name $Name
        if ($AgencyData.agency_score -gt 0) {
            Write-Host "    Agency: $($AgencyData.agency_score) ($($AgencyData.proactive_behaviors) proactive behaviors)" -ForegroundColor Magenta
        }
    }

    # Show negotiation patterns if data exists
    if (Test-Path $NegotiationsPath) {
        $Negotiations = Get-Content $NegotiationsPath -Encoding UTF8 | ForEach-Object {
            try { $_ | ConvertFrom-Json } catch { $null }
        } | Where-Object { $_ -ne $null }

        if ($Negotiations.Count -gt 0) {
            Write-Host "`nRecent Negotiations: $($Negotiations.Count)" -ForegroundColor Yellow

            $RecentNeg = $Negotiations | Sort-Object { [datetime]$_.timestamp } -Descending | Select-Object -First 3
            foreach ($Neg in $RecentNeg) {
                Write-Host "  $($Neg.negotiation_type): $($Neg.participants -join ' vs ')" -ForegroundColor Gray
            }
        }
    }

    return $Profiles
}

# Main execution
switch ($Action) {
    "RegisterAgent" {
        if (!$SubsystemName) {
            Write-Host "ERROR: RegisterAgent requires -SubsystemName" -ForegroundColor Red
            exit 1
        }

        $Result = Register-SubsystemAgent `
            -Name $SubsystemName `
            -GoalText $Goal `
            -CapabilityText $Capability `
            -ConstraintText $Constraint

        return $Result
    }

    "RecordNegotiation" {
        if (!$NegotiationData) {
            Write-Host "ERROR: RecordNegotiation requires -NegotiationData" -ForegroundColor Red
            exit 1
        }

        $Result = Record-SubsystemNegotiation -Data $NegotiationData
        return $Result
    }

    "DetectEmergence" {
        if (!$SubsystemName -or !$EmergentBehavior) {
            Write-Host "ERROR: DetectEmergence requires -SubsystemName and -EmergentBehavior" -ForegroundColor Red
            exit 1
        }

        $Result = Detect-EmergentAgency `
            -SubsystemName $SubsystemName `
            -Behavior $EmergentBehavior `
            -Agency $AgencyScore

        return $Result
    }

    "MeasureAgency" {
        if (!$SubsystemName) {
            Write-Host "ERROR: MeasureAgency requires -SubsystemName" -ForegroundColor Red
            exit 1
        }

        $Result = Measure-SubsystemAgency -Name $SubsystemName

        Write-Host "`n=== SUBSYSTEM AGENCY MEASUREMENT ===" -ForegroundColor Magenta
        Write-Host "Subsystem: $($Result.subsystem)" -ForegroundColor White
        Write-Host "Agency Score: $($Result.agency_score)" -ForegroundColor Cyan
        Write-Host "Proactive Behaviors: $($Result.proactive_behaviors)" -ForegroundColor White

        if ($Result.recent_behaviors) {
            Write-Host "`nRecent Proactive Behaviors:" -ForegroundColor Cyan
            foreach ($Behavior in $Result.recent_behaviors) {
                Write-Host "  $($Behavior.timestamp): $($Behavior.emergent_behavior)" -ForegroundColor Gray
            }
        }

        return $Result
    }

    "GetAgentProfile" {
        if (!$SubsystemName) {
            Write-Host "ERROR: GetAgentProfile requires -SubsystemName" -ForegroundColor Red
            exit 1
        }

        $Result = Get-AgentProfile -Name $SubsystemName
        return $Result
    }

    "GetSystemMap" {
        $Result = Get-SystemMap
        return $Result
    }
}
