<#
.SYNOPSIS
    Suggest related files based on knowledge graph connections

.DESCRIPTION
    Given a file or topic, suggest 3-5 most relevant related files
    based on RELATED_READING_MAP.yaml and CONTEXT_KNOWLEDGE_GRAPH.yaml

.PARAMETER File
    File path or name to find related content for

.PARAMETER Topic
    Topic or entity name (e.g., "client-manager", "worktrees", "PR workflow")

.PARAMETER MaxSuggestions
    Maximum number of suggestions to show (default: 5)

.PARAMETER ShowDescription
    Show descriptions of why files are related (default: $true)

.EXAMPLE
    .\suggest-related.ps1 -File "CLAUDE.md"
    Find files related to CLAUDE.md

.EXAMPLE
    .\suggest-related.ps1 -Topic "client-manager"
    Find files related to client-manager project

.EXAMPLE
    .\suggest-related.ps1 -Topic "worktree" -MaxSuggestions 3
    Find top 3 files related to worktree topic

.NOTES
    Part of Improvement #5: Context-aware file recommendations
    Expert: Zara Johnson (Related content recommendations)
#>

param(
    [string]$File = "",
    [string]$Topic = "",
    [int]$MaxSuggestions = 5,
    [bool]$ShowDescription = $true
)

# Load related reading map
function Load-RelatedReadingMap {
    $mapPath = "C:\scripts\_machine\RELATED_READING_MAP.yaml"

    if (-not (Test-Path $mapPath)) {
        Write-Warning "RELATED_READING_MAP.yaml not found. Using fallback knowledge graph."
        return $null
    }

    try {
        # Simple YAML parsing (assumes basic structure)
        $content = Get-Content -Path $mapPath -Raw
        return $content
    }
    catch {
        Write-Warning "Could not load related reading map: $_"
        return $null
    }
}

# Extract file name from path
function Get-NormalizedFileName {
    param([string]$InputPath)

    if (Test-Path $InputPath) {
        return [System.IO.Path]::GetFileName($InputPath)
    }
    elseif ($InputPath -match '\.md$') {
        return [System.IO.Path]::GetFileName($InputPath)
    }
    else {
        return $InputPath
    }
}

# Find related files from map
function Find-RelatedFiles {
    param(
        [string]$Query,
        [string]$MapContent,
        [int]$MaxResults
    )

    $related = @()

    # Parse YAML for matching entry
    if ($MapContent -match "(?s)$Query[:\s]+consider_also:\s*\[([^\]]+)\]") {
        $relatedList = $matches[1] -split ',' | ForEach-Object { $_.Trim().Trim('"').Trim("'") }
        $related += $relatedList | Select-Object -First $MaxResults
    }

    # Also check for topic mentions
    if ($MapContent -match "(?s)when_reading[:\s]+([^\n]+)$Query") {
        if ($MapContent -match "(?s)consider_also:\s*\[([^\]]+)\]") {
            $relatedList = $matches[1] -split ',' | ForEach-Object { $_.Trim().Trim('"').Trim("'") }
            $related += $relatedList | Select-Object -First $MaxResults
        }
    }

    return $related | Select-Object -Unique -First $MaxResults
}

# Get hardcoded fallback recommendations (if map doesn't exist yet)
function Get-FallbackRecommendations {
    param([string]$Query)

    $recommendations = @{
        "CLAUDE.md" = @("MACHINE_CONFIG.md", "GENERAL_ZERO_TOLERANCE_RULES.md", "STARTUP_PROTOCOL.md", "CAPABILITIES.md")
        "MACHINE_CONFIG.md" = @("CLAUDE.md", "CONTEXT_KNOWLEDGE_GRAPH.yaml", "worktree-workflow.md")
        "worktree-workflow.md" = @("MANDATORY_CODE_WORKFLOW.md", "worktrees.pool.md", "allocate-worktree skill", "GENERAL_DUAL_MODE_WORKFLOW.md")
        "MANDATORY_CODE_WORKFLOW.md" = @("DEFINITION_OF_DONE.md", "clickup-sync.ps1", "git-workflow.md", "worktree-workflow.md")
        "client-manager" = @("hazina docs", "brand2boost store", "WORKTREE_WORKFLOW.md", "MACHINE_CONFIG.md")
        "hazina" = @("client-manager docs", "MACHINE_CONFIG.md", "API documentation")
        "DEFINITION_OF_DONE.md" = @("MANDATORY_CODE_WORKFLOW.md", "ef-preflight-check.ps1", "GENERAL_ZERO_TOLERANCE_RULES.md")
        "STARTUP_PROTOCOL.md" = @("CLAUDE.md", "MACHINE_CONFIG.md", "consciousness-practices skill", "SESSION_RECOVERY.md")
        "git-workflow.md" = @("MANDATORY_CODE_WORKFLOW.md", "github-workflow skill", "pr-dependencies skill")
        "arjan" = @("C:\arjan_emails\DEFINITIEVE_ANALYSE.md", "C:\arjan_emails\EVIDENCE_SUMMARY_2026-01-26.md", "C:\arjan_emails\TIJDLIJN_ARJAN_STROEVE_COMPLEET.md")
        "gemeente" = @("C:\gemeente_emails\CONCLUSIE_VOOR_CORINA_EN_SUZANNE.md", "C:\gemeente_emails\TIJDLIJN_HUWELIJK_2022-2026_COMPLEET.md")
        "PR" = @("git-workflow.md", "MANDATORY_CODE_WORKFLOW.md", "github-workflow skill", "clickup-sync.ps1")
        "worktree" = @("worktree-workflow.md", "allocate-worktree skill", "release-worktree skill", "worktrees.pool.md")
        "ClickUp" = @("MANDATORY_CODE_WORKFLOW.md", "clickup-sync.ps1", "DEFINITION_OF_DONE.md")
        "EF Core" = @("DEFINITION_OF_DONE.md", "ef-preflight-check.ps1", "ef-migration-safety skill", "migration-patterns.md")
        "debugging" = @("GENERAL_DUAL_MODE_WORKFLOW.md", "debug-mode skill", "CAPABILITIES.md")
        "feature" = @("GENERAL_DUAL_MODE_WORKFLOW.md", "feature-mode skill", "MANDATORY_CODE_WORKFLOW.md", "worktree-workflow.md")
    }

    # Try exact match
    if ($recommendations.ContainsKey($Query)) {
        return $recommendations[$Query]
    }

    # Try partial match
    foreach ($key in $recommendations.Keys) {
        if ($Query -match $key -or $key -match $Query) {
            return $recommendations[$key]
        }
    }

    return @()
}

# Get file description
function Get-FileDescription {
    param([string]$FileName)

    $descriptions = @{
        "CLAUDE.md" = "Main documentation index and system overview"
        "MACHINE_CONFIG.md" = "Machine-specific paths, projects, credentials"
        "GENERAL_ZERO_TOLERANCE_RULES.md" = "Hard stop rules that must never be violated"
        "STARTUP_PROTOCOL.md" = "Session startup checklist and mandatory loading"
        "CAPABILITIES.md" = "All autonomous capabilities (AI image gen, debugging, etc.)"
        "worktree-workflow.md" = "Worktree allocation and release protocol"
        "MANDATORY_CODE_WORKFLOW.md" = "NON-NEGOTIABLE 7-step workflow for code changes"
        "DEFINITION_OF_DONE.md" = "Complete checklist before task is DONE"
        "git-workflow.md" = "PR creation, cross-repo dependencies, merge strategy"
        "GENERAL_DUAL_MODE_WORKFLOW.md" = "Feature Development vs Active Debugging mode decision"
        "CONTEXT_KNOWLEDGE_GRAPH.yaml" = "Complete system context and entity relationships"
        "worktrees.pool.md" = "Current worktree allocation state (FREE/BUSY)"
        "SESSION_RECOVERY.md" = "Crash recovery and session restoration"
        "clickup-sync.ps1" = "ClickUp task integration (Step 7 of workflow)"
        "ef-preflight-check.ps1" = "Check for pending EF Core migrations"
        "allocate-worktree skill" = "Automate worktree allocation with conflict checking"
        "release-worktree skill" = "Automate worktree release after PR"
        "github-workflow skill" = "PR creation and GitHub integration"
        "ef-migration-safety skill" = "Safe EF Core migration handling"
        "migration-patterns.md" = "EF Core migration best practices and patterns"
        "brand2boost store" = "Data store for Brand2Boost (C:\stores\brand2boost)"
        "hazina docs" = "Hazina framework documentation"
        "consciousness-practices skill" = "Activate consciousness framework"
    }

    if ($descriptions.ContainsKey($FileName)) {
        return $descriptions[$FileName]
    }

    return "Related resource"
}

# Main execution
Write-Host "Finding related files..." -ForegroundColor Cyan
Write-Host ""

# Determine query
$query = ""
if ($File) {
    $query = Get-NormalizedFileName -InputPath $File
    Write-Host "Looking for files related to: $query" -ForegroundColor White
}
elseif ($Topic) {
    $query = $Topic
    Write-Host "Looking for files related to topic: $query" -ForegroundColor White
}
else {
    Write-Error "Must specify either -File or -Topic"
    exit 1
}

# Load map and find related files
$mapContent = Load-RelatedReadingMap
$related = @()

if ($mapContent) {
    $related = Find-RelatedFiles -Query $query -MapContent $mapContent -MaxResults $MaxSuggestions
}

# Fallback to hardcoded recommendations
if ($related.Count -eq 0) {
    $related = Get-FallbackRecommendations -Query $query
}

# Display results
if ($related.Count -eq 0) {
    Write-Host "No related files found for: $query" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Try:" -ForegroundColor Gray
    Write-Host "  - CLAUDE.md (main index)" -ForegroundColor Gray
    Write-Host "  - MACHINE_CONFIG.md (system configuration)" -ForegroundColor Gray
    Write-Host "  - CONTEXT_KNOWLEDGE_GRAPH.yaml (complete graph)" -ForegroundColor Gray
}
else {
    Write-Host "Related files:" -ForegroundColor Green
    Write-Host ""

    $count = 1
    foreach ($relatedFile in $related | Select-Object -First $MaxSuggestions) {
        Write-Host "  $count. " -ForegroundColor Cyan -NoNewline
        Write-Host "$relatedFile" -ForegroundColor White

        if ($ShowDescription) {
            $description = Get-FileDescription -FileName $relatedFile
            Write-Host "     $description" -ForegroundColor DarkGray
        }

        Write-Host ""
        $count++
    }

    Write-Host "TIP: Use these files to get complete context on '$query'" -ForegroundColor DarkCyan
}

Write-Host ""
