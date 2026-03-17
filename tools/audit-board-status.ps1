param(
    [switch]$DryRun = $false
)

$API_KEY = "pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI"
$HEADERS = @{ "Authorization" = $API_KEY; "Content-Type" = "application/json" }

$LIST_IDS = @(
    "901214097647",  # client-manager
    "901215559249",  # hazina
    "901211612245",  # art-revisionist
    "901215927087",  # seo-god
    "901216032110"   # real-estate
)

$EVIDENCE_PATTERNS = @(
    "github\.com.*pull",
    "pull request",
    "\bPR\s*#?\d+",
    "\bpr\s*#?\d+",
    "merged",
    "deployed",
    "no pr",
    "no code",
    "config change",
    "non-code",
    "wp-cli",
    "ftp",
    "rest api",
    "fixed in",
    "resolved in",
    "cherry.pick"
)

function Has-Evidence($comments) {
    foreach ($comment in $comments) {
        $text = $comment.comment_text
        if (-not $text) { continue }
        foreach ($pattern in $EVIDENCE_PATTERNS) {
            if ($text -match $pattern) { return $true }
        }
    }
    return $false
}

$results = @{
    WithEvidence = @()
    NeedsReview = @()
    Errors = @()
}

Write-Host "`n=== AUDITING TESTING TASKS ACROSS ALL BOARDS ===" -ForegroundColor Cyan
Write-Host "Mode: $(if ($DryRun) { 'DRY RUN' } else { 'LIVE - WILL MOVE TASKS' })" -ForegroundColor $(if ($DryRun) { "Yellow" } else { "Red" })

foreach ($listId in $LIST_IDS) {
    Write-Host "`n--- List $listId ---" -ForegroundColor Yellow

    try {
        $response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$listId/task?statuses%5B%5D=testing&include_closed=false" `
            -Headers $HEADERS -Method GET

        $tasks = $response.tasks
        Write-Host "Found $($tasks.Count) testing tasks" -ForegroundColor Gray

        foreach ($task in $tasks) {
            Write-Host "  Checking: $($task.id) - $($task.name.Substring(0, [Math]::Min(60, $task.name.Length)))..." -ForegroundColor Gray -NoNewline

            try {
                $commentsResponse = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)/comment" `
                    -Headers $HEADERS -Method GET

                $hasEvidence = Has-Evidence $commentsResponse.comments

                if ($hasEvidence) {
                    Write-Host " OK" -ForegroundColor Green
                    $results.WithEvidence += @{ id = $task.id; name = $task.name; list = $listId }
                } else {
                    Write-Host " NO EVIDENCE -> MOVING TO TODO" -ForegroundColor Red
                    $results.NeedsReview += @{ id = $task.id; name = $task.name; list = $listId }

                    if (-not $DryRun) {
                        $body = @{ status = "todo" } | ConvertTo-Json
                        try {
                            Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)" `
                                -Headers $HEADERS -Method PUT -Body $body | Out-Null
                            Write-Host "    -> Moved to todo" -ForegroundColor DarkRed
                        } catch {
                            Write-Host "    -> FAILED to move: $_" -ForegroundColor Magenta
                        }
                    }
                }

                Start-Sleep -Milliseconds 100  # rate limiting

            } catch {
                Write-Host " ERROR: $_" -ForegroundColor Magenta
                $results.Errors += @{ id = $task.id; name = $task.name; error = $_.ToString() }
            }
        }
    } catch {
        Write-Host "ERROR fetching list ${listId}: $_" -ForegroundColor Magenta
    }
}

Write-Host "`n`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Tasks WITH evidence (left in testing): $($results.WithEvidence.Count)" -ForegroundColor Green
Write-Host "Tasks WITHOUT evidence (moved to todo): $($results.NeedsReview.Count)" -ForegroundColor Red

if ($results.NeedsReview.Count -gt 0) {
    Write-Host "`nMoved to todo:" -ForegroundColor Red
    foreach ($t in $results.NeedsReview) {
        Write-Host "  [$($t.list)] $($t.id): $($t.name.Substring(0, [Math]::Min(70, $t.name.Length)))"
    }
}

if ($results.Errors.Count -gt 0) {
    Write-Host "`nErrors: $($results.Errors.Count)" -ForegroundColor Magenta
}
