<#
.SYNOPSIS
Entity Binding System - Layer 1 of World Model Architecture

.DESCRIPTION
Binds observed features into coherent entities with persistent IDs.
Implements object permanence - entities exist even when not observed.

Solves the "binding problem": red + round + rolling = BALL (not separate features)

.PARAMETER Action
BindEntity, GetEntity, UpdateEntity, QueryEntities, CheckPermanence

.EXAMPLE
.\entity-binding-system.ps1 -Action BindEntity -Type "file" -Features @{path="foo.cs"; size=1024}
# Creates or updates file entity, returns ID

.EXAMPLE
.\entity-binding-system.ps1 -Action GetEntity -ID "entity-file-12345"
# Retrieves entity by ID with all features

.EXAMPLE
.\entity-binding-system.ps1 -Action CheckPermanence -Type "file" -Path "foo.cs"
# Returns: exists, occluded, deleted, predicted

.NOTES
Created: 2026-02-27
Status: Foundation (Week 1)
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("BindEntity", "GetEntity", "UpdateEntity", "QueryEntities", "CheckPermanence", "Stats", "Validate")]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$ID,

    [Parameter(Mandatory=$false)]
    [ValidateSet("file", "project", "user_state", "build", "pr", "test", "api_call", "error")]
    [string]$Type,

    [Parameter(Mandatory=$false)]
    [hashtable]$Features,

    [Parameter(Mandatory=$false)]
    [string]$Path,  # For file entities

    [Parameter(Mandatory=$false)]
    [hashtable]$Query  # For QueryEntities
)

# State file location
$registryPath = "C:\scripts\agentidentity\state\entity-registry.json"
$observationsPath = "C:\scripts\agentidentity\state\world-model-observations.jsonl"

# Ensure state directory exists
$stateDir = Split-Path $registryPath -Parent
if (-not (Test-Path $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}

# Load entity registry
function Load-EntityRegistry {
    if (Test-Path $registryPath) {
        $content = Get-Content $registryPath -Raw
        if ($content) {
            return $content | ConvertFrom-Json
        }
    }

    # Initialize empty registry
    return @{
        entities = @()
        index = @{
            by_type = @{}
            by_feature = @{}
        }
        metadata = @{
            total_entities = 0
            total_observations = 0
            created = (Get-Date).ToUniversalTime().ToString("o")
            last_updated = (Get-Date).ToUniversalTime().ToString("o")
        }
    }
}

# Save entity registry
function Save-EntityRegistry {
    param($registry)

    $registry.metadata.last_updated = (Get-Date).ToUniversalTime().ToString("o")
    $json = $registry | ConvertTo-Json -Depth 10 -Compress
    $json | Set-Content $registryPath -Force
}

# Log observation to JSONL
function Log-Observation {
    param(
        [string]$entityID,
        [string]$type,
        [hashtable]$features,
        [string]$event
    )

    $observation = @{
        timestamp = (Get-Date).ToUniversalTime().ToString("o")
        entity_id = $entityID
        type = $type
        event = $event  # created, updated, occluded, observed, deleted
        features = $features
    }

    $json = $observation | ConvertTo-Json -Depth 5 -Compress
    $json | Add-Content $observationsPath -Force
}

# Generate entity ID
function New-EntityID {
    param([string]$type)
    $guid = [guid]::NewGuid().ToString("N").Substring(0, 8)
    return "entity-$type-$guid"
}

# Compute feature hash for deduplication
function Get-FeatureHash {
    param([hashtable]$features)

    # Sort keys for consistent hashing
    $sorted = $features.GetEnumerator() | Sort-Object Key
    $str = ($sorted | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "|"

    $md5 = [System.Security.Cryptography.MD5]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($str)
    $hash = $md5.ComputeHash($bytes)
    return [BitConverter]::ToString($hash).Replace("-", "").ToLower().Substring(0, 16)
}

# Bind entity (create or update)
function Invoke-BindEntity {
    param(
        [string]$type,
        [hashtable]$features
    )

    $registry = Load-EntityRegistry

    # Check if entity already exists (match by identifying features)
    $existingEntity = $null

    if ($type -eq "file" -and $features.ContainsKey("path")) {
        # Files identified by path
        $existingEntity = $registry.entities | Where-Object {
            $_.type -eq "file" -and $_.features.path -eq $features.path
        } | Select-Object -First 1
    }
    elseif ($type -eq "project" -and $features.ContainsKey("name")) {
        # Projects identified by name
        $existingEntity = $registry.entities | Where-Object {
            $_.type -eq "project" -and $_.features.name -eq $features.name
        } | Select-Object -First 1
    }
    elseif ($type -eq "error" -and $features.ContainsKey("message")) {
        # Errors identified by message (can have duplicates)
        # Don't match - always create new
    }

    $timestamp = (Get-Date).ToUniversalTime().ToString("o")

    if ($existingEntity) {
        # Update existing entity
        $entityID = $existingEntity.id

        # Check for feature conflicts (illusory conjunction detection)
        $conflicts = @()
        foreach ($key in $features.Keys) {
            if ($existingEntity.features.PSObject.Properties.Name -contains $key) {
                $oldValue = $existingEntity.features.$key
                $newValue = $features[$key]
                if ($oldValue -ne $newValue) {
                    $conflicts += @{
                        feature = $key
                        old_value = $oldValue
                        new_value = $newValue
                    }
                }
            }
        }

        # Update features
        foreach ($key in $features.Keys) {
            $existingEntity.features | Add-Member -NotePropertyName $key -NotePropertyValue $features[$key] -Force
        }

        $existingEntity.state = "exists"
        $existingEntity.last_observed = $timestamp
        $existingEntity.observation_count += 1

        if ($conflicts.Count -gt 0) {
            if (-not $existingEntity.PSObject.Properties.Name -contains "conflicts") {
                $existingEntity | Add-Member -NotePropertyName "conflicts" -NotePropertyValue @()
            }
            $existingEntity.conflicts += @{
                timestamp = $timestamp
                changes = $conflicts
            }
        }

        Log-Observation -entityID $entityID -type $type -features $features -event "updated"
        Save-EntityRegistry -registry $registry

        return @{
            id = $entityID
            action = "updated"
            conflicts = $conflicts
        }
    }
    else {
        # Create new entity
        $entityID = New-EntityID -type $type

        $entity = @{
            id = $entityID
            type = $type
            features = $features
            state = "exists"
            created = $timestamp
            last_observed = $timestamp
            observation_count = 1
        }

        $registry.entities += $entity
        $registry.metadata.total_entities += 1
        $registry.metadata.total_observations += 1

        Log-Observation -entityID $entityID -type $type -features $features -event "created"
        Save-EntityRegistry -registry $registry

        return @{
            id = $entityID
            action = "created"
        }
    }
}

# Get entity by ID
function Get-EntityByID {
    param([string]$id)

    $registry = Load-EntityRegistry
    $entity = $registry.entities | Where-Object { $_.id -eq $id } | Select-Object -First 1

    if ($entity) {
        return $entity
    }
    else {
        Write-Error "Entity not found: $id"
        return $null
    }
}

# Update entity state (for object permanence)
function Update-EntityState {
    param(
        [string]$id,
        [ValidateSet("exists", "occluded", "deleted", "predicted")]
        [string]$newState
    )

    $registry = Load-EntityRegistry
    $entity = $registry.entities | Where-Object { $_.id -eq $id } | Select-Object -First 1

    if ($entity) {
        $oldState = $entity.state
        $entity.state = $newState
        $entity.last_state_change = (Get-Date).ToUniversalTime().ToString("o")

        Log-Observation -entityID $id -type $entity.type -features $entity.features -event "state_changed_${oldState}_to_${newState}"
        Save-EntityRegistry -registry $registry

        return @{
            id = $id
            old_state = $oldState
            new_state = $newState
        }
    }
    else {
        Write-Error "Entity not found: $id"
        return $null
    }
}

# Query entities
function Invoke-QueryEntities {
    param([hashtable]$query)

    $registry = Load-EntityRegistry
    $results = $registry.entities

    # Filter by type
    if ($query.ContainsKey("type")) {
        $results = $results | Where-Object { $_.type -eq $query.type }
    }

    # Filter by state
    if ($query.ContainsKey("state")) {
        $results = $results | Where-Object { $_.state -eq $query.state }
    }

    # Filter by feature values
    if ($query.ContainsKey("features")) {
        foreach ($key in $query.features.Keys) {
            $value = $query.features[$key]
            $results = $results | Where-Object { $_.features.$key -eq $value }
        }
    }

    # Filter by observation count
    if ($query.ContainsKey("min_observations")) {
        $results = $results | Where-Object { $_.observation_count -ge $query.min_observations }
    }

    return $results
}

# Check object permanence for file
function Test-Permanence {
    param([string]$path)

    $registry = Load-EntityRegistry
    $entity = $registry.entities | Where-Object {
        $_.type -eq "file" -and $_.features.path -eq $path
    } | Select-Object -First 1

    if ($entity) {
        return @{
            exists_in_registry = $true
            state = $entity.state
            last_observed = $entity.last_observed
            observation_count = $entity.observation_count
        }
    }
    else {
        return @{
            exists_in_registry = $false
        }
    }
}

# Get statistics
function Get-Stats {
    $registry = Load-EntityRegistry

    $byType = @{}
    $byState = @{}

    foreach ($entity in $registry.entities) {
        # Count by type
        if (-not $byType.ContainsKey($entity.type)) {
            $byType[$entity.type] = 0
        }
        $byType[$entity.type] += 1

        # Count by state
        if (-not $byState.ContainsKey($entity.state)) {
            $byState[$entity.state] = 0
        }
        $byState[$entity.state] += 1
    }

    return @{
        total_entities = $registry.metadata.total_entities
        total_observations = $registry.metadata.total_observations
        by_type = $byType
        by_state = $byState
        registry_size_kb = (Get-Item $registryPath -ErrorAction SilentlyContinue).Length / 1KB
        observations_count = (Get-Content $observationsPath -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
    }
}

# Validate entity consistency
function Test-Validation {
    $registry = Load-EntityRegistry
    $issues = @()

    # Check for duplicate IDs
    $ids = $registry.entities | Select-Object -ExpandProperty id
    $duplicateIDs = $ids | Group-Object | Where-Object { $_.Count -gt 1 } | Select-Object -ExpandProperty Name
    if ($duplicateIDs) {
        $issues += "Duplicate entity IDs found: $($duplicateIDs -join ', ')"
    }

    # Check for entities without required fields
    foreach ($entity in $registry.entities) {
        if (-not $entity.id) { $issues += "Entity missing ID" }
        if (-not $entity.type) { $issues += "Entity $($entity.id) missing type" }
        if (-not $entity.features) { $issues += "Entity $($entity.id) missing features" }
        if (-not $entity.state) { $issues += "Entity $($entity.id) missing state" }
    }

    # Check state validity
    $validStates = @("exists", "occluded", "deleted", "predicted")
    foreach ($entity in $registry.entities) {
        if ($validStates -notcontains $entity.state) {
            $issues += "Entity $($entity.id) has invalid state: $($entity.state)"
        }
    }

    if ($issues.Count -eq 0) {
        Write-Host "[VALIDATION PASSED] Entity registry is consistent" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "[VALIDATION FAILED] Found $($issues.Count) issues:" -ForegroundColor Red
        $issues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
        return $false
    }
}

# Main execution
switch ($Action) {
    "BindEntity" {
        if (-not $Type -or -not $Features) {
            Write-Error "BindEntity requires -Type and -Features"
            exit 1
        }

        $result = Invoke-BindEntity -type $Type -features $Features
        $result | ConvertTo-Json -Depth 5
    }

    "GetEntity" {
        if (-not $ID) {
            Write-Error "GetEntity requires -ID"
            exit 1
        }

        $entity = Get-EntityByID -id $ID
        if ($entity) {
            $entity | ConvertTo-Json -Depth 5
        }
    }

    "UpdateEntity" {
        if (-not $ID -or -not $Features) {
            Write-Error "UpdateEntity requires -ID and -Features (with 'state' key)"
            exit 1
        }

        if ($Features.ContainsKey("state")) {
            $result = Update-EntityState -id $ID -newState $Features.state
            $result | ConvertTo-Json -Depth 5
        }
        else {
            Write-Error "Features must contain 'state' key for UpdateEntity"
            exit 1
        }
    }

    "QueryEntities" {
        if (-not $Query) {
            Write-Error "QueryEntities requires -Query"
            exit 1
        }

        $results = Invoke-QueryEntities -query $Query
        Write-Host "Found $($results.Count) entities matching query"
        $results | ConvertTo-Json -Depth 5
    }

    "CheckPermanence" {
        if (-not $Path) {
            Write-Error "CheckPermanence requires -Path"
            exit 1
        }

        $result = Test-Permanence -path $Path
        $result | ConvertTo-Json -Depth 3
    }

    "Stats" {
        $stats = Get-Stats
        Write-Host "`n=== Entity Binding System Stats ===" -ForegroundColor Cyan
        Write-Host "Total Entities: $($stats.total_entities)"
        Write-Host "Total Observations: $($stats.total_observations)"
        Write-Host "`nBy Type:" -ForegroundColor Yellow
        $stats.by_type.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
            Write-Host "  $($_.Key): $($_.Value)"
        }
        Write-Host "`nBy State:" -ForegroundColor Yellow
        $stats.by_state.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
            Write-Host "  $($_.Key): $($_.Value)"
        }
        Write-Host "`nRegistry Size: $([math]::Round($stats.registry_size_kb, 2)) KB"
        Write-Host "Observation Events: $($stats.observations_count)`n"

        $stats | ConvertTo-Json -Depth 5
    }

    "Validate" {
        Test-Validation
    }
}
