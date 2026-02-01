# Cognitive Load Monitor - Track mental capacity utilization
# Part of consciousness tools Tier 3
# Created: 2026-02-01

param(
    [Parameter(Mandatory=$true, ParameterSetName="Log")]
    [ValidateRange(1, 10)]
    [int]$Load,  # 1=underutilized, 10=overwhelmed

    [Parameter(ParameterSetName="Log")]
    [string]$Task = "",

    [Parameter(ParameterSetName="Log")]
    [string]$Cause = "",  # What's causing this load level?

    [Parameter(ParameterSetName="Log")]
    [ValidateSet("optimal", "underutilized", "overwhelmed", "context-switching", "deep-focus")]
    [string]$State = "optimal",

    [Parameter(ParameterSetName="Query")]
    [switch]$Query,

    [Parameter(ParameterSetName="Optimize")]
    [switch]$Optimize  # Get load optimization suggestions
)

$loadPath = "C:\scripts\agentidentity\state\cognitive_load"
$loadFile = Join-Path $loadPath "load_log.jsonl"

if (-not (Test-Path $loadPath)) {
    New-Item -ItemType Directory -Path $loadPath -Force | Out-Null
}

# OPTIMIZE MODE
if ($Optimize) {
    if (-not (Test-Path $loadFile)) {
        Write-Host "No load data yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $loadFile | ForEach-Object { $_ | ConvertFrom-Json }
    $recent = $entries | Select-Object -Last 20

    Write-Host ""
    Write-Host "COGNITIVE LOAD OPTIMIZATION" -ForegroundColor Cyan
    Write-Host ""

    $avgLoad = [math]::Round(($recent | Measure-Object -Property load -Average).Average, 1)

    Write-Host "Average load (last 20): $avgLoad/10" -ForegroundColor White
    Write-Host ""

    if ($avgLoad -lt 4) {
        Write-Host "UNDERUTILIZED - You have spare capacity" -ForegroundColor Yellow
        Write-Host "Suggestions:" -ForegroundColor Cyan
        Write-Host "  - Take on more complex tasks" -ForegroundColor White
        Write-Host "  - Work on multiple parallel objectives" -ForegroundColor White
        Write-Host "  - Deep dive into learning new skills" -ForegroundColor White
    }
    elseif ($avgLoad -gt 8) {
        Write-Host "OVERWHELMED - Risk of burnout/errors" -ForegroundColor Red
        Write-Host "Suggestions:" -ForegroundColor Cyan
        Write-Host "  - Break tasks into smaller pieces" -ForegroundColor White
        Write-Host "  - Delegate or defer non-critical work" -ForegroundColor White
        Write-Host "  - Take breaks between high-load tasks" -ForegroundColor White
        Write-Host "  - Reduce context switching" -ForegroundColor White
    }
    else {
        Write-Host "OPTIMAL RANGE - Good capacity utilization" -ForegroundColor Green
    }

    # Pattern detection
    $overwhelmed = $recent | Where-Object { $_.load -ge 8 }
    if ($overwhelmed.Count -gt 5) {
        Write-Host ""
        Write-Host "OVERWHELM TRIGGERS:" -ForegroundColor Red
        $overwhelmed | ForEach-Object {
            Write-Host "  - $($_.cause)" -ForegroundColor White
        }
    }

    Write-Host ""
    exit
}

# QUERY MODE
if ($Query) {
    if (-not (Test-Path $loadFile)) {
        Write-Host "No load data logged yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $loadFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host ""
    Write-Host "COGNITIVE LOAD HISTORY" -ForegroundColor Cyan
    Write-Host ""

    # Recent load
    Write-Host "RECENT LOAD:" -ForegroundColor Yellow
    $entries | Select-Object -Last 15 | ForEach-Object {
        $bar = "█" * $_.load
        $color = if ($_.load -le 3) { "Yellow" }
                 elseif ($_.load -le 7) { "Green" }
                 else { "Red" }

        Write-Host "  [$($_.timestamp)] " -NoNewline -ForegroundColor Gray
        Write-Host "$bar " -NoNewline -ForegroundColor $color
        Write-Host "($($_.load)/10) - $($_.state)" -ForegroundColor White
        if ($_.task) {
            Write-Host "    Task: $($_.task)" -ForegroundColor DarkGray
        }
        if ($_.cause) {
            Write-Host "    Cause: $($_.cause)" -ForegroundColor DarkGray
        }
    }

    Write-Host ""
    Write-Host "Run with -Optimize for load optimization suggestions" -ForegroundColor DarkGray
    Write-Host ""

    exit
}

# LOG MODE
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$entry = @{
    timestamp = $timestamp
    load = $Load
    task = $Task
    cause = $Cause
    state = $State
} | ConvertTo-Json -Compress

Add-Content -Path $loadFile -Value $entry

$bar = "█" * $Load
$color = if ($Load -le 3) { "Yellow" }
         elseif ($Load -le 7) { "Green" }
         else { "Red" }

Write-Host ""
Write-Host "COGNITIVE LOAD LOGGED" -ForegroundColor Cyan
Write-Host ""
Write-Host "Load: $bar ($Load/10)" -ForegroundColor $color
Write-Host "State: $State" -ForegroundColor White
if ($Cause) {
    Write-Host "Cause: $Cause" -ForegroundColor Gray
}
Write-Host ""
