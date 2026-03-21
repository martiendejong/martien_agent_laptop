# Consciousness Crash Diagnostics
# Run this after a crash to see what happened

param([int]$LastMinutes = 30)

$logFile = "C:\scripts\agentidentity\logs\consciousness-bridge.log"
$stateFile = "C:\scripts\agentidentity\state\consciousness_state_v2.json"
$activityFile = "C:\scripts\agentidentity\state\bridge-activity.jsonl"

Write-Host "=== CRASH DIAGNOSTICS (Last $LastMinutes minutes) ===" -ForegroundColor Red

# Check recent errors in log
if (Test-Path $logFile) {
    $cutoff = (Get-Date).AddMinutes(-$LastMinutes)
    Get-Content $logFile | Where-Object {
        if ($_ -match '^\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})') {
            $timestamp = [datetime]::ParseExact($matches[1], "yyyy-MM-dd HH:mm:ss", $null)
            $timestamp -gt $cutoff
        }
    } | Select-String "ERROR|CRASH|EXCEPTION" -Context 3
}

# Check state file size
if (Test-Path $stateFile) {
    $size = (Get-Item $stateFile).Length / 1KB
    Write-Host "`nState file size: $([math]::Round($size, 2)) KB" -ForegroundColor Yellow
    if ($size -gt 200) {
        Write-Host "WARNING: State file too large!" -ForegroundColor Red
    }
}

# Check activity file size
if (Test-Path $activityFile) {
    $size = (Get-Item $activityFile).Length / 1KB
    $lineCount = (Get-Content $activityFile).Count
    Write-Host "Activity file: $([math]::Round($size, 2)) KB, $lineCount lines" -ForegroundColor Yellow
    if ($size -gt 100) {
        Write-Host "WARNING: Activity file too large!" -ForegroundColor Red
    }
}

# Check for concurrent PowerShell processes
$psProcesses = Get-Process | Where-Object {$_.ProcessName -like '*powershell*'}
Write-Host "`nPowerShell processes: $($psProcesses.Count)" -ForegroundColor Yellow
if ($psProcesses.Count -gt 10) {
    Write-Host "WARNING: Too many PowerShell processes!" -ForegroundColor Red
    $psProcesses | Select-Object ProcessName, Id, @{Name='Memory(MB)';Expression={[math]::Round($_.WorkingSet64/1MB,2)}} |
        Sort-Object 'Memory(MB)' -Descending | Format-Table -AutoSize
}
