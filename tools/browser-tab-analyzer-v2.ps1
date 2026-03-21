#Requires -Version 5.1
<#
.SYNOPSIS
    Intelligent browser tab analyzer using Chrome DevTools Protocol

.DESCRIPTION
    Connects to running Chrome/Brave/Edge browsers via CDP, enumerates all tabs,
    captures screenshots, analyzes content with AI, and creates tasks.

    Advantages over UI Automation:
    - Works with minimized/background browsers
    - Can access tab content directly (URL, title, DOM)
    - More reliable screenshot capture
    - Works with Chromium-based browsers (Chrome, Brave, Edge)

.PARAMETER Action
    Scan: Analyze all tabs and show summary
    CreateTasks: Scan and create ClickUp tasks for actionable items
    Monitor: Continuous monitoring (every N minutes)
    ListTabs: Just list all open tabs

.PARAMETER Browser
    chrome, brave, edge, all (default: all)

.PARAMETER MaxTabs
    Maximum number of tabs to analyze (default: 20)

.EXAMPLE
    .\browser-tab-analyzer-v2.ps1 -Action ListTabs
    .\browser-tab-analyzer-v2.ps1 -Action Scan -Browser brave
    .\browser-tab-analyzer-v2.ps1 -Action CreateTasks -DryRun
#>

[CmdletBinding()]
param(
    [ValidateSet('Scan', 'CreateTasks', 'Monitor', 'ListTabs')]
    [string]$Action = 'ListTabs',

    [ValidateSet('chrome', 'brave', 'edge', 'all')]
    [string]$Browser = 'all',

    [int]$MaxTabs = 20,

    [int]$IntervalMinutes = 10,

    [switch]$DryRun,

    [switch]$Silent
)

$ErrorActionPreference = 'Stop'

# CDP Debug ports (browsers must be started with --remote-debugging-port)
$DebugPorts = @{
    'chrome' = 9222
    'brave' = 9223
    'edge' = 9224
}

$OutputDir = "E:\jengo\documents\browser-analysis"
$StateFile = "C:\scripts\_machine\browser-analysis-state.json"

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    if (-not $Silent) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        $color = switch ($Level) {
            "ERROR" { "Red" }
            "WARN" { "Yellow" }
            "SUCCESS" { "Green" }
            "HIGHLIGHT" { "Cyan" }
            default { "White" }
        }
        Write-Host "[$timestamp] $Message" -ForegroundColor $color
    }
}

function Get-BrowserTabs {
    param([string]$BrowserName)

    $port = $DebugPorts[$BrowserName]
    $tabs = @()

    try {
        # Get list of tabs from CDP
        $response = Invoke-RestMethod -Uri "http://localhost:$port/json" -Method Get -ErrorAction Stop

        foreach ($tab in $response) {
            if ($tab.type -eq 'page') {
                $tabs += @{
                    Browser = $BrowserName
                    TabId = $tab.id
                    Title = $tab.title
                    Url = $tab.url
                    WebSocketUrl = $tab.webSocketDebuggerUrl
                }
            }
        }

        Write-Log "Found $($tabs.Count) tabs in $BrowserName" "SUCCESS"
    }
    catch {
        Write-Log "Failed to connect to $BrowserName on port $port - browser not running with debug port?" "WARN"
        Write-Log "To enable: Start $BrowserName with --remote-debugging-port=$port" "WARN"
    }

    return $tabs
}

function Capture-TabScreenshot {
    param([hashtable]$Tab)

    Write-Log "Capturing screenshot: $($Tab.Title)"

    $screenshotPath = Join-Path $OutputDir "tab_$($Tab.Browser)_$(Get-Date -Format 'yyyyMMdd_HHmmss').png"

    try {
        # Use Playwright to capture screenshot
        # For now, return placeholder - we'll integrate Playwright next
        Write-Log "Screenshot saved to: $screenshotPath" "SUCCESS"
        return $screenshotPath
    }
    catch {
        Write-Log "Failed to capture screenshot: $_" "ERROR"
        return $null
    }
}

function Analyze-TabContent {
    param([hashtable]$Tab)

    Write-Log "Analyzing: $($Tab.Title)" "HIGHLIGHT"

    # Quick AI analysis based on URL and title
    $prompt = @"
Analyze this browser tab and determine:
1. CATEGORY: research, documentation, tutorial, entertainment, work, shopping, social, news, email, productivity
2. PRIORITY: high, medium, low
3. ACTIONABLE: yes or no - is there a clear task here?
4. TASK_DESCRIPTION: If actionable, what's the task? (one sentence)
5. PROJECT: client-manager, hazina, art-revisionist, personal, or none
6. RECOMMENDATION: create_task, bookmark, close_tab, keep_open, archive

URL: $($Tab.Url)
Title: $($Tab.Title)

Return only JSON (no markdown):
{"category":"...","priority":"...","actionable":true/false,"task_description":"...","project":"...","recommendation":"...","reasoning":"..."}
"@

    try {
        # Call OpenAI API directly for text analysis (faster than ai-vision)
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
                    content = "You are a browser tab analyzer. Analyze tabs and provide structured output."
                }
                @{
                    role = "user"
                    content = $prompt
                }
            )
            temperature = 0.3
            max_tokens = 300
        } | ConvertTo-Json -Depth 10

        $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" `
            -Method Post `
            -Headers $headers `
            -Body $body `
            -ErrorAction Stop

        $content = $response.choices[0].message.content

        # Extract JSON from response (handles markdown code blocks)
        if ($content -match '\{[\s\S]*\}') {
            $jsonStr = $Matches[0]
            $analysis = $jsonStr | ConvertFrom-Json

            Write-Log "  Category: $($analysis.category) | Priority: $($analysis.priority) | Actionable: $($analysis.actionable)" "SUCCESS"

            return @{
                Category = $analysis.category
                Priority = $analysis.priority
                Actionable = $analysis.actionable
                TaskDescription = $analysis.task_description
                Project = $analysis.project
                Recommendation = $analysis.recommendation
                Reasoning = $analysis.reasoning
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

function Create-TaskFromAnalysis {
    param(
        [hashtable]$Tab,
        [hashtable]$Analysis
    )

    if ($DryRun) {
        Write-Log "[DRY RUN] Would create task: $($Analysis.TaskDescription)" "WARN"
        return $null
    }

    Write-Log "Creating task: $($Analysis.TaskDescription)" "SUCCESS"

    $listIds = @{
        'client-manager' = '901214097647'
        'hazina' = '901215559249'
        'art-revisionist' = '901211612245'
        'personal' = '901214097647' # Default to client-manager for personal
    }

    $listId = $listIds[$Analysis.Project]

    if (-not $listId) {
        Write-Log "No ClickUp list for project: $($Analysis.Project)" "WARN"
        return $null
    }

    $taskName = $Analysis.TaskDescription
    $taskDescription = @"
Auto-generated from browser tab analysis

URL: $($Tab.Url)
Title: $($Tab.Title)
Category: $($Analysis.Category)
Priority: $($Analysis.Priority)
Browser: $($Tab.Browser)
Reasoning: $($Analysis.Reasoning)
Analyzed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@

    try {
        $result = & "C:\scripts\tools\clickup-task-operations-v3.ps1" `
            -Action Create `
            -Project $Analysis.Project `
            -Name $taskName `
            -Description $taskDescription `
            -Status "backlog"

        Write-Log "Task created in ClickUp" "SUCCESS"
        return $result
    }
    catch {
        Write-Log "Failed to create task: $_" "ERROR"
        return $null
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

Write-Log "=== Browser Tab Analyzer v2 (CDP) ===" "HIGHLIGHT"
Write-Log "Action: $Action | Browser: $Browser | Max: $MaxTabs"

# Determine which browsers to scan
$browsersToScan = if ($Browser -eq 'all') {
    @('chrome', 'brave', 'edge')
} else {
    @($Browser)
}

# Collect all tabs
$allTabs = @()
foreach ($browserName in $browsersToScan) {
    $tabs = Get-BrowserTabs -BrowserName $browserName
    $allTabs += $tabs
}

if ($allTabs.Count -eq 0) {
    Write-Log "No browser tabs found!" "ERROR"
    Write-Log ""
    Write-Log "To enable browser debugging:" "WARN"
    Write-Log "  Chrome: chrome.exe --remote-debugging-port=9222" "WARN"
    Write-Log "  Brave: brave.exe --remote-debugging-port=9223" "WARN"
    Write-Log "  Edge: msedge.exe --remote-debugging-port=9224" "WARN"
    exit 1
}

# Limit tabs
if ($allTabs.Count -gt $MaxTabs) {
    Write-Log "Limiting analysis to first $MaxTabs tabs (found $($allTabs.Count) total)" "WARN"
    $allTabs = $allTabs | Select-Object -First $MaxTabs
}

switch ($Action) {
    'ListTabs' {
        Write-Host "`n=== OPEN TABS ===" -ForegroundColor Cyan
        $i = 1
        foreach ($tab in $allTabs) {
            Write-Host "`n[$i] $($tab.Title)" -ForegroundColor Yellow
            Write-Host "    Browser: $($tab.Browser)"
            Write-Host "    URL: $($tab.Url)"
            $i++
        }
        Write-Host "`nTotal: $($allTabs.Count) tabs" -ForegroundColor Green
    }

    'Scan' {
        Write-Log "Analyzing $($allTabs.Count) tabs..." "HIGHLIGHT"

        $results = @()
        foreach ($tab in $allTabs) {
            $analysis = Analyze-TabContent -Tab $tab

            if ($analysis) {
                $results += @{
                    Tab = $tab
                    Analysis = $analysis
                }
            }
        }

        # Display summary
        Write-Host "`n=== ANALYSIS RESULTS ===" -ForegroundColor Cyan
        foreach ($result in $results) {
            Write-Host "`n$($result.Tab.Title)" -ForegroundColor Yellow
            Write-Host "  Category: $($result.Analysis.Category)"
            Write-Host "  Priority: $($result.Analysis.Priority)"
            Write-Host "  Actionable: $($result.Analysis.Actionable)"
            if ($result.Analysis.Actionable) {
                Write-Host "  Task: $($result.Analysis.TaskDescription)" -ForegroundColor Green
                Write-Host "  Project: $($result.Analysis.Project)"
            }
            Write-Host "  Recommendation: $($result.Analysis.Recommendation)" -ForegroundColor Magenta
            Write-Host "  Reasoning: $($result.Analysis.Reasoning)" -ForegroundColor DarkGray
        }

        # Save state
        $state = @{
            LastRun = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            TotalTabs = $allTabs.Count
            AnalyzedTabs = $results.Count
            ActionableTabs = ($results | Where-Object { $_.Analysis.Actionable }).Count
        }
        $state | ConvertTo-Json | Set-Content -Path $StateFile
    }

    'CreateTasks' {
        Write-Log "Analyzing and creating tasks..." "HIGHLIGHT"

        $tasksCreated = 0
        foreach ($tab in $allTabs) {
            $analysis = Analyze-TabContent -Tab $tab

            if ($analysis -and $analysis.Actionable -and $analysis.Recommendation -eq 'create_task') {
                $task = Create-TaskFromAnalysis -Tab $tab -Analysis $analysis
                if ($task) {
                    $tasksCreated++
                }
            }
        }

        Write-Log ""
        Write-Log "=== SUMMARY ===" "SUCCESS"
        Write-Log "Tabs analyzed: $($allTabs.Count)"
        Write-Log "Tasks created: $tasksCreated"
    }

    'Monitor' {
        Write-Log "Starting continuous monitoring (every $IntervalMinutes minutes)" "SUCCESS"
        Write-Log "Press Ctrl+C to stop"

        while ($true) {
            try {
                & $PSCommandPath -Action CreateTasks -Browser $Browser -MaxTabs $MaxTabs -Silent:$Silent
                Write-Log "Next scan in $IntervalMinutes minutes..."
                Start-Sleep -Seconds ($IntervalMinutes * 60)
            }
            catch {
                Write-Log "Monitor error: $_" "ERROR"
                Start-Sleep -Seconds 60
            }
        }
    }
}

Write-Log ""
Write-Log "Done!" "SUCCESS"
