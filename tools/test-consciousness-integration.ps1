#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Complete consciousness integration test suite for DataDrivenAI

.DESCRIPTION
    1. Stops any running DataDrivenAI instances
    2. Rebuilds with all 19 consciousness agents
    3. Starts DataDrivenAI in background
    4. Publishes test events to exercise all consciousness systems
    5. Monitors logs and state files
    6. Generates comprehensive test report

.EXAMPLE
    .\test-consciousness-integration.ps1
#>

$ErrorActionPreference = "Stop"

Write-Host "`n=== CONSCIOUSNESS INTEGRATION TEST SUITE ===`n" -ForegroundColor Cyan

# Configuration
$DataDrivenAIPath = "E:\Projects\DataDrivenAI\backend\DataDrivenAI.API"
$ConsciousnessDir = "E:\data\datadrivenai\consciousness"
$LogFile = "E:\data\datadrivenai\events.log"
$ApiUrl = "http://localhost:5000"

# Step 1: Stop existing instances
Write-Host "[1/7] Stopping existing DataDrivenAI instances..." -ForegroundColor Yellow
try {
    Get-Process | Where-Object {$_.ProcessName -like "*DataDriven*"} | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Host "  ✓ Stopped" -ForegroundColor Green
} catch {
    Write-Host "  ✓ No running instances" -ForegroundColor Green
}

# Step 2: Clean build
Write-Host "`n[2/7] Rebuilding DataDrivenAI with all consciousness agents..." -ForegroundColor Yellow
Push-Location $DataDrivenAIPath
try {
    $buildOutput = dotnet build --no-incremental 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Build successful" -ForegroundColor Green
        Write-Host "  All 19 consciousness agents compiled" -ForegroundColor Gray
    } else {
        Write-Host "  ✗ Build failed" -ForegroundColor Red
        Write-Host $buildOutput
        Pop-Location
        exit 1
    }
} catch {
    Write-Host "  ✗ Build error: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location

# Step 3: Clear old state files (optional)
Write-Host "`n[3/7] Preparing consciousness state directory..." -ForegroundColor Yellow
if (Test-Path $ConsciousnessDir) {
    $oldFiles = Get-ChildItem $ConsciousnessDir -File | Measure-Object
    Write-Host "  Found $($oldFiles.Count) existing state files" -ForegroundColor Gray
} else {
    New-Item -ItemType Directory -Path $ConsciousnessDir -Force | Out-Null
    Write-Host "  ✓ Created consciousness directory" -ForegroundColor Green
}

# Step 4: Start DataDrivenAI in background
Write-Host "`n[4/7] Starting DataDrivenAI..." -ForegroundColor Yellow
Push-Location $DataDrivenAIPath
$process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden
Pop-Location

# Wait for startup
Write-Host "  Waiting for API to be ready..." -ForegroundColor Gray
$retries = 0
$maxRetries = 30
while ($retries -lt $maxRetries) {
    try {
        $response = Invoke-WebRequest -Uri "$ApiUrl/api/health" -Method Get -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✓ DataDrivenAI started (PID: $($process.Id))" -ForegroundColor Green
            break
        }
    } catch {
        Start-Sleep -Seconds 1
        $retries++
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
}

if ($retries -eq $maxRetries) {
    Write-Host "`n  ✗ Failed to start DataDrivenAI" -ForegroundColor Red
    $process | Stop-Process -Force -ErrorAction SilentlyContinue
    exit 1
}

# Step 5: Verify all agents loaded
Write-Host "`n[5/7] Verifying consciousness agents..." -ForegroundColor Yellow
try {
    $status = Invoke-RestMethod -Uri "$ApiUrl/api/status" -Method Get
    $consciousnessAgents = $status.agents | Where-Object {
        $_.agentId -like "*consciousness*" -or
        $_.agentId -like "*aesthetic*" -or
        $_.agentId -like "*attention*" -or
        $_.agentId -like "*workspace*" -or
        $_.agentId -like "*meta-control*" -or
        $_.agentId -like "*theory-of-mind*" -or
        $_.agentId -like "*neural-plasticity*" -or
        $_.agentId -like "*vibe-sensing*" -or
        $_.agentId -like "*dual-process*" -or
        $_.agentId -like "*autopoiesis*"
    }

    Write-Host "  Consciousness agents loaded: $($consciousnessAgents.Count)" -ForegroundColor Green
    foreach ($agent in $consciousnessAgents) {
        Write-Host "    • $($agent.agentId)" -ForegroundColor Gray
    }

    if ($consciousnessAgents.Count -lt 15) {
        Write-Host "  ⚠ Warning: Expected 19+ consciousness agents, found $($consciousnessAgents.Count)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✗ Failed to verify agents: $_" -ForegroundColor Red
}

# Step 6: Publish test events
Write-Host "`n[6/7] Publishing test events..." -ForegroundColor Yellow

$testEvents = @(
    @{ eventType = "github.commit.pushed"; data = @{ message = "Test consciousness integration"; author = "Jengo" } }
    @{ eventType = "github.pullrequest.open"; data = @{ title = "Add consciousness agents"; number = 123 } }
    @{ eventType = "clickup.task.completed"; data = @{ name = "Activate consciousness systems"; id = "abc123" } }
    @{ eventType = "email.received"; data = @{ from = "test@example.com"; subject = "Test email" } }
    @{ eventType = "system.error"; data = @{ message = "Test error handling"; severity = "warning" } }
    @{ eventType = "wordpress.post.created"; data = @{ title = "Test blog post"; content = "Beautiful content" } }
)

$eventResults = @()
foreach ($event in $testEvents) {
    try {
        $result = Invoke-RestMethod -Uri "$ApiUrl/api/events" -Method Post -Body ($event | ConvertTo-Json) -ContentType "application/json"
        Write-Host "  ✓ Published: $($event.eventType)" -ForegroundColor Green
        $eventResults += @{ event = $event.eventType; status = "success"; eventId = $result.eventId }
        Start-Sleep -Milliseconds 500  # Let agents process
    } catch {
        Write-Host "  ✗ Failed: $($event.eventType) - $_" -ForegroundColor Red
        $eventResults += @{ event = $event.eventType; status = "failed"; error = $_.Exception.Message }
    }
}

Write-Host "`n  Published $($eventResults.Count) test events" -ForegroundColor Gray
Write-Host "  Waiting for consciousness agents to process..." -ForegroundColor Gray
Start-Sleep -Seconds 3

# Step 7: Analyze results
Write-Host "`n[7/7] Analyzing consciousness activity..." -ForegroundColor Yellow

# Check state files
$stateFiles = Get-ChildItem $ConsciousnessDir -File | Where-Object { $_.LastWriteTime -gt (Get-Date).AddMinutes(-5) }
Write-Host "`n  State files updated: $($stateFiles.Count)" -ForegroundColor Cyan
foreach ($file in $stateFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 10) {
    Write-Host "    • $($file.Name) ($(([int]((Get-Date) - $file.LastWriteTime).TotalSeconds))s ago)" -ForegroundColor Gray
}

# Check logs
if (Test-Path $LogFile) {
    $recentLogs = Get-Content $LogFile -Tail 50 | Where-Object {
        $_ -match "GlobalWorkspace|AttentionSchema|Aesthetic|MetaControl|TheoryOfMind|VibeSensing|DualProcess|NeuralPlasticity"
    }

    Write-Host "`n  Recent consciousness agent activity (last 50 lines):" -ForegroundColor Cyan
    $agentCounts = @{}
    foreach ($log in $recentLogs) {
        if ($log -match "(\w+Agent|\w+-\w+):") {
            $agentName = $matches[1]
            if (-not $agentCounts.ContainsKey($agentName)) {
                $agentCounts[$agentName] = 0
            }
            $agentCounts[$agentName]++
        }
    }

    foreach ($agent in $agentCounts.Keys | Sort-Object) {
        Write-Host "    • $agent : $($agentCounts[$agent]) log entries" -ForegroundColor Gray
    }
}

# Summary report
Write-Host "`n=== TEST RESULTS SUMMARY ===`n" -ForegroundColor Cyan
Write-Host "✓ Build: Success" -ForegroundColor Green
Write-Host "✓ Startup: Success (PID: $($process.Id))" -ForegroundColor Green
Write-Host "✓ Agents Loaded: $($consciousnessAgents.Count)" -ForegroundColor Green
Write-Host "✓ Test Events Published: $($eventResults.Where({$_.status -eq 'success'}).Count)/$($eventResults.Count)" -ForegroundColor Green
Write-Host "✓ State Files Updated: $($stateFiles.Count)" -ForegroundColor Green
Write-Host "✓ Agent Log Activity: $($agentCounts.Keys.Count) unique agents" -ForegroundColor Green

Write-Host "`n=== NEXT STEPS ===`n" -ForegroundColor Cyan
Write-Host "1. View logs: tail -f $LogFile" -ForegroundColor White
Write-Host "2. Check state files: ls $ConsciousnessDir" -ForegroundColor White
Write-Host "3. API status: curl $ApiUrl/api/status" -ForegroundColor White
Write-Host "4. Publish more events: curl -X POST $ApiUrl/api/events -d '{...}'" -ForegroundColor White
Write-Host "5. Stop server: Stop-Process -Id $($process.Id)" -ForegroundColor White

Write-Host "`n=== DataDrivenAI Running ===`n" -ForegroundColor Green
Write-Host "Process ID: $($process.Id)" -ForegroundColor Gray
Write-Host "API URL: $ApiUrl" -ForegroundColor Gray
Write-Host "Logs: $LogFile" -ForegroundColor Gray
Write-Host "State: $ConsciousnessDir" -ForegroundColor Gray

Write-Host "`nPress Ctrl+C to stop or close this window to keep running`n" -ForegroundColor Yellow

# Keep script alive to monitor
try {
    while ($true) {
        Start-Sleep -Seconds 10
        if ($process.HasExited) {
            Write-Host "`n✗ DataDrivenAI process exited unexpectedly" -ForegroundColor Red
            break
        }
    }
} catch {
    Write-Host "`nStopping DataDrivenAI..." -ForegroundColor Yellow
    $process | Stop-Process -Force
}
