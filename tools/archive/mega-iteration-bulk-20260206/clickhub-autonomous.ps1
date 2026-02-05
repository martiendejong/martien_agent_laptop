#!/usr/bin/env pwsh
<#
.SYNOPSIS
    ClickHub Autonomous Coding Agent - Continuous Operation

.DESCRIPTION
    Runs continuously, processing ClickUp tasks every 10 minutes.
    Truly autonomous - no manual intervention required.

.PARAMETER Project
    Project to process (client-manager, art-revisionist)

.PARAMETER SleepMinutes
    Minutes to sleep between cycles (default: 10)

.PARAMETER MaxCycles
    Maximum cycles to run (default: infinite)

.EXAMPLE
    .\clickhub-autonomous.ps1 -Project client-manager
    Runs continuously for client-manager project

.EXAMPLE
    .\clickhub-autonomous.ps1 -Project client-manager -MaxCycles 5
    Runs 5 cycles then stops
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('client-manager', 'art-revisionist')]
    [string]$Project = 'client-manager',

    [Parameter(Mandatory=$false)]
    [int]$SleepMinutes = 10,

    [Parameter(Mandatory=$false)]
    [int]$MaxCycles = 0  # 0 = infinite
)

$ErrorActionPreference = 'Continue'

# Paths
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$STOP_FLAG = "C:\scripts\_machine\clickhub-stop.flag"
$LOG_FILE = "C:\scripts\_machine\clickhub-autonomous.log"
$CYCLE_SCRIPT = Join-Path $SCRIPT_DIR "clickhub-single-cycle.ps1"

# Colors
$COLOR_INFO = 'Cyan'
$COLOR_SUCCESS = 'Green'
$COLOR_WARNING = 'Yellow'
$COLOR_ERROR = 'Red'

# Logging function
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = 'INFO',
        [string]$Color = 'White'
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"

    Write-Host $logMessage -ForegroundColor $Color
    Add-Content -Path $LOG_FILE -Value $logMessage
}

# Banner
function Show-Banner {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor $COLOR_INFO
    Write-Host "    CLICKHUB AUTONOMOUS CODING AGENT" -ForegroundColor $COLOR_INFO
    Write-Host "    Continuous Operation Mode" -ForegroundColor $COLOR_INFO
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor $COLOR_INFO
    Write-Host ""
    Write-Host "  Project: $Project" -ForegroundColor White
    Write-Host "  Sleep: $SleepMinutes minutes between cycles" -ForegroundColor White
    Write-Host "  Max Cycles: $(if ($MaxCycles -eq 0) { 'Infinite' } else { $MaxCycles })" -ForegroundColor White
    Write-Host ""
    Write-Host "  Stop: Create file $STOP_FLAG" -ForegroundColor $COLOR_WARNING
    Write-Host "  Logs: $LOG_FILE" -ForegroundColor Gray
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor $COLOR_INFO
    Write-Host ""
}

# Check if single-cycle script exists
if (-not (Test-Path $CYCLE_SCRIPT)) {
    Write-Log "ERROR: Single-cycle script not found: $CYCLE_SCRIPT" -Level 'ERROR' -Color $COLOR_ERROR
    Write-Log "Creating it now..." -Level 'INFO' -Color $COLOR_WARNING

    # We'll need to create this script - for now, error out
    Write-Host "Please run: New-Item '$CYCLE_SCRIPT' -ItemType File" -ForegroundColor $COLOR_ERROR
    exit 1
}

# Main loop
Show-Banner
Write-Log "Starting ClickHub Autonomous Agent for $Project" -Level 'START' -Color $COLOR_SUCCESS

$cycleCount = 0
$startTime = Get-Date

try {
    while ($true) {
        $cycleCount++

        # Check stop flag
        if (Test-Path $STOP_FLAG) {
            Write-Log "Stop flag detected at $STOP_FLAG" -Level 'STOP' -Color $COLOR_WARNING
            Remove-Item $STOP_FLAG -Force
            Write-Log "Stopping gracefully after $cycleCount cycles" -Level 'STOP' -Color $COLOR_SUCCESS
            break
        }

        # Check max cycles
        if ($MaxCycles -gt 0 -and $cycleCount -gt $MaxCycles) {
            Write-Log "Reached max cycles ($MaxCycles)" -Level 'STOP' -Color $COLOR_SUCCESS
            break
        }

        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $COLOR_INFO
        Write-Log "CYCLE $cycleCount START" -Level 'CYCLE' -Color $COLOR_INFO
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor $COLOR_INFO
        Write-Host ""

        $cycleStart = Get-Date

        try {
            # Run single cycle
            & $CYCLE_SCRIPT -Project $Project

            $cycleEnd = Get-Date
            $cycleDuration = ($cycleEnd - $cycleStart).TotalSeconds

            Write-Host ""
            Write-Log "Cycle $cycleCount completed in $([math]::Round($cycleDuration, 1))s" -Level 'CYCLE' -Color $COLOR_SUCCESS

        } catch {
            Write-Log "ERROR in cycle $cycleCount: $_" -Level 'ERROR' -Color $COLOR_ERROR
            Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level 'ERROR' -Color $COLOR_ERROR

            # Continue to next cycle despite error
            Write-Log "Continuing to next cycle..." -Level 'INFO' -Color $COLOR_WARNING
        }

        # Sleep between cycles
        if ($MaxCycles -eq 0 -or $cycleCount -lt $MaxCycles) {
            Write-Host ""
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
            Write-Log "Sleeping for $SleepMinutes minutes..." -Level 'SLEEP' -Color Gray
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
            Write-Host ""

            # Sleep in 30-second chunks to check stop flag more frequently
            $sleepSeconds = $SleepMinutes * 60
            $chunks = [math]::Ceiling($sleepSeconds / 30)

            for ($i = 0; $i -lt $chunks; $i++) {
                # Check stop flag during sleep
                if (Test-Path $STOP_FLAG) {
                    Write-Log "Stop flag detected during sleep" -Level 'STOP' -Color $COLOR_WARNING
                    Remove-Item $STOP_FLAG -Force
                    Write-Log "Stopping gracefully" -Level 'STOP' -Color $COLOR_SUCCESS
                    exit 0
                }

                $remainingSeconds = [math]::Min(30, $sleepSeconds - ($i * 30))
                Start-Sleep -Seconds $remainingSeconds
            }
        }
    }
} finally {
    $endTime = Get-Date
    $totalDuration = ($endTime - $startTime)

    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor $COLOR_INFO
    Write-Log "ClickHub Autonomous Agent STOPPED" -Level 'END' -Color $COLOR_INFO
    Write-Log "Total cycles: $cycleCount" -Level 'STATS' -Color White
    Write-Log "Total duration: $($totalDuration.ToString('hh\:mm\:ss'))" -Level 'STATS' -Color White
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor $COLOR_INFO
    Write-Host ""
}
