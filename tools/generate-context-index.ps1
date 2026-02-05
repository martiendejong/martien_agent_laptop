<#
.SYNOPSIS
    Generate index of all context files in _machine directory

.DESCRIPTION
    Scans C:\scripts\_machine directory for documentation files,
    extracts metadata, and generates a comprehensive index with:
    - File descriptions (from first paragraph)
    - Last modified timestamps
    - File sizes
    - Categories
    - Quick links

.PARAMETER OutputPath
    Where to save the generated index (default: C:\scripts\_machine\CONTEXT_INDEX.md)

.EXAMPLE
    .\generate-context-index.ps1

.EXAMPLE
    .\generate-context-index.ps1 -OutputPath "context-index-2026-02-05.md"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\scripts\_machine\CONTEXT_INDEX.md"
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Context File Index Generator" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$MachinePath = "C:\scripts\_machine"

# Get all markdown files
Write-Host "🔍 Scanning for context files..." -ForegroundColor Cyan
$files = Get-ChildItem -Path $MachinePath -Filter "*.md" -File -Recurse |
    Where-Object { $_.Name -ne "CONTEXT_INDEX.md" } |
    Sort-Object DirectoryName, Name

Write-Host "  Found $($files.Count) markdown files" -ForegroundColor Gray
Write-Host ""

# Categorize files
$categories = @{
    "Core Documentation" = @()
    "Best Practices" = @()
    "Workflows" = @()
    "Reflections" = @()
    "Incidents" = @()
    "Research" = @()
    "Archive" = @()
    "Other" = @()
}

foreach ($file in $files) {
    $relativePath = $file.FullName.Replace("$MachinePath\", "")

    if ($relativePath -match '^best-practices\\') {
        $categories["Best Practices"] += $file
    }
    elseif ($relativePath -match 'workflow|process') {
        $categories["Workflows"] += $file
    }
    elseif ($relativePath -match 'reflection|lesson') {
        $categories["Reflections"] += $file
    }
    elseif ($relativePath -match 'incident|error|crash') {
        $categories["Incidents"] += $file
    }
    elseif ($relativePath -match 'research|analysis') {
        $categories["Research"] += $file
    }
    elseif ($relativePath -match 'archive') {
        $categories["Archive"] += $file
    }
    elseif ($file.Directory.Name -eq "_machine") {
        $categories["Core Documentation"] += $file
    }
    else {
        $categories["Other"] += $file
    }
}

# Generate index
$doc = @"
# Context Files Index

**Auto-generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Source:** ``$MachinePath``
**Total Files:** $($files.Count)

---

## Summary

"@

foreach ($category in $categories.Keys | Sort-Object) {
    $count = $categories[$category].Count
    if ($count -gt 0) {
        $doc += "- **$category**: $count files`n"
    }
}

$doc += "`n---`n`n"

# Document each category
foreach ($category in $categories.Keys | Sort-Object) {
    $categoryFiles = $categories[$category]
    if ($categoryFiles.Count -eq 0) { continue }

    $doc += "## $category`n`n"

    foreach ($file in ($categoryFiles | Sort-Object Name)) {
        Write-Host "📝 Indexing: $($file.Name)" -ForegroundColor Cyan

        $relativePath = $file.FullName.Replace("$MachinePath\", "")

        # Read first few lines to get description
        $description = ""
        $lines = Get-Content $file.FullName -TotalCount 20

        # Skip title lines and extract first paragraph
        $foundContent = $false
        foreach ($line in $lines) {
            $line = $line.Trim()

            # Skip empty lines, headers, and metadata
            if (-not $line -or $line -match '^#' -or $line -match '^\*\*' -or $line -match '^---') {
                if ($foundContent) { break }
                continue
            }

            $foundContent = $true
            $description += $line + " "

            # Stop after first sentence
            if ($line -match '\.$') { break }
        }

        $description = $description.Trim()
        if ($description.Length -gt 150) {
            $description = $description.Substring(0, 147) + "..."
        }

        # Build entry
        $doc += "### $($file.Name)`n`n"

        if ($description) {
            $doc += "$description`n`n"
        }

        $doc += "- **Path:** ``$relativePath```n"
        $doc += "- **Last Modified:** $($file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss"))`n"
        $doc += "- **Size:** $([math]::Round($file.Length / 1KB, 2)) KB`n"

        # Warn if file is too large
        if ($file.Length -gt 40KB) {
            $doc += "- ⚠️ **Warning:** File exceeds 40KB - consider splitting`n"
        }

        $doc += "`n"
    }

    $doc += "---`n`n"
}

# Add statistics section
$totalSize = ($files | Measure-Object -Property Length -Sum).Sum
$avgSize = $totalSize / $files.Count
$largeFiles = $files | Where-Object { $_.Length -gt 40KB }

$doc += "## Statistics`n`n"
$doc += "- **Total Files:** $($files.Count)`n"
$doc += "- **Total Size:** $([math]::Round($totalSize / 1MB, 2)) MB`n"
$doc += "- **Average File Size:** $([math]::Round($avgSize / 1KB, 2)) KB`n"
$doc += "- **Files > 40KB:** $($largeFiles.Count)`n"
$doc += "`n"

if ($largeFiles.Count -gt 0) {
    $doc += "### Large Files (> 40KB)`n`n"
    foreach ($file in ($largeFiles | Sort-Object Length -Descending)) {
        $doc += "- ``$($file.Name)`` - $([math]::Round($file.Length / 1KB, 2)) KB`n"
    }
    $doc += "`n"
}

$doc += "---`n`n*Auto-generated by generate-context-index.ps1*`n"

# Save index
$doc | Set-Content $OutputPath -Encoding UTF8

Write-Host ""
Write-Host "✅ Context index generated: $OutputPath" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "  - Files indexed: $($files.Count)" -ForegroundColor Gray
Write-Host "  - Total size: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor Gray
Write-Host "  - Large files (>40KB): $($largeFiles.Count)" -ForegroundColor Gray
Write-Host ""
