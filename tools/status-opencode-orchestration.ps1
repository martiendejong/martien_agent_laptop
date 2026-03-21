# status-opencode-orchestration.ps1
# Shows status of OpenCode orchestration agents

$ErrorActionPreference = "Stop"

Write-Host "=== OpenCode Orchestration Status ===" -ForegroundColor Cyan
Write-Host ""

# Expected agents and ports
$ExpectedAgents = @{
    "saas-dev" = 3051
    "wordpress-dev" = 3052
    "research-agent" = 3053
}

# Find running processes
$processes = Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*opencode*acp*"
}

if (!$processes) {
    Write-Host "[!] No OpenCode ACP servers running" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Start with: start-opencode-orchestration.ps1" -ForegroundColor Gray
    exit 0
}

Write-Host "[OK] Found $($processes.Count) OpenCode process(es)" -ForegroundColor Green
Write-Host ""

# Check each expected agent
Write-Host "=== Agent Status ===" -ForegroundColor Cyan
Write-Host ""

foreach ($agentName in $ExpectedAgents.Keys) {
    $port = $ExpectedAgents[$agentName]
    $url = "http://localhost:$port"

    Write-Host "[$agentName]" -ForegroundColor White
    Write-Host "  Port: $port" -ForegroundColor Gray

    # Try to connect
    try {
        $null = Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 2 -ErrorAction Stop
        Write-Host "  Status: " -NoNewline -ForegroundColor Gray
        Write-Host "RUNNING" -ForegroundColor Green
    } catch {
        Write-Host "  Status: " -NoNewline -ForegroundColor Gray
        Write-Host "NOT RESPONDING" -ForegroundColor Red
    }

    Write-Host ""
}

# Show process details
Write-Host "=== Process Details ===" -ForegroundColor Cyan
Write-Host ""

foreach ($proc in $processes) {
    Write-Host "PID: $($proc.Id)" -ForegroundColor White
    Write-Host "  Started: $($proc.StartTime)" -ForegroundColor Gray
    Write-Host "  CPU: $([math]::Round($proc.CPU, 2))s" -ForegroundColor Gray
    Write-Host "  Memory: $([math]::Round($proc.WorkingSet64 / 1MB, 2)) MB" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "=== Commands ===" -ForegroundColor Cyan
Write-Host "Stop all: " -NoNewline -ForegroundColor Gray
Write-Host "stop-opencode-orchestration.ps1" -ForegroundColor White
Write-Host ""
