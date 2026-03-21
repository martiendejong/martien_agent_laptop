$config = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$token = $config.api_key
$headers = @{ Authorization = $token; 'Content-Type' = 'application/json' }

# Task 1: Move 869c7mt8c to testing (PR #42 already merged)
$taskId = '869c7mt8c'
Write-Host "Moving 869c7mt8c (Page Advisor) to testing - PR #42 already merged..."
$body = '{"status":"testing"}'
try {
    $result = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers -Method Put -Body $body -ErrorAction Stop
    Write-Host "  Status now: $($result.status.status)"
    $comment = '{"comment_text":"Status mismatch resolved: PR #42 was merged on 2026-03-04 (commit d8b8aabd). Task was in todo but work is complete. Moving to TESTING."}'
    Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Headers $headers -Method Post -Body $comment -ErrorAction Stop | Out-Null
    Write-Host "  Comment added."
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)"
}

Write-Host ""

# Task 2: Refine 869ccubck (FAQ from URL cards)
$taskId = '869ccubck'
Write-Host "Refining 869ccubck (FAQ from URL cards)..."

# Get current task details
$task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers -Method Get -ErrorAction Stop
Write-Host "  Current: $($task.name)"
Write-Host "  Status: $($task.status.status)"

# Update with refined description
$refinedDesc = @"
## Summary
Make FAQs accessible from the Website/URLs page. When user clicks on a URL card in the Website section, it should navigate to the FAQ generator pre-filtered for that specific URL.

## Current Behavior
- FAQ Generator is a separate menu item (/faq)
- Website page (/urls) shows URL cards but has no link to FAQs
- User must manually navigate to FAQ and select the URL

## Required Behavior
1. On the Website page (/urls), each URL card should have a clickable action/link to open FAQs for that URL
2. Clicking the FAQ action on a URL card should navigate to /faq?url_id={url_id}
3. The FAQ page should read the url_id query parameter and auto-select that URL
4. If url_id is provided, skip the URL selection step and go straight to FAQ list

## Technical Details
- Frontend: Add FAQ button/link to URL card component on /urls page
- Frontend: Update FAQ page to read ?url_id= query param from URL
- Frontend: Auto-load FAQs for the specified URL on mount
- No backend changes needed (FAQ AJAX handlers already accept url_id)

## Acceptance Criteria
- [ ] URL cards on /urls page show FAQ action button
- [ ] Clicking FAQ button navigates to /faq?url_id={url_id}
- [ ] FAQ page auto-selects URL when url_id param present
- [ ] Direct navigation to /faq still works (no url_id = normal flow)
"@

$updateBody = @{
    description = $refinedDesc
    status = 'refined'
} | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers -Method Put -Body $updateBody -ErrorAction Stop
    Write-Host "  Status now: $($result.status.status)"
    $comment = '{"comment_text":"Refined from backlog: Added structured description with technical approach, acceptance criteria, and UX flow. Moving to refined."}'
    Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Headers $headers -Method Post -Body $comment -ErrorAction Stop | Out-Null
    Write-Host "  Comment added. Refinement complete."
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)"
    Write-Host "  Details: $($_.ErrorDetails.Message)"
}

Write-Host ""

# Task 3: Move refined task to todo
Write-Host "Moving 869ccubck to todo..."
$body = '{"status":"todo"}'
try {
    $result = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers -Method Put -Body $body -ErrorAction Stop
    Write-Host "  Status now: $($result.status.status)"
    Write-Host "  Ready for implementation."
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "All operations complete."
