<#
.SYNOPSIS
    Load full context for a topic mentioned by user

.DESCRIPTION
    Searches all knowledge sources for context about a topic:
    - Active situations (ongoing user situations)
    - Knowledge base (all categories)
    - Reflection log (past learnings)
    - Project files (if topic is a project)

.PARAMETER Topic
    The topic to load context for (e.g., "Arjan", "client-manager", "worktrees")

.PARAMETER Sources
    Which sources to search. Default: all
    Options: active, knowledge, reflection, projects, all

.PARAMETER OutputFormat
    How to format output. Default: summary
    Options: summary, full, json

.EXAMPLE
    .\load-context.ps1 -Topic "Arjan"
    # Returns: Full context about Arjan situation from all sources

.EXAMPLE
    .\load-context.ps1 -Topic "worktrees" -Sources knowledge,reflection
    # Returns: Worktree info from knowledge base + past learnings

.EXAMPLE
    .\load-context.ps1 -Topic "client-manager" -OutputFormat json
    # Returns: JSON with all context about client-manager project

.NOTES
    Purpose: Prevent asking user about information that already exists
    Part of: CONTEXT_AWARENESS.md cognitive system
    Created: 2026-01-31
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Topic,

    [Parameter(Mandatory=$false)]
    [ValidateSet('active', 'knowledge', 'reflection', 'projects', 'all')]
    [string[]]$Sources = @('all'),

    [Parameter(Mandatory=$false)]
    [ValidateSet('summary', 'full', 'json')]
    [string]$OutputFormat = 'summary'
)

$ErrorActionPreference = 'Stop'

# Paths
$activeSituationsPath = "C:\scripts\_machine\knowledge-base\01-USER\active-situations.md"
$knowledgeBasePath = "C:\scripts\_machine\knowledge-base\"
$reflectionLogPath = "C:\scripts\_machine\reflection.log.md"
$projectsPath = "C:\Projects\"

# Result container
$result = @{
    Topic = $Topic
    Found = $false
    Sources = @{
        ActiveSituation = $null
        KnowledgeBase = @()
        Reflections = @()
        Projects = @()
    }
    Summary = ""
}

# Helper: Extract relevant section from markdown
function Extract-Section {
    param([string]$Content, [string]$Topic)

    $lines = $Content -split "`r?`n"
    $inSection = $false
    $section = @()
    $headerLevel = 0

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        # Check if line contains topic
        if ($line -match [regex]::Escape($Topic)) {
            # Find header of this section
            for ($j = $i; $j -ge 0; $j--) {
                if ($lines[$j] -match '^(#{1,6})\s') {
                    $headerLevel = $Matches[1].Length
                    $inSection = $true
                    $section = @($lines[$j])
                    break
                }
            }
        }

        # If in section, collect lines until next same-level header
        if ($inSection) {
            if ($i -gt 0 -and $line -match "^#{1,$headerLevel}\s" -and $line -notmatch [regex]::Escape($Topic)) {
                break
            }
            $section += $line
        }
    }

    return ($section -join "`n")
}

# Source 1: Active Situations
if ($Sources -contains 'all' -or $Sources -contains 'active') {
    if (Test-Path $activeSituationsPath) {
        $content = Get-Content $activeSituationsPath -Raw
        if ($content -match [regex]::Escape($Topic)) {
            $section = Extract-Section -Content $content -Topic $Topic
            $result.Sources.ActiveSituation = $section
            $result.Found = $true
        }
    }
}

# Source 2: Knowledge Base
if ($Sources -contains 'all' -or $Sources -contains 'knowledge') {
    if (Test-Path $knowledgeBasePath) {
        $kbFiles = Get-ChildItem $knowledgeBasePath -Recurse -Filter "*.md" -ErrorAction SilentlyContinue
        foreach ($file in $kbFiles) {
            $matches = Select-String -Path $file.FullName -Pattern $Topic -Context 5,5
            if ($matches) {
                $result.Sources.KnowledgeBase += @{
                    File = $file.FullName.Replace("C:\scripts\_machine\knowledge-base\", "")
                    Matches = $matches | ForEach-Object {
                        @{
                            LineNumber = $_.LineNumber
                            Context = ($_.Context.PreContext + $_.Line + $_.Context.PostContext) -join "`n"
                        }
                    }
                }
                $result.Found = $true
            }
        }
    }
}

# Source 3: Reflection Log
if ($Sources -contains 'all' -or $Sources -contains 'reflection') {
    if (Test-Path $reflectionLogPath) {
        $matches = Select-String -Path $reflectionLogPath -Pattern $Topic -Context 10,10
        if ($matches) {
            $result.Sources.Reflections = $matches | ForEach-Object {
                @{
                    LineNumber = $_.LineNumber
                    Context = ($_.Context.PreContext + $_.Line + $_.Context.PostContext) -join "`n"
                }
            }
            $result.Found = $true
        }
    }
}

# Source 4: Projects
if ($Sources -contains 'all' -or $Sources -contains 'projects') {
    if (Test-Path $projectsPath) {
        # Check project names
        $projectDirs = Get-ChildItem $projectsPath -Directory -ErrorAction SilentlyContinue
        foreach ($dir in $projectDirs) {
            if ($dir.Name -match $Topic) {
                # Check for README.md
                $readme = Join-Path $dir.FullName "README.md"
                if (Test-Path $readme) {
                    $result.Sources.Projects += @{
                        Project = $dir.Name
                        ReadmePath = $readme
                        Content = Get-Content $readme -Raw
                    }
                    $result.Found = $true
                }
            }
        }
    }
}

# Generate Summary
if ($result.Found) {
    $summary = @()
    $summary += "=" * 70
    $summary += "CONTEXT LOADED FOR: $Topic"
    $summary += "=" * 70
    $summary += ""

    if ($result.Sources.ActiveSituation) {
        $summary += "[ACTIVE SITUATION] (Ongoing - High Priority)"
        $summary += "-" * 70
        $summary += $result.Sources.ActiveSituation
        $summary += ""
    }

    if ($result.Sources.KnowledgeBase.Count -gt 0) {
        $summary += "[KNOWLEDGE BASE] ($($result.Sources.KnowledgeBase.Count) files)"
        $summary += "-" * 70
        foreach ($kb in $result.Sources.KnowledgeBase) {
            $summary += "File: $($kb.File)"
            $summary += "   Matches: $($kb.Matches.Count)"
        }
        $summary += ""
    }

    if ($result.Sources.Reflections.Count -gt 0) {
        $summary += "[REFLECTION LOG] ($($result.Sources.Reflections.Count) entries)"
        $summary += "-" * 70
        $summary += "Past learnings/discussions about this topic"
        $summary += ""
    }

    if ($result.Sources.Projects.Count -gt 0) {
        $summary += "[PROJECTS] ($($result.Sources.Projects.Count) projects)"
        $summary += "-" * 70
        foreach ($proj in $result.Sources.Projects) {
            $summary += "Project: $($proj.Project)"
        }
        $summary += ""
    }

    $summary += "=" * 70
    $summary += "CONTEXT AVAILABLE - DO NOT ASK USER ABOUT THIS"
    $summary += "=" * 70

    $result.Summary = $summary -join "`n"
}
else {
    $result.Summary = "No context found for '$Topic' in any source`nAsking user MAY be necessary (verify first)"
}

# Output
switch ($OutputFormat) {
    'json' {
        $result | ConvertTo-Json -Depth 10
    }
    'full' {
        $result.Summary
        ""
        "=" * 70
        "FULL DETAILS:"
        "=" * 70
        ""
        if ($result.Sources.ActiveSituation) {
            "ACTIVE SITUATION:"
            $result.Sources.ActiveSituation
            ""
        }
        if ($result.Sources.KnowledgeBase.Count -gt 0) {
            "KNOWLEDGE BASE:"
            $result.Sources.KnowledgeBase | ForEach-Object {
                "File: $($_.File)"
                $_.Matches | ForEach-Object {
                    "Line $($_.LineNumber):"
                    $_.Context
                    ""
                }
            }
        }
        if ($result.Sources.Reflections.Count -gt 0) {
            "REFLECTIONS:"
            $result.Sources.Reflections | ForEach-Object {
                "Line $($_.LineNumber):"
                $_.Context
                ""
            }
        }
        if ($result.Sources.Projects.Count -gt 0) {
            "PROJECTS:"
            $result.Sources.Projects | ForEach-Object {
                "Project: $($_.Project)"
                "README: $($_.ReadmePath)"
                $_.Content
                ""
            }
        }
    }
    'summary' {
        $result.Summary
    }
}

# Return status code
if ($result.Found) {
    exit 0  # Success - context found
}
else {
    exit 1  # Not found - user question may be needed
}
