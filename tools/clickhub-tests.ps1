# ClickHub System Test Suite
# Version: 1.0.0
# Created: 2026-02-28

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("All", "Learning", "Orchestrator", "CrashRecovery", "Metrics", "Notifications", "Integration")]
    [string]$Suite = "All"
)

$ErrorActionPreference = "Stop"

# Test result tracking
$script:TestsPassed = 0
$script:TestsFailed = 0
$script:TestsSkipped = 0

function Write-TestResult {
    param($TestName, $Passed, $Message = "")

    if ($Passed) {
        Write-Host "[PASS] $TestName" -ForegroundColor Green
        $script:TestsPassed++
    } else {
        Write-Host "[FAIL] $TestName" -ForegroundColor Red
        if ($Message) {
            Write-Host "       $Message" -ForegroundColor Yellow
        }
        $script:TestsFailed++
    }
}

function Write-TestSkip {
    param($TestName, $Reason)
    Write-Host "[SKIP] $TestName - $Reason" -ForegroundColor Yellow
    $script:TestsSkipped++
}

function Test-FileExists {
    param($Path, $TestName)

    $exists = Test-Path $Path
    Write-TestResult -TestName $TestName -Passed $exists -Message "File not found: $Path"
    return $exists
}

function Test-JsonStructure {
    param($Path, $RequiredKeys, $TestName)

    try {
        $content = Get-Content $Path -Raw | ConvertFrom-Json
        $hasAllKeys = $true

        foreach ($key in $RequiredKeys) {
            if (-not ($content.PSObject.Properties.Name -contains $key)) {
                Write-TestResult -TestName $TestName -Passed $false -Message "Missing key: $key"
                return $false
            }
        }

        Write-TestResult -TestName $TestName -Passed $true
        return $true
    }
    catch {
        Write-TestResult -TestName $TestName -Passed $false -Message $_.Exception.Message
        return $false
    }
}

# ===== LEARNING ENGINE TESTS =====
function Test-LearningEngine {
    Write-Host "`n=== Learning Engine Tests ===" -ForegroundColor Cyan

    # Test 1: Script exists
    Test-FileExists -Path "C:\scripts\tools\clickhub-learning-engine.ps1" -TestName "Learning engine script exists"

    # Test 2: Data file structure
    Test-JsonStructure `
        -Path "C:\scripts\_machine\clickhub-learning.json" `
        -RequiredKeys @("version", "tasks", "failure_patterns", "success_patterns", "projects", "agents", "priority_weights") `
        -TestName "Learning data structure valid"

    # Test 3: Record success
    try {
        & "C:\scripts\tools\clickhub-learning-engine.ps1" `
            -Action RecordSuccess `
            -TaskId "test-001" `
            -Project "test-project" `
            -AgentId "test-agent" `
            -CompletionMinutes 10 | Out-Null

        $data = Get-Content "C:\scripts\_machine\clickhub-learning.json" -Raw | ConvertFrom-Json
        $taskExists = $data.tasks.PSObject.Properties.Name -contains "test-001"

        Write-TestResult -TestName "Record success functionality" -Passed $taskExists
    }
    catch {
        Write-TestResult -TestName "Record success functionality" -Passed $false -Message $_.Exception.Message
    }

    # Test 4: Record failure
    try {
        & "C:\scripts\tools\clickhub-learning-engine.ps1" `
            -Action RecordFailure `
            -TaskId "test-002" `
            -Project "test-project" `
            -AgentId "test-agent" `
            -FailureReason "Unit test failure" | Out-Null

        $data = Get-Content "C:\scripts\_machine\clickhub-learning.json" -Raw | ConvertFrom-Json
        $taskExists = $data.tasks.PSObject.Properties.Name -contains "test-002"

        Write-TestResult -TestName "Record failure functionality" -Passed $taskExists
    }
    catch {
        Write-TestResult -TestName "Record failure functionality" -Passed $false -Message $_.Exception.Message
    }

    # Test 5: Analyze patterns
    try {
        $output = & "C:\scripts\tools\clickhub-learning-engine.ps1" -Action AnalyzePatterns 2>&1
        $success = $output -match "Failure Patterns" -or $output -match "Success Patterns"

        Write-TestResult -TestName "Pattern analysis functionality" -Passed $success
    }
    catch {
        Write-TestResult -TestName "Pattern analysis functionality" -Passed $false -Message $_.Exception.Message
    }

    # Test 6: Priority calculation
    try {
        $testTasks = @(
            @{ id = "task1"; priority = 1; name = "Test Task 1"; status = "todo" }
            @{ id = "task2"; priority = 3; name = "Test Task 2"; status = "todo" }
        )

        $prioritized = & "C:\scripts\tools\clickhub-learning-engine.ps1" `
            -Action PrioritizeTasks `
            -Tasks $testTasks 2>&1

        $success = $prioritized -ne $null
        Write-TestResult -TestName "Task prioritization functionality" -Passed $success
    }
    catch {
        Write-TestResult -TestName "Task prioritization functionality" -Passed $false -Message $_.Exception.Message
    }
}

# ===== CRASH RECOVERY TESTS =====
function Test-CrashRecovery {
    Write-Host "`n=== Crash Recovery Tests ===" -ForegroundColor Cyan

    # Test 1: Script exists
    Test-FileExists -Path "C:\scripts\tools\clickhub-crash-recovery.ps1" -TestName "Crash recovery script exists"

    # Test 2: Create checkpoint
    try {
        & "C:\scripts\tools\clickhub-crash-recovery.ps1" `
            -Action Checkpoint `
            -AgentId "test-agent" `
            -TaskId "test-checkpoint-001" `
            -Project "test-project" `
            -Phase "analysis" `
            -Metadata @{ test = "true" } | Out-Null

        $checkpoints = Get-ChildItem "C:\scripts\_machine\checkpoints" -Filter "*test-checkpoint-001*.json"
        Write-TestResult -TestName "Create checkpoint functionality" -Passed ($checkpoints.Count -gt 0)
    }
    catch {
        Write-TestResult -TestName "Create checkpoint functionality" -Passed $false -Message $_.Exception.Message
    }

    # Test 3: List checkpoints
    try {
        $output = & "C:\scripts\tools\clickhub-crash-recovery.ps1" -Action List 2>&1
        $success = $output -match "Checkpoints" -or $output -match "No checkpoints"

        Write-TestResult -TestName "List checkpoints functionality" -Passed $success
    }
    catch {
        Write-TestResult -TestName "List checkpoints functionality" -Passed $false -Message $_.Exception.Message
    }

    # Test 4: Checkpoint directory exists
    Test-FileExists -Path "C:\scripts\_machine\checkpoints" -TestName "Checkpoint directory exists"
}

# ===== METRICS DASHBOARD TESTS =====
function Test-MetricsDashboard {
    Write-Host "`n=== Metrics Dashboard Tests ===" -ForegroundColor Cyan

    # Test 1: Script exists
    Test-FileExists -Path "C:\scripts\tools\clickhub-metrics-dashboard.ps1" -TestName "Metrics dashboard script exists"

    # Test 2: Show metrics
    try {
        $output = & "C:\scripts\tools\clickhub-metrics-dashboard.ps1" -Action Show 2>&1
        $success = $output -match "CLICKHUB METRICS" -or $output -match "Total Tasks"

        Write-TestResult -TestName "Show metrics functionality" -Passed $success
    }
    catch {
        Write-TestResult -TestName "Show metrics functionality" -Passed $false -Message $_.Exception.Message
    }

    # Test 3: History file created
    $historyExists = Test-Path "C:\scripts\_machine\clickhub-metrics-history.jsonl"
    Write-TestResult -TestName "Metrics history tracking" -Passed $historyExists
}

# ===== NOTIFICATIONS TESTS =====
function Test-Notifications {
    Write-Host "`n=== Notifications Tests ===" -ForegroundColor Cyan

    # Test 1: Script exists
    Test-FileExists -Path "C:\scripts\tools\clickhub-notifications.ps1" -TestName "Notifications script exists"

    # Test 2: Config exists and valid
    Test-JsonStructure `
        -Path "C:\scripts\_machine\clickhub-notifications-config.json" `
        -RequiredKeys @("version", "enabled", "channels", "thresholds", "notification_rules") `
        -TestName "Notifications config structure valid"

    # Test 3: Test notification (TaskBlocked)
    try {
        & "C:\scripts\tools\clickhub-notifications.ps1" `
            -EventType "TaskBlocked" `
            -Data @{
                task_id = "test-001"
                task_name = "Test Task"
                project = "test-project"
                reason = "Test reason"
                hours_blocked = 1
            } `
            -Test | Out-Null

        Write-TestResult -TestName "TaskBlocked notification" -Passed $true
    }
    catch {
        Write-TestResult -TestName "TaskBlocked notification" -Passed $false -Message $_.Exception.Message
    }

    # Test 4: Test notification (DailyDigest)
    try {
        & "C:\scripts\tools\clickhub-notifications.ps1" `
            -EventType "DailyDigest" `
            -Data @{
                tasks_processed = 10
                success_rate = 85
                avg_completion = 35
                cost = 2.50
                top_failures = @()
                agents = @()
            } `
            -Test | Out-Null

        Write-TestResult -TestName "DailyDigest notification" -Passed $true
    }
    catch {
        Write-TestResult -TestName "DailyDigest notification" -Passed $false -Message $_.Exception.Message
    }
}

# ===== ORCHESTRATOR TESTS =====
function Test-Orchestrator {
    Write-Host "`n=== Orchestrator Tests ===" -ForegroundColor Cyan

    # Test 1: Script exists
    Test-FileExists -Path "C:\scripts\tools\clickhub-orchestrator.ps1" -TestName "Orchestrator script exists"

    # Test 2: State file structure
    Test-JsonStructure `
        -Path "C:\scripts\_machine\clickhub-orchestrator-state.json" `
        -RequiredKeys @("version", "active_agents", "completed_tasks", "failed_tasks") `
        -TestName "Orchestrator state structure valid"

    # Test 3: Status check
    try {
        $output = & "C:\scripts\tools\clickhub-orchestrator.ps1" -Action Status 2>&1
        $success = $output -match "Active Agents" -or $output -match "No active agents"

        Write-TestResult -TestName "Orchestrator status check" -Passed $success
    }
    catch {
        Write-TestResult -TestName "Orchestrator status check" -Passed $false -Message $_.Exception.Message
    }
}

# ===== INTEGRATION TESTS =====
function Test-Integration {
    Write-Host "`n=== Integration Tests ===" -ForegroundColor Cyan

    # Test 1: Skill files updated
    $codingSkillPath = "C:\scripts\.claude\skills\clickhub-coding-agent\SKILL.md"
    if (Test-Path $codingSkillPath) {
        $content = Get-Content $codingSkillPath -Raw
        $hasLearning = $content -match "clickhub-learning-engine"
        $hasCrashRecovery = $content -match "clickhub-crash-recovery"

        Write-TestResult -TestName "Coding agent skill integration" -Passed ($hasLearning -and $hasCrashRecovery)
    }
    else {
        Write-TestSkip -TestName "Coding agent skill integration" -Reason "Skill file not found"
    }

    # Test 2: All core files present
    $coreFiles = @(
        "C:\scripts\tools\clickhub-learning-engine.ps1",
        "C:\scripts\tools\clickhub-orchestrator.ps1",
        "C:\scripts\tools\clickhub-crash-recovery.ps1",
        "C:\scripts\tools\clickhub-metrics-dashboard.ps1",
        "C:\scripts\tools\clickhub-notifications.ps1",
        "C:\scripts\tools\clickhub-demo.ps1"
    )

    $allPresent = $true
    foreach ($file in $coreFiles) {
        if (-not (Test-Path $file)) {
            $allPresent = $false
            break
        }
    }

    Write-TestResult -TestName "All core system files present" -Passed $allPresent

    # Test 3: Documentation exists
    Test-FileExists -Path "C:\scripts\_machine\CLICKHUB-SYSTEM-UPGRADE.md" -TestName "System documentation exists"

    # Test 4: Config files present
    $configFiles = @(
        "C:\scripts\_machine\clickhub-learning.json",
        "C:\scripts\_machine\clickhub-orchestrator-state.json",
        "C:\scripts\_machine\clickhub-notifications-config.json"
    )

    $allConfigsPresent = $true
    foreach ($file in $configFiles) {
        if (-not (Test-Path $file)) {
            $allConfigsPresent = $false
            break
        }
    }

    Write-TestResult -TestName "All config files present" -Passed $allConfigsPresent
}

# ===== MAIN EXECUTION =====
Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "           CLICKHUB SYSTEM TEST SUITE" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

$startTime = Get-Date

switch ($Suite) {
    "All" {
        Test-LearningEngine
        Test-CrashRecovery
        Test-MetricsDashboard
        Test-Notifications
        Test-Orchestrator
        Test-Integration
    }
    "Learning" { Test-LearningEngine }
    "Orchestrator" { Test-Orchestrator }
    "CrashRecovery" { Test-CrashRecovery }
    "Metrics" { Test-MetricsDashboard }
    "Notifications" { Test-Notifications }
    "Integration" { Test-Integration }
}

$duration = (Get-Date) - $startTime

# Summary
Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "                    TEST SUMMARY" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Passed:  $script:TestsPassed" -ForegroundColor Green
Write-Host "  Failed:  $script:TestsFailed" -ForegroundColor $(if ($script:TestsFailed -gt 0) { "Red" } else { "Green" })
Write-Host "  Skipped: $script:TestsSkipped" -ForegroundColor Yellow
Write-Host "  Duration: $([math]::Round($duration.TotalSeconds, 2))s" -ForegroundColor White
Write-Host "════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Exit code
if ($script:TestsFailed -gt 0) {
    exit 1
}
else {
    exit 0
}
