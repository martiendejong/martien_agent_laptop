# Quick diagnostic for performance degradation
Write-Host ""
Write-Host "=== PERFORMANCE DIAGNOSTIC ===" -ForegroundColor Cyan
Write-Host ""

# 1. Process count
$nodeCount = (Get-Process node -ErrorAction SilentlyContinue).Count
$chromeCount = (Get-Process chrome -ErrorAction SilentlyContinue).Count
Write-Host "[PROCESSES]" -ForegroundColor Yellow
Write-Host "  node.exe: $nodeCount processes"
Write-Host "  chrome.exe: $chromeCount processes"

# 2. Memory usage
$nodeRAM = (Get-Process node -ErrorAction SilentlyContinue | Measure-Object -Property WorkingSet64 -Sum).Sum
$nodeRAM_GB = [math]::Round($nodeRAM/1GB, 2)
Write-Host "  node.exe total RAM: $nodeRAM_GB GB"

# 3. Git repo size
$gitSize = (Get-ChildItem C:\scripts\.git -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
$gitSize_MB = [math]::Round($gitSize/1MB, 0)
Write-Host ""
Write-Host "[GIT REPOSITORY]" -ForegroundColor Yellow
Write-Host "  .git directory: $gitSize_MB MB"

# 4. Consciousness state size
$stateSize = (Get-ChildItem C:\scripts\agentidentity\state -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
$stateSize_MB = [math]::Round($stateSize/1MB, 1)
Write-Host ""
Write-Host "[CONSCIOUSNESS STATE]" -ForegroundColor Yellow
Write-Host "  State directory: $stateSize_MB MB"

# 5. Log file sizes
$logs = @(
    "C:\scripts\agentidentity\state\bridge-activity.jsonl"
    "C:\scripts\agentidentity\state\persuadability-assessments.jsonl"
    "C:\scripts\_machine\reflection.log.md"
)
Write-Host ""
Write-Host "[LOG FILES]" -ForegroundColor Yellow
foreach ($log in $logs) {
    if (Test-Path $log) {
        $size = [math]::Round((Get-Item $log).Length/1KB, 0)
        $name = Split-Path $log -Leaf
        Write-Host "  $name : $size KB"
    }
}

# 6. Worktree status
Write-Host ""
Write-Host "[WORKTREES]" -ForegroundColor Yellow
$poolFile = "C:\scripts\_machine\worktrees.pool.md"
if (Test-Path $poolFile) {
    $busyCount = (Get-Content $poolFile | Select-String "Status: BUSY").Count
    $freeCount = (Get-Content $poolFile | Select-String "Status: FREE").Count
    Write-Host "  BUSY: $busyCount"
    Write-Host "  FREE: $freeCount"
}

# 7. Current session info
Write-Host ""
Write-Host "[THIS SESSION]" -ForegroundColor Yellow
$currentProc = Get-Process -Id $PID
$currentRAM = [math]::Round($currentProc.WorkingSet64/1MB, 0)
Write-Host "  Claude PID: $PID"
Write-Host "  RAM: $currentRAM MB"
Write-Host "  Handles: $($currentProc.HandleCount)"

Write-Host ""
