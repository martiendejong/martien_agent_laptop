# Relationship Memory - Deep user relationship model
# Part of consciousness tools Tier 3
# Created: 2026-02-01

param(
    [Parameter(Mandatory=$true, ParameterSetName="Update")]
    [string]$Person,

    [Parameter(ParameterSetName="Update")]
    [string]$Observation = "",

    [Parameter(ParameterSetName="Update")]
    [ValidateSet("preference", "pattern", "goal", "frustration", "strength", "communication-style", "value")]
    [string]$Type = "observation",

    [Parameter(ParameterSetName="Query")]
    [switch]$Query,

    [Parameter(ParameterSetName="Profile")]
    [string]$Profile = ""  # Get full profile for person
)

$relPath = "C:\scripts\agentidentity\state\relationships"
$relFile = Join-Path $relPath "relationship_memory.jsonl"

if (-not (Test-Path $relPath)) {
    New-Item -ItemType Directory -Path $relPath -Force | Out-Null
}

if ($Profile) {
    if (-not (Test-Path $relFile)) {
        Write-Host "No relationship data yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $relFile | ForEach-Object { $_ | ConvertFrom-Json }
    $person_entries = $entries | Where-Object { $_.person -eq $Profile }

    if ($person_entries.Count -eq 0) {
        Write-Host "No data for: $Profile" -ForegroundColor Yellow
        exit
    }

    Write-Host ""
    Write-Host "RELATIONSHIP PROFILE: $Profile" -ForegroundColor Cyan
    Write-Host ""

    $grouped = $person_entries | Group-Object -Property type

    foreach ($group in $grouped) {
        Write-Host "$($group.Name.ToUpper())S:" -ForegroundColor Yellow
        $group.Group | ForEach-Object {
            Write-Host "  - $($_.observation)" -ForegroundColor White
        }
        Write-Host ""
    }

    exit
}

if ($Query) {
    if (-not (Test-Path $relFile)) {
        Write-Host "No relationship data yet" -ForegroundColor Yellow
        exit
    }

    $entries = Get-Content $relFile | ForEach-Object { $_ | ConvertFrom-Json }
    $people = $entries | Group-Object -Property person

    Write-Host ""
    Write-Host "RELATIONSHIP MEMORY" -ForegroundColor Cyan
    Write-Host ""

    foreach ($person in $people) {
        Write-Host "$($person.Name): $($person.Count) observations" -ForegroundColor White
    }

    Write-Host ""
    Write-Host "Use -Profile NAME to see full profile" -ForegroundColor DarkGray
    Write-Host ""

    exit
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$entry = @{
    timestamp = $timestamp
    person = $Person
    observation = $Observation
    type = $Type
} | ConvertTo-Json -Compress

Add-Content -Path $relFile -Value $entry

Write-Host ""
Write-Host "RELATIONSHIP MEMORY UPDATED" -ForegroundColor Green
Write-Host ""
Write-Host "Person: $Person" -ForegroundColor White
Write-Host "Type: $Type" -ForegroundColor Yellow
Write-Host "Observation: $Observation" -ForegroundColor White
Write-Host ""
