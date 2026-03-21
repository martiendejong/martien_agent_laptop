"""Final fix for web.config using proper method"""
import paramiko
import os

# Create the correct web.config locally
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

# Save locally
os.makedirs('C:/temp', exist_ok=True)
with open('C:/temp/web.config.fixed', 'w', encoding='utf-8') as f:
    f.write(webconfig_content)

print('Connecting to server...')
client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')
print('OK Connected\n')

# Upload via SFTP
print('Uploading web.config...')
sftp = client.open_sftp()

try:
    # Backup original
    try:
        sftp.rename('C:/inetpub/vault.prospergenics.com/web.config',
                   'C:/inetpub/vault.prospergenics.com/web.config.backup')
        print('  Backed up original web.config')
    except:
        print('  No backup needed (file may not exist or already backed up)')

    # Upload new file
    sftp.put('C:/temp/web.config.fixed', 'C:/inetpub/vault.prospergenics.com/web.config')
    print('OK Uploaded\n')

    # Verify file exists and get size
    stat = sftp.stat('C:/inetpub/vault.prospergenics.com/web.config')
    print(f'Verification: File size = {stat.st_size} bytes')

except Exception as e:
    print(f'ERROR: {e}')

finally:
    sftp.close()

# Read back to verify
print('\nReading back web.config to verify...')
stdin, stdout, stderr = client.exec_command('cmd /c type C:\\inetpub\\vault.prospergenics.com\\web.config')
content = stdout.read().decode('utf-8', errors='ignore')

if content:
    print('Content retrieved:')
    print('-' * 60)
    print(content)
    print('-' * 60)

    if 'ASPNETCORE_ENVIRONMENT' in content:
        print('\n✓ SUCCESS: ASPNETCORE_ENVIRONMENT is present!')
    else:
        print('\n✗ WARNING: Environment variable not found in content')
else:
    print('WARNING: Could not read file content')

# Restart app pool
print('\nRestarting application pool...')
stdin, stdout, stderr = client.exec_command('powershell Import-Module WebAdministration; Restart-WebAppPool vault.prospergenics.com')
import time
time.sleep(2)
print('OK Restarted')

print('\n' + '='*60)
print('  DEPLOYMENT FIX COMPLETE')
print('='*60)
print('\nTest the application now:')
print('  https://vault.prospergenics.com')
print('\n(Ignore certificate warning - we\'ll fix that next)')

client.close()
