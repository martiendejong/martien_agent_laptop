# Fix Visual Studio Cache Issues
# Run this script with Visual Studio CLOSED

Write-Host "1. Stopping Visual Studio processes..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.Name -like "*devenv*" -or $_.Name -like "*MSBuild*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host "`n2. Cleaning Hazina..." -ForegroundColor Yellow
cd C:\Projects\hazina
if (Test-Path .vs) {
    Remove-Item -Recurse -Force .vs -ErrorAction SilentlyContinue
    Write-Host "   Removed .vs folder" -ForegroundColor Green
}
Get-ChildItem -Recurse -Directory | Where-Object { $_.Name -eq 'obj' -or $_.Name -eq 'bin' } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "   Removed obj/bin folders" -ForegroundColor Green

Write-Host "`n3. Cleaning ArtRevisionist..." -ForegroundColor Yellow
cd C:\Projects\artrevisionist
if (Test-Path .vs) {
    Remove-Item -Recurse -Force .vs -ErrorAction SilentlyContinue
    Write-Host "   Removed .vs folder" -ForegroundColor Green
}
Get-ChildItem -Recurse -Directory | Where-Object { $_.Name -eq 'obj' -or $_.Name -eq 'bin' } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "   Removed obj/bin folders" -ForegroundColor Green

Write-Host "`n4. Rebuilding Hazina..." -ForegroundColor Yellow
cd C:\Projects\hazina
dotnet clean Hazina.sln -v quiet
dotnet restore Hazina.sln -v quiet
dotnet build Hazina.sln -v quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "   Hazina build SUCCESS" -ForegroundColor Green
} else {
    Write-Host "   Hazina build FAILED" -ForegroundColor Red
}

Write-Host "`n5. Rebuilding ArtRevisionist..." -ForegroundColor Yellow
cd C:\Projects\artrevisionist
dotnet clean ArtRevisionist.local.sln -v quiet
dotnet restore ArtRevisionist.local.sln -v quiet
dotnet build ArtRevisionist.local.sln -v quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ArtRevisionist build SUCCESS" -ForegroundColor Green
} else {
    Write-Host "   ArtRevisionist build FAILED" -ForegroundColor Red
}

Write-Host "`n[DONE] Je kunt Visual Studio nu openen" -ForegroundColor Cyan
Write-Host "Errors zouden weg moeten zijn." -ForegroundColor Cyan
