# Fix ClickHub PowerShell 5.1 Compatibility Issues
# Version: 1.0.0
# Created: 2026-02-28

Write-Host "Fixing PowerShell 5.1 compatibility issues..." -ForegroundColor Yellow

# Fix 1: Remove -Verbose parameters from all scripts (conflicts with common parameter)
$scriptsToFix = @(
    "C:\scripts\tools\clickhub-learning-engine.ps1",
    "C:\scripts\tools\clickhub-crash-recovery.ps1",
    "C:\scripts\tools\clickhub-orchestrator.ps1"
)

foreach ($scriptPath in $scriptsToFix) {
    $content = Get-Content $scriptPath -Raw

    # Remove -Verbose parameter
    $content = $content -replace ',\s+\[Parameter\(Mandatory=\$false\)\]\s+\[switch\]\$Verbose', ''

    Set-Content $scriptPath -Value $content -NoNewline
    Write-Host "[FIXED] Removed -Verbose parameter from $(Split-Path $scriptPath -Leaf)" -ForegroundColor Green
}

# Fix 2: Replace Join-String with -join in notifications.ps1
$notificationsPath = "C:\scripts\tools\clickhub-notifications.ps1"
$content = Get-Content $notificationsPath -Raw

# Replace Join-String with -join
$content = $content -replace '\| Join-String -Separator "``n"', '-join "`n"'

Set-Content $notificationsPath -Value $content -NoNewline
Write-Host "[FIXED] Replaced Join-String with -join in clickhub-notifications.ps1" -ForegroundColor Green

# Fix 3: Fix metrics dashboard string interpolation issue
$metricsPath = "C:\scripts\tools\clickhub-metrics-dashboard.ps1"
$content = Get-Content $metricsPath -Raw

# Fix the problematic line by using concatenation instead of interpolation
$content = $content -replace 'Write-Host "║          \$today\s+║" -ForegroundColor Cyan',
    'Write-Host ("║          " + $today + (" " * (44 - $today.Length)) + "║") -ForegroundColor Cyan'

Set-Content $metricsPath -Value $content -NoNewline
Write-Host "[FIXED] Fixed string interpolation in clickhub-metrics-dashboard.ps1" -ForegroundColor Green

# Fix 4: Ensure learning data has correct structure
$learningDataPath = "C:\scripts\_machine\clickhub-learning.json"
if (Test-Path $learningDataPath) {
    $learningData = Get-Content $learningDataPath -Raw | ConvertFrom-Json

    # Ensure all required keys exist
    $requiredKeys = @("version", "tasks", "failure_patterns", "success_patterns", "projects", "agents", "priority_weights")

    $updated = $false
    foreach ($key in $requiredKeys) {
        if (-not ($learningData.PSObject.Properties.Name -contains $key)) {
            Add-Member -InputObject $learningData -MemberType NoteProperty -Name $key -Value @{} -Force
            $updated = $true
        }
    }

    if ($updated) {
        $learningData | ConvertTo-Json -Depth 10 | Set-Content $learningDataPath
        Write-Host "[FIXED] Updated learning data structure" -ForegroundColor Green
    }
    else {
        Write-Host "[OK] Learning data structure already correct" -ForegroundColor Yellow
    }
}

Write-Host "`nAll compatibility issues fixed!" -ForegroundColor Green
