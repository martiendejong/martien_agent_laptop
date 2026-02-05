# recency-bias-detector.ps1
# Detect over-weighting of recent information

param(
    [string]$Statement,
    [switch]$Detect
)

$recencyPatterns = @(
    'recently', 'just now', 'latest', 'newest', 'most recent',
    'yesterday', 'last week', 'this week', 'currently'
)

if ($Detect) {
    $matchCount = 0
    foreach ($pattern in $recencyPatterns) {
        if ($Statement -match $pattern) {
            $matchCount++
        }
    }

    if ($matchCount -gt 2) {
        Write-Host "⚠️  Recency bias detected: Over-emphasizing recent information" -ForegroundColor Yellow
    } else {
        Write-Host "✅ No significant recency bias detected" -ForegroundColor Green
    }
}

Write-Output "Recency bias detection complete"
