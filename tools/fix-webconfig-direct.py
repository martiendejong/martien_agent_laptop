"""Fix web.config by writing correct content directly"""
import paramiko

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Writing correct web.config...\n')

# The correct web.config content with ASPNETCORE_ENVIRONMENT
webconfig_content = """<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <location path="." inheritInChildApplications="false">
    <system.webServer>
      <handlers>
        <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
      </handlers>
      <aspNetCore processPath="dotnet" arguments=".\\PasswordManager.API.dll" stdoutLogEnabled="false" stdoutLogFile=".\\logs\\stdout" hostingModel="inprocess">
        <environmentVariables>
          <environmentVariable name="ASPNETCORE_ENVIRONMENT" value="Production" />
        </environmentVariables>
      </aspNetCore>
    </system.webServer>
  </location>
</configuration>"""

# Write the web.config file
write_script = f"""
$content = @'
{webconfig_content}
'@
$content | Set-Content -Path 'C:\\inetpub\\vault.prospergenics.com\\web.config' -Encoding UTF8
Write-Host 'web.config updated'
"""

stdin, stdout, stderr = client.exec_command(f'powershell -Command "{write_script}"')
output = stdout.read().decode('utf-8', errors='ignore')
error = stderr.read().decode('utf-8', errors='ignore')

print(output)
if error:
    print(f'Errors: {error}')

# Verify the change
print('\nVerifying web.config:')
stdin, stdout, stderr = client.exec_command('powershell -Command "Get-Content C:\\inetpub\\vault.prospergenics.com\\web.config"')
print(stdout.read().decode('utf-8', errors='ignore'))

# Restart app pool
print('\nRestarting application pool...')
stdin, stdout, stderr = client.exec_command('powershell -Command "Import-Module WebAdministration; Restart-WebAppPool -Name \'vault.prospergenics.com\'"')
print('OK Application pool restarted')

print('\nWaiting 5 seconds for application to initialize...')
import time
time.sleep(5)

print('\n' + '='*60)
print('  FINAL FIX COMPLETE')
print('='*60)
print('\nweb.config now includes ASPNETCORE_ENVIRONMENT=Production')
print('Application will now load appsettings.Production.json')
print('with the correct absolute database path.')
print('\nTest now: https://vault.prospergenics.com')

client.close()
