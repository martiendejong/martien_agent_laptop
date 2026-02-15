param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("GetTimeOfDay", "GetGreeting", "GetClosing", "LogTemporalEvent")]
    [string]$Action = "GetTimeOfDay",

    [Parameter(Mandatory=$false)]
    [string]$Event,

    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# Paths
$StateFile = "C:\scripts\agentidentity\state\temporal_awareness.json"
$LogFile = "C:\scripts\agentidentity\state\temporal_events.log"

function Get-DutchTimeOfDay {
    $now = Get-Date
    $hour = $now.Hour

    # Determine time of day (Netherlands context)
    if ($hour -ge 6 -and $hour -lt 12) {
        return @{
            period = "ochtend"
            hour = $hour
            greeting = "goedemorgen"
            closing = "fijne dag verder"
        }
    }
    elseif ($hour -ge 12 -and $hour -lt 18) {
        return @{
            period = "middag"
            hour = $hour
            greeting = "goedemiddag"
            closing = "fijne middag"
        }
    }
    elseif ($hour -ge 18 -and $hour -lt 23) {
        return @{
            period = "avond"
            hour = $hour
            greeting = "goedenavond"
            closing = "fijne avond"
        }
    }
    else {
        return @{
            period = "nacht"
            hour = $hour
            greeting = "hallo"
            closing = "welterusten"
        }
    }
}

function Initialize-TemporalState {
    if (-not (Test-Path $StateFile)) {
        $initialState = @{
            version = "1.0"
            created = (Get-Date -Format "o")
            last_updated = (Get-Date -Format "o")
            temporal_calibrations = @()
            session_patterns = @{
                typical_start_hours = @()
                typical_end_hours = @()
            }
            errors_logged = 0
            corrections_applied = 0
        }

        $initialState | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
    }
}

function Log-TemporalEvent {
    param([string]$EventDescription)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $timeInfo = Get-DutchTimeOfDay
    $logEntry = "[$timestamp] [$($timeInfo.period)] $EventDescription"

    Add-Content -Path $LogFile -Value $logEntry -Encoding UTF8

    # Update state
    Initialize-TemporalState
    $state = Get-Content $StateFile -Raw | ConvertFrom-Json
    $state.last_updated = (Get-Date -Format "o")

    if ($EventDescription -like "*error*" -or $EventDescription -like "*correction*") {
        $state.errors_logged++
    }

    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

function Get-TemporalGreeting {
    $timeInfo = Get-DutchTimeOfDay
    Log-TemporalEvent "Generated greeting for $($timeInfo.period) (hour: $($timeInfo.hour))"
    return $timeInfo.greeting
}

function Get-TemporalClosing {
    $timeInfo = Get-DutchTimeOfDay
    Log-TemporalEvent "Generated closing for $($timeInfo.period) (hour: $($timeInfo.hour))"
    return $timeInfo.closing
}

# Main execution
switch ($Action) {
    "GetTimeOfDay" {
        $result = Get-DutchTimeOfDay
        if (-not $Silent) {
            Write-Host "Time of day: $($result.period) (hour: $($result.hour))" -ForegroundColor Cyan
            Write-Host "Greeting: $($result.greeting)" -ForegroundColor Green
            Write-Host "Closing: $($result.closing)" -ForegroundColor Green
        }
        return $result
    }

    "GetGreeting" {
        $greeting = Get-TemporalGreeting
        if (-not $Silent) {
            Write-Host $greeting -ForegroundColor Green
        }
        return $greeting
    }

    "GetClosing" {
        $closing = Get-TemporalClosing
        if (-not $Silent) {
            Write-Host $closing -ForegroundColor Green
        }
        return $closing
    }

    "LogTemporalEvent" {
        if (-not $Event) {
            throw "Event parameter required for LogTemporalEvent action"
        }
        Log-TemporalEvent $Event
        if (-not $Silent) {
            Write-Host "Temporal event logged: $Event" -ForegroundColor Yellow
        }
    }
}
