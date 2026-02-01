#Requires -Version 5.1
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('capture', 'create', 'link', 'search', 'inbox', 'review', 'update-index')]
    [string]$Action,
    [string]$Title,
    [string]$Content,
    [string]$Tags,
    [switch]$Actionable,
    [string]$Project = "client-manager",
    [string]$Query
)

$ZK_ROOT = "C:\projects\zettelkasten"
$INBOX = "$ZK_ROOT\inbox"
$NOTES = "$ZK_ROOT\notes"
$ARCHIVE = "$ZK_ROOT\archive"

# Ensure directories exist
@($INBOX, $NOTES, $ARCHIVE) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

function Get-NoteID {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmm"
    $slug = $Title -replace '\s+', '-' -replace '[^\w\-]', ''
    if ($slug.Length > 50) { $slug = $slug.Substring(0, 50) }
    return "$timestamp-$($slug.ToLower())"
}

function New-Note {
    param([string]$Location, [string]$Status = "inbox")

    $noteID = Get-NoteID
    $filename = "$noteID.md"
    $filepath = Join-Path $Location $filename
    $created = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $tagList = if ($Tags) { $Tags.Split(',') | ForEach-Object { $_.Trim() } } else { @() }
    $tagYaml = if ($tagList.Count -gt 0) { "[$($tagList -join ', ')]" } else { "[]" }
    $contentText = if ($Content) { $Content } else { "" }

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
$contentText


## Implementation Notes


## Related Notes


## ClickUp Task


"@

    Set-Content -Path $filepath -Value $template -Encoding UTF8
    Write-Host "[OK] Created note: $filepath" -ForegroundColor Green

    if (-not $Content) {
        Write-Host "[EDIT] Opening in VS Code..." -ForegroundColor Cyan
        code $filepath
    }

    return $filepath
}

function Update-Index {
    Write-Host "[SYNC] Updating INDEX.md..." -ForegroundColor Cyan

    $allNotes = @(Get-ChildItem -Path $NOTES -Filter "*.md" -ErrorAction SilentlyContinue)
    $inboxNotes = @(Get-ChildItem -Path $INBOX -Filter "*.md" -ErrorAction SilentlyContinue)
    $archiveNotes = @(Get-ChildItem -Path $ARCHIVE -Filter "*.md" -ErrorAction SilentlyContinue)

    $tagCounts = @{}
    $clickupCount = 0

    foreach ($note in $allNotes) {
        $content = Get-Content $note.FullName -Raw

        if ($content -match 'tags:\s*\[(.*?)\]') {
            $noteTags = $matches[1].Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
            foreach ($tag in $noteTags) {
                if (-not $tagCounts.ContainsKey($tag)) {
                    $tagCounts[$tag] = 0
                }
                $tagCounts[$tag] = $tagCounts[$tag] + 1
            }
        }

        if ($content -match 'clickup:\s*\w+') {
            $clickupCount++
        }
    }

    $recentNotesText = if ($allNotes.Count -gt 0) {
        ($allNotes | Sort-Object LastWriteTime -Descending | Select-Object -First 10 | ForEach-Object {
            $content = Get-Content $_.FullName -Raw
            if ($content -match '# (.+)') {
                $title = $matches[1]
                "- [$($_.BaseName)]: $title"
            }
        }) -join "`n"
    } else {
        "(No notes yet)"
    }

    $tagsText = if ($tagCounts.Count -gt 0) {
        ($tagCounts.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
            "- **$($_.Key)**: $($_.Value) notes"
        }) -join "`n"
    } else {
        "(No tags yet)"
    }

    $indexContent = @"
# Zettelkasten Index

**Last Updated:** $(Get-Date -Format "yyyy-MM-dd HH:mm")
**Total Notes:** $($allNotes.Count)

## Statistics

- **Inbox:** $($inboxNotes.Count) notes (unprocessed)
- **Active:** $($allNotes.Count) notes
- **Archived:** $($archiveNotes.Count) notes
- **ClickUp Tasks Created:** $clickupCount

## Recent Notes (Last 10)

$recentNotesText

## Tags

$tagsText

## Projects

### client-manager / Brand2Boost
- Notes: $(($allNotes | Where-Object { (Get-Content $_.FullName -Raw) -match 'client-manager' }).Count)

### Hazina Framework
- Notes: $(($allNotes | Where-Object { (Get-Content $_.FullName -Raw) -match 'hazina' }).Count)

"@

    Set-Content -Path "$ZK_ROOT\INDEX.md" -Value $indexContent -Encoding UTF8
    Write-Host "[OK] INDEX.md updated!" -ForegroundColor Green
}

function Show-Inbox {
    $inboxNotes = @(Get-ChildItem -Path $INBOX -Filter "*.md" -ErrorAction SilentlyContinue)

    if ($inboxNotes.Count -eq 0) {
        Write-Host "[OK] Inbox is empty!" -ForegroundColor Green
    } else {
        Write-Host "[INBOX] $($inboxNotes.Count) unprocessed notes:" -ForegroundColor Cyan
        $inboxNotes | ForEach-Object {
            $content = Get-Content $_.FullName -Raw
            if ($content -match '# (.+)') {
                $title = $matches[1]
                Write-Host "  - $($_.Name): $title" -ForegroundColor Yellow
            }
        }
    }
}

function Search-Notes {
    param([string]$Query)

    Write-Host "[SEARCH] Searching for: $Query" -ForegroundColor Cyan
    $allNotes = Get-ChildItem -Path $NOTES, $INBOX -Filter "*.md" -Recurse -ErrorAction SilentlyContinue
    $matches = @()

    foreach ($note in $allNotes) {
        $content = Get-Content $note.FullName -Raw
        if ($content -match $Query) {
            $matches += [PSCustomObject]@{
                File = $note.Name
                Path = $note.FullName
            }
        }
    }

    if ($matches.Count -eq 0) {
        Write-Host "[SEARCH] No matches found." -ForegroundColor Yellow
    } else {
        Write-Host "[OK] Found $($matches.Count) matches:" -ForegroundColor Green
        $matches | Format-Table File, Path -AutoSize
    }
}

# Main action dispatcher
switch ($Action) {
    "capture" {
        if (-not $Title) {
            Write-Host "[ERROR] -Title required for capture" -ForegroundColor Red
            exit 1
        }
        New-Note -Location $INBOX -Status "inbox"
        Update-Index
    }

    "create" {
        if (-not $Title) {
            Write-Host "[ERROR] -Title required for create" -ForegroundColor Red
            exit 1
        }
        New-Note -Location $NOTES -Status "active"
        Update-Index
    }

    "search" {
        if (-not $Query) {
            Write-Host "[ERROR] -Query required for search" -ForegroundColor Red
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
        Write-Host "[REVIEW] Daily Review" -ForegroundColor Cyan
        Show-Inbox
    }

    "link" {
        Write-Host "[LINK] Linking functionality coming soon..." -ForegroundColor Yellow
    }
}
