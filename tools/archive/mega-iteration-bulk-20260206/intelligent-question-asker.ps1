# intelligent-question-asker.ps1
# Ask questions based on available context, avoid asking what can be inferred

param(
    [Parameter(Mandatory=$true)]
    [string]$Topic,

    [string[]]$KnownFacts = @(),

    [string[]]$PossibleQuestions = @(),

    [switch]$ShowAnalysis
)

# Context gathering functions
function Get-AvailableContext {
    param($topic)

    $context = @{
        git_status = $null
        recent_errors = $null
        worktree_status = $null
        recent_commands = $null
    }

    # Git status
    if (Test-Path ".git") {
        try {
            $gitStatus = git status --short 2>$null
            $gitBranch = git branch --show-current 2>$null
            $context.git_status = @{
                branch = $gitBranch
                changes = $gitStatus
                has_changes = ($gitStatus.Length -gt 0)
            }
        } catch {}
    }

    # Recent build errors
    $recentErrorsPath = "C:\scripts\agentidentity\state\recent-build-errors.yaml"
    if (Test-Path $recentErrorsPath) {
        try {
            $context.recent_errors = Get-Content $recentErrorsPath -Raw | ConvertFrom-Yaml
        } catch {}
    }

    # Worktree status
    $worktreePath = "C:\scripts\_machine\worktrees.pool.md"
    if (Test-Path $worktreePath) {
        try {
            $worktreeContent = Get-Content $worktreePath -Raw
            $context.worktree_status = @{
                content = $worktreeContent
                has_busy = ($worktreeContent -match "BUSY")
            }
        } catch {}
    }

    return $context
}

function Filter-RedundantQuestions {
    param($questions, $context, $knownFacts)

    $filtered = @()

    foreach ($q in $questions) {
        $redundant = $false

        # Check if question can be answered from context
        if ($q -match "which branch" -and $context.git_status.branch) {
            # Can answer: which branch -> current branch is X
            $redundant = $true
        }

        if ($q -match "any errors" -and $context.recent_errors) {
            # Can answer: are there errors -> yes, here they are
            $redundant = $true
        }

        if ($q -match "worktree.*available" -and $context.worktree_status) {
            # Can answer: worktree availability -> check pool status
            $redundant = $true
        }

        # Check if question already answered by known facts
        foreach ($fact in $knownFacts) {
            if ($q -match [regex]::Escape($fact.Split(':')[0])) {
                $redundant = $true
                break
            }
        }

        if (-not $redundant) {
            $filtered += @{
                question = $q
                reason = "Cannot be inferred from available context"
            }
        } else {
            if ($ShowAnalysis) {
                Write-Host "   Filtered: " -NoNewline -ForegroundColor DarkGray
                Write-Host $q -ForegroundColor Gray
                Write-Host "   (Can be inferred from context)" -ForegroundColor DarkGray
            }
        }
    }

    return $filtered
}

# Main logic
$context = Get-AvailableContext -topic $Topic

if ($ShowAnalysis) {
    Write-Host "`n🧠 INTELLIGENT QUESTION ANALYSIS" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "Topic: " -NoNewline -ForegroundColor Gray
    Write-Host $Topic -ForegroundColor White

    Write-Host "`nAvailable Context:" -ForegroundColor Cyan
    if ($context.git_status) {
        Write-Host "  ✅ Git status: " -NoNewline -ForegroundColor Green
        Write-Host "Branch '$($context.git_status.branch)', $($context.git_status.changes.Count) changes" -ForegroundColor Gray
    } else {
        Write-Host "  ❌ Git status: Not available" -ForegroundColor DarkGray
    }

    if ($context.recent_errors) {
        $errorCount = 0
        foreach ($target in $context.recent_errors.findings.Keys) {
            $errorCount += $context.recent_errors.findings[$target].Count
        }
        Write-Host "  ✅ Recent errors: " -NoNewline -ForegroundColor Green
        Write-Host "$errorCount error log(s) found" -ForegroundColor Gray
    } else {
        Write-Host "  ❌ Recent errors: Not available" -ForegroundColor DarkGray
    }

    if ($context.worktree_status) {
        Write-Host "  ✅ Worktree status: " -NoNewline -ForegroundColor Green
        Write-Host "Available" -ForegroundColor Gray
    } else {
        Write-Host "  ❌ Worktree status: Not available" -ForegroundColor DarkGray
    }

    Write-Host "`nKnown Facts:" -ForegroundColor Cyan
    if ($KnownFacts.Count -gt 0) {
        foreach ($fact in $KnownFacts) {
            Write-Host "  • $fact" -ForegroundColor Gray
        }
    } else {
        Write-Host "  (none provided)" -ForegroundColor DarkGray
    }
}

# Filter questions
$necessaryQuestions = Filter-RedundantQuestions -questions $PossibleQuestions -context $context -knownFacts $KnownFacts

# Output
if ($ShowAnalysis) {
    Write-Host "`nFiltered Questions:" -ForegroundColor Cyan
}

$output = @{
    topic = $Topic
    analyzed_at = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    context_available = @{
        git = ($null -ne $context.git_status)
        errors = ($null -ne $context.recent_errors)
        worktrees = ($null -ne $context.worktree_status)
    }
    known_facts = $KnownFacts
    necessary_questions = @()
}

if ($necessaryQuestions.Count -eq 0) {
    if ($ShowAnalysis) {
        Write-Host "  ✅ All questions can be answered from available context!" -ForegroundColor Green
    }
    $output.conclusion = "No questions needed - sufficient context available"
} else {
    foreach ($nq in $necessaryQuestions) {
        $output.necessary_questions += $nq.question
        if ($ShowAnalysis) {
            Write-Host "  ? " -NoNewline -ForegroundColor Yellow
            Write-Host $nq.question -ForegroundColor White
            Write-Host "    Reason: " -NoNewline -ForegroundColor DarkGray
            Write-Host $nq.reason -ForegroundColor Gray
        }
    }
    $output.conclusion = "$($necessaryQuestions.Count) question(s) necessary"
}

if ($ShowAnalysis) {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
}

# Save analysis
$analysisPath = "C:\scripts\agentidentity\state\question-analysis.yaml"
$output | ConvertTo-Yaml | Out-File -FilePath $analysisPath -Encoding UTF8

return $output
