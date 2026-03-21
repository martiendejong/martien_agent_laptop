# setup-opencode-agents.ps1
# Installs OpenCode agent configurations and verifies setup

param(
    [switch]$Force,
    [switch]$Verify
)

$ErrorActionPreference = "Stop"

Write-Host "=== OpenCode Agent Setup ===" -ForegroundColor Cyan
Write-Host ""

# Configuration
$AgentDir = "$env:USERPROFILE\.local\share\opencode\agents"
$SourceDir = "$PSScriptRoot\..\opencode-agents"

# Agent definitions
$Agents = @(
    @{
        Name = "saas-dev"
        Description = "SaaS development (client-manager, hazina, brand2boost)"
        Port = 3051
        Color = "Green"
    },
    @{
        Name = "wordpress-dev"
        Description = "WordPress development (artrevisionist)"
        Port = 3052
        Color = "Blue"
    },
    @{
        Name = "research-agent"
        Description = "Read-only research and analysis"
        Port = 3053
        Color = "Yellow"
    }
)

# Create agents directory
if (!(Test-Path $AgentDir)) {
    Write-Host "[*] Creating agents directory..." -ForegroundColor Gray
    New-Item -ItemType Directory -Path $AgentDir -Force | Out-Null
    Write-Host "[OK] Directory created: $AgentDir" -ForegroundColor Green
} else {
    Write-Host "[OK] Agents directory exists" -ForegroundColor Green
}

# Check if agents are already configured
Write-Host ""
Write-Host "[*] Checking existing agents..." -ForegroundColor Gray

$ExistingAgents = @()
foreach ($agent in $Agents) {
    $agentFile = Join-Path $AgentDir "$($agent.Name).json"
    if (Test-Path $agentFile) {
        $ExistingAgents += $agent.Name
    }
}

if ($ExistingAgents.Count -gt 0 -and !$Force) {
    Write-Host "[!] Found existing agents: $($ExistingAgents -join ', ')" -ForegroundColor Yellow
    Write-Host "    Use -Force to overwrite" -ForegroundColor Gray
    if (!$Verify) {
        exit 0
    }
} else {
    Write-Host "[OK] No conflicts found" -ForegroundColor Green
}

# Verify agents with opencode
if ($Verify) {
    Write-Host ""
    Write-Host "[*] Verifying OpenCode installation..." -ForegroundColor Gray

    try {
        $version = & opencode --version 2>&1
        Write-Host "[OK] OpenCode v$version installed" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] OpenCode not found. Install with: npm install -g @opencode/cli" -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    Write-Host "[*] Listing configured agents..." -ForegroundColor Gray
    & opencode agent list | Out-String | Write-Host

    Write-Host ""
    Write-Host "[*] Agent verification complete" -ForegroundColor Green
}

# Summary
Write-Host ""
Write-Host "=== Agent Configuration Summary ===" -ForegroundColor Cyan
Write-Host ""

foreach ($agent in $Agents) {
    $agentFile = Join-Path $AgentDir "$($agent.Name).json"
    $status = if (Test-Path $agentFile) { "[OK]" } else { "[MISSING]" }
    $color = if (Test-Path $agentFile) { $agent.Color } else { "Red" }

    Write-Host "$status" -ForegroundColor $color -NoNewline
    Write-Host " $($agent.Name) " -NoNewline
    Write-Host "- $($agent.Description)" -ForegroundColor Gray
    Write-Host "      Port: $($agent.Port)" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Start orchestration:" -ForegroundColor Gray
Write-Host "   start-opencode-orchestration.ps1" -ForegroundColor White
Write-Host ""
Write-Host "2. Check status:" -ForegroundColor Gray
Write-Host "   Get-Process opencode" -ForegroundColor White
Write-Host ""
Write-Host "3. Test an agent:" -ForegroundColor Gray
Write-Host "   curl http://localhost:3051/health" -ForegroundColor White
Write-Host ""
