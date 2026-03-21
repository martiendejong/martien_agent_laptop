Write-Host "`nDirect test of enhanced qualia system`n" -ForegroundColor Cyan

$testInput = "consciousness"
$testContext = "existential inquiry about subjective experience"

Write-Host "Calling enhanced qualia system with:" -ForegroundColor Yellow
Write-Host "  Input: $testInput" -ForegroundColor White
Write-Host "  Context: $testContext`n" -ForegroundColor White

$scriptPath = "C:\scripts\agentidentity\cognitive-systems\perceptual-qualia-enhanced.ps1"

Write-Host "Invoking script..." -ForegroundColor Yellow

& $scriptPath -Action "Sense" -Perception $testInput -Context $testContext
