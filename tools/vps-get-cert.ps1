$pass = ConvertTo-SecureString 'SpaceElevator1tam!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('administrator', $pass)
$s = New-PSSession -ComputerName '85.215.217.154' -Credential $cred

Invoke-Command -Session $s -ScriptBlock {
    Import-Module WebAdministration

    Write-Host '=== Get RealEstateAgency site ID ==='
    $site = Get-Website -Name 'RealEstateAgency'
    $siteId = $site.Id
    Write-Host "Site ID: $siteId"

    Write-Host ''
    Write-Host '=== Find win-acme ==='
    $wacs = Get-ChildItem 'C:\' -Recurse -Name 'wacs.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $wacs) {
        $wacs = Get-ChildItem 'C:\Program Files*' -Recurse -Name 'wacs.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    Write-Host "wacs.exe: $wacs"

    # Also check common locations
    $locations = @('C:\wacs', 'C:\win-acme', 'C:\tools\win-acme', 'C:\ProgramData\win-acme')
    foreach ($loc in $locations) {
        if (Test-Path "$loc\wacs.exe") {
            Write-Host "Found at: $loc\wacs.exe"
        }
    }

    # Check PATH
    $wacsInPath = (Get-Command wacs -ErrorAction SilentlyContinue)
    if ($wacsInPath) { Write-Host "In PATH: $($wacsInPath.Source)" }
}

Remove-PSSession $s
