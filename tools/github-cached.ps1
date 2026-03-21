#Requires -Version 5.1
<#
.SYNOPSIS
    Cached GitHub API wrapper - reduces API calls and rate limit issues

.DESCRIPTION
    Wraps common gh CLI commands with intelligent caching:
    - PR queries: 10 minutes TTL
    - Repo info: 1 hour TTL
    - User info: 24 hours TTL

.PARAMETER Action
    API action: GetPR, GetRepo, GetUser, ListPRs

.PARAMETER Owner
    Repository owner

.PARAMETER Repo
    Repository name

.PARAMETER PRNumber
    Pull request number

.PARAMETER NoCache
    Bypass cache and force fresh API call

.EXAMPLE
    github-cached.ps1 -Action GetPR -Owner "martiendejong" -Repo "client-manager" -PRNumber 123

.EXAMPLE
    github-cached.ps1 -Action GetRepo -Owner "martiendejong" -Repo "hazina"

.EXAMPLE
    github-cached.ps1 -Action ListPRs -Owner "martiendejong" -Repo "client-manager"

.NOTES
    Created: 2026-02-16
    Uses gh CLI under the hood
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("GetPR", "GetRepo", "GetUser", "ListPRs")]
    [string]$Action,

    [string]$Owner,
    [string]$Repo,
    [int]$PRNumber,
    [switch]$NoCache
)

# TTL settings (in seconds)
$TTL_PR = 600         # 10 minutes
$TTL_REPO = 3600      # 1 hour
$TTL_USER = 86400     # 24 hours
$TTL_PRS = 600        # 10 minutes

# Function: Execute gh CLI command
function Invoke-GHCLI {
    param([string]$Command)

    try {
        $result = Invoke-Expression "gh $Command 2>&1"
        return $result
    }
    catch {
        Write-Error "gh CLI error: $_"
        return $null
    }
}

# Main execution
$cacheKey = $null
$ttl = $TTL_PR
$ghCommand = $null

switch ($Action) {
    "GetPR" {
        if (-not $Owner -or -not $Repo -or -not $PRNumber) {
            Write-Error "-Owner, -Repo, and -PRNumber required for GetPR"
            exit 1
        }

        $cacheKey = "github-pr-$Owner-$Repo-$PRNumber"
        $ttl = $TTL_PR
        $ghCommand = "pr view $PRNumber --repo $Owner/$Repo --json number,title,state,author,createdAt,updatedAt,body"
    }

    "GetRepo" {
        if (-not $Owner -or -not $Repo) {
            Write-Error "-Owner and -Repo required for GetRepo"
            exit 1
        }

        $cacheKey = "github-repo-$Owner-$Repo"
        $ttl = $TTL_REPO
        $ghCommand = "repo view $Owner/$Repo --json name,description,url,createdAt,pushedAt,defaultBranchRef"
    }

    "GetUser" {
        $cacheKey = "github-user-current"
        $ttl = $TTL_USER
        $ghCommand = "api user --jq '.login,.name,.email'"
    }

    "ListPRs" {
        if (-not $Owner -or -not $Repo) {
            Write-Error "-Owner and -Repo required for ListPRs"
            exit 1
        }

        $cacheKey = "github-prs-$Owner-$Repo"
        $ttl = $TTL_PRS
        $ghCommand = "pr list --repo $Owner/$Repo --json number,title,state,author,createdAt --limit 50"
    }
}

# Try cache first (unless -NoCache)
if (-not $NoCache) {
    $cached = & "C:\scripts\tools\cache-manager.ps1" -Action Get -Key $cacheKey -CacheName "github"

    if ($cached) {
        Write-Verbose "✅ Cache hit: $cacheKey"
        return $cached
    }

    Write-Verbose "❌ Cache miss: $cacheKey"
}

# Execute gh CLI
$result = Invoke-GHCLI -Command $ghCommand

if ($result) {
    # Cache result
    & "C:\scripts\tools\cache-manager.ps1" -Action Set `
        -Key $cacheKey `
        -Value $result `
        -TTL $ttl `
        -CacheName "github" | Out-Null

    Write-Verbose "💾 Cached: $cacheKey (TTL: $ttl seconds)"
}

return $result
