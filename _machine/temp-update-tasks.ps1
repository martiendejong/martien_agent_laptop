param([int]$StartIndex = 0, [int]$EndIndex = 14)

$apiKey = "pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI"
$apiBase = "https://api.clickup.com/api/v2"

$headers = @{
    "Authorization" = $apiKey
    "Content-Type" = "application/json"
}

# Load task data from JSON file
$taskData = Get-Content "C:\scripts\_machine\temp-task-refinements.json" -Raw | ConvertFrom-Json

$total = $taskData.Count
Write-Host "Loaded $total tasks to update" -ForegroundColor Cyan
Write-Host "Processing index $StartIndex to $EndIndex" -ForegroundColor Cyan
Write-Host ""

for ($i = $StartIndex; $i -le [Math]::Min($EndIndex, $total - 1); $i++) {
    $task = $taskData[$i]
    $taskId = $task.id
    $newTitle = $task.title
    $newDesc = $task.description

    Write-Host "[$($i+1)/$total] Updating $taskId..." -ForegroundColor Yellow -NoNewline

    $body = @{
        name = $newTitle
        description = $newDesc
    } | ConvertTo-Json -Depth 5

    try {
        $response = Invoke-RestMethod -Uri "$apiBase/task/$taskId" -Method Put -Headers $headers -Body $body
        Write-Host " OK - $($response.name.Substring(0, [Math]::Min(60, $response.name.Length)))..." -ForegroundColor Green
    } catch {
        Write-Host " FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Small delay to avoid rate limiting
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "Done! Updated tasks $StartIndex to $EndIndex" -ForegroundColor Cyan
