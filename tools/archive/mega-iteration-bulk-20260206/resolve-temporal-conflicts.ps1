# Temporal Conflict Resolver
# Part of Round 7 Improvements - Temporal Conflict Resolver
# Flags when docs describe outdated practices with timestamp + version tracking

param(
    [Parameter(Mandatory=$false)]
    [string]$DocsPath = "C:\scripts",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\scripts\_machine\temporal-conflicts.md",

    [Parameter(Mandatory=$false)]
    [int]$StaleThresholdDays = 180,

    [Parameter(Mandatory=$false)]
    [switch]$CheckVersions = $true
)

$ErrorActionPreference = "Stop"

Write-Host "Temporal Conflict Resolver - Round 7 Implementation" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# Extract version numbers from text
function Get-VersionReferences {
    param([string]$Content)

    $versions = @()

    # Match version patterns
    $patterns = @(
        'v?(\d+\.\d+(?:\.\d+)?)',  # v1.2.3 or 1.2.3
        'Version\s+(\d+\.\d+(?:\.\d+)?)',  # Version 1.2.3
        '(?:NET|Core)\s+(\d+(?:\.\d+)?)',  # .NET 6, .NET Core 3.1
        'Node\.?js\s+v?(\d+(?:\.\d+)?)',  # Node.js 18
        'React\s+v?(\d+(?:\.\d+)?)'  # React 18
    )

    foreach ($pattern in $patterns) {
        $matches = [regex]::Matches($Content, $pattern, 'IgnoreCase')
        foreach ($match in $matches) {
            $versions += @{
                Version = $match.Groups[1].Value
                Context = $match.Value
            }
        }
    }

    return $versions
}

# Extract timestamps from documentation
function Get-DocumentTimestamps {
    param([string]$Content, [string]$FilePath)

    $timestamps = @{
        LastUpdated = $null
        CreatedDate = $null
        VersionDate = $null
        FileModified = (Get-Item $FilePath).LastWriteTime
    }

    # Match common timestamp patterns
    if ($Content -match 'Last\s+Updated?:?\s*(\d{4}-\d{2}-\d{2})') {
        $timestamps.LastUpdated = [datetime]::Parse($matches[1])
    }

    if ($Content -match 'Created?:?\s*(\d{4}-\d{2}-\d{2})') {
        $timestamps.CreatedDate = [datetime]::Parse($matches[1])
    }

    if ($Content -match 'Date:?\s*(\d{4}-\d{2}-\d{2})') {
        $timestamps.VersionDate = [datetime]::Parse($matches[1])
    }

    return $timestamps
}

# Check for outdated practice indicators
function Get-OutdatedIndicators {
    param([string]$Content)

    $indicators = @()

    $outdatedPatterns = @{
        'bower' = 'Bower is deprecated, use npm/yarn'
        'gulp' = 'Consider modern build tools like Vite or esbuild'
        'grunt' = 'Consider modern build tools like Vite or esbuild'
        'Internet Explorer' = 'IE is deprecated since 2022'
        '\.NET Framework\s+4\.[0-5]' = '.NET Framework 4.5 and below are outdated'
        'jQuery\s+1\.' = 'jQuery 1.x is very outdated'
        'Angular\.?js|Angular\s+1\.' = 'AngularJS reached end of life in 2022'
        'Python\s+2\.' = 'Python 2 reached end of life in 2020'
        'Node\.?js\s+([0-9]|1[0-3])(?:\.\d+)?' = 'Node.js versions below 14 are EOL'
    }

    foreach ($pattern in $outdatedPatterns.Keys) {
        if ($Content -match $pattern) {
            $indicators += @{
                Pattern = $pattern
                Message = $outdatedPatterns[$pattern]
                Match = $matches[0]
            }
        }
    }

    return $indicators
}

# Scan documentation
Write-Host "Scanning documentation for temporal conflicts..." -ForegroundColor Yellow
$docFiles = Get-ChildItem -Path $DocsPath -Recurse -Filter "*.md" -File

$conflicts = @()
$stats = @{
    TotalDocs = 0
    StaleDocs = 0
    OutdatedVersions = 0
    MissingTimestamps = 0
    OutdatedPractices = 0
}

$cutoffDate = (Get-Date).AddDays(-$StaleThresholdDays)

foreach ($docFile in $docFiles) {
    $stats.TotalDocs++

    $content = Get-Content $docFile.FullName -Raw
    $timestamps = Get-DocumentTimestamps -Content $content -FilePath $docFile.FullName

    # Check if document is stale
    $lastUpdate = $timestamps.LastUpdated ?? $timestamps.VersionDate ?? $timestamps.FileModified

    if ($lastUpdate -lt $cutoffDate) {
        $daysSinceUpdate = ([datetime]::Now - $lastUpdate).Days

        $conflicts += @{
            File = $docFile.FullName
            FileName = $docFile.Name
            Type = "STALE_DOCUMENT"
            Severity = if ($daysSinceUpdate -gt 365) { "HIGH" } elseif ($daysSinceUpdate -gt 270) { "MEDIUM" } else { "LOW" }
            LastUpdate = $lastUpdate
            DaysSinceUpdate = $daysSinceUpdate
            Message = "Document hasn't been updated in $daysSinceUpdate days"
        }

        $stats.StaleDocs++
    }

    # Check for missing timestamps
    if (-not $timestamps.LastUpdated -and -not $timestamps.VersionDate) {
        $conflicts += @{
            File = $docFile.FullName
            FileName = $docFile.Name
            Type = "MISSING_TIMESTAMP"
            Severity = "LOW"
            Message = "Document has no 'Last Updated' or 'Date' field"
        }

        $stats.MissingTimestamps++
    }

    # Check for outdated version references
    if ($CheckVersions) {
        $versions = Get-VersionReferences -Content $content

        if ($versions.Count -gt 0) {
            # Simple heuristic: very old version numbers in recent-ish docs
            foreach ($ver in $versions) {
                if ($ver.Version -match '^[01]\.' -and $lastUpdate -gt (Get-Date).AddYears(-2)) {
                    $conflicts += @{
                        File = $docFile.FullName
                        FileName = $docFile.Name
                        Type = "OUTDATED_VERSION"
                        Severity = "MEDIUM"
                        Version = $ver.Context
                        Message = "References potentially outdated version: $($ver.Context)"
                    }

                    $stats.OutdatedVersions++
                }
            }
        }
    }

    # Check for outdated practices
    $indicators = Get-OutdatedIndicators -Content $content

    foreach ($indicator in $indicators) {
        $conflicts += @{
            File = $docFile.FullName
            FileName = $docFile.Name
            Type = "OUTDATED_PRACTICE"
            Severity = "HIGH"
            Practice = $indicator.Match
            Message = $indicator.Message
        }

        $stats.OutdatedPractices++
    }
}

# Generate report
Write-Host ""
Write-Host "Generating temporal conflict report..." -ForegroundColor Yellow

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$report = @"
# Temporal Conflict Report
**Generated:** $timestamp
**Stale Threshold:** $StaleThresholdDays days

## Summary

- **Total Documents Scanned:** $($stats.TotalDocs)
- **Stale Documents:** $($stats.StaleDocs)
- **Missing Timestamps:** $($stats.MissingTimestamps)
- **Outdated Version References:** $($stats.OutdatedVersions)
- **Outdated Practices:** $($stats.OutdatedPractices)

### Total Conflicts: $($conflicts.Count)

---

## Conflicts by Type

"@

# Group by type and severity
$byType = $conflicts | Group-Object -Property Type

foreach ($typeGroup in $byType) {
    $report += "`n### $($typeGroup.Name -replace '_', ' ') ($($typeGroup.Count) issues)`n`n"

    $bySeverity = $typeGroup.Group | Group-Object -Property Severity

    foreach ($severityGroup in $bySeverity) {
        $report += "`n#### $($severityGroup.Name) Severity`n`n"

        foreach ($conflict in $severityGroup.Group) {
            $report += "- **File:** ``$($conflict.FileName)```n"
            $report += "  - **Path:** ``$($conflict.File)```n"
            $report += "  - **Issue:** $($conflict.Message)`n"

            if ($conflict.LastUpdate) {
                $report += "  - **Last Updated:** $($conflict.LastUpdate.ToString('yyyy-MM-dd'))`n"
                $report += "  - **Days Since Update:** $($conflict.DaysSinceUpdate)`n"
            }

            if ($conflict.Version) {
                $report += "  - **Version Reference:** $($conflict.Version)`n"
            }

            if ($conflict.Practice) {
                $report += "  - **Outdated Practice:** $($conflict.Practice)`n"
            }

            $report += "`n"
        }
    }
}

# Recommendations
$report += @"

---

## Recommendations

### Immediate Actions (HIGH Severity)

"@

$highSeverity = $conflicts | Where-Object { $_.Severity -eq "HIGH" }

foreach ($conflict in $highSeverity) {
    $report += "1. **$($conflict.FileName)** - $($conflict.Message)`n"
}

$report += @"

### Documentation Health Best Practices

1. **Add Timestamps:** Every documentation file should include:
   \`\`\`markdown
   **Last Updated:** YYYY-MM-DD
   **Version:** X.Y.Z
   \`\`\`

2. **Regular Reviews:** Schedule quarterly documentation reviews

3. **Version Control:** Track technology versions and update when upgraded

4. **Deprecation Warnings:** Add warning boxes for outdated practices

5. **Automation:** Run this temporal conflict detector monthly

6. **Archive Strategy:** Move outdated docs to archive/ folder with clear labels

### Next Steps

- [ ] Review and update HIGH severity conflicts
- [ ] Add timestamps to files missing them
- [ ] Update or archive stale documentation
- [ ] Replace outdated practice references
- [ ] Set up monthly automated temporal conflict checks
- [ ] Create documentation review calendar

"@

# Save report
$report | Out-File -FilePath $OutputPath -Encoding UTF8

Write-Host ""
if ($conflicts.Count -eq 0) {
    Write-Host "No temporal conflicts found! Documentation is up to date." -ForegroundColor Green
}
else {
    Write-Host "Temporal conflict analysis complete!" -ForegroundColor Yellow
    Write-Host "  Total conflicts: $($conflicts.Count)" -ForegroundColor Yellow
    Write-Host "  Stale documents: $($stats.StaleDocs)" -ForegroundColor Red
    Write-Host "  Outdated practices: $($stats.OutdatedPractices)" -ForegroundColor Red
    Write-Host "  Missing timestamps: $($stats.MissingTimestamps)" -ForegroundColor Yellow
    Write-Host "  Report saved: $OutputPath" -ForegroundColor Cyan
}
Write-Host ""

return @{
    Success = $true
    TotalConflicts = $conflicts.Count
    Stats = $stats
    ReportPath = $OutputPath
}
