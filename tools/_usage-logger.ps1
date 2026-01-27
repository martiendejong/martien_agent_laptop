# INTERNAL: Automatic Usage Logger - Called by all tools
# Do not call directly - this is infrastructure
#
# WARNING: This script uses parameter names that might conflict with caller variables
# when dot-sourced. Use unique parameter names prefixed with 'Log' to avoid collisions.
# Callers should use: -LogToolName instead of -ToolName, etc.

param(
    [Parameter(Mandatory=$true)]
    [Alias('ToolName')]
    [string]$LogToolName,

    [Parameter(Mandatory=$false)]
    [Alias('Action')]
    [string]$LogAction = "execute",

    [Parameter(Mandatory=$false)]
    [Alias('Metadata')]
    [hashtable]$LogMetadata = @{}
)

$LogFile = "C:\scripts\_machine\tool-usage-log.jsonl"

# Ensure log file exists
if (-not (Test-Path $LogFile)) {
    "" | Set-Content $LogFile -Encoding UTF8
}

# Create log entry
$entry = @{
    Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    Tool = $LogToolName
    Action = $LogAction
    Metadata = $LogMetadata
    User = $env:USERNAME
    Session = $PID
}

# Append to log (JSONL format - one JSON object per line)
$entry | ConvertTo-Json -Compress | Add-Content $LogFile -Encoding UTF8

# Also update aggregated stats (fast lookup)
$StatsFile = "C:\scripts\_machine\tool-usage-stats.json"

if (Test-Path $StatsFile) {
    $stats = Get-Content $StatsFile -Raw | ConvertFrom-Json
} else {
    $stats = @{ Tools = @{} }
}

if (-not $stats.Tools.$LogToolName) {
    $stats.Tools | Add-Member -MemberType NoteProperty -Name $LogToolName -Value @{
        TotalCalls = 0
        FirstUsed = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        LastUsed = $null
        RecentCalls = 0
    }
}

$stats.Tools.$LogToolName.TotalCalls++
$stats.Tools.$LogToolName.LastUsed = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Save stats
$stats | ConvertTo-Json -Depth 10 | Set-Content $StatsFile -Encoding UTF8
