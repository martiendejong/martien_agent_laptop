# Populate Baseline Metrics
# Quick scan to establish current state

Write-Host "Populating baseline metrics..." -ForegroundColor Cyan

# Tool count
$toolCount = (Get-ChildItem C:\scripts\tools -Filter *.ps1 -File).Count

# Documentation size
$docSizeMB = [math]::Round((Get-ChildItem C:\scripts -Filter *.md -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
$docCount = (Get-ChildItem C:\scripts -Filter *.md -Recurse).Count

# Worktree status
$worktreeContent = Get-Content C:\scripts\_machine\worktrees.pool.md
$busyWorktrees = ($worktreeContent | Select-String "BUSY").Count
$freeWorktrees = ($worktreeContent | Select-String "FREE").Count

# Git health (simplified)
Push-Location C:\Projects\client-manager
$clientManagerBranches = (git branch -r).Count
$openPRs = (gh pr list --json number 2>$null | ConvertFrom-Json).Count
Pop-Location

# Create baseline metrics
$baseline = @{
    timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    tools = @{
        total_count = $toolCount
        last_scan = "2026-02-05"
    }
    documentation = @{
        total_size_mb = $docSizeMB
        file_count = $docCount
    }
    worktrees = @{
        busy = $busyWorktrees
        free = $freeWorktrees
        total = $busyWorktrees + $freeWorktrees
    }
    git_repos = @{
        client_manager = @{
            branches = $clientManagerBranches
            open_prs = $openPRs
        }
    }
}

$outputFile = "C:\scripts\_machine\baseline-metrics.json"
$baseline | ConvertTo-Json -Depth 10 | Set-Content $outputFile

Write-Host "Baseline metrics saved to: $outputFile" -ForegroundColor Green
Write-Host "  Tools: $toolCount" -ForegroundColor Gray
Write-Host "  Docs: $docCount files ($docSizeMB MB)" -ForegroundColor Gray
Write-Host "  Worktrees: $busyWorktrees busy, $freeWorktrees free" -ForegroundColor Gray
Write-Host "  PRs: $openPRs open" -ForegroundColor Gray
