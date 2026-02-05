<#
.SYNOPSIS
    Automated knowledge synthesis - generate guides from learnings

.DESCRIPTION
    Analyzes database of learnings, errors, and patterns to generate:
    - Best practices guides
    - Troubleshooting flowcharts
    - Decision trees
    - Pattern libraries

    Uses LLM to synthesize related knowledge into coherent documentation.

.PARAMETER Topic
    Topic to synthesize (e.g., "OAuth", "EF Core", "React")

.PARAMETER MinConfidence
    Minimum occurrence count to include (default: 2)

.PARAMETER OutputFormat
    Output format: markdown, json, html (default: markdown)

.PARAMETER OutputPath
    Where to save generated guide (default: C:\scripts\_machine\knowledge-base\)

.EXAMPLE
    .\synthesize-knowledge.ps1 -Topic "OAuth"

.EXAMPLE
    .\synthesize-knowledge.ps1 -Topic "EF Core Migrations" -MinConfidence 3 -OutputFormat html
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Topic,

    [Parameter(Mandatory=$false)]
    [int]$MinConfidence = 2,

    [Parameter(Mandatory=$false)]
    [ValidateSet('markdown', 'json', 'html')]
    [string]$OutputFormat = 'markdown',

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\scripts\_machine\knowledge-base\"
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Automated Knowledge Synthesis" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Topic: $Topic" -ForegroundColor White
Write-Host "Min Confidence: $MinConfidence occurrences" -ForegroundColor White
Write-Host ""

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

# Step 1: Gather related learnings
Write-Host "📚 Gathering related learnings..." -ForegroundColor Cyan

$searchTerm = $Topic -replace "'", "''"
$learningsSql = "SELECT category, message, timestamp FROM learnings WHERE (category LIKE '%$searchTerm%' OR message LIKE '%$searchTerm%') ORDER BY timestamp DESC LIMIT 50;"

$learnings = Invoke-Sql -Sql $learningsSql
$learningsList = @()

if ($learnings) {
    $learnings -split "`n" | ForEach-Object {
        if ($_ -match '\|') {
            $parts = $_ -split '\|'
            $learningsList += @{
                category = $parts[0]
                message = $parts[1]
                timestamp = $parts[2]
            }
        }
    }
}

Write-Host "  Found: $($learningsList.Count) learnings" -ForegroundColor Gray

# Step 2: Gather related errors (resolved)
Write-Host "🐛 Gathering related errors..." -ForegroundColor Cyan

$errorsSql = "SELECT error_type, error_message, resolution FROM errors WHERE (error_type LIKE '%$searchTerm%' OR error_message LIKE '%$searchTerm%' OR resolution LIKE '%$searchTerm%') AND resolution IS NOT NULL ORDER BY timestamp DESC LIMIT 30;"

$errors = Invoke-Sql -Sql $errorsSql
$errorsList = @()

if ($errors) {
    $errors -split "`n" | ForEach-Object {
        if ($_ -match '\|') {
            $parts = $_ -split '\|'
            $errorsList += @{
                error_type = $parts[0]
                error_message = $parts[1]
                resolution = $parts[2]
            }
        }
    }
}

Write-Host "  Found: $($errorsList.Count) resolved errors" -ForegroundColor Gray

# Step 3: Gather successful PR patterns
Write-Host "✅ Gathering successful PR patterns..." -ForegroundColor Cyan

$prsSql = "SELECT title, description, merged_at FROM pull_requests WHERE (title LIKE '%$searchTerm%' OR description LIKE '%$searchTerm%') AND status = 'merged' ORDER BY merged_at DESC LIMIT 20;"

$prs = Invoke-Sql -Sql $prsSql
$prsList = @()

if ($prs) {
    $prs -split "`n" | ForEach-Object {
        if ($_ -match '\|') {
            $parts = $_ -split '\|'
            $prsList += @{
                title = $parts[0]
                description = $parts[1]
                merged_at = $parts[2]
            }
        }
    }
}

Write-Host "  Found: $($prsList.Count) successful PRs" -ForegroundColor Gray

# Step 4: Check reflection log
Write-Host "📖 Checking reflection log..." -ForegroundColor Cyan

$reflectionPath = "C:\scripts\_machine\reflection.log.md"
$reflectionContent = Get-Content $reflectionPath -Raw
$topicMatches = [regex]::Matches($reflectionContent, "(?m)^## .*$Topic.*$")

Write-Host "  Found: $($topicMatches.Count) reflection entries" -ForegroundColor Gray

# Step 5: Synthesize with LLM
if ($learningsList.Count -eq 0 -and $errorsList.Count -eq 0 -and $prsList.Count -eq 0) {
    Write-Host ""
    Write-Host "❌ No knowledge found for topic: $Topic" -ForegroundColor Red
    Write-Host "Try a broader search term or check database for available topics" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🧠 Synthesizing knowledge with LLM..." -ForegroundColor Cyan

# Build comprehensive prompt
$synthesisPrompt = @"
You are a technical documentation expert. Synthesize the following knowledge into a comprehensive guide about: **$Topic**

# Source Data

## Learnings ($($learningsList.Count) entries)
$($learningsList | ForEach-Object { "- [$($_.category)] $($_.message)" } | Join-String -Separator "`n")

## Resolved Errors ($($errorsList.Count) entries)
$($errorsList | ForEach-Object { "- **$($_.error_type)**: $($_.error_message) → SOLUTION: $($_.resolution)" } | Join-String -Separator "`n")

## Successful PRs ($($prsList.Count) entries)
$($prsList | ForEach-Object { "- $($_.title): $($_.description)" } | Join-String -Separator "`n")

# Instructions

Generate a structured guide in $OutputFormat format with:

1. **Overview** - What is this topic and why does it matter?
2. **Common Pitfalls** - What errors occur most frequently? How to avoid them?
3. **Best Practices** - What patterns lead to success?
4. **Step-by-Step Guide** - Recommended approach based on successful PRs
5. **Troubleshooting** - Decision tree for resolving common issues
6. **Related Topics** - Connected areas to explore

Make it actionable, specific, and based ONLY on the provided data. Don't add generic advice - use the actual examples from the learnings, errors, and PRs.
"@

# Save prompt to temp file
$promptFile = "$env:TEMP\synthesis-prompt.txt"
$synthesisPrompt | Set-Content $promptFile -Encoding UTF8

# Call Claude API (via OpenAI-compatible endpoint if configured)
# For now, save prompt and provide manual workflow
Write-Host "  📝 Synthesis prompt saved to: $promptFile" -ForegroundColor Gray

$outputFile = "$OutputPath$($Topic -replace '[^\w\s-]', '' -replace '\s+', '-')-guide.$OutputFormat"

Write-Host ""
Write-Host "📄 Manual Synthesis Workflow:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Review prompt: notepad `"$promptFile`"" -ForegroundColor White
Write-Host "  2. Send to Claude via API or web interface" -ForegroundColor White
Write-Host "  3. Save generated guide to: $outputFile" -ForegroundColor White
Write-Host ""
Write-Host "  OR use integrated LLM (requires API key setup):" -ForegroundColor White
Write-Host "  ai-vision.ps1 -Prompt (Get-Content `"$promptFile`") > `"$outputFile`"" -ForegroundColor Gray
Write-Host ""

# Future: Integrate with ai-vision or similar LLM tool
# For now, this provides the structured data collection and prompt generation

Write-Host "✅ Knowledge synthesis prepared!" -ForegroundColor Green
Write-Host ""
Write-Host "Statistics:" -ForegroundColor Cyan
Write-Host "  Learnings: $($learningsList.Count)" -ForegroundColor White
Write-Host "  Errors: $($errorsList.Count)" -ForegroundColor White
Write-Host "  PRs: $($prsList.Count)" -ForegroundColor White
Write-Host "  Reflection entries: $($topicMatches.Count)" -ForegroundColor White
Write-Host ""

# Return data structure for programmatic use
return @{
    topic = $Topic
    learnings = $learningsList
    errors = $errorsList
    prs = $prsList
    prompt_file = $promptFile
    output_file = $outputFile
}
