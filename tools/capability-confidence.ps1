<#
.SYNOPSIS
    Query and update capability confidence scores

.DESCRIPTION
    Manages the capability confidence scoring system (ACE Framework Layer 3 requirement).
    Provides commands to query scores, assess capabilities, update scores, and identify improvement areas.

.PARAMETER Action
    Operation to perform:
    - query: Get confidence score for a capability
    - list: List all capabilities with scores
    - update: Update a capability score
    - assess: Get overall confidence assessment
    - gaps: Identify low-confidence areas
    - report: Generate detailed capability report

.PARAMETER Capability
    Capability name to query/update (use dot notation: code_development.csharp_backend)

.PARAMETER Score
    New confidence score (0-100) when using -Action update

.PARAMETER MinScore
    Minimum score threshold for filtering (default: 0)

.PARAMETER Format
    Output format: text, json, markdown (default: text)

.EXAMPLE
    .\capability-confidence.ps1 -Action query -Capability "code_development.csharp_backend"
    # Get confidence score for C# backend development

.EXAMPLE
    .\capability-confidence.ps1 -Action list -MinScore 90
    # List all capabilities with 90%+ confidence

.EXAMPLE
    .\capability-confidence.ps1 -Action gaps
    # Identify low-confidence areas needing improvement

.EXAMPLE
    .\capability-confidence.ps1 -Action assess
    # Get overall confidence assessment

.EXAMPLE
    .\capability-confidence.ps1 -Action update -Capability "sql_database" -Score 80
    # Update SQL database confidence to 80%

.EXAMPLE
    .\capability-confidence.ps1 -Action report -Format markdown
    # Generate detailed markdown report
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("query", "list", "update", "assess", "gaps", "report")]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$Capability,

    [Parameter(Mandatory=$false)]
    [ValidateRange(0, 100)]
    [int]$Score,

    [Parameter(Mandatory=$false)]
    [ValidateRange(0, 100)]
    [int]$MinScore = 0,

    [Parameter(Mandatory=$false)]
    [ValidateSet("text", "json", "markdown")]
    [string]$Format = "text"
)

$ErrorActionPreference = "Stop"

# Path to confidence scores file
$ScoresPath = "C:\scripts\agentidentity\capabilities\confidence_scores.yaml"

# Load YAML (simple parser for our structured format)
function Parse-ConfidenceYAML {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        throw "Confidence scores file not found: $Path"
    }

    $content = Get-Content $Path -Raw

    # Parse YAML into hashtable (simplified - assumes our specific format)
    $scores = @{}
    $currentCategory = $null
    $currentCapability = $null

    foreach ($line in $content -split "`n") {
        # Category detection (no indentation, ends with :)
        if ($line -match '^([a-z_]+):$') {
            $currentCategory = $matches[1]
            if ($currentCategory -notin @('metadata', 'aggregate_metrics')) {
                $scores[$currentCategory] = @{}
            }
        }
        # Capability detection (2-space indent, ends with :)
        elseif ($line -match '^  ([a-z_]+):$') {
            $currentCapability = $matches[1]
            if ($currentCategory -and $currentCategory -ne 'metadata') {
                $scores[$currentCategory][$currentCapability] = @{}
            }
        }
        # Score detection (4-space indent, score: value)
        elseif ($line -match '^    score:\s*(\d+)$') {
            if ($currentCategory -and $currentCapability) {
                $scores[$currentCategory][$currentCapability]['score'] = [int]$matches[1]
            }
        }
        # Evidence detection
        elseif ($line -match '^    evidence:\s*"(.+)"$') {
            if ($currentCategory -and $currentCapability) {
                $scores[$currentCategory][$currentCapability]['evidence'] = $matches[1]
            }
        }
    }

    return $scores
}

# Get all capabilities as flat list
function Get-AllCapabilities {
    param($Scores)

    $capabilities = @()
    foreach ($category in $Scores.Keys) {
        foreach ($capability in $Scores[$category].Keys) {
            $capabilities += [PSCustomObject]@{
                Category = $category
                Capability = $capability
                FullName = "$category.$capability"
                Score = $Scores[$category][$capability]['score']
                Evidence = $Scores[$category][$capability]['evidence']
            }
        }
    }

    return $capabilities
}

# Main execution
try {
    $scores = Parse-ConfidenceYAML -Path $ScoresPath

    switch ($Action) {
        "query" {
            if (-not $Capability) {
                throw "Capability parameter required for query action"
            }

            if ($Capability -match '^([^.]+)\.([^.]+)$') {
                $category = $matches[1]
                $capName = $matches[2]

                if ($scores.ContainsKey($category) -and $scores[$category].ContainsKey($capName)) {
                    $cap = $scores[$category][$capName]

                    if ($Format -eq "json") {
                        $cap | ConvertTo-Json
                    }
                    else {
                        Write-Host "`n🎯 Capability: $Capability" -ForegroundColor Cyan
                        Write-Host "   Confidence: $($cap.score)%" -ForegroundColor $(if ($cap.score -ge 85) { "Green" } elseif ($cap.score -ge 70) { "Yellow" } else { "Red" })
                        Write-Host "   Evidence: $($cap.evidence)" -ForegroundColor Gray
                    }
                }
                else {
                    throw "Capability not found: $Capability"
                }
            }
            else {
                throw "Invalid capability format. Use: category.capability_name"
            }
        }

        "list" {
            $capabilities = Get-AllCapabilities -Scores $scores | Where-Object { $_.Score -ge $MinScore } | Sort-Object -Property Score -Descending

            if ($Format -eq "json") {
                $capabilities | ConvertTo-Json
            }
            elseif ($Format -eq "markdown") {
                Write-Host "# Capability Confidence Scores`n"
                Write-Host "| Capability | Score | Evidence |"
                Write-Host "|------------|-------|----------|"
                foreach ($cap in $capabilities) {
                    Write-Host "| $($cap.FullName) | $($cap.Score)% | $($cap.Evidence) |"
                }
            }
            else {
                Write-Host "`n📊 Capability Confidence Scores (>= $MinScore%)`n" -ForegroundColor Cyan
                foreach ($cap in $capabilities) {
                    $color = if ($cap.Score -ge 90) { "Green" } elseif ($cap.Score -ge 80) { "Cyan" } elseif ($cap.Score -ge 70) { "Yellow" } else { "Red" }
                    Write-Host "  [$($cap.Score.ToString().PadLeft(3))%] " -NoNewline -ForegroundColor $color
                    Write-Host "$($cap.FullName.PadRight(40)) " -NoNewline
                    Write-Host "($($cap.Evidence))" -ForegroundColor Gray
                }
                Write-Host ""
            }
        }

        "assess" {
            $capabilities = Get-AllCapabilities -Scores $scores
            $avgScore = ($capabilities | Measure-Object -Property Score -Average).Average
            $expertCount = ($capabilities | Where-Object { $_.Score -ge 95 }).Count
            $proficientCount = ($capabilities | Where-Object { $_.Score -ge 80 -and $_.Score -lt 95 }).Count
            $competentCount = ($capabilities | Where-Object { $_.Score -ge 65 -and $_.Score -lt 80 }).Count
            $developingCount = ($capabilities | Where-Object { $_.Score -lt 65 }).Count

            if ($Format -eq "json") {
                @{
                    overall_confidence = [math]::Round($avgScore, 1)
                    expert = $expertCount
                    proficient = $proficientCount
                    competent = $competentCount
                    developing = $developingCount
                    total = $capabilities.Count
                } | ConvertTo-Json
            }
            else {
                Write-Host "`n🎯 Overall Capability Assessment`n" -ForegroundColor Cyan
                Write-Host "  Overall Confidence: " -NoNewline
                Write-Host "$([math]::Round($avgScore, 1))%" -ForegroundColor Green
                Write-Host "`n  Confidence Distribution:"
                Write-Host "    Expert (95-100):      $expertCount capabilities" -ForegroundColor Green
                Write-Host "    Proficient (80-94):   $proficientCount capabilities" -ForegroundColor Cyan
                Write-Host "    Competent (65-79):    $competentCount capabilities" -ForegroundColor Yellow
                Write-Host "    Developing (<65):     $developingCount capabilities" -ForegroundColor Red
                Write-Host "`n  Total Capabilities: $($capabilities.Count)`n"
            }
        }

        "gaps" {
            $capabilities = Get-AllCapabilities -Scores $scores | Where-Object { $_.Score -lt 85 } | Sort-Object -Property Score

            if ($Format -eq "json") {
                $capabilities | ConvertTo-Json
            }
            else {
                Write-Host "`n⚠️  Low-Confidence Areas (Improvement Needed)`n" -ForegroundColor Yellow
                foreach ($cap in $capabilities) {
                    $color = if ($cap.Score -ge 70) { "Yellow" } else { "Red" }
                    Write-Host "  [$($cap.Score.ToString().PadLeft(3))%] " -NoNewline -ForegroundColor $color
                    Write-Host "$($cap.FullName)"
                }
                Write-Host "`n  💡 Tip: Focus on capabilities below 80% for maximum impact`n"
            }
        }

        "update" {
            if (-not $Capability) {
                throw "Capability parameter required for update action"
            }
            if ($null -eq $Score) {
                throw "Score parameter required for update action"
            }

            # Update YAML file (simple approach: read, modify, write)
            $content = Get-Content $ScoresPath -Raw

            if ($content -match "(?m)^  $Capability`:.*?^    score:\s*\d+$") {
                $content = $content -replace "(?m)(^  $Capability`:.*?^    score:)\s*\d+", "`$1 $Score"
                $content | Set-Content $ScoresPath -NoNewline

                Write-Host "`n✅ Updated $Capability confidence: $Score%" -ForegroundColor Green
                Write-Host "   Updated: $ScoresPath`n"
            }
            else {
                throw "Capability not found or invalid format: $Capability"
            }
        }

        "report" {
            $capabilities = Get-AllCapabilities -Scores $scores | Sort-Object -Property Score -Descending
            $avgScore = ($capabilities | Measure-Object -Property Score -Average).Average

            if ($Format -eq "markdown") {
                Write-Host "# Capability Confidence Report`n"
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
                Write-Host "**Generated:** $timestamp"
                Write-Host "**Overall Confidence:** $([math]::Round($avgScore, 1))%`n"

                Write-Host "## Summary by Category`n"

                foreach ($category in $scores.Keys | Sort-Object) {
                    $catCaps = $capabilities | Where-Object { $_.Category -eq $category }
                    if ($catCaps) {
                        $catAvg = ($catCaps | Measure-Object -Property Score -Average).Average
                        $catTitle = $category -replace "_", " "
                        $catTitle = (Get-Culture).TextInfo.ToTitleCase($catTitle)
                        Write-Host "### $catTitle"
                        Write-Host "**Average Confidence:** $([math]::Round($catAvg, 1))%`n"

                        foreach ($cap in $catCaps) {
                            $level = if ($cap.Score -ge 95) { "🟢 Expert" } elseif ($cap.Score -ge 80) { "🔵 Proficient" } elseif ($cap.Score -ge 65) { "🟡 Competent" } else { "🔴 Developing" }
                            Write-Host "- **$($cap.Capability)** ($($cap.Score)%) - $level"
                            Write-Host "  - $($cap.Evidence)`n"
                        }
                    }
                }
            }
            else {
                Write-Host "`n📊 Detailed Capability Report`n" -ForegroundColor Cyan
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
                Write-Host "Generated: $timestamp"
                Write-Host "Overall Confidence: $([math]::Round($avgScore, 1))%`n"

                foreach ($category in $scores.Keys | Sort-Object) {
                    $catCaps = $capabilities | Where-Object { $_.Category -eq $category }
                    if ($catCaps) {
                        Write-Host "━━━ $($category.ToUpper()) ━━━" -ForegroundColor Cyan
                        foreach ($cap in $catCaps | Sort-Object -Property Score -Descending) {
                            $color = if ($cap.Score -ge 90) { "Green" } elseif ($cap.Score -ge 80) { "Cyan" } elseif ($cap.Score -ge 70) { "Yellow" } else { "Red" }
                            Write-Host "  [$($cap.Score.ToString().PadLeft(3))%] $($cap.Capability)" -ForegroundColor $color
                        }
                        Write-Host ""
                    }
                }
            }
        }
    }
}
catch {
    Write-Error "Error: $_"
    exit 1
}
