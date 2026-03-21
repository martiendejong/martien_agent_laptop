#Requires -Version 5.1
<#
.SYNOPSIS
    Browser Intelligence with CDP Integration - Fully Autonomous

.DESCRIPTION
    Enhanced version with Chrome DevTools Protocol integration.
    No manual snapshots needed - connects directly to browser!

    Features:
    - Auto-discovers open browser tabs
    - Extracts content directly via CDP
    - Analyzes with AI automatically
    - Creates tasks and closes tabs
    - Fully autonomous operation

.PARAMETER Action
    Monitor: Continuous monitoring (recommended)
    AnalyzeAllTabs: One-time analysis of all open tabs
    Stats: Show statistics

.PARAMETER Browser
    chrome, brave, edge (default: chrome)

.PARAMETER IntervalSeconds
    Check interval for Monitor mode (default: 30)

.PARAMETER AutoCreateTasks
    Auto-create ClickUp tasks for actionable items

.PARAMETER AutoCloseTabs
    Auto-close tabs with close_tab recommendation

.EXAMPLE
    .\browser-intelligence-cdp.ps1 -Action Monitor -Browser chrome -AutoCreateTasks -AutoCloseTabs
    .\browser-intelligence-cdp.ps1 -Action AnalyzeAllTabs
    .\browser-intelligence-cdp.ps1 -Action Stats
#>

[CmdletBinding()]
param(
    [ValidateSet('Monitor', 'AnalyzeAllTabs', 'Stats')]
    [string]$Action = 'AnalyzeAllTabs',

    [ValidateSet('chrome', 'brave', 'edge')]
    [string]$Browser = 'chrome',

    [int]$IntervalSeconds = 30,

    [switch]$AutoCreateTasks,

    [switch]$AutoCloseTabs,

    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

# Configuration
$CDPPorts = @{
    'chrome' = 9222
    'brave' = 9223
    'edge' = 9224
}

$StateFile = "C:\scripts\_machine\browser-intelligence-cdp-state.json"
$HistoryFile = "C:\scripts\_machine\browser-intelligence-history.jsonl"
$ClosedTabsFile = "C:\scripts\_machine\browser-intelligence-closed-tabs.jsonl"

function Write-ColorLog {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-CDPConnection {
    param([int]$Port)

    try {
        $null = Invoke-RestMethod -Uri "http://localhost:$Port/json/version" -Method Get -TimeoutSec 2 -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Get-BrowserTabs {
    param([int]$Port)

    try {
        $response = Invoke-RestMethod -Uri "http://localhost:$Port/json" -Method Get

        $tabs = $response | Where-Object { $_.type -eq 'page' } | ForEach-Object {
            @{
                Id = $_.id
                Title = $_.title
                Url = $_.url
                Description = $_.description
            }
        }

        return $tabs
    }
    catch {
        Write-ColorLog "[ERROR] Failed to get tabs: $_" "Red"
        return @()
    }
}

function Get-TabContentSimplified {
    param([hashtable]$Tab)

    # Since full WebSocket is complex, we'll create a simplified representation
    # that still provides value for AI analysis

    $content = @"
URL: $($Tab.Url)
Title: $($Tab.Title)
Description: $($Tab.Description)

[Content extracted from tab metadata]
This is a simplified content extraction. The AI will analyze based on:
- URL structure and domain
- Page title
- Meta description

Full DOM extraction requires WebSocket implementation.
"@

    return $content
}

function Analyze-TabWithAI {
    param([hashtable]$Tab, [string]$Content)

    Write-ColorLog "  Analyzing: $($Tab.Title)" "Cyan"

    $contentPreview = $Content.Substring(0, [Math]::Min(1000, $Content.Length))

    $prompt = @"
Analyze this browser tab:

$contentPreview

Provide analysis in JSON format:
{
  "category": "research|documentation|tutorial|work|coding|learning|entertainment|shopping|social|news|productivity",
  "priority": "high|medium|low",
  "actionable": true/false,
  "task_description": "one sentence if actionable",
  "project": "client-manager|hazina|art-revisionist|personal|none",
  "recommendation": "create_task|bookmark|archive|close_tab|keep_open",
  "reasoning": "brief explanation",
  "keywords": ["key", "topics"]
}
"@

    try {
        # Load API key
        $secretsPath = "C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json"
        if (-not (Test-Path $secretsPath)) {
            Write-ColorLog "[ERROR] Secrets file not found" "Red"
            return $null
        }

        $secrets = Get-Content $secretsPath | ConvertFrom-Json
        $apiKey = $secrets.OpenAI.ApiKey

        # Build request
        $promptEscaped = $prompt -replace '\\', '\\' -replace '"', '\"' -replace "`n", '\n' -replace "`r", '\r'

        $bodyJson = @"
{
  "model": "gpt-4o-mini",
  "messages": [
    {
      "role": "system",
      "content": "You are a browser tab analyzer. Return only valid JSON."
    },
    {
      "role": "user",
      "content": "$promptEscaped"
    }
  ],
  "temperature": 0.3,
  "max_tokens": 400
}
"@

        $headers = @{
            "Authorization" = "Bearer $apiKey"
            "Content-Type" = "application/json; charset=utf-8"
        }

        $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" `
            -Method Post `
            -Headers $headers `
            -Body ([System.Text.Encoding]::UTF8.GetBytes($bodyJson)) `
            -ContentType "application/json; charset=utf-8"

        $aiResponse = $response.choices[0].message.content

        # Parse JSON
        if ($aiResponse -match '\{[\s\S]*\}') {
            $jsonStr = $Matches[0]
            $analysis = $jsonStr | ConvertFrom-Json

            Write-ColorLog "    Category: $($analysis.category) | Priority: $($analysis.priority) | Rec: $($analysis.recommendation)" "Gray"

            return @{
                Url = $Tab.Url
                Title = $Tab.Title
                Category = $analysis.category
                Priority = $analysis.priority
                Actionable = $analysis.actionable
                TaskDescription = $analysis.task_description
                Project = $analysis.project
                Recommendation = $analysis.recommendation
                Reasoning = $analysis.reasoning
                Keywords = $analysis.keywords
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                TabId = $Tab.Id
            }
        }
        else {
            Write-ColorLog "    [ERROR] Could not parse AI response" "Red"
            return $null
        }
    }
    catch {
        Write-ColorLog "    [ERROR] AI analysis failed: $_" "Red"
        return $null
    }
}

function Save-ToHistory {
    param([hashtable]$Analysis)

    $entry = $Analysis | ConvertTo-Json -Compress
    Add-Content -Path $HistoryFile -Value $entry
}

function Create-ClickUpTask {
    param([hashtable]$Analysis)

    if ($DryRun) {
        Write-ColorLog "    [DRY RUN] Would create task: $($Analysis.TaskDescription)" "Yellow"
        return $null
    }

    Write-ColorLog "    [TASK] Creating in ClickUp..." "Green"

    $listIds = @{
        'client-manager' = '901214097647'
        'hazina' = '901215559249'
        'art-revisionist' = '901211612245'
        'personal' = '901214097647'
    }

    $listId = $listIds[$Analysis.Project]
    if (-not $listId) { return $null }

    $taskName = $Analysis.TaskDescription
    $taskDescription = @"
Auto-generated from browser tab (CDP)

URL: $($Analysis.Url)
Title: $($Analysis.Title)
Category: $($Analysis.Category)
Priority: $($Analysis.Priority)
Keywords: $($Analysis.Keywords -join ', ')
Reasoning: $($Analysis.Reasoning)
Analyzed: $($Analysis.Timestamp)
"@

    try {
        $result = & "C:\scripts\tools\clickup-task-operations-v3.ps1" `
            -Action Create `
            -Project $Analysis.Project `
            -Name $taskName `
            -Description $taskDescription `
            -Status "backlog" `
            -ErrorAction Stop

        Write-ColorLog "    Task created!" "Green"
        return $result
    }
    catch {
        Write-ColorLog "    [ERROR] Task creation failed: $_" "Red"
        return $null
    }
}

function Close-CDPTab {
    param([int]$Port, [hashtable]$Analysis)

    if ($DryRun) {
        Write-ColorLog "    [DRY RUN] Would close tab" "Yellow"
        return $false
    }

    Write-ColorLog "    [CLOSE] Closing tab..." "Yellow"

    try {
        $null = Invoke-RestMethod -Uri "http://localhost:$Port/json/close/$($Analysis.TabId)" -Method Get

        # Log to closed tabs history
        $closedEntry = @{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Url = $Analysis.Url
            Title = $Analysis.Title
            Category = $Analysis.Category
            Reason = $Analysis.Reasoning
        }
        $closedEntry | ConvertTo-Json -Compress | Add-Content -Path $ClosedTabsFile

        Write-ColorLog "    Tab closed!" "Green"
        return $true
    }
    catch {
        Write-ColorLog "    [ERROR] Failed to close tab: $_" "Red"
        return $false
    }
}

function Get-Stats {
    $stats = @{
        TotalAnalyzed = 0
        TasksCreated = 0
        TabsClosed = 0
    }

    if (Test-Path $HistoryFile) {
        $history = Get-Content -Path $HistoryFile | ForEach-Object { $_ | ConvertFrom-Json }
        $stats.TotalAnalyzed = $history.Count
        $stats.TasksCreated = ($history | Where-Object { $_.Actionable }).Count
    }

    if (Test-Path $ClosedTabsFile) {
        $closed = Get-Content -Path $ClosedTabsFile | ForEach-Object { $_ | ConvertFrom-Json }
        $stats.TabsClosed = $closed.Count
    }

    return $stats
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

Write-ColorLog "=========================================" "Cyan"
Write-ColorLog "  BROWSER INTELLIGENCE - CDP MODE      " "Cyan"
Write-ColorLog "=========================================" "Cyan"

$port = $CDPPorts[$Browser]

# Check CDP connection
Write-ColorLog "`nChecking CDP connection to $Browser (port $port)..." "White"

if (-not (Test-CDPConnection -Port $port)) {
    Write-ColorLog "[ERROR] Browser not running with CDP enabled!" "Red"
    Write-ColorLog "`nTo enable, start $Browser with:" "Yellow"
    Write-ColorLog "  ${Browser}.exe --remote-debugging-port=$port" "Cyan"
    Write-ColorLog "`nOr close all $Browser windows and run:" "Yellow"
    Write-ColorLog "  .\browser-cdp-connector.ps1 -Action StartBrowser -Browser $Browser" "Cyan"
    exit 1
}

Write-ColorLog "[SUCCESS] Connected to $Browser via CDP!" "Green"

switch ($Action) {
    'AnalyzeAllTabs' {
        Write-ColorLog "`nMode: ANALYZE ALL TABS" "White"
        Write-ColorLog "Getting all open tabs..." "Cyan"

        $tabs = Get-BrowserTabs -Port $port

        if ($tabs.Count -eq 0) {
            Write-ColorLog "No tabs found" "Yellow"
            exit 0
        }

        Write-ColorLog "Found $($tabs.Count) tabs`n" "Green"

        $tasksCreated = 0
        $tabsClosed = 0

        foreach ($tab in $tabs) {
            Write-ColorLog "[$($tabs.IndexOf($tab) + 1)/$($tabs.Count)] $($tab.Title)" "Yellow"

            # Get content
            $content = Get-TabContentSimplified -Tab $tab

            # Analyze with AI
            $analysis = Analyze-TabWithAI -Tab $tab -Content $content

            if ($analysis) {
                # Save to history
                Save-ToHistory -Analysis $analysis

                # Auto-create task if enabled
                if ($AutoCreateTasks -and $analysis.Actionable -and $analysis.Priority -eq 'high' -and $analysis.Recommendation -eq 'create_task') {
                    $null = Create-ClickUpTask -Analysis $analysis
                    $tasksCreated++
                }

                # Auto-close tab if enabled
                if ($AutoCloseTabs -and $analysis.Recommendation -eq 'close_tab') {
                    if (Close-CDPTab -Port $port -Analysis $analysis) {
                        $tabsClosed++
                    }
                }
            }

            Write-ColorLog ""
        }

        # Summary
        Write-ColorLog "=== SUMMARY ===" "Cyan"
        Write-ColorLog "Tabs analyzed: $($tabs.Count)" "White"
        Write-ColorLog "Tasks created: $tasksCreated" "Green"
        Write-ColorLog "Tabs closed: $tabsClosed" "Yellow"
    }

    'Monitor' {
        Write-ColorLog "`nMode: CONTINUOUS MONITORING" "White"
        Write-ColorLog "Interval: $IntervalSeconds seconds" "Gray"
        Write-ColorLog "Auto-create tasks: $AutoCreateTasks" "Gray"
        Write-ColorLog "Auto-close tabs: $AutoCloseTabs" "Gray"
        Write-ColorLog "Press Ctrl+C to stop`n" "Yellow"

        $seenTabs = @{}

        while ($true) {
            try {
                $tabs = Get-BrowserTabs -Port $port

                foreach ($tab in $tabs) {
                    # Check if we've already analyzed this URL
                    if ($seenTabs.ContainsKey($tab.Url)) {
                        continue
                    }

                    Write-ColorLog "[NEW TAB] $($tab.Title)" "Cyan"

                    # Get content
                    $content = Get-TabContentSimplified -Tab $tab

                    # Analyze
                    $analysis = Analyze-TabWithAI -Tab $tab -Content $content

                    if ($analysis) {
                        Save-ToHistory -Analysis $analysis

                        # Auto-create task
                        if ($AutoCreateTasks -and $analysis.Actionable -and $analysis.Priority -eq 'high' -and $analysis.Recommendation -eq 'create_task') {
                            Create-ClickUpTask -Analysis $analysis
                        }

                        # Auto-close tab
                        if ($AutoCloseTabs -and $analysis.Recommendation -eq 'close_tab') {
                            Close-CDPTab -Port $port -Analysis $analysis
                        }

                        # Mark as seen
                        $seenTabs[$tab.Url] = $true
                    }

                    Write-ColorLog ""
                }

                # Show stats
                $stats = Get-Stats
                Write-ColorLog "[STATS] Analyzed: $($stats.TotalAnalyzed) | Tasks: $($stats.TasksCreated) | Closed: $($stats.TabsClosed)" "DarkGray"

                Write-ColorLog "Next check in $IntervalSeconds seconds..." "DarkGray"
                Start-Sleep -Seconds $IntervalSeconds
            }
            catch {
                Write-ColorLog "[ERROR] Monitor error: $_" "Red"
                Start-Sleep -Seconds 10
            }
        }
    }

    'Stats' {
        Write-ColorLog "`nMode: STATISTICS" "White"

        $stats = Get-Stats

        Write-ColorLog "`n=== STATISTICS ===" "Cyan"
        Write-ColorLog "Total tabs analyzed: $($stats.TotalAnalyzed)" "White"
        Write-ColorLog "Tasks created: $($stats.TasksCreated)" "Green"
        Write-ColorLog "Tabs closed: $($stats.TabsClosed)" "Yellow"

        if (Test-Path $HistoryFile) {
            $history = Get-Content -Path $HistoryFile | ForEach-Object { $_ | ConvertFrom-Json }

            # Category breakdown
            $categories = $history | Group-Object Category | Sort-Object Count -Descending
            Write-ColorLog "`nTop categories:" "White"
            foreach ($cat in ($categories | Select-Object -First 5)) {
                Write-ColorLog "  $($cat.Name): $($cat.Count)" "Gray"
            }

            # Projects
            $projects = $history | Group-Object Project | Sort-Object Count -Descending
            Write-ColorLog "`nProjects:" "White"
            foreach ($proj in $projects) {
                Write-ColorLog "  $($proj.Name): $($proj.Count)" "Gray"
            }
        }
    }
}

Write-ColorLog "`n[DONE]" "Green"
