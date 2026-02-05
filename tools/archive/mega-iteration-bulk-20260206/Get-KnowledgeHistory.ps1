# Knowledge Version Control - Round 8
# Git-based versioning for context files

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,

    [Parameter(Mandatory=$false)]
    [string]$Action = "history",

    [Parameter(Mandatory=$false)]
    [string]$Date = ""
)

$repoRoot = "C:\scripts"
$relativePath = $FilePath.Replace($repoRoot, "").TrimStart('\')

function Get-FileHistory {
    Write-Host "`n=== File History: $relativePath ===" -ForegroundColor Cyan

    $history = git -C $repoRoot log --follow --pretty=format:"%h|%ai|%an|%s" -- $relativePath

    if ($history) {
        $history | ForEach-Object {
            $parts = $_ -split '\|'
            [PSCustomObject]@{
                Commit = $parts[0]
                Date = $parts[1]
                Author = $parts[2]
                Message = $parts[3]
            }
        } | Format-Table -AutoSize
    } else {
        Write-Host "No history found" -ForegroundColor Yellow
    }
}

function Get-FileBlame {
    Write-Host "`n=== File Blame: $relativePath ===" -ForegroundColor Cyan
    git -C $repoRoot blame -w --date=short $relativePath
}

function Get-FileAtDate {
    param($TargetDate)

    Write-Host "`n=== File Content at $TargetDate ===" -ForegroundColor Cyan

    $commit = git -C $repoRoot rev-list -1 --before="$TargetDate" --all

    if ($commit) {
        git -C $repoRoot show "${commit}:$relativePath"
    } else {
        Write-Host "No version found before $TargetDate" -ForegroundColor Yellow
    }
}

function Get-FileDiff {
    param($FromCommit = "HEAD~1", $ToCommit = "HEAD")

    Write-Host "`n=== Changes: $FromCommit..$ToCommit ===" -ForegroundColor Cyan
    git -C $repoRoot diff $FromCommit $ToCommit -- $relativePath
}

# Execute action
switch ($Action) {
    "history" { Get-FileHistory }
    "blame" { Get-FileBlame }
    "at-date" { Get-FileAtDate -TargetDate $Date }
    "diff" { Get-FileDiff }
    "timeline" {
        Write-Host "`n=== Knowledge Evolution Timeline ===" -ForegroundColor Cyan
        git -C $repoRoot log --graph --oneline --follow -- $relativePath
    }
}
