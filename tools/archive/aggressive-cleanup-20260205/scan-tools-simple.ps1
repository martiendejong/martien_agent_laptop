# Simple Tool Scanner - Quick version without syntax issues
$toolsDir = "C:\scripts\tools"
$analyticsFile = "C:\scripts\_machine\tool-usage-analytics.json"

Write-Host "Scanning tools..." -ForegroundColor Cyan

$tools = Get-ChildItem -Path $toolsDir -Filter "*.ps1" -File
$usageData = @{}

foreach ($tool in $tools) {
    $daysSinceAccess = (New-TimeSpan -Start $tool.LastAccessTime -End (Get-Date)).Days

    $usageData[$tool.Name] = @{
        name = $tool.Name
        lastAccessed = $tool.LastAccessTime.ToString("yyyy-MM-dd")
        daysSinceAccess = $daysSinceAccess
        sizeKB = [math]::Round($tool.Length / 1KB, 1)
    }
}

$usageData | ConvertTo-Json | Set-Content $analyticsFile

Write-Host "Tool count: $($tools.Count)" -ForegroundColor Green
Write-Host "Data saved to: $analyticsFile" -ForegroundColor Green
Write-Host "Oldest access: $((Get-Item ($tools | Sort-Object LastAccessTime | Select-Object -First 1).FullName).LastAccessTime.ToString('yyyy-MM-dd'))" -ForegroundColor Yellow
