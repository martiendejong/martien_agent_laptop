# Documentation Drift Detector
# Part of Round 6 Improvements - Documentation Drift Detector
# Compares documentation to code and flags outdated documentation

param(
    [Parameter(Mandatory=$false)]
    [string]$DocsPath = "C:\scripts",

    [Parameter(Mandatory=$false)]
    [string]$CodePath = "C:\Projects",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\scripts\_machine\drift-report.md",

    [Parameter(Mandatory=$false)]
    [int]$DriftThresholdDays = 30
)

$ErrorActionPreference = "Stop"

Write-Host "Documentation Drift Detector - Round 6 Implementation" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# Track code references in documentation
function Get-CodeReferences {
    param([string]$FilePath)

    $content = Get-Content $FilePath -Raw
    $references = @()

    # Match file paths in markdown
    $patterns = @(
        'C:\\Projects\\[^\s\)`"]+',  # Windows paths
        '`([^`]+\.(cs|js|ts|tsx|jsx))`',  # Code files in backticks
        '\[.*?\]\(([^)]+\.(cs|js|ts|tsx|jsx))\)'  # Code files in markdown links
    )

    foreach ($pattern in $patterns) {
        $matches = [regex]::Matches($content, $pattern)
        foreach ($match in $matches) {
            $path = $match.Groups[1].Value
            if (-not $path) { $path = $match.Value }
            $references += $path.Trim()
        }
    }

    return $references | Select-Object -Unique
}

# Calculate file hash for change detection
function Get-FileHash-Simple {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        return $null
    }

    $hash = Get-FileHash -Path $FilePath -Algorithm SHA256
    return $hash.Hash
}

# Scan documentation files
Write-Host "Scanning documentation files..." -ForegroundColor Yellow
$docFiles = Get-ChildItem -Path $DocsPath -Recurse -Filter "*.md" -File

$driftIssues = @()
$stats = @{
    TotalDocs = 0
    DocsWithRefs = 0
    StaleRefs = 0
    MissingRefs = 0
    RecentChanges = 0
}

$cutoffDate = (Get-Date).AddDays(-$DriftThresholdDays)

foreach ($docFile in $docFiles) {
    $stats.TotalDocs++

    $docModified = $docFile.LastWriteTime
    $refs = Get-CodeReferences -FilePath $docFile.FullName

    if ($refs.Count -eq 0) {
        continue
    }

    $stats.DocsWithRefs++

    foreach ($ref in $refs) {
        # Normalize path
        $codePath = $ref -replace '`', ''

        if (-not (Test-Path $codePath)) {
            # File doesn't exist
            $driftIssues += @{
                DocFile = $docFile.FullName
                DocName = $docFile.Name
                CodeRef = $codePath
                Issue = "MISSING"
                Severity = "HIGH"
                DocModified = $docModified
            }
            $stats.MissingRefs++
        }
        else {
            $codeFile = Get-Item $codePath
            $codeModified = $codeFile.LastWriteTime

            # Check if code was modified after documentation
            if ($codeModified -gt $docModified) {
                $daysDrift = ($codeModified - $docModified).Days

                if ($daysDrift -gt $DriftThresholdDays) {
                    $driftIssues += @{
                        DocFile = $docFile.FullName
                        DocName = $docFile.Name
                        CodeRef = $codePath
                        Issue = "STALE"
                        Severity = if ($daysDrift -gt 90) { "HIGH" } elseif ($daysDrift -gt 60) { "MEDIUM" } else { "LOW" }
                        DocModified = $docModified
                        CodeModified = $codeModified
                        DaysDrift = $daysDrift
                    }
                    $stats.StaleRefs++
                }
            }
        }
    }
}

# Group issues by documentation file
Write-Host ""
Write-Host "Analyzing drift..." -ForegroundColor Yellow

$highSeverity = ($driftIssues | Where-Object { $_.Severity -eq "HIGH" }).Count
$mediumSeverity = ($driftIssues | Where-Object { $_.Severity -eq "MEDIUM" }).Count
$lowSeverity = ($driftIssues | Where-Object { $_.Severity -eq "LOW" }).Count

# Generate report
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$report = @"
# Documentation Drift Report
**Generated:** $timestamp
**Drift Threshold:** $DriftThresholdDays days

## Summary

- **Total Documentation Files:** $($stats.TotalDocs)
- **Files with Code References:** $($stats.DocsWithRefs)
- **Missing Code References:** $($stats.MissingRefs)
- **Stale References:** $($stats.StaleRefs)

### Severity Breakdown
- **HIGH:** $highSeverity issues
- **MEDIUM:** $mediumSeverity issues
- **LOW:** $lowSeverity issues

---

## Issues Found

"@

# Group by severity
foreach ($severity in @("HIGH", "MEDIUM", "LOW")) {
    $severityIssues = $driftIssues | Where-Object { $_.Severity -eq $severity }

    if ($severityIssues.Count -eq 0) { continue }

    $report += "`n### $severity Severity ($($severityIssues.Count) issues)`n`n"

    foreach ($issue in $severityIssues) {
        $report += "#### $($issue.DocName)`n"
        $report += "- **Doc Path:** ``$($issue.DocFile)```n"
        $report += "- **Code Reference:** ``$($issue.CodeRef)```n"
        $report += "- **Issue:** $($issue.Issue)`n"

        if ($issue.Issue -eq "STALE") {
            $report += "- **Doc Last Modified:** $($issue.DocModified.ToString('yyyy-MM-dd HH:mm'))`n"
            $report += "- **Code Last Modified:** $($issue.CodeModified.ToString('yyyy-MM-dd HH:mm'))`n"
            $report += "- **Days Drift:** $($issue.DaysDrift)`n"
        }
        elseif ($issue.Issue -eq "MISSING") {
            $report += "- **Action Required:** Remove reference or update path`n"
        }

        $report += "`n"
    }
}

# Recommendations
$report += @"

---

## Recommendations

### High Priority
"@

$highIssuesByDoc = $driftIssues | Where-Object { $_.Severity -eq "HIGH" } | Group-Object -Property DocName

foreach ($group in $highIssuesByDoc) {
    $report += "`n- **$($group.Name):** $($group.Count) issue(s) - Review and update immediately`n"
}

$report += @"

### Maintenance Strategy
1. **Set up automation:** Run this drift detector weekly via scheduled task
2. **Update frequently-changing docs:** Focus on high-traffic documentation
3. **Archive outdated docs:** Move deprecated documentation to archive folder
4. **Link validation:** Fix or remove missing code references
5. **Consider version tags:** Add "Last Verified" dates to critical documentation

### Next Steps
- Review HIGH severity issues first
- Update documentation or code references
- Re-run drift detector to verify fixes
- Consider implementing pre-commit hooks to check drift

"@

# Save report
$report | Out-File -FilePath $OutputPath -Encoding UTF8

Write-Host ""
if ($driftIssues.Count -eq 0) {
    Write-Host "No drift issues found! Documentation is up to date." -ForegroundColor Green
}
else {
    Write-Host "Drift detection complete!" -ForegroundColor Yellow
    Write-Host "  Total issues: $($driftIssues.Count)" -ForegroundColor Yellow
    Write-Host "  HIGH severity: $highSeverity" -ForegroundColor Red
    Write-Host "  MEDIUM severity: $mediumSeverity" -ForegroundColor Yellow
    Write-Host "  LOW severity: $lowSeverity" -ForegroundColor Gray
    Write-Host "  Report saved: $OutputPath" -ForegroundColor Cyan
}
Write-Host ""

return @{
    Success = $true
    TotalIssues = $driftIssues.Count
    HighSeverity = $highSeverity
    MediumSeverity = $mediumSeverity
    LowSeverity = $lowSeverity
    ReportPath = $OutputPath
}
