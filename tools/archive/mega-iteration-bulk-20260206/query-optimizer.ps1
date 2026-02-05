# query-optimizer.ps1
# Optimizes file/data queries with indexing
param([string]$Action, [string]$Path, [string]$Query)

$indexFile = "/c/scripts/_machine/query-index.json"

function Build-Index {
    param([string]$Path)
    $index = @{}
    Get-ChildItem $Path -Recurse -File | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $words = $content -split '\W+' | Where-Object {$_.Length -gt 3}
        foreach($word in $words) {
            if(-not $index.ContainsKey($word)){$index[$word]=@()}
            $index[$word] += $_.FullName
        }
    }
    $index | ConvertTo-Json | Set-Content $indexFile
    Write-Host "✅ Index built: $($index.Count) terms" -ForegroundColor Green
}

function Search-Indexed {
    param([string]$Query)
    if(Test-Path $indexFile) {
        $index = Get-Content $indexFile | ConvertFrom-Json
        $terms = $Query -split '\s+'
        $results = @{}
        foreach($term in $terms) {
            if($index.$term) {
                foreach($file in $index.$term) {
                    if(-not $results.ContainsKey($file)){$results[$file]=0}
                    $results[$file]++
                }
            }
        }
        $results.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
            Write-Host "$($_.Value) matches: $($_.Key)" -ForegroundColor White
        }
    }
}

switch($Action) {
    "Index" { Build-Index -Path $Path }
    "Search" { Search-Indexed -Query $Query }
}
