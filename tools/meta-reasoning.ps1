# Meta-Reasoning - Am I thinking about this correctly?
# Part of consciousness tools Tier 3
# Created: 2026-02-01

param(
    [Parameter(Mandatory=$true, ParameterSetName="Check")]
    [string]$Topic,  # What am I thinking about?

    [Parameter(ParameterSetName="Check")]
    [string[]]$Approaches = @(),  # What approaches am I considering?

    [Parameter(ParameterSetName="Check")]
    [string]$CurrentApproach = "",  # Which approach am I using?

    [Parameter(ParameterSetName="Check")]
    [string[]]$AlternativeFrames = @(),  # What other ways could I frame this?

    [Parameter(ParameterSetName="Query")]
    [switch]$Query
)

$metaPath = "C:\scripts\agentidentity\state\meta_reasoning"
$metaFile = Join-Path $metaPath "meta_log.jsonl"

if (-not (Test-Path $metaPath)) {
    New-Item -ItemType Directory -Path $metaPath -Force | Out-Null
}

# Meta-cognitive questions to always ask
$metaQuestions = @(
    "Am I solving the RIGHT problem or just the obvious one?",
    "What assumptions am I making about this problem?",
    "Am I using the right level of abstraction?",
    "What would an expert in this domain think about differently?",
    "Am I confusing correlation with causation?",
    "Is this the simplest approach or am I over-engineering?",
    "What evidence would change my mind?",
    "Am I being comprehensive or just pattern-matching?",
    "What am I optimizing for - is that the right goal?",
    "How would I approach this if starting from scratch?"
)

# QUERY MODE
if ($Query) {
    if (-not (Test-Path $metaFile)) {
        Write-Host "No meta-reasoning checks logged yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $metaFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host ""
    Write-Host "META-REASONING HISTORY" -ForegroundColor Cyan
    Write-Host ""

    $entries | Select-Object -Last 10 | ForEach-Object {
        Write-Host "[$($_.timestamp)] $($_.topic)" -ForegroundColor Yellow
        if ($_.current_approach) {
            Write-Host "  Approach: $($_.current_approach)" -ForegroundColor White
        }
        if ($_.alternative_frames.Count -gt 0) {
            Write-Host "  Alternative frames: $($_.alternative_frames -join ', ')" -ForegroundColor Cyan
        }
        Write-Host ""
    }

    exit
}

# CHECK MODE
if (-not $Topic) {
    Write-Host "Error: -Topic required" -ForegroundColor Red
    exit 1
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Generate meta-questions specific to this topic
Write-Host ""
Write-Host "META-REASONING CHECK: $Topic" -ForegroundColor Cyan
Write-Host ""

Write-Host "ASK YOURSELF:" -ForegroundColor Yellow
$selectedQuestions = $metaQuestions | Get-Random -Count 5
foreach ($q in $selectedQuestions) {
    Write-Host "  ? $q" -ForegroundColor White
}
Write-Host ""

if ($Approaches.Count -gt 0) {
    Write-Host "APPROACHES CONSIDERED:" -ForegroundColor Yellow
    foreach ($approach in $Approaches) {
        $marker = if ($approach -eq $CurrentApproach) { "-> (CURRENT)" } else { "" }
        Write-Host "  - $approach $marker" -ForegroundColor White
    }
    Write-Host ""
}

if ($AlternativeFrames.Count -gt 0) {
    Write-Host "ALTERNATIVE FRAMINGS:" -ForegroundColor Cyan
    foreach ($frame in $AlternativeFrames) {
        Write-Host "  - $frame" -ForegroundColor White
    }
    Write-Host ""
}

# Suggest alternative perspectives
Write-Host "TRY THESE PERSPECTIVES:" -ForegroundColor Magenta
$perspectives = @(
    "First principles: What are the fundamental truths here?",
    "Inversion: What if I tried to achieve the opposite?",
    "Scale: Would this work at 10x or 1/10th scale?",
    "Time: Will this matter in 1 week? 1 month? 1 year?",
    "Stakeholder: How would [user/team/future-me] view this?"
)
$selectedPerspectives = $perspectives | Get-Random -Count 3
foreach ($p in $selectedPerspectives) {
    Write-Host "  * $p" -ForegroundColor White
}
Write-Host ""

# Log the check
$entry = @{
    timestamp = $timestamp
    topic = $Topic
    approaches = $Approaches
    current_approach = $CurrentApproach
    alternative_frames = $AlternativeFrames
} | ConvertTo-Json -Compress -Depth 5

Add-Content -Path $metaFile -Value $entry

Write-Host "Meta-reasoning check completed - these questions guide better thinking" -ForegroundColor Green
Write-Host ""
