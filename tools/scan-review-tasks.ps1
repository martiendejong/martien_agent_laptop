# Scan all ClickUp boards for tasks in review status
param(
    [string]$ConfigPath = "C:\scripts\_machine\clickup-config.json"
)

# Load configuration
$config = Get-Content $ConfigPath | ConvertFrom-Json

# Define scope: internal + client projects
$boards = @(
    @{Name="Brand Designer"; ListId="901214097647"; Project="client-manager"},
    @{Name="Art Revisionist"; ListId="901211612245"; Project="art-revisionist"},
    @{Name="Hazina Framework"; ListId="901215559249"; Project="hazina"},
    @{Name="DataDrivenAI"; ListId="901216187878"; Project="datadrivenai"},
    @{Name="SEO God"; ListId="901215927087"; Project="seo-god"},
    @{Name="STM Plugin"; ListId="901216036563"; Project="simple-translation-manager"},
    @{Name="Personality Test"; ListId="901216266641"; Project="personalitytest"}
)

$allReviewTasks = @()

Write-Host "Scanning $($boards.Count) boards for tasks in review status..." -ForegroundColor Cyan
Write-Host ""

foreach ($board in $boards) {
    Write-Host "Scanning: $($board.Name)..." -ForegroundColor Yellow

    try {
        $tasks = & "C:\scripts\tools\clickup-sync.ps1" -Action list -ListId $board.ListId 2>$null

        if ($tasks) {
            $taskObjects = $tasks | ConvertFrom-Json

            # Filter for review status (case-insensitive match)
            $reviewTasks = $taskObjects | Where-Object {
                $_.status.status -match 'review'
            }

            if ($reviewTasks) {
                foreach ($task in $reviewTasks) {
                    $allReviewTasks += [PSCustomObject]@{
                        BoardName = $board.Name
                        Project = $board.Project
                        TaskId = $task.id
                        TaskName = $task.name
                        Status = $task.status.status
                        Url = $task.url
                    }
                }
                Write-Host "  Found: $($reviewTasks.Count) task(s) in review" -ForegroundColor Green
            } else {
                Write-Host "  Found: 0 tasks in review" -ForegroundColor Gray
            }
        }
    } catch {
        Write-Host "  Error: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "SUMMARY: Found $($allReviewTasks.Count) total task(s) in review status" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""

if ($allReviewTasks.Count -gt 0) {
    $allReviewTasks | Format-Table -AutoSize

    # Output as JSON for programmatic use
    $allReviewTasks | ConvertTo-Json -Depth 10
} else {
    Write-Host "No tasks in review status found across all boards." -ForegroundColor Gray
}
