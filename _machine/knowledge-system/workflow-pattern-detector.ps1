# Workflow Pattern Detector - R03-003
# Detect if current conversation matches known patterns (debug, feature, docs, etc.)
# Expert: Johan Andersson - Developer Workflow Analyst

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('detect', 'train', 'patterns')]
    [string]$Action = 'detect',

    [Parameter(Mandatory=$false)]
    [string]$Query,

    [Parameter(Mandatory=$false)]
    [string[]]$RecentQueries
)

# Define known workflow patterns
$WorkflowPatterns = @{
    'debug' = @{
        'keywords' = @('debug', 'error', 'bug', 'fail', 'issue', 'broken', 'fix', 'crash', 'exception', 'stack trace')
        'typical_sequence' = @('Check error logs', 'Review recent changes', 'Test locally', 'Fix code', 'Verify fix')
        'predicted_context' = @(
            'C:\scripts\ci-cd-troubleshooting.md'
            'C:\scripts\_machine\reflection.log.md'
            'C:\Projects\client-manager\README.md'
        )
        'confidence_threshold' = 0.3
    }

    'feature' = @{
        'keywords' = @('feature', 'implement', 'add', 'create', 'new', 'develop', 'build')
        'typical_sequence' = @('Allocate worktree', 'Review similar code', 'Implement', 'Test', 'Create PR')
        'predicted_context' = @(
            'C:\scripts\worktree-workflow.md'
            'C:\scripts\development-patterns.md'
            'C:\scripts\_machine\worktrees.pool.md'
        )
        'confidence_threshold' = 0.25
    }

    'documentation' = @{
        'keywords' = @('docs', 'documentation', 'readme', 'update docs', 'document', 'explain')
        'typical_sequence' = @('Read current docs', 'Update content', 'Review changes', 'Commit')
        'predicted_context' = @(
            'C:\scripts\CLAUDE.md'
            'C:\scripts\docs\claude-system\STARTUP_PROTOCOL.md'
            'C:\scripts\continuous-improvement.md'
        )
        'confidence_threshold' = 0.35
    }

    'ci-cd' = @{
        'keywords' = @('ci', 'cd', 'pipeline', 'build', 'deploy', 'github actions', 'workflow', 'test fail')
        'typical_sequence' = @('Check pipeline logs', 'Review workflow file', 'Fix config', 'Re-run pipeline')
        'predicted_context' = @(
            'C:\scripts\ci-cd-troubleshooting.md'
            'C:\Projects\client-manager\.github\workflows'
        )
        'confidence_threshold' = 0.3
    }

    'git-workflow' = @{
        'keywords' = @('commit', 'push', 'pull', 'merge', 'branch', 'pr', 'pull request', 'git')
        'typical_sequence' = @('Stage changes', 'Commit', 'Push', 'Create PR', 'Review', 'Merge')
        'predicted_context' = @(
            'C:\scripts\git-workflow.md'
            'C:\scripts\_machine\worktrees.activity.md'
        )
        'confidence_threshold' = 0.25
    }

    'worktree-management' = @{
        'keywords' = @('worktree', 'allocate', 'release', 'pool', 'agent')
        'typical_sequence' = @('Check pool', 'Allocate worktree', 'Work on task', 'Release worktree')
        'predicted_context' = @(
            'C:\scripts\worktree-workflow.md'
            'C:\scripts\_machine\worktrees.pool.md'
            'C:\scripts\_machine\worktrees.protocol.md'
        )
        'confidence_threshold' = 0.4
    }

    'exploration' = @{
        'keywords' = @('how', 'what', 'why', 'explain', 'show', 'find', 'search', 'where')
        'typical_sequence' = @('Search codebase', 'Read files', 'Understand architecture', 'Provide answer')
        'predicted_context' = @(
            'C:\scripts\CLAUDE.md'
            'C:\Projects\client-manager\README.md'
        )
        'confidence_threshold' = 0.2
    }

    'review' = @{
        'keywords' = @('review', 'check', 'verify', 'validate', 'test', 'qa')
        'typical_sequence' = @('Review code', 'Check tests', 'Verify behavior', 'Approve/Request changes')
        'predicted_context' = @(
            'C:\scripts\development-patterns.md'
            'C:\scripts\_machine\DEFINITION_OF_DONE.md'
        )
        'confidence_threshold' = 0.3
    }
}

function Detect-WorkflowPattern {
    param(
        [string]$Query,
        [string[]]$RecentQueries
    )

    $allQueries = @($Query)
    if ($RecentQueries) {
        $allQueries += $RecentQueries
    }

    $combinedText = ($allQueries -join " ").ToLower()

    $scores = @{}

    foreach ($patternName in $WorkflowPatterns.Keys) {
        $pattern = $WorkflowPatterns[$patternName]
        $matchCount = 0

        foreach ($keyword in $pattern.keywords) {
            if ($combinedText -match [regex]::Escape($keyword.ToLower())) {
                $matchCount++
            }
        }

        $score = $matchCount / $pattern.keywords.Count
        $scores[$patternName] = @{
            'score' = [math]::Round($score, 3)
            'confidence' = [math]::Round($score * 100, 1)
            'threshold' = $pattern.confidence_threshold
            'match' = $score -ge $pattern.confidence_threshold
        }
    }

    # Get best matches
    $matches = $scores.GetEnumerator() |
        Where-Object { $_.Value.match } |
        Sort-Object { $_.Value.score } -Descending

    Write-Host "`nWorkflow Pattern Detection Results:" -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host "Query: $Query" -ForegroundColor Gray

    if ($matches.Count -eq 0) {
        Write-Host "`nNo confident pattern match found" -ForegroundColor Yellow
        Write-Host "All scores:" -ForegroundColor Gray
        $scores.GetEnumerator() | Sort-Object { $_.Value.score } -Descending | ForEach-Object {
            Write-Host "  $($_.Name): $($_.Value.confidence)% (threshold: $($_.Value.threshold * 100)%)" -ForegroundColor Gray
        }
        return $null
    }

    Write-Host "`nMatched Patterns:" -ForegroundColor Green
    $results = @()

    foreach ($match in $matches) {
        $patternName = $match.Name
        $pattern = $WorkflowPatterns[$patternName]
        $score = $match.Value

        Write-Host "`n[$patternName] - Confidence: $($score.confidence)%" -ForegroundColor Yellow

        $result = @{
            'pattern' = $patternName
            'confidence' = $score.confidence
            'typical_sequence' = $pattern.typical_sequence
            'predicted_context' = $pattern.predicted_context
        }

        $results += $result

        Write-Host "  Typical sequence:" -ForegroundColor Gray
        $pattern.typical_sequence | ForEach-Object { Write-Host "    → $_" -ForegroundColor DarkGray }

        Write-Host "  Predicted context files:" -ForegroundColor Gray
        $pattern.predicted_context | ForEach-Object { Write-Host "    • $_" -ForegroundColor DarkGray }
    }

    return $results
}

function Show-Patterns {
    Write-Host "`nAvailable Workflow Patterns:" -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor Cyan

    foreach ($patternName in $WorkflowPatterns.Keys) {
        $pattern = $WorkflowPatterns[$patternName]

        Write-Host "`n[$patternName]" -ForegroundColor Yellow
        Write-Host "  Keywords: $($pattern.keywords -join ', ')" -ForegroundColor Gray
        Write-Host "  Confidence threshold: $($pattern.confidence_threshold * 100)%" -ForegroundColor Gray
        Write-Host "  Typical sequence:" -ForegroundColor Gray
        $pattern.typical_sequence | ForEach-Object { Write-Host "    → $_" -ForegroundColor DarkGray }
    }
}

function Train-PatternDetector {
    # Analyze past sequences to improve patterns
    $SequenceFile = "C:\scripts\_machine\knowledge-system\sequences.jsonl"

    if (-not (Test-Path $SequenceFile)) {
        Write-Host "No sequence data available" -ForegroundColor Red
        return
    }

    Write-Host "Training pattern detector from historical data..." -ForegroundColor Cyan

    $sequences = Get-Content $SequenceFile | ForEach-Object { $_ | ConvertFrom-Json }

    # Analyze keyword frequency per pattern
    $patternCounts = @{}
    foreach ($patternName in $WorkflowPatterns.Keys) {
        $patternCounts[$patternName] = 0
    }

    foreach ($seq in $sequences) {
        $query = $seq.query.ToLower()

        foreach ($patternName in $WorkflowPatterns.Keys) {
            $pattern = $WorkflowPatterns[$patternName]

            foreach ($keyword in $pattern.keywords) {
                if ($query -match [regex]::Escape($keyword.ToLower())) {
                    $patternCounts[$patternName]++
                    break
                }
            }
        }
    }

    Write-Host "`nPattern Frequency in Historical Data:" -ForegroundColor Green
    $patternCounts.GetEnumerator() |
        Sort-Object Value -Descending |
        ForEach-Object {
            $percentage = [math]::Round(($_.Value / $sequences.Count) * 100, 1)
            Write-Host "  $($_.Name): $($_.Value) occurrences ($percentage%)" -ForegroundColor Yellow
        }
}

# Main execution
switch ($Action) {
    'detect' {
        if (-not $Query) {
            Write-Host "Query required for detection" -ForegroundColor Red
            Write-Host "Example: -Query 'Debug failing CI pipeline'" -ForegroundColor Gray
            exit 1
        }
        $result = Detect-WorkflowPattern -Query $Query -RecentQueries $RecentQueries

        # If pattern detected, suggest preloading context
        if ($result) {
            Write-Host "`nSuggested Action:" -ForegroundColor Cyan
            Write-Host "Preload context files using hot-context-cache.ps1" -ForegroundColor Gray
        }
    }
    'train' {
        Train-PatternDetector
    }
    'patterns' {
        Show-Patterns
    }
}
