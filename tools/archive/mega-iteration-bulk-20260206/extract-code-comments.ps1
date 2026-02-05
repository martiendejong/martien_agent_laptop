# Extract Code Comments to Documentation
# Part of Round 6 Improvements - Code Comment Extractor
# Extracts XML docs, JSDoc comments, and converts to Markdown

param(
    [Parameter(Mandatory=$false)]
    [string]$Path = "C:\Projects",

    [Parameter(Mandatory=$false)]
    [ValidateSet("csharp", "javascript", "typescript", "all")]
    [string]$Language = "all",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\scripts\_machine\extracted-docs",

    [Parameter(Mandatory=$false)]
    [switch]$IncludePrivate = $false
)

$ErrorActionPreference = "Stop"

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

Write-Host "Code Comment Extractor - Round 6 Implementation" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# C# XML Documentation Pattern
function Extract-CSharpDocs {
    param([string]$FilePath)

    $content = Get-Content $FilePath -Raw
    $docs = @()

    # Match XML doc comments
    $pattern = '(?s)///\s*<summary>(.*?)</summary>.*?(?:public|private|protected|internal)\s+(?:static\s+)?(?:async\s+)?(\w+(?:<[^>]+>)?)\s+(\w+)'

    $matches = [regex]::Matches($content, $pattern)

    foreach ($match in $matches) {
        $summary = $match.Groups[1].Value.Trim()
        $returnType = $match.Groups[2].Value.Trim()
        $name = $match.Groups[3].Value.Trim()

        $docs += @{
            Name = $name
            Type = "Method/Property"
            Summary = $summary -replace '\s+', ' '
            ReturnType = $returnType
            File = (Split-Path $FilePath -Leaf)
            FilePath = $FilePath
        }
    }

    return $docs
}

# JavaScript/TypeScript JSDoc Pattern
function Extract-JSDoc {
    param([string]$FilePath)

    $content = Get-Content $FilePath -Raw
    $docs = @()

    # Match JSDoc comments
    $pattern = '(?s)/\*\*\s*\n\s*\*\s*([^\n]+).*?\*/\s*(?:export\s+)?(?:async\s+)?(?:function|class|const|let|var)\s+(\w+)'

    $matches = [regex]::Matches($content, $pattern)

    foreach ($match in $matches) {
        $description = $match.Groups[1].Value.Trim()
        $name = $match.Groups[2].Value.Trim()

        $docs += @{
            Name = $name
            Type = "Function/Class"
            Description = $description
            File = (Split-Path $FilePath -Leaf)
            FilePath = $FilePath
        }
    }

    return $docs
}

# Process files
$allDocs = @()
$stats = @{
    CSharp = 0
    JavaScript = 0
    TypeScript = 0
    TotalFiles = 0
    TotalDocs = 0
}

Write-Host "Scanning for documented code..." -ForegroundColor Yellow

if ($Language -eq "all" -or $Language -eq "csharp") {
    Write-Host "  Processing C# files..." -ForegroundColor Gray
    $csFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.cs" -File -ErrorAction SilentlyContinue

    foreach ($file in $csFiles) {
        $docs = Extract-CSharpDocs -FilePath $file.FullName
        if ($docs.Count -gt 0) {
            $allDocs += $docs
            $stats.CSharp += $docs.Count
            $stats.TotalFiles++
        }
    }
}

if ($Language -eq "all" -or $Language -eq "javascript") {
    Write-Host "  Processing JavaScript files..." -ForegroundColor Gray
    $jsFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.js" -File -ErrorAction SilentlyContinue

    foreach ($file in $jsFiles) {
        # Skip node_modules
        if ($file.FullName -notmatch "node_modules") {
            $docs = Extract-JSDoc -FilePath $file.FullName
            if ($docs.Count -gt 0) {
                $allDocs += $docs
                $stats.JavaScript += $docs.Count
                $stats.TotalFiles++
            }
        }
    }
}

if ($Language -eq "all" -or $Language -eq "typescript") {
    Write-Host "  Processing TypeScript files..." -ForegroundColor Gray
    $tsFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.ts" -File -ErrorAction SilentlyContinue

    foreach ($file in $tsFiles) {
        # Skip node_modules
        if ($file.FullName -notmatch "node_modules") {
            $docs = Extract-JSDoc -FilePath $file.FullName
            if ($docs.Count -gt 0) {
                $allDocs += $docs
                $stats.TypeScript += $docs.Count
                $stats.TotalFiles++
            }
        }
    }
}

$stats.TotalDocs = $allDocs.Count

# Generate Markdown documentation
Write-Host ""
Write-Host "Generating Markdown documentation..." -ForegroundColor Yellow

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$markdown = @"
# Extracted Code Documentation
**Generated:** $timestamp
**Source Path:** $Path
**Language Filter:** $Language

## Statistics
- **Total Files Processed:** $($stats.TotalFiles)
- **Total Documented Items:** $($stats.TotalDocs)
- **C# Items:** $($stats.CSharp)
- **JavaScript Items:** $($stats.JavaScript)
- **TypeScript Items:** $($stats.TypeScript)

---

## Documentation by File

"@

# Group by file
$byFile = $allDocs | Group-Object -Property File

foreach ($group in $byFile) {
    $markdown += "`n### $($group.Name)`n`n"

    foreach ($doc in $group.Group) {
        $markdown += "#### $($doc.Name)`n"
        $markdown += "- **Type:** $($doc.Type)`n"

        if ($doc.Summary) {
            $markdown += "- **Summary:** $($doc.Summary)`n"
        }
        if ($doc.Description) {
            $markdown += "- **Description:** $($doc.Description)`n"
        }
        if ($doc.ReturnType) {
            $markdown += "- **Returns:** $($doc.ReturnType)`n"
        }

        $markdown += "- **File:** ``$($doc.FilePath)```n"
        $markdown += "`n"
    }
}

# Save to file
$outputFile = Join-Path $OutputPath "code-documentation-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
$markdown | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host ""
Write-Host "Documentation extracted successfully!" -ForegroundColor Green
Write-Host "  Files processed: $($stats.TotalFiles)" -ForegroundColor Green
Write-Host "  Items documented: $($stats.TotalDocs)" -ForegroundColor Green
Write-Host "  Output: $outputFile" -ForegroundColor Green
Write-Host ""

return @{
    Success = $true
    TotalFiles = $stats.TotalFiles
    TotalDocs = $stats.TotalDocs
    OutputFile = $outputFile
    Stats = $stats
}
