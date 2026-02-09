$tasks = @('869byxa55','869byxa45','869byxa2k','869byxa0y','869byx9mw','869byx9kk','869byx9j2','869byx98e','869byx95z','869byx94b','869byx8qe','869byx8n9','869byx85n','869byx83r','869byx81e')

foreach($t in $tasks) {
    Write-Host "=== TASK: $t ==="
    & 'C:\scripts\tools\clickup-sync.ps1' -Action show -TaskId $t -Project art-revisionist
    Write-Host "---END---"
    Write-Host ""
}
