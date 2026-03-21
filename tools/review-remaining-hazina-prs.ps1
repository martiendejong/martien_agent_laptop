# Review and merge remaining 3 Hazina PRs
$ErrorActionPreference = "Continue"

$prs = @(
    @{
        Number = 243
        Branch = "hazina-phase1-architecture-audit"
        Worktree = "C:/Projects/hazina-worktrees/pr-243-phase1"
        TaskId = "869cfzy8a"
        BuildTest = $false  # Documentation only
    },
    @{
        Number = 251
        Branch = "feature/upgrade-semantickernel-869cjgt43"
        Worktree = "C:/Projects/hazina-worktrees/pr-251-upgrade-sk"
        TaskId = "869cjgt43"
        BuildTest = $true
    },
    @{
        Number = 249
        Branch = "feature/transactional-updates-869cabf4y"
        Worktree = "C:/Projects/hazina-worktrees/pr-249-transactional"
        TaskId = "869cabf4y"
        BuildTest = $true
    }
)

foreach ($pr in $prs) {
    Write-Host "`n$('=' * 80)"
    Write-Host "Processing PR #$($pr.Number)"
    Write-Host "$('=' * 80)"

    # Allocate worktree
    Write-Host "`n[1/5] Allocating worktree..."
    Set-Location C:/Projects/hazina
    git worktree add $pr.Worktree $pr.Branch
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to allocate worktree"
        continue
    }

    # Merge develop
    Write-Host "`n[2/5] Merging develop..."
    Set-Location $pr.Worktree
    git fetch origin develop
    git merge origin/develop --no-edit
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Merge conflicts detected"
        continue
    }

    # Build test (if applicable)
    if ($pr.BuildTest) {
        Write-Host "`n[3/5] Testing build..."
        $testProject = Get-ChildItem -Recurse -Filter "*.csproj" | Select-Object -First 1
        if ($testProject) {
            dotnet build $testProject.FullName --nologo | Select-Object -Last 5
            if ($LASTEXITCODE -ne 0) {
                Write-Host "ERROR: Build failed"
                continue
            }
        }
    } else {
        Write-Host "`n[3/5] Skipping build test (documentation only)"
    }

    # Merge PR
    Write-Host "`n[4/5] Merging PR..."
    Set-Location C:/Projects/hazina
    $env:NO_COLOR = "1"
    gh pr merge $pr.Number --merge --delete-branch
    $merged = gh pr view $pr.Number --json state -q ".state"
    if ($merged -ne "MERGED") {
        Write-Host "ERROR: PR not merged"
        continue
    }

    # Cleanup worktree
    Write-Host "`n[5/5] Cleaning up..."
    git worktree remove $pr.Worktree -f
    git branch -D $pr.Branch 2>$null

    Write-Host "`n[OK] PR #$($pr.Number) completed successfully"
}

Write-Host "`n$('=' * 80)"
Write-Host "ALL PRS PROCESSED"
Write-Host "$('=' * 80)"
