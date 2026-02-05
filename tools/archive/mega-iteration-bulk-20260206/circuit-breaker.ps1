# Tool Circuit Breakers (R23-002)
# Tracks tool failures and auto-disables faulty components

param(
    [string]$ToolName,
    [switch]$RecordFailure,
    [switch]$RecordSuccess,
    [switch]$CheckStatus,
    [switch]$Reset,
    [switch]$ShowAll
)

$CircuitState = "C:\scripts\_machine\circuit-breaker-state.yaml"
$FailureThreshold = 3
$CooldownMinutes = 5

function Initialize-CircuitState {
    if (!(Test-Path $CircuitState)) {
        @{
            circuits = @{}
            metadata = @{
                created = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            }
        } | ConvertTo-Yaml | Out-File -FilePath $CircuitState -Encoding UTF8
    }
}

function Get-CircuitStatus {
    param([string]$Tool)

    Initialize-CircuitState
    $state = Get-Content $CircuitState -Raw | ConvertFrom-Yaml

    if (!$state.circuits.ContainsKey($Tool)) {
        return @{
            state = "CLOSED"
            failure_count = 0
            last_failure = $null
            disabled_until = $null
        }
    }

    $circuit = $state.circuits[$Tool]

    # Check if cooldown period has passed
    if ($circuit.state -eq "OPEN" -and $circuit.disabled_until) {
        $disabledUntil = [DateTime]::Parse($circuit.disabled_until)
        if ((Get-Date) -gt $disabledUntil) {
            # Cooldown passed, enter half-open state
            $circuit.state = "HALF_OPEN"
            $circuit.failure_count = 0
            Save-CircuitState -State $state
        }
    }

    return $circuit
}

function Record-Failure {
    param([string]$Tool)

    Initialize-CircuitState
    $state = Get-Content $CircuitState -Raw | ConvertFrom-Yaml

    if (!$state.circuits.ContainsKey($Tool)) {
        $state.circuits[$Tool] = @{
            state = "CLOSED"
            failure_count = 0
            last_failure = $null
            disabled_until = $null
        }
    }

    $circuit = $state.circuits[$Tool]
    $circuit.failure_count++
    $circuit.last_failure = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    # Trip circuit if threshold exceeded
    if ($circuit.failure_count -ge $FailureThreshold) {
        $circuit.state = "OPEN"
        $disabledUntil = (Get-Date).AddMinutes($CooldownMinutes)
        $circuit.disabled_until = $disabledUntil.ToString('yyyy-MM-dd HH:mm:ss')

        Write-Host "CIRCUIT BREAKER TRIPPED for $Tool" -ForegroundColor Red
        Write-Host "  Failures: $($circuit.failure_count)"
        Write-Host "  Disabled until: $($circuit.disabled_until)" -ForegroundColor Yellow
    }
    else {
        Write-Host "Failure recorded for $Tool ($($circuit.failure_count)/$FailureThreshold)" -ForegroundColor Yellow
    }

    Save-CircuitState -State $state
}

function Record-Success {
    param([string]$Tool)

    Initialize-CircuitState
    $state = Get-Content $CircuitState -Raw | ConvertFrom-Yaml

    if ($state.circuits.ContainsKey($Tool)) {
        $circuit = $state.circuits[$Tool]

        if ($circuit.state -eq "HALF_OPEN") {
            # Success in half-open state, close circuit
            $circuit.state = "CLOSED"
            $circuit.failure_count = 0
            $circuit.disabled_until = $null
            Write-Host "Circuit CLOSED for $Tool (recovery successful)" -ForegroundColor Green
        }
        elseif ($circuit.state -eq "CLOSED") {
            # Success in closed state, reduce failure count
            if ($circuit.failure_count -gt 0) {
                $circuit.failure_count = [Math]::Max(0, $circuit.failure_count - 1)
                Write-Host "Success for $Tool, failure count reduced to $($circuit.failure_count)" -ForegroundColor Cyan
            }
        }

        Save-CircuitState -State $state
    }
}

function Reset-Circuit {
    param([string]$Tool)

    Initialize-CircuitState
    $state = Get-Content $CircuitState -Raw | ConvertFrom-Yaml

    if ($state.circuits.ContainsKey($Tool)) {
        $state.circuits[$Tool] = @{
            state = "CLOSED"
            failure_count = 0
            last_failure = $null
            disabled_until = $null
        }
        Save-CircuitState -State $state
        Write-Host "Circuit reset for $Tool" -ForegroundColor Green
    }
}

function Save-CircuitState {
    param([object]$State)
    $State | ConvertTo-Yaml | Out-File -FilePath $CircuitState -Encoding UTF8
}

function Show-AllCircuits {
    Initialize-CircuitState
    $state = Get-Content $CircuitState -Raw | ConvertFrom-Yaml

    Write-Host "`n=== Circuit Breaker Status ===" -ForegroundColor Cyan

    if ($state.circuits.Count -eq 0) {
        Write-Host "No circuits registered" -ForegroundColor Yellow
        return
    }

    foreach ($tool in $state.circuits.Keys) {
        $circuit = $state.circuits[$tool]
        $color = switch ($circuit.state) {
            "CLOSED" { "Green" }
            "HALF_OPEN" { "Yellow" }
            "OPEN" { "Red" }
        }

        Write-Host "`n[$tool]" -ForegroundColor $color
        Write-Host "  State: $($circuit.state)"
        Write-Host "  Failures: $($circuit.failure_count)"
        if ($circuit.last_failure) {
            Write-Host "  Last Failure: $($circuit.last_failure)"
        }
        if ($circuit.disabled_until) {
            Write-Host "  Disabled Until: $($circuit.disabled_until)"
        }
    }
}

# Main execution
if ($CheckStatus -and $ToolName) {
    $status = Get-CircuitStatus -Tool $ToolName
    $status | ConvertTo-Json -Depth 3
}
elseif ($RecordFailure -and $ToolName) {
    Record-Failure -Tool $ToolName
}
elseif ($RecordSuccess -and $ToolName) {
    Record-Success -Tool $ToolName
}
elseif ($Reset -and $ToolName) {
    Reset-Circuit -Tool $ToolName
}
elseif ($ShowAll) {
    Show-AllCircuits
}
else {
    Write-Host "Usage: circuit-breaker.ps1 -ToolName <name> [-CheckStatus] [-RecordFailure] [-RecordSuccess] [-Reset]"
    Write-Host "       circuit-breaker.ps1 -ShowAll"
    Write-Host "`nCircuit States:"
    Write-Host "  CLOSED     : Normal operation"
    Write-Host "  HALF_OPEN  : Testing after cooldown"
    Write-Host "  OPEN       : Disabled due to failures"
}
