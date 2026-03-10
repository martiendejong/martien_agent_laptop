$h = @{ Authorization = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI' }
$r = Invoke-RestMethod "https://api.clickup.com/api/v2/list/901215927087/task?statuses[]=todo&include_closed=false" -Headers $h
foreach ($t in $r.tasks) {
    Write-Host "TASK $($t.id): $($t.name) [$($t.status.status)]"
}
