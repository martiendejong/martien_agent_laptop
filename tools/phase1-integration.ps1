#!/usr/bin/env pwsh
# phase1-integration.ps1 - Integrate Phase 1: Semantic + Predictive Learning
# Run this at session start and periodically during work

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("init", "predict", "analyze", "train", "full")]
    [string]$Mode = "full",

    [Parameter(Mandatory=$false)]
    [switch]$AutoSuggest = $false
)

$ErrorActionPreference = "Continue"

switch ($Mode) {
    "init" {
        Write-Host "🚀 Initializing Phase 1: Semantic + Predictive Learning" -ForegroundColor Cyan
        Write-Host ""

        # Ensure directories exist
        $dirs = @(
            "C:\scripts\_machine\session-logs",
            "C:\scripts\_machine"
        )

        foreach ($dir in $dirs) {
            if (-not (Test-Path $dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
                Write-Host "✅ Created: $dir" -ForegroundColor Green
            }
        }

        # Check if model exists
        if (-not (Test-Path "C:\scripts\_machine\prediction-model.json")) {
            Write-Host "⚠️  No prediction model found" -ForegroundColor Yellow
            Write-Host "   Run: phase1-integration.ps1 -Mode train" -ForegroundColor Gray
        } else {
            Write-Host "✅ Prediction model exists" -ForegroundColor Green
        }

        # Check if taxonomy exists
        if (Test-Path "C:\scripts\_machine\intent-taxonomy.yaml") {
            Write-Host "✅ Intent taxonomy loaded" -ForegroundColor Green
        }

        Write-Host ""
        Write-Host "Phase 1 initialized ✓" -ForegroundColor Green
    }

    "predict" {
        Write-Host "🔮 Running Action Predictor..." -ForegroundColor Cyan
        Write-Host ""

        & "C:\scripts\tools\action-predictor.ps1" -AutoSuggest:$AutoSuggest
    }

    "analyze" {
        Write-Host "🧠 Running Semantic Pattern Detection..." -ForegroundColor Cyan
        Write-Host ""

        & "C:\scripts\tools\semantic-pattern-detector.ps1" -Detailed
    }

    "train" {
        Write-Host "🎓 Training Prediction Model..." -ForegroundColor Cyan
        Write-Host ""

        # Check if session logs exist
        if (-not (Test-Path "C:\scripts\_machine\session-logs")) {
            Write-Host "❌ Session logs directory not found" -ForegroundColor Red
            Write-Host "   Creating directory..." -ForegroundColor Yellow
            New-Item -ItemType Directory -Path "C:\scripts\_machine\session-logs" -Force | Out-Null
        }

        # Check if current session log exists and move it to session-logs
        if (Test-Path "C:\scripts\_machine\current-session-log.jsonl") {
            $timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
            $archivePath = "C:\scripts\_machine\session-logs\session-$timestamp.jsonl"
            Copy-Item "C:\scripts\_machine\current-session-log.jsonl" $archivePath -Force
            Write-Host "✅ Archived current session to: $archivePath" -ForegroundColor Green
        }

        # Train model
        & "C:\scripts\tools\predictive-engine.ps1" -Train

        Write-Host ""
        Write-Host "View model: phase1-integration.ps1 -Mode full" -ForegroundColor Cyan
    }

    "full" {
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "  PHASE 1: SEMANTIC + PREDICTIVE LEARNING" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""

        # 1. Semantic pattern detection
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        & "C:\scripts\tools\semantic-pattern-detector.ps1"

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        Write-Host ""

        # 2. Action prediction
        & "C:\scripts\tools\action-predictor.ps1" -AutoSuggest:$AutoSuggest

        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        Write-Host ""

        # 3. Show prediction model status
        if (Test-Path "C:\scripts\_machine\prediction-model.json") {
            $model = Get-Content "C:\scripts\_machine\prediction-model.json" | ConvertFrom-Json

            Write-Host "📊 Prediction Model Status:" -ForegroundColor Yellow
            Write-Host "   Trained on: $($model.metadata.trained_on) sessions" -ForegroundColor Gray
            Write-Host "   Patterns learned: $($model.metadata.total_patterns)" -ForegroundColor Gray
            Write-Host "   Last updated: $($model.metadata.last_updated)" -ForegroundColor Gray
            Write-Host ""
            Write-Host "   View details: predictive-engine.ps1 -ShowModel" -ForegroundColor Gray
        } else {
            Write-Host "⚠️  No prediction model found" -ForegroundColor Yellow
            Write-Host "   Train model: phase1-integration.ps1 -Mode train" -ForegroundColor Gray
        }

        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    }
}

Write-Host ""
