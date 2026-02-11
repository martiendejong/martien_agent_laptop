Get-PSDrive C,E -ErrorAction SilentlyContinue | ForEach-Object {
    $used = [math]::Round($_.Used/1GB,1)
    $free = [math]::Round($_.Free/1GB,1)
    $total = [math]::Round(($_.Used+$_.Free)/1GB,1)
    Write-Host "$($_.Name): Used=$used GB, Free=$free GB, Total=$total GB"
}
