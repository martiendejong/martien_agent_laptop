# Tool Development Best Practices

**Last Updated:** 2026-01-25
**Based On:** 147 production tools across 3 waves
**Success Rate:** 100% (all tools production-ready)

---

## 🎯 Overview

This document captures proven patterns, conventions, and best practices learned from creating 147 automation tools as part of the Meta-Optimization project.

**Core Principle:** Every tool should save more time than it took to create.

---

## 📋 Tool Creation Checklist

### Phase 1: Planning
- [ ] Identify value/effort ratio (aim for > 4.0)
- [ ] Check if similar tool already exists
- [ ] Define clear parameters and use cases
- [ ] Plan output formats needed
- [ ] Consider CI/CD integration requirements

### Phase 2: Implementation
- [ ] Create PowerShell script with `.ps1` extension
- [ ] Add comprehensive comment-based help
- [ ] Implement usage tracking integration
- [ ] Add parameter validation
- [ ] Implement core functionality
- [ ] Add error handling
- [ ] Support multiple output formats

### Phase 3: Documentation
- [ ] Add inline comments for complex logic
- [ ] Create usage examples
- [ ] Update tools catalog
- [ ] Update main README if significant
- [ ] Document any dependencies

### Phase 4: Testing
- [ ] Test with sample inputs
- [ ] Verify error handling
- [ ] Test all output formats
- [ ] Validate CI/CD integration if applicable
- [ ] Check help documentation renders correctly

---

## 🏗️ Standard Tool Structure

### Template Pattern

```powershell
<#
.SYNOPSIS
    Brief one-line description (imperative form)

.DESCRIPTION
    Detailed description of what the tool does:
    - Key feature 1
    - Key feature 2
    - Key feature 3

.PARAMETER ParameterName
    Parameter description with valid values and defaults

.EXAMPLE
    .\tool-name.ps1 -Param1 "value"

    Description of what this example does

.EXAMPLE
    .\tool-name.ps1 -Param1 "value" -OutputFormat json

    Example with different output format

.NOTES
    Value: X/10 - Brief value justification
    Effort: Y/10 - Brief effort justification
    Ratio: Z.Z (TIER X)
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$RequiredParam,

    [Parameter(Mandatory=$false)]
    [ValidateSet('option1', 'option2', 'option3')]
    [string]$EnumParam = 'option1',

    [Parameter(Mandatory=$false)]
    [ValidateSet('table', 'json', 'html')]
    [string]$OutputFormat = 'table',

    [Parameter(Mandatory=$false)]
    [switch]$FailOnError
)

# AUTO-USAGE TRACKING (MANDATORY)
$toolName = $MyInvocation.MyCommand.Name -replace '\.ps1$', ''
. "$PSScriptRoot\_usage-logger.ps1" -ToolName $toolName -Action "execute" -Metadata @{ Parameters = ($PSBoundParameters.Keys -join ',') } -ErrorAction SilentlyContinue

# Header with tool name and key parameters
Write-Host "🔧 Tool Name" -ForegroundColor Cyan
Write-Host "  Param1: $RequiredParam" -ForegroundColor Gray
Write-Host "  Format: $OutputFormat" -ForegroundColor Gray
Write-Host ""

# Input validation
if (-not (Test-Path $RequiredParam)) {
    Write-Host "❌ Error: Path not found: $RequiredParam" -ForegroundColor Red
    exit 1
}

# Main logic
try {
    Write-Host "📋 Processing..." -ForegroundColor Yellow

    # Core functionality here
    $results = @()

    # Build results
    $result = [PSCustomObject]@{
        Property1 = "Value1"
        Property2 = "Value2"
        Status = "OK"
        Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    }
    $results += $result

    # Output formatting
    Write-Host ""
    Write-Host "RESULTS" -ForegroundColor Cyan
    Write-Host ""

    switch ($OutputFormat) {
        'table' {
            $results | Format-Table -AutoSize
        }
        'json' {
            $results | ConvertTo-Json -Depth 10
        }
        'html' {
            $html = $results | ConvertTo-Html -Fragment
            $html | Out-String
        }
    }

    # Summary
    Write-Host ""
    Write-Host "✅ Processing complete" -ForegroundColor Green
    Write-Host "  Total: $($results.Count) items" -ForegroundColor Gray

    # Exit code for CI/CD
    if ($FailOnError -and $errorCount -gt 0) {
        exit 1
    }

} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}
```

---

## 🎨 Naming Conventions

### Tool Names
**Pattern:** `<action>-<subject>.ps1`

**Good Examples:**
- `api-client-generator.ps1` - Generates API clients
- `database-backup-validator.ps1` - Validates backups
- `code-duplication-detector.ps1` - Detects duplicates
- `configuration-drift-detector.ps1` - Detects drift

**Bad Examples:**
- ❌ `tool1.ps1` - Not descriptive
- ❌ `helper.ps1` - Too generic
- ❌ `my-awesome-tool.ps1` - Subjective adjectives
- ❌ `API_Client_Generator.ps1` - Wrong casing

### Parameter Names
**Use PascalCase:** `-OutputPath`, `-PackageManager`, `-FailOnCritical`

**Common Parameters:**
- `-Path` - File or directory path
- `-OutputPath` - Output file/directory
- `-OutputFormat` - Output format (table/json/html/sarif)
- `-Recursive` - Recursive search
- `-FailOnError` / `-FailOnCritical` - CI/CD integration
- `-DryRun` - Preview mode
- `-Verbose` - Detailed output

### Variable Names
**Use camelCase:** `$toolName`, `$resultCount`, `$errorMessage`

---

## 📊 Output Format Standards

### Supported Formats

1. **table (Default)** - Human-readable terminal output
   ```powershell
   $results | Format-Table -AutoSize
   ```

2. **json** - Machine-readable, CI/CD integration
   ```powershell
   $results | ConvertTo-Json -Depth 10
   ```

3. **html** - Reports and documentation
   ```powershell
   $results | ConvertTo-Html -Fragment
   ```

4. **sarif** - Security tools, IDE integration
   ```powershell
   # SARIF 2.1.0 format
   @{
       version = "2.1.0"
       '$schema' = "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json"
       runs = @(...)
   } | ConvertTo-Json -Depth 20
   ```

### Format Selection Pattern

```powershell
switch ($OutputFormat) {
    'table' { $results | Format-Table -AutoSize }
    'json' { $results | ConvertTo-Json -Depth 10 }
    'html' {
        $html = $results | ConvertTo-Html -Fragment -PreContent "<h2>Report Title</h2>"
        $html | Out-String
    }
    'sarif' {
        # Build SARIF structure
        $sarif = @{...}
        $sarif | ConvertTo-Json -Depth 20
    }
}
```

---

## 🎯 Parameter Validation Patterns

### Mandatory Parameters
```powershell
[Parameter(Mandatory=$true)]
[string]$SpecFile
```

### Enum Validation
```powershell
[Parameter(Mandatory=$false)]
[ValidateSet('nuget', 'npm', 'pip', 'maven')]
[string]$PackageManager = 'nuget'
```

### Path Validation
```powershell
[Parameter(Mandatory=$true)]
[ValidateScript({Test-Path $_ -PathType 'Container'})]
[string]$ProjectPath
```

### Range Validation
```powershell
[Parameter(Mandatory=$false)]
[ValidateRange(1, 100)]
[int]$SimilarityThreshold = 80
```

### Pattern Validation
```powershell
[Parameter(Mandatory=$false)]
[ValidatePattern('^[a-z0-9-]+$')]
[string]$BranchName
```

---

## 🔍 Error Handling Patterns

### Try-Catch with Detailed Errors
```powershell
try {
    # Risky operation
    $result = Invoke-SomeCommand

} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray

    # Log error for usage tracking
    . "$PSScriptRoot\_usage-logger.ps1" -ToolName $toolName -Action "error" -Metadata @{ Error = $_.Exception.Message }

    exit 1
}
```

### Input Validation
```powershell
if (-not (Test-Path $SpecFile)) {
    Write-Host "❌ Spec file not found: $SpecFile" -ForegroundColor Red
    exit 1
}

if ($SimilarityThreshold -lt 0 -or $SimilarityThreshold -gt 100) {
    Write-Host "❌ Similarity threshold must be 0-100" -ForegroundColor Red
    exit 1
}
```

### Graceful Degradation
```powershell
# Try preferred tool, fall back to alternative
$dotnetAvailable = Get-Command dotnet -ErrorAction SilentlyContinue
if ($dotnetAvailable) {
    dotnet format
} else {
    Write-Host "⚠️ dotnet not found, using PowerShell formatter" -ForegroundColor Yellow
    # Fallback implementation
}
```

---

## 📝 Usage Tracking Integration

### Standard Pattern (MANDATORY)

```powershell
# At the top of every tool, immediately after param block
$toolName = $MyInvocation.MyCommand.Name -replace '\.ps1$', ''
. "$PSScriptRoot\_usage-logger.ps1" -ToolName $toolName -Action "execute" -Metadata @{ Parameters = ($PSBoundParameters.Keys -join ',') } -ErrorAction SilentlyContinue
```

### Advanced Tracking

```powershell
# Track specific events
. "$PSScriptRoot\_usage-logger.ps1" -ToolName $toolName -Action "generate" -Metadata @{
    FileCount = $fileCount
    OutputFormat = $OutputFormat
    Duration = $duration
}

# Track errors
. "$PSScriptRoot\_usage-logger.ps1" -ToolName $toolName -Action "error" -Metadata @{
    Error = $_.Exception.Message
    Step = "file-processing"
}
```

---

## 🎨 User Experience Patterns

### Consistent Headers
```powershell
Write-Host "🔧 Tool Name" -ForegroundColor Cyan
Write-Host "  Key Param: $value" -ForegroundColor Gray
Write-Host ""
```

### Progress Indication
```powershell
Write-Host "📋 Scanning files..." -ForegroundColor Yellow
Write-Host "  Found: $fileCount files" -ForegroundColor Gray
Write-Host "  Analyzing..." -ForegroundColor Gray
```

### Status Icons
- 🔧 Tool name/header
- 📋 Processing/scanning
- ✅ Success
- ❌ Error/failure
- ⚠️ Warning
- 📊 Results/summary
- 💡 Tips/recommendations

### Color Coding
- **Cyan** - Headers, section titles
- **Gray** - Details, metadata
- **Yellow** - Progress, in-progress
- **Green** - Success, completion
- **Red** - Errors, failures
- **Magenta** - Important warnings

### Summary Sections
```powershell
Write-Host ""
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total Scanned:  $totalCount" -ForegroundColor Gray
Write-Host "Issues Found:   $issueCount" -ForegroundColor $(if ($issueCount -gt 0) { "Red" } else { "Green" })
Write-Host "Warnings:       $warningCount" -ForegroundColor Yellow
Write-Host ""
Write-Host "✅ Scan complete" -ForegroundColor Green
```

---

## 🚀 CI/CD Integration Patterns

### Fail Build Option
```powershell
[Parameter(Mandatory=$false)]
[switch]$FailOnCritical

# Later in code
if ($FailOnCritical -and $criticalCount -gt 0) {
    Write-Host ""
    Write-Host "❌ Build failed: $criticalCount critical issue(s) found" -ForegroundColor Red
    exit 1
}
```

### Exit Codes
```powershell
# Success
exit 0

# Failure (errors found)
exit 1

# Warning (non-critical issues)
exit 2  # Optional, some CI systems treat any non-zero as failure
```

### Machine-Readable Output
```powershell
if ($OutputFormat -eq 'json') {
    # Ensure valid JSON with all necessary fields
    @{
        success = $true
        totalScanned = $totalCount
        issuesFound = $issueCount
        criticalIssues = $criticalCount
        results = $results
    } | ConvertTo-Json -Depth 10
}
```

---

## 🧪 Testing Patterns

### Dry Run Support
```powershell
[Parameter(Mandatory=$false)]
[switch]$DryRun

if ($DryRun) {
    Write-Host "🔍 DRY RUN MODE - No changes will be made" -ForegroundColor Magenta
    Write-Host ""
}

# Later
if (-not $DryRun) {
    # Perform actual changes
    Set-Content -Path $file -Value $content
} else {
    Write-Host "  Would write to: $file" -ForegroundColor Gray
}
```

### Example Data
```powershell
# Include example usage in help
<#
.EXAMPLE
    .\tool-name.ps1 -Path "C:\Projects\myapp" -Recursive

    Scans all files in C:\Projects\myapp and subdirectories

.EXAMPLE
    .\tool-name.ps1 -Path . -OutputFormat json | Out-File results.json

    Scans current directory and saves results as JSON
#>
```

---

## 📚 Documentation Patterns

### Comment-Based Help
```powershell
<#
.SYNOPSIS
    One-line description in imperative form

.DESCRIPTION
    Multi-paragraph detailed description.

    Explain:
    - What the tool does
    - Why it's useful
    - Key features
    - Limitations or requirements

.PARAMETER ParameterName
    Detailed parameter description.
    Valid values: option1, option2, option3
    Default: option1

.EXAMPLE
    .\tool-name.ps1 -Param "value"

    Description of what this example demonstrates

.NOTES
    Value: 8/10 - Saves 30 minutes per incident
    Effort: 2/10 - Template-based generation
    Ratio: 4.0 (TIER A)

    Requirements:
    - PowerShell 7+
    - External tool (if applicable)

    See also:
    - Related tool name
#>
```

### Inline Comments
```powershell
# Complex algorithm - explain why, not what
# Using token-based comparison instead of line-based because:
# 1. Language-agnostic (works for all languages)
# 2. Whitespace insensitive (formatting doesn't affect detection)
# 3. More accurate similarity scoring
$tokens = Get-Tokens -Content $fileContent
```

---

## 🔄 Common Algorithms & Patterns

### File Processing
```powershell
# Get all matching files
$files = Get-ChildItem -Path $Path -Filter "*.cs" -Recurse:$Recursive

# Process with progress
$fileCount = $files.Count
$processed = 0

foreach ($file in $files) {
    $processed++
    Write-Progress -Activity "Processing files" -Status "$processed of $fileCount" -PercentComplete (($processed / $fileCount) * 100)

    # Process file
    $content = Get-Content $file.FullName -Raw
    # ... processing logic
}

Write-Progress -Activity "Processing files" -Completed
```

### JSON Parsing
```powershell
# Safe JSON parsing with error handling
try {
    $data = Get-Content $JsonFile -Raw | ConvertFrom-Json
} catch {
    Write-Host "❌ Invalid JSON in file: $JsonFile" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Gray
    exit 1
}
```

### API Calls
```powershell
# External API with error handling and retries
$maxRetries = 3
$retryCount = 0

while ($retryCount -lt $maxRetries) {
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers
        break
    } catch {
        $retryCount++
        if ($retryCount -ge $maxRetries) {
            Write-Host "❌ API call failed after $maxRetries attempts" -ForegroundColor Red
            throw
        }
        Start-Sleep -Seconds (2 * $retryCount)
    }
}
```

### Regex Patterns
```powershell
# Common patterns used across tools

# Email
$emailPattern = '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'

# Credit card
$ccPattern = '\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'

# API key (generic)
$apiKeyPattern = '(?i)(api[_-]?key|apikey|access[_-]?token)\s*[:=]\s*[''"]?([a-zA-Z0-9_-]{20,})'

# URL
$urlPattern = 'https?://[a-zA-Z0-9.-]+(?:/[a-zA-Z0-9./_-]*)?'

# Semantic version
$semverPattern = '\d+\.\d+\.\d+(?:-[a-zA-Z0-9.-]+)?(?:\+[a-zA-Z0-9.-]+)?'
```

---

## 🎯 Value/Effort Ratio Guidelines

### High Value Indicators (8-10)
- Prevents critical production incidents
- Saves 30+ minutes per use
- Automates error-prone manual process
- Legal/compliance requirement
- Eliminates entire category of bugs

### Medium Value Indicators (5-7)
- Saves 15-30 minutes per use
- Improves code quality significantly
- Provides actionable insights
- Reduces cognitive load

### Low Value Indicators (1-4)
- Saves < 15 minutes per use
- Nice-to-have convenience
- Limited use cases
- Niche scenarios

### Low Effort Indicators (1-3)
- Template-based generation
- Simple file operations
- Basic parsing/validation
- Uses existing tools/libraries

### Medium Effort Indicators (4-6)
- Complex algorithm required
- Multiple integrations
- Significant error handling
- Performance optimization needed

### High Effort Indicators (7-10)
- Novel algorithm development
- Deep integration with multiple systems
- Extensive testing required
- Ongoing maintenance burden

---

## 🏆 Success Metrics

### Tool Quality Checklist

A production-ready tool must have:

1. ✅ **Functional completeness** - Does what it claims to do
2. ✅ **Error handling** - Graceful failure with clear messages
3. ✅ **Documentation** - Complete help with examples
4. ✅ **Usage tracking** - Integrated with _usage-logger.ps1
5. ✅ **Output formats** - At least table and JSON
6. ✅ **Parameter validation** - Prevents invalid input
7. ✅ **CI/CD ready** - Exit codes and fail options
8. ✅ **Consistent UX** - Follows color/icon conventions

### Performance Targets

- **Startup time:** < 2 seconds for simple tools
- **Processing time:** Proportional to input size (show progress for > 5 seconds)
- **Memory usage:** < 500 MB for typical workloads
- **Error rate:** < 1% on valid inputs

---

## 🎓 Lessons Learned

### What Works Well

1. **Template-Based Creation** - Starting from a template ensures consistency
2. **Batch Creation** - Similar tools can be created together
3. **Early Usage Tracking** - Enables data-driven prioritization
4. **Multiple Output Formats** - Increases versatility
5. **Fail-Fast Validation** - Check inputs before processing
6. **Clear Naming** - Action-subject pattern is intuitive

### Common Pitfalls

1. ❌ **Over-Engineering** - Don't add features "just in case"
2. ❌ **Poor Error Messages** - "Error occurred" is not helpful
3. ❌ **Missing Examples** - Users need concrete usage examples
4. ❌ **Hardcoded Paths** - Use parameters or configuration
5. ❌ **Silent Failures** - Always indicate success/failure
6. ❌ **Inconsistent Naming** - Stick to conventions

### Best Practices from 147 Tools

1. **Start Simple** - Core functionality first, refinements later
2. **Test Early** - Run with real data during development
3. **Document As You Go** - Don't leave it for later
4. **Use Existing Patterns** - Copy from similar successful tools
5. **Think CI/CD** - Consider automation from the start
6. **Plan for Errors** - What can go wrong?
7. **Show Progress** - Users appreciate feedback on long operations

---

## 📖 Related Documentation

- **Tools Catalog:** `C:\scripts\_machine\TOOLS_CATALOG.md`
- **Wave 3 Report:** `C:\scripts\_machine\WAVE_3_COMPLETION_REPORT.md`
- **Meta-Optimization Progress:** `C:\scripts\_machine\META_OPTIMIZATION_PROGRESS.md`
- **Main Documentation:** `C:\scripts\CLAUDE.md`

---

**Created:** 2026-01-25
**Based On:** 147 production tools (Waves 1-3)
**Maintained By:** Claude Agent (Continuous improvement protocol)
**Status:** Living document - updated as patterns emerge
