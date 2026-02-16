# Update E: drive references to C: drive for laptop deployment
# Created: 2026-02-16
# Purpose: Replace desktop E: drive paths with laptop C: drive equivalents

param(
    [switch]$DryRun
)

$replacements = @(
    @{
        Pattern = 'E:\\jengo\\documents'
        Replacement = 'C:\\jengo\\documents'
        Description = 'Update jengo documents path to C: drive'
    },
    @{
        Pattern = 'E:\\\\jengo\\\\documents'
        Replacement = 'C:\\\\jengo\\\\documents'
        Description = 'Update jengo documents path (JSON escaped) to C: drive'
    },
    @{
        Pattern = 'E:/jengo/documents'
        Replacement = 'C:/jengo/documents'
        Description = 'Update jengo documents path (forward slash) to C: drive'
    },
    @{
        Pattern = 'E:\\xampp\\htdocs'
        Replacement = 'NOT_AVAILABLE_LAPTOP'
        Description = 'Mark XAMPP paths as not available on laptop'
    },
    @{
        Pattern = 'E:\\\\xampp\\\\htdocs'
        Replacement = 'NOT_AVAILABLE_LAPTOP'
        Description = 'Mark XAMPP paths (JSON escaped) as not available on laptop'
    }
)

$files = @(
    'C:\scripts\_machine\quick-context.json',
    'C:\scripts\_machine\services-registry.json',
    'C:\scripts\_machine\projects\art-revisionist.json',
    'C:\scripts\_machine\knowledge-base\personal-domains.json',
    'C:\scripts\CLAUDE.md',
    'C:\scripts\OPERATIONAL_RULES.md',
    'C:\scripts\clickup-github-workflow.md',
    'C:\scripts\tools\wordpress-switcher-README.md',
    'C:\scripts\.claude\skills\check-task-clarity.skill.md',
    'C:\scripts\agentidentity\state\vibe-sensing-state.json',
    'C:\scripts\_machine\context-index.db.json',
    'C:\scripts\.hazina\documents\chunks.json'
)

$changesLog = @()

foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        Write-Host "⚠️  Skipping $file (not found)" -ForegroundColor Yellow
        continue
    }

    $content = Get-Content $file -Raw
    $originalContent = $content
    $fileChanged = $false

    foreach ($replacement in $replacements) {
        if ($content -match [regex]::Escape($replacement.Pattern)) {
            Write-Host "📝 $($replacement.Description) in $(Split-Path $file -Leaf)" -ForegroundColor Cyan
            $content = $content -replace [regex]::Escape($replacement.Pattern), $replacement.Replacement
            $fileChanged = $true
            $changesLog += "$file : $($replacement.Description)"
        }
    }

    if ($fileChanged) {
        if ($DryRun) {
            Write-Host "   [DRY RUN] Would update: $file" -ForegroundColor Gray
        } else {
            Set-Content -Path $file -Value $content -NoNewline
            Write-Host "   ✅ Updated: $file" -ForegroundColor Green
        }
    }
}

Write-Host "`n═══════════════════════════════════════" -ForegroundColor Magenta
Write-Host "📊 SUMMARY" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════" -ForegroundColor Magenta
Write-Host "Total changes: $($changesLog.Count)" -ForegroundColor White

if ($DryRun) {
    Write-Host "`n⚠️  DRY RUN MODE - No files were modified" -ForegroundColor Yellow
    Write-Host "Run without -DryRun to apply changes" -ForegroundColor Yellow
} else {
    Write-Host "`n✅ All E: drive references updated to C: drive" -ForegroundColor Green
}
