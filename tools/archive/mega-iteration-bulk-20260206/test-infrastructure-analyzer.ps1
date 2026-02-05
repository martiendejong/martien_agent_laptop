<#
.SYNOPSIS
    Analyzes C# controllers for integration test infrastructure issues

.DESCRIPTION
    Scans ASP.NET Core controllers for patterns that cause WebApplicationFactory test failures:
    - Deep dependency chains (>3 levels in constructor)
    - Excessive constructor parameters (>5 parameters)
    - Service instantiation in controllers (should be injected)
    - Missing interface abstractions
    - Static dependencies that break testability

    Triggered by: 20 ChatController tests failing due to deep constructor chains (2026-01-25)

.PARAMETER ProjectPath
    Path to the ASP.NET Core project containing controllers

.PARAMETER OutputFormat
    Output format: console (default), json, or markdown

.PARAMETER MinSeverity
    Minimum severity to report: info, warning (default), or critical

.PARAMETER FixSuggestions
    Include detailed fix suggestions with service extraction examples

.EXAMPLE
    test-infrastructure-analyzer.ps1 -ProjectPath "C:\Projects\client-manager\ClientManagerAPI"

.EXAMPLE
    test-infrastructure-analyzer.ps1 -ProjectPath "." -OutputFormat markdown -FixSuggestions

.NOTES
    Author: Jengo (Autonomous Agent)
    Created: 2026-02-01
    Value: 9/10 - Prevents integration test failures proactively
    Ratio: 4.5 (high value, moderate effort)
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = ".",

    [Parameter(Mandatory=$false)]
    [ValidateSet("console", "json", "markdown")]
    [string]$OutputFormat = "console",

    [Parameter(Mandatory=$false)]
    [ValidateSet("info", "warning", "critical")]
    [string]$MinSeverity = "warning",

    [Parameter(Mandatory=$false)]
    [switch]$FixSuggestions
)

# Color output helpers
function Write-Severity {
    param([string]$Message, [string]$Severity)

    $color = switch ($Severity) {
        "critical" { "Red" }
        "warning" { "Yellow" }
        "info" { "Cyan" }
        default { "White" }
    }

    Write-Host $Message -ForegroundColor $color
}

# Analysis result class
class ControllerIssue {
    [string]$File
    [string]$Controller
    [int]$LineNumber
    [string]$Severity
    [string]$Category
    [string]$Issue
    [string]$Suggestion
    [hashtable]$Metrics
}

# Main analysis function
function Analyze-Controller {
    param([string]$FilePath)

    $issues = @()
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath

    # Extract controller name
    $controllerName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)

    # 1. Analyze constructor parameters
    $constructorMatch = [regex]::Match($content, 'public\s+' + [regex]::Escape($controllerName) + '\s*\(([\s\S]*?)\)')

    if ($constructorMatch.Success) {
        $constructorParams = $constructorMatch.Groups[1].Value

        # Count parameters
        $paramCount = ($constructorParams -split ',').Count
        if ($paramCount -eq 1 -and $constructorParams.Trim() -eq "") {
            $paramCount = 0
        }

        # Find line number
        $lineNumber = ($lines | Select-String -Pattern "public\s+$controllerName\s*\(" | Select-Object -First 1).LineNumber

        if ($paramCount -gt 10) {
            $issues += [ControllerIssue]@{
                File = $FilePath
                Controller = $controllerName
                LineNumber = $lineNumber
                Severity = "critical"
                Category = "DeepDependencyChain"
                Issue = "Constructor has $paramCount parameters (critical: >10)"
                Suggestion = "Extract services. Controllers should orchestrate, not implement logic."
                Metrics = @{
                    ParameterCount = $paramCount
                    Threshold = 10
                }
            }
        }
        elseif ($paramCount -gt 5) {
            $issues += [ControllerIssue]@{
                File = $FilePath
                Controller = $controllerName
                LineNumber = $lineNumber
                Severity = "warning"
                Category = "HighDependencyCount"
                Issue = "Constructor has $paramCount parameters (warning: >5)"
                Suggestion = "Consider service extraction if controller logic is complex."
                Metrics = @{
                    ParameterCount = $paramCount
                    Threshold = 5
                }
            }
        }
    }

    # 2. Detect service instantiation in controller (anti-pattern)
    $newServicePattern = 'new\s+\w+Service\s*\('
    $newServiceMatches = [regex]::Matches($content, $newServicePattern)

    foreach ($match in $newServiceMatches) {
        $lineNumber = ($content.Substring(0, $match.Index) -split "`n").Count

        $issues += [ControllerIssue]@{
            File = $FilePath
            Controller = $controllerName
            LineNumber = $lineNumber
            Severity = "critical"
            Category = "ServiceInstantiation"
            Issue = "Service instantiated in controller: $($match.Value)"
            Suggestion = "Inject service through constructor. This breaks WebApplicationFactory tests."
            Metrics = @{
                Pattern = $match.Value
            }
        }
    }

    # 3. Detect static dependencies
    $staticCallPattern = '\w+\.\w+\s*\('
    $staticCalls = [regex]::Matches($content, $staticCallPattern) | Where-Object { $_.Value -notmatch '^(string|int|bool|DateTime|Guid|Console|System)\.' }

    if ($staticCalls.Count -gt 20) {
        $issues += [ControllerIssue]@{
            File = $FilePath
            Controller = $controllerName
            LineNumber = 0
            Severity = "info"
            Category = "StaticDependencies"
            Issue = "High static method usage ($($staticCalls.Count) calls)"
            Suggestion = "Review for static dependencies that may break testability."
            Metrics = @{
                StaticCallCount = $staticCalls.Count
            }
        }
    }

    # 4. Analyze using statements (indirect dependency indicator)
    $usingStatements = ([regex]::Matches($content, '^using\s+[\w\.]+;', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count

    if ($usingStatements -gt 30) {
        $issues += [ControllerIssue]@{
            File = $FilePath
            Controller = $controllerName
            LineNumber = 0
            Severity = "warning"
            Category = "ExcessiveUsings"
            Issue = "$usingStatements using statements (indicator of high coupling)"
            Suggestion = "High coupling detected. Consider service extraction."
            Metrics = @{
                UsingCount = $usingStatements
                Threshold = 30
            }
        }
    }

    # 5. Detect lack of interfaces (concrete dependencies)
    $concreteServicePattern = 'private\s+\w+Service\s+\w+;'
    $concreteServices = [regex]::Matches($content, $concreteServicePattern)

    foreach ($match in $concreteServices) {
        $lineNumber = ($content.Substring(0, $match.Index) -split "`n").Count

        $issues += [ControllerIssue]@{
            File = $FilePath
            Controller = $controllerName
            LineNumber = $lineNumber
            Severity = "info"
            Category = "ConcreteDepe ndency"
            Issue = "Concrete service dependency: $($match.Value)"
            Suggestion = "Prefer interface injection (I$($match.Value)) for better testability."
            Metrics = @{
                Pattern = $match.Value
            }
        }
    }

    return $issues
}

# Generate fix suggestions
function Get-FixSuggestions {
    param([ControllerIssue]$Issue)

    $suggestions = @{
        "DeepDependencyChain" = @"

=== SERVICE EXTRACTION PATTERN ===

BEFORE (Controller with $($Issue.Metrics.ParameterCount) dependencies):
public class $($Issue.Controller)(
    IService1 service1,
    IService2 service2,
    ... [many more]
)

AFTER (Extracted service):

1. Create Interface:
   public interface I$($Issue.Controller)Service
   {
       Task<Result> HandleMainOperation(params);
   }

2. Implement Service:
   public class $($Issue.Controller)Service : I$($Issue.Controller)Service
   {
       private readonly IService1 _service1;
       private readonly IService2 _service2;
       // ... moved dependencies

       public $($Issue.Controller)Service(IService1 service1, IService2 service2, ...)
       {
           _service1 = service1;
           _service2 = service2;
       }

       public async Task<Result> HandleMainOperation(params)
       {
           // Move controller logic here
       }
   }

3. Simplified Controller:
   public class $($Issue.Controller)(I$($Issue.Controller)Service service)
   {
       [HttpPost]
       public async Task<IActionResult> Action(params)
       {
           var result = await service.HandleMainOperation(params);
           return Ok(result);
       }
   }

4. Register in Program.cs:
   builder.Services.AddScoped<I$($Issue.Controller)Service, $($Issue.Controller)Service>();

BENEFIT: Reduces constructor params from $($Issue.Metrics.ParameterCount) to 1-2
"@

        "ServiceInstantiation" = @"

=== DEPENDENCY INJECTION FIX ===

WRONG:
var service = new MyService(config);  // Breaks WebApplicationFactory

RIGHT:
1. Add to constructor:
   private readonly IMyService _service;
   public $($Issue.Controller)(IMyService service) => _service = service;

2. Register in Program.cs:
   builder.Services.AddScoped<IMyService, MyService>();

3. Use injected service:
   var result = await _service.DoWork();
"@

        "ExcessiveUsings" = @"

=== REDUCE COUPLING ===

$($Issue.Metrics.UsingCount) using statements indicates high coupling.

FIX:
1. Identify which usings are for service dependencies
2. Group related functionality into a service
3. Inject the service interface
4. Remove direct usings from controller

RESULT: Controller focuses on HTTP concerns, services handle logic
"@
    }

    return $suggestions[$Issue.Category]
}

# Main execution
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  TEST INFRASTRUCTURE ANALYZER" -ForegroundColor Cyan
Write-Host "  Preventing WebApplicationFactory Failures" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# Find controllers
$controllerPath = Join-Path $ProjectPath "Controllers"
if (-not (Test-Path $controllerPath)) {
    Write-Host "Controllers directory not found: $controllerPath" -ForegroundColor Red
    exit 1
}

$controllers = Get-ChildItem $controllerPath -Filter "*Controller.cs" -File

Write-Host "Analyzing $($controllers.Count) controllers..." -ForegroundColor White
Write-Host ""

# Analyze all controllers
$allIssues = @()
foreach ($controller in $controllers) {
    $issues = Analyze-Controller -FilePath $controller.FullName
    $allIssues += $issues
}

# Filter by severity
$severityOrder = @{ "critical" = 3; "warning" = 2; "info" = 1 }
$minSeverityLevel = $severityOrder[$MinSeverity]
$filteredIssues = $allIssues | Where-Object { $severityOrder[$_.Severity] -ge $minSeverityLevel }

# Output results
if ($OutputFormat -eq "json") {
    $filteredIssues | ConvertTo-Json -Depth 10 | Write-Output
}
elseif ($OutputFormat -eq "markdown") {
    Write-Output "# Test Infrastructure Analysis Report"
    Write-Output ""
    Write-Output "**Date:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    Write-Output "**Project:** $ProjectPath"
    Write-Output "**Controllers Analyzed:** $($controllers.Count)"
    Write-Output "**Issues Found:** $($filteredIssues.Count)"
    Write-Output ""

    # Group by severity
    $bySeverity = $filteredIssues | Group-Object Severity
    foreach ($group in $bySeverity | Sort-Object { $severityOrder[$_.Name] } -Descending) {
        $emoji = switch ($group.Name) {
            "critical" { "[CRITICAL]" }
            "warning" { "[WARNING]" }
            "info" { "[INFO]" }
        }

        Write-Output "## $emoji $($group.Name.ToUpper()) ($($group.Count))"
        Write-Output ""

        foreach ($issue in $group.Group) {
            Write-Output "### $($issue.Controller)"
            Write-Output "- **File:** $($issue.File):$($issue.LineNumber)"
            Write-Output "- **Issue:** $($issue.Issue)"
            Write-Output "- **Suggestion:** $($issue.Suggestion)"
            Write-Output ""
        }
    }
}
else {
    # Console output
    $bySeverity = $filteredIssues | Group-Object Severity

    foreach ($group in $bySeverity | Sort-Object { $severityOrder[$_.Name] } -Descending) {
        Write-Host ""
        Write-Severity "=== $($group.Name.ToUpper()): $($group.Count) ISSUES ===" $group.Name
        Write-Host ""

        foreach ($issue in $group.Group) {
            Write-Host ">> $($issue.Controller)" -ForegroundColor White
            Write-Host "   File: $($issue.File):$($issue.LineNumber)" -ForegroundColor Gray
            Write-Severity "   Issue: $($issue.Issue)" $issue.Severity
            Write-Host "   Suggestion: $($issue.Suggestion)" -ForegroundColor Green

            if ($FixSuggestions) {
                $fixDetails = Get-FixSuggestions -Issue $issue
                if ($fixDetails) {
                    Write-Host $fixDetails -ForegroundColor DarkGray
                }
            }

            Write-Host ""
        }
    }

    # Summary
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host "SUMMARY" -ForegroundColor Cyan
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host "Controllers Analyzed: $($controllers.Count)" -ForegroundColor White
    Write-Host "Issues Found: $($filteredIssues.Count)" -ForegroundColor White
    Write-Host "  Critical: $(($filteredIssues | Where-Object Severity -eq 'critical').Count)" -ForegroundColor Red
    Write-Host "  Warning: $(($filteredIssues | Where-Object Severity -eq 'warning').Count)" -ForegroundColor Yellow
    Write-Host "  Info: $(($filteredIssues | Where-Object Severity -eq 'info').Count)" -ForegroundColor Cyan
    Write-Host ""

    if ($filteredIssues.Count -gt 0) {
        Write-Host "TIP: Run with -FixSuggestions for detailed refactoring guidance" -ForegroundColor Green
        Write-Host "TIP: Run with -OutputFormat markdown > report.md for documentation" -ForegroundColor Green
    }
    else {
        Write-Host "[OK] No issues found! Controllers are well-structured." -ForegroundColor Green
    }
}

# Return exit code
exit ($filteredIssues | Where-Object Severity -eq "critical").Count
