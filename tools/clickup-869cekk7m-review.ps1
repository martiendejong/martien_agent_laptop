$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$taskId = '869cekk7m'

$comment = @{ comment_text = "Implementation complete.

PR created: https://github.com/martiendejong/real-estate-agency-ai/pull/137

Changes:
- analytics.service.ts: trackView, trackLead, getPropertyAnalytics, getDashboardStats with 5min cache
- api.ts: retry logic with exponential backoff for network errors and 5xx responses
- WoningPubliek.tsx: tracks property views and leads via analytics service
- PropertyCard.tsx: optimistic update for favorites toggle (instant UI response)
- services/index.ts: exports analyticsService

Ready for code review." } | ConvertTo-Json

$r = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId/comment" -Method POST -Headers @{ Authorization = $apiKey; 'Content-Type' = 'application/json' } -Body $comment
Write-Host "Comment posted: $($r.id)"

$status = @{ status = 'review' } | ConvertTo-Json
$r2 = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Method PUT -Headers @{ Authorization = $apiKey; 'Content-Type' = 'application/json' } -Body $status
Write-Host "Status: $($r2.status.status)"
