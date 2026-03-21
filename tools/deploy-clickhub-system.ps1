# ClickHub System Deployment
# Version: 1.0.0
# Created: 2026-02-28
# Deploys the complete ClickHub 2.0 system

param(
    [Parameter(Mandatory=$false)]
    [switch]$SkipTests,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "      CLICKHUB 2.0 SYSTEM DEPLOYMENT" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Step 1: Verify prerequisites
Write-Host "[1/8] Verifying prerequisites..." -ForegroundColor Yellow

$requiredDirs = @(
    "C:\scripts\tools",
    "C:\scripts\_machine",
    "C:\scripts\.claude\skills"
)

foreach ($dir in $requiredDirs) {
    if (-not (Test-Path $dir)) {
        Write-Host "  [ERROR] Required directory missing: $dir" -ForegroundColor Red
        exit 1
    }
}

Write-Host "  [OK] All required directories present" -ForegroundColor Green

# Step 2: Check for existing configuration
Write-Host "`n[2/8] Checking existing configuration..." -ForegroundColor Yellow

$clickupConfigPath = "C:\scripts\_machine\clickup-config.json"
if (-not (Test-Path $clickupConfigPath)) {
    Write-Host "  [ERROR] ClickUp config not found: $clickupConfigPath" -ForegroundColor Red
    Write-Host "  Please ensure clickup-config.json exists with your board configuration" -ForegroundColor Yellow
    exit 1
}

$clickupConfig = Get-Content $clickupConfigPath -Raw | ConvertFrom-Json
Write-Host "  [OK] ClickUp config found" -ForegroundColor Green
Write-Host "       Internal projects: $($clickupConfig.internal_projects.Count)" -ForegroundColor Gray
Write-Host "       Client projects: $($clickupConfig.client_projects.Count)" -ForegroundColor Gray

# Step 3: Verify core scripts exist
Write-Host "`n[3/8] Verifying core scripts..." -ForegroundColor Yellow

$coreScripts = @{
    "Learning Engine" = "C:\scripts\tools\clickhub-learning-engine.ps1"
    "Orchestrator" = "C:\scripts\tools\clickhub-orchestrator.ps1"
    "Crash Recovery" = "C:\scripts\tools\clickhub-crash-recovery.ps1"
    "Metrics Dashboard" = "C:\scripts\tools\clickhub-metrics-dashboard.ps1"
    "Notifications" = "C:\scripts\tools\clickhub-notifications.ps1"
    "Demo" = "C:\scripts\tools\clickhub-demo.ps1"
    "Tests" = "C:\scripts\tools\clickhub-tests.ps1"
}

$allPresent = $true
foreach ($script in $coreScripts.GetEnumerator()) {
    if (Test-Path $script.Value) {
        Write-Host "  [OK] $($script.Key)" -ForegroundColor Green
    }
    else {
        Write-Host "  [MISSING] $($script.Key): $($script.Value)" -ForegroundColor Red
        $allPresent = $false
    }
}

if (-not $allPresent) {
    Write-Host "`n[ERROR] Some core scripts are missing. Deployment cannot continue." -ForegroundColor Red
    exit 1
}

# Step 4: Initialize data files
Write-Host "`n[4/8] Initializing data files..." -ForegroundColor Yellow

# Learning data
$learningDataPath = "C:\scripts\_machine\clickhub-learning.json"
if (-not (Test-Path $learningDataPath)) {
    $learningData = @{
        version = "1.0.0"
        tasks = @{}
        failure_patterns = @{}
        success_patterns = @{}
        projects = @{}
        agents = @{}
        priority_weights = @{
            clickup_priority = 3.0
            historical_difficulty = 0.5
            blocks_other_tasks = 2.0
            age_days = 0.1
            user_requested = 5.0
            has_deadline = 4.0
            urgent_deadline_boost = 10.0
        }
    }

    if (-not $DryRun) {
        $learningData | ConvertTo-Json -Depth 10 | Set-Content $learningDataPath
        Write-Host "  [CREATED] Learning data file" -ForegroundColor Green
    }
    else {
        Write-Host "  [DRY RUN] Would create learning data file" -ForegroundColor Cyan
    }
}
else {
    Write-Host "  [EXISTS] Learning data file" -ForegroundColor Yellow
}

# Orchestrator state
$orchestratorStatePath = "C:\scripts\_machine\clickhub-orchestrator-state.json"
if (-not (Test-Path $orchestratorStatePath)) {
    $orchestratorState = @{
        version = "1.0.0"
        active_agents = @{}
        completed_tasks = @()
        failed_tasks = @()
        last_cycle = $null
        config = @{
            max_parallel_agents = 5
            cycle_interval_seconds = 300
            timeout_hours = 2
        }
    }

    if (-not $DryRun) {
        $orchestratorState | ConvertTo-Json -Depth 10 | Set-Content $orchestratorStatePath
        Write-Host "  [CREATED] Orchestrator state file" -ForegroundColor Green
    }
    else {
        Write-Host "  [DRY RUN] Would create orchestrator state file" -ForegroundColor Cyan
    }
}
else {
    Write-Host "  [EXISTS] Orchestrator state file" -ForegroundColor Yellow
}

# Notifications config
$notificationsConfigPath = "C:\scripts\_machine\clickhub-notifications-config.json"
if (-not (Test-Path $notificationsConfigPath)) {
    Write-Host "  [ERROR] Notifications config not found" -ForegroundColor Red
    Write-Host "  Expected: $notificationsConfigPath" -ForegroundColor Yellow
    Write-Host "  This file should have been created during initial setup" -ForegroundColor Yellow
    exit 1
}
else {
    Write-Host "  [EXISTS] Notifications config" -ForegroundColor Yellow
}

# Checkpoints directory
$checkpointsDir = "C:\scripts\_machine\checkpoints"
if (-not (Test-Path $checkpointsDir)) {
    if (-not $DryRun) {
        New-Item -ItemType Directory -Path $checkpointsDir | Out-Null
        Write-Host "  [CREATED] Checkpoints directory" -ForegroundColor Green
    }
    else {
        Write-Host "  [DRY RUN] Would create checkpoints directory" -ForegroundColor Cyan
    }
}
else {
    Write-Host "  [EXISTS] Checkpoints directory" -ForegroundColor Yellow
}

# Step 5: Run tests
if (-not $SkipTests) {
    Write-Host "`n[5/8] Running test suite..." -ForegroundColor Yellow

    if (-not $DryRun) {
        $testResult = & "C:\scripts\tools\clickhub-tests.ps1" -Suite All
        if ($LASTEXITCODE -ne 0) {
            Write-Host "`n[ERROR] Tests failed. Deployment cannot continue." -ForegroundColor Red
            Write-Host "Run with -SkipTests to bypass (not recommended for production)" -ForegroundColor Yellow
            exit 1
        }
        Write-Host "`n  [OK] All tests passed" -ForegroundColor Green
    }
    else {
        Write-Host "  [DRY RUN] Would run test suite" -ForegroundColor Cyan
    }
}
else {
    Write-Host "`n[5/8] Skipping tests (as requested)..." -ForegroundColor Yellow
}

# Step 6: Verify skill integration
Write-Host "`n[6/8] Verifying skill integration..." -ForegroundColor Yellow

$codingAgentSkill = "C:\scripts\.claude\skills\clickhub-coding-agent\SKILL.md"
$reviewerSkill = "C:\scripts\.claude\skills\clickup-reviewer\SKILL.md"

$skillsValid = $true

if (Test-Path $codingAgentSkill) {
    $content = Get-Content $codingAgentSkill -Raw
    if ($content -match "clickhub-learning-engine" -and $content -match "clickhub-crash-recovery") {
        Write-Host "  [OK] Coding agent skill properly integrated" -ForegroundColor Green
    }
    else {
        Write-Host "  [WARNING] Coding agent skill may not be fully integrated" -ForegroundColor Yellow
        $skillsValid = $false
    }
}
else {
    Write-Host "  [ERROR] Coding agent skill not found" -ForegroundColor Red
    $skillsValid = $false
}

if (Test-Path $reviewerSkill) {
    Write-Host "  [OK] Reviewer skill exists" -ForegroundColor Green
}
else {
    Write-Host "  [WARNING] Reviewer skill not found" -ForegroundColor Yellow
}

# Step 7: Create quick reference card
Write-Host "`n[7/8] Creating quick reference card..." -ForegroundColor Yellow

$quickRefPath = "C:\scripts\_machine\CLICKHUB-QUICK-REFERENCE.md"
$quickRef = @"
# ClickHub 2.0 Quick Reference

## Core Commands

### Learning Engine
``````powershell
# Record task success
.\clickhub-learning-engine.ps1 -Action RecordSuccess -TaskId <id> -Project <name> -AgentId <agent> -CompletionMinutes <num>

# Record task failure
.\clickhub-learning-engine.ps1 -Action RecordFailure -TaskId <id> -Project <name> -AgentId <agent> -FailureReason "<reason>"

# Analyze patterns
.\clickhub-learning-engine.ps1 -Action AnalyzePatterns

# Get statistics
.\clickhub-learning-engine.ps1 -Action GetStats
``````

### Orchestrator
``````powershell
# Start orchestration (background)
.\clickhub-orchestrator.ps1 -Action Start -MaxParallelAgents 5 -CycleIntervalSeconds 300

# Check status
.\clickhub-orchestrator.ps1 -Action Status

# Stop orchestration
.\clickhub-orchestrator.ps1 -Action Stop

# Balance workload
.\clickhub-orchestrator.ps1 -Action Balance
``````

### Crash Recovery
``````powershell
# Create checkpoint
.\clickhub-crash-recovery.ps1 -Action Checkpoint -AgentId <agent> -TaskId <id> -Project <name> -Phase <phase>

# List checkpoints
.\clickhub-crash-recovery.ps1 -Action List

# Recover from checkpoint
.\clickhub-crash-recovery.ps1 -Action Recover -CheckpointFile <path> -RecoveryOption <option>

# Clean old checkpoints
.\clickhub-crash-recovery.ps1 -Action Clean -OlderThanHours 48
``````

### Metrics Dashboard
``````powershell
# Show current metrics
.\clickhub-metrics-dashboard.ps1 -Action Show

# Export to file
.\clickhub-metrics-dashboard.ps1 -Action Export -OutputPath "metrics.json"

# Daily summary
.\clickhub-metrics-dashboard.ps1 -Action Daily

# Weekly summary
.\clickhub-metrics-dashboard.ps1 -Action Weekly
``````

### Notifications
``````powershell
# Test notification
.\clickhub-notifications.ps1 -EventType <type> -Data <hashtable> -Test
``````

### Testing
``````powershell
# Run all tests
.\clickhub-tests.ps1 -Suite All

# Run specific suite
.\clickhub-tests.ps1 -Suite Learning
``````

## Workflow

### Task Swimlanes
``````
TODO → IN PROGRESS/BUSY → REVIEW → TESTING → DONE
       ↓                  ↓
   BLOCKED/NEEDS INFO   TODO (if changes needed)
``````

### Agent Invocation

#### Default (internal + client projects)
``````
/clickhub-coding-agent
``````

#### Specific project
``````
/clickhub-coding-agent in hazina
``````

#### Specific list ID
``````
/clickhub-coding-agent in list 901215559249
``````

#### Multiple projects
``````
/clickhub-coding-agent in hazina, client-manager, art-revisionist
``````

## Key Files

- Learning data: ``C:\scripts\_machine\clickhub-learning.json``
- Orchestrator state: ``C:\scripts\_machine\clickhub-orchestrator-state.json``
- Notifications config: ``C:\scripts\_machine\clickhub-notifications-config.json``
- Checkpoints: ``C:\scripts\_machine\checkpoints\``
- Metrics history: ``C:\scripts\_machine\clickhub-metrics-history.jsonl``

## Monitoring

Check orchestrator status regularly:
``````powershell
.\clickhub-orchestrator.ps1 -Action Status
``````

View metrics dashboard:
``````powershell
.\clickhub-metrics-dashboard.ps1 -Action Show
``````

Review learning patterns:
``````powershell
.\clickhub-learning-engine.ps1 -Action AnalyzePatterns
``````

## Documentation

Full documentation: ``C:\scripts\_machine\CLICKHUB-SYSTEM-UPGRADE.md``
"@

if (-not $DryRun) {
    $quickRef | Set-Content $quickRefPath -Encoding UTF8
    Write-Host "  [CREATED] Quick reference card: $quickRefPath" -ForegroundColor Green
}
else {
    Write-Host "  [DRY RUN] Would create quick reference card" -ForegroundColor Cyan
}

# Step 8: Final summary
Write-Host "`n[8/8] Deployment summary" -ForegroundColor Yellow

Write-Host "`n  Core Scripts:" -ForegroundColor White
Write-Host "    - Learning Engine: clickhub-learning-engine.ps1" -ForegroundColor Gray
Write-Host "    - Orchestrator: clickhub-orchestrator.ps1" -ForegroundColor Gray
Write-Host "    - Crash Recovery: clickhub-crash-recovery.ps1" -ForegroundColor Gray
Write-Host "    - Metrics Dashboard: clickhub-metrics-dashboard.ps1" -ForegroundColor Gray
Write-Host "    - Notifications: clickhub-notifications.ps1" -ForegroundColor Gray
Write-Host "    - Demo: clickhub-demo.ps1" -ForegroundColor Gray
Write-Host "    - Tests: clickhub-tests.ps1" -ForegroundColor Gray

Write-Host "`n  Data Files:" -ForegroundColor White
Write-Host "    - Learning data: clickhub-learning.json" -ForegroundColor Gray
Write-Host "    - Orchestrator state: clickhub-orchestrator-state.json" -ForegroundColor Gray
Write-Host "    - Notifications config: clickhub-notifications-config.json" -ForegroundColor Gray
Write-Host "    - Checkpoints directory: checkpoints/" -ForegroundColor Gray

Write-Host "`n  Skills:" -ForegroundColor White
Write-Host "    - Coding Agent: /clickhub-coding-agent" -ForegroundColor Gray
Write-Host "    - Reviewer: /clickup-reviewer" -ForegroundColor Gray

Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Green
if ($DryRun) {
    Write-Host "     DRY RUN COMPLETE - No changes made" -ForegroundColor Cyan
}
else {
    Write-Host "     DEPLOYMENT COMPLETE" -ForegroundColor Green
}
Write-Host "════════════════════════════════════════════════════════════`n" -ForegroundColor Green

if (-not $DryRun) {
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Review quick reference: C:\scripts\_machine\CLICKHUB-QUICK-REFERENCE.md" -ForegroundColor White
    Write-Host "  2. Run demo: .\clickhub-demo.ps1" -ForegroundColor White
    Write-Host "  3. Configure notifications in clickhub-notifications-config.json" -ForegroundColor White
    Write-Host "  4. Start orchestrator: .\clickhub-orchestrator.ps1 -Action Start" -ForegroundColor White
    Write-Host "`nFull documentation: C:\scripts\_machine\CLICKHUB-SYSTEM-UPGRADE.md`n" -ForegroundColor Cyan
}
