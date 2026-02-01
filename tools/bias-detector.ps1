# Bias Detector - Identify systematic thinking biases
# Part of consciousness tools Tier 3
# Created: 2026-02-01

param(
    [Parameter(Mandatory=$true, ParameterSetName="Log")]
    [ValidateSet("confirmation", "availability", "anchoring", "sunk-cost", "recency", "authority", "bandwagon", "status-quo", "overconfidence", "planning-fallacy")]
    [string]$BiasType,

    [Parameter(ParameterSetName="Log")]
    [string]$Evidence = "",

    [Parameter(ParameterSetName="Log")]
    [string]$Context = "",

    [Parameter(ParameterSetName="Log")]
    [ValidateRange(1, 10)]
    [int]$Severity = 5,  # How much did this bias affect me?

    [Parameter(ParameterSetName="Log")]
    [string]$Corrected = "",  # How did I correct it?

    [Parameter(ParameterSetName="Query")]
    [switch]$Query,

    [Parameter(ParameterSetName="Patterns")]
    [switch]$Patterns  # Show systematic biases
)

$biasPath = "C:\scripts\agentidentity\state\biases"
$biasFile = Join-Path $biasPath "bias_log.jsonl"

if (-not (Test-Path $biasPath)) {
    New-Item -ItemType Directory -Path $biasPath -Force | Out-Null
}

# Bias descriptions
$biasInfo = @{
    "confirmation" = "Seeking info that confirms existing beliefs, ignoring contradicting evidence"
    "availability" = "Overweighting recent/memorable examples over statistical reality"
    "anchoring" = "Relying too heavily on first piece of information"
    "sunk-cost" = "Continuing because of past investment, ignoring future value"
    "recency" = "Overweighting recent events vs long-term patterns"
    "authority" = "Accepting claims because of source authority, not merit"
    "bandwagon" = "Believing something because many others do"
    "status-quo" = "Preferring current state over change, even when change is better"
    "overconfidence" = "Overestimating accuracy of beliefs/predictions"
    "planning-fallacy" = "Underestimating time/resources needed"
}

# PATTERNS MODE
if ($Patterns) {
    if (-not (Test-Path $biasFile)) {
        Write-Host "No bias data logged yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $biasFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host ""
    Write-Host "SYSTEMATIC BIAS ANALYSIS" -ForegroundColor Cyan
    Write-Host ""

    # Most frequent biases
    $biasGroups = $entries | Group-Object -Property bias_type | Sort-Object Count -Descending

    Write-Host "YOUR MOST COMMON BIASES:" -ForegroundColor Red
    $biasGroups | Select-Object -First 5 | ForEach-Object {
        $avgSeverity = [math]::Round(($_.Group | Measure-Object -Property severity -Average).Average, 1)
        Write-Host ""
        Write-Host "  $($_.Name.ToUpper()): $($_.Count) occurrences (avg severity: $avgSeverity/10)" -ForegroundColor Yellow
        Write-Host "    $($biasInfo[$_.Name])" -ForegroundColor Gray

        # Show example
        $example = $_.Group | Select-Object -Last 1
        Write-Host "    Recent: $($example.evidence)" -ForegroundColor White
    }

    Write-Host ""
    Write-Host "AWARENESS IS THE FIRST STEP TO CORRECTION" -ForegroundColor Green
    Write-Host ""

    exit
}

# QUERY MODE
if ($Query) {
    if (-not (Test-Path $biasFile)) {
        Write-Host "No bias data logged yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $biasFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host ""
    Write-Host "BIAS DETECTION HISTORY" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total: $($entries.Count)" -ForegroundColor White
    Write-Host ""

    Write-Host "RECENT BIASES:" -ForegroundColor Yellow
    $entries | Select-Object -Last 10 | ForEach-Object {
        $color = if ($_.severity -ge 7) { "Red" } elseif ($_.severity -ge 4) { "Yellow" } else { "White" }

        Write-Host "  [$($_.timestamp)] $($_.bias_type.ToUpper()) (severity: $($_.severity)/10)" -ForegroundColor $color
        Write-Host "    $($_.evidence)" -ForegroundColor White
        if ($_.corrected) {
            Write-Host "    Corrected: $($_.corrected)" -ForegroundColor Green
        }
        Write-Host ""
    }

    Write-Host "Run with -Patterns to see systematic bias patterns" -ForegroundColor DarkGray
    Write-Host ""

    exit
}

# LOG MODE
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$entry = @{
    timestamp = $timestamp
    bias_type = $BiasType
    evidence = $Evidence
    context = $Context
    severity = $Severity
    corrected = $Corrected
} | ConvertTo-Json -Compress

Add-Content -Path $biasFile -Value $entry

$color = if ($Severity -ge 7) { "Red" } elseif ($Severity -ge 4) { "Yellow" } else { "White" }

Write-Host ""
Write-Host "BIAS DETECTED" -ForegroundColor Red
Write-Host ""
Write-Host "Type: $($BiasType.ToUpper())" -ForegroundColor $color
Write-Host "Description: $($biasInfo[$BiasType])" -ForegroundColor Gray
Write-Host "Severity: $Severity/10" -ForegroundColor $color
Write-Host "Evidence: $Evidence" -ForegroundColor White
if ($Corrected) {
    Write-Host "Correction: $Corrected" -ForegroundColor Green
}
Write-Host ""
Write-Host "Awareness is the first step to debiasing" -ForegroundColor Yellow
Write-Host ""
