param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId,
    [Parameter(Mandatory=$true)]
    [string]$Comment
)

$config = Get-Content 'C:\scripts\_machine\clickup-config.json' | ConvertFrom-Json
$token = $config.api_key
$headers = @{ Authorization = $token; 'Content-Type' = 'application/json' }
$body = @{ comment_text = $Comment } | ConvertTo-Json -Depth 5

try {
    $response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$TaskId/comment" -Headers $headers -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -ContentType 'application/json; charset=utf-8'
    Write-Host "Comment posted successfully on task $TaskId"
} catch {
    Write-Host "Error: $_"
}
