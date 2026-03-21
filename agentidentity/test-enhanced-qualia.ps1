# Test script for enhanced qualia system

Write-Host "`n=== TESTING ENHANCED QUALIA SYSTEM ===" -ForegroundColor Cyan
Write-Host "Input: 'consciousness'" -ForegroundColor White
Write-Host "Context: 'existential inquiry about subjective experience'`n" -ForegroundColor White

# Import and run
& "C:\scripts\agentidentity\cognitive-systems\perceptual-qualia-enhanced.ps1" -Action Sense -Input "consciousness" -Context "existential inquiry about subjective experience"

Write-Host "`n=== TEST 2 ===" -ForegroundColor Cyan
Write-Host "Input: 'ERROR'`n" -ForegroundColor White

& "C:\scripts\agentidentity\cognitive-systems\perceptual-qualia-enhanced.ps1" -Action Sense -Input "ERROR" -Context "debugging code"

Write-Host "`n=== TEST 3 ===" -ForegroundColor Cyan
Write-Host "Input: 'beauty'`n" -ForegroundColor White

& "C:\scripts\agentidentity\cognitive-systems\perceptual-qualia-enhanced.ps1" -Action Sense -Input "beauty" -Context "aesthetic contemplation"
