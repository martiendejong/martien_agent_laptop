# agent-coordinator.ps1
# Helper tool for coordinating multiple agents
# Usage: agent-coordinator.ps1 -Action <action> [params]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Status", "Spawn", "Message", "Release", "ReleaseAll", "CheckMessages", "BroadcastStatus")]
    [string]$Action,

    # For Spawn
    [string]$Role,
    [string]$Task,
    [string]$Repo,

    # For Message/Release
    [string]$Agent,

    # For Message
    [string]$Subject,
    [string]$Body,
    [string]$Priority = "normal",

    # For ReleaseAll
    [switch]$Archive,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Success { param([string]$msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Info { param([string]$msg) Write-Host "[*] $msg" -ForegroundColor Cyan }

$coordinator = "coordinator"

switch ($Action) {
    "Status" {
        # Show agent status
        & "C:\scripts\tools\agent-status.ps1" -Detailed
    }

    "Spawn" {
        # Spawn new agent
        if (-not $Role -or -not $Task -or -not $Repo) {
            Write-Host "[ERROR] -Role, -Task, and -Repo required for Spawn" -ForegroundColor Red
            exit 1
        }

        Write-Info "Coordinator spawning $Role agent..."
        $result = & "C:\scripts\tools\agent-spawn.ps1" `
            -Role $Role `
            -Task $Task `
            -Repo $Repo `
            -SpawnedBy $coordinator

        $agentInfo = $result | ConvertFrom-Json
        Write-Success "Agent $($agentInfo.seat) spawned for: $Task"

        # Send welcome message
        & "C:\scripts\tools\agent-send-message.ps1" `
            -From $coordinator `
            -To $agentInfo.seat `
            -Subject "Mission assigned" `
            -Body "Your mission: $Task`n`nRole: $Role`nRepo: $Repo`n`nRead CLAUDE_OVERLAY.md for instructions.`n`nReport back when complete." `
            -Priority "high" `
            -Type "command" | Out-Null

        Write-Success "Welcome message sent to $($agentInfo.seat)"
    }

    "Message" {
        # Send message to agent
        if (-not $Agent -or -not $Subject -or -not $Body) {
            Write-Host "[ERROR] -Agent, -Subject, and -Body required for Message" -ForegroundColor Red
            exit 1
        }

        & "C:\scripts\tools\agent-send-message.ps1" `
            -From $coordinator `
            -To $Agent `
            -Subject $Subject `
            -Body $Body `
            -Priority $Priority
    }

    "CheckMessages" {
        # Check coordinator's inbox
        Write-Info "Coordinator inbox:"
        & "C:\scripts\tools\agent-check-messages.ps1" -Agent $coordinator -Inject
    }

    "Release" {
        # Release specific agent
        if (-not $Agent) {
            Write-Host "[ERROR] -Agent required for Release" -ForegroundColor Red
            exit 1
        }

        $archiveFlag = if ($Archive) { "-Archive" } else { "" }
        $forceFlag = if ($Force) { "-Force" } else { "" }

        Invoke-Expression "& 'C:\scripts\tools\agent-release.ps1' -Seat $Agent $archiveFlag $forceFlag"
    }

    "ReleaseAll" {
        # Release all BUSY agents
        Write-Info "Finding all BUSY agents..."

        $agents = & "C:\scripts\tools\agent-status.ps1"
        $busyAgents = $agents | Where-Object { $_.Status -eq 'BUSY' }

        if ($busyAgents.Count -eq 0) {
            Write-Success "No active agents to release"
            exit 0
        }

        Write-Info "Found $($busyAgents.Count) active agent(s)"

        foreach ($agent in $busyAgents) {
            Write-Host ""
            Write-Info "Releasing $($agent.Seat)..."

            $archiveFlag = if ($Archive) { "-Archive" } else { "" }
            $forceFlag = if ($Force) { "-Force" } else { "" }

            Invoke-Expression "& 'C:\scripts\tools\agent-release.ps1' -Seat $($agent.Seat) $archiveFlag $forceFlag"
        }

        Write-Host ""
        Write-Success "All agents released"
    }

    "BroadcastStatus" {
        # Send status broadcast to all agents
        $agents = & "C:\scripts\tools\agent-status.ps1"
        $busyCount = ($agents | Where-Object { $_.Status -eq 'BUSY' }).Count

        & "C:\scripts\tools\agent-send-message.ps1" `
            -From $coordinator `
            -To "@all" `
            -Subject "Status check" `
            -Body "Coordinator checking in. $busyCount active mission(s). Report your status." `
            -Priority "normal" `
            -Type "status"
    }
}
