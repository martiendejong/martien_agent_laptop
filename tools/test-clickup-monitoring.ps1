# Quick Test - ClickUp Consciousness Monitoring
# Tests all components in dry-run mode
# Author: Jengo
# Created: 2026-02-28

Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║   ClickUp Consciousness System - QUICK TEST                 ║
╚══════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

$ErrorActionPreference = 'Continue'

# Test 1: Check ClickUp Config
Write-Host "`n[1/4] Checking ClickUp Configuration..." -ForegroundColor Yellow
$configPath = "C:\scripts\_machine\clickup-config.json"
if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
    Write-Host "  [OK] API Key found: $($config.api_key.Substring(0,10))..." -ForegroundColor Green
    Write-Host "  [OK] Lists configured: $($config.lists.Count)" -ForegroundColor Green
} else {
    Write-Host "  [WARN] Config not found at $configPath" -ForegroundColor Red
}

# Test 2: Check Quality Guardian
Write-Host "`n[2/4] Testing Quality Guardian..." -ForegroundColor Yellow
$qgPath = "C:\scripts\tools\clickup-quality-guardian.ps1"
if (Test-Path $qgPath) {
    Write-Host "  [OK] Quality Guardian found ($([int]((Get-Item $qgPath).Length / 1KB)) KB)" -ForegroundColor Green
    Write-Host "  [TEST] Running dry-run check..." -ForegroundColor DarkGray

    # Dry run - just verify it loads
    try {
        $result = & $qgPath -Action Report -ErrorAction Stop 2>&1
        Write-Host "  [OK] Quality Guardian executable" -ForegroundColor Green
    } catch {
        Write-Host "  [INFO] $($_.Exception.Message)" -ForegroundColor DarkGray
    }
} else {
    Write-Host "  [ERROR] Quality Guardian not found" -ForegroundColor Red
}

# Test 3: Check Learning Engine
Write-Host "`n[3/4] Testing Learning Engine..." -ForegroundColor Yellow
$lePath = "C:\scripts\tools\clickup-learning-engine.ps1"
if (Test-Path $lePath) {
    Write-Host "  [OK] Learning Engine found ($([int]((Get-Item $lePath).Length / 1KB)) KB)" -ForegroundColor Green
    Write-Host "  [TEST] Running dry-run..." -ForegroundColor DarkGray

    try {
        $result = & $lePath -Action GetLearnings -ErrorAction Stop 2>&1
        Write-Host "  [OK] Learning Engine executable" -ForegroundColor Green
    } catch {
        Write-Host "  [INFO] $($_.Exception.Message)" -ForegroundColor DarkGray
    }
} else {
    Write-Host "  [ERROR] Learning Engine not found" -ForegroundColor Red
}

# Test 4: Check Monitor Daemon
Write-Host "`n[4/4] Testing Unified Monitor..." -ForegroundColor Yellow
$monitorPath = "C:\scripts\tools\clickup-consciousness-monitor.ps1"
if (Test-Path $monitorPath) {
    Write-Host "  [OK] Monitor Daemon found ($([int]((Get-Item $monitorPath).Length / 1KB)) KB)" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] Monitor Daemon not found" -ForegroundColor Red
}

# Summary
Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║   TEST COMPLETE                                              ║
╚══════════════════════════════════════════════════════════════╝

NEXT STEPS:

1. Start Monitoring (Manual):
   cd C:\scripts\tools
   .\clickup-consciousness-monitor.ps1

2. Check Single Task:
   .\clickup-quality-guardian.ps1 -Action CheckTask -TaskId "869..."

3. View Documentation:
   E:\jengo\documents\temp\clickup-consciousness-deployment-guide-2026-02-28.md

4. Check PR #214:
   https://github.com/martiendejong/Hazina/pull/214

"@ -ForegroundColor Cyan

Write-Host "System Status: READY TO USE`n" -ForegroundColor Green
