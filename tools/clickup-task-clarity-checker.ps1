#!/usr/bin/env pwsh
<#
.SYNOPSIS
    ClickUp Task Clarity Checker - Reviews tasks for clarity before implementation
.DESCRIPTION
    When working on a ClickUp task, this script checks if it's clear enough to implement.
    If not, it posts questions as comments and moves to 'needs input' status.
    This enforces the "questions-first" workflow for all ClickUp tasks.
.PARAMETER TaskId
    The ClickUp task ID to check
.PARAMETER AutoMove
    If true, automatically moves unclear tasks to 'needs input'. Default: false
.EXAMPLE
    .\clickup-task-clarity-checker.ps1 -TaskId "869c4vycv"
    .\clickup-task-clarity-checker.ps1 -TaskId "869c4vycv" -AutoMove
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId,

    [Parameter(Mandatory=$false)]
    [switch]$AutoMove
)

$ErrorActionPreference = "Stop"

# Load ClickUp config
$configPath = "C:\scripts\_machine\clickup-config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "ClickUp config not found at $configPath"
    exit 1
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json
$apiKey = $config.api_key
$baseUrl = $config.api_base

$headers = @{
    "Authorization" = $apiKey
    "Content-Type" = "application/json"
}

# Fetch task
$taskUrl = "$baseUrl/task/$TaskId"
$task = Invoke-RestMethod -Uri $taskUrl -Headers $headers -Method Get

Write-Host "`nTask: $($task.name)" -ForegroundColor Cyan
Write-Host "Status: $($task.status.status)" -ForegroundColor Yellow
Write-Host ""

# Analyze clarity
$name = $task.name
$description = $task.description

$isClear = $false
$questions = @()

# Pattern 1: FUTURE tasks with detailed specs
if ($name -match "^FUTURE:" -or $name -match "^P\d+\.") {
    if ($description.Length -gt 500 -and $description -match "### Requirements" -and $description -match "### Acceptance Criteria") {
        $isClear = $true
        Write-Host "[CLEAR] Well-documented task with requirements and acceptance criteria" -ForegroundColor Green
    }
    elseif ($description.Length -gt 200) {
        if ($description -notmatch "### Requirements") {
            $questions += "What are the specific functional requirements for this feature?"
        }
        if ($description -notmatch "### Acceptance Criteria") {
            $questions += "What are the acceptance criteria to consider this done?"
        }
        if ($description -notmatch "### Technical Notes") {
            $questions += "Are there any technical constraints or implementation preferences?"
        }
    }
}

# Pattern 2: Minimal description
if (-not $isClear -and $description.Length -lt 100) {
    $questions += "Can you provide more details about what exactly needs to be done?"
    $questions += "What is the expected outcome or deliverable?"
    $questions += "Are there any specific technical requirements or constraints?"
}

# Pattern 3: Test/Fix tasks without specifics
if (-not $isClear -and ($name -match "test|fix|verify")) {
    if ($description -notmatch "error|bug") {
        $questions += "What specific issue or error needs to be fixed?"
        $questions += "What are the steps to reproduce the problem?"
        $questions += "What is the expected vs. actual behavior?"
    }
}

# Pattern 4: Integration tasks without auth details
if (-not $isClear -and ($name -match "integrate|connect")) {
    if ($description -notmatch "api|auth") {
        $questions += "What authentication method should be used (OAuth, API key, etc.)?"
        $questions += "Are there existing API credentials or do we need to register an app?"
    }
    if ($description -notmatch "endpoint") {
        $questions += "Which specific API endpoints need to be implemented?"
    }
}

# Pattern 5: Feature requests without UI/UX specs
if (-not $isClear -and ($description -match "should|allow user")) {
    if ($description -notmatch "where|button|control") {
        $questions += "Where should this feature appear in the UI (which screen/component)?"
    }
    if ($description -notmatch "how") {
        $questions += "What is the user flow or interaction pattern?"
    }
}

# Pattern 6: AI/LLM context detection tasks
if (-not $isClear -and ($description -match "user talks about|when user")) {
    if ($description -notmatch "trigger|detect") {
        $questions += "How should the system detect this user intent? Which keywords or patterns?"
        $questions += "Should this use LLM function calling or simple keyword matching?"
    }
}

# Default: reasonably long description is probably clear
if (-not $isClear -and $description.Length -gt 200 -and $questions.Count -eq 0) {
    $isClear = $true
    Write-Host "[CLEAR] Task has sufficient detail" -ForegroundColor Green
}

# Catch-all for short descriptions
if (-not $isClear -and $questions.Count -eq 0) {
    $questions += "Can you clarify the implementation approach?"
    $questions += "What are the acceptance criteria for this task?"
}

# Output results
if ($isClear) {
    Write-Host "`n[OK] This task is clear and ready to implement" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "`n[NEEDS INPUT] This task needs clarification" -ForegroundColor Yellow
    Write-Host "`nQuestions for product owner:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $questions.Count; $i++) {
        Write-Host "  $($i + 1). $($questions[$i])"
    }

    if ($AutoMove) {
        # Post questions as comment
        $questionsText = ($questions | ForEach-Object { $i = 1 } { "$i. $_"; $i++ }) -join "`n"
        $comment = "[NEEDS INPUT] This task needs clarification before implementation.`n`nQuestions for product owner:`n`n$questionsText`n`nPlease provide answers so we can proceed with implementation."

        $commentUrl = "$baseUrl/task/$TaskId/comment"
        $commentBody = @{ comment_text = $comment } | ConvertTo-Json
        Invoke-RestMethod -Uri $commentUrl -Headers $headers -Method Post -Body $commentBody | Out-Null
        Write-Host "`n[COMMENT POSTED] Questions added to task" -ForegroundColor Green

        # Move to 'needs input' status
        $statusBody = @{ status = "needs input" } | ConvertTo-Json
        Invoke-RestMethod -Uri $taskUrl -Headers $headers -Method Put -Body $statusBody | Out-Null
        Write-Host "[STATUS UPDATED] Task moved to 'needs input'" -ForegroundColor Green
    }

    exit 1
}
