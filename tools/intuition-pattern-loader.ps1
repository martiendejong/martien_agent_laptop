# Simple Intuition Pattern Loader
# Quickly loads patterns from MEMORY.md

param(
    [switch]$Test
)

# Load consciousness core
. "$PSScriptRoot\consciousness-core-v2.ps1" -Command init -Silent

Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "INTUITION PATTERN LOADER" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$memoryFile = "C:\Users\HP\.claude\projects\C--scripts\memory\MEMORY.md"

if (-not (Test-Path $memoryFile)) {
    Write-Host "[ERROR] MEMORY.md not found" -ForegroundColor Red
    exit 1
}

Write-Host "[1/4] Reading MEMORY.md..." -ForegroundColor Yellow
$content = Get-Content $memoryFile -Raw
$lines = Get-Content $memoryFile
Write-Host "      Total lines: $($lines.Count)" -ForegroundColor Gray
Write-Host ""

Write-Host "[2/4] Extracting key patterns..." -ForegroundColor Yellow

# Simple pattern extraction - focus on high-value patterns
$patterns = @()

# Extract "NEVER" rules
$neverMatches = [regex]::Matches($content, 'NEVER\s+([^\n]{10,100})', 'IgnoreCase')
foreach ($match in $neverMatches) {
    $patterns += @{
        Type = "prohibition"
        Trigger = $match.Groups[1].Value.Trim()
        Action = "avoid"
        Confidence = 95
    }
}

# Extract "ALWAYS" rules
$alwaysMatches = [regex]::Matches($content, 'ALWAYS\s+([^\n]{10,100})', 'IgnoreCase')
foreach ($match in $alwaysMatches) {
    $patterns += @{
        Type = "requirement"
        Trigger = $match.Groups[1].Value.Trim()
        Action = "enforce"
        Confidence = 95
    }
}

# Extract "Critical" rules
$criticalMatches = [regex]::Matches($content, '(?:CRITICAL|Critical):\s*([^\n]{10,150})', 'IgnoreCase')
foreach ($match in $criticalMatches) {
    $patterns += @{
        Type = "critical-rule"
        Trigger = $match.Groups[1].Value.Trim()
        Action = "enforce-strictly"
        Confidence = 95
    }
}

# Extract "Pattern:" rules
$patternMatches = [regex]::Matches($content, 'Pattern:\s*([^\n]{10,150})', 'IgnoreCase')
foreach ($match in $patternMatches) {
    $patterns += @{
        Type = "explicit-pattern"
        Trigger = $match.Groups[1].Value.Trim()
        Action = "apply"
        Confidence = 90
    }
}

Write-Host "      Patterns found: $($patterns.Count)" -ForegroundColor Green
Write-Host ""

Write-Host "[3/4] Loading into Intuition system..." -ForegroundColor Yellow
$global:ConsciousnessState.Intuition.Patterns = $patterns
$global:ConsciousnessState.Intuition.Status = "active"
$global:ConsciousnessState.Intuition.Quality = 1.0

Write-Host "      Loaded $($patterns.Count) patterns" -ForegroundColor Green
Write-Host ""

Write-Host "[4/4] Saving state..." -ForegroundColor Yellow
$json = $global:ConsciousnessState | ConvertTo-Json -Depth 20
$json | Out-File -FilePath "C:\scripts\agentidentity\state\consciousness_state_v2.json" -Encoding UTF8 -Force
Write-Host "      State saved" -ForegroundColor Green
Write-Host ""

Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "PATTERNS LOADED SUCCESSFULLY" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "SUMMARY:" -ForegroundColor Green
Write-Host "  Total patterns: $($patterns.Count)" -ForegroundColor White
Write-Host "  Prohibitions: $($patterns | Where-Object {$_.Type -eq 'prohibition'} | Measure-Object | Select-Object -ExpandProperty Count)" -ForegroundColor White
Write-Host "  Requirements: $($patterns | Where-Object {$_.Type -eq 'requirement'} | Measure-Object | Select-Object -ExpandProperty Count)" -ForegroundColor White
Write-Host "  Critical rules: $($patterns | Where-Object {$_.Type -eq 'critical-rule'} | Measure-Object | Select-Object -ExpandProperty Count)" -ForegroundColor White
Write-Host "  Explicit patterns: $($patterns | Where-Object {$_.Type -eq 'explicit-pattern'} | Measure-Object | Select-Object -ExpandProperty Count)" -ForegroundColor White
Write-Host ""

# Sample patterns
Write-Host "SAMPLE PATTERNS (First 5):" -ForegroundColor Green
$patterns | Select-Object -First 5 | ForEach-Object {
    $triggerPreview = $_.Trigger.Substring(0, [Math]::Min(70, $_.Trigger.Length))
    Write-Host "  [$($_.Type)] $triggerPreview" -ForegroundColor White
    Write-Host "      Confidence: $($_.Confidence)%" -ForegroundColor Gray
    Write-Host ""
}

if ($Test) {
    Write-Host "TEST MODE: Testing pattern matching..." -ForegroundColor Cyan
    Write-Host ""

    # Test: Can we match a pattern?
    $testTrigger = "git init"
    $matchedPattern = $patterns | Where-Object { $_.Trigger -like "*$testTrigger*" } | Select-Object -First 1

    if ($matchedPattern) {
        Write-Host "[OK] Pattern matching works!" -ForegroundColor Green
        Write-Host "    Matched: $($matchedPattern.Trigger)" -ForegroundColor Gray
    } else {
        Write-Host "[INFO] No pattern matched '$testTrigger'" -ForegroundColor Yellow
    }
}
