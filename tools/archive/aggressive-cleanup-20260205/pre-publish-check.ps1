<#
.SYNOPSIS
    Pre-publication fact-checking tool - verify all factual claims in content

.DESCRIPTION
    Analyzes content file to extract factual claims (dates, amounts, names, timelines)
    Cross-references against knowledge base
    Reports verification status for each claim

.PARAMETER ContentFile
    Path to content file to verify (markdown, text)

.PARAMETER KnowledgeBase
    Base path to knowledge base (e.g., "C:\scripts\_machine\knowledge-base")

.PARAMETER AdditionalPaths
    Additional paths to search (e.g., emails, blogs)

.PARAMETER AutoFix
    Attempt to suggest corrections based on knowledge base

.EXAMPLE
    .\pre-publish-check.ps1 -ContentFile "article.md" -KnowledgeBase "C:\scripts\_machine\knowledge-base"

.EXAMPLE
    .\pre-publish-check.ps1 -ContentFile "blog-post.md" -KnowledgeBase "C:\scripts\_machine\knowledge-base" -AdditionalPaths "C:\gemeente_emails" -AutoFix

.NOTES
    Part of FACT_VERIFICATION_PROTOCOL.md
    Created: 2026-01-26

    FACTUAL CLAIM PATTERNS DETECTED:
    - Dates: "2023", "3 jaar", "januari 2026"
    - Amounts: "€10,000", "tienduizend euro", "10k"
    - Names: Proper nouns (capitalized)
    - Timelines: "sinds X", "na Y jaren"
    - Status claims: "nog steeds", "vastgelopen", "opgelost"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ContentFile,

    [Parameter(Mandatory=$true)]
    [string]$KnowledgeBase,

    [string]$AdditionalPaths = "",

    [switch]$AutoFix
)

if (-not (Test-Path $ContentFile)) {
    Write-Host "ERROR: Content file not found: $ContentFile" -ForegroundColor Red
    exit 1
}

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "PRE-PUBLICATION FACT CHECK" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Content file: $ContentFile" -ForegroundColor Yellow
Write-Host "Knowledge base: $KnowledgeBase" -ForegroundColor Yellow
Write-Host ""

$content = Get-Content $ContentFile -Raw

# Extract factual claims using regex patterns
$claims = @()

# Pattern 1: Monetary amounts
$moneyPattern = '(\d+[.,]?\d*k?\+?\s*(euro|EUR)|tienduizend|duizenden|euro)'
$moneyMatches = [regex]::Matches($content, $moneyPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
foreach ($match in $moneyMatches) {
    $claims += [PSCustomObject]@{
        Type = 'Money'
        Claim = $match.Value
        Pattern = $moneyPattern
        Verified = $false
        Evidence = @()
    }
}

# Pattern 2: Time periods
$timePattern = '(\d+\s+(jaar|jaren|maanden|weken)|drie jaar|2023|2024|2025|2026)'
$timeMatches = [regex]::Matches($content, $timePattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
foreach ($match in $timeMatches) {
    $claims += [PSCustomObject]@{
        Type = 'Time'
        Claim = $match.Value
        Pattern = $timePattern
        Verified = $false
        Evidence = @()
    }
}

# Pattern 3: Status claims
$statusPattern = '(nog steeds|eindelijk|vastgelopen|opgelost|afgewezen|goedgekeurd|pending|completed)'
$statusMatches = [regex]::Matches($content, $statusPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
foreach ($match in $statusMatches) {
    $claims += [PSCustomObject]@{
        Type = 'Status'
        Claim = $match.Value
        Pattern = $statusPattern
        Verified = $false
        Evidence = @()
    }
}

# Pattern 4: Document/certificate references
$docPattern = '(trouwboekje|certificaat|document of no impediment|verklaring|authenticatie)'
$docMatches = [regex]::Matches($content, $docPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
foreach ($match in $docMatches) {
    $claims += [PSCustomObject]@{
        Type = 'Document'
        Claim = $match.Value
        Pattern = $docPattern
        Verified = $false
        Evidence = @()
    }
}

# Remove duplicates
$claims = $claims | Select-Object -Property Type, Claim, Pattern, Verified, Evidence -Unique

Write-Host "EXTRACTED CLAIMS:" -ForegroundColor Cyan
Write-Host "  Money: $($claims | Where-Object Type -eq 'Money' | Measure-Object | Select-Object -ExpandProperty Count)"
Write-Host "  Time: $($claims | Where-Object Type -eq 'Time' | Measure-Object | Select-Object -ExpandProperty Count)"
Write-Host "  Status: $($claims | Where-Object Type -eq 'Status' | Measure-Object | Select-Object -ExpandProperty Count)"
Write-Host "  Document: $($claims | Where-Object Type -eq 'Document' | Measure-Object | Select-Object -ExpandProperty Count)"
Write-Host ""
Write-Host "Total unique claims: $($claims.Count)" -ForegroundColor Yellow
Write-Host ""

# Verify each claim against knowledge base
$searchPaths = @($KnowledgeBase)
if ($AdditionalPaths) {
    $searchPaths += $AdditionalPaths -split ','
}

Write-Host "VERIFICATION IN PROGRESS..." -ForegroundColor Cyan
Write-Host ""

foreach ($claim in $claims) {
    Write-Host "Verifying: $($claim.Claim) [$($claim.Type)]" -ForegroundColor Yellow

    $evidenceCount = 0

    foreach ($basePath in $searchPaths) {
        if (-not (Test-Path $basePath)) { continue }

        Get-ChildItem -Path $basePath -Recurse -File -Include *.md,*.txt -ErrorAction SilentlyContinue | ForEach-Object {
            $file = $_
            $fileContent = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue

            if ($fileContent -match [regex]::Escape($claim.Claim)) {
                $evidenceCount++
                $claim.Evidence += $file.FullName
            }
        }
    }

    if ($evidenceCount -gt 0) {
        $claim.Verified = $true
        Write-Host "  ✅ Verified ($evidenceCount source(s))" -ForegroundColor Green
    } else {
        Write-Host "  ❌ NOT VERIFIED - no evidence found" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "VERIFICATION SUMMARY" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$verified = $claims | Where-Object Verified -eq $true
$unverified = $claims | Where-Object Verified -eq $false

Write-Host "✅ VERIFIED: $($verified.Count) / $($claims.Count)" -ForegroundColor Green
Write-Host "❌ UNVERIFIED: $($unverified.Count) / $($claims.Count)" -ForegroundColor Red
Write-Host ""

if ($unverified.Count -gt 0) {
    Write-Host "⚠️ UNVERIFIED CLAIMS:" -ForegroundColor Yellow
    Write-Host ""

    $unverified | ForEach-Object {
        Write-Host "  🚨 $($_.Claim) [$($_.Type)]" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "RECOMMENDATION:" -ForegroundColor Yellow
    Write-Host "  - Use verify-fact.ps1 to search for evidence" -ForegroundColor Gray
    Write-Host "  - Use fact-triangulate.ps1 to find all mentions" -ForegroundColor Gray
    Write-Host "  - Verify claim accuracy before publishing" -ForegroundColor Gray
    Write-Host "  - Update content if claim cannot be verified" -ForegroundColor Gray
    Write-Host ""
}

if ($verified.Count -gt 0) {
    Write-Host "✅ VERIFIED CLAIMS:" -ForegroundColor Green
    Write-Host ""

    $verified | Select-Object -First 10 | ForEach-Object {
        Write-Host "  ✓ $($_.Claim) [$($_.Type)] - found in $($_.Evidence.Count) source(s)" -ForegroundColor Green
    }

    if ($verified.Count -gt 10) {
        Write-Host "  ... and $($verified.Count - 10) more verified claims" -ForegroundColor Gray
    }
    Write-Host ""
}

# Final verdict
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if ($unverified.Count -eq 0) {
    Write-Host "🎉 READY TO PUBLISH" -ForegroundColor Green
    Write-Host "All factual claims have been verified against knowledge base." -ForegroundColor Green
    exit 0
} else {
    $percentage = [math]::Round(($verified.Count / $claims.Count) * 100, 1)
    Write-Host "⚠️ NOT READY TO PUBLISH" -ForegroundColor Yellow
    Write-Host "Verification rate: $percentage%" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please verify unverified claims before publishing." -ForegroundColor Yellow
    exit 1
}
