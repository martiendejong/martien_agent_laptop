# Archive Bulk Documentation - Mass cleanup
# Keep essential docs, archive auto-generated ones

$scriptsDir = "C:\scripts"
$archiveDir = "C:\scripts\_machine\doc-archive\mega-iteration-bulk-20260206"

# Create archive directory
New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null

# Essential docs to ALWAYS KEEP (core system)
$keepDocs = @(
    "CLAUDE.md",
    "MACHINE_CONFIG.md",
    "SYSTEM_INDEX.md",
    "NETWORK_MAP.md",
    "worktree-workflow.md",
    "git-workflow.md",
    "MANDATORY_CODE_WORKFLOW.md",
    "GENERAL_ZERO_TOLERANCE_RULES.md",
    "GENERAL_DUAL_MODE_WORKFLOW.md",
    "scripts.md",
    "QUICK_LAUNCHERS.md",
    "clickup-github-workflow.md",
    "development-patterns.md",
    "ci-cd-troubleshooting.md",
    "continuous-improvement.md",
    "session-management.md",
    "README.md"
)

# Essential directories to KEEP completely
$keepDirs = @(
    "docs",
    "agentidentity",
    "agents",
    ".claude"
)

# Get all MD files (exclude already archived)
$allDocs = Get-ChildItem -Path $scriptsDir -Filter "*.md" -File -Recurse | Where-Object {
    $_.FullName -notlike "*archive*" -and
    $_.FullName -notlike "*node_modules*"
}

$totalDocs = $allDocs.Count
$keepCount = 0
$archiveCount = 0

Write-Host "Starting bulk documentation archive..." -ForegroundColor Cyan
Write-Host "Total docs: $totalDocs"

foreach ($doc in $allDocs) {
    $shouldKeep = $false
    $relativePath = $doc.FullName.Replace($scriptsDir, "").TrimStart('\')

    # Keep if explicitly listed
    if ($keepDocs -contains $doc.Name) {
        $shouldKeep = $true
    }

    # Keep if in essential directory
    foreach ($keepDir in $keepDirs) {
        if ($relativePath -like "$keepDir\*" -or $relativePath -like "$keepDir/*") {
            $shouldKeep = $true
            break
        }
    }

    # Keep if older than 5 days (established docs)
    $age = (New-TimeSpan -Start $doc.LastWriteTime -End (Get-Date)).Days
    if ($age -gt 5) {
        $shouldKeep = $true
    }

    # Keep if in _machine and is a core file
    if ($relativePath -like "_machine\*.md") {
        $coreFiles = @("reflection.log.md", "PERSONAL_INSIGHTS.md", "worktrees.pool.md", "pr-dependencies.md", "ENDGAME_VISION.md", "baseline-metrics.json")
        if ($coreFiles -contains $doc.Name) {
            $shouldKeep = $true
        }
    }

    if ($shouldKeep) {
        $keepCount++
    } else {
        # Archive it
        $destPath = Join-Path $archiveDir $doc.Name
        # Handle duplicates
        $counter = 1
        while (Test-Path $destPath) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($doc.Name)
            $ext = [System.IO.Path]::GetExtension($doc.Name)
            $destPath = Join-Path $archiveDir "$baseName-$counter$ext"
            $counter++
        }
        Move-Item -Path $doc.FullName -Destination $destPath -Force
        $archiveCount++
    }
}

Write-Host "`nArchive complete!" -ForegroundColor Green
Write-Host "  Kept: $keepCount docs"
Write-Host "  Archived: $archiveCount docs"
Write-Host "  Archive location: $archiveDir"
