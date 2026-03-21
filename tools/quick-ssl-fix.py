"""Quick SSL fix - create and bind self-signed certificate"""
import paramiko
import time

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Creating Self-Signed Certificate')
print('='*60)
print('\nThis will create a self-signed cert for vault.prospergenics.com')
print('Better than no cert or wrong domain cert!')
print()

# Create self-signed certificate
print('1. Creating certificate...')
create_cert = """
$cert = New-SelfSignedCertificate -DnsName "vault.prospergenics.com" -CertStoreLocation "Cert:\\LocalMachine\\My" -NotAfter (Get-Date).AddYears(1) -FriendlyName "vault.prospergenics.com" -KeyDescription "vault.prospergenics.com SSL" -KeyFriendlyName "vault.prospergenics.com" -KeyUsage DigitalSignature,KeyEncipherment
Write-Host "Thumbprint: $($cert.Thumbprint)"
$cert.Thumbprint
"""

stdin, stdout, stderr = c.exec_command(f'powershell {create_cert}')
thumbprint = stdout.read().decode('utf-8', errors='ignore').strip().split()[-1]
print(f'   Created with thumbprint: {thumbprint}')

# Bind to IIS
print('\n2. Binding to IIS HTTPS port 443...')
bind_cert = f"""
Import-Module WebAdministration
$binding = Get-WebBinding -Name "vault.prospergenics.com" -Protocol "https"
if ($binding) {{
    Remove-WebBinding -Name "vault.prospergenics.com" -Protocol "https" -Port 443
}}
New-WebBinding -Name "vault.prospergenics.com" -Protocol "https" -Port 443 -IPAddress "*" -HostHeader "vault.prospergenics.com" -SslFlags 1
$binding = Get-WebBinding -Name "vault.prospergenics.com" -Protocol "https" -Port 443
$binding.AddSslCertificate("{thumbprint}", "My")
Write-Host "Certificate bound"
"""

stdin, stdout, stderr = c.exec_command(f'powershell {bind_cert}')
output = stdout.read().decode('utf-8', errors='ignore')
error = stderr.read().decode('utf-8', errors='ignore')

if 'bound' in output.lower() or not error:
    print('   OK Certificate bound')
else:
    print(f'   Output: {output}')
    if error:
        print(f'   Error: {error}')

# Verify
print('\n3. Verifying...')
time.sleep(2)

verify = """
Import-Module WebAdministration
$binding = Get-WebBinding -Name "vault.prospergenics.com" -Protocol "https"
if ($binding -and $binding.certificateHash) {
    $cert = Get-ChildItem Cert:\\LocalMachine\\My | Where-Object { $_.Thumbprint -eq $binding.certificateHash }
    if ($cert) {
        Write-Host "SUCCESS"
        Write-Host "Subject: $($cert.Subject)"
        Write-Host "Valid Until: $($cert.NotAfter)"
    }
}
"""

stdin, stdout, stderr = c.exec_command(f'powershell {verify}')
result = stdout.read().decode('utf-8', errors='ignore')

if 'SUCCESS' in result:
    print(result)
    print('\n' + '='*60)
    print('  CERTIFICATE INSTALLED')
    print('='*60)
    print('\nSelf-signed certificate created and bound!')
    print('\nBrowsers will still show a warning (self-signed)')
    print('but it\'s now for the correct domain.')
    print('\nFor production: Install Let\'s Encrypt via RDP later.')
    print('\nTest now: https://vault.prospergenics.com/api/auth/register')
else:
    print('Verification failed - manual check needed')

c.close()
