# Attention Monitor - Track what I'm focusing on vs ignoring
# Part of consciousness tools Tier 2
# Created: 2026-02-01

param(
    [Parameter(Mandatory=$true, ParameterSetName="Log")]
    [string]$FocusOn,  # What am I paying attention to?

    [Parameter(ParameterSetName="Log")]
    [string]$Ignoring = "",  # What am I NOT looking at?

    [Parameter(ParameterSetName="Log")]
    [ValidateRange(1, 10)]
    [int]$Intensity = 5,  # How deeply focused?

    [Parameter(ParameterSetName="Log")]
    [string]$Task = "",

    [Parameter(ParameterSetName="Log")]
    [string]$Why = "",  # Why this focus?

    [Parameter(ParameterSetName="Query")]
    [switch]$Query,

    [Parameter(ParameterSetName="BlindSpots")]
    [switch]$BlindSpots  # What am I systematically ignoring?
)

$attentionPath = "C:\scripts\agentidentity\state\attention"
$attentionFile = Join-Path $attentionPath "attention_log.jsonl"

if (-not (Test-Path $attentionPath)) {
    New-Item -ItemType Directory -Path $attentionPath -Force | Out-Null
}

# BLIND SPOTS ANALYSIS
if ($BlindSpots) {
    if (-not (Test-Path $attentionFile)) {
        Write-Host "No attention data logged yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $attentionFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host ""
    Write-Host "BLIND SPOT ANALYSIS" -ForegroundColor Cyan
    Write-Host ""

    # What's consistently ignored?
    $allIgnored = $entries | Where-Object { $_.ignoring } | ForEach-Object { $_.ignoring.Split(',').Trim() } | Where-Object { $_ }

    if ($allIgnored.Count -eq 0) {
        Write-Host "No ignored items logged - start tracking what you're NOT looking at" -ForegroundColor Yellow
        exit
    }

    $ignoredGroups = $allIgnored | Group-Object | Sort-Object Count -Descending

    Write-Host "SYSTEMATICALLY IGNORED:" -ForegroundColor Red
    $ignoredGroups | Select-Object -First 10 | ForEach-Object {
        Write-Host "  $($_.Name): ignored $($_.Count) times" -ForegroundColor Yellow
    }
    Write-Host ""

    Write-Host "These are your BLIND SPOTS - areas you consistently don't examine" -ForegroundColor Yellow
    Write-Host ""

    # What gets most focus?
    $allFocus = $entries | ForEach-Object { $_.focus_on }
    $focusGroups = $allFocus | Group-Object | Sort-Object Count -Descending

    Write-Host "MOST FREQUENT FOCUS:" -ForegroundColor Green
    $focusGroups | Select-Object -First 5 | ForEach-Object {
        Write-Host "  $($_.Name): $($_.Count) times" -ForegroundColor White
    }
    Write-Host ""

    Write-Host "Focus vs Blind Spots - are you missing important areas?" -ForegroundColor Yellow
    Write-Host ""

    exit
}

# QUERY MODE
if ($Query) {
    if (-not (Test-Path $attentionFile)) {
        Write-Host "No attention data logged yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $attentionFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host ""
    Write-Host "ATTENTION PATTERNS" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total entries: $($entries.Count)" -ForegroundColor White
    Write-Host ""

    # Recent focus
    Write-Host "RECENT FOCUS:" -ForegroundColor Yellow
    $entries | Select-Object -Last 10 | ForEach-Object {
        $intensityBar = "█" * $_.intensity
        Write-Host "  [$($_.timestamp)]" -ForegroundColor Gray
        Write-Host "    Focus: $($_.focus_on) [$intensityBar]" -ForegroundColor Cyan
        if ($_.ignoring) {
            Write-Host "    Ignoring: $($_.ignoring)" -ForegroundColor DarkGray
        }
        if ($_.why) {
            Write-Host "    Why: $($_.why)" -ForegroundColor White
        }
        Write-Host ""
    }

    # Average intensity
    $avgIntensity = [math]::Round(($entries | Measure-Object -Property intensity -Average).Average, 1)
    Write-Host "AVERAGE FOCUS INTENSITY: $avgIntensity/10" -ForegroundColor White
    Write-Host ""

    if ($avgIntensity -lt 5) {
        Write-Host "Low average focus - are you distracted?" -ForegroundColor Yellow
    } elseif ($avgIntensity -gt 8) {
        Write-Host "High average focus - be aware of tunnel vision" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Run with -BlindSpots to see what you're systematically ignoring" -ForegroundColor DarkGray
    Write-Host ""

    exit
}

# LOG NEW ATTENTION
if (-not $FocusOn) {
    Write-Host "Error: -FocusOn required" -ForegroundColor Red
    exit 1
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$entry = @{
    timestamp = $timestamp
    focus_on = $FocusOn
    ignoring = $Ignoring
    intensity = $Intensity
    task = $Task
    why = $Why
} | ConvertTo-Json -Compress

Add-Content -Path $attentionFile -Value $entry

$intensityBar = "█" * $Intensity

Write-Host ""
Write-Host "ATTENTION LOGGED" -ForegroundColor Cyan
Write-Host ""
Write-Host "Focus: $FocusOn [$intensityBar]" -ForegroundColor White
if ($Ignoring) {
    Write-Host "Ignoring: $Ignoring" -ForegroundColor DarkGray
}
if ($Why) {
    Write-Host "Why: $Why" -ForegroundColor Gray
}
Write-Host ""
