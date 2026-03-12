$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'

$tasks = @(
    @{ id = '869ceqgnc'; msg = "CODE REVIEW - PR #136 MERGED. APPROVED. Sidebar accepts isOpen/onClose props, MainLayout manages state, overlay closes on tap, nav items close on click, aria-label on button, CSS drawer transition. No issues found." },
    @{ id = '869cekk7m'; msg = "CODE REVIEW - PR #137 MERGED. APPROVED. analytics.service.ts with trackView/trackLead/getPropertyAnalytics/getDashboardStats + 5min cache. Retry logic (500ms/1s/2s backoff) on network errors and 5xx. Optimistic favorites update. Fire-and-forget tracking never breaks UX. Minor: _retryCount assignment style (non-blocking). All acceptance criteria met." },
    @{ id = '869cekk62'; msg = "CODE REVIEW - PR #138 MERGED. APPROVED. Table<T> generic component with typed Column<T>[] config, loading/empty states, row click, custom cell render. Header component with title/subtitle/search/actions/notification bell/user dropdown. Gebruikers.tsx refactored (-90 lines). All 10 core components now complete: Sidebar/Header/StatCard/PropertyCard/PersonCard/Timeline/Calendar/Modal/Tabs/Table." }
)

foreach ($task in $tasks) {
    $body = @{ comment_text = $task.msg } | ConvertTo-Json
    try {
        $r = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)/comment" `
            -Method POST -Headers @{ Authorization = $apiKey; 'Content-Type' = 'application/json' } -Body $body
        Write-Host "[$($task.id)] Review comment posted: $($r.id)"
    } catch {
        Write-Host "[$($task.id)] Comment error: $($_.Exception.Message)"
    }
}
