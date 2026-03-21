#Requires -Version 5.1
<#
.SYNOPSIS
    Hazina documentation scraper - aggregates scattered docs into unified knowledge base

.DESCRIPTION
    Scrapes documentation from:
    - README files across Hazina repos
    - XML documentation comments in C# code
    - Markdown files in docs folders
    - Code comments and examples

    Outputs unified Markdown knowledge base.

.PARAMETER OutputPath
    Where to save unified docs (default: E:\jengo\documents\hazina-knowledge-base.md)

.PARAMETER IncludeCode
    Include code examples from source files

.PARAMETER Verbose
    Show detailed progress

.EXAMPLE
    hazina-docs-scraper.ps1 -OutputPath "E:\jengo\documents\hazina-docs.md"

.NOTES
    Created: 2026-02-16
    Pattern: llm-codes scraping logic adapted for local repos
#>

[CmdletBinding()]
param(
    [string]$OutputPath = "E:\jengo\documents\hazina-knowledge-base.md",
    [switch]$IncludeCode
)

# Hazina repository locations
$HazinaRepos = @{
    Framework = "C:\Projects\hazina"
    ClientManager = "C:\Projects\client-manager"
}

$DocsContent = @()

Write-Host ""
Write-Host "�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?" -ForegroundColor Cyan
Write-Host "Hazina Documentation Scraper" -ForegroundColor Cyan
Write-Host "�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?" -ForegroundColor Cyan
Write-Host ""

# Function: Extract XML documentation from C# file
function Get-CSharpDocumentation {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) { return $null }

    $content = Get-Content $FilePath -Raw
    $docs = @()

    # Extract /// XML comments
    if ($content -match '(?s)///\s*<summary>(.*?)</summary>') {
        $summary = $matches[1].Trim()
        $docs += "**Summary:** $summary"
    }

    # Extract class/interface names
    if ($content -match 'public (?:class|interface|enum) (\w+)') {
        $typeName = $matches[1]
        $docs += "**Type:** $typeName"
    }

    if ($docs.Count -gt 0) {
        return $docs -join "`n"
    }

    return $null
}

# Function: Process README files
function Get-ReadmeContent {
    param([string]$RepoPath, [string]$RepoName)

    $readmeFiles = Get-ChildItem -Path $RepoPath -Filter "README.md" -Recurse -ErrorAction SilentlyContinue

    foreach ($readme in $readmeFiles) {
        Write-Verbose "Processing: $($readme.FullName)"

        $content = Get-Content $readme.FullName -Raw
        $relativePath = $readme.FullName.Replace($RepoPath, "").TrimStart("\")

        $DocsContent += @"

## $RepoName - $relativePath

$content

---

"@
    }
}

# Function: Process docs folder
function Get-DocsFolder {
    param([string]$RepoPath, [string]$RepoName)

    $docsPath = Join-Path $RepoPath "docs"
    if (-not (Test-Path $docsPath)) { return }

    $docFiles = Get-ChildItem -Path $docsPath -Filter "*.md" -Recurse -ErrorAction SilentlyContinue

    foreach ($docFile in $docFiles) {
        Write-Verbose "Processing: $($docFile.FullName)"

        $content = Get-Content $docFile.FullName -Raw
        $relativePath = $docFile.FullName.Replace($RepoPath, "").TrimStart("\")

        $DocsContent += @"

## $RepoName - $relativePath

$content

---

"@
    }
}

# Function: Extract public API documentation
function Get-PublicAPI {
    param([string]$RepoPath, [string]$RepoName)

    if (-not $IncludeCode) { return }

    # Find public interfaces and classes
    $csFiles = Get-ChildItem -Path $RepoPath -Filter "*.cs" -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\obj\\|\\bin\\|\\node_modules\\' }

    $apiDocs = @()

    foreach ($file in $csFiles) {
        $doc = Get-CSharpDocumentation -FilePath $file.FullName
        if ($doc) {
            $relativePath = $file.FullName.Replace($RepoPath, "").TrimStart("\")
            $apiDocs += "### $relativePath`n`n$doc`n"
        }
    }

    if ($apiDocs.Count -gt 0) {
        $DocsContent += @"

## $RepoName - Public API Documentation

$($apiDocs -join "`n`n")

---

"@
    }
}

# Process each repository
foreach ($repo in $HazinaRepos.GetEnumerator()) {
    Write-Host "Scraping $($repo.Key)..." -ForegroundColor Yellow

    if (-not (Test-Path $repo.Value)) {
        Write-Warning "Repository not found: $($repo.Value)"
        continue
    }

    Get-ReadmeContent -RepoPath $repo.Value -RepoName $repo.Key
    Get-DocsFolder -RepoPath $repo.Value -RepoName $repo.Key
    Get-PublicAPI -RepoPath $repo.Value -RepoName $repo.Key
}

# Generate final markdown
$finalContent = @"
# Hazina Framework - Unified Knowledge Base

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Source Repositories:** $($HazinaRepos.Count)
**Total Sections:** $($DocsContent.Count)

---

$($DocsContent -join "`n`n")

---

**End of Knowledge Base**
"@

# Save to file
$finalContent | Set-Content -Path $OutputPath -Force

Write-Host ""
Write-Host "Documentation scraping complete!" -ForegroundColor Green
Write-Host "Output: $OutputPath" -ForegroundColor Cyan
Write-Host "Sections extracted: $($DocsContent.Count)" -ForegroundColor White
Write-Host "File size: $([math]::Round((Get-Item $OutputPath).Length / 1KB, 2)) KB" -ForegroundColor White
Write-Host ""
