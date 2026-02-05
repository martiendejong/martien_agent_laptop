<#
.SYNOPSIS
    Monitor documentation file sizes and flag oversized files

.DESCRIPTION
    Scans all .md files in C:\scripts recursively and identifies files
    that exceed optimal token count (> 25K tokens ~= 100KB).
    Suggests splits or summarization for oversized files.

.PARAMETER Path
    Root path to scan (default: C:\scripts)

.PARAMETER TokenThreshold
    Token count threshold (default: 25000, approximate 4 chars per token)

.PARAMETER OutputReport
    Generate detailed report file (default: $true)

.EXAMPLE
    .\doc-size-monitor.ps1
    Scan C:\scripts for oversized documentation files

.EXAMPLE
    .\doc-size-monitor.ps1 -Path C:\Projects\client-manager -TokenThreshold 10000
    Scan client-manager with lower threshold

.NOTES
    Part of Improvement #4: Smart file size warnings
    Expert: Prof. Emily Bradford (Documentation structure patterns)
#>

param(
    [string]$Path = "C:\scripts",
    [int]$TokenThreshold = 25000,
    [bool]$OutputReport = $true
)

# Approximate tokens from character count (rough: 1 token ~= 4 characters)
function Get-ApproximateTokenCount {
    param([string]$FilePath)

    try {
        $content = Get-Content -Path $FilePath -Raw -ErrorAction Stop
        $charCount = $content.Length
        return [int]($charCount / 4)
    }
    catch {
        Write-Warning "Could not read file: $FilePath"
        return 0
    }
}

# Get file size category
function Get-SizeCategory {
    param([int]$Tokens, [int]$Threshold)

    if ($Tokens -gt $Threshold * 2) {
        return "CRITICAL"
    }
    elseif ($Tokens -gt $Threshold * 1.5) {
        return "HIGH"
    }
    elseif ($Tokens -gt $Threshold) {
        return "MODERATE"
    }
    else {
        return "OK"
    }
}

# Generate split suggestions
function Get-SplitSuggestions {
    param([string]$FilePath, [int]$Tokens, [int]$Threshold)

    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $suggestions = @()

    if ($Tokens -gt $Threshold * 2) {
        $suggestions += "Consider splitting into 3-4 files"
        $suggestions += "Generate executive summary: ${fileName}_SUMMARY.md"
        $suggestions += "Create overview: ${fileName}_OVERVIEW.md"
    }
    elseif ($Tokens -gt $Threshold * 1.5) {
        $suggestions += "Consider splitting into 2-3 files"
        $suggestions += "Generate summary: ${fileName}_SUMMARY.md"
    }
    elseif ($Tokens -gt $Threshold) {
        $suggestions += "Generate summary file: ${fileName}_SUMMARY.md"
        $suggestions += "Consider splitting if content is independent"
    }

    return $suggestions
}

# Main execution
Write-Host "Scanning documentation files in: $Path" -ForegroundColor Cyan
Write-Host "Token threshold: $TokenThreshold (~$([int]($TokenThreshold * 4 / 1024))KB)" -ForegroundColor Cyan
Write-Host ""

# Find all markdown files (excluding node_modules, .git)
$mdFiles = Get-ChildItem -Path $Path -Filter "*.md" -Recurse -File |
    Where-Object {
        $_.FullName -notmatch 'node_modules' -and
        $_.FullName -notmatch '\.git' -and
        $_.FullName -notmatch 'playwright'
    }

$results = @()
$oversizedCount = 0
$totalFiles = 0

foreach ($file in $mdFiles) {
    $totalFiles++
    $tokens = Get-ApproximateTokenCount -FilePath $file.FullName
    $category = Get-SizeCategory -Tokens $tokens -Threshold $TokenThreshold

    if ($category -ne "OK") {
        $oversizedCount++
        $suggestions = Get-SplitSuggestions -FilePath $file.FullName -Tokens $tokens -Threshold $TokenThreshold

        $result = [PSCustomObject]@{
            File = $file.FullName.Replace($Path, "").TrimStart('\')
            Tokens = $tokens
            Size_KB = [int]($file.Length / 1024)
            Category = $category
            Ratio = [math]::Round($tokens / $TokenThreshold, 2)
            Suggestions = $suggestions -join "; "
        }

        $results += $result

        # Display warning
        $color = switch ($category) {
            "CRITICAL" { "Red" }
            "HIGH" { "Yellow" }
            "MODERATE" { "DarkYellow" }
        }

        Write-Host "[$category] " -ForegroundColor $color -NoNewline
        Write-Host "$($result.File)" -ForegroundColor White
        Write-Host "  Size: $($result.Size_KB)KB (~$tokens tokens, ${($result.Ratio)}x threshold)" -ForegroundColor Gray
        foreach ($suggestion in $suggestions) {
            Write-Host "  → $suggestion" -ForegroundColor DarkGray
        }
        Write-Host ""
    }
}

# Summary
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "  Total files scanned: $totalFiles" -ForegroundColor White
Write-Host "  Oversized files: $oversizedCount" -ForegroundColor $(if ($oversizedCount -gt 0) { "Yellow" } else { "Green" })
Write-Host "  Percentage: $([math]::Round(($oversizedCount / $totalFiles) * 100, 1))%" -ForegroundColor White

if ($oversizedCount -gt 0) {
    Write-Host ""
    Write-Host "RECOMMENDATIONS:" -ForegroundColor Yellow
    Write-Host "  1. Run doc-summarizer.ps1 to auto-generate summaries" -ForegroundColor White
    Write-Host "  2. Review CRITICAL files for immediate splitting" -ForegroundColor White
    Write-Host "  3. Consider implementing content chunking strategy" -ForegroundColor White
}

# Generate report file
if ($OutputReport -and $results.Count -gt 0) {
    $reportPath = "C:\scripts\_machine\doc-size-report.md"

    $reportContent = @"
# Documentation Size Report
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Summary
- Total files scanned: $totalFiles
- Oversized files: $oversizedCount
- Token threshold: $TokenThreshold
- Scan path: $Path

## Oversized Files

| File | Size (KB) | Tokens | Category | Ratio | Suggestions |
|------|-----------|--------|----------|-------|-------------|
"@

    foreach ($result in ($results | Sort-Object -Property Tokens -Descending)) {
        $reportContent += "`n| $($result.File) | $($result.Size_KB) | $($result.Tokens) | $($result.Category) | $($result.Ratio)x | $($result.Suggestions) |"
    }

    $reportContent += @"


## Recommendations

### Immediate Actions (CRITICAL files)
$(
    $critical = $results | Where-Object { $_.Category -eq "CRITICAL" }
    if ($critical) {
        ($critical | ForEach-Object { "- Split ``$($_.File)`` ($($_.Tokens) tokens)" }) -join "`n"
    } else {
        "None"
    }
)

### Medium Priority (HIGH files)
$(
    $high = $results | Where-Object { $_.Category -eq "HIGH" }
    if ($high) {
        ($high | ForEach-Object { "- Review ``$($_.File)`` for splitting potential" }) -join "`n"
    } else {
        "None"
    }
)

### Low Priority (MODERATE files)
$(
    $moderate = $results | Where-Object { $_.Category -eq "MODERATE" }
    if ($moderate) {
        ($moderate | ForEach-Object { "- Generate summary for ``$($_.File)``" }) -join "`n"
    } else {
        "None"
    }
)

## Next Steps

1. Run ``doc-summarizer.ps1`` to auto-generate summary files
2. Split CRITICAL files manually or with AI assistance
3. Update cross-references in documentation
4. Re-run this monitor to verify improvements

---
*Generated by doc-size-monitor.ps1 (Improvement #4)*
"@

    Set-Content -Path $reportPath -Value $reportContent -Encoding UTF8
    Write-Host ""
    Write-Host "Report saved to: $reportPath" -ForegroundColor Green
}

Write-Host "=" * 80 -ForegroundColor Cyan
