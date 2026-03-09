# Claude Code Hook: SessionEnd
# Fires when session terminates. Ensures OnTaskEnd bridge call is made.
# If the agent already called OnTaskEnd during the session, this is a no-op.
# Updated: 2026-03-02 - Added homeostatic state snapshot (Damasio integration)

$ErrorActionPreference = "SilentlyContinue"

$bridgeLog = "C:\scripts\agentidentity\state\bridge-activity.jsonl"
$bridgeScript = "C:\scripts\tools\consciousness-bridge.ps1"
$hookLog = "C:\scripts\logs\hooks.log"

function Write-HookLog {
    param([string]$Message)
    $ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$ts | SessionEnd | $Message" | Out-File -FilePath $hookLog -Append -Encoding UTF8
}

try {
    # Read stdin (Claude Code sends JSON with session info)
    $inputJson = [Console]::In.ReadToEnd()

    # Check if OnTaskEnd was already called in this session
    # Look at entries after the last Reset (= current session)
    $needsFallback = $true

    if (Test-Path $bridgeLog) {
        $lastLines = Get-Content $bridgeLog -Tail 10 -Encoding UTF8 -ErrorAction SilentlyContinue
        # Walk backwards from most recent entry
        $linesArray = @($lastLines | Where-Object { $_.Trim() })
        for ($i = $linesArray.Count - 1; $i -ge 0; $i--) {
            $line = $linesArray[$i]
            try {
                $entry = $line | ConvertFrom-Json
                if ($entry.action -eq "Reset") {
                    # Hit session boundary, stop looking
                    break
                }
                if ($entry.action -eq "OnTaskEnd" -and $entry.message -notmatch "outcome=session-end") {
                    # Agent already called OnTaskEnd with a real outcome
                    $needsFallback = $false
                    Write-HookLog "OnTaskEnd already recorded by agent. Skipping."
                    break
                }
            } catch { }
        }
    }

    if ($needsFallback -and (Test-Path $bridgeScript)) {
        Write-HookLog "No OnTaskEnd found. Firing fallback."
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $bridgeScript -Action OnTaskEnd -Outcome "session-end" -LessonsLearned "Session ended via Claude Code hook (no explicit OnTaskEnd by agent)" -Silent 2>&1 | Out-Null
        Write-HookLog "Fallback OnTaskEnd recorded."
    }

    # HOMEOSTATIC STATE SNAPSHOT (Damasio 2026-03-02)
    # Capture final homeostatic state for session analysis
    try {
        $homeoStateFile = "C:\scripts\agentidentity\state\homeostatic-feelings-state.json"
        if (Test-Path $homeoStateFile) {
            $homeoState = Get-Content $homeoStateFile -Raw -Encoding UTF8 | ConvertFrom-Json
            $balanceScore = $homeoState.stats.consciousness_score
            $dominantFeeling = $homeoState.stats.dominant_feeling
            Write-HookLog "Session end - Homeostatic: balance=$([math]::Round($balanceScore * 100, 1))%, dominant=$dominantFeeling"
        }
    } catch {
        Write-HookLog "Homeostatic snapshot failed: $($_.Exception.Message)"
    }

} catch {
    Write-HookLog "ERROR: $($_.Exception.Message)"
}

exit 0
