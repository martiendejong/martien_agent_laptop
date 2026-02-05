# Radical Documentation Pruning
# Delete or archive 50% of unused documentation

param(
    [switch]$Analyze,
    [switch]$Execute,
    [int]$UnusedDaysThreshold = 30,
    [switch]$DryRun
)

$scriptsRoot = "C:\scripts"
$archiveRoot = "C:\scripts\_machine\doc-archive\$(Get-Date -Format 'yyyy-MM-dd')"

function Get-DocumentationHealth {
    Write-Host "🔍 Scanning all markdown files..." -ForegroundColor Cyan

    $allMdFiles = Get-ChildItem -Path $scriptsRoot -Filter "*.md" -Recurse -File

    $analysis = @()

    foreach ($file in $allMdFiles) {
        $relativePath = $file.FullName.Replace($scriptsRoot, "").TrimStart('\')

        # Skip archive directories
        if ($relativePath -like "*archive*") { continue }

        $daysSinceModified = (New-TimeSpan -Start $file.LastWriteTime -End (Get-Date)).Days
        $daysSinceAccessed = (New-TimeSpan -Start $file.LastAccessTime -End (Get-Date)).Days
        $sizeKB = [math]::Round($file.Length / 1KB, 1)

        # Count references in other files
        $references = 0
        $allMdFiles | ForEach-Object {
            $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
            if ($content -and $content -like "*$($file.BaseName)*") {
                $references++
            }
        }

        # Check if it's in CLAUDE.md startup protocol or SYSTEM_INDEX.md
        $isEssential = $false
        $claudeMd = Join-Path $scriptsRoot "CLAUDE.md"
        $systemIndex = Join-Path $scriptsRoot "SYSTEM_INDEX.md"

        if ((Test-Path $claudeMd) -and ((Get-Content $claudeMd -Raw) -like "*$($file.BaseName)*")) {
            $isEssential = $true
        }
        if ((Test-Path $systemIndex) -and ((Get-Content $systemIndex -Raw) -like "*$($file.BaseName)*")) {
            $isEssential = $true
        }

        # Calculate health score
        $healthScore = 0
        $healthScore += [math]::Max(0, 100 - $daysSinceAccessed)
        $healthScore += ($references * 10)
        $healthScore += if ($isEssential) { 100 } else { 0 }
        $healthScore += if ($daysSinceModified -le 7) { 50 } else { 0 }

        $analysis += [PSCustomObject]@{
            Path = $relativePath
            FullPath = $file.FullName
            SizeKB = $sizeKB
            DaysSinceAccessed = $daysSinceAccessed
            DaysSinceModified = $daysSinceModified
            References = $references
            IsEssential = $isEssential
            HealthScore = $healthScore
            Recommendation = if ($isEssential) { "KEEP" }
                            elseif ($healthScore -lt 20 -and $daysSinceAccessed -gt $UnusedDaysThreshold) { "ARCHIVE" }
                            elseif ($healthScore -lt 50) { "REVIEW" }
                            else { "KEEP" }
        }
    }

    return $analysis
}

function Show-PruningAnalysis {
    param($Analysis)

    $totalFiles = $Analysis.Count
    $totalSizeKB = ($Analysis | Measure-Object -Property SizeKB -Sum).Sum
    $toArchive = ($Analysis | Where-Object { $_.Recommendation -eq "ARCHIVE" }).Count
    $toReview = ($Analysis | Where-Object { $_.Recommendation -eq "REVIEW" }).Count
    $toKeep = ($Analysis | Where-Object { $_.Recommendation -eq "KEEP" }).Count

    $archiveSizeKB = ($Analysis | Where-Object { $_.Recommendation -eq "ARCHIVE" } | Measure-Object -Property SizeKB -Sum).Sum

    Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "📊 DOCUMENTATION HEALTH ANALYSIS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan

    Write-Host "`nOVERALL STATISTICS:"
    Write-Host "  Total markdown files: $totalFiles"
    Write-Host "  Total size: $([math]::Round($totalSizeKB/1024, 1)) MB"
    Write-Host "  To archive: $toArchive ($([math]::Round(($toArchive/$totalFiles)*100, 1))%)"
    Write-Host "  To review: $toReview ($([math]::Round(($toReview/$totalFiles)*100, 1))%)"
    Write-Host "  To keep: $toKeep ($([math]::Round(($toKeep/$totalFiles)*100, 1))%)"
    Write-Host "  Space savings: $([math]::Round($archiveSizeKB/1024, 1)) MB"

    Write-Host "`nTOP 10 FILES TO ARCHIVE (lowest health score):"
    $Analysis | Where-Object { $_.Recommendation -eq "ARCHIVE" } | Sort-Object -Property HealthScore | Select-Object -First 10 | ForEach-Object {
        Write-Host "  🔴 $($_.Path) (score: $([math]::Round($_.HealthScore, 0)), last accessed: $($_.DaysSinceAccessed) days ago, size: $($_.SizeKB) KB)"
    }

    Write-Host "`nTOP 10 MOST ESSENTIAL FILES (highest health score):"
    $Analysis | Sort-Object -Property HealthScore -Descending | Select-Object -First 10 | ForEach-Object {
        $icon = if ($_.IsEssential) { "⭐" } else { "🟢" }
        Write-Host "  $icon $($_.Path) (score: $([math]::Round($_.HealthScore, 0)), refs: $($_.References))"
    }

    Write-Host "`nRECOMMENDATIONS:"
    if ($toArchive -gt ($totalFiles * 0.4)) {
        Write-Host "  ⚠️ DOCUMENTATION BLOAT: $([math]::Round(($toArchive/$totalFiles)*100, 1))% can be archived" -ForegroundColor Yellow
        Write-Host "  → Run with -Execute to archive unused files"
    }
    elseif ($toArchive -gt 0) {
        Write-Host "  ✓ Moderate cleanup opportunity: $toArchive files can be archived" -ForegroundColor Green
    }
    else {
        Write-Host "  ✅ Documentation is healthy" -ForegroundColor Green
    }

    Write-Host "`n═══════════════════════════════════════════════`n" -ForegroundColor Cyan
}

function Invoke-DocumentationPruning {
    param($Analysis, $DryRun)

    $toArchive = $Analysis | Where-Object { $_.Recommendation -eq "ARCHIVE" }

    if ($toArchive.Count -eq 0) {
        Write-Host "✅ No files to archive" -ForegroundColor Green
        return
    }

    if (!$DryRun) {
        New-Item -ItemType Directory -Path $archiveRoot -Force | Out-Null
    }

    Write-Host "📦 Archiving $($toArchive.Count) unused documentation files..." -ForegroundColor Yellow

    foreach ($file in $toArchive) {
        $relativePath = $file.Path
        $destPath = Join-Path $archiveRoot $relativePath
        $destDir = Split-Path $destPath -Parent

        if ($DryRun) {
            Write-Host "  [DRY RUN] Would archive: $relativePath" -ForegroundColor Gray
        }
        else {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            Move-Item -Path $file.FullPath -Destination $destPath -Force
            Write-Host "  → Archived: $relativePath"
        }
    }

    if (!$DryRun) {
        Write-Host "`n✅ Archived $($toArchive.Count) files to $archiveRoot" -ForegroundColor Green
    }
    else {
        Write-Host "`n✓ Dry run complete. Run without -DryRun to execute." -ForegroundColor Green
    }
}

# Main execution
if ($Analyze -or $Execute) {
    $analysis = Get-DocumentationHealth
    Show-PruningAnalysis -Analysis $analysis

    if ($Execute) {
        Write-Host "`n❓ Proceed with archiving? (Y/N): " -NoNewline -ForegroundColor Yellow
        $confirmation = Read-Host

        if ($confirmation -eq "Y" -or $confirmation -eq "y") {
            Invoke-DocumentationPruning -Analysis $analysis -DryRun:$DryRun
        }
        else {
            Write-Host "❌ Pruning cancelled" -ForegroundColor Red
        }
    }
}
else {
    Write-Host "DOCUMENTATION PRUNING TOOL" -ForegroundColor Cyan
    Write-Host "Usage:"
    Write-Host "  Analyze: .\doc-pruning.ps1 -Analyze"
    Write-Host "  Execute: .\doc-pruning.ps1 -Execute [-DryRun] [-UnusedDaysThreshold 30]"
}
