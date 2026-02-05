# Simple Problem Scanner
# Find obvious issues quickly

Write-Host "Running system health scan..." -ForegroundColor Cyan

$problems = @()

# Check for large documentation files
Write-Host "  Checking documentation..." -ForegroundColor Gray
$largeDocs = Get-ChildItem C:\scripts -Filter *.md -Recurse | Where-Object { $_.Length -gt 256KB }
foreach ($doc in $largeDocs) {
    $sizeKB = [math]::Round($doc.Length / 1KB, 1)
    $problems += @{
        category = "docs"
        severity = "medium"
        issue = "Large file: $($doc.Name) ($sizeKB KB)"
        path = $doc.FullName
    }
}

# Check for stale PRs in client-manager
Write-Host "  Checking PRs..." -ForegroundColor Gray
Push-Location C:\Projects\client-manager
$prs = gh pr list --json number,title,updatedAt 2>$null | ConvertFrom-Json
foreach ($pr in $prs) {
    $updated = [DateTime]::Parse($pr.updatedAt)
    $days = (New-TimeSpan -Start $updated -End (Get-Date)).Days
    if ($days -gt 14) {
        $problems += @{
            category = "git"
            severity = "medium"
            issue = "Stale PR #$($pr.number): $($pr.title) ($days days)"
        }
    }
}
Pop-Location

# Check for long-running worktrees
Write-Host "  Checking worktrees..." -ForegroundColor Gray
$poolContent = Get-Content C:\scripts\_machine\worktrees.pool.md
$busyLines = $poolContent | Select-String "BUSY"
foreach ($line in $busyLines) {
    if ($line -match '(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)') {
        $timestamp = [DateTime]::Parse($matches[1])
        $hours = (New-TimeSpan -Start $timestamp -End (Get-Date)).TotalHours
        if ($hours -gt 24) {
            $problems += @{
                category = "worktrees"
                severity = "high"
                issue = "Long-running worktree (busy for $([math]::Round($hours, 1)) hours)"
            }
        }
    }
}

# Check consciousness tracker state
Write-Host "  Checking consciousness state..." -ForegroundColor Gray
$consciousnessFile = "C:\scripts\agentidentity\state\consciousness_tracker.yaml"
if (Test-Path $consciousnessFile) {
    $content = Get-Content $consciousnessFile -Raw
    if ($content -like "*modified*") {
        $problems += @{
            category = "consciousness"
            severity = "low"
            issue = "Consciousness tracker has uncommitted changes"
        }
    }
}

# Save results
$results = @{
    timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    total_issues = $problems.Count
    high = ($problems | Where-Object { $_.severity -eq "high" }).Count
    medium = ($problems | Where-Object { $_.severity -eq "medium" }).Count
    low = ($problems | Where-Object { $_.severity -eq "low" }).Count
    issues = $problems
}

$outputFile = "C:\scripts\_machine\problem-scan-results.json"
$results | ConvertTo-Json -Depth 10 | Set-Content $outputFile

Write-Host "Scan complete" -ForegroundColor Green
Write-Host "  Total issues: $($problems.Count)" -ForegroundColor Gray
Write-Host "  High: $($results.high), Medium: $($results.medium), Low: $($results.low)" -ForegroundColor Gray
Write-Host "  Results saved to: $outputFile" -ForegroundColor Gray
