<#
.SYNOPSIS
    !/usr/bin/env pwsh

.DESCRIPTION
    !/usr/bin/env pwsh

.NOTES
    File: demo-embedded-learning.ps1
    Auto-generated help documentation
#>

$ErrorActionPreference = "Stop"

#!/usr/bin/env pwsh
# demo-embedded-learning.ps1 - Demonstrate embedded learning architecture
# Shows the complete cycle: logging â†’ pattern detection â†’ queue â†’ improvements

Write-Host ""
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host "  ðŸ§  EMBEDDED LEARNING ARCHITECTURE - LIVE DEMO" -ForegroundColor Cyan
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host ""

# Phase 1: Initialize
Write-Host "PHASE 1: Initialize Learning System" -ForegroundColor Yellow
Write-Host "â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€" -ForegroundColor Yellow
& "C:\scripts\tools\init-embedded-learning.ps1" -Verbose
Start-Sleep -Seconds 1

# Phase 2: Simulate work with logging
Write-Host ""
Write-Host "PHASE 2: Simulate Work Session (with real-time logging)" -ForegroundColor Yellow
Write-Host "â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€" -ForegroundColor Yellow
Write-Host "Simulating: User asked to implement a feature..." -ForegroundColor Gray
Write-Host ""

# Action 1: Read CLAUDE.md
Write-Host "â†’ Action: Read CLAUDE.md" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Read CLAUDE.md" `
    -Reasoning "Check current workflow documentation" `
    -Outcome "Found relevant patterns"
Start-Sleep -Milliseconds 500

# Action 2: Allocate worktree
Write-Host "â†’ Action: Allocate worktree" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Allocate worktree" `
    -Reasoning "Feature mode - need isolated workspace" `
    -Outcome "Worktree allocated successfully"
Start-Sleep -Milliseconds 500

# Action 3: Allocate another worktree
Write-Host "â†’ Action: Allocate worktree (second time)" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Allocate worktree" `
    -Reasoning "Another feature - need another workspace" `
    -Outcome "Worktree allocated successfully"
Start-Sleep -Milliseconds 500

# Action 4: Allocate third worktree (triggers automation)
Write-Host "â†’ Action: Allocate worktree (third time - PATTERN!)" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Allocate worktree" `
    -Reasoning "Yet another feature - this is getting repetitive" `
    -Outcome "Worktree allocated successfully"
Start-Sleep -Milliseconds 500

# Action 5: Read CLAUDE.md again
Write-Host "â†’ Action: Read CLAUDE.md (second time)" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Read CLAUDE.md" `
    -Reasoning "Double-checking workflow steps" `
    -Outcome "Confirmed approach"
Start-Sleep -Milliseconds 500

# Action 6: Read CLAUDE.md third time
Write-Host "â†’ Action: Read CLAUDE.md (third time - PATTERN!)" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Read CLAUDE.md" `
    -Reasoning "Verifying one more time" `
    -Outcome "This is getting repetitive - should create quick-ref"
Start-Sleep -Milliseconds 500

# Action 7: Error scenario
Write-Host "â†’ Action: Build project (FAILED)" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Build project" `
    -Reasoning "Validate changes before PR" `
    -Outcome "ERROR: Missing migration"
Start-Sleep -Milliseconds 500

# Action 8: Same error again (CRITICAL)
Write-Host "â†’ Action: Build project (FAILED AGAIN - CRITICAL!)" -ForegroundColor Cyan
& "C:\scripts\tools\log-action.ps1" `
    -Action "Build project" `
    -Reasoning "Retry after adding migration" `
    -Outcome "ERROR: Missing migration - same error twice!"
Start-Sleep -Milliseconds 500

# Phase 3: Pattern Detection
Write-Host ""
Write-Host "PHASE 3: Pattern Detection (automatic every 10 actions)" -ForegroundColor Yellow
Write-Host "â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€" -ForegroundColor Yellow
& "C:\scripts\tools\pattern-detector.ps1" -AutoAddToQueue
Start-Sleep -Seconds 2

# Phase 4: Session Analysis
Write-Host ""
Write-Host "PHASE 4: Session Analysis" -ForegroundColor Yellow
Write-Host "â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€" -ForegroundColor Yellow
& "C:\scripts\tools\analyze-session.ps1" -Detailed
Start-Sleep -Seconds 2

# Phase 5: Learning Queue Management
Write-Host ""
Write-Host "PHASE 5: Learning Queue (improvements detected)" -ForegroundColor Yellow
Write-Host "â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€" -ForegroundColor Yellow
& "C:\scripts\tools\learning-queue.ps1" -Action list -SortBy roi
Start-Sleep -Seconds 2

# Phase 6: Process Queue (decision tree)
Write-Host ""
Write-Host "PHASE 6: Process Queue (automatic improvement decisions)" -ForegroundColor Yellow
Write-Host "â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€" -ForegroundColor Yellow
& "C:\scripts\tools\learning-queue.ps1" -Action process
Start-Sleep -Seconds 2

# Summary
Write-Host ""
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Green
Write-Host "  âœ… EMBEDDED LEARNING DEMONSTRATION COMPLETE" -ForegroundColor Green
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Green
Write-Host ""
Write-Host "ðŸ“Š What Just Happened:" -ForegroundColor Cyan
Write-Host "   1. âœ… Session initialized with embedded learning" -ForegroundColor White
Write-Host "   2. âœ… Actions logged in real-time during work" -ForegroundColor White
Write-Host "   3. âœ… Patterns detected automatically (3x = automation trigger)" -ForegroundColor White
Write-Host "   4. âœ… Errors flagged for immediate instruction updates" -ForegroundColor White
Write-Host "   5. âœ… Improvements added to learning queue with ROI" -ForegroundColor White
Write-Host "   6. âœ… Queue processed with risk-based decision tree" -ForegroundColor White
Write-Host ""
Write-Host "ðŸŽ¯ Next Steps:" -ForegroundColor Cyan
Write-Host "   â€¢ Review learning queue: learning-queue.ps1 -Action list" -ForegroundColor Gray
Write-Host "   â€¢ Implement high-ROI items autonomously (LOW risk)" -ForegroundColor Gray
Write-Host "   â€¢ Suggest MEDIUM/HIGH risk items to user" -ForegroundColor Gray
Write-Host "   â€¢ Update reflection.log.md at session end" -ForegroundColor Gray
Write-Host ""
Write-Host "ðŸ’¡ This is how learning becomes CONTINUOUS, not episodic!" -ForegroundColor Magenta
Write-Host ""
