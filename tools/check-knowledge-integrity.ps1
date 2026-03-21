# Knowledge Architecture Integrity Checker
# Created: 2026-03-20
# Purpose: Detect broken links, missing files, orphaned references in memory system

param(
    [switch]$Fix,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

$memoryPath = "C:\Users\HP\.claude\projects\C--scripts\memory"
$memoryIndex = Join-Path $memoryPath "MEMORY.md"
$skillsPath = "C:\scripts\.claude\skills"

$brokenReferences = @()
$missingFiles = @()
$orphanedFiles = @()
$suggestions = @()

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "KNOWLEDGE INTEGRITY CHECKER" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# CHECK 1: MEMORY.md index references
Write-Host "[CHECK 1] Verifying MEMORY.md index references..." -ForegroundColor Yellow

if (!(Test-Path $memoryIndex)) {
    Write-Host "❌ MEMORY.md not found at: $memoryIndex" -ForegroundColor Red
    exit 1
}

$memoryContent = Get-Content $memoryIndex -Raw

# Extract all .md file references from MEMORY.md
$references = [regex]::Matches($memoryContent, '`([a-zA-Z0-9\-_]+\.md)`') | ForEach-Object { $_.Groups[1].Value }

$totalReferences = $references.Count
$validReferences = 0
$invalidReferences = 0

foreach ($ref in $references) {
    $fullPath = Join-Path $memoryPath $ref

    if (Test-Path $fullPath) {
        $validReferences++
        if ($Verbose) {
            Write-Host "  ✅ $ref" -ForegroundColor Green
        }
    } else {
        $invalidReferences++
        Write-Host "  ❌ Missing: $ref" -ForegroundColor Red
        $missingFiles += $ref
        $brokenReferences += @{
            Source = "MEMORY.md"
            Reference = $ref
            Type = "Index Reference"
        }
    }
}

Write-Host "  References checked: $totalReferences" -ForegroundColor White
Write-Host "  Valid: $validReferences" -ForegroundColor Green
Write-Host "  Broken: $invalidReferences" -ForegroundColor Red

# CHECK 2: Topic file cross-references
Write-Host "`n[CHECK 2] Scanning topic files for cross-references..." -ForegroundColor Yellow

$topicFiles = Get-ChildItem $memoryPath -Filter "*.md" -File | Where-Object { $_.Name -ne "MEMORY.md" }

foreach ($file in $topicFiles) {
    $content = Get-Content $file.FullName -Raw

    # Find all .md references in this file
    $fileRefs = [regex]::Matches($content, '`([a-zA-Z0-9\-_]+\.md)`') | ForEach-Object { $_.Groups[1].Value }

    foreach ($ref in $fileRefs) {
        $refPath = Join-Path $memoryPath $ref

        if (!(Test-Path $refPath)) {
            Write-Host "  ❌ $($file.Name) references missing file: $ref" -ForegroundColor Red
            $brokenReferences += @{
                Source = $file.Name
                Reference = $ref
                Type = "Cross-Reference"
            }
        }
    }
}

# CHECK 3: Skill file memory references
Write-Host "`n[CHECK 3] Checking skill files for memory references..." -ForegroundColor Yellow

if (Test-Path $skillsPath) {
    $skillFiles = Get-ChildItem $skillsPath -Recurse -Filter "SKILL.md"

    foreach ($skillFile in $skillFiles) {
        $content = Get-Content $skillFile.FullName -Raw

        # Find memory file references
        $memRefs = [regex]::Matches($content, 'memory/([a-zA-Z0-9\-_]+\.md)') | ForEach-Object { $_.Groups[1].Value }

        foreach ($ref in $memRefs) {
            $refPath = Join-Path $memoryPath $ref

            if (!(Test-Path $refPath)) {
                Write-Host "  ❌ $($skillFile.Directory.Name) references missing memory file: $ref" -ForegroundColor Red
                $brokenReferences += @{
                    Source = $skillFile.FullName
                    Reference = $ref
                    Type = "Skill→Memory Reference"
                }
            }
        }
    }
}

# CHECK 4: Orphaned files (not referenced in MEMORY.md)
Write-Host "`n[CHECK 4] Detecting orphaned topic files..." -ForegroundColor Yellow

$allTopicFiles = $topicFiles.Name
$referencedFiles = $references | Select-Object -Unique

foreach ($topicFile in $allTopicFiles) {
    if ($referencedFiles -notcontains $topicFile) {
        Write-Host "  ⚠️ Orphaned (not in MEMORY.md): $topicFile" -ForegroundColor Yellow
        $orphanedFiles += $topicFile

        # Suggest adding to MEMORY.md
        $suggestions += @{
            Type = "Add to Index"
            File = $topicFile
            Action = "Add reference to MEMORY.md Topic Files section"
        }
    }
}

# CHECK 5: Duplicate patterns (same pattern in multiple files)
Write-Host "`n[CHECK 5] Scanning for duplicate patterns..." -ForegroundColor Yellow

# Common pattern indicators
$patternKeywords = @("Pattern", "PATTERN", "Rule", "RULE", "Protocol", "PROTOCOL")

$patternOccurrences = @{}

foreach ($file in $topicFiles) {
    $content = Get-Content $file.FullName -Raw

    foreach ($keyword in $patternKeywords) {
        $matches = [regex]::Matches($content, "$keyword\s+(\d+)")

        foreach ($match in $matches) {
            $patternId = "$keyword $($match.Groups[1].Value)"

            if ($patternOccurrences.ContainsKey($patternId)) {
                $patternOccurrences[$patternId] += $file.Name
            } else {
                $patternOccurrences[$patternId] = @($file.Name)
            }
        }
    }
}

$duplicates = $patternOccurrences.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }

foreach ($dup in $duplicates) {
    Write-Host "  ⚠️ $($dup.Key) appears in: $($dup.Value -join ', ')" -ForegroundColor Yellow
}

# DISPLAY RESULTS
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "INTEGRITY REPORT" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Broken References: $($brokenReferences.Count)" -ForegroundColor $(if ($brokenReferences.Count -eq 0) { "Green" } else { "Red" })
Write-Host "Missing Files: $($missingFiles.Count)" -ForegroundColor $(if ($missingFiles.Count -eq 0) { "Green" } else { "Red" })
Write-Host "Orphaned Files: $($orphanedFiles.Count)" -ForegroundColor $(if ($orphanedFiles.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host "Duplicate Patterns: $($duplicates.Count)" -ForegroundColor $(if ($duplicates.Count -eq 0) { "Green" } else { "Yellow" })

if ($brokenReferences.Count -eq 0 -and $orphanedFiles.Count -eq 0) {
    Write-Host "`n✅ KNOWLEDGE INTEGRITY: EXCELLENT" -ForegroundColor Green
    Write-Host "No broken references or orphaned files detected." -ForegroundColor Green
} elseif ($brokenReferences.Count -eq 0) {
    Write-Host "`n⚠️ KNOWLEDGE INTEGRITY: GOOD" -ForegroundColor Yellow
    Write-Host "No broken references, but some orphaned files exist." -ForegroundColor Yellow
} else {
    Write-Host "`n❌ KNOWLEDGE INTEGRITY: COMPROMISED" -ForegroundColor Red
    Write-Host "Broken references detected. Manual review required." -ForegroundColor Red
}

# Suggestions
if ($suggestions.Count -gt 0) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "SUGGESTED ACTIONS" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan

    foreach ($suggestion in $suggestions) {
        Write-Host "[$($suggestion.Type)] $($suggestion.File)" -ForegroundColor Cyan
        Write-Host "  → $($suggestion.Action)" -ForegroundColor White
    }
}

# Export results
$reportPath = "C:\scripts\_machine\knowledge-integrity-report-$(Get-Date -Format 'yyyy-MM-dd-HHmm').json"
$report = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    BrokenReferences = $brokenReferences
    MissingFiles = $missingFiles
    OrphanedFiles = $orphanedFiles
    Suggestions = $suggestions
    TotalReferences = $totalReferences
    ValidReferences = $validReferences
    InvalidReferences = $invalidReferences
} | ConvertTo-Json -Depth 10

$report | Out-File $reportPath -Encoding UTF8
Write-Host "`n📄 Detailed report saved to: $reportPath" -ForegroundColor Cyan

exit $(if ($brokenReferences.Count -eq 0) { 0 } else { 1 })
