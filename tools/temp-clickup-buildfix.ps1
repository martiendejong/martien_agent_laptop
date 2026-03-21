$config = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$headers = @{ Authorization = $config.api_key; 'Content-Type' = 'application/json' }

$listId = '901215927087'
Write-Host "Creating build fix task on SEO God board (list: $listId)..."

$body = @{
    name = "Fix WordPressId type mismatch build errors"
    description = "DISCOVERED ISSUE: SEOController and PageAdvisorController had type mismatch errors (string vs int) when comparing WordPressId for Products vs Pages/BlogPosts. Products.WordPressId is int while Pages/BlogPosts.WordPressId is string.`n`nFix: Use string comparison for Pages/BlogPosts and int.TryParse for Products.`n`nFixed in PR #68: https://github.com/martiendejong/seo-god/pull/68"
    status = "review"
    priority = 2
} | ConvertTo-Json

$result = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task" -Headers $headers -Method Post -Body $body -ErrorAction Stop
Write-Host "  Created task: $($result.id) - $($result.name)"
Write-Host "  Status: $($result.status.status)"
