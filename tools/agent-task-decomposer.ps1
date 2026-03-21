# agent-task-decomposer.ps1
# AI-assisted task decomposition for multi-agent coordination
# Usage: agent-task-decomposer.ps1 -Task "description" -Repo "client-manager" [-Execute]

param(
    [Parameter(Mandatory=$true)]
    [string]$Task,

    [Parameter(Mandatory=$true)]
    [string]$Repo,

    [switch]$Execute,  # Actually spawn agents (vs just plan)
    [switch]$AutoMerge  # Automatically process merge queue after completion
)

$ErrorActionPreference = "Stop"

function Write-Success { param([string]$msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Error-Msg { param([string]$msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Info { param([string]$msg) Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Warning-Msg { param([string]$msg) Write-Host "[!] $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  TASK DECOMPOSER" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Info "Task: $Task"
Write-Info "Repo: $Repo"
Write-Host ""

# Task analysis prompts
$analysisPrompt = @"
Analyze this software development task and decompose it into subtasks for specialized agents:

TASK: $Task
REPOSITORY: $Repo

Available agent roles:
- Scout (read-only): Research, analysis, pattern identification, documentation review
- Builder (read-write): Code implementation, tests, migrations
- Reviewer (read-only + tests): Code review, quality checks, security audit
- Merger (read-write + git): Branch merging, conflict resolution

Decomposition rules:
1. Simple tasks (1 file, <50 lines) → Single Builder
2. Medium tasks (3-5 files) → Scout (analyze) → Builder (implement) → Reviewer (check)
3. Complex tasks (10+ files, architectural) → Scout (analyze) → Multiple Builders (parallel) → Reviewer → Merger
4. Always start with Scout if requirements unclear
5. Use parallel Builders for independent components
6. End with Reviewer for quality gate
7. End with Merger if multiple branches need integration

Respond in JSON format:
{
  "complexity": "simple|medium|complex",
  "estimated_time_minutes": 30,
  "approach": "brief description",
  "steps": [
    {
      "order": 1,
      "role": "Scout",
      "task": "specific task description",
      "depends_on": [],
      "parallel": false
    },
    ...
  ]
}
"@

Write-Info "Analyzing task complexity..."
Write-Host ""

# Here we'd call an LLM API to analyze the task
# For now, simple heuristic-based decomposition

$steps = @()

# Heuristic: Check if task mentions "analyze", "research", "find"
$needsScout = $Task -match "(analyze|research|find|investigate|understand|document)"

# Heuristic: Check complexity keywords
$isComplex = $Task -match "(refactor|migrate|architect|redesign|multiple|several|all)"

if ($needsScout -or $isComplex) {
    $steps += @{
        order = 1
        role = "Scout"
        task = "Analyze existing codebase related to: $Task"
        depends_on = @()
        parallel = $false
    }
}

# Always need a Builder
$builderOrder = if ($steps.Count -gt 0) { 2 } else { 1 }
$builderDeps = if ($steps.Count -gt 0) { @(1) } else { @() }

$steps += @{
    order = $builderOrder
    role = "Builder"
    task = if ($needsScout) { "Implement based on Scout findings: $Task" } else { $Task }
    depends_on = $builderDeps
    parallel = $false
}

# Add Reviewer if complex
if ($isComplex) {
    $steps += @{
        order = $builderOrder + 1
        role = "Reviewer"
        task = "Review implementation for: $Task"
        depends_on = @($builderOrder)
        parallel = $false
    }
}

# Show decomposition
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  DECOMPOSITION PLAN" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

Write-Info "Complexity: $(if ($isComplex) { 'Complex' } elseif ($needsScout) { 'Medium' } else { 'Simple' })"
Write-Info "Steps: $($steps.Count)"
Write-Host ""

foreach ($step in $steps) {
    $depStr = if ($step.depends_on.Count -gt 0) {
        " (depends on step $($step.depends_on -join ', '))"
    } else {
        ""
    }

    Write-Host "Step $($step.order): " -NoNewline -ForegroundColor Cyan
    Write-Host "[$($step.role)]" -NoNewline -ForegroundColor Yellow
    Write-Host "$depStr" -ForegroundColor Gray
    Write-Host "  Task: $($step.task)" -ForegroundColor White
    Write-Host ""
}

if (-not $Execute) {
    Write-Host ""
    Write-Warning-Msg "Dry run mode. Use -Execute to spawn agents."
    Write-Host ""
    exit 0
}

# Execute plan
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  EXECUTION" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$spawnedAgents = @()

foreach ($step in $steps) {
    # Wait for dependencies
    if ($step.depends_on.Count -gt 0) {
        Write-Info "Step $($step.order): Waiting for dependencies..."

        $maxWait = 300  # 5 minutes max per dependency
        $checkInterval = 5  # Check every 5 seconds

        foreach ($depStep in $step.depends_on) {
            $depAgent = $spawnedAgents | Where-Object { $_.step -eq $depStep }

            if (-not $depAgent) {
                Write-Error-Msg "Dependency step $depStep not found"
                continue
            }

            Write-Info "  Waiting for $($depAgent.seat) to complete..."

            $waited = 0
            $completed = $false

            while ($waited -lt $maxWait) {
                # Check for completion message
                $messages = & "C:\scripts\tools\agent-check-messages.ps1" -Agent "coordinator" 2>$null

                $completionMsg = $messages | Where-Object {
                    $_.from -eq $depAgent.seat -and
                    $_.body -match "(complete|done|finished|ready)"
                }

                if ($completionMsg) {
                    Write-Success "  $($depAgent.seat) completed"
                    $completed = $true
                    break
                }

                Start-Sleep -Seconds $checkInterval
                $waited += $checkInterval

                if (($waited % 30) -eq 0) {
                    Write-Host "    Waiting... ($waited/$maxWait seconds)" -ForegroundColor Gray
                }
            }

            if (-not $completed) {
                Write-Warning-Msg "  $($depAgent.seat) did not complete in time. Proceeding anyway."
            }
        }

        Write-Host ""
    }

    # Spawn agent for this step
    Write-Info "Step $($step.order): Spawning $($step.role) agent..."

    $result = & "C:\scripts\tools\agent-spawn.ps1" `
        -Role $step.role `
        -Task $step.task `
        -Repo $Repo `
        -SpawnedBy "coordinator"

    if ($result) {
        $agentInfo = $result | ConvertFrom-Json

        $spawnedAgents += @{
            step = $step.order
            seat = $agentInfo.seat
            role = $step.role
            task = $step.task
        }

        Write-Success "Spawned: $($agentInfo.seat) ($($step.role))"
    } else {
        Write-Error-Msg "Failed to spawn agent for step $($step.order)"
    }

    Write-Host ""
}

# Summary
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  EXECUTION SUMMARY" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

Write-Info "Spawned $($spawnedAgents.Count) agent(s):"
foreach ($agent in $spawnedAgents) {
    Write-Host "  [$($agent.role)] $($agent.seat): $($agent.task)" -ForegroundColor Cyan
}

Write-Host ""
Write-Info "Monitor progress:"
Write-Host "  agent-status.ps1 -OnlyActive" -ForegroundColor Gray
Write-Host "  agent-check-messages.ps1 -Agent coordinator -Inject" -ForegroundColor Gray

Write-Host ""
Write-Info "Next steps:"
Write-Host "  1. Wait for agents to complete (check messages)"
Write-Host "  2. Review work: agent-status.ps1 -Detailed"
Write-Host "  3. Merge if approved: agent-merge-queue.ps1 -Action ProcessAll"
Write-Host "  4. Release agents: agent-coordinator.ps1 -Action ReleaseAll -Archive"

if ($AutoMerge) {
    Write-Host ""
    Write-Warning-Msg "AutoMerge enabled - will process merge queue after completion"
}

Write-Host ""
