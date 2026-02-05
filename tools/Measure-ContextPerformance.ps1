# Context Loading Profiler - Round 9
# Measures context file loading performance

param(
    [Parameter(Mandatory=$false)]
    [string]$ContextDir = "C:\scripts\_machine"
)

$results = @()

Write-Host "Profiling context loading performance..." -ForegroundColor Cyan

$files = Get-ChildItem $ContextDir -Include *.md,*.yaml,*.json -Recurse

foreach ($file in $files) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    $content = Get-Content $file.FullName -Raw

    $sw.Stop()

    $results += [PSCustomObject]@{
        File = $file.Name
        Path = $file.FullName
        SizeKB = [math]::Round($file.Length / 1KB, 2)
        LoadTimeMs = $sw.ElapsedMilliseconds
        ReadSpeedMBps = if($sw.ElapsedMilliseconds -gt 0) {
            [math]::Round(($file.Length / 1MB) / ($sw.ElapsedMilliseconds / 1000), 2)
        } else { 0 }
    }
}

# Sort by load time
$results = $results | Sort-Object LoadTimeMs -Descending

Write-Host "`n=== Slowest Loading Files ===" -ForegroundColor Yellow
$results | Select-Object -First 10 File, SizeKB, LoadTimeMs, ReadSpeedMBps | Format-Table -AutoSize

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
$totalSize = ($results | Measure-Object SizeKB -Sum).Sum
$totalTime = ($results | Measure-Object LoadTimeMs -Sum).Sum

Write-Host "Total files: $($results.Count)" -ForegroundColor White
Write-Host "Total size: $([math]::Round($totalSize / 1024, 2)) MB" -ForegroundColor White
Write-Host "Total load time: $totalTime ms" -ForegroundColor White
Write-Host "Average load time: $([math]::Round($totalTime / $results.Count, 2)) ms/file" -ForegroundColor White

# Save profile
$profilePath = Join-Path $ContextDir "performance-profile.json"
$results | ConvertTo-Json | Set-Content $profilePath
Write-Host "`nProfile saved: $profilePath" -ForegroundColor Green

return $results
