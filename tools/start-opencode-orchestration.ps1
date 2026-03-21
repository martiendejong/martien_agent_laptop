# start-opencode-orchestration.ps1
# Starts multiple OpenCode ACP servers for multi-agent orchestration

param(
    [string[]]$Agents = @("saas-dev", "wordpress-dev", "research-agent"),
    [switch]$Wait,
    [switch]$Status
)

$ErrorActionPreference = "Stop"

Write-Host "=== OpenCode Orchestration Startup ===" -ForegroundColor Cyan
Write-Host ""

# Agent port configuration
$AgentPorts = @{
    "saas-dev" = 3051
    "wordpress-dev" = 3052
    "research-agent" = 3053
}

# Check if OpenCode is installed
try {
    $null = & opencode --version 2>&1
} catch {
    Write-Host "[ERROR] OpenCode not installed. Run: npm install -g @opencode/cli" -ForegroundColor Red
    exit 1
}

# Check for already running instances
Write-Host "[*] Checking for existing OpenCode processes..." -ForegroundColor Gray
$existing = Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*opencode*acp*"
}

if ($existing) {
    Write-Host "[!] Found $($existing.Count) running OpenCode processes" -ForegroundColor Yellow
    Write-Host "    Run stop-opencode-orchestration.ps1 first to clean up" -ForegroundColor Gray

    if ($Status) {
        Write-Host ""
        Write-Host "=== Running Processes ===" -ForegroundColor Cyan
        foreach ($proc in $existing) {
            Write-Host "PID: $($proc.Id) - $($proc.StartTime)" -ForegroundColor Gray
        }
    }
    exit 0
}

# Start each agent
Write-Host "[OK] No conflicts found" -ForegroundColor Green
Write-Host ""

$StartedProcesses = @()

foreach ($agentName in $Agents) {
    $port = $AgentPorts[$agentName]
    if (!$port) {
        Write-Host "[ERROR] Unknown agent: $agentName" -ForegroundColor Red
        continue
    }

    Write-Host "[*] Starting $agentName on port $port..." -ForegroundColor Gray

    # Start ACP server
    $process = Start-Process -FilePath "opencode" `
        -ArgumentList "acp --port $port --agent $agentName --hostname 127.0.0.1" `
        -WindowStyle Hidden `
        -PassThru

    $StartedProcesses += @{
        Name = $agentName
        Port = $port
        PID = $process.Id
        Process = $process
    }

    Write-Host "[OK] $agentName started (PID: $($process.Id))" -ForegroundColor Green
}

# Wait for servers to be ready
Write-Host ""
Write-Host "[*] Waiting for servers to initialize..." -ForegroundColor Gray
Start-Sleep -Seconds 3

# Health check
Write-Host ""
Write-Host "[*] Performing health checks..." -ForegroundColor Gray

foreach ($agent in $StartedProcesses) {
    $url = "http://localhost:$($agent.Port)/health"

    try {
        $response = Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5 -ErrorAction Stop
        Write-Host "[OK] $($agent.Name) - Port $($agent.Port) - Status: $($response.StatusCode)" -ForegroundColor Green
    } catch {
        # Some OpenCode versions might not have /health endpoint
        # Check if process is still running instead
        if (Get-Process -Id $agent.PID -ErrorAction SilentlyContinue) {
            Write-Host "[OK] $($agent.Name) - Port $($agent.Port) - Process running" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $($agent.Name) - Port $($agent.Port) - Failed to start" -ForegroundColor Red
        }
    }
}

# Save PIDs to file for stop script
$pidFile = "$env:TEMP\opencode-orchestration-pids.txt"
$StartedProcesses | ForEach-Object {
    "$($_.Name)|$($_.Port)|$($_.PID)" | Out-File -Append -FilePath $pidFile
}

Write-Host ""
Write-Host "=== Orchestration Status ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Started $($StartedProcesses.Count) agents:" -ForegroundColor Gray

foreach ($agent in $StartedProcesses) {
    Write-Host "  - $($agent.Name)" -NoNewline -ForegroundColor White
    Write-Host " @ http://localhost:$($agent.Port)" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "PIDs saved to: $pidFile" -ForegroundColor DarkGray
Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host "Test agents:" -ForegroundColor Gray
Write-Host "  curl http://localhost:3051/" -ForegroundColor White
Write-Host ""
Write-Host "Stop orchestration:" -ForegroundColor Gray
Write-Host "  stop-opencode-orchestration.ps1" -ForegroundColor White
Write-Host ""

# Wait mode (for debugging)
if ($Wait) {
    Write-Host "Press Ctrl+C to stop all agents..." -ForegroundColor Yellow
    try {
        while ($true) {
            Start-Sleep -Seconds 1
        }
    } finally {
        Write-Host ""
        Write-Host "Stopping all agents..." -ForegroundColor Yellow
        & "$PSScriptRoot\stop-opencode-orchestration.ps1"
    }
}
