# semantic-extraction.ps1
# Extract semantic patterns from episodic memories

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [int]$AnalyzeLastN = 100,

    [Parameter(Mandatory=$false)]
    [switch]$UpdateMemoryMd
)

$ErrorActionPreference = "Continue"
$ScriptPath = $PSScriptRoot
$EpisodicMemoryPath = Join-Path $ScriptPath "memory\episodic-memory.jsonl"
$SemanticPatternsPath = Join-Path $ScriptPath "memory\semantic-patterns.json"
$MemoryMdPath = "C:\Users\HP\.claude\projects\C--scripts\memory\MEMORY.md"

function Extract-Patterns {
    param([array]$Episodes)

    if ($Episodes.Count -eq 0) {
        Write-Host "No episodes to analyze" -ForegroundColor Yellow
        return @()
    }

    $patterns = @{
        recurring_contexts = @()
        common_mistakes = @()
        successful_strategies = @()
        emotional_triggers = @()
        learning_insights = @()
    }

    # Group episodes by type
    $byType = $Episodes | Group-Object -Property type

    # Extract recurring contexts (what situations repeat?)
    $contextCounts = @{}
    foreach ($episode in $Episodes) {
        if ($episode.context) {
            $contextKeys = $episode.context.PSObject.Properties.Name
            foreach ($key in $contextKeys) {
                if (-not $contextCounts[$key]) { $contextCounts[$key] = 0 }
                $contextCounts[$key]++
            }
        }
    }

    $patterns.recurring_contexts = $contextCounts.GetEnumerator() |
        Where-Object { $_.Value -gt 2 } |
        Sort-Object -Property Value -Descending |
        Select-Object -First 10 |
        ForEach-Object { @{context = $_.Key; frequency = $_.Value} }

    # Extract mistakes and learnings
    $mistakes = $byType | Where-Object { $_.Name -eq "Mistake" }
    if ($mistakes) {
        $patterns.common_mistakes = $mistakes.Group |
            Select-Object -First 5 |
            ForEach-Object {
                @{
                    description = $_.description
                    timestamp = $_.timestamp
                    valence = $_.emotional.valence
                }
            }
    }

    # Extract successes
    $successes = $byType | Where-Object { $_.Name -eq "Success" }
    if ($successes) {
        $patterns.successful_strategies = $successes.Group |
            Sort-Object { $_.emotional.importance } -Descending |
            Select-Object -First 5 |
            ForEach-Object {
                @{
                    description = $_.description
                    timestamp = $_.timestamp
                    importance = $_.emotional.importance
                }
            }
    }

    # Extract learnings
    $learnings = $byType | Where-Object { $_.Name -eq "Learning" }
    if ($learnings) {
        $patterns.learning_insights = $learnings.Group |
            Sort-Object { $_.emotional.importance } -Descending |
            Select-Object -First 10 |
            ForEach-Object {
                @{
                    description = $_.description
                    timestamp = $_.timestamp
                    importance = $_.emotional.importance
                }
            }
    }

    # Emotional trigger analysis (what causes strong emotions?)
    $strongEmotions = $Episodes | Where-Object { [Math]::Abs($_.emotional.valence) -gt 0.7 }
    $patterns.emotional_triggers = $strongEmotions |
        Select-Object -First 10 |
        ForEach-Object {
            @{
                description = $_.description
                valence = $_.emotional.valence
                type = $_.type
                timestamp = $_.timestamp
            }
        }

    return $patterns
}

function Save-SemanticPatterns {
    param($Patterns)

    $output = @{
        extracted = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        episodesAnalyzed = $AnalyzeLastN
        patterns = $Patterns
    }

    $output | ConvertTo-Json -Depth 10 | Set-Content $SemanticPatternsPath -Force

    Write-Host "Semantic patterns saved to $SemanticPatternsPath" -ForegroundColor Green
}

function Update-MemoryMd {
    param($Patterns)

    if (-not (Test-Path $MemoryMdPath)) {
        Write-Host "MEMORY.md not found at $MemoryMdPath" -ForegroundColor Yellow
        return
    }

    # Build new learnings section
    $newSection = @"

## Recent Semantic Patterns (Auto-extracted $(Get-Date -Format "yyyy-MM-dd"))

**Successful Strategies:**
"@

    if ($Patterns.successful_strategies.Count -gt 0) {
        foreach ($strategy in $Patterns.successful_strategies) {
            $newSection += "`n- $($strategy.description) (Importance: $($strategy.importance))"
        }
    } else {
        $newSection += "`n- No patterns detected yet"
    }

    $newSection += "`n`n**Common Challenges:**"
    if ($Patterns.common_mistakes.Count -gt 0) {
        foreach ($mistake in $Patterns.common_mistakes) {
            $newSection += "`n- $($mistake.description)"
        }
    } else {
        $newSection += "`n- No patterns detected yet"
    }

    $newSection += "`n`n**Key Learnings:**"
    if ($Patterns.learning_insights.Count -gt 0) {
        foreach ($learning in $Patterns.learning_insights) {
            $newSection += "`n- $($learning.description)"
        }
    } else {
        $newSection += "`n- No patterns detected yet"
    }

    Write-Host "`nExtracted semantic patterns:" -ForegroundColor Cyan
    Write-Host $newSection

    # Note: We don't auto-append to MEMORY.md to avoid cluttering it
    # Instead, save to separate file for manual review
    $extractedPath = Join-Path $ScriptPath "memory\extracted-patterns-$(Get-Date -Format 'yyyyMMdd').md"
    $newSection | Set-Content $extractedPath -Force

    Write-Host "`nPatterns saved to: $extractedPath" -ForegroundColor Green
    Write-Host "Review and manually add to MEMORY.md if valuable" -ForegroundColor Yellow
}

# Main execution
Write-Host "Analyzing episodic memory..." -ForegroundColor Cyan

if (-not (Test-Path $EpisodicMemoryPath)) {
    Write-Host "No episodic memory found yet" -ForegroundColor Yellow
    exit 0
}

# Load recent episodes
$episodes = Get-Content $EpisodicMemoryPath -Tail $AnalyzeLastN | ForEach-Object {
    $_ | ConvertFrom-Json
}

Write-Host "Loaded $($episodes.Count) episodes" -ForegroundColor White

# Extract patterns
$patterns = Extract-Patterns -Episodes $episodes

# Save patterns
Save-SemanticPatterns -Patterns $patterns

# Update MEMORY.md if requested
if ($UpdateMemoryMd) {
    Update-MemoryMd -Patterns $patterns
}

Write-Host "`n=== Extraction Complete ===" -ForegroundColor Green
Write-Host "Recurring contexts: $($patterns.recurring_contexts.Count)"
Write-Host "Common mistakes: $($patterns.common_mistakes.Count)"
Write-Host "Successful strategies: $($patterns.successful_strategies.Count)"
Write-Host "Learning insights: $($patterns.learning_insights.Count)"
Write-Host "Emotional triggers: $($patterns.emotional_triggers.Count)"

return $patterns
