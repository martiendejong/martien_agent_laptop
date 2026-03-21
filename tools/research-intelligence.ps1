param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('ExtractClaim', 'RegisterConflict', 'EstablishCanon', 'QueryClaims', 'GenerateSynthesis', 'CheckMode')]
    [string]$Action,

    [string]$SourceFile,
    [string]$SourceType, # PRIMARY, CONTEMPORARY, SECONDARY, UNCORROBORATED
    [string]$ExactQuote,
    [string]$NormalizedClaim,
    [string]$Entities,
    [string]$Confidence, # HIGH, MEDIUM, LOW, INSUFFICIENT
    [string]$ClaimId,
    [string]$ConflictDescription,
    [string]$ClaimA,
    [string]$ClaimB,
    [string]$ResolutionStatus, # OPEN, RESOLVED, ACKNOWLEDGED
    [string]$CanonTopic,
    [string]$Query,
    [switch]$Silent
)

$ResearchBase = "E:\jengo\documents\research"
$ClaimsDir = "$ResearchBase\claims"
$ConflictsDir = "$ResearchBase\conflicts"
$CanonDir = "$ResearchBase\canon"
$SynthesisDir = "$ResearchBase\synthesis"
$SourcesDir = "$ResearchBase\sources"

# Ensure directories exist
@($ClaimsDir, $ConflictsDir, $CanonDir, $SynthesisDir, $SourcesDir) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

function Get-NextId {
    param([string]$Prefix, [string]$Directory)

    $files = Get-ChildItem -Path $Directory -Filter "$Prefix-*.md" -ErrorAction SilentlyContinue
    if ($files.Count -eq 0) {
        return "$Prefix-001"
    }

    $nums = $files | ForEach-Object {
        if ($_.BaseName -match "$Prefix-(\d+)") {
            [int]$matches[1]
        }
    }

    if ($nums) {
        $maxNum = ($nums | Measure-Object -Maximum).Maximum
        $nextNum = $maxNum + 1
    } else {
        $nextNum = 1
    }

    $paddedNum = $nextNum.ToString("000")
    return "$Prefix-$paddedNum"
}

function Write-Output-Safe {
    param([string]$Message)
    if (-not $Silent) {
        Write-Host $Message
    }
}

switch ($Action) {
    'ExtractClaim' {
        if (-not $SourceFile -or -not $SourceType -or -not $NormalizedClaim) {
            throw "ExtractClaim requires: -SourceFile, -SourceType, -NormalizedClaim"
        }

        $claimId = Get-NextId -Prefix "CLM" -Directory $ClaimsDir
        $timestamp = Get-Date -Format "yyyy-MM-dd"

        $claimContent = @"
# $claimId — $NormalizedClaim
**Created:** $timestamp

## Claim Details
- **Source:** $SourceFile
- **Source type:** $SourceType
- **Date of source:** [to be filled]
- **Exact quote:** "$ExactQuote"
- **Normalized claim:** $NormalizedClaim
- **Entities:** $Entities
- **Confidence:** $(if ($Confidence) { $Confidence } else { "MEDIUM" })
- **Contradicts:** NONE (check for conflicts)
- **Supports:** NEW

## Notes
[Additional context or analysis]

---
**Status:** Active
**Last updated:** $timestamp
"@

        $claimFile = Join-Path $ClaimsDir "$claimId.md"
        $claimContent | Out-File -FilePath $claimFile -Encoding UTF8

        Write-Output-Safe "[CLAIM EXTRACTED]"
        Write-Output-Safe "ID: $claimId"
        Write-Output-Safe "File: $claimFile"
        Write-Output-Safe "Source: $SourceFile ($SourceType)"
        Write-Output-Safe "Claim: $NormalizedClaim"

        # Return claim ID for programmatic use
        return $claimId
    }

    'RegisterConflict' {
        if (-not $ConflictDescription -or -not $ClaimA -or -not $ClaimB) {
            throw "RegisterConflict requires: -ConflictDescription, -ClaimA, -ClaimB"
        }

        $confId = Get-NextId -Prefix "CONF" -Directory $ConflictsDir
        $timestamp = Get-Date -Format "yyyy-MM-dd"

        $conflictContent = @"
# $confId — $ConflictDescription
**Created:** $timestamp
**Status:** $(if ($ResolutionStatus) { $ResolutionStatus } else { "OPEN" })

## Conflict Details

**Claim A:** $ClaimA
[Source type: to be filled]

**Claim B:** $ClaimB
[Source type: to be filled]

## Analysis
[Why does this contradiction exist? What does each source represent?]

## Resolution
[If RESOLVED: which claim wins, and why]
[If OPEN: what primary source evidence would resolve this conflict?]
[If ACKNOWLEDGED: no resolution possible with available evidence - state why]

## Impact on Synthesis
[Does this conflict affect any existing synthesis conclusions?]

---
**Last updated:** $timestamp
"@

        $conflictFile = Join-Path $ConflictsDir "$confId.md"
        $conflictContent | Out-File -FilePath $conflictFile -Encoding UTF8

        Write-Output-Safe "[CONFLICT REGISTERED]"
        Write-Output-Safe "ID: $confId"
        Write-Output-Safe "File: $conflictFile"
        Write-Output-Safe "Claim A: $ClaimA"
        Write-Output-Safe "Claim B: $ClaimB"
        Write-Output-Safe "Status: $(if ($ResolutionStatus) { $ResolutionStatus } else { 'OPEN' })"

        return $confId
    }

    'EstablishCanon' {
        if (-not $CanonTopic) {
            throw "EstablishCanon requires: -CanonTopic"
        }

        $canonId = Get-NextId -Prefix "C" -Directory $CanonDir
        $timestamp = Get-Date -Format "yyyy-MM-dd"

        $canonContent = @"
# $canonId — $CanonTopic
**Established:** $timestamp
**Status:** LOCKED

## Canon Entry

| Field | Value | Source | Confidence |
|-------|-------|--------|------------|
| [field] | [value] | [document] | ABSOLUTE/HIGH/MEDIUM |

**Critical note:** [Any important caveats or edge cases]

## Override Protocol
To challenge this canon entry, you must produce ALL of:
1. A primary source (official document, original record)
2. That directly contradicts the specific canon statement
3. With higher evidentiary weight than the source that established this entry

## Version History
v1 ($timestamp): Initial establishment

---
**Last updated:** $timestamp
"@

        $canonFile = Join-Path $CanonDir "$canonId.md"
        $canonContent | Out-File -FilePath $canonFile -Encoding UTF8

        Write-Output-Safe "[CANON ESTABLISHED]"
        Write-Output-Safe "ID: $canonId"
        Write-Output-Safe "File: $canonFile"
        Write-Output-Safe "Topic: $CanonTopic"
        Write-Output-Safe "Status: LOCKED (requires primary source override)"

        return $canonId
    }

    'QueryClaims' {
        if (-not $Query) {
            # List all claims
            $claims = Get-ChildItem -Path $ClaimsDir -Filter "CLM-*.md" | Sort-Object Name
            Write-Output-Safe "`n[CLAIMS REGISTRY]"
            Write-Output-Safe "Total claims: $($claims.Count)"
            Write-Output-Safe ""

            foreach ($claim in $claims) {
                $content = Get-Content $claim.FullName -Raw
                if ($content -match '# (CLM-\d+) — (.+)') {
                    $id = $matches[1]
                    $title = $matches[2]
                    Write-Output-Safe "$id : $title"
                }
            }
        } else {
            # Search claims
            $results = Get-ChildItem -Path $ClaimsDir -Filter "CLM-*.md" | Where-Object {
                (Get-Content $_.FullName -Raw) -match $Query
            }

            Write-Output-Safe "`n[SEARCH RESULTS]"
            Write-Output-Safe "Query: $Query"
            Write-Output-Safe "Matches: $($results.Count)"
            Write-Output-Safe ""

            foreach ($result in $results) {
                $content = Get-Content $result.FullName -Raw
                if ($content -match '# (CLM-\d+) — (.+)') {
                    Write-Output-Safe "$($matches[1]) : $($matches[2])"
                }
            }
        }
    }

    'GenerateSynthesis' {
        $version = "v1"
        $existingSynthesis = Get-ChildItem -Path $SynthesisDir -Filter "synthesis-*.md" -ErrorAction SilentlyContinue
        if ($existingSynthesis) {
            $maxVersion = ($existingSynthesis | ForEach-Object {
                if ($_.BaseName -match 'synthesis-v(\d+)') {
                    [int]$matches[1]
                }
            } | Measure-Object -Maximum).Maximum
            $version = "v$($maxVersion + 1)"
        }

        $timestamp = Get-Date -Format "yyyy-MM-dd"
        $synthesisContent = @"
# Synthesis: [Research Question]
**Version:** $version
**Date:** $timestamp
**Status:** CURRENT
**Confidence:** [HIGH / MEDIUM / LOW / INSUFFICIENT]

---

## Research Question
[State the exact question this synthesis addresses]

---

## Claims Used
[List the CLM-IDs that form the evidence base for this synthesis]

---

## Evidence Summary

### What primary sources say
[Quote the most important claims, with CLM-IDs]

### What secondary sources say
[Note secondary sources, with assessment of reliability]

---

## Conflicts Found
[List CONF-IDs that are relevant to this question]
[For each: state whether RESOLVED or OPEN, and how it affects this synthesis]

---

## Canon Alignment
[State whether this synthesis is CONSISTENT with relevant canon entries,
EXTENDS canon with new findings, or CONFLICTS with canon (should not happen - fix it)]

---

## Conclusion
[The answer to the research question, derived from the above]

**Confidence:** [HIGH / MEDIUM / LOW / INSUFFICIENT]
**Basis:** [Number of primary sources, independence, conflicts]

---

## Unresolved Questions
[What cannot be answered with current evidence]

---

## Next Evidence Needed
[Specific documents or sources that would resolve unresolved questions or upgrade confidence]

---

## Version History
$version ($timestamp): [summary of what was established]
"@

        $synthesisFile = Join-Path $SynthesisDir "synthesis-$version-$timestamp.md"
        $synthesisContent | Out-File -FilePath $synthesisFile -Encoding UTF8

        Write-Output-Safe "[SYNTHESIS GENERATED]"
        Write-Output-Safe "Version: $version"
        Write-Output-Safe "File: $synthesisFile"
        Write-Output-Safe "Status: CURRENT (edit and complete)"
    }

    'CheckMode' {
        Write-Output-Safe "`n[RESEARCH INTELLIGENCE STATUS]"
        Write-Output-Safe ""
        Write-Output-Safe "Storage: $ResearchBase"
        Write-Output-Safe ""

        $claimCount = (Get-ChildItem -Path $ClaimsDir -Filter "CLM-*.md" -ErrorAction SilentlyContinue).Count
        $conflictCount = (Get-ChildItem -Path $ConflictsDir -Filter "CONF-*.md" -ErrorAction SilentlyContinue).Count
        $canonCount = (Get-ChildItem -Path $CanonDir -Filter "C*.md" -ErrorAction SilentlyContinue).Count
        $synthesisCount = (Get-ChildItem -Path $SynthesisDir -Filter "synthesis-*.md" -ErrorAction SilentlyContinue).Count

        Write-Output-Safe "Layer 1 (Claims): $claimCount registered"
        Write-Output-Safe "Layer 2 (Conflicts): $conflictCount registered"
        Write-Output-Safe "Layer 3 (Canon): $canonCount established"
        Write-Output-Safe "Layer 4 (Synthesis): $synthesisCount versions"
        Write-Output-Safe ""

        if ($claimCount -eq 0) {
            Write-Output-Safe "[READY] No claims yet - awaiting first research task"
        } else {
            Write-Output-Safe "[ACTIVE] Research intelligence system operational"
            Write-Output-Safe ""
            Write-Output-Safe "Recent claims:"
            Get-ChildItem -Path $ClaimsDir -Filter "CLM-*.md" |
                Sort-Object LastWriteTime -Descending |
                Select-Object -First 5 |
                ForEach-Object {
                    $content = Get-Content $_.FullName -Raw
                    if ($content -match '# (CLM-\d+) — (.+)') {
                        Write-Output-Safe "  $($matches[1]) : $($matches[2])"
                    }
                }
        }

        Write-Output-Safe ""
        Write-Output-Safe "Mode check:"
        Write-Output-Safe "  [OK] Claim Accountant protocols loaded"
        Write-Output-Safe "  [OK] 4-layer architecture ready"
        Write-Output-Safe "  [OK] Source typing hierarchy: PRIMARY > CONTEMPORARY > SECONDARY"
    }
}
