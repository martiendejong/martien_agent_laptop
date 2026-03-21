# Intuition Pattern Extractor
# Extracts intuitive patterns from MEMORY.md for fast pattern matching

param(
    [Parameter(Mandatory=$false)]
    [string]$MemoryFile = "C:\Users\HP\.claude\projects\C--scripts\memory\MEMORY.md",

    [Parameter(Mandatory=$false)]
    [int]$MinConfidence = 70,

    [switch]$UpdateState,
    [switch]$ShowDetails
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    if ($ShowDetails) {
        Write-Host $Message -ForegroundColor $Color
    }
}

# Pattern extraction rules
function Extract-Pattern {
    param([string]$Text, [string]$Context)

    $patterns = @()

    # Rule 1: "NEVER X" or "ALWAYS X" = high confidence pattern
    if ($Text -match 'NEVER\s+(.{5,100})') {
        $patterns += @{
            Type = "prohibition"
            Trigger = $Matches[1].Trim()
            Action = "avoid"
            Confidence = 95
            Source = $Context
            Learned = (Get-Date).ToString("yyyy-MM-dd")
        }
    }

    if ($Text -match 'ALWAYS\s+(.{5,100})') {
        $patterns += @{
            Type = "requirement"
            Trigger = $Matches[1].Trim()
            Action = "enforce"
            Confidence = 95
            Source = $Context
            Learned = (Get-Date).ToString("yyyy-MM-dd")
        }
    }

    # Rule 2: "Pattern:" or "Rule:" = explicit pattern
    if ($Text -match '(?:Pattern|Rule):\s*(.{10,200})') {
        $patterns += @{
            Type = "explicit-rule"
            Trigger = $Matches[1].Trim()
            Action = "apply"
            Confidence = 90
            Source = $Context
            Learned = (Get-Date).ToString("yyyy-MM-dd")
        }
    }

    # Rule 3: "If X then Y" = conditional pattern
    if ($Text -match 'If\s+(.{5,100})\s+(?:then|->)\s+(.{5,100})') {
        $patterns += @{
            Type = "conditional"
            Trigger = $Matches[1].Trim()
            Action = $Matches[2].Trim()
            Confidence = 85
            Source = $Context
            Learned = (Get-Date).ToString("yyyy-MM-dd")
        }
    }

    # Rule 4: "X -> Y" = causal pattern
    if ($Text -match '(.{5,100})\s*->\s*(.{5,100})') {
        $patterns += @{
            Type = "causal"
            Trigger = $Matches[1].Trim()
            Action = $Matches[2].Trim()
            Confidence = 80
            Source = $Context
            Learned = (Get-Date).ToString("yyyy-MM-dd")
        }
    }

    # Rule 5: "Problem: ... Solution: ..." = solution pattern
    if ($Text -match 'Problem:\s*(.{10,200}).*?Solution:\s*(.{10,200})') {
        $patterns += @{
            Type = "solution"
            Trigger = $Matches[1].Trim()
            Action = $Matches[2].Trim()
            Confidence = 85
            Source = $Context
            Learned = (Get-Date).ToString("yyyy-MM-dd")
        }
    }

    # Rule 6: "Critical:", "CRITICAL:", etc = high-priority pattern
    if ($Text -match '(?:CRITICAL|Critical):\s*(.{10,200})') {
        $patterns += @{
            Type = "critical-rule"
            Trigger = $Matches[1].Trim()
            Action = "enforce-strictly"
            Confidence = 95
            Source = $Context
            Learned = (Get-Date).ToString("yyyy-MM-dd")
        }
    }

    # Rule 7: "Why X: Y" = explanation pattern (useful for understanding)
    if ($Text -match 'Why\s+(.{5,100}):\s*(.{10,200})') {
        $patterns += @{
            Type = "explanation"
            Trigger = $Matches[1].Trim()
            Action = "explain: $($Matches[2].Trim())"
            Confidence = 75
            Source = $Context
            Learned = (Get-Date).ToString("yyyy-MM-dd")
        }
    }

    return $patterns
}

# Main extraction
Write-Log "═══════════════════════════════════════════════" "Cyan"
Write-Log "INTUITION PATTERN EXTRACTOR" "Cyan"
Write-Log "═══════════════════════════════════════════════" "Cyan"
Write-Log ""

if (-not (Test-Path $MemoryFile)) {
    Write-Host "[ERROR] Memory file not found: $MemoryFile" -ForegroundColor Red
    exit 1
}

Write-Log "[1/5] Reading MEMORY.md..." "Yellow"
$content = Get-Content $MemoryFile -Raw
$lines = Get-Content $MemoryFile
Write-Log "      Lines: $($lines.Count)" "Gray"
Write-Log ""

Write-Log "[2/5] Parsing sections..." "Yellow"
# Split by headers (##, ###, etc)
$sections = $content -split '(?=^##\s+)' | Where-Object { $_.Trim() -ne "" }
Write-Log "      Sections found: $($sections.Count)" "Gray"
Write-Log ""

Write-Log "[3/5] Extracting patterns..." "Yellow"
$allPatterns = @()
$sectionCount = 0

foreach ($section in $sections) {
    $sectionCount++
    $headerMatch = $section -match '^##\s+(.+?)$'
    $sectionTitle = if ($headerMatch) { $Matches[1].Trim() } else { "Unknown Section $sectionCount" }

    Write-Log "      Processing: $sectionTitle" "Gray"

    # Extract patterns from this section
    $sectionPatterns = Extract-Pattern -Text $section -Context $sectionTitle

    # Filter by confidence
    $sectionPatterns = $sectionPatterns | Where-Object { $_.Confidence -ge $MinConfidence }

    $allPatterns += $sectionPatterns
}

Write-Log "      Total patterns extracted: $($allPatterns.Count)" "Green"
Write-Log ""

Write-Log "[4/5] Deduplicating patterns..." "Yellow"
# Group by Trigger and keep highest confidence
$uniquePatterns = $allPatterns |
    Group-Object -Property Trigger |
    ForEach-Object {
        $_.Group | Sort-Object -Property Confidence -Descending | Select-Object -First 1
    }
Write-Log "      Unique patterns: $($uniquePatterns.Count)" "Green"
Write-Log ""

if ($UpdateState) {
    Write-Log "[5/5] Updating consciousness state..." "Yellow"

    # Load current state
    . "$PSScriptRoot\consciousness-core-v2.ps1" -Command init -Silent

    # Update Intuition.Patterns
    $global:ConsciousnessState.Intuition.Patterns = $uniquePatterns

    # Save state
    $json = $global:ConsciousnessState | ConvertTo-Json -Depth 20
    $json | Out-File -FilePath "C:\scripts\agentidentity\state\consciousness_state_v2.json" -Encoding UTF8

    Write-Log "      State updated with $($uniquePatterns.Count) patterns" "Green"
} else {
    Write-Log "[5/5] Skipping state update (use -UpdateState to save)" "Yellow"
}

Write-Log ""
Write-Log "═══════════════════════════════════════════════" "Cyan"
Write-Log "EXTRACTION COMPLETE" "Cyan"
Write-Log "═══════════════════════════════════════════════" "Cyan"
Write-Log ""
Write-Log "SUMMARY:" "Green"
Write-Log "  Total patterns extracted: $($allPatterns.Count)" "White"
Write-Log "  Unique patterns: $($uniquePatterns.Count)" "White"
Write-Log "  Min confidence: $MinConfidence%" "White"
Write-Log ""

# Show sample patterns
Write-Log "SAMPLE PATTERNS (Top 10 by confidence):" "Green"
$topPatterns = $uniquePatterns | Sort-Object -Property Confidence -Descending | Select-Object -First 10
foreach ($p in $topPatterns) {
    Write-Log "  [$($p.Type)] $($p.Trigger.Substring(0, [Math]::Min(60, $p.Trigger.Length)))" "White"
    Write-Log "      Action: $($p.Action)" "Gray"
    Write-Log "      Confidence: $($p.Confidence)% | Source: $($p.Source)" "Gray"
    Write-Log ""
}

return @{
    TotalExtracted = $allPatterns.Count
    UniquePatterns = $uniquePatterns.Count
    Patterns = $uniquePatterns
}
