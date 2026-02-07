#!/usr/bin/env powershell
# Simple module load test

$modulePath = "C:\scripts\tools\work-tracking.psm1"

Write-Host "Testing module load..." -ForegroundColor Cyan

try {
    Import-Module $modulePath -Force -ErrorAction Stop
    Write-Host "✅ Module loaded successfully" -ForegroundColor Green

    Write-Host "`nExported functions:" -ForegroundColor Cyan
    Get-Command -Module work-tracking | Format-Table Name, CommandType

    Write-Host "`n✅ Module test passed" -ForegroundColor Green
}
catch {
    Write-Host "❌ Module load failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nFull error:" -ForegroundColor Yellow
    Write-Host $_ | Format-List * | Out-String
    exit 1
}
