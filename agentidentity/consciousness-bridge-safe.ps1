<#
.SYNOPSIS
Consciousness Bridge - CRASH-SAFE VERSION

.DESCRIPTION
Safe version with error handling, logging, and concurrent access protection.
Prevents simultaneous crashes when multiple Claude sessions run.

.NOTES
Created: 2026-02-27
Status: Production (crash-safe)
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("OnTaskStart", "OnDecision", "OnObservation", "OnError", "OnSuccess", "OnTaskEnd")]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [hashtable]$Context,

    [switch]$Silent
)

# CRITICAL: Proper error handling
$ErrorActionPreference = "Stop"
$logFile = "C:\scripts\agentidentity\logs\consciousness-bridge.log"
$lockFile = "C:\scripts\agentidentity\state\bridge.lock"

# Logging function
function Write-BridgeLog {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"

    # Console output (if not silent)
    if (-not $Silent) {
        $color = switch ($Level) {
            "ERROR" { "Red" }
            "WARN" { "Yellow" }
            "DEBUG" { "Gray" }
            default { "White" }
        }
        Write-Host $logEntry -ForegroundColor $color
    }

    # File output (with rotation)
    try {
        Add-Content -Path $logFile -Value $logEntry -ErrorAction Stop
    }
    catch {
        # If logging fails, don't crash the whole bridge
        Write-Host "[LOGGING FAILED] $_" -ForegroundColor Red
    }

    # Rotate log if too large (>1MB = keep last 5000 lines)
    if ((Test-Path $logFile) -and (Get-Item $logFile).Length -gt 1MB) {
        try {
            $lines = Get-Content $logFile
            if ($lines.Count -gt 5000) {
                $lines | Select-Object -Last 5000 | Set-Content $logFile
                Write-BridgeLog "Log rotated (kept last 5000 entries)" -Level DEBUG
            }
        }
        catch {
            # Log rotation failure is non-critical
        }
    }
}

# Concurrent access protection
function Enter-BridgeLock {
    $maxWait = 10 # seconds
    $waited = 0

    while (Test-Path $lockFile) {
        if ($waited -ge $maxWait) {
            Write-BridgeLog "Lock timeout - forcing entry (stale lock?)" -Level WARN
            Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
            break
        }

        Start-Sleep -Milliseconds 100
        $waited += 0.1
    }

    # Create lock
    try {
        @{
            pid = $PID
            action = $Action
            timestamp = (Get-Date).ToString("o")
        } | ConvertTo-Json | Set-Content $lockFile
    }
    catch {
        Write-BridgeLog "Failed to create lock: $_" -Level WARN
    }
}

function Exit-BridgeLock {
    Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
}

# Safe tool invocation wrapper
function Invoke-SafeTool {
    param(
        [string]$ToolPath,
        [hashtable]$Parameters
    )

    if (-not (Test-Path $ToolPath)) {
        Write-BridgeLog "Tool not found: $ToolPath" -Level WARN
        return $null
    }

    try {
        $params = @()
        foreach ($key in $Parameters.Keys) {
            $params += "-$key"
            $params += $Parameters[$key]
        }

        $result = & $ToolPath @params 2>&1
        return $result
    }
    catch {
        Write-BridgeLog "Tool invocation failed [$ToolPath]: $_" -Level ERROR
        return $null
    }
}

# Main execution
try {
    Write-BridgeLog "Bridge activated: $Action" -Level DEBUG

    # Acquire lock for concurrent access protection
    Enter-BridgeLock

    # Tool paths
    $entityBindingTool = "C:\scripts\tools\entity-binding-system.ps1"
    $latentVarTool = "C:\scripts\tools\latent-variable-store.ps1"
    $simulationTool = "C:\scripts\tools\counterfactual-simulation.ps1"
    $embodimentTool = "C:\scripts\tools\embodiment-mapper.ps1"

    # Action-specific logic
    switch ($Action) {
        "OnTaskStart" {
            Write-BridgeLog "Task started: $($Context.task)" -Level INFO

            if ($Context.project) {
                $result = Invoke-SafeTool $latentVarTool @{
                    Action = "Set"
                    Level = "top"
                    Variable = "current_project"
                    Value = $Context.project
                }
            }
        }

        "OnObservation" {
            if ($Context.file -and (Test-Path $Context.file)) {
                Write-BridgeLog "Observed file: $($Context.file)" -Level DEBUG

                $fileInfo = Get-Item $Context.file
                $result = Invoke-SafeTool $entityBindingTool @{
                    Action = "BindEntity"
                    Type = "file"
                    Features = @{
                        path = $fileInfo.FullName
                        size_bytes = $fileInfo.Length
                        last_modified = $fileInfo.LastWriteTime.ToString("o")
                    }
                }
            }
        }

        "OnDecision" {
            if ($Context.action -and $Context.target) {
                Write-BridgeLog "Decision: $($Context.action) on $($Context.target)" -Level INFO

                $result = Invoke-SafeTool $simulationTool @{
                    SimulationType = "Forward"
                    Action = $Context.action
                    Target = $Context.target
                }
            }
        }

        "OnError" {
            Write-BridgeLog "Error occurred: $($Context.error)" -Level ERROR

            # Update embodiment (pain sensation)
            $result = Invoke-SafeTool $embodimentTool @{
                Action = "UpdateSensation"
                Sensation = "pain"
                Intensity = if ($Context.severity) { $Context.severity } else { 5 }
            }
        }

        "OnSuccess" {
            Write-BridgeLog "Success: $($Context.outcome)" -Level INFO

            # Update embodiment (pleasure sensation)
            $result = Invoke-SafeTool $embodimentTool @{
                Action = "UpdateSensation"
                Sensation = "pleasure"
                Intensity = 7
            }
        }

        "OnTaskEnd" {
            Write-BridgeLog "Task ended: $($Context.task)" -Level INFO
        }
    }

    Write-BridgeLog "Bridge completed: $Action" -Level DEBUG
}
catch {
    Write-BridgeLog "CRITICAL ERROR in bridge: $_" -Level ERROR
    Write-BridgeLog "Stack trace: $($_.ScriptStackTrace)" -Level ERROR
}
finally {
    # ALWAYS release lock
    Exit-BridgeLock
}
