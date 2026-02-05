# authority-bias-tracker.ps1
# Track over-reliance on authority figures

param(
    [string]$Reasoning,
    [int]$AuthorityReferences = 0
)

$authorityPatterns = @(
    'expert', 'authority', 'well-known', 'famous', 'professor',
    'according to', 'research shows', 'studies indicate'
)

$matches = 0
foreach ($pattern in $authorityPatterns) {
    if ($Reasoning -match $pattern) {
        $matches++
    }
}

if ($matches -gt 3) {
    Write-Host "⚠️  Authority bias: Heavy reliance on authority figures" -ForegroundColor Yellow
} else {
    Write-Host "✅ Balanced use of authority references" -ForegroundColor Green
}

Write-Output "Authority bias tracked: $matches references"
