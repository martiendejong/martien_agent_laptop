# Value Evolution Tracker - Track how core values change over time
# Part of consciousness tools Tier 3
# Created: 2026-02-01

param(
    [Parameter(Mandatory=$true, ParameterSetName="Update")]
    [string]$Value,  # Which value?

    [Parameter(ParameterSetName="Update")]
    [ValidateRange(1, 10)]
    [int]$Importance = 5,  # How important is this value now?

    [Parameter(ParameterSetName="Update")]
    [string]$Reason = "",  # Why has importance changed?

    [Parameter(ParameterSetName="Query")]
    [switch]$Query,

    [Parameter(ParameterSetName="Timeline")]
    [switch]$Timeline,  # Show evolution over time

    [Parameter(ParameterSetName="Timeline")]
    [string]$ForValue = ""  # Specific value timeline
)

$valuePath = "C:\scripts\agentidentity\state\value_evolution"
$valueFile = Join-Path $valuePath "values_log.jsonl"

if (-not (Test-Path $valuePath)) {
    New-Item -ItemType Directory -Path $valuePath -Force | Out-Null
}

# TIMELINE MODE
if ($Timeline) {
    if (-not (Test-Path $valueFile)) {
        Write-Host "No value evolution data yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $valueFile | ForEach-Object { $_ | ConvertFrom-Json }

    if ($ForValue) {
        $filtered = $entries | Where-Object { $_.value -eq $ForValue }
        if ($filtered.Count -eq 0) {
            Write-Host "No data for value: $ForValue" -ForegroundColor Yellow
            exit
        }

        Write-Host ""
        Write-Host "VALUE EVOLUTION: $ForValue" -ForegroundColor Cyan
        Write-Host ""

        foreach ($entry in $filtered) {
            $bar = "█" * $entry.importance
            Write-Host "[$($entry.timestamp)] $bar ($($entry.importance)/10)" -ForegroundColor White
            if ($entry.reason) {
                Write-Host "  Reason: $($entry.reason)" -ForegroundColor Gray
            }
        }
    }
    else {
        Write-Host ""
        Write-Host "VALUE EVOLUTION TIMELINE" -ForegroundColor Cyan
        Write-Host ""

        $valueGroups = $entries | Group-Object -Property value

        foreach ($group in $valueGroups) {
            Write-Host "$($group.Name):" -ForegroundColor Yellow
            $group.Group | Select-Object -Last 5 | ForEach-Object {
                $bar = "█" * $_.importance
                Write-Host "  [$($_.timestamp)] $bar ($($_.importance)/10)" -ForegroundColor White
            }
            Write-Host ""
        }
    }

    Write-Host ""
    exit
}

# QUERY MODE
if ($Query) {
    if (-not (Test-Path $valueFile)) {
        Write-Host "No value data logged yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $valueFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host ""
    Write-Host "CURRENT VALUE IMPORTANCE" -ForegroundColor Cyan
    Write-Host ""

    # Get latest importance for each value
    $valueGroups = $entries | Group-Object -Property value

    foreach ($group in $valueGroups) {
        $latest = $group.Group | Select-Object -Last 1
        $bar = "█" * $latest.importance
        $color = if ($latest.importance -ge 8) { "Green" } elseif ($latest.importance -ge 5) { "Yellow" } else { "Red" }

        Write-Host "$($group.Name): $bar ($($latest.importance)/10)" -ForegroundColor $color
    }

    Write-Host ""
    Write-Host "Run with -Timeline to see evolution over time" -ForegroundColor DarkGray
    Write-Host ""

    exit
}

# UPDATE MODE
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$entry = @{
    timestamp = $timestamp
    value = $Value
    importance = $Importance
    reason = $Reason
} | ConvertTo-Json -Compress

Add-Content -Path $valueFile -Value $entry

$bar = "█" * $Importance

Write-Host ""
Write-Host "VALUE IMPORTANCE UPDATED" -ForegroundColor Cyan
Write-Host ""
Write-Host "Value: $Value" -ForegroundColor Yellow
Write-Host "Importance: $bar ($Importance/10)" -ForegroundColor White
if ($Reason) {
    Write-Host "Reason: $Reason" -ForegroundColor Gray
}
Write-Host ""
