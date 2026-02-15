Write-Host '=== Build Artifacts Cleanup ===' -ForegroundColor Cyan

# Find all bin and obj directories
Write-Host "`nScanning C:\Projects for build artifacts..."
$binDirs = Get-ChildItem C:\Projects -Recurse -Directory -Filter 'bin' -Force -ErrorAction SilentlyContinue
$objDirs = Get-ChildItem C:\Projects -Recurse -Directory -Filter 'obj' -Force -ErrorAction SilentlyContinue

$allDirs = $binDirs + $objDirs

Write-Host "Found $($allDirs.Count) directories to clean"

# Calculate total size before cleanup
$totalSize = 0
foreach ($dir in $allDirs) {
    try {
        $size = (Get-ChildItem $dir.FullName -Recurse -File -Force -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum
        if ($size) {
            $totalSize += $size
        }
    } catch {}
}

$totalGB = [math]::Round($totalSize / 1GB, 2)
Write-Host "Total size to remove: $totalGB GB"

# Remove directories
Write-Host "`nRemoving build artifacts..."
$removed = 0
$failed = 0

foreach ($dir in $allDirs) {
    try {
        Remove-Item $dir.FullName -Recurse -Force -ErrorAction Stop
        $removed++
    } catch {
        $failed++
        # Silent fail on locked files
    }
}

Write-Host "`nCleanup complete:" -ForegroundColor Green
Write-Host "  Removed: $removed directories"
if ($failed -gt 0) {
    Write-Host "  Skipped: $failed directories (locked files)" -ForegroundColor Yellow
}
Write-Host "  Space freed: ~$totalGB GB" -ForegroundColor Green

Write-Host "`n⚠️  NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Rebuild client-manager: cd C:\Projects\client-manager && dotnet build --configuration Release"
Write-Host "  2. Rebuild hazina: cd C:\Projects\hazina && dotnet build --configuration Release"
Write-Host "  3. Rebuild any other active projects as needed"
