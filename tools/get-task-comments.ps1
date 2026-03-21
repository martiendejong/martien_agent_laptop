#!/usr/bin/env pwsh
param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId
)

$ConfigPath = "C:\scripts\_machine\clickup-config.json"
$Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$ApiKey = $Config.api_key
$ApiBase = $Config.api_base

$Headers = @{
    "Authorization" = $ApiKey
    "Content-Type" = "application/json"
}

$Uri = "$ApiBase/task/$TaskId/comment"
try {
    $Response = Invoke-RestMethod -Uri $Uri -Method GET -Headers $Headers

    if ($Response.comments.Count -eq 0) {
        Write-Host "No comments found for task $TaskId" -ForegroundColor Yellow
        return
    }

    Write-Host "`n=== Comments for Task $TaskId ===" -ForegroundColor Cyan
    foreach ($comment in $Response.comments) {
        $date = [DateTimeOffset]::FromUnixTimeMilliseconds($comment.date).ToString("yyyy-MM-dd HH:mm")
        $user = $comment.user.username
        Write-Host "`n[$date] $user" -ForegroundColor Gray
        Write-Host $comment.comment_text -ForegroundColor White
        Write-Host "---" -ForegroundColor DarkGray
    }

    # Return the last comment for programmatic use
    $lastComment = $Response.comments[-1]
    return @{
        TaskId = $TaskId
        LastCommentDate = [DateTimeOffset]::FromUnixTimeMilliseconds($lastComment.date).ToString("yyyy-MM-dd HH:mm")
        LastCommentUser = $lastComment.user.username
        LastCommentText = $lastComment.comment_text
    }
} catch {
    Write-Host "Error fetching comments: $($_.Exception.Message)" -ForegroundColor Red
    throw
}
