# Pattern Mining from Reflection Log
# Auto-extract learnings and patterns

param(
    [switch]$Mine,
    [switch]$ShowPatterns,
    [int]$MinOccurrences = 2
)

$reflectionLog = "C:\scripts\_machine\reflection.log.md"
$patternsFile = "C:\scripts\_machine\extracted-patterns.md"

function Extract-Patterns {
    if (!(Test-Path $reflectionLog)) {
        Write-Host "No reflection log found" -ForegroundColor Yellow
        return
    }

    $content = Get-Content $reflectionLog -Raw

    Write-Host "Mining patterns from reflection log..." -ForegroundColor Cyan

    # Pattern categories
    $patterns = @{
        Mistakes = @()
        Solutions = @()
        UserPatterns = @()
        TechnicalPatterns = @()
        ProcessImprovements = @()
    }

    # Extract mistake patterns
    $mistakeMatches = [regex]::Matches($content, '(?i)(mistake|error|failed|wrong|violation):(.*?)(?=\n\n|\z)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    foreach ($match in $mistakeMatches) {
        $patterns.Mistakes += $match.Groups[2].Value.Trim()
    }

    # Extract solution patterns
    $solutionMatches = [regex]::Matches($content, '(?i)(solution|fix|resolved|corrective action):(.*?)(?=\n\n|\z)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    foreach ($match in $solutionMatches) {
        $patterns.Solutions += $match.Groups[2].Value.Trim()
    }

    # Extract user patterns
    $userMatches = [regex]::Matches($content, '(?i)(user|Martien).{0,50}(prefers|likes|wants|expects|values)(.*?)(?=\n|\.)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    foreach ($match in $userMatches) {
        $patterns.UserPatterns += $match.Value.Trim()
    }

    # Extract "Pattern:" explicit mentions
    $explicitPatterns = [regex]::Matches($content, '\*\*Pattern.*?:\*\*(.*?)(?=\n\n|\*\*|\z)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    foreach ($match in $explicitPatterns) {
        $patterns.TechnicalPatterns += $match.Groups[1].Value.Trim()
    }

    # Extract process improvements
    $processMatches = [regex]::Matches($content, '(?i)(always|never|must|should) (.*?)(?=\n|\.)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    foreach ($match in $processMatches) {
        if ($match.Value.Length -lt 200) { # Keep concise
            $patterns.ProcessImprovements += $match.Value.Trim()
        }
    }

    # Deduplicate and count occurrences
    $deduped = @{}
    foreach ($category in $patterns.Keys) {
        $grouped = $patterns[$category] | Group-Object | Where-Object { $_.Count -ge $MinOccurrences } | Sort-Object -Property Count -Descending
        $deduped[$category] = $grouped | ForEach-Object {
            @{
                Pattern = $_.Name
                Count = $_.Count
            }
        }
    }

    # Generate patterns file
    $output = @"
# Extracted Patterns from Reflection Log

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm") UTC
**Source:** reflection.log.md
**Min Occurrences:** $MinOccurrences

---

## Mistake Patterns (Most Common First)

"@

    foreach ($item in $deduped.Mistakes) {
        $output += "`n- **[$($item.Count)x]** $($item.Pattern)"
    }

    $output += @"

---

## Solution Patterns

"@

    foreach ($item in $deduped.Solutions) {
        $output += "`n- **[$($item.Count)x]** $($item.Pattern)"
    }

    $output += @"

---

## User Behavior Patterns (Martien)

"@

    foreach ($item in $deduped.UserPatterns) {
        $output += "`n- **[$($item.Count)x]** $($item.Pattern)"
    }

    $output += @"

---

## Technical Patterns

"@

    foreach ($item in $deduped.TechnicalPatterns) {
        $output += "`n- **[$($item.Count)x]** $($item.Pattern)"
    }

    $output += @"

---

## Process Improvement Patterns

"@

    foreach ($item in $deduped.ProcessImprovements) {
        $output += "`n- **[$($item.Count)x]** $($item.Pattern)"
    }

    $output += @"

---

**Total Unique Patterns:** $(($deduped.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum)
**Categories:** $($deduped.Keys.Count)

"@

    $output | Set-Content $patternsFile

    Write-Host "Patterns extracted and saved to: $patternsFile" -ForegroundColor Green

    # Summary
    Write-Host "`nPattern Summary:" -ForegroundColor Cyan
    Write-Host "  Mistakes: $($deduped.Mistakes.Count)"
    Write-Host "  Solutions: $($deduped.Solutions.Count)"
    Write-Host "  User patterns: $($deduped.UserPatterns.Count)"
    Write-Host "  Technical: $($deduped.TechnicalPatterns.Count)"
    Write-Host "  Process improvements: $($deduped.ProcessImprovements.Count)"
}

function Show-ExtractedPatterns {
    if (!(Test-Path $patternsFile)) {
        Write-Host "No patterns file found. Run with -Mine first." -ForegroundColor Yellow
        return
    }

    Get-Content $patternsFile | Write-Host
}

# Main execution
if ($Mine) {
    Extract-Patterns
}
elseif ($ShowPatterns) {
    Show-ExtractedPatterns
}
else {
    Write-Host "PATTERN MINER" -ForegroundColor Cyan
    Write-Host "Usage:"
    Write-Host "  Mine patterns: .\pattern-miner.ps1 -Mine [-MinOccurrences 2]"
    Write-Host "  Show patterns: .\pattern-miner.ps1 -ShowPatterns"
}
