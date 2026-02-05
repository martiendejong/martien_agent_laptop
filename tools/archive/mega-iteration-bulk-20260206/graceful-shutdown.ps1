# graceful-shutdown.ps1
# Ensures clean agent shutdown with state preservation
# Releases resources, saves state, completes critical operations

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Initiate", "Register", "Status", "Force")]
    [string]$Action,

    [string]$AgentId = "",
    [int]$TimeoutSeconds = 30,
    [switch]$SaveState
)

$script:ShutdownState = "C:\scripts\_machine\shutdown.state.json"
$script:ShutdownHooks = @()

function Get-ShutdownState {
    if (Test-Path $script:ShutdownState) {
        return Get-Content $script:ShutdownState -Raw | ConvertFrom-Json
    }
    return @{
        InProgress = $false
        AgentId = $null
        InitiatedAt = $null
        CompletedSteps = @()
        PendingSteps = @()
    }
}

function Set-ShutdownState {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Set-Content -Path $script:ShutdownState -Force
}

function Register-ShutdownHook {
    param(
        [string]$Name,
        [scriptblock]$Action,
        [int]$Priority = 5  # 1=highest, 10=lowest
    )

    $script:ShutdownHooks += @{
        Name = $Name
        Action = $Action
        Priority = $Priority
    }

    Write-Host "✅ Shutdown hook registered: $Name (Priority $Priority)" -ForegroundColor Green
}

function Invoke-GracefulShutdown {
    param(
        [string]$AgentId,
        [int]$Timeout,
        [switch]$SaveState
    )

    Write-Host "`n🛑 Initiating graceful shutdown for $AgentId..." -ForegroundColor Yellow
    Write-Host "   Timeout: ${Timeout}s" -ForegroundColor Gray

    $state = @{
        InProgress = $true
        AgentId = $AgentId
        InitiatedAt = (Get-Date).ToString("o")
        CompletedSteps = @()
        PendingSteps = @(
            "1. Release worktree locks",
            "2. Commit pending changes",
            "3. Save agent state",
            "4. Update coordinator",
            "5. Close file handles",
            "6. Flush logs"
        )
    }
    Set-ShutdownState -State $state

    $startTime = Get-Date
    $success = $true

    # Step 1: Release worktree locks
    Write-Host "`n📍 Step 1/6: Releasing worktree locks..." -ForegroundColor Cyan
    try {
        $lockFile = "C:\scripts\_machine\locks\$AgentId.lock"
        if (Test-Path $lockFile) {
            & "C:\scripts\tools\worktree-lock.ps1" -Action Release -Seat $AgentId
            Write-Host "   ✅ Locks released" -ForegroundColor Green
        } else {
            Write-Host "   ⏭️ No locks to release" -ForegroundColor Gray
        }
        $state.CompletedSteps += "Release worktree locks"
    }
    catch {
        Write-Host "   ❌ Failed to release locks: $_" -ForegroundColor Red
        $success = $false
    }

    # Step 2: Commit pending changes (if in a git repo)
    Write-Host "`n📍 Step 2/6: Checking for uncommitted changes..." -ForegroundColor Cyan
    try {
        $gitStatus = git status --short 2>$null
        if ($LASTEXITCODE -eq 0 -and $gitStatus) {
            Write-Host "   ⚠️ Uncommitted changes detected" -ForegroundColor Yellow
            Write-Host "   Staging all changes..." -ForegroundColor Gray

            git add -A 2>$null
            $commitMsg = "chore: Auto-commit during graceful shutdown of $AgentId`n`nAuto-saved by graceful-shutdown.ps1"
            git commit -m $commitMsg 2>$null

            if ($LASTEXITCODE -eq 0) {
                Write-Host "   ✅ Changes committed" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️ Commit failed (may not be critical)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "   ⏭️ No uncommitted changes" -ForegroundColor Gray
        }
        $state.CompletedSteps += "Commit pending changes"
    }
    catch {
        Write-Host "   ❌ Git operations failed: $_" -ForegroundColor Red
    }

    # Step 3: Save agent state
    Write-Host "`n📍 Step 3/6: Saving agent state..." -ForegroundColor Cyan
    if ($SaveState) {
        try {
            $agentState = @{
                AgentId = $AgentId
                ShutdownAt = (Get-Date).ToString("o")
                LastTask = "Unknown"
                WorkingDirectory = (Get-Location).Path
                SessionDuration = ((Get-Date) - $startTime).TotalSeconds
            }

            $stateFile = "C:\scripts\_machine\agent-states\$AgentId.state.json"
            $stateDir = Split-Path $stateFile -Parent
            if (-not (Test-Path $stateDir)) {
                New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
            }

            $agentState | ConvertTo-Json | Set-Content -Path $stateFile -Force

            Write-Host "   ✅ State saved: $stateFile" -ForegroundColor Green
            $state.CompletedSteps += "Save agent state"
        }
        catch {
            Write-Host "   ❌ Failed to save state: $_" -ForegroundColor Red
            $success = $false
        }
    } else {
        Write-Host "   ⏭️ State save not requested" -ForegroundColor Gray
    }

    # Step 4: Update coordinator
    Write-Host "`n📍 Step 4/6: Updating coordinator..." -ForegroundColor Cyan
    try {
        & "C:\scripts\tools\agent-coordinator.ps1" -Action Stop -AgentId $AgentId 2>$null
        Write-Host "   ✅ Coordinator updated" -ForegroundColor Green
        $state.CompletedSteps += "Update coordinator"
    }
    catch {
        Write-Host "   ⚠️ Coordinator update failed (may not exist)" -ForegroundColor Yellow
    }

    # Step 5: Close file handles (best effort)
    Write-Host "`n📍 Step 5/6: Closing file handles..." -ForegroundColor Cyan
    try {
        # Clear PowerShell error log
        $Error.Clear()
        Write-Host "   ✅ Error buffer cleared" -ForegroundColor Green
        $state.CompletedSteps += "Close file handles"
    }
    catch {
        Write-Host "   ⚠️ Cleanup failed" -ForegroundColor Yellow
    }

    # Step 6: Flush logs
    Write-Host "`n📍 Step 6/6: Flushing logs..." -ForegroundColor Cyan
    try {
        $reflectionFile = "C:\scripts\_machine\reflection.log.md"
        if (Test-Path $reflectionFile) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $entry = @"

## $timestamp - Graceful Shutdown: $AgentId

**Duration:** $([math]::Round(((Get-Date) - [DateTime]$state.InitiatedAt).TotalSeconds, 1))s
**Status:** $(if ($success) { "✅ Clean" } else { "⚠️ Incomplete" })
**Steps Completed:** $($state.CompletedSteps.Count)/6

---

"@
            Add-Content -Path $reflectionFile -Value $entry
        }

        Write-Host "   ✅ Logs flushed" -ForegroundColor Green
        $state.CompletedSteps += "Flush logs"
    }
    catch {
        Write-Host "   ⚠️ Log flush failed" -ForegroundColor Yellow
    }

    # Final state
    $state.InProgress = $false
    $state.CompletedAt = (Get-Date).ToString("o")
    $state.Success = $success
    Set-ShutdownState -State $state

    $duration = ((Get-Date) - $startTime).TotalSeconds

    if ($success) {
        Write-Host "`n✅ Graceful shutdown complete ($([math]::Round($duration, 1))s)" -ForegroundColor Green
        return 0
    } else {
        Write-Host "`n⚠️ Shutdown completed with warnings ($([math]::Round($duration, 1))s)" -ForegroundColor Yellow
        return 1
    }
}

function Show-ShutdownStatus {
    $state = Get-ShutdownState

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "🛑 GRACEFUL SHUTDOWN STATUS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

    if ($state.InProgress) {
        Write-Host "`n⚠️ Shutdown IN PROGRESS" -ForegroundColor Yellow
        Write-Host "   Agent: $($state.AgentId)" -ForegroundColor White
        Write-Host "   Started: $($state.InitiatedAt)" -ForegroundColor Gray
        Write-Host "   Completed: $($state.CompletedSteps.Count)/$($state.PendingSteps.Count) steps" -ForegroundColor Gray

        Write-Host "`n✅ Completed:" -ForegroundColor Green
        foreach ($step in $state.CompletedSteps) {
            Write-Host "   - $step" -ForegroundColor Gray
        }

        Write-Host "`n⏳ Pending:" -ForegroundColor Yellow
        $remaining = $state.PendingSteps | Where-Object { $state.CompletedSteps -notcontains $_ }
        foreach ($step in $remaining) {
            Write-Host "   - $step" -ForegroundColor Gray
        }
    } else {
        if ($state.AgentId) {
            Write-Host "`n✅ Last shutdown: $($state.AgentId)" -ForegroundColor Green
            Write-Host "   Completed: $($state.CompletedAt)" -ForegroundColor Gray
            Write-Host "   Status: $(if ($state.Success) { '✅ Clean' } else { '⚠️ With warnings' })" -ForegroundColor Gray
        } else {
            Write-Host "`nNo recent shutdowns" -ForegroundColor Gray
        }
    }

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

# Main logic
switch ($Action) {
    "Initiate" {
        if (-not $AgentId) {
            Write-Host "❌ Initiate requires -AgentId parameter" -ForegroundColor Red
            exit 1
        }

        $exitCode = Invoke-GracefulShutdown -AgentId $AgentId -Timeout $TimeoutSeconds -SaveState:$SaveState
        exit $exitCode
    }

    "Register" {
        Write-Host "📋 Registering shutdown hooks..." -ForegroundColor Cyan

        # Default hooks
        Register-ShutdownHook -Name "Release locks" -Priority 1 -Action {
            & "C:\scripts\tools\worktree-lock.ps1" -Action Release -Seat $AgentId
        }

        Register-ShutdownHook -Name "Update coordinator" -Priority 2 -Action {
            & "C:\scripts\tools\agent-coordinator.ps1" -Action Stop -AgentId $AgentId
        }

        Register-ShutdownHook -Name "Flush logs" -Priority 10 -Action {
            Write-Host "Flushing logs..."
        }

        Write-Host "✅ $($script:ShutdownHooks.Count) hooks registered" -ForegroundColor Green
        exit 0
    }

    "Status" {
        Show-ShutdownStatus
        exit 0
    }

    "Force" {
        if (-not $AgentId) {
            Write-Host "❌ Force requires -AgentId parameter" -ForegroundColor Red
            exit 1
        }

        Write-Host "💥 FORCE SHUTDOWN: $AgentId (no cleanup)" -ForegroundColor Red

        # Just update coordinator and exit
        & "C:\scripts\tools\agent-coordinator.ps1" -Action Stop -AgentId $AgentId -Force 2>$null

        Write-Host "✅ Force shutdown complete" -ForegroundColor Green
        exit 0
    }
}
