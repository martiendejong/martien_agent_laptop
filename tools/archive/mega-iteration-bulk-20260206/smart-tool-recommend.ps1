# Smart Tool Recommender
# AI-powered tool discovery - finds the right tool for your task
#
# Usage:
#   .\smart-tool-recommend.ps1 -Intent "I want to create a pull request"
#   .\smart-tool-recommend.ps1 -Intent "Fix build errors" -Context "C# compilation"
#   .\smart-tool-recommend.ps1 -Intent "Optimize images"

param(
    [Parameter(Mandatory=$true)]
    [string]$Intent,

    [Parameter(Mandatory=$false)]
    [string]$Context = "",

    [Parameter(Mandatory=$false)]
    [int]$TopN = 3
)

# Tool knowledge base (will be auto-generated from tools/ directory in v2)
$toolDatabase = @(
    @{
        Name = "gh pr create"
        Category = "Git/GitHub"
        Keywords = @("pull request", "pr", "create pr", "github", "merge request")
        Description = "Create a GitHub pull request"
        Usage = "gh pr create --title `"Title`" --body `"Description`""
        UseCases = @("Creating PR", "Starting code review", "Proposing changes")
    },
    @{
        Name = "allocate-worktree"
        Category = "Development"
        Keywords = @("worktree", "allocate", "start feature", "new branch", "isolated workspace")
        Description = "Allocate a worker agent worktree for code editing"
        Usage = "Use /allocate-worktree skill in Claude Code"
        UseCases = @("Starting new feature", "Isolated development", "Multi-agent work")
    },
    @{
        Name = "cs-autofix"
        Category = "C#"
        Keywords = @("c#", "compilation errors", "build errors", "fix errors", "auto fix")
        Description = "Automatically fix common C# compilation errors"
        Usage = ".\cs-autofix.ps1 -ProjectPath C:\Projects\client-manager"
        UseCases = @("Fixing compilation errors", "Code cleanup", "Quick fixes")
    },
    @{
        Name = "ai-image.ps1"
        Category = "AI/Media"
        Keywords = @("image", "generate", "dall-e", "illustration", "visual", "picture")
        Description = "Generate AI images using DALL-E"
        Usage = ".\ai-image.ps1 -Prompt `"A professional illustration`" -OutputPath image.png"
        UseCases = @("Creating visuals", "Marketing materials", "Mockups")
    },
    @{
        Name = "ai-vision.ps1"
        Category = "AI/Media"
        Keywords = @("vision", "analyze image", "describe image", "ocr", "read image")
        Description = "Analyze images using GPT-4 Vision"
        Usage = ".\ai-vision.ps1 -ImagePath image.png -Prompt `"Describe this`""
        UseCases = @("Image analysis", "OCR", "Visual inspection")
    },
    @{
        Name = "build-dashboard.ps1"
        Category = "Development"
        Keywords = @("build", "status", "ci", "pipeline", "checks")
        Description = "Show build status across all projects"
        Usage = ".\build-dashboard.ps1"
        UseCases = @("Checking build status", "CI/CD monitoring", "Health check")
    },
    @{
        Name = "check-duplicates.ps1"
        Category = "ClickUp"
        Keywords = @("duplicate", "clickup", "similar tasks", "find duplicates")
        Description = "Find duplicate ClickUp tasks using Levenshtein distance"
        Usage = ".\check-duplicates.ps1"
        UseCases = @("Finding duplicate tasks", "Cleanup", "Task hygiene")
    },
    @{
        Name = "task-discovery-scan.ps1"
        Category = "ClickUp"
        Keywords = @("task", "exists", "already implemented", "check implementation")
        Description = "Check if a task is already implemented"
        Usage = ".\task-discovery-scan.ps1 -TaskId 869bx3h3g"
        UseCases = @("Pre-task audit", "Avoiding duplicate work", "Code discovery")
    },
    @{
        Name = "trace-signalr.ps1"
        Category = "Debugging"
        Keywords = @("signalr", "websocket", "real-time", "debug", "diagnose")
        Description = "Diagnose SignalR issues"
        Usage = ".\trace-signalr.ps1"
        UseCases = @("SignalR debugging", "Real-time issues", "Connection problems")
    },
    @{
        Name = "world-daily-dashboard.ps1"
        Category = "Information"
        Keywords = @("news", "world", "daily", "briefing", "updates")
        Description = "Generate daily world development briefing"
        Usage = ".\world-daily-dashboard.ps1"
        UseCases = @("Daily briefing", "World news", "Context awareness")
    }
)

function Calculate-Relevance {
    param($Tool, $Intent, $Context)

    $score = 0
    $intentLower = $Intent.ToLower()
    $contextLower = $Context.ToLower()

    # Keyword matching
    foreach ($keyword in $Tool.Keywords) {
        if ($intentLower -match [regex]::Escape($keyword.ToLower())) {
            $score += 10
        }
        if ($contextLower -match [regex]::Escape($keyword.ToLower())) {
            $score += 5
        }
    }

    # Description matching
    if ($Tool.Description.ToLower() -match [regex]::Escape($intentLower)) {
        $score += 8
    }

    # Category relevance
    if ($contextLower -match $Tool.Category.ToLower()) {
        $score += 7
    }

    # Use case matching
    foreach ($useCase in $Tool.UseCases) {
        if ($intentLower -match [regex]::Escape($useCase.ToLower())) {
            $score += 12
        }
    }

    return $score
}

# Calculate relevance scores
$rankedTools = @()
foreach ($tool in $toolDatabase) {
    $score = Calculate-Relevance -Tool $tool -Intent $Intent -Context $Context
    if ($score -gt 0) {
        $rankedTools += @{
            Tool = $tool
            Score = $score
        }
    }
}

# Sort by score descending
$rankedTools = $rankedTools | Sort-Object -Property Score -Descending

# Output results
if ($rankedTools.Count -eq 0) {
    Write-Host "`n❌ No tools found matching your intent." -ForegroundColor Red
    Write-Host "Try rephrasing your request or check C:\scripts\tools\ for available tools." -ForegroundColor Yellow
    exit 1
}

Write-Host "`n🔍 Smart Tool Recommender Results" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════" -ForegroundColor Cyan
Write-Host "Intent: $Intent" -ForegroundColor White
if ($Context) {
    Write-Host "Context: $Context" -ForegroundColor Gray
}
Write-Host ""

$displayCount = [Math]::Min($TopN, $rankedTools.Count)

for ($i = 0; $i -lt $displayCount; $i++) {
    $item = $rankedTools[$i]
    $tool = $item.Tool
    $score = $item.Score

    Write-Host "🔧 #$($i+1) $($tool.Name) " -ForegroundColor Green -NoNewline
    Write-Host "(Score: $score)" -ForegroundColor DarkGray
    Write-Host "   Category: $($tool.Category)" -ForegroundColor Gray
    Write-Host "   $($tool.Description)" -ForegroundColor White
    Write-Host "   Usage: " -ForegroundColor Yellow -NoNewline
    Write-Host "$($tool.Usage)" -ForegroundColor White

    if ($tool.UseCases.Count -gt 0) {
        Write-Host "   Use cases: $($tool.UseCases -join ', ')" -ForegroundColor DarkCyan
    }
    Write-Host ""
}

# Learning feedback
Write-Host "💡 Tip: The more specific your intent, the better the recommendations." -ForegroundColor DarkYellow
Write-Host "Run with -TopN 5 to see more results." -ForegroundColor DarkYellow
