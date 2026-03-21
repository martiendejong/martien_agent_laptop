Get-Process | Where-Object { $_.ProcessName -match 'chrome|firefox|msedge|brave' } |
    Select-Object ProcessName, Id, @{Name='Title';Expression={$_.MainWindowTitle}} |
    Where-Object { $_.Title -ne '' } |
    Format-Table -AutoSize
