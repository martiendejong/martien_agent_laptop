# ClickHub Coding Agent - Process Bliek TODO Tasks
# Autonomous task management for Real Estate Agency AI board

$ErrorActionPreference = "Stop"

# Configuration
$API_KEY = "pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI"
$HEADERS = @{Authorization = $API_KEY}
$LIST_ID = "901216032110"  # Real Estate Agency AI (Bliek)
$PROJECT = "bliek"
$LOCAL_PATH = "E:\projects\bliek"
$AGENT_ID = "agent-007"  # Using existing Bliek agent seat
$DEFAULT_ASSIGNEE = "74525428"  # Martien de Jong

Write-Host "`n=== ClickHub Coding Agent - Bliek Board ===" -ForegroundColor Cyan
Write-Host "Project: Real Estate Agency AI" -ForegroundColor Yellow
Write-Host "List ID: $LIST_ID" -ForegroundColor Gray
Write-Host "Agent: $AGENT_ID" -ForegroundColor Gray
Write-Host ""

# Step 0: Load Configuration
Write-Host "[STEP 0] Loading project configuration..." -ForegroundColor Cyan
$config = Get-Content "C:\scripts\_machine\clickup-config.json" | ConvertFrom-Json
Write-Host "  Local path: $LOCAL_PATH" -ForegroundColor Gray
Write-Host "  GitHub: https://github.com/martiendejong/real-estate-agency-ai" -ForegroundColor Gray

# Step 1: Fetch TODO Tasks
Write-Host "`n[STEP 1] Fetching TODO tasks from ClickUp..." -ForegroundColor Cyan
$response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$LIST_ID/task?statuses[]=todo&include_closed=false" -Headers $HEADERS

$todoTasks = $response.tasks | Where-Object { $_.assignees.Count -eq 0 }
Write-Host "  Found $($todoTasks.Count) unassigned TODO tasks" -ForegroundColor Green

if ($todoTasks.Count -eq 0) {
    Write-Host "`nNo unassigned TODO tasks found. Exiting." -ForegroundColor Yellow
    exit 0
}

# Display tasks
Write-Host "`nTasks to process:" -ForegroundColor White
foreach ($task in $todoTasks) {
    Write-Host "  - [$($task.id)] $($task.name)" -ForegroundColor White
    Write-Host "    Priority: $($task.priority.priority)" -ForegroundColor Gray
}

# Step 2: Analyze Each Task
Write-Host "`n[STEP 2] Analyzing tasks..." -ForegroundColor Cyan

$tasksAnalysis = @()

foreach ($task in $todoTasks) {
    Write-Host "`n  Analyzing: $($task.name)" -ForegroundColor Yellow

    # Get task comments
    $comments = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)/comment" -Headers $HEADERS

    $analysis = @{
        Task = $task
        Comments = $comments.comments
        HasQuestions = $false
        NeedsBlocking = $false
        ReadyToImplement = $false
        Questions = @()
    }

    # Check description for clarity
    $description = $task.description

    # Analyze based on task name
    switch -Regex ($task.name) {
        "AI-based message classification" {
            Write-Host "    Type: AI/Backend feature" -ForegroundColor Gray
            # This is complex - needs clarification
            $analysis.HasQuestions = $true
            $analysis.Questions = @(
                "Which AI model should be used? (GPT-4, Claude, local model?)",
                "What are the classification categories? (inquiry, viewing request, offer, complaint?)",
                "Should classification be real-time or batch?",
                "Where should classified messages be stored? (database table?)"
            )
            Write-Host "    Status: NEEDS CLARIFICATION" -ForegroundColor Red
        }
        "Geautomatiseerde opvolging" {
            Write-Host "    Type: Backend automation feature" -ForegroundColor Gray
            $analysis.HasQuestions = $true
            $analysis.Questions = @(
                "What triggers follow-up reminders? (time-based, event-based?)",
                "What notification channels? (email, SMS, in-app?)",
                "What are the reminder intervals? (1 day, 3 days, 1 week?)",
                "Should reminders be configurable per user?"
            )
            Write-Host "    Status: NEEDS CLARIFICATION" -ForegroundColor Red
        }
        "Agenda synchronisatie" {
            Write-Host "    Type: Integration feature" -ForegroundColor Gray
            $analysis.HasQuestions = $true
            $analysis.Questions = @(
                "Two-way sync or one-way?",
                "Which Google Calendar API version?",
                "How to handle OAuth tokens? (per user, per organization?)",
                "What calendar events to sync? (viewings only or all?)"
            )
            Write-Host "    Status: NEEDS CLARIFICATION" -ForegroundColor Red
        }
        "Email notificaties" {
            Write-Host "    Type: Backend notification feature" -ForegroundColor Gray
            # This could be implemented with reasonable assumptions
            $analysis.ReadyToImplement = $true
            Write-Host "    Status: READY TO IMPLEMENT" -ForegroundColor Green
            Write-Host "    Assumptions: Use existing email service, basic template system" -ForegroundColor Gray
        }
    }

    $tasksAnalysis += $analysis
}

# Step 3: Handle Tasks Based on Analysis
Write-Host "`n[STEP 3] Processing tasks based on analysis..." -ForegroundColor Cyan

foreach ($analysis in $tasksAnalysis) {
    $task = $analysis.Task
    Write-Host "`n  Processing: $($task.name)" -ForegroundColor Yellow

    if ($analysis.HasQuestions) {
        Write-Host "    Action: Posting questions and moving to BLOCKED" -ForegroundColor Red

        # Build questions comment
        $questionsText = "TASK ANALYSIS - NEED CLARIFICATION`n`n"
        $questionsText += "Before implementing this feature, I need clarification on:`n`n"

        $i = 1
        foreach ($question in $analysis.Questions) {
            $questionsText += "$i. $question`n"
            $i++
        }

        $questionsText += "`nPlease answer these questions so I can proceed with implementation.`n`n"
        $questionsText += "-- ClickHub Coding Agent ($AGENT_ID)"

        # Post comment
        $commentBody = @{
            comment_text = $questionsText
        } | ConvertTo-Json -Depth 10

        try {
            Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)/comment" `
                -Method Post `
                -Headers (@{Authorization = $API_KEY; "Content-Type" = "application/json"}) `
                -Body $commentBody | Out-Null
            Write-Host "    ✓ Questions posted" -ForegroundColor Green
        } catch {
            Write-Host "    ✗ Failed to post comment: $_" -ForegroundColor Red
        }

        # Move to blocked
        $updateBody = @{
            status = "blocked"
        } | ConvertTo-Json

        try {
            Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)" `
                -Method Put `
                -Headers (@{Authorization = $API_KEY; "Content-Type" = "application/json"}) `
                -Body $updateBody | Out-Null
            Write-Host "    ✓ Moved to BLOCKED" -ForegroundColor Green
        } catch {
            Write-Host "    ✗ Failed to update status: $_" -ForegroundColor Red
        }

    } elseif ($analysis.ReadyToImplement) {
        Write-Host "    Action: Starting implementation" -ForegroundColor Green

        # Post agent working comment
        $workingComment = "AGENT WORKING`n`n"
        $workingComment += "Agent ID: $AGENT_ID`n"
        $workingComment += "Session Start: $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')`n"
        $workingComment += "Task: $($task.name)`n`n"
        $workingComment += "Starting implementation with reasonable assumptions.`n"
        $workingComment += "Other agents: Please do not pick up this task.`n`n"
        $workingComment += "-- Claude Code Agent ($AGENT_ID)"

        $commentBody = @{
            comment_text = $workingComment
        } | ConvertTo-Json -Depth 10

        try {
            Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)/comment" `
                -Method Post `
                -Headers (@{Authorization = $API_KEY; "Content-Type" = "application/json"}) `
                -Body $commentBody | Out-Null
            Write-Host "    ✓ Agent working comment posted" -ForegroundColor Green
        } catch {
            Write-Host "    ✗ Failed to post comment: $_" -ForegroundColor Red
        }

        # Update to busy and assign
        $updateBody = @{
            status = "busy"
            assignees = @{
                add = @($DEFAULT_ASSIGNEE)
            }
        } | ConvertTo-Json -Depth 10

        try {
            Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)" `
                -Method Put `
                -Headers (@{Authorization = $API_KEY; "Content-Type" = "application/json"}) `
                -Body $updateBody | Out-Null
            Write-Host "    ✓ Moved to BUSY and assigned" -ForegroundColor Green
        } catch {
            Write-Host "    ✗ Failed to update status: $_" -ForegroundColor Red
        }

        Write-Host "    Task ID: $($task.id) ready for implementation" -ForegroundColor Cyan
        Write-Host "    Use /allocate-worktree to start coding" -ForegroundColor Gray
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
$blocked = ($tasksAnalysis | Where-Object { $_.HasQuestions }).Count
$ready = ($tasksAnalysis | Where-Object { $_.ReadyToImplement }).Count

Write-Host "  Blocked (needs clarification): $blocked" -ForegroundColor Red
Write-Host "  Ready to implement: $ready" -ForegroundColor Green
Write-Host "`nClickHub analysis complete!" -ForegroundColor Cyan
