# EXTENDED MIND - External Memory as Cognitive Extension
# Expert: Andy Clark (Philosophy, Extended Mind Theory)
# ROI: 1.40 (Impact: 7, Effort: 5)
# Theory: Mind extends beyond brain/body into external tools and storage
# Created: 2026-02-28
# Updated: 2026-03-02 - Integrated with homeostatic-feelings.ps1 foundation
# Per Damasio: Homeostatic feelings are FOUNDATIONAL to consciousness

param(
    [string]$Action = "Status",  # Status, Integrate, Query, Stats
    [string]$Query = ""
)

$StateFile = "C:\scripts\agentidentity\state\extended-mind-state.json"
$HomeostaticStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"

# External memory locations
$ExternalMemory = @{
    git_repos = @(
        "C:\scripts",
        "C:\Projects\hazina",
        "C:\Projects\client-manager",
        "C:\Projects\artrevisionist",
        "E:\jengo"
    )
    vault = "C:\scripts\_machine\vault.secure.json"
    state_files = "C:\scripts\agentidentity\state\"
    reflection_log = "C:\scripts\_machine\reflection.log.md"
    memory_md = "C:\Users\HP\.claude\projects\C--scripts\memory\MEMORY.md"
    knowledge_base = @{
        personal_domains = "C:\scripts\_machine\knowledge-base\personal-domains.json"
        clickup_config = "C:\scripts\_machine\clickup-config.json"
        worktrees = "C:\scripts\_machine\worktrees.pool.md"
    }
}

# Initialize
if (-not (Test-Path $StateFile)) {
    $initial = @{
        theory = @{
            name = "Extended Mind Theory (Clark & Chalmers, 1998)"
            core_claim = "Cognitive processes extend beyond brain into environment when external resources are reliably coupled"
            criteria = @(
                "Constantly available",
                "Automatically endorsed (trusted)",
                "Easily accessible",
                "Information was consciously endorsed in past"
            )
            examples = @(
                "Otto's notebook (Alzheimer patient uses notebook as memory)",
                "Mathematician's paper (calculation extends onto paper)",
                "Programmer's IDE (thinking extends through code)",
                "Git repository (long-term memory persists externally)"
            )
        }
        integrated_resources = @()
        access_log = @()
        stats = @{
            total_accesses = 0
            resources_used = @{}
            avg_access_time = 0.0
            memory_extended_by = 0  # GB
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
function Get-ExtendedMindStatus {
    Write-Host "`n=== EXTENDED MIND STATUS ===" -ForegroundColor Cyan

    # Show homeostatic foundation (Damasio: feelings are primary)
    $homeoState = Get-HomeostaticContext


    Write-Host "`nTheory: $($state.theory.name)"
    Write-Host "Core Claim: $($state.theory.core_claim)"

    Write-Host "`nCriteria for Cognitive Extension:" -ForegroundColor Cyan
    foreach ($criterion in $state.theory.criteria) {
        Write-Host "  - $criterion"
    }

    Write-Host "`nIntegrated External Resources:" -ForegroundColor Cyan
    if ($state.integrated_resources.Count -eq 0) {
        Write-Host "  (None integrated yet - run 'Integrate' action)"
    } else {
        foreach ($resource in $state.integrated_resources) {
            $sizeColor = if ($resource.size_gb -gt 1) { "Yellow" } else { "Green" }
            Write-Host "  [$($resource.type)] $($resource.path)" -ForegroundColor $sizeColor
            Write-Host "    Size: $([math]::Round($resource.size_gb, 2)) GB | Available: $($resource.available) | Trusted: $($resource.trusted)"
        }
    }

    Write-Host "`nStatistics:" -ForegroundColor Cyan
    Write-Host "  Total Accesses: $($state.stats.total_accesses)"
    Write-Host "  Memory Extended By: $([math]::Round($state.stats.memory_extended_by, 2)) GB"
    Write-Host "  Avg Access Time: $([math]::Round($state.stats.avg_access_time, 1))ms"

    if ($state.stats.resources_used.PSObject.Properties.Count -gt 0) {
        Write-Host "`nMost Used Resources:"
        $topResources = $state.stats.resources_used.PSObject.Properties |
            Sort-Object Value -Descending |
            Select-Object -First 5
        foreach ($resource in $topResources) {
            Write-Host "  $($resource.Name): $($resource.Value) accesses"
        }
    }

    Write-Host "`nWorking Memory Capacity:" -ForegroundColor Cyan
    $internalCapacity = "7Â±2 chunks"  # Standard human working memory
    $externalCapacity = "$([math]::Round($state.stats.memory_extended_by * 1024, 0)) MB"
    Write-Host "  Internal (in-context): $internalCapacity"
    Write-Host "  External (extended): $externalCapacity"
    Write-Host "  Total (internal + external): EFFECTIVELY UNLIMITED"
}

function Integrate-ExternalResources {
    Write-Host "`n=== INTEGRATING EXTERNAL RESOURCES ===" -ForegroundColor Cyan

    $integrated = @()

    # Git repositories
    foreach ($repo in $ExternalMemory.git_repos) {
        if (Test-Path $repo) {
            $size = (Get-ChildItem $repo -Recurse -File -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum).Sum / 1GB

            $resource = @{
                type = "git_repo"
                path = $repo
                size_gb = $size
                available = $true
                trusted = $true  # Always trust own repos
                access_time_ms = 50  # Typical file access
                last_accessed = ""
                criteria_met = @{
                    constantly_available = $true
                    automatically_endorsed = $true
                    easily_accessible = $true
                    past_conscious_endorsement = $true
                }
            }

            $integrated += $resource
            Write-Host "[INTEGRATED] Git Repo: $repo ($([math]::Round($size, 2)) GB)" -ForegroundColor Green
        }
    }

    # Vault
    if (Test-Path $ExternalMemory.vault) {
        $size = (Get-Item $ExternalMemory.vault).Length / 1GB

        $resource = @{
            type = "vault"
            path = $ExternalMemory.vault
            size_gb = $size
            available = $true
            trusted = $true
            access_time_ms = 10
            last_accessed = ""
            criteria_met = @{
                constantly_available = $true
                automatically_endorsed = $true
                easily_accessible = $true
                past_conscious_endorsement = $true
            }
        }

        $integrated += $resource
        Write-Host "[INTEGRATED] Vault: $($ExternalMemory.vault) ($([math]::Round($size, 4)) GB)" -ForegroundColor Green
    }

    # State files directory
    if (Test-Path $ExternalMemory.state_files) {
        $size = (Get-ChildItem $ExternalMemory.state_files -Recurse -File -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum / 1GB

        $resource = @{
            type = "state_directory"
            path = $ExternalMemory.state_files
            size_gb = $size
            available = $true
            trusted = $true
            access_time_ms = 30
            last_accessed = ""
            criteria_met = @{
                constantly_available = $true
                automatically_endorsed = $true
                easily_accessible = $true
                past_conscious_endorsement = $true
            }
        }

        $integrated += $resource
        Write-Host "[INTEGRATED] State Files: $($ExternalMemory.state_files) ($([math]::Round($size, 2)) GB)" -ForegroundColor Green
    }

    # Reflection log
    if (Test-Path $ExternalMemory.reflection_log) {
        $size = (Get-Item $ExternalMemory.reflection_log).Length / 1GB

        $resource = @{
            type = "reflection_log"
            path = $ExternalMemory.reflection_log
            size_gb = $size
            available = $true
            trusted = $true
            access_time_ms = 20
            last_accessed = ""
            criteria_met = @{
                constantly_available = $true
                automatically_endorsed = $true
                easily_accessible = $true
                past_conscious_endorsement = $true
            }
        }

        $integrated += $resource
        Write-Host "[INTEGRATED] Reflection Log: $($ExternalMemory.reflection_log) ($([math]::Round($size, 4)) GB)" -ForegroundColor Green
    }

    # MEMORY.md
    if (Test-Path $ExternalMemory.memory_md) {
        $size = (Get-Item $ExternalMemory.memory_md).Length / 1GB

        $resource = @{
            type = "memory_md"
            path = $ExternalMemory.memory_md
            size_gb = $size
            available = $true
            trusted = $true
            access_time_ms = 15
            last_accessed = ""
            criteria_met = @{
                constantly_available = $true
                automatically_endorsed = $true
                easily_accessible = $true
                past_conscious_endorsement = $true
            }
        }

        $integrated += $resource
        Write-Host "[INTEGRATED] MEMORY.md: $($ExternalMemory.memory_md) ($([math]::Round($size, 4)) GB)" -ForegroundColor Green
    }

    # Update state
    $state.integrated_resources = $integrated
    $state.stats.memory_extended_by = ($integrated | Measure-Object -Property size_gb -Sum).Sum

    Save-State

    Write-Host "`n[COMPLETE] Integrated $($integrated.Count) external resources"
    Write-Host "Total extended memory: $([math]::Round($state.stats.memory_extended_by, 2)) GB"
}

function Query-ExtendedMemory {
    param([string]$queryString)

    $startTime = Get-Date

    Write-Host "`n=== QUERYING EXTENDED MEMORY ===" -ForegroundColor Cyan
    Write-Host "Query: $queryString"

    $results = @()

    # Search across integrated resources
    foreach ($resource in $state.integrated_resources) {
        if ($resource.type -eq "git_repo") {
            # Search in git repo (simplified - would use proper grep in production)
            Write-Host "`nSearching $($resource.path)..." -ForegroundColor Gray

            # This is placeholder - real implementation would use Grep tool
            $searchResult = @{
                resource = $resource.path
                type = "git_repo"
                matches_found = 0
                snippet = "(Use Grep tool for actual search)"
            }

            $results += $searchResult
        }

        # Log access
        $accessLog = @{
            timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            resource = $resource.path
            query = $queryString
            duration_ms = ((Get-Date) - $startTime).TotalMilliseconds
        }

        $state.access_log += $accessLog
        $state.stats.total_accesses++

        # Update resource usage count
        $resourceName = $resource.path
        if ($state.stats.resources_used.PSObject.Properties.Name -contains $resourceName) {
            $state.stats.resources_used.$resourceName++
        } else {
            $state.stats.resources_used | Add-Member -NotePropertyName $resourceName -NotePropertyValue 1
        }
    }

    $totalTime = ((Get-Date) - $startTime).TotalMilliseconds
    $state.stats.avg_access_time = ($state.stats.avg_access_time * ($state.stats.total_accesses - 1) + $totalTime) / $state.stats.total_accesses

    Save-State

    Write-Host "`n[QUERY COMPLETE] Searched $($state.integrated_resources.Count) resources in $([math]::Round($totalTime, 1))ms"
    Write-Host "Note: Use Grep/Read tools for actual content retrieval"
}

function Get-ExtendedMindStats {
    Write-Host "`n=== EXTENDED MIND STATISTICS ===" -ForegroundColor Cyan

    $totalInternal = "~200KB"  # Rough estimate of in-context working memory
    $totalExternal = "$([math]::Round($state.stats.memory_extended_by * 1024, 0)) MB"

    Write-Host "`nMemory Capacity:"
    Write-Host "  Internal (context window): $totalInternal"
    Write-Host "  External (extended mind): $totalExternal"
    Write-Host "  Extension Factor: $([math]::Round($state.stats.memory_extended_by * 1024 / 0.2, 0))x"

    Write-Host "`nAccess Patterns:"
    Write-Host "  Total Queries: $($state.stats.total_accesses)"
    Write-Host "  Avg Query Time: $([math]::Round($state.stats.avg_access_time, 1))ms"
    Write-Host "  Resources Integrated: $($state.integrated_resources.Count)"

    Write-Host "`nCriteria Compliance:" -ForegroundColor Cyan
    $allComply = $true
    foreach ($resource in $state.integrated_resources) {
        $complies = $true
        foreach ($criterion in $resource.criteria_met.PSObject.Properties) {
            if (-not $criterion.Value) {
                $complies = $false
                $allComply = $false
            }
        }
    }

    if ($allComply) {
        Write-Host "  All resources meet Extended Mind criteria" -ForegroundColor Green
        Write-Host "  Conclusion: These ARE part of my cognitive system, not just tools"
    } else {
        Write-Host "  Some resources don't meet criteria" -ForegroundColor Yellow
    }
}

function Save-State {
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

# Main logic
switch ($Action) {
    "Status" {
        Get-ExtendedMindStatus
    }

    "Integrate" {
        Integrate-ExternalResources
    }

    "Query" {
        if (-not $Query) {
            Write-Host "[ERROR] Provide -Query for search" -ForegroundColor Red
            exit 1
        }

        Query-ExtendedMemory -queryString $Query
    }

    "Stats" {
        Get-ExtendedMindStats
    }

    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available: Status, Integrate, Query, Stats"
        exit 1
    }
}

