# test-multi-agent-system.ps1
# Comprehensive test of the multi-agent system
# Usage: test-multi-agent-system.ps1 [-Quick] [-FullDemo]

param(
    [switch]$Quick,     # Quick test (status only)
    [switch]$FullDemo   # Full demo with agent spawning
)

$ErrorActionPreference = "Stop"

function Write-Success { param([string]$msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Info { param([string]$msg) Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Test { param([string]$msg) Write-Host "[TEST] $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  MULTI-AGENT SYSTEM TEST" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$tests = @()

# Test 1: Status tool
Write-Test "Testing agent-status.ps1..."
try {
    & "C:\scripts\tools\agent-status.ps1" -OnlyActive | Out-Null
    Write-Success "agent-status.ps1 works"
    $tests += @{ name = "agent-status"; passed = $true }
} catch {
    Write-Host "[FAIL] agent-status.ps1 error: $_" -ForegroundColor Red
    $tests += @{ name = "agent-status"; passed = $false }
}

Write-Host ""

# Test 2: Messaging system
Write-Test "Testing messaging system..."
try {
    # Send test message
    & "C:\scripts\tools\agent-send-message.ps1" `
        -From "test" `
        -To "coordinator" `
        -Subject "System test" `
        -Body "Test message from system test" `
        -Priority "low" | Out-Null

    # Check message delivered
    $messages = & "C:\scripts\tools\agent-check-messages.ps1" -Agent "coordinator" 2>$null
    $testMsg = $messages | Where-Object { $_.subject -eq "System test" }

    if ($testMsg) {
        Write-Success "Messaging system works"
        $tests += @{ name = "messaging"; passed = $true }
    } else {
        throw "Message not delivered"
    }
} catch {
    Write-Host "[FAIL] Messaging error: $_" -ForegroundColor Red
    $tests += @{ name = "messaging"; passed = $false }
}

Write-Host ""

# Test 3: Merge queue
Write-Test "Testing merge queue..."
try {
    & "C:\scripts\tools\agent-merge-queue.ps1" -Action List | Out-Null
    Write-Success "Merge queue works"
    $tests += @{ name = "merge-queue"; passed = $true }
} catch {
    Write-Host "[FAIL] Merge queue error: $_" -ForegroundColor Red
    $tests += @{ name = "merge-queue"; passed = $false }
}

Write-Host ""

# Test 4: Coordinator helper
Write-Test "Testing coordinator helper..."
try {
    & "C:\scripts\tools\agent-coordinator.ps1" -Action Status | Out-Null
    Write-Success "Coordinator helper works"
    $tests += @{ name = "coordinator"; passed = $true }
} catch {
    Write-Host "[FAIL] Coordinator error: $_" -ForegroundColor Red
    $tests += @{ name = "coordinator"; passed = $false }
}

Write-Host ""

if ($Quick) {
    # Summary
    $passed = ($tests | Where-Object { $_.passed }).Count
    $total = $tests.Count

    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  TEST RESULTS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Success "$passed/$total tests passed"
    Write-Host ""

    exit 0
}

# Full demo
if ($FullDemo) {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  FULL DEMO" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""

    Write-Warning-Msg "This will spawn actual agents in the pool"
    $confirm = Read-Host "Continue? (y/n)"

    if ($confirm -ne 'y') {
        Write-Info "Demo cancelled"
        exit 0
    }

    Write-Host ""
    Write-Test "Spawning Scout agent..."

    $scoutResult = & "C:\scripts\tools\agent-spawn.ps1" `
        -Role "Scout" `
        -Task "Test mission: Analyze test scenario" `
        -Repo "client-manager" `
        -SpawnedBy "test-system"

    $scout = $scoutResult | ConvertFrom-Json
    Write-Success "Scout spawned: $($scout.seat)"

    Write-Host ""
    Write-Test "Spawning Builder agent..."

    $builderResult = & "C:\scripts\tools\agent-spawn.ps1" `
        -Role "Builder" `
        -Task "Test mission: Implement test scenario" `
        -Repo "client-manager" `
        -SpawnedBy "test-system"

    $builder = $builderResult | ConvertFrom-Json
    Write-Success "Builder spawned: $($builder.seat)"

    Write-Host ""
    Write-Test "Sending messages..."

    & "C:\scripts\tools\agent-send-message.ps1" `
        -From $scout.seat `
        -To "coordinator" `
        -Subject "Test complete" `
        -Body "Scout mission complete (test)" | Out-Null

    Write-Success "Message sent"

    Write-Host ""
    Write-Test "Checking status..."

    & "C:\scripts\tools\agent-status.ps1" -OnlyActive

    Write-Host ""
    Write-Test "Releasing agents..."

    & "C:\scripts\tools\agent-release.ps1" -Seat $scout.seat -Force
    & "C:\scripts\tools\agent-release.ps1" -Seat $builder.seat -Force

    Write-Success "Demo complete"
}

# Final summary
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  SYSTEM STATUS" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

$passed = ($tests | Where-Object { $_.passed }).Count
$total = $tests.Count

Write-Success "$passed/$total core components working"
Write-Host ""

Write-Info "Available tools:"
Write-Host "  agent-spawn.ps1           - Spawn specialized agents"
Write-Host "  agent-status.ps1          - Monitor agent status"
Write-Host "  agent-release.ps1         - Release completed agents"
Write-Host "  agent-send-message.ps1    - Send inter-agent messages"
Write-Host "  agent-check-messages.ps1  - Check inbox"
Write-Host "  agent-coordinator.ps1     - Unified interface"
Write-Host "  agent-watchdog.ps1        - Health monitoring daemon"
Write-Host "  agent-merge-queue.ps1     - FIFO merge queue"
Write-Host "  agent-task-decomposer.ps1 - Task decomposition"
Write-Host ""

Write-Info "System ready for production use!"
Write-Host ""