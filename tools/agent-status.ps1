# agent-status.ps1
# Show status of all agents in the pool
# Usage: agent-status.ps1 [-Detailed] [-OnlyActive]

param(
    [switch]$Detailed,    # Show detailed info for each agent
    [switch]$OnlyActive   # Only show BUSY agents
)

$ErrorActionPreference = "Stop"

function Write-Success { param([string]$msg) Write-Host $msg -ForegroundColor Green }
function Write-Info { param([string]$msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Warning-Msg { param([string]$msg) Write-Host $msg -ForegroundColor Yellow }

$poolFile = "C:\scripts\_machine\worktrees.pool.md"
$mailDir = "C:\scripts\_machine\agent-mail"

if (-not (Test-Path $poolFile)) {
    Write-Host "[ERROR] Pool file not found: $poolFile" -ForegroundColor Red
    exit 1
}

# Parse pool
$poolContent = Get-Content $poolFile

# Find all agent rows (skip header and rules)
$agentRows = $poolContent | Where-Object { $_ -match '^\| agent-\d+' }

# Parse each row
$agents = @()
foreach ($row in $agentRows) {
    $parts = $row -split '\|' | ForEach-Object { $_.Trim() }

    if ($parts.Count -ge 9) {
        $agent = @{
            Seat = $parts[1]
            BaseBranch = $parts[2]
            BaseRepo = $parts[3]
            WorktreeRoot = $parts[4]
            Status = $parts[5]
            CurrentRepo = $parts[6]
            Branch = $parts[7]
            LastActivity = $parts[8]
            Notes = $parts[9]
        }

        # Parse role from notes if present
        if ($agent.Notes -match '\[(\w+)\]') {
            $agent.Role = $matches[1]
        } else {
            $agent.Role = "-"
        }

        # Count messages
        $inboxFile = "$mailDir\inbox\$($agent.Seat).jsonl"
        if (Test-Path $inboxFile) {
            $messages = Get-Content $inboxFile | ConvertFrom-Json
            $agent.UnreadMessages = ($messages | Where-Object { -not $_.read }).Count
            $agent.TotalMessages = $messages.Count
        } else {
            $agent.UnreadMessages = 0
            $agent.TotalMessages = 0
        }

        # Check worktree health
        $seatPath = $agent.WorktreeRoot
        if (Test-Path $seatPath) {
            $repos = Get-ChildItem -Path $seatPath -Directory -ErrorAction SilentlyContinue |
                     Where-Object { Test-Path "$($_.FullName)\.git" }
            $agent.WorktreeCount = $repos.Count
        } else {
            $agent.WorktreeCount = 0
        }

        $agents += $agent
    }
}

# Filter if OnlyActive
if ($OnlyActive) {
    $agents = $agents | Where-Object { $_.Status -eq 'BUSY' }
}

# Summary header
Write-Host ""
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "  AGENT STATUS DASHBOARD" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""

$busyCount = @($agents | Where-Object { $_.Status -eq 'BUSY' }).Count
$freeCount = @($agents | Where-Object { $_.Status -eq 'FREE' }).Count
$totalMessages = 0
foreach ($a in $agents) {
    $totalMessages += $a.TotalMessages
}

Write-Info "Total Agents: $($agents.Count)"
Write-Success "  FREE: $freeCount"
if ($busyCount -gt 0) {
    Write-Warning-Msg "  BUSY: $busyCount"
} else {
    Write-Host "  BUSY: $busyCount"
}
Write-Host "  Total Messages: $totalMessages"
Write-Host ""

# Show agents
if ($Detailed) {
    # Detailed view
    foreach ($agent in $agents) {
        $statusColor = if ($agent.Status -eq 'BUSY') { 'Yellow' } else { 'Green' }

        Write-Host "---------------------------------------------------------------" -ForegroundColor Gray
        Write-Host "  $($agent.Seat) [$($agent.Status)]" -ForegroundColor $statusColor
        Write-Host "---------------------------------------------------------------" -ForegroundColor Gray

        if ($agent.Status -eq 'BUSY') {
            Write-Host "  Role:         $($agent.Role)" -ForegroundColor White
            Write-Host "  Repository:   $($agent.CurrentRepo)" -ForegroundColor White
            Write-Host "  Branch:       $($agent.Branch)" -ForegroundColor White
            Write-Host "  Worktrees:    $($agent.WorktreeCount)" -ForegroundColor White
            Write-Host "  Messages:     $($agent.UnreadMessages) unread / $($agent.TotalMessages) total" -ForegroundColor White
            Write-Host "  Last Active:  $($agent.LastActivity)" -ForegroundColor Gray

            $taskDesc = $agent.Notes -replace '\[.*?\]\s*', ''
            Write-Host "  Task:         $taskDesc" -ForegroundColor White
        } else {
            Write-Host "  Available for assignment" -ForegroundColor Gray
            Write-Host "  Last task:    $($agent.Notes)" -ForegroundColor Gray
        }

        Write-Host ""
    }
} else {
    # Compact view
    Write-Host "Seat         Status  Role       Repo              Branch                    Messages"
    Write-Host "------------------------------------------------------------------------------------"

    foreach ($agent in $agents) {
        $statusColor = if ($agent.Status -eq 'BUSY') { 'Yellow' } elseif ($agent.Status -eq 'FREE') { 'Green' } else { 'Red' }

        $seat = $agent.Seat.PadRight(12)
        $status = $agent.Status.PadRight(7)
        $role = $agent.Role.PadRight(10)
        $repo = ($agent.CurrentRepo -replace '^$', '-').PadRight(17)
        $branchText = $agent.Branch -replace '^$', '-'
        $branch = $branchText.Substring(0, [Math]::Min($branchText.Length, 25)).PadRight(25)
        $messages = if ($agent.TotalMessages -gt 0) {
            "$($agent.UnreadMessages)/$($agent.TotalMessages)"
        } else {
            "-"
        }

        Write-Host "$seat " -NoNewline
        Write-Host "$status " -NoNewline -ForegroundColor $statusColor
        Write-Host "$role $repo $branch $messages"
    }

    Write-Host ""
    Write-Info "Use -Detailed for more information"
    Write-Info "Use -OnlyActive to show only BUSY agents"
}

Write-Host ""

# Show active agent summary
$activeAgents = $agents | Where-Object { $_.Status -eq 'BUSY' }

if ($activeAgents.Count -gt 0) {
    Write-Host "===============================================================" -ForegroundColor Cyan
    Write-Host "  ACTIVE MISSIONS" -ForegroundColor Cyan
    Write-Host "===============================================================" -ForegroundColor Cyan
    Write-Host ""

    foreach ($agent in $activeAgents) {
        $taskDesc = $agent.Notes -replace '\[.*?\]\s*', ''
        Write-Host "  [$($agent.Role)] " -NoNewline -ForegroundColor Yellow
        Write-Host "$($agent.Seat): " -NoNewline -ForegroundColor Cyan
        Write-Host "$taskDesc" -ForegroundColor White
    }

    Write-Host ""
}

# Return structured data for programmatic use (silent)
$agents | Out-Null
return
