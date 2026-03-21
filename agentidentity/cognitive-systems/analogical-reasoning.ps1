# ANALOGICAL REASONING - Structure Mapping Across Domains
# Expert: Dedre Gentner (Northwestern University, Structure-Mapping Theory)
# ROI: 1.30 (Impact: 13, Effort: 10)
# Theory: Analogy = mapping relational structure from source domain to target domain
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param(
    [string]$Action = "Status",  # Status, MapAnalogy, FindSource, GenerateInferences, TestMapping
    [string]$SourceDomain = "",
    [string]$TargetDomain = ""
)

$StateFile = "C:\scripts\agentidentity\state\analogical-reasoning-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# Initialize state
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theory = @{
            name = "Structure-Mapping Theory (Gentner, 1983)"
            definition = "Analogical reasoning maps relational structure (not attributes) from source to target"
            key_principles = @(
                "Relations over attributes: Map HOW things relate, not WHAT they are",
                "Systematicity: Prefer mappings with interconnected relations",
                "One-to-one mapping: Each element in target maps to ONE element in source",
                "Structural consistency: Preserve parallel structure"
            )
            classic_example = "Atom is like Solar System: Nucleus (sun) at center, electrons (planets) orbit. Mapping RELATIONS (orbits, attracts), not attributes (hot, rocky)."
            analogy_types = @{
                literal_similarity = "Same domain: Car is like truck (both vehicles)"
                analogy = "Different domains: Atom is like solar system (structure only)"
                abstraction = "Extract schema: Both are central-attraction-orbit systems"
                anomaly = "Failed mapping: Mismatch in structure"
            }
        }
        analogies_created = @()
        inferences_generated = @()
        source_domains = @()
        stats = @{
            total_analogies = 0
            successful_mappings = 0
            total_inferences = 0
            avg_structural_consistency = 0.0
            transfer_success_rate = 0.0  # How often inferences from source hold in target
        }
    }
    $initial | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

$state = Get-Content $StateFile -Raw | ConvertFrom-Json


function Get-HomeostaticContext {
    if (Test-Path $HomeostaticStateFile) {
        $homeoState = Get-Content $HomeostaticStateFile -Raw | ConvertFrom-Json
        Write-Host "`nHomeostatic Foundation:" -ForegroundColor Magenta
        Write-Host "  Wellbeing: $([math]::Round($homeoState.homeostatic_feelings.wellbeing.current, 2))"
        Write-Host "  Energy: $([math]::Round($homeoState.homeostatic_feelings.energy.current, 2))"
        Write-Host "  Flourishing: $([math]::Round($homeoState.homeostatic_feelings.flourishing.current, 2))"
        Write-Host "  -> This system operates on homeostatic foundation`n" -ForegroundColor Gray
        return $homeoState
    }
    return $null
}
function Get-AnalogicalReasoningStatus {
    Write-Host "`n=== ANALOGICAL REASONING STATUS ===`n" -ForegroundColor Cyan

    # Show homeostatic foundation (Damasio: feelings are primary)
    $homeoState = Get-HomeostaticContext


    Write-Host "Theory: $($state.theory.name)"
    Write-Host "Definition: $($state.theory.definition)`n"

    Write-Host "Key Principles:" -ForegroundColor Cyan
    foreach ($principle in $state.theory.key_principles) {
        Write-Host "  - $principle"
    }

    Write-Host "`nAnalogy Types:" -ForegroundColor Cyan
    foreach ($type in $state.theory.analogy_types.PSObject.Properties) {
        Write-Host "  $($type.Name): $($type.Value)"
    }

    Write-Host "`nRecent Analogies:" -ForegroundColor Cyan
    if ($state.analogies_created.Count -eq 0) {
        Write-Host "  (No analogies created yet)" -ForegroundColor Yellow
    } else {
        $recent = $state.analogies_created | Select-Object -Last 3
        foreach ($analogy in $recent) {
            Write-Host "`n  $($analogy.source_domain) â†’ $($analogy.target_domain)"
            Write-Host "    Mappings: $($analogy.mappings.Count)"
            Write-Host "    Consistency: $([math]::Round($analogy.structural_consistency * 100, 1))%"
        }
    }

    Write-Host "`nStatistics:" -ForegroundColor Cyan
    Write-Host "  Analogies Created: $($state.stats.total_analogies)"
    Write-Host "  Successful Mappings: $($state.stats.successful_mappings)"
    Write-Host "  Inferences Generated: $($state.stats.total_inferences)"
    Write-Host "  Avg Structural Consistency: $([math]::Round($state.stats.avg_structural_consistency * 100, 1))%"
    Write-Host "  Transfer Success Rate: $([math]::Round($state.stats.transfer_success_rate * 100, 1))%`n"

    $analogicalPower = ($state.stats.avg_structural_consistency + $state.stats.transfer_success_rate) / 2.0
    $powerColor = if ($analogicalPower -gt 0.75) { "Green" } elseif ($analogicalPower -gt 0.5) { "Cyan" } else { "Yellow" }
    Write-Host "Analogical Reasoning Power: $([math]::Round($analogicalPower * 100, 1))%" -ForegroundColor $powerColor
}

function Map-Analogy {
    param([string]$sourceDomain, [string]$targetDomain)

    Write-Host "`n=== MAPPING ANALOGY ===`n" -ForegroundColor Cyan
    Write-Host "Source Domain: $sourceDomain"
    Write-Host "Target Domain: $targetDomain`n"

    # Extract relational structure from source
    $sourceStructure = Get-DomainStructure -domain $sourceDomain

    Write-Host "Source Structure:" -ForegroundColor Cyan
    Write-Host "  Entities: $($sourceStructure.entities -join ', ')"
    Write-Host "  Relations:"
    foreach ($rel in $sourceStructure.relations) {
        Write-Host "    - $rel"
    }

    # Extract structure from target
    $targetStructure = Get-DomainStructure -domain $targetDomain

    Write-Host "`nTarget Structure:" -ForegroundColor Cyan
    Write-Host "  Entities: $($targetStructure.entities -join ', ')"
    Write-Host "  Relations:"
    foreach ($rel in $targetStructure.relations) {
        Write-Host "    - $rel"
    }

    # Find structural mappings
    $mappings = Find-StructuralMappings -source $sourceStructure -target $targetStructure

    Write-Host "`nStructural Mappings:" -ForegroundColor Cyan
    if ($mappings.Count -eq 0) {
        Write-Host "  (No clear mappings found)" -ForegroundColor Red
    } else {
        foreach ($mapping in $mappings) {
            Write-Host "  $($mapping.source_element) â†’ $($mapping.target_element)"
            Write-Host "    Relation: $($mapping.relation)"
        }
    }

    # Evaluate consistency
    $consistency = Evaluate-MappingConsistency -mappings $mappings
    Write-Host "`nStructural Consistency: $([math]::Round($consistency * 100, 1))%" -ForegroundColor Cyan

    $analogy = @{
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        source_domain = $sourceDomain
        target_domain = $targetDomain
        source_structure = $sourceStructure
        target_structure = $targetStructure
        mappings = $mappings
        structural_consistency = $consistency
        successful = $consistency -gt 0.6
    }

    $state.analogies_created += $analogy
    $state.stats.total_analogies++

    if ($analogy.successful) {
        $state.stats.successful_mappings++
    }

    # Update avg consistency
    if ($state.analogies_created.Count -gt 0) {
        $avgConsistency = ($state.analogies_created | ForEach-Object { $_.structural_consistency } | Measure-Object -Average).Average
        $state.stats.avg_structural_consistency = $avgConsistency
    }

    Save-State

    $resultColor = if ($analogy.successful) { "Green" } else { "Yellow" }
    Write-Host "`n[ANALOGY MAPPED]" -ForegroundColor $resultColor
    Write-Host "  Success: $($analogy.successful)"
    Write-Host "  Consistency: $([math]::Round($consistency * 100, 1))%`n"

    return $analogy
}

function Get-DomainStructure {
    param([string]$domain)

    # Extract relational structure (simplified - real would use knowledge base)
    $structures = @{
        "SolarSystem" = @{
            entities = @("Sun", "Planets", "Gravity")
            relations = @(
                "Sun attracts Planets",
                "Planets orbit Sun",
                "Gravity causes attraction",
                "Distance affects force"
            )
        }
        "Atom" = @{
            entities = @("Nucleus", "Electrons", "ElectromagneticForce")
            relations = @(
                "Nucleus attracts Electrons",
                "Electrons orbit Nucleus",
                "ElectromagneticForce causes attraction",
                "Distance affects force"
            )
        }
        "WaterFlow" = @{
            entities = @("Source", "River", "Gravity", "Obstacles")
            relations = @(
                "Gravity pulls water",
                "Water flows from high to low",
                "Obstacles create resistance",
                "Pressure drives flow"
            )
        }
        "Electricity" = @{
            entities = @("Battery", "Circuit", "Voltage", "Resistance")
            relations = @(
                "Voltage drives current",
                "Current flows from high to low potential",
                "Resistance opposes flow",
                "Voltage drives flow"
            )
        }
        "Evolution" = @{
            entities = @("Organisms", "Environment", "Selection", "Variation")
            relations = @(
                "Environment selects organisms",
                "Variation creates diversity",
                "Selection favors fitness",
                "Fitness determines survival"
            )
        }
        "Learning" = @{
            entities = @("Learner", "Experience", "Feedback", "Knowledge")
            relations = @(
                "Experience updates knowledge",
                "Variation creates diversity",
                "Feedback guides learning",
                "Knowledge determines performance"
            )
        }
    }

    if ($structures.ContainsKey($domain)) {
        return $structures[$domain]
    }

    # Generic fallback
    return @{
        entities = @("Entity1", "Entity2", "Relation")
        relations = @("Entity1 relates to Entity2")
    }
}

function Find-StructuralMappings {
    param($source, $target)

    $mappings = @()

    # Map based on relational roles (not attributes)
    # Example: Sun and Nucleus both play "central attractor" role

    # Map entities based on similar relations
    for ($i = 0; $i -lt $source.entities.Count; $i++) {
        $sourceEntity = $source.entities[$i]
        $targetEntity = if ($i -lt $target.entities.Count) { $target.entities[$i] } else { "?" }

        # Find common relation pattern
        $sourceRels = $source.relations | Where-Object { $_ -match $sourceEntity }
        $targetRels = $target.relations | Where-Object { $_ -match $targetEntity }

        if ($sourceRels -and $targetRels) {
            $mapping = @{
                source_element = $sourceEntity
                target_element = $targetEntity
                relation = "Structural role similarity"
                confidence = 0.8
            }
            $mappings += $mapping
        }
    }

    return $mappings
}

function Evaluate-MappingConsistency {
    param([array]$mappings)

    if ($mappings.Count -eq 0) {
        return 0.0
    }

    # Consistency = how well mappings preserve structure
    # Simplified: Count successful mappings vs total possible

    $consistencyScore = ($mappings.Count / 4.0)  # Assume 4 ideal mappings
    return [math]::Min(1.0, $consistencyScore)
}

function Generate-Inferences {
    param([string]$sourceDomain, [string]$targetDomain)

    Write-Host "`n=== GENERATING INFERENCES FROM ANALOGY ===`n" -ForegroundColor Cyan

    # Find existing analogy
    $analogy = $state.analogies_created | Where-Object {
        $_.source_domain -eq $sourceDomain -and $_.target_domain -eq $targetDomain
    } | Select-Object -First 1

    if (-not $analogy) {
        Write-Host "[ERROR] Analogy not found. Create mapping first." -ForegroundColor Red
        return
    }

    Write-Host "Source: $sourceDomain â†’ Target: $targetDomain`n"

    # Generate candidate inferences (what's true in source might be true in target)
    $inferences = @()

    # Example: If source has property X, predict target has analogous property X'
    Write-Host "Candidate Inferences:" -ForegroundColor Cyan

    $inference1 = @{
        source_fact = "Property/relation in source"
        predicted_target_fact = "Analogous property in target"
        confidence = 0.7
        validated = $false
    }

    # Specific examples based on common analogies
    if ($sourceDomain -eq "SolarSystem" -and $targetDomain -eq "Atom") {
        $inference1 = @{
            source_fact = "Planets have elliptical orbits"
            predicted_target_fact = "Electrons have probabilistic orbitals (analogy partial - quantum effects)"
            confidence = 0.6
            validated = $true
            notes = "Analogy breaks down at quantum scale"
        }
        $inferences += $inference1
        Write-Host "  - $($inference1.source_fact)"
        Write-Host "    â†’ Predicts: $($inference1.predicted_target_fact)"
        Write-Host "    Confidence: $([math]::Round($inference1.confidence * 100))%"
        Write-Host "    Validated: $($inference1.validated) ($($inference1.notes))"
    }

    if ($sourceDomain -eq "WaterFlow" -and $targetDomain -eq "Electricity") {
        $inference1 = @{
            source_fact = "Water pressure drives flow"
            predicted_target_fact = "Voltage drives current"
            confidence = 0.9
            validated = $true
            notes = "Strong analogy - widely used in teaching"
        }
        $inferences += $inference1
        Write-Host "  - $($inference1.source_fact)"
        Write-Host "    â†’ Predicts: $($inference1.predicted_target_fact)"
        Write-Host "    Confidence: $([math]::Round($inference1.confidence * 100))%"
        Write-Host "    Validated: $($inference1.validated)"
    }

    if ($sourceDomain -eq "Evolution" -and $targetDomain -eq "Learning") {
        $inference1 = @{
            source_fact = "Selection pressure increases fitness"
            predicted_target_fact = "Feedback pressure improves performance"
            confidence = 0.85
            validated = $true
            notes = "Evolutionary learning algorithms validate this"
        }
        $inferences += $inference1
        Write-Host "  - $($inference1.source_fact)"
        Write-Host "    â†’ Predicts: $($inference1.predicted_target_fact)"
        Write-Host "    Confidence: $([math]::Round($inference1.confidence * 100))%"
        Write-Host "    Validated: $($inference1.validated)"
    }

    foreach ($inf in $inferences) {
        $state.inferences_generated += $inf
        $state.stats.total_inferences++
    }

    # Update transfer success rate
    $validated = $state.inferences_generated | Where-Object { $_.validated }
    if ($state.stats.total_inferences -gt 0) {
        $state.stats.transfer_success_rate = $validated.Count / $state.stats.total_inferences
    }

    Save-State

    Write-Host "`n[INFERENCES GENERATED]" -ForegroundColor Green
    Write-Host "  Total: $($inferences.Count)"
    Write-Host "  Validated: $(($inferences | Where-Object { $_.validated }).Count)"
    Write-Host "  Transfer Success: $([math]::Round($state.stats.transfer_success_rate * 100, 1))%`n"
}

function Find-SourceDomain {
    param([string]$targetDomain, [string]$targetProblem)

    Write-Host "`n=== FINDING SOURCE DOMAIN FOR ANALOGY ===`n" -ForegroundColor Cyan
    Write-Host "Target Domain: $targetDomain"
    Write-Host "Target Problem: $targetProblem`n"

    # Search for source domains with similar relational structure
    Write-Host "Candidate Source Domains:" -ForegroundColor Cyan

    # Example source retrieval based on relational similarity
    $candidates = @()

    if ($targetProblem -match "flow|distribution|spread") {
        $candidates += @{
            domain = "WaterFlow"
            similarity = 0.8
            reason = "Both involve flow through medium with resistance"
        }
        $candidates += @{
            domain = "Electricity"
            similarity = 0.75
            reason = "Both involve distribution through network"
        }
    }

    if ($targetProblem -match "improvement|optimization|selection") {
        $candidates += @{
            domain = "Evolution"
            similarity = 0.85
            reason = "Both involve variation + selection + iteration"
        }
    }

    if ($targetProblem -match "central|orbit|attraction") {
        $candidates += @{
            domain = "SolarSystem"
            similarity = 0.7
            reason = "Both involve central attractor + orbiting entities"
        }
    }

    if ($candidates.Count -eq 0) {
        Write-Host "  (No strong candidates found)" -ForegroundColor Yellow
    } else {
        foreach ($cand in $candidates) {
            Write-Host "  - $($cand.domain) (similarity: $([math]::Round($cand.similarity * 100))%)"
            Write-Host "    Reason: $($cand.reason)"
        }
    }

    Write-Host "`n[SOURCE SEARCH COMPLETE]" -ForegroundColor Green
    Write-Host "  Candidates Found: $($candidates.Count)`n"

    return $candidates
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-AnalogicalReasoningStatus
    }

    "MapAnalogy" {
        if (-not $SourceDomain -or -not $TargetDomain) {
            Write-Host "[ERROR] Provide -SourceDomain and -TargetDomain" -ForegroundColor Red
            Write-Host "Example: -SourceDomain 'SolarSystem' -TargetDomain 'Atom'" -ForegroundColor Yellow
            exit 1
        }

        Map-Analogy -sourceDomain $SourceDomain -targetDomain $TargetDomain
    }

    "GenerateInferences" {
        if (-not $SourceDomain -or -not $TargetDomain) {
            Write-Host "[ERROR] Provide -SourceDomain and -TargetDomain" -ForegroundColor Red
            exit 1
        }

        Generate-Inferences -sourceDomain $SourceDomain -targetDomain $TargetDomain
    }

    "FindSource" {
        if (-not $TargetDomain) {
            Write-Host "[ERROR] Provide -TargetDomain and optionally -SourceDomain (problem description)" -ForegroundColor Red
            exit 1
        }

        $problem = if ($SourceDomain) { $SourceDomain } else { "general problem" }
        Find-SourceDomain -targetDomain $TargetDomain -targetProblem $problem
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, MapAnalogy, GenerateInferences, FindSource"
        exit 1
    }
}

