#Requires -Version 5.1
<#
.SYNOPSIS
    Intelligent browser tab analyzer using Playwright MCP

.DESCRIPTION
    Works with the Browser MCP/Playwright instance that's already running.
    Analyzes current page, keeps history of visited pages, creates tasks based on content.

    Features:
    - Real-time analysis of current browser tab
    - AI-powered content understanding
    - Automatic task creation for actionable content
    - Pattern detection (research, documentation, tutorials, etc.)
    - History tracking of analyzed pages

.PARAMETER Action
    Analyze: Analyze current tab
    History: Show analysis history
    CreateTask: Create ClickUp task from current tab
    StartMonitor: Monitor browser continuously (every N seconds)
    Summary: Show summary of browsing patterns

.PARAMETER IntervalSeconds
    For Monitor mode - how often to check (default: 30)

.EXAMPLE
    .\browser-tab-intelligence.ps1 -Action Analyze
    .\browser-tab-intelligence.ps1 -Action CreateTask -DryRun
    .\browser-tab-intelligence.ps1 -Action StartMonitor -IntervalSeconds 60
#>

[CmdletBinding()]
param(
    [ValidateSet('Analyze', 'History', 'CreateTask', 'StartMonitor', 'Summary')]
    [string]$Action = 'Analyze',

    [int]$IntervalSeconds = 30,

    [switch]$DryRun,

    [switch]$Silent
)

$ErrorActionPreference = 'Stop'

$StateFile = "C:\scripts\_machine\browser-intelligence-state.json"
$HistoryFile = "C:\scripts\_machine\browser-intelligence-history.jsonl"
$OutputDir = "E:\jengo\documents\browser-analysis"

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    if (-not $Silent) {
        $color = switch ($Level) {
            "ERROR" { "Red" }
            "WARN" { "Yellow" }
            "SUCCESS" { "Green" }
            "HIGHLIGHT" { "Cyan" }
            default { "White" }
        }
        Write-Host $Message -ForegroundColor $color
    }
}

function Get-CurrentTabInfo {
    Write-Log "Capturing current tab..." "INFO"

    try {
        # Use Playwright MCP to get current page info
        $snapshotPath = Join-Path $OutputDir "snapshot_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"

        # Capture snapshot (text content)
        & "C:\Users\HP\.claude\node_modules\.bin\mcp.cmd" playwright browser_snapshot `
            --filename $snapshotPath 2>$null

        # Read snapshot
        if (Test-Path $snapshotPath) {
            $content = Get-Content -Path $snapshotPath -Raw

            # Extract URL from snapshot (usually in first lines)
            $url = "unknown"
            if ($content -match 'URL: (.+)') {
                $url = $Matches[1]
            }

            Write-Log "Snapshot captured: $snapshotPath" "SUCCESS"

            return @{
                Url = $url
                Content = $content
                SnapshotPath = $snapshotPath
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        } else {
            Write-Log "Failed to capture snapshot" "ERROR"
            return $null
        }
    }
    catch {
        Write-Log "Error capturing tab: $_" "ERROR"
        return $null
    }
}

function Analyze-WithAI {
    param([hashtable]$TabInfo)

    Write-Log "AI analyzing content..." "HIGHLIGHT"

    # Truncate content for analysis (first 2000 chars)
    $contentPreview = $TabInfo.Content.Substring(0, [Math]::Min(2000, $TabInfo.Content.Length))

    $prompt = @"
Analyze this browser tab content and determine:

URL: $($TabInfo.Url)

Content preview:
$contentPreview

Provide analysis in JSON format:
{
  "category": "research|documentation|tutorial|entertainment|work|shopping|social|news|email|productivity|coding|learning",
  "priority": "high|medium|low",
  "actionable": true/false,
  "task_description": "one sentence description if actionable",
  "project": "client-manager|hazina|art-revisionist|personal|none",
  "recommendation": "create_task|bookmark|close_tab|keep_open|archive",
  "reasoning": "why this recommendation",
  "keywords": ["key", "concepts", "from", "content"]
}
"@

    try {
        # Call OpenAI API
        $config = Get-Content "C:\scripts\_machine\quick-context.json" | ConvertFrom-Json
        $apiKey = $config.services.openai.api_key

        $headers = @{
            "Authorization" = "Bearer $apiKey"
            "Content-Type" = "application/json"
        }

        $body = @{
            model = "gpt-4o-mini"
            messages = @(
                @{
                    role = "system"
                    content = "You are a browser tab analyzer. Analyze content and provide structured JSON output."
                }
                @{
                    role = "user"
                    content = $prompt
                }
            )
            temperature = 0.3
            max_tokens = 400
        } | ConvertTo-Json -Depth 10

        $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" `
            -Method Post `
            -Headers $headers `
            -Body $body

        $content = $response.choices[0].message.content

        # Parse JSON
        if ($content -match '\{[\s\S]*\}') {
            $jsonStr = $Matches[0]
            $analysis = $jsonStr | ConvertFrom-Json

            Write-Log "Analysis complete!" "SUCCESS"
            Write-Log "  Category: $($analysis.category)" "INFO"
            Write-Log "  Priority: $($analysis.priority)" "INFO"
            Write-Log "  Actionable: $($analysis.actionable)" "INFO"
            Write-Log "  Recommendation: $($analysis.recommendation)" "HIGHLIGHT"

            return @{
                Category = $analysis.category
                Priority = $analysis.priority
                Actionable = $analysis.actionable
                TaskDescription = $analysis.task_description
                Project = $analysis.project
                Recommendation = $analysis.recommendation
                Reasoning = $analysis.reasoning
                Keywords = $analysis.keywords
            }
        }
        else {
            Write-Log "Failed to parse AI response" "ERROR"
            return $null
        }
    }
    catch {
        Write-Log "AI analysis failed: $_" "ERROR"
        return $null
    }
}

function Save-ToHistory {
    param(
        [hashtable]$TabInfo,
        [hashtable]$Analysis
    )

    $entry = @{
        Timestamp = $TabInfo.Timestamp
        Url = $TabInfo.Url
        Category = $Analysis.Category
        Priority = $Analysis.Priority
        Actionable = $Analysis.Actionable
        TaskDescription = $Analysis.TaskDescription
        Project = $Analysis.Project
        Recommendation = $Analysis.Recommendation
        Keywords = $Analysis.Keywords
    }

    # Append to JSONL history file
    $entry | ConvertTo-Json -Compress | Add-Content -Path $HistoryFile

    Write-Log "Saved to history" "SUCCESS"
}

function Create-TaskFromAnalysis {
    param(
        [hashtable]$TabInfo,
        [hashtable]$Analysis
    )

    if ($DryRun) {
        Write-Log "[DRY RUN] Would create task: $($Analysis.TaskDescription)" "WARN"
        return $null
    }

    Write-Log "Creating ClickUp task..." "HIGHLIGHT"

    $listIds = @{
        'client-manager' = '901214097647'
        'hazina' = '901215559249'
        'art-revisionist' = '901211612245'
        'personal' = '901214097647'
    }

    $listId = $listIds[$Analysis.Project]

    if (-not $listId) {
        Write-Log "No ClickUp list for project: $($Analysis.Project)" "WARN"
        return $null
    }

    $taskName = $Analysis.TaskDescription
    $taskDescription = @"
Auto-generated from browser analysis

URL: $($TabInfo.Url)
Category: $($Analysis.Category)
Priority: $($Analysis.Priority)
Keywords: $($Analysis.Keywords -join ', ')
Reasoning: $($Analysis.Reasoning)

Analyzed: $($TabInfo.Timestamp)
Snapshot: $($TabInfo.SnapshotPath)
"@

    try {
        $result = & "C:\scripts\tools\clickup-task-operations-v3.ps1" `
            -Action Create `
            -Project $Analysis.Project `
            -Name $taskName `
            -Description $taskDescription `
            -Status "backlog"

        Write-Log "Task created successfully!" "SUCCESS"
        return $result
    }
    catch {
        Write-Log "Failed to create task: $_" "ERROR"
        return $null
    }
}

function Show-History {
    if (-not (Test-Path $HistoryFile)) {
        Write-Log "No history yet" "WARN"
        return
    }

    $history = Get-Content -Path $HistoryFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host "`n=== BROWSING HISTORY ===" -ForegroundColor Cyan
    Write-Host "Total entries: $($history.Count)`n"

    $history | Select-Object -Last 10 | ForEach-Object {
        Write-Host "[$($_.Timestamp)] $($_.Category) - $($_.Priority)" -ForegroundColor Yellow
        Write-Host "  URL: $($_.Url)"
        if ($_.Actionable) {
            Write-Host "  Task: $($_.TaskDescription)" -ForegroundColor Green
        }
        Write-Host "  Recommendation: $($_.Recommendation)" -ForegroundColor Magenta
        Write-Host ""
    }
}

function Show-Summary {
    if (-not (Test-Path $HistoryFile)) {
        Write-Log "No history yet" "WARN"
        return
    }

    $history = Get-Content -Path $HistoryFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-Host "`n=== BROWSING PATTERNS SUMMARY ===" -ForegroundColor Cyan

    # Category breakdown
    $categories = $history | Group-Object Category | Sort-Object Count -Descending
    Write-Host "`nCategories:"
    foreach ($cat in $categories) {
        Write-Host "  $($cat.Name): $($cat.Count)" -ForegroundColor Yellow
    }

    # Priority breakdown
    $priorities = $history | Group-Object Priority | Sort-Object Count -Descending
    Write-Host "`nPriorities:"
    foreach ($pri in $priorities) {
        Write-Host "  $($pri.Name): $($pri.Count)" -ForegroundColor Yellow
    }

    # Actionable items
    $actionable = ($history | Where-Object { $_.Actionable }).Count
    Write-Host "`nActionable items: $actionable / $($history.Count)" -ForegroundColor Green

    # Project breakdown
    $projects = $history | Group-Object Project | Sort-Object Count -Descending
    Write-Host "`nProjects:"
    foreach ($proj in $projects) {
        Write-Host "  $($proj.Name): $($proj.Count)" -ForegroundColor Yellow
    }

    # Top keywords
    $allKeywords = $history | ForEach-Object { $_.Keywords } | Where-Object { $_ } | ForEach-Object { $_ }
    $topKeywords = $allKeywords | Group-Object | Sort-Object Count -Descending | Select-Object -First 10
    Write-Host "`nTop keywords:"
    foreach ($kw in $topKeywords) {
        Write-Host "  $($kw.Name): $($kw.Count)" -ForegroundColor Cyan
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

Write-Log "=== Browser Tab Intelligence ===" "HIGHLIGHT"

switch ($Action) {
    'Analyze' {
        $tabInfo = Get-CurrentTabInfo
        if (-not $tabInfo) { exit 1 }

        $analysis = Analyze-WithAI -TabInfo $tabInfo
        if (-not $analysis) { exit 1 }

        Save-ToHistory -TabInfo $tabInfo -Analysis $analysis

        # Show analysis
        Write-Host "`n=== ANALYSIS ===" -ForegroundColor Cyan
        Write-Host "URL: $($tabInfo.Url)" -ForegroundColor Yellow
        Write-Host "Category: $($analysis.Category)"
        Write-Host "Priority: $($analysis.Priority)"
        Write-Host "Actionable: $($analysis.Actionable)"
        if ($analysis.Actionable) {
            Write-Host "Task: $($analysis.TaskDescription)" -ForegroundColor Green
            Write-Host "Project: $($analysis.Project)"
        }
        Write-Host "Recommendation: $($analysis.Recommendation)" -ForegroundColor Magenta
        Write-Host "Reasoning: $($analysis.Reasoning)" -ForegroundColor DarkGray
        Write-Host "Keywords: $($analysis.Keywords -join ', ')" -ForegroundColor Cyan
    }

    'CreateTask' {
        $tabInfo = Get-CurrentTabInfo
        if (-not $tabInfo) { exit 1 }

        $analysis = Analyze-WithAI -TabInfo $tabInfo
        if (-not $analysis) { exit 1 }

        if ($analysis.Actionable) {
            Save-ToHistory -TabInfo $tabInfo -Analysis $analysis
            Create-TaskFromAnalysis -TabInfo $tabInfo -Analysis $analysis
        } else {
            Write-Log "This tab is not actionable - no task will be created" "WARN"
        }
    }

    'History' {
        Show-History
    }

    'Summary' {
        Show-Summary
    }

    'StartMonitor' {
        Write-Log "Starting continuous monitoring (every $IntervalSeconds seconds)" "SUCCESS"
        Write-Log "Press Ctrl+C to stop`n"

        $lastUrl = ""

        while ($true) {
            try {
                $tabInfo = Get-CurrentTabInfo

                # Only analyze if URL changed
                if ($tabInfo -and $tabInfo.Url -ne $lastUrl) {
                    Write-Log "New page detected: $($tabInfo.Url)" "HIGHLIGHT"

                    $analysis = Analyze-WithAI -TabInfo $tabInfo
                    if ($analysis) {
                        Save-ToHistory -TabInfo $tabInfo -Analysis $analysis

                        # Auto-create task if highly actionable
                        if ($analysis.Actionable -and $analysis.Priority -eq 'high' -and $analysis.Recommendation -eq 'create_task') {
                            Write-Log "Auto-creating task (high priority + actionable)..." "SUCCESS"
                            Create-TaskFromAnalysis -TabInfo $tabInfo -Analysis $analysis
                        }
                    }

                    $lastUrl = $tabInfo.Url
                }

                Start-Sleep -Seconds $IntervalSeconds
            }
            catch {
                Write-Log "Monitor error: $_" "ERROR"
                Start-Sleep -Seconds 10
            }
        }
    }
}

Write-Log "`nDone!" "SUCCESS"
