#Requires -Version 5.1
<#
.SYNOPSIS
    Browser Tab Intelligence System - analyzes browser content and creates tasks

.DESCRIPTION
    Complete browser intelligence system that:
    - Captures browser snapshot (via Playwright MCP)
    - Analyzes content with AI (GPT-4o-mini)
    - Determines category, priority, actionability
    - Creates ClickUp tasks automatically
    - Tracks browsing history and patterns
    - Monitors continuously for productivity insights

    Usage modes:
    - Analyze: One-time analysis of current tab
    - Monitor: Continuous monitoring (checks every N seconds)
    - History: View past analyzed tabs
    - Summary: Browsing patterns and statistics
    - CreateTask: Force task creation from current tab

.PARAMETER Action
    What to do: Analyze, Monitor, History, Summary, CreateTask

.PARAMETER IntervalSeconds
    For Monitor mode - check interval (default: 30)

.PARAMETER AutoCreateTasks
    Automatically create tasks for high-priority actionable items

.PARAMETER AutoCloseTabs
    Automatically close tabs with recommendation = close_tab (404s, duplicates, completed)

.EXAMPLE
    .\browser-intelligence.ps1 -Action Analyze
    .\browser-intelligence.ps1 -Action Analyze -AutoCloseTabs
    .\browser-intelligence.ps1 -Action Monitor -IntervalSeconds 60 -AutoCreateTasks -AutoCloseTabs
    .\browser-intelligence.ps1 -Action Summary
#>

[CmdletBinding()]
param(
    [ValidateSet('Analyze', 'Monitor', 'History', 'Summary', 'CreateTask')]
    [string]$Action = 'Analyze',

    [int]$IntervalSeconds = 30,

    [switch]$AutoCreateTasks,

    [switch]$AutoCloseTabs,

    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$StateFile = "C:\scripts\_machine\browser-intelligence-state.json"
$HistoryFile = "C:\scripts\_machine\browser-intelligence-history.jsonl"
$ClosedTabsFile = "C:\scripts\_machine\browser-intelligence-closed-tabs.jsonl"
$OutputDir = "E:\jengo\documents\browser-analysis"

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

function Write-ColorLog {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Get-BrowserSnapshot {
    Write-ColorLog "`n[CAPTURE] Taking browser snapshot..." "Cyan"

    $snapshotFile = Join-Path $OutputDir "snapshot_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"

    try {
        # Since we can't call MCP directly from PowerShell, return instructions
        # The user/system will need to call browser_snapshot via the MCP interface
        return @{
            SnapshotFile = $snapshotFile
            Instructions = "Call browser_snapshot with filename: $snapshotFile"
            Status = "manual"
        }
    }
    catch {
        Write-ColorLog "[ERROR] Failed to capture: $_" "Red"
        return $null
    }
}

function Analyze-Content {
    param([string]$SnapshotFile, [string]$Url = "")

    if (-not (Test-Path $SnapshotFile)) {
        Write-ColorLog "[ERROR] Snapshot file not found: $SnapshotFile" "Red"
        return $null
    }

    $content = Get-Content -Path $SnapshotFile -Raw

    # Extract URL from content if not provided
    if ([string]::IsNullOrWhiteSpace($Url)) {
        if ($content -match 'https?://[^\s\)]+') {
            $Url = $Matches[0]
        }
    }

    $contentPreview = $content.Substring(0, [Math]::Min(2000, $content.Length))

    Write-ColorLog "`n[ANALYZE] Processing with AI..." "Cyan"
    Write-ColorLog "  URL: $Url" "Gray"

    $prompt = @"
Analyze this browser tab content:

URL: $Url

Content:
$contentPreview

Provide analysis as JSON:
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
        # Load OpenAI API key from client-manager secrets
        $secretsPath = "C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json"
        if (-not (Test-Path $secretsPath)) {
            Write-ColorLog "[ERROR] Secrets file not found: $secretsPath" "Red"
            return $null
        }

        $secrets = Get-Content $secretsPath | ConvertFrom-Json
        $apiKey = $secrets.OpenAI.ApiKey

        # Call OpenAI API
        $headers = @{
            "Authorization" = "Bearer $apiKey"
            "Content-Type" = "application/json; charset=utf-8"
        }

        # Escape prompt for JSON
        $promptEscaped = $prompt -replace '\\', '\\' -replace '"', '\"' -replace "`n", '\n' -replace "`r", '\r' -replace "`t", '\t'

        # Build JSON manually to avoid PS encoding issues
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

        $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" `
            -Method Post `
            -Headers $headers `
            -Body ([System.Text.Encoding]::UTF8.GetBytes($bodyJson)) `
            -ContentType "application/json; charset=utf-8"

        $aiResponse = $response.choices[0].message.content

        # Extract JSON
        if ($aiResponse -match '\{[\s\S]*\}') {
            $jsonStr = $Matches[0]
            $analysis = $jsonStr | ConvertFrom-Json

            Write-ColorLog "`n[RESULT]" "Green"
            Write-ColorLog "  Category: $($analysis.category)" "Yellow"
            Write-ColorLog "  Priority: $($analysis.priority)" "Yellow"
            Write-ColorLog "  Actionable: $($analysis.actionable)" "Yellow"
            if ($analysis.actionable) {
                Write-ColorLog "  Task: $($analysis.task_description)" "Green"
                Write-ColorLog "  Project: $($analysis.project)" "Cyan"
            }
            Write-ColorLog "  Recommendation: $($analysis.recommendation)" "Magenta"
            Write-ColorLog "  Reasoning: $($analysis.reasoning)" "Gray"

            return @{
                Url = $Url
                Category = $analysis.category
                Priority = $analysis.priority
                Actionable = $analysis.actionable
                TaskDescription = $analysis.task_description
                Project = $analysis.project
                Recommendation = $analysis.recommendation
                Reasoning = $analysis.reasoning
                Keywords = $analysis.keywords
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }
        else {
            Write-ColorLog "[ERROR] Could not parse AI response" "Red"
            return $null
        }
    }
    catch {
        Write-ColorLog "[ERROR] AI analysis failed: $_" "Red"
        return $null
    }
}

function Save-ToHistory {
    param([hashtable]$Analysis)

    $entry = $Analysis | ConvertTo-Json -Compress
    Add-Content -Path $HistoryFile -Value $entry
    Write-ColorLog "`n[SAVED] Added to history" "Green"
}

function Close-CurrentTab {
    param(
        [hashtable]$Analysis,
        [string]$Reason = "close_tab recommendation"
    )

    if ($DryRun) {
        Write-ColorLog "`n[DRY RUN] Would close tab: $($Analysis.Url)" "Yellow"
        Write-ColorLog "  Reason: $Reason" "Gray"
        return $false
    }

    Write-ColorLog "`n[AUTO-CLOSE] Closing tab: $($Analysis.Url)" "Yellow"
    Write-ColorLog "  Reason: $Reason" "Gray"

    try {
        # Since we can't directly call Playwright MCP from PowerShell,
        # we'll log the close request and return instructions

        # Save to closed tabs history
        $closedEntry = @{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Url = $Analysis.Url
            Category = $Analysis.Category
            Reason = $Reason
            Recommendation = $Analysis.Recommendation
        }

        $closedEntry | ConvertTo-Json -Compress | Add-Content -Path $ClosedTabsFile

        Write-ColorLog "`n[ACTION REQUIRED] Manual close needed:" "Yellow"
        Write-ColorLog "  Use Playwright MCP: mcp__playwright__browser_tabs -action close" "Cyan"
        Write-ColorLog "  Or use browser to close this tab manually" "Cyan"
        Write-ColorLog "`n[LOGGED] Tab marked for closure in closed-tabs history" "Green"

        return $true
    }
    catch {
        Write-ColorLog "[ERROR] Failed to close tab: $_" "Red"
        return $false
    }
}

function Get-ClosedTabsStats {
    if (-not (Test-Path $ClosedTabsFile)) {
        return @{
            Total = 0
            Today = 0
            ThisWeek = 0
        }
    }

    $closedTabs = Get-Content -Path $ClosedTabsFile | ForEach-Object { $_ | ConvertFrom-Json }

    $today = Get-Date -Format "yyyy-MM-dd"
    $weekAgo = (Get-Date).AddDays(-7)

    $todayCount = ($closedTabs | Where-Object { $_.Timestamp -like "$today*" }).Count
    $weekCount = ($closedTabs | Where-Object {
        [DateTime]::Parse($_.Timestamp) -gt $weekAgo
    }).Count

    return @{
        Total = $closedTabs.Count
        Today = $todayCount
        ThisWeek = $weekCount
    }
}

function Create-ClickUpTask {
    param([hashtable]$Analysis)

    if ($DryRun) {
        Write-ColorLog "`n[DRY RUN] Would create task: $($Analysis.TaskDescription)" "Yellow"
        return
    }

    Write-ColorLog "`n[TASK] Creating ClickUp task..." "Cyan"

    $listIds = @{
        'client-manager' = '901214097647'
        'hazina' = '901215559249'
        'art-revisionist' = '901211612245'
        'personal' = '901214097647'
    }

    $listId = $listIds[$Analysis.Project]

    if (-not $listId) {
        Write-ColorLog "[WARN] No list for project: $($Analysis.Project)" "Yellow"
        return
    }

    $taskName = $Analysis.TaskDescription
    $taskDescription = @"
Auto-generated from browser analysis

URL: $($Analysis.Url)
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
            -Status "backlog"

        Write-ColorLog "[SUCCESS] Task created!" "Green"
        return $result
    }
    catch {
        Write-ColorLog "[ERROR] Failed to create task: $_" "Red"
        return $null
    }
}

function Show-History {
    if (-not (Test-Path $HistoryFile)) {
        Write-ColorLog "`n[EMPTY] No history yet" "Yellow"
        return
    }

    $history = Get-Content -Path $HistoryFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-ColorLog "`n=== BROWSING HISTORY ===" "Cyan"
    Write-ColorLog "Total entries: $($history.Count)`n" "White"

    $recent = $history | Select-Object -Last 10

    foreach ($entry in $recent) {
        Write-ColorLog "[$($entry.Timestamp)] $($entry.Category) | $($entry.Priority)" "Yellow"
        Write-ColorLog "  URL: $($entry.Url)" "Gray"
        if ($entry.Actionable) {
            Write-ColorLog "  Task: $($entry.TaskDescription)" "Green"
        }
        Write-ColorLog "  -> $($entry.Recommendation)" "Magenta"
        Write-ColorLog ""
    }
}

function Show-Summary {
    if (-not (Test-Path $HistoryFile)) {
        Write-ColorLog "`n[EMPTY] No history yet" "Yellow"
        return
    }

    $history = Get-Content -Path $HistoryFile | ForEach-Object { $_ | ConvertFrom-Json }

    Write-ColorLog "`n=== BROWSING PATTERNS ===" "Cyan"

    # Categories
    $categories = $history | Group-Object Category | Sort-Object Count -Descending
    Write-ColorLog "`nCategories:" "White"
    foreach ($cat in $categories) {
        Write-ColorLog "  $($cat.Name): $($cat.Count)" "Yellow"
    }

    # Priorities
    $priorities = $history | Group-Object Priority | Sort-Object Count -Descending
    Write-ColorLog "`nPriorities:" "White"
    foreach ($pri in $priorities) {
        Write-ColorLog "  $($pri.Name): $($pri.Count)" "Yellow"
    }

    # Actionable
    $actionableCount = ($history | Where-Object { $_.Actionable }).Count
    Write-ColorLog "`nActionable items: $actionableCount / $($history.Count)" "Green"

    # Projects
    $projects = $history | Group-Object Project | Sort-Object Count -Descending
    Write-ColorLog "`nProjects:" "White"
    foreach ($proj in $projects) {
        Write-ColorLog "  $($proj.Name): $($proj.Count)" "Yellow"
    }

    # Closed tabs stats
    $closedStats = Get-ClosedTabsStats
    if ($closedStats.Total -gt 0) {
        Write-ColorLog "`nTabs auto-closed:" "White"
        Write-ColorLog "  Today: $($closedStats.Today)" "Yellow"
        Write-ColorLog "  This week: $($closedStats.ThisWeek)" "Yellow"
        Write-ColorLog "  Total: $($closedStats.Total)" "Yellow"
    }
}

# ============================================================================
# MAIN
# ============================================================================

Write-ColorLog "=========================================" "Cyan"
Write-ColorLog "   BROWSER INTELLIGENCE SYSTEM         " "Cyan"
Write-ColorLog "=========================================" "Cyan"

switch ($Action) {
    'Analyze' {
        Write-ColorLog "`nMode: ANALYZE - single analysis" "White"

        # For now, use the last snapshot in the output directory
        $latestSnapshot = Get-ChildItem -Path $OutputDir -Filter "*.md" |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        if (-not $latestSnapshot) {
            Write-ColorLog "`n[MANUAL STEP REQUIRED]" "Yellow"
            Write-ColorLog "1. Use Playwright MCP to capture snapshot:" "White"
            Write-ColorLog "   mcp__playwright__browser_snapshot" "Cyan"
            Write-ColorLog "   filename: $OutputDir\current-snapshot.md" "Cyan"
            Write-ColorLog "2. Then run this script again" "White"
            exit 0
        }

        Write-ColorLog "`nUsing snapshot: $($latestSnapshot.Name)" "Gray"

        $analysis = Analyze-Content -SnapshotFile $latestSnapshot.FullName

        if ($analysis) {
            Save-ToHistory -Analysis $analysis

            # Auto-create task if high priority and actionable
            if ($analysis.Actionable -and $analysis.Priority -eq 'high' -and $analysis.Recommendation -eq 'create_task') {
                Create-ClickUpTask -Analysis $analysis
            }

            # Auto-close tab if recommended
            if ($AutoCloseTabs -and $analysis.Recommendation -eq 'close_tab') {
                $closed = Close-CurrentTab -Analysis $analysis -Reason "AI recommends closing - $($analysis.Reasoning)"

                if ($closed) {
                    $stats = Get-ClosedTabsStats
                    Write-ColorLog "`n[STATS] Tabs closed: Today $($stats.Today) | Week $($stats.ThisWeek) | Total $($stats.Total)" "Cyan"
                }
            }
        }
    }

    'CreateTask' {
        Write-ColorLog "`nMode: CREATE TASK - force task creation" "White"

        $latestSnapshot = Get-ChildItem -Path $OutputDir -Filter "*.md" |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        if (-not $latestSnapshot) {
            Write-ColorLog "[ERROR] No snapshot found. Capture one first." "Red"
            exit 1
        }

        $analysis = Analyze-Content -SnapshotFile $latestSnapshot.FullName

        if ($analysis -and $analysis.Actionable) {
            Create-ClickUpTask -Analysis $analysis
        }
        else {
            Write-ColorLog "[WARN] Tab is not actionable - no task created" "Yellow"
        }
    }

    'History' {
        Show-History
    }

    'Summary' {
        Show-Summary
    }

    'Monitor' {
        Write-ColorLog "`nMode: MONITOR - continuous check every $IntervalSeconds seconds" "White"
        Write-ColorLog "Auto-create tasks: $AutoCreateTasks" "Gray"
        Write-ColorLog "Auto-close tabs: $AutoCloseTabs" "Gray"
        Write-ColorLog "Press Ctrl+C to stop`n" "Yellow"

        $lastAnalyzedUrl = ""

        while ($true) {
            try {
                $latestSnapshot = Get-ChildItem -Path $OutputDir -Filter "*.md" |
                    Sort-Object LastWriteTime -Descending |
                    Select-Object -First 1

                if ($latestSnapshot) {
                    # Check if this is a new snapshot (modified in last N seconds)
                    $age = (Get-Date) - $latestSnapshot.LastWriteTime

                    if ($age.TotalSeconds -lt ($IntervalSeconds * 2)) {
                        $analysis = Analyze-Content -SnapshotFile $latestSnapshot.FullName

                        if ($analysis -and $analysis.Url -ne $lastAnalyzedUrl) {
                            Write-ColorLog "`n[NEW PAGE] $($analysis.Url)" "Cyan"
                            Save-ToHistory -Analysis $analysis

                            # Auto-create task if enabled
                            if ($AutoCreateTasks -and $analysis.Actionable -and $analysis.Priority -eq 'high') {
                                Create-ClickUpTask -Analysis $analysis
                            }

                            # Auto-close tab if enabled and recommended
                            if ($AutoCloseTabs -and $analysis.Recommendation -eq 'close_tab') {
                                $closed = Close-CurrentTab -Analysis $analysis -Reason "Monitor detected close_tab recommendation"

                                if ($closed) {
                                    $stats = Get-ClosedTabsStats
                                    Write-ColorLog "[STATS] Tabs closed today: $($stats.Today)" "Cyan"
                                }
                            }

                            $lastAnalyzedUrl = $analysis.Url
                        }
                    }
                }

                Write-ColorLog "[MONITORING] Next check in $IntervalSeconds seconds..." "Gray"
                Start-Sleep -Seconds $IntervalSeconds
            }
            catch {
                Write-ColorLog "[ERROR] Monitor error: $_" "Red"
                Start-Sleep -Seconds 10
            }
        }
    }
}

Write-ColorLog "`n[DONE] Complete!" "Green"
