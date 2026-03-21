"""Check IIS configuration"""
import paramiko

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Checking IIS configuration...')
print('='*60)

# List all IIS sites
print('\nAll IIS sites:')
stdin, stdout, stderr = client.exec_command('powershell Import-Module WebAdministration; Get-Website | Format-Table Name, ID, State, PhysicalPath -AutoSize')
print(stdout.read().decode('utf-8', errors='ignore'))

# Check specific site
print('\nChecking vault.prospergenics.com site:')
stdin, stdout, stderr = client.exec_command('powershell Import-Module WebAdministration; Get-Website -Name "vault.prospergenics.com"')
output = stdout.read().decode('utf-8', errors='ignore')
error = stderr.read().decode('utf-8', errors='ignore')
if output:
    print(output)
else:
    print(f'Site not found or error: {error}')

# Check all bindings
print('\nAll bindings:')
stdin, stdout, stderr = client.exec_command('powershell Import-Module WebAdministration; Get-WebBinding | Format-Table protocol, bindingInformation, ItemXPath -AutoSize')
print(stdout.read().decode('utf-8', errors='ignore'))

# Try to start the site
print('\nTrying to start the site:')
stdin, stdout, stderr = client.exec_command('powershell Import-Module WebAdministration; Start-Website -Name "vault.prospergenics.com"')
output = stdout.read().decode('utf-8', errors='ignore')
error = stderr.read().decode('utf-8', errors='ignore')
if error:
    print(f'Error: {error}')
else:
    print('OK Started (or already running)')

# Check site state again
print('\nSite state after start attempt:')
stdin, stdout, stderr = client.exec_command('powershell Import-Module WebAdministration; (Get-Website -Name "vault.prospergenics.com").State')
print(stdout.read().decode('utf-8', errors='ignore'))

client.close()
