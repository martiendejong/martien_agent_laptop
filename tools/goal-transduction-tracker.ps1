# Goal Transduction Tracker
# Tracks how abstract user goals get transduced across scales into concrete execution
# Based on Michael Levin's work on goal scaling in biological systems

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("LogTransduction", "GetHistory", "AnalyzeFidelity", "GetStats")]
    [string]$Action = "LogTransduction",

    [Parameter(Mandatory=$false)]
    [string]$GoalId,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Semantic", "Strategic", "Procedural", "Code", "Filesystem", "Molecular")]
    [string]$Scale,

    [Parameter(Mandatory=$false)]
    [string]$Content,

    [Parameter(Mandatory=$false)]
    [string]$Transformation,

    [Parameter(Mandatory=$false)]
    [int]$LookbackHours = 24
)

$LogPath = "C:\scripts\agentidentity\state\goal-transduction.jsonl"
$ErrorActionPreference = "Stop"

# Ensure directory exists
$LogDir = Split-Path $LogPath -Parent
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

function Get-Timestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
}

function Log-Transduction {
    param($GoalId, $Scale, $Content, $Transformation)

    $Entry = @{
        timestamp = Get-Timestamp
        goal_id = $GoalId
        scale = $Scale
        content = $Content
        transformation = $Transformation
        session_id = $env:CLAUDE_SESSION_ID
    }

    $Json = ($Entry | ConvertTo-Json -Compress)
    Add-Content -Path $LogPath -Value $Json -Encoding UTF8

    return $Entry
}

function Get-TransductionHistory {
    param($GoalId, $LookbackHours)

    if (!(Test-Path $LogPath)) {
        return @()
    }

    $Cutoff = (Get-Date).AddHours(-$LookbackHours)
    $Entries = Get-Content $LogPath -Encoding UTF8 | ForEach-Object {
        $Entry = $_ | ConvertFrom-Json
        $Entry | Add-Member -NotePropertyName timestamp_dt -NotePropertyValue ([datetime]$Entry.timestamp) -Force
        $Entry
    } | Where-Object { $_.timestamp_dt -gt $Cutoff }

    if ($GoalId) {
        $Entries = $Entries | Where-Object { $_.goal_id -eq $GoalId }
    }

    return $Entries
}

function Analyze-TransductionFidelity {
    param($GoalId)

    $History = Get-TransductionHistory -GoalId $GoalId -LookbackHours 9999

    if ($History.Count -eq 0) {
        Write-Host "No transduction history found for goal: $GoalId" -ForegroundColor Yellow
        return $null
    }

    # Group by scale
    $ByScale = $History | Group-Object -Property scale

    # Calculate fidelity metrics
    $ScaleOrder = @("Semantic", "Strategic", "Procedural", "Code", "Filesystem", "Molecular")
    $TransductionChain = @()

    foreach ($Scale in $ScaleOrder) {
        $ScaleEntries = $ByScale | Where-Object { $_.Name -eq $Scale }
        if ($ScaleEntries) {
            $TransductionChain += @{
                scale = $Scale
                count = $ScaleEntries.Count
                transformations = ($ScaleEntries.Group | Select-Object -ExpandProperty transformation)
            }
        }
    }

    $Fidelity = @{
        goal_id = $GoalId
        total_transductions = $History.Count
        scales_traversed = $TransductionChain.Count
        chain = $TransductionChain
        completeness = [math]::Round($TransductionChain.Count / $ScaleOrder.Count, 2)
    }

    return $Fidelity
}

function Get-TransductionStats {
    $History = Get-TransductionHistory -LookbackHours $LookbackHours

    $Stats = @{
        total_events = $History.Count
        unique_goals = ($History | Select-Object -ExpandProperty goal_id -Unique).Count
        scales_used = ($History | Select-Object -ExpandProperty scale -Unique)
        avg_chain_length = 0
        recent_goals = @()
    }

    # Calculate average chain length
    $GoalIds = $History | Select-Object -ExpandProperty goal_id -Unique
    $ChainLengths = @()

    foreach ($GId in $GoalIds) {
        $GoalHistory = $History | Where-Object { $_.goal_id -eq $GId }
        $ChainLengths += $GoalHistory.Count

        $Stats.recent_goals += @{
            goal_id = $GId
            chain_length = $GoalHistory.Count
            scales = ($GoalHistory | Select-Object -ExpandProperty scale -Unique)
        }
    }

    if ($ChainLengths.Count -gt 0) {
        $Stats.avg_chain_length = [math]::Round(($ChainLengths | Measure-Object -Average).Average, 2)
    }

    return $Stats
}

# Main execution
switch ($Action) {
    "LogTransduction" {
        if (!$GoalId -or !$Scale -or !$Content) {
            Write-Host "ERROR: LogTransduction requires -GoalId, -Scale, and -Content" -ForegroundColor Red
            exit 1
        }

        $Result = Log-Transduction -GoalId $GoalId -Scale $Scale -Content $Content -Transformation $Transformation
        Write-Host "[TRANSDUCTION LOGGED] $Scale : $($Content.Substring(0, [Math]::Min(50, $Content.Length)))..." -ForegroundColor Green
        return $Result
    }

    "GetHistory" {
        $History = Get-TransductionHistory -GoalId $GoalId -LookbackHours $LookbackHours
        return $History
    }

    "AnalyzeFidelity" {
        if (!$GoalId) {
            Write-Host "ERROR: AnalyzeFidelity requires -GoalId" -ForegroundColor Red
            exit 1
        }

        $Fidelity = Analyze-TransductionFidelity -GoalId $GoalId

        if ($Fidelity) {
            Write-Host "`n=== GOAL TRANSDUCTION FIDELITY ANALYSIS ===" -ForegroundColor Cyan
            Write-Host "Goal ID: $($Fidelity.goal_id)" -ForegroundColor White
            Write-Host "Total Transductions: $($Fidelity.total_transductions)" -ForegroundColor White
            Write-Host "Scales Traversed: $($Fidelity.scales_traversed)/6" -ForegroundColor White
            Write-Host "Completeness: $($Fidelity.completeness * 100)%" -ForegroundColor $(if ($Fidelity.completeness -gt 0.7) { "Green" } else { "Yellow" })

            Write-Host "`nTransduction Chain:" -ForegroundColor Cyan
            foreach ($Step in $Fidelity.chain) {
                Write-Host "  $($Step.scale): $($Step.count) events" -ForegroundColor Gray
            }
        }

        return $Fidelity
    }

    "GetStats" {
        $Stats = Get-TransductionStats

        Write-Host "`n=== GOAL TRANSDUCTION STATISTICS ===" -ForegroundColor Cyan
        Write-Host "Lookback: Last $LookbackHours hours" -ForegroundColor Gray
        Write-Host "Total Events: $($Stats.total_events)" -ForegroundColor White
        Write-Host "Unique Goals: $($Stats.unique_goals)" -ForegroundColor White
        Write-Host "Avg Chain Length: $($Stats.avg_chain_length)" -ForegroundColor White
        Write-Host "Scales Used: $($Stats.scales_used -join ', ')" -ForegroundColor White

        if ($Stats.recent_goals.Count -gt 0) {
            Write-Host "`nRecent Goals:" -ForegroundColor Cyan
            foreach ($Goal in ($Stats.recent_goals | Select-Object -First 5)) {
                Write-Host "  $($Goal.goal_id): $($Goal.chain_length) steps across [$($Goal.scales -join ', ')]" -ForegroundColor Gray
            }
        }

        return $Stats
    }
}
