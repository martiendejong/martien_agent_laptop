<#
.SYNOPSIS
    Circuit Breaker Pattern (R23-002)

.DESCRIPTION
    Prevents cascade failures by automatically disabling failing components.
    Implements circuit breaker states: CLOSED, OPEN, HALF-OPEN

.PARAMETER ToolName
    Name of the tool to check

.PARAMETER RegisterFailure
    Register a failure for the tool

.PARAMETER RegisterSuccess
    Register a success for the tool

.PARAMETER CheckStatus
    Check current circuit breaker status

.EXAMPLE
    .\circuit-breaker.ps1 -ToolName "prediction-engine" -CheckStatus
    .\circuit-breaker.ps1 -ToolName "prediction-engine" -RegisterFailure

.NOTES
    Part of Round 23: Robustness & Resilience
    Created: 2026-02-05
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ToolName,

    [switch]$RegisterFailure,
    [switch]$RegisterSuccess,
    [switch]$CheckStatus,
    [switch]$Reset
)

$CircuitBreakerFile = "C:\scripts\_machine\circuit-breaker-state.yaml"

# Circuit breaker configuration
$Config = @{
    FailureThreshold = 3      # Open after 3 failures
    TimeWindow = 300          # Within 5 minutes
    CooldownPeriod = 300      # Stay open for 5 minutes
    HalfOpenRetries = 1       # Allow 1 retry in half-open state
}

function Load-CircuitState {
    if (Test-Path $CircuitBreakerFile) {
        return Get-Content $CircuitBreakerFile -Raw | ConvertFrom-Yaml
    }

    return @{
        circuits = @{}
        last_updated = (Get-Date -Format "o")
    }
}

function Save-CircuitState {
    param($State)
    $State.last_updated = Get-Date -Format "o"
    $State | ConvertTo-Yaml | Set-Content $CircuitBreakerFile -Force
}

function Get-CircuitStatus {
    param($CircuitState, $ToolName)

    if (-not $CircuitState.circuits.ContainsKey($ToolName)) {
        return @{
            state = "CLOSED"
            failure_count = 0
            last_failure = $null
            opened_at = $null
            half_open_attempts = 0
        }
    }

    $circuit = $CircuitState.circuits[$ToolName]

    # Check if cooldown period has expired (OPEN → HALF-OPEN)
    if ($circuit.state -eq "OPEN" -and $circuit.opened_at) {
        $openedAt = [DateTime]::Parse($circuit.opened_at)
        $elapsed = ((Get-Date) - $openedAt).TotalSeconds

        if ($elapsed -gt $Config.CooldownPeriod) {
            $circuit.state = "HALF-OPEN"
            $circuit.half_open_attempts = 0
            Write-Host "🔄 Circuit transitioning: OPEN → HALF-OPEN" -ForegroundColor Yellow
        }
    }

    return $circuit
}

function Register-Failure {
    param($CircuitState, $ToolName)

    $circuit = Get-CircuitStatus $CircuitState $ToolName

    # If already OPEN, don't count more failures
    if ($circuit.state -eq "OPEN") {
        Write-Host "⛔ Circuit already OPEN for: $ToolName" -ForegroundColor Red
        return $circuit
    }

    # Increment failure count
    $circuit.failure_count++
    $circuit.last_failure = Get-Date -Format "o"

    # Check if should transition to OPEN
    if ($circuit.failure_count -ge $Config.FailureThreshold) {
        $circuit.state = "OPEN"
        $circuit.opened_at = Get-Date -Format "o"
        Write-Host "⚠️  CIRCUIT BREAKER OPENED for: $ToolName" -ForegroundColor Red
        Write-Host "   Reason: $($circuit.failure_count) failures in $($Config.TimeWindow)s" -ForegroundColor Yellow
        Write-Host "   Cooldown: $($Config.CooldownPeriod)s" -ForegroundColor Yellow
    }
    elseif ($circuit.state -eq "HALF-OPEN") {
        # Failure in HALF-OPEN → back to OPEN
        $circuit.state = "OPEN"
        $circuit.opened_at = Get-Date -Format "o"
        Write-Host "⚠️  Circuit re-opened: $ToolName" -ForegroundColor Red
        Write-Host "   Reason: Failure during half-open state" -ForegroundColor Yellow
    }
    else {
        Write-Host "⚠️  Failure registered for: $ToolName" -ForegroundColor Yellow
        Write-Host "   Count: $($circuit.failure_count)/$($Config.FailureThreshold)" -ForegroundColor Yellow
    }

    $CircuitState.circuits[$ToolName] = $circuit
    Save-CircuitState $CircuitState

    return $circuit
}

function Register-Success {
    param($CircuitState, $ToolName)

    $circuit = Get-CircuitStatus $CircuitState $ToolName

    if ($circuit.state -eq "HALF-OPEN") {
        # Success in HALF-OPEN → CLOSED
        $circuit.state = "CLOSED"
        $circuit.failure_count = 0
        $circuit.opened_at = $null
        $circuit.half_open_attempts = 0
        Write-Host "✅ Circuit CLOSED: $ToolName" -ForegroundColor Green
        Write-Host "   Reason: Successful call in half-open state" -ForegroundColor Cyan
    }
    elseif ($circuit.state -eq "CLOSED") {
        # Reset failure count on success
        if ($circuit.failure_count -gt 0) {
            Write-Host "✅ Success registered, resetting failure count" -ForegroundColor Green
        }
        $circuit.failure_count = 0
    }

    $CircuitState.circuits[$ToolName] = $circuit
    Save-CircuitState $CircuitState

    return $circuit
}

function Show-Status {
    param($Circuit, $ToolName)

    Write-Host ""
    Write-Host "🔌 Circuit Breaker Status: $ToolName" -ForegroundColor Cyan
    Write-Host ""

    $stateColor = switch ($Circuit.state) {
        "CLOSED" { "Green" }
        "HALF-OPEN" { "Yellow" }
        "OPEN" { "Red" }
        default { "Gray" }
    }

    $stateEmoji = switch ($Circuit.state) {
        "CLOSED" { "✅" }
        "HALF-OPEN" { "🔄" }
        "OPEN" { "⛔" }
        default { "❓" }
    }

    Write-Host "  State: $stateEmoji " -NoNewline
    Write-Host $Circuit.state -ForegroundColor $stateColor

    Write-Host "  Failure Count: $($Circuit.failure_count)/$($Config.FailureThreshold)" -ForegroundColor White

    if ($Circuit.last_failure) {
        $lastFailure = [DateTime]::Parse($Circuit.last_failure)
        $elapsed = ((Get-Date) - $lastFailure).TotalSeconds
        Write-Host "  Last Failure: $([math]::Round($elapsed))s ago" -ForegroundColor DarkGray
    }

    if ($Circuit.opened_at) {
        $openedAt = [DateTime]::Parse($Circuit.opened_at)
        $elapsed = ((Get-Date) - $openedAt).TotalSeconds
        $remaining = $Config.CooldownPeriod - $elapsed

        if ($remaining -gt 0) {
            Write-Host "  Cooldown Remaining: $([math]::Round($remaining))s" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "📋 Circuit Breaker Info:" -ForegroundColor Cyan
    Write-Host "  Failure Threshold: $($Config.FailureThreshold) failures" -ForegroundColor White
    Write-Host "  Time Window: $($Config.TimeWindow)s" -ForegroundColor White
    Write-Host "  Cooldown Period: $($Config.CooldownPeriod)s" -ForegroundColor White
    Write-Host ""

    switch ($Circuit.state) {
        "CLOSED" {
            Write-Host "  ✅ Circuit is healthy" -ForegroundColor Green
            Write-Host "     All calls are allowed" -ForegroundColor DarkGray
        }
        "HALF-OPEN" {
            Write-Host "  🔄 Circuit is testing recovery" -ForegroundColor Yellow
            Write-Host "     Limited calls allowed" -ForegroundColor DarkGray
        }
        "OPEN" {
            Write-Host "  ⛔ Circuit is protecting system" -ForegroundColor Red
            Write-Host "     All calls are blocked" -ForegroundColor DarkGray
            Write-Host "     Use fallback mechanism" -ForegroundColor Yellow
        }
    }

    Write-Host ""
}

function Reset-Circuit {
    param($CircuitState, $ToolName)

    if ($CircuitState.circuits.ContainsKey($ToolName)) {
        $CircuitState.circuits.Remove($ToolName)
        Save-CircuitState $CircuitState
        Write-Host "✅ Circuit breaker reset for: $ToolName" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  No circuit breaker found for: $ToolName" -ForegroundColor Yellow
    }
}

# Main execution
$state = Load-CircuitState

if ($RegisterFailure) {
    $circuit = Register-Failure $state $ToolName
    Show-Status $circuit $ToolName
}
elseif ($RegisterSuccess) {
    $circuit = Register-Success $state $ToolName
    Show-Status $circuit $ToolName
}
elseif ($Reset) {
    Reset-Circuit $state $ToolName
}
elseif ($CheckStatus) {
    $circuit = Get-CircuitStatus $state $ToolName
    Show-Status $circuit $ToolName
}
else {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  -CheckStatus         Check current status" -ForegroundColor White
    Write-Host "  -RegisterFailure     Register a failure" -ForegroundColor White
    Write-Host "  -RegisterSuccess     Register a success" -ForegroundColor White
    Write-Host "  -Reset               Reset circuit breaker" -ForegroundColor White
}
