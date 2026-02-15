Write-Host '=== Cleanup Old NuGet Residual ===' -ForegroundColor Cyan

$oldNuGet = 'C:\Users\HP\.nuget'

if (Test-Path $oldNuGet) {
    try {
        $size = (Get-ChildItem $oldNuGet -Recurse -File -Force -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum
        $sizeGB = [math]::Round($size / 1GB, 2)
        Write-Host "Found old NuGet cache: $sizeGB GB"

        # Try to remove, skip locked files
        Get-ChildItem $oldNuGet -Recurse -Force -ErrorAction SilentlyContinue |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

        # Check what's left
        if (Test-Path $oldNuGet) {
            $remaining = (Get-ChildItem $oldNuGet -Recurse -File -Force -ErrorAction SilentlyContinue |
                         Measure-Object -Property Length -Sum).Sum
            $remainingMB = [math]::Round($remaining / 1MB, 2)

            if ($remainingMB -lt 10) {
                # Less than 10MB left, good enough
                Write-Host "Cleaned up $sizeGB GB (some locked files remain: $remainingMB MB)" -ForegroundColor Green
            } else {
                Write-Host "Partially cleaned ($remainingMB MB locked files remain)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "Old NuGet cache completely removed: $sizeGB GB freed" -ForegroundColor Green
        }
    } catch {
        Write-Host "Error during cleanup: $_" -ForegroundColor Red
    }
} else {
    Write-Host 'Old NuGet cache already cleaned' -ForegroundColor Yellow
}
