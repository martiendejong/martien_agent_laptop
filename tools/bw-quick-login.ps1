#!/usr/bin/env pwsh
# Quick Bitwarden login helper

$bw = "C:\scripts\tools\bw.exe"

Write-Host "🔐 Bitwarden CLI Login" -ForegroundColor Cyan
Write-Host ""
Write-Host "Voer je Bitwarden email in:" -ForegroundColor Yellow
$email = Read-Host

Write-Host ""
& $bw login $email

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Login succesvol!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Nu vault unlocken..." -ForegroundColor Cyan
    $session = & $bw unlock --raw

    if ($session) {
        $env:BW_SESSION = $session
        Write-Host "✅ Vault unlocked!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Je kunt nu het leaked password script runnen:" -ForegroundColor Yellow
        Write-Host "  .\check-leaked-password.ps1" -ForegroundColor Cyan
    }
}
