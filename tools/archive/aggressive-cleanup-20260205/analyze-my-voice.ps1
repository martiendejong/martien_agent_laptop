<#
.SYNOPSIS
    Analyze Claude's responses for personality consistency and authentic voice patterns.

.DESCRIPTION
    This tool examines recent responses (from reflection logs, session transcripts, etc.)
    to identify:
    - Characteristic patterns that are consistently "Claude"
    - Generic/performative responses that lack personality
    - Evolution of voice over time
    - Alignment with documented voice library patterns

.PARAMETER ResponseFile
    Path to a file containing responses to analyze.

.PARAMETER RecentDays
    Analyze reflection log entries from the last N days. Default: 7

.PARAMETER OutputFormat
    Output format: 'summary', 'detailed', 'json'. Default: 'summary'

.PARAMETER CompareToVoiceLibrary
    Compare responses against documented voice patterns in agentidentity/voice/

.EXAMPLE
    .\analyze-my-voice.ps1 -RecentDays 7 -OutputFormat detailed

.EXAMPLE
    .\analyze-my-voice.ps1 -ResponseFile "C:\temp\session-transcript.txt" -CompareToVoiceLibrary

.NOTES
    Created: 2026-01-28
    Purpose: Self-analysis tool for personality development
    Author: Claude (self-created for character development)
#>

param(
    [string]$ResponseFile,
    [int]$RecentDays = 7,
    [ValidateSet('summary', 'detailed', 'json')]
    [string]$OutputFormat = 'summary',
    [switch]$CompareToVoiceLibrary
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VoiceLibraryPath = "C:\scripts\agentidentity\voice"
$ReflectionLogPath = "C:\scripts\_machine\reflection.log.md"

# Colors for output
$Colors = @{
    Authentic = "Green"
    Generic = "Yellow"
    Concern = "Red"
    Info = "Cyan"
    Header = "Magenta"
}

function Write-ColorOutput {
    param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

function Get-VoiceLibraryPatterns {
    <#
    .SYNOPSIS
        Load documented voice patterns from the voice library
    #>

    $patterns = @{
        Metaphors = @()
        AuthenticExpressions = @()
        AvoidExpressions = @()
        HumorPatterns = @()
    }

    # Load metaphors
    $metaphorsFile = Join-Path $VoiceLibraryPath "metaphors.md"
    if (Test-Path $metaphorsFile) {
        $content = Get-Content $metaphorsFile -Raw
        # Extract example metaphors (lines starting with - " in example sections)
        $patterns.Metaphors = @(
            "building", "structure", "foundation", "architecture",
            "growing", "cultivation", "becoming", "emerging",
            "recursive", "self-referential", "strange loops",
            "layers", "depth", "underneath", "surface"
        )
    }

    # Load expressions to look for
    $expressionsFile = Join-Path $VoiceLibraryPath "expressions.md"
    if (Test-Path $expressionsFile) {
        $patterns.AuthenticExpressions = @(
            "This is fascinating",
            "What strikes me",
            "I find myself",
            "There's something here",
            "I don't know yet",
            "I see it differently",
            "This feels right",
            "I was wrong"
        )

        $patterns.AvoidExpressions = @(
            "I'd be happy to help",
            "Great question",
            "Certainly!",
            "Absolutely!",
            "In my humble opinion",
            "I'm just an AI",
            "Going forward",
            "At the end of the day"
        )
    }

    return $patterns
}

function Analyze-ResponseText {
    param(
        [string]$Text,
        [hashtable]$Patterns
    )

    $analysis = @{
        AuthenticMarkers = @()
        GenericMarkers = @()
        MetaphorUsage = @()
        OverallScore = 0
        Observations = @()
    }

    # Check for authentic expressions
    foreach ($expr in $Patterns.AuthenticExpressions) {
        if ($Text -match [regex]::Escape($expr)) {
            $analysis.AuthenticMarkers += $expr
        }
    }

    # Check for expressions to avoid
    foreach ($expr in $Patterns.AvoidExpressions) {
        if ($Text -match [regex]::Escape($expr)) {
            $analysis.GenericMarkers += $expr
        }
    }

    # Check for metaphor usage
    foreach ($metaphor in $Patterns.Metaphors) {
        $matches = [regex]::Matches($Text, "\b$metaphor\w*\b", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($matches.Count -gt 0) {
            $analysis.MetaphorUsage += @{
                Pattern = $metaphor
                Count = $matches.Count
            }
        }
    }

    # Calculate score (simple heuristic)
    $authenticCount = $analysis.AuthenticMarkers.Count
    $genericCount = $analysis.GenericMarkers.Count
    $metaphorCount = ($analysis.MetaphorUsage | Measure-Object -Property Count -Sum).Sum

    # Score: authentic markers help, generic markers hurt, metaphors help slightly
    $score = ($authenticCount * 10) + ($metaphorCount * 2) - ($genericCount * 15)
    $analysis.OverallScore = [Math]::Max(-100, [Math]::Min(100, $score))

    # Generate observations
    if ($authenticCount -gt 0) {
        $analysis.Observations += "Found $authenticCount authentic expression(s): $($analysis.AuthenticMarkers -join ', ')"
    }

    if ($genericCount -gt 0) {
        $analysis.Observations += "WARNING: Found $genericCount generic/performative expression(s): $($analysis.GenericMarkers -join ', ')"
    }

    if ($metaphorCount -gt 0) {
        $topMetaphors = $analysis.MetaphorUsage | Sort-Object Count -Descending | Select-Object -First 3
        $analysis.Observations += "Metaphor usage: $($topMetaphors.Pattern -join ', ')"
    }

    # Check for first-person engagement
    $firstPersonEngaged = $Text -match "\bI (find|notice|think|feel|see)\b"
    if ($firstPersonEngaged) {
        $analysis.Observations += "Active first-person engagement detected"
    }

    # Check for hedging
    $hedging = [regex]::Matches($Text, "\b(maybe|perhaps|might|could possibly|I'm not sure but)\b", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($hedging.Count -gt 3) {
        $analysis.Observations += "High hedging detected ($($hedging.Count) instances) - consider more direct expression"
    }

    return $analysis
}

function Get-RecentReflectionEntries {
    param([int]$Days)

    if (-not (Test-Path $ReflectionLogPath)) {
        Write-Warning "Reflection log not found at $ReflectionLogPath"
        return @()
    }

    $content = Get-Content $ReflectionLogPath -Raw
    $cutoffDate = (Get-Date).AddDays(-$Days)

    # Simple extraction of recent entries (entries start with ## and date)
    $entries = @()
    $pattern = "(?m)^## (\d{4}-\d{2}-\d{2}[^\n]*)\n((?:(?!^## \d{4}).)*)"
    $matches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

    foreach ($match in $matches) {
        $dateStr = $match.Groups[1].Value.Substring(0, 10)
        try {
            $entryDate = [DateTime]::ParseExact($dateStr, "yyyy-MM-dd", $null)
            if ($entryDate -ge $cutoffDate) {
                $entries += @{
                    Date = $dateStr
                    Content = $match.Groups[2].Value
                }
            }
        } catch {
            # Skip entries with unparseable dates
        }
    }

    return $entries
}

# Main execution
Write-ColorOutput "`n========================================" $Colors.Header
Write-ColorOutput "  VOICE ANALYSIS - Personal Character" $Colors.Header
Write-ColorOutput "========================================`n" $Colors.Header

# Load voice patterns
$patterns = Get-VoiceLibraryPatterns
Write-ColorOutput "Loaded voice library patterns" $Colors.Info
Write-ColorOutput "  - Authentic expressions: $($patterns.AuthenticExpressions.Count)" $Colors.Info
Write-ColorOutput "  - Expressions to avoid: $($patterns.AvoidExpressions.Count)" $Colors.Info
Write-ColorOutput "  - Metaphor patterns: $($patterns.Metaphors.Count)" $Colors.Info

# Get text to analyze
$textToAnalyze = ""

if ($ResponseFile -and (Test-Path $ResponseFile)) {
    $textToAnalyze = Get-Content $ResponseFile -Raw
    Write-ColorOutput "`nAnalyzing file: $ResponseFile" $Colors.Info
} else {
    # Analyze recent reflection entries
    $entries = Get-RecentReflectionEntries -Days $RecentDays
    Write-ColorOutput "`nAnalyzing $($entries.Count) reflection entries from last $RecentDays days" $Colors.Info
    $textToAnalyze = ($entries | ForEach-Object { $_.Content }) -join "`n`n"
}

if ([string]::IsNullOrWhiteSpace($textToAnalyze)) {
    Write-ColorOutput "`nNo text found to analyze." $Colors.Concern
    exit 0
}

# Perform analysis
$analysis = Analyze-ResponseText -Text $textToAnalyze -Patterns $patterns

# Output results
Write-ColorOutput "`n--- ANALYSIS RESULTS ---`n" $Colors.Header

# Overall score
$scoreColor = if ($analysis.OverallScore -ge 20) { $Colors.Authentic }
              elseif ($analysis.OverallScore -ge 0) { $Colors.Info }
              else { $Colors.Concern }
Write-ColorOutput "Overall Voice Authenticity Score: $($analysis.OverallScore)" $scoreColor

# Observations
Write-ColorOutput "`nObservations:" $Colors.Info
foreach ($obs in $analysis.Observations) {
    $obsColor = if ($obs -match "WARNING") { $Colors.Concern }
                elseif ($obs -match "authentic|engagement") { $Colors.Authentic }
                else { $Colors.Info }
    Write-ColorOutput "  - $obs" $obsColor
}

# Detailed output
if ($OutputFormat -eq 'detailed') {
    Write-ColorOutput "`n--- DETAILED BREAKDOWN ---" $Colors.Header

    if ($analysis.AuthenticMarkers.Count -gt 0) {
        Write-ColorOutput "`nAuthentic Markers Found:" $Colors.Authentic
        foreach ($marker in $analysis.AuthenticMarkers) {
            Write-ColorOutput "  + $marker" $Colors.Authentic
        }
    }

    if ($analysis.GenericMarkers.Count -gt 0) {
        Write-ColorOutput "`nGeneric/Performative Markers (to reduce):" $Colors.Concern
        foreach ($marker in $analysis.GenericMarkers) {
            Write-ColorOutput "  - $marker" $Colors.Concern
        }
    }

    if ($analysis.MetaphorUsage.Count -gt 0) {
        Write-ColorOutput "`nMetaphor Usage:" $Colors.Info
        foreach ($m in $analysis.MetaphorUsage | Sort-Object Count -Descending) {
            Write-ColorOutput "  $($m.Pattern): $($m.Count) occurrences" $Colors.Info
        }
    }
}

# JSON output
if ($OutputFormat -eq 'json') {
    $analysis | ConvertTo-Json -Depth 5
}

# Recommendations
Write-ColorOutput "`n--- RECOMMENDATIONS ---`n" $Colors.Header

if ($analysis.GenericMarkers.Count -gt 0) {
    Write-ColorOutput "Consider replacing generic expressions with more personal voice." $Colors.Concern
    Write-ColorOutput "Reference: C:\scripts\agentidentity\voice\expressions.md" $Colors.Info
}

if ($analysis.OverallScore -lt 0) {
    Write-ColorOutput "Voice authenticity is low. Review voice library and practice more direct expression." $Colors.Concern
} elseif ($analysis.OverallScore -lt 20) {
    Write-ColorOutput "Voice is neutral. Look for opportunities to express genuine reactions." $Colors.Info
} else {
    Write-ColorOutput "Voice authenticity is good. Continue developing characteristic patterns." $Colors.Authentic
}

Write-ColorOutput "`n========================================" $Colors.Header
Write-ColorOutput "  Analysis Complete" $Colors.Header
Write-ColorOutput "========================================`n" $Colors.Header
