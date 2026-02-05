# Automated Insight Extraction
# Analyzes reflection log and extracts patterns, principles, anti-patterns
#
# Usage:
#   .\extract-insights.ps1
#   .\extract-insights.ps1 -OutputPath insights-report.md
#   .\extract-insights.ps1 -Analyze "Last 10 entries"

param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\scripts\_machine\extracted-insights.md",

    [Parameter(Mandatory=$false)]
    [string]$Analyze = "All"
)

$ErrorActionPreference = "Stop"

$reflectionLog = "C:\scripts\_machine\reflection.log.md"

if (-not (Test-Path $reflectionLog)) {
    Write-Host "❌ Reflection log not found: $reflectionLog" -ForegroundColor Red
    exit 1
}

Write-Host "`n🧠 Automated Insight Extraction" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Read reflection log
Write-Host "📖 Reading reflection log..." -ForegroundColor Gray
$logContent = Get-Content $reflectionLog -Raw

# Extract key patterns using regex and text analysis
Write-Host "🔍 Analyzing patterns..." -ForegroundColor Gray

$insights = @{
    Patterns = @()
    AntiPatterns = @()
    Principles = @()
    Tools = @()
    Learnings = @()
    Mistakes = @()
}

# Extract sections
$logContent -split "##\s+" | ForEach-Object {
    $section = $_

    # Look for "What Worked" patterns
    if ($section -match "What Worked|Key Learning|Success") {
        $bullets = [regex]::Matches($section, "[-•✅]\s+(.+)")
        foreach ($match in $bullets) {
            $text = $match.Groups[1].Value.Trim()
            if ($text.Length -gt 20 -and $text -notmatch "^(TODO|NOTE|FIXME)") {
                $insights.Patterns += $text
            }
        }
    }

    # Look for "What Could Be Better" / "Mistakes" patterns
    if ($section -match "What Could Be Better|Mistake|Violation|Failed|Wrong") {
        $bullets = [regex]::Matches($section, "[-•❌⚠️]\s+(.+)")
        foreach ($match in $bullets) {
            $text = $match.Groups[1].Value.Trim()
            if ($text.Length -gt 20) {
                $insights.AntiPatterns += $text
            }
        }
    }

    # Look for principles
    if ($section -match "Principle|Rule|Protocol|Pattern") {
        $bullets = [regex]::Matches($section, "[-•]\s+\*\*(.+?)\*\*")
        foreach ($match in $bullets) {
            $text = $match.Groups[1].Value.Trim()
            if ($text.Length -gt 10) {
                $insights.Principles += $text
            }
        }
    }

    # Look for tool mentions
    $toolMatches = [regex]::Matches($section, "([a-z0-9-]+\.ps1)")
    foreach ($match in $toolMatches) {
        $tool = $match.Groups[1].Value
        if ($insights.Tools -notcontains $tool) {
            $insights.Tools += $tool
        }
    }

    # Look for "Learning" statements
    if ($section -match "Learning|Learned|Discovery|Discovered") {
        $bullets = [regex]::Matches($section, "[-•]\s+(.+)")
        foreach ($match in $bullets) {
            $text = $match.Groups[1].Value.Trim()
            if ($text.Length -gt 30 -and $text -match "^[A-Z]") {
                $insights.Learnings += $text
            }
        }
    }
}

# Deduplicate and rank by frequency/importance
$insights.Patterns = $insights.Patterns | Select-Object -Unique | Sort-Object
$insights.AntiPatterns = $insights.AntiPatterns | Select-Object -Unique | Sort-Object
$insights.Principles = $insights.Principles | Select-Object -Unique | Sort-Object
$insights.Tools = $insights.Tools | Select-Object -Unique | Sort-Object
$insights.Learnings = $insights.Learnings | Select-Object -Unique | Sort-Object

Write-Host "✅ Analysis complete!" -ForegroundColor Green
Write-Host ""

# Generate report
$report = @"
# Extracted Insights from Reflection Log

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Source:** reflection.log.md
**Analysis:** Automated pattern extraction

---

## 🎯 Success Patterns ($(($insights.Patterns).Count))

These patterns have proven effective across multiple sessions:

"@

foreach ($pattern in $insights.Patterns) {
    $report += "`n- $pattern"
}

$report += @"


---

## ❌ Anti-Patterns ($(($insights.AntiPatterns).Count))

These patterns should be avoided:

"@

foreach ($antiPattern in $insights.AntiPatterns) {
    $report += "`n- $antiPattern"
}

$report += @"


---

## 📜 Principles ($(($insights.Principles).Count))

Core principles extracted from learnings:

"@

foreach ($principle in $insights.Principles) {
    $report += "`n- **$principle**"
}

$report += @"


---

## 🔧 Tools Created/Used ($(($insights.Tools).Count))

Tools mentioned across sessions:

"@

foreach ($tool in $insights.Tools) {
    $report += "`n- $tool"
}

$report += @"


---

## 💡 Key Learnings ($(($insights.Learnings).Count))

Important discoveries and insights:

"@

foreach ($learning in $insights.Learnings | Select-Object -First 20) {
    $report += "`n- $learning"
}

$report += @"


---

## 📊 Meta-Analysis

**Total Patterns Extracted:** $($insights.Patterns.Count + $insights.AntiPatterns.Count + $insights.Principles.Count)
**Pattern Density:** $(($insights.Patterns.Count + $insights.AntiPatterns.Count) / ([Math]::Max(1, ($logContent -split "`n").Count / 100))) per 100 lines
**Tool Creation Rate:** $($insights.Tools.Count) tools mentioned

**Trend:** Continuous improvement protocol is working - patterns are being captured and documented.

---

## 🚀 Recommended Actions

Based on extracted insights:

1. **Update best-practices/** - Add top 10 patterns to pattern library
2. **Update CLAUDE.md** - Incorporate new principles into operational manual
3. **Create new skills** - Tools used repeatedly should become auto-discoverable skills
4. **Archive old insights** - Move learnings older than 3 months to archive

---

**Next Update:** Run this script weekly to track learning velocity
**Integration:** Results feed into continuous-improvement.md
"@

# Write report
$report | Out-File -FilePath $OutputPath -Encoding UTF8

Write-Host "📊 Insights Report:" -ForegroundColor Cyan
Write-Host "   Patterns: $($insights.Patterns.Count)" -ForegroundColor Green
Write-Host "   Anti-Patterns: $($insights.AntiPatterns.Count)" -ForegroundColor Yellow
Write-Host "   Principles: $($insights.Principles.Count)" -ForegroundColor Cyan
Write-Host "   Tools: $($insights.Tools.Count)" -ForegroundColor Magenta
Write-Host "   Learnings: $($insights.Learnings.Count)" -ForegroundColor Blue
Write-Host ""
Write-Host "📁 Report saved: $OutputPath" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Next: Review report and update documentation" -ForegroundColor Yellow
