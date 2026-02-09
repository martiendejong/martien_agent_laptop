param([string]$SearchPattern, [string]$DateFilter)

$projectDirs = Get-ChildItem "C:\Users\HP\.claude\projects\" -Directory
foreach ($dir in $projectDirs) {
    $files = Get-ChildItem "$($dir.FullName)\*.jsonl" -ErrorAction SilentlyContinue
    if ($DateFilter) {
        $files = $files | Where-Object { $_.LastWriteTime.Date -eq [datetime]$DateFilter }
    }
    foreach ($f in $files) {
        $found = Select-String -Path $f.FullName -Pattern $SearchPattern -SimpleMatch -ErrorAction SilentlyContinue
        if ($found) {
            $time = $f.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
            $size = [Math]::Round($f.Length / 1024)
            Write-Output "$time | ${size}KB | $($dir.Name) | $($f.BaseName) | matches: $($found.Count)"
        }
    }
}
