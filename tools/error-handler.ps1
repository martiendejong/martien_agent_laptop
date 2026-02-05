# error-handler.ps1
# Centralized error handling with automatic recovery
# Catches errors, logs them, attempts recovery, and alerts when needed

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Catch", "Log", "Recover", "Alert", "Query")]
    [string]$Action,

    [string]$ErrorMessage = "",
    [string]$Context = "",
    [string]$Component = "",
    [ValidateSet("Low", "Medium", "High", "Critical")]
    [string]$Severity = "Medium",
    [switch]$AttemptRecovery,
    [int]$Hours = 24  # For Query action
)

$script:ErrorLogFile = "C:\scripts\_machine\errors.jsonl"
$script:RecoveryLog = "C:\scripts\_machine\recovery.log"
$script:AlertThreshold = @{
    Low = 10
    Medium = 5
    High = 2
    Critical = 1
}

# Ensure log files exist
if (-not (Test-Path $script:ErrorLogFile)) {
    New-Item -ItemType File -Path $script:ErrorLogFile -Force | Out-Null
}
if (-not (Test-Path $script:RecoveryLog)) {
    New-Item -ItemType File -Path $script:RecoveryLog -Force | Out-Null
}

function Write-ErrorLog {
    param(
        [string]$Message,
        [string]$Context,
        [string]$Component,
        [string]$Severity,
        [string]$StackTrace = "",
        [hashtable]$Metadata = @{}
    )

    $errorEntry = @{
        Timestamp = (Get-Date).ToString("o")
        Message = $Message
        Context = $Context
        Component = $Component
        Severity = $Severity
        StackTrace = $StackTrace
        ProcessId = $PID
        MachineName = $env:COMPUTERNAME
        Metadata = $Metadata
    }

    $json = $errorEntry | ConvertTo-Json -Compress
    Add-Content -Path $script:ErrorLogFile -Value $json

    # Also log to reflection if high severity
    if ($Severity -in @("High", "Critical")) {
        $reflectionFile = "C:\scripts\_machine\reflection.log.md"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $entry = @"

## $timestamp - [ERROR-$Severity] $Component

**Error:** $Message

**Context:** $Context

**Recovery:** $(if ($AttemptRecovery) { "Attempted" } else { "Not attempted" })

---

"@
        Add-Content -Path $reflectionFile -Value $entry
    }

    return $errorEntry
}

function Invoke-RecoveryStrategy {
    param(
        [hashtable]$ErrorEntry
    )

    $component = $ErrorEntry.Component
    $message = $ErrorEntry.Message
    $recovered = $false
    $strategy = ""

    # Recovery strategies based on component/error type
    switch -Wildcard ($component) {
        "*worktree*" {
            # Worktree-related errors
            if ($message -match "lock") {
                $strategy = "Clean stale locks"
                try {
                    & "C:\scripts\tools\worktree-lock.ps1" -Action Clean -Timeout 300 -Force
                    $recovered = $true
                }
                catch {
                    $recovered = $false
                }
            }
            elseif ($message -match "allocation") {
                $strategy = "Reset worktree pool"
                # Could implement pool reset logic here
                $recovered = $false
            }
        }

        "*git*" {
            # Git-related errors
            if ($message -match "merge conflict") {
                $strategy = "Abort merge and reset"
                # Could implement conflict resolution here
                $recovered = $false
            }
            elseif ($message -match "detached HEAD") {
                $strategy = "Checkout develop branch"
                try {
                    git checkout develop
                    $recovered = $true
                }
                catch {
                    $recovered = $false
                }
            }
        }

        "*file*" {
            # File-related errors
            if ($message -match "file not found") {
                $strategy = "Create missing file"
                # Could implement file recreation here
                $recovered = $false
            }
            elseif ($message -match "access denied") {
                $strategy = "Check file permissions"
                $recovered = $false
            }
        }

        "*network*" {
            # Network-related errors
            if ($message -match "timeout|connection") {
                $strategy = "Retry with exponential backoff"
                # Could implement retry logic here
                $recovered = $false
            }
        }

        default {
            $strategy = "No automatic recovery available"
            $recovered = $false
        }
    }

    # Log recovery attempt
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = @"
[$timestamp] RECOVERY_ATTEMPT
  Component: $component
  Error: $message
  Strategy: $strategy
  Result: $(if ($recovered) { "SUCCESS" } else { "FAILED" })

"@
    Add-Content -Path $script:RecoveryLog -Value $logEntry

    return @{
        Recovered = $recovered
        Strategy = $strategy
    }
}

function Test-AlertThreshold {
    param([string]$Severity, [int]$Hours)

    # Count errors of this severity in last N hours
    if (-not (Test-Path $script:ErrorLogFile)) {
        return $false
    }

    $cutoff = (Get-Date).AddHours(-$Hours)
    $content = Get-Content $script:ErrorLogFile

    $recentErrors = $content | ForEach-Object {
        $entry = $_ | ConvertFrom-Json
        if ([datetime]$entry.Timestamp -gt $cutoff -and $entry.Severity -eq $Severity) {
            $entry
        }
    } | Where-Object { $_ -ne $null }

    $count = $recentErrors.Count
    $threshold = $script:AlertThreshold[$Severity]

    return $count -ge $threshold
}

function Send-Alert {
    param(
        [string]$Severity,
        [string]$Message,
        [int]$ErrorCount
    )

    # For now, just write to console and reflection log
    # Could integrate with Windows notifications, email, Slack, etc.

    Write-Host "`n" -NoNewline
    Write-Host "🚨 ALERT: $Severity ERROR THRESHOLD REACHED 🚨" -ForegroundColor Red -BackgroundColor Yellow
    Write-Host "   $ErrorCount errors in last 24 hours" -ForegroundColor Red
    Write-Host "   Latest: $Message" -ForegroundColor Red
    Write-Host "`n" -NoNewline

    # Log to reflection
    $reflectionFile = "C:\scripts\_machine\reflection.log.md"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = @"

## $timestamp - [ALERT] $Severity Error Threshold Exceeded

**Threshold:** $($script:AlertThreshold[$Severity]) errors in 24h
**Actual:** $ErrorCount errors

**Latest Error:** $Message

**Action Required:** Investigate root cause and implement systematic fix.

---

"@
    Add-Content -Path $reflectionFile -Value $entry
}

function Get-RecentErrors {
    param([int]$Hours)

    if (-not (Test-Path $script:ErrorLogFile)) {
        return @()
    }

    $cutoff = (Get-Date).AddHours(-$Hours)
    $content = Get-Content $script:ErrorLogFile

    $errors = $content | ForEach-Object {
        $entry = $_ | ConvertFrom-Json
        if ([datetime]$entry.Timestamp -gt $cutoff) {
            $entry
        }
    } | Where-Object { $_ -ne $null }

    return $errors
}

# Main logic
switch ($Action) {
    "Catch" {
        if (-not $ErrorMessage) {
            Write-Host "❌ Catch requires -ErrorMessage parameter" -ForegroundColor Red
            exit 1
        }

        Write-Host "📝 Logging error..." -ForegroundColor Yellow

        # Get stack trace if available
        $stackTrace = ""
        if ($Error.Count -gt 0) {
            $stackTrace = $Error[0].ScriptStackTrace
        }

        # Log error
        $errorEntry = Write-ErrorLog -Message $ErrorMessage -Context $Context -Component $Component -Severity $Severity -StackTrace $stackTrace

        Write-Host "✅ Error logged: $($errorEntry.Timestamp)" -ForegroundColor Green

        # Attempt recovery if requested
        if ($AttemptRecovery) {
            Write-Host "🔧 Attempting recovery..." -ForegroundColor Cyan
            $recovery = Invoke-RecoveryStrategy -ErrorEntry $errorEntry

            if ($recovery.Recovered) {
                Write-Host "✅ Recovery successful: $($recovery.Strategy)" -ForegroundColor Green
            } else {
                Write-Host "❌ Recovery failed: $($recovery.Strategy)" -ForegroundColor Red
            }
        }

        # Check if alert threshold reached
        if (Test-AlertThreshold -Severity $Severity -Hours 24) {
            $recentCount = (Get-RecentErrors -Hours 24 | Where-Object { $_.Severity -eq $Severity }).Count
            Send-Alert -Severity $Severity -Message $ErrorMessage -ErrorCount $recentCount
        }

        exit 0
    }

    "Log" {
        if (-not $ErrorMessage) {
            Write-Host "❌ Log requires -ErrorMessage parameter" -ForegroundColor Red
            exit 1
        }

        Write-ErrorLog -Message $ErrorMessage -Context $Context -Component $Component -Severity $Severity | Out-Null
        Write-Host "✅ Error logged" -ForegroundColor Green
        exit 0
    }

    "Recover" {
        Write-Host "🔧 Running recovery strategies..." -ForegroundColor Cyan

        # Get recent unrecovered errors
        $errors = Get-RecentErrors -Hours 24
        $recoveredCount = 0

        foreach ($error in $errors) {
            $recovery = Invoke-RecoveryStrategy -ErrorEntry $error
            if ($recovery.Recovered) {
                $recoveredCount++
            }
        }

        Write-Host "✅ Recovery complete: $recoveredCount/$($errors.Count) errors resolved" -ForegroundColor Green
        exit 0
    }

    "Alert" {
        Write-Host "🔔 Checking alert thresholds..." -ForegroundColor Cyan

        $alerts = @()
        foreach ($severity in @("Critical", "High", "Medium", "Low")) {
            if (Test-AlertThreshold -Severity $severity -Hours 24) {
                $count = (Get-RecentErrors -Hours 24 | Where-Object { $_.Severity -eq $severity }).Count
                $alerts += "$severity ($count errors)"
            }
        }

        if ($alerts.Count -gt 0) {
            Write-Host "🚨 Alert thresholds exceeded: $($alerts -join ', ')" -ForegroundColor Red
        } else {
            Write-Host "✅ No alert thresholds exceeded" -ForegroundColor Green
        }

        exit 0
    }

    "Query" {
        $errors = Get-RecentErrors -Hours $Hours

        Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "🔍 ERRORS (Last ${Hours}h)" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

        if ($errors.Count -eq 0) {
            Write-Host "✅ No errors in last ${Hours}h" -ForegroundColor Green
        } else {
            $groupedBySeverity = $errors | Group-Object Severity

            foreach ($group in $groupedBySeverity | Sort-Object Name -Descending) {
                Write-Host "`n$($group.Name): $($group.Count) errors" -ForegroundColor Yellow

                foreach ($error in $group.Group | Select-Object -First 5) {
                    $age = ((Get-Date) - [datetime]$error.Timestamp).TotalMinutes
                    Write-Host "  [$([math]::Round($age, 0))m ago] $($error.Component): $($error.Message)" -ForegroundColor Gray
                }

                if ($group.Count -gt 5) {
                    Write-Host "  ... and $($group.Count - 5) more" -ForegroundColor DarkGray
                }
            }
        }

        Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

        exit 0
    }
}
