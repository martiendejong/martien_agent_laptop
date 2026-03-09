$password = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ('administrator', $password)
Invoke-Command -ComputerName 85.215.217.154 -Credential $cred -ScriptBlock {
    Import-Module WebAdministration

    # Voeg HTTP :80 binding toe voor hostname (nodig voor Let's Encrypt HTTP-01 challenge)
    $existing80 = Get-WebBinding -Name 'AgentBridge' -Protocol http -Port 80 -HostHeader 'agentbridge.wreckingball.ai' -ErrorAction SilentlyContinue
    if (-not $existing80) {
        New-WebBinding -Name 'AgentBridge' -Protocol http -Port 80 -IPAddress '*' -HostHeader 'agentbridge.wreckingball.ai'
        Write-Host "HTTP :80 binding toegevoegd voor agentbridge.wreckingball.ai" -ForegroundColor Green
    } else {
        Write-Host "HTTP :80 binding bestaat al" -ForegroundColor DarkGray
    }

    # Toon alle bindings van AgentBridge nu
    Write-Host ""
    Write-Host "Huidige bindings AgentBridge:"
    Get-WebBinding -Name 'AgentBridge' | Select-Object protocol, bindingInformation

    # Check win-acme locatie
    Write-Host ""
    Write-Host "win-acme:"
    Get-ChildItem 'C:\win-acme' -Filter "*.exe" | Select-Object Name
}
