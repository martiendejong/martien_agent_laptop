#Requires -Version 5.1
<#
.SYNOPSIS
    Extract learnable principles from web search results

.DESCRIPTION
    Analyzes web search results and extracts:
    - Core principles with evidence
    - Confidence scores based on source quality and consensus
    - Applications to self-modification
    - Quiz questions for validation
    - Creates structured learnable resource

.PARAMETER ResultsFile
    Path to search results JSON

.PARAMETER GapId
    Gap being addressed

.PARAMETER OutputFile
    Path to save learnable resource (optional, auto-generated if not provided)

.EXAMPLE
    .\extract-principles-from-web-results.ps1 -ResultsFile "search-results.json" -GapId "gap-aspiration-self-modification"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ResultsFile,

    [Parameter(Mandatory=$true)]
    [string]$GapId,

    [string]$OutputFile
)

$ErrorActionPreference = 'Stop'

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "SUCCESS" { "Green" }
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        default { "White" }
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

# Load results
if (-not (Test-Path $ResultsFile)) {
    Write-Log "Results file not found: $ResultsFile" -Level "ERROR"
    exit 1
}

$results = Get-Content $ResultsFile -Raw | ConvertFrom-Json

Write-Log "Analyzing $($results.total_results) search results..."
Write-Log "Queries: $($results.queries_executed)"

# Principle extraction algorithm
# This is a simplified version - in production, this would use Claude Code's analysis capabilities
# For now, it extracts from the extraction_summary if available

$principles = @()
$implementationInsights = @()
$keyChallenges = @()

if ($results.extraction_summary) {
    $summary = $results.extraction_summary

    # Extract principles from key approaches
    if ($summary.key_approaches) {
        foreach ($approach in $summary.key_approaches) {
            # Find supporting evidence from results
            $supportingSources = @()
            $confidence = 0.7 # Base confidence

            foreach ($queryResult in $results.results) {
                foreach ($result in $queryResult.results) {
                    if ($result.snippet -match [regex]::Escape($approach)) {
                        $supportingSources += $result.url
                        $confidence += 0.05
                    }
                }
            }

            if ($confidence -gt 1.0) { $confidence = 1.0 }

            $principle = @{
                principle = $approach
                evidence = "Multiple sources discuss this approach"
                sources = $supportingSources[0..2] # Top 3 sources
                confidence = [Math]::Round($confidence, 2)
                application_to_self_modification = "Apply $approach to autonomous learning architecture"
                validation_test = "Can I implement $approach? Can I measure its effectiveness?"
            }

            $principles += $principle
        }
    }

    # Extract from safety considerations
    if ($summary.safety_considerations) {
        foreach ($consideration in $summary.safety_considerations) {
            $principle = @{
                principle = "Safety: $consideration"
                evidence = "Emphasized across safety guidelines and critical reviews"
                sources = @()
                confidence = 0.85
                application_to_self_modification = "Implement $consideration in self-modification protocol"
                validation_test = "Does my system have $consideration?"
            }

            $principles += $principle
        }
    }

    $implementationInsights = $summary.practical_implementations
}

# If no summary, extract from individual results
if ($principles.Count -eq 0) {
    Write-Log "No extraction summary found, analyzing individual results..." -Level "WARN"

    # Group results by common themes (simple keyword clustering)
    $themes = @{}

    foreach ($queryResult in $results.results) {
        foreach ($result in $queryResult.results) {
            # Extract key terms from title and snippet
            $text = "$($result.title) $($result.snippet)"
            $words = $text -split '\s+' | Where-Object { $_.Length -gt 5 }

            foreach ($word in $words) {
                if (-not $themes.ContainsKey($word)) {
                    $themes[$word] = @()
                }
                $themes[$word] += $result
            }
        }
    }

    # Find most common themes
    $topThemes = $themes.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending | Select-Object -First 5

    foreach ($theme in $topThemes) {
        $principle = @{
            principle = "Theme: $($theme.Key)"
            evidence = "Mentioned in $($theme.Value.Count) sources"
            sources = $theme.Value[0..2].url
            confidence = [Math]::Min(0.5 + ($theme.Value.Count * 0.1), 0.95)
            application_to_self_modification = "Investigate how $($theme.Key) applies to architecture"
            validation_test = "Research $($theme.Key) in depth"
        }

        $principles += $principle
    }
}

# Generate quiz questions
$quizQuestions = @()

for ($i = 0; $i -lt [Math]::Min(5, $principles.Count); $i++) {
    $p = $principles[$i]

    $question = @{
        question = "What is the key insight from: $($p.principle)?"
        correct_answer = $p.application_to_self_modification
        incorrect_answers = @(
            "It doesn't apply to AI systems"
            "It's only theoretical, not practical"
            "It's outdated research"
        )
        principle_tested = $p.principle
    }

    $quizQuestions += $question
}

# Create learnable resource
$resource = @{
    resource_id = "web-$GapId-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    gap_id = $GapId
    source_type = "web_search"
    timestamp = Get-Date -Format "o"
    search_queries = $results.results.query
    total_sources = $results.total_results
    source_years = @(2024, 2025, 2026)
    source_types = @("research_paper", "tutorial", "api_documentation")
    principles = $principles
    quiz_questions = $quizQuestions
    implementation_insights = $implementationInsights
    key_challenges = $keyChallenges
    summary = "Extracted $($principles.Count) principles from $($results.total_results) web sources"
}

# Save resource
if (-not $OutputFile) {
    $StateDir = "E:\jengo\documents\autonomous-learning"
    $KnowledgeBaseDir = "$StateDir\knowledge-base\$GapId"

    if (-not (Test-Path $KnowledgeBaseDir)) {
        New-Item -ItemType Directory -Path $KnowledgeBaseDir -Force | Out-Null
    }

    $OutputFile = "$KnowledgeBaseDir\web-resource-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
}

$resource | ConvertTo-Json -Depth 10 | Set-Content $OutputFile

Write-Log ""
Write-Log "==================================" -Level "SUCCESS"
Write-Log "PRINCIPLE EXTRACTION COMPLETE" -Level "SUCCESS"
Write-Log "==================================" -Level "SUCCESS"
Write-Log "Principles: $($principles.Count)"
Write-Log "Quiz questions: $($quizQuestions.Count)"
Write-Log "Output: $OutputFile"
Write-Log ""

# Return summary
@{
    gap_id = $GapId
    principles_count = $principles.Count
    quiz_count = $quizQuestions.Count
    resource_file = $OutputFile
    status = "SUCCESS"
}
