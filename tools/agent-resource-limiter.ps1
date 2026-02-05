# agent-resource-limiter.ps1
# Enforces CPU and memory limits on agent processes
# Prevents single agent from consuming all system resources

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Set", "Monitor", "Kill", "Status")]
    [string]$Action,

    [int]$ProcessId = 0,
    [int]$MaxCPUPercent = 80,      # Max CPU usage per agent
    [int]$MaxMemoryMB = 2048,       # Max memory per agent (2GB)
    [int]$CheckIntervalSeconds = 5,
    [switch]$Continuous
)

$script:LimitsFile = "C:\scripts\_machine\resource-limits.json"
$script:ViolationsFile = "C:\scripts\_machine\resource-violations.jsonl"

function Get-ResourceLimits {
    if (Test-Path $script:LimitsFile) {
        return Get-Content $script:LimitsFile -Raw | ConvertFrom-Json
    }
    return @{
        Processes = @{}
        GlobalLimits = @{
            MaxCPUPercent = 80
            MaxMemoryMB = 2048
        }
    }
}

function Set-ResourceLimits {
    param($Limits)
    $Limits | ConvertTo-Json -Depth 10 | Set-Content -Path $script:LimitsFile -Force
}

function Set-ProcessLimit {
    param(
        [int]$ProcessId,
        [int]$MaxCPU,
        [int]$MaxMemoryMB
    )

    $limits = Get-ResourceLimits

    try {
        $process = Get-Process -Id $ProcessId -ErrorAction Stop

        $limits.Processes[$ProcessId.ToString()] = @{
            Name = $process.Name
            MaxCPUPercent = $MaxCPU
            MaxMemoryMB = $MaxMemoryMB
            SetAt = (Get-Date).ToString("o")
            Violations = 0
        }

        Set-ResourceLimits -Limits $limits

        Write-Host "✅ Resource limits set for process $ProcessId ($($process.Name))" -ForegroundColor Green
        Write-Host "   Max CPU: $MaxCPU%" -ForegroundColor Gray
        Write-Host "   Max Memory: $MaxMemoryMB MB" -ForegroundColor Gray

        return $true
    }
    catch {
        Write-Host "❌ Process $ProcessId not found" -ForegroundColor Red
        return $false
    }
}

function Get-ProcessResourceUsage {
    param([int]$ProcessId)

    try {
        $process = Get-Process -Id $ProcessId -ErrorAction Stop

        # Get CPU usage (averaged over 1 second)
        $cpu1 = $process.CPU
        Start-Sleep -Seconds 1
        $process = Get-Process -Id $ProcessId -ErrorAction Stop
        $cpu2 = $process.CPU
        $cpuUsage = ($cpu2 - $cpu1) * 100 / [Environment]::ProcessorCount

        # Get memory usage in MB
        $memoryMB = [math]::Round($process.WorkingSet64 / 1MB, 2)

        return @{
            ProcessId = $ProcessId
            Name = $process.Name
            CPUPercent = [math]::Round($cpuUsage, 2)
            MemoryMB = $memoryMB
            Threads = $process.Threads.Count
            Handles = $process.HandleCount
        }
    }
    catch {
        return $null
    }
}

function Test-ResourceViolation {
    param(
        [hashtable]$Usage,
        [int]$MaxCPU,
        [int]$MaxMemory
    )

    $violations = @()

    if ($Usage.CPUPercent -gt $MaxCPU) {
        $violations += "CPU: $($Usage.CPUPercent)% > $MaxCPU%"
    }

    if ($Usage.MemoryMB -gt $MaxMemory) {
        $violations += "Memory: $($Usage.MemoryMB) MB > $MaxMemory MB"
    }

    return $violations
}

function Write-ViolationLog {
    param(
        [int]$ProcessId,
        [string]$ProcessName,
        [string[]]$Violations,
        [hashtable]$Usage
    )

    $entry = @{
        Timestamp = (Get-Date).ToString("o")
        ProcessId = $ProcessId
        ProcessName = $ProcessName
        Violations = $Violations
        CPUPercent = $Usage.CPUPercent
        MemoryMB = $Usage.MemoryMB
        Action = "Warning"
    }

    $json = $entry | ConvertTo-Json -Compress
    Add-Content -Path $script:ViolationsFile -Value $json

    # Also log to error handler
    & "C:\scripts\tools\error-handler.ps1" -Action Log `
        -ErrorMessage "Resource limit violation: $($Violations -join ', ')" `
        -Context "Process: $ProcessName (PID $ProcessId)" `
        -Component "Agent-Resource-Limiter" `
        -Severity "Medium"
}

function Stop-ViolatingProcess {
    param([int]$ProcessId, [string]$Reason)

    try {
        $process = Get-Process -Id $ProcessId -ErrorAction Stop

        Write-Host "🛑 Killing process $ProcessId ($($process.Name)): $Reason" -ForegroundColor Red

        # Log termination
        $entry = @{
            Timestamp = (Get-Date).ToString("o")
            ProcessId = $ProcessId
            ProcessName = $process.Name
            Reason = $Reason
            Action = "Killed"
        }
        $json = $entry | ConvertTo-Json -Compress
        Add-Content -Path $script:ViolationsFile -Value $json

        $process.Kill()

        Write-Host "✅ Process terminated" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Failed to kill process: $_" -ForegroundColor Red
        return $false
    }
}

function Invoke-ResourceMonitoring {
    param([int]$CheckInterval, [switch]$Continuous)

    $limits = Get-ResourceLimits

    Write-Host "👀 Starting resource monitoring..." -ForegroundColor Cyan
    Write-Host "   Check interval: ${CheckInterval}s" -ForegroundColor Gray
    Write-Host "   Mode: $(if ($Continuous) { 'Continuous' } else { 'Single check' })" -ForegroundColor Gray
    Write-Host ""

    do {
        foreach ($pidStr in $limits.Processes.Keys) {
            $pid = [int]$pidStr
            $processLimits = $limits.Processes[$pidStr]

            $usage = Get-ProcessResourceUsage -ProcessId $pid

            if ($usage) {
                $violations = Test-ResourceViolation `
                    -Usage $usage `
                    -MaxCPU $processLimits.MaxCPUPercent `
                    -MaxMemory $processLimits.MaxMemoryMB

                if ($violations.Count -gt 0) {
                    Write-Host "⚠️ VIOLATION: $($usage.Name) (PID $pid)" -ForegroundColor Red
                    foreach ($violation in $violations) {
                        Write-Host "   $violation" -ForegroundColor Red
                    }

                    # Log violation
                    Write-ViolationLog -ProcessId $pid -ProcessName $usage.Name -Violations $violations -Usage $usage

                    # Increment violation count
                    $processLimits.Violations++
                    Set-ResourceLimits -Limits $limits

                    # Kill if too many violations (3 strikes)
                    if ($processLimits.Violations -ge 3) {
                        Write-Host "   💀 3 strikes - terminating process" -ForegroundColor Red
                        Stop-ViolatingProcess -ProcessId $pid -Reason "3 resource limit violations"
                    }
                } else {
                    Write-Host "✅ $($usage.Name) (PID $pid): CPU $($usage.CPUPercent)%, Memory $($usage.MemoryMB) MB" -ForegroundColor Green
                }
            } else {
                Write-Host "⚠️ Process $pid no longer running" -ForegroundColor Yellow
                # Remove from limits
                $limits.Processes.Remove($pidStr)
                Set-ResourceLimits -Limits $limits
            }
        }

        if ($Continuous) {
            Write-Host ""
            Start-Sleep -Seconds $CheckInterval
        }
    } while ($Continuous)
}

function Show-ResourceStatus {
    $limits = Get-ResourceLimits

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "📊 RESOURCE LIMITER STATUS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

    Write-Host "`n🌐 Global Limits:" -ForegroundColor Cyan
    Write-Host "   Max CPU: $($limits.GlobalLimits.MaxCPUPercent)%" -ForegroundColor White
    Write-Host "   Max Memory: $($limits.GlobalLimits.MaxMemoryMB) MB" -ForegroundColor White

    Write-Host "`n🔒 Monitored Processes: $($limits.Processes.Count)" -ForegroundColor Cyan

    if ($limits.Processes.Count -eq 0) {
        Write-Host "   No processes currently monitored" -ForegroundColor Gray
    } else {
        foreach ($pidStr in $limits.Processes.Keys) {
            $pid = [int]$pidStr
            $processLimits = $limits.Processes[$pidStr]

            $usage = Get-ProcessResourceUsage -ProcessId $pid

            if ($usage) {
                $cpuStatus = if ($usage.CPUPercent -gt $processLimits.MaxCPUPercent) { "❌" } else { "✅" }
                $memStatus = if ($usage.MemoryMB -gt $processLimits.MaxMemoryMB) { "❌" } else { "✅" }

                Write-Host "`n   📍 $($usage.Name) (PID $pid)" -ForegroundColor Yellow
                Write-Host "      $cpuStatus CPU: $($usage.CPUPercent)% / $($processLimits.MaxCPUPercent)%" -ForegroundColor Gray
                Write-Host "      $memStatus Memory: $($usage.MemoryMB) MB / $($processLimits.MaxMemoryMB) MB" -ForegroundColor Gray
                Write-Host "      Violations: $($processLimits.Violations)" -ForegroundColor Gray
            } else {
                Write-Host "`n   ⚠️ Process $pid (not running)" -ForegroundColor DarkGray
            }
        }
    }

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

# Main logic
switch ($Action) {
    "Set" {
        if ($ProcessId -eq 0) {
            # Use current process
            $ProcessId = $PID
        }

        $success = Set-ProcessLimit -ProcessId $ProcessId -MaxCPU $MaxCPUPercent -MaxMemoryMB $MaxMemoryMB

        exit $(if ($success) { 0 } else { 1 })
    }

    "Monitor" {
        Invoke-ResourceMonitoring -CheckInterval $CheckIntervalSeconds -Continuous:$Continuous
        exit 0
    }

    "Kill" {
        if ($ProcessId -eq 0) {
            Write-Host "❌ Kill requires -ProcessId parameter" -ForegroundColor Red
            exit 1
        }

        $success = Stop-ViolatingProcess -ProcessId $ProcessId -Reason "Manual termination"
        exit $(if ($success) { 0 } else { 1 })
    }

    "Status" {
        Show-ResourceStatus
        exit 0
    }
}
