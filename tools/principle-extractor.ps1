# Principle Extractor - Separate Mechanisms from Principles
# Created: 2026-02-20
# Purpose: Extract deep principles from observed patterns and mechanisms

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Extract', 'Validate', 'List', 'Hierarchy')]
    [string]$Action,

    [string]$Pattern = "",
    [string]$Mechanism = "",
    [string]$ProposedPrinciple = "",
    [string[]]$ValidationDomains = @(),
    [string]$PrincipleId = "",
    [switch]$Silent
)

$StateFile = "C:\scripts\agentidentity\state\principles.json"

# Initialize state if not exists
if (-not (Test-Path $StateFile)) {
    $InitialState = @{
        version = "1.0"
        created = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        principles = @()
        extraction_count = 0
        validation_attempts = 0
        validated_principles = 0
    }
    $InitialState | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

$State = Get-Content $StateFile -Raw | ConvertFrom-Json

function Extract-Principle {
    param($Pattern, $Mechanism)

    # Generate principle ID
    $PrincipleId = "P-" + (Get-Date -Format "yyyyMMdd-HHmmss")

    # Prompt for principle extraction (this is where LLM reasoning happens in real implementation)
    # For now, store as proposed principle requiring validation

    if (-not $Silent) {
        Write-Host ""
        Write-Host "=== PRINCIPLE EXTRACTION ===" -ForegroundColor Cyan
        Write-Host "Pattern: $Pattern"
        Write-Host "Mechanism: $Mechanism"
        Write-Host ""
        Write-Host "EXTRACTION QUESTIONS:" -ForegroundColor Yellow
        Write-Host "1. What deeper rule generates this pattern?"
        Write-Host "2. Why does this mechanism work?"
        Write-Host "3. What other patterns could this principle generate?"
        Write-Host "4. Is this principle or just restated mechanism?"
        Write-Host ""
        Write-Host "Enter proposed principle (or empty to skip):" -ForegroundColor Yellow
        $ProposedPrinciple = Read-Host
    }

    if ([string]::IsNullOrWhiteSpace($ProposedPrinciple)) {
        Write-Host "Extraction cancelled" -ForegroundColor Red
        return
    }

    # Create principle entry
    $NewPrinciple = @{
        id = $PrincipleId
        pattern = $Pattern
        mechanism = $Mechanism
        principle = $ProposedPrinciple
        status = "proposed"
        extracted_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        validations = @()
        confidence = 0.0
        abstraction_level = "unknown"
    }

    # Add to state
    $State.principles += $NewPrinciple
    $State.extraction_count++

    # Save
    $State | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8

    if (-not $Silent) {
        Write-Host ""
        Write-Host "[SUCCESS] Principle extracted: $PrincipleId" -ForegroundColor Green
        Write-Host "Status: PROPOSED (needs validation across 3+ domains)"
        Write-Host ""
        Write-Host "Next: Use -Action Validate -PrincipleId $PrincipleId -ValidationDomains @('domain1','domain2','domain3')"
    }

    return $PrincipleId
}

function Validate-Principle {
    param($PrincipleId, $ValidationDomains)

    $Principle = $State.principles | Where-Object { $_.id -eq $PrincipleId }

    if (-not $Principle) {
        Write-Host "[ERROR] Principle not found: $PrincipleId" -ForegroundColor Red
        return
    }

    if (-not $Silent) {
        Write-Host ""
        Write-Host "=== PRINCIPLE VALIDATION ===" -ForegroundColor Cyan
        Write-Host "Principle: $($Principle.principle)"
        Write-Host ""
        Write-Host "Validation: Does this principle apply in OTHER domains?" -ForegroundColor Yellow
        Write-Host ""
    }

    $ValidationResults = @()

    foreach ($Domain in $ValidationDomains) {
        if (-not $Silent) {
            Write-Host "Domain: $Domain" -ForegroundColor White
            Write-Host "Does principle apply here? (yes/no/partial):" -ForegroundColor Yellow
            $Result = Read-Host
            Write-Host "Evidence/Example:" -ForegroundColor Yellow
            $Evidence = Read-Host
        }

        $ValidationResults += @{
            domain = $Domain
            result = $Result
            evidence = $Evidence
            validated_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        }
    }

    # Update principle
    $Principle.validations = $ValidationResults

    # Calculate confidence
    $SuccessCount = ($ValidationResults | Where-Object { $_.result -eq 'yes' }).Count
    $PartialCount = ($ValidationResults | Where-Object { $_.result -eq 'partial' }).Count
    $TotalCount = $ValidationResults.Count

    if ($TotalCount -gt 0) {
        $Confidence = ($SuccessCount + 0.5 * $PartialCount) / $TotalCount
        $Principle.confidence = [math]::Round($Confidence, 2)
    }

    # Update status
    if ($Principle.confidence -ge 0.7 -and $TotalCount -ge 3) {
        $Principle.status = "validated"
        $State.validated_principles++
    } elseif ($TotalCount -ge 3) {
        $Principle.status = "rejected"
    } else {
        $Principle.status = "partial_validation"
    }

    $State.validation_attempts++

    # Determine abstraction level
    if ($Principle.confidence -ge 0.8) {
        $Principle.abstraction_level = "principle"
    } elseif ($Principle.confidence -ge 0.5) {
        $Principle.abstraction_level = "pattern"
    } else {
        $Principle.abstraction_level = "mechanism"
    }

    # Save
    $State | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8

    if (-not $Silent) {
        Write-Host ""
        Write-Host "[VALIDATION COMPLETE]" -ForegroundColor Green
        Write-Host "Status: $($Principle.status)"
        Write-Host "Confidence: $($Principle.confidence * 100)%"
        Write-Host "Abstraction Level: $($Principle.abstraction_level)"
        Write-Host ""
    }

    return $Principle.status
}

function List-Principles {
    if ($State.principles.Count -eq 0) {
        Write-Host "No principles extracted yet" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "=== EXTRACTED PRINCIPLES ===" -ForegroundColor Cyan
    Write-Host ""

    $Validated = $State.principles | Where-Object { $_.status -eq 'validated' } | Sort-Object -Property confidence -Descending
    $Proposed = $State.principles | Where-Object { $_.status -eq 'proposed' }
    $Rejected = $State.principles | Where-Object { $_.status -eq 'rejected' }

    if ($Validated.Count -gt 0) {
        Write-Host "VALIDATED PRINCIPLES ($($Validated.Count)):" -ForegroundColor Green
        foreach ($P in $Validated) {
            Write-Host "  [$($P.id)] $($P.principle)" -ForegroundColor White
            Write-Host "    Confidence: $($P.confidence * 100)%  |  Level: $($P.abstraction_level)" -ForegroundColor Gray
            Write-Host "    Validated in: $($P.validations.domain -join ', ')" -ForegroundColor Gray
            Write-Host ""
        }
    }

    if ($Proposed.Count -gt 0) {
        Write-Host "PROPOSED (Needs Validation) ($($Proposed.Count)):" -ForegroundColor Yellow
        foreach ($P in $Proposed) {
            Write-Host "  [$($P.id)] $($P.principle)" -ForegroundColor White
            Write-Host "    From Pattern: $($P.pattern)" -ForegroundColor Gray
            Write-Host ""
        }
    }

    if ($Rejected.Count -gt 0) {
        Write-Host "REJECTED (Failed Validation) ($($Rejected.Count)):" -ForegroundColor Red
        foreach ($P in $Rejected) {
            Write-Host "  [$($P.id)] $($P.principle)" -ForegroundColor White
            Write-Host "    Confidence: $($P.confidence * 100)%" -ForegroundColor Gray
            Write-Host ""
        }
    }

    Write-Host "STATISTICS:" -ForegroundColor Cyan
    Write-Host "  Total Extracted: $($State.extraction_count)"
    Write-Host "  Validated: $($State.validated_principles)"
    Write-Host "  Validation Rate: $(if ($State.validation_attempts -gt 0) { [math]::Round($State.validated_principles / $State.validation_attempts * 100, 1) } else { 0 })%"
    Write-Host ""
}

function Show-Hierarchy {
    Write-Host ""
    Write-Host "=== ABSTRACTION HIERARCHY ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Level 1: OBSERVATIONS" -ForegroundColor Gray
    Write-Host "  - Raw data, events, occurrences"
    Write-Host ""
    Write-Host "Level 2: PATTERNS" -ForegroundColor White
    Write-Host "  - Recurring observations"
    Write-Host "  - Statistical regularities"
    $Patterns = $State.principles | Where-Object { $_.abstraction_level -eq 'pattern' }
    if ($Patterns) {
        foreach ($P in $Patterns) {
            Write-Host "  * $($P.principle)" -ForegroundColor Gray
        }
    }
    Write-Host ""
    Write-Host "Level 3: MECHANISMS" -ForegroundColor White
    Write-Host "  - HOW things work"
    Write-Host "  - Process descriptions"
    $Mechanisms = $State.principles | Where-Object { $_.abstraction_level -eq 'mechanism' }
    if ($Mechanisms) {
        foreach ($M in $Mechanisms) {
            Write-Host "  * $($M.principle)" -ForegroundColor Gray
        }
    }
    Write-Host ""
    Write-Host "Level 4: PRINCIPLES" -ForegroundColor Green
    Write-Host "  - WHY mechanisms work"
    Write-Host "  - Deep rules that generate patterns"
    Write-Host "  - Validated across 3+ domains"
    $Principles = $State.principles | Where-Object { $_.abstraction_level -eq 'principle' }
    if ($Principles) {
        foreach ($P in $Principles) {
            Write-Host "  * $($P.principle)" -ForegroundColor Green
        }
    }
    Write-Host ""
    Write-Host "Level 5: META-PRINCIPLES" -ForegroundColor Cyan
    Write-Host "  - Principles about principles"
    Write-Host "  - Universal rules"
    Write-Host "  * Heuristic of Superiority: Understanding principles > Copying mechanisms" -ForegroundColor Cyan
    Write-Host "  * Abstraction Power: Higher abstraction levels generate more patterns" -ForegroundColor Cyan
    Write-Host ""
}

# Execute action
switch ($Action) {
    'Extract' {
        if ([string]::IsNullOrWhiteSpace($Pattern) -or [string]::IsNullOrWhiteSpace($Mechanism)) {
            Write-Host "[ERROR] -Pattern and -Mechanism required for extraction" -ForegroundColor Red
            exit 1
        }
        Extract-Principle -Pattern $Pattern -Mechanism $Mechanism
    }
    'Validate' {
        if ([string]::IsNullOrWhiteSpace($PrincipleId) -or $ValidationDomains.Count -eq 0) {
            Write-Host "[ERROR] -PrincipleId and -ValidationDomains required for validation" -ForegroundColor Red
            exit 1
        }
        Validate-Principle -PrincipleId $PrincipleId -ValidationDomains $ValidationDomains
    }
    'List' {
        List-Principles
    }
    'Hierarchy' {
        Show-Hierarchy
    }
}
