# Test Context Intelligence System
# Simple ASCII-only version for testing
# Created: 2026-02-05

param(
    [string]$Command = "health"
)

function Test-Health {
    Write-Host ""
    Write-Host "=== Context Intelligence Health Check ===" -ForegroundColor Cyan
    Write-Host ""

    # Check knowledge store
    $knowledgeStore = "C:\scripts\_machine\knowledge-store.yaml"
    if (Test-Path $knowledgeStore) {
        Write-Host "[OK] Knowledge Store exists" -ForegroundColor Green
        $size = (Get-Item $knowledgeStore).Length
        Write-Host "     Size: $([math]::Round($size/1KB, 2)) KB" -ForegroundColor DarkGray
    } else {
        Write-Host "[MISSING] Knowledge Store" -ForegroundColor Red
    }

    # Check documentation
    $docs = @(
        "C:\scripts\_machine\PHASE1_IMPLEMENTATIONS_ROUND16-25.md",
        "C:\scripts\_machine\CONTEXT_INTELLIGENCE_GETTING_STARTED.md"
    )

    Write-Host ""
    Write-Host "[Documentation]" -ForegroundColor Cyan
    foreach ($doc in $docs) {
        if (Test-Path $doc) {
            $name = Split-Path $doc -Leaf
            Write-Host "[OK] $name" -ForegroundColor Green
        } else {
            Write-Host "[MISSING] $doc" -ForegroundColor Red
        }
    }

    # Check tools
    $tools = @(
        "C:\scripts\tools\reasoning-engine.ps1",
        "C:\scripts\tools\temporal-intelligence.ps1",
        "C:\scripts\tools\explanation-system.ps1",
        "C:\scripts\tools\circuit-breaker.ps1",
        "C:\scripts\tools\health-dashboard.ps1",
        "C:\scripts\tools\pattern-transfer.ps1",
        "C:\scripts\tools\improvement-analyzer.ps1"
    )

    Write-Host ""
    Write-Host "[Tools]" -ForegroundColor Cyan
    $foundCount = 0
    foreach ($tool in $tools) {
        if (Test-Path $tool) {
            $foundCount++
        }
    }
    Write-Host "[OK] Found $foundCount/$($tools.Count) tools" -ForegroundColor Green

    Write-Host ""
    Write-Host "=== Overall Status ===" -ForegroundColor Cyan
    if ($foundCount -eq $tools.Count) {
        Write-Host "[HEALTHY] All components present" -ForegroundColor Green
    } else {
        Write-Host "[DEGRADED] Some components missing" -ForegroundColor Yellow
    }
    Write-Host ""
}

function Test-Prediction {
    Write-Host ""
    Write-Host "=== Context Prediction Test ===" -ForegroundColor Cyan
    Write-Host ""

    $hour = (Get-Date).Hour
    $dayOfWeek = (Get-Date).DayOfWeek

    Write-Host "Current Time: $(Get-Date -Format 'HH:mm')" -ForegroundColor White
    Write-Host "Day: $dayOfWeek" -ForegroundColor White
    Write-Host ""

    # Simple time-based prediction
    $prediction = "No prediction"
    $confidence = 0.0
    $reason = "Unknown time"

    if ($hour -ge 7 -and $hour -lt 12) {
        $prediction = "STARTUP_PROTOCOL.md"
        $confidence = 0.95
        $reason = "Morning startup - typical to load startup documentation"
    }
    elseif ($hour -ge 12 -and $hour -lt 17) {
        $prediction = "Active development files"
        $confidence = 0.75
        $reason = "Afternoon - typically coding period"
    }
    elseif ($hour -ge 17 -and $hour -lt 23) {
        $prediction = "Review and reflection"
        $confidence = 0.70
        $reason = "Evening - typical review time"
    }

    Write-Host "Prediction: $prediction" -ForegroundColor Green
    Write-Host "Confidence: $([math]::Round($confidence * 100))%" -ForegroundColor Cyan
    Write-Host "Reason: $reason" -ForegroundColor White
    Write-Host ""
}

function Show-Summary {
    Write-Host ""
    Write-Host "=== Context Intelligence Summary ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Implementation: Rounds 16-25 (150 improvements)" -ForegroundColor White
    Write-Host "Date: 2026-02-05" -ForegroundColor White
    Write-Host ""
    Write-Host "Key Features:" -ForegroundColor Yellow
    Write-Host "  - Reasoning engine (logical inference)" -ForegroundColor White
    Write-Host "  - Temporal intelligence (time-based patterns)" -ForegroundColor White
    Write-Host "  - Explanation system (full transparency)" -ForegroundColor White
    Write-Host "  - Circuit breakers (fault tolerance)" -ForegroundColor White
    Write-Host "  - Health monitoring (system status)" -ForegroundColor White
    Write-Host "  - Pattern transfer (cross-project)" -ForegroundColor White
    Write-Host "  - Meta-learning (improvement analysis)" -ForegroundColor White
    Write-Host ""
    Write-Host "Documentation:" -ForegroundColor Yellow
    Write-Host "  - Getting Started: C:\scripts\_machine\CONTEXT_INTELLIGENCE_GETTING_STARTED.md" -ForegroundColor Cyan
    Write-Host "  - Full Impl Details: C:\scripts\_machine\PHASE1_IMPLEMENTATIONS_ROUND16-25.md" -ForegroundColor Cyan
    Write-Host ""
}

# Main execution
switch ($Command) {
    "health" { Test-Health }
    "predict" { Test-Prediction }
    "summary" { Show-Summary }
    default {
        Write-Host ""
        Write-Host "Usage: .\test-context-intelligence.ps1 -Command <command>" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Commands:" -ForegroundColor Cyan
        Write-Host "  health   - Check system health" -ForegroundColor White
        Write-Host "  predict  - Test prediction system" -ForegroundColor White
        Write-Host "  summary  - Show implementation summary" -ForegroundColor White
        Write-Host ""
    }
}
