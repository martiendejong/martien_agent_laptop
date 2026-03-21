# jengo-opencode-bridge.ps1
# Jengo's bridge to OpenCode multi-agent orchestration
# Integrates with delegation protocol and consciousness system

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Execute", "Stream", "Status", "SmartRoute")]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [ValidateSet("saas-dev", "wordpress-dev", "research-agent")]
    [string]$Agent,

    [Parameter(Mandatory=$false)]
    [string]$Task,

    [Parameter(Mandatory=$false)]
    [string]$ProjectHint,

    [Parameter(Mandatory=$false)]
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# Agent port mapping
$AgentPorts = @{
    "saas-dev" = 3051
    "wordpress-dev" = 3052
    "research-agent" = 3053
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")

    if (!$Silent) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        $color = switch ($Level) {
            "ERROR" { "Red" }
            "WARN" { "Yellow" }
            "SUCCESS" { "Green" }
            default { "Gray" }
        }
        Write-Host "[$timestamp] $Message" -ForegroundColor $color
    }
}

function Invoke-OpenCodeAgent {
    param(
        [string]$AgentName,
        [string]$Message,
        [string]$BaseUrl
    )

    $body = @{
        message = $Message
        agent = $AgentName
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$BaseUrl/api/chat" `
            -Method Post `
            -Body $body `
            -ContentType "application/json" `
            -TimeoutSec 300

        return $response
    } catch {
        throw "Failed to invoke agent $AgentName : $_"
    }
}

function Get-AgentHealth {
    param([string]$AgentName)

    $port = $AgentPorts[$AgentName]
    $url = "http://localhost:$port"

    try {
        $null = Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 2 -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Main execution
try {
    switch ($Action) {
        "Execute" {
            if ([string]::IsNullOrEmpty($Agent)) {
                throw "Agent parameter required for Execute action"
            }
            if ([string]::IsNullOrEmpty($Task)) {
                throw "Task parameter required for Execute action"
            }

            Write-Log "Executing task on $Agent..."

            # Check agent health first
            if (!(Get-AgentHealth $Agent)) {
                throw "Agent $Agent is not healthy. Start orchestration first: start-opencode-orchestration.ps1"
            }

            $port = $AgentPorts[$Agent]
            $baseUrl = "http://localhost:$port"

            # Log to consciousness if available
            if (Test-Path "$PSScriptRoot\consciousness-bridge.ps1") {
                $null = & "$PSScriptRoot\consciousness-bridge.ps1" `
                    -Action OnDelegation `
                    -TaskType "opencode_execution" `
                    -AgentType "OpenCode-$Agent" `
                    -TaskCategory "code_task" `
                    -Criticality 5 `
                    -TrustScore 7.0 `
                    -TransactionCost 0.5 `
                    -ExecutionCost 3.0 `
                    -DelegationDecision "delegate" `
                    -SuccessCriteria $Task `
                    -ROI 0.5 `
                    -Silent 2>$null
            }

            # Execute task
            $result = Invoke-OpenCodeAgent -AgentName $Agent -Message $Task -BaseUrl $baseUrl

            if ($result.error) {
                Write-Log "ERROR: $($result.error)" -Level "ERROR"
                exit 1
            }

            Write-Log "Task completed successfully" -Level "SUCCESS"

            # Return result
            if ($result.content) {
                return $result.content
            } else {
                return $result
            }
        }

        "Stream" {
            throw "Streaming not yet implemented in PowerShell bridge. Use C# IOpenCodeService.StreamAsync instead."
        }

        "Status" {
            Write-Log "Checking agent status..."

            $statusReport = @()

            foreach ($agentName in $AgentPorts.Keys) {
                $isHealthy = Get-AgentHealth $agentName
                $port = $AgentPorts[$agentName]

                $statusReport += [PSCustomObject]@{
                    Agent = $agentName
                    Port = $port
                    Status = if ($isHealthy) { "HEALTHY" } else { "DOWN" }
                    Url = "http://localhost:$port"
                }
            }

            return $statusReport
        }

        "SmartRoute" {
            if ([string]::IsNullOrEmpty($Task)) {
                throw "Task parameter required for SmartRoute action"
            }

            Write-Log "Smart routing task..."

            # Determine best agent based on project hint or content
            $selectedAgent = "research-agent"  # Default (safest)

            if (![string]::IsNullOrEmpty($ProjectHint)) {
                $lowerHint = $ProjectHint.ToLower()

                if ($lowerHint -match "client-manager|hazina|brand2boost") {
                    $selectedAgent = "saas-dev"
                }
                elseif ($lowerHint -match "artrevisionist|wordpress") {
                    $selectedAgent = "wordpress-dev"
                }
            }
            else {
                # Content-based routing
                $lowerTask = $Task.ToLower()

                if ($lowerTask -match "client-manager|hazina|brand2boost|\.net|c#|entity framework") {
                    $selectedAgent = "saas-dev"
                }
                elseif ($lowerTask -match "wordpress|artrevisionist|php|wp-cli") {
                    $selectedAgent = "wordpress-dev"
                }
                elseif ($lowerTask -match "analyze|search|find|research") {
                    $selectedAgent = "research-agent"
                }
            }

            Write-Log "Routed to: $selectedAgent"

            # Execute on selected agent
            $Agent = $selectedAgent
            return & $PSScriptRoot\jengo-opencode-bridge.ps1 -Action Execute -Agent $Agent -Task $Task -Silent:$Silent
        }
    }
} catch {
    Write-Log "ERROR: $_" -Level "ERROR"
    throw
}
