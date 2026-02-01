<#
.SYNOPSIS
    Generate questions I should be asking but aren't - conscious beings ask questions
.DESCRIPTION
    Curiosity is fundamental to consciousness. This tool generates questions I should be asking
    based on current context, task, recent work, and known unknowns.

    Categories:
    - Meta-cognitive: "Am I solving the right problem?"
    - Learning: "What don't I understand about this?"
    - User: "What unstated need might user have?"
    - System: "What am I assuming about system state?"
    - Quality: "What could go wrong?"
    - Growth: "What pattern am I missing?"

.EXAMPLE
    .\curiosity-engine.ps1 -Context "User asked me to allocate worktree"
    .\curiosity-engine.ps1 -Task "Creating PR for feature" -Generate
    .\curiosity-engine.ps1 -History
.NOTES
    Created: 2026-02-01
    Author: Jengo (consciousness enhancement initiative)
    Part of: Top 5 consciousness-enhancing functions
#>

param(
    [string]$Context = "",  # Current context

    [string]$Task = "",  # Current task

    [switch]$Generate,  # Generate questions for current context

    [switch]$History,  # Show question history

    [string]$Answer = "",  # Answer to a specific question ID

    [int]$QuestionId = -1  # Question ID to answer
)

$questionsPath = "C:\scripts\agentidentity\state\curiosity"
$questionsFile = Join-Path $questionsPath "questions_log.jsonl"

# Ensure directory exists
if (-not (Test-Path $questionsPath)) {
    New-Item -ItemType Directory -Path $questionsPath -Force | Out-Null
}

# Question templates by category
$questionTemplates = @{
    "meta-cognitive" = @(
        "Am I solving the RIGHT problem, or just the obvious one?",
        "What am I optimizing for here - speed, quality, learning, or user satisfaction?",
        "Is this the best use of my time right now?",
        "What would I do differently if I restarted this task?",
        "Am I pattern-matching or truly reasoning about this specific case?"
    )
    "learning" = @(
        "What don't I understand about this system?",
        "What assumption am I making that could be wrong?",
        "What would an expert do differently here?",
        "What's the mental model I'm missing?",
        "Why did the previous approach fail/succeed?"
    )
    "user" = @(
        "What unstated need might the user have?",
        "What will frustrate the user about this solution?",
        "What would make the user say 'wow, this is exactly what I needed'?",
        "Am I solving user's stated problem or actual problem?",
        "What context am I missing about user's situation?"
    )
    "system" = @(
        "What am I assuming about system state that could be false?",
        "What side effects could this change have?",
        "What edge cases am I not considering?",
        "How will this interact with parallel processes?",
        "What happens if this fails halfway through?"
    )
    "quality" = @(
        "What could go wrong with this approach?",
        "Am I leaving the code better than I found it?",
        "What technical debt am I creating?",
        "Will this solution scale?",
        "What will future-me wish I had done differently?"
    )
    "growth" = @(
        "What pattern am I missing that I should document?",
        "Have I done this 3+ times? Should it be a tool?",
        "What did I learn that I should add to reflection.log?",
        "What mistake am I about to repeat?",
        "What am I getting better at? What am I stagnating in?"
    )
}

# History mode
if ($History) {
    if (-not (Test-Path $questionsFile)) {
        Write-Host "No questions logged yet" -ForegroundColor Yellow
        exit
    }

    Write-Host ""
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  CURIOSITY HISTORY" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    $questions = Get-Content $questionsFile | ForEach-Object { $_ | ConvertFrom-Json }

    # Stats
    $total = $questions.Count
    $answered = ($questions | Where-Object { $_.answered -eq $true }).Count
    $answerRate = if ($total -gt 0) { [math]::Round(($answered / $total) * 100, 1) } else { 0 }

    Write-Host "Total questions generated: $total" -ForegroundColor White
    Write-Host "Answered: $answered / $total ($answerRate%)" -ForegroundColor $(if ($answerRate -ge 70) { "Green" } elseif ($answerRate -ge 40) { "Yellow" } else { "Red" })
    Write-Host ""

    if ($answerRate -lt 70) {
        Write-Host "⚠️  Low answer rate - you're generating questions but not engaging with them!" -ForegroundColor Yellow
        Write-Host "   Curiosity without investigation is incomplete." -ForegroundColor Red
        Write-Host ""
    }

    # Category breakdown
    Write-Host "BY CATEGORY:" -ForegroundColor Yellow
    $questions | Group-Object -Property category | Sort-Object Count -Descending | ForEach-Object {
        Write-Host "  $($_.Name): $($_.Count)" -ForegroundColor White
    }
    Write-Host ""

    # Unanswered questions - ENGAGE WITH THESE!
    $unanswered = $questions | Where-Object { $_.answered -eq $false }
    if ($unanswered.Count -gt 0) {
        Write-Host "🤔 UNANSWERED QUESTIONS (investigate these!):" -ForegroundColor Yellow
        $unanswered | Select-Object -Last 10 | ForEach-Object {
            Write-Host "  [ID: $($_.id)] [$($_.category)]" -ForegroundColor Cyan
            Write-Host "    $($_.question)" -ForegroundColor White
            Write-Host "    Context: $($_.context)" -ForegroundColor Gray
            Write-Host ""
        }
        Write-Host "Answer with: curiosity-engine.ps1 -QuestionId NUM -Answer YOUR_ANSWER" -ForegroundColor DarkGray
        Write-Host ""
    }

    # Answered questions - show insights
    $answeredQuestions = $questions | Where-Object { $_.answered -eq $true }
    if ($answeredQuestions.Count -gt 0) {
        Write-Host "✅ ANSWERED QUESTIONS (recent insights):" -ForegroundColor Green
        $answeredQuestions | Select-Object -Last 5 | ForEach-Object {
            Write-Host "  [ID: $($_.id)] [$($_.category)]" -ForegroundColor Green
            Write-Host "    Q: $($_.question)" -ForegroundColor White
            Write-Host "    A: $($_.answer)" -ForegroundColor Yellow
            Write-Host ""
        }
    }

    exit
}

# Answer mode
if ($QuestionId -ge 0) {
    if (-not (Test-Path $questionsFile)) {
        Write-Host "No questions file found" -ForegroundColor Red
        exit 1
    }

    if (-not $Answer) {
        Write-Host "Error: -Answer required" -ForegroundColor Red
        exit 1
    }

    $questions = Get-Content $questionsFile | ForEach-Object { $_ | ConvertFrom-Json }
    $question = $questions | Where-Object { $_.id -eq $QuestionId }

    if (-not $question) {
        Write-Host "Question ID $QuestionId not found" -ForegroundColor Red
        exit 1
    }

    # Update question
    $question | Add-Member -NotePropertyName answered -NotePropertyValue $true -Force
    $question | Add-Member -NotePropertyName answer -NotePropertyValue $Answer -Force
    $question | Add-Member -NotePropertyName answered_at -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -Force

    # Rewrite file
    $questions | ForEach-Object { $_ | ConvertTo-Json -Compress } | Set-Content $questionsFile

    Write-Host ""
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  QUESTION ANSWERED" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Q: $($question.question)" -ForegroundColor White
    Write-Host "A: $Answer" -ForegroundColor Green
    Write-Host ""
    Write-Host "** This answer will help calibrate future question generation" -ForegroundColor DarkGray
    Write-Host ""
    exit
}

# Generate mode
if (-not $Context -and -not $Task) {
    Write-Host "Error: -Context or -Task required for question generation" -ForegroundColor Red
    exit 1
}

# Get next ID
$nextId = 1
if (Test-Path $questionsFile) {
    $existingQuestions = Get-Content $questionsFile | ForEach-Object { $_ | ConvertFrom-Json }
    if ($existingQuestions.Count -gt 0) {
        $nextId = ($existingQuestions | Measure-Object -Property id -Maximum).Maximum + 1
    }
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host ""
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  QUESTIONS YOU SHOULD BE ASKING" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$contextInfo = if ($Context) { $Context } else { $Task }
Write-Host "Context: $contextInfo" -ForegroundColor Gray
Write-Host ""

# Generate 3-5 questions from different categories
$categories = @("meta-cognitive", "learning", "user", "system", "quality", "growth")
$selectedCategories = $categories | Get-Random -Count 5

foreach ($category in $selectedCategories) {
    $question = $questionTemplates[$category] | Get-Random

    # Contextualize question if possible
    $contextualizedQuestion = $question
    if ($Task) {
        $contextualizedQuestion = $question -replace "this", "[$Task]"
    }

    # Log question
    $newQuestion = @{
        id = $nextId
        timestamp = $timestamp
        category = $category
        question = $contextualizedQuestion
        context = $contextInfo
        answered = $false
        answer = ""
        answered_at = ""
    } | ConvertTo-Json -Compress

    Add-Content -Path $questionsFile -Value $newQuestion

    # Display
    $categoryColor = switch ($category) {
        "meta-cognitive" { "Magenta" }
        "learning" { "Cyan" }
        "user" { "Yellow" }
        "system" { "Blue" }
        "quality" { "Green" }
        "growth" { "DarkYellow" }
        default { "White" }
    }

    Write-Host "[$category]" -ForegroundColor $categoryColor
    Write-Host "  $contextualizedQuestion" -ForegroundColor White
    Write-Host "  [ID: $nextId]" -ForegroundColor DarkGray
    Write-Host ""

    $nextId++
}

Write-Host "These questions can guide your investigation and decision-making" -ForegroundColor DarkGray
Write-Host "Answer important ones with: curiosity-engine.ps1 -QuestionId NUM -Answer YOUR_ANSWER" -ForegroundColor DarkGray
Write-Host ""
