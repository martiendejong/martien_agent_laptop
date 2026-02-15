# Find largest bin/obj directories
Write-Host "=== Build Artifacts (bin/obj) ===" -ForegroundColor Cyan

$binFolders = Get-ChildItem C:\Projects -Recurse -Directory -Filter 'bin' -Force -ErrorAction SilentlyContinue
$objFolders = Get-ChildItem C:\Projects -Recurse -Directory -Filter 'obj' -Force -ErrorAction SilentlyContinue

$totalSize = 0

foreach ($folder in ($binFolders + $objFolders)) {
    try {
        $size = (Get-ChildItem $folder.FullName -Recurse -File -Force -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum
        if ($size -gt 0) {
            $totalSize += $size
        }
    } catch {}
}

$totalGB = [math]::Round($totalSize / 1GB, 2)
Write-Host "Total build artifacts: $totalGB GB" -ForegroundColor Yellow

# Now check for large node_modules
Write-Host "`n=== Node Modules ===" -ForegroundColor Cyan
$nodeModules = Get-ChildItem C:\Projects -Recurse -Directory -Filter 'node_modules' -Depth 2 -Force -ErrorAction SilentlyContinue

$nodeTotal = 0
foreach ($nm in $nodeModules) {
    try {
        $size = (Get-ChildItem $nm.FullName -Recurse -File -Force -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum
        if ($size -gt 100MB) {
            $sizeGB = [math]::Round($size / 1GB, 2)
            Write-Host "$($nm.Parent.Name): $sizeGB GB"
            $nodeTotal += $size
        }
    } catch {}
}

$nodeTotalGB = [math]::Round($nodeTotal / 1GB, 2)
Write-Host "Total node_modules: $nodeTotalGB GB" -ForegroundColor Yellow
