<#
.SYNOPSIS
    Migrate ClickUp tasks to new naming and tagging convention
.DESCRIPTION
    Updates task names and adds tags according to CLICKUP_NAMING_AND_TAGGING.md
#>

param(
    [ValidateSet("client-manager", "art-revisionist", "both")]
    [string]$Project = "both",

    [switch]$DryRun = $false
)

# Load config
$configPath = "C:\scripts\_machine\clickup-config.json"
$config = Get-Content $configPath | ConvertFrom-Json
$apiKey = $config.api_key
$apiBase = $config.api_base

$headers = @{
    "Authorization" = $apiKey
    "Content-Type" = "application/json"
}

function Update-TaskNameAndTags {
    param(
        [string]$TaskId,
        [string]$NewName,
        [string[]]$Tags,
        [string]$MigrationComment
    )

    if ($DryRun) {
        Write-Host "[DRY RUN] Would update task $TaskId" -ForegroundColor Yellow
        Write-Host "  New Name: $NewName" -ForegroundColor Cyan
        Write-Host "  Tags: $($Tags -join ', ')" -ForegroundColor Cyan
        return
    }

    # Update task name
    $url = "$apiBase/task/$TaskId"
    $body = @{ name = $NewName } | ConvertTo-Json

    try {
        Invoke-RestMethod -Method PUT -Uri $url -Headers $headers -Body $body | Out-Null
        Write-Host "✓ Renamed: $NewName" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to rename task $TaskId : $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    # Add tags
    foreach ($tag in $Tags) {
        $tagUrl = "$apiBase/task/$TaskId/tag/$tag"
        try {
            Invoke-RestMethod -Method POST -Uri $tagUrl -Headers $headers | Out-Null
            Write-Host "  + Tag: $tag" -ForegroundColor Gray
        } catch {
            # Tag might already exist or need creation - try creating tag first
            Write-Host "  ! Tag issue: $tag (might need creation in ClickUp first)" -ForegroundColor Yellow
        }
    }

    # Add migration comment
    if ($MigrationComment) {
        $commentUrl = "$apiBase/task/$TaskId/comment"
        $commentBody = @{ comment_text = $MigrationComment } | ConvertTo-Json
        try {
            Invoke-RestMethod -Method POST -Uri $commentUrl -Headers $headers -Body $commentBody | Out-Null
            Write-Host "  ✓ Migration comment added" -ForegroundColor Gray
        } catch {
            Write-Host "  ! Comment failed" -ForegroundColor Yellow
        }
    }
}

# Manual migrations for already-analyzed tasks
$knownMigrations = @(
    @{
        TaskId = "869c1dnyd"
        NewName = "FEAT [M] Post Duplication System (Social Media)"
        Tags = @("moscow:must-have", "type:feature", "domain:social-media", "complexity:complex")
        Project = "client-manager"
    },
    @{
        TaskId = "869c1dpq4"
        NewName = "FEAT [S] Provenance Confidence Scoring (Metadata)"
        Tags = @("moscow:should-have", "type:feature", "domain:metadata", "complexity:moderate", "impact:high")
        Project = "art-revisionist"
    },
    @{
        TaskId = "869c1dppx"
        NewName = "FEAT [S] Similar Artwork Visual Search (Search)"
        Tags = @("moscow:should-have", "type:feature", "domain:ai-vision", "domain:search", "complexity:moderate", "impact:high")
        Project = "art-revisionist"
    },
    @{
        TaskId = "869c1dnx7"
        NewName = "FEAT [S] Media Upload & Management (Content)"
        Tags = @("moscow:should-have", "type:feature", "domain:frontend", "domain:backend", "complexity:complex", "blocked:scope")
        Project = "client-manager"
    },
    @{
        TaskId = "869c1dppk"
        NewName = "FEAT [M] AI Art Style Classifier (Metadata)"
        Tags = @("moscow:must-have", "type:feature", "domain:ai-vision", "domain:metadata", "complexity:moderate", "impact:high")
        Project = "art-revisionist"
    }
)

$migrationComment = "📋 Task renamed and tagged per new naming/tagging system (2026-02-07)

See: C:\scripts\CLICKUP_NAMING_AND_TAGGING.md

-- Claude Code Agent"

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " ClickUp Task Migration - Naming & Tagging System" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN MODE - No changes will be made]" -ForegroundColor Yellow
    Write-Host ""
}

# Migrate known tasks
$filtered = $knownMigrations | Where-Object {
    $Project -eq "both" -or $_.Project -eq $Project
}

Write-Host "Migrating $($filtered.Count) pre-analyzed tasks..." -ForegroundColor White
Write-Host ""

foreach ($task in $filtered) {
    Write-Host "Task: $($task.TaskId) [$($task.Project)]" -ForegroundColor White
    Update-TaskNameAndTags -TaskId $task.TaskId -NewName $task.NewName -Tags $task.Tags -MigrationComment $migrationComment
    Write-Host ""
}

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host " Migration Complete!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
