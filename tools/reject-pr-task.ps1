param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId,

    [Parameter(Mandatory=$true)]
    [string]$Comment
)

# Load config
$config = Get-Content "C:\scripts\_machine\clickup-config.json" | ConvertFrom-Json
$apiKey = $config.api_key

# API headers
$headers = @{
    Authorization = $apiKey
    'Content-Type' = 'application/json'
}

# Post comment
$commentUri = "https://api.clickup.com/api/v2/task/$TaskId/comment"
$commentBody = @{
    comment_text = $Comment
} | ConvertTo-Json

Write-Host "Posting rejection comment to task $TaskId..." -ForegroundColor Yellow
Invoke-RestMethod -Uri $commentUri -Headers $headers -Method Post -Body $commentBody -ContentType 'application/json'

# Move to TODO
$updateUri = "https://api.clickup.com/api/v2/task/$TaskId"
$updateBody = @{
    status = "todo"
} | ConvertTo-Json

Write-Host "Moving task to TODO status..." -ForegroundColor Yellow
Invoke-RestMethod -Uri $updateUri -Headers $headers -Method Put -Body $updateBody -ContentType 'application/json'

Write-Host "`n✅ Task $TaskId moved to TODO with rejection comment" -ForegroundColor Green
