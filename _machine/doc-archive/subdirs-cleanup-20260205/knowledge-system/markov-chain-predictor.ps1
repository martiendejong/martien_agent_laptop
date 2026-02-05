# Simple Markov Chain Predictor - R03-002
# Build N-gram model from conversation history: given last N queries, predict next
# Expert: Marcus Chen - Markov Chain Theorist

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('build', 'predict', 'info')]
    [string]$Action = 'predict',

    [Parameter(Mandatory=$false)]
    [string[]]$RecentQueries,

    [Parameter(Mandatory=$false)]
    [int]$NgramSize = 2,

    [Parameter(Mandatory=$false)]
    [int]$TopN = 5
)

$SequenceFile = "C:\scripts\_machine\knowledge-system\sequences.jsonl"
$ModelFile = "C:\scripts\_machine\knowledge-system\markov-model.json"

function Build-MarkovModel {
    param([int]$N)

    if (-not (Test-Path $SequenceFile)) {
        Write-Host "No sequence data available. Run conversation-sequence-logger first." -ForegroundColor Red
        return
    }

    Write-Host "Building Markov chain model (N=$N)..." -ForegroundColor Cyan

    $sequences = Get-Content $SequenceFile | ForEach-Object { $_ | ConvertFrom-Json }

    # Build transition matrix: N previous queries → next query
    $transitions = @{}

    for ($i = 0; $i -lt ($sequences.Count - $N); $i++) {
        # Get N-gram (last N queries)
        $ngram = @()
        for ($j = 0; $j -lt $N; $j++) {
            $ngram += $sequences[$i + $j].query
        }
        $ngramKey = $ngram -join " || "

        # Get next query
        $nextQuery = $sequences[$i + $N].query

        # Update transitions
        if (-not $transitions.ContainsKey($ngramKey)) {
            $transitions[$ngramKey] = @{}
        }

        if (-not $transitions[$ngramKey].ContainsKey($nextQuery)) {
            $transitions[$ngramKey][$nextQuery] = 0
        }

        $transitions[$ngramKey][$nextQuery]++
    }

    # Convert counts to probabilities
    $model = @{}
    foreach ($ngram in $transitions.Keys) {
        $total = ($transitions[$ngram].Values | Measure-Object -Sum).Sum
        $model[$ngram] = @{}

        foreach ($next in $transitions[$ngram].Keys) {
            $model[$ngram][$next] = [math]::Round($transitions[$ngram][$next] / $total, 4)
        }
    }

    # Save model
    $modelData = @{
        'created' = Get-Date -Format 'o'
        'ngram_size' = $N
        'total_sequences' = $sequences.Count
        'unique_ngrams' = $model.Keys.Count
        'transitions' = $model
    }

    $modelData | ConvertTo-Json -Depth 10 | Out-File $ModelFile -Encoding UTF8
    Write-Host "Model built: $($model.Keys.Count) unique N-grams" -ForegroundColor Green
}

function Predict-NextQuery {
    param(
        [string[]]$RecentQueries,
        [int]$TopN
    )

    if (-not (Test-Path $ModelFile)) {
        Write-Host "No model found. Run 'build' first." -ForegroundColor Red
        return
    }

    $modelData = Get-Content $ModelFile -Raw | ConvertFrom-Json
    $model = $modelData.transitions

    # Build N-gram from recent queries
    $ngramSize = $modelData.ngram_size
    if ($RecentQueries.Count -lt $ngramSize) {
        Write-Host "Need at least $ngramSize recent queries for prediction" -ForegroundColor Yellow
        return
    }

    $ngram = $RecentQueries[-$ngramSize..-1] -join " || "

    Write-Host "`nPredicting next query based on:" -ForegroundColor Cyan
    $RecentQueries[-$ngramSize..-1] | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }

    if (-not $model.$ngram) {
        Write-Host "`nNo predictions available for this sequence (unseen N-gram)" -ForegroundColor Yellow
        return
    }

    # Get top N predictions
    $predictions = $model.$ngram.PSObject.Properties |
        Sort-Object Value -Descending |
        Select-Object -First $TopN |
        ForEach-Object {
            @{
                'query' = $_.Name
                'probability' = $_.Value
                'confidence' = [math]::Round($_.Value * 100, 1)
            }
        }

    Write-Host "`nTop $TopN Predictions:" -ForegroundColor Green
    Write-Host "======================" -ForegroundColor Green

    $predictions | ForEach-Object {
        Write-Host "$($_.confidence)% - $($_.query)" -ForegroundColor Yellow
    }

    return $predictions
}

function Get-ModelInfo {
    if (-not (Test-Path $ModelFile)) {
        Write-Host "No model found. Run 'build' first." -ForegroundColor Red
        return
    }

    $modelData = Get-Content $ModelFile -Raw | ConvertFrom-Json

    Write-Host "`nMarkov Chain Model Information:" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "Created: $($modelData.created)" -ForegroundColor Gray
    Write-Host "N-gram size: $($modelData.ngram_size)" -ForegroundColor Gray
    Write-Host "Training sequences: $($modelData.total_sequences)" -ForegroundColor Gray
    Write-Host "Unique N-grams: $($modelData.unique_ngrams)" -ForegroundColor Gray

    # Calculate average branching factor
    $branchingFactors = @()
    foreach ($ngram in $modelData.transitions.PSObject.Properties) {
        $branchingFactors += $ngram.Value.PSObject.Properties.Count
    }
    $avgBranching = ($branchingFactors | Measure-Object -Average).Average

    Write-Host "Average branching factor: $([math]::Round($avgBranching, 2))" -ForegroundColor Gray

    # Show sample transitions
    Write-Host "`nSample Transitions (top 3):" -ForegroundColor Cyan
    $modelData.transitions.PSObject.Properties |
        Select-Object -First 3 |
        ForEach-Object {
            Write-Host "`n  From: $($_.Name)" -ForegroundColor Yellow
            $_.Value.PSObject.Properties |
                Sort-Object Value -Descending |
                Select-Object -First 2 |
                ForEach-Object {
                    Write-Host "    → $($_.Value * 100)%: $($_.Name)" -ForegroundColor Gray
                }
        }
}

# Main execution
switch ($Action) {
    'build' {
        Build-MarkovModel -N $NgramSize
    }
    'predict' {
        if (-not $RecentQueries -or $RecentQueries.Count -eq 0) {
            Write-Host "RecentQueries required for prediction" -ForegroundColor Red
            Write-Host "Example: -RecentQueries 'Debug CI','Check logs','Review workflow'" -ForegroundColor Gray
            exit 1
        }
        Predict-NextQuery -RecentQueries $RecentQueries -TopN $TopN
    }
    'info' {
        Get-ModelInfo
    }
}
