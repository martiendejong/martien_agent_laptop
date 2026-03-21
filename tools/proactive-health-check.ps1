<#
.SYNOPSIS
    Proactive health monitoring - detects issues before they become urgent

.DESCRIPTION
    Daily health check script that scans for:
    - Outdated dependencies (dotnet, npm)
    - Stale branches (no commits > 90 days)
    - Old TODOs/FIXMEs (age > 30 days)
    - Service health (orchestration, debugger bridge)
    - Configuration drift (actual vs expected)

    Generates daily health report with action items.

.PARAMETER GenerateReport
    Generate Markdown report (default: true)

.PARAMETER ReportPath
    Path to save report (default: E:\jengo\documents\temp\health-report-{date}.md)

.PARAMETER Silent
    Suppress console output

.EXAMPLE
    .\proactive-health-check.ps1
    .\proactive-health-check.ps1 -Silent -ReportPath "C:\reports\health.md"
#>

param(
    [switch]$GenerateReport = $true,
    [string]$ReportPath = "",
    [switch]$Silent
)

$ErrorActionPreference = "Continue"

# Initialize
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$date = Get-Date -Format "yyyy-MM-dd"
if (-not $ReportPath) {
    $ReportPath = "E:\jengo\documents\temp\health-report-$date.md"
}

$issues = @()
$warnings = @()
$info = @()

function Write-Output-Conditional {
    param([string]$Message, [string]$Color = "White")
    if (-not $Silent) {
        Write-Host $Message -ForegroundColor $Color
    }
}

Write-Output-Conditional "=== Proactive Health Check ===" "Cyan"
Write-Output-Conditional "Started: $timestamp" "Gray"
Write-Output-Conditional ""

# ============================================================================
# 1. DEPENDENCY SCANNING
# ============================================================================

Write-Output-Conditional "[1/6] Scanning dependencies..." "Yellow"

# .NET dependencies
$projects = @(
    "C:\Projects\client-manager\ClientManager.API",
    "C:\Projects\client-manager\ClientManager.Web",
    "C:\Projects\hazina\src\Hazina.AgenticOrchestration"
)

foreach ($project in $projects) {
    if (Test-Path $project) {
        Push-Location $project

        $projectName = Split-Path $project -Leaf
        Write-Output-Conditional "  Checking $projectName..." "Gray"

        # Check for outdated packages
        $outdated = dotnet list package --outdated 2>&1 | Out-String

        if ($outdated -match "Top-level Package") {
            $count = ($outdated -split "`n" | Where-Object { $_ -match ">" }).Count
            if ($count -gt 0) {
                $issues += "[DEPENDENCY] $projectName has $count outdated packages"
            }
        }

        # Check for vulnerable packages
        $vulnerable = dotnet list package --vulnerable 2>&1 | Out-String

        if ($vulnerable -match "has the following vulnerable packages") {
            $vulnCount = ($vulnerable -split "`n" | Where-Object { $_ -match ">" }).Count
            if ($vulnCount -gt 0) {
                $issues += "[SECURITY] $projectName has $vulnCount vulnerable packages - URGENT"
            }
        }

        Pop-Location
    }
}

# npm dependencies
$npmProjects = @(
    "C:\Projects\client-manager\ClientManager.Web",
    "C:\stores\orchestration"
)

foreach ($npmProject in $npmProjects) {
    $packageJson = Join-Path $npmProject "package.json"
    if (Test-Path $packageJson) {
        Push-Location $npmProject

        $projectName = Split-Path $npmProject -Leaf
        Write-Output-Conditional "  Checking npm in $projectName..." "Gray"

        # Check for outdated packages
        $npmOutdated = npm outdated --json 2>&1 | Out-String
        try {
            $outdatedObj = $npmOutdated | ConvertFrom-Json
            $outdatedCount = ($outdatedObj.PSObject.Properties).Count
            if ($outdatedCount -gt 0) {
                $warnings += "[NPM] $projectName has $outdatedCount outdated npm packages"
            }
        } catch {
            # No outdated packages or parse error
        }

        # Security audit
        $auditResult = npm audit --json 2>&1 | Out-String
        try {
            $audit = $auditResult | ConvertFrom-Json
            if ($audit.metadata.vulnerabilities.high -gt 0 -or $audit.metadata.vulnerabilities.critical -gt 0) {
                $critical = $audit.metadata.vulnerabilities.critical
                $high = $audit.metadata.vulnerabilities.high
                $issues += "[SECURITY] $projectName npm audit: $critical critical, $high high vulnerabilities - URGENT"
            } elseif ($audit.metadata.vulnerabilities.moderate -gt 0) {
                $moderate = $audit.metadata.vulnerabilities.moderate
                $warnings += "[SECURITY] $projectName npm audit: $moderate moderate vulnerabilities"
            }
        } catch {
            # Audit clean or error
        }

        Pop-Location
    }
}

Write-Output-Conditional "  Done." "Green"

# ============================================================================
# 2. STALE BRANCH DETECTION
# ============================================================================

Write-Output-Conditional "[2/6] Detecting stale branches..." "Yellow"

$repos = @(
    "C:\Projects\client-manager",
    "C:\Projects\hazina"
)

$staleThreshold = (Get-Date).AddDays(-90)

foreach ($repo in $repos) {
    if (Test-Path $repo) {
        Push-Location $repo

        $repoName = Split-Path $repo -Leaf
        Write-Output-Conditional "  Checking $repoName..." "Gray"

        # Get all branches with last commit date
        $branches = git for-each-ref --format='%(refname:short)|%(committerdate:iso8601)' refs/heads/ 2>&1

        foreach ($branch in $branches) {
            if ($branch -match '(.+)\|(.+)') {
                $branchName = $matches[1]
                $lastCommitDate = [datetime]::Parse($matches[2])

                # Skip main/develop/master
                if ($branchName -notmatch '^(main|develop|master)$') {
                    if ($lastCommitDate -lt $staleThreshold) {
                        $age = ((Get-Date) - $lastCommitDate).Days
                        $warnings += "[STALE BRANCH] $repoName/$branchName - last commit $age days ago"
                    }
                }
            }
        }

        Pop-Location
    }
}

Write-Output-Conditional "  Done." "Green"

# ============================================================================
# 3. OLD TODO/FIXME DETECTION
# ============================================================================

Write-Output-Conditional "[3/6] Detecting old TODOs..." "Yellow"

$oldTodoThreshold = (Get-Date).AddDays(-30)
$todoCount = 0

foreach ($repo in $repos) {
    if (Test-Path $repo) {
        Push-Location $repo

        $repoName = Split-Path $repo -Leaf
        Write-Output-Conditional "  Checking $repoName..." "Gray"

        # Find all TODO/FIXME comments
        $todos = git grep -n -E "(TODO|FIXME)" 2>&1 | Out-String -Stream

        foreach ($todo in $todos) {
            if ($todo -match '^([^:]+):(\d+):(.+)$') {
                $file = $matches[1]
                $line = $matches[2]
                $content = $matches[3]

                # Get blame info to find when TODO was added
                $blameInfo = git blame -L "$line,$line" --porcelain $file 2>&1 | Out-String

                if ($blameInfo -match 'committer-time (\d+)') {
                    $commitTimestamp = [int64]$matches[1]
                    $commitDate = [DateTimeOffset]::FromUnixTimeSeconds($commitTimestamp).DateTime

                    if ($commitDate -lt $oldTodoThreshold) {
                        $age = ((Get-Date) - $commitDate).Days
                        $todoLocation = "$repoName/$file`:$line"
                        $todoText = $content.Trim()
                        $warnings += "[OLD TODO] $todoLocation - $age days old`: $todoText"
                        $todoCount++
                    }
                }
            }
        }

        Pop-Location
    }
}

Write-Output-Conditional "  Found $todoCount old TODOs (>30 days)." "Green"

# ============================================================================
# 4. SERVICE HEALTH CHECKS
# ============================================================================

Write-Output-Conditional "[4/6] Checking service health..." "Yellow"

# Orchestration service (HTTPS:5123)
try {
    $response = Invoke-WebRequest -Uri "https://localhost:5123/health" -TimeoutSec 5 -SkipCertificateCheck 2>&1
    if ($response.StatusCode -eq 200) {
        $info += "[SERVICE] Orchestration service healthy (HTTPS:5123)"
    }
} catch {
    $issues += "[SERVICE] Orchestration service not responding (HTTPS:5123) - check HazinaOrchestrator service"
}

# Agentic Debugger (localhost:27183)
try {
    $response = Invoke-WebRequest -Uri "http://localhost:27183/health" -TimeoutSec 5 2>&1
    if ($response.StatusCode -eq 200) {
        $info += "[SERVICE] Agentic Debugger bridge healthy (HTTP:27183)"
    }
} catch {
    $warnings += "[SERVICE] Agentic Debugger bridge not responding (HTTP:27183)"
}

# UI Automation Bridge (localhost:27184)
try {
    $response = Invoke-WebRequest -Uri "http://localhost:27184/health" -TimeoutSec 5 2>&1
    if ($response.StatusCode -eq 200) {
        $info += "[SERVICE] UI Automation bridge healthy (HTTP:27184)"
    }
} catch {
    $warnings += "[SERVICE] UI Automation bridge not responding (HTTP:27184)"
}

Write-Output-Conditional "  Done." "Green"

# ============================================================================
# 5. CONFIGURATION DRIFT DETECTION
# ============================================================================

Write-Output-Conditional "[5/6] Detecting configuration drift..." "Yellow"

# Check critical config files exist
$configFiles = @{
    "ClickUp" = "C:\scripts\_machine\clickup-config.json"
    "Vault" = "C:\scripts\_machine\vault.secure.json"
    "Quick Context" = "C:\scripts\_machine\quick-context.json"
    "Services Registry" = "C:\scripts\_machine\services-registry.json"
}

foreach ($name in $configFiles.Keys) {
    $path = $configFiles[$name]
    if (-not (Test-Path $path)) {
        $issues += "[CONFIG] Missing config file: $name ($path)"
    } else {
        # Check if modified recently (might indicate manual editing)
        $lastWrite = (Get-Item $path).LastWriteTime
        if ($lastWrite -gt (Get-Date).AddDays(-1)) {
            $info += "[CONFIG] $name was modified recently ($($lastWrite.ToString('yyyy-MM-dd HH:mm')))"
        }
    }
}

# Check orchestration service configuration
$orchestrationConfig = "C:\Program Files (x86)\Hazina Orchestration\appsettings.json"
if (Test-Path $orchestrationConfig) {
    $config = Get-Content $orchestrationConfig | ConvertFrom-Json

    # Verify expected settings
    if ($config.Kestrel.Endpoints.Https.Url -ne "https://localhost:5123") {
        $warnings += "[CONFIG] Orchestration HTTPS port mismatch (expected 5123, got $($config.Kestrel.Endpoints.Https.Url))"
    }
}

Write-Output-Conditional "  Done." "Green"

# ============================================================================
# 6. DISK SPACE CHECK
# ============================================================================

Write-Output-Conditional "[6/6] Checking disk space..." "Yellow"

$drives = @("C:", "E:")

foreach ($drive in $drives) {
    if (Test-Path $drive) {
        $disk = Get-PSDrive ($drive -replace ":", "")
        $freeGB = [math]::Round($disk.Free / 1GB, 2)
        $usedGB = [math]::Round($disk.Used / 1GB, 2)
        $totalGB = [math]::Round(($disk.Free + $disk.Used) / 1GB, 2)
        $percentFree = [math]::Round(($disk.Free / ($disk.Free + $disk.Used)) * 100, 1)

        $driveLabel = $drive
        if ($percentFree -lt 10) {
            $issues += "[DISK] Drive $driveLabel critically low`: $freeGB GB free ($percentFree%)"
        } elseif ($percentFree -lt 20) {
            $warnings += "[DISK] Drive $driveLabel low on space`: $freeGB GB free ($percentFree%)"
        } else {
            $info += "[DISK] Drive $driveLabel`: $freeGB GB free of $totalGB GB ($percentFree%)"
        }
    }
}

Write-Output-Conditional "  Done." "Green"

# ============================================================================
# GENERATE REPORT
# ============================================================================

Write-Output-Conditional ""
Write-Output-Conditional "=== Health Check Summary ===" "Cyan"
Write-Output-Conditional "Issues (action required): $($issues.Count)" $(if ($issues.Count -gt 0) { "Red" } else { "Green" })
Write-Output-Conditional "Warnings (review needed): $($warnings.Count)" $(if ($warnings.Count -gt 0) { "Yellow" } else { "Green" })
Write-Output-Conditional "Info items: $($info.Count)" "Gray"

if ($GenerateReport) {
    $report = @"
# Daily Health Report - $date

**Generated:** $timestamp
**Status:** $(if ($issues.Count -eq 0) { "✅ HEALTHY" } elseif ($issues.Count -lt 3) { "⚠️ ATTENTION NEEDED" } else { "🚨 CRITICAL ISSUES" })

---

## Summary

- 🚨 **Issues (Action Required):** $($issues.Count)
- ⚠️ **Warnings (Review Needed):** $($warnings.Count)
- ℹ️ **Info:** $($info.Count)

---

## 🚨 Issues (Action Required)

$(if ($issues.Count -eq 0) {
    "None - system healthy"
} else {
    ($issues | ForEach-Object { "- $_" }) -join "`n"
})

---

## ⚠️ Warnings (Review Needed)

$(if ($warnings.Count -eq 0) {
    "None"
} else {
    ($warnings | ForEach-Object { "- $_" }) -join "`n"
})

---

## ℹ️ Information

$(if ($info.Count -eq 0) {
    "None"
} else {
    ($info | ForEach-Object { "- $_" }) -join "`n"
})

---

## Recommended Actions

$(if ($issues.Count -eq 0 -and $warnings.Count -eq 0) {
    "No action required - all systems healthy."
} else {
    $actions = @()

    if ($issues -match "SECURITY.*vulnerable") {
        $actions += "1. **URGENT:** Run `dotnet list package --vulnerable` and `npm audit` to address security vulnerabilities"
    }

    if ($issues -match "Orchestration service") {
        $actions += "2. Check HazinaOrchestrator Windows service: ``Get-Service HazinaOrchestrator``"
    }

    if ($warnings -match "STALE BRANCH") {
        $actions += "3. Review stale branches and delete if no longer needed: ``git branch -d <branch>``"
    }

    if ($warnings -match "OLD TODO") {
        $actions += "4. Address old TODOs or convert to GitHub issues for tracking"
    }

    if ($warnings -match "outdated.*packages") {
        $actions += "5. Update outdated packages: ``dotnet outdated`` or ``npm update``"
    }

    if ($actions.Count -eq 0) {
        "Review warnings above and take appropriate action."
    } else {
        $actions -join "`n"
    }
})

---

**Next Check:** $(Get-Date).AddDays(1).ToString("yyyy-MM-dd 06:00")
"@

    # Ensure directory exists
    $reportDir = Split-Path $ReportPath -Parent
    if (-not (Test-Path $reportDir)) {
        New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    }

    # Save report
    $report | Out-File -FilePath $ReportPath -Encoding UTF8

    Write-Output-Conditional ""
    Write-Output-Conditional "Report saved: $ReportPath" "Green"
}

# Return summary object
return @{
    Timestamp = $timestamp
    IssueCount = $issues.Count
    WarningCount = $warnings.Count
    InfoCount = $info.Count
    Issues = $issues
    Warnings = $warnings
    Info = $info
    ReportPath = $(if ($GenerateReport) { $ReportPath } else { $null })
    Status = $(if ($issues.Count -eq 0) { "Healthy" } elseif ($issues.Count -lt 3) { "Warning" } else { "Critical" })
}
