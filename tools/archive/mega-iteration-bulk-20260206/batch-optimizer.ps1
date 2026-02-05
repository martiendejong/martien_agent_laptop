# batch-optimizer.ps1
# Batches multiple operations for efficiency
param([array]$Operations, [string]$Mode="Parallel")

$results = @()
$startTime = Get-Date

switch($Mode) {
    "Parallel" {
        $jobs = $Operations | ForEach-Object {
            Start-Job -ScriptBlock { Invoke-Expression $using:_ }
        }
        $results = $jobs | Wait-Job | Receive-Job
        $jobs | Remove-Job
    }
    "Sequential" {
        $results = $Operations | ForEach-Object {
            Invoke-Expression $_
        }
    }
    "Optimized" {
        # Group similar operations
        $grouped = $Operations | Group-Object { $_ -replace '\s+.*', '' }
        foreach($group in $grouped) {
            $results += $group.Group | ForEach-Object { Invoke-Expression $_ }
        }
    }
}

$duration = ((Get-Date) - $startTime).TotalSeconds
Write-Host "✅ Processed $($Operations.Count) operations in $([math]::Round($duration, 2))s" -ForegroundColor Green
Write-Host "   Mode: $Mode | Throughput: $([math]::Round($Operations.Count/$duration, 1)) ops/sec" -ForegroundColor Gray

return $results
