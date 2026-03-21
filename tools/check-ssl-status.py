"""Check current SSL certificate status"""
import paramiko

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Checking SSL Certificate Status')
print('='*60)

# Check current certificate
print('\n1. Current HTTPS binding:')
stdin, stdout, stderr = c.exec_command('''powershell Import-Module WebAdministration; $binding = Get-WebBinding -Name "vault.prospergenics.com" -Protocol "https"; if ($binding) { if ($binding.certificateHash) { Write-Host "Hash: $($binding.certificateHash)"; $cert = Get-ChildItem Cert:\\LocalMachine\\My | Where-Object { $_.Thumbprint -eq $binding.certificateHash }; if ($cert) { Write-Host "Subject: $($cert.Subject)"; Write-Host "Issuer: $($cert.Issuer)"; Write-Host "Valid: $($cert.NotBefore) to $($cert.NotAfter)" } else { Write-Host "Certificate not found in store" } } else { Write-Host "No certificate bound" } } else { Write-Host "No HTTPS binding" }''')
print(stdout.read().decode('utf-8', errors='ignore'))

# Check if port 80 is accessible
print('\n2. Testing port 80 accessibility (required for Let\'s Encrypt):')
stdin, stdout, stderr = c.exec_command('powershell Test-NetConnection -ComputerName vault.prospergenics.com -Port 80 | Select-Object TcpTestSucceeded')
print(stdout.read().decode('utf-8', errors='ignore'))

# Check win-acme logs
print('\n3. Checking win-acme logs:')
stdin, stdout, stderr = c.exec_command('powershell Get-ChildItem C:\\win-acme -Recurse -Include *.log | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content -Tail 30')
logs = stdout.read().decode('utf-8', errors='ignore')
if logs:
    print(logs)
else:
    print('   No logs found')

# Try simple certbot alternative - use Posh-ACME
print('\n4. Trying alternative: Posh-ACME PowerShell module...')
posh_acme_install = '''
if (-not (Get-Module -ListAvailable -Name Posh-ACME)) {
    Write-Host "Installing Posh-ACME..."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction SilentlyContinue
    Install-Module -Name Posh-ACME -Force -AllowClobber -ErrorAction SilentlyContinue
    Write-Host "Installed"
} else {
    Write-Host "Already installed"
}
'''
stdin, stdout, stderr = c.exec_command(f'powershell {posh_acme_install}')
print(stdout.read().decode('utf-8', errors='ignore'))

c.close()
