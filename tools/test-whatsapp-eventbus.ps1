# Test WhatsApp EventBus Integration
# Verifies all components are working correctly

param(
    [switch]$SkipAPI  # Skip API tests (if API not running)
)

Write-Host "=== WhatsApp EventBus Integration Test ===" -ForegroundColor Cyan
Write-Host ""

$errors = 0
$warnings = 0

# Test 1: Check WhatsApp API credentials
Write-Host "[TEST 1] Checking WhatsApp API credentials..." -ForegroundColor Yellow
try {
    $vaultRaw = & "C:\scripts\tools\vault.ps1" -Action get -Service whatsapp-bridge-api
    $jsonString = $vaultRaw | Where-Object { $_ -match '^\s*\{' } | Select-Object -First 1
    $vault = $jsonString | ConvertFrom-Json

    if ($vault.username -and $vault.password) {
        Write-Host "  [PASS] Credentials found in vault" -ForegroundColor Green
        Write-Host "    Username: $($vault.username)" -ForegroundColor Gray
        Write-Host "    Token: $($vault.password.Substring(0, 20))..." -ForegroundColor Gray
    } else {
        Write-Host "  [FAIL] Credentials missing from vault" -ForegroundColor Red
        $errors++
    }
} catch {
    Write-Host "  [FAIL] Could not retrieve credentials: $_" -ForegroundColor Red
    $errors++
}
Write-Host ""

# Test 2: Test WhatsApp API connectivity
Write-Host "[TEST 2] Testing WhatsApp API connectivity..." -ForegroundColor Yellow
try {
    $vaultRaw = & "C:\scripts\tools\vault.ps1" -Action get -Service whatsapp-bridge-api
    $jsonString = $vaultRaw | Where-Object { $_ -match '^\s*\{' } | Select-Object -First 1
    $vault = $jsonString | ConvertFrom-Json

    $headers = @{
        'X-Api-Token' = $vault.password
        'X-Email' = $vault.username
        'Content-Type' = 'application/json'
    }

    $sessions = Invoke-RestMethod -Uri "https://whatsapp.wreckingball.ai:5001/api/external/whatsapp/sessions" -Headers $headers -TimeoutSec 10
    if ($sessions -and $sessions.Count -gt 0) {
        Write-Host "  [PASS] WhatsApp API accessible" -ForegroundColor Green
        Write-Host "    Session ID: $($sessions[0].sessionId)" -ForegroundColor Gray
        Write-Host "    Status: $($sessions[0].status)" -ForegroundColor Gray
        Write-Host "    Phone: $($sessions[0].phoneNumber)" -ForegroundColor Gray
    } else {
        Write-Host "  [WARN] No active WhatsApp sessions found" -ForegroundColor Yellow
        $warnings++
    }
} catch {
    Write-Host "  [FAIL] Could not connect to WhatsApp API: $_" -ForegroundColor Red
    $errors++
}
Write-Host ""

# Test 3: Check state file
Write-Host "[TEST 3] Checking poller state file..." -ForegroundColor Yellow
$stateFile = "C:\scripts\_machine\whatsapp-poller-state.json"
if (Test-Path $stateFile) {
    $state = Get-Content $stateFile | ConvertFrom-Json
    Write-Host "  [PASS] State file exists" -ForegroundColor Green
    Write-Host "    Last poll: $($state.lastPollTime)" -ForegroundColor Gray
    Write-Host "    Processed messages: $($state.processedMessageIds.Count)" -ForegroundColor Gray
} else {
    Write-Host "  [INFO] State file does not exist (will be created on first run)" -ForegroundColor Cyan
}
Write-Host ""

# Test 4: Check DataDrivenAI EventOrchestrator API
if (-not $SkipAPI) {
    Write-Host "[TEST 4] Testing DataDrivenAI API..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "https://localhost:7087/api/health" -TimeoutSec 5 -SkipCertificateCheck
        Write-Host "  [PASS] DataDrivenAI API accessible" -ForegroundColor Green
        Write-Host "    Status: $($response.status)" -ForegroundColor Gray
    } catch {
        Write-Host "  [FAIL] DataDrivenAI API not accessible: $_" -ForegroundColor Red
        Write-Host "    Make sure DataDrivenAI API is running:" -ForegroundColor Yellow
        Write-Host "    cd E:\projects\datadrivenai\backend\DataDrivenAI.API" -ForegroundColor Yellow
        Write-Host "    dotnet run" -ForegroundColor Yellow
        $errors++
    }
    Write-Host ""
} else {
    Write-Host "[TEST 4] Skipping DataDrivenAI API test (use -SkipAPI to skip)" -ForegroundColor Gray
    Write-Host ""
}

# Test 5: Check scheduled task
Write-Host "[TEST 5] Checking scheduled task..." -ForegroundColor Yellow
$task = Get-ScheduledTask -TaskName "WhatsAppEventBusPoller" -ErrorAction SilentlyContinue
if ($task) {
    $info = $task | Get-ScheduledTaskInfo
    Write-Host "  [PASS] Scheduled task exists" -ForegroundColor Green
    Write-Host "    State: $($task.State)" -ForegroundColor Gray
    Write-Host "    Last run: $($info.LastRunTime)" -ForegroundColor Gray
    Write-Host "    Next run: $($info.NextRunTime)" -ForegroundColor Gray
    Write-Host "    Last result: $($info.LastTaskResult) (0 = success)" -ForegroundColor Gray

    if ($task.State -ne "Ready") {
        Write-Host "  [WARN] Task state is not 'Ready'" -ForegroundColor Yellow
        $warnings++
    }
} else {
    Write-Host "  [INFO] Scheduled task not created yet" -ForegroundColor Cyan
    Write-Host "    Run: .\setup-whatsapp-poller-task.ps1" -ForegroundColor Yellow
}
Write-Host ""

# Test 6: Check log file
Write-Host "[TEST 6] Checking log file..." -ForegroundColor Yellow
$logFile = "E:\jengo\documents\temp\whatsapp-poller.log"
if (Test-Path $logFile) {
    $logSize = (Get-Item $logFile).Length
    $lastLines = Get-Content $logFile -Tail 5
    Write-Host "  [PASS] Log file exists" -ForegroundColor Green
    Write-Host "    Size: $([math]::Round($logSize / 1KB, 2)) KB" -ForegroundColor Gray
    Write-Host "    Last 3 lines:" -ForegroundColor Gray
    $lastLines | Select-Object -Last 3 | ForEach-Object {
        Write-Host "      $_" -ForegroundColor DarkGray
    }
} else {
    Write-Host "  [INFO] Log file does not exist (will be created on first run)" -ForegroundColor Cyan
}
Write-Host ""

# Test 7: Run poller manually (dry run)
Write-Host "[TEST 7] Running poller manually (test run)..." -ForegroundColor Yellow
try {
    $output = & "C:\scripts\tools\whatsapp-eventbus-poller.ps1" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [PASS] Poller executed successfully" -ForegroundColor Green

        # Parse output
        $output | ForEach-Object {
            if ($_ -match "Found (\d+) chats") {
                Write-Host "    Chats found: $($matches[1])" -ForegroundColor Gray
            }
            if ($_ -match "Active chats.*: (\d+)") {
                Write-Host "    Active chats: $($matches[1])" -ForegroundColor Gray
            }
            if ($_ -match "New messages found: (\d+)") {
                Write-Host "    New messages: $($matches[1])" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "  [FAIL] Poller failed with exit code $LASTEXITCODE" -ForegroundColor Red
        $errors++
    }
} catch {
    Write-Host "  [FAIL] Could not run poller: $_" -ForegroundColor Red
    $errors++
}
Write-Host ""

# Summary
Write-Host "=== Test Summary ===" -ForegroundColor Cyan
Write-Host ""
if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "  [SUCCESS] All tests passed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Ensure client-manager API is running" -ForegroundColor White
    Write-Host "  2. Create scheduled task: .\setup-whatsapp-poller-task.ps1" -ForegroundColor White
    Write-Host "  3. Monitor events: curl http://localhost:5000/api/events/recent" -ForegroundColor White
} elseif ($errors -eq 0) {
    Write-Host "  [OK] Tests passed with $warnings warning(s)" -ForegroundColor Yellow
} else {
    Write-Host "  [FAILED] $errors error(s), $warnings warning(s)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Review errors above and fix before proceeding" -ForegroundColor Yellow
}
Write-Host ""
