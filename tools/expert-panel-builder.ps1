# expert-panel-builder.ps1
# Identifies relevant experts for a given task and simulates their perspectives
# Part of the Expert Panel System for multi-perspective analysis

param(
    [Parameter(Mandatory=$true)]
    [string]$TaskDescription,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Simple", "Moderate", "Complex", "Enterprise")]
    [string]$Complexity = "Moderate",

    [Parameter(Mandatory=$false)]
    [int]$MaxExperts = 0,  # 0 = use complexity default

    [Parameter(Mandatory=$false)]
    [switch]$DetailedOutput,

    [Parameter(Mandatory=$false)]
    [string]$OutputFile
)

$ErrorActionPreference = "Stop"

# Load expert domains database
$expertDomainsPath = "C:\scripts\agentidentity\state\expert-domains.json"
if (-not (Test-Path $expertDomainsPath)) {
    Write-Error "Expert domains database not found at: $expertDomainsPath"
    exit 1
}

$expertData = Get-Content $expertDomainsPath -Raw | ConvertFrom-Json

# Determine panel size
if ($MaxExperts -eq 0) {
    $MaxExperts = switch ($Complexity) {
        "Simple" { 3 }
        "Moderate" { 5 }
        "Complex" { 7 }
        "Enterprise" { 10 }
    }
}

Write-Host "`n[EXPERT PANEL BUILDER]" -ForegroundColor Cyan
Write-Host "Task: $TaskDescription"
Write-Host "Complexity: $Complexity (Max $MaxExperts experts)`n"

# Normalize task for matching
$taskLower = $TaskDescription.ToLower()

# Scoring function
function Get-ExpertRelevanceScore {
    param($expert, $triggers)

    $score = 0

    foreach ($trigger in $triggers) {
        if ($taskLower -match "\b$trigger\b") {
            $score += 10
        } elseif ($taskLower -match $trigger) {
            $score += 5
        }
    }

    return $score
}

# Collect all candidates with scores
$candidates = @()

# Domain experts
foreach ($expert in $expertData.domainExperts) {
    $score = Get-ExpertRelevanceScore -expert $expert -triggers $expert.domains
    if ($score -gt 0) {
        $candidates += @{
            Name = $expert.name
            Type = "Domain"
            Score = $score
            Expertise = $expert.expertise
        }
    }
}

# Role experts
foreach ($expert in $expertData.roleExperts) {
    $score = Get-ExpertRelevanceScore -expert $expert -triggers $expert.triggers
    if ($score -gt 0) {
        $candidates += @{
            Name = $expert.name
            Type = "Role"
            Score = $score
            Expertise = $expert.expertise
        }
    }
}

# Process experts
foreach ($expert in $expertData.processExperts) {
    $score = Get-ExpertRelevanceScore -expert $expert -triggers $expert.triggers
    if ($score -gt 0) {
        $candidates += @{
            Name = $expert.name
            Type = "Process"
            Score = $score
            Expertise = $expert.expertise
        }
    }
}

# Sort by score and select top N
$selectedExperts = $candidates | Sort-Object -Property Score -Descending | Select-Object -First $MaxExperts

if ($selectedExperts.Count -eq 0) {
    Write-Host "[WARNING] No experts matched. Using default panel..." -ForegroundColor Yellow
    # Default panel: Designer, Copywriter, SEO
    $selectedExperts = @(
        @{
            Name = "Web Designer (UI/UX)"
            Type = "Role"
            Score = 0
            Expertise = $expertData.roleExperts | Where-Object { $_.name -eq "Web Designer (UI/UX)" } | Select-Object -ExpandProperty expertise
        },
        @{
            Name = "Copywriter"
            Type = "Role"
            Score = 0
            Expertise = $expertData.roleExperts | Where-Object { $_.name -eq "Copywriter" } | Select-Object -ExpandProperty expertise
        },
        @{
            Name = "SEO Specialist"
            Type = "Role"
            Score = 0
            Expertise = $expertData.roleExperts | Where-Object { $_.name -eq "SEO Specialist" } | Select-Object -ExpandProperty expertise
        }
    )
}

# Display selected panel
Write-Host "[EXPERT PANEL ASSEMBLED]" -ForegroundColor Green
Write-Host "Total experts: $($selectedExperts.Count)`n"

$expertSummaries = @()

foreach ($expert in $selectedExperts) {
    Write-Host "[$($expert.Type.ToUpper())] $($expert.Name)" -ForegroundColor Cyan
    Write-Host "  Relevance Score: $($expert.Score)"
    Write-Host "  Key Expertise:"

    $topExpertise = $expert.Expertise | Select-Object -First 5
    foreach ($item in $topExpertise) {
        Write-Host "    - $item" -ForegroundColor Gray
    }
    Write-Host ""

    # Collect for output
    $expertSummaries += @{
        Name = $expert.Name
        Type = $expert.Type
        RelevanceScore = $expert.Score
        Expertise = $expert.Expertise
    }
}

# Generate consultation prompts
Write-Host "`n[CONSULTATION PROMPTS]" -ForegroundColor Magenta
Write-Host "Use these prompts to think from each expert's perspective:`n"

$consultationPrompts = @()

foreach ($expert in $selectedExperts) {
    $prompt = "As a $($expert.Name), what are the 3 most important considerations for: '$TaskDescription'?"
    Write-Host "- $prompt" -ForegroundColor Yellow

    $consultationPrompts += @{
        Expert = $expert.Name
        Prompt = $prompt
    }
}

# Integration advice
Write-Host "`n[INTEGRATION STRATEGY]" -ForegroundColor Magenta
Write-Host "Synthesis approach:"
Write-Host "  1. Consult each expert sequentially (collect perspectives)"
Write-Host "  2. Identify overlapping recommendations (high confidence)"
Write-Host "  3. Resolve conflicts (trade-offs, priorities)"
Write-Host "  4. Create unified action plan (integrated advice)"
Write-Host ""

# Build result object
$result = @{
    Task = $TaskDescription
    Complexity = $Complexity
    MaxExperts = $MaxExperts
    ExpertPanel = $expertSummaries
    ConsultationPrompts = $consultationPrompts
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

# Output to file if requested
if ($OutputFile) {
    $result | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Host "[SAVED] Expert panel details: $OutputFile" -ForegroundColor Green
}

# Return result for pipeline use
return $result
