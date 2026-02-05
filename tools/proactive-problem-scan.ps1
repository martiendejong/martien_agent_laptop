# Proactive Problem Scanner
# Find and solve problems before user notices them

param(
    [switch]$Scan,
    [switch]$Report,
    [switch]$AutoFix,
    [string[]]$Categories = @("git", "docs", "worktrees", "tools", "ci")
)

$scanResultFile = "C:\scripts\_machine\proactive-scan-results.json"

function Scan-GitHealth {
    $issues = @()

    $repos = @("C:\Projects\client-manager", "C:\Projects\hazina", "C:\Projects\art-revisionist")

    foreach ($repo in $repos) {
        if (!(Test-Path $repo)) { continue }

        Push-Location $repo

        # Check for uncommitted changes on develop
        $currentBranch = git branch --show-current
        if ($currentBranch -eq "develop") {
            $uncommitted = git status --short
            if ($uncommitted) {
                $issues += @{
                    category = "git"
                    severity = "medium"
                    repo = $repo
                    issue = "Uncommitted changes on develop branch"
                    autofix = "Stash changes or commit them"
                }
            }
        }

        # Check for stale branches (no commits in 60+ days)
        $branches = git branch -r --format="%(refname:short)|%(committerdate:unix)"
        $now = [DateTimeOffset]::Now.ToUnixTimeSeconds()

        foreach ($branchInfo in $branches) {
            $parts = $branchInfo -split '\|'
            if ($parts.Count -ne 2) { continue }

            $branch = $parts[0]
            $lastCommit = [int]$parts[1]
            $daysSinceCommit = ($now - $lastCommit) / 86400

            if ($daysSinceCommit -gt 60) {
                $issues += @{
                    category = "git"
                    severity = "low"
                    repo = $repo
                    issue = "Stale branch: $branch ($([math]::Round($daysSinceCommit, 0)) days old)"
                    autofix = "Delete if merged, otherwise investigate"
                }
            }
        }

        # Check for unmerged PRs
        $openPRs = gh pr list --json number,title,updatedAt 2>$null | ConvertFrom-Json
        foreach ($pr in $openPRs) {
            $updated = [DateTime]::Parse($pr.updatedAt)
            $daysSinceUpdate = (New-TimeSpan -Start $updated -End (Get-Date)).Days

            if ($daysSinceUpdate -gt 14) {
                $issues += @{
                    category = "git"
                    severity = "medium"
                    repo = $repo
                    issue = "Stale PR #$($pr.number): $($pr.title) (no activity for $daysSinceUpdate days)"
                    autofix = "Review and merge or close"
                }
            }
        }

        Pop-Location
    }

    return $issues
}

function Scan-DocumentationHealth {
    $issues = @()

    # Check for large files
    $largeDocs = Get-ChildItem -Path "C:\scripts" -Filter "*.md" -Recurse | Where-Object { $_.Length -gt 256KB }

    foreach ($doc in $largeDocs) {
        $sizeKB = [math]::Round($doc.Length / 1KB, 1)
        $issues += @{
            category = "docs"
            severity = "medium"
            issue = "Large documentation file: $($doc.Name) ($sizeKB KB)"
            path = $doc.FullName
            autofix = "Split into smaller files or archive"
        }
    }

    # Check for broken links (simplified)
    $claudeMd = "C:\scripts\CLAUDE.md"
    if (Test-Path $claudeMd) {
        $content = Get-Content $claudeMd -Raw
        $linkedFiles = [regex]::Matches($content, '\[.*?\]\((\.\/.*?\.md)\)') | ForEach-Object { $_.Groups[1].Value }

        foreach ($link in $linkedFiles) {
            $fullPath = Join-Path "C:\scripts" $link.TrimStart('./', '\')
            if (!(Test-Path $fullPath)) {
                $issues += @{
                    category = "docs"
                    severity = "high"
                    issue = "Broken link in CLAUDE.md: $link"
                    autofix = "Fix or remove link"
                }
            }
        }
    }

    return $issues
}

function Scan-WorktreeHealth {
    $issues = @()

    $poolFile = "C:\scripts\_machine\worktrees.pool.md"
    if (!(Test-Path $poolFile)) {
        return $issues
    }

    $content = Get-Content $poolFile -Raw

    # Check for BUSY seats older than 2 hours
    $lines = Get-Content $poolFile
    foreach ($line in $lines) {
        if ($line -like "*| BUSY |*") {
            # Extract timestamp
            if ($line -match '\| (\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z) \|') {
                $timestamp = [DateTime]::Parse($matches[1])
                $hoursSinceBusy = (New-TimeSpan -Start $timestamp -End (Get-Date)).TotalHours

                if ($hoursSinceBusy -gt 2) {
                    $issues += @{
                        category = "worktrees"
                        severity = "high"
                        issue = "Stale BUSY worktree (busy for $([math]::Round($hoursSinceBusy, 1)) hours)"
                        autofix = "Investigate and release if abandoned"
                    }
                }
            }
        }
    }

    return $issues
}

function Scan-ToolHealth {
    $issues = @()

    # Check for tools that haven't been accessed in 60+ days
    $tools = Get-ChildItem -Path "C:\scripts\tools" -Filter "*.ps1" -File

    foreach ($tool in $tools) {
        $daysSinceAccess = (New-TimeSpan -Start $tool.LastAccessTime -End (Get-Date)).Days

        if ($daysSinceAccess -gt 60) {
            $issues += @{
                category = "tools"
                severity = "low"
                issue = "Unused tool: $($tool.Name) (last accessed $daysSinceAccess days ago)"
                autofix = "Archive if truly unused"
            }
        }
    }

    return $issues
}

function Scan-CIHealth {
    $issues = @()

    $repos = @("C:\Projects\client-manager")

    foreach ($repo in $repos) {
        if (!(Test-Path $repo)) { continue }

        Push-Location $repo

        # Check recent workflow failures
        $workflows = gh run list --limit 10 --json conclusion,name,createdAt 2>$null | ConvertFrom-Json

        $recentFailures = $workflows | Where-Object { $_.conclusion -eq "failure" }

        if ($recentFailures.Count -gt 3) {
            $issues += @{
                category = "ci"
                severity = "high"
                repo = $repo
                issue = "$($recentFailures.Count) recent CI failures"
                autofix = "Investigate and fix build issues"
            }
        }

        Pop-Location
    }

    return $issues
}

function Run-ProactiveScan {
    param($Categories)

    Write-Host "🔍 Running proactive problem scan..." -ForegroundColor Cyan

    $allIssues = @()

    if ($Categories -contains "git") {
        Write-Host "  → Scanning git health..." -ForegroundColor Gray
        $allIssues += Scan-GitHealth
    }

    if ($Categories -contains "docs") {
        Write-Host "  → Scanning documentation health..." -ForegroundColor Gray
        $allIssues += Scan-DocumentationHealth
    }

    if ($Categories -contains "worktrees") {
        Write-Host "  → Scanning worktree health..." -ForegroundColor Gray
        $allIssues += Scan-WorktreeHealth
    }

    if ($Categories -contains "tools") {
        Write-Host "  → Scanning tool health..." -ForegroundColor Gray
        $allIssues += Scan-ToolHealth
    }

    if ($Categories -contains "ci") {
        Write-Host "  → Scanning CI/CD health..." -ForegroundColor Gray
        $allIssues += Scan-CIHealth
    }

    $scanResults = @{
        timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        issues = $allIssues
        summary = @{
            total = $allIssues.Count
            high = ($allIssues | Where-Object { $_.severity -eq "high" }).Count
            medium = ($allIssues | Where-Object { $_.severity -eq "medium" }).Count
            low = ($allIssues | Where-Object { $_.severity -eq "low" }).Count
        }
    }

    $scanResults | ConvertTo-Json -Depth 10 | Set-Content $scanResultFile

    Write-Host "✅ Scan complete" -ForegroundColor Green
    return $scanResults
}

function Show-ScanReport {
    if (!(Test-Path $scanResultFile)) {
        Write-Host "⚠️ No scan results. Run with -Scan first." -ForegroundColor Yellow
        return
    }

    $results = Get-Content $scanResultFile | ConvertFrom-Json

    Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "🔍 PROACTIVE PROBLEM SCAN REPORT" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan

    Write-Host "`nSUMMARY:"
    Write-Host "  Total issues found: $($results.summary.total)"
    Write-Host "  High severity: $($results.summary.high)" -ForegroundColor Red
    Write-Host "  Medium severity: $($results.summary.medium)" -ForegroundColor Yellow
    Write-Host "  Low severity: $($results.summary.low)" -ForegroundColor Gray

    if ($results.issues.Count -eq 0) {
        Write-Host "`n✅ No issues found - system is healthy!" -ForegroundColor Green
        Write-Host "`n═══════════════════════════════════════════════`n" -ForegroundColor Cyan
        return
    }

    Write-Host "`nISSUES FOUND:`n"

    $grouped = $results.issues | Group-Object -Property category

    foreach ($group in $grouped) {
        Write-Host "📁 $($group.Name.ToUpper()):" -ForegroundColor Cyan

        foreach ($issue in $group.Group) {
            $icon = switch ($issue.severity) {
                "high" { "🔴" }
                "medium" { "🟡" }
                "low" { "⚪" }
            }

            Write-Host "  $icon $($issue.issue)"
            if ($issue.autofix) {
                Write-Host "     💡 Autofix: $($issue.autofix)" -ForegroundColor Gray
            }
        }
        Write-Host ""
    }

    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Cyan
}

# Main execution
if ($Scan) {
    $results = Run-ProactiveScan -Categories $Categories
    Show-ScanReport
}
elseif ($Report) {
    Show-ScanReport
}
elseif ($AutoFix) {
    Write-Host "⚠️ AutoFix not yet implemented (safety first)" -ForegroundColor Yellow
    Write-Host "   Review issues manually with -Report, then fix individually" -ForegroundColor Gray
}
else {
    Write-Host "PROACTIVE PROBLEM SCANNER" -ForegroundColor Cyan
    Write-Host "Usage:"
    Write-Host "  Scan: .\proactive-problem-scan.ps1 -Scan [-Categories git,docs,worktrees,tools,ci]"
    Write-Host "  Report: .\proactive-problem-scan.ps1 -Report"
    Write-Host "  AutoFix: .\proactive-problem-scan.ps1 -AutoFix (coming soon)"
}
