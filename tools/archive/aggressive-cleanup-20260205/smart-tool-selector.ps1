<#
.SYNOPSIS
    AI-powered tool recommendation system

.DESCRIPTION
    Given a natural language task description, uses AI to recommend the top 3-5
    most relevant tools from 270+ available tools with usage examples.

    Tracks recommendations vs actual usage for continuous learning.

.PARAMETER Task
    Natural language description of what you want to do
    Example: "I need to find code that hasn't been used in months"

.PARAMETER Count
    Number of tool recommendations to return (default: 5)

.PARAMETER Provider
    AI provider: openai (default), anthropic

.PARAMETER Model
    Model to use (default: gpt-4o for openai, claude-3-5-sonnet for anthropic)

.PARAMETER OutputFormat
    Output format: text (default), json, markdown

.PARAMETER Learn
    Record whether recommended tools were actually used (for learning)
    Use: -Learn @{tool1=$true; tool2=$false; tool3=$true}

.PARAMETER ShowStats
    Show recommendation accuracy statistics

.EXAMPLE
    # Find tools for refactoring
    .\smart-tool-selector.ps1 -Task "I need to refactor old code"

.EXAMPLE
    # Get JSON output
    .\smart-tool-selector.ps1 -Task "allocate worktree" -OutputFormat json

.EXAMPLE
    # Record which tools were actually used
    .\smart-tool-selector.ps1 -Learn @{"code-hotspot-analyzer.ps1"=$true; "unused-code-detector.ps1"=$true}

.EXAMPLE
    # View recommendation accuracy
    .\smart-tool-selector.ps1 -ShowStats
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Task,

    [Parameter(Mandatory=$false)]
    [int]$Count = 5,

    [Parameter(Mandatory=$false)]
    [ValidateSet("openai", "anthropic")]
    [string]$Provider = "openai",

    [Parameter(Mandatory=$false)]
    [string]$Model,

    [Parameter(Mandatory=$false)]
    [ValidateSet("text", "json", "markdown")]
    [string]$OutputFormat = "text",

    [Parameter(Mandatory=$false)]
    [hashtable]$Learn,

    [Parameter(Mandatory=$false)]
    [switch]$ShowStats
)

$ErrorActionPreference = "Stop"

# Constants
$KNOWLEDGE_BASE_PATH = "C:\scripts\_machine\knowledge-base\07-AUTOMATION"
$TRACKING_FILE = "C:\scripts\_machine\tool-recommendations.jsonl"
$APPSETTINGS_PATH = "C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json"

# Default models
if (-not $Model) {
    $Model = if ($Provider -eq "openai") { "gpt-4o" } else { "claude-3-5-sonnet-20241022" }
}

function Load-ApiKey {
    param([string]$Provider)

    if (-not (Test-Path $APPSETTINGS_PATH)) {
        throw "appsettings.Secrets.json not found at $APPSETTINGS_PATH"
    }

    $secrets = Get-Content $APPSETTINGS_PATH -Raw | ConvertFrom-Json

    switch ($Provider) {
        "openai" {
            if (-not $secrets.ApiSettings.OpenApiKey) {
                throw "OpenAI API key not found in appsettings.ApiSettings.OpenApiKey"
            }
            return $secrets.ApiSettings.OpenApiKey
        }
        "anthropic" {
            if (-not $secrets.ApiSettings.AnthropicKey) {
                throw "Anthropic API key not found in appsettings.ApiSettings.AnthropicKey"
            }
            return $secrets.ApiSettings.AnthropicKey
        }
    }
}

function Load-ToolKnowledge {
    Write-Host "📚 Loading tool knowledge base..." -ForegroundColor Cyan

    $toolsLibrary = Get-Content "$KNOWLEDGE_BASE_PATH\tools-library.md" -Raw
    $selectionGuide = Get-Content "$KNOWLEDGE_BASE_PATH\tool-selection-guide.md" -Raw

    # Extract condensed version - smaller to avoid JSON issues
    $maxChars = 50000  # Reduced from 200000
    $condensed = @"
# TOOLS LIBRARY (270+ tools)

$($toolsLibrary.Substring(0, [Math]::Min($toolsLibrary.Length, $maxChars)))

---

# SELECTION GUIDE

$($selectionGuide.Substring(0, [Math]::Min($selectionGuide.Length, $maxChars)))
"@

    # Remove problematic characters that might break JSON
    $condensed = $condensed -replace '[\x00-\x1F]', ' '  # Remove control characters
    $condensed = $condensed -replace '"', '\"'  # Escape quotes

    return $condensed
}

function Get-ToolRecommendations {
    param(
        [string]$Task,
        [string]$ToolKnowledge,
        [string]$Provider,
        [string]$Model,
        [string]$ApiKey,
        [int]$Count
    )

    Write-Host "🤖 Analyzing task with $Provider ($Model)..." -ForegroundColor Cyan

    $systemPrompt = @"
You are an expert tool recommendation system for a Claude AI agent with 270+ automation tools.

Given a task description, you MUST recommend EXACTLY $Count tools.

For EACH of the $Count tools, provide:
1. Tool name (exact filename with .ps1 extension)
2. Why it's relevant to the task
3. Concrete usage example with actual parameters
4. Priority score (1-10)

Be SPECIFIC with tool names and parameters. Use the knowledge base to find exact matches.

IMPORTANT: Return a JSON object with a "recommendations" array containing EXACTLY $Count tools.

Output format:
{
  "recommendations": [
    {
      "tool": "exact-tool-name.ps1",
      "relevance": "why this tool matches the task",
      "example": ".\exact-tool-name.ps1 -Param1 value -Param2",
      "priority": 9
    },
    ...($Count total tools)
  ]
}
"@

    $userPrompt = @"
TASK: $Task

AVAILABLE TOOLS & KNOWLEDGE:
$ToolKnowledge

Recommend the top $Count tools for this task.
"@

    if ($Provider -eq "openai") {
        $headers = @{
            "Content-Type" = "application/json; charset=utf-8"
            "Authorization" = "Bearer $ApiKey"
        }

        # Manually construct JSON to avoid ConvertTo-Json issues with large strings
        $systemPromptEscaped = $systemPrompt -replace '\\', '\\' -replace '"', '\"' -replace "`n", '\n' -replace "`r", ''
        $userPromptEscaped = $userPrompt -replace '\\', '\\' -replace '"', '\"' -replace "`n", '\n' -replace "`r", ''

        $body = @"
{
  "model": "$Model",
  "messages": [
    {"role": "system", "content": "$systemPromptEscaped"},
    {"role": "user", "content": "$userPromptEscaped"}
  ],
  "temperature": 0.3,
  "max_tokens": 2000,
  "response_format": {"type": "json_object"}
}
"@

        try {
            $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" `
                -Method Post -Headers $headers -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 60

            $content = $response.choices[0].message.content

            # Parse JSON response
            $result = $content | ConvertFrom-Json

            # Handle different JSON structures
            if ($result.recommendations) {
                return $result.recommendations
            } elseif ($result.tools) {
                return $result.tools
            } else {
                return $result
            }

        } catch {
            Write-Host "❌ OpenAI API error: $_" -ForegroundColor Red
            Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor DarkRed
            throw
        }

    } elseif ($Provider -eq "anthropic") {
        $headers = @{
            "Content-Type" = "application/json"
            "x-api-key" = $ApiKey
            "anthropic-version" = "2023-06-01"
        }

        $body = @{
            model = $Model
            max_tokens = 2000
            temperature = 0.3
            system = $systemPrompt
            messages = @(
                @{ role = "user"; content = $userPrompt }
            )
        } | ConvertTo-Json -Depth 10

        try {
            $response = Invoke-RestMethod -Uri "https://api.anthropic.com/v1/messages" `
                -Method Post -Headers $headers -Body $body -TimeoutSec 60

            $content = $response.content[0].text

            # Extract JSON from markdown code block if present
            if ($content -match '```json\s*(.*?)\s*```') {
                $content = $matches[1]
            }

            return ($content | ConvertFrom-Json)

        } catch {
            Write-Host "❌ Anthropic API error: $_" -ForegroundColor Red
            throw
        }
    }
}

function Format-Recommendations {
    param(
        [array]$Recommendations,
        [string]$Format
    )

    switch ($Format) {
        "json" {
            return ($Recommendations | ConvertTo-Json -Depth 10)
        }

        "markdown" {
            $output = "# Tool Recommendations`n`n"
            $i = 1
            foreach ($rec in $Recommendations) {
                $output += "## $i. $($rec.tool) (Priority: $($rec.priority)/10)`n`n"
                $output += "**Relevance:** $($rec.relevance)`n`n"
                $output += "**Usage:**`n``````powershell`n$($rec.example)`n```````n`n"
                $i++
            }
            return $output
        }

        default {
            # Text format with colors
            Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor Cyan
            Write-Host "🎯 TOOL RECOMMENDATIONS" -ForegroundColor Cyan
            Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Cyan

            $i = 1
            foreach ($rec in $Recommendations) {
                Write-Host "$i. " -NoNewline -ForegroundColor Yellow
                Write-Host "$($rec.tool)" -ForegroundColor Green
                Write-Host "   Priority: $($rec.priority)/10" -ForegroundColor DarkGray
                Write-Host "   Relevance: " -NoNewline -ForegroundColor DarkGray
                Write-Host "$($rec.relevance)" -ForegroundColor White
                Write-Host "   Usage: " -NoNewline -ForegroundColor DarkGray
                Write-Host "$($rec.example)" -ForegroundColor Cyan
                Write-Host ""
                $i++
            }

            Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Cyan
            return $null
        }
    }
}

function Record-Recommendation {
    param(
        [string]$Task,
        [array]$Recommendations,
        [hashtable]$UsageFeedback
    )

    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"

    # Create tracking directory if needed
    $trackingDir = Split-Path $TRACKING_FILE
    if (-not (Test-Path $trackingDir)) {
        New-Item -ItemType Directory -Path $trackingDir -Force | Out-Null
    }

    $entry = @{
        timestamp = $timestamp
        task = $Task
        recommendations = $Recommendations
        feedback = $UsageFeedback
    } | ConvertTo-Json -Depth 10 -Compress

    # Append to JSONL file
    Add-Content -Path $TRACKING_FILE -Value $entry

    Write-Host "✅ Recommendation recorded for learning" -ForegroundColor Green
}

function Show-Statistics {
    if (-not (Test-Path $TRACKING_FILE)) {
        Write-Host "❌ No tracking data found" -ForegroundColor Red
        return
    }

    $entries = Get-Content $TRACKING_FILE | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "📊 TOOL RECOMMENDATION STATISTICS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Cyan

    Write-Host "Total Recommendations: " -NoNewline
    Write-Host $entries.Count -ForegroundColor Green

    $withFeedback = ($entries | Where-Object { $_.feedback -ne $null }).Count
    Write-Host "With Feedback: " -NoNewline
    Write-Host "$withFeedback ($([Math]::Round($withFeedback/$entries.Count*100, 1))%)" -ForegroundColor Green

    # Calculate accuracy
    $totalRecommended = 0
    $totalUsed = 0

    foreach ($entry in $entries) {
        if ($entry.feedback) {
            $totalRecommended += $entry.feedback.PSObject.Properties.Count
            $totalUsed += ($entry.feedback.PSObject.Properties | Where-Object { $_.Value -eq $true }).Count
        }
    }

    if ($totalRecommended -gt 0) {
        $accuracy = [Math]::Round($totalUsed / $totalRecommended * 100, 1)
        Write-Host "Recommendation Accuracy: " -NoNewline
        Write-Host "$accuracy% ($totalUsed used / $totalRecommended recommended)" -ForegroundColor Green
    }

    # Most recommended tools
    $toolCounts = @{}
    foreach ($entry in $entries) {
        foreach ($rec in $entry.recommendations) {
            if (-not $toolCounts.ContainsKey($rec.tool)) {
                $toolCounts[$rec.tool] = 0
            }
            $toolCounts[$rec.tool]++
        }
    }

    Write-Host "`nTop 10 Most Recommended Tools:" -ForegroundColor Yellow
    $toolCounts.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10 | ForEach-Object {
        Write-Host "  $($_.Key): " -NoNewline -ForegroundColor White
        Write-Host "$($_.Value) times" -ForegroundColor Cyan
    }

    Write-Host "`n═══════════════════════════════════════════════`n" -ForegroundColor Cyan
}

# Main execution
try {
    if ($ShowStats) {
        Show-Statistics
        exit 0
    }

    if ($Learn) {
        # Record feedback for previous recommendations
        # User should provide task description and feedback hash
        Write-Host "⚠️ Learning mode: You must provide -Task parameter to match the original task" -ForegroundColor Yellow

        if (-not $Task) {
            Write-Host "❌ -Task parameter required for learning mode" -ForegroundColor Red
            exit 1
        }

        # Record with empty recommendations (we're just recording feedback)
        Record-Recommendation -Task $Task -Recommendations @() -UsageFeedback $Learn
        exit 0
    }

    if (-not $Task) {
        Write-Host "❌ -Task parameter required" -ForegroundColor Red
        Write-Host "Example: .\smart-tool-selector.ps1 -Task 'I need to find unused code'" -ForegroundColor Yellow
        exit 1
    }

    # Load API key
    $apiKey = Load-ApiKey -Provider $Provider

    # Load tool knowledge base
    $toolKnowledge = Load-ToolKnowledge

    # Get recommendations
    $recommendations = Get-ToolRecommendations `
        -Task $Task `
        -ToolKnowledge $toolKnowledge `
        -Provider $Provider `
        -Model $Model `
        -ApiKey $apiKey `
        -Count $Count

    # Handle array or object response
    if ($recommendations -is [array]) {
        # Already an array
    } elseif ($recommendations.PSObject.Properties.Name -contains "recommendations") {
        $recommendations = $recommendations.recommendations
    } elseif ($recommendations.PSObject.Properties.Name -contains "tools") {
        $recommendations = $recommendations.tools
    } else {
        # Assume single object, wrap in array
        $recommendations = @($recommendations)
    }

    # Record recommendation (without feedback)
    Record-Recommendation -Task $Task -Recommendations $recommendations -UsageFeedback $null

    # Format and display
    $output = Format-Recommendations -Recommendations $recommendations -Format $OutputFormat

    if ($OutputFormat -in @("json", "markdown")) {
        Write-Output $output
    }

    Write-Host "💡 Tip: Use " -NoNewline -ForegroundColor DarkGray
    Write-Host "-Learn " -NoNewline -ForegroundColor Cyan
    Write-Host "to record which tools you actually used for continuous improvement" -ForegroundColor DarkGray

} catch {
    Write-Host "`n❌ Error: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
    exit 1
}
