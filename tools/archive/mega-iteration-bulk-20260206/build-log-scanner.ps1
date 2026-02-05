# build-log-scanner.ps1
# Proactively scan recent build logs before asking user questions

param(
    [ValidateSet('auto', 'frontend', 'backend', 'all')]
    [string]$Target = 'auto',

    [int]$MaxAge = 60,  # Minutes

    [switch]$Summary
)

$timestamp = Get-Date

# Define log locations
$logLocations = @{
    frontend = @{
        name = "Frontend (npm/vite)"
        paths = @(
            "C:\Projects\client-manager\npm-debug.log"
            "C:\Projects\client-manager\frontend\npm-debug.log"
            "$env:TEMP\vite-*.log"
        )
        patterns = @("ERROR", "Failed to compile", "Module not found", "Syntax error")
    }
    backend = @{
        name = "Backend (dotnet/MSBuild)"
        paths = @(
            "C:\Projects\client-manager\msbuild.log"
            "C:\Projects\client-manager\bin\Debug\*.log"
        )
        patterns = @("error CS", "error MSB", "Build FAILED", "Exception")
    }
}

function Get-RecentErrors {
    param($logPath, $patterns, $maxAgeMinutes)

    if (-not (Test-Path $logPath)) {
        return $null
    }

    $file = Get-Item $logPath
    if (($timestamp - $file.LastWriteTime).TotalMinutes -gt $maxAgeMinutes) {
        return $null
    }

    $content = Get-Content $logPath -Tail 500 -ErrorAction SilentlyContinue
    if (-not $content) { return $null }

    $errors = @()
    foreach ($pattern in $patterns) {
        $matches = $content | Select-String -Pattern $pattern -Context 1,2
        foreach ($match in $matches) {
            $errors += @{
                pattern = $pattern
                line = $match.Line
                context = $match.Context.PostContext -join "`n"
                lineNumber = $match.LineNumber
            }
        }
    }

    if ($errors.Count -gt 0) {
        return @{
            file = $logPath
            lastModified = $file.LastWriteTime
            errors = $errors
        }
    }

    return $null
}

# Determine what to scan
$targetsToScan = @()
if ($Target -eq 'auto' -or $Target -eq 'all') {
    $targetsToScan = @('frontend', 'backend')
} else {
    $targetsToScan = @($Target)
}

# Scan logs
$findings = @{}
foreach ($targetName in $targetsToScan) {
    $targetInfo = $logLocations[$targetName]

    foreach ($logPath in $targetInfo.paths) {
        # Handle wildcards
        if ($logPath -like "*`**") {
            $files = Get-ChildItem -Path (Split-Path $logPath) -Filter (Split-Path $logPath -Leaf) -ErrorAction SilentlyContinue
            foreach ($file in $files) {
                $result = Get-RecentErrors -logPath $file.FullName -patterns $targetInfo.patterns -maxAgeMinutes $MaxAge
                if ($result) {
                    if (-not $findings.ContainsKey($targetName)) {
                        $findings[$targetName] = @()
                    }
                    $findings[$targetName] += $result
                }
            }
        } else {
            $result = Get-RecentErrors -logPath $logPath -patterns $targetInfo.patterns -maxAgeMinutes $MaxAge
            if ($result) {
                if (-not $findings.ContainsKey($targetName)) {
                    $findings[$targetName] = @()
                }
                $findings[$targetName] += $result
            }
        }
    }
}

# Output results
if ($findings.Count -eq 0) {
    Write-Host "✅ No recent build errors found (last $MaxAge minutes)" -ForegroundColor Green
    return
}

Write-Host "`n🔍 RECENT BUILD ERRORS DETECTED" -ForegroundColor Red
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

foreach ($targetName in $findings.Keys) {
    $targetInfo = $logLocations[$targetName]
    Write-Host "`n📁 $($targetInfo.name)" -ForegroundColor Yellow

    foreach ($logResult in $findings[$targetName]) {
        Write-Host "   File: " -NoNewline -ForegroundColor Gray
        Write-Host $logResult.file -ForegroundColor White
        Write-Host "   Modified: " -NoNewline -ForegroundColor Gray
        Write-Host $logResult.lastModified -ForegroundColor DarkGray

        if ($Summary) {
            Write-Host "   Errors: " -NoNewline -ForegroundColor Gray
            Write-Host "$($logResult.errors.Count) found" -ForegroundColor Red
        } else {
            Write-Host "   Errors:" -ForegroundColor Red

            $displayedErrors = $logResult.errors | Select-Object -First 5
            foreach ($error in $displayedErrors) {
                Write-Host "   • " -NoNewline -ForegroundColor DarkGray
                Write-Host $error.line -ForegroundColor Red
                if ($error.context) {
                    Write-Host "     Context: " -NoNewline -ForegroundColor DarkGray
                    Write-Host $error.context -ForegroundColor Gray
                }
            }

            if ($logResult.errors.Count -gt 5) {
                Write-Host "   ... and $($logResult.errors.Count - 5) more errors" -ForegroundColor DarkGray
            }
        }
    }
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

# Save to state for other tools to use
$stateOutput = @{
    scanned_at = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    max_age_minutes = $MaxAge
    findings = $findings
}

$statePath = "C:\scripts\agentidentity\state\recent-build-errors.yaml"
$stateOutput | ConvertTo-Yaml | Out-File -FilePath $statePath -Encoding UTF8

Write-Output "`nSaved to: $statePath"
