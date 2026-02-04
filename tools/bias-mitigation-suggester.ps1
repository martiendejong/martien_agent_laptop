# bias-mitigation-suggester.ps1
# Suggest ways to mitigate detected biases

param(
    [Parameter(Mandatory=$true)]
    [string[]]$DetectedBiases
)

$mitigations = @{
    'confirmation' = @(
        'Actively seek disconfirming evidence',
        'Ask: What would disprove this?',
        'Consider opposite viewpoint'
    )
    'anchoring' = @(
        'Generate multiple independent estimates',
        'Start from different baselines',
        'Delay initial judgment'
    )
    'recency' = @(
        'Review historical data',
        'Weight information by relevance, not recency',
        'Ask: Is this representative or just recent?'
    )
    'authority' = @(
        'Evaluate evidence independently',
        'Consider credentials vs. actual argument',
        'Seek diverse expert opinions'
    )
}

Write-Host "`n💡 BIAS MITIGATION SUGGESTIONS" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

foreach ($bias in $DetectedBiases) {
    if ($mitigations.ContainsKey($bias)) {
        Write-Host "`n$bias bias:" -ForegroundColor Yellow
        foreach ($mitigation in $mitigations[$bias]) {
            Write-Host "  • $mitigation" -ForegroundColor Gray
        }
    }
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Output "Mitigation suggestions provided"
