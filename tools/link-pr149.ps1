$ApiKey = 'pk_74525428_TXT8V1QUA13N7SCRM0UUM6WNQO2I2NML'
$TaskId = '869bt43qt'
$Headers = @{ Authorization = $ApiKey; 'Content-Type' = 'application/json' }

$Comment = @{
    comment_text = "PR #149 (allitemslist branch) linked:`nhttps://github.com/martiendejong/client-manager/pull/149`n`nThis PR must be merged before subsequent phases can begin."
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$TaskId/comment" -Method Post -Headers $Headers -Body $Comment | Out-Null
    Write-Host "Linked PR #149 to Phase 0 task (869bt43qt)"
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
