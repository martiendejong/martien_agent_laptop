$API_KEY = "pk_74525428_TXT8V1QUA13N7SCRM0UUM6WNQO2I2NML"
$API_BASE = "https://api.clickup.com/api/v2"
$LIST_ID = "901214097647"

$headers = @{
    "Authorization" = $API_KEY
    "Content-Type" = "application/json"
}

$platforms = @(
    @{name="Facebook/Meta API Verification"; file="1_Facebook_Meta_API_Verification"; desc="Complete Facebook/Meta Business Verification and App Review process"; priority=2},
    @{name="LinkedIn API Verification"; file="2_LinkedIn_API_Verification"; desc="Complete LinkedIn Company Page Verification and API Products request"; priority=2},
    @{name="TikTok API Verification"; file="3_TikTok_API_Verification"; desc="Complete TikTok app registration and audit process"; priority=3},
    @{name="Instagram API Verification"; file="4_Instagram_API_Verification"; desc="Setup Instagram Business Account and complete Meta App Review"; priority=2},
    @{name="Medium API Integration"; file="5_Medium_API_Verification"; desc="Generate Medium integration token (Note: API deprecated)"; priority=4}
)

Write-Host "Searching for existing tasks..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "$API_BASE/list/$LIST_ID/task" -Headers $headers -Method Get
    $existingTasks = $response.tasks | Where-Object { $_.name -match "API.*Verification|API.*Integration" }

    Write-Host "Found $($existingTasks.Count) existing API tasks" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host "Error fetching tasks: $_" -ForegroundColor Red
    $existingTasks = @()
}

Write-Host "Creating tasks..." -ForegroundColor Cyan
$createdTasks = @()

foreach ($platform in $platforms) {
    $exists = $existingTasks | Where-Object { $_.name -like "*$($platform.name.Split(' ')[0])*" }

    if ($exists) {
        Write-Host "  EXISTS: $($platform.name)" -ForegroundColor Gray
        Write-Host "          $($exists.url)" -ForegroundColor DarkGray
        $createdTasks += @{id=$exists.id; name=$exists.name; url=$exists.url; file=$platform.file}
    } else {
        $taskBody = @{
            name = $platform.name
            description = "$($platform.desc). See attached PDF for complete verification guide."
            status = "todo"
            priority = $platform.priority
            tags = @("api", "social-media", "integration")
        } | ConvertTo-Json

        try {
            $result = Invoke-RestMethod -Uri "$API_BASE/list/$LIST_ID/task" -Headers $headers -Method Post -Body $taskBody
            Write-Host "  CREATED: $($platform.name)" -ForegroundColor Green
            Write-Host "           $($result.url)" -ForegroundColor DarkGray
            $createdTasks += @{id=$result.id; name=$result.name; url=$result.url; file=$platform.file}
        } catch {
            Write-Host "  FAILED: $($platform.name) - $_" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "Tasks ready: $($createdTasks.Count)" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Create PDFs from HTML files:" -ForegroundColor White
Write-Host "   - Press Ctrl+P in each browser tab" -ForegroundColor White
Write-Host "   - Select 'Save as PDF'" -ForegroundColor White
Write-Host "   - Save to C:\scripts\temp\" -ForegroundColor White
Write-Host ""
Write-Host "2. Manually attach PDFs to ClickUp tasks:" -ForegroundColor White
foreach ($task in $createdTasks) {
    Write-Host "   - $($task.file).pdf -> $($task.url)" -ForegroundColor Gray
}
Write-Host ""
Write-Host "ClickUp List: https://app.clickup.com/9012956001/v/li/901214097647" -ForegroundColor Cyan
