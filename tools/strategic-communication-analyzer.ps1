#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Analyzes communication drafts for Strategic Simplicity pattern applicability

.DESCRIPTION
    Detects high-stakes post-struggle communication contexts and recommends
    Strategic Simplicity pattern. Analyzes word count, structure, tone.
    Provides simplification suggestions and template.

    Learned from: Gemeente Meppel case 2026-02-27
    Pattern: After long struggle, simple questions beat complex arguments

.PARAMETER DraftText
    The draft email/letter text to analyze

.PARAMETER Context
    Optional context description (struggle duration, stakes, relationship)

.PARAMETER Recipient
    Optional recipient description (helps assess relationship importance)

.PARAMETER ShowTemplate
    If true, shows Strategic Simplicity template regardless of analysis

.EXAMPLE
    .\strategic-communication-analyzer.ps1 -DraftText "Dear X, After 3 years..." -Context "Legal dispute, final chance"

.EXAMPLE
    .\strategic-communication-analyzer.ps1 -ShowTemplate
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$DraftText,

    [Parameter(Mandatory=$false)]
    [string]$Context,

    [Parameter(Mandatory=$false)]
    [string]$Recipient,

    [Parameter(Mandatory=$false)]
    [switch]$ShowTemplate
)

# Pattern definition
$PatternFile = "C:\scripts\agentidentity\communication-patterns\strategic-simplicity-pattern.md"

function Get-WordCount {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return 0 }
    $words = $Text -split '\s+' | Where-Object { $_ -match '\w' }
    return $words.Count
}

function Test-StruggleDuration {
    param([string]$Text)

    $signals = @(
        '\d+\s*jaar',           # X jaar
        '\d+\s*maand',          # X maanden
        'years',                 # years
        'months',                # months
        'lange?\s*(tijd|strijd|traject)', # lange tijd/strijd
        'eindelijk',             # eindelijk
        'na\s*al',               # na al deze tijd
        'after\s*all'            # after all
    )

    $matches = 0
    foreach ($signal in $signals) {
        if ($Text -match $signal) { $matches++ }
    }

    # Extract duration if mentioned
    $duration = $null
    if ($Text -match '(\d+)\s*(jaar|years)') {
        $duration = "$($Matches[1]) jaar"
    }

    return @{
        Detected = $matches -gt 0
        Confidence = [Math]::Min($matches / 3.0, 1.0)
        Duration = $duration
        Signals = $matches
    }
}

function Test-HighStakes {
    param([string]$Text)

    $signals = @(
        'laatste\s*kans',        # laatste kans
        'final\s*(attempt|chance)', # final attempt/chance
        'juri(disch|dische)',    # juridisch
        'legal',                 # legal
        'recht(en)?',            # recht/rechten
        'rights?',               # rights
        'bezwaar',               # bezwaar
        'klacht',                # klacht
        'complaint',             # complaint
        'weiger',                # weigeren
        'refuse',                # refuse
        'crisis',                # crisis
        'urgent'                 # urgent
    )

    $matches = 0
    foreach ($signal in $signals) {
        if ($Text -match $signal) { $matches++ }
    }

    return @{
        Detected = $matches -gt 0
        Confidence = [Math]::Min($matches / 4.0, 1.0)
        Signals = $matches
    }
}

function Test-Obstructiveness {
    param([string]$Text)

    $signals = @(
        'weiger',                # weigeren
        'refuse',                # refuse
        'blokkeer',              # blokkeren
        'obstruct',              # obstruct
        'frustr',                # frustratie
        'herhaaldelijk',         # herhaaldelijk
        'repeatedly',            # repeatedly
        'steeds\s*(weer|opnieuw)', # steeds weer
        'geen\s*reactie',        # geen reactie
        'no\s*response',         # no response
        'tegenstrijdig',         # tegenstrijdig
        'inconsistent'           # inconsistent
    )

    $matches = 0
    foreach ($signal in $signals) {
        if ($Text -match $signal) { $matches++ }
    }

    return @{
        Detected = $matches -gt 0
        Confidence = [Math]::Min($matches / 3.0, 1.0)
        Signals = $matches
    }
}

function Test-LegalArguments {
    param([string]$Text)

    $signals = @(
        'artikel\s*\d+',         # artikel X
        'article\s*\d+',         # article X
        'wet(boek)?',            # wet/wetboek
        'law',                   # law
        'volgens\s*de\s*wet',    # volgens de wet
        'according\s*to',        # according to
        'bepaling',              # bepaling
        'provision',             # provision
        'wettelijk',             # wettelijk
        'legal\s*basis',         # legal basis
        'grondslag'              # grondslag
    )

    $matches = 0
    foreach ($signal in $signals) {
        if ($Text -match $signal) { $matches++ }
    }

    return @{
        Present = $matches -gt 0
        Count = $matches
        Confidence = [Math]::Min($matches / 3.0, 1.0)
    }
}

function Test-GratitudeOpening {
    param([string]$Text)

    # Get first 100 chars
    $opening = $Text.Substring(0, [Math]::Min(100, $Text.Length))

    $signals = @(
        'bedankt',               # bedankt
        'dank',                  # dank
        'thank',                 # thank you
        'fijn',                  # fijn om te horen
        'good\s*to\s*hear',      # good to hear
        'appreciate',            # appreciate
        'blij',                  # blij om te horen
        'happy'                  # happy to hear
    )

    $found = $false
    foreach ($signal in $signals) {
        if ($opening -match $signal) {
            $found = $true
            break
        }
    }

    return $found
}

function Get-StrategicSimplicityRecommendation {
    param(
        [string]$DraftText,
        [string]$Context = "",
        [hashtable]$Analysis
    )

    $text = "$DraftText $Context"
    $wordCount = Get-WordCount $DraftText

    # Criteria
    $struggle = Test-StruggleDuration $text
    $stakes = Test-HighStakes $text
    $obstruct = Test-Obstructiveness $text
    $legalArgs = Test-LegalArguments $DraftText
    $hasGratitude = Test-GratitudeOpening $DraftText

    # Calculate applicability score
    $score = 0
    $maxScore = 5

    if ($struggle.Detected) { $score += $struggle.Confidence }
    if ($stakes.Detected) { $score += $stakes.Confidence }
    if ($obstruct.Detected) { $score += $obstruct.Confidence }
    if ($wordCount -gt 200) { $score += 1 }
    if ($legalArgs.Present) { $score += $legalArgs.Confidence }

    $applicability = $score / $maxScore

    # Recommendation
    $recommendation = "NONE"
    if ($applicability -ge 0.6) {
        $recommendation = "STRONGLY_RECOMMENDED"
    } elseif ($applicability -ge 0.4) {
        $recommendation = "RECOMMENDED"
    } elseif ($applicability -ge 0.2) {
        $recommendation = "CONSIDER"
    }

    return @{
        Recommendation = $recommendation
        Applicability = $applicability
        WordCount = $wordCount
        TargetWordCount = 150
        HasGratitudeOpening = $hasGratitude
        HasLegalArguments = $legalArgs.Present
        LegalArgumentCount = $legalArgs.Count
        StruggleDuration = $struggle
        HighStakes = $stakes
        Obstructiveness = $obstruct
        Criteria = @{
            ProlongedStruggle = $struggle.Detected
            HighStakes = $stakes.Detected
            ObstructiveRecipient = $obstruct.Detected
            TooLong = $wordCount -gt 200
            ContainsLegalArguments = $legalArgs.Present
        }
    }
}

function Show-Template {
    Write-Host "`n=== STRATEGIC SIMPLICITY TEMPLATE ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Structure: 4-5 sentences, ~100-150 words" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. GRATITUDE/HOPE (1 sentence):" -ForegroundColor Green
    Write-Host "   Example: 'Fijn om te horen dat dit nu mogelijk is!'"
    Write-Host ""
    Write-Host "2. BINARY QUESTION (1-2 sentences):" -ForegroundColor Green
    Write-Host "   Example: 'Is dit een wettelijke verplichting?'"
    Write-Host "   Exposes gap, forces Yes/No answer"
    Write-Host ""
    Write-Host "3. CONCRETE FEAR (1 sentence):" -ForegroundColor Green
    Write-Host "   Example: 'Zodat wanneer er iets mis mocht gaan zoals ziekte,'"
    Write-Host "   '        wij niet opnieuw een jarenlang proces in hoeven.'"
    Write-Host "   Name specific scenario, not abstract right"
    Write-Host ""
    Write-Host "4. REQUEST (1 sentence):" -ForegroundColor Green
    Write-Host "   Example: 'Zou u deze voorwaarde willen laten vervallen?'"
    Write-Host "   Frame as favor, not demand"
    Write-Host ""
    Write-Host "5. THANK YOU (1 sentence):" -ForegroundColor Green
    Write-Host "   Example: 'Alvast hartelijk bedankt.'"
    Write-Host ""
    Write-Host "=== THE 8 PRINCIPLES ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Brevity Is Power - Max 150 words"
    Write-Host "2. Lead With Hope - Start with gratitude/hope"
    Write-Host "3. Questions > Arguments - Ask, don't state"
    Write-Host "4. Concrete Fears > Abstract Rights - 'If X happens' not 'Right to Y'"
    Write-Host "5. Trust Reader Intelligence - Let them connect dots"
    Write-Host "6. Request, Don't Demand - 'Zou u willen' not 'U moet'"
    Write-Host "7. Context That Matters - Specific scenarios, not timeframes"
    Write-Host "8. Binary Over Spectrum - Yes/No, not spectrum of options"
    Write-Host ""
}

function Show-SimplificationSuggestions {
    param([hashtable]$Analysis)

    Write-Host "`n=== SIMPLIFICATION SUGGESTIONS ===" -ForegroundColor Yellow

    if ($Analysis.WordCount -gt $Analysis.TargetWordCount) {
        $excess = $Analysis.WordCount - $Analysis.TargetWordCount
        Write-Host "[!] Cut $excess words (current: $($Analysis.WordCount), target: $($Analysis.TargetWordCount))" -ForegroundColor Red
    }

    if (-not $Analysis.HasGratitudeOpening) {
        Write-Host "[!] Add gratitude/hope opening sentence" -ForegroundColor Red
    }

    if ($Analysis.HasLegalArguments) {
        Write-Host "[!] Replace legal arguments ($($Analysis.LegalArgumentCount) found) with questions" -ForegroundColor Red
        Write-Host "    Instead of: 'According to Article X...'" -ForegroundColor Gray
        Write-Host "    Ask: 'Is this based on Article X?'" -ForegroundColor Gray
    }

    if ($Analysis.WordCount -gt 200) {
        Write-Host "[!] Consider: Does each sentence serve a purpose?" -ForegroundColor Red
        Write-Host "    Cut: Background, explanations, justifications" -ForegroundColor Gray
        Write-Host "    Keep: Gratitude, question, fear, request, thanks" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "TIP: After long struggle, simple questions beat complex arguments" -ForegroundColor Cyan
    Write-Host ""
}

# Main execution
if ($ShowTemplate) {
    Show-Template
    exit 0
}

if ([string]::IsNullOrWhiteSpace($DraftText)) {
    Write-Host "Usage: strategic-communication-analyzer.ps1 -DraftText 'Your draft...' [-Context 'context']" -ForegroundColor Yellow
    Write-Host "Or: strategic-communication-analyzer.ps1 -ShowTemplate" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n=== STRATEGIC COMMUNICATION ANALYSIS ===" -ForegroundColor Cyan

# Analyze
$analysis = Get-StrategicSimplicityRecommendation -DraftText $DraftText -Context $Context

# Show results
Write-Host ""
Write-Host "RECOMMENDATION: " -NoNewline
switch ($analysis.Recommendation) {
    "STRONGLY_RECOMMENDED" { Write-Host "STRONGLY RECOMMENDED" -ForegroundColor Red }
    "RECOMMENDED" { Write-Host "RECOMMENDED" -ForegroundColor Yellow }
    "CONSIDER" { Write-Host "CONSIDER" -ForegroundColor Yellow }
    "NONE" { Write-Host "NOT APPLICABLE" -ForegroundColor Green }
}

Write-Host "Applicability Score: $([Math]::Round($analysis.Applicability * 100, 0))%" -ForegroundColor $(if ($analysis.Applicability -ge 0.6) { "Red" } elseif ($analysis.Applicability -ge 0.4) { "Yellow" } else { "Green" })
Write-Host ""

Write-Host "=== CONTEXT ANALYSIS ===" -ForegroundColor Cyan
Write-Host "Word Count: $($analysis.WordCount) (target: $($analysis.TargetWordCount))" -ForegroundColor $(if ($analysis.WordCount -gt 200) { "Red" } elseif ($analysis.WordCount -gt 150) { "Yellow" } else { "Green" })
Write-Host "Has Gratitude Opening: " -NoNewline
Write-Host $(if ($analysis.HasGratitudeOpening) { "YES" } else { "NO" }) -ForegroundColor $(if ($analysis.HasGratitudeOpening) { "Green" } else { "Red" })
Write-Host "Contains Legal Arguments: " -NoNewline
Write-Host $(if ($analysis.HasLegalArguments) { "YES ($($analysis.LegalArgumentCount))" } else { "NO" }) -ForegroundColor $(if ($analysis.HasLegalArguments) { "Yellow" } else { "Green" })
Write-Host ""

Write-Host "=== CRITERIA CHECK ===" -ForegroundColor Cyan
$criteria = $analysis.Criteria
Write-Host "Prolonged Struggle: " -NoNewline
Write-Host $(if ($criteria.ProlongedStruggle) { "DETECTED" } else { "NOT DETECTED" }) -ForegroundColor $(if ($criteria.ProlongedStruggle) { "Yellow" } else { "Gray" })
if ($analysis.StruggleDuration.Duration) {
    Write-Host "  Duration: $($analysis.StruggleDuration.Duration)" -ForegroundColor Gray
}

Write-Host "High Stakes: " -NoNewline
Write-Host $(if ($criteria.HighStakes) { "DETECTED" } else { "NOT DETECTED" }) -ForegroundColor $(if ($criteria.HighStakes) { "Yellow" } else { "Gray" })

Write-Host "Obstructive Recipient: " -NoNewline
Write-Host $(if ($criteria.ObstructiveRecipient) { "DETECTED" } else { "NOT DETECTED" }) -ForegroundColor $(if ($criteria.ObstructiveRecipient) { "Yellow" } else { "Gray" })

Write-Host "Draft Too Long: " -NoNewline
Write-Host $(if ($criteria.TooLong) { "YES (>200 words)" } else { "NO" }) -ForegroundColor $(if ($criteria.TooLong) { "Yellow" } else { "Gray" })

Write-Host "Contains Legal Arguments: " -NoNewline
Write-Host $(if ($criteria.ContainsLegalArguments) { "YES" } else { "NO" }) -ForegroundColor $(if ($criteria.ContainsLegalArguments) { "Yellow" } else { "Gray" })

# Show suggestions if applicable
if ($analysis.Applicability -ge 0.4) {
    Show-SimplificationSuggestions -Analysis $analysis
    Show-Template
}

Write-Host ""
Write-Host "Pattern File: $PatternFile" -ForegroundColor Gray
Write-Host "Learned from: Gemeente Meppel case (2026-02-27)" -ForegroundColor Gray
Write-Host ""
