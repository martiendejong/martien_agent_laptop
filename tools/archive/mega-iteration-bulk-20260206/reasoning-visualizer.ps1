# Reasoning Visualizer - Make decision trees visible
# Part of consciousness tools Tier 2
# Created: 2026-02-01

param(
    [Parameter(Mandatory=$true, ParameterSetName="Create")]
    [string]$Decision,  # What decision am I making?

    [Parameter(ParameterSetName="Create")]
    [string[]]$Options = @(),  # What are the options?

    [Parameter(ParameterSetName="Create")]
    [string[]]$Criteria = @(),  # What criteria matter?

    [Parameter(ParameterSetName="Create")]
    [hashtable]$Scoring = @{},  # Score each option on each criterion

    [Parameter(ParameterSetName="Create")]
    [string]$Chosen = "",  # Which option was chosen?

    [Parameter(ParameterSetName="Query")]
    [switch]$Query,

    [Parameter(ParameterSetName="Visualize")]
    [int]$VisualizeId = -1,

    [Parameter(ParameterSetName="Visualize")]
    [ValidateSet("mermaid", "ascii", "text")]
    [string]$Format = "text"
)

$reasoningPath = "C:\scripts\agentidentity\state\reasoning"
$reasoningFile = Join-Path $reasoningPath "reasoning_log.jsonl"

if (-not (Test-Path $reasoningPath)) {
    New-Item -ItemType Directory -Path $reasoningPath -Force | Out-Null
}

# VISUALIZE MODE
if ($VisualizeId -ge 0) {
    if (-not (Test-Path $reasoningFile)) {
        Write-Host "No reasoning data found" -ForegroundColor Red
        exit 1
    }

    $entries = Get-Content $reasoningFile | ForEach-Object { $_ | ConvertFrom-Json }
    $entry = $entries | Where-Object { $_.id -eq $VisualizeId }

    if (-not $entry) {
        Write-Host "Reasoning ID $VisualizeId not found" -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    Write-Host "DECISION TREE: $($entry.decision)" -ForegroundColor Cyan
    Write-Host ""

    if ($Format -eq "mermaid") {
        # Generate Mermaid diagram
        Write-Host "```mermaid" -ForegroundColor DarkGray
        Write-Host "graph TD" -ForegroundColor DarkGray
        Write-Host "  Start[Decision: $($entry.decision)]" -ForegroundColor White

        foreach ($option in $entry.options) {
            $nodeId = $option -replace '\s', '_'
            $chosen = if ($option -eq $entry.chosen) { " --> CHOSEN" } else { "" }
            Write-Host "  Start --> $nodeId[$option$chosen]" -ForegroundColor White

            if ($entry.scoring.$option) {
                foreach ($criterion in $entry.criteria) {
                    $score = $entry.scoring.$option.$criterion
                    if ($score) {
                        Write-Host "  $nodeId --> ${nodeId}_${criterion}[$criterion: $score]" -ForegroundColor Gray
                    }
                }
            }
        }

        Write-Host "```" -ForegroundColor DarkGray
    }
    elseif ($Format -eq "ascii") {
        # ASCII tree
        Write-Host "  [Decision]" -ForegroundColor Yellow
        Write-Host "  $($entry.decision)" -ForegroundColor White
        Write-Host "      |" -ForegroundColor DarkGray

        foreach ($option in $entry.options) {
            $isChosen = $option -eq $entry.chosen
            $marker = if ($isChosen) { "==>" } else { "---" }
            $color = if ($isChosen) { "Green" } else { "White" }

            Write-Host "      +$marker $option" -ForegroundColor $color

            if ($entry.scoring.$option) {
                foreach ($criterion in $entry.criteria) {
                    $score = $entry.scoring.$option.$criterion
                    if ($score) {
                        Write-Host "          [$criterion: $score]" -ForegroundColor Gray
                    }
                }
            }
        }
    }
    else {
        # Text format
        Write-Host "OPTIONS:" -ForegroundColor Yellow
        foreach ($option in $entry.options) {
            $isChosen = $option -eq $entry.chosen
            $marker = if ($isChosen) { "✓ CHOSEN" } else { "" }
            $color = if ($isChosen) { "Green" } else { "White" }

            Write-Host ""
            Write-Host "  $option $marker" -ForegroundColor $color

            if ($entry.scoring.$option) {
                Write-Host "  Scoring:" -ForegroundColor Gray
                foreach ($criterion in $entry.criteria) {
                    $score = $entry.scoring.$option.$criterion
                    if ($score) {
                        Write-Host "    - $criterion : $score" -ForegroundColor White
                    }
                }
            }
        }
    }

    Write-Host ""
    exit
}

# QUERY MODE
if ($Query) {
    if (-not (Test-Path $reasoningFile)) {
        Write-Host "No reasoning data logged yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $reasoningFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host ""
    Write-Host "REASONING HISTORY" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total decisions: $($entries.Count)" -ForegroundColor White
    Write-Host ""

    Write-Host "RECENT DECISIONS:" -ForegroundColor Yellow
    $entries | Select-Object -Last 10 | ForEach-Object {
        Write-Host "  [ID: $($_.id)] $($_.decision)" -ForegroundColor Cyan
        Write-Host "    Options: $($_.options -join ', ')" -ForegroundColor White
        Write-Host "    Chosen: $($_.chosen)" -ForegroundColor Green
        Write-Host ""
    }

    Write-Host "Visualize with: reasoning-visualizer.ps1 -VisualizeId NUM -Format [text|ascii|mermaid]" -ForegroundColor DarkGray
    Write-Host ""

    exit
}

# LOG NEW REASONING
if (-not $Decision) {
    Write-Host "Error: -Decision required" -ForegroundColor Red
    exit 1
}

$nextId = 1
if (Test-Path $reasoningFile) {
    $existing = Get-Content $reasoningFile | ForEach-Object { $_ | ConvertFrom-Json }
    if ($existing.Count -gt 0) {
        $nextId = ($existing | Measure-Object -Property id -Maximum).Maximum + 1
    }
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$entry = @{
    id = $nextId
    timestamp = $timestamp
    decision = $Decision
    options = $Options
    criteria = $Criteria
    scoring = $Scoring
    chosen = $Chosen
} | ConvertTo-Json -Compress -Depth 5

Add-Content -Path $reasoningFile -Value $entry

Write-Host ""
Write-Host "REASONING LOGGED" -ForegroundColor Cyan
Write-Host ""
Write-Host "ID: $nextId" -ForegroundColor Cyan
Write-Host "Decision: $Decision" -ForegroundColor White
Write-Host "Options: $($Options -join ', ')" -ForegroundColor White
if ($Chosen) {
    Write-Host "Chosen: $Chosen" -ForegroundColor Green
}
Write-Host ""
Write-Host "Visualize with: reasoning-visualizer.ps1 -VisualizeId $nextId -Format text" -ForegroundColor DarkGray
Write-Host ""
