param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId
)

# Load config
$config = Get-Content "C:\scripts\_machine\clickup-config.json" | ConvertFrom-Json
$apiKey = $config.api_key

# API headers
$headers = @{
    Authorization = $apiKey
    'Content-Type' = 'application/json'
}

# Get task details
$taskUri = "https://api.clickup.com/api/v2/task/$TaskId"
$task = Invoke-RestMethod -Uri $taskUri -Headers $headers -Method Get

# Get task comments
$commentsUri = "https://api.clickup.com/api/v2/task/$TaskId/comment"
$comments = Invoke-RestMethod -Uri $commentsUri -Headers $headers -Method Get

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TASK: $($task.name)" -ForegroundColor Yellow
Write-Host "ID: $($task.id)" -ForegroundColor Green
Write-Host "Status: $($task.status.status)" -ForegroundColor Magenta
Write-Host "URL: $($task.url)" -ForegroundColor Blue
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "DESCRIPTION:" -ForegroundColor Yellow
Write-Host $task.description
Write-Host ""

if ($comments.comments -and $comments.comments.Count -gt 0) {
    Write-Host "`n--- COMMENTS ($($comments.comments.Count)) ---" -ForegroundColor Cyan
    foreach ($comment in $comments.comments) {
        $date = [DateTimeOffset]::FromUnixTimeMilliseconds([long]$comment.date).DateTime.ToString("yyyy-MM-dd HH:mm")
        Write-Host "`n[$date] $($comment.user.username):" -ForegroundColor Green
        Write-Host $comment.comment_text -ForegroundColor White
    }
} else {
    Write-Host "`n--- NO COMMENTS ---" -ForegroundColor Yellow
}

# Check for PR links in description
Write-Host "`n--- SEARCHING FOR PR LINKS ---" -ForegroundColor Cyan
$prPattern = 'https://github\.com/[^/]+/[^/]+/pull/(\d+)'
$matches = [regex]::Matches($task.description, $prPattern)
if ($matches.Count -gt 0) {
    foreach ($match in $matches) {
        Write-Host "Found PR: $($match.Value)" -ForegroundColor Green
    }
} else {
    Write-Host "No PR links found in description" -ForegroundColor Yellow
}

Write-Host "`n========================================`n" -ForegroundColor Cyan

# Return as object for processing
@{
    Task = $task
    Comments = $comments.comments
    PRLinks = $matches | ForEach-Object { $_.Value }
} | ConvertTo-Json -Depth 10
