Write-Host 'Checking what changed...' -ForegroundColor Cyan

# Check if old Temp is still there
if (Test-Path 'C:\Users\HP\AppData\Local\Temp') {
    $tempSize = (Get-ChildItem 'C:\Users\HP\AppData\Local\Temp' -Recurse -File -Force -ErrorAction SilentlyContinue |
                  Measure-Object -Property Length -Sum).Sum
    $tempGB = [math]::Round($tempSize / 1GB, 2)
    Write-Host "Old Temp still exists: $tempGB GB"
} else {
    Write-Host 'Old Temp directory was removed!' -ForegroundColor Green
}

# Check C: drive details
$drive = Get-PSDrive C
$usedGB = [math]::Round($drive.Used / 1GB, 2)
$freeGB = [math]::Round($drive.Free / 1GB, 2)
$totalGB = [math]::Round(($drive.Used + $drive.Free) / 1GB, 2)

Write-Host "`nC: Drive Status:"
Write-Host "  Total: $totalGB GB"
Write-Host "  Used: $usedGB GB"
Write-Host "  Free: $freeGB GB" -ForegroundColor Green
Write-Host "`nSpace gained from 11.5 GB baseline: $([math]::Round($freeGB - 11.5, 2)) GB"
