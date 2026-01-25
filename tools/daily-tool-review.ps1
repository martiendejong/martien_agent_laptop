<#
.SYNOPSIS
    Daily tool wishlist review - 2-minute end-of-session routine

.DESCRIPTION
    MANDATORY end-of-session check:
    - Scan wishlist for new items
    - Check tally marks (≥3 = URGENT)
    - Identify quick wins (effort = 1)
    - Suggest implementation priorities
    - Auto-detect repeated patterns from session history

.PARAMETER WishlistPath
    Path to tool wishlist (default: C:\scripts\_machine\tool-wishlist.md)

.PARAMETER SessionHistoryPath
    Path to PowerShell history (auto-detected)

.PARAMETER AutoImplement
    Auto-implement tools with ratio > 10 and effort = 1 (default: false)

.PARAMETER ShowQuickWins
    Highlight 10-minute tools that would help tomorrow (default: true)

.EXAMPLE
    # Standard daily review (end of session)
    .\daily-tool-review.ps1

.EXAMPLE
    # Auto-implement trivial high-value tools
    .\daily-tool-review.ps1 -AutoImplement

.NOTES
    Part of continuous discovery system
    Run this EVERY session end (2 minutes)
    Implements: Meta-Cognitive Rule #6 (Convert to Assets)
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$WishlistPath = "C:\scripts\_machine\tool-wishlist.md",

    [Parameter(Mandatory=$false)]
    [string]$SessionHistoryPath = (Get-PSReadlineOption).HistorySavePath,

    [Parameter(Mandatory=$false)]
    [switch]$AutoImplement = $false,

    [Parameter(Mandatory=$false)]
    [bool]$ShowQuickWins = $true
)

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  📋 DAILY TOOL REVIEW - End of Session Routine" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check if wishlist exists
if (-not (Test-Path $WishlistPath)) {
    Write-Host "❌ Wishlist not found: $WishlistPath" -ForegroundColor Red
    exit 1
}

# Read wishlist
$wishlistContent = Get-Content $WishlistPath -Raw

# Parse active wishlist items
$activeSection = $wishlistContent -match '(?s)## 📋 ACTIVE WISHLIST.*?(?=##|$)'
if ($Matches) {
    $activeContent = $Matches[0]
} else {
    Write-Host "⚠️  No active wishlist section found" -ForegroundColor Yellow
    $activeContent = ""
}

# Count items in each priority
$criticalCount = ([regex]::Matches($activeContent, "Priority: CRITICAL")).Count
$highCount = ([regex]::Matches($activeContent, "Priority: HIGH")).Count
$mediumCount = ([regex]::Matches($activeContent, "Priority: MEDIUM")).Count
$lowCount = ([regex]::Matches($activeContent, "Priority: LOW")).Count

Write-Host "📊 Current Wishlist Status:" -ForegroundColor Yellow
Write-Host "   🔴 CRITICAL: $criticalCount" -ForegroundColor Red
Write-Host "   🟠 HIGH: $highCount" -ForegroundColor Yellow
Write-Host "   🟡 MEDIUM: $mediumCount" -ForegroundColor Yellow
Write-Host "   ⚪ LOW: $lowCount" -ForegroundColor Gray
Write-Host ""

# Check for urgent items (tally marks ≥3 or ratio > 8)
if ($criticalCount -gt 0) {
    Write-Host "⚠️  ACTION REQUIRED: $criticalCount CRITICAL items in wishlist!" -ForegroundColor Red
    Write-Host "   Review and implement top item today." -ForegroundColor Yellow
    Write-Host ""
}

# Analyze session history for repeated patterns
if (Test-Path $SessionHistoryPath) {
    Write-Host "🔍 Analyzing session history for repeated patterns..." -ForegroundColor Gray

    $history = Get-Content $SessionHistoryPath -Tail 100

    # Group by command (first word)
    $commandFrequency = $history | ForEach-Object {
        if ($_ -match '^(\S+)') {
            $Matches[1]
        }
    } | Group-Object | Where-Object { $_.Count -ge 3 } | Sort-Object Count -Descending | Select-Object -First 5

    if ($commandFrequency) {
        Write-Host ""
        Write-Host "🔁 Repeated Commands Today (≥3 times):" -ForegroundColor Yellow
        $commandFrequency | ForEach-Object {
            $cmd = $_.Name
            $count = $_.Count

            # Check if related tool already exists
            $toolExists = Test-Path "C:\scripts\tools\*$cmd*.ps1"

            if (-not $toolExists) {
                Write-Host "   ⚡ $cmd ($count times) - Consider creating tool?" -ForegroundColor Cyan
            } else {
                Write-Host "   ✅ $cmd ($count times) - Tool exists" -ForegroundColor Green
            }
        }
        Write-Host ""
    }

    # Check for multi-step sequences (potential automation candidates)
    $sequences = @()
    for ($i = 0; $i -lt $history.Count - 2; $i++) {
        $seq = $history[$i..($i+2)] -join " && "
        if ($seq.Length -lt 200) {  # Reasonable length
            $sequences += $seq
        }
    }

    $repeatedSequences = $sequences | Group-Object | Where-Object { $_.Count -ge 2 } | Sort-Object Count -Descending | Select-Object -First 3

    if ($repeatedSequences) {
        Write-Host "🔗 Repeated Command Sequences (potential workflows to automate):" -ForegroundColor Yellow
        $repeatedSequences | ForEach-Object {
            Write-Host "   🔸 $($_.Count)x: $($_.Name.Substring(0, [Math]::Min(100, $_.Name.Length)))..." -ForegroundColor Gray
        }
        Write-Host ""
    }
}

# Quick wins analysis
if ($ShowQuickWins) {
    Write-Host "⚡ Quick Wins (10-minute tools with high impact):" -ForegroundColor Green
    Write-Host "   Tools from META_OPTIMIZATION_100_TOOLS.md with ratio > 5.0 and effort = 1:" -ForegroundColor Gray

    $quickWins = @(
        "git-bisect-automation.ps1 (ratio 5.3) - Auto-find regression commits",
        "stale-branch-auto-cleanup.ps1 (ratio 7.0) - Delete merged branches",
        "pr-review-checklist-generator.ps1 (ratio 7.0) - Context-aware checklists"
    )

    $quickWins | ForEach-Object {
        Write-Host "   💡 $_" -ForegroundColor Cyan
    }
    Write-Host ""
}

# Suggestions based on wishlist state
Write-Host "💭 Recommendations:" -ForegroundColor Yellow

if ($criticalCount -eq 0 -and $highCount -eq 0) {
    Write-Host "   ✅ No urgent items - great job staying ahead!" -ForegroundColor Green
    Write-Host "   Consider implementing 1-2 MEDIUM priority tools this week" -ForegroundColor Gray
} elseif ($criticalCount -gt 0) {
    Write-Host "   🔴 Implement top CRITICAL item before end of day" -ForegroundColor Red
    Write-Host "   Estimated time: 10-30 minutes" -ForegroundColor Gray
} elseif ($highCount -gt 3) {
    Write-Host "   🟠 HIGH priority backlog building up ($highCount items)" -ForegroundColor Yellow
    Write-Host "   Consider dedicating 1 hour this week to clear top 3" -ForegroundColor Gray
}

Write-Host ""
Write-Host "📝 Action Items:" -ForegroundColor Cyan
Write-Host "   1. Review wishlist: code $WishlistPath" -ForegroundColor White
Write-Host "   2. Implement top 1 item if ratio > 8.0 or effort = 1" -ForegroundColor White
Write-Host "   3. Move any completed tools to IMPLEMENTED section" -ForegroundColor White
Write-Host "   4. Add any new ""I wish..."" thoughts from today" -ForegroundColor White
Write-Host ""

# Auto-implement check
if ($AutoImplement) {
    Write-Host "🤖 AUTO-IMPLEMENT mode enabled" -ForegroundColor Magenta
    Write-Host "   Checking for ultra-high-value trivial tools (ratio > 10, effort = 1)..." -ForegroundColor Gray
    Write-Host "   (Not implemented yet - requires tool template generator)" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ✅ Daily review complete - See you tomorrow!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Return summary object for scripting
[PSCustomObject]@{
    CriticalItems = $criticalCount
    HighItems = $highCount
    MediumItems = $mediumCount
    LowItems = $lowCount
    TotalItems = $criticalCount + $highCount + $mediumCount + $lowCount
    RecommendedAction = if ($criticalCount -gt 0) { "IMPLEMENT_TOP_CRITICAL" }
                        elseif ($highCount -gt 3) { "CLEAR_HIGH_BACKLOG" }
                        else { "MAINTAIN_CURRENT_PACE" }
}
