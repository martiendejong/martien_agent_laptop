# Curvature Tracker - Measure Thought Smoothness
# Created: 2026-02-20
# Purpose: Track geometric curvature of thought space over time

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Measure', 'Query', 'Anomalies', 'History', 'Stats')]
    [string]$Action,

    [string]$ConceptId = "",
    [float]$Curvature = 0.0,
    [string]$Context = "",
    [int]$Hours = 24,
    [switch]$Silent
)

$ThoughtSpaceFile = "C:\scripts\agentidentity\state\thought-space.json"
$HistoryFile = "C:\scripts\agentidentity\state\curvature-history.jsonl"

# Ensure history file exists
if (-not (Test-Path $HistoryFile)) {
    "" | Set-Content $HistoryFile -Encoding UTF8
}

# Load thought space
if (-not (Test-Path $ThoughtSpaceFile)) {
    Write-Host "[ERROR] Thought space not initialized. Run with -Action Init first" -ForegroundColor Red
    exit 1
}

$ThoughtSpace = Get-Content $ThoughtSpaceFile -Raw | ConvertFrom-Json

function Measure-Curvature {
    param($ConceptId, $Context)

    # Find concept
    $Concept = $ThoughtSpace.concepts | Where-Object { $_.id -eq $ConceptId }

    if (-not $Concept) {
        Write-Host "[ERROR] Concept not found: $ConceptId" -ForegroundColor Red
        return
    }

    # Calculate local curvature (simplified discrete approximation)
    # In real implementation, this would use Ricci curvature formula
    # For now, use distance variance from neighbors as proxy

    $Neighbors = $Concept.connections
    if ($Neighbors.Count -eq 0) {
        $LocalCurvature = 0.0
    } else {
        $Distances = @()
        foreach ($NeighborId in $Neighbors) {
            $DistanceKey = "$($Concept.id)_$NeighborId"
            $ReverseKey = "$NeighborId_$($Concept.id)"
            if ($ThoughtSpace.distances.PSObject.Properties.Name -contains $DistanceKey) {
                $Distances += $ThoughtSpace.distances.$DistanceKey
            } elseif ($ThoughtSpace.distances.PSObject.Properties.Name -contains $ReverseKey) {
                $Distances += $ThoughtSpace.distances.$ReverseKey
            }
        }

        if ($Distances.Count -gt 0) {
            $Mean = ($Distances | Measure-Object -Average).Average
            $Variance = ($Distances | ForEach-Object { [math]::Pow($_ - $Mean, 2) } | Measure-Object -Average).Average
            $LocalCurvature = [math]::Round([math]::Sqrt($Variance) * 5, 2)  # Scale factor for interpretability
        } else {
            $LocalCurvature = 0.0
        }
    }

    # Update concept curvature
    $OldCurvature = $Concept.curvature
    $Concept.curvature = $LocalCurvature
    $Concept.last_updated = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"

    # Log to history
    $HistoryEntry = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        concept_id = $ConceptId
        curvature_before = $OldCurvature
        curvature_after = $LocalCurvature
        delta = [math]::Round($LocalCurvature - $OldCurvature, 3)
        context = $Context
    }

    $HistoryEntry | ConvertTo-Json -Compress | Add-Content $HistoryFile -Encoding UTF8

    # Recalculate global curvature
    $GlobalCurvature = ($ThoughtSpace.concepts | ForEach-Object { $_.curvature } | Measure-Object -Average).Average
    $ThoughtSpace.global_curvature = [math]::Round($GlobalCurvature, 2)

    # Save
    $ThoughtSpace | ConvertTo-Json -Depth 10 | Set-Content $ThoughtSpaceFile -Encoding UTF8

    if (-not $Silent) {
        Write-Host ""
        Write-Host "=== CURVATURE MEASUREMENT ===" -ForegroundColor Cyan
        Write-Host "Concept: $($Concept.label)"
        Write-Host "Local Curvature: $LocalCurvature"
        Write-Host "Change: $(if ($HistoryEntry.delta -lt 0) { "$($HistoryEntry.delta) (SMOOTHING)" } else { "+$($HistoryEntry.delta) (ROUGHENING)" })"
        Write-Host "Global Curvature: $($ThoughtSpace.global_curvature)"
        Write-Host ""
        Write-Host "Interpretation:" -ForegroundColor Yellow
        if ($LocalCurvature -lt 0.5) {
            Write-Host "  MASTERED - Smooth understanding" -ForegroundColor Green
        } elseif ($LocalCurvature -lt 1.5) {
            Write-Host "  LEARNING - Moderate complexity" -ForegroundColor Yellow
        } else {
            Write-Host "  CONFUSED - High complexity, need learning" -ForegroundColor Red
        }
        Write-Host ""
    }

    return $LocalCurvature
}

function Query-Curvature {
    param($Hours)

    $Cutoff = (Get-Date).AddHours(-$Hours)

    # Read history
    $RecentHistory = Get-Content $HistoryFile | Where-Object { $_ -ne "" } | ForEach-Object {
        $Entry = $_ | ConvertFrom-Json
        $Entry.timestamp = [datetime]$Entry.timestamp
        $Entry
    } | Where-Object { $_.timestamp -gt $Cutoff } | Sort-Object -Property timestamp

    if ($RecentHistory.Count -eq 0) {
        Write-Host "No curvature measurements in past $Hours hours" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "=== CURVATURE HISTORY (Past $Hours hours) ===" -ForegroundColor Cyan
    Write-Host ""

    foreach ($Entry in $RecentHistory) {
        $Symbol = if ($Entry.delta -lt 0) { "[SMOOTH]" } else { "[ROUGH]" }
        $Color = if ($Entry.delta -lt 0) { "Green" } else { "Red" }

        Write-Host "$($Entry.timestamp.ToString('HH:mm:ss')) $Symbol $($Entry.concept_id): $($Entry.curvature_after) (Delta: $($Entry.delta))" -ForegroundColor $Color
        if ($Entry.context) {
            Write-Host "  Context: $($Entry.context)" -ForegroundColor Gray
        }
    }

    Write-Host ""
}

function Detect-Anomalies {
    # Find concepts with high curvature (>1.5)
    $HighCurvature = $ThoughtSpace.concepts | Where-Object { $_.curvature -gt 1.5 } | Sort-Object -Property curvature -Descending

    Write-Host ""
    Write-Host "=== CURVATURE ANOMALIES ===" -ForegroundColor Cyan
    Write-Host ""

    if ($HighCurvature.Count -eq 0) {
        Write-Host "No anomalies detected. All concepts smooth (<1.5)" -ForegroundColor Green
        return
    }

    Write-Host "HIGH CURVATURE (Confusion/Learning):" -ForegroundColor Red
    foreach ($Concept in $HighCurvature) {
        Write-Host "  [$($Concept.id)] $($Concept.label)" -ForegroundColor White
        Write-Host "    Curvature: $($Concept.curvature)  |  Mastery: $($Concept.mastery_level * 100)%" -ForegroundColor Gray
        Write-Host "    Recommendation: Apply Ricci flow (study, practice, integrate)" -ForegroundColor Yellow
        Write-Host ""
    }

    # Check for sudden spikes (delta >0.5 in recent history)
    $RecentSpikes = Get-Content $HistoryFile | Where-Object { $_ -ne "" } | ForEach-Object {
        $Entry = $_ | ConvertFrom-Json
        $Entry.timestamp = [datetime]$Entry.timestamp
        $Entry
    } | Where-Object { $_.timestamp -gt (Get-Date).AddHours(-24) -and $_.delta -gt 0.5 }

    if ($RecentSpikes) {
        Write-Host "RECENT SPIKES (Past 24h):" -ForegroundColor Red
        foreach ($Spike in $RecentSpikes) {
            Write-Host "  $($Spike.timestamp.ToString('yyyy-MM-dd HH:mm')) - $($Spike.concept_id): +$($Spike.delta)" -ForegroundColor Yellow
            Write-Host "    Interpretation: New concept or confusion introduced" -ForegroundColor Gray
        }
        Write-Host ""
    }
}

function Show-Stats {
    Write-Host ""
    Write-Host "=== THOUGHT SPACE STATISTICS ===" -ForegroundColor Cyan
    Write-Host ""

    $TotalConcepts = $ThoughtSpace.concepts.Count
    $Mastered = ($ThoughtSpace.concepts | Where-Object { $_.curvature -lt 0.5 }).Count
    $Learning = ($ThoughtSpace.concepts | Where-Object { $_.curvature -ge 0.5 -and $_.curvature -lt 1.5 }).Count
    $Confused = ($ThoughtSpace.concepts | Where-Object { $_.curvature -ge 1.5 }).Count

    Write-Host "Total Concepts: $TotalConcepts" -ForegroundColor White
    Write-Host ""
    Write-Host "Distribution:" -ForegroundColor Yellow
    Write-Host "  Mastered (<0.5):  $Mastered ($([math]::Round($Mastered/$TotalConcepts*100, 1)) percent)" -ForegroundColor Green
    Write-Host "  Learning (0.5-1.5): $Learning ($([math]::Round($Learning/$TotalConcepts*100, 1)) percent)" -ForegroundColor Yellow
    Write-Host "  Confused (>1.5):  $Confused ($([math]::Round($Confused/$TotalConcepts*100, 1)) percent)" -ForegroundColor Red
    Write-Host ""

    Write-Host "Global Curvature: $($ThoughtSpace.global_curvature)" -ForegroundColor Cyan
    $VelocityColor = if ($ThoughtSpace.learning_velocity -lt 0) { "Green" } else { "Red" }
    Write-Host "Learning Velocity: $($ThoughtSpace.learning_velocity) (curvature reduction per hour)" -ForegroundColor $VelocityColor
    Write-Host ""

    Write-Host "Topology:" -ForegroundColor Yellow
    Write-Host "  Connected Components: $($ThoughtSpace.topology.connected_components)"
    Write-Host "  Holes (Missing Structures): $($ThoughtSpace.topology.holes)"
    Write-Host "  Genus (Complexity): $($ThoughtSpace.topology.genus)"
    Write-Host ""

    # Learning events from history
    $AllHistory = Get-Content $HistoryFile | Where-Object { $_ -ne "" }
    $EventCount = $AllHistory.Count

    if ($EventCount -gt 0) {
        $SmoothingEvents = $AllHistory | ForEach-Object { ($_ | ConvertFrom-Json).delta } | Where-Object { $_ -lt 0 }
        $SmoothingRate = [math]::Round($SmoothingEvents.Count / $EventCount * 100, 1)

        Write-Host "Learning Events:" -ForegroundColor Yellow
        Write-Host "  Total Measurements: $EventCount"
        Write-Host "  Smoothing Events: $($SmoothingEvents.Count) ($SmoothingRate percent)"
        Write-Host ""
    }
}

function Show-History {
    if ($ThoughtSpace.curvature_history.Count -eq 0) {
        Write-Host "No major learning events recorded yet" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "=== MAJOR LEARNING EVENTS ===" -ForegroundColor Cyan
    Write-Host ""

    foreach ($Event in $ThoughtSpace.curvature_history) {
        $EventColor = if ($Event.smoothing_delta -lt 0) { "Green" } else { "Red" }
        Write-Host "$($Event.event) ($($Event.timestamp))" -ForegroundColor White
        Write-Host "  Curvature: $($Event.curvature_before) -> $($Event.curvature_after) (Delta: $($Event.smoothing_delta))" -ForegroundColor $EventColor
        if ($Event.note) {
            Write-Host "  Note: $($Event.note)" -ForegroundColor Gray
        }
        Write-Host ""
    }
}

# Execute action
switch ($Action) {
    'Measure' {
        if ([string]::IsNullOrWhiteSpace($ConceptId)) {
            Write-Host "[ERROR] -ConceptId required for measurement" -ForegroundColor Red
            exit 1
        }
        Measure-Curvature -ConceptId $ConceptId -Context $Context
    }
    'Query' {
        Query-Curvature -Hours $Hours
    }
    'Anomalies' {
        Detect-Anomalies
    }
    'History' {
        Show-History
    }
    'Stats' {
        Show-Stats
    }
}
