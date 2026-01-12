# Dynamic Terminal Color Management for Claude Code
# Sets terminal background color based on execution state

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("running", "complete", "blocked", "idle")]
    [string]$State
)

# Enable ANSI escape sequences for Windows Console
$host.UI.RawUI.ForegroundColor = "White"

# ANSI color codes
$colors = @{
    "running"  = "`e[44m`e[97m"  # Blue background, bright white text
    "complete" = "`e[42m`e[97m"  # Green background, bright white text
    "blocked"  = "`e[41m`e[97m"  # Red background, bright white text
    "idle"     = "`e[40m`e[97m"  # Black background, bright white text
}

# Emit ANSI escape sequence (no clear screen)
Write-Host -NoNewline $colors[$State]

# Also update window title with status emoji
$emojis = @{
    "running"  = "🔵"
    "complete" = "🟢"
    "blocked"  = "🔴"
    "idle"     = "⚪"
}

# Get current branch if in git repo
$branch = (git branch --show-current 2>$null)
if ($branch) {
    $branch = $branch.ToUpper()
    $title = "$($emojis[$State]) $State - $branch"
} else {
    $title = "$($emojis[$State]) CLAUDE AGENT - $state"
}

$host.UI.RawUI.WindowTitle = $title

# Log state change (optional)
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
Add-Content -Path "C:\scripts\logs\color-state.log" -Value "$timestamp - $State" -ErrorAction SilentlyContinue
