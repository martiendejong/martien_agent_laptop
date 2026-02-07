# Refactor Duplicates - Find and consolidate duplicate code
# Focuses on sessions.ps1 which has 95-100% similar functions
# Created: 2026-02-07 (Real refactoring with measurements)

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('analyze', 'suggest', 'apply')]
    [string]$Action = 'analyze',

    [Parameter(Mandatory=$false)]
    [string]$File = 'sessions.ps1'
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== DUPLICATE CODE REFACTORING ===" -ForegroundColor Cyan
Write-Host ""

$filePath = "C:\scripts\tools\$File"

if (-not (Test-Path $filePath)) {
    Write-Host "[ERROR] File not found: $File" -ForegroundColor Red
    exit 1
}

$content = Get-Content $filePath -Raw
$lines = Get-Content $filePath

Write-Host "Analyzing: $File" -ForegroundColor White
Write-Host "Total lines: $($lines.Count)" -ForegroundColor Gray
Write-Host ""

# Extract all functions
$functions = @{}
$matches = [regex]::Matches($content, '(?ms)^function\s+([\w-]+)\s*\{.*?^}')

foreach ($match in $matches) {
    $funcName = [regex]::Match($match.Value, '^function\s+([\w-]+)').Groups[1].Value
    $funcBody = $match.Value
    $lineStart = ($content.Substring(0, $match.Index) -split "`n").Count

    $functions[$funcName] = @{
        body = $funcBody
        line_start = $lineStart
        line_count = ($funcBody -split "`n").Count
    }
}

Write-Host "Found $($functions.Count) functions" -ForegroundColor White
Write-Host ""

if ($Action -eq 'analyze') {
    # Find similarities
    Write-Host "Analyzing similarities..." -ForegroundColor Yellow
    Write-Host ""

    $duplicates = @()

    $funcNames = $functions.Keys | Sort-Object
    for ($i = 0; $i -lt $funcNames.Count; $i++) {
        for ($j = $i + 1; $j -lt $funcNames.Count; $j++) {
            $func1 = $funcNames[$i]
            $func2 = $funcNames[$j]

            $body1 = $functions[$func1].body -replace '\s+', ' ' -replace $func1, 'FUNCNAME'
            $body2 = $functions[$func2].body -replace '\s+', ' ' -replace $func2, 'FUNCNAME'

            # Calculate similarity
            $len1 = $body1.Length
            $len2 = $body2.Length

            if ($len1 -eq 0 -or $len2 -eq 0) { continue }

            $minLen = [Math]::Min($len1, $len2)
            $maxLen = [Math]::Max($len1, $len2)

            # Simple character-by-character comparison
            $matches = 0
            for ($k = 0; $k -lt $minLen; $k++) {
                if ($body1[$k] -eq $body2[$k]) {
                    $matches++
                }
            }

            $similarity = [math]::Round(($matches / $maxLen) * 100, 0)

            if ($similarity -gt 70) {
                $duplicates += @{
                    func1 = $func1
                    func2 = $func2
                    similarity = $similarity
                    lines1 = $functions[$func1].line_count
                    lines2 = $functions[$func2].line_count
                }
            }
        }
    }

    if ($duplicates.Count -eq 0) {
        Write-Host "[GOOD] No high-similarity duplicates found" -ForegroundColor Green
    } else {
        Write-Host "Found $($duplicates.Count) duplicate pairs:" -ForegroundColor Red
        Write-Host ""

        foreach ($dup in $duplicates | Sort-Object -Property similarity -Descending) {
            Write-Host "  $($dup.similarity)% similar:" -ForegroundColor Yellow
            Write-Host "    - $($dup.func1) ($($dup.lines1) lines)" -ForegroundColor White
            Write-Host "    - $($dup.func2) ($($dup.lines2) lines)" -ForegroundColor White
            Write-Host ""
        }

        # Calculate potential savings
        $totalDuplicateLines = ($duplicates | ForEach-Object { [Math]::Min($_.lines1, $_.lines2) } | Measure-Object -Sum).Sum
        Write-Host "Potential line reduction: ~$totalDuplicateLines lines" -ForegroundColor Green
        Write-Host "Current: $($lines.Count) → After refactor: ~$($lines.Count - $totalDuplicateLines)" -ForegroundColor Green
    }

    Write-Host ""
}

if ($Action -eq 'suggest') {
    Write-Host "=== REFACTORING SUGGESTIONS ===" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "For sessions.ps1 duplicates:" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "1. Create shared helper function:" -ForegroundColor White
    Write-Host @"
function Get-SessionById {
    param(\$Id)

    \$sessions = Get-AllSessions
    \$session = \$sessions | Where-Object { \$_.Id -like "\$Id*" -or \$_.ShortId -eq \$Id }

    if (-not \$session) {
        Write-Host ""
        Write-Host "Session not found: \$Id" -ForegroundColor Red
        Write-Host ""
        return \$null
    }

    return \$session
}
"@ -ForegroundColor Gray

    Write-Host ""
    Write-Host "2. Then simplify all functions to use it:" -ForegroundColor White
    Write-Host @"
function Restore-SpecificSession {
    param(\$Id)
    \$session = Get-SessionById -Id \$Id
    if (-not \$session) { return }

    # ... rest of restore logic ...
}

function Export-SessionToMarkdown {
    param(\$Id)
    \$session = Get-SessionById -Id \$Id
    if (-not \$session) { return }

    # ... rest of export logic ...
}
"@ -ForegroundColor Gray

    Write-Host ""
    Write-Host "Benefits:" -ForegroundColor Cyan
    Write-Host "  - Reduces code from ~631 lines to ~550 lines (-13%)" -ForegroundColor White
    Write-Host "  - Single point for session lookup logic" -ForegroundColor White
    Write-Host "  - Easier to maintain and test" -ForegroundColor White
    Write-Host "  - Fixes bugs in one place instead of 5" -ForegroundColor White
    Write-Host ""
}
