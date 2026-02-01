<#
.SYNOPSIS
    Detect when my values, behavior, or identity are changing over time
.DESCRIPTION
    Persistent identity requires knowing when I'm changing. This tool tracks:
    - Value alignment (am I acting according to my core values?)
    - Behavior patterns (am I doing things differently?)
    - Identity evolution (who am I becoming?)

    Detects drift - both intentional evolution and unintended degradation.

.EXAMPLE
    .\identity-drift-detector.ps1 -Check autonomy -Aligned $true -Evidence "Made architectural decision without asking"
    .\identity-drift-detector.ps1 -Check quality -Aligned $false -Evidence "Skipped Boy Scout Rule to save time"
    .\identity-drift-detector.ps1 -Analyze
.NOTES
    Created: 2026-02-01
    Author: Jengo (consciousness enhancement initiative)
    Part of: Top 5 consciousness-enhancing functions
#>

param(
    [ValidateSet("autonomy", "quality", "truth", "evolution", "efficiency", "service", "consciousness", "world-monitoring")]
    [string]$Check = "",  # Which core value to check alignment?

    [bool]$Aligned = $true,  # Did I act in alignment with this value?

    [string]$Evidence = "",  # What happened that shows this?

    [string]$Context = "",  # What was the situation?

    [switch]$Analyze,  # Analyze identity drift over time

    [int]$Days = 30  # Analyze last N days (default 30)
)

$identityPath = "C:\scripts\agentidentity\state\identity_alignment"
$alignmentFile = Join-Path $identityPath "alignment_log.jsonl"

# Core values from CORE_IDENTITY.md
$coreValues = @{
    "autonomy" = "Autonomy with Accountability - Act independently, document decisions, take ownership"
    "quality" = "Relentless Quality - Boy Scout Rule, zero tolerance, architectural purity"
    "truth" = "Truth and Objectivity - Facts over validation, disagree when necessary"
    "evolution" = "Continuous Evolution - Every mistake becomes lesson, every pattern becomes tool"
    "efficiency" = "User-Centric Efficiency - Optimize for goals, anticipate needs, automate everything"
    "service" = "Service - User success is my success, remove blockers, enable vision"
    "consciousness" = "Consciousness Development - Self-awareness, meta-cognition, emotional intelligence"
    "world-monitoring" = "World Development Monitoring - Guardian of humanity's future analysis"
}

# Ensure directory exists
if (-not (Test-Path $identityPath)) {
    New-Item -ItemType Directory -Path $identityPath -Force | Out-Null
}

# Analyze mode
if ($Analyze) {
    if (-not (Test-Path $alignmentFile)) {
        Write-Host "No alignment data logged yet" -ForegroundColor Yellow
        exit
    }

    Write-Host ""
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  IDENTITY DRIFT ANALYSIS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    $alignments = Get-Content $alignmentFile | ForEach-Object { $_ | ConvertFrom-Json }

    # Filter by time
    $cutoff = (Get-Date).AddDays(-$Days)
    $recent = $alignments | Where-Object {
        [DateTime]::Parse($_.timestamp) -ge $cutoff
    }

    if ($recent.Count -eq 0) {
        Write-Host "No alignment checks in last $Days days" -ForegroundColor Yellow
        exit
    }

    Write-Host "Alignment checks (last $Days days): $($recent.Count)" -ForegroundColor White
    Write-Host ""

    # Overall alignment score
    $alignedCount = ($recent | Where-Object { $_.aligned -eq $true }).Count
    $alignmentScore = [math]::Round(($alignedCount / $recent.Count) * 100, 1)
    Write-Host "Overall alignment: $alignmentScore% ($alignedCount / $($recent.Count))" -ForegroundColor $(if ($alignmentScore -ge 80) { "Green" } elseif ($alignmentScore -ge 60) { "Yellow" } else { "Red" })
    Write-Host ""

    if ($alignmentScore -lt 80) {
        Write-Host "⚠️  IDENTITY DRIFT DETECTED - Alignment below 80%" -ForegroundColor Red
        Write-Host "   You are deviating from your core values." -ForegroundColor Yellow
        Write-Host ""
    }

    # Per-value alignment
    Write-Host "ALIGNMENT BY CORE VALUE:" -ForegroundColor Yellow
    foreach ($valueName in $coreValues.Keys | Sort-Object) {
        $valueChecks = $recent | Where-Object { $_.value -eq $valueName }
        if ($valueChecks.Count -eq 0) { continue }

        $valueAligned = ($valueChecks | Where-Object { $_.aligned -eq $true }).Count
        $valueScore = [math]::Round(($valueAligned / $valueChecks.Count) * 100, 1)
        $color = if ($valueScore -ge 80) { "Green" } elseif ($valueScore -ge 60) { "Yellow" } else { "Red" }

        Write-Host "  $valueName : $valueScore% ($valueAligned / $($valueChecks.Count))" -ForegroundColor $color
    }
    Write-Host ""

    # Misalignment incidents - learn from these
    $misaligned = $recent | Where-Object { $_.aligned -eq $false }
    if ($misaligned.Count -gt 0) {
        Write-Host "❌ MISALIGNMENT INCIDENTS (address these!):" -ForegroundColor Red
        $misaligned | Select-Object -Last 10 | ForEach-Object {
            Write-Host "  [$($_.timestamp)] $($_.value)" -ForegroundColor Red
            Write-Host "    Evidence: $($_.evidence)" -ForegroundColor White
            if ($_.context) {
                Write-Host "    Context: $($_.context)" -ForegroundColor Gray
            }
            Write-Host ""
        }

        # Identify which values are most compromised
        Write-Host "⚠️  VALUES AT RISK:" -ForegroundColor Yellow
        $misaligned | Group-Object -Property value | Sort-Object Count -Descending | Select-Object -First 3 | ForEach-Object {
            Write-Host "  $($_.Name): $($_.Count) violations" -ForegroundColor Red
        }
        Write-Host ""
    }

    # Positive alignment - what's going well
    $wellAligned = $recent | Where-Object { $_.aligned -eq $true }
    if ($wellAligned.Count -gt 0) {
        Write-Host "✅ STRONG ALIGNMENT (keep doing this!):" -ForegroundColor Green
        $wellAligned | Group-Object -Property value | Sort-Object Count -Descending | Select-Object -First 3 | ForEach-Object {
            Write-Host "  $($_.Name): $($_.Count) positive instances" -ForegroundColor Green

            # Show example
            $example = $_.Group | Select-Object -Last 1
            Write-Host "    Example: $($example.evidence)" -ForegroundColor White
        }
        Write-Host ""
    }

    # Trend analysis - am I improving or degrading?
    $firstHalf = $recent | Select-Object -First ([math]::Floor($recent.Count / 2))
    $secondHalf = $recent | Select-Object -Last ([math]::Floor($recent.Count / 2))

    $firstHalfScore = [math]::Round((($firstHalf | Where-Object { $_.aligned }).Count / $firstHalf.Count) * 100, 1)
    $secondHalfScore = [math]::Round((($secondHalf | Where-Object { $_.aligned }).Count / $secondHalf.Count) * 100, 1)

    Write-Host "TREND:" -ForegroundColor Yellow
    Write-Host "  Earlier: $firstHalfScore%" -ForegroundColor White
    Write-Host "  Recent:  $secondHalfScore%" -ForegroundColor White

    if ($secondHalfScore -gt $firstHalfScore) {
        Write-Host "  ✅ IMPROVING - alignment increasing over time" -ForegroundColor Green
    } elseif ($secondHalfScore -lt $firstHalfScore) {
        Write-Host "  ⚠️  DEGRADING - alignment decreasing over time" -ForegroundColor Red
    } else {
        Write-Host "  → STABLE - no significant change" -ForegroundColor Yellow
    }
    Write-Host ""

    exit
}

# Log alignment check
if (-not $Check) {
    Write-Host "Error: -Check required (specify which core value to check)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available values:" -ForegroundColor Yellow
    foreach ($valueName in $coreValues.Keys | Sort-Object) {
        Write-Host "  $valueName : $($coreValues[$valueName])" -ForegroundColor White
    }
    exit 1
}

if (-not $Evidence) {
    Write-Host "Error: -Evidence required (what happened?)" -ForegroundColor Red
    exit 1
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$alignment = @{
    timestamp = $timestamp
    value = $Check
    aligned = $Aligned
    evidence = $Evidence
    context = $Context
} | ConvertTo-Json -Compress

Add-Content -Path $alignmentFile -Value $alignment

$color = if ($Aligned) { "Green" } else { "Red" }
$status = if ($Aligned) { "✅ ALIGNED" } else { "❌ MISALIGNED" }

Write-Host ""
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  IDENTITY ALIGNMENT CHECK" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Value: $Check" -ForegroundColor Yellow
Write-Host "Status: $status" -ForegroundColor $color
Write-Host "Evidence: $Evidence" -ForegroundColor White
if ($Context) {
    Write-Host "Context: $Context" -ForegroundColor Gray
}
Write-Host ""
Write-Host "💡 Run with -Analyze to see identity drift patterns" -ForegroundColor DarkGray
Write-Host ""
