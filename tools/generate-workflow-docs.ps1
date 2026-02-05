<#
.SYNOPSIS
    Generate workflow documentation from git history

.DESCRIPTION
    Analyzes git commit messages and PR descriptions to generate
    workflow documentation showing how features were developed.

    Groups commits by:
    - Feature (feat: commits)
    - Bug fixes (fix: commits)
    - Documentation (docs: commits)
    - Refactoring (refactor: commits)

.PARAMETER Repository
    Path to git repository (default: C:\Projects\client-manager)

.PARAMETER Since
    Generate docs for commits since this date (default: 30 days ago)

.PARAMETER OutputPath
    Where to save generated documentation

.EXAMPLE
    .\generate-workflow-docs.ps1 -Repository "C:\Projects\client-manager" -OutputPath "workflows.md"

.EXAMPLE
    .\generate-workflow-docs.ps1 -Since "2026-01-01" -OutputPath "jan-workflows.md"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Repository = "C:\Projects\client-manager",

    [Parameter(Mandatory=$false)]
    [string]$Since = (Get-Date).AddDays(-30).ToString("yyyy-MM-dd"),

    [Parameter(Mandatory=$true)]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Workflow Documentation Generator" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $Repository)) {
    Write-Host "❌ Repository not found: $Repository" -ForegroundColor Red
    exit 1
}

Push-Location $Repository

try {
    Write-Host "📚 Analyzing git history since $Since..." -ForegroundColor Cyan

    # Get commit log
    $gitLog = git log --since="$Since" --pretty=format:"%H|%an|%ad|%s" --date=short

    if (-not $gitLog) {
        Write-Host "⚠️ No commits found since $Since" -ForegroundColor Yellow
        exit 0
    }

    $commits = $gitLog -split "`n" | ForEach-Object {
        $parts = $_ -split '\|'
        if ($parts.Count -eq 4) {
            [PSCustomObject]@{
                Hash = $parts[0]
                Author = $parts[1]
                Date = $parts[2]
                Message = $parts[3]
            }
        }
    } | Where-Object { $_ -ne $null }

    Write-Host "  Found $($commits.Count) commits" -ForegroundColor Gray
    Write-Host ""

    # Categorize commits
    $features = $commits | Where-Object { $_.Message -match '^feat:' }
    $fixes = $commits | Where-Object { $_.Message -match '^fix:' }
    $docs = $commits | Where-Object { $_.Message -match '^docs:' }
    $refactor = $commits | Where-Object { $_.Message -match '^refactor:' }
    $other = $commits | Where-Object { $_.Message -notmatch '^(feat|fix|docs|refactor):' }

    # Generate documentation
    $doc = @"
# Workflow Documentation

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Repository:** ``$Repository``
**Period:** $Since to $(Get-Date -Format "yyyy-MM-dd")
**Total Commits:** $($commits.Count)

---

## Summary

- **Features Added:** $($features.Count)
- **Bugs Fixed:** $($fixes.Count)
- **Documentation Updates:** $($docs.Count)
- **Refactorings:** $($refactor.Count)
- **Other Changes:** $($other.Count)

---

"@

    # Document features
    if ($features.Count -gt 0) {
        $doc += "## Features Added`n`n"
        foreach ($commit in ($features | Sort-Object Date -Descending)) {
            $message = $commit.Message -replace '^feat:\s*', ''
            $doc += "### $message`n`n"
            $doc += "- **Date:** $($commit.Date)`n"
            $doc += "- **Author:** $($commit.Author)`n"
            $doc += "- **Commit:** ``$($commit.Hash.Substring(0,7))```n`n"

            # Get commit details
            $details = git show --stat --format="" $commit.Hash
            if ($details) {
                $doc += "**Files Changed:**`n````````n$details`n```````n`n"
            }
        }
        $doc += "---`n`n"
    }

    # Document bug fixes
    if ($fixes.Count -gt 0) {
        $doc += "## Bug Fixes`n`n"
        foreach ($commit in ($fixes | Sort-Object Date -Descending)) {
            $message = $commit.Message -replace '^fix:\s*', ''
            $doc += "- **$($commit.Date)**: $message (``$($commit.Hash.Substring(0,7))``) - $($commit.Author)`n"
        }
        $doc += "`n---`n`n"
    }

    # Document refactorings
    if ($refactor.Count -gt 0) {
        $doc += "## Refactorings`n`n"
        foreach ($commit in ($refactor | Sort-Object Date -Descending)) {
            $message = $commit.Message -replace '^refactor:\s*', ''
            $doc += "- **$($commit.Date)**: $message (``$($commit.Hash.Substring(0,7))``) - $($commit.Author)`n"
        }
        $doc += "`n---`n`n"
    }

    # Document documentation changes
    if ($docs.Count -gt 0) {
        $doc += "## Documentation Updates`n`n"
        foreach ($commit in ($docs | Sort-Object Date -Descending)) {
            $message = $commit.Message -replace '^docs:\s*', ''
            $doc += "- **$($commit.Date)**: $message (``$($commit.Hash.Substring(0,7))``)`n"
        }
        $doc += "`n---`n`n"
    }

    # Timeline visualization
    $doc += "## Timeline`n`n````mermaid`n"
    $doc += "gantt`n"
    $doc += "    title Development Timeline`n"
    $doc += "    dateFormat YYYY-MM-DD`n"
    $doc += "    section Features`n"

    foreach ($commit in ($features | Select-Object -First 10)) {
        $message = ($commit.Message -replace '^feat:\s*', '').Substring(0, [Math]::Min(30, ($commit.Message.Length)))
        $doc += "    $message :$($commit.Date), 1d`n"
    }

    $doc += "```````n`n"

    $doc += "---`n`n*Generated by generate-workflow-docs.ps1*`n"

    # Save documentation
    $doc | Set-Content $OutputPath -Encoding UTF8

    Write-Host "✅ Workflow documentation generated: $OutputPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Statistics:" -ForegroundColor Cyan
    Write-Host "  - Features: $($features.Count)" -ForegroundColor Gray
    Write-Host "  - Bug fixes: $($fixes.Count)" -ForegroundColor Gray
    Write-Host "  - Refactorings: $($refactor.Count)" -ForegroundColor Gray
    Write-Host "  - Documentation lines: $($doc -split "`n" | Measure-Object | Select-Object -ExpandProperty Count)" -ForegroundColor Gray
    Write-Host ""
}
finally {
    Pop-Location
}
