#!/usr/bin/env pwsh
# pattern-detector.ps1 - Continuous pattern monitoring
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
    [switch]$AutoAddToQueue = $false
)

if (-not (Test-Path $SessionLogPath)) {
    Write-Verbose "No session log found - pattern detection skipped"
    exit 0
}

# Load session log
$logEntries = Get-Content $SessionLogPath | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
    $_ | ConvertFrom-Json
}

if ($logEntries.Count -eq 0) {
    Write-Verbose "Session log empty - pattern detection skipped"
    exit 0
}

Write-Host ""
Write-Host "🔍 PATTERN DETECTION (Threshold: ${ActionThreshold}x)" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta
Write-Host ""

$patternsDetected = $false

# Detect repeated actions
$actionFreq = $logEntries | Group-Object -Property action | Sort-Object Count -Descending
$repeatedActions = $actionFreq | Where-Object { $_.Count -ge $ActionThreshold }

if ($repeatedActions) {
    $patternsDetected = $true
    Write-Host "🤖 Repeated Actions (automation candidates):" -ForegroundColor Yellow

    foreach ($action in $repeatedActions) {
        Write-Host "   • $($action.Name) - occurred $($action.Count) times" -ForegroundColor Yellow

        # Suggest automation type based on action
        $suggestedType = "automation"
        if ($action.Name -like "*Read*" -or $action.Name -like "*lookup*") {
            $suggestedType = "documentation"
            Write-Host "     Suggestion: Create quick-reference entry" -ForegroundColor Cyan
        }
        elseif ($action.Name -like "*workflow*" -or $action.Name -like "*sequence*") {
            $suggestedType = "skill"
            Write-Host "     Suggestion: Create Skill for this workflow" -ForegroundColor Cyan
        }
        else {
            Write-Host "     Suggestion: Create automation tool" -ForegroundColor Cyan
        }

        # Auto-add to learning queue if enabled
        if ($AutoAddToQueue) {
            $roi = [math]::Min(10.0, $action.Count * 2.5)  # Simple ROI estimate
            & "C:\scripts\tools\learning-queue.ps1" -Action add `
                -Type $suggestedType `
                -Description "Automate: $($action.Name)" `
                -Frequency $action.Count `
                -Risk "MEDIUM" `
                -RoiEstimate $roi
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

            # Auto-add to learning queue if enabled
            if ($AutoAddToQueue) {
                & "C:\scripts\tools\learning-queue.ps1" -Action add `
                    -Type "instruction" `
                    -Description "Update instructions to prevent: $($error.Name)" `
                    -Frequency $error.Count `
                    -Risk "LOW" `
                    -RoiEstimate 9.0
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
            Write-Host "   • $($lookup.Name) - accessed $($lookup.Count) times" -ForegroundColor Cyan
            Write-Host "     Suggestion: Create quick-reference entry for this topic" -ForegroundColor Yellow

            # Auto-add to learning queue if enabled
            if ($AutoAddToQueue) {
                $roi = [math]::Min(10.0, $lookup.Count * 1.5)
                & "C:\scripts\tools\learning-queue.ps1" -Action add `
                    -Type "documentation" `
                    -Description "Quick-ref for: $($lookup.Name)" `
                    -Frequency $lookup.Count `
                    -Risk "LOW" `
                    -RoiEstimate $roi
            }
        }
        Write-Host ""
    }
}

# Summary
if (-not $patternsDetected) {
    Write-Host "✅ No significant patterns detected (session appears optimal)" -ForegroundColor Green
    Write-Host ""
}
else {
    Write-Host "💡 Next Steps:" -ForegroundColor Magenta
    if ($AutoAddToQueue) {
        Write-Host "   • Items added to learning queue automatically" -ForegroundColor Cyan
        Write-Host "   • Run: learning-queue.ps1 -Action list" -ForegroundColor Cyan
    }
    else {
        Write-Host "   • Run with -AutoAddToQueue to add patterns to learning queue" -ForegroundColor Cyan
        Write-Host "   • Or manually create improvements using detected patterns" -ForegroundColor Cyan
    }
    Write-Host ""
}

# Return detected patterns for programmatic use
return @{
    RepeatedActions = $repeatedActions.Count
    CriticalErrors = if ($criticalErrors) { $criticalErrors.Count } else { 0 }
    FrequentLookups = if ($frequentLookups) { $frequentLookups.Count } else { 0 }
    PatternsDetected = $patternsDetected
}
