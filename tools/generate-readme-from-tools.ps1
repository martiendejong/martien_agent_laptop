<#
.SYNOPSIS
    Generate living README for tools directory

.DESCRIPTION
    Automatically scans tools directory and generates comprehensive
    README.md by extracting metadata from each tool script.

    Generates:
    - Table of contents
    - Categorized tool listings
    - Usage examples
    - Installation requirements

.PARAMETER ToolsPath
    Path to tools directory (default: C:\scripts\tools)

.PARAMETER OutputPath
    Where to save README (default: C:\scripts\tools\README.md)

.EXAMPLE
    .\generate-readme-from-tools.ps1

.EXAMPLE
    .\generate-readme-from-tools.ps1 -ToolsPath "C:\scripts\tools" -OutputPath "README.md"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ToolsPath = "C:\scripts\tools",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\scripts\tools\README.md"
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Living README Generator" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔍 Scanning tools directory: $ToolsPath" -ForegroundColor Cyan
$scripts = Get-ChildItem -Path $ToolsPath -Filter "*.ps1" -File | Sort-Object Name

Write-Host "  Found $($scripts.Count) PowerShell tools" -ForegroundColor Gray
Write-Host ""

# Categorize tools
$categories = @{
    "Knowledge Management" = @()
    "Documentation" = @()
    "Worktree Management" = @()
    "Git Workflow" = @()
    "Database Tools" = @()
    "Monitoring" = @()
    "Visualization" = @()
    "Automation" = @()
    "Other" = @()
}

foreach ($script in $scripts) {
    $content = Get-Content $script.FullName -Raw

    # Extract synopsis
    $synopsis = ""
    if ($content -match '\.SYNOPSIS\s+(.*?)(?=\.|\z)') {
        $synopsis = $Matches[1].Trim()
    }

    # Categorize based on name and synopsis
    $tool = [PSCustomObject]@{
        Name = $script.Name
        Synopsis = $synopsis
        Path = $script.FullName
    }

    if ($script.Name -match 'knowledge|learning|query') {
        $categories["Knowledge Management"] += $tool
    }
    elseif ($script.Name -match 'document|readme|generate-.*-docs') {
        $categories["Documentation"] += $tool
    }
    elseif ($script.Name -match 'worktree|allocate|release') {
        $categories["Worktree Management"] += $tool
    }
    elseif ($script.Name -match 'git|pr|merge|branch') {
        $categories["Git Workflow"] += $tool
    }
    elseif ($script.Name -match 'db|sqlite|query') {
        $categories["Database Tools"] += $tool
    }
    elseif ($script.Name -match 'monitor|watch|track') {
        $categories["Monitoring"] += $tool
    }
    elseif ($script.Name -match 'viz|visual|graph|chart') {
        $categories["Visualization"] += $tool
    }
    elseif ($script.Name -match 'auto|batch|bulk') {
        $categories["Automation"] += $tool
    }
    else {
        $categories["Other"] += $tool
    }
}

# Generate README
$doc = @"
# PowerShell Tools Collection

**Auto-generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Total Tools:** $($scripts.Count)
**Location:** ``$ToolsPath``

---

## Quick Start

All tools are PowerShell scripts (.ps1) that can be executed directly:

````powershell
# Get help for any tool
Get-Help .\tool-name.ps1 -Full

# Run a tool
.\tool-name.ps1 -Parameter Value
````

---

## Table of Contents

"@

# Add TOC
foreach ($category in $categories.Keys | Sort-Object) {
    $count = $categories[$category].Count
    if ($count -gt 0) {
        $anchor = $category -replace ' ', '-'
        $doc += "- [$category ($count)](#$anchor)`n"
    }
}

$doc += "`n---`n`n"

# Document each category
foreach ($category in $categories.Keys | Sort-Object) {
    $tools = $categories[$category]
    if ($tools.Count -eq 0) { continue }

    Write-Host "📝 Documenting category: $category ($($tools.Count) tools)" -ForegroundColor Cyan

    $doc += "## $category`n`n"

    foreach ($tool in ($tools | Sort-Object Name)) {
        $doc += "### $($tool.Name -replace '\.ps1$', '')`n`n"

        if ($tool.Synopsis) {
            $doc += "$($tool.Synopsis)`n`n"
        }

        $doc += "**Usage:**`n````powershell`n.\$($tool.Name) -Parameter Value`n```````n`n"
        $doc += "**Details:** Run ``Get-Help .\$($tool.Name) -Full`` for complete documentation`n`n"
    }

    $doc += "---`n`n"
}

# Add footer
$doc += @"
## Installation

These tools are part of the Claude Agent system located at ``C:\scripts``.

### Requirements

- PowerShell 5.1 or later
- Git (for repository tools)
- SQLite (for database tools)

### Configuration

Tools read configuration from:
- ``C:\scripts\MACHINE_CONFIG.md`` - Machine-specific paths
- ``C:\scripts\_machine\`` - Agent context and state

---

## Contributing

To add a new tool:

1. Create PowerShell script with comment-based help
2. Include .SYNOPSIS, .DESCRIPTION, .PARAMETER, .EXAMPLE
3. Run ``.\generate-readme-from-tools.ps1`` to update this README

---

*Auto-generated by generate-readme-from-tools.ps1*
*DO NOT EDIT MANUALLY - Changes will be overwritten*
"@

# Save README
$doc | Set-Content $OutputPath -Encoding UTF8

Write-Host ""
Write-Host "✅ README generated: $OutputPath" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Cyan
foreach ($category in $categories.Keys | Sort-Object) {
    $count = $categories[$category].Count
    if ($count -gt 0) {
        Write-Host "  - $category`: $count tools" -ForegroundColor Gray
    }
}
Write-Host ""
