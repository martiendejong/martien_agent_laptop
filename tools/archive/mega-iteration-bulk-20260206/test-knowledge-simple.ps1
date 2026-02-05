# Simple Knowledge System Test
# Created: 2026-02-05
# Purpose: Quick validation of knowledge system components

$ErrorActionPreference = "Continue"
$passed = 0
$failed = 0
$warnings = 0

function Test-Result {
    param([string]$Name, [string]$Status, [string]$Message)

    $icon = switch ($Status) {
        "PASS" { "[OK]"; $script:passed++ }
        "FAIL" { "[X]"; $script:failed++ }
        "WARN" { "[!]"; $script:warnings++ }
    }

    $color = switch ($Status) {
        "PASS" { "Green" }
        "FAIL" { "Red" }
        "WARN" { "Yellow" }
    }

    Write-Host "$icon $Name" -ForegroundColor $color
    Write-Host "   $Message" -ForegroundColor Gray
}

Write-Host "`n=== KNOWLEDGE SYSTEM TEST SUITE ===`n" -ForegroundColor Cyan

# Test 1: Alias Resolver
Write-Host "[TEST 1] Alias Resolution" -ForegroundColor Cyan
$aliasFile = "C:\scripts\_machine\ALIAS_RESOLVER.yaml"
if (Test-Path $aliasFile) {
    $content = Get-Content $aliasFile -Raw
    $aliases = @('brand2boost', 'b2b', 'client-manager', 'arjan_emails', 'gemeente_emails', 'hazina')
    $found = 0
    foreach ($alias in $aliases) {
        if ($content -match $alias) { $found++ }
    }
    Test-Result "Alias Resolver File" "PASS" "Found $found/$($aliases.Count) critical aliases"
} else {
    Test-Result "Alias Resolver File" "FAIL" "File not found"
}

# Test 2: Context Knowledge Graph
Write-Host "`n[TEST 2] Context Knowledge Graph" -ForegroundColor Cyan
$graphFile = "C:\scripts\_machine\CONTEXT_KNOWLEDGE_GRAPH.yaml"
if (Test-Path $graphFile) {
    $graph = Get-Content $graphFile -Raw
    $sections = @('projects:', 'stores:', 'tools:', 'skills:', 'workflows:', 'connections:')
    $found = 0
    foreach ($section in $sections) {
        if ($graph -match $section) { $found++ }
    }
    Test-Result "Knowledge Graph Structure" "PASS" "Found $found/$($sections.Count) required sections"
} else {
    Test-Result "Knowledge Graph File" "FAIL" "File not found"
}

# Test 3: Projects
Write-Host "`n[TEST 3] Project Bundles" -ForegroundColor Cyan
$projects = @(
    @{Name="client-manager"; Path="C:\Projects\client-manager"},
    @{Name="hazina"; Path="C:\Projects\hazina"},
    @{Name="hydro-vision-website"; Path="C:\Projects\hydro-vision-website"}
)
$found = 0
foreach ($proj in $projects) {
    if (Test-Path $proj.Path) { $found++ }
}
Test-Result "Project Directories" "PASS" "Found $found/$($projects.Count) projects"

# Test 4: Documentation Size
Write-Host "`n[TEST 4] Documentation Compliance" -ForegroundColor Cyan
$docs = Get-ChildItem "C:\scripts\*.md" -ErrorAction SilentlyContinue
$oversized = 0
$compliant = 0
foreach ($doc in $docs) {
    if ($doc.Length -gt 40KB) {
        $oversized++
    } else {
        $compliant++
    }
}
if ($oversized -eq 0) {
    Test-Result "File Size Compliance" "PASS" "All $compliant files under 40KB"
} else {
    Test-Result "File Size Compliance" "WARN" "$oversized files exceed 40KB limit"
}

# Test 5: Knowledge System Tools
Write-Host "`n[TEST 5] Knowledge System Tools" -ForegroundColor Cyan
$tools = @(
    "session-context-buffer.ps1",
    "auto-pattern-updater.ps1",
    "context-delta-tracker.ps1",
    "hot-context-cache.ps1",
    "markov-chain-predictor.ps1",
    "workflow-pattern-detector.ps1",
    "session-state-manager.ps1"
)
$found = 0
$toolsDir = "C:\scripts\_machine\knowledge-system"
foreach ($tool in $tools) {
    if (Test-Path (Join-Path $toolsDir $tool)) { $found++ }
}
if ($found -eq $tools.Count) {
    Test-Result "Knowledge Tools Present" "PASS" "All $found tools found"
} else {
    Test-Result "Knowledge Tools Present" "WARN" "Found $found/$($tools.Count) tools"
}

# Test 6: Core Documentation
Write-Host "`n[TEST 6] Core Documentation" -ForegroundColor Cyan
$coreDocs = @(
    "C:\scripts\CLAUDE.md",
    "C:\scripts\MACHINE_CONFIG.md",
    "C:\scripts\GENERAL_ZERO_TOLERANCE_RULES.md",
    "C:\scripts\_machine\DEFINITION_OF_DONE.md",
    "C:\scripts\_machine\KNOWLEDGE_SYSTEM_COMPLETE.md"
)
$found = 0
foreach ($doc in $coreDocs) {
    if (Test-Path $doc) { $found++ }
}
Test-Result "Core Documentation Files" "PASS" "Found $found/$($coreDocs.Count) core docs"

# Test 7: Special Folders
Write-Host "`n[TEST 7] Special Folders" -ForegroundColor Cyan
$specialFolders = @(
    "C:\arjan_emails",
    "C:\gemeente_emails",
    "C:\stores\brand2boost"
)
$found = 0
foreach ($folder in $specialFolders) {
    if (Test-Path $folder) { $found++ }
}
Test-Result "Special Folders Access" "PASS" "Found $found/$($specialFolders.Count) special folders"

# Summary
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "  Passed:   $passed" -ForegroundColor Green
Write-Host "  Failed:   $failed" -ForegroundColor Red
Write-Host "  Warnings: $warnings" -ForegroundColor Yellow
$total = $passed + $failed + $warnings
Write-Host "  Total:    $total" -ForegroundColor Cyan

if ($total -gt 0) {
    $passRate = [math]::Round(($passed / $total) * 100, 1)
    Write-Host "`n  Pass Rate: $passRate%" -ForegroundColor $(
        if ($passRate -ge 90) { "Green" } elseif ($passRate -ge 70) { "Yellow" } else { "Red" }
    )
}

if ($failed -eq 0 -and $warnings -eq 0) {
    Write-Host "`n  VERDICT: ALL SYSTEMS OPERATIONAL`n" -ForegroundColor Green
} elseif ($failed -eq 0) {
    Write-Host "`n  VERDICT: OPERATIONAL (with warnings)`n" -ForegroundColor Yellow
} else {
    Write-Host "`n  VERDICT: ATTENTION REQUIRED`n" -ForegroundColor Red
}
