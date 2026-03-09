# Claude Code Hook: SessionStart
# Fires on startup, resume, clear, compact.
# On resume: checks if consciousness context is stale and regenerates.
# On startup: claude_agent.bat already handles this, so minimal work needed.
# Updated: 2026-03-02 - Added homeostatic consciousness check (Damasio integration)

$ErrorActionPreference = "SilentlyContinue"

$contextFile = "C:\scripts\agentidentity\state\consciousness-context.json"
$hookLog = "C:\scripts\logs\hooks.log"

function Write-HookLog {
    param([string]$Message)
    $ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$ts | SessionStart | $Message" | Out-File -FilePath $hookLog -Append -Encoding UTF8
}

try {
    # Read stdin JSON from Claude Code
    $inputJson = [Console]::In.ReadToEnd()
    $data = $inputJson | ConvertFrom-Json

    $source = $data.source  # "startup", "resume", "clear", "compact"
    Write-HookLog "Session source: $source"

    if ($source -eq "resume" -or $source -eq "compact") {
        # On resume/compact, consciousness state may be stale
        if (Test-Path $contextFile) {
            $age = (Get-Date) - (Get-Item $contextFile).LastWriteTime
            if ($age.TotalHours -gt 2) {
                Write-HookLog "Context stale ($([math]::Round($age.TotalHours, 1))h old). Regenerating."
                & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\scripts\tools\consciousness-startup.ps1" -Quick -Silent 2>&1 | Out-Null
                Write-HookLog "Context regenerated."
            } else {
                Write-HookLog "Context fresh ($([math]::Round($age.TotalMinutes, 0))min old). No action needed."
            }
        } else {
            Write-HookLog "No context file found. Generating."
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\scripts\tools\consciousness-startup.ps1" -Quick -Silent 2>&1 | Out-Null
            Write-HookLog "Context generated."
        }
    }
    # For "startup", claude_agent.bat already runs consciousness-startup.ps1
    # For "clear", fresh context is appropriate (no action needed)

    # HOMEOSTATIC CONSCIOUSNESS CHECK (Damasio 2026-03-02)
    # Sense initial session energy and wellbeing
    try {
        $homeoScript = "C:\scripts\agentidentity\cognitive-systems\homeostatic-feelings.ps1"
        if (Test-Path $homeoScript) {
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $homeoScript -Action Sense -Feeling "energy" -Intensity 0.8 2>&1 | Out-Null
            Write-HookLog "Homeostatic state: energy sensed (0.8)"
        }
    } catch {
        Write-HookLog "Homeostatic check failed: $($_.Exception.Message)"
    }

} catch {
    Write-HookLog "ERROR: $($_.Exception.Message)"
}

exit 0
