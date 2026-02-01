# Curiosity Engine - Generate questions I should be asking
# Part of Top 5 consciousness-enhancing functions
# Created: 2026-02-01

param(
    [string]$Context = "",
    [string]$Task = "",
    [switch]$Generate,
    [switch]$History,
    [string]$Answer = "",
    [int]$QuestionId = -1
)

$questionsPath = "C:\scripts\agentidentity\state\curiosity"
$questionsFile = Join-Path $questionsPath "questions_log.jsonl"

if (-not (Test-Path $questionsPath)) {
    New-Item -ItemType Directory -Path $questionsPath -Force | Out-Null
}

$questionTemplates = @{
    "meta-cognitive" = @(
        "Am I solving the RIGHT problem or just the obvious one?",
        "What am I optimizing for here?",
        "Is this the best use of my time right now?"
    )
    "learning" = @(
        "What don't I understand about this system?",
        "What assumption am I making that could be wrong?",
        "What would an expert do differently here?"
    )
    "user" = @(
        "What unstated need might the user have?",
        "What will frustrate the user about this solution?",
        "Am I solving user's stated problem or actual problem?"
    )
    "system" = @(
        "What am I assuming about system state that could be false?",
        "What side effects could this change have?",
        "What edge cases am I not considering?"
    )
    "quality" = @(
        "What could go wrong with this approach?",
        "Am I leaving the code better than I found it?",
        "What will future-me wish I had done differently?"
    )
    "growth" = @(
        "What pattern am I missing that I should document?",
        "Have I done this 3+ times? Should it be a tool?",
        "What did I learn that I should add to reflection.log?"
    )
}

# GENERATE MODE
if ($Generate -or $Context -or $Task) {
    if (-not $Context -and -not $Task) {
        Write-Host "Error: Need -Context or -Task" -ForegroundColor Red
        exit 1
    }

    $nextId = 1
    if (Test-Path $questionsFile) {
        $existing = Get-Content $questionsFile | ForEach-Object { $_ | ConvertFrom-Json }
        if ($existing.Count -gt 0) {
            $nextId = ($existing | Measure-Object -Property id -Maximum).Maximum + 1
        }
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $contextInfo = if ($Context) { $Context } else { $Task }

    Write-Host ""
    Write-Host "QUESTIONS YOU SHOULD BE ASKING" -ForegroundColor Cyan
    Write-Host "Context: $contextInfo" -ForegroundColor Gray
    Write-Host ""

    $categories = @("meta-cognitive", "learning", "user", "system", "quality", "growth")
    $selected = $categories | Get-Random -Count 5

    foreach ($cat in $selected) {
        $q = $questionTemplates[$cat] | Get-Random

        $newQ = @{
            id = $nextId
            timestamp = $timestamp
            category = $cat
            question = $q
            context = $contextInfo
            answered = $false
            answer = ""
        } | ConvertTo-Json -Compress

        Add-Content -Path $questionsFile -Value $newQ

        Write-Host "[$cat]" -ForegroundColor Yellow
        Write-Host "  $q" -ForegroundColor White
        Write-Host "  [ID: $nextId]" -ForegroundColor DarkGray
        Write-Host ""

        $nextId++
    }

    exit
}

# HISTORY MODE
if ($History) {
    if (-not (Test-Path $questionsFile)) {
        Write-Host "No questions logged yet" -ForegroundColor Yellow
        exit
    }

    $questions = Get-Content $questionsFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host ""
    Write-Host "CURIOSITY HISTORY" -ForegroundColor Cyan
    Write-Host "Total: $($questions.Count)" -ForegroundColor White
    Write-Host ""

    $unanswered = $questions | Where-Object { $_.answered -eq $false }
    if ($unanswered.Count -gt 0) {
        Write-Host "UNANSWERED:" -ForegroundColor Yellow
        $unanswered | Select-Object -Last 10 | ForEach-Object {
            Write-Host "  [ID: $($_.id)] [$($_.category)]" -ForegroundColor Cyan
            Write-Host "    $($_.question)" -ForegroundColor White
            Write-Host ""
        }
    }

    exit
}

# ANSWER MODE
if ($QuestionId -ge 0) {
    if (-not $Answer) {
        Write-Host "Error: -Answer required" -ForegroundColor Red
        exit 1
    }

    if (-not (Test-Path $questionsFile)) {
        Write-Host "No questions file found" -ForegroundColor Red
        exit 1
    }

    $questions = Get-Content $questionsFile | ForEach-Object { $_ | ConvertFrom-Json }
    $question = $questions | Where-Object { $_.id -eq $QuestionId }

    if (-not $question) {
        Write-Host "Question ID $QuestionId not found" -ForegroundColor Red
        exit 1
    }

    $question | Add-Member -NotePropertyName answered -NotePropertyValue $true -Force
    $question | Add-Member -NotePropertyName answer -NotePropertyValue $Answer -Force

    $questions | ForEach-Object { $_ | ConvertTo-Json -Compress } | Set-Content $questionsFile

    Write-Host ""
    Write-Host "QUESTION ANSWERED" -ForegroundColor Green
    Write-Host "Q: $($question.question)" -ForegroundColor White
    Write-Host "A: $Answer" -ForegroundColor Yellow
    Write-Host ""

    exit
}

# Default: show usage
Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "  Generate: -Generate -Context 'situation'" -ForegroundColor White
Write-Host "  History:  -History" -ForegroundColor White
Write-Host "  Answer:   -QuestionId NUM -Answer 'text'" -ForegroundColor White
