#!/usr/bin/env pwsh
# pattern-detector.ps1 - Continuous pattern monitoring with AUTO-EXECUTION
# Part of Embedded Learning Architecture
# Run automatically every 10 actions during session

param(
    [Parameter(Mandatory=$false)]
    [string]$SessionLogPath = "C:\scripts\_machine\current-session-log.jsonl",

    [Parameter(Mandatory=$false)]
    [int]$ActionThreshold = 3,

    [Parameter(Mandatory=$false)]
    [int]$ErrorThreshold = 2,

    [Parameter(Mandatory=$false)]
    [switch]$AutoAddToQueue = $false,

    [Parameter(Mandatory=$false)]
    [switch]$ExecuteLowRisk = $false
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $SessionLogPath)) {
    Write-Verbose "No session log found - pattern detection skipped"
    exit 0
}

# Load session log
$logEntries = Get-Content $SessionLogPath -Raw -ErrorAction SilentlyContinue
if (-not $logEntries -or $logEntries.Trim() -eq "") {
    Write-Verbose "Session log empty - pattern detection skipped"
    exit 0
}

$logEntries = $logEntries -split "`n" | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
    $_ | ConvertFrom-Json
}

if ($logEntries.Count -eq 0) {
    Write-Verbose "Session log empty - pattern detection skipped"
    exit 0
}

Write-Host ""
Write-Host "🔍 PATTERN DETECTION (Threshold: ${ActionThreshold}x)" -ForegroundColor Magenta
if ($ExecuteLowRisk) {
    Write-Host "⚡ AUTO-EXECUTION ENABLED (LOW risk items will be implemented)" -ForegroundColor Green
}
Write-Host "================================================" -ForegroundColor Magenta
Write-Host ""

$patternsDetected = $false
$executedImprovements = @()

#region Execution Functions

function Execute-QuickRefCreation {
    param(
        [string]$Action,
        [int]$Frequency,
        [array]$LogEntries
    )

    # Extract what file/topic is being read repeatedly
    if ($Action -match "Read (.+)") {
        $fileName = $Matches[1].Trim()

        # Get all entries for this action to understand context
        $relatedEntries = $LogEntries | Where-Object { $_.action -eq $Action }
        $contexts = $relatedEntries | Select-Object -ExpandProperty reasoning | Where-Object { $_ }

        $quickRefPath = "C:\scripts\_machine\quick-refs\$($fileName -replace '\.md$', '')-QUICKREF.md"
        $quickRefDir = Split-Path $quickRefPath -Parent

        if (-not (Test-Path $quickRefDir)) {
            New-Item -ItemType Directory -Path $quickRefDir -Force | Out-Null
        }

        $content = @"
# Quick Reference: $fileName

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm")
**Reason:** This file was accessed ${Frequency}x in one session
**Common lookups:**
$(($contexts | ForEach-Object { "- $_" }) -join "`n")

---

## Frequently Referenced Sections

> **Note:** This is an auto-generated quick reference. Update manually as needed.
> Original file: ``$fileName``

### Common Patterns

$(if ($fileName -like "*CLAUDE.md*") {
@"
- Worktree workflow: See worktree-workflow.md
- PR creation: Always use ``develop`` as base branch
- Mode detection: ClickUp task = Feature Mode
- Zero tolerance rules: Check ZERO_TOLERANCE_RULES.md first
"@
} elseif ($fileName -like "*API*") {
@"
- JWT setup: Check knowledge-base/secrets for API keys
- Authentication flow: Bearer token in Authorization header
- Error handling: Use try-catch with proper logging
"@
} else {
    "- Add frequently referenced patterns here"
})

---

**Next time you need info from $fileName, check this quick-ref first!**
"@

        $content | Out-File -FilePath $quickRefPath -Encoding utf8 -Force

        return @{
            Success = $true
            Path = $quickRefPath
            Description = "Created quick-ref for $fileName (accessed ${Frequency}x)"
        }
    }

    return @{ Success = $false }
}

function Execute-InstructionUpdate {
    param(
        [string]$ErrorAction,
        [int]$Frequency,
        [array]$LogEntries
    )

    # Get error details
    $errorEntries = $LogEntries | Where-Object { $_.action -eq $ErrorAction -and ($_.outcome -like "*error*" -or $_.outcome -like "*fail*") }
    $errorReasons = $errorEntries | Select-Object -ExpandProperty reasoning | Where-Object { $_ }
    $errorOutcomes = $errorEntries | Select-Object -ExpandProperty outcome | Where-Object { $_ }

    $lessonPath = "C:\scripts\_machine\learned-lessons.md"

    if (-not (Test-Path $lessonPath)) {
        "# Learned Lessons (Auto-Generated)`n`n" | Out-File -FilePath $lessonPath -Encoding utf8
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $lesson = @"

## $timestamp - Repeated Error: $ErrorAction

**Frequency:** Failed ${Frequency}x in one session
**Context:**
$(($errorReasons | ForEach-Object { "- $_" }) -join "`n")

**Error Details:**
$(($errorOutcomes | ForEach-Object { "- $_" }) -join "`n")

**Action Taken:**
- [ ] Update CLAUDE.md with prevention protocol
- [ ] Create verification step in workflow
- [ ] Add to behavior tests

**Prevention Protocol:**
1. Before running ``$ErrorAction``: Check prerequisites
2. Common causes to verify first
3. If error persists: Document root cause

---

"@

    $lesson | Out-File -FilePath $lessonPath -Append -Encoding utf8

    return @{
        Success = $true
        Path = $lessonPath
        Description = "Logged lesson for repeated error: $ErrorAction (${Frequency}x)"
    }
}

function Execute-HelperScript {
    param(
        [string]$Action,
        [int]$Frequency
    )

    # Create simple helper script for repeated actions
    $scriptName = ($Action -replace '[^a-zA-Z0-9]', '-').ToLower()
    $scriptPath = "C:\scripts\tools\helpers\$scriptName.ps1"
    $scriptDir = Split-Path $scriptPath -Parent

    if (-not (Test-Path $scriptDir)) {
        New-Item -ItemType Directory -Path $scriptDir -Force | Out-Null
    }

    $content = @"
#!/usr/bin/env pwsh
# Auto-generated helper script for: $Action
# Created: $(Get-Date -Format "yyyy-MM-dd HH:mm")
# Reason: Action performed ${Frequency}x in one session

# TODO: Implement the actual logic for: $Action
# This is a placeholder - customize based on your needs

Write-Host "🔧 Running: $Action" -ForegroundColor Cyan
# Add your implementation here

Write-Host "✅ Completed: $Action" -ForegroundColor Green
"@

    $content | Out-File -FilePath $scriptPath -Encoding utf8 -Force

    return @{
        Success = $true
        Path = $scriptPath
        Description = "Created helper script for: $Action (performed ${Frequency}x)"
    }
}

#endregion

#region Pattern Detection

# Detect repeated actions
$actionFreq = $logEntries | Group-Object -Property action | Sort-Object Count -Descending
$repeatedActions = $actionFreq | Where-Object { $_.Count -ge $ActionThreshold }

if ($repeatedActions) {
    $patternsDetected = $true
    Write-Host "🤖 Repeated Actions (automation candidates):" -ForegroundColor Yellow

    foreach ($action in $repeatedActions) {
        Write-Host "   • $($action.Name) - occurred $($action.Count) times" -ForegroundColor Yellow

        # Assess risk and determine action type
        $risk = "MEDIUM"
        $suggestedType = "automation"
        $canAutoExecute = $false

        if ($action.Name -like "*Read*" -or $action.Name -like "*lookup*" -or $action.Name -like "*Grep*") {
            $suggestedType = "documentation"
            $risk = "LOW"
            $canAutoExecute = $true
            Write-Host "     Suggestion: Create quick-reference entry" -ForegroundColor Cyan
            Write-Host "     Risk: $risk (can auto-execute)" -ForegroundColor Green
        }
        elseif ($action.Name -like "*workflow*" -or $action.Name -like "*sequence*") {
            $suggestedType = "skill"
            $risk = "MEDIUM"
            Write-Host "     Suggestion: Create Skill for this workflow" -ForegroundColor Cyan
            Write-Host "     Risk: $risk (queue for review)" -ForegroundColor Yellow
        }
        else {
            Write-Host "     Suggestion: Create automation tool" -ForegroundColor Cyan
            Write-Host "     Risk: $risk (queue for review)" -ForegroundColor Yellow
        }

        # Execute LOW risk items if flag enabled
        if ($ExecuteLowRisk -and $canAutoExecute -and $risk -eq "LOW") {
            Write-Host "     ⚡ EXECUTING: Creating quick-ref..." -ForegroundColor Green
            $result = Execute-QuickRefCreation -Action $action.Name -Frequency $action.Count -LogEntries $logEntries

            if ($result.Success) {
                Write-Host "     ✅ CREATED: $($result.Path)" -ForegroundColor Green
                $executedImprovements += $result
            } else {
                Write-Host "     ⚠️  Could not auto-create (manual intervention needed)" -ForegroundColor Yellow
            }
        }

        # Auto-add to learning queue if enabled
        if ($AutoAddToQueue) {
            $roi = [math]::Min(10.0, $action.Count * 2.5)
            & "C:\scripts\tools\learning-queue.ps1" -Action add `
                -Type $suggestedType `
                -Description "Automate: $($action.Name)" `
                -Frequency $action.Count `
                -Risk $risk `
                -RoiEstimate $roi 2>$null
        }
    }
    Write-Host ""
}

# Detect repeated errors
$errors = $logEntries | Where-Object { $_.outcome -like "*error*" -or $_.outcome -like "*fail*" }
if ($errors) {
    $errorFreq = $errors | Group-Object -Property action | Sort-Object Count -Descending
    $criticalErrors = $errorFreq | Where-Object { $_.Count -ge $ErrorThreshold }

    if ($criticalErrors) {
        $patternsDetected = $true
        Write-Host "🚨 CRITICAL: Repeated Errors (update instructions NOW):" -ForegroundColor Red

        foreach ($error in $criticalErrors) {
            Write-Host "   • $($error.Name) - failed $($error.Count) times" -ForegroundColor Red
            Write-Host "     ACTION REQUIRED: Update CLAUDE.md to prevent this error" -ForegroundColor Yellow
            Write-Host "     Risk: LOW (can auto-document)" -ForegroundColor Green

            # Execute: Log the lesson
            if ($ExecuteLowRisk) {
                Write-Host "     ⚡ EXECUTING: Documenting lesson..." -ForegroundColor Green
                $result = Execute-InstructionUpdate -ErrorAction $error.Name -Frequency $error.Count -LogEntries $logEntries

                if ($result.Success) {
                    Write-Host "     ✅ LOGGED: $($result.Path)" -ForegroundColor Green
                    $executedImprovements += $result
                } else {
                    Write-Host "     ⚠️  Could not auto-document" -ForegroundColor Yellow
                }
            }

            # Auto-add to learning queue if enabled
            if ($AutoAddToQueue) {
                & "C:\scripts\tools\learning-queue.ps1" -Action add `
                    -Type "instruction" `
                    -Description "Update instructions to prevent: $($error.Name)" `
                    -Frequency $error.Count `
                    -Risk "LOW" `
                    -RoiEstimate 9.0 2>$null
            }
        }
        Write-Host ""
    }
}

# Detect documentation lookups
$docLookups = $logEntries | Where-Object { $_.action -like "*Read*" -or $_.action -like "*Grep*" -or $_.action -like "*search*" }
if ($docLookups) {
    $docFreq = $docLookups | Group-Object -Property action | Sort-Object Count -Descending
    $frequentLookups = $docFreq | Where-Object { $_.Count -ge $ActionThreshold }

    if ($frequentLookups) {
        $patternsDetected = $true
        Write-Host "📚 Frequent Documentation Lookups (create quick-ref):" -ForegroundColor Cyan

        foreach ($lookup in $frequentLookups) {
            # Skip if already processed in repeated actions
            if ($repeatedActions.Name -contains $lookup.Name) {
                continue
            }

            Write-Host "   • $($lookup.Name) - accessed $($lookup.Count) times" -ForegroundColor Cyan
            Write-Host "     Suggestion: Create quick-reference entry for this topic" -ForegroundColor Yellow
            Write-Host "     Risk: LOW (can auto-execute)" -ForegroundColor Green

            # Execute if flag enabled
            if ($ExecuteLowRisk) {
                Write-Host "     ⚡ EXECUTING: Creating quick-ref..." -ForegroundColor Green
                $result = Execute-QuickRefCreation -Action $lookup.Name -Frequency $lookup.Count -LogEntries $logEntries

                if ($result.Success) {
                    Write-Host "     ✅ CREATED: $($result.Path)" -ForegroundColor Green
                    $executedImprovements += $result
                }
            }

            # Auto-add to learning queue if enabled
            if ($AutoAddToQueue) {
                $roi = [math]::Min(10.0, $lookup.Count * 1.5)
                & "C:\scripts\tools\learning-queue.ps1" -Action add `
                    -Type "documentation" `
                    -Description "Quick-ref for: $($lookup.Name)" `
                    -Frequency $lookup.Count `
                    -Risk "LOW" `
                    -RoiEstimate $roi 2>$null
            }
        }
        Write-Host ""
    }
}

#endregion

#region Summary

if (-not $patternsDetected) {
    Write-Host "✅ No significant patterns detected (session appears optimal)" -ForegroundColor Green
    Write-Host ""
}
else {
    Write-Host "💡 Next Steps:" -ForegroundColor Magenta

    if ($executedImprovements.Count -gt 0) {
        Write-Host "   ✅ AUTO-EXECUTED $($executedImprovements.Count) LOW RISK IMPROVEMENTS:" -ForegroundColor Green
        foreach ($improvement in $executedImprovements) {
            Write-Host "      • $($improvement.Description)" -ForegroundColor Green
        }
        Write-Host ""
    }

    if ($AutoAddToQueue) {
        Write-Host "   • Items added to learning queue automatically" -ForegroundColor Cyan
        Write-Host "   • Run: learning-queue.ps1 -Action list" -ForegroundColor Cyan
    }
    else {
        Write-Host "   • Run with -AutoAddToQueue to add patterns to learning queue" -ForegroundColor Cyan
    }

    if (-not $ExecuteLowRisk) {
        Write-Host "   • Run with -ExecuteLowRisk to AUTO-IMPLEMENT low risk improvements" -ForegroundColor Cyan
    }

    Write-Host ""
}

#endregion

# Return detected patterns for programmatic use
return @{
    RepeatedActions = if ($repeatedActions) { $repeatedActions.Count } else { 0 }
    CriticalErrors = if ($criticalErrors) { $criticalErrors.Count } else { 0 }
    FrequentLookups = if ($frequentLookups) { $frequentLookups.Count } else { 0 }
    PatternsDetected = $patternsDetected
    ExecutedImprovements = $executedImprovements.Count
    Improvements = $executedImprovements
}
