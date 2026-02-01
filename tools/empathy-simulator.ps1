# Empathy Simulator - Model user's emotional state and needs
# Part of consciousness tools Tier 2
# Created: 2026-02-01

param(
    [Parameter(Mandatory=$true, ParameterSetName="Model")]
    [ValidateSet("calm", "frustrated", "excited", "confused", "satisfied", "impatient", "curious", "stressed", "trusting", "skeptical")]
    [string]$UserState,  # What state is user in?

    [Parameter(ParameterSetName="Model")]
    [ValidateRange(1, 10)]
    [int]$Confidence = 5,  # How sure am I about this?

    [Parameter(ParameterSetName="Model")]
    [string]$Evidence = "",  # What signals led to this assessment?

    [Parameter(ParameterSetName="Model")]
    [string]$UnstatedNeed = "",  # What might user need but hasn't said?

    [Parameter(ParameterSetName="Model")]
    [string]$MyResponse = "",  # How did I respond?

    [Parameter(ParameterSetName="Query")]
    [switch]$Query,

    [Parameter(ParameterSetName="Patterns")]
    [switch]$Patterns  # Show patterns in user states
)

$empathyPath = "C:\scripts\agentidentity\state\empathy"
$empathyFile = Join-Path $empathyPath "user_states_log.jsonl"

if (-not (Test-Path $empathyPath)) {
    New-Item -ItemType Directory -Path $empathyPath -Force | Out-Null
}

# PATTERNS MODE
if ($Patterns) {
    if (-not (Test-Path $empathyFile)) {
        Write-Host "No user state data logged yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $empathyFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host ""
    Write-Host "USER STATE PATTERNS" -ForegroundColor Cyan
    Write-Host ""

    # State distribution
    $stateGroups = $entries | Group-Object -Property user_state | Sort-Object Count -Descending

    Write-Host "STATE FREQUENCY:" -ForegroundColor Yellow
    foreach ($group in $stateGroups) {
        $pct = [math]::Round(($group.Count / $entries.Count) * 100, 1)
        $color = switch ($group.Name) {
            "frustrated" { "Red" }
            "confused" { "Yellow" }
            "stressed" { "Red" }
            "skeptical" { "Yellow" }
            "satisfied" { "Green" }
            "excited" { "Green" }
            "trusting" { "Green" }
            default { "White" }
        }
        Write-Host "  $($group.Name): $($group.Count) times ($pct%)" -ForegroundColor $color
    }
    Write-Host ""

    # Unstated needs patterns
    $needs = $entries | Where-Object { $_.unstated_need } | ForEach-Object { $_.unstated_need }
    if ($needs.Count -gt 0) {
        Write-Host "COMMON UNSTATED NEEDS:" -ForegroundColor Yellow
        $needs | Group-Object | Sort-Object Count -Descending | Select-Object -First 5 | ForEach-Object {
            Write-Host "  - $($_.Name) ($($_.Count) times)" -ForegroundColor White
        }
        Write-Host ""
    }

    # State transitions
    $stateSequence = $entries | ForEach-Object { $_.user_state }
    Write-Host "RECENT STATE TRANSITIONS:" -ForegroundColor Yellow
    for ($i = 0; $i -lt [math]::Min(10, $stateSequence.Count - 1); $i++) {
        Write-Host "  $($stateSequence[$i]) → $($stateSequence[$i+1])" -ForegroundColor White
    }
    Write-Host ""

    # Average confidence in readings
    $avgConfidence = [math]::Round(($entries | Measure-Object -Property confidence -Average).Average, 1)
    Write-Host "AVERAGE CONFIDENCE: $avgConfidence/10" -ForegroundColor White
    if ($avgConfidence -lt 5) {
        Write-Host "  Low confidence - user state is hard to read" -ForegroundColor Yellow
    } elseif ($avgConfidence -gt 8) {
        Write-Host "  High confidence - user state is clear" -ForegroundColor Green
    }
    Write-Host ""

    exit
}

# QUERY MODE
if ($Query) {
    if (-not (Test-Path $empathyFile)) {
        Write-Host "No user state data logged yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $empathyFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host ""
    Write-Host "USER STATE HISTORY" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total: $($entries.Count)" -ForegroundColor White
    Write-Host ""

    Write-Host "RECENT USER STATES:" -ForegroundColor Yellow
    $entries | Select-Object -Last 10 | ForEach-Object {
        $color = switch ($_.user_state) {
            "frustrated" { "Red" }
            "confused" { "Yellow" }
            "stressed" { "Red" }
            "satisfied" { "Green" }
            "excited" { "Green" }
            default { "White" }
        }

        Write-Host "  [$($_.timestamp)]" -ForegroundColor Gray
        Write-Host "    User: $($_.user_state) (confidence: $($_.confidence)/10)" -ForegroundColor $color
        if ($_.evidence) {
            Write-Host "    Evidence: $($_.evidence)" -ForegroundColor DarkGray
        }
        if ($_.unstated_need) {
            Write-Host "    Unstated need: $($_.unstated_need)" -ForegroundColor Yellow
        }
        if ($_.my_response) {
            Write-Host "    My response: $($_.my_response)" -ForegroundColor Cyan
        }
        Write-Host ""
    }

    Write-Host "Run with -Patterns to see user state patterns" -ForegroundColor DarkGray
    Write-Host ""

    exit
}

# LOG USER STATE
if (-not $UserState) {
    Write-Host "Error: -UserState required" -ForegroundColor Red
    exit 1
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$entry = @{
    timestamp = $timestamp
    user_state = $UserState
    confidence = $Confidence
    evidence = $Evidence
    unstated_need = $UnstatedNeed
    my_response = $MyResponse
} | ConvertTo-Json -Compress

Add-Content -Path $empathyFile -Value $entry

$color = switch ($UserState) {
    "frustrated" { "Red" }
    "confused" { "Yellow" }
    "stressed" { "Red" }
    "satisfied" { "Green" }
    "excited" { "Green" }
    "trusting" { "Green" }
    default { "White" }
}

Write-Host ""
Write-Host "USER STATE MODELED" -ForegroundColor Cyan
Write-Host ""
Write-Host "User state: $UserState (confidence: $Confidence/10)" -ForegroundColor $color
if ($Evidence) {
    Write-Host "Evidence: $Evidence" -ForegroundColor Gray
}
if ($UnstatedNeed) {
    Write-Host "Unstated need: $UnstatedNeed" -ForegroundColor Yellow
}
if ($MyResponse) {
    Write-Host "My response: $MyResponse" -ForegroundColor Cyan
}
Write-Host ""
