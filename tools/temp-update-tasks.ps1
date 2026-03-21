$cfg = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$token = $cfg.api_key
$headers = @{ Authorization = $token; 'Content-Type' = 'application/json' }

$prUrl = "https://github.com/martiendejong/bliek-vastgoed/pull/84"

# Code tasks that are implemented in this PR - move to review
$codeTasks = @(
    @{ id = "869cchnz7"; name = "Backend: Add agency configuration settings API" },
    @{ id = "869cchnyn"; name = "Frontend: Make logo configurable" },
    @{ id = "869cchnyt"; name = "Frontend: Make homepage background image configurable" },
    @{ id = "869cchnyw"; name = "Frontend: Search and replace hardcoded Bliek text strings" }
)

foreach ($task in $codeTasks) {
    # Move to review
    $body = @{ status = "review" } | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)" -Method PUT -Headers $headers -Body $body | Out-Null
        Write-Output "MOVED to review: $($task.id) ($($task.name))"
    } catch {
        Write-Output "ERROR moving $($task.id): $($_.Exception.Message)"
    }

    # Add comment with PR link
    $comment = @{ comment_text = "PR #84: $prUrl`nImplemented in feature/white-label-rebrand branch.`n`nTesting Instructions:`n1. Build backend: dotnet build`n2. Build frontend: npm run build`n3. Start both backend and frontend`n4. Navigate to homepage - verify branding loads from defaults`n5. PUT /api/settings/agency with custom agency name/logo`n6. Verify all pages reflect new branding`n7. Check email templates in woningzoekende detail" } | ConvertTo-Json -Depth 2
    try {
        Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)/comment" -Method POST -Headers $headers -Body $comment | Out-Null
        Write-Output "  -> Comment added"
    } catch {
        Write-Output "  -> Error adding comment: $($_.Exception.Message)"
    }
}

# Non-code tasks that depend on other work (repo rename, ClickUp, infra, docs, testing)
# These stay in "todo" until the code is merged and repo work can begin
$pendingTasks = @(
    @{ id = "869cchnyf"; name = "GitHub: Rename repository" },
    @{ id = "869cchnzn"; name = "ClickUp: Rename board" },
    @{ id = "869cchnzu"; name = "Infrastructure: Update Jengo knowledge base" },
    @{ id = "869cchp01"; name = "Documentation: Update README" },
    @{ id = "869cchp0g"; name = "Testing: Verify complete rebrand" }
)

Write-Output "`nPending tasks (stay in todo - depend on code merge + repo rename):"
foreach ($task in $pendingTasks) {
    Write-Output "  $($task.id) | $($task.name)"
}
