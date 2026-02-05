<#
.SYNOPSIS
    Extract exact quote from source with surrounding context

.DESCRIPTION
    Retrieves a specific line from a file with surrounding context
    Formats output for citation in content

.PARAMETER File
    Path to the source file

.PARAMETER LineNumber
    Line number to extract

.PARAMETER Context
    Number of lines before/after to include (default: 5)

.PARAMETER Format
    Output format: markdown, plain, citation (default: citation)

.EXAMPLE
    .\source-quote.ps1 -File "C:\gemeente_emails\TIJDLIJN.md" -LineNumber 123 -Context 5

.EXAMPLE
    .\source-quote.ps1 -File "path" -LineNumber 50 -Format markdown

.NOTES
    Part of FACT_VERIFICATION_PROTOCOL.md
    Created: 2026-01-26
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$File,

    [Parameter(Mandatory=$true)]
    [int]$LineNumber,

    [int]$Context = 5,

    [ValidateSet('markdown', 'plain', 'citation')]
    [string]$Format = 'citation'
)

if (-not (Test-Path $File)) {
    Write-Host "ERROR: File not found: $File" -ForegroundColor Red
    exit 1
}

$allLines = Get-Content $File
$totalLines = $allLines.Count

if ($LineNumber -lt 1 -or $LineNumber -gt $totalLines) {
    Write-Host "ERROR: Line number $LineNumber out of range (file has $totalLines lines)" -ForegroundColor Red
    exit 1
}

# Calculate range
$startLine = [Math]::Max(1, $LineNumber - $Context)
$endLine = [Math]::Min($totalLines, $LineNumber + $Context)

# Get lines (arrays are 0-indexed, so subtract 1)
$targetLine = $allLines[$LineNumber - 1]
$beforeLines = if ($startLine -lt $LineNumber) { $allLines[($startLine-1)..($LineNumber-2)] } else { @() }
$afterLines = if ($endLine -gt $LineNumber) { $allLines[$LineNumber..($endLine-1)] } else { @() }

# Format output
switch ($Format) {
    'plain' {
        Write-Host "File: $File" -ForegroundColor Cyan
        Write-Host "Line $LineNumber" -ForegroundColor Cyan
        Write-Host ""

        if ($beforeLines) {
            $beforeLines | ForEach-Object -Begin { $i = $startLine } -Process {
                Write-Host "  $i│ $_" -ForegroundColor Gray
                $i++
            }
        }

        Write-Host "→ $LineNumber│ $targetLine" -ForegroundColor Yellow

        if ($afterLines) {
            $afterLines | ForEach-Object -Begin { $i = $LineNumber + 1 } -Process {
                Write-Host "  $i│ $_" -ForegroundColor Gray
                $i++
            }
        }
    }

    'markdown' {
        Write-Host "## Quote from $([System.IO.Path]::GetFileName($File))"
        Write-Host ""
        Write-Host "**Source:** ``$File`` (line $LineNumber)"
        Write-Host ""
        Write-Host "````"

        if ($beforeLines) {
            $beforeLines | ForEach-Object { Write-Host $_ }
        }

        Write-Host "→ $targetLine" -ForegroundColor Yellow

        if ($afterLines) {
            $afterLines | ForEach-Object { Write-Host $_ }
        }

        Write-Host "````"
    }

    'citation' {
        Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "CITATION-READY QUOTE" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "SOURCE:" -ForegroundColor Yellow
        Write-Host "  File: $File"
        Write-Host "  Line: $LineNumber"
        Write-Host ""
        Write-Host "CONTEXT (lines $startLine-$endLine):" -ForegroundColor Yellow
        Write-Host ""

        if ($beforeLines) {
            $beforeLines | ForEach-Object -Begin { $i = $startLine } -Process {
                Write-Host "  $i│ $_" -ForegroundColor Gray
                $i++
            }
        }

        Write-Host "→ $LineNumber│ $targetLine" -ForegroundColor Green

        if ($afterLines) {
            $afterLines | ForEach-Object -Begin { $i = $LineNumber + 1 } -Process {
                Write-Host "  $i│ $_" -ForegroundColor Gray
                $i++
            }
        }

        Write-Host ""
        Write-Host "EXACT QUOTE:" -ForegroundColor Yellow
        Write-Host "  `"$targetLine`""
        Write-Host ""
        Write-Host "CITATION FORMAT:" -ForegroundColor Yellow
        Write-Host "  Source: $([System.IO.Path]::GetFileName($File)):$LineNumber"
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    }
}
