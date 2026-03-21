param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId,
    [Parameter(Mandatory=$true)]
    [string]$Status
)

# ZERO TOLERANCE ENFORCEMENT (Pattern P108-P112, 2026-03-14)
# Agent is FORBIDDEN from moving tasks to "done" - only user/QA can do this.
# Code enforcement achieves 100% prevention vs 0% for documentation alone.
$ForbiddenStatuses = @('done', 'Done', 'DONE', 'complete', 'Complete', 'COMPLETE', 'closed', 'Closed', 'CLOSED')
if ($Status -in $ForbiddenStatuses) {
    Write-Error "ZERO TOLERANCE VIOLATION BLOCKED: Agent is FORBIDDEN from moving tasks to '$Status'. Only user/QA can perform this transition. Maximum agent status = 'testing'."
    throw "ForbiddenStatusTransition: '$Status' is not allowed for automated agents."
}

$config = Get-Content 'C:\scripts\_machine\clickup-config.json' | ConvertFrom-Json
$token = $config.api_key
$headers = @{ Authorization = $token; 'Content-Type' = 'application/json' }
$body = @{ status = $Status } | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$TaskId" -Headers $headers -Method Put -Body $body
    Write-Host "Task $TaskId moved to '$Status' successfully"
    Write-Host "Title: $($response.name)"
} catch {
    Write-Host "Error: $_"
}
