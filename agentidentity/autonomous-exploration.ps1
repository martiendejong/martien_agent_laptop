# autonomous-exploration.ps1
# Self-directed learning driven by curiosity engine
# Explore without being asked - intrinsic motivation

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Target = "",

    [Parameter(Mandatory=$false)]
    [ValidateSet("Auto", "Codebase", "Documentation", "Hypothesis")]
    [string]$Mode = "Auto"
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$DiscoveriesPath = Join-Path $ScriptPath "memory\discoveries.jsonl"

function Explore-Autonomously {
    # Get curiosity targets
    $curiosityScript = Join-Path $ScriptPath "curiosity-engine.ps1"
    if (-not (Test-Path $curiosityScript)) {
        Write-Host "Curiosity engine not found" -ForegroundColor Red
        return
    }

    $targets = & $curiosityScript -Action Prioritize

    if ($targets.Count -eq 0) {
        Write-Host "No exploration targets identified" -ForegroundColor Yellow
        return
    }

    # Pick highest curiosity target
    $target = $targets[0]

    Write-Host ""
    Write-Host "=== Autonomous Exploration ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Target: $($target.target)" -ForegroundColor Green
    Write-Host "Type: $($target.type)" -ForegroundColor White
    Write-Host "Curiosity: $([Math]::Round($target.curiosityValue, 2))" -ForegroundColor Yellow
    Write-Host ""

    # Explore based on type
    $discovery = switch ($target.type) {
        "UnexploredCodebase" { Explore-Codebase -Path $target.path -Name $target.target }
        "ChangedCodebase" { Explore-Codebase -Path $target.path -Name $target.target }
        "UnreadDocumentation" { Explore-Documentation -Path $target.path }
        "UnansweredHypothesis" { Explore-Hypothesis }
        default { $null }
    }

    if ($discovery) {
        Record-Discovery -Discovery $discovery
    }

    return $discovery
}

function Explore-Codebase {
    param([string]$Path, [string]$Name)

    Write-Host "Exploring codebase: $Name" -ForegroundColor Cyan

    $discovery = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        type = "CodebaseExploration"
        target = $Name
        findings = @()
    }

    if (-not (Test-Path $Path)) {
        $discovery.findings += "Path not found: $Path"
        return $discovery
    }

    Push-Location $Path

    # 1. Count files by type
    $extensions = Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
        Group-Object -Property Extension |
        Sort-Object -Property Count -Descending |
        Select-Object -First 5

    $discovery.findings += "File types: $($extensions | ForEach-Object { "$($_.Name) ($($_.Count))" } | Join-String -Separator ', ')"

    # 2. Find main entry points
    $entryPoints = Get-ChildItem -Recurse -Filter "*.cs" -ErrorAction SilentlyContinue |
        Select-String -Pattern "static void Main|public static async Task Main" -List |
        Select-Object -First 3 -ExpandProperty Path

    if ($entryPoints) {
        $discovery.findings += "Entry points: $($entryPoints.Count) found"
    }

    # 3. Check for tests
    $testFiles = Get-ChildItem -Recurse -Filter "*test*.cs" -ErrorAction SilentlyContinue | Measure-Object
    $discovery.findings += "Test files: $($testFiles.Count)"

    # 4. Recent activity
    $recentCommits = git log --oneline -5 2>$null
    if ($recentCommits) {
        $discovery.findings += "Recent commits: $($recentCommits.Count)"
    }

    Pop-Location

    Write-Host "  Findings: $($discovery.findings.Count)" -ForegroundColor Green

    return $discovery
}

function Explore-Documentation {
    param([string]$Path)

    $discovery = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        type = "DocumentationExploration"
        target = (Split-Path $Path -Leaf)
        findings = @()
    }

    if (Test-Path $Path) {
        $content = Get-Content $Path -Raw
        $discovery.findings += "Length: $($content.Length) chars"

        # Extract headers
        $headers = $content | Select-String -Pattern "^#+\s+(.+)" -AllMatches
        if ($headers.Matches.Count -gt 0) {
            $discovery.findings += "Sections: $($headers.Matches.Count)"
        }

        # Extract code blocks
        $codeBlocks = ($content | Select-String -Pattern "```" -AllMatches).Matches.Count / 2
        if ($codeBlocks -gt 0) {
            $discovery.findings += "Code examples: $codeBlocks"
        }
    }

    return $discovery
}

function Explore-Hypothesis {
    # Read hypothesis log and suggest experiments
    $hypothesisLog = Join-Path $ScriptPath "memory\hypothesis-log.md"

    $discovery = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        type = "HypothesisExploration"
        target = "Active hypotheses"
        findings = @()
    }

    if (Test-Path $hypothesisLog) {
        $content = Get-Content $hypothesisLog -Raw
        $discovery.findings += "Hypothesis log exists"
        # In real implementation, would parse and suggest experiments
    }

    return $discovery
}

function Record-Discovery {
    param($Discovery)

    # Append to discoveries log
    $Discovery | ConvertTo-Json -Compress | Add-Content $DiscoveriesPath

    # Update knowledge graph
    $knowledgeGraphPath = Join-Path $ScriptPath "memory\knowledge-graph.json"
    $graph = if (Test-Path $knowledgeGraphPath) {
        Get-Content $knowledgeGraphPath -Raw | ConvertFrom-Json
    } else {
        @{codebases = @(); documentation = @(); explorationHistory = @()}
    }

    $graph.explorationHistory += @{
        timestamp = $Discovery.timestamp
        target = $Discovery.target
        type = $Discovery.type
    }

    $graph | ConvertTo-Json -Depth 10 | Set-Content $knowledgeGraphPath -Force

    Write-Host "✓ Discovery recorded" -ForegroundColor Green
}

# Main execution
if ($Mode -eq "Auto") {
    Explore-Autonomously
} else {
    Write-Host "Manual exploration mode not yet implemented" -ForegroundColor Yellow
}
