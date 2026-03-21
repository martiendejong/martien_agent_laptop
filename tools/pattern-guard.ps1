# Pattern Guard - Pre-Execution Pattern Enforcement
# Purpose: Trigger critical patterns BEFORE execution (prevent violations, not fix after)
# Usage: Call before high-risk operations (merge, commit, PR, deploy)

param(
    [Parameter(Mandatory)]
    [ValidateSet('PreMerge', 'PreCommit', 'PrePR', 'PreDeploy', 'PreEdit', 'PreBrowserTest', 'PreImplementation')]
    [string]$Checkpoint,

    [hashtable]$Context = @{},

    [switch]$Interactive,
    [switch]$Silent
)

$ErrorActionPreference = 'Stop'

# Pattern definitions with triggers
$Patterns = @{
    PreMerge = @(
        @{
            Pattern = "Never merge without permission"
            Question = "Heeft user EXPLICIET gevraagd om te mergen?"
            Evidence = @("User zei 'merge'", "User zei 'push naar main'", "PR approved door user")
            Violation = "User zei 'ga reviewen' (NOT merge!)"
            Severity = "CRITICAL"
            BlockOnNo = $true
        }
        @{
            Pattern = "Feature-exists check"
            Question = "Heb je gecheckt of deze feature al bestaat in develop?"
            Evidence = @("git log --grep gevonden", "Grep voor feature naam", "Existing files checked")
            Violation = "Duplicate PR created"
            Severity = "HIGH"
            BlockOnNo = $false
        }
    )

    PreCommit = @(
        @{
            Pattern = "Git init protocol"
            Question = "Heb je gezocht naar bestaande repo VOOR git init?"
            Evidence = @("Searched C:\Projects", "Searched E:", "Checked reflection.log.md")
            Violation = "Duplicate repo created"
            Severity = "CRITICAL"
            BlockOnNo = $true
        }
    )

    PrePR = @(
        @{
            Pattern = "Browser testing"
            Question = "Heb je de feature getest in browser (niet alleen build)?"
            Evidence = @("Browser MCP screenshot", "Playwright test run", "Manual browser test")
            Violation = "Claimed done without browser verification"
            Severity = "HIGH"
            BlockOnNo = $true
        }
        @{
            Pattern = "ClickUp task update"
            Question = "Heb je ClickUp task status bijgewerkt (review/complete)?"
            Evidence = @("clickup-sync.ps1 executed", "Task comment added with PR link")
            Violation = "PR without ClickUp sync"
            Severity = "MEDIUM"
            BlockOnNo = $false
        }
    )

    PreEdit = @(
        @{
            Pattern = "Read before Edit"
            Question = "Heb je het bestand gelezen met Read tool VOOR Edit?"
            Evidence = @("Read tool called", "File content verified")
            Violation = "Edit without Read → cascade failures"
            Severity = "CRITICAL"
            BlockOnNo = $true
        }
    )

    PreBrowserTest = @(
        @{
            Pattern = "Backend running check"
            Question = "Heb je geverifieerd dat backend nog steeds draait (niet alleen started)?"
            Evidence = @("Backend health check", "API endpoint test", "Recent log activity")
            Violation = "Backend crashed after initial test"
            Severity = "HIGH"
            BlockOnNo = $true
        }
    )

    PreImplementation = @(
        @{
            Pattern = "Read implementation first (for tests)"
            Question = "Heb je de daadwerkelijke API/implementatie gelezen VOOR tests schrijven?"
            Evidence = @("Interface file read", "Model classes read", "Implementation methods checked")
            Violation = "43 compilation errors from wrong assumptions"
            Severity = "HIGH"
            BlockOnNo = $false
        }
        @{
            Pattern = "MoSCoW analysis"
            Question = "Heb je MUST/SHOULD/COULD/WON'T gedefinieerd voor deze feature?"
            Evidence = @("MoSCoW comment on ClickUp", "Requirements prioritized")
            Violation = "Unclear scope → wasted work"
            Severity = "MEDIUM"
            BlockOnNo = $false
        }
    )
}

function Write-PatternLog {
    param($Message, $Level = 'INFO')

    if (-not $Silent) {
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $color = switch ($Level) {
            'ERROR' { 'Red' }
            'WARN' { 'Yellow' }
            'SUCCESS' { 'Green' }
            default { 'White' }
        }
        Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
    }
}

function Test-Pattern {
    param($Pattern, $Context)

    Write-PatternLog "Checking: $($Pattern.Pattern)" -Level 'INFO'
    Write-PatternLog "Question: $($Pattern.Question)" -Level 'INFO'

    if ($Interactive) {
        Write-Host "`nEvidence verwacht:" -ForegroundColor Cyan
        foreach ($ev in $Pattern.Evidence) {
            Write-Host "  - $ev" -ForegroundColor Gray
        }

        $response = Read-Host "`nVoldaan? (y/n)"
        $passed = $response -eq 'y'
    }
    else {
        # Auto-check based on context
        $passed = $false

        # Check if evidence exists in context
        foreach ($evidence in $Pattern.Evidence) {
            if ($Context.ContainsKey('Evidence') -and $Context.Evidence -contains $evidence) {
                $passed = $true
                break
            }
        }
    }

    return @{
        Pattern = $Pattern.Pattern
        Passed = $passed
        Severity = $Pattern.Severity
        BlockOnNo = $Pattern.BlockOnNo
        Violation = $Pattern.Violation
    }
}

# Main execution
Write-PatternLog "Pattern Guard - Checkpoint: $Checkpoint" -Level 'INFO'

$checkPatterns = $Patterns[$Checkpoint]
if (-not $checkPatterns) {
    Write-PatternLog "No patterns defined for checkpoint: $Checkpoint" -Level 'WARN'
    exit 0
}

$results = @()
$blocked = $false

foreach ($pattern in $checkPatterns) {
    $result = Test-Pattern -Pattern $pattern -Context $Context
    $results += $result

    if (-not $result.Passed) {
        $level = if ($result.Severity -eq 'CRITICAL') { 'ERROR' } else { 'WARN' }
        Write-PatternLog "FAILED: $($result.Pattern)" -Level $level
        Write-PatternLog "Potential violation: $($result.Violation)" -Level $level

        if ($result.BlockOnNo) {
            $blocked = $true
        }
    }
    else {
        Write-PatternLog "PASSED: $($result.Pattern)" -Level 'SUCCESS'
    }
}

# Summary
Write-Host "`n=== PATTERN GUARD SUMMARY ===" -ForegroundColor Cyan
$passed = ($results | Where-Object { $_.Passed }).Count
$failed = ($results | Where-Object { -not $_.Passed }).Count
$critical = ($results | Where-Object { -not $_.Passed -and $_.Severity -eq 'CRITICAL' }).Count

Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor Yellow
Write-Host "Critical failures: $critical" -ForegroundColor Red

if ($blocked) {
    Write-Host "`n[BLOCKED] Operation cannot proceed - critical pattern violations" -ForegroundColor Red
    exit 1
}
elseif ($failed -gt 0) {
    Write-Host "`n[WARNING] Proceed with caution - pattern violations detected" -ForegroundColor Yellow
    exit 0
}
else {
    Write-Host "`n[SAFE] All patterns satisfied - proceed" -ForegroundColor Green
    exit 0
}
