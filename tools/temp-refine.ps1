$apiKey = "pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI"
$headers = @{
    "Authorization" = $apiKey
    "Content-Type"  = "application/json"
}

$tasks = @(
    @{
        Id = "869ccv84k"
        Name = "Add SEO Advisor button to URL detail panel"
        Description = @"
WHAT: Add a button in the URL detail panel (next to the FAQ toggle) that navigates to the Page Advisor for that specific URL/page.

WHERE: URLDetailPanel.tsx - the panel that opens when clicking a URL row in the URLs page

HOW: Add a button that navigates to /page-advisor?url_id={contentType}-{id} similar to how the FAQ button works

ACCEPTANCE: Clicking the button opens Page Advisor pre-filtered for that URL. Button visible next to FAQ toggle.
"@
        Priority = 2
    },
    @{
        Id = "869ccv7ta"
        Name = "Remove standalone FAQ page from navigation"
        Description = @"
WHAT: The FAQ generator should not be a separate page in the sidebar menu. FAQ management is done through the Website/URLs page by clicking on a URL item.

WHERE: Sidebar navigation component, routing

HOW: Remove FAQ page link from sidebar/navigation menu. The FAQ functionality is already accessible via the URLs page (FAQ button per row). The /faq route can remain for direct URL access but shouldn't be in the menu.

ACCEPTANCE: No FAQ link in sidebar navigation. FAQ functionality works through URLs page. Direct /faq?url_id=... URLs still work.
"@
        Priority = 2
    }
)

foreach ($task in $tasks) {
    $taskId = $task.Id
    $url = "https://api.clickup.com/api/v2/task/$taskId"
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Processing task: $taskId - $($task.Name)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    # Step 1: Update name
    Write-Host "`n[1/5] Updating task name..." -ForegroundColor Yellow
    $nameBody = @{ name = $task.Name } | ConvertTo-Json
    try {
        $resp = Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $nameBody
        Write-Host "  OK - Name set to: $($resp.name)" -ForegroundColor Green
    } catch {
        Write-Host "  FAILED - $($_.Exception.Message)" -ForegroundColor Red
    }

    # Step 2: Update description
    Write-Host "[2/5] Updating description..." -ForegroundColor Yellow
    $descBody = @{ description = $task.Description } | ConvertTo-Json
    try {
        $resp = Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $descBody
        Write-Host "  OK - Description updated ($($task.Description.Length) chars)" -ForegroundColor Green
    } catch {
        Write-Host "  FAILED - $($_.Exception.Message)" -ForegroundColor Red
    }

    # Step 3: Update priority (2 = normal)
    Write-Host "[3/5] Setting priority to normal (2)..." -ForegroundColor Yellow
    $prioBody = @{ priority = $task.Priority } | ConvertTo-Json
    try {
        $resp = Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $prioBody
        Write-Host "  OK - Priority set to: $($resp.priority.priority)" -ForegroundColor Green
    } catch {
        Write-Host "  FAILED - $($_.Exception.Message)" -ForegroundColor Red
    }

    # Step 4: Move to todo
    Write-Host "[4/5] Moving to TODO status..." -ForegroundColor Yellow
    $statusBody = @{ status = "todo" } | ConvertTo-Json
    try {
        $resp = Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $statusBody
        Write-Host "  OK - Status: $($resp.status.status)" -ForegroundColor Green
    } catch {
        Write-Host "  FAILED - $($_.Exception.Message)" -ForegroundColor Red
    }

    # Step 5: Post comment
    Write-Host "[5/5] Posting comment..." -ForegroundColor Yellow
    $commentUrl = "https://api.clickup.com/api/v2/task/$taskId/comment"
    $commentBody = @{ comment_text = "Refined and moved to TODO. Ready for implementation." } | ConvertTo-Json
    try {
        $resp = Invoke-RestMethod -Uri $commentUrl -Method Post -Headers $headers -Body $commentBody
        Write-Host "  OK - Comment posted (id: $($resp.id))" -ForegroundColor Green
    } catch {
        Write-Host "  FAILED - $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DONE - Both tasks refined and moved to TODO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
