<#
.SYNOPSIS
Pre-task code audit - Checks if work matching task description already exists

.DESCRIPTION
Before allocating a worktree for a ClickUp task, this script searches the codebase
to determine if the feature/fix is already implemented. Saves agent time by preventing
duplicate work on already-complete tasks.

.PARAMETER TaskId
ClickUp task ID (e.g., "869bz3h0w")

.PARAMETER TaskDescription
Task description or title (for keyword extraction)

.PARAMETER SearchPaths
Array of paths to search (default: client-manager, hazina)

.EXAMPLE
.\task-discovery-scan.ps1 -TaskId "869bz3h0w" -TaskDescription "Implement social login with Google and Facebook"

.OUTPUTS
JSON object with:
- found: boolean (true if implementation likely exists)
- confidence: 0-100 (how confident we are)
- evidence: array of evidence (files, PRs, branches, commits)
- recommendation: "implement" | "verify" | "close"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId,

    [Parameter(Mandatory=$true)]
    [string]$TaskDescription,

    [Parameter(Mandatory=$false)]
    [string[]]$SearchPaths = @("C:\Projects\client-manager", "C:\Projects\hazina")
)

$ErrorActionPreference = "Stop"

# Extract keywords from task description
function Extract-Keywords {
    param([string]$text)

    # Remove common words
    $stopWords = @("the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by", "from", "up", "about", "into", "through", "during")

    # Extract meaningful words (3+ chars, not stop words)
    $words = $text -split '\W+' | Where-Object {
        $_.Length -ge 3 -and $stopWords -notcontains $_.ToLower()
    } | Select-Object -First 10

    return $words
}

# Search for code matching keywords
function Search-Code {
    param([string[]]$keywords, [string[]]$paths)

    $evidence = @()

    foreach ($path in $paths) {
        foreach ($keyword in $keywords) {
            # Search files
            $files = Get-ChildItem -Path $path -Recurse -File -Include *.cs,*.tsx,*.ts,*.js |
                     Select-String -Pattern $keyword -List |
                     Select-Object -First 5

            foreach ($file in $files) {
                $evidence += @{
                    type = "file"
                    path = $file.Path
                    keyword = $keyword
                    line = $file.LineNumber
                }
            }
        }
    }

    return $evidence
}

# Search for PRs matching keywords
function Search-PRs {
    param([string[]]$keywords, [string]$repo)

    $evidence = @()

    foreach ($keyword in $keywords) {
        try {
            $prs = & gh pr list --repo $repo --search $keyword --state all --limit 5 --json number,title,state,mergedAt 2>$null | ConvertFrom-Json

            foreach ($pr in $prs) {
                $evidence += @{
                    type = "pr"
                    number = $pr.number
                    title = $pr.title
                    state = $pr.state
                    mergedAt = $pr.mergedAt
                    keyword = $keyword
                }
            }
        } catch {
            # Ignore GH API errors
        }
    }

    return $evidence
}

# Search for branches matching keywords
function Search-Branches {
    param([string[]]$keywords, [string]$path)

    $evidence = @()

    Push-Location $path
    try {
        $branches = & git branch -a 2>$null

        foreach ($keyword in $keywords) {
            $matchingBranches = $branches | Select-String -Pattern $keyword -List

            foreach ($branch in $matchingBranches) {
                $evidence += @{
                    type = "branch"
                    name = $branch.Line.Trim()
                    keyword = $keyword
                }
            }
        }
    } finally {
        Pop-Location
    }

    return $evidence
}

# Main execution
Write-Host "🔍 Task Discovery Scan for Task $TaskId" -ForegroundColor Cyan
Write-Host "Description: $TaskDescription" -ForegroundColor Gray
Write-Host ""

# Extract keywords
$keywords = Extract-Keywords -text $TaskDescription
Write-Host "📌 Keywords extracted: $($keywords -join ', ')" -ForegroundColor Yellow
Write-Host ""

# Collect evidence
$allEvidence = @()

# Search code files
Write-Host "🔎 Searching code files..." -ForegroundColor Cyan
$codeEvidence = Search-Code -keywords $keywords -paths $SearchPaths
$allEvidence += $codeEvidence
Write-Host "   Found $($codeEvidence.Count) matching files" -ForegroundColor Gray

# Search PRs
Write-Host "🔎 Searching pull requests..." -ForegroundColor Cyan
$prEvidence = Search-PRs -keywords $keywords -repo "martiendejong/client-manager"
$allEvidence += $prEvidence
Write-Host "   Found $($prEvidence.Count) matching PRs" -ForegroundColor Gray

# Search branches
Write-Host "🔎 Searching branches..." -ForegroundColor Cyan
$branchEvidence = Search-Branches -keywords $keywords -path "C:\Projects\client-manager"
$allEvidence += $branchEvidence
Write-Host "   Found $($branchEvidence.Count) matching branches" -ForegroundColor Gray
Write-Host ""

# Calculate confidence score
$confidence = 0

# Evidence scoring
$fileCount = ($allEvidence | Where-Object { $_.type -eq "file" }).Count
$prCount = ($allEvidence | Where-Object { $_.type -eq "pr" }).Count
$branchCount = ($allEvidence | Where-Object { $_.type -eq "branch" }).Count
$mergedPRCount = ($allEvidence | Where-Object { $_.type -eq "pr" -and $_.state -eq "MERGED" }).Count

if ($fileCount -ge 10) { $confidence += 40 }
elseif ($fileCount -ge 5) { $confidence += 20 }
elseif ($fileCount -ge 1) { $confidence += 10 }

if ($mergedPRCount -ge 1) { $confidence += 50 }
elseif ($prCount -ge 1) { $confidence += 30 }

if ($branchCount -ge 1) { $confidence += 10 }

# Determine recommendation
$recommendation = "implement"  # Default
if ($confidence -ge 80) {
    $recommendation = "close"  # Likely already complete
} elseif ($confidence -ge 40) {
    $recommendation = "verify"  # Might be complete, verify manually
}

# Output results
$result = @{
    taskId = $TaskId
    found = ($confidence -gt 0)
    confidence = [math]::Min($confidence, 100)
    evidenceCount = $allEvidence.Count
    evidence = $allEvidence | Select-Object -First 20  # Limit output
    recommendation = $recommendation
}

Write-Host "📊 RESULTS" -ForegroundColor Cyan
Write-Host "   Confidence: $($result.confidence)%" -ForegroundColor $(if ($result.confidence -ge 80) { "Green" } elseif ($result.confidence -ge 40) { "Yellow" } else { "Red" })
Write-Host "   Evidence: $($result.evidenceCount) items found" -ForegroundColor Gray
Write-Host "   Recommendation: $recommendation" -ForegroundColor $(if ($recommendation -eq "close") { "Green" } elseif ($recommendation -eq "verify") { "Yellow" } else { "Red" })
Write-Host ""

if ($recommendation -eq "close") {
    Write-Host "✅ HIGH CONFIDENCE: This task appears to be already implemented." -ForegroundColor Green
    Write-Host "   → Verify manually, then close or move to review" -ForegroundColor Green
} elseif ($recommendation -eq "verify") {
    Write-Host "⚠️ MEDIUM CONFIDENCE: Some evidence of existing work found." -ForegroundColor Yellow
    Write-Host "   → Check code/PRs manually before allocating worktree" -ForegroundColor Yellow
} else {
    Write-Host "🚀 READY TO IMPLEMENT: No significant evidence of existing work." -ForegroundColor Cyan
    Write-Host "   → Safe to allocate worktree and proceed" -ForegroundColor Cyan
}

# Output JSON for programmatic use
$result | ConvertTo-Json -Depth 5

# Return exit code
exit $(if ($recommendation -eq "implement") { 0 } elseif ($recommendation -eq "verify") { 1 } else { 2 })
