"""Install Let's Encrypt SSL certificate for vault.prospergenics.com"""
import paramiko
import sys
import time

def execute_command(client, command, description=''):
    if description:
        print(f'  -> {description}')
    stdin, stdout, stderr = client.exec_command(f'powershell -Command "{command}"')
    output = stdout.read().decode('utf-8', errors='ignore').strip()
    error = stderr.read().decode('utf-8', errors='ignore').strip()
    return output, error

host = '85.215.217.154'
username = 'administrator'
password = 'SpaceElevator1tam!'

print('='*70)
print('  SSL Certificate Installation for vault.prospergenics.com')
print('  Using win-acme (Let\'s Encrypt)')
print('='*70)
print()

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

try:
    print(f'Connecting to {host}...')
    client.connect(host, username=username, password=password, timeout=30)
    print('OK Connected\n')
except Exception as e:
    print(f'ERROR: {e}')
    sys.exit(1)

try:
    # Check if win-acme is already installed
    print('STEP 1: Checking for win-acme...')
    output, error = execute_command(client, "Test-Path 'C:\\win-acme\\wacs.exe'", 'Check if win-acme exists')

    if output.lower() == 'true':
        print('OK win-acme already installed\n')
        wacs_path = 'C:\\win-acme'
    else:
        print('NOT FOUND - Installing win-acme...')

        # Download and install win-acme
        install_script = """
$ErrorActionPreference = 'Stop'
$downloadUrl = 'https://github.com/win-acme/win-acme/releases/download/v2.2.9.1701/win-acme.v2.2.9.1701.x64.trimmed.zip'
$tempFile = 'C:\\temp\\win-acme.zip'
$installPath = 'C:\\win-acme'

New-Item -ItemType Directory -Force -Path 'C:\\temp' | Out-Null
New-Item -ItemType Directory -Force -Path $installPath | Out-Null

Write-Host 'Downloading win-acme...'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile -UseBasicParsing

Write-Host 'Extracting...'
Expand-Archive -Path $tempFile -DestinationPath $installPath -Force

Write-Host 'Installed'
"""
        output, error = execute_command(client, install_script.replace('\n', '; '), 'Download and extract win-acme')
        if 'Installed' in output:
            print('OK win-acme installed\n')
            wacs_path = 'C:\\win-acme'
        else:
            print(f'ERROR: Installation failed: {output} {error}')
            sys.exit(1)

    # Step 2: Request certificate
    print('STEP 2: Requesting Let\'s Encrypt certificate...')
    print('  This will use HTTP-01 validation (port 80 must be open)\n')

    # Create automated certificate request
    cert_script = f"""
$ErrorActionPreference = 'Stop'
cd '{wacs_path}'

# Run wacs in unattended mode
.\\wacs.exe --source manual --host vault.prospergenics.com --validation http-01 --webroot C:\\inetpub\\vault.prospergenics.com --installation iis --installationsiteid (Get-Website -Name 'vault.prospergenics.com').ID --accepttos --emailaddress admin@prospergenics.com --baseuri https://acme-v02.api.letsencrypt.org/directory

Write-Host 'Certificate requested'
"""

    output, error = execute_command(client, cert_script.replace('\n', '; '), 'Request and install certificate')

    print(f'Output: {output}')
    if error:
        print(f'Errors/Warnings: {error}')

    # Step 3: Verify certificate installation
    print('\nSTEP 3: Verifying certificate installation...')
    time.sleep(3)

    verify_script = """
Import-Module WebAdministration
$binding = Get-WebBinding -Name 'vault.prospergenics.com' -Protocol 'https'
if ($binding -and $binding.certificateHash) {
    $cert = Get-ChildItem Cert:\\LocalMachine\\My | Where-Object { $_.Thumbprint -eq $binding.certificateHash }
    if ($cert) {
        Write-Host "SUCCESS"
        Write-Host "Subject: $($cert.Subject)"
        Write-Host "Issuer: $($cert.Issuer)"
        Write-Host "Valid Until: $($cert.NotAfter)"
        Write-Host "Thumbprint: $($cert.Thumbprint)"
    } else {
        Write-Host "NOTFOUND"
    }
} else {
    Write-Host "NOBINDING"
}
"""
    output, error = execute_command(client, verify_script.replace('\n', '; '), 'Check certificate')

    if 'SUCCESS' in output:
        print('OK Certificate installed successfully!')
        print(f'  {output}\n')
        print('='*70)
        print('  SSL CERTIFICATE INSTALLED')
        print('='*70)
        print('\nThe certificate warning should now be resolved.')
        print('Test: https://vault.prospergenics.com')
        print('\nwin-acme will automatically renew the certificate before expiration.')
    else:
        print(f'WARNING: Certificate may not be installed correctly')
        print(f'  Output: {output}')
        print(f'\nManual steps needed:')
        print(f'  1. RDP to server: {host}')
        print(f'  2. Open PowerShell as Administrator')
        print(f'  3. cd C:\\win-acme')
        print(f'  4. Run: .\\wacs.exe')
        print(f'  5. Follow the interactive prompts')

except Exception as e:
    print(f'\nERROR: {e}')
    import traceback
    traceback.print_exc()
    sys.exit(1)
finally:
    client.close()
