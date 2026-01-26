<#
.SYNOPSIS
    Find all mentions of a topic across knowledge base and detect contradictions

.DESCRIPTION
    Searches multiple source types (emails, blogs, reflections) for mentions of a topic
    Groups results by source type
    Flags potential contradictions

.PARAMETER Topic
    Topic to search for (e.g., "gemeente marriage", "€10,000")

.PARAMETER Paths
    Array of base paths to search (e.g., @("C:\gemeente_emails", "C:\blogs", "C:\scripts\_machine"))

.PARAMETER ShowContradictions
    Highlight potential contradictions based on keyword analysis

.EXAMPLE
    .\fact-triangulate.ps1 -Topic "gemeente marriage" -Paths @("C:\gemeente_emails", "C:\scripts\agentidentity")

.NOTES
    Part of FACT_VERIFICATION_PROTOCOL.md
    Created: 2026-01-26
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Topic,

    [Parameter(Mandatory=$true)]
    [string[]]$Paths,

    [switch]$ShowContradictions
)

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "FACT TRIANGULATION: $Topic" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Extract keywords
$keywords = ($Topic -split '\s+') | Where-Object { $_.Length -gt 2 }
Write-Host "Keywords: $($keywords -join ', ')" -ForegroundColor Gray
Write-Host "Search paths: $($Paths.Count) location(s)" -ForegroundColor Gray
Write-Host ""

$allMentions = @()

foreach ($basePath in $Paths) {
    if (-not (Test-Path $basePath)) {
        Write-Host "⚠️ Path not found: $basePath" -ForegroundColor Yellow
        continue
    }

    Write-Host "Searching: $basePath..." -ForegroundColor Cyan

    Get-ChildItem -Path $basePath -Recurse -File -Include *.md,*.txt,*.eml -ErrorAction SilentlyContinue | ForEach-Object {
        $file = $_
        $lineNum = 0
        $fileContent = Get-Content $file.FullName -ErrorAction SilentlyContinue

        foreach ($line in $fileContent) {
            $lineNum++
            $matchCount = 0

            foreach ($keyword in $keywords) {
                if ($line -match [regex]::Escape($keyword)) {
                    $matchCount++
                }
            }

            if ($matchCount -gt 0) {
                # Determine source type
                $sourceType = switch -Regex ($file.DirectoryName) {
                    'email' { 'Email' }
                    'blog' { 'Blog' }
                    'reflection' { 'Reflection' }
                    'agentidentity' { 'Agent Knowledge' }
                    'gemeente' { 'Gemeente Docs' }
                    default { 'Other' }
                }

                $allMentions += [PSCustomObject]@{
                    File = $file.FullName
                    FileName = $file.Name
                    LineNumber = $lineNum
                    Line = $line.Trim()
                    SourceType = $sourceType
                    MatchCount = $matchCount
                    Keywords = ($keywords | Where-Object { $line -match [regex]::Escape($_) }) -join ', '
                }
            }
        }
    }
}

if ($allMentions.Count -eq 0) {
    Write-Host "❌ NO MENTIONS FOUND" -ForegroundColor Red
    Write-Host ""
    Write-Host "TROUBLESHOOTING:" -ForegroundColor Yellow
    Write-Host "  - Verify topic spelling" -ForegroundColor Gray
    Write-Host "  - Try broader keywords" -ForegroundColor Gray
    Write-Host "  - Check if paths contain relevant files" -ForegroundColor Gray
    exit 0
}

Write-Host "✅ Found $($allMentions.Count) mentions across $($allMentions | Select-Object -Unique File | Measure-Object | Select-Object -ExpandProperty Count) files" -ForegroundColor Green
Write-Host ""

# Group by source type
$bySourceType = $allMentions | Group-Object -Property SourceType

foreach ($sourceGroup in $bySourceType) {
    Write-Host "─────────────────────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "SOURCE TYPE: $($sourceGroup.Name)" -ForegroundColor Cyan
    Write-Host "Mentions: $($sourceGroup.Count)" -ForegroundColor Gray
    Write-Host ""

    # Group by file within source type
    $byFile = $sourceGroup.Group | Group-Object -Property FileName

    foreach ($fileGroup in $byFile | Select-Object -First 5) {
        Write-Host "  📄 $($fileGroup.Name)" -ForegroundColor Yellow

        $fileGroup.Group | Select-Object -First 3 | ForEach-Object {
            Write-Host "     Line $($_.LineNumber): $($_.Line.Substring(0, [Math]::Min(80, $_.Line.Length)))..." -ForegroundColor White
        }

        if ($fileGroup.Count -gt 3) {
            Write-Host "     ... and $($fileGroup.Count - 3) more mentions" -ForegroundColor Gray
        }
        Write-Host ""
    }

    if ($byFile.Count -gt 5) {
        Write-Host "  ... and $($byFile.Count - 5) more files" -ForegroundColor Gray
        Write-Host ""
    }
}

# Contradiction detection
if ($ShowContradictions) {
    Write-Host "─────────────────────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "CONTRADICTION ANALYSIS" -ForegroundColor Cyan
    Write-Host ""

    # Look for conflicting keywords
    $contradictionKeywords = @(
        @('yes', 'no'),
        @('true', 'false'),
        @('completed', 'ongoing', 'pending'),
        @('approved', 'denied', 'rejected'),
        @('€10,000', '€10k+', 'duizenden', 'thousands'),
        @('2 years', '3 years', '4 years'),
        @('resolved', 'unresolved', 'impasse', 'stuck')
    )

    $detectedContradictions = @()

    foreach ($pair in $contradictionKeywords) {
        $mentions1 = $allMentions | Where-Object { $_.Line -match $pair[0] }
        $mentions2 = $allMentions | Where-Object { $_.Line -match $pair[1] }

        if ($mentions1.Count -gt 0 -and $mentions2.Count -gt 0) {
            $detectedContradictions += [PSCustomObject]@{
                Term1 = $pair[0]
                Count1 = $mentions1.Count
                Term2 = $pair[1]
                Count2 = $mentions2.Count
            }
        }
    }

    if ($detectedContradictions.Count -gt 0) {
        Write-Host "⚠️ POTENTIAL CONTRADICTIONS DETECTED:" -ForegroundColor Yellow
        Write-Host ""

        $detectedContradictions | ForEach-Object {
            Write-Host "  🔍 '$($_.Term1)' ($($_.Count1) mentions) vs '$($_.Term2)' ($($_.Count2) mentions)" -ForegroundColor Yellow
        }

        Write-Host ""
        Write-Host "RECOMMENDATION: Manually review mentions to resolve contradictions" -ForegroundColor Gray
    } else {
        Write-Host "✅ No obvious contradictions detected" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Review mentions by source type" -ForegroundColor Gray
Write-Host "  2. Use source-quote.ps1 to get full context of key mentions" -ForegroundColor Gray
Write-Host "  3. Determine authoritative source if contradictions exist" -ForegroundColor Gray
Write-Host "  4. Update content to reflect verified facts" -ForegroundColor Gray
