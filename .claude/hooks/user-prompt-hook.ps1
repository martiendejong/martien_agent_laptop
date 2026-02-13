# Claude Code Hook: UserPromptSubmit (ASYNC)
# Fires on every user message. Calls OnUserMessage bridge for social calibration.
# Runs async so it never blocks the user experience.

$ErrorActionPreference = "SilentlyContinue"

$bridgeScript = "C:\scripts\tools\consciousness-bridge.ps1"
$hookLog = "C:\scripts\logs\hooks.log"

function Write-HookLog {
    param([string]$Message)
    $ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$ts | UserPrompt | $Message" | Out-File -FilePath $hookLog -Append -Encoding UTF8
}

try {
    # Read stdin JSON from Claude Code
    $inputJson = [Console]::In.ReadToEnd()
    $data = $inputJson | ConvertFrom-Json

    $prompt = $data.prompt
    if ($prompt -and $prompt.Length -gt 3) {
        # Truncate very long messages to avoid command line length issues
        $truncated = if ($prompt.Length -gt 500) { $prompt.Substring(0, 500) } else { $prompt }

        # Escape double quotes for command line
        $escaped = $truncated -replace '"', '\"'

        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $bridgeScript -Action OnUserMessage -UserMessage "$escaped" -Silent 2>&1 | Out-Null
    }
} catch {
    Write-HookLog "ERROR: $($_.Exception.Message)"
}

exit 0
