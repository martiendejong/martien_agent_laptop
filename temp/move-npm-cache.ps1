Write-Host '=== Move NPM Cache to E: ===' -ForegroundColor Cyan

$oldCache = 'C:\Users\HP\AppData\Local\npm-cache'
$newCache = 'E:\npm-cache'

if (Test-Path $oldCache) {
    try {
        $size = (Get-ChildItem $oldCache -Recurse -File -Force -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum
        $sizeGB = [math]::Round($size / 1GB, 2)
        Write-Host "Found NPM cache: $sizeGB GB"

        # Create target if not exists
        if (-not (Test-Path $newCache)) {
            New-Item -Path $newCache -ItemType Directory -Force | Out-Null
            Write-Host "Created E:\npm-cache directory" -ForegroundColor Green
        }

        # Move cache
        Move-Item $oldCache "$newCache\npm-cache" -Force -ErrorAction Stop
        Write-Host "NPM cache moved to E:\npm-cache: $sizeGB GB" -ForegroundColor Green

    } catch {
        Write-Host "Error moving NPM cache: $_" -ForegroundColor Red
    }
} else {
    Write-Host 'NPM cache already moved or does not exist' -ForegroundColor Yellow
}

# Configure npm
Write-Host "`nConfiguring npm to use E:\npm-cache..." -ForegroundColor Cyan
npm config set cache "E:\npm-cache" --global
$currentCache = npm config get cache
Write-Host "NPM cache location: $currentCache" -ForegroundColor Green
