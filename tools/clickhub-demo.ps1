# ClickHub System Demo - Interactive Demonstration
# Version: 1.0.0
# Created: 2026-02-28

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║            CLICKHUB 2.0 SYSTEM DEMONSTRATION                ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nThis demo will showcase the new ClickHub 2.0 capabilities:" -ForegroundColor White
Write-Host "  1. Pattern Learning and Auto-Prioritization" -ForegroundColor Gray
Write-Host "  2. Multi-Agent Orchestration" -ForegroundColor Gray
Write-Host "  3. Crash Recovery" -ForegroundColor Gray
Write-Host "  4. Metrics Dashboard" -ForegroundColor Gray
Write-Host "  5. Notification System" -ForegroundColor Gray

Write-Host "`nPress any key to start demo..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Demo 1: Learning Engine
Write-Host "`n`n┌─ DEMO 1: PATTERN LEARNING ──────────────────────────────────┐" -ForegroundColor Cyan
Write-Host "Recording sample task completions and failures..." -ForegroundColor White

# Simulate successful task
Write-Host "`n[1/3] Recording successful task completion..." -ForegroundColor Gray
& "C:\scripts\tools\clickhub-learning-engine.ps1" `
    -Action RecordSuccess `
    -TaskId "demo-001" `
    -Project "client-manager" `
    -AgentId "agent-007" `
    -CompletionMinutes 35 `
    -Verbose

Start-Sleep -Seconds 2

# Simulate failure
Write-Host "`n[2/3] Recording task failure (merge conflict)..." -ForegroundColor Gray
& "C:\scripts\tools\clickhub-learning-engine.ps1" `
    -Action RecordFailure `
    -TaskId "demo-002" `
    -Project "art-revisionist" `
    -AgentId "agent-008" `
    -FailureReason "merge conflicts with develop" `
    -Verbose

Start-Sleep -Seconds 2

# Record more successes
Write-Host "`n[3/3] Recording multiple successes to build learning data..." -ForegroundColor Gray
& "C:\scripts\tools\clickhub-learning-engine.ps1" -Action RecordSuccess -TaskId "demo-003" -Project "hazina" -AgentId "agent-007" -CompletionMinutes 42 | Out-Null
& "C:\scripts\tools\clickhub-learning-engine.ps1" -Action RecordSuccess -TaskId "demo-004" -Project "client-manager" -AgentId "agent-009" -CompletionMinutes 28 | Out-Null

Start-Sleep -Seconds 1

Write-Host "`n[ANALYZING PATTERNS]" -ForegroundColor Yellow
& "C:\scripts\tools\clickhub-learning-engine.ps1" -Action AnalyzePatterns

Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Demo 2: Crash Recovery
Write-Host "`n`n┌─ DEMO 2: CRASH RECOVERY ────────────────────────────────────┐" -ForegroundColor Cyan
Write-Host "Simulating agent work with checkpoints..." -ForegroundColor White

Write-Host "`n[1/3] Creating checkpoint - analysis phase..." -ForegroundColor Gray
& "C:\scripts\tools\clickhub-crash-recovery.ps1" `
    -Action Checkpoint `
    -AgentId "agent-demo" `
    -TaskId "demo-crash-001" `
    -Project "client-manager" `
    -Phase "analysis" `
    -Metadata @{ task_name = "Add Google Login" } `
    -Verbose

Start-Sleep -Seconds 2

Write-Host "`n[2/3] Creating checkpoint - implementation phase..." -ForegroundColor Gray
& "C:\scripts\tools\clickhub-crash-recovery.ps1" `
    -Action Checkpoint `
    -AgentId "agent-demo" `
    -TaskId "demo-crash-001" `
    -Project "client-manager" `
    -Phase "implementation" `
    -Metadata @{ branch = "feature/demo-google-login" } `
    -Verbose

Start-Sleep -Seconds 2

Write-Host "`n[3/3] Listing all checkpoints..." -ForegroundColor Gray
& "C:\scripts\tools\clickhub-crash-recovery.ps1" -Action List

Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Demo 3: Metrics Dashboard
Write-Host "`n`n┌─ DEMO 3: METRICS DASHBOARD ─────────────────────────────────┐" -ForegroundColor Cyan
Write-Host "Displaying real-time metrics..." -ForegroundColor White

Start-Sleep -Seconds 1
& "C:\scripts\tools\clickhub-metrics-dashboard.ps1" -Action Show

Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Demo 4: Notifications
Write-Host "`n`n┌─ DEMO 4: NOTIFICATION SYSTEM ───────────────────────────────┐" -ForegroundColor Cyan
Write-Host "Testing notification system..." -ForegroundColor White

Write-Host "`n[1/2] Sending task blocked notification..." -ForegroundColor Gray
& "C:\scripts\tools\clickhub-notifications.ps1" `
    -EventType "TaskBlocked" `
    -Data @{
        task_id = "demo-001"
        task_name = "Add Google Login"
        project = "client-manager"
        reason = "Missing OAuth credentials"
        hours_blocked = 2.5
    } `
    -Test

Start-Sleep -Seconds 2

Write-Host "`n[2/2] Sending daily digest notification..." -ForegroundColor Gray
& "C:\scripts\tools\clickhub-notifications.ps1" `
    -EventType "DailyDigest" `
    -Data @{
        tasks_processed = 12
        success_rate = 83.3
        avg_completion = 38.5
        cost = 2.40
        top_failures = @(
            @{ pattern = "Merge conflicts"; count = 2 }
        )
        agents = @(
            @{ id = "agent-007"; tasks = 6; success_rate = 100 }
            @{ id = "agent-008"; tasks = 6; success_rate = 66.7 }
        )
    } `
    -Test

Write-Host "`n`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    DEMO COMPLETE!                           ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "  1. Review generated learning data in clickhub-learning.json" -ForegroundColor White
Write-Host "  2. Check crash recovery checkpoints in checkpoints/ directory" -ForegroundColor White
Write-Host "  3. Configure notifications in clickhub-notifications-config.json" -ForegroundColor White
Write-Host "  4. Start orchestrator for multi-agent operation" -ForegroundColor White

Write-Host "`nDocumentation: C:\scripts\_machine\CLICKHUB-SYSTEM-UPGRADE.md" -ForegroundColor Cyan
Write-Host ""
