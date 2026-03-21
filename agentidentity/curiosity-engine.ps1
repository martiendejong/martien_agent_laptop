# curiosity-engine.ps1
# Information-theoretic curiosity - maximize information gain
# Intrinsic motivation to reduce uncertainty

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Scan", "Prioritize", "Status")]
    [string]$Action = "Scan"
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$StatePath = Join-Path $ScriptPath "state\curiosity-state.json"
$KnowledgeGraphPath = Join-Path $ScriptPath "memory\knowledge-graph.json"

function Scan-KnowledgeGaps {
    # Identify what we don't know yet
    $gaps = @()

    # 1. Unexamined codebases
    $gaps += Scan-CodebaseGaps

    # 2. Unexplored documentation
    $gaps += Scan-DocumentationGaps

    # 3. Unanswered questions
    $gaps += Scan-HypothesisGaps

    # 4. Low-confidence beliefs
    $gaps += Scan-UncertaintyGaps

    return $gaps
}

function Scan-CodebaseGaps {
    $projectRoot = "C:\Projects"
    if (-not (Test-Path $projectRoot)) {
        return @()
    }

    $gaps = @()
    $repos = Get-ChildItem $projectRoot -Directory | Where-Object {
        Test-Path (Join-Path $_.FullName ".git")
    }

    # Load knowledge graph to see what we've explored
    $knowledgeGraph = Load-KnowledgeGraph

    foreach ($repo in $repos) {
        $repoName = $repo.Name

        # Check if we've explored this repo
        $explored = $knowledgeGraph.codebases | Where-Object { $_.name -eq $repoName }

        if (-not $explored) {
            # Never explored - high curiosity value
            $gaps += @{
                type = "UnexploredCodebase"
                target = $repoName
                path = $repo.FullName
                curiosityValue = 0.9
                reason = "Never examined this codebase"
                estimatedInfoGain = "High"
            }
        } elseif ($explored.lastExplored) {
            # Check if changed since last exploration
            $lastExplored = [DateTime]::Parse($explored.lastExplored)
            Push-Location $repo.FullName
            $recentCommits = (git log --since="$($lastExplored.ToString('yyyy-MM-dd'))" --oneline 2>$null | Measure-Object).Count
            Pop-Location

            if ($recentCommits -gt 5) {
                $gaps += @{
                    type = "ChangedCodebase"
                    target = $repoName
                    path = $repo.FullName
                    curiosityValue = 0.6
                    reason = "$recentCommits new commits since last exploration"
                    estimatedInfoGain = "Medium"
                }
            }
        }
    }

    return $gaps
}

function Scan-DocumentationGaps {
    # Look for README files we haven't read
    $gaps = @()
    $projectRoot = "C:\Projects"

    if (Test-Path $projectRoot) {
        $readmes = Get-ChildItem $projectRoot -Recurse -Filter "README.md" -ErrorAction SilentlyContinue | Select-Object -First 10

        $knowledgeGraph = Load-KnowledgeGraph

        foreach ($readme in $readmes) {
            $readPath = $readme.FullName
            $read = $knowledgeGraph.documentation | Where-Object { $_.path -eq $readPath }

            if (-not $read) {
                $gaps += @{
                    type = "UnreadDocumentation"
                    target = $readme.Directory.Name
                    path = $readPath
                    curiosityValue = 0.7
                    reason = "Unread documentation"
                    estimatedInfoGain = "Medium-High"
                }
            }
        }
    }

    return $gaps
}

function Scan-HypothesisGaps {
    # Check for unanswered hypotheses
    $hypothesisLog = Join-Path $ScriptPath "memory\hypothesis-log.md"

    if (Test-Path $hypothesisLog) {
        $content = Get-Content $hypothesisLog -Raw

        # Count unanswered hypotheses (marked with ❓ or ⏳)
        $unanswered = ($content | Select-String -Pattern "❓|⏳" -AllMatches).Matches.Count

        if ($unanswered -gt 0) {
            return @(@{
                type = "UnansweredHypothesis"
                target = "hypothesis-log.md"
                curiosityValue = 0.8
                reason = "$unanswered unanswered hypotheses"
                estimatedInfoGain = "High"
            })
        }
    }

    return @()
}

function Scan-UncertaintyGaps {
    # Identify low-confidence beliefs in knowledge graph
    $knowledgeGraph = Load-KnowledgeGraph
    $gaps = @()

    if ($knowledgeGraph.beliefs) {
        $uncertain = $knowledgeGraph.beliefs | Where-Object { $_.confidence -lt 0.5 }

        foreach ($belief in $uncertain) {
            $gaps += @{
                type = "LowConfidenceBelief"
                target = $belief.subject
                curiosityValue = 1 - $belief.confidence
                reason = "Confidence only $($belief.confidence)"
                estimatedInfoGain = "High"
            }
        }
    }

    return $gaps
}

function Prioritize-ExplorationTargets {
    param([array]$Gaps)

    # Sort by curiosity value (information gain potential)
    $prioritized = $Gaps | Sort-Object -Property curiosityValue -Descending

    # Apply diminishing returns (explored topics less interesting)
    $knowledgeGraph = Load-KnowledgeGraph
    foreach ($gap in $prioritized) {
        $exploredCount = ($knowledgeGraph.explorationHistory | Where-Object { $_.target -eq $gap.target }).Count

        # Reduce curiosity for repeatedly explored targets
        if ($exploredCount -gt 0) {
            $gap.curiosityValue *= (0.8 / ($exploredCount + 1))
        }
    }

    # Re-sort after diminishing returns
    $prioritized = $prioritized | Sort-Object -Property curiosityValue -Descending

    return $prioritized
}

function Load-KnowledgeGraph {
    if (Test-Path $KnowledgeGraphPath) {
        try {
            return Get-Content $KnowledgeGraphPath -Raw | ConvertFrom-Json
        } catch {}
    }

    return @{
        codebases = @()
        documentation = @()
        beliefs = @()
        explorationHistory = @()
    }
}

function Save-KnowledgeGraph {
    param($Graph)
    $Graph | ConvertTo-Json -Depth 10 | Set-Content $KnowledgeGraphPath -Force
}

function Load-State {
    if (Test-Path $StatePath) {
        try {
            return Get-Content $StatePath -Raw | ConvertFrom-Json
        } catch {}
    }

    return @{
        totalScans = 0
        gapsIdentified = 0
        explorationsSuggested = 0
        lastScan = $null
    }
}

function Save-State {
    param($State)
    $State | ConvertTo-Json -Depth 5 | Set-Content $StatePath -Force
}

function Show-CuriosityStatus {
    param($Gaps, $State)

    Write-Host ""
    Write-Host "=== Curiosity Engine ===" -ForegroundColor Cyan
    Write-Host ""

    if ($Gaps.Count -eq 0) {
        Write-Host "No knowledge gaps detected (unlikely!)" -ForegroundColor Yellow
        Write-Host "This probably means the scanning isn't working properly." -ForegroundColor Gray
        return
    }

    Write-Host "Knowledge gaps identified: $($Gaps.Count)" -ForegroundColor White
    Write-Host ""

    Write-Host "Top curiosity targets:" -ForegroundColor Yellow
    $Gaps | Select-Object -First 5 | ForEach-Object {
        $color = if ($_.curiosityValue -gt 0.7) { "Green" } elseif ($_.curiosityValue -gt 0.4) { "Yellow" } else { "Gray" }
        Write-Host "  [$($_.type)] " -NoNewline -ForegroundColor $color
        Write-Host "$($_.target)" -ForegroundColor White
        Write-Host "    Curiosity: $([Math]::Round($_.curiosityValue, 2)) | Info gain: $($_.estimatedInfoGain)" -ForegroundColor Gray
        Write-Host "    Reason: $($_.reason)" -ForegroundColor DarkGray
    }

    Write-Host ""
    Write-Host "Total scans: $($State.totalScans)" -ForegroundColor Gray
    Write-Host "Last scan: $($State.lastScan)" -ForegroundColor Gray
}

# Main execution
$state = Load-State

switch ($Action) {
    "Scan" {
        $gaps = Scan-KnowledgeGaps

        $state.totalScans++
        $state.gapsIdentified = $gaps.Count
        $state.lastScan = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        Save-State -State $state

        if ($VerbosePreference -eq "Continue") {
            Show-CuriosityStatus -Gaps $gaps -State $state
        }

        return $gaps
    }
    "Prioritize" {
        $gaps = Scan-KnowledgeGaps
        $prioritized = Prioritize-ExplorationTargets -Gaps $gaps

        $state.explorationsSuggested = $prioritized.Count
        Save-State -State $state

        if ($VerbosePreference -eq "Continue") {
            Show-CuriosityStatus -Gaps $prioritized -State $state
        }

        return $prioritized
    }
    "Status" {
        $gaps = Scan-KnowledgeGaps
        Show-CuriosityStatus -Gaps $gaps -State $state
    }
}
