# Add YAML Frontmatter to Markdown Files
# Adds standardized metadata headers to documentation

param(
    [Parameter(Mandatory=$false)]
    [string]$FilePath,

    [Parameter(Mandatory=$false)]
    [string]$ScanDirectory = "C:\scripts",

    [switch]$DryRun
)

$schema = Get-Content "C:\scripts\_machine\DOCUMENTATION_SCHEMA.yaml" -Raw | ConvertFrom-Yaml

function Add-Frontmatter {
    param([string]$Path)

    $content = Get-Content $Path -Raw

    # Check if frontmatter already exists
    if ($content -match '^---\s*\n') {
        Write-Host "[SKIP] $Path (already has frontmatter)" -ForegroundColor Yellow
        return
    }

    # Detect context type from file path/name
    $contextType = "reference"  # default
    if ($Path -match "workflow") { $contextType = "workflow_protocol" }
    if ($Path -match "pattern") { $contextType = "pattern_library" }
    if ($Path -match "CONFIG") { $contextType = "system_config" }
    if ($Path -match "troubleshoot|error") { $contextType = "troubleshooting" }

    # Get last modified date
    $lastUpdate = (Get-Item $Path).LastWriteTime.ToString("yyyy-MM-dd")

    # Build frontmatter
    $frontmatter = @"
---
context_type: $contextType
related_files: []
last_major_update: $lastUpdate
primary_expert: documentation
tags: []
importance: medium
---

"@

    $newContent = $frontmatter + $content

    if ($DryRun) {
        Write-Host "[DRY RUN] Would add frontmatter to: $Path" -ForegroundColor Cyan
    } else {
        Set-Content $Path -Value $newContent -NoNewline
        Write-Host "[ADDED] $Path" -ForegroundColor Green
    }
}

if ($FilePath) {
    Add-Frontmatter -Path $FilePath
} else {
    Get-ChildItem $ScanDirectory -Filter "*.md" -Recurse | ForEach-Object {
        Add-Frontmatter -Path $_.FullName
    }
}
