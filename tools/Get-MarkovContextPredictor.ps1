# Markov Chain Context Predictor
# Builds probability matrix of file transitions

param(
    [Parameter(Mandatory=$false)]
    [string]$CurrentFile = "",

    [Parameter(Mandatory=$false)]
    [int]$TopN = 5
)

# Load or initialize transition matrix
$matrixFile = "C:\scripts\_machine\context-transition-matrix.json"

if (Test-Path $matrixFile) {
    $matrix = Get-Content $matrixFile -Raw | ConvertFrom-Json -AsHashtable
} else {
    $matrix = @{}
}

function Update-TransitionMatrix {
    param($From, $To)

    if (-not $matrix.ContainsKey($From)) {
        $matrix[$From] = @{}
    }

    $current = $matrix[$From][$To] ?? 0
    $matrix[$From][$To] = $current + 1

    # Save matrix
    $matrix | ConvertTo-Json -Depth 10 | Set-Content $matrixFile
}

function Get-NextFilePredictions {
    param($CurrentFile, $TopN)

    if (-not $matrix.ContainsKey($CurrentFile)) {
        Write-Host "No historical data for: $CurrentFile" -ForegroundColor Yellow
        return @()
    }

    $transitions = $matrix[$CurrentFile]
    $total = ($transitions.Values | Measure-Object -Sum).Sum

    $predictions = $transitions.GetEnumerator() |
        Sort-Object Value -Descending |
        Select-Object -First $TopN |
        ForEach-Object {
            @{
                file = $_.Key
                probability = [math]::Round($_.Value / $total * 100, 2)
                count = $_.Value
            }
        }

    return $predictions
}

# Execute
if ($CurrentFile) {
    $predictions = Get-NextFilePredictions -CurrentFile $CurrentFile -TopN $TopN

    Write-Host "`n=== Context Predictions for: $CurrentFile ===" -ForegroundColor Cyan
    foreach ($pred in $predictions) {
        Write-Host "  $($pred.probability)% - $($pred.file) ($($pred.count) times)" -ForegroundColor Green
    }

    return $predictions
}
