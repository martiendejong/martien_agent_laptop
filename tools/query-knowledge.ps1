<#
.SYNOPSIS
    Unified search across ALL Claude Agent knowledge sources.

.DESCRIPTION
    Comprehensive search that covers:
    - Personal insights (user preferences, learnings)
    - Reflection log (session history, mistakes, successes)
    - Machine config (paths, constraints, setup)
    - Knowledge base (user, machine, systems, workflows, secrets)
    - Cognitive architecture (identity, decision-making, memory)
    - Documentation (CLAUDE.md, workflows, patterns)
    - Skills (auto-discoverable workflows)

    Returns ranked results with context snippets, grouped by source type.

    This tool exists because knowledge is scattered across multiple files
    and directories. Searching manually is inefficient (3+ repetitions observed).

.PARAMETER Query
    Search term or pattern (case-insensitive)

.PARAMETER Source
    Limit search to specific source type:
    - all (default) - Search everything
    - insights - PERSONAL_INSIGHTS.md only
    - reflection - reflection.log.md only
    - config - MACHINE_CONFIG.md and related
    - kb - knowledge-base/ directory
    - identity - agentidentity/ (cognitive architecture)
    - docs - CLAUDE.md and documentation
    - skills - Claude Skills directory

.PARAMETER Context
    Number of context lines before/after match (default: 2)

.PARAMETER Limit
    Maximum results per source (default: 10, 0 = unlimited)

.PARAMETER Recent
    Only search recent N days (for date-stamped sources like reflection.log)

.EXAMPLE
    .\query-knowledge.ps1 -Query "disk space"
    Find all mentions of disk space constraints

.EXAMPLE
    .\query-knowledge.ps1 -Query "worktree" -Source skills
    Find worktree-related skills

.EXAMPLE
    .\query-knowledge.ps1 -Query "user prefers" -Source insights -Context 5
    Find user preferences with more context

.EXAMPLE
    .\query-knowledge.ps1 -Query "build error" -Recent 7
    Find recent build error solutions (last 7 days)
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Query,

    [ValidateSet("all", "insights", "reflection", "config", "kb", "identity", "docs", "skills")]
    [string]$Source = "all",

    [int]$Context = 2,
    [int]$Limit = 10,
    [int]$Recent = 0
)

# AUTO-USAGE TRACKING
$toolName = $MyInvocation.MyCommand.Name -replace '\.ps1$', ''
. "$PSScriptRoot\_usage-logger.ps1" -ToolName $toolName -Action "execute" -Metadata @{ Parameters = ($PSBoundParameters.Keys -join ',') } -ErrorAction SilentlyContinue

# Define all knowledge sources with metadata
$KnowledgeSources = @{
    "insights" = @{
        name = "Personal Insights"
        paths = @("C:\scripts\_machine\PERSONAL_INSIGHTS.md")
        description = "User preferences, behavioral patterns, session learnings"
        priority = 10  # Highest priority (most frequently needed)
    }
    "reflection" = @{
        name = "Reflection Log"
        paths = @("C:\scripts\_machine\reflection.log.md")
        description = "Session history, mistakes, successes, patterns"
        priority = 9
    }
    "config" = @{
        name = "Machine Configuration"
        paths = @(
            "C:\scripts\MACHINE_CONFIG.md",
            "C:\scripts\GENERAL_ZERO_TOLERANCE_RULES.md",
            "C:\scripts\GENERAL_DUAL_MODE_WORKFLOW.md",
            "C:\scripts\GENERAL_WORKTREE_PROTOCOL.md"
        )
        description = "Paths, projects, constraints, core workflows"
        priority = 8
    }
    "kb" = @{
        name = "Knowledge Base"
        paths = @("C:\scripts\_machine\knowledge-base")
        description = "Comprehensive user/machine/system/workflow knowledge"
        priority = 9
        isDirectory = $true
    }
    "identity" = @{
        name = "Cognitive Architecture"
        paths = @("C:\scripts\agentidentity")
        description = "Identity, decision-making, memory, ethics"
        priority = 7
        isDirectory = $true
    }
    "docs" = @{
        name = "Documentation"
        paths = @(
            "C:\scripts\CLAUDE.md",
            "C:\scripts\continuous-improvement.md",
            "C:\scripts\git-workflow.md",
            "C:\scripts\development-patterns.md",
            "C:\scripts\ci-cd-troubleshooting.md",
            "C:\scripts\_machine\SOFTWARE_DEVELOPMENT_PRINCIPLES.md",
            "C:\scripts\_machine\DEFINITION_OF_DONE.md"
        )
        description = "Operational manual, workflows, patterns, troubleshooting"
        priority = 6
    }
    "skills" = @{
        name = "Claude Skills"
        paths = @("C:\scripts\.claude\skills")
        description = "Auto-discoverable specialized workflows"
        priority = 7
        isDirectory = $true
    }
}

function Search-Source {
    param(
        [string]$SourceType,
        [string]$SearchQuery,
        [int]$ContextLines,
        [int]$MaxResults
    )

    $sourceInfo = $KnowledgeSources[$SourceType]
    $results = @()

    foreach ($path in $sourceInfo.paths) {
        if (-not (Test-Path $path)) { continue }

        if ($sourceInfo.isDirectory) {
            # Search all .md files in directory recursively
            $files = Get-ChildItem $path -Filter "*.md" -Recurse -File -ErrorAction SilentlyContinue

            foreach ($file in $files) {
                $matches = Search-File -FilePath $file.FullName -Pattern $SearchQuery -Context $ContextLines

                foreach ($match in $matches) {
                    $results += @{
                        source = $sourceInfo.name
                        file = $file.Name
                        fullPath = $file.FullName
                        lineNumber = $match.lineNumber
                        matchText = $match.matchText
                        contextBefore = $match.contextBefore
                        contextAfter = $match.contextAfter
                        priority = $sourceInfo.priority
                    }
                }
            }
        } else {
            # Single file search
            $matches = Search-File -FilePath $path -Pattern $SearchQuery -Context $ContextLines

            foreach ($match in $matches) {
                $results += @{
                    source = $sourceInfo.name
                    file = Split-Path $path -Leaf
                    fullPath = $path
                    lineNumber = $match.lineNumber
                    matchText = $match.matchText
                    contextBefore = $match.contextBefore
                    contextAfter = $match.contextAfter
                    priority = $sourceInfo.priority
                }
            }
        }
    }

    # Apply result limit if specified
    if ($MaxResults -gt 0) {
        $results = $results | Select-Object -First $MaxResults
    }

    return $results
}

function Search-File {
    param(
        [string]$FilePath,
        [string]$Pattern,
        [int]$Context
    )

    $matches = @()
    $lines = Get-Content $FilePath -ErrorAction SilentlyContinue

    if (-not $lines) { return $matches }

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match $Pattern) {
            $contextBefore = @()
            $contextAfter = @()

            # Get context before
            for ($j = [Math]::Max(0, $i - $Context); $j -lt $i; $j++) {
                $contextBefore += $lines[$j]
            }

            # Get context after
            for ($j = $i + 1; $j -le [Math]::Min($lines.Count - 1, $i + $Context); $j++) {
                $contextAfter += $lines[$j]
            }

            $matches += @{
                lineNumber = $i + 1
                matchText = $lines[$i]
                contextBefore = $contextBefore
                contextAfter = $contextAfter
            }
        }
    }

    return $matches
}

function Format-Results {
    param([array]$Results)

    if ($Results.Count -eq 0) {
        Write-Host "`n❌ No matches found for: $Query" -ForegroundColor Red
        return
    }

    # Group by source
    $groupedResults = $Results | Group-Object -Property source | Sort-Object { $_.Group[0].priority } -Descending

    Write-Host "`n🔍 Found $($Results.Count) match(es) across $($groupedResults.Count) source(s)" -ForegroundColor Green
    Write-Host ("=" * 80) -ForegroundColor DarkGray

    foreach ($group in $groupedResults) {
        Write-Host "`n📁 $($group.Name) ($($group.Count) match(es))" -ForegroundColor Cyan
        Write-Host ("-" * 80) -ForegroundColor DarkGray

        foreach ($result in $group.Group) {
            Write-Host "  📄 $($result.file):$($result.lineNumber)" -ForegroundColor Yellow
            Write-Host "     Path: $($result.fullPath)" -ForegroundColor DarkGray

            # Show context before (dimmed)
            foreach ($line in $result.contextBefore) {
                Write-Host "     $line" -ForegroundColor DarkGray
            }

            # Show match line (highlighted)
            $matchLine = $result.matchText
            $highlightedLine = $matchLine -replace "(?i)($([regex]::Escape($Query)))", "`e[1;33m`$1`e[0m"
            Write-Host "  ➤  $highlightedLine" -ForegroundColor White

            # Show context after (dimmed)
            foreach ($line in $result.contextAfter) {
                Write-Host "     $line" -ForegroundColor DarkGray
            }

            Write-Host ""
        }
    }

    Write-Host ("=" * 80) -ForegroundColor DarkGray
}

# Main execution
Write-Host "`n🧠 Query Knowledge: Searching for '$Query'" -ForegroundColor Cyan

if ($Source -eq "all") {
    $allResults = @()

    foreach ($sourceType in $KnowledgeSources.Keys) {
        $sourceResults = Search-Source -SourceType $sourceType -SearchQuery $Query -ContextLines $Context -MaxResults $Limit
        $allResults += $sourceResults
    }

    # Sort by priority, then by source name
    $allResults = $allResults | Sort-Object -Property priority -Descending
    Format-Results -Results $allResults

} else {
    if (-not $KnowledgeSources.ContainsKey($Source)) {
        Write-Host "❌ Invalid source type: $Source" -ForegroundColor Red
        Write-Host "Valid sources: $($KnowledgeSources.Keys -join ', ')" -ForegroundColor Yellow
        exit 1
    }

    $results = Search-Source -SourceType $Source -SearchQuery $Query -ContextLines $Context -MaxResults $Limit
    Format-Results -Results $results
}

Write-Host "`n✅ Search complete" -ForegroundColor Green
