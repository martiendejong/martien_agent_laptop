# agent-spawn.ps1
# Spawn a specialized agent in the worktree pool with a specific role
# Usage: agent-spawn.ps1 -Role Scout -Task "Analyze auth flow" -Repo "client-manager" [-SpawnedBy "coordinator"]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Scout", "Builder", "Reviewer", "Merger", "Coordinator")]
    [string]$Role,

    [Parameter(Mandatory=$true)]
    [string]$Task,

    [Parameter(Mandatory=$true)]
    [string]$Repo,

    [string]$Branch = "",  # If empty, generated from task
    [string]$SpawnedBy = "main",  # Who spawned this agent
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Success { param([string]$msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Error-Msg { param([string]$msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Info { param([string]$msg) Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Warning-Msg { param([string]$msg) Write-Host "[!] $msg" -ForegroundColor Yellow }

Write-Info "Agent Spawn Request"
Write-Host "  Role: $Role"
Write-Host "  Task: $Task"
Write-Host "  Repo: $Repo"
Write-Host "  Spawned by: $SpawnedBy"
Write-Host ""

# 1. Find free seat in pool
$poolFile = "C:\scripts\_machine\worktrees.pool.md"
if (-not (Test-Path $poolFile)) {
    Write-Error-Msg "Pool file not found: $poolFile"
    exit 1
}

$poolContent = Get-Content $poolFile -Raw
$freeSeats = $poolContent | Select-String -Pattern '\| (agent-\d+) \|[^|]*\|[^|]*\|[^|]*\| FREE \|' -AllMatches

if ($freeSeats.Matches.Count -eq 0) {
    Write-Warning-Msg "No free seats available. Need to provision new seat."

    # Find highest seat number
    $allSeats = $poolContent | Select-String -Pattern 'agent-(\d+)' -AllMatches
    $maxNumber = ($allSeats.Matches | ForEach-Object {
        [int]($_.Groups[1].Value)
    } | Measure-Object -Maximum).Maximum

    $newNumber = $maxNumber + 1
    $seat = "agent-$('{0:D3}' -f $newNumber)"

    Write-Info "Provisioning new seat: $seat"

    if (-not $DryRun) {
        # Create directory
        $seatPath = "C:\Projects\worker-agents\$seat"
        New-Item -ItemType Directory -Path $seatPath -Force | Out-Null

        # Add to pool (append new row)
        $newRow = "| $seat | agent$('{0:D3}' -f $newNumber) | C:\Projects | C:\Projects\worker-agents\$seat | FREE | - | - | $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')) | Provisioned for $Role role |"
        Add-Content -Path $poolFile -Value $newRow

        Write-Success "Seat $seat provisioned"
    }
} else {
    $seat = $freeSeats.Matches[0].Groups[1].Value
    Write-Info "Found free seat: $seat"
}

# 2. Generate branch name if not provided
if ([string]::IsNullOrEmpty($Branch)) {
    # Generate from task: "Analyze auth flow" -> "scout-analyze-auth-flow"
    $taskSlug = $Task.ToLower() -replace '[^a-z0-9]+', '-' -replace '^-|-$', ''
    $Branch = "$($Role.ToLower())-$taskSlug"
    Write-Info "Generated branch: $Branch"
}

# 3. Create worktree
$seatPath = "C:\Projects\worker-agents\$seat"
$repoPath = "$seatPath\$Repo"

Write-Info "Creating worktree at $repoPath"

if (-not $DryRun) {
    # Check if repo worktree already exists (shouldn't, but check)
    if (Test-Path "$repoPath\.git") {
        Write-Error-Msg "Worktree already exists at $repoPath. Seat may not be properly released."
        exit 1
    }

    # Create worktree from base repo
    $baseRepo = "C:\Projects\$Repo"
    if (-not (Test-Path $baseRepo)) {
        Write-Error-Msg "Base repository not found: $baseRepo"
        exit 1
    }

    Push-Location $baseRepo
    try {
        # Check if branch exists
        $branchExists = git branch --list $Branch
        if ($branchExists) {
            Write-Warning-Msg "Branch $Branch already exists. Using existing branch."
            git worktree add $repoPath $Branch 2>&1 | Out-Null
        } else {
            # Create new branch from develop
            git worktree add -b $Branch $repoPath develop 2>&1 | Out-Null
        }

        if ($LASTEXITCODE -ne 0) {
            Write-Error-Msg "Failed to create worktree"
            exit 1
        }

        Write-Success "Worktree created: $repoPath"
    } finally {
        Pop-Location
    }
}

# 4. Update pool tracking
Write-Info "Updating pool tracking"

if (-not $DryRun) {
    $timestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

    # Update pool file (mark seat as BUSY with role)
    $poolContent = Get-Content $poolFile -Raw
    $pattern = "\| $seat \|([^|]*)\|([^|]*)\|([^|]*)\| FREE \|([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)\|"
    $replacement = "| $seat |`$1|`$2|`$3| BUSY |`$4|`$5| $timestamp | [$Role] $Task (spawned by $SpawnedBy) |"
    $poolContent = $poolContent -replace $pattern, $replacement
    Set-Content -Path $poolFile -Value $poolContent -NoNewline

    Write-Success "Pool updated: $seat marked BUSY"
}

# 5. Create agent context file
$agentContextFile = "$seatPath\agent-context.json"

$agentContext = @{
    seat = $seat
    role = $Role
    task = $Task
    repo = $Repo
    branch = $Branch
    spawned_by = $SpawnedBy
    spawned_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    status = "active"
    permissions = @{
        read = $true
        write = ($Role -eq "Builder" -or $Role -eq "Merger" -or $Role -eq "Coordinator")
        commit = ($Role -eq "Builder" -or $Role -eq "Merger")
        push = ($Role -eq "Merger" -or $Role -eq "Coordinator")
        spawn_agents = ($Role -eq "Coordinator")
    }
} | ConvertTo-Json -Depth 10

if (-not $DryRun) {
    Set-Content -Path $agentContextFile -Value $agentContext
    Write-Success "Agent context created: $agentContextFile"
}

# 6. Create role-specific CLAUDE.md overlay
$claudeOverlay = "$seatPath\CLAUDE_OVERLAY.md"

$overlayContent = @"
# Agent Role: $Role

**Seat:** $seat
**Task:** $Task
**Repository:** $Repo
**Branch:** $Branch
**Spawned by:** $SpawnedBy

---

## Your Role: $Role

"@

switch ($Role) {
    "Scout" {
        $overlayContent += @"

You are a **Scout** agent - read-only explorer.

**Your Mission:**
$Task

**You CAN:**
- Read files (Read, Grep, Glob)
- Run read-only commands (git log, git diff, ls, etc.)
- Research and analyze
- Create reports and documentation

**You CANNOT:**
- Edit files (Edit, Write tools are blocked)
- Commit code
- Push to remote
- Create PRs

**Output Format:**
Create a research report at: ``$seatPath\scout-report.md``

Include:
- Findings
- Analysis
- Recommendations
- Code snippets (with file paths and line numbers)
- Next steps for Builder agent

When done, send message to coordinator: "Scout mission complete. Report ready."

"@
    }
    "Builder" {
        $overlayContent += @"

You are a **Builder** agent - implementation specialist.

**Your Mission:**
$Task

**You CAN:**
- Read and write files
- Edit code
- Create new files
- Commit changes (local only)
- Run tests

**You CANNOT:**
- Push to remote (Coordinator handles this)
- Create PRs (Coordinator handles this)
- Merge branches (Merger role handles this)

**Workflow:**
1. Read Scout report (if spawned after Scout): ``$seatPath\scout-report.md``
2. Implement changes
3. Write tests
4. Commit locally: ``git commit -m "[$Role] $Task"``
5. Send message to coordinator: "Builder mission complete. Ready for review."

**Quality Standards:**
- Follow existing code style
- Add tests for new functionality
- Update documentation
- No TODOs or FIXMEs

"@
    }
    "Reviewer" {
        $overlayContent += @"

You are a **Reviewer** agent - quality assurance specialist.

**Your Mission:**
$Task

**You CAN:**
- Read all files
- Run tests
- Run builds
- Check code quality
- Create review reports

**You CANNOT:**
- Edit code
- Commit changes
- Merge branches

**Review Checklist:**
- [ ] Code follows style guidelines
- [ ] Tests exist and pass
- [ ] No security vulnerabilities
- [ ] Performance acceptable
- [ ] Documentation updated
- [ ] No code smells

**Output Format:**
Create review at: ``$seatPath\review-report.md``

Include:
- Pass/Fail decision
- Issues found (with severity: Critical/Major/Minor)
- Recommendations
- Test results

Send message with verdict: "Review complete: APPROVED" or "Review complete: REJECTED (N issues)"

"@
    }
    "Merger" {
        $overlayContent += @"

You are a **Merger** agent - conflict resolution specialist.

**Your Mission:**
$Task

**You CAN:**
- All file operations
- All git operations
- Merge branches
- Resolve conflicts
- Push to remote
- Manage PRs

**Workflow:**
1. Check branch is approved by Reviewer
2. Merge develop into branch: ``git merge develop``
3. Resolve any conflicts
4. Run tests to verify
5. Push: ``git push origin $Branch``
6. Create PR or merge to develop
7. Send message: "Merge complete. PR #XXX created."

**Conflict Resolution:**
- Understand both sides of conflict
- Preserve functionality
- Run tests after resolution
- Document decisions in commit message

"@
    }
    "Coordinator" {
        $overlayContent += @"

You are a **Coordinator** agent - orchestrator.

**Your Mission:**
$Task

**You CAN:**
- Read all files
- Spawn specialized agents
- Monitor agent progress
- Coordinate merge order
- Make final decisions

**You CANNOT:**
- Edit code directly (spawn Builder instead)
- Merge directly (spawn Merger instead)

**Task Decomposition Strategy:**
1. Analyze task complexity
2. Break into subtasks
3. Spawn appropriate agents:
   - Scout for research
   - Builder for implementation
   - Reviewer for quality check
   - Merger for integration
4. Monitor progress via messaging
5. Coordinate dependencies
6. Report completion

**Spawning Agents:**
``````powershell
C:\scripts\tools\agent-spawn.ps1 ``
  -Role Scout ``
  -Task "Analyze authentication system" ``
  -Repo client-manager ``
  -SpawnedBy $seat
``````

"@
    }
}

$overlayContent += @"

---

## Communication

**Send messages:**
``````powershell
C:\scripts\tools\agent-send-message.ps1 ``
  -From $seat ``
  -To coordinator ``
  -Subject "Status update" ``
  -Body "Task 50% complete"
``````

**Check messages:**
``````powershell
C:\scripts\tools\agent-check-messages.ps1 -Agent $seat
``````

---

## When Done

1. Commit any remaining work
2. Send completion message to coordinator
3. DO NOT release seat yourself (coordinator handles this)

Your work will be reviewed and integrated by the coordinator.

---

**Agent spawned:** $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))
"@

if (-not $DryRun) {
    Set-Content -Path $claudeOverlay -Value $overlayContent
    Write-Success "Role overlay created: $claudeOverlay"
}

# 7. Output agent details
Write-Host ""
Write-Success "Agent Spawned Successfully!"
Write-Host ""
Write-Host "  Seat:   $seat" -ForegroundColor Cyan
Write-Host "  Role:   $Role" -ForegroundColor Cyan
Write-Host "  Task:   $Task" -ForegroundColor Cyan
Write-Host "  Repo:   $repoPath" -ForegroundColor Cyan
Write-Host "  Branch: $Branch" -ForegroundColor Cyan
Write-Host ""
Write-Info "Next steps:"
Write-Host "  1. cd $repoPath"
Write-Host "  2. Read CLAUDE_OVERLAY.md in parent directory"
Write-Host "  3. Execute your mission"
Write-Host "  4. Send completion message when done"
Write-Host ""

# Return agent info as JSON for programmatic use
$agentInfo = @{
    seat = $seat
    role = $Role
    task = $Task
    repo = $Repo
    repo_path = $repoPath
    branch = $Branch
    spawned_by = $SpawnedBy
    context_file = $agentContextFile
    overlay_file = $claudeOverlay
} | ConvertTo-Json -Compress

return $agentInfo
