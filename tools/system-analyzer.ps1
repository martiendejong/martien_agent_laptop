# System Analyzer - REAL comprehensive analysis
# Scans all tools, finds actual issues, measures everything
# Created: 2026-02-07 (Post-critique - NO THEATER)

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('scan', 'detailed', 'report')]
    [string]$Action = 'scan'
)

$ErrorActionPreference = "Stop"

function Measure-CodeQuality {
    param([string]$FilePath)

    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath

    $metrics = @{
        file = Split-Path $FilePath -Leaf
        total_lines = $lines.Count
        code_lines = ($lines | Where-Object { $_ -match '\S' }).Count
        comment_lines = ($lines | Where-Object { $_ -match '^\s*#' }).Count
        functions = ([regex]::Matches($content, 'function\s+[\w-]+') | Measure-Object).Count
        error_handling = ($content -match '\$ErrorActionPreference')
        param_validation = ($content -match '\[ValidateSet')
        help_comments = ($content -match '\.SYNOPSIS' -or $content -match '\.DESCRIPTION')
        size_kb = [math]::Round((Get-Item $FilePath).Length / 1KB, 2)
    }

    # Find actual issues
    $issues = @()

    # No error handling
    if (-not $metrics.error_handling) {
        $issues += "No error handling configured"
    }

    # No parameter validation
    if ($content -match 'param\(' -and -not $metrics.param_validation) {
        $issues += "Parameters lack validation"
    }

    # No documentation
    if (-not $metrics.help_comments) {
        $issues += "Missing help documentation"
    }

    # Very long file (>500 lines)
    if ($metrics.total_lines -gt 500) {
        $issues += "File too long ($($metrics.total_lines) lines) - consider splitting"
    }

    # Low comment ratio (<5%)
    $commentRatio = if ($metrics.code_lines -gt 0) {
        $metrics.comment_lines / $metrics.code_lines
    } else { 0 }

    if ($commentRatio -lt 0.05 -and $metrics.total_lines -gt 50) {
        $issues += "Low comment ratio ($([math]::Round($commentRatio * 100, 1))%)"
    }

    $metrics['issues'] = $issues
    $metrics['quality_score'] = 100 - ($issues.Count * 15)

    return $metrics
}

function Find-DuplicateCode {
    param([array]$Files)

    Write-Host ""
    Write-Host "[ANALYZING] Searching for duplicate code patterns..." -ForegroundColor Yellow

    $functionPatterns = @{}
    $duplicates = @()

    foreach ($file in $Files) {
        $content = Get-Content $file.FullName -Raw
        $functions = [regex]::Matches($content, 'function\s+([\w-]+)\s*\{([^\}]{50,200})\}')

        foreach ($match in $functions) {
            $funcName = $match.Groups[1].Value
            $funcBody = $match.Groups[2].Value -replace '\s+', ' '

            # Look for similar function bodies
            foreach ($pattern in $functionPatterns.Keys) {
                $similarity = 0
                $words1 = $pattern -split '\s+'
                $words2 = $funcBody -split '\s+'

                $commonWords = $words1 | Where-Object { $words2 -contains $_ }
                if ($words1.Count -gt 0) {
                    $similarity = $commonWords.Count / $words1.Count
                }

                if ($similarity -gt 0.7) {
                    $duplicates += @{
                        file1 = $functionPatterns[$pattern].file
                        func1 = $functionPatterns[$pattern].name
                        file2 = $file.Name
                        func2 = $funcName
                        similarity = [math]::Round($similarity * 100, 0)
                    }
                }
            }

            $functionPatterns[$funcBody] = @{
                name = $funcName
                file = $file.Name
            }
        }
    }

    return $duplicates
}

function Find-UnusedFunctions {
    param([array]$Files)

    Write-Host ""
    Write-Host "[ANALYZING] Finding unused functions..." -ForegroundColor Yellow

    # Extract all function definitions
    $allFunctions = @{}
    foreach ($file in $Files) {
        $content = Get-Content $file.FullName -Raw
        $functions = [regex]::Matches($content, 'function\s+([\w-]+)')

        foreach ($match in $functions) {
            $funcName = $match.Groups[1].Value
            if (-not $allFunctions.ContainsKey($funcName)) {
                $allFunctions[$funcName] = @{
                    defined_in = $file.Name
                    called = $false
                }
            }
        }
    }

    # Search for function calls
    foreach ($file in $Files) {
        $content = Get-Content $file.FullName -Raw

        foreach ($funcName in $allFunctions.Keys) {
            # Look for calls to this function
            if ($content -match "$funcName\s*(?:\(|-)|& `".*$funcName") {
                $allFunctions[$funcName].called = $true
            }
        }
    }

    # Return unused functions
    $unused = @()
    foreach ($funcName in $allFunctions.Keys) {
        if (-not $allFunctions[$funcName].called) {
            $unused += @{
                function = $funcName
                file = $allFunctions[$funcName].defined_in
            }
        }
    }

    return $unused
}

function Scan-System {
    Write-Host ""
    Write-Host "=== REAL SYSTEM ANALYSIS ===" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "[SCANNING] All tools in C:\scripts\tools..." -ForegroundColor Cyan
    Write-Host ""

    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    # Get all PowerShell files
    $files = Get-ChildItem "C:\scripts\tools\*.ps1" -File

    Write-Host "Found $($files.Count) PowerShell tools" -ForegroundColor White
    Write-Host ""

    # Analyze each file
    $allMetrics = @()
    $totalIssues = 0

    foreach ($file in $files) {
        $metrics = Measure-CodeQuality -FilePath $file.FullName
        $allMetrics += $metrics
        $totalIssues += $metrics.issues.Count

        if ($metrics.issues.Count -gt 0) {
            Write-Host "  [!] $($file.Name) - $($metrics.issues.Count) issues" -ForegroundColor Yellow
        }
    }

    # Find duplicates
    $duplicates = Find-DuplicateCode -Files $files

    # Find unused functions
    $unused = Find-UnusedFunctions -Files $files

    $sw.Stop()

    Write-Host ""
    Write-Host "[SUMMARY]" -ForegroundColor Cyan
    Write-Host "  Files analyzed: $($files.Count)" -ForegroundColor White

    $totalLines = ($allMetrics | ForEach-Object { $_.total_lines } | Measure-Object -Sum).Sum
    $totalFunctions = ($allMetrics | ForEach-Object { $_.functions } | Measure-Object -Sum).Sum

    Write-Host "  Total lines: $totalLines" -ForegroundColor White
    Write-Host "  Total functions: $totalFunctions" -ForegroundColor White
    Write-Host "  Issues found: $totalIssues" -ForegroundColor Yellow
    Write-Host "  Duplicate code patterns: $($duplicates.Count)" -ForegroundColor Yellow
    Write-Host "  Unused functions: $($unused.Count)" -ForegroundColor Yellow
    Write-Host "  Analysis time: $($sw.ElapsedMilliseconds)ms" -ForegroundColor Gray
    Write-Host ""

    # Calculate average quality score
    $avgQuality = [math]::Round(($allMetrics | ForEach-Object { $_.quality_score } | Measure-Object -Average).Average, 1)
    $qualityColor = if ($avgQuality -ge 80) { "Green" } elseif ($avgQuality -ge 60) { "Yellow" } else { "Red" }

    Write-Host "Average quality score: " -NoNewline -ForegroundColor Gray
    Write-Host "$avgQuality/100" -ForegroundColor $qualityColor
    Write-Host ""

    return @{
        metrics = $allMetrics
        duplicates = $duplicates
        unused = $unused
        total_issues = $totalIssues
        avg_quality = $avgQuality
        scan_time_ms = $sw.ElapsedMilliseconds
    }
}

function Show-DetailedReport {
    param($Analysis)

    Write-Host ""
    Write-Host "=== DETAILED ANALYSIS REPORT ===" -ForegroundColor Magenta
    Write-Host ""

    # Top 10 files with most issues
    Write-Host "TOP 10 FILES WITH MOST ISSUES:" -ForegroundColor Yellow
    Write-Host ""

    $topIssues = $Analysis.metrics |
                 Where-Object { $_.issues.Count -gt 0 } |
                 Sort-Object { $_.issues.Count } -Descending |
                 Select-Object -First 10

    foreach ($file in $topIssues) {
        Write-Host "  $($file.file) - $($file.issues.Count) issues" -ForegroundColor White
        foreach ($issue in $file.issues) {
            Write-Host "    - $issue" -ForegroundColor Gray
        }
        Write-Host ""
    }

    # Duplicate code
    if ($Analysis.duplicates.Count -gt 0) {
        Write-Host "DUPLICATE CODE DETECTED:" -ForegroundColor Yellow
        Write-Host ""

        foreach ($dup in $Analysis.duplicates) {
            Write-Host "  $($dup.similarity)% similar:" -ForegroundColor White
            Write-Host "    - $($dup.file1):$($dup.func1)" -ForegroundColor Gray
            Write-Host "    - $($dup.file2):$($dup.func2)" -ForegroundColor Gray
            Write-Host ""
        }
    }

    # Unused functions
    if ($Analysis.unused.Count -gt 0) {
        Write-Host "UNUSED FUNCTIONS (Candidates for removal):" -ForegroundColor Yellow
        Write-Host ""

        foreach ($func in $Analysis.unused) {
            Write-Host "  $($func.function) in $($func.file)" -ForegroundColor Gray
        }
        Write-Host ""
    }

    # Recommendations
    Write-Host "=== ACTIONABLE RECOMMENDATIONS ===" -ForegroundColor Cyan
    Write-Host ""

    $recommendations = @()

    # Based on actual findings
    if ($Analysis.total_issues -gt 50) {
        $recommendations += "Add error handling to $($Analysis.total_issues) locations"
    }

    if ($Analysis.duplicates.Count -gt 5) {
        $recommendations += "Refactor $($Analysis.duplicates.Count) duplicate code patterns into shared functions"
    }

    if ($Analysis.unused.Count -gt 10) {
        $recommendations += "Remove $($Analysis.unused.Count) unused functions to reduce complexity"
    }

    $lowQualityFiles = ($Analysis.metrics | Where-Object { $_.quality_score -lt 60 }).Count
    if ($lowQualityFiles -gt 0) {
        $recommendations += "Improve $lowQualityFiles low-quality files (score < 60)"
    }

    if ($recommendations.Count -eq 0) {
        Write-Host "[EXCELLENT] No major issues found!" -ForegroundColor Green
    } else {
        $rank = 1
        foreach ($rec in $recommendations) {
            Write-Host "  $rank. $rec" -ForegroundColor White
            $rank++
        }
    }

    Write-Host ""
}

# Main execution
switch ($Action) {
    'scan' {
        $analysis = Scan-System

        # Save results
        $outputFile = "C:\scripts\.machine\system-analysis.json"
        $analysis | ConvertTo-Json -Depth 10 | Out-File $outputFile -Encoding UTF8
        Write-Host "[SAVED] Analysis results: $outputFile" -ForegroundColor Green
        Write-Host ""
    }

    'detailed' {
        $analysis = Scan-System
        Show-DetailedReport -Analysis $analysis

        # Save results
        $outputFile = "C:\scripts\.machine\system-analysis.json"
        $analysis | ConvertTo-Json -Depth 10 | Out-File $outputFile -Encoding UTF8
        Write-Host "[SAVED] Analysis results: $outputFile" -ForegroundColor Green
        Write-Host ""
    }

    'report' {
        # Load existing analysis
        $analysisFile = "C:\scripts\.machine\system-analysis.json"
        if (-not (Test-Path $analysisFile)) {
            Write-Host "[ERROR] No analysis found. Run with -Action scan first" -ForegroundColor Red
            exit 1
        }

        $analysis = Get-Content $analysisFile -Raw | ConvertFrom-Json
        Show-DetailedReport -Analysis $analysis
    }
}
