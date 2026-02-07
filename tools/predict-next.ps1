# Predict-Next - Proactive next-action suggestions
# Integrates Markov predictor into actual workflow
# Created: 2026-02-07 (Real integration, not theater)

<#
.SYNOPSIS
    Predict-Next - Proactive next-action suggestions

.DESCRIPTION
    Predict-Next - Proactive next-action suggestions

.NOTES
    File: predict-next.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$LastAction,

    [Parameter(Mandatory=$false)]
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"
$markovFile = "C:\scripts\.machine\markov-chain.json"

# Quick prediction (no output, just data)
if (-not (Test-Path $markovFile)) {
    # Silently fail if not built yet
    exit 0
}

try {
    $markov = Get-Content $markovFile -Raw | ConvertFrom-Json

    if (-not $markov.transitions.$LastAction) {
        # No predictions available
        exit 0
    }

    # Get top 3 predictions
    $predictions = @()
    foreach ($next in $markov.transitions.$LastAction.PSObject.Properties) {
        $predictions += @{
            action = $next.Name
            probability = $next.Value.probability
            count = $next.Value.count
        }
    }

    $predictions = $predictions | Sort-Object -Property probability -Descending | Select-Object -First 3

    # Filter out low-confidence (<10%) and self-loops if there are alternatives
    $predictions = $predictions | Where-Object { $_.probability -ge 0.10 -or $predictions.Count -le 1 }

    if ($predictions.Count -eq 0) {
        exit 0
    }

    # Show suggestions if not quiet
    if (-not $Quiet) {
        Write-Host ""
        Write-Host "ðŸ’¡ " -NoNewline -ForegroundColor Cyan
        Write-Host "Likely next: " -NoNewline -ForegroundColor Gray

        $first = $true
        foreach ($pred in $predictions) {
            if (-not $first) {
                Write-Host " | " -NoNewline -ForegroundColor DarkGray
            }
            $pct = [math]::Round($pred.probability * 100, 0)
            Write-Host "$($pred.action) (${pct}%)" -NoNewline -ForegroundColor White
            $first = $false
        }
        Write-Host ""
    }

    # Return data for programmatic use
    return $predictions

} catch {
    # Fail silently - don't break workflow
    exit 0
}
