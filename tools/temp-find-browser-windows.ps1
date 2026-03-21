$windows = Invoke-RestMethod -Uri 'http://localhost:27184/windows'

# Find by title patterns
$browserWindows = $windows | Where-Object {
    $_.title -like '*YouTube*' -or
    $_.title -like '*Chrome*' -or
    $_.title -like '*Brave*' -or
    $_.title -like '*Edge*' -or
    $_.title -like '*Firefox*'
}

if ($browserWindows) {
    Write-Host "Found browser windows:" -ForegroundColor Green
    $browserWindows | Format-List id, title, processName
} else {
    Write-Host "No browser windows found by title. Checking all windows..." -ForegroundColor Yellow
    $windows | Format-Table id, title, processName -AutoSize
}
