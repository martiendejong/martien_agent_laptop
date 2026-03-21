"""Fix web.config to set ASPNETCORE_ENVIRONMENT=Production"""
import paramiko

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Fixing web.config to use Production environment...\n')

# Update web.config to add ASPNETCORE_ENVIRONMENT
update_script = """
$webConfigPath = 'C:\\inetpub\\vault.prospergenics.com\\web.config'
[xml]$webConfig = Get-Content $webConfigPath

# Find the aspNetCore element
$aspNetCore = $webConfig.configuration.location.'system.webServer'.aspNetCore

# Add environmentVariables section if it doesn't exist
if (-not $aspNetCore.environmentVariables) {
    $envVars = $webConfig.CreateElement('environmentVariables')
    $aspNetCore.AppendChild($envVars) | Out-Null
}

# Add ASPNETCORE_ENVIRONMENT variable
$envVar = $webConfig.CreateElement('environmentVariable')
$envVar.SetAttribute('name', 'ASPNETCORE_ENVIRONMENT')
$envVar.SetAttribute('value', 'Production')
$aspNetCore.environmentVariables.AppendChild($envVar) | Out-Null

# Save the updated web.config
$webConfig.Save($webConfigPath)
Write-Host 'web.config updated successfully'
"""

stdin, stdout, stderr = client.exec_command(f'powershell -Command "{update_script}"')
output = stdout.read().decode('utf-8', errors='ignore')
error = stderr.read().decode('utf-8', errors='ignore')

print(output)
if error:
    print(f'Warnings: {error}')

# Verify the change
print('\nVerifying web.config update:')
stdin, stdout, stderr = client.exec_command('powershell -Command "Get-Content C:\\inetpub\\vault.prospergenics.com\\web.config"')
print(stdout.read().decode('utf-8', errors='ignore'))

# Restart app pool
print('\nRestarting application pool...')
stdin, stdout, stderr = client.exec_command('powershell -Command "Import-Module WebAdministration; Restart-WebAppPool -Name \'vault.prospergenics.com\'"')
print('OK Application pool restarted')

print('\nWaiting 5 seconds for application to start...')
import time
time.sleep(5)

print('\n' + '='*60)
print('  FIX COMPLETE')
print('='*60)
print('\nThe application should now use Production configuration.')
print('Test now: https://vault.prospergenics.com')
print('(Ignore certificate warning for now)')

client.close()
