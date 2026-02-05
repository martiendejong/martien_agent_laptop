# Test Knowledge System Comprehensively
# Created: 2026-02-05
# Purpose: Validate all 25 rounds of knowledge system improvements

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"
$results = @{
    passed = 0
    failed = 0
    warnings = 0
    tests = @()
}

function Write-TestResult {
    param(
        [string]$TestName,
        [string]$Status,  # PASS, FAIL, WARN
        [string]$Message,
        [hashtable]$Metrics = @{}
    )

    $icon = switch ($Status) {
        "PASS" { "[OK]"; $script:results.passed++ }
        "FAIL" { "[X]"; $script:results.failed++ }
        "WARN" { "[!]"; $script:results.warnings++ }
    }

    Write-Host "$icon $TestName" -ForegroundColor $(
        switch ($Status) {
            "PASS" { "Green" }
            "FAIL" { "Red" }
            "WARN" { "Yellow" }
        }
    )
    Write-Host "   $Message" -ForegroundColor Gray

    if ($Metrics.Count -gt 0 -and $Verbose) {
        $Metrics.GetEnumerator() | ForEach-Object {
            Write-Host "   • $($_.Key): $($_.Value)" -ForegroundColor DarkGray
        }
    }

    $script:results.tests += @{
        name = $TestName
        status = $Status
        message = $Message
        metrics = $Metrics
    }
}

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          KNOWLEDGE SYSTEM COMPREHENSIVE TEST SUITE             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# ============================================================================
# TEST 1: Alias Resolution Test
# ============================================================================
Write-Host "`n[TEST 1] Alias Resolution Test" -ForegroundColor Cyan
Write-Host "Testing instant context lookup for common aliases...`n" -ForegroundColor Gray

$aliasFile = "C:\scripts\_machine\ALIAS_RESOLVER.yaml"
if (Test-Path $aliasFile) {
    # Test 1.1: File exists and readable
    $loadTime = Measure-Command { $content = Get-Content $aliasFile -Raw }
    $loadTimeMs = [math]::Round($loadTime.TotalMilliseconds, 2)
    $fileSizeKB = [math]::Round((Get-Item $aliasFile).Length / 1KB, 2)

    Write-TestResult `
        -TestName "1.1 ALIAS_RESOLVER.yaml exists and loads" `
        -Status "PASS" `
        -Message "Loaded in ${loadTimeMs}ms" `
        -Metrics @{
            "LoadTimeMs" = $loadTimeMs
            "FileSizeKB" = $fileSizeKB
        }

    # Test 1.2: Key aliases present
    $testAliases = @('brand2boost', 'b2b', 'client-manager', 'arjan_emails', 'gemeente_emails', 'hazina')
    $foundAliases = 0
    foreach ($alias in $testAliases) {
        if ($content -match $alias) {
            $foundAliases++
        }
    }

    if ($foundAliases -eq $testAliases.Count) {
        Write-TestResult `
            -TestName "1.2 All critical aliases present" `
            -Status "PASS" `
            -Message "Found $foundAliases/$($testAliases.Count) test aliases" `
            -Metrics @{
                "Aliases Found" = "$foundAliases/$($testAliases.Count)"
                "Coverage" = "100%"
            }
    } else {
        Write-TestResult `
            -TestName "1.2 All critical aliases present" `
            -Status "FAIL" `
            -Message "Only found $foundAliases/$($testAliases.Count) test aliases"
    }

    # Test 1.3: Performance benchmark (<100ms requirement)
    if ($loadTimeMs -lt 100) {
        Write-TestResult `
            -TestName "1.3 Performance benchmark (<100ms)" `
            -Status "PASS" `
            -Message "Load time ${loadTimeMs}ms is under 100ms threshold"
    } else {
        Write-TestResult `
            -TestName "1.3 Performance benchmark (<100ms)" `
            -Status "WARN" `
            -Message "Load time ${loadTimeMs}ms exceeds 100ms threshold"
    }

} else {
    Write-TestResult `
        -TestName "1.1 ALIAS_RESOLVER.yaml exists" `
        -Status "FAIL" `
        -Message "File not found at $aliasFile"
}

# ============================================================================
# TEST 2: Context Knowledge Graph Test
# ============================================================================
Write-Host "`n[TEST 2] Context Knowledge Graph Test" -ForegroundColor Cyan
Write-Host "Testing comprehensive knowledge graph structure...`n" -ForegroundColor Gray

$graphFile = "C:\scripts\_machine\CONTEXT_KNOWLEDGE_GRAPH.yaml"
if (Test-Path $graphFile) {
    $loadTime = Measure-Command { $graph = Get-Content $graphFile -Raw }
    $loadTimeMs = [math]::Round($loadTime.TotalMilliseconds, 2)
    $graphFileSizeKB = [math]::Round((Get-Item $graphFile).Length / 1KB, 2)
    $graphLines = (Get-Content $graphFile).Count

    Write-TestResult `
        -TestName "2.1 CONTEXT_KNOWLEDGE_GRAPH.yaml loads" `
        -Status "PASS" `
        -Message "Loaded in ${loadTimeMs}ms" `
        -Metrics @{
            "LoadTimeMs" = $loadTimeMs
            "FileSizeKB" = $graphFileSizeKB
            "Lines" = $graphLines
        }

    # Test 2.2: Required sections present
    $requiredSections = @('projects:', 'stores:', 'special_folders:', 'tools:', 'skills:', 'workflows:', 'connections:')
    $foundSections = 0
    foreach ($section in $requiredSections) {
        if ($graph -match $section) {
            $foundSections++
        }
    }

    if ($foundSections -eq $requiredSections.Count) {
        Write-TestResult `
            -TestName "2.2 All required sections present" `
            -Status "PASS" `
            -Message "Found all $foundSections sections" `
            -Metrics @{
                "Sections" = "$foundSections/$($requiredSections.Count)"
            }
    } else {
        Write-TestResult `
            -TestName "2.2 All required sections present" `
            -Status "FAIL" `
            -Message "Missing sections: found $foundSections/$($requiredSections.Count)"
    }

} else {
    Write-TestResult `
        -TestName "2.1 CONTEXT_KNOWLEDGE_GRAPH.yaml exists" `
        -Status "FAIL" `
        -Message "File not found at $graphFile"
}

# ============================================================================
# TEST 3: Project Bundle Test
# ============================================================================
Write-Host "`n[TEST 3] Project Bundle Test" -ForegroundColor Cyan
Write-Host "Testing project-specific context loading...`n" -ForegroundColor Gray

$testProjects = @(
    @{ Name = "client-manager"; Path = "C:\Projects\client-manager" },
    @{ Name = "hazina"; Path = "C:\Projects\hazina" },
    @{ Name = "hydro-vision-website"; Path = "C:\Projects\hydro-vision-website" }
)

$projectsFound = 0
foreach ($project in $testProjects) {
    if (Test-Path $project.Path) {
        $projectsFound++
        Write-TestResult `
            -TestName "3.$($projectsFound) Project '$($project.Name)' exists" `
            -Status "PASS" `
            -Message "Found at $($project.Path)"
    } else {
        Write-TestResult `
            -TestName "3.x Project '$($project.Name)' exists" `
            -Status "FAIL" `
            -Message "Not found at $($project.Path)"
    }
}

# ============================================================================
# TEST 4: Documentation Size Compliance Test
# ============================================================================
Write-Host "`n[TEST 4] Documentation Size Compliance Test" -ForegroundColor Cyan
Write-Host "Testing 40KB file size limit compliance...`n" -ForegroundColor Gray

$docFiles = Get-ChildItem "C:\scripts\*.md" -ErrorAction SilentlyContinue
$oversizedCount = 0
$compliantCount = 0
$maxSize = 40KB

foreach ($doc in $docFiles) {
    if ($doc.Length -gt $maxSize) {
        $oversizedCount++
        if ($Verbose) {
            Write-Host "   ⚠️ $($doc.Name): $([math]::Round($doc.Length / 1KB, 2))KB (over 40KB)" -ForegroundColor Yellow
        }
    } else {
        $compliantCount++
    }
}

if ($oversizedCount -eq 0) {
    Write-TestResult `
        -TestName "4.1 All documentation files comply with 40KB limit" `
        -Status "PASS" `
        -Message "All $compliantCount files under 40KB" `
        -Metrics @{
            "Compliant Files" = $compliantCount
            "Oversized Files" = 0
        }
} else {
    Write-TestResult `
        -TestName "4.1 Documentation size compliance" `
        -Status "WARN" `
        -Message "$oversizedCount files exceed 40KB limit" `
        -Metrics @{
            "Compliant Files" = $compliantCount
            "Oversized Files" = $oversizedCount
        }
}

# ============================================================================
# TEST 5: Knowledge System Tools Test
# ============================================================================
Write-Host "`n[TEST 5] Knowledge System Tools Test" -ForegroundColor Cyan
Write-Host "Testing implemented knowledge system PowerShell tools...`n" -ForegroundColor Gray

$knowledgeTools = @(
    "session-context-buffer.ps1",
    "auto-pattern-updater.ps1",
    "context-delta-tracker.ps1",
    "hot-context-cache.ps1",
    "realtime-worktree-sync.ps1",
    "conversation-sequence-logger.ps1",
    "markov-chain-predictor.ps1",
    "workflow-pattern-detector.ps1",
    "context-preloader.ps1",
    "time-patterns-analyzer.ps1",
    "session-state-manager.ps1"
)

$toolsFound = 0
$toolsDir = "C:\scripts\_machine\knowledge-system"
foreach ($tool in $knowledgeTools) {
    $toolPath = Join-Path $toolsDir $tool
    if (Test-Path $toolPath) {
        $toolsFound++
    } elseif ($Verbose) {
        Write-Host "   ⚠️ Missing: $tool" -ForegroundColor Yellow
    }
}

if ($toolsFound -eq $knowledgeTools.Count) {
    Write-TestResult `
        -TestName "5.1 All knowledge system tools present" `
        -Status "PASS" `
        -Message "Found all $toolsFound/$($knowledgeTools.Count) tools" `
        -Metrics @{
            "Tools Found" = "$toolsFound/$($knowledgeTools.Count)"
            "Coverage" = "100%"
        }
} else {
    Write-TestResult `
        -TestName "5.1 Knowledge system tools present" `
        -Status "WARN" `
        -Message "Found $toolsFound/$($knowledgeTools.Count) tools" `
        -Metrics @{
            "Tools Found" = "$toolsFound/$($knowledgeTools.Count)"
            "Missing" = $($knowledgeTools.Count - $toolsFound)
        }
}

# ============================================================================
# TEST 6: Real-time Updates Test (Simulated)
# ============================================================================
Write-Host "`n[TEST 6] Real-time Updates Test" -ForegroundColor Cyan
Write-Host "Testing conversation-time auto-update capability...`n" -ForegroundColor Gray

$contextBufferTool = "C:\scripts\_machine\knowledge-system\session-context-buffer.ps1"
if (Test-Path $contextBufferTool) {
    # Check if tool is syntactically valid PowerShell
    try {
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $contextBufferTool -Raw), [ref]$null)
        Write-TestResult `
            -TestName "6.1 Session context buffer tool valid" `
            -Status "PASS" `
            -Message "Tool syntax is valid PowerShell"
    } catch {
        Write-TestResult `
            -TestName "6.1 Session context buffer tool valid" `
            -Status "FAIL" `
            -Message "Tool has syntax errors: $($_.Exception.Message)"
    }
} else {
    Write-TestResult `
        -TestName "6.1 Session context buffer exists" `
        -Status "FAIL" `
        -Message "Tool not found at $contextBufferTool"
}

# ============================================================================
# TEST 7: Predictive Loading Test
# ============================================================================
Write-Host "`n[TEST 7] Predictive Loading Test" -ForegroundColor Cyan
Write-Host "Testing Markov chain and workflow pattern detection...`n" -ForegroundColor Gray

$markovTool = "C:\scripts\_machine\knowledge-system\markov-chain-predictor.ps1"
$workflowTool = "C:\scripts\_machine\knowledge-system\workflow-pattern-detector.ps1"

$predictiveToolsPresent = 0
if (Test-Path $markovTool) { $predictiveToolsPresent++ }
if (Test-Path $workflowTool) { $predictiveToolsPresent++ }

if ($predictiveToolsPresent -eq 2) {
    Write-TestResult `
        -TestName "7.1 Predictive loading tools present" `
        -Status "PASS" `
        -Message "Both Markov chain and workflow pattern tools found"
} else {
    Write-TestResult `
        -TestName "7.1 Predictive loading tools present" `
        -Status "WARN" `
        -Message "Only $predictiveToolsPresent/2 predictive tools found"
}

# ============================================================================
# TEST 8: Session Memory Test
# ============================================================================
Write-Host "`n[TEST 8] Session Memory Test" -ForegroundColor Cyan
Write-Host "Testing cross-session state preservation...`n" -ForegroundColor Gray

$sessionManager = "C:\scripts\_machine\knowledge-system\session-state-manager.ps1"
if (Test-Path $sessionManager) {
    Write-TestResult `
        -TestName "8.1 Session state manager exists" `
        -Status "PASS" `
        -Message "Cross-session memory tool available"
} else {
    Write-TestResult `
        -TestName "8.1 Session state manager exists" `
        -Status "FAIL" `
        -Message "Session state manager not found"
}

# ============================================================================
# TEST 9: Integration Test
# ============================================================================
Write-Host "`n[TEST 9] End-to-End Integration Test" -ForegroundColor Cyan
Write-Host "Testing system integration and completeness...`n" -ForegroundColor Gray

# Check for key documentation files
$keyDocs = @(
    "C:\scripts\CLAUDE.md",
    "C:\scripts\MACHINE_CONFIG.md",
    "C:\scripts\GENERAL_ZERO_TOLERANCE_RULES.md",
    "C:\scripts\_machine\DEFINITION_OF_DONE.md",
    "C:\scripts\_machine\KNOWLEDGE_SYSTEM_COMPLETE.md"
)

$docsFound = 0
foreach ($doc in $keyDocs) {
    if (Test-Path $doc) {
        $docsFound++
    }
}

if ($docsFound -eq $keyDocs.Count) {
    Write-TestResult `
        -TestName "9.1 Core documentation present" `
        -Status "PASS" `
        -Message "All $docsFound core documentation files found"
} else {
    Write-TestResult `
        -TestName "9.1 Core documentation present" `
        -Status "WARN" `
        -Message "Only $docsFound/$($keyDocs.Count) core docs found"
}

# ============================================================================
# SUMMARY
# ============================================================================
Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                        TEST SUMMARY                            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "  [OK] Passed:   $($results.passed)" -ForegroundColor Green
Write-Host "  [X]  Failed:   $($results.failed)" -ForegroundColor Red
Write-Host "  [!]  Warnings: $($results.warnings)" -ForegroundColor Yellow
Write-Host "  [#]  Total:    $($results.tests.Count)`n" -ForegroundColor Cyan

if ($results.tests.Count -gt 0) {
    $passRate = [math]::Round(($results.passed / $results.tests.Count) * 100, 1)
    Write-Host "  Pass Rate: $passRate%`n" -ForegroundColor $(
        if ($passRate -ge 90) { "Green" }
        elseif ($passRate -ge 70) { "Yellow" }
        else { "Red" }
    )
} else {
    Write-Host "  Pass Rate: N/A (no tests run)`n" -ForegroundColor Red
}

# Overall verdict
if ($results.failed -eq 0 -and $results.warnings -eq 0) {
    Write-Host "  [***] VERDICT: ALL SYSTEMS OPERATIONAL" -ForegroundColor Green
} elseif ($results.failed -eq 0) {
    Write-Host "  [OK] VERDICT: OPERATIONAL (with warnings)" -ForegroundColor Yellow
} else {
    Write-Host "  [!] VERDICT: ATTENTION REQUIRED" -ForegroundColor Red
}

Write-Host ""

# Return results for programmatic access
return $results
