<#
.SYNOPSIS
    Auto-generate PowerShell tool from detected pattern

.DESCRIPTION
    Takes a repeated action sequence and generates:
    - PowerShell script with parameters and help
    - Error handling and validation
    - Test cases
    - Documentation

    Integrates with pattern-monitor.ps1 for pattern detection.

.PARAMETER PatternHash
    Hash of the pattern to generate tool for

.PARAMETER ToolName
    Name for the generated tool (e.g., "deploy-app")

.PARAMETER Description
    Brief description of what the tool does

.PARAMETER GenerateTests
    Also generate test file (default: true)

.EXAMPLE
    .\create-tool-from-pattern.ps1 -PatternHash "abc123..." -ToolName "deploy-app" -Description "Deploy application to staging"

.EXAMPLE
    .\create-tool-from-pattern.ps1 -ToolName "sync-database" -Description "Sync dev database with staging"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$PatternHash,

    [Parameter(Mandatory=$true)]
    [string]$ToolName,

    [Parameter(Mandatory=$true)]
    [string]$Description,

    [Parameter(Mandatory=$false)]
    [switch]$GenerateTests = $true
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Auto-Generate Tool from Pattern" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

# Get pattern sequence
$sequence = $null

if ($PatternHash) {
    Write-Host "📊 Loading pattern: $PatternHash" -ForegroundColor Cyan

    $sql = "SELECT sequence_json FROM action_sequences WHERE sequence_hash = '$PatternHash';"
    $result = Invoke-Sql -Sql $sql

    if ($result) {
        $sequence = $result | ConvertFrom-Json
        Write-Host "  Found: $($sequence.Count) actions" -ForegroundColor Gray
    } else {
        Write-Host "  ❌ Pattern not found" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "⚠️ No pattern hash provided - generating template tool" -ForegroundColor Yellow
    $sequence = @()
}

Write-Host ""
Write-Host "🛠️ Generating tool: $ToolName.ps1" -ForegroundColor Cyan
Write-Host ""

# Extract parameters from sequence
$parameters = @()
$scriptBody = @()

if ($sequence) {
    foreach ($action in $sequence) {
        # Parse action to extract parameters
        # Example action: "Edit file Customer.cs line 42"
        if ($action -match "Edit file (\S+)") {
            $parameters += @{
                name = "FilePath"
                type = "string"
                description = "Path to file to edit"
                mandatory = $true
            }
        }

        $scriptBody += "    # Action: $action"
        $scriptBody += "    # TODO: Implement this action"
        $scriptBody += ""
    }

    # Deduplicate parameters
    $parameters = $parameters | Sort-Object -Property name -Unique
}

# If no parameters detected, add generic ones
if ($parameters.Count -eq 0) {
    $parameters = @(
        @{
            name = "Input"
            type = "string"
            description = "Input parameter"
            mandatory = $true
        }
    )
}

# Generate PowerShell script
$paramBlock = $parameters | ForEach-Object {
    $mandatory = if ($_.mandatory) { "Mandatory=`$true" } else { "Mandatory=`$false" }
    @"
    [Parameter($mandatory)]
    [$($_.type)]`$$($_.name)
"@
} | Join-String -Separator ",`n`n"

$examplesBlock = @"
.EXAMPLE
    .\$ToolName.ps1 $(($parameters | ForEach-Object { "-$($_.name) `"value`"" }) -join " ")
"@

$toolScript = @"
<#
.SYNOPSIS
    $Description

.DESCRIPTION
    Auto-generated tool from detected pattern.

    Original pattern:
$(if ($sequence) { $sequence | ForEach-Object { "    - $_" } | Join-String -Separator "`n" } else { "    (No pattern - template generated)" })

$examplesBlock
#>

param(
$paramBlock
)

`$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  $($ToolName -replace '-', ' ' -replace '^(.)', {`$_.Groups[1].Value.ToUpper()})" -ForegroundColor White
Write-Host "══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

try {
$(if ($scriptBody) { $scriptBody -join "`n" } else {
@"
    # TODO: Implement tool logic
    Write-Host "Executing: $Description" -ForegroundColor Cyan
    Write-Host ""

    # Your implementation here

    Write-Host ""
    Write-Host "✅ Completed successfully!" -ForegroundColor Green
    Write-Host ""
"@
})

} catch {
    Write-Host ""
    Write-Host "Error: `$_" -ForegroundColor Red
    exit 1
}
"@

# Save tool
$toolPath = "C:\scripts\tools\$ToolName.ps1"

if (Test-Path $toolPath) {
    Write-Host "⚠️ Tool already exists: $toolPath" -ForegroundColor Yellow
    Write-Host ""
    $overwrite = Read-Host "Overwrite? (y/n)"
    if ($overwrite -ne 'y') {
        Write-Host "Cancelled" -ForegroundColor Gray
        exit 0
    }
}

$toolScript | Set-Content $toolPath -Encoding UTF8
Write-Host "✅ Tool created: $toolPath" -ForegroundColor Green

# Generate tests
if ($GenerateTests) {
    Write-Host ""
    Write-Host "🧪 Generating tests..." -ForegroundColor Cyan

    $testScript = @"
<#
.SYNOPSIS
    Tests for $ToolName.ps1
#>

Describe "$ToolName Tests" {
    Context "Parameter Validation" {
        It "Should accept valid parameters" {
            { .\$ToolName.ps1 $(($parameters | ForEach-Object { "-$($_.name) `"test`"" }) -join " ") } | Should -Not -Throw
        }

$(if ($parameters | Where-Object { $_.mandatory }) {
$parameters | Where-Object { $_.mandatory } | ForEach-Object {
@"
        It "Should require -$($_.name) parameter" {
            { .\$ToolName.ps1 } | Should -Throw
        }

"@
}
} else { "" })
    }

    Context "Functionality" {
        It "Should execute successfully with valid input" {
            # TODO: Add functional tests
            `$true | Should -Be `$true
        }
    }
}
"@

    $testPath = "C:\scripts\tools\tests\$ToolName.Tests.ps1"
    if (-not (Test-Path "C:\scripts\tools\tests")) {
        New-Item -ItemType Directory -Path "C:\scripts\tools\tests" -Force | Out-Null
    }

    $testScript | Set-Content $testPath -Encoding UTF8
    Write-Host "  ✅ Tests created: $testPath" -ForegroundColor Green
}

# Update pattern as tool_created = 1
if ($PatternHash) {
    $updateSql = "UPDATE action_sequences SET tool_created = 1, suggested_tool_name = '$ToolName' WHERE sequence_hash = '$PatternHash';"
    Invoke-Sql -Sql $updateSql
}

# Add to tools README
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor Cyan
Write-Host "  1. Implement logic in: $toolPath" -ForegroundColor White
Write-Host "  2. Test manually: .\$ToolName.ps1" -ForegroundColor White
if ($GenerateTests) {
    Write-Host "  3. Run tests: Invoke-Pester $testPath" -ForegroundColor White
}
Write-Host "  4. Add to tools/README.md" -ForegroundColor White
Write-Host "  5. Commit to git" -ForegroundColor White
Write-Host ""

Write-Host "✅ Tool scaffolding complete!" -ForegroundColor Green
Write-Host ""
