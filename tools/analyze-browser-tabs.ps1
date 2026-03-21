#Requires -Version 5.1
<#
.SYNOPSIS
    Intelligent browser tab analyzer - scans all tabs, understands content, creates tasks

.DESCRIPTION
    Multi-stage browser intelligence system:
    1. Scan all browser windows/tabs
    2. Capture screenshots + extract text/URLs
    3. AI analysis: what's happening, what's the context
    4. Decision: create task, archive, ignore, close
    5. Execute action (ClickUp integration)

.PARAMETER Action
    Scan: Analyze all tabs and show summary
    CreateTasks: Scan and create ClickUp tasks for actionable items
    Monitor: Continuous monitoring mode (runs every N minutes)

.PARAMETER Browser
    Target browser: Chrome, Brave, Edge, Firefox, All (default: All)

.PARAMETER ProjectFilter
    Only create tasks for specific ClickUp project (client-manager, hazina, art-revisionist)

.PARAMETER DryRun
    Show what would be done without creating tasks

.EXAMPLE
    .\analyze-browser-tabs.ps1 -Action Scan
    .\analyze-browser-tabs.ps1 -Action CreateTasks -Browser Brave -ProjectFilter client-manager
    .\analyze-browser-tabs.ps1 -Action Monitor -IntervalMinutes 10
#>

[CmdletBinding()]
param(
    [ValidateSet('Scan', 'CreateTasks', 'Monitor', 'Cleanup')]
    [string]$Action = 'Scan',

    [ValidateSet('Chrome', 'Brave', 'Edge', 'Firefox', 'All')]
    [string]$Browser = 'All',

    [ValidateSet('client-manager', 'hazina', 'art-revisionist', 'all')]
    [string]$ProjectFilter = 'all',

    [int]$IntervalMinutes = 10,

    [switch]$DryRun,

    [switch]$Silent
)

$ErrorActionPreference = 'Stop'

# Paths
$StateFile = "C:\scripts\_machine\browser-analysis-state.json"
$OutputDir = "E:\jengo\documents\browser-analysis"
$UIBridgeUrl = "http://localhost:27184"

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    if (-not $Silent) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $color = switch ($Level) {
            "ERROR" { "Red" }
            "WARN" { "Yellow" }
            "SUCCESS" { "Green" }
            default { "White" }
        }
        Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
    }
}

function Get-BrowserWindows {
    param([string]$BrowserFilter)

    Write-Log "Scanning for browser windows..."

    try {
        $response = Invoke-RestMethod -Uri "$UIBridgeUrl/windows" -Method Get -ErrorAction Stop

        $browserPatterns = @{
            'Chrome' = 'Google Chrome'
            'Brave' = 'Brave'
            'Edge' = 'Microsoft Edge'
            'Firefox' = 'Firefox'
        }

        $windows = $response | Where-Object {
            $title = $_.title
            if ($BrowserFilter -eq 'All') {
                $browserPatterns.Values | Where-Object { $title -like "*$_*" }
            } else {
                $title -like "*$($browserPatterns[$BrowserFilter])*"
            }
        }

        Write-Log "Found $($windows.Count) browser windows"
        return $windows
    }
    catch {
        Write-Log "Failed to connect to UI Bridge. Is it running on $UIBridgeUrl?" "ERROR"
        Write-Log "Start with: C:\Projects\WindowsUIBridge\WindowsUIBridge\publish\WindowsUIBridge.exe" "WARN"
        throw
    }
}

function Capture-WindowContent {
    param([PSCustomObject]$Window)

    Write-Log "Capturing content for: $($Window.title)"

    try {
        # Get window details (UI tree)
        $details = Invoke-RestMethod -Uri "$UIBridgeUrl/window/$($Window.id)" -Method Get

        # Capture screenshot
        $screenshot = Invoke-RestMethod -Uri "$UIBridgeUrl/window/$($Window.id)/screenshot" -Method Get

        # Extract text from UI elements
        $textElements = $details.elements | Where-Object {
            $_.type -eq 'Text' -or $_.type -eq 'Edit' -or $_.type -eq 'Document'
        }

        $extractedText = ($textElements | ForEach-Object { $_.name }) -join " "

        return @{
            WindowId = $Window.id
            Title = $Window.title
            Screenshot = $screenshot.path
            ExtractedText = $extractedText
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            ProcessId = $Window.processId
        }
    }
    catch {
        Write-Log "Failed to capture window $($Window.id): $_" "ERROR"
        return $null
    }
}

function Analyze-WithAI {
    param(
        [PSCustomObject]$WindowData,
        [string]$AnalysisType = 'Quick' # Quick, Deep
    )

    Write-Log "AI analyzing: $($WindowData.Title)"

    # Use ai-vision.ps1 to analyze screenshot
    $prompt = @"
Analyze this browser tab and determine:
1. CATEGORY: What type of content is this? (research, documentation, tutorial, entertainment, work, shopping, social, news, email, task management)
2. CONTEXT: What is the user likely doing? (learning, working on project, researching, planning, procrastinating, reading news)
3. PRIORITY: How important/urgent is this? (high, medium, low, entertainment)
4. ACTIONABLE: Is there a task here? (yes/no)
5. TASK_DESCRIPTION: If actionable, what's the task? (1 sentence)
6. PROJECT: Which project might this relate to? (client-manager, hazina, art-revisionist, personal, none)
7. RECOMMENDATION: What should be done? (create_task, bookmark, archive, close_tab, keep_open)

Title: $($WindowData.Title)
Extracted text: $($WindowData.ExtractedText.Substring(0, [Math]::Min(500, $WindowData.ExtractedText.Length)))

Return JSON format:
{
  "category": "...",
  "context": "...",
  "priority": "...",
  "actionable": true/false,
  "task_description": "...",
  "project": "...",
  "recommendation": "..."
}
"@

    try {
        # Validate image first
        $validateResult = & "C:\scripts\tools\validate-image-for-claude.ps1" -ImagePath $WindowData.Screenshot

        if ($validateResult -ne 0) {
            Write-Log "Screenshot invalid, optimizing..." "WARN"
            & "C:\scripts\tools\optimize-image-for-claude.ps1" -ImagePath $WindowData.Screenshot
        }

        # Analyze with AI
        $result = & "C:\scripts\tools\ai-vision.ps1" -ImagePath $WindowData.Screenshot -Prompt $prompt

        # Parse JSON response
        $jsonMatch = $result -match '\{[\s\S]*\}'
        if ($jsonMatch) {
            $json = $Matches[0]
            $analysis = $json | ConvertFrom-Json

            Write-Log "Analysis complete: $($analysis.category), $($analysis.recommendation)" "SUCCESS"

            return @{
                Category = $analysis.category
                Context = $analysis.context
                Priority = $analysis.priority
                Actionable = $analysis.actionable
                TaskDescription = $analysis.task_description
                Project = $analysis.project
                Recommendation = $analysis.recommendation
                RawResponse = $result
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

function Create-ClickUpTask {
    param(
        [PSCustomObject]$Analysis,
        [PSCustomObject]$WindowData
    )

    if ($DryRun) {
        Write-Log "[DRY RUN] Would create task: $($Analysis.TaskDescription)" "WARN"
        return $null
    }

    Write-Log "Creating ClickUp task for: $($Analysis.TaskDescription)"

    # Map project name to list ID
    $listIds = @{
        'client-manager' = '901214097647'
        'hazina' = '901215559249'
        'art-revisionist' = '901211612245'
    }

    $listId = $listIds[$Analysis.Project]

    if (-not $listId) {
        Write-Log "No ClickUp list for project: $($Analysis.Project)" "WARN"
        return $null
    }

    # Create task via clickup-task-operations-v3.ps1
    $taskName = $Analysis.TaskDescription
    $taskDescription = @"
Auto-generated from browser analysis

Browser Tab: $($WindowData.Title)
URL/Context: $($WindowData.ExtractedText.Substring(0, [Math]::Min(200, $WindowData.ExtractedText.Length)))
Category: $($Analysis.Category)
Priority: $($Analysis.Priority)
Analyzed: $($WindowData.Timestamp)
Screenshot: $($WindowData.Screenshot)
"@

    try {
        $result = & "C:\scripts\tools\clickup-task-operations-v3.ps1" `
            -Action Create `
            -Project $Analysis.Project `
            -Name $taskName `
            -Description $taskDescription `
            -Status "backlog"

        Write-Log "Task created successfully: $taskName" "SUCCESS"
        return $result
    }
    catch {
        Write-Log "Failed to create task: $_" "ERROR"
        return $null
    }
}

function Save-State {
    param([array]$ProcessedWindows)

    $state = @{
        LastRun = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ProcessedWindows = $ProcessedWindows
        TotalProcessed = $ProcessedWindows.Count
        TasksCreated = ($ProcessedWindows | Where-Object { $_.TaskCreated }).Count
    }

    $state | ConvertTo-Json -Depth 10 | Set-Content -Path $StateFile
    Write-Log "State saved to $StateFile"
}

function Load-State {
    if (Test-Path $StateFile) {
        return Get-Content -Path $StateFile | ConvertFrom-Json
    }
    return $null
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

Write-Log "=== Browser Tab Analyzer ===" "SUCCESS"
Write-Log "Action: $Action | Browser: $Browser | Project Filter: $ProjectFilter"

switch ($Action) {
    'Scan' {
        $windows = Get-BrowserWindows -BrowserFilter $Browser

        if ($windows.Count -eq 0) {
            Write-Log "No browser windows found" "WARN"
            exit 0
        }

        $results = @()

        foreach ($window in $windows) {
            $content = Capture-WindowContent -Window $window
            if ($content) {
                $analysis = Analyze-WithAI -WindowData $content

                $results += @{
                    Window = $window
                    Content = $content
                    Analysis = $analysis
                }
            }
        }

        # Display summary
        Write-Host "`n=== SCAN RESULTS ===" -ForegroundColor Cyan
        foreach ($result in $results) {
            Write-Host "`nTitle: $($result.Content.Title)" -ForegroundColor Yellow
            Write-Host "Category: $($result.Analysis.Category)"
            Write-Host "Priority: $($result.Analysis.Priority)"
            Write-Host "Actionable: $($result.Analysis.Actionable)"
            if ($result.Analysis.Actionable) {
                Write-Host "Task: $($result.Analysis.TaskDescription)" -ForegroundColor Green
                Write-Host "Project: $($result.Analysis.Project)"
            }
            Write-Host "Recommendation: $($result.Analysis.Recommendation)" -ForegroundColor Magenta
        }

        Save-State -ProcessedWindows $results
    }

    'CreateTasks' {
        $windows = Get-BrowserWindows -BrowserFilter $Browser

        if ($windows.Count -eq 0) {
            Write-Log "No browser windows found" "WARN"
            exit 0
        }

        $results = @()
        $tasksCreated = 0

        foreach ($window in $windows) {
            $content = Capture-WindowContent -Window $window
            if (-not $content) { continue }

            $analysis = Analyze-WithAI -WindowData $content
            if (-not $analysis) { continue }

            # Filter by project if specified
            if ($ProjectFilter -ne 'all' -and $analysis.Project -ne $ProjectFilter) {
                Write-Log "Skipping (project mismatch): $($content.Title)" "WARN"
                continue
            }

            # Create task if actionable
            if ($analysis.Actionable -and $analysis.Recommendation -eq 'create_task') {
                $task = Create-ClickUpTask -Analysis $analysis -WindowData $content
                if ($task) {
                    $tasksCreated++
                }
            }

            $results += @{
                Window = $window
                Content = $content
                Analysis = $analysis
                TaskCreated = $null -ne $task
            }
        }

        Write-Log "=== SUMMARY ===" "SUCCESS"
        Write-Log "Windows analyzed: $($results.Count)"
        Write-Log "Tasks created: $tasksCreated"

        Save-State -ProcessedWindows $results
    }

    'Monitor' {
        Write-Log "Starting continuous monitoring (every $IntervalMinutes minutes)" "SUCCESS"
        Write-Log "Press Ctrl+C to stop"

        while ($true) {
            try {
                & $PSCommandPath -Action CreateTasks -Browser $Browser -ProjectFilter $ProjectFilter -Silent:$Silent
                Write-Log "Next scan in $IntervalMinutes minutes..."
                Start-Sleep -Seconds ($IntervalMinutes * 60)
            }
            catch {
                Write-Log "Monitor error: $_" "ERROR"
                Start-Sleep -Seconds 60
            }
        }
    }

    'Cleanup' {
        Write-Log "Cleaning up old screenshots and state..."

        # Delete screenshots older than 7 days
        Get-ChildItem -Path $OutputDir -Filter "*.png" |
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
            Remove-Item -Force

        Write-Log "Cleanup complete" "SUCCESS"
    }
}

Write-Log "=== DONE ===" "SUCCESS"
