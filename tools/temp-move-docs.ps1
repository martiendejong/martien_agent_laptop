$cfg = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$token = $cfg.api_key
$headers = @{ Authorization = $token; 'Content-Type' = 'application/json' }

# Move docs task to review
$body = @{ status = "review" } | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/869cchp01" -Method PUT -Headers $headers -Body $body | Out-Null
Write-Output "MOVED to review: 869cchp01 (Documentation: Update README)"

# Add comment
$comment = @{ comment_text = "PR #84: https://github.com/martiendejong/bliek-vastgoed/pull/84`nREADME and API docs updated with new agency name.`n`nNote: Sales docs (PROPOSAL, SALES_DECK, etc.) contain client-specific content and are left as-is." } | ConvertTo-Json -Depth 2
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/869cchp01/comment" -Method POST -Headers $headers -Body $comment | Out-Null
Write-Output "  -> Comment added"
