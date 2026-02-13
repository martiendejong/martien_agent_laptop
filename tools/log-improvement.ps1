<#
.SYNOPSIS
    Log a 1% improvement for the day.
.DESCRIPTION
    Tracks daily micro-improvements in improvements-1pct.jsonl.
    Called after making a small improvement during a session.
.EXAMPLE
    .\log-improvement.ps1 -What "Deleted stale .search-index.json" -Category "cleanup"
    .\log-improvement.ps1 -What "Fixed services-query path reference" -Category "fix"
#>
param(
    [Parameter(Mandatory)]
    [string]$What,

    [ValidateSet('cleanup', 'fix', 'optimize', 'document', 'automate', 'security', 'other')]
    [string]$Category = 'other'
)

$logFile = "C:\scripts\_machine\improvements-1pct.jsonl"

$entry = @{
    date = Get-Date -Format "yyyy-MM-dd"
    time = Get-Date -Format "HH:mm:ss"
    what = $What
    category = $Category
} | ConvertTo-Json -Compress

[System.IO.File]::AppendAllText($logFile, "$entry`n")

Write-Host "[1%] Logged: $What ($Category)" -ForegroundColor Green
