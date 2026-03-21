#!/usr/bin/env pwsh
<#
.SYNOPSIS
    ClickUp Refinement Agent - Refines backlog tasks with human-readable titles and structured descriptions
.DESCRIPTION
    Processes tasks from backlog, analyzes clarity, adds human-readable titles,
    structured descriptions, priorities, and tags. Moves tasks to 'refined' status.

    🚨 DEFAULT BEHAVIOR: Tasks are automatically moved to "refined" status.
    This is MANDATORY workflow compliance. Do NOT override without explicit reason.

    Refinement Process:
    1. Fetch backlog tasks (unrefined status)
    2. Analyze each task for clarity
    3. Generate human-readable title
    4. Create structured description (human summary + technical details)
    5. Assign priority based on content analysis
    6. Add relevant tags
    7. 🚨 MOVE to 'refined' status (DEFAULT - MANDATORY workflow)

.PARAMETER ListId
    The ClickUp list ID to process (e.g., "901215927087" for SEO God)
.PARAMETER Project
    The project name (e.g., "seo-god", "art-revisionist")
.PARAMETER Status
    Status to fetch tasks from (default: "backlog")
.PARAMETER TargetStatus
    Target status to move refined tasks to (default: "refined")
    🚨 DEFAULT "refined" - MANDATORY workflow compliance
.PARAMETER MaxTasks
    Maximum number of tasks to process in one run (default: 10)
.PARAMETER DryRun
    If true, shows what would be done without making changes
.PARAMETER Verbose
    Enable verbose logging
.EXAMPLE
    # Standard refinement (automatically moves to "refined" status)
    .\clickup-refinement-agent.ps1 -Project "seo-god"

    # Custom max tasks
    .\clickup-refinement-agent.ps1 -ListId "901215927087" -MaxTasks 50

    # Dry-run preview
    .\clickup-refinement-agent.ps1 -Project "art-revisionist" -DryRun

    # Explicit target status (normally not needed - "refined" is default)
    .\clickup-refinement-agent.ps1 -Project "seo-god" -TargetStatus "refined"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ListId,

    [Parameter(Mandatory=$false)]
    [string]$Project,

    [Parameter(Mandatory=$false)]
    [string]$Status = "backlog",

    [Parameter(Mandatory=$false)]
    [string]$TargetStatus = "refined",  # DEFAULT: Always move to "refined" status after refinement

    [Parameter(Mandatory=$false)]
    [int]$MaxTasks = 10,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [switch]$VerboseLogging
)

$ErrorActionPreference = "Stop"

# Config paths
$ConfigPath = "C:\scripts\_machine\clickup-config.json"
$RefinementLogPath = "C:\scripts\_machine\clickup-refinement.log.jsonl"

# Load configuration
if (-not (Test-Path $ConfigPath)) {
    throw "ClickUp config not found at $ConfigPath"
}

$Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$ApiKey = $Config.api_key
$ApiBase = $Config.api_base

# Resolve List ID from project if provided
if ($Project -and -not $ListId) {
    if ($Config.projects.$Project) {
        $ListId = $Config.projects.$Project.list_id
        Write-Host "Resolved project '$Project' to list ID: $ListId" -ForegroundColor Cyan
    } else {
        throw "Unknown project: $Project. Available: $($Config.projects.PSObject.Properties.Name -join ', ')"
    }
}

if (-not $ListId) {
    throw "Either -ListId or -Project must be provided"
}

$Headers = @{
    "Authorization" = $ApiKey
    "Content-Type" = "application/json"
}

# Helper functions
function Write-VerboseLog {
    param([string]$Message)
    if ($VerboseLogging) {
        Write-Host "[VERBOSE] $Message" -ForegroundColor DarkGray
    }
}

function Write-RefinementLog {
    param(
        [string]$TaskId,
        [string]$Action,
        [hashtable]$Changes
    )

    if ($DryRun) { return }

    $LogEntry = @{
        timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        task_id = $TaskId
        action = $Action
        changes = $Changes
    } | ConvertTo-Json -Compress

    Add-Content -Path $RefinementLogPath -Value $LogEntry -Encoding UTF8
}

function Invoke-ClickUpAPI {
    param(
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null
    )

    $Uri = "$ApiBase$Endpoint"
    Write-VerboseLog "API $Method $Uri"

    if ($DryRun -and $Method -ne "GET") {
        Write-Host "[DRY-RUN] Would call: $Method $Uri" -ForegroundColor Magenta
        if ($Body) {
            Write-Host "[DRY-RUN] Body: $($Body | ConvertTo-Json -Compress)" -ForegroundColor Magenta
        }
        return @{ dry_run = $true }
    }

    try {
        if ($Body) {
            # Ensure proper encoding for PowerShell 5.1
            # Clean up any special characters that could break JSON
            if ($Body.description) {
                $Body.description = $Body.description -replace '[^\x20-\x7E\r\n]', ''
            }
            if ($Body.name) {
                $Body.name = $Body.name -replace '[^\x20-\x7E ]', ''
            }

            $JsonBody = $Body | ConvertTo-Json -Depth 10 -Compress
            # Extra validation - ensure valid JSON
            $null = $JsonBody | ConvertFrom-Json

            $Response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body $JsonBody
        } else {
            $Response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers
        }
        return $Response
    } catch {
        Write-Host "API call failed: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.ErrorDetails) {
            Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        throw
    }
}

# AI-powered task analysis
function Get-TaskRefinementSuggestions {
    param(
        [string]$Name,
        [string]$Description
    )

    Write-VerboseLog "Analyzing task: $Name"

    # Generate human-readable title
    $HumanTitle = $Name
    $Priority = "normal"
    $Tags = @()
    $HumanSummary = ""

    # Pattern detection for title improvement
    if ($Name -match "^[A-Z]{2,}-\d+:?\s*(.+)") {
        # Jira-style: "ABC-123: Do something" -> "Do something"
        $HumanTitle = $matches[1].Trim()
    } elseif ($Name -match "^\[.+\]\s*(.+)") {
        # Bracketed prefix: "[TAG] Do something" -> "Do something"
        $HumanTitle = $matches[1].Trim()
    }

    # Capitalize first letter
    $HumanTitle = $HumanTitle.Substring(0,1).ToUpper() + $HumanTitle.Substring(1)

    # Priority detection from keywords
    if ($Name -match "\b(urgent|critical|asap|blocker|hotfix)\b" -or
        $Description -match "\b(urgent|critical|asap|blocker|hotfix)\b") {
        $Priority = "urgent"
    } elseif ($Name -match "\b(important|high|priority)\b" -or
              $Description -match "\b(important|high|priority)\b") {
        $Priority = "high"
    } elseif ($Name -match "\b(nice to have|optional|future)\b" -or
              $Description -match "\b(nice to have|optional|future)\b") {
        $Priority = "low"
    }

    # Tag detection
    if ($Name -match "\b(bug|fix|error|issue)\b" -or
        $Description -match "\b(bug|fix|error|issue)\b") {
        $Tags += "bug"
    }
    if ($Name -match "\b(feature|enhancement|new)\b" -or
        $Description -match "\b(feature|enhancement|new)\b") {
        $Tags += "feature"
    }
    if ($Name -match "\b(refactor|cleanup|improve)\b" -or
        $Description -match "\b(refactor|cleanup|improve)\b") {
        $Tags += "refactor"
    }
    if ($Name -match "\b(test|testing|qa)\b" -or
        $Description -match "\b(test|testing|qa)\b") {
        $Tags += "testing"
    }
    if ($Name -match "\b(doc|documentation)\b" -or
        $Description -match "\b(doc|documentation)\b") {
        $Tags += "documentation"
    }
    if ($Name -match "\b(seo|optimization|performance)\b" -or
        $Description -match "\b(seo|optimization|performance)\b") {
        $Tags += "seo"
    }
    if ($Name -match "\b(ui|ux|design)\b" -or
        $Description -match "\b(ui|ux|design)\b") {
        $Tags += "ui/ux"
    }
    if ($Name -match "\b(api|integration|backend)\b" -or
        $Description -match "\b(api|integration|backend)\b") {
        $Tags += "backend"
    }

    # Generate human summary from description
    if ($Description.Length -gt 0) {
        # Extract first meaningful sentence or paragraph
        $FirstParagraph = ($Description -split "`n`n")[0]
        $FirstSentence = ($FirstParagraph -split "\. ")[0]

        if ($FirstSentence.Length -lt 200) {
            $HumanSummary = $FirstSentence.Trim()
        } else {
            # Truncate intelligently
            $Words = $FirstSentence -split " "
            $Summary = ""
            foreach ($Word in $Words) {
                if (($Summary + " " + $Word).Length -gt 150) { break }
                $Summary += " " + $Word
            }
            $HumanSummary = $Summary.Trim() + "..."
        }
    } else {
        # Generate from title
        $HumanSummary = "This task involves: $HumanTitle"
    }

    return @{
        human_title = $HumanTitle
        human_summary = $HumanSummary
        priority = $Priority
        tags = $Tags
    }
}

function Format-RefinedDescription {
    param(
        [string]$HumanSummary,
        [string]$OriginalDescription
    )

    # Build structured description using plain text (ClickUp doesn't support markup)
    $Parts = @()

    # Human-readable summary at the top
    $Parts += "SUMMARY"
    $Parts += $HumanSummary
    $Parts += ""

    # Keep technical details if they exist
    if ($OriginalDescription.Length -gt 0) {
        $Parts += "TECHNICAL DETAILS"
        $Parts += $OriginalDescription
        $Parts += ""
    }

    # Add refinement metadata
    $Parts += "---"
    $Parts += "Refined by ClickUp Refinement Agent on $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

    return $Parts -join "`n"
}

# Main refinement process
function Start-TaskRefinement {
    Write-Host "`n=== ClickUp Refinement Agent ===" -ForegroundColor Cyan
    Write-Host "List ID: $ListId" -ForegroundColor White
    Write-Host "Status: $Status" -ForegroundColor White
    Write-Host "Max Tasks: $MaxTasks" -ForegroundColor White
    Write-Host ""

    # Fetch tasks in specified status
    $QueryParams = @(
        "archived=false",
        "subtasks=false",
        "statuses[]=$Status"
    )
    $Endpoint = "/list/$ListId/task?$($QueryParams -join '&')"

    Write-Host "Fetching tasks..." -ForegroundColor Yellow
    $Response = Invoke-ClickUpAPI -Method "GET" -Endpoint $Endpoint

    $Tasks = $Response.tasks | Select-Object -First $MaxTasks

    if ($Tasks.Count -eq 0) {
        Write-Host "No tasks found in '$Status' status" -ForegroundColor Yellow
        return
    }

    Write-Host "Found $($Tasks.Count) task(s) to refine`n" -ForegroundColor Green

    $ProcessedCount = 0
    $SkippedCount = 0
    $ErrorCount = 0

    foreach ($Task in $Tasks) {
        Write-Host "[$($ProcessedCount + $SkippedCount + $ErrorCount + 1)/$($Tasks.Count)] Processing: $($Task.name)" -ForegroundColor Cyan
        Write-Host "  ID: $($Task.id)" -ForegroundColor Gray

        try {
            # Get refinement suggestions
            $Suggestions = Get-TaskRefinementSuggestions -Name $Task.name -Description $Task.description

            # Build refined description
            $RefinedDescription = Format-RefinedDescription `
                -HumanSummary $Suggestions.human_summary `
                -OriginalDescription $Task.description

            # Show changes
            if ($Task.name -ne $Suggestions.human_title) {
                Write-Host "  Title: $($Task.name) -> $($Suggestions.human_title)" -ForegroundColor Yellow
            }
            Write-Host "  Priority: $($Suggestions.priority)" -ForegroundColor Yellow
            if ($Suggestions.tags.Count -gt 0) {
                Write-Host "  Tags: $($Suggestions.tags -join ', ')" -ForegroundColor Yellow
            }

            # Update task
            $UpdateBody = @{
                name = $Suggestions.human_title
                description = $RefinedDescription
                priority = switch ($Suggestions.priority) {
                    "urgent" { 1 }
                    "high" { 2 }
                    "normal" { 3 }
                    "low" { 4 }
                    default { 3 }
                }
            }

            # Only change status if TargetStatus is specified
            if ($TargetStatus) {
                $UpdateBody.status = $TargetStatus
            }

            if (-not $DryRun) {
                $null = Invoke-ClickUpAPI -Method "PUT" -Endpoint "/task/$($Task.id)" -Body $UpdateBody

                # Add tags if any
                if ($Suggestions.tags.Count -gt 0) {
                    # Note: ClickUp tag addition requires tag names that exist in the space
                    # For now, we'll skip tag addition and just log them
                    Write-VerboseLog "Tags suggested: $($Suggestions.tags -join ', ')"
                }

                Write-RefinementLog -TaskId $Task.id -Action "refined" -Changes @{
                    original_name = $Task.name
                    new_name = $Suggestions.human_title
                    priority = $Suggestions.priority
                    tags = $Suggestions.tags
                }
            }

            Write-Host "  [OK] Refined!" -ForegroundColor Green
            $ProcessedCount++

        } catch {
            Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
            $ErrorCount++
        }

        Write-Host ""
    }

    # Summary
    Write-Host "=== Refinement Complete ===" -ForegroundColor Cyan
    Write-Host "Processed: $ProcessedCount" -ForegroundColor Green
    Write-Host "Skipped: $SkippedCount" -ForegroundColor Yellow
    Write-Host "Errors: $ErrorCount" -ForegroundColor $(if ($ErrorCount -gt 0) { "Red" } else { "Gray" })
}

# Execute
try {
    Start-TaskRefinement
} catch {
    Write-Host "`nFATAL ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
