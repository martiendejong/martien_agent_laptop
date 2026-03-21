$config = Get-Content 'C:\scripts\_machine\clickup-config.json' | ConvertFrom-Json

$headers = @{
    'Authorization' = $config.api_key
    'Content-Type' = 'application/json'
}

$body = @{
    status = 'testing'
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri 'https://api.clickup.com/api/v2/task/869ccw9ar' -Method Put -Headers $headers -Body $body

Write-Output "Task 869ccw9ar updated to testing status"
$response | ConvertTo-Json -Depth 5
