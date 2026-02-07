# Auto-Documentation Updater
# Automatically maintains documentation when system changes
# Created: 2026-02-07 (Iteration #12 - Auto-maintenance)

<#
.SYNOPSIS
    Auto-Documentation Updater

.DESCRIPTION
    Auto-Documentation Updater

.NOTES
    File: auto-doc-update.ps1
    Auto-generated help documentation
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('scan', 'update', 'verify')]
    [string]$Action = 'scan',

    [Parameter(Mandatory=$false)]
    [string]$SpecificDoc
)

$ErrorActionPreference = "Stop"

# Paths
$toolsDir = "C:\scripts\tools"
$docsToMaintain = @{
    "SESSION_MANAGER.md" = "C:\scripts\SESSION_MANAGER.md"
    "AUTO_STARTUP.md" = "C:\scripts\agentidentity\AUTO_STARTUP.md"
    "MEMORY.md" = "C:\Users\HP\.claude\projects\C--scripts\memory\MEMORY.md"
    "SYSTEM_INDEX.md" = "C:\scripts\SYSTEM_INDEX.md"
}

function Get-ToolInventory {
    $tools = Get-ChildItem "$toolsDir\*.ps1" -File | ForEach-Object {
        $content = Get-Content $_.FullName -Raw

        # Extract purpose from header comment
        $purpose = if ($content -match "(?m)^# (.+?)$") {
            $matches[1]
        } else {
            "No description"
        }

        # Extract created date
        $created = if ($content -match "Created: (.+)") {
            $matches[1]
        } else {
            "Unknown"
        }

        @{
            name = $_.BaseName
            file = $_.Name
            purpose = $purpose
            created = $created
            size_kb = [math]::Round($_.Length / 1KB, 2)
            last_modified = $_.LastWriteTime
        }
    }
    return $tools
}

function Get-DocumentationState {
    param($DocPath)

    if (-not (Test-Path $DocPath)) {
        return @{ exists = $false; tools_mentioned = @() }
    }

    $content = Get-Content $DocPath -Raw
    $toolsMentioned = @()

    # Find all .ps1 file mentions
    if ($content -match "(?m)(\w+\.ps1)") {
        $toolsMentioned = [regex]::Matches($content, "(\w+)\.ps1") | ForEach-Object { $_.Groups[1].Value }
    }

    return @{
        exists = $true
        tools_mentioned = $toolsMentioned
        size_kb = [math]::Round((Get-Item $DocPath).Length / 1KB, 2)
        last_modified = (Get-Item $DocPath).LastWriteTime
    }
}

function Update-SessionManagerDoc {
    param($Tools)

    $docPath = $docsToMaintain["SESSION_MANAGER.md"]

    if (-not (Test-Path $docPath)) {
        Write-Host "[WARN] SESSION_MANAGER.md not found, skipping" -ForegroundColor Yellow
        return
    }

    # Build tool reference section
    $toolReference = @"
## Tool Reference

All tools located in ``C:\scripts\tools\``:

"@

    foreach ($tool in $Tools | Sort-Object name) {
        $toolReference += "`n### $($tool.name).ps1`n"
        $toolReference += "- **Purpose:** $($tool.purpose)`n"
        $toolReference += "- **Created:** $($tool.created)`n"
        $toolReference += "- **Size:** $($tool.size_kb) KB`n"
        $toolReference += "`n"
    }

    # Read existing doc
    $content = Get-Content $docPath -Raw

    # Find where Tool Reference section starts
    $toolRefIndex = $content.IndexOf("## Tool Reference")

    if ($toolRefIndex -ge 0) {
        # Remove everything from Tool Reference to end of file
        $content = $content.Substring(0, $toolRefIndex).TrimEnd()
    }

    # Append new Tool Reference section at the end
    $content = $content + "`n`n$toolReference"

    # Update timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $content = $content -replace "Last Updated:.*", "Last Updated: $timestamp (auto-updated)"

    Set-Content $docPath -Value $content -Encoding UTF8
    Write-Host "[OK] Updated SESSION_MANAGER.md with $($Tools.Count) tools" -ForegroundColor Green
}

function Update-MemoryDoc {
    param($Tools)

    $docPath = $docsToMaintain["MEMORY.md"]

    if (-not (Test-Path $docPath)) {
        Write-Host "[WARN] MEMORY.md not found, skipping" -ForegroundColor Yellow
        return
    }

    # Read current content
    $content = Get-Content $docPath -Raw

    # Update timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm UTC"
    $content = $content -replace "\*\*Last Updated:\*\* [\d\-]+ [\d:]+ UTC", "**Last Updated:** $timestamp"

    # Add tool count note if not present
    $toolCount = $Tools.Count
    $toolNote = "**System metrics (auto-updated):** $toolCount tools, $(([math]::Round((Get-ChildItem 'C:\scripts\tools\*.ps1' | Measure-Object Length -Sum).Sum / 1KB, 0))) KB total"

    if ($content -notmatch "System metrics \(auto-updated\)") {
        # Add before "Last Updated" line
        $content = $content -replace "(\*\*Last Updated:\*\*)", "$toolNote`n`n`$1"
    } else {
        # Update existing line
        $content = $content -replace "\*\*System metrics \(auto-updated\):\*\*[^\n]+", $toolNote
    }

    Set-Content $docPath -Value $content -Encoding UTF8
    Write-Host "[OK] Updated MEMORY.md timestamp and metrics" -ForegroundColor Green
}

function Show-ScanResults {
    param($Tools, $Docs)

    Write-Host ""
    Write-Host "=== AUTO-DOCUMENTATION SCAN ===" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "TOOLS INVENTORY:" -ForegroundColor Yellow
    Write-Host "  Total tools: $($Tools.Count)" -ForegroundColor White
    Write-Host ""

    foreach ($tool in $Tools | Sort-Object name) {
        Write-Host "  - $($tool.name).ps1" -NoNewline -ForegroundColor Cyan
        Write-Host " ($($tool.size_kb) KB)" -ForegroundColor Gray
        Write-Host "    $($tool.purpose)" -ForegroundColor DarkGray
    }

    Write-Host ""
    Write-Host "DOCUMENTATION STATE:" -ForegroundColor Yellow

    foreach ($docName in $Docs.Keys) {
        $state = $Docs[$docName]
        if ($state.exists) {
            Write-Host "  [OK] " -NoNewline -ForegroundColor Green
            Write-Host "$docName " -NoNewline -ForegroundColor White
            Write-Host "($($state.size_kb) KB, $($state.tools_mentioned.Count) tools mentioned)" -ForegroundColor Gray
        } else {
            Write-Host "  [MISSING] " -NoNewline -ForegroundColor Red
            Write-Host "$docName" -ForegroundColor White
        }
    }

    Write-Host ""
}

# Main execution
$tools = Get-ToolInventory

switch ($Action) {
    'scan' {
        $docStates = @{}
        foreach ($docName in $docsToMaintain.Keys) {
            $docStates[$docName] = Get-DocumentationState -DocPath $docsToMaintain[$docName]
        }
        Show-ScanResults -Tools $tools -Docs $docStates
    }

    'update' {
        Write-Host ""
        Write-Host "=== AUTO-DOCUMENTATION UPDATE ===" -ForegroundColor Cyan
        Write-Host ""

        if ($SpecificDoc) {
            # Update specific document
            switch ($SpecificDoc) {
                "SESSION_MANAGER.md" { Update-SessionManagerDoc -Tools $tools }
                "MEMORY.md" { Update-MemoryDoc -Tools $tools }
                default {
                    Write-Host "[ERROR] Unknown document: $SpecificDoc" -ForegroundColor Red
                    exit 1
                }
            }
        } else {
            # Update all documents
            Update-SessionManagerDoc -Tools $tools
            Update-MemoryDoc -Tools $tools
        }

        Write-Host ""
        Write-Host "[COMPLETE] Documentation updated successfully" -ForegroundColor Green
        Write-Host ""
    }

    'verify' {
        Write-Host ""
        Write-Host "=== DOCUMENTATION VERIFICATION ===" -ForegroundColor Cyan
        Write-Host ""

        $issues = @()

        # Check if all tools are mentioned in SESSION_MANAGER.md
        $sessionMgrState = Get-DocumentationState -DocPath $docsToMaintain["SESSION_MANAGER.md"]
        $undocumentedTools = $tools | Where-Object { $_.name -notin $sessionMgrState.tools_mentioned }

        if ($undocumentedTools.Count -gt 0) {
            $issues += "SESSION_MANAGER.md missing $($undocumentedTools.Count) tools"
            Write-Host "[WARN] Undocumented tools in SESSION_MANAGER.md:" -ForegroundColor Yellow
            foreach ($tool in $undocumentedTools) {
                Write-Host "  - $($tool.name).ps1" -ForegroundColor Gray
            }
        } else {
            Write-Host "[OK] All tools documented in SESSION_MANAGER.md" -ForegroundColor Green
        }

        Write-Host ""

        if ($issues.Count -eq 0) {
            Write-Host "[PERFECT] Documentation is up to date" -ForegroundColor Green
        } else {
            Write-Host "[ACTION NEEDED] Run with -Action update to fix issues" -ForegroundColor Yellow
        }

        Write-Host ""
    }
}

return @{
    tools = $tools
    action = $Action
    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
}
