$ports = @(9222, 9223, 9224)
$names = @('Chrome', 'Brave', 'Edge')

for ($i = 0; $i -lt $ports.Count; $i++) {
    $port = $ports[$i]
    $name = $names[$i]
    $result = Test-NetConnection -ComputerName localhost -Port $port -InformationLevel Quiet

    if ($result) {
        Write-Host "$name (port $port): OPEN" -ForegroundColor Green
    } else {
        Write-Host "$name (port $port): CLOSED" -ForegroundColor Red
    }
}
