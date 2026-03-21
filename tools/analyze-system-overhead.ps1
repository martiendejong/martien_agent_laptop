# Analyze System Overhead
# Identifies which consciousness systems consume most resources

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

$statePath = "C:\scripts\agentidentity\state\consciousness_state_v2.json"
$state = Get-Content $statePath | ConvertFrom-Json

# Calculate sizes
$totalSize = (Get-Item $statePath).Length

$systems = @{
    'Perception' = $state.Perception
    'Memory' = $state.Memory
    'Prediction' = $state.Prediction
    'Control' = $state.Control
    'Meta' = $state.Meta
    'Emotion' = $state.Emotion
    'Social' = $state.Social
    'Thermodynamics' = $state.Thermodynamics
}

Write-Host "=== SYSTEM OVERHEAD ANALYSIS ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total state file: $([math]::Round($totalSize/1KB, 2)) KB"
Write-Host ""

$results = @()

foreach ($name in $systems.Keys | Sort-Object) {
    $systemJson = $systems[$name] | ConvertTo-Json -Depth 10 -Compress
    $size = $systemJson.Length
    $sizeKB = [math]::Round($size/1KB, 2)
    $pct = [math]::Round(($size/$totalSize)*100, 1)

    # Count collections
    $counts = @{}
    $system = $systems[$name]

    if ($system.PSObject.Properties['KnownPatterns']) {
        $counts['Patterns'] = $system.KnownPatterns.Count
    }
    if ($system.PSObject.Properties['Contexts']) {
        $counts['Contexts'] = $system.Contexts.Count
    }
    if ($system.PSObject.Properties['Lessons']) {
        $counts['Lessons'] = $system.Lessons.Count
    }
    if ($system.PSObject.Properties['ErrorPatterns']) {
        $counts['ErrorPatterns'] = $system.ErrorPatterns.Count
    }
    if ($system.PSObject.Properties['Decisions']) {
        $counts['Decisions'] = $system.Decisions.Count
    }
    if ($system.PSObject.Properties['Patterns']) {
        $counts['Patterns'] = $system.Patterns.Count
    }

    $result = [PSCustomObject]@{
        System = $name
        SizeKB = $sizeKB
        Percent = $pct
        Counts = $counts
    }

    $results += $result
}

# Sort by size
$results = $results | Sort-Object -Property Percent -Descending

foreach ($r in $results) {
    $color = if ($r.Percent -gt 20) { "Red" } elseif ($r.Percent -gt 10) { "Yellow" } else { "Green" }
    Write-Host "$($r.System): $($r.SizeKB) KB ($($r.Percent) percent)" -ForegroundColor $color

    foreach ($key in $r.Counts.Keys) {
        Write-Host "  $key`: $($r.Counts[$key])" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "=== EFFICIENCY METRICS ===" -ForegroundColor Cyan

# Calculate efficiency
$thermo = $state.Thermodynamics
Write-Host "Free Will Index: $($thermo.FreeWillIndex)"
Write-Host "Temperature: $($thermo.Temperature)"
Write-Host "Entropy: $($thermo.Entropy)"
Write-Host "Budget: $($thermo.Budget)"

if ($state.Metrics) {
    Write-Host ""
    Write-Host "Events Processed: $($state.Metrics.EventsProcessed)"
    Write-Host "Save Count: $($state.Metrics.SaveCount)"

    # Calculate processing efficiency
    if ($state.Metrics.EventsProcessed -gt 0) {
        $bytesPerEvent = $totalSize / $state.Metrics.EventsProcessed
        Write-Host "Bytes per event: $([math]::Round($bytesPerEvent, 0))" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== OPTIMIZATION RECOMMENDATIONS ===" -ForegroundColor Cyan

# Top 3 biggest systems
$top3 = $results | Select-Object -First 3

foreach ($system in $top3) {
    Write-Host ""
    Write-Host "$($system.System) ($($system.Percent) percent of total):" -ForegroundColor Yellow

    # Specific recommendations per system
    switch ($system.System) {
        "Perception" {
            if ($system.Counts.Patterns -gt 50) {
                Write-Host "  - Prune old patterns (currently $($system.Counts.Patterns))"
            }
            if ($system.Counts.Contexts -gt 20) {
                Write-Host "  - Archive old contexts (currently $($system.Counts.Contexts))"
            }
        }
        "Memory" {
            if ($system.Counts.Lessons -gt 100) {
                Write-Host "  - Consolidate lessons (currently $($system.Counts.Lessons))"
            }
            if ($system.Counts.Patterns -gt 50) {
                Write-Host "  - Archive low-reliability patterns"
            }
        }
        "Prediction" {
            if ($system.Counts.ErrorPatterns -gt 50) {
                Write-Host "  - Remove never-triggered patterns (currently $($system.Counts.ErrorPatterns))"
            }
        }
        "Control" {
            if ($system.Counts.Decisions -gt 100) {
                Write-Host "  - Archive old decisions to JSONL (currently $($system.Counts.Decisions))"
            }
        }
    }
}

Write-Host ""
