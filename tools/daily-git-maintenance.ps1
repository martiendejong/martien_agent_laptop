# Daily Git Maintenance - Run gc if not done today
$gcMarker = "C:\scripts\.git\last-gc-date.txt"
$today = Get-Date -Format "yyyy-MM-dd"

# Check if we already ran gc today
$needsGC = $true
if (Test-Path $gcMarker) {
    $lastGC = Get-Content $gcMarker -Raw
    if ($lastGC.Trim() -eq $today) {
        $needsGC = $false
    }
}

if ($needsGC) {
    Write-Host "Running daily git maintenance..." -ForegroundColor Yellow

    # Use --auto: only gc if repo needs it (faster than --aggressive)
    $before = (Get-ChildItem C:\scripts\.git -Recurse -File -ErrorAction SilentlyContinue |
               Measure-Object -Property Length -Sum).Sum / 1MB

    git gc --auto 2>&1 | Out-Null

    $after = (Get-ChildItem C:\scripts\.git -Recurse -File -ErrorAction SilentlyContinue |
              Measure-Object -Property Length -Sum).Sum / 1MB

    $saved = [math]::Round($before - $after, 0)

    if ($saved -gt 0) {
        Write-Host "  Git gc complete (saved $saved MB)" -ForegroundColor Green
    } else {
        Write-Host "  Git gc skipped (repo already optimal)" -ForegroundColor Gray
    }

    # Mark as done today
    $today | Out-File $gcMarker -Encoding ASCII
} else {
    Write-Host "Git maintenance already done today" -ForegroundColor Gray
}
