# friendly-errors.ps1
# Converts cryptic technical errors into helpful, actionable messages
# Includes suggestions for common error scenarios

param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string]$ErrorMessage,

    [string]$Context = "",
    [switch]$ShowStackTrace,
    [switch]$JSON
)

$script:ErrorPatterns = @(
    @{
        Pattern = "The term '.*' is not recognized"
        FriendlyMessage = "Command not found"
        Suggestions = @(
            "Check if the command is installed",
            "Verify the PATH environment variable",
            "Try using the full path to the executable"
        )
        Severity = "Medium"
    },
    @{
        Pattern = "Access.*denied"
        FriendlyMessage = "Permission denied"
        Suggestions = @(
            "Run PowerShell as Administrator",
            "Check file/folder permissions",
            "Verify you have necessary access rights"
        )
        Severity = "High"
    },
    @{
        Pattern = "Cannot find path.*because it does not exist"
        FriendlyMessage = "File or folder not found"
        Suggestions = @(
            "Check if the path is correct",
            "Verify the file/folder exists",
            "Use Tab completion to avoid typos"
        )
        Severity = "Medium"
    },
    @{
        Pattern = "merge conflict"
        FriendlyMessage = "Git merge conflict detected"
        Suggestions = @(
            "Open conflicted files and resolve markers (<<<, ===, >>>)",
            "Stage resolved files with: git add <file>",
            "Complete merge with: git commit",
            "Or abort merge with: git merge --abort"
        )
        Severity = "High"
    },
    @{
        Pattern = "port.*already in use|address already in use"
        FriendlyMessage = "Port already in use by another process"
        Suggestions = @(
            "Find process using port: netstat -ano | findstr :<port>",
            "Kill process: taskkill /PID <pid> /F",
            "Or use a different port number"
        )
        Severity = "Medium"
    },
    @{
        Pattern = "ECONNREFUSED|connection refused"
        FriendlyMessage = "Connection refused - service not running"
        Suggestions = @(
            "Check if the service/application is running",
            "Verify the correct host and port",
            "Check firewall settings"
        )
        Severity = "High"
    },
    @{
        Pattern = "out of memory|OutOfMemoryException"
        FriendlyMessage = "System ran out of memory"
        Suggestions = @(
            "Close other applications to free memory",
            "Increase system RAM if possible",
            "Optimize code to use less memory",
            "Process data in smaller chunks"
        )
        Severity = "Critical"
    },
    @{
        Pattern = "timeout|timed out"
        FriendlyMessage = "Operation timed out"
        Suggestions = @(
            "Check network connection",
            "Increase timeout duration if possible",
            "Verify remote service is responding"
        )
        Severity = "Medium"
    },
    @{
        Pattern = "null reference|NullReferenceException"
        FriendlyMessage = "Tried to use something that doesn't exist (null reference)"
        Suggestions = @(
            "Check if variable is initialized before use",
            "Add null checks: if (\$var -ne \$null) { ... }",
            "Use -ErrorAction SilentlyContinue to handle gracefully"
        )
        Severity = "Medium"
    },
    @{
        Pattern = "certificate|SSL|TLS"
        FriendlyMessage = "SSL/Certificate validation failed"
        Suggestions = @(
            "Check if certificate is valid and not expired",
            "Trust the certificate if it's self-signed (testing only)",
            "Verify system clock is correct",
            "Update root certificates if needed"
        )
        Severity = "High"
    }
)

function Find-ErrorPattern {
    param([string]$ErrorText)

    foreach ($pattern in $script:ErrorPatterns) {
        if ($ErrorText -match $pattern.Pattern) {
            return $pattern
        }
    }

    return $null
}

function Format-FriendlyError {
    param(
        [string]$ErrorMessage,
        [string]$Context,
        [bool]$ShowStack
    )

    $pattern = Find-ErrorPattern -ErrorText $ErrorMessage

    if ($pattern) {
        # Friendly error format
        $severityColor = switch ($pattern.Severity) {
            "Critical" { "Red" }
            "High" { "Red" }
            "Medium" { "Yellow" }
            "Low" { "Gray" }
            default { "Yellow" }
        }

        Write-Host "`n❌ ERROR: $($pattern.FriendlyMessage)" -ForegroundColor $severityColor
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

        if ($Context) {
            Write-Host "`n📍 Context: $Context" -ForegroundColor Cyan
        }

        Write-Host "`n💡 Suggestions:" -ForegroundColor Green
        $pattern.Suggestions | ForEach-Object { Write-Host "   • $_" -ForegroundColor White }

        if ($ShowStack) {
            Write-Host "`n🔍 Technical Details:" -ForegroundColor DarkGray
            Write-Host "   $ErrorMessage" -ForegroundColor DarkGray
        }

        Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor DarkGray

        return @{
            Friendly = $pattern.FriendlyMessage
            Suggestions = $pattern.Suggestions
            Severity = $pattern.Severity
            Original = $ErrorMessage
        }
    } else {
        # Unknown error - generic format
        Write-Host "`n❌ ERROR" -ForegroundColor Red
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

        if ($Context) {
            Write-Host "`n📍 Context: $Context" -ForegroundColor Cyan
        }

        Write-Host "`n$ErrorMessage" -ForegroundColor White

        Write-Host "`n💡 General Troubleshooting:" -ForegroundColor Green
        Write-Host "   • Check the error message for clues" -ForegroundColor White
        Write-Host "   • Search online: `"$($ErrorMessage.Substring(0, [Math]::Min(50, $ErrorMessage.Length)))`"" -ForegroundColor White
        Write-Host "   • Check logs for more details" -ForegroundColor White
        Write-Host "   • Try the operation again" -ForegroundColor White

        Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor DarkGray

        return @{
            Friendly = "Unknown error"
            Suggestions = @("Check the error message for clues", "Search online", "Check logs")
            Severity = "Medium"
            Original = $ErrorMessage
        }
    }
}

# Main logic
$result = Format-FriendlyError -ErrorMessage $ErrorMessage -Context $Context -ShowStack:$ShowStackTrace

if ($JSON) {
    $result | ConvertTo-Json
} else {
    # Already formatted above
}
