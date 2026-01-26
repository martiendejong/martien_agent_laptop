<#
.SYNOPSIS
    Git operations wrapper with automatic SQLite tracking

.DESCRIPTION
    Wraps common git operations and automatically logs to database:
    - commit, push, pull, merge, checkout, rebase
    - Captures success/failure
    - Logs error messages
    - Tracks performance metrics

.PARAMETER Operation
    Git operation: commit, push, pull, merge, checkout, rebase

.PARAMETER Message
    Commit message (for commit operation)

.PARAMETER Branch
    Branch name (for checkout, merge)

.PARAMETER Remote
    Remote name (for push, pull)

.PARAMETER Args
    Additional git arguments

.EXAMPLE
    .\git-tracked.ps1 -Operation commit -Message "feat: Add OAuth"

.EXAMPLE
    .\git-tracked.ps1 -Operation push -Remote origin -Branch main

.EXAMPLE
    .\git-tracked.ps1 -Operation merge -Branch develop
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('commit', 'push', 'pull', 'merge', 'checkout', 'rebase', 'add', 'status')]
    [string]$Operation,

    [Parameter(Mandatory=$false)]
    [string]$Message = '',

    [Parameter(Mandatory=$false)]
    [string]$Branch = '',

    [Parameter(Mandatory=$false)]
    [string]$Remote = 'origin',

    [Parameter(Mandatory=$false)]
    [string[]]$Args = @()
)

$ErrorActionPreference = 'Stop'

# Get current repo and branch
function Get-CurrentRepo {
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if ($gitRoot) {
        return Split-Path -Leaf $gitRoot
    }
    return "unknown"
}

function Get-CurrentBranch {
    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($branch) {
        return $branch
    }
    return "unknown"
}

$repo = Get-CurrentRepo
$currentBranch = Get-CurrentBranch
$startTime = Get-Date

Write-Host "Git $Operation on $repo/$currentBranch..." -ForegroundColor Cyan

try {
    # Execute git operation
    $commitSha = ""
    $success = 0
    $errorMessage = ""

    switch ($Operation) {
        'commit' {
            if (-not $Message) {
                throw "Commit message required"
            }

            git add -A
            git commit -m $Message @Args

            if ($LASTEXITCODE -eq 0) {
                $commitSha = git rev-parse HEAD
                $success = 1
                Write-Host "Committed: $commitSha" -ForegroundColor Green
            } else {
                throw "Commit failed"
            }
        }

        'push' {
            $targetBranch = if ($Branch) { $Branch } else { $currentBranch }

            git push $Remote $targetBranch @Args

            if ($LASTEXITCODE -eq 0) {
                $success = 1
                $commitSha = git rev-parse HEAD
                Write-Host "Pushed to $Remote/$targetBranch" -ForegroundColor Green
            } else {
                throw "Push failed"
            }
        }

        'pull' {
            $targetBranch = if ($Branch) { $Branch } else { $currentBranch }

            git pull $Remote $targetBranch @Args

            if ($LASTEXITCODE -eq 0) {
                $success = 1
                $commitSha = git rev-parse HEAD
                Write-Host "Pulled from $Remote/$targetBranch" -ForegroundColor Green
            } else {
                throw "Pull failed"
            }
        }

        'merge' {
            if (-not $Branch) {
                throw "Branch required for merge"
            }

            git merge $Branch @Args

            if ($LASTEXITCODE -eq 0) {
                $success = 1
                $commitSha = git rev-parse HEAD
                Write-Host "Merged $Branch into $currentBranch" -ForegroundColor Green
            } else {
                throw "Merge failed"
            }
        }

        'checkout' {
            if (-not $Branch) {
                throw "Branch required for checkout"
            }

            git checkout $Branch @Args

            if ($LASTEXITCODE -eq 0) {
                $success = 1
                Write-Host "Checked out $Branch" -ForegroundColor Green
            } else {
                throw "Checkout failed"
            }
        }

        'rebase' {
            if (-not $Branch) {
                throw "Branch required for rebase"
            }

            git rebase $Branch @Args

            if ($LASTEXITCODE -eq 0) {
                $success = 1
                $commitSha = git rev-parse HEAD
                Write-Host "Rebased onto $Branch" -ForegroundColor Green
            } else {
                throw "Rebase failed"
            }
        }

        'add' {
            git add @Args

            if ($LASTEXITCODE -eq 0) {
                $success = 1
                Write-Host "Files staged" -ForegroundColor Green
            } else {
                throw "Add failed"
            }
        }

        'status' {
            git status @Args
            $success = 1
        }
    }

} catch {
    $errorMessage = $_.Exception.Message
    Write-Host "Git operation failed: $errorMessage" -ForegroundColor Red
}

# Log to database
try {
    $duration = ((Get-Date) - $startTime).TotalMilliseconds

    & "C:\scripts\tools\agent-logger-enhanced.ps1" -Action log_git_op `
        -GitOp $Operation `
        -Repo $repo `
        -Branch $(if ($Branch) { $Branch } else { $currentBranch }) `
        -CommitSha $commitSha `
        -Message $(if ($Message) { $Message } else { "$Operation on $repo" }) `
        -Success $success

    # Log performance metric
    $agentId = if (Test-Path "C:\scripts\_machine\.current_agent_id") {
        Get-Content "C:\scripts\_machine\.current_agent_id" -Raw | ForEach-Object { $_.Trim() }
    } else { "unknown" }

    $DbPath = "C:\scripts\_machine\agent-activity.db"
    $SqlitePath = "C:\scripts\_machine\sqlite3.exe"
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    $sql = @"
INSERT INTO metrics (agent_id, metric_name, metric_value, unit, timestamp, context)
VALUES ('$agentId', 'git_${Operation}_duration', $duration, 'milliseconds', '$now', '{\"repo\":\"$repo\",\"branch\":\"$currentBranch\"}');
"@

    $sql | & $SqlitePath $DbPath

} catch {
    Write-Host "Warning: Failed to log to database: $_" -ForegroundColor Yellow
}

# Exit with git's exit code
exit $(if ($success -eq 1) { 0 } else { 1 })
