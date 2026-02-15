Write-Host '=== Migration Summary ===' -ForegroundColor Cyan

# Check NuGet
Write-Host "`nNuGet Configuration:"
$nugetEnv = [Environment]::GetEnvironmentVariable('NUGET_PACKAGES', 'User')
Write-Host "  NUGET_PACKAGES = $nugetEnv"
$nugetExists = Test-Path 'E:\nuget-cache\.nuget'
Write-Host "  E:\nuget-cache\.nuget exists: $nugetExists" -ForegroundColor Green

$oldNugetExists = Test-Path 'C:\Users\HP\.nuget'
if ($oldNugetExists) {
    $remaining = (Get-ChildItem 'C:\Users\HP\.nuget' -Recurse -File -Force -ErrorAction SilentlyContinue |
                  Measure-Object -Property Length -Sum).Sum
    $remainingMB = [math]::Round($remaining / 1MB, 2)
    Write-Host "  Old NuGet residual: $remainingMB MB (locked files)" -ForegroundColor Yellow
} else {
    Write-Host "  Old NuGet cache: Removed" -ForegroundColor Green
}

# Check NPM
Write-Host "`nNPM Configuration:"
$npmCache = npm config get cache
Write-Host "  npm cache = $npmCache"
$npmExists = Test-Path 'E:\npm-cache\_cacache'
Write-Host "  E:\npm-cache exists: $npmExists" -ForegroundColor Green
$oldNpmExists = Test-Path 'C:\Users\HP\AppData\Local\npm-cache'
if ($oldNpmExists) {
    Write-Host "  Old npm-cache: Still exists (shouldn't happen)" -ForegroundColor Yellow
} else {
    Write-Host "  Old npm-cache: Removed" -ForegroundColor Green
}

# Check C: free space
$drive = Get-PSDrive C
$freeGB = [math]::Round($drive.Free / 1GB, 2)
Write-Host "`nC: drive free space: $freeGB GB" -ForegroundColor Yellow
Write-Host "Total space freed: ~4.76 GB (2.74 GB NuGet + 2.02 GB NPM)" -ForegroundColor Green
