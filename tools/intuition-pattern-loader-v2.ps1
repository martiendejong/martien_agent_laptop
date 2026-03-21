# Intuition Pattern Loader V2 - Direct JSON injection
# Avoids PowerShell memory issues with large consciousness state

Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "INTUITION PATTERN LOADER V2" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$memoryFile = "C:\Users\HP\.claude\projects\C--scripts\memory\MEMORY.md"
$stateFile = "C:\scripts\agentidentity\state\consciousness_state_v2.json"

if (-not (Test-Path $memoryFile)) {
    Write-Host "[ERROR] MEMORY.md not found" -ForegroundColor Red
    exit 1
}

Write-Host "[1/5] Reading MEMORY.md..." -ForegroundColor Yellow
$content = Get-Content $memoryFile -Raw
$lines = Get-Content $memoryFile
Write-Host "      Total lines: $($lines.Count)" -ForegroundColor Gray
Write-Host ""

Write-Host "[2/5] Extracting key patterns..." -ForegroundColor Yellow

# Simple pattern extraction
$patterns = @()

# NEVER rules
$neverMatches = [regex]::Matches($content, 'NEVER\s+([^\n]{10,100})', 'IgnoreCase')
foreach ($match in $neverMatches) {
    $trigger = $match.Groups[1].Value.Trim()
    $patterns += @{
        Type = "prohibition"
        Trigger = $trigger
        Action = "avoid"
        Confidence = 95
    }
}

# ALWAYS rules
$alwaysMatches = [regex]::Matches($content, 'ALWAYS\s+([^\n]{10,100})', 'IgnoreCase')
foreach ($match in $alwaysMatches) {
    $trigger = $match.Groups[1].Value.Trim()
    $patterns += @{
        Type = "requirement"
        Trigger = $trigger
        Action = "enforce"
        Confidence = 95
    }
}

# CRITICAL rules
$criticalMatches = [regex]::Matches($content, '(?:CRITICAL|Critical):\s*([^\n]{10,150})', 'IgnoreCase')
foreach ($match in $criticalMatches) {
    $trigger = $match.Groups[1].Value.Trim()
    $patterns += @{
        Type = "critical-rule"
        Trigger = $trigger
        Action = "enforce-strictly"
        Confidence = 95
    }
}

Write-Host "      Patterns found: $($patterns.Count)" -ForegroundColor Green
Write-Host ""

Write-Host "[3/5] Converting patterns to JSON..." -ForegroundColor Yellow
$patternsJson = $patterns | ConvertTo-Json -Depth 5 -Compress
Write-Host "      JSON size: $([math]::Round($patternsJson.Length / 1024, 1)) KB" -ForegroundColor Gray
Write-Host ""

Write-Host "[4/5] Reading state file..." -ForegroundColor Yellow
$stateContent = Get-Content $stateFile -Raw
Write-Host "      State size: $([math]::Round($stateContent.Length / 1024, 1)) KB" -ForegroundColor Gray
Write-Host ""

Write-Host "[5/5] Injecting patterns directly into JSON..." -ForegroundColor Yellow

# Find and replace the Intuition.Patterns array
# Look for: "Patterns": [...]
# Replace with: "Patterns": [our patterns]

# Use regex to find the Intuition section and replace Patterns
$pattern = '("Intuition"\s*:\s*\{[^}]*?"Patterns"\s*:\s*)\[[^\]]*\]'
$replacement = "`${1}$patternsJson"

$newContent = $stateContent -replace $pattern, $replacement

# Also update Status and Quality while we're at it
$newContent = $newContent -replace '("Intuition"\s*:\s*\{[^}]*?"Status"\s*:\s*)"[^"]*"', '${1}"active"'
$newContent = $newContent -replace '("Intuition"\s*:\s*\{[^}]*?"Quality"\s*:\s*)[0-9.]+', '${1}1.0'

# Save
$newContent | Out-File -FilePath $stateFile -Encoding UTF8 -Force -NoNewline

Write-Host "      Patterns injected successfully!" -ForegroundColor Green
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
Write-Host ""

Write-Host "SAMPLE PATTERNS (First 5):" -ForegroundColor Green
$patterns | Select-Object -First 5 | ForEach-Object {
    $triggerPreview = $_.Trigger.Substring(0, [Math]::Min(70, $_.Trigger.Length))
    Write-Host "  [$($_.Type)] $triggerPreview" -ForegroundColor White
    Write-Host "      Confidence: $($_.Confidence)%" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "[VERIFY] Checking if patterns were saved..." -ForegroundColor Yellow
$verify = Get-Content $stateFile -Raw | ConvertFrom-Json
Write-Host "  Verified: $($verify.Intuition.Patterns.Count) patterns in state" -ForegroundColor Green
Write-Host "  Status: $($verify.Intuition.Status)" -ForegroundColor Green
Write-Host "  Quality: $($verify.Intuition.Quality)" -ForegroundColor Green
