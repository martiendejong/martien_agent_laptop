#!/usr/bin/env pwsh
# test-phase1.ps1 - Quick test of Phase 1 capabilities

Write-Host ""
Write-Host "PHASE 1 TEST: Semantic + Predictive Learning" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Create sample session log
Write-Host "1. Creating sample session log..." -ForegroundColor Yellow

$sampleLog = @"
{"timestamp":"2026-02-07T10:00:00","action":"Read CLAUDE.md","reasoning":"Check learning protocol","outcome":"Found embedded learning section","pattern_count":1}
{"timestamp":"2026-02-07T10:02:00","action":"Read API_PATTERNS.md","reasoning":"Looking for authentication examples","outcome":"Found JWT setup","pattern_count":1,"intent":"authentication"}
{"timestamp":"2026-02-07T10:05:00","action":"Grep jwt","reasoning":"Find all JWT references","outcome":"Found 12 matches","pattern_count":1,"intent":"authentication"}
{"timestamp":"2026-02-07T10:08:00","action":"Read knowledge-base/secrets","reasoning":"Check API keys location","outcome":"Found API keys registry","pattern_count":1,"intent":"authentication"}
{"timestamp":"2026-02-07T10:12:00","action":"Read CLAUDE.md","reasoning":"Verify MoSCoW prioritization","outcome":"Found MoSCoW section","pattern_count":2}
{"timestamp":"2026-02-07T10:15:00","action":"Allocate worktree","reasoning":"ClickUp task detected","outcome":"Worktree allocated","pattern_count":1}
{"timestamp":"2026-02-07T10:18:00","action":"Create branch","reasoning":"Start feature work","outcome":"Branch created","pattern_count":1}
{"timestamp":"2026-02-07T10:22:00","action":"Read CLAUDE.md","reasoning":"Check worktree protocol","outcome":"Found worktree workflow","pattern_count":3,"automation_trigger":true,"suggestion":"Consider automating: 'Read CLAUDE.md' has occurred 3 times this session"}
{"timestamp":"2026-02-07T10:25:00","action":"dotnet build","reasoning":"Verify code compiles","outcome":"Build successful","pattern_count":1}
{"timestamp":"2026-02-07T10:28:00","action":"dotnet test","reasoning":"Run unit tests","outcome":"All tests passed","pattern_count":1,"intent":"testing"}
"@

# Ensure directory exists
if (-not (Test-Path "C:\scripts\_machine")) {
    New-Item -ItemType Directory -Path "C:\scripts\_machine" -Force | Out-Null
}

$sampleLog | Out-File -FilePath "C:\scripts\_machine\current-session-log.jsonl" -Encoding utf8 -Force

Write-Host "   Sample session log created (10 actions)" -ForegroundColor Green
Write-Host ""

# 2. Run semantic pattern detector
Write-Host "2. Running semantic pattern detector..." -ForegroundColor Yellow
Write-Host ""

& "C:\scripts\tools\semantic-pattern-detector.ps1"

# 3. Create sample prediction model
Write-Host "3. Creating sample prediction model..." -ForegroundColor Yellow

$sampleModel = @{
    sequences = @{
        "Read CLAUDE.md" = @{
            "Grep learning" = @{
                probability = 0.853
                count = 12
            }
            "Read EMBEDDED_LEARNING_ARCHITECTURE.md" = @{
                probability = 0.721
                count = 8
            }
        }
        "Allocate worktree" = @{
            "Create branch" = @{
                probability = 0.95
                count = 19
            }
            "Read task details" = @{
                probability = 0.75
                count = 15
            }
        }
        "Read CLAUDE.md -> Grep learning" = @{
            "Read EMBEDDED_LEARNING_ARCHITECTURE.md" = @{
                probability = 0.88
                count = 14
            }
        }
    }
    metadata = @{
        trained_on = 20
        last_updated = "2026-02-07T15:30:00"
        total_patterns = 3
    }
}

$sampleModel | ConvertTo-Json -Depth 10 | Out-File -FilePath "C:\scripts\_machine\prediction-model.json" -Encoding utf8 -Force

Write-Host "   Sample prediction model created (20 sessions, 3 patterns)" -ForegroundColor Green
Write-Host ""

# 4. Run action predictor
Write-Host "4. Running action predictor (based on last action: 'Read CLAUDE.md')..." -ForegroundColor Yellow
Write-Host ""

& "C:\scripts\tools\action-predictor.ps1" -AutoSuggest

Write-Host ""
Write-Host "TEST COMPLETE" -ForegroundColor Green
Write-Host "=============" -ForegroundColor Green
Write-Host ""
Write-Host "What you just saw:" -ForegroundColor Cyan
Write-Host "  1. Semantic clustering: 'authentication' intent detected across different actions" -ForegroundColor Gray
Write-Host "  2. Automation trigger: 'Read CLAUDE.md' occurred 3x" -ForegroundColor Gray
Write-Host "  3. Predictive suggestions: Next likely action based on learned sequences" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  - Use actual sessions to train real model" -ForegroundColor Gray
Write-Host "  - Apply during work for real-time learning" -ForegroundColor Gray
Write-Host "  - Watch patterns emerge and suggestions improve" -ForegroundColor Gray
Write-Host ""
