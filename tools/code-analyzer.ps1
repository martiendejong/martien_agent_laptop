# Real Code Analyzer - No Theater, Actual Analysis
# Scans actual code and finds real issues
# Created: 2026-02-07

param(
    [string]$Path = "C:\scripts\tools",
    [switch]$Detailed
)

$ErrorActionPreference = "Stop"

function Analyze-PowerShellFile {
    param([string]$FilePath)

    $content = Get-Content $FilePath -Raw
    $lines = $content -split "`n"

    $analysis = @{
        File = (Split-Path $FilePath -Leaf)
        Path = $FilePath
        Lines = $lines.Count
        Issues = @()
        Metrics = @{
            Functions = 0
            Parameters = 0
            ErrorHandling = 0
            Comments = 0
            TODOs = 0
        }
    }

    # Count functions
    $functions = [regex]::Matches($content, "function\s+[\w-]+")
    $analysis.Metrics.Functions = $functions.Count

    # Count parameters
    $params = [regex]::Matches($content, "\[Parameter")
    $analysis.Metrics.Parameters = $params.Count

    # Count error handling
    $tryCatch = [regex]::Matches($content, "try\s*\{")
    $errorAction = [regex]::Matches($content, '\$ErrorActionPreference')
    $analysis.Metrics.ErrorHandling = $tryCatch.Count + $errorAction.Count

    # Count comments and TODOs
    foreach ($line in $lines) {
        if ($line -match '^\s*#') { $analysis.Metrics.Comments++ }
        if ($line -match 'TODO|FIXME|HACK|XXX') { $analysis.Metrics.TODOs++ }
    }

    # Find issues

    # Issue: Large file with no functions
    if ($lines.Count -gt 200 -and $analysis.Metrics.Functions -eq 0) {
        $analysis.Issues += @{
            Severity = 7
            Type = "Structure"
            Issue = "Large file ($($lines.Count) lines) with no functions - should be modularized"
        }
    }

    # Issue: Functions with no error handling
    if ($analysis.Metrics.Functions -gt 3 -and $analysis.Metrics.ErrorHandling -eq 0) {
        $analysis.Issues += @{
            Severity = 8
            Type = "Reliability"
            Issue = "File has $($analysis.Metrics.Functions) functions but zero error handling"
        }
    }

    # Issue: High TODO count
    if ($analysis.Metrics.TODOs -gt 3) {
        $analysis.Issues += @{
            Severity = 5
            Type = "Maintenance"
            Issue = "File has $($analysis.Metrics.TODOs) TODO/FIXME comments - unfinished work"
        }
    }

    # Issue: Low comment ratio
    $commentRatio = if ($lines.Count -gt 0) { $analysis.Metrics.Comments / $lines.Count } else { 0 }
    if ($lines.Count -gt 100 -and $commentRatio -lt 0.05) {
        $analysis.Issues += @{
            Severity = 4
            Type = "Maintainability"
            Issue = "Low comment ratio ($([math]::Round($commentRatio * 100, 1))%) - code may be hard to understand"
        }
    }

    # Issue: Parameter validation
    if ($analysis.Metrics.Parameters -gt 5 -and $content -notmatch '\[ValidateSet|\[ValidateNotNull|\[ValidateRange') {
        $analysis.Issues += @{
            Severity = 6
            Type = "Robustness"
            Issue = "Has parameters but no validation attributes"
        }
    }

    # Issue: Hardcoded paths
    $hardcodedPaths = [regex]::Matches($content, 'C:\\[^\s"'']+')
    if ($hardcodedPaths.Count -gt 5) {
        $analysis.Issues += @{
            Severity = 5
            Type = "Portability"
            Issue = "Contains $($hardcodedPaths.Count) hardcoded paths - not portable"
        }
    }

    # Issue: Global variables
    $globals = [regex]::Matches($content, '\$global:')
    if ($globals.Count -gt 2) {
        $analysis.Issues += @{
            Severity = 7
            Type = "Architecture"
            Issue = "Uses $($globals.Count) global variables - tight coupling"
        }
    }

    # Issue: Long functions (>100 lines)
    $functionPattern = 'function\s+([\w-]+)\s*\{'
    $functionMatches = [regex]::Matches($content, $functionPattern)
    foreach ($match in $functionMatches) {
        $funcName = $match.Groups[1].Value
        $funcStart = $match.Index
        $funcContent = $content.Substring($funcStart)

        # Simple brace counting to find function end
        $braceCount = 0
        $funcEnd = 0
        for ($i = 0; $i -lt $funcContent.Length; $i++) {
            if ($funcContent[$i] -eq '{') { $braceCount++ }
            if ($funcContent[$i] -eq '}') {
                $braceCount--
                if ($braceCount -eq 0) {
                    $funcEnd = $i
                    break
                }
            }
        }

        if ($funcEnd -gt 0) {
            $funcLines = ($funcContent.Substring(0, $funcEnd) -split "`n").Count
            if ($funcLines -gt 100) {
                $analysis.Issues += @{
                    Severity = 6
                    Type = "Complexity"
                    Issue = "Function '$funcName' is $funcLines lines - should be split"
                }
            }
        }
    }

    return $analysis
}

function Analyze-Directory {
    param([string]$Path)

    Write-Host "Analyzing: $Path" -ForegroundColor Cyan
    Write-Host ""

    $files = Get-ChildItem $Path -Filter "*.ps1" | Where-Object { -not $_.Name.StartsWith('.') }
    $allAnalyses = @()
    $totalIssues = 0

    foreach ($file in $files) {
        $analysis = Analyze-PowerShellFile -FilePath $file.FullName
        $allAnalyses += $analysis
        $totalIssues += $analysis.Issues.Count

        if ($Detailed -or $analysis.Issues.Count -gt 0) {
            Write-Host "[$($file.Name)]" -ForegroundColor Yellow
            Write-Host "  Lines: $($analysis.Lines) | Functions: $($analysis.Metrics.Functions) | TODOs: $($analysis.Metrics.TODOs)" -ForegroundColor Gray

            if ($analysis.Issues.Count -gt 0) {
                Write-Host "  Issues found: $($analysis.Issues.Count)" -ForegroundColor Red
                foreach ($issue in $analysis.Issues) {
                    Write-Host "    [Severity $($issue.Severity)] $($issue.Issue)" -ForegroundColor DarkRed
                }
            } else {
                Write-Host "  No issues found" -ForegroundColor Green
            }
            Write-Host ""
        }
    }

    # Summary
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "ANALYSIS SUMMARY" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "Files analyzed: $($files.Count)" -ForegroundColor Gray
    Write-Host "Total issues: $totalIssues" -ForegroundColor $(if($totalIssues -gt 10) {'Red'} else {'Yellow'})
    Write-Host ""

    # Top issues by severity
    $topIssues = $allAnalyses |
        ForEach-Object {
            $file = $_.File
            $_.Issues | ForEach-Object {
                $_ | Add-Member -NotePropertyName "File" -NotePropertyValue $file -PassThru
            }
        } |
        Sort-Object -Property Severity -Descending |
        Select-Object -First 10

    if ($topIssues.Count -gt 0) {
        Write-Host "Top 10 Issues by Severity:" -ForegroundColor Yellow
        foreach ($issue in $topIssues) {
            Write-Host "  [$($issue.File)] [Sev $($issue.Severity)] $($issue.Issue)" -ForegroundColor Red
        }
    }

    return $allAnalyses
}

# Run analysis
$results = Analyze-Directory -Path $Path

# Return results for programmatic use
return $results
