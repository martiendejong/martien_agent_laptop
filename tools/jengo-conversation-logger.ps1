<#
.SYNOPSIS
Logs Jengo conversation sessions for training data collection.

.DESCRIPTION
Captures session metadata, task details, tools used, decisions made, and outcomes.
Stores as structured JSON for later embedding/retrieval (RAG) or fine-tuning.

.PARAMETER SessionId
Optional session identifier. Auto-generated if not provided.

.PARAMETER Mode
Session mode: Feature or Debug

.PARAMETER TaskDescription
Brief description of the task

.PARAMETER Outcome
Session outcome: Success, Fail, Partial

.PARAMETER Interactive
If set, prompts for all information interactively

.EXAMPLE
jengo-conversation-logger.ps1 -Interactive

.EXAMPLE
jengo-conversation-logger.ps1 -Mode Feature -TaskDescription "Fix DI bug" -Outcome Success
#>

param(
    [string]$SessionId,
    [ValidateSet("Feature", "Debug", "Research", "Review", "Meta")]
    [string]$Mode,
    [string]$TaskDescription,
    [ValidateSet("Success", "Fail", "Partial", "Abandoned")]
    [string]$Outcome,
    [switch]$Interactive
)

$ErrorActionPreference = "Stop"

# Ensure training data directory exists
$TrainingDataDir = "E:\jengo\training-data\conversations"
if (-not (Test-Path $TrainingDataDir)) {
    New-Item -ItemType Directory -Path $TrainingDataDir -Force | Out-Null
    Write-Host "[CREATED] Training data directory: $TrainingDataDir" -ForegroundColor Green
}

# Generate session ID if not provided
if (-not $SessionId) {
    $SessionId = "session-$(Get-Date -Format 'yyyy-MM-dd-HHmmss')"
}

# Interactive mode: prompt for all information
if ($Interactive) {
    Write-Host "`n=== Jengo Conversation Logger ===" -ForegroundColor Cyan
    Write-Host "Collecting session data for training purposes`n"

    # Mode
    Write-Host "Session Mode:" -ForegroundColor Yellow
    Write-Host "  1. Feature Development (worktrees, PRs, new functionality)"
    Write-Host "  2. Debug (fixing bugs in base repo)"
    Write-Host "  3. Research (exploration, analysis, no code changes)"
    Write-Host "  4. Review (PR reviews, code analysis)"
    Write-Host "  5. Meta (system improvements, documentation)"
    $modeChoice = Read-Host "Select mode (1-5)"
    $Mode = switch ($modeChoice) {
        "1" { "Feature" }
        "2" { "Debug" }
        "3" { "Research" }
        "4" { "Review" }
        "5" { "Meta" }
        default { "Feature" }
    }

    # Task description
    $TaskDescription = Read-Host "`nTask description (brief, 1-2 sentences)"

    # Project (if applicable)
    $Project = Read-Host "Project name (client-manager, hazina, artrevisionist, or leave empty)"

    # Tools used
    Write-Host "`nTools used (comma-separated, e.g., worktree,gh,grep):" -ForegroundColor Yellow
    $toolsInput = Read-Host "Tools"
    $ToolsUsed = if ($toolsInput) { $toolsInput -split ',' | ForEach-Object { $_.Trim() } } else { @() }

    # Key decisions
    Write-Host "`nKey decisions made (one per line, empty line to finish):" -ForegroundColor Yellow
    $decisions = @()
    while ($true) {
        $decision = Read-Host "Decision"
        if ([string]::IsNullOrWhiteSpace($decision)) { break }

        $reasoning = Read-Host "  Reasoning"
        $decisions += @{
            decision = $decision
            reasoning = $reasoning
            timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        }
    }

    # Outcome
    Write-Host "`nSession Outcome:" -ForegroundColor Yellow
    Write-Host "  1. Success (task completed)"
    Write-Host "  2. Partial (progress made, not complete)"
    Write-Host "  3. Fail (blocked, error)"
    Write-Host "  4. Abandoned (switched tasks)"
    $outcomeChoice = Read-Host "Select outcome (1-4)"
    $Outcome = switch ($outcomeChoice) {
        "1" { "Success" }
        "2" { "Partial" }
        "3" { "Fail" }
        "4" { "Abandoned" }
        default { "Success" }
    }

    # Artifacts
    $PRUrl = Read-Host "`nPR URL (if created, or leave empty)"
    $ClickUpTask = Read-Host "ClickUp task ID (if applicable, or leave empty)"

    # Lessons learned
    Write-Host "`nLessons learned (one per line, empty line to finish):" -ForegroundColor Yellow
    $lessons = @()
    while ($true) {
        $lesson = Read-Host "Lesson"
        if ([string]::IsNullOrWhiteSpace($lesson)) { break }
        $lessons += $lesson
    }

} else {
    # Non-interactive mode: use parameters
    $Project = ""
    $ToolsUsed = @()
    $decisions = @()
    $PRUrl = ""
    $ClickUpTask = ""
    $lessons = @()
}

# Build conversation log structure
$conversationLog = @{
    session_id = $SessionId
    timestamp_start = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    timestamp_end = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    mode = $Mode
    task_description = $TaskDescription
    project = $Project

    # Conversation content (to be filled manually or via export)
    conversation = @{
        user_messages = @()
        agent_messages = @()
        message_count = 0
    }

    # Execution details
    tools_used = $ToolsUsed
    decisions = $decisions

    # Outcomes
    outcome = $Outcome
    artifacts = @{
        pr_url = $PRUrl
        clickup_task = $ClickUpTask
        files_modified = @()
    }

    # Learnings
    lessons_learned = $lessons

    # Metadata for retrieval
    tags = @()
    embeddings_generated = $false
}

# Save to JSON
$outputPath = Join-Path $TrainingDataDir "$SessionId.json"
$conversationLog | ConvertTo-Json -Depth 10 | Set-Content -Path $outputPath -Encoding UTF8

Write-Host "`n[SUCCESS] Session logged: $outputPath" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "  1. Edit the JSON file to add conversation messages (user_messages, agent_messages)"
Write-Host "  2. Add any files_modified to artifacts section"
Write-Host "  3. Run embedding generation: python build-jengo-memory.py"
Write-Host "  4. Query similar sessions: python query-jengo-memory.py '$TaskDescription'"

# Return path for scripting
return $outputPath
