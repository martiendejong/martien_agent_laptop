#!/usr/bin/env pwsh
# demo-embedded-learning.ps1 - Demonstrate embedded learning architecture
# Shows the complete cycle: logging → pattern detection → queue → improvements

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🧠 EMBEDDED LEARNING ARCHITECTURE - LIVE DEMO" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Phase 1: Initialize
Write-Host "PHASE 1: Initialize Learning System" -ForegroundColor Yellow
Write-Host "────────────────────────────────────" -ForegroundColor Yellow
& "C:\scripts\tools\init-embedded-learning.ps1" -Verbose
Start-Sleep -Seconds 1

# Phase 2: Simulate work with logging
Write-Host ""
Write-Host "PHASE 2: Simulate Work Session (with real-time logging)" -ForegroundColor Yellow
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor Yellow
Write-Host "Simulating: User asked to implement a feature..." -ForegroundColor Gray
Write-Host ""

# Action 1: Read CLAUDE.md
Write-Host "→ Action: Read CLAUDE.md" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Read CLAUDE.md" `
    -Reasoning "Check current workflow documentation" `
    -Outcome "Found relevant patterns"
Start-Sleep -Milliseconds 500

# Action 2: Allocate worktree
Write-Host "→ Action: Allocate worktree" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Allocate worktree" `
    -Reasoning "Feature mode - need isolated workspace" `
    -Outcome "Worktree allocated successfully"
Start-Sleep -Milliseconds 500

# Action 3: Allocate another worktree
Write-Host "→ Action: Allocate worktree (second time)" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Allocate worktree" `
    -Reasoning "Another feature - need another workspace" `
    -Outcome "Worktree allocated successfully"
Start-Sleep -Milliseconds 500

# Action 4: Allocate third worktree (triggers automation)
Write-Host "→ Action: Allocate worktree (third time - PATTERN!)" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Allocate worktree" `
    -Reasoning "Yet another feature - this is getting repetitive" `
    -Outcome "Worktree allocated successfully"
Start-Sleep -Milliseconds 500

# Action 5: Read CLAUDE.md again
Write-Host "→ Action: Read CLAUDE.md (second time)" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Read CLAUDE.md" `
    -Reasoning "Double-checking workflow steps" `
    -Outcome "Confirmed approach"
Start-Sleep -Milliseconds 500

# Action 6: Read CLAUDE.md third time
Write-Host "→ Action: Read CLAUDE.md (third time - PATTERN!)" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Read CLAUDE.md" `
    -Reasoning "Verifying one more time" `
    -Outcome "This is getting repetitive - should create quick-ref"
Start-Sleep -Milliseconds 500

# Action 7: Error scenario
Write-Host "→ Action: Build project (FAILED)" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Build project" `
    -Reasoning "Validate changes before PR" `
    -Outcome "ERROR: Missing migration"
Start-Sleep -Milliseconds 500

# Action 8: Same error again (CRITICAL)
Write-Host "→ Action: Build project (FAILED AGAIN - CRITICAL!)" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Build project" `
    -Reasoning "Retry after adding migration" `
    -Outcome "ERROR: Missing migration - same error twice!"
Start-Sleep -Milliseconds 500

# Phase 3: Pattern Detection
Write-Host ""
Write-Host "PHASE 3: Pattern Detection (automatic every 10 actions)" -ForegroundColor Yellow
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor Yellow
& "C:\scripts\tools\pattern-detector.ps1" -AutoAddToQueue
Start-Sleep -Seconds 2

# Phase 4: Session Analysis
Write-Host ""
Write-Host "PHASE 4: Session Analysis" -ForegroundColor Yellow
Write-Host "─────────────────────────" -ForegroundColor Yellow
& "C:\scripts\tools\analyze-session.ps1" -Detailed
Start-Sleep -Seconds 2

# Phase 5: Learning Queue Management
Write-Host ""
Write-Host "PHASE 5: Learning Queue (improvements detected)" -ForegroundColor Yellow
Write-Host "────────────────────────────────────────────────" -ForegroundColor Yellow
& "C:\scripts\tools\learning-queue.ps1" -Action list -SortBy roi
Start-Sleep -Seconds 2

# Phase 6: Process Queue (decision tree)
Write-Host ""
Write-Host "PHASE 6: Process Queue (automatic improvement decisions)" -ForegroundColor Yellow
Write-Host "──────────────────────────────────────────────────────────" -ForegroundColor Yellow
& "C:\scripts\tools\learning-queue.ps1" -Action process
Start-Sleep -Seconds 2

# Summary
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✅ EMBEDDED LEARNING DEMONSTRATION COMPLETE" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📊 What Just Happened:" -ForegroundColor Cyan
Write-Host "   1. ✅ Session initialized with embedded learning" -ForegroundColor White
Write-Host "   2. ✅ Actions logged in real-time during work" -ForegroundColor White
Write-Host "   3. ✅ Patterns detected automatically (3x = automation trigger)" -ForegroundColor White
Write-Host "   4. ✅ Errors flagged for immediate instruction updates" -ForegroundColor White
Write-Host "   5. ✅ Improvements added to learning queue with ROI" -ForegroundColor White
Write-Host "   6. ✅ Queue processed with risk-based decision tree" -ForegroundColor White
Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
Write-Host "   • Review learning queue: learning-queue.ps1 -Action list" -ForegroundColor Gray
Write-Host "   • Implement high-ROI items autonomously (LOW risk)" -ForegroundColor Gray
Write-Host "   • Suggest MEDIUM/HIGH risk items to user" -ForegroundColor Gray
Write-Host "   • Update reflection.log.md at session end" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 This is how learning becomes CONTINUOUS, not episodic!" -ForegroundColor Magenta
Write-Host ""
