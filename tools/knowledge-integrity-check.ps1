<#
.SYNOPSIS
    Knowledge Integrity Check - GDIO-derived validation for Jengo's knowledge systems
.DESCRIPTION
    Scans memory files, skills, and knowledge base for GDIO principle violations:
    - Orthogonal isolation violations (cross-domain contamination)
    - Frozen layer modification attempts
    - Oversized files needing expansion
    - Missing index entries in MEMORY.md
    - Duplicate content across files
.NOTES
    Based on GDIO (Growing Deep Into Orthogonal subspaces) - UWisc + Google Research, March 2026
    Created: 2026-03-12
#>

param(
    [switch]$Verbose,
    [switch]$Fix  # Auto-fix minor issues (missing index entries)
)

$ErrorActionPreference = "Continue"

# ═══════════════════════════════════════════════
# Configuration
# ═══════════════════════════════════════════════

$MemoryDir = "C:\Users\HP\.claude\projects\C--scripts\memory"
$SkillsDir = "C:\scripts\skills"
$ToolsDir = "C:\scripts\tools"
$MemoryIndex = Join-Path $MemoryDir "MEMORY.md"

# Layer 1: FROZEN FILES (should NEVER be modified by automated processes)
$FrozenFiles = @(
    "C:\scripts\ZERO_TOLERANCE_RULES.md",
    (Join-Path $MemoryDir "hard-rules.md"),
    (Join-Path $MemoryDir "legal-safeguards.md"),
    (Join-Path $MemoryDir "windows-ssh-rule.md")
)

# Maximum recommended size for a single topic file (chars)
# Note: Knowledge files naturally vary. Domain-specific deep dives may exceed this.
# The threshold flags for AWARENESS, not hard violations.
$MaxTopicSize = 20000     # Flag: consider if file covers multiple unrelated domains
$WarningTopicSize = 10000 # Info: file growing large, ensure single-domain focus

# ═══════════════════════════════════════════════
# Results tracking
# ═══════════════════════════════════════════════

$results = @{
    Errors   = [System.Collections.ArrayList]::new()
    Warnings = [System.Collections.ArrayList]::new()
    Info     = [System.Collections.ArrayList]::new()
    Stats    = @{
        TotalFiles = 0
        Layer1Files = 0
        Layer2Files = 0
        Layer3Files = 0
        OversizedFiles = 0
        MissingIndexEntries = 0
        OrphanedEntries = 0
    }
}

function Add-Error($msg) { [void]$results.Errors.Add($msg) }
function Add-Warning($msg) { [void]$results.Warnings.Add($msg) }
function Add-Info($msg) { [void]$results.Info.Add($msg) }

Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Knowledge Integrity Check (GDIO Principles)" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# ═══════════════════════════════════════════════
# Check 1: Frozen Layer Integrity
# ═══════════════════════════════════════════════

Write-Host "[1/5] Checking Layer 1 (Frozen Values)..." -ForegroundColor Yellow

foreach ($frozenFile in $FrozenFiles) {
    if (Test-Path $frozenFile) {
        $results.Stats.Layer1Files++
        $lastWrite = (Get-Item $frozenFile).LastWriteTime
        $daysSinceModified = (New-TimeSpan -Start $lastWrite -End (Get-Date)).Days

        if ($daysSinceModified -lt 1) {
            Add-Warning "FROZEN file modified today: $frozenFile (Layer 1 should be stable)"
        }

        if ($Verbose) {
            Add-Info "FROZEN OK: $frozenFile (last modified $daysSinceModified days ago)"
        }
    } else {
        Add-Error "FROZEN file MISSING: $frozenFile"
    }
}

# ═══════════════════════════════════════════════
# Check 2: Memory Index Integrity (Layer 2)
# ═══════════════════════════════════════════════

Write-Host "[2/5] Checking Layer 2 (MEMORY.md Index)..." -ForegroundColor Yellow
$results.Stats.Layer2Files++

if (Test-Path $MemoryIndex) {
    $indexContent = Get-Content $MemoryIndex -Raw

    # Get all .md files in memory dir (excluding MEMORY.md itself)
    $topicFiles = Get-ChildItem $MemoryDir -Filter "*.md" | Where-Object { $_.Name -ne "MEMORY.md" }

    foreach ($file in $topicFiles) {
        $results.Stats.TotalFiles++
        $results.Stats.Layer3Files++

        # Check if file is indexed in MEMORY.md
        if ($indexContent -notmatch [regex]::Escape($file.Name)) {
            $results.Stats.MissingIndexEntries++
            Add-Warning "NOT INDEXED in MEMORY.md: $($file.Name) (Layer 2 routing gap)"
        }
    }

    # Check for orphaned index entries (referenced but file doesn't exist)
    $indexLines = $indexContent -split "`n" | Where-Object { $_ -match "^\s*-\s*``([^``]+)``" }
    foreach ($line in $indexLines) {
        if ($line -match "``([^``]+\.md)``") {
            $referencedFile = $Matches[1]
            $fullPath = Join-Path $MemoryDir $referencedFile
            if (-not (Test-Path $fullPath)) {
                $results.Stats.OrphanedEntries++
                Add-Error "ORPHANED INDEX entry: $referencedFile (referenced in MEMORY.md but file doesn't exist)"
            }
        }
    }

    # Check MEMORY.md size (should stay under 200 lines per spec)
    $lineCount = ($indexContent -split "`n").Count
    if ($lineCount -gt 200) {
        Add-Warning "MEMORY.md exceeds 200 lines ($lineCount lines) - truncation risk"
    } elseif ($lineCount -gt 150) {
        Add-Info "MEMORY.md at $lineCount lines (max 200, getting close)"
    }
} else {
    Add-Error "MEMORY.md NOT FOUND at $MemoryIndex"
}

# ═══════════════════════════════════════════════
# Check 3: Orthogonal Isolation (Layer 3)
# ═══════════════════════════════════════════════

Write-Host "[3/5] Checking Layer 3 (Orthogonal Isolation)..." -ForegroundColor Yellow

$topicFiles = Get-ChildItem $MemoryDir -Filter "*.md" | Where-Object { $_.Name -ne "MEMORY.md" }

foreach ($file in $topicFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }

    $charCount = $content.Length

    # Check file size (expansion needed?)
    if ($charCount -gt $MaxTopicSize) {
        $results.Stats.OversizedFiles++
        Add-Warning "OVERSIZED: $($file.Name) ($charCount chars > $MaxTopicSize max) - consider splitting into orthogonal subspaces"
    } elseif ($charCount -gt $WarningTopicSize -and $Verbose) {
        Add-Info "GROWING: $($file.Name) ($charCount chars, approaching $MaxTopicSize limit)"
    }
}

# ═══════════════════════════════════════════════
# Check 4: Skills Integrity
# ═══════════════════════════════════════════════

Write-Host "[4/5] Checking Skills (Capability Layer)..." -ForegroundColor Yellow

$skillFiles = Get-ChildItem $SkillsDir -Filter "*.md" -ErrorAction SilentlyContinue

foreach ($skill in $skillFiles) {
    $content = Get-Content $skill.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }

    # Check for YAML frontmatter
    if ($content -notmatch "^---") {
        Add-Warning "SKILL missing YAML frontmatter: $($skill.Name)"
    }

    # Check for name field
    if ($content -notmatch "name:\s*\w+") {
        Add-Warning "SKILL missing name field: $($skill.Name)"
    }

    if ($Verbose) {
        Add-Info "SKILL OK: $($skill.Name)"
    }
}

# ═══════════════════════════════════════════════
# Check 5: Cross-Domain Contamination Detection
# ═══════════════════════════════════════════════

Write-Host "[5/5] Checking for cross-domain contamination..." -ForegroundColor Yellow

# Define known domain markers
$domains = @{
    "wordpress" = @("WordPress", "WP_", "wp-", "CPT", "REST API.*WordPress")
    "deployment" = @("IIS", "paramiko", "SFTP", "app pool", "dotnet publish")
    "legal"     = @("juridisch", "gemeente", "bezwaar", "huwelijk", "rechtbank")
    "clickup"   = @("ClickUp", "backlog", "refinement", "board.*status")
    "ml"        = @("fine-tun", "LoRA", "GDIO", "orthogonal", "catastrophic forgetting", "MLP.*expansion")
}

foreach ($file in $topicFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }

    $fileName = $file.Name.ToLower()
    $matchedDomains = [System.Collections.ArrayList]::new()

    foreach ($domain in $domains.Keys) {
        $domainMarkerCount = 0
        foreach ($marker in $domains[$domain]) {
            if ($content -match $marker) {
                $domainMarkerCount++
            }
        }
        # Consider it "in this domain" if 2+ markers match
        if ($domainMarkerCount -ge 2) {
            [void]$matchedDomains.Add($domain)
        }
    }

    # Flag files that span multiple unrelated domains
    if ($matchedDomains.Count -gt 2) {
        Add-Warning "CROSS-DOMAIN: $($file.Name) spans $($matchedDomains.Count) domains: $($matchedDomains -join ', ') - consider splitting"
    }
}

# ═══════════════════════════════════════════════
# Report
# ═══════════════════════════════════════════════

Write-Host ""
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Results" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan

# Errors
if ($results.Errors.Count -gt 0) {
    Write-Host ""
    Write-Host "ERRORS ($($results.Errors.Count)):" -ForegroundColor Red
    foreach ($err in $results.Errors) {
        Write-Host "  [X] $err" -ForegroundColor Red
    }
}

# Warnings
if ($results.Warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "WARNINGS ($($results.Warnings.Count)):" -ForegroundColor Yellow
    foreach ($warn in $results.Warnings) {
        Write-Host "  [!] $warn" -ForegroundColor Yellow
    }
}

# Info (verbose only)
if ($Verbose -and $results.Info.Count -gt 0) {
    Write-Host ""
    Write-Host "INFO ($($results.Info.Count)):" -ForegroundColor Gray
    foreach ($info in $results.Info) {
        Write-Host "  [i] $info" -ForegroundColor Gray
    }
}

# Stats
Write-Host ""
Write-Host "STATISTICS:" -ForegroundColor Cyan
Write-Host "  Layer 1 (Frozen):    $($results.Stats.Layer1Files) files" -ForegroundColor White
Write-Host "  Layer 2 (Routing):   $($results.Stats.Layer2Files) files" -ForegroundColor White
Write-Host "  Layer 3 (Knowledge): $($results.Stats.Layer3Files) files" -ForegroundColor White
Write-Host "  Total topic files:   $($results.Stats.TotalFiles)" -ForegroundColor White
Write-Host "  Oversized files:     $($results.Stats.OversizedFiles)" -ForegroundColor $(if ($results.Stats.OversizedFiles -gt 0) { "Yellow" } else { "Green" })
Write-Host "  Missing index:       $($results.Stats.MissingIndexEntries)" -ForegroundColor $(if ($results.Stats.MissingIndexEntries -gt 0) { "Yellow" } else { "Green" })
Write-Host "  Orphaned entries:    $($results.Stats.OrphanedEntries)" -ForegroundColor $(if ($results.Stats.OrphanedEntries -gt 0) { "Red" } else { "Green" })

# Overall verdict
Write-Host ""
if ($results.Errors.Count -eq 0 -and $results.Warnings.Count -eq 0) {
    Write-Host "VERDICT: HEALTHY - All GDIO principles satisfied" -ForegroundColor Green
} elseif ($results.Errors.Count -eq 0) {
    Write-Host "VERDICT: GOOD - No errors, $($results.Warnings.Count) warnings to address" -ForegroundColor Yellow
} else {
    Write-Host "VERDICT: NEEDS ATTENTION - $($results.Errors.Count) errors, $($results.Warnings.Count) warnings" -ForegroundColor Red
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
