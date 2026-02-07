<#
.SYNOPSIS
    Migrate ALL ClickUp tasks to new naming and tagging convention
.DESCRIPTION
    Intelligently analyzes and updates all active tasks
#>

param(
    [ValidateSet("client-manager", "art-revisionist", "both")]

$ErrorActionPreference = "Stop"
    [string]$Project = "both",

    [ValidateSet("todo", "busy", "blocked", "review", "all")]
    [string]$StatusFilter = "all",

    [switch]$DryRun = $false,

    [int]$MaxTasks = 0  # 0 = unlimited
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

# Skip already-migrated tasks
$alreadyMigrated = @("869c1dnyd", "869c1dpq4", "869c1dppx", "869c1dnx7", "869c1dppk")

function Detect-TaskType {
    param([string]$Name, [string]$Description)

    $nameLower = $Name.ToLower()
    $descLower = $Description.ToLower()

    # Already has type prefix?
    if ($Name -match '^(FEAT|FIX|ENH|REFACTOR|DOC|TEST|INFRA)\s') {
        return $matches[1]
    }

    # Bug keywords
    if ($nameLower -match '\b(fix|bug|error|broken|not working|issue|crash)\b') {
        return "FIX"
    }

    # Enhancement keywords
    if ($nameLower -match '\b(improve|enhance|better|optimize|upgrade)\b') {
        return "ENH"
    }

    # Documentation
    if ($nameLower -match '\b(doc|documentation|readme|guide)\b') {
        return "DOC"
    }

    # Phase/Feature indicators
    if ($nameLower -match '\b(phase|mvp|system|feature|add|create|implement)\b') {
        return "FEAT"
    }

    # Default to FEAT
    return "FEAT"
}

function Detect-Domain {
    param([string]$Name, [string]$Description, [string]$ProjectName)

    $text = "$Name $Description".ToLower()
    $domains = @()

    if ($ProjectName -eq "client-manager") {
        if ($text -match '\b(social media|post|linkedin|facebook|instagram|platform)\b') { $domains += "social-media" }
        if ($text -match '\b(calendar|schedule|date|time)\b') { $domains += "calendar" }
        if ($text -match '\b(chat|message|conversation)\b') { $domains += "chat" }
        if ($text -match '\b(dashboard|analytics|metrics)\b') { $domains += "dashboard" }
        if ($text -match '\b(auth|login|signup|register)\b') { $domains += "auth" }
        if ($text -match '\b(api|backend|service|endpoint)\b') { $domains += "backend" }
        if ($text -match '\b(ui|ux|frontend|react|component)\b') { $domains += "frontend" }
        if ($text -match '\b(ai|llm|gpt|openai|generate)\b') { $domains += "ai-llm" }
        if ($text -match '\b(database|db|sql|migration)\b') { $domains += "database" }
    } else {
        # art-revisionist
        if ($text -match '\b(wordpress|wp|cms)\b') { $domains += "wordpress" }
        if ($text -match '\b(ai|vision|classifier|detect)\b') { $domains += "ai-vision" }
        if ($text -match '\b(metadata|tag|category|field)\b') { $domains += "metadata" }
        if ($text -match '\b(provenance|ownership|history)\b') { $domains += "provenance" }
        if ($text -match '\b(search|find|filter|query)\b') { $domains += "search" }
        if ($text -match '\b(image|media|photo|upload)\b') { $domains += "media" }
        if ($text -match '\b(frontend|ui|react)\b') { $domains += "frontend" }
        if ($text -match '\b(backend|api|database)\b') { $domains += "backend" }
    }

    if ($domains.Count -eq 0) {
        $domains += "general"
    }

    return $domains[0..1]  # Max 2 domains
}

function Detect-Component {
    param([string]$Name, [string]$Description, [string[]]$Domains)

    # Extract component from existing parentheses
    if ($Name -match '\(([^)]+)\)$') {
        return $matches[1]
    }

    # Use first domain as component
    $componentMap = @{
        "social-media" = "Social Media"
        "calendar" = "Calendar"
        "chat" = "Chat"
        "dashboard" = "Dashboard"
        "auth" = "Auth"
        "backend" = "Backend"
        "frontend" = "Frontend"
        "ai-llm" = "AI"
        "ai-vision" = "AI Vision"
        "database" = "Database"
        "wordpress" = "WordPress"
        "metadata" = "Metadata"
        "provenance" = "Provenance"
        "search" = "Search"
        "media" = "Media"
        "general" = "General"
    }

    return $componentMap[$Domains[0]]
}

function Detect-Complexity {
    param([string]$Description)

    $descLower = $Description.ToLower()

    # Epic indicators
    if ($descLower -match '\b(comprehensive|complete|full|system|platform|multiple|batch|all)\b') {
        return "complex"
    }

    # Simple indicators
    if ($descLower -match '\b(simple|quick|minor|small|basic|single)\b') {
        return "simple"
    }

    # Count features/items
    $itemCount = ([regex]::Matches($descLower, '\d\)')).Count
    if ($itemCount -gt 6) { return "complex" }
    if ($itemCount -gt 3) { return "moderate" }
    if ($itemCount -gt 0) { return "simple" }

    return "moderate"
}

function Get-MoSCoW-FromDescription {
    param([string]$Description)

    $descLower = $Description.ToLower()

    # Check if description has MoSCoW info
    if ($descLower -match 'must have') { return "M" }
    if ($descLower -match 'critical|essential|required') { return "M" }
    if ($descLower -match 'should have|important') { return "S" }
    if ($descLower -match 'could have|nice.?to.?have') { return "C" }
    if ($descLower -match "won't have|out of scope") { return "W" }

    # Default: treat as SHOULD for now (can be refined later)
    return "S"
}

function Generate-NewTaskName {
    param(
        [string]$CurrentName,
        [string]$Type,
        [string]$MoSCoW,
        [string]$Component
    )

    # Remove existing type prefix
    $cleanName = $CurrentName -replace '^(FEAT|FIX|ENH|REFACTOR|DOC|TEST|INFRA)\s+', ''

    # Remove existing MoSCoW
    $cleanName = $cleanName -replace '\[(M|S|C|W)\]\s*', ''

    # Remove existing component
    $cleanName = $cleanName -replace '\s*\([^)]+\)\s*$', ''

    # Trim and capitalize
    $cleanName = $cleanName.Trim()

    # Build new name
    return "$Type [$MoSCoW] $cleanName ($Component)"
}

function Migrate-Task {
    param($Task, [string]$ProjectName)

    $taskId = $Task.id
    $currentName = $Task.name
    $description = if ($Task.description) { $Task.description } else { "" }

    Write-Host "─────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "Task: $taskId" -ForegroundColor White
    Write-Host "Current: $currentName" -ForegroundColor Gray

    # Analyze task
    $type = Detect-TaskType -Name $currentName -Description $description
    $moscow = Get-MoSCoW-FromDescription -Description $description
    $domains = Detect-Domain -Name $currentName -Description $description -ProjectName $ProjectName
    $component = Detect-Component -Name $currentName -Description $description -Domains $domains
    $complexity = Detect-Complexity -Description $description

    # Generate new name
    $newName = Generate-NewTaskName -CurrentName $currentName -Type $type -MoSCoW $moscow -Component $component

    # Build tags
    $tags = @(
        "moscow:$(switch($moscow) { 'M' {'must-have'} 'S' {'should-have'} 'C' {'could-have'} 'W' {'wont-have'} })",
        "type:$(switch($type) { 'FEAT' {'feature'} 'FIX' {'bug'} 'ENH' {'enhancement'} 'REFACTOR' {'refactor'} 'DOC' {'documentation'} 'TEST' {'test'} 'INFRA' {'infrastructure'} })"
    )

    foreach ($domain in $domains) {
        $tags += "domain:$domain"
    }

    $tags += "complexity:$complexity"

    Write-Host "New:     $newName" -ForegroundColor Cyan
    Write-Host "Tags:    $($tags -join ', ')" -ForegroundColor DarkCyan

    if ($DryRun) {
        Write-Host "[DRY RUN] Would update" -ForegroundColor Yellow
        return
    }

    # Update task name
    $url = "$apiBase/task/$taskId"
    $body = @{ name = $newName } | ConvertTo-Json

    try {
        Invoke-RestMethod -Method PUT -Uri $url -Headers $headers -Body $body | Out-Null
        Write-Host "✓ Renamed" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to rename: $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    # Add tags
    foreach ($tag in $tags) {
        $tagUrl = "$apiBase/task/$taskId/tag/$tag"
        try {
            Invoke-RestMethod -Method POST -Uri $tagUrl -Headers $headers | Out-Null
        } catch {
            # Ignore tag errors (might already exist)
        }
    }

    # Add migration comment
    $commentUrl = "$apiBase/task/$taskId/comment"
    $moscowText = switch($moscow) {
        'M' {'Must Have'}
        'S' {'Should Have'}
        'C' {'Could Have'}
        'W' {"Won't Have"}
    }

    $commentBody = @{ comment_text = "📋 Auto-migrated to naming/tagging system (2026-02-07)

Detected:
- Type: $type
- MoSCoW: $moscowText
- Domains: $($domains -join ', ')
- Complexity: $complexity

If incorrect, please adjust tags in ClickUp or notify agent.

-- Claude Code Agent" } | ConvertTo-Json

    try {
        Invoke-RestMethod -Method POST -Uri $commentUrl -Headers $headers -Body $commentBody | Out-Null
        Write-Host "✓ Comment added" -ForegroundColor Gray
    } catch {
        # Ignore comment errors
    }
}

# Main execution
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " ClickUp Bulk Migration - All Tasks" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN MODE - No changes will be made]" -ForegroundColor Yellow
    Write-Host ""
}

$projects = if ($Project -eq "both") { @("client-manager", "art-revisionist") } else { @($Project) }

$totalMigrated = 0

foreach ($proj in $projects) {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor White
    Write-Host " Project: $proj" -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor White
    Write-Host ""

    # Get list ID
    $listId = $config.projects.$proj.list_id

    # Fetch all tasks
    $url = "$apiBase/list/$listId/task"
    $response = Invoke-RestMethod -Method GET -Uri $url -Headers $headers

    $tasks = $response.tasks | Where-Object {
        $task = $_
        # Filter by status
        $statusMatch = ($StatusFilter -eq "all") -or ($task.status.status -eq $StatusFilter)

        # Skip already migrated
        $notMigrated = $task.id -notin $alreadyMigrated

        # Skip done tasks
        $notDone = $task.status.status -ne "done"

        $statusMatch -and $notMigrated -and $notDone
    }

    if ($MaxTasks -gt 0) {
        $tasks = $tasks | Select-Object -First $MaxTasks
    }

    Write-Host "Found $($tasks.Count) tasks to migrate" -ForegroundColor Cyan
    Write-Host ""

    foreach ($task in $tasks) {
        Migrate-Task -Task $task -ProjectName $proj
        $totalMigrated++
    }

    Write-Host ""
}

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host " Migration Complete! ($totalMigrated tasks updated)" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
