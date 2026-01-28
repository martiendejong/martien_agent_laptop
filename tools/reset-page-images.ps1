<#
.SYNOPSIS
    Resets all featured and additional images from pages in an ArtRevisionist topic.

.DESCRIPTION
    This script clears FeaturedImageFilename and AdditionalImages for all pages,
    detail pages, and evidence pages in a topic's pages.json file.
    This effectively resets the diversity counter since it's calculated from page assignments.

.PARAMETER TopicId
    The topic ID (folder name) to reset images for.

.PARAMETER StorePath
    The store path. Defaults to C:\stores\artrevisionist

.PARAMETER BackupFirst
    Create a backup before modifying. Defaults to true.

.PARAMETER DryRun
    Show what would be changed without actually modifying the file.

.EXAMPLE
    .\reset-page-images.ps1 -TopicId "Valsuani"

.EXAMPLE
    .\reset-page-images.ps1 -TopicId "Valsuani" -DryRun

.EXAMPLE
    .\reset-page-images.ps1 -TopicId "Valsuani" -BackupFirst:$false
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$TopicId,

    [string]$StorePath = "C:\stores\artrevisionist",

    [switch]$BackupFirst = $true,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# Build path to pages.json
$pagesJsonPath = Join-Path (Join-Path $StorePath $TopicId) "pages.json"

if (-not (Test-Path $pagesJsonPath)) {
    Write-Error "Pages file not found: $pagesJsonPath"
    exit 1
}

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "Reset Page Images Tool" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""
Write-Host "Topic ID: $TopicId" -ForegroundColor Yellow
Write-Host "File: $pagesJsonPath" -ForegroundColor Yellow
Write-Host "Dry Run: $DryRun" -ForegroundColor Yellow
Write-Host ""

# Create backup if requested
if ($BackupFirst -and -not $DryRun) {
    $backupPath = "$pagesJsonPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "Creating backup: $backupPath" -ForegroundColor Green
    Copy-Item $pagesJsonPath $backupPath
}

# Read the JSON file
Write-Host "Loading pages.json..." -ForegroundColor Gray
$json = Get-Content $pagesJsonPath -Raw | ConvertFrom-Json

# Counters for reporting
$stats = @{
    MainPages = 0
    DetailPages = 0
    EvidencePages = 0
    FeaturedImagesCleared = 0
    AdditionalImagesCleared = 0
}

# Function to clear images from a page object
function Clear-PageImages {
    param($page, $pageType)

    $cleared = $false

    # Clear featured image
    if ($page.FeaturedImageFilename) {
        if ($DryRun) {
            Write-Host "  Would clear featured image: $($page.FeaturedImageFilename)" -ForegroundColor DarkGray
        }
        $page.FeaturedImageFilename = $null
        $script:stats.FeaturedImagesCleared++
        $cleared = $true
    }

    # Clear additional images
    if ($page.AdditionalImages -and $page.AdditionalImages.Count -gt 0) {
        $count = $page.AdditionalImages.Count
        if ($DryRun) {
            Write-Host "  Would clear $count additional images" -ForegroundColor DarkGray
        }
        $page.AdditionalImages = @()
        $script:stats.AdditionalImagesCleared += $count
        $cleared = $true
    }

    return $cleared
}

# Process all pages
Write-Host ""
Write-Host "Processing pages..." -ForegroundColor Cyan

foreach ($mainPage in $json.Pages) {
    $stats.MainPages++
    $mainTitle = $mainPage.Title
    Write-Host "Main Page: $mainTitle" -ForegroundColor White
    Clear-PageImages -page $mainPage -pageType "main" | Out-Null

    # Process detail pages
    if ($mainPage.Details) {
        foreach ($detailPage in $mainPage.Details) {
            $stats.DetailPages++
            Write-Host "  Detail: $($detailPage.Title)" -ForegroundColor Gray
            Clear-PageImages -page $detailPage -pageType "detail" | Out-Null

            # Process evidence pages
            if ($detailPage.Evidence) {
                foreach ($evidencePage in $detailPage.Evidence) {
                    $stats.EvidencePages++
                    Write-Host "    Evidence: $($evidencePage.Title)" -ForegroundColor DarkGray
                    Clear-PageImages -page $evidencePage -pageType "evidence" | Out-Null
                }
            }
        }
    }
}

# Save the modified JSON
if (-not $DryRun) {
    Write-Host ""
    Write-Host "Saving changes..." -ForegroundColor Green
    $json | ConvertTo-Json -Depth 20 | Set-Content $pagesJsonPath -Encoding UTF8
    Write-Host "File saved successfully!" -ForegroundColor Green
}

# Print summary
Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "Main Pages processed:       $($stats.MainPages)" -ForegroundColor White
Write-Host "Detail Pages processed:     $($stats.DetailPages)" -ForegroundColor White
Write-Host "Evidence Pages processed:   $($stats.EvidencePages)" -ForegroundColor White
Write-Host "Featured Images cleared:    $($stats.FeaturedImagesCleared)" -ForegroundColor Yellow
Write-Host "Additional Images cleared:  $($stats.AdditionalImagesCleared)" -ForegroundColor Yellow
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN - No changes were made. Run without -DryRun to apply changes." -ForegroundColor Magenta
} else {
    Write-Host "All images have been cleared. Diversity counter is now reset." -ForegroundColor Green
    Write-Host "Restart the application to see the changes." -ForegroundColor Green
}

Write-Host ""
