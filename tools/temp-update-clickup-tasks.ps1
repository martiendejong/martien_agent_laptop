[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$token = (Get-Content 'C:\scripts\_machine\clickup-config.json' | ConvertFrom-Json).token

# Tasks to move to review
$tasks = @('869cbx8z0','869cbx8t6','869cbwvp4','869cbvg8j','869cbg7bb','869cbccdh')
$prUrl = "https://github.com/martiendejong/bliek-vastgoed/pull/45"

foreach ($id in $tasks) {
    # Get task to find the actual status name for the board
    $task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$id" -Headers @{Authorization=$token} -Method Get
    $currentStatus = $task.status.status
    Write-Host "Task $id - Current: $currentStatus"

    # Move to review
    try {
        $body = @{ status = "review" } | ConvertTo-Json
        Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$id" -Headers @{Authorization=$token; "Content-Type"="application/json"} -Method Put -Body $body
        Write-Host "  -> Moved to review"
    } catch {
        Write-Host "  -> Error moving: $($_.Exception.Message)"
    }

    # Add comment with PR link
    try {
        $commentBody = @{ comment_text = "PR #45: $prUrl - Consolidates all TODO fixes (merge develop + featured image + document upload). Ready for review." } | ConvertTo-Json -Depth 3
        Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$id/comment" -Headers @{Authorization=$token; "Content-Type"="application/json"} -Method Post -Body $commentBody
        Write-Host "  -> Comment added"
    } catch {
        Write-Host "  -> Error commenting: $($_.Exception.Message)"
    }
}

# Task 869cbfft6 (email) - already done via PR #36, just move to review
$id = '869cbfft6'
$task = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$id" -Headers @{Authorization=$token} -Method Get
Write-Host "Task $id - Current: $($task.status.status)"
try {
    $body = @{ status = "review" } | ConvertTo-Json
    Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$id" -Headers @{Authorization=$token; "Content-Type"="application/json"} -Method Put -Body $body
    Write-Host "  -> Moved to review"
    $commentBody = @{ comment_text = "PR #45: $prUrl - Email integration included via merged develop branch (originally PR #36). Ready for review." } | ConvertTo-Json -Depth 3
    Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$id/comment" -Headers @{Authorization=$token; "Content-Type"="application/json"} -Method Post -Body $commentBody
    Write-Host "  -> Comment added"
} catch {
    Write-Host "  -> Error: $($_.Exception.Message)"
}
