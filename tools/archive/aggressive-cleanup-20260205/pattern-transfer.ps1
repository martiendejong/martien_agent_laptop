<#
.SYNOPSIS
    Cross-Project Pattern Transfer (R18-001)

.DESCRIPTION
    Apply successful patterns from one project to another.
    Transfer workflows, templates, and best practices across repositories.

.PARAMETER SourceProject
    Source project name (e.g., "client-manager")

.PARAMETER TargetProject
    Target project name (e.g., "hazina")

.PARAMETER Pattern
    Pattern to transfer (e.g., "worktree-workflow", "context-intelligence")

.PARAMETER ListPatterns
    List all available patterns for transfer

.EXAMPLE
    .\pattern-transfer.ps1 -ListPatterns
    .\pattern-transfer.ps1 -SourceProject "client-manager" -TargetProject "hazina" -Pattern "worktree-workflow"

.NOTES
    Part of Round 18: Transfer Learning
    Created: 2026-02-05
#>

param(
    [string]$SourceProject = "client-manager",
    [string]$TargetProject = "",
    [string]$Pattern = "",
    [switch]$ListPatterns,
    [switch]$DryRun
)

$PatternsDir = "C:\scripts\_machine\patterns"

# Define transferable patterns
$AvailablePatterns = @{
    "worktree-workflow" = @{
        Name = "Worktree Workflow"
        Description = "Git worktree allocation and release workflow"
        Files = @(
            "worktree-workflow.md",
            "worktrees.protocol.md",
            "tools\allocate-worktree.ps1",
            "tools\release-worktree.ps1"
        )
        Adaptations = @(
            @{ Find = "client-manager"; Replace = "{{PROJECT}}" },
            @{ Find = "C:\\Projects\\client-manager"; Replace = "C:\\Projects\\{{PROJECT}}" }
        )
        Value = "Prevents main branch conflicts, enables parallel development"
    }

    "context-intelligence" = @{
        Name = "Context Intelligence System"
        Description = "Full context intelligence with predictions, reasoning, temporal analysis"
        Files = @(
            "_machine\knowledge-store.yaml",
            "tools\context-intelligence.ps1",
            "tools\reasoning-engine.ps1",
            "tools\temporal-intelligence.ps1",
            "tools\explanation-system.ps1"
        )
        Adaptations = @(
            @{ Find = "client-manager"; Replace = "{{PROJECT}}" }
        )
        Value = "Proactive context suggestions, self-improving predictions"
    }

    "git-workflow" = @{
        Name = "Git Workflow & PR Process"
        Description = "Standardized git workflow with automated PR creation"
        Files = @(
            "git-workflow.md",
            "tools\github-workflow.ps1"
        )
        Adaptations = @(
            @{ Find = "client-manager"; Replace = "{{PROJECT}}" }
        )
        Value = "Consistent PR process, automated workflows"
    }

    "ci-cd-patterns" = @{
        Name = "CI/CD Troubleshooting Patterns"
        Description = "Common CI/CD issues and solutions"
        Files = @(
            "ci-cd-troubleshooting.md"
        )
        Adaptations = @()
        Value = "Faster debugging, proven solutions"
    }

    "session-management" = @{
        Name = "Session Management & Notifications"
        Description = "Window colors, notifications, state tracking"
        Files = @(
            "session-management.md",
            "tools\session-notification.ps1"
        )
        Adaptations = @()
        Value = "Visual feedback, better awareness"
    }
}

function Show-AvailablePatterns {
    Write-Host ""
    Write-Host "📦 Available Patterns for Transfer" -ForegroundColor Cyan
    Write-Host ""

    $index = 1
    foreach ($key in $AvailablePatterns.Keys) {
        $pattern = $AvailablePatterns[$key]

        Write-Host "  $index. " -NoNewline -ForegroundColor DarkGray
        Write-Host $pattern.Name -ForegroundColor Green
        Write-Host "     $($pattern.Description)" -ForegroundColor White
        Write-Host "     Files: $($pattern.Files.Count)" -ForegroundColor DarkGray
        Write-Host "     Value: $($pattern.Value)" -ForegroundColor Cyan
        Write-Host ""

        $index++
    }

    Write-Host "💡 Usage:" -ForegroundColor Yellow
    Write-Host "   .\pattern-transfer.ps1 -Pattern `"worktree-workflow`" -TargetProject `"hazina`"" -ForegroundColor White
    Write-Host ""
}

function Transfer-Pattern {
    param($PatternKey, $Source, $Target)

    if (-not $AvailablePatterns.ContainsKey($PatternKey)) {
        Write-Host "❌ Error: Pattern not found: $PatternKey" -ForegroundColor Red
        Write-Host "   Use -ListPatterns to see available patterns" -ForegroundColor Yellow
        return
    }

    $pattern = $AvailablePatterns[$PatternKey]

    Write-Host ""
    Write-Host "🔄 Pattern Transfer" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Pattern: $($pattern.Name)" -ForegroundColor Green
    Write-Host "  Source: $Source" -ForegroundColor White
    Write-Host "  Target: $Target" -ForegroundColor White
    Write-Host ""

    if ($DryRun) {
        Write-Host "  🔍 DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
        Write-Host ""
    }

    # Show what will be transferred
    Write-Host "  📋 Files to transfer:" -ForegroundColor Cyan
    foreach ($file in $pattern.Files) {
        $sourcePath = "C:\scripts\$file"
        Write-Host "     - $file" -ForegroundColor White

        if (-not (Test-Path $sourcePath)) {
            Write-Host "       ⚠️  Not found in source" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "  🔧 Adaptations to apply:" -ForegroundColor Cyan
    foreach ($adaptation in $pattern.Adaptations) {
        $find = $adaptation.Find
        $replace = $adaptation.Replace -replace "{{PROJECT}}", $Target
        Write-Host "     - Replace: '$find' → '$replace'" -ForegroundColor White
    }

    Write-Host ""

    if ($DryRun) {
        Write-Host "  ✅ Dry run complete - review changes above" -ForegroundColor Green
        Write-Host "  💡 Remove -DryRun to apply changes" -ForegroundColor Cyan
        return
    }

    # Confirm before proceeding
    Write-Host "  ⚠️  This will create/modify files in target project" -ForegroundColor Yellow
    Write-Host "     Continue? (Y/N): " -NoNewline -ForegroundColor White
    $confirm = Read-Host

    if ($confirm -ne "Y" -and $confirm -ne "y") {
        Write-Host "  ❌ Transfer cancelled" -ForegroundColor Red
        return
    }

    Write-Host ""
    Write-Host "  🚀 Transferring pattern..." -ForegroundColor Green
    Write-Host ""

    # Perform the transfer
    $transferred = 0
    $skipped = 0

    foreach ($file in $pattern.Files) {
        $sourcePath = "C:\scripts\$file"

        if (-not (Test-Path $sourcePath)) {
            Write-Host "     ⚠️  Skipped: $file (not found)" -ForegroundColor Yellow
            $skipped++
            continue
        }

        # Read source content
        $content = Get-Content $sourcePath -Raw

        # Apply adaptations
        foreach ($adaptation in $pattern.Adaptations) {
            $find = $adaptation.Find
            $replace = $adaptation.Replace -replace "{{PROJECT}}", $Target
            $content = $content -replace [regex]::Escape($find), $replace
        }

        # Determine target path
        $targetPath = $sourcePath -replace "client-manager", $Target

        # For this demo, we'll save to a transfer directory
        $transferDir = "C:\scripts\_machine\pattern-transfers\$Target"
        if (-not (Test-Path $transferDir)) {
            New-Item -Path $transferDir -ItemType Directory -Force | Out-Null
        }

        $targetFile = Join-Path $transferDir (Split-Path $file -Leaf)

        # Write adapted content
        $content | Set-Content $targetFile -Force

        Write-Host "     ✅ Transferred: $file" -ForegroundColor Green
        $transferred++
    }

    Write-Host ""
    Write-Host "  📊 Transfer Summary:" -ForegroundColor Cyan
    Write-Host "     Transferred: $transferred files" -ForegroundColor Green
    if ($skipped -gt 0) {
        Write-Host "     Skipped: $skipped files" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "  📁 Files saved to: $transferDir" -ForegroundColor White
    Write-Host ""
    Write-Host "  💡 Next Steps:" -ForegroundColor Yellow
    Write-Host "     1. Review transferred files" -ForegroundColor White
    Write-Host "     2. Copy to target project: C:\Projects\$Target" -ForegroundColor White
    Write-Host "     3. Test in target environment" -ForegroundColor White
    Write-Host "     4. Adjust as needed for target-specific requirements" -ForegroundColor White
    Write-Host ""

    # Create transfer report
    $report = @{
        timestamp = Get-Date -Format "o"
        pattern = $PatternKey
        source = $Source
        target = $Target
        files_transferred = $transferred
        files_skipped = $skipped
        transfer_dir = $transferDir
    }

    $reportFile = Join-Path $transferDir "transfer-report.json"
    $report | ConvertTo-Json | Set-Content $reportFile -Force

    Write-Host "  📝 Transfer report saved: $reportFile" -ForegroundColor Cyan
    Write-Host ""
}

# Main execution
if ($ListPatterns) {
    Show-AvailablePatterns
}
elseif ($Pattern -and $TargetProject) {
    Transfer-Pattern $Pattern $SourceProject $TargetProject
}
else {
    Write-Host ""
    Write-Host "🔄 Cross-Project Pattern Transfer" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  -ListPatterns                 Show all available patterns" -ForegroundColor White
    Write-Host "  -Pattern <name>               Pattern to transfer" -ForegroundColor White
    Write-Host "  -TargetProject <name>         Target project name" -ForegroundColor White
    Write-Host "  -DryRun                       Preview changes without applying" -ForegroundColor White
    Write-Host ""
    Write-Host "Example:" -ForegroundColor Yellow
    Write-Host "  .\pattern-transfer.ps1 -ListPatterns" -ForegroundColor Cyan
    Write-Host "  .\pattern-transfer.ps1 -Pattern `"worktree-workflow`" -TargetProject `"hazina`" -DryRun" -ForegroundColor Cyan
    Write-Host ""
}
