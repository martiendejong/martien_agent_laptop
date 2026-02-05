# Conversation Intent Classifier
# Classifies conversation intent from first few messages

param(
    [Parameter(Mandatory=$true)]
    [string]$Message
)

$intents = @{
    debug = @{
        keywords = @("debug", "error", "bug", "fix", "issue", "problem", "crash", "exception", "stack trace", "breakpoint")
        context_files = @(
            "C:\scripts\docs\claude-system\CAPABILITIES.md",
            "C:\scripts\_machine\best-practices\debugging-patterns.md"
        )
    }
    feature = @{
        keywords = @("feature", "implement", "add", "create", "build", "develop", "PR", "pull request", "worktree")
        context_files = @(
            "C:\scripts\development-patterns.md",
            "C:\scripts\worktree-workflow.md",
            "C:\scripts\git-workflow.md"
        )
    }
    docs = @{
        keywords = @("document", "readme", "explain", "how does", "what is", "describe", "clarify")
        context_files = @(
            "C:\scripts\CLAUDE.md",
            "C:\scripts\docs\claude-system\STARTUP_PROTOCOL.md"
        )
    }
    config = @{
        keywords = @("configure", "setup", "install", "config", "settings", "environment")
        context_files = @(
            "C:\scripts\MACHINE_CONFIG.md",
            "C:\scripts\session-management.md"
        )
    }
    migration = @{
        keywords = @("migration", "database", "ef core", "schema", "migrate")
        context_files = @(
            "C:\scripts\_machine\migration-patterns.md"
        )
    }
}

$messageLower = $Message.ToLower()
$scores = @{}

foreach ($intent in $intents.Keys) {
    $score = 0
    foreach ($keyword in $intents[$intent].keywords) {
        if ($messageLower -match $keyword) {
            $score++
        }
    }
    $scores[$intent] = $score
}

$topIntent = $scores.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1

if ($topIntent.Value -gt 0) {
    $intent = $topIntent.Key
    $confidence = [math]::Min([math]::Round($topIntent.Value / 3 * 100, 2), 95)

    Write-Host "`n=== Detected Intent: $($intent.ToUpper()) ===" -ForegroundColor Cyan
    Write-Host "Confidence: $confidence%" -ForegroundColor Green
    Write-Host "`nRecommended context files:" -ForegroundColor Yellow

    foreach ($file in $intents[$intent].context_files) {
        Write-Host "  - $file" -ForegroundColor White
    }

    return @{
        intent = $intent
        confidence = $confidence
        context_files = $intents[$intent].context_files
        detected_keywords = ($intents[$intent].keywords | Where-Object { $messageLower -match $_ })
    }
} else {
    Write-Host "No clear intent detected - loading default context" -ForegroundColor Yellow
    return @{
        intent = "general"
        confidence = 0
        context_files = @("C:\scripts\CLAUDE.md")
    }
}
