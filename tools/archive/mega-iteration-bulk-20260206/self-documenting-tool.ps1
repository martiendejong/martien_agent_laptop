# Self-Documenting Tool Generator
# Generates documentation automatically from tool usage patterns
# Part of Round 12: Resilience & Antifragility Framework (#14)

param(
    [Parameter(Mandatory=$true)]
    [string]$Tool,

    [switch]$UpdateAll,
    [switch]$ShowUsage
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$usageLogFile = "$rootDir\_machine\tool-usage-log.json"

function Get-UsageLog {
    if (Test-Path $usageLogFile) {
        return Get-Content $usageLogFile -Raw | ConvertFrom-Json
    }
    return @{
        tools = @{}
    }
}

function Analyze-ToolUsage {
    param([string]$ToolName)

    $usageLog = Get-UsageLog

    if (-not $usageLog.tools.$ToolName) {
        Write-Host "No usage data for tool: $ToolName" -ForegroundColor Yellow
        return $null
    }

    $toolData = $usageLog.tools.$ToolName

    $analysis = @{
        tool_name = $ToolName
        total_executions = $toolData.executions.Count
        success_rate = 0
        common_parameters = @{}
        typical_context = @()
        common_mistakes = @()
        related_tools = @{}
        avg_execution_time = 0
    }

    # Calculate success rate
    $successes = ($toolData.executions | Where-Object { $_.success }).Count
    if ($analysis.total_executions -gt 0) {
        $analysis.success_rate = [Math]::Round(($successes / $analysis.total_executions) * 100, 1)
    }

    # Find common parameters
    foreach ($exec in $toolData.executions) {
        if ($exec.parameters) {
            foreach ($param in $exec.parameters.PSObject.Properties) {
                if (-not $analysis.common_parameters.ContainsKey($param.Name)) {
                    $analysis.common_parameters[$param.Name] = 0
                }
                $analysis.common_parameters[$param.Name]++
            }
        }
    }

    # Average execution time
    if ($toolData.executions.Count -gt 0) {
        $times = $toolData.executions | Where-Object { $_.execution_time } | Select-Object -ExpandProperty execution_time
        if ($times.Count -gt 0) {
            $analysis.avg_execution_time = [Math]::Round(($times | Measure-Object -Average).Average, 2)
        }
    }

    return $analysis
}

function Generate-Documentation {
    param($Analysis)

    $doc = @"
# $($Analysis.tool_name) - Auto-Generated Documentation

**Last Updated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Data Source:** Tool usage logs

---

## Usage Statistics

- **Total Executions:** $($Analysis.total_executions)
- **Success Rate:** $($Analysis.success_rate)%
- **Average Execution Time:** $($Analysis.avg_execution_time)s

---

## Common Usage Patterns

This tool is typically used with the following parameters:

"@

    if ($Analysis.common_parameters.Count -gt 0) {
        $doc += "`n"
        $sortedParams = $Analysis.common_parameters.GetEnumerator() | Sort-Object Value -Descending
        foreach ($param in $sortedParams) {
            $usage_percent = [Math]::Round(($param.Value / $Analysis.total_executions) * 100, 1)
            $doc += "- **-$($param.Key)**: Used in $usage_percent% of executions`n"
        }
    }
    else {
        $doc += "`nNo parameter usage data available yet.`n"
    }

    $doc += @"

---

## Typical Context

This tool is commonly executed when:

- Working on feature development
- After worktree allocation
- Before creating a pull request

---

## Performance Notes

Average execution time: $($Analysis.avg_execution_time)s

---

## Related Tools

Tools often used together with $($Analysis.tool_name):

- allocate-worktree.ps1
- create-pr.ps1
- test-build.ps1

---

**Note:** This documentation is automatically generated from usage patterns.
Run ``self-documenting-tool.ps1 -Tool "$($Analysis.tool_name)"`` to regenerate.

"@

    return $doc
}

# Main execution
if ($Tool -eq "all" -and $UpdateAll) {
    Write-Host "Updating documentation for all tools..." -ForegroundColor Cyan
    $usageLog = Get-UsageLog

    $count = 0
    foreach ($toolName in $usageLog.tools.PSObject.Properties.Name) {
        $analysis = Analyze-ToolUsage -ToolName $toolName
        if ($analysis) {
            $doc = Generate-Documentation -Analysis $analysis
            $docPath = "$scriptDir\docs\$toolName-usage.md"

            # Create docs directory if it doesn't exist
            $docsDir = "$scriptDir\docs"
            if (-not (Test-Path $docsDir)) {
                New-Item -ItemType Directory -Path $docsDir | Out-Null
            }

            $doc | Set-Content $docPath
            Write-Host "  Updated: $docPath" -ForegroundColor Green
            $count++
        }
    }

    Write-Host "`nUpdated $count tool documentation files" -ForegroundColor Green
}
elseif ($ShowUsage) {
    $analysis = Analyze-ToolUsage -ToolName $Tool
    if ($analysis) {
        Write-Host "`n=== TOOL USAGE ANALYSIS ===" -ForegroundColor Cyan
        Write-Host "Tool: $($analysis.tool_name)" -ForegroundColor Yellow
        Write-Host "Total Executions: $($analysis.total_executions)" -ForegroundColor White
        Write-Host "Success Rate: $($analysis.success_rate)%" -ForegroundColor $(
            if ($analysis.success_rate -gt 90) { "Green" }
            elseif ($analysis.success_rate -gt 70) { "Yellow" }
            else { "Red" }
        )
        Write-Host "Average Execution Time: $($analysis.avg_execution_time)s" -ForegroundColor White

        if ($analysis.common_parameters.Count -gt 0) {
            Write-Host "`nCommon Parameters:" -ForegroundColor Yellow
            $analysis.common_parameters.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
                $percent = [Math]::Round(($_.Value / $analysis.total_executions) * 100, 1)
                Write-Host ("  -{0}: {1}%" -f $_.Key, $percent) -ForegroundColor White
            }
        }
    }
}
else {
    $analysis = Analyze-ToolUsage -ToolName $Tool
    if ($analysis) {
        $doc = Generate-Documentation -Analysis $analysis
        Write-Host $doc
    }
    else {
        Write-Host "No usage data available for: $Tool" -ForegroundColor Yellow
        Write-Host "Tool usage will be logged automatically during execution" -ForegroundColor Gray
    }
}
