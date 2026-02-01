#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Zettelkasten management tool with full ClickUp integration

.DESCRIPTION
    Manage your ideas and plans system:
    - Quick capture ideas
    - Create permanent notes
    - Link notes together
    - Auto-create ClickUp tasks for actionable items
    - Search and review notes

.PARAMETER Action
    Action to perform: capture, create, link, search, inbox, review, update-index

.PARAMETER Title
    Note title

.PARAMETER Content
    Note content (optional, will prompt in editor if not provided)

.PARAMETER Tags
    Comma-separated tags

.PARAMETER Actionable
    Create ClickUp task for this note

.PARAMETER Project
    Project name for ClickUp task (client-manager, hazina, automation)

.PARAMETER From
    Source note ID for linking

.PARAMETER To
    Target note ID for linking

.PARAMETER Query
    Search query

.EXAMPLE
    zettelkasten.ps1 -Action capture -Title "Website import optimization" -Tags "technical,client-manager" -Actionable
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('capture', 'create', 'link', 'search', 'inbox', 'review', 'update-index')]
    [string]$Action,

    [string]$Title,
    [string]$Content,
    [string]$Tags,
    [switch]$Actionable,
    [string]$Project = "client-manager",
    [string]$From,
    [string]$To,
    [string]$Query
)

$ZK_ROOT = "C:\projects\zettelkasten"
$INBOX = "$ZK_ROOT\inbox"
$NOTES = "$ZK_ROOT\notes"
$ARCHIVE = "$ZK_ROOT\archive"
$PROJECTS = "$ZK_ROOT\projects"

# Ensure directories exist
@($INBOX, $NOTES, $ARCHIVE, $PROJECTS) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

function Get-NoteID {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmm"
    $slug = $Title -replace '\s+', '-' -replace '[^\w\-]', '' | Select-Object -First 50
    return "$timestamp-$($slug.ToLower())"
}

function New-Note {
    param([string]$Location, [string]$Status = "inbox")

    $noteID = Get-NoteID
    $filename = "$noteID.md"
    $filepath = Join-Path $Location $filename

    $created = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $tagList = if ($Tags) { $Tags.Split(',') | ForEach-Object { $_.Trim() } } else { @() }
    $tagYaml = if ($tagList) { "[$($tagList -join ', ')]" } else { "[]" }

    $template = @"
---
id: $noteID
created: $created
tags: $tagYaml
status: $Status
clickup: null
---

# $Title

## Context


## Core Idea
$($Content ?? "")


## Implementation Notes


## Related Notes


## ClickUp Task
(Will be filled automatically if task is created)

"@

    Set-Content -Path $filepath -Value $template -Encoding UTF8
    Write-Host "✅ Created note: $filepath" -ForegroundColor Green

    # Open in editor if content not provided
    if (-not $Content) {
        Write-Host "📝 Opening in VS Code for editing..." -ForegroundColor Cyan
        & code $filepath
    }

    # Create ClickUp task if actionable
    if ($Actionable) {
        Create-ClickUpTask -NoteID $noteID -NotePath $filepath
    }

    return $filepath
}

function Create-ClickUpTask {
    param([string]$NoteID, [string]$NotePath)

    Write-Host "🔄 Creating ClickUp task..." -ForegroundColor Cyan

    # Read note content
    $noteContent = Get-Content $NotePath -Raw

    # Determine project/list ID
    $projectMap = @{
        "client-manager" = "your-client-manager-list-id"  # TODO: Replace with actual IDs
        "hazina" = "your-hazina-list-id"
        "automation" = "your-automation-list-id"
    }

    $listID = $projectMap[$Project]

    if (-not $listID) {
        Write-Host "⚠️  Unknown project: $Project. Skipping ClickUp task creation." -ForegroundColor Yellow
        return
    }

    # Extract tags from note
    $noteContent -match 'tags:\s*\[(.*?)\]'
    $noteTags = if ($matches[1]) { $matches[1].Split(',') | ForEach-Object { $_.Trim() } } else { @() }

    # Create task description with backlink
    $taskDescription = @"
**Note:** $Title
**File:** ``$NotePath``

$($noteContent -replace '---[\s\S]*?---', '')

---
*Auto-created from Zettelkasten note [$NoteID]*
"@

    # Use clickup-sync.ps1 tool
    $clickupScript = "C:\scripts\tools\clickup-sync.ps1"

    try {
        $result = & $clickupScript -Action create `
            -ProjectId $Project `
            -TaskName $Title `
            -Description $taskDescription `
            -Tags ($noteTags -join ',')

        if ($result) {
            # Extract task ID from result (assuming clickup-sync returns task ID)
            # Update note with task ID
            $noteContent = $noteContent -replace 'clickup: null', "clickup: TASK-ID-HERE"  # TODO: Parse actual task ID
            Set-Content -Path $NotePath -Value $noteContent -Encoding UTF8

            Write-Host "✅ ClickUp task created and linked!" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Failed to create ClickUp task: $_" -ForegroundColor Red
    }
}

function Search-Notes {
    param([string]$Query)

    Write-Host "🔍 Searching for: $Query" -ForegroundColor Cyan

    $allNotes = Get-ChildItem -Path $NOTES, $INBOX -Filter "*.md" -Recurse
    $matches = @()

    foreach ($note in $allNotes) {
        $content = Get-Content $note.FullName -Raw
        if ($content -match $Query) {
            $matches += [PSCustomObject]@{
                File = $note.Name
                Path = $note.FullName
                Preview = ($content -split "`n" | Select-Object -First 10) -join "`n"
            }
        }
    }

    if ($matches.Count -eq 0) {
        Write-Host "❌ No matches found." -ForegroundColor Red
    } else {
        Write-Host "✅ Found $($matches.Count) matches:" -ForegroundColor Green
        $matches | Format-Table File, Path -AutoSize
    }

    return $matches
}

function Show-Inbox {
    $inboxNotes = Get-ChildItem -Path $INBOX -Filter "*.md"

    if ($inboxNotes.Count -eq 0) {
        Write-Host "✅ Inbox is empty! (Inbox zero)" -ForegroundColor Green
    } else {
        Write-Host "📥 Inbox ($($inboxNotes.Count) unprocessed notes):" -ForegroundColor Cyan
        $inboxNotes | ForEach-Object {
            $content = Get-Content $_.FullName -Raw
            $content -match '# (.+)'
            $title = $matches[1]
            Write-Host "  - $($_.Name): $title" -ForegroundColor Yellow
        }

        Write-Host "`n💡 Process inbox with: zettelkasten.ps1 -Action review" -ForegroundColor Cyan
    }
}

function Update-Index {
    Write-Host "🔄 Updating INDEX.md..." -ForegroundColor Cyan

    $allNotes = Get-ChildItem -Path $NOTES -Filter "*.md"
    $inboxNotes = Get-ChildItem -Path $INBOX -Filter "*.md"
    $archiveNotes = Get-ChildItem -Path $ARCHIVE -Filter "*.md"

    $tagCounts = @{}
    $clickupCount = 0

    foreach ($note in $allNotes) {
        $content = Get-Content $note.FullName -Raw

        # Count tags
        if ($content -match 'tags:\s*\[(.*?)\]') {
            $noteTags = $matches[1].Split(',') | ForEach-Object { $_.Trim() }
            foreach ($tag in $noteTags) {
                $tagCounts[$tag] = ($tagCounts[$tag] ?? 0) + 1
            }
        }

        # Count ClickUp tasks
        if ($content -match 'clickup:\s*\w+') {
            $clickupCount++
        }
    }

    # Generate index content
    $indexContent = @"
# Zettelkasten Index

**Last Updated:** $(Get-Date -Format "yyyy-MM-dd HH:mm")
**Total Notes:** $($allNotes.Count)

## 📊 Statistics

- **Inbox:** $($inboxNotes.Count) notes (unprocessed)
- **Active:** $($allNotes.Count) notes
- **Archived:** $($archiveNotes.Count) notes
- **ClickUp Tasks Created:** $clickupCount

## 📝 Recent Notes (Last 10)

$($allNotes | Sort-Object LastWriteTime -Descending | Select-Object -First 10 | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $content -match '# (.+)'
    $title = $matches[1]
    "- [$($_.BaseName)]($($_.FullName)): $title"
} | Out-String)

## 🏷️ Tags

$(($tagCounts.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
    "- **$($_.Key)**: $($_.Value) notes"
}) -join "`n")

## 📁 Projects

### client-manager / Brand2Boost
- Notes: $(($allNotes | Where-Object { (Get-Content $_.FullName -Raw) -match 'client-manager' }).Count)

### Hazina Framework
- Notes: $(($allNotes | Where-Object { (Get-Content $_.FullName -Raw) -match 'hazina' }).Count)

### Automation & Tools
- Notes: $(($allNotes | Where-Object { (Get-Content $_.FullName -Raw) -match 'automation' }).Count)

---

**Note:** This index auto-updates when you use ``zettelkasten.ps1 -Action update-index``
"@

    Set-Content -Path "$ZK_ROOT\INDEX.md" -Value $indexContent -Encoding UTF8
    Write-Host "✅ INDEX.md updated!" -ForegroundColor Green
}

# Main action dispatcher
switch ($Action) {
    "capture" {
        if (-not $Title) {
            Write-Host "❌ -Title required for capture" -ForegroundColor Red
            exit 1
        }
        New-Note -Location $INBOX -Status "inbox"
    }

    "create" {
        if (-not $Title) {
            Write-Host "❌ -Title required for create" -ForegroundColor Red
            exit 1
        }
        New-Note -Location $NOTES -Status "active"
    }

    "search" {
        if (-not $Query) {
            Write-Host "❌ -Query required for search" -ForegroundColor Red
            exit 1
        }
        Search-Notes -Query $Query
    }

    "inbox" {
        Show-Inbox
    }

    "update-index" {
        Update-Index
    }

    "review" {
        Write-Host "📋 Daily Review" -ForegroundColor Cyan
        Show-Inbox
        Write-Host "`n💡 Process each inbox item manually, or use bulk commands." -ForegroundColor Yellow
    }

    "link" {
        Write-Host "🔗 Linking functionality coming soon..." -ForegroundColor Yellow
    }
}
