"""Install SSL certificate with explicit win-acme parameters"""
import paramiko
import time

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Installing Let\'s Encrypt Certificate')
print('='*60)

# Step 1: Ensure win-acme is present
print('\n1. Checking win-acme installation...')
stdin, stdout, stderr = c.exec_command('powershell Test-Path C:\\win-acme\\wacs.exe')
exists = stdout.read().decode('utf-8', errors='ignore').strip()

if exists.lower() != 'true':
    print('   Installing win-acme...')
    install_cmd = """
$url = 'https://github.com/win-acme/win-acme/releases/download/v2.2.9.1701/win-acme.v2.2.9.1701.x64.trimmed.zip'
$zip = 'C:\\temp\\wacs.zip'
New-Item -ItemType Directory -Force -Path C:\\temp | Out-Null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
Expand-Archive -Path $zip -DestinationPath C:\\win-acme -Force
Write-Host 'Installed'
"""
    stdin, stdout, stderr = c.exec_command(f'powershell {install_cmd}')
    print(stdout.read().decode('utf-8', errors='ignore'))
    print('   OK Installed')
else:
    print('   OK Already installed')

# Step 2: Get IIS site ID
print('\n2. Getting IIS site ID...')
stdin, stdout, stderr = c.exec_command('powershell Import-Module WebAdministration; (Get-Website -Name "vault.prospergenics.com").ID')
site_id = stdout.read().decode('utf-8', errors='ignore').strip()
print(f'   Site ID: {site_id}')

# Step 3: Request certificate with full parameters
print('\n3. Requesting Let\'s Encrypt certificate...')
print('   (This may take 30-60 seconds)')

# Build the command with all required parameters
cert_cmd = f"""
cd C:\\win-acme
.\\wacs.exe --source manual --host vault.prospergenics.com --validation http-01 --validationmode http-01 --webroot C:\\inetpub\\vault.prospergenics.com --installation iis --installationsiteid {site_id} --accepttos --emailaddress admin@prospergenics.com
"""

stdin, stdout, stderr = c.exec_command(f'powershell {cert_cmd}', timeout=120)

# Read output
time.sleep(5)
output_lines = []
error_lines = []

try:
    while True:
        line = stdout.readline()
        if not line:
            break
        output_lines.append(line.strip())
        print(f'   {line.strip()}')
except:
    pass

# Check stderr
try:
    err = stderr.read().decode('utf-8', errors='ignore')
    if err:
        print(f'   Errors: {err}')
except:
    pass

# Step 4: Wait and verify
print('\n4. Waiting for certificate binding...')
time.sleep(5)

# Step 5: Check certificate
print('\n5. Verifying certificate installation...')
check_cmd = """
Import-Module WebAdministration
$binding = Get-WebBinding -Name 'vault.prospergenics.com' -Protocol 'https'
if ($binding -and $binding.certificateHash) {
    $cert = Get-ChildItem Cert:\\LocalMachine\\My | Where-Object { $_.Thumbprint -eq $binding.certificateHash }
    if ($cert) {
        Write-Host "SUCCESS"
        Write-Host "Subject: $($cert.Subject)"
        Write-Host "Issuer: $($cert.Issuer)"
        Write-Host "Valid From: $($cert.NotBefore)"
        Write-Host "Valid Until: $($cert.NotAfter)"
        Write-Host "Thumbprint: $($cert.Thumbprint)"
    } else {
        Write-Host "CERT_NOT_IN_STORE"
    }
} else {
    Write-Host "NO_BINDING"
}
"""

stdin, stdout, stderr = c.exec_command(f'powershell {check_cmd}')
result = stdout.read().decode('utf-8', errors='ignore')

print(result)

if 'SUCCESS' in result:
    print('\n' + '='*60)
    print('  SSL CERTIFICATE INSTALLED SUCCESSFULLY')
    print('='*60)
    print('\nThe certificate warning should now be gone!')
    print('Test: https://vault.prospergenics.com')
elif 'NO_BINDING' in result or 'CERT_NOT_IN_STORE' in result:
    print('\n' + '='*60)
    print('  Certificate installation incomplete')
    print('='*60)
    print('\nLet me try an alternative method...')
else:
    print('\n' + '='*60)
    print('  Status uncertain - checking logs')
    print('='*60)

c.close()
