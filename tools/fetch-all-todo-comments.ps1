#!/usr/bin/env pwsh

$tasks = @('869cbvg8j', '869cbg7bb', '869cbfft6', '869cbccdh', '869cb5q3r', '869cb0ppt')

foreach ($taskId in $tasks) {
    Write-Host "`n===================================================" -ForegroundColor Cyan
    Write-Host "TASK: $taskId" -ForegroundColor Yellow
    Write-Host "===================================================" -ForegroundColor Cyan

    $result = C:\scripts\tools\get-task-comments.ps1 -TaskId $taskId
    Write-Host ""
}
