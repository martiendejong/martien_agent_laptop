param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId
)

$config = Get-Content 'C:\scripts\_machine\clickup-config.json' | ConvertFrom-Json
$token = $config.api_key
$headers = @{ Authorization = $token }

try {
    $response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$TaskId/comment" -Headers $headers -Method Get
    $comments = $response.comments
    if ($comments.Count -eq 0) {
        Write-Host "No comments on task $TaskId"
    } else {
        $last3 = $comments | Select-Object -Last 3
        foreach ($c in $last3) {
            Write-Host "---"
            $dateStr = [DateTimeOffset]::FromUnixTimeMilliseconds([long]$c.date).DateTime.ToString('yyyy-MM-dd HH:mm')
            Write-Host "Date: $dateStr"
            Write-Host "By: $($c.user.username)"
            Write-Host $c.comment_text
        }
    }
} catch {
    Write-Host "Error: $_"
}
