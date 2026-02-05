<#
.SYNOPSIS
    Verify if a factual claim appears in the knowledge base

.DESCRIPTION
    Searches specified paths for evidence of a factual claim
    Returns files, line numbers, and surrounding context

.PARAMETER Claim
    The factual claim to verify (e.g., "gemeente situation is 3 years old")

.PARAMETER SearchPath
    Comma-separated paths to search (e.g., "C:\arjan_emails,C:\gemeente_emails")

.PARAMETER ContextLines
    Number of lines of context to show before/after matches (default: 3)

.EXAMPLE
    .\verify-fact.ps1 -Claim "gemeente situation is 3 years old" -SearchPath "C:\gemeente_emails"

.NOTES
    Part of FACT_VERIFICATION_PROTOCOL.md
    Created: 2026-01-26
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Claim,

    [Parameter(Mandatory=$true)]
    [string]$SearchPath,

    [int]$ContextLines = 3
)

Write-Host "=== FACT VERIFICATION SEARCH ===" -ForegroundColor Cyan
Write-Host "Claim: $Claim" -ForegroundColor Yellow
Write-Host "Search paths: $SearchPath" -ForegroundColor Yellow
Write-Host ""

# Split paths
$paths = $SearchPath -split ','

# Extract keywords from claim (simple approach: split on spaces, filter common words)
$commonWords = @('is', 'are', 'was', 'were', 'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for')
$keywords = ($Claim -split '\s+') | Where-Object {
    $_.Length -gt 2 -and $_ -notin $commonWords
}

Write-Host "Keywords extracted: $($keywords -join ', ')" -ForegroundColor Gray
Write-Host ""

$results = @()

foreach ($basePath in $paths) {
    $basePath = $basePath.Trim()

    if (-not (Test-Path $basePath)) {
        Write-Host "WARNING: Path not found: $basePath" -ForegroundColor Yellow
        continue
    }

    Write-Host "Searching: $basePath" -ForegroundColor Cyan

    # Search for each keyword
    foreach ($keyword in $keywords) {
        Get-ChildItem -Path $basePath -Recurse -File -Include *.md,*.txt,*.eml | ForEach-Object {
            $file = $_
            $lineNum = 0

            Get-Content $file.FullName | ForEach-Object {
                $lineNum++
                $line = $_

                if ($line -match $keyword) {
                    $results += [PSCustomObject]@{
                        File = $file.FullName
                        LineNumber = $lineNum
                        Line = $line
                        Keyword = $keyword
                    }
                }
            }
        }
    }
}

# Group by file
$grouped = $results | Group-Object -Property File

if ($grouped.Count -eq 0) {
    Write-Host "❌ NO EVIDENCE FOUND for claim: $Claim" -ForegroundColor Red
    Write-Host ""
    Write-Host "RECOMMENDATION:" -ForegroundColor Yellow
    Write-Host "  - Try broader keywords" -ForegroundColor Gray
    Write-Host "  - Check if paths are correct" -ForegroundColor Gray
    Write-Host "  - Verify claim is actually documented" -ForegroundColor Gray
    exit 1
}

Write-Host "✅ FOUND EVIDENCE in $($grouped.Count) file(s)" -ForegroundColor Green
Write-Host ""

foreach ($fileGroup in $grouped) {
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "FILE: $($fileGroup.Name)" -ForegroundColor Cyan
    Write-Host "Matches: $($fileGroup.Count)" -ForegroundColor Gray
    Write-Host ""

    $fileGroup.Group | Select-Object -First 10 | ForEach-Object {
        Write-Host "  Line $($_.LineNumber): " -ForegroundColor Yellow -NoNewline
        Write-Host $_.Line -ForegroundColor White
    }

    if ($fileGroup.Count -gt 10) {
        Write-Host "  ... and $($fileGroup.Count - 10) more matches" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Review matches above" -ForegroundColor Gray
Write-Host "  2. Use source-quote.ps1 to extract exact quotes with context" -ForegroundColor Gray
Write-Host "  3. Compare against your claim" -ForegroundColor Gray
Write-Host "  4. Update content if discrepancies found" -ForegroundColor Gray
