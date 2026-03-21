$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $apiKey; 'Content-Type' = 'application/json' }

# Move task to review
Write-Host "Moving Claude VS Bridge task to REVIEW..." -ForegroundColor Cyan
$body = @{ status = 'review' } | ConvertTo-Json
$url = "https://api.clickup.com/api/v2/task/869c6y96p"
try {
    $response = Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $body
    Write-Host "  [OK] Moved to: $($response.status.status)" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Failed: $_" -ForegroundColor Red
}

# Add comment with PR link
Write-Host "`nAdding comment with PR link..." -ForegroundColor Cyan
$comment = @"
✅ PHASE 1 COMPLETE

PR Created: https://github.com/martiendejong/AgenticDebuggerVsix/pull/6
Branch: feature/vs-automation-poc

Phase 1 Commands Implemented:
1. ✅ OpenFile - /vs/file/open
2. ✅ Build - POST /command (action=build)
3. ✅ GetDiagnostics - GET /errors
4. ✅ FindReferences - POST /code/references
5. ✅ RunTests - POST /vs/tests/run

BONUS: Phase 1.5 Dialog Automation with FlaUI

All 5 Phase 1 commands working and tested. Ready for review and merge.

Next: Phase 2 (10+ additional commands)

-- Claude Code Agent
"@

$commentBody = @{
    comment_text = $comment
    notify_all = $false
} | ConvertTo-Json

$commentUrl = "https://api.clickup.com/api/v2/task/869c6y96p/comment"
try {
    Invoke-RestMethod -Uri $commentUrl -Method Post -Headers $headers -Body $commentBody | Out-Null
    Write-Host "  [OK] Comment added" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Failed: $_" -ForegroundColor Red
}

Write-Host "`n=== Task updated successfully! ===" -ForegroundColor Green
